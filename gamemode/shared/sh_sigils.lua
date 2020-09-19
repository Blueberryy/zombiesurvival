ESCAPESTAGE_NONE = 0
ESCAPESTAGE_ESCAPE = 1
ESCAPESTAGE_BOSS = 2
ESCAPESTAGE_DEATH = 3

function GM:GetSigils()
	local sigils = {}

	for _, ent in pairs(ents.FindByClass("prop_obj_sigil")) do
		if ent:IsValid() and ent.GetSigilHealthBase and ent:GetSigilHealthBase() ~= 0 then
			sigils[#sigils + 1] = ent
		end
	end

	return sigils
end

function GM:NumSigils()
	return #self:GetSigils()
end

function GM:GetUseSigils(use)
	return GetGlobalBool("sigils", false)
end

function GM:GetEscapeSequence()
	return self:GetUseSigils() and self:GetEscapeStage() ~= ESCAPESTAGE_NONE
end
GM.IsEscapeSequence = GM.GetEscapeSequence

function GM:SetEscapeStage(stage)
	SetGlobalInt("esstg", stage)
end

function GM:GetEscapeStage()
	return GetGlobalInt("esstg", ESCAPESTAGE_NONE)
end

function GM:SigilsSpawned()
    if #ents.FindByClass( "prop_obj_sigil" ) >= 1 then
        return true
    end

    return false
end
