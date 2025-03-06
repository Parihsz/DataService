local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Utils.Signal)
local PathMapping = require(ReplicatedStorage.Shared.PathMap)

local PublicData = {}

local data = {}
local cache = {}

PublicData.Updated = Signal()

function PublicData.UpdateData(player: Player, key: string, update)
	data[player] = data[player] or {}

	if key == "FullData" then
		data[player] = update
		cache[player] = {}
	else
		cache[player] = cache[player] or {}
		local pointer = cache[player][key]

		if not pointer then
			pointer = PathMapping.GetPointer(data[player], key)
			if pointer then
				cache[player][key] = pointer
			end
		end

		if pointer then
			pointer.parent[pointer.key] = update[key]
		end
	end

	PublicData.Updated:Fire(player, data[player])
end

function PublicData.GetData(player)
	return data[player]
end

Players.PlayerRemoving:Connect(function(player)
	data[player] = nil
	cache[player] = nil
end)

return PublicData
