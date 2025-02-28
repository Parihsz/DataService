local Vlq = require(script.Parent.Parent.Vlq)

local Writer = {}

export type Writer = {
	buff: buffer,
	cursorPosition: number,

	Writeu8: (self: Writer, value: number) -> nil,
	Writeu16: (self: Writer, value: number) -> nil,
	Writeu32: (self: Writer, value: number) -> nil,
	Writei16: (self: Writer, value: number) -> nil,
	Writei32: (self: Writer, value: number) -> nil,
	Writef32: (self: Writer, value: number) -> nil,
	Writef64: (self: Writer, value: number) -> nil,
	WriteString: (self: Writer, value: string) -> nil,
}

function Writer.new()
	local self = {
		buff = buffer.create(100),
		cursorPosition = 1,
	}

	function self.Writeu8(self: Writer, value: number)
		buffer.writeu8(self.buff, self.cursorPosition, value)
		self.cursorPosition += 1
	end

	function self.Writeu16(self: Writer, value: number)
		buffer.writeu16(self.buff, self.cursorPosition, value)
		self.cursorPosition += 2
	end

	function self.Writeu32(self: Writer, value: number)
		buffer.writeu32(self.buff, self.cursorPosition, value)
		self.cursorPosition += 4
	end

	function self.Writei16(self: Writer, value: number)
		buffer.writei16(self.buff, self.cursorPosition, value)
		self.cursorPosition += 2
	end

	function self.Writei32(self: Writer, value: number)
		buffer.writei32(self.buff, self.cursorPosition, value)
		self.cursorPosition += 4
	end

	function self.Writef32(self: Writer, value: number)
		buffer.writef32(self.buff, self.cursorPosition, value)
		self.cursorPosition += 4
	end

	function self.Writef64(self: Writer, value: number)
		buffer.writef64(self.buff, self.cursorPosition, value)
		self.cursorPosition += 8
	end

	function self.WriteString(self: Writer, value: string)
		local length = #value
		Vlq.Encode(self, length)
		buffer.writestring(self.buff, self.cursorPosition, value)
		self.cursorPosition += length
	end

	return self
end

return Writer
