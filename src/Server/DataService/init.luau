local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ProfileService = require(script.ProfileService)
local Data = require(ReplicatedStorage.Shared.Data)
local Template = require(ReplicatedStorage.Shared.Template)
local Future = require(ReplicatedStorage.Shared.Utils.Future)
local SerDes = require(ReplicatedStorage.Shared.SerDes)
local Writer = require(ReplicatedStorage.Shared.Buffer.Writer)
local PathMap = require(ReplicatedStorage.Shared.PathMap)

local DataService = {}

local STORE = `PlayerDataV{Data.VERSION}`
local PREFIX = "Player_"

local ProfileStore = assert(ProfileService.GetProfileStore(STORE, Template), "Failed to load profile store")

type NotReleasedHandler = (number?, number?) -> "Repeat" | "Cancel" | "ForceLoad" | "Steal"

type Data = Template.Data
type ReplicationDefinition = Data.ReplicationDefinition
type ReplicationLevel = Data.ReplicationLevel

local profiles: { [Player]: any } = {}
local tempData: { [Player]: any } = {}

local NETWORK_CHANGE = Instance.new("RemoteEvent")
NETWORK_CHANGE.Name = "NETWORK_CHANGE"
NETWORK_CHANGE.Parent = ReplicatedStorage

local Signal = require(ReplicatedStorage.Shared.Utils.Signal)
DataService.DataLoaded = Signal()
DataService.DataChanged = Signal()

local function GetKey(userId: number): string
	return `{PREFIX}{userId}`
end

local function Replicate(
	player: Player,
	key: any,
	value: any,
	fieldType: Data.FieldType,
	replicationLevel: Data.ReplicationLevel
)
	local writer = Writer.new()
	SerDes.Serialize({ [key] = value }, writer :: any, fieldType)
	local serialized = writer.buff

	local keyId = PathMap.GetId(key)
	local toSend = keyId or key

	if replicationLevel == "Public" then
		NETWORK_CHANGE:FireAllClients(toSend, serialized, player)
	elseif replicationLevel == "Private" then
		NETWORK_CHANGE:FireClient(player, toSend, serialized)
	end
end

local function PlayerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync(GetKey(player.UserId))
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()

		profile:ListenToRelease(function()
			profiles[player] = nil
			player:Kick()
			return
		end)

		if player.Parent == Players then
			profiles[player] = profile
		else
			profile:Release()
		end

		profile.Data = DataService.MakeNetworkable(player, profile.Data)
		local data, _, _ = Data.Extract(Template :: any)

		DataService.DataLoaded:Fire(player, data)
		NETWORK_CHANGE:FireClient(player, "FullData", data)
	else
		player:Kick()
	end
end

local function PlayerRemoving(player: Player)
	local profile = profiles[player]
	if profile then
		profile:Release()
	end
	profiles[player] = nil
	tempData[player] = nil
end

local function OnDataChanged(player: Player, key: string, value: any)
	DataService.DataChanged:Fire(player, key, value)
end

function DataService.MakeNetworkable<T>(player: Player, dataTemplate: T): T
	local data, replicationDefinition, typeDefinition = Data.Extract(dataTemplate :: any)

	local function CreateShadowTable(
		default: { [string]: any },
		definition: ReplicationDefinition,
		types: { [string]: any },
		parentKey: string?
	): any
		local shadowTable = {}

		setmetatable(shadowTable, {
			__index = default,
			__newindex = function(_, key: string, value: any)
				local fullKey = parentKey and `{parentKey}.{key}` or key

				if type(value) == "table" then
					local subData, subDef, subTypes = Data.Extract(value)
					value = CreateShadowTable(subData, subDef, subTypes, fullKey)
				end

				default[key] = value

				local localReplication = definition[key]
				if type(localReplication) == "table" then
					localReplication = "Private"
				end

				local replicationLevel = localReplication or "Private"

				local fieldType = types[key]
				Replicate(player, fullKey, value, fieldType, replicationLevel :: ReplicationLevel)

				OnDataChanged(player, fullKey, value)
			end,
		})

		for k, v in default do
			if type(v) == "table" then
				local nestedTypes = {}

				if type(types[k]) == "table" then
					nestedTypes = types[k]
				end

				local nested: ReplicationDefinition = {}
				if type(definition[k]) == "table" then
					nested = definition[k] :: ReplicationDefinition
				end

				default[k] = CreateShadowTable(v, nested, nestedTypes, parentKey and `{parentKey}.{k}` or k)
			end
		end

		return shadowTable
	end

	return CreateShadowTable(data, replicationDefinition, typeDefinition, nil)
end

function DataService.GetData(player: Player)
	return Future.new(function(): Data?
		while player.Parent ~= nil and not profiles[player] do
			task.wait()
		end

		local profile = profiles[player]
		if profile then
			return profile.Data
		else
			return nil
		end
	end)
end

function DataService.UpdateData(player: Player, mutate: (data: Data) -> (), ...): ()
	return Future.new(function(...)
		local data = DataService.GetData(player):Await()
		if not data then
			return nil
		end

		local yielded = true
		task.spawn(function(...)
			mutate(data, ...)
			yielded = false
		end, ...)

		if yielded then
			warn(debug.traceback("Data transform function yielded!"))
		end

		return nil
	end, ...)
end

function DataService.SetTempData(player: Player, newTemp: any): ()
	tempData[player] = newTemp
	DataService.DataChanged:Fire(player, newTemp)
end

function DataService.GetTempData(player: Player): any
	return tempData[player]
end

Players.PlayerAdded:Connect(PlayerAdded)
Players.PlayerRemoving:Connect(PlayerRemoving)

return DataService
