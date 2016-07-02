--[[
	Sandbox Persistence
	Copyright (c) 2008-2016 Garry Newman
--]]
local gm = engine.ActiveGamemode():lower();
if (gm == "sandbox" or gm == "darkrp") then
	return;
end

if (not ConVarExists("sbox_persist")) then
	CreateConVar(
		"sbox_persist",
		"",
		0,
		"Set to anything but 0 to enable persistence mode"
	);
end

duplicator.Allow("prop_physics");
duplicator.Allow("prop_physics_multiplayer");

hook.Add( "PersistenceLoad", "PersistenceLoad", function( name )

	local file = file.Read( "persist/" .. game.GetMap() .. "_" .. name .. ".txt" )
	if ( not file ) then return end

	local tab = util.JSONToTable( file )
	if ( not tab ) then return end
	if ( not tab.Entities ) then return end
	if ( not tab.Constraints ) then return end

	local Ents, Constraints = duplicator.Paste( nil, tab.Entities, tab.Constraints )

	for k, v in pairs( Ents ) do
		v:SetPersistent( true )
	end

end )

hook.Add( "InitPostEntity", "PersistenceInit", function()

	local PersistPage = GetConVarString( "sbox_persist" )
	if ( PersistPage == "0" ) then return end

	hook.Run( "PersistenceLoad", PersistPage );

end )
