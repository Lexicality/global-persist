--
-- Extra Persistence
-- Copyright (c) 2016 Lex Robinson
-- This code is freely available under the MIT License
--
local cvar = CreateConVar(
	"sbox_persist_cleanup", "1", FCVAR_ARCHIVE,
	"Set to anything but 0 to enable persisting through cleanups"
);

hook.Add(
	"PostCleanupMap", "Global Persistence - Extra Persistence", function()

		if (cvar:GetString() == "0") then
			return
		end

		local PersistPage = GetConVarString("sbox_persist")
		if (PersistPage == "0") then
			return
		end

		hook.Run("PersistenceLoad", PersistPage)

	end
)
