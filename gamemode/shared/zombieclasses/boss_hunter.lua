-- Created by noob coder - A-91
-- Co-autor - GunFreak

CLASS.Name = "Night Stalker"
CLASS.TranslationName = "class_night_stalker"
CLASS.Description = "description_night_stalker"
CLASS.Help = "controls_night_stalker"
CLASS.Model = Model("models/player/zombie_fast.mdl")
CLASS.Wave = 0
CLASS.Threshold = 0
CLASS.Unlocked = true
CLASS.Hidden = true
CLASS.Boss = true
CLASS.Health = 850
CLASS.Speed = 290
CLASS.SWEP = "weapon_zs_fastzombie_hunter"
CLASS.ModelScale = 1
CLASS.Points = 40
CLASS.Hull = {Vector(-16, -16, 0), Vector(16, 16, 58)}
CLASS.HullDuck = {Vector(-16, -16, 0), Vector(16, 16, 32)}
CLASS.ViewOffset = Vector(0, 0, 50)
CLASS.ViewOffsetDucked = Vector(0, 0, 24)
CLASS.PainSounds = {"NPC_FastZombie.Pain"}
CLASS.DeathSounds = {"NPC_FastZombie.Die"}
CLASS.VoicePitch = 0.75
CLASS.NoShadow = true

CLASS.NoFallDamage = true
CLASS.NoFallSlowdown = true

CLASS.Icon = "zombiesurvival/killicons/nhunter"

function CLASS:Move(pl, mv)
	local wep = pl:GetActiveWeapon()
	if wep.Move and wep:Move(mv) then
		return true
	end

	if mv:GetForwardSpeed() <= 0 then
		mv:SetMaxSpeed(math.min(mv:GetMaxSpeed(), 90))
		mv:SetMaxClientSpeed(math.min(mv:GetMaxClientSpeed(), 90))
	end
end
local mathrandom = math.random
local StepLeftSounds = {
	"npc/fast_zombie/foot1.wav",
	"npc/fast_zombie/foot2.wav"
}
local StepRightSounds = {
	"npc/fast_zombie/foot3.wav",
	"npc/fast_zombie/foot4.wav"
}
function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound(StepLeftSounds[mathrandom(#StepLeftSounds)], 70)
	else
		pl:EmitSound(StepRightSounds[mathrandom(#StepRightSounds)], 70)
	end
	
	return true
end
--[[function CLASS:PlayerFootstep(pl, vFootPos, iFoot, strSoundName, fVolume, pFilter)
	if iFoot == 0 then
		pl:EmitSound("NPC_FastZombie.GallopLeft")
	else
		pl:EmitSound("NPC_FastZombie.GallopRight")
	end
	return true
end]]

function CLASS:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return 450 - pl:GetVelocity():Length()
	elseif iType == STEPSOUNDTIME_ON_LADDER then
		return 400
	elseif iType == STEPSOUNDTIME_WATER_KNEE then
		return 550
	end

	return 250
end

function CLASS:CalcMainActivity(pl, velocity)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or not wep.GetClimbing then return end

	if wep:GetClimbing() then
		pl.CalcIdeal = ACT_ZOMBIE_CLIMB_UP
		return true
	elseif wep:GetPounceTime() > 0 then
		pl.CalcIdeal = ACT_ZOMBIE_LEAP_START
		return true
	end

	local speed = velocity:Length2D()
	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		pl.CalcIdeal = ACT_ZOMBIE_LEAPING
	elseif speed <= 0.5 and wep:IsRoaring() then
		pl.CalcSeqOverride = pl:LookupSequence("menu_zombie_01")
	elseif speed > 16 and wep:GetSwinging() then
		pl.CalcIdeal = ACT_HL2MP_RUN_ZOMBIE
	else
		pl.CalcIdeal = ACT_HL2MP_RUN_ZOMBIE_FAST
	end

	return true
end

function CLASS:UpdateAnimation(pl, velocity, maxseqgroundspeed)
	local wep = pl:GetActiveWeapon()
	if not wep:IsValid() or not wep.GetClimbing then return end

	if wep:GetSwinging() then
		if not pl.PlayingFZSwing then
			pl.PlayingFZSwing = true
			pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_FRENZY)
		end
	elseif pl.PlayingFZSwing then
		pl.PlayingFZSwing = false
		pl:AnimResetGestureSlot(GESTURE_SLOT_ATTACK_AND_RELOAD) --pl:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_RANGE_FRENZY, true)
	end

	if wep:GetClimbing() then
		local vel = pl:GetVelocity()
		local speed = vel:Length()
		if speed > 8 then
			pl:SetPlaybackRate(math.Clamp(speed / 160, 0, 1) * (vel.z < 0 and -1 or 1))
		else
			pl:SetPlaybackRate(0)
		end

		return true
	end

	if wep:GetPounceTime() > 0 then
		pl:SetPlaybackRate(0.25)

		if not pl.m_PrevFrameCycle then
			pl.m_PrevFrameCycle = true
			pl:SetCycle(0)
		end

		return true
	elseif pl.m_PrevFrameCycle then
		pl.m_PrevFrameCycle = nil
	end

	local speed = velocity:Length2D()
	if not pl:OnGround() or pl:WaterLevel() >= 3 then
		pl:SetPlaybackRate(1)

		if pl:GetCycle() >= 1 then
			pl:SetCycle(pl:GetCycle() - 1)
		end

		return true
	end
	if speed <= 0.5 and wep:IsRoaring() then
		pl:SetPlaybackRate(0)
		pl:SetCycle(math.Clamp(1 - (wep:GetRoarEndTime() - CurTime()) / wep.RoarTime, 0, 1) * 0.9)

		return true
	end
end

function CLASS:DoAnimationEvent(pl, event, data)
	if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
		return ACT_INVALID
	end
end

function CLASS:CreateMove(pl, cmd)
	local wep = pl:GetActiveWeapon()
	if wep:IsValid() and wep.IsPouncing then
		if wep.m_ViewAngles and wep:IsPouncing() then
			local maxdiff = FrameTime() * 20
			local mindiff = -maxdiff
			local originalangles = wep.m_ViewAngles
			local viewangles = cmd:GetViewAngles()

			local diff = math.AngleDifference(viewangles.yaw, originalangles.yaw)
			if diff > maxdiff or diff < mindiff then
				viewangles.yaw = math.NormalizeAngle(originalangles.yaw + math.Clamp(diff, mindiff, maxdiff))
			end

			wep.m_ViewAngles = viewangles

			cmd:SetViewAngles(viewangles)
		--[[elseif wep:IsClimbing() then
			local buttons = cmd:GetButtons()
			if bit.band(buttons, IN_DUCK) ~= 0 then
				cmd:SetButtons(buttons - IN_DUCK)
			end]]
		end
	end
end
function CLASS:GetAlpha(pl)
	local wep = pl:GetActiveWeapon()
	if not wep.IsAttacking then wep = NULL end
	if wep:IsValid() and wep:IsAttacking() then
		return 0.9
	elseif MySelf:IsValid() and MySelf:Team() == TEAM_UNDEAD then
		local eyepos = EyePos()
		return math.Clamp(pl:GetVelocity():Length() - pl:NearestPoint(eyepos):Distance(eyepos) * 0, 200, 10) / 255
	else
		local eyepos = EyePos()
		return math.Clamp(pl:GetVelocity():Length() - pl:NearestPoint(eyepos):Distance(eyepos) * 0, 200, 10) / 255
	end
end

function CLASS:PrePlayerDraw(pl)
	pl:RemoveAllDecals()
	--[[if pl:GetBarricadeGhosting() then
		render.SetBlend(0.7)
		render.SetColorModulation(1, 1, 5)
	else]]
		local alpha = self:GetAlpha(pl)
		if alpha == 0 then return true end
		render.SetBlend(alpha)
		render.SetColorModulation(0.4, 0.4, 0.4)
	--end
end