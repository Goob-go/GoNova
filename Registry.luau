local Types = require("./Types")

local function DeepCopy(t)
	local copy = {}
	for i,v in t do
		if type(v) == "table"  then
			copy[i] = DeepCopy(v)
		else
			copy[i] = v
		end
	end
	return copy
end

local Registry = {} :: Types.Registry
Registry.__index = Registry


function Registry.new()
	local self = setmetatable({
		_defs = {},
	},Registry)
	return self
end

function Registry:define(compName,opts)
	self._defs[compName] = opts or {}
end

function Registry:get(compName)
	return self._defs[compName]
end

function Registry:getForDefault(compName)
	local opts = self:get(compName)
	
	if not opts or not opts.default then return end	
	
	if type(opts.default) ~= "table" then
		return opts.default,false
	end
	
	return DeepCopy(opts.default),true
end

return Registry