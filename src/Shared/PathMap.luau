local PathMap = {}
local pointerToId = {}
local idToPointer = {}

local incrementalUID = 0
local root = nil

local function AssignId(table)
	if not pointerToId[table] then
		incrementalUID += 1
		pointerToId[table] = incrementalUID
		idToPointer[incrementalUID] = table
	end
end

local function AssignIds(node)
	if type(node) ~= "table" then
		return
	end

	if not root then
		root = node
	end

	AssignId(node)

	for _, child in node do
		if type(child) == "table" then
			AssignIds(child)
		end
	end
end

function PathMap.GetId(table)
	return pointerToId[table]
end

function PathMap.GetPointer(id: number?)
	if not id then
		return root
	end
	return idToPointer[id]
end

function PathMap.UpdateById(parentId: number, key: any, value: any)
	local parentRef = idToPointer[parentId]
	if parentRef then
		parentRef[key] = value
	else
		warn("No table reference found for ID", parentId)
	end
end

PathMap.AssignIds = AssignIds

return PathMap
