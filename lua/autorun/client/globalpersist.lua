--[[
	Global Persistence Client Setup File
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

local function setupTips()
	local prevGM = _G.GM
	local fakeGM = {}
	_G.GM = fakeGM
	include("sandbox/gamemode/cl_worldtips.lua")
	_G.GM = prevGM
	hook.Add("HUDPaint", "GlobalPersist World Tips", fakeGM.PaintWorldTips)
end

local function onInitialize()
	local gm = gmod.GetGamemode()
	if gm.IsSandboxDerived then
		return
	end

	setupTips()
end

hook.Add("Initialize", "Global Persistence Client", onInitialize)
