--!strict

local typings = require(script.Parent.internalTypings)

local state = {}

function state.new<T>(initial: T): typings.state<T>
	local value: T = initial
	local callbacks: { [number]: (old: T, new: T) -> () } = {}

	local self = {} :: typings.state<T>

	function self.respond(_: any, fn: (old: T, new: T) -> ()): () -> ()
		table.insert(callbacks, fn)
		local index = #callbacks

		return function()
			callbacks[index] = nil
		end
	end

	setmetatable(self, {
		__call = function(_: any, newValue: T?, forceUpdate: boolean?): T
			if newValue ~= nil then
				local shouldUpdate = (newValue ~= value) or (forceUpdate == true)
				if shouldUpdate then
					local old = value
					value = newValue
					for _, fn in callbacks do
						fn(old, newValue)
					end
				end
			end
			return value
		end,
	})

	return self
end

setmetatable(state, {
	__call = function<T>(_: typeof(state), value: T): typings.state<T>
		return state.new(value)
	end,
})

return table.freeze(state)
