local Serializer = {}

local SerializerMap = require(script.Parent.SerializationMap)
local DeserializationMap = require(script.Parent.DeserializationMap)

local function SerializeTable(table, writer, customType)
	for key, value in table do
		writer:WriteString(key)
		local dataType

		if type(value) == "table" then
			dataType = "table"
			writer:WriteString(dataType)
			SerializeTable(value, writer, dataType)
		else
			dataType = customType
			writer:WriteString(dataType)
			local writeFunction = writer[`Write{dataType}`]

			if writeFunction then
				writeFunction(writer, value, customType)
			elseif SerializerMap[dataType] then
				SerializerMap[dataType](writer, value, customType)
			else
				warn(`Unsupported data type: {dataType}`)
			end
		end
	end

	writer:WriteString("END")
end

local function DeserializeTable(reader, customType)
	local table = {}

	while true do
		local key = reader:ReadString()
		if key == "END" then
			break
		end
		local dataType = reader:ReadString()
		if dataType == "table" then
			table[key] = DeserializeTable(reader, dataType)
		else
			local readFunction = reader[`Read{dataType}`]
			if readFunction then
				table[key] = readFunction(reader, customType)
			elseif DeserializationMap[dataType] then
				table[key] = DeserializationMap[dataType](reader, customType)
			else
				warn(`Unsupported data type: {dataType}`)
			end
		end
	end

	return table
end

function Serializer.Serialize(template, writer, customType)
	SerializeTable(template, writer, customType)
end

function Serializer.Deserialize(reader, customType)
	return DeserializeTable(reader, customType)
end

return Serializer
