--[[
	Sandbox Tools
	Copyright (c) 2008-2016 Garry Newman
--]]
local gm = engine.ActiveGamemode():lower();
if (gm == "sandbox" or gm == "darkrp") then
	return;
end
local function SetColour( ply, ent, data )

	--
	-- If we're trying to make them transparent them make the render mode
	-- a transparent type. This used to fix in the engine - but made HL:S props invisible(not )
	--
	if ( data.Color and data.Color.a < 255 and data.RenderMode == 0 ) then
		data.RenderMode = 1
	end

	if ( data.Color ) then ent:SetColor( Color( data.Color.r, data.Color.g, data.Color.b, data.Color.a ) ) end
	if ( data.RenderMode ) then ent:SetRenderMode( data.RenderMode ) end
	if ( data.RenderFX ) then ent:SetKeyValue( "renderfx", data.RenderFX ) end

	if ( SERVER ) then
		duplicator.StoreEntityModifier( ent, "colour", data )
	end

end
duplicator.RegisterEntityModifier( "colour", SetColour )
local function SetMaterial( Player, Entity, Data )

	if ( SERVER ) then

		--
		-- Make sure this is in the 'allowed' list in multiplayer - to stop people using exploits
		--
		if ( not game.SinglePlayer() and not list.Contains( "OverrideMaterials", Data.MaterialOverride ) and Data.MaterialOverride ~= "" ) then return end

		Entity:SetMaterial( Data.MaterialOverride )
		duplicator.StoreEntityModifier( Entity, "material", Data )
	end

	return true

end
duplicator.RegisterEntityModifier( "material", SetMaterial )
for i = 1, 32 do

	function PlaceDecal_delayed( Player, Entity, Data )
		timer.Simple( i * 0.05, function() PlaceDecal( Player, Entity, Data ) end )
	end

	duplicator.RegisterEntityModifier( "decal" .. i, PlaceDecal_delayed )

end
local function SetTrails( ply, ent, data )

	if ( IsValid( ent.SToolTrail ) ) then

		ent.SToolTrail:Remove()
		ent.SToolTrail = nil

	end

	if ( not data ) then

		duplicator.ClearEntityModifier( ent, "trail" )
		return

	end

	if ( data.StartSize == 0 ) then

		data.StartSize = 0.0001

	end

	--
	-- Lock down the trail material - only allow what the server allows
	-- This is here to fix a crash exploit
	--
	if ( not game.SinglePlayer() and not list.Contains( "trail_materials", data.Material ) ) then return end

	local trail_entity = util.SpriteTrail( ent, 0, data.Color, false, data.StartSize, data.EndSize, data.Length, 1 / ( ( data.StartSize + data.EndSize ) * 0.5 ), data.Material .. ".vmt" )

	ent.SToolTrail = trail_entity

	if ( IsValid( ply ) ) then
		ply:AddCleanup( "trails", trail_entity )
	end

	duplicator.StoreEntityModifier( ent, "trail", data )

	return trail_entity

end
duplicator.RegisterEntityModifier( "trail", SetTrails )
local function SetEyeTarget( Player, Entity, Data )

	if ( Data.EyeTarget ) then Entity:SetEyeTarget( Data.EyeTarget ) end

	if ( SERVER ) then
		duplicator.StoreEntityModifier( Entity, "eyetarget", Data )
	end

end
duplicator.RegisterEntityModifier( "eyetarget", SetEyeTarget )
