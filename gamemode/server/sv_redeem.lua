function GM:PlayerRedeemed(pl, silent, noequip)

if not silent then
		net.Start("zs_playerredeemed")
			net.WriteEntity(pl)
			net.WriteString(pl:Name())
		net.Broadcast()
	end
	
--[[
////////// Objective Mode, Zombie Escape 
		   or server/client disabled becoming a bandit. //////////
]]--
	
	if GAMEMODE.ObjectiveMap or GAMEMODE.ZombieEscape 
	or not GAMEMODE.BanditMode or pl:GetInfo("zs_nobandit") ~= "0" then
	pl:RemoveStatus("overridemodel", false, true)
	pl:ChangeTeam(TEAM_HUMAN)
	pl:SetPoints(0)
	pl:DoHulls()
	if not noequip then pl.m_PreRedeem = true end
	pl:UnSpectateAndSpawn()
	timer.Simple( 0.5, function() pl:EmitSound("zombiesurvival/redeem.mp3", 100, 100, 1) end )
	--timer.Simple( 0.8, function() pl:EmitSound("zombiesurvival/beats/placeholder/swag.ogg", 100, 100, 1) end )
    pl.m_PreRedeem = nil

	local frags = pl:Frags()
	if frags < 0 then
		pl:SetFrags(frags * 5)
	else
		pl:SetFrags(0)
	end
	pl:SetDeaths(0)
	pl.DeathClass = nil
	pl:SetZombieClass(self.DefaultZombieClass)
	if GAMEMODE.ZombieEscape then
	pl:Give("weapon_zs_fists") -- DONT add anything here but Zombie Escape weapons and/or items!
	else
	pl:Give("weapon_zs_fists") -- Here you're fine to add or remove whatever you want.
	pl:Give("weapon_zs_redeemers")
    pl:Give("weapon_zs_hammer")
    pl:Give("weapon_zs_arsenalcrate")
end
	
--[[
////////// Normal Mode //////////
]]--
	
	elseif not GAMEMODE.ZombieEscape or not GAMEMODE.ObjectiveMap then
	pl:RemoveStatus("overridemodel", false, true)
	pl:SendLua("MakepRedeemMenu()")
	pl:ChangeTeam(TEAM_REDEEMER)
	pl:SetPoints(150)
	pl:DoHulls()
	if not noequip then pl.m_PreRedeem = true end
	pl:UnSpectateAndSpawn()
	pl:Give("weapon_zs_fists")
	pl:Give("weapon_zs_redeemers")
    pl:Give("weapon_zs_hammer")
    pl:Give("weapon_zs_arsenalcrate")
	pl:SetModel( "models/player/skeleton.mdl" )
	timer.Simple( 0.5, function() pl:EmitSound("zombiesurvival/redeem.mp3", 100, 100, 1) end )
	--timer.Simple( 0.8, function() pl:EmitSound("zombiesurvival/beats/placeholder/swag.ogg", 100, 100, 1) end )
    pl.m_PreRedeem = nil

	local frags = pl:Frags()
	if frags < 0 then
		pl:SetFrags(frags * 5)
	else
		pl:SetFrags(0)
	end
	pl:SetDeaths(0)
	pl.DeathClass = nil
	pl:SetZombieClass(self.DefaultZombieClass)
	pl.SpawnedTime = CurTime()
    timer.Create("AddPoints_"..pl:SteamID(), 60, 0, function() pl:AddPoints(25) end)
		end
	end

function GM:PlayerRespawn(pl, silent, noequip)

	pl:RemoveStatus("overridemodel", false, true)
	pl:ChangeTeam(TEAM_HUMAN)
	pl:DoHulls()
	pl:UnSpectateAndSpawn()
	pl:Give("weapon_zs_peashooter")
	pl:Give("weapon_zs_swissarmyknife")

	local frags = pl:Frags()
	if frags < 0 then
		pl:SetFrags(frags * 5)
	else
		pl:SetFrags(0)
	end
	pl:SetDeaths(0)
	pl.DeathClass = nil
	pl:SetZombieClass(self.DefaultZombieClass)
    pl:SetPoints(0)
	pl.SpawnedTime = CurTime()
	timer.Destroy("AddPoints_" .. pl:SteamID())
	end

hook.Add("PostPlayerDeath", "PostPlayerDeath.Redeemer", function(ply)
    if ply:Team() == TEAM_REDEEMER or ply:Team() == TEAM_HUMAN then
        ply:ChangeTeam(TEAM_UNDEAD)
        ply:SetFrags(0)
        ply:SetDeaths(0)
        GAMEMODE.StartingZombie[ply:UniqueID()] = true
        GAMEMODE.PreviouslyDied[ply:UniqueID()] = CurTime()
	ply:SetZombieClassName(Zombie)
	timer.Destroy("AddPoints_" .. ply:SteamID())
    end
end)

concommand.Add("zs_bandit", function(sender, command, arguments)
    if sender:Team() ~= TEAM_REDEEMER then return end    
    sender:ChangeTeam(TEAM_HUMAN)    
end)


--[[
////////// Zombie Escape (Unused Code) //////////
]]--
	
	--[[elseif GAMEMODE.ZombieEscape then
	pl:RemoveStatus("overridemodel", false, true)
	pl:ChangeTeam(TEAM_HUMAN)
	pl:SetPoints(0)
	pl:DoHulls()
	if not noequip then pl.m_PreRedeem = true end
	pl:UnSpectateAndSpawn()
	pl:Give("weapon_zs_fists")
	timer.Simple( 0.5, function() pl:EmitSound("zombiesurvival/redeem.mp3", 100, 100, 1) end )
    pl.m_PreRedeem = nil

	local frags = pl:Frags()
	if frags < 0 then
		pl:SetFrags(frags * 5)
	else
		pl:SetFrags(0)
	end
	pl:SetDeaths(0)
	pl.DeathClass = nil
	pl:SetZombieClass(self.DefaultZombieClass)
	pl.SpawnedTime = CurTime()]]--
