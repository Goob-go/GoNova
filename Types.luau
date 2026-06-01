-----------------World------------------------------------------
export type World<compNames=string> = {
	_components : {[compNames]:{any}};
	_nextId : number;
	_registry : Registry<compNames>;
	
	query : (self:World<compNames>,...compNames)->({number});
	get : (self:World<compNames>,id:number,compName:compNames)->({}?);
	has : (self:World<compNames>,id:number,compName:compNames)->(boolean);
	spawn : (self:World<compNames>)->(number);
	kill : (self:World<compNames>,id:number)->();
	add : (self:World<compNames>,id:number,compName:compNames,data:{}?)->();
	remove : (self:World<compNames>,id:number,compName:compNames)->();
	new : (registry:Registry)->World<compNames>;
}

-----------------------------------------------------------------
-----------------Registry----------------------------------------
export type Defenition<compNames=string> = {
	default : {}?;
	requires : {compNames}?;
	conflicts : {compNames}?;
	validate : (d:{})->(boolean,string?)?;

	onAdd : (self:World,id:number,d:{})->();
	onRemove : (self:World,id:number,d:{})->();
}

export type Registry<compNames=string> = {
	_defs : {[compNames]:Defenition<compNames>};

	define : (self:Registry<compNames>,compName:compNames,opts:Defenition<compNames>?)->();
	get : (self:Registry<compNames>,compName:compNames)->(Defenition<compNames>);
	getForDefault : (self:Registry<compNames>,compName:compNames)->({}|any,boolean);

	new : ()->(Registry<compNames>);
}
--------------------------------------------------------------------
----------------Scheduler----------------------------
export type System = {
	_update : ()->()?;
	_init : ()->()?;
	_after : {string};
	_name : string;	
	_dependincies : {[string]:System};
}&{[any]:any}
export type Scheduler = {
	new : () -> Scheduler;
	add : (self:Scheduler,system:System)->();
	run : (self:Scheduler,...any)->();
	initialize : (self:Scheduler,...any)->();
	get : (self:Scheduler,name:string)->(System?);

	_build : (self:Scheduler)->();


	_systems : {System};
	_order : {System};
	_byName : {[string]:System};
	_initialized : boolean;
}
---------------------------------------------------


return nil