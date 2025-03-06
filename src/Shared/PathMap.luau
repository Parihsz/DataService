local Template = require(script.Parent.Template)
local Data = require(script.Parent.Data)

type DataTemplate = { [string]: any }
type PathEntry = { fullKey: string, parent: DataTemplate?, key: string }

local PathMap = {}

local pathToId = {} :: { [string]: number }
local idToMapping = {} :: { [number]: { tab: DataTemplate?, key: string } }
local allPaths = {} :: { PathEntry }

local function FromPrefix(data: DataTemplate, prefix: string): DataTemplate
	if prefix == "" then
		return data
	end
	local parent = data

	for _, k in string.split(prefix, ".") do
		parent = (parent :: any)[k]
		if not parent then
			break
		end
	end

	return parent
end

local function GetPaths(mapping: DataTemplate, data: DataTemplate, prefix: string?)
	prefix = prefix or ""
	for key, value in mapping do
		local fullKey = (prefix == "" and key or `"{prefix}.{key}"`)

		table.insert(allPaths, { fullKey = fullKey, parent = FromPrefix(data, prefix :: string), key = key })

		if type(value) == "table" then
			GetPaths(value, data, fullKey)
		end
	end
end

local data, _, typeMapping = Data.Extract(Template)
GetPaths(typeMapping, data)

table.sort(allPaths, function(a, b)
	return a.fullKey < b.fullKey
end)

for i, entry in allPaths do
	pathToId[entry.fullKey] = i
	idToMapping[i] = { tab = entry.parent, key = entry.key }
end

function PathMap.GetId(path: string): number?
	return pathToId[path]
end

function PathMap.GetMapping(id: number): { tab: DataTemplate?, key: string }?
	return idToMapping[id]
end

PathMap.PathToId = pathToId
PathMap.IdToMapping = idToMapping

return PathMap
