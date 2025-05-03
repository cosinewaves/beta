--!strict

local typings = require(script.Parent.internalTypings)

local evaluate = {}

function evaluate.new<T>(fn: () -> T): typings.evaluate<T>
	local self = {} :: any
	local value: T
	local disconnectors: { () -> () } = {}

	
	local function update()
		
		for _, disconnect in disconnectors do
			disconnect()
		end
		disconnectors = {}

		value = fn()

	end

	
	update()
	setmetatable(self, {
		__call = function(_: any): T
			return value
		end,
	})

	
	function self:disconnect()
		for _, disconnect in disconnectors do
			disconnect()
		end
		disconnectors = {}
	end

	self.value = value

	local oldMeta = getmetatable(_G)
	local proxy = setmetatable({}, {
		__index = function(_, key)
			local val = _G[key]
			if type(val) == "function" and pcall(function() return val.respond end) then
				-- Hook into state to listen for updates
				local disconnect = val:respond(function()
					update()
				end)
				table.insert(disconnectors, disconnect)
			end
			return val
		end,
	})

	setfenv(fn, proxy)
	update()
	setfenv(fn, _G)

	return self :: typings.evaluate<T>
end

setmetatable(evaluate, {
	__call = function(_: typeof(evaluate), fn: () -> any)
		return evaluate.new(fn)
	end,
})

return table.freeze(evaluate)
