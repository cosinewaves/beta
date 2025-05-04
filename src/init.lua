--!strict
--[[
	Author: cosinewaves
	Name: beta.init.lua
]]

local state = require(script.state)
local internalTypings = require(script.internalTypings)
local evaluate = require(script.evaluate)
local errors = require(script.errors)

export type state<T> = internalTypings.state<T>
export type evaluate<T> = internalTypings.evaluate<T>

return table.freeze({
	state = state,
	evaluate = evaluate,
	errors = errors
})
