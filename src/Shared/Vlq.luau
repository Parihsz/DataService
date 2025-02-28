return {
	Encode = function(writer, value: number)
		repeat
			local byte = bit32.band(value, 0x7F)
			value = bit32.rshift(value, 7)

			if value > 0 then
				byte = bit32.bor(byte, 0x80)
			end

			writer:Writeu8(byte)
		until value == 0
	end,

	Decode = function(reader)
		local value = 0
		local shift = 0
		local byte: number

		repeat
			byte = reader:Readu8()
			value = bit32.bor(value, bit32.lshift(bit32.band(byte, 0x7F), shift))
			shift = shift + 7
		until bit32.band(byte, 0x80) == 0

		return value
	end,
}
