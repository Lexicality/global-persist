--[[
	Global Persistence Shared Setup File
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
_G.globalpersist = {version = "2.0.0"}

local function noop()
end

---
--- Registers a sandbox entity that someone may have been expecting to
--- exist/work in their persistances
--- @param name string
local function setupEntity(name)
	if scripted_ents.Get(name) then
		return
	end

	_G.ENT = {Folder = "entities/" .. name}

	include("sandbox/entities/entities/" .. name .. ".lua")

	scripted_ents.Register(ENT, name)
	baseclass.Set(name, scripted_ents.Get(name))

	_G.ENT = nil
end

---
--- Extracts the useful bits of a tool (eg setting up duplicator configs)
--- without actually creating the tool or anything related to it
--- @param name string
local function setupTool(name)
	_G.TOOL = {ClientConVar = {}, ServerConVar = {}, BuildConVarList = noop}
	local fname = "sandbox/entities/weapons/gmod_tool/stools/" .. name .. ".lua"
	AddCSLuaFile(fname)
	include(fname)
	_G.TOOL = nil
end

local function onInitialize()
	local gm = gmod.GetGamemode()
	if gm.IsSandboxDerived then
		return
	end

	-- Entity modifiers
	setupTool("colour")
	setupTool("material")
	setupTool("paint")
	setupTool("trails")
	setupTool("eyeposer")

	-- For constraints
	setupEntity("gmod_anchor")
	setupEntity("gmod_winch_controller")

	-- Useful sandbox entities
	setupEntity("gmod_light")
	setupTool("light")

	setupEntity("gmod_lamp")
	setupTool("lamp")

	setupEntity("gmod_balloon")
	setupTool("balloon")
end

hook.Add("Initialize", "Global Persistence Shared", onInitialize)
