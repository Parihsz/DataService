# DataService
DataService is a ProfileService wrapper, that's about it.

## Installation

Model: https://create.roblox.com/marketplace/asset/15066046821/DataService

## Usage

### Initializing
Proceed to ServerStorage -> DateTemplate
```lua
--Initalize the data template so it's ready to be used.
local dataTemplate = {
    Inventory = {}
}
return dataTemplate
```

Initialize DataService
```lua
local DataService = require(Path)
DataService.Initialize()
```

All Set!

### Wait for Data to load properly
```lua
DataService.DataLoaded:Connect(onDataLoaded)
--set up your onDatLoaded function to utilize the loaded profile!
```

### Setting Data
```lua
local DataService = require(Path)
DataService.SetData(player, "Inventory", {"Sword", "Sword2"}) --setting inventory data
```

### Getting Data
```lua
local data = DataService.GetData(player, "Inventory")
--retrieves the inventory data along with attached metadata
```

