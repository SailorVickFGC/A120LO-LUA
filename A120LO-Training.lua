-- Global Variables
local DMGAddr=0x0875C4
local DMG
local LastDMG = 0

local StunAddr=0x087342
local Stun = memory.readbyte(StunAddr)

local StunLimP2Addr=0x087348
local StunLimP2

local StunTimerAddr=0x087344
local StunTimer

local P2StateAddr = 0x083EB0
local P2State

local TimerAddr = 0x0903F2
local Timer


local AIButtonsAddr2 = 0x087356
local AIButtons2
-- local AIStickAddr2 = 0x087350
-- local AIStick2

local AIButtonsAddr = 0x087354
local AIButtons
local AIa = 1
local AIb = 2
local AIc = 8	-- != A+B -> 1+2
local AIx = 4
local AIy = 16
local AIz = 32
-- R 64, L 128
-- Buttons combination equal the result of their addition: eg A+C=9 or C+Z=40

local P1StickAddr = 0x086D00
local AIStickAddr = 0x087350 -- P2 stick but also Dummy? 🤔 Can't find a second AI stick
local AIStick
-- 8 ↑, 9 ↗, 6 →, 3 ↘, 2 ↓, 1 ↙, 4 ←, 7 ↖, 0 •

local AISideAddr = 0x0872C4
local AISide
-- 0 = P1, 1 = P2

local ComboAddr = 0x0873FC
local Combo

local LastComboAddr = 0x086E12
local LastCombo


function comboCounter()
	Combo=memory.readbyte(ComboAddr)
	LastCombo=memory.readbyte(LastComboAddr)
	gui.text(10,200, "Combo:" .. Combo .. " (" .. LastCombo .. ")")
	-- gui.text(10,215, "Last Combo:" .. LastCombo)

end

function comboDamage()
	DMG=191 - memory.readbyte(DMGAddr) -- Starts at -1 but once you hit it come back to 0 (-1hp in training for some reasons)
	if DMG ~= 0 then LastDMG=DMG
	end
	gui.text(10,240,"Damage: " .. DMG .. " (" .. LastDMG .. ") ")

end

function stunCounter()
	Stun=memory.readbyte(StunAddr)
	StunLimP2=memory.readbyte(StunLimP2Addr)
	StunTimer=memory.readbyte(StunTimerAddr)
	gui.text(10,255,"Stun: " .. Stun .. "/" .. StunLimP2 .. " - " .. StunTimer)
end

function dummyState()
	P2State=memory.readbyte(P2StateAddr)

	if P2State==0 then 
		gui.text(10,270,"P2 State: Hit")
	end

	if P2State==127 then
		gui.text(10,270,"P2 State: Clash!") 
	end

	if P2State==8 then
		gui.text(10,270, "P2 State: Thrown") 
	end

	if P2State==15 then
		gui.text(10,270, "P2 State: Idle") 
	end
end



-- Asuka 120% L.O. Pause Menu class --
HitboxViewer = {}

-- Initializing
function HitboxViewer:new()
    setmetatable({}, HitboxViewer)

    self.m_menu = 0x0FFB82
    self.m_pause = 0x07984A
    self.m_modeSelect = 0x07C9B6
    self.m_isEnabled = false
		
		return self
end


-- Asuka 120% L.O. Pause Menu class --
PauseMenu = {}

-- Initializing
function PauseMenu:new()
    setmetatable({}, PauseMenu)

    self.m_menu = 0x0FFB82
    self.m_pause = 0x07984A
    self.m_modeSelect = 0x07C9B6
    self.m_isEnabled = false

    return self
end

--[[Return the value of the selected menu :
- 99 is the main menu
- 1 is VS Game
- 2 is Ranking mode
- 3 is Deathmatch
- 4 is Config 
- 150 is the battle screen (playing)]]
function PauseMenu:menuSelected()
    menuSelect = memory.readbyte(self.m_menu)
    return menuSelect
end

function PauseMenu:pauseIsActive()
    pauseEnabled = memory.readbyte(self.m_pause)
    return pauseEnabled
end

--[[Return the value of the select Vs Mode :
- 0 is 1p vs 2p
- 1 is vs com 
- 2 is com vs com 
- 3 is deku]]
function PauseMenu:modeSelected()
    vsModeSelected = memory.readbyte(self.m_modeSelect)
    return vsModeSelected
end

Pause = PauseMenu:new()
-- Hitbox viewer enable if both = 1
-- 0x0856B0 
-- 0x090402

while true do
	if Pause:menuSelected() == 150 and Pause:modeSelected() then
		memory.writebyte(0x0856B0, 1)
		memory.writebyte(0x090402, 1)
	else
		memory.writebyte(0x0856B0, 0)
		memory.writebyte(0x090402, 0)
	end


	comboCounter()
	comboDamage()
	stunCounter()
	dummyState()

	emu.frameadvance()
end
