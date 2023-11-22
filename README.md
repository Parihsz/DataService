# DataService
DataService is a ProfileService wrapper, that's about it. 

Heavily abstracted, literally uses a good chunk of PS documentation code under the hood.
Listens for playeradded for you, uses a signal implementation to alert other scripts when a profile has been loaded.

## Installation

Model: https://create.roblox.com/marketplace/asset/15066046821/DataService

## Usage

### Initializing
Proceed to ServerStorage -> DateTemplate
```lua
--Initalize the data template so it's ready to be used.
local dataTemplate = {
    coins = 0
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
DataService.SetData(player, "coins", 5) --setting coins data
```

### Getting Data
```lua
local data = DataService.GetData(player, "coins")
--retrieves the coins data along with attached metadata
```

