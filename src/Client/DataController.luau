local ReplicatedStorage = game:GetService("ReplicatedStorage")

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

local function ApplyUpdates(root: any, path: string, value: any): ()
	local keys = path:split(".")
	local node = root

	for i = 1, #keys - 1 do
		node[keys[i]] = node[keys[i]] or {}
		node = node[keys[i]]
	end

	node[keys[#keys]] = value
end

local function HandleReplicateData(keyOrId: string | number, serialized: any, player: Player?): ()
	if keyOrId == "FullData" then
		if player then
			PublicData.UpdateData(player, keyOrId, serialized)
		else
			data = serialized
			DataController.Updated:Fire(data)
		end
		return
	end

	local path: string
	if typeof(keyOrId) == "number" then
		local mapping = PathMapping.GetMapping(keyOrId)
		if not mapping then
			warn(`No path mapping found for ID {keyOrId}`)
			return
		end
		path = mapping.key
	else
		path = keyOrId
	end

	if not path then
		warn("path is nil")
		return
	end

	local reader = Reader.new(serialized)
	local fieldType = GetFieldType(path) or "table"
	local update = SerDes.Deserialize(reader :: any, fieldType)

	if player then
		PublicData.UpdateData(player, path, update)
	else
		ApplyUpdates(data, path, update[path])
		DataController.Updated:Fire(data)
	end
end

function DataController.GetData(): Future.Future<any>
	return Future.new(function()
		if not data then
			return DataController.Updated:Wait()
		end
		return data
	end)
end

function DataController.UnwrapData(): Template.Data?
	return data
end

local function Initialize()
	local NETWORK_CHANGE = ReplicatedStorage:WaitForChild("NETWORK_CHANGE")
	NETWORK_CHANGE.OnClientEvent:Connect(HandleReplicateData)
end

task.spawn(Initialize)

task.delay(5, function()
	print(DataController.GetData():Unwrap())
end)

return DataController
