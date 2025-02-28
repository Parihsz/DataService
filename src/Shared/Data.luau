export type ReplicationLevel = "Public" | "Private"
export type ReplicationDefinition = {
	[string]: ReplicationLevel | ReplicationDefinition,
}

export type FieldType =
	| "u8"
	| "u16"
	| "u32"
	| "i8"
	| "i16"
	| "i32"
	| "f16"
	| "f32"
	| "f64"
	| "vector"
	| "buffer"
	| "string"
	| "boolean"
	| "CFrame"
	| "Color3"
	| "Instance"

export type Field<T> = {
	value: T,
	replication: ReplicationLevel,
	type: FieldType,
}

local Data = {}
Data.VERSION = 1

local function DataType<T, F>(typeName: T & FieldType)
	return function(replication: ReplicationLevel, value: F): Field<F>
		return {
			value = value,
			replication = replication,
			type = typeName,
		}
	end
end

Data.u8 = DataType("u8")
Data.u16 = DataType("u16")
Data.u32 = DataType("u32")
Data.i8 = DataType("i8")
Data.i16 = DataType("i16")
Data.i32 = DataType("i32")
Data.f16 = DataType("f16")
Data.f32 = DataType("f32")
Data.f64 = DataType("f64")
Data.vector = DataType("vector")
Data.string = DataType("string")
Data.boolean = DataType("boolean")
Data.CFrame = DataType("CFrame")
Data.Color3 = DataType("Color3")
Data.Instance = DataType("Instance")

function Data.Extract(template: { [string]: any }): ({ [string]: any }, ReplicationDefinition, { [string]: any })
	local data = {}
	local replication = {}
	local types = {}

	for key, value in template do
		if type(value) == "table" and value.value ~= nil and value.replication ~= nil and value.type then
			data[key] = value.value
			replication[key] = value.replication
			types[key] = value.type
		elseif type(value) == "table" then
			local subData, subDef, subTypes = Data.Extract(value)
			data[key] = subData
			replication[key] = subDef
			types[key] = subTypes
		else
			data[key] = value
			replication[key] = "Private"
		end
	end

	return data, replication, types
end

return Data
