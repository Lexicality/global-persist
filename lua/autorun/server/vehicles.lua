-- LuaFormatter off
--
-- Sandbox Vehicle Spawning
-- Copyright (c) 2008-2016 Garry Newman
--
local gm = engine.ActiveGamemode():lower();
if (gm == "sandbox" or gm == "darkrp") then
	return;
end

local function MakeVehicle( Player, Pos, Ang, Model, Class, VName, VTable, data )

	local Ent = ents.Create( Class )
	if ( not Ent ) then return NULL end

	duplicator.DoGeneric( Ent, data )

	Ent:SetModel( Model )

	-- Fallback vehiclescripts for HL2 maps ( dupe support )
	if ( Model == "models/buggy.mdl" ) then Ent:SetKeyValue( "vehiclescript", "scripts/vehicles/jeep_test.txt" ) end
	if ( Model == "models/vehicle.mdl" ) then Ent:SetKeyValue( "vehiclescript", "scripts/vehicles/jalopy.txt" ) end

	-- Fill in the keyvalues if we have them
	if ( VTable and VTable.KeyValues ) then
		for k, v in pairs( VTable.KeyValues ) do

			local kLower = string.lower( k )

			if ( kLower == "vehiclescript" or
			     kLower == "limitview"     or
			     kLower == "vehiclelocked" or
			     kLower == "cargovisible"  or
			     kLower == "enablegun" )
			then
				Ent:SetKeyValue( k, v )
			end

		end
	end

	Ent:SetAngles( Ang )
	Ent:SetPos( Pos )

	Ent:Spawn()
	Ent:Activate()

	if ( Ent.SetVehicleClass and VName ) then Ent:SetVehicleClass( VName ) end
	Ent.VehicleName = VName
	Ent.VehicleTable = VTable

	-- We need to override the class in the case of the Jeep, because it
	-- actually uses a different class than is reported by GetClass
	Ent.ClassOverride = Class

	return Ent

end

duplicator.RegisterEntityClass( "prop_vehicle_jeep_old", MakeVehicle, "Pos", "Ang", "Model", "Class", "VehicleName", "VehicleTable", "Data" )
duplicator.RegisterEntityClass( "prop_vehicle_jeep", MakeVehicle, "Pos", "Ang", "Model", "Class", "VehicleName", "VehicleTable", "Data" )
duplicator.RegisterEntityClass( "prop_vehicle_airboat", MakeVehicle, "Pos", "Ang", "Model", "Class", "VehicleName", "VehicleTable", "Data" )
duplicator.RegisterEntityClass( "prop_vehicle_prisoner_pod", MakeVehicle, "Pos", "Ang", "Model", "Class", "VehicleName", "VehicleTable", "Data" )

local function VehicleMemDupe( Player, Entity, Data )

	table.Merge( Entity, Data )

end
duplicator.RegisterEntityModifier( "VehicleMemDupe", VehicleMemDupe )

-- LuaFormatter on
