local Types = require("./Types")

local World = {} :: Types.World
World.__index = World

function World.new(registry)
	local self = setmetatable({
		_registry = registry,
		_components = {},
		_nextId = 0,
	},World)
	
	
	return self
end


function World:spawn()
	local id = self._nextId 
	self._nextId += 1
	return id
end

function World:kill(id)
	for _,comp in self._components do
		self:remove(id,comp)
	end
end

function World:add(id,compName,data)
	local defenition = self._registry:get(compName) or {}
	
	if defenition.conflicts then
		for _,conflictCompName in defenition.conflicts do
			if not self:has(id,conflictCompName) then continue end
			self:remove(id,conflictCompName)
		end
	end
	
	if defenition.requires then
		for _,requireCompName in defenition.requires do
			if self:has(id,requireCompName) then continue end
			self:add(id,requireCompName)
		end
	end
	
	local defaultData,isTable = self._registry:getForDefault(compName)

	if defaultData then
		if data and isTable then
			for k,v in data do
				defaultData[k] = v
			end
		end
		data = defaultData
	end
	
	if defenition.validate then
		local status,err = defenition.validate(self,id,data)
		assert(status,`[ECS] invalid {compName} {err}`)
	end
	
	
	if not self._components[compName] then
		self._components[compName] = {}
	end
	
	self._components[compName][id] = data
	
	if not defenition.onAdd then return end
	defenition.onAdd(self,id,data)
end

function World:remove(id,compName)
	local ids = self._components[compName]
	if not ids	then return end
	ids[id] = nil
	if next(ids) then return end
	self._components[compName] = nil
end

function World:get(id,compName)
	local t = self._components[compName]
	return t and t[id]
end

function World:has(id,compName)
	return self:get(id,compName) ~= nil
end

function World:query(...)
	local required = {...}
	local results = {}
	
	local first = self._components[required[1]]
	if not first then return results end
	
	for id,data in first do
		local match = true
		
		for i=2,#required do
			if self:has(id,required[i]) then continue end
			match = false
			break
		end
		if not match then continue end
		table.insert(results,id)
	end
		
	return results
end

return World