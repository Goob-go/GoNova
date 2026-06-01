local Types = require("./Types")

local Scheduler = {} :: Types.Scheduler
Scheduler.__index = Scheduler


function Scheduler.new()
	local self = setmetatable({
		_systems = {},
		_byName = {},
		_order = nil,
		_initialized = false,
	},Scheduler)
	
	
	return self
end

function Scheduler:get(name)
	return self._byName[name]
end

function Scheduler:add(system)
	if self._initialized then
		error(`[Scheduler] cannot add system({system._name}) after init`)
	end
	if not system._name	then
		error(`[Scheduler] system must have a name`)
	end
	
	system._after = system._after or {}
	table.insert(self._systems,system)
	
	self._order = nil
end

function Scheduler:_build()
	local byName = {}
	
	for _,s in self._systems do
		if byName[s._name] then
			error("[Scheduler] duplicate system name: " .. s._name)
		end
		
		byName[s._name] = s
	end
	self._byName = byName
	local visited,visiting,order = {},{},{}
	
	local function visit(s)
		if visited[s._name] then return end
		
		if visiting[s._name] then
			error(`[Scheduler] cycle detected in system dependency graph for system: {s._name}`)
		end
		
		visiting[s._name] = true
		
		for _,n in s._after do
			if not byName[n] then
				error(`[Scheduler] unknown system name: {n} in after list of {s._name}`)
			end
			visit(byName[n])
		end
		visited[s._name] = true
		visiting[s._name] = nil
		
		table.insert(order,s)
	end
	
	for _,s in self._systems do
		visit(s)
	end
	
	for _,s in self._systems do
		local dependencies = {}
		for _,n in s._after do
			local dep = byName[n]
			if not dep then
				error(`[Scheduler] dependency is not found: {n} for system: {s._name}`)
			end
			dependencies[n] = dep
		end
		s._dependencies = dependencies
	end
	
	self._order = order
end
function Scheduler:initialize(...)
	self._initialized = true
	if not self._order then self:_build() end
	for _,s in self._order do
		if not s._init then continue end
		
		s:_init(s._dependencies,...)
	end
end
function Scheduler:run(ecs,...)
	if not self._order then self:_build() end
	
	for _,s in self._order do
		if not s._update then continue end
		s:_update(s._dependencies,ecs,...)
	end
	
	ecs.bus:flush()
end

return Scheduler