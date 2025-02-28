local Vlq = require(script.Parent.Parent.Vlq)

local Reader = {}

export type Reader = {
	buff: buffer,
	cursorPosition: number,

	Readu8: (self: Reader) -> number,
	Readu16: (self: Reader) -> number,
	Readu32: (self: Reader) -> number,
	Readi16: (self: Reader) -> number,
	Readi32: (self: Reader) -> number,
	Readf32: (self: Reader) -> number,
	Readf64: (self: Reader) -> number,
	ReadString: (self: Reader) -> string,
}

function Reader.new(buff: buffer): Reader
	local self = {
		buff = buff,
		cursorPosition = 1,
	}

	function self.Readu8(self: Reader): number
		local value = buffer.readu8(buff, self.cursorPosition)
		self.cursorPosition += 1
		return value
	end

	function self.Readu16(self: Reader): number
		local value = buffer.readu16(buff, self.cursorPosition)
		self.cursorPosition += 2
		return value
	end

	function self.Readu32(self: Reader): number
		local value = buffer.readu32(buff, self.cursorPosition)
		self.cursorPosition += 4
		return value
	end

	function self.Readi16(self: Reader): number
		local value = buffer.readi16(buff, self.cursorPosition)
		self.cursorPosition += 2
		return value
	end

	function self.Readi32(self: Reader): number
		local value = buffer.readi32(buff, self.cursorPosition)
		self.cursorPosition += 4
		return value
	end

	function self.Readf32(self: Reader): number
		local value = buffer.readf32(buff, self.cursorPosition)
		self.cursorPosition += 4
		return value
	end

	function self.Readf64(self: Reader): number
		local value = buffer.readf64(buff, self.cursorPosition)
		self.cursorPosition += 8
		return value
	end

	function self.ReadString(self: Reader): string
		local len = Vlq.Decode(self)
		local value = buffer.readstring(buff, self.cursorPosition, len)
		self.cursorPosition += len
		return value
	end

	return self
end

return Reader
