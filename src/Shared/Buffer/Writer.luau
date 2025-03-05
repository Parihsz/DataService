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

local GROWTH_FACTOR = 1.5

local function realloc(self: Writer, bytes: number)
	local b = self.buff
	local p = self.cursorPosition
	local len = buffer.len(b)

	if len < (p + bytes) then
		if len == 0 then
			len = 1
		end
		local exponent = math.ceil(math.log((bytes + p) / len, GROWTH_FACTOR))
		local new = buffer.create(len * GROWTH_FACTOR ^ exponent)
		buffer.copy(new, 0, b, 0)
		self.buff = new
	end
end

function Writer.new()
    local self = {
        buff = buffer.create(16), 
        cursorPosition = 1,
    }

    function self.Writeu8(self: Writer, value: number)
        realloc(self, 1)
        buffer.writeu8(self.buff, self.cursorPosition, value)
        self.cursorPosition += 1
    end

    function self.Writeu16(self: Writer, value: number)
        realloc(self, 2)
        buffer.writeu16(self.buff, self.cursorPosition, value)
        self.cursorPosition += 2
    end

    function self.Writeu32(self: Writer, value: number)
        realloc(self, 4)
        buffer.writeu32(self.buff, self.cursorPosition, value)
        self.cursorPosition += 4
    end

    function self.Writei16(self: Writer, value: number)
        realloc(self, 2)
        buffer.writei16(self.buff, self.cursorPosition, value)
        self.cursorPosition += 2
    end

    function self.Writei32(self: Writer, value: number)
        realloc(self, 4)
        buffer.writei32(self.buff, self.cursorPosition, value)
        self.cursorPosition += 4
    end

    function self.Writef32(self: Writer, value: number)
        realloc(self, 4)
        buffer.writef32(self.buff, self.cursorPosition, value)
        self.cursorPosition += 4
    end

    function self.Writef64(self: Writer, value: number)
        realloc(self, 8)
        buffer.writef64(self.buff, self.cursorPosition, value)
        self.cursorPosition += 8
    end

    function self.WriteString(self: Writer, value: string)
        local length = #value
        realloc(self, length + 4) 
        Vlq.Encode(self, length)
        buffer.writestring(self.buff, self.cursorPosition, value)
        self.cursorPosition += length
    end

    return self
end

return Writer
