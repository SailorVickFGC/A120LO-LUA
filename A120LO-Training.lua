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


--- CODE ---
while true do
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

-- /// If thrown = tech
	if P2State==8 then  -- 0 hit, 8 thrown / clash / hitting
		repeat
			gui.text(10,180,"Throw tech")			-- erase everything but mokay
			memory.writebyte(AIButtonsAddr2, 2)		-- Works fine
			memory.writebyte(AIStickAddr, 2)		-- Doesn't work cause... ¯\_(ツ)_/¯


			-- What tested before
			-- input['P1 Start'] = true				-- Works for P1 inputs. Needs joypad.set(input) to work.
			-- input['P2 B'] = true 				-- Doesn't work cause dummy buttons != P2 buttons
			-- memory.writebyte(P2ButtonsAddr, 2)	-- same

			P2State=memory.readbyte(P2StateAddr)
			emu.frameadvance() 
		until (P2State==15) -- return to Idle
	end

	emu.frameadvance()
end
