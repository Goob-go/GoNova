local World = require("@self/World")
local Registry = require("@self/Registry")
local Scheduler = require("@self/Scheduler")
local FlushEvent = require("@self/FlushEvent")
local Types = require("@self/Types")

export type World = Types.World
export type Registry = Types.Registry
export type Scheduler = Types.Scheduler
export type FlushEvent = FlushEvent.FlushEvent


export type Entity<compNames=string> = {
	id : number;
	_ecs : ECS<compNames>;
	
	add : (self:Entity<compNames>,compName:compNames,data:{})->(Entity<compNames>);
	build : (self:Entity<compNames>)->number;
}

export type ECS<compNames=string> = {
	registry : Registry<compNames>;
	world : World<compNames>;
	scheduler : Scheduler;
	bus : FlushEvent;
	
	new : ()->ECS<compNames>;
	entity : (self:ECS<compNames>)->(Entity<compNames>);
	component : (self:ECS<compNames>,compName:compNames,defenition:Types.Defenition<compNames>)->(ECS<compNames>);
	update : (self:ECS<compNames>,...any)->();
	initialize : (self:ECS<compNames>,...any)->();
}

local ECS = {} :: ECS
ECS.__index = ECS


function ECS.new()
	local registry = Registry.new()
	local scheduler = Scheduler.new()
	local world = World.new(registry)
	local bus = FlushEvent.new()

	return setmetatable({
		registry = registry,
		scheduler = scheduler,
		world = world,
		bus = bus,
	},ECS)
end



function ECS:entity()
	local entity = {
		id = self.world:spawn(),
		_ecs = self,
	}
	
	function entity:add(compName,data)
		self._ecs.world:add(self.id,compName,data)
		return self
	end
	
	function entity:build()
		return self.id
	end
	
	return entity
end


function ECS:component(compName,definition)
	self.registry:define(compName,definition)
	return self
end
function ECS:initialize(...)
	self.scheduler:initialize(self,...)
end
function ECS:update(...)
	self.scheduler:run(self,...)
end



return ECS