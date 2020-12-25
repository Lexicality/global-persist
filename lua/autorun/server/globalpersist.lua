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
);

AddCSLuaFile("sandbox/gamemode/cl_worldtips.lua")

local function noop()
end

local function setupPersistence()
	include("sandbox/gamemode/persistence.lua")
	-- TODO: There should really be a convar here in case people want it
	hook.Remove("ShutDown", "SavePersistenceOnShutdown")
	hook.Remove("PersistenceSave", "PersistenceSave")
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
	local gm = gmod.GetGamemode()
	if gm.IsSandboxDerived then
		return
	end

	setupSandboxDupes()
	setupPersistence()
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

hook.Add(
	"PostCleanupMap", "Global Persistence", onPostCleanupMap
)
