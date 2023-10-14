# DataService
DataService is a ProfileService wrapper, that's about it.

# Usage

### Initializing
Proceed to ServerStorage -> DateTemplate
```lua
--Initalize the data template so it's ready to be used.
local dataTemplate = {
    Inventory = {}
}
return dataTemplate
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

