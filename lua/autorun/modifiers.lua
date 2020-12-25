-- LuaFormatter off
--
-- Sandbox Tools
-- Copyright (c) 2008-2020 Facepunch Studios
--
local gm = engine.ActiveGamemode():lower();
if (gm == "sandbox" or gm == "darkrp") then
	return;
end

-----
--
-- Colour Tool
--
-----

local function SetColour( ply, ent, data )

	--
	-- If we're trying to make them transparent them make the render mode
	-- a transparent type. This used to fix in the engine - but made HL:S props invisible(!)
	--
	if ( data.Color and data.Color.a < 255 and data.RenderMode == RENDERMODE_NORMAL ) then
		data.RenderMode = RENDERMODE_TRANSCOLOR
	end

	if ( data.Color ) then ent:SetColor( Color( data.Color.r, data.Color.g, data.Color.b, data.Color.a ) ) end
	if ( data.RenderMode ) then ent:SetRenderMode( data.RenderMode ) end
	if ( data.RenderFX ) then ent:SetKeyValue( "renderfx", data.RenderFX ) end

	if ( SERVER ) then
		duplicator.StoreEntityModifier( ent, "colour", data )
	end

end
duplicator.RegisterEntityModifier( "colour", SetColour )

-----
--
-- Material Tool
--
-----

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

-----
--
--  Paint Tool
--
-----

local function PlaceDecal( ply, ent, data )

	if ( not IsValid( ent ) and not ent:IsWorld() ) then return end

	local bone = ent:GetPhysicsObjectNum( data.bone or 0 )
	if ( not IsValid( bone ) ) then bone = ent end

	if ( SERVER ) then
		util.Decal( data.decal, bone:LocalToWorld( data.Pos1 ), bone:LocalToWorld( data.Pos2 ), ply )

		local i = ent.DecalCount or 0
		i = i + 1
		duplicator.StoreEntityModifier( ent, "decal" .. i, data )
		ent.DecalCount = i
	end

end

--
-- Register decal duplicator
--
for i = 1, 32 do

	duplicator.RegisterEntityModifier( "decal" .. i, function( ply, ent, data )
		timer.Simple( i * 0.05, function() PlaceDecal( ply, ent, data ) end )
	end )

end

-----
--
--  Trails Tool
--
-----

local function SetTrails( ply, ent, data )

	if ( IsValid( ent.SToolTrail ) ) then

		ent.SToolTrail:Remove()
		ent.SToolTrail = nil

	end

	if ( not data ) then

		duplicator.ClearEntityModifier( ent, "trail" )
		return

	end

	-- Just don't even bother with invisible trails
	if ( data.StartSize <= 0 and data.EndSize <= 0 ) then return end

		-- This is here to fix crash exploits
	if ( not game.SinglePlayer() ) then

		-- Lock down the trail material - only allow what the server allows
		if ( not list.Contains( "trail_materials", data.Material ) ) then return end

		-- Clamp sizes in multiplayer
		data.Length = math.Clamp( data.Length, 0.1, 10 )
		data.EndSize = math.Clamp( data.EndSize, 0, 128 )
		data.StartSize = math.Clamp( data.StartSize, 0, 128 )

	end

	data.StartSize = math.max( 0.0001, data.StartSize )

	local trail_entity = util.SpriteTrail( ent, 0, data.Color, false, data.StartSize, data.EndSize, data.Length, 1 / ( ( data.StartSize + data.EndSize ) * 0.5 ), data.Material .. ".vmt" )

	ent.SToolTrail = trail_entity

	if ( IsValid( ply ) ) then
		ply:AddCleanup( "trails", trail_entity )
	end

	duplicator.StoreEntityModifier( ent, "trail", data )

	return trail_entity

end
duplicator.RegisterEntityModifier( "trail", SetTrails )

-----
--
--  EyePoser Tool
--
-----

local function SetEyeTarget( Player, Entity, Data )

	if ( Data.EyeTarget ) then Entity:SetEyeTarget( Data.EyeTarget ) end

	if ( SERVER ) then
		duplicator.StoreEntityModifier( Entity, "eyetarget", Data )
	end

end
duplicator.RegisterEntityModifier( "eyetarget", SetEyeTarget )

-- LuaFormatter on
