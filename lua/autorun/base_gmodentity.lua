-- LuaFormatter off
--
-- GMod Base Entity
-- Copyright (c) 2008-2016 Garry Newman
--
local gm = engine.ActiveGamemode():lower();
if (gm == "sandbox" or gm == "darkrp") then
	return;
end

-- Don't do anything if we already have an entity
if (scripted_ents.Get("base_gmodentity")) then
	return;
end

local ENT = {
	Type = "anim";
};

if ( CLIENT ) then

	ENT.LabelColor = Color( 255, 255, 255, 255 )

	function ENT:BeingLookedAtByLocalPlayer()

		if ( LocalPlayer():GetEyeTrace().Entity ~= self ) then return false end
		if ( EyePos():Distance( self:GetPos() ) > 256 ) then return false end

		return true

	end


	function ENT:Think()

		if ( self:BeingLookedAtByLocalPlayer() ) then

			halo.Add( { self }, Color( 255, 255, 255, 255 ), 1, 1, 1, true, true )

		end

	end

end

function ENT:SetOverlayText( text )
	self:SetNetworkedString( "GModOverlayText", text )
end

function ENT:GetOverlayText()

	local txt = self:GetNetworkedString( "GModOverlayText" )

	if ( txt == "" ) then
		return ""
	end

	if ( game.SinglePlayer() ) then
		return txt
	end

	local PlayerName = self:GetPlayerName()

	return txt .. "\n(" .. PlayerName .. ")"

end

function ENT:SetPlayer( ply )

	if ( IsValid(ply) ) then

		self:SetVar( "Founder", ply )
		self:SetVar( "FounderIndex", ply:UniqueID() )

		self:SetNetworkedString( "FounderName", ply:Nick() )

	end

end

function ENT:GetPlayer()

	return self:GetVar( "Founder", NULL )

end

function ENT:GetPlayerIndex()

	return self:GetVar( "FounderIndex", 0 )

end

function ENT:GetPlayerName()

	local ply = self:GetPlayer()
	if ( IsValid( ply ) ) then
		return ply:Nick()
	end

	return self:GetNetworkedString( "FounderName" )

end

scripted_ents.Register(ENT, "base_gmodentity");

-- LuaFormatter on
