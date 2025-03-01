local PublicData = {}
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Utils.Signal)

local data = {}

PublicData.Updated = Signal()

local function ApplyUpdates(root: any, path: string, value: any): ()
	local keys = path:split(".")
	local node = root

	for i = 1, #keys - 1 do
		node[keys[i]] = node[keys[i]] or {}
		node = node[keys[i]]
	end

	node[keys[#keys]] = value
end

function PublicData.UpdateData(player: Player, key: string, update)
	data[player] = data[player] or {}

	if key == "FullData" then
		data[player] = update
	else
		ApplyUpdates(data[player], key, update[key])
	end

	PublicData.Updated:Fire(player, data[player])
end

function PublicData.GetData(player)
	return data[player]
end

return PublicData
