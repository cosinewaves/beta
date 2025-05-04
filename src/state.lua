--!strict
--[[
	Author: cosinewaves
	Name: state.lua
]]

local typings = require(script.Parent.internalTypings)
local errors = require(script.Parent.errors)

local state = {}

function state.new<T>(initial: T): typings.state<T>
	if initial == nil then
		errors.new("state", "initial value cannot be nil", 3)
	end

	local value: T = initial 
	local callbacks: { [number]: (old: T, new: T) -> () } = {}

	local self = {} :: typings.state<T>

	-- https://en.wikipedia.org/wiki/Event_(computing)
	-- https://en.wikipedia.org/wiki/Observer_pattern
	function self.respond(_: any, fn: (old: T, new: T) -> ()): () -> ()
		if typeof(fn) ~= "function" then
			errors.new("state", "respond callback must be a function", 3)
		end

		table.insert(callbacks, fn)
		local index = #callbacks

		return function()
			callbacks[index] = nil
		end
	end

	setmetatable(self, {
		__call = function(_: any, newValue: T?, forceUpdate: boolean?): T
			if newValue ~= nil then 
				-- this is how the distinctUntilChanged is implemented - check if the oldValue is equal to the newValue, or get overridden by forceUpdate.
				-- https://www.learnrxjs.io/learn-rxjs/operators/filtering/distinctuntilchanged
				local shouldUpdate = newValue ~= value or forceUpdate == true 
				
				if shouldUpdate then
					local old = value
					value = newValue
										
					for _, fn in callbacks do
						local ok, err = pcall(fn, old, newValue) -- https://create.roblox.com/docs/reference/engine/globals/LuaGlobals#pcall
						if not ok then
							errors.new("state", `callback error: {err}`, 2)
						end
					end
				end
			end

			return value
		end,
	})

	return self
end

setmetatable(state, {
	-- to allow calling a table function, we modify the metatable's __call method - see more below
	-- https://devforum.roblox.com/t/all-you-need-to-know-about-metatables-and-metamethods/503259
	__call = function<T>(_: typeof(state), value: T): typings.state<T>
		return state.new(value)
	end,
})

return table.freeze(state)
