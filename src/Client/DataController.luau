local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Future = require(ReplicatedStorage.Shared.Utils.Future)
local Signal = require(ReplicatedStorage.Shared.Utils.Signal)
local SerDes = require(ReplicatedStorage.Shared.SerDes)
local Reader = require(ReplicatedStorage.Shared.Buffer.Reader)
local Data = require(ReplicatedStorage.Shared.Data)
local Template = require(ReplicatedStorage.Shared.Template)
local PublicData = require(script.Parent.PublicData)
local PathMapping = require(ReplicatedStorage.Shared.PathMap)

local DataController = {}

local data: Template.Data? = nil

DataController.Updated = Signal()

local _, _, typeMapping = Data.Extract(Template)

local fieldTypes = {}

local function CacheFieldTypes(prefix: string?, mapping: { [string]: any })
	for key, value in mapping do
		local fullKey = prefix and `{prefix}.{key}` or key

		if type(value) == "table" then
			fieldTypes[fullKey] = "table"
			CacheFieldTypes(fullKey, value)
		else
			fieldTypes[fullKey] = value
		end
	end
end

CacheFieldTypes(nil, typeMapping)

local function GetFieldType(key: string)
	return fieldTypes[key] or "table"
end

local function HandleReplicateData(idOrFull: string | number, keyOrData: any, serialized: any, player: Player?)
	if idOrFull == "FullData" then
		if player then
			PublicData.UpdateData(player, idOrFull, keyOrData)
			if player == Players.LocalPlayer then
				data = keyOrData
				DataController.Updated:Fire(data)
			end
		else
			data = keyOrData
			DataController.Updated:Fire(data)
		end
		return
	end

	local parent = PathMapping.GetPointer(idOrFull :: number)

	if not parent then
		warn(`No table reference found for ID {idOrFull}`)
		return
	end

	local fieldType = GetFieldType(keyOrData) or "table"
	local reader = Reader.new(serialized)
	local update = SerDes.Deserialize(reader :: any, fieldType)

	if type(update) == "table" and update[keyOrData] ~= nil then
		update = update[keyOrData]
	end

	PathMapping.UpdateById(idOrFull :: number, keyOrData, update)

	if player then
		PublicData.UpdateData(player, keyOrData, update)
		if player == Players.LocalPlayer then
			data = PathMapping.GetPointer()
			DataController.Updated:Fire(data)
		end
	else
		data = PathMapping.GetPointer()
		DataController.Updated:Fire(data)
	end
end

function DataController.GetData(): Future.Future<any>
	return Future.new(function()
		if not data then
			data = DataController.Updated:Wait()
		end
		return data
	end)
end

function DataController.UnwrapData(): Template.Data?
	return data
end

local function Initialize()
	local extractedData, _, _ = Data.Extract(Template :: any)
	data = extractedData

	PathMapping.AssignIds(data)

	local NETWORK_CHANGE = ReplicatedStorage:WaitForChild("NETWORK_CHANGE")
	NETWORK_CHANGE.OnClientEvent:Connect(HandleReplicateData)
end

task.spawn(Initialize)

return DataController
