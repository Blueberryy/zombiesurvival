include("shared.lua")

SWEP.PrintName = ""..translate.Get("worth_beacon")
SWEP.Description = ""..translate.Get("msgbeacon_desk")
SWEP.DrawCrosshair = false

SWEP.Slot = 4
SWEP.SlotPos = 0

function SWEP:Deploy()
	gamemode.Call("WeaponDeployed", self.Owner, self)

	return true
end

function SWEP:DrawHUD()
	if GetConVarNumber("crosshair") ~= 1 then return end
	self:DrawCrosshairDot()
end

function SWEP:PrimaryAttack()
end

function SWEP:DrawWeaponSelection(...)
	return self:BaseDrawWeaponSelection(...)
end

function SWEP:Think()
end

local function okclick(self)
	RunConsoleCommand("setmessagebeaconmessage", self:GetParent().Choice)
	self:GetParent():Close()
end

local function onselect(self, index, value, data)
	self:GetParent().Choice = data
end

local Menu
function SWEP:SecondaryAttack()
	if Menu and Menu:Valid() then
		Menu:SetVisible(true)
		return
	end

	Menu = vgui.Create("DFrame")
	Menu:SetDeleteOnClose(false)
	Menu:SetSize(200, 100)
	Menu:SetTitle(translate.Get("msgbeacon_text"))
	Menu:Center()
	Menu.Choice = 1

	local choice = vgui.Create("DComboBox", Menu)
	for k, v in ipairs(GAMEMODE.ValidBeaconMessages) do
		choice:AddChoice(translate.Get(v), k)
	end
	choice:ChooseOption(GAMEMODE.ValidBeaconMessages[1], 1)
	choice:SizeToContents()
	choice:SetWide(Menu:GetWide() - 16)
	choice:Center()
	choice.OnSelect = onselect

	local ok = EasyButton(Menu, translate.Get("worth_ok").."", 8, 4)
	ok:AlignBottom(8)
	ok:CenterHorizontal()
	ok.DoClick = okclick

	Menu:MakePopup()
end
