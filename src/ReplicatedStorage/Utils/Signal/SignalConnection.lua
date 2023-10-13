--!nonstrict
local SignalConnection = {}
SignalConnection.__index = SignalConnection

export type func = (...any) -> (...any)

export type SignalConnection = typeof(setmetatable({}, SignalConnection)) & {
	Signal: any,
	Callback: func
}

function SignalConnection.new(signal: any, callback: any)
	local self = setmetatable({}, SignalConnection)
	self.Signal = signal
	self.Callback = callback
	return self
end

function SignalConnection:Disconnect()
	local signal = self.Signal
	local index = table.find(signal.Callbacks, self.Callback)
	if not index then
		warn("Attempted to disconnect object already disconnected!")
		return nil
	end
	table.remove(signal.Callbacks, index)
	table.remove(signal.Names, index)
	return true
end

return SignalConnection