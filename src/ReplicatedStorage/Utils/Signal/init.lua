local RunService = game:GetService("RunService")

local SignalConnection = require(script:WaitForChild("SignalConnection"))

local Signal = {}
Signal.__index = Signal
Signal.ClassName = "Signal"

type func = (...any) -> (...any)
type SignalConnection = SignalConnection.SignalConnection

export type Signal = typeof(setmetatable({}, Signal)) & {
	Callbacks: {func},
	Names: {[number]: string?},
	Status: string,
	_internalConnection: RBXScriptConnection,
	DestroyFunction: func
}

local function callbackAtIndex(signal: Signal, index: number): boolean
	if signal.Callbacks[index] then
		return true
	end
	return false
end

local function connectInternal(signal: Signal, callback: func, priority: number)
	if signal.Status == "Inactive" then
		warn("Cannot connect to inactive signal!")
	end
	if callbackAtIndex(signal, priority) then
		warn("Callback already at index", priority)
	end
	if priority then
		table.insert(signal.Callbacks, priority, callback)
	else
		table.insert(signal.Callbacks, callback)
	end
	return SignalConnection.new(signal, callback)
end

function Signal.new(): Signal
	local self: Signal = setmetatable({} :: Signal, Signal)
	self.Callbacks = {}
	self.Names = {}
	self.Status = "Active"
	return self
end

function Signal.Wrap(scriptSignal: RBXScriptSignal): Signal
	local signal: Signal = Signal.new()
	signal:Fire()
	signal._internalConnection = scriptSignal:Connect(function(...)
		signal:Fire(...)
	end)
	return signal
end

function Signal:Fire(...: any)
	for i, callback: func in self.Callbacks do
		local thread = coroutine.create(callback)
		coroutine.resume(thread, ...)
	end
end

function Signal:FireTo(name: string, ...: any)
	local callback = self.Names[name]
	if not callback then
		return
	end
	local thread = coroutine.create(callback)
	coroutine.resume(thread, ...)
end

function Signal:Connect(callback: any, priority: number): SignalConnection
	return connectInternal(self, callback, priority)
end

function Signal:Once(callback: func, priority: number): SignalConnection
	local connection: SignalConnection
	connection = self:Connect(function(...)
		connection:Disconnect()
		callback(...)
	end, priority)
	return connection
end

function Signal:Wait(): any
	if self.Status == "Inactive" then
		warn("Cannot wait for inactive signal!")
		return nil
	end
	local thread: thread = coroutine.running()
	local returnValue
	self:Once(function(...)
		returnValue = {...}
		coroutine.resume(thread)
	end)
	return table.unpack(returnValue)
end

function Signal:Bind(callback: any, name: string, priority: number): SignalConnection
	local oldCallback = self.Names[name]
	if oldCallback then
		local index = table.find(self.Callbacks, oldCallback)
		if index then
			table.remove(self.Callbacks, index)
		end
	end
	self.Names[name] = callback
	return connectInternal(self, callback, priority)
end

function Signal:Unbind(name: string)
	local oldCallback = self.Names[name]
	if oldCallback then
		local index = table.find(self.Callbacks, oldCallback)
		if index then
			table.remove(self.Callbacks, index)
		end
	end
	self.Names[name] = nil
end

function Signal:BindToDestroy(callback: func)
	self.DestroyFunction = callback
end

function Signal:Destroy()
	self:DisconnectAll()
	if self._internalConnection then
		self._internalConnection:Disconnect()
		self._internalConnection = nil
	end
	self.Status = "Inactive"
	table.freeze(self)
	local destroyFunction = self.DestroyFunction
	if destroyFunction then
		destroyFunction()
	end
end

function Signal:DisconnectAll()
	table.clear(self.Callbacks)
	table.clear(self.Names)
end

return Signal

--[[
function Signal:Wait(maxDuration: number)
	if self.Status == "Inactive" then
		warn("Cannot wait for inactive signal!")
		return nil
	end
	local signalFired = false
	local connection = self:Once(function()
		signalFired = true
	end)
	local startTime = os.time()
	if maxDuration then
		while true do
			if signalFired then
				return true
			end
			if maxDuration and os.time() - startTime > maxDuration then
				warn("Yield timed out!")
				return false
			end
			task.wait()
		end
	end
	while true do
		if signalFired then
			return true
		end
		task.wait()
	end
end
]]