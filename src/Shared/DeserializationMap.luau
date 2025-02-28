return {
	boolean = function(reader)
		return reader:Readu8() == 1
	end,
	vector = function(reader)
		return Vector3.new(reader:Readf32(), reader:Readf32(), reader:Readf32())
	end,
	CFrame = function(reader)
		return CFrame.fromMatrix(
			Vector3.new(reader:Readf32(), reader:Readf32(), reader:Readf32()),
			Vector3.new(reader:Readf32(), reader:Readf32(), reader:Readf32()),
			Vector3.new(reader:Readf32(), reader:Readf32(), reader:Readf32())
		)
	end,
}
