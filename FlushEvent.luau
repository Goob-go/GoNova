export type FlushEvent = {
	new : ()->FlushEvent;
	
	_listeners : {
		[string] : {()->()};
	};
	_queue : {
		{evName : string,data : any}	
	};
	
	emit : (self:FlushEvent,eventName:string,data:any)->();
	on : (self:FlushEvent,eventName:string,func:(data:any)->())->();
	flush : (self:FlushEvent)->();
}

local Module = {} :: FlushEvent
Module.__index = Module


function Module.new()
	local self = setmetatable({
		_listeners = {},
		_queue = {},
	},Module)
	
	return self
end

function Module:emit(eventName,data)
	if not self._listeners[eventName] then return end
	table.insert(self._queue,{evName = eventName,data = data})
end

function Module:on(eventName,func)
	if not self._listeners[eventName] then
		self._listeners[eventName] = {}
	end
	
	table.insert(self._listeners[eventName],func)
end

function Module:flush()
	local saved = self._queue
	self._queue = {}
	
	for _,data in saved do
		for _,func in self._listeners[data.evName] do
			func(data.data)
		end
	end
end


return Module