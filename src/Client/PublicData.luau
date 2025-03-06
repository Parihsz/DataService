local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Utils.Signal)

local PublicData = {}

local data = {}

PublicData.Updated = Signal()

function PublicData.UpdateData(player: Player, key: string, update)
	data[player] = data[player] or {}

	if key == "FullData" then
		data[player] = update
	else
		data[player][key] = update
	end

	PublicData.Updated:Fire(player, data[player])
end

function PublicData.GetData(player)
	return data[player]
end

Players.PlayerRemoving:Connect(function(player)
	data[player] = nil
end)

return PublicData
