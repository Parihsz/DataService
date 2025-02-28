return {
	boolean = function(writer, value)
		writer:Writeu8(value and 1 or 0)
	end,
	vector = function(writer, value)
		writer:Writef32(value.X)
		writer:Writef32(value.Y)
		writer:Writef32(value.Z)
	end,
	CFrame = function(writer, value)
		writer:Writef32(value.Position.X)
		writer:Writef32(value.Position.Y)
		writer:Writef32(value.Position.Z)

		local a, b, c, d, e, f, g, h, i = value:GetComponents()
		writer:Writef32(a)
		writer:Writef32(b)
		writer:Writef32(c)
		writer:Writef32(d)
		writer:Writef32(e)
		writer:Writef32(f)
		writer:Writef32(g)
		writer:Writef32(h)
		writer:Writef32(i)
	end,
}
