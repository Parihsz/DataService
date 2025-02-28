export type ReplicationLevel = "Public" | "Private"
export type ReplicationDefinition = {
	[string]: ReplicationLevel | ReplicationDefinition,
}

export type Field<T> = {
	value: T,
	replication: ReplicationLevel,
	type: "u8"
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
		| "Instance",
}

local Data = {}
Data.VERSION = 1

function Data.u8(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "u8" }
end

function Data.u16(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "u16" }
end

function Data.u32(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "u32" }
end

function Data.i8(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "i8" }
end

function Data.i16(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "i16" }
end

function Data.i32(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "i32" }
end

function Data.f16(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "f16" }
end

function Data.f32(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "f32" }
end

function Data.f64(replication: ReplicationLevel, value: number): Field<number>
	return { value = value, replication = replication, type = "f64" }
end

function Data.vector(replication: ReplicationLevel, value: Vector3): Field<Vector3>
	return { value = value, replication = replication, type = "vector" }
end

function Data.string(replication: ReplicationLevel, value: string): Field<string>
	return { value = value, replication = replication, type = "string" }
end

function Data.boolean(replication: ReplicationLevel, value: boolean): Field<boolean>
	return { value = value, replication = replication, type = "boolean" }
end

function Data.CFrame(replication: ReplicationLevel, value: CFrame): Field<CFrame>
	return { value = value, replication = replication, type = "CFrame" }
end

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
