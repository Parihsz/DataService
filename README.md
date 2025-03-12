# DataService
This is a ProfileService wrapper, allowing you to safely read/write data within a single entry point while providing optimized networking. The main feature for this wrapper would be its serialization capabilities - 100% blazingly fast!⚡

This can be used outside of data tables 
* any form of state tracking and networking can be done with this. Simply use ``.MakeNetworkable(player, template)``

This library does not implement any compression for saving itself because that is not really a common usecase. However, our serdes tools can easily support that if you want to DIY!

### Woahhh how to use!
To start, head over to Template and simply define a schema with the necessary data type to serialize to:
```luau
local u32 = Data.u32
local f32 = Data.f32
local str = Data.string

local dataTemplate: Data = {
	firstTime = boolean("Public", true),

	xp = f32("Public", 0),
	requiredXp = f32("Public", 100),
	level = u32("Public", 1),

	alignment = str("Public", "Jedi"),
	gender = str("Public", "Male"),
}
```
DataService will attach the type as a metadata, automatically track changes (using recursively set shadow tables) and network it for you in an efficient manner.
Manually declaring the serialization format is a lot more efficient than dynamically serializing to maximum precision!

### Net Filters :O
* 🔓Public -> Replicates to all clients
* 🔐Private -> Only replicate to specific client
* 🔒Protected -> Does not replicate. (period added for aura farming)
