local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileService = require(ServerStorage.Services.ProfileService)
local IndexFunctions = require(ReplicatedStorage.Utils.IndexFunctions)
local Signal = require(ReplicatedStorage.Utils.Signal)

local DataService = {}

type notReleasedHandler =  (number?, number?) -> ("Repeat" | "Cancel" | "ForceLoad" | "Steal")

type Signal = Signal.Signal

export type keyPath = string | {string}

local dataTemplate = require(game.ServerStorage.DataTemplate)

local tempDataTemplate = {

}

local profiles = {}
local tempData = {}
local signals = {}

local playerData = ProfileService.GetProfileStore("PlayerData", dataTemplate)

DataService.DataChanged = Signal.new()
DataService.DataLoaded = Signal.new()

local function deepCopy(oldTable: {[any]: any})
	local newTable = {}
	for i, v in oldTable do
		if typeof(v) == "table" then
			newTable[i] = deepCopy(v)
			continue
		end
		newTable[i] = v
	end
	return newTable
end

local function onPlayerAdded(player: Player)
	local userId = player.UserId
	local profile = playerData:LoadProfileAsync(tostring(userId))
	if not profile then
		player:Kick("Failed to load profile!")
		return
	end
	profile:AddUserId(userId)
	profile:Reconcile()
	profile:ListenToRelease(function()
		profiles[player] = nil
		tempData[player] = nil
		player:Kick("Profile released!")
	end)
	if not player:IsDescendantOf(Players) then
		profile:Release()
		return
	end
	profiles[player] = profile
	tempData[player] = deepCopy(tempDataTemplate)
	DataService.DataLoaded:Fire(player, profile.Data)
end

local function onPlayerRemoving(player: Player)
	local profile = profiles[player]
	if not profile then
		return
	end
	profile:Release()
end

local function onDataChanged(player: Player, keyPath: keyPath, newValue: any)
	local signal = signals[keyPath]
	if signal then
		signal:Fire(player, newValue)
	end
end

function DataService.SetDataInternal(player: Player, keyPath: keyPath, newValue: any): boolean
	local profile = profiles[player]
	if not profile then
		warn("Profile does not exist!")
		return false
	end
	local data = profile.Data
	IndexFunctions.SetData(data, keyPath, newValue)
	return true
end

function DataService.SetTempDataInternal(player: Player, keyPath: keyPath, newValue: any): boolean
	local data = tempData[player]
	if not data then
		warn("Data does not exist!")
		return false
	end
	IndexFunctions.SetData(data, keyPath, newValue)
	return true
end

function DataService.SetTempData(player: Player, keyPath: keyPath, newValue: any)
	local success = DataService.SetTempDataInternal(player, keyPath, newValue)
	if not success then
		return
	end
	DataService.DataChanged:Fire(player, keyPath, newValue)
end

function DataService.SetData(player: Player, keyPath: keyPath, newValue: any)
	local success = DataService.SetDataInternal(player, keyPath, newValue)
	if not success then
		return
	end
	DataService.DataChanged:Fire(player, keyPath, newValue)
end

function DataService.GetTempData(player: Player, keyPath: keyPath?): any
	local data = tempData[player]
	if not keyPath then
		return data
	end
	if not data then
		warn("Data does not exist!")
		return
	end
	return IndexFunctions.GetData(data, keyPath)
end

function DataService.GetData(player: Player, keyPath: keyPath?): any
	local data = profiles[player]
	if not keyPath then
		return data
	end
	if not data then
		warn("Profile does not exist!")
		return
	end
	return IndexFunctions.GetData(data, keyPath)
end

function DataService.LoadProfile(userId: number, notReleasedHandler: notReleasedHandler?)
	return playerData:LoadProfileAsync(tostring(userId), notReleasedHandler)
end

function DataService.GetDataChangedSignal(key: string): Signal
	local signal = signals[key]
	if signal then
		return signal
	end
	signal = Signal.new()
	signals[key] = signal
	return signal
end

function DataService.Initialize()
	DataService.DataChanged:Connect(onDataChanged)
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return DataService