--[[ 
	This file controls weight limits and the like.



]]

-- Delay and timer to keep player's chat from being instantly nuked.
-- Will get screwy if one player on the server keeps trying to spam auto weapons on an overloaded chassis.

local wlalertdelay = 1
local wlalertdelaytimer = 0

function weightlimitcheck(gunent, bullet)
	
	-- If we don't have a weight set yet (example, if it's just been spawned), tell acf to generate one.
	if gunent.acftotal == nil then
		ACF_CalcMassRatio(gunent, true)

	end

	local totalmass = 0
	
	totalmass = gunent.acftotal

	local gmaxweightshoot = GetConVar("gpoints_maxweight"):GetFloat() + 1

	if totalmass > gmaxweightshoot then
		
		if CurTime() > wlalertdelaytimer then
			local gunowner = gunent:CPPIGetOwner()
			print(gunowner)
			gunowner:PrintMessage(HUD_PRINTTALK, "Your contraption is too heavy to fire (" .. totalmass .. " kg). The server weightlimit is: " .. gmaxweightshoot .. " kg.")
			wlalertdelaytimer = CurTime() + wlalertdelay
		end

		return false -- Tell acf to not do anything.
	else
		return true
	end
	
end

hook.Add("ACF_FireShell", "WeightLimitCheckScript", weightlimitcheck)