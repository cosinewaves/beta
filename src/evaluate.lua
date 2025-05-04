--!strict
--[[
	Author: cosinewaves
	Name: evaluate.lua
]]

local typings = require(script.Parent.internalTypings)
local errors = require(script.Parent.errors)

local evaluate = {}

function evaluate.new<T>(computeFn: () -> T): typings.evaluate<T>
	if typeof(computeFn) ~= "function" then
		errors.new("evaluate", "computeFn must be a function", 3)
	end

	local self = {} :: typings.evaluate<T>
	local value: T
	local disconnects: { () -> () } = {}

	-- disconnects all listeners to avoid memory leaks and stale listeners
	function self:disconnect()
		for _, disconnect in disconnects do
			pcall(disconnect)
		end
		table.clear(disconnects)
	end

	local function safeCompute(): T
		local ok, result = pcall(computeFn)
		if not ok then
			errors.new("evaluate", `failed to compute: {result}`, 3)
		end
		return result
	end

	local function setup()
		self:disconnect()

		local usedStates: { typings.state<any> } = {}

		-- Monkey-patching concept to intercept `state()` calls while evaluating
		-- https://en.wikipedia.org/wiki/Monkey_patch
		local meta = getmetatable(setmetatable({}, {
			__call = function(_, ...)
				error("Unexpected __call interception", 2)
			end,
		}))

		if not meta or typeof(meta.__call) ~= "function" then
			errors.new("evaluate", "Unable to monkey-patch __call", 3)
		end

		-- used to track dependencies during computeFn execution
		local function interceptState<T>(state: typings.state<T>): T
			table.insert(usedStates, state)
			local ok, result = pcall(state)
			if not ok then
				errors.new("evaluate", `error calling state: {result}`, 3)
			end
			return result
		end

		-- initial compute and track which states were accessed
		value = safeCompute()

		-- re-subscribe to all used states so we can reactively update
		for _, state in usedStates do
			local disconnect
			local ok, err = pcall(function()
				-- Observer pattern: subscribe to state changes
				-- https://en.wikipedia.org/wiki/Observer_pattern
				disconnect = state:respond(function()
					value = safeCompute()
				end)
			end)
			if not ok or not disconnect then
				errors.new("evaluate", `failed to respond to state: {err}`, 2)
			else
				table.insert(disconnects, disconnect)
			end
		end
	end

	setup()

	function self:__call(): T
		-- Acts like a getter
		return value
	end

	setmetatable(self, {
		__call = self.__call,
	})

	return self
end

-- Syntactic sugar: allows calling evaluate(fn) directly
-- https://en.wikipedia.org/wiki/Syntactic_sugar
setmetatable(evaluate, {
	__call = function(_, fn)
		return evaluate.new(fn)
	end,
})

return table.freeze(evaluate)
