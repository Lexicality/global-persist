--[[
	Global Persistence Server Setup File
	Copyright 2020 Lex Robinson

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
]] --
local sbox_perisist_cleanup = CreateConVar(
	"sbox_persist_cleanup", "1", FCVAR_ARCHIVE,
	"Prevent map cleanups from deleting persisted props"
)
local sbox_perisist_autosave = CreateConVar(
	"sbox_persist_autosave", "1", FCVAR_ARCHIVE,
	"When should the game save the persistent state? 0 = never, 1 = in sandbox, 2 = always",
	0, 2
)

AddCSLuaFile("sandbox/gamemode/cl_worldtips.lua")

local function noop()
end

local function setupPersistence()
	include("sandbox/gamemode/persistence.lua")
end

local function shouldSave()
	local setting = sbox_perisist_autosave:GetInt()
	if setting == 2 then
		return true
	elseif setting == 1 then
		return gmod.GetGamemode().IsSandboxDerived
	end
	return false
end

local function onShutdown()
	if shouldSave() then
		hook.Run("PersistenceSave")
	end
end

local function onCvarChange(name, old, new)
	old = old:Trim()
	new = new:Trim()

	local function onActualChange()
		if (old == new) then
			return
		end

		if shouldSave() then
			hook.Run("PersistenceSave", old)
		end

		game.CleanUpMap()

		if (new == "") then
			return
		end

		hook.Run("PersistenceLoad", new)
	end

	-- A timer in case someone tries to rapily change the convar, such as addons with "live typing" or whatever
	timer.Create("sbox_persist_change_timer", 1, 1, onActualChange)
end

local function adjustPersistence()
	hook.Remove("ShutDown", "SavePersistenceOnShutdown")
	hook.Add("ShutDown", "SavePersistenceOnShutdown", onShutdown)

	local oldLoad = hook.GetTable()["PersistenceLoad"]["PersistenceLoad"]
	local function onPersistenceLoad(name)
		local function onTimer()
			oldLoad(name)
		end

		-- debounce
		timer.Create("sbox_persist_load_timer", 0.1, 1, onTimer)
	end
	hook.Add("PersistenceLoad", "PersistenceLoad", onPersistenceLoad)

	cvars.AddChangeCallback("sbox_persist", onCvarChange, "sbox_persist_load")
end

---
--- All the code to correctly duplicate props/ragdolls/vehicles etc is mixed in
--- with the spawn menu commands to create them. This function modifies the
--  global state to avoid any of that happening and then includes that file.
local function setupSandboxDupes()
	local ccAdd = concommand.Add
	concommand.Add = noop

	include("sandbox/gamemode/commands.lua")

	concommand.Add = ccAdd
end

local function onInitialize()
	if not gmod.GetGamemode().IsSandboxDerived then
		setupSandboxDupes()
		setupPersistence()
	end

	adjustPersistence()
end

hook.Add("Initialize", "Global Persistence Server", onInitialize)

local function onPostCleanupMap()
	if not sbox_perisist_cleanup:GetBool() then
		return
	end

	local PersistPage = GetConVarString("sbox_persist"):Trim()
	if (PersistPage == "") then
		return
	end

	-- BUG: This causes duplicate loads on cvar changes!
	hook.Run("PersistenceLoad", PersistPage)
end

hook.Add("PostCleanupMap", "Global Persistence", onPostCleanupMap)

--- @param ply GPlayer
local function ccSave(ply)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		return
	end

	hook.Run("PersistenceSave")
end
concommand.Add("sbox_persist_save", ccSave, nil, "Save the current persistant state to disk")
