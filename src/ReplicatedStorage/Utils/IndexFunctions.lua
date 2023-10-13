local IndexFunctions = {}

function IndexFunctions.GetPath(keyPath: string | {string}): {string}
	local path
	if typeof(keyPath) == "table" then
		path = keyPath
	else
		path = keyPath:split(".")
	end
	return path
end

function IndexFunctions.GetData(data: {any}, keyPath: string | {string}): any
	local path = IndexFunctions.GetPath(keyPath)
	local dataTemp = data
	while #path > 0 do
		dataTemp = dataTemp[table.remove(path, 1)]
		if dataTemp == nil then
			warn("No value at index!")
			return nil
		end
	end
	return dataTemp
end

function IndexFunctions.SetData(data: {any}, keyPath: string | {string}, value: any): boolean
	local path = IndexFunctions.GetPath(keyPath)
	while #path > 1 do
		local index = table.remove(path, 1)
		if not data[index] then
			warn("Cannot index nil!")
			return false
		end
		data = data[index]
	end
	local key = path[1]
	data[key] = value
	return true
end

return IndexFunctions