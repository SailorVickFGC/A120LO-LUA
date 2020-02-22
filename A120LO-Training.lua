-- Global Variables
local DMGAddr=0x0875C4
local DMG
local LastDMG = 0

local StunAddr=0x087342
local Stun

local StunLimP2Addr=0x087348
local StunLimP2

local StunTimerAddr=0x087344
local StunTimer

local P2StateAddr = 0x083EB0
local P2State

local TimerAddr = 0x0903F2
local Timer

local AIButtonsAddr = 0x087356
local AIButtons

local P2ButtonsAddr = 0x087354
local P2Buttons
local AIa = 1
local AIb = 2
local AIc = 8	-- != A+B -> 1+2
local AIx = 4
local AIy = 16
local AIz = 32
-- R 64
-- L 128
-- Buttons combination equal the result of their addition: eg A+C=9 or C+Z=40

local AIStickAddr = 0x087350
local AIStick
-- 8 ↑
-- 9 ↗
-- 6 →
-- 3 ↘
-- 2 ↓
-- 1 ↙
-- 4 ←
-- 7 ↖
-- 0 •

local AISideAddr = 0x0872C4
local AISide
-- 0 = P1
-- 1 = P2
-- Which side it looks iirc.

local ComboAddr = 0x0873FC
local Combo

local LastComboAddr = 0x086E12
local LastCombo


--- CODE ---
while true do
-- Infinite life
		--> take Damage
		--> stay like that for 200-500ms
		--> refill life

-- transform VS mode into Training Mode
	-- Timer=memory.readbyte(TimerAddr)
	-- memory.writebyte(TimerAddr, 88)
	-- gui.text(10,200,"Timer: " .. Timer)

-- Combo Counter
	Combo=memory.readbyte(ComboAddr)
	LastCombo=memory.readbyte(LastComboAddr)
	gui.text(10,200, "Combo:" .. Combo .. " (" .. LastCombo .. ")")
	-- gui.text(10,215, "Last Combo:" .. LastCombo)

-- Combo Damage
	DMG=191 - memory.readbyte(DMGAddr) -- Starts at -1 but once you hit it come back to 0 (-1hp in training for some reasons)
	if DMG ~= 0 then LastDMG=DMG
	end
	gui.text(10,240,"Damage: " .. DMG .. " (" .. LastDMG .. ") ")

-- Stun
	Stun=memory.readbyte(StunAddr)
	StunLimP2=memory.readbyte(StunLimP2Addr)
	StunTimer=memory.readbyte(StunTimerAddr)
	gui.text(10,255,"Stun: " .. Stun .. "/" .. StunLimP2 .. " - " .. StunTimer)

-- P2 State
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

	emu.frameadvance()
end


--- CREDITs
-- Sprint (help to get started, did the SMS hitboxes viewer)
-- 
-- From TASVideo discord: (early help with LUA)
-- Arcorann 
-- Mothrayas
-- Xander
