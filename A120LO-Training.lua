
	-- -- -- --
	-- Asuka 120% LimitOver BURNING Fest.
	-- BizHawk Training Script ver: 2.0.0
	-- + Game wiki: https://wiki.gbl.gg/w/Asuka_120_LimitOver
	-- + English netplay community: https://discord.gg/GpYn2Tx
	-- -- -- -- -- --


local _DEBUG = false
local _SCRIPT_VER = '2.0.0'
local _ORIGIN = 'https://github.com/VickGE/A120LO-LUA/blob/master/README.md'
-- local _ORIGIN = 'http://127.0.0.1:8080/README.md'	--DEBUG

local COLOR = {	-- https://www.radix-ui.com/docs/colors/palette-composition/the-scales
	white = 'white',
	lightgray = '#FFC1C8CD',
	gray = '#FF16161d',
	lightblue = '#FF68DDFD',
	green = '#FF40C4AA',
	yellow = '#FFF5D90A',
	orange = '#FFF1A10D',
	pink = '#FFEB9091',
	red = '#FFCD2B31',
	crimson = '#FFF65CB6',
	purple = '#FFAB4ABA',
}
local _c = {
		pxLineH = 19,
		menuPauseColInvert = true,
		menuPauseColInvertCenter = true,
		menu = {	-- { Text, Value: {str, [color]}, [State, Game, Address] }
			['  '] = {
				A = {t = 'History', v = {{'OFF'}, {'INPUT', COLOR.green}, {'HIT'}}, s = {'modeHistory'}},
				B = {t = 'Hitbox Viewer', v = {{'OFF'}, {'ON'}}, g = {'g', 'hitbox1'}},
				C = {t = 'Reset Max Damage'},
				Z = {t = 'Block', v = {{'ON'}, {'1-HIT'}, {'OFF'}}, s = {'modeGuard'}},
				Y = {t = 'Stun', v = {{'ON'}, {'1-HIT'}, {'OFF'}}, s = {'modeStun'}},
				X = {t = 'Neutral Stance', v = {{'STAND', COLOR.green}, {'CROUCH', COLOR.lightblue}, {'JUMP', COLOR.yellow}, {'DOUBLE', COLOR.orange}, {'HOP', COLOR.crimson}, {'HIGH', COLOR.purple}}, s = {'modeStance'}},
			},
			['R+'] = {
				A = {t = 'Quick Undizzy', v = {{'OFF'}, {'ON'}}, s = {'tech', 'dizzy'}},
				B = {t = 'Ground/Air Tech', v = {{'OFF'}, {'ON'}}, s = {'tech', 'ground'}},
				C = {t = 'Wall Slam Tech', v = {{'OFF'}, {'ON'}}, s = {'tech', 'wall'}},
				Z = {t = 'Wall Slide Tech', v = {{'OFF'}, {'ON'}}, s = {'tech', 'slide'}},
				Y = {t = 'Throw Tech', v = {{'OFF'}, {'ON'}}, s = {'tech', 'throw'}},
				X = {t = 'Mime Inputs', v = {{'OFF'}, {'ON'}, {'MIRROR'}}, s = {'modeInvert'}},
			},
			['L+'] = nil,
		},
-- -- -- -- -- -- -- -- -- -- -- -- Game constants below
		maxHP = 192,
		addr = {
			g = {
					menu = 0x0FFB82,	-- 99: main; 1: VS; 2: ranking; 3: DM; 4: config; 150: ingame
					modeVS = 0x07C9B6,	-- 0: PvP; 1: COM; 2: auto; 3: DEKU
					pause = 0x07984A,	--TODO P1 only?
					timer = 0x0903F2,
					combo = 0x0873FC,
					lastCombo = 0x086E12,
					hitbox1 = 0x0856B0,
					hitbox2 = 0x090402,	-- both need to be set to 1
				},
			p1 = {
					guardMode = 0x08593E,	--TODO
					sideFacingLeft = 0x086C74,
					health = 0x086F74,
					stun = 0x086CF2,
					timerStun = 0x086CF4,
					limitStun = 0x086CF8,
					meter = 0x086F7C,
					state = 0x0872C2,	--TODO
					state2 = 0x083EB0,	--TODO
					stick = 0x086D00,
					btn = 0x086D04,
				},
			p2 = {
					guardMode = 0x08593E,
					sideFacingLeft = 0x0872C4,
					health = 0x0875C4,
					stun = 0x087342,
					timerStun = 0x087344,
					limitStun = 0x087348,
					meter = 0x0875CC,
					state = 0x0872C2,
					state2 = 0x083EB0,
					stick = 0x087350,
					btn = 0x087356,
				},
			},
	}

local bool2str = {[false] = 'False', [true] = 'True', False = 'False', True = 'True', ['false'] = 'False', ['true'] = 'True'}
local int2bool = {[0] = false, [1] = true, [false] = false, [true] = true}
local function tonum (v)
	if v == false then return 0 end
	if v == true then return 1 end
	return tonumber(v)
end
function lenTable (t)
	local count = 0
	for _ in pairs( t ) do count = count + 1 end
	return count
end

local MENU = {
	main = 99,
	VS = 1,
	ranking = 2,
	deathmatch = 3,
	config = 4,
	ingame = 150,
}
local VS_MODE = {
	pvp = 0,
	com = 1,
	auto = 2,
	deku = 3,
}
local btnFlag = {
	A =   1,
	B =   2,
	X =   4,
	C =   8,	-- != A+B -> 1+2
	Y =  16,
	Z =  32,
	R =  64,	-- == 2+C+R ; !=2+C -> 8
	L = 128,	-- does nothing for the game's input reader
}

local function getPadState (p)
	b = joypad.get( p )
	s = 0
	-- row
	if b.Left then s = s + 1
	elseif b.Right then s = s + 3
	else s = s + 2 end
	-- col
	if b.Up then s = 3 * 2 + s
	elseif b.Down then
	else s = 3 * 1 + s end
	-- neutral
	if s == 5 then s = 0 end
	return {b = b, s = s}
end
local function getGameState ()
	tmp = {}
	for cat, set in pairs( _c.addr ) do
		tmp[cat] = {}
		for key, val in pairs( set ) do
			tmp[cat][key] = memory.readbyte( val )
		end
	end
	tmp.p1.inputsPad = getPadState(1)
	tmp.p2.inputsPad = getPadState(2)
	return tmp
end

local _s = {
	modeHistory = 1,	-- 0: off; 1: inputs; 2: hit data
	prntColCurr = 'left',
	lineCurr = {
		left = 0,
		center = 0,	--TODO
		right = 0,
	},
	lastComboDmg = 0,
	maxComboDmg = 0,
	lastMaxComboDmg = 0,
	offsQuickRec = -1,
	modeInvert = 0,	-- 0: off; 1: on; 2: mirrored
	modeGuard = 1,	-- 0: auto; 1: 1-hit; 2: off
	modeStun = 0,	-- 0: on; 1: 1-hit; 2: off
	modeStance = 0,	-- 0: stand; 1: crouch; 2: jump; 3: double jump; 4: hop; 5: high jump;
	hitboxes = false,
	tech = {
		throw = false,
		ground = true,
		wall = true,
		slide = true,
		dizzy = true,
	},
	p1 = 'p1',	-- invert helpers
	p2 = 'p2',
	p2Record = {
			dekuMash = {},
			running = 0,
			invertSide = 0,
			fRewind = 0,
			-- frameGameLast = 0,
			frameUpTo = 0,
			skipped = 0,
			triggerHeld = false,
		},
	prntInputsP1 = {{v = '', t = 0, tt = ''}},	--TODO meh; OLD: {{v = {b = 0, s = 0}, t = 0}}
	prntDmgP1 = {{v = '', t = 0, tt = ''}},	--also meh
	g = {getGameState(), getGameState()},	--TODO lmao as long as it works
}
local f = 0
local s = getGameState()
local s2 = s

local cClient = {
	borderheight = 0,
	borderwidth = 0,
	bufferheight = 0,
	bufferwidth = 0,
	getwindowsize = 1,
}
local cClient2 = {}
local function clientUpdateCache ()
	for key, val in pairs( cClient ) do
		cClient2[key] = cClient[key]
	end

	mult = 1
	if s.g.menu ~= MENU.ingame then mult = 0.5 end 	-- ???
	cClient.borderheight = client.borderheight()
	cClient.borderwidth = client.borderwidth()
	cClient.bufferheight = math.floor( client.bufferheight() * mult )
	cClient.bufferwidth = math.floor( client.bufferwidth() * mult )
	cClient.getwindowsize = client.getwindowsize()

	diff = false
	for key, val in pairs( cClient ) do
		if cClient[key] ~= cClient2[key] then
			diff = true
		end
	end
	cClient2.isChanged = diff
end

local _padsNew = {{}, {}}
local function setPad ( btns, p )
	for key, val in pairs( btns ) do
		_padsNew[p][key] = val
	end
end
local function drawRect ( x, y, width, height, bg, outline )
	if outline == nil then outline = bg end
	x2 = x + width
	y2 = y + height
	if _s.prntColCurr == 'right' then	--FIXME heck
		x = cClient.bufferwidth * cClient.getwindowsize - x
		x2 = x - width
	end
	gui.drawBox( x, y, x2, y2, outline, bg, 'client' )
end
local function prnt (str, color, col)
	if str == nil then str = '' end
	if col == nil then col = _s.prntColCurr end
	colFix = col
	if col == 'center' then
		colFix = 'left'
		str = string.format( '%' .. 50 .. 's', str )	--TODO slow if printing many lines
	elseif col == 'right' then
		pad = 34
		if _c. menuPauseColInvert then pad = 22 end
		str = string.format( '%-' .. pad .. 's', str )	--TODO slow if printing many lines
	end
	_s.lineCurr[col] = _s.lineCurr[col] + 1
	gui.text( _c.pxLineH, cClient.borderheight + _s.lineCurr[col] * _c.pxLineH, str, color, 'top' .. colFix )
end
local function prntLeft (str, color)
	prnt( str, color, 'left' )
end
local function prntRight (str, color)
	prnt( str, color, 'right' )
end


local function prntStateDummy ()
	P2State = s[_s.p2].state2
	msg = ''
	if P2State == 0 then msg = 'Hit'
	elseif P2State == 127 then msg = 'Clash!'
	elseif P2State == 8 then msg = 'Thrown'
	elseif P2State == 15 then msg = 'Idle' end
	prnt( 'P2 State: ' .. msg .. ' (' .. P2State .. ' ' .. s[_s.p2].state .. ')' )
end

local function refillHP ()
	if s.p2.state == 0 and s.p1.timerStun <= ( 192 - 192 / 3 ) then
		memory.writebyte( _c.addr.p1.health, _c.maxHP )
		memory.writebyte( _c.addr.p1.stun, 0 )
		memory.writebyte( _c.addr.p1.timerStun, 0 )
		-- memory.writebyte( _c.addr.p2.meter, 0 )	--TODO also breaks the hit data meter counter, prints a line every frame
	end

	if s.p2.state == 0 and s.p2.state2 == 15 and (
		s.p2.timerStun <= ( 192 - 192 / 2 ) and s.p2.timerStun ~= 0
		or _s.modeStun == 1 and ( s2.p2.state ~= 0 or s2.p2.state2 ~= 15 )
	) then
		memory.writebyte( _c.addr.p2.health, _c.maxHP )
		if _s.modeStun ~= 1 then
			memory.writebyte( _c.addr.p2.stun, 0 )
			memory.writebyte( _c.addr.p2.timerStun, 0 )
		end
		-- memory.writebyte( _c.addr.p1.meter, 0 )
	end

	if _s.modeStun == 2 then
		memory.writebyte( _c.addr[_s.p2].stun, 0 )
	elseif _s.modeStun == 1 and s[_s.p2].state == 0 and s[_s.p2].stun == 0 then
		memory.writebyte( _c.addr[_s.p2].stun, s[_s.p2].limitStun - 1 )
	end
end
function prntComboDamageMax ()
	if _s.lastComboDmg > _s.maxComboDmg then
		_s.lastMaxComboDmg = _s.maxComboDmg
		_s.maxComboDmg = _s.lastComboDmg
	end
	prnt( 'Max Damage: ' .. _s.maxComboDmg .. ' (' .. _s.lastMaxComboDmg .. ')' )
end

local function fmtStick (n)
	str = ''
	if n == 1 or n == 4 or n == 7 then str = str .. '<' else str = str .. ' ' end
	if n == 0 then str = str .. ' '
		elseif n == 7 or n == 8 or n == 9 then str = str .. '^'
		elseif n == 1 or n == 2 or n == 3 then str = str .. 'v'
		else str = str .. ' ' end
	if n == 3 or n == 6 or n == 9 then str = str .. '>' else str = str .. ' ' end
	return str
end
local function fmtButtons (bf)
	str = ''
	if bit.band( btnFlag.A, bf ) ~= 0 then str = str .. 'A' else str = str .. ' ' end
	if bit.band( btnFlag.B, bf ) ~= 0 then str = str .. 'B' else str = str .. ' ' end
	if bit.band( btnFlag.C, bf ) ~= 0 then str = str .. 'C' else str = str .. ' ' end
	if bit.band( btnFlag.X, bf ) ~= 0 then str = str .. 'X' else str = str .. ' ' end
	if bit.band( btnFlag.Y, bf ) ~= 0 then str = str .. 'Y' else str = str .. ' ' end
	if bit.band( btnFlag.Z, bf ) ~= 0 then str = str .. 'Z' else str = str .. ' ' end
	-- if bit.band( btnFlag.L, bf ) ~= 0 then str = str .. 'L' else str = str .. ' ' end
	if bit.band( btnFlag.R, bf ) ~= 0 then str = str .. 'R' else str = str .. ' ' end
	return str
end
local function historyInput ()	--NOTE sepDrop inserted by historyHit()
	inp = _s.prntInputsP1

	curr = {s = s.p1.stick, b = s.p1.btn}
	str = fmtStick( curr.s ) .. ' ' .. fmtButtons( curr.b )
	if str ~= inp[#inp].v then
		inp[#inp+1] = {v = str, t = 1, tt = string.format( '%3u', 1 )}
	else
		inp[#inp].t = inp[#inp].t + 1
		inp[#inp].tt = string.format( '%3u', math.min( inp[#inp].t, 999 )  )
	end
end
local function historyHit ()
	dmg = _s.prntDmgP1

	sepDrop = ' --  DROP    '

	diff = {
		h = s2[_s.p2].health - s[_s.p2].health,
		s = s[_s.p2].stun - s2[_s.p2].stun,
		m = ( s[_s.p1].meter - s2[_s.p1].meter ) * 120 / 192,
	}
	totDiff = diff.h + diff.s + diff.m

	if totDiff > 0
		or s[_s.p2].state > 26 and s2[_s.p2].state <= 26	-- act
		or s[_s.p2].state == 0 and s2[_s.p2].state ~= 0	-- idle
		or s[_s.p2].state == 1 and s2[_s.p2].state ~= 1	-- crouch
		-- or s[_s.p1].inputsPad.b.R and not s2[_s.p1].inputsPad.b.R	--DEBUG
	then
		tmp = {v = nil, t = 1}
		if dmg[#dmg].v ~= sepDrop and (
			s.g.combo == 0 and s2.g.combo > 0
			or 29 <= s2[_s.p2].state and s2[_s.p2].state <= 31
				and ( s[_s.p2].state < 29 or 31 < s[_s.p2].state )	-- blockstun
		) then
			tmp.v = sepDrop
			_s.prntInputsP1[#_s.prntInputsP1+1] = tmp
		elseif totDiff > 0 then
			tmp.v = string.format( '%3u%4u%6.2f', diff.h, diff.s, diff.m )
		end
		if tmp.v then
			tmp.tt = string.format( '%3u', 1 )
			dmg[#dmg+1] = tmp
		end
	else
		dmg[#dmg].t = dmg[#dmg].t + 1
		dmg[#dmg].tt = string.format( '%3u', math.min( dmg[#dmg].t, 999 ) )
	end
end


local function prntHistoryInput ()
	inp = _s.prntInputsP1

	if _s.modeHistory == 1 then
		i = 0
		skipped = 0
		repeat
			tmp = inp[#inp - i]
			if tmp.v == '           ' and tmp.t <= 9 and i > 0 then
				skipped = skipped + 1
			else
				prnt( tmp.tt .. ' ' .. tmp.v, COLOR.white )
			end
			i = i + 1
		until i >= math.min( #inp - 1, 40 + skipped )
	end
end
local function prntHistoryHit ()
	dmg = _s.prntDmgP1

	if _s.modeHistory == 2 then
		prnt( ' f  Dmg  Stn  Mtr', COLOR.lightgray )
		i = 0
		repeat
			tmp = dmg[#dmg - i]
			prnt( tmp.tt .. ' ' .. tmp.v, COLOR.white )
			i = i + 1
		until i >= math.min( #dmg - 1, 40 )
	end
end

local function p2ToDummy ()
	st = s[_s.p2].state

	if _s.modeGuard == 0 then
		memory.writebyte( _c.addr[_s.p2].guardMode, 0 )
	elseif _s.modeGuard == 1 then
		if s[_s.p2].health < _c.maxHP then
			memory.writebyte( _c.addr[_s.p2].guardMode, 0 )
		else
			memory.writebyte( _c.addr[_s.p2].guardMode, 1 )
		end
	elseif _s.modeGuard == 2 then
		memory.writebyte( _c.addr[_s.p2].guardMode, 1 )
	end

	if s.g.pause == 0 then
		if _s.offsQuickRec == -1 then _s.offsQuickRec = f % 2 end
		dirTech = ({'Left', 'Right'})[s[_s.p1].sideFacingLeft + 1]

		tmp = {}
		tech = true
		if st > 18 and st < 23 or st == 25 then	-- 22 ground-slam; 21 and 22 should be too late but don't hurt, 19 too early
			if _s.tech.ground then
				if f % 2 == _s.offsQuickRec then tmp.Up = true end
			else tech = false end
		elseif st == 18 then	-- happens often after generic hitstun
			tech = false
			if _s.tech.wall then
				if f % 2 == _s.offsQuickRec then tmp[dirTech] = true end
			end
		elseif s.p2.state == 13 and s.p2.state2 == 8 and _s.g[#_s.g - 9].p2.state2 == 8 then	-- grab
			if _s.tech.throw then
				-- setPad( {[dirTech] = true}, 2 )	--NOTE you can tech with no direction if facing right	--TODO
				-- tech = false	--DEBUG
			else tech = false end
		elseif st == 26 then	-- air throw
			if _s.tech.throw then
				tmp[dirTech] = true
			else tech = false end
		elseif st == 17 then	-- generic hitstun
			if _s.tech.slide and s.p1.sideFacingLeft == s.p2.sideFacingLeft then
				if f % 2 == _s.offsQuickRec then tmp[dirTech] = true end
			else tech = false end
		elseif st == 15 then	-- dizzy
			tech = false
			if _s.tech.dizzy then
				if f % 2 == _s.offsQuickRec then
					tmp[dirTech] = true
				else
					tmp.Down = true
				end
			end
		else
			tech = false
			_s.offsQuickRec = -1
		end
		if tech then
			if f % 2 == _s.offsQuickRec then tmp.B = true end
		end
		setPad( tmp, 2 )
	end
end

local function pInvert (v)
	if v == nil then
		v = ( _s.modeInvert + 1 ) % 3
	end

	_s.modeInvert = v
	-- if v then	--TODO
	-- 	_s.p1 = 'p1'
	-- 	_s.p2 = 'p2'
	-- else
	-- 	_s.p1 = 'p2'
	-- 	_s.p2 = 'p1'
	-- end
end
local function p2Control ()
	r = _s.p2Record

	if s.g.menu == MENU.VS and s.p1.inputsPad.b.L ~= s2.p1.inputsPad.b.L then
		pInvert( ( _s.modeInvert + 1 ) % 2 )
	end
	if s.g.menu ~= s2.g.menu then
		r.running = 0
		r.dekuMash = {}
		pInvert( 0 )
		if s.g.menu == MENU.VS and s.p1.inputsPad.b.L then pInvert( 1 ) end	-- otherwise if holding L trough menu transition it inverts until switching again
	end

	if s.g.pause == 1 then
		if s2.g.pause == 0 then
			r.dekuMash = {}
			-- r.frameGameLast = #_s.g - 1
		end
		if r.running > 0 then
			r.skipped = r.skipped - 1
		end
	else
		if s2.g.pause == 0 and s2.p1.inputsPad.b.Start and not s.p1.inputsPad.b.Start then
			tmp = {}
			for key, val in pairs( s.p1.inputsPad.b ) do
				if val and key ~= 'Start' and key ~= 'L' then
					tmp[key] = true
				end
			end
			r.dekuMash = tmp
		end
		if _s.modeInvert > 0 then
			tmp = {}
			for key, val in pairs( s.p1.inputsPad.b ) do
				if key ~= 'Start' and key ~= 'L' then
					tmp[key] = tmp[key] or val
				end
			end
			if _s.modeInvert == 2 then
				tmpLeft = tmp['Left']
				tmp['Left'] = tmp['Right']
				tmp['Right'] = tmpLeft
			end
			setPad( tmp, 2 )

			null = {}
			for key, _ in pairs( s.p1.inputsPad.b ) do
				if key ~= 'Start' and key ~= 'L' then
					null[key] = false
				end
			end
			-- setPad( null, 1 )	--FIXME
		elseif s.g.menu == MENU.ingame then
			if r.running > 0 then
				starting = r.frameUpTo - r.fRewind

				offset = ( f - r.running + r.skipped ) % r.fRewind
				while _s.g[starting + offset].g.pause == 1 do
					offset = ( f - r.running + r.skipped ) % r.fRewind
					r.skipped = r.skipped + 1
				end

				if offset == 0 then
					r.skipped = 0
					if _s.g[starting].p2.sideFacingLeft == s.p2.sideFacingLeft then
						r.invertSide = 1
					else
						r.invertSide = 0
					end
				end

				tmp = {}
				for k, v in pairs( _s.g[starting + offset].p1.inputsPad.b ) do tmp[k] = v end
				tmp.Start = false
				tmp.L = false
				if r.invertSide == 1 and ( tmp.Left or tmp.Right ) then
					tmp.Left = not tmp.Left
					tmp.Right = not tmp.Right
				end
				setPad( tmp, 2 )
			elseif lenTable( r.dekuMash ) > 0 then
				tmp = {}
				for key, val in pairs( r.dekuMash ) do
					if string.len( key ) > 1 then
						tmp[key] = val
					elseif f % 2 > 0 then
						tmp[key] = val
					else
						tmp[key] = not val
					end
				end
				setPad( tmp, 2 )
			elseif _s.modeStance == 1 then
				setPad( {Down = true}, 2 )
			elseif _s.modeStance == 2 then
				if s.p2.state == 0 then
					setPad( {Up = true}, 2 )
				end
			elseif _s.modeStance == 3 then
				if s.p2.state == 0 or s.p2.state == 11 then
					setPad( {Up = true}, 2 )
				end
			elseif _s.modeStance == 4 then
				if s.p2.state == 0 then
					setPad( {Down = true, Z = true}, 2 )
				end
			elseif _s.modeStance == 5 then
				if s.p2.state == 0 then
					setPad( {Z = true}, 2 )
				end
			end
		end
	end
end

local function ctlSettings ()
	r = _s.p2Record

	if s.g.pause == 1 then
		if not s.p1.inputsPad.b.L then
			if not s.p1.inputsPad.b.R then	-- raw b
				if s.p1.inputsPad.b.A and not s2.p1.inputsPad.b.A then
					-- if _DEBUG then
						_s.modeHistory = ( _s.modeHistory + 1 ) % 3
					-- else
					-- 	_s.modeHistory = ( _s.modeHistory + 1 ) % 2
					-- end
				end
				if s.p1.inputsPad.b.B and not s2.p1.inputsPad.b.B then
					_s.hitboxes = not _s.hitboxes
				end
				if s.p1.inputsPad.b.C and not s2.p1.inputsPad.b.C then
					_s.lastMaxComboDmg = _s.maxComboDmg
					_s.lastComboDmg = 0
					_s.maxComboDmg = 0
				end
				if s.p1.inputsPad.b.Z and not s2.p1.inputsPad.b.Z then
					_s.modeGuard = ( _s.modeGuard + 1 ) % 3
				end
				if s.p1.inputsPad.b.Y and not s2.p1.inputsPad.b.Y then
					_s.modeStun = ( _s.modeStun + 1 ) % 3
				end
				if s.p1.inputsPad.b.X and not s2.p1.inputsPad.b.X then
					_s.modeStance = ( _s.modeStance + 1 ) % 6
				end
			elseif s.p1.inputsPad.b.R then	--	 R+b
				if s.p1.inputsPad.b.A and not s2.p1.inputsPad.b.A then
					_s.tech.dizzy = not _s.tech.dizzy
				end
				if s.p1.inputsPad.b.B and not s2.p1.inputsPad.b.B then
					_s.tech.ground = not _s.tech.ground	--TODO ground-slam tech grouped with air and wakeup
				end
				if s.p1.inputsPad.b.C and not s2.p1.inputsPad.b.C then
					_s.tech.wall = not _s.tech.wall
				end
				if s.p1.inputsPad.b.Z and not s2.p1.inputsPad.b.Z then
					_s.tech.slide = not _s.tech.slide
				end
				if s.p1.inputsPad.b.Y and not s2.p1.inputsPad.b.Y then
					_s.tech.throw = not _s.tech.throw
				end
				if s.p1.inputsPad.b.X and not s2.p1.inputsPad.b.X then
					pInvert()
				end
			end
		else	-- L+b
		end
	else
		fHold = 45

		if #_s.g > fHold + 2 then
			r.triggerHeld = true
			for i = 1, fHold do
				if not _s.g[f - i - 1].p1.inputsPad.b.L then
					r.triggerHeld = false
					break
				end
			end

			if r.triggerHeld then
				r.running = 0
			end

			if s2.p1.inputsPad.b.L and not s.p1.inputsPad.b.L then
				if r.triggerHeld then
					r.running = 0
					r.frameUpTo = -1
					r.skipped = 0
					r.fRewind = f
				else
					if r.frameUpTo == -1 then
						r.frameUpTo = f
						r.fRewind = r.frameUpTo - r.fRewind
					else
						if r.running == 0 then
							r.running = f
						else
							r.running = 0
						end
					end
				end
			end
		end
	end
end
local function prntMenu ()
	colTxt = COLOR.lightgray
	if _c. menuPauseColInvert then colTxt = white end

	prnt( '   Hold [L] to record, press', colTxt )
	prnt( '   again to save and replay', colTxt )

	prnt()
	for _, mod in ipairs( {'  ', 'R+', 'L+'} ) do if _c.menu[mod] then
		for _, b in pairs( {'A', 'B', 'C', '', 'Z', 'Y', 'X'} ) do
			if b == '' then
				prnt()
			else
				v = nil
				color = colTxt
				if not _c.menu[mod][b] then
					e = {t = '--                     '}
					color = color.lightgray
				else
					e = _c.menu[mod][b]
					if e.s then
						v = _s
						for _, k in ipairs(e.s) do
							v = v[k]
						end
					elseif e.g then
						v = s
						for _, k in ipairs(e.g) do
							v = v[k]
						end
					elseif e.a then --TODO
						-- v = memory.readbyte( e.a )
					end
				end
				strV = {'', ''}
				if v ~= nil then
					objV = e.v[tonum(v) + 1]
					if not objV[2] then
						if objV[1] == 'OFF' then objV[2] = COLOR.pink
						elseif objV[1] == 'ON' then objV[2] = COLOR.green
						else objV[2] = COLOR.yellow end
					end
					strV[1] = ':'
					strV[2] = objV[1]
					color = objV[2]
				end
				alignRight = {
					string.format( '%-23s', mod .. b .. ' : ' .. e.t .. strV[1] ),
					string.format( '%6s', strV[2] ),
				}
				prnt( alignRight[1] .. alignRight[2] , color )
			end
		end
		prnt()
		prnt()
	end end
	_s.lineCurr[_s.prntColCurr] = _s.lineCurr[_s.prntColCurr] - 2

	prnt()
	prnt( 'Exiting pause hold [Start] and', colTxt )
	prnt( 'release with buttons to replay', colTxt )
end

local function prntReplay ()
	r = _s.p2Record

	if r.triggerHeld then
		prnt( '[ ] Release to record' )
		prnt()
		prnt( '    Press [Start]' )
		prnt( '    to cancel' )
	elseif r.frameUpTo == -1 then
		if math.floor( ( f % 120 ) / 60 ) == 0 then
			prnt( '[ ]  REC' )
			_s.lineCurr[_s.prntColCurr] = _s.lineCurr[_s.prntColCurr] - 1
			prnt( ' O      ', COLOR.red )
		else
			prnt( '[ ]  REC' )
		end
	elseif r.running > 0 then
		prnt( '[ ]  PLAY' )
		_s.lineCurr[_s.prntColCurr] = _s.lineCurr[_s.prntColCurr] - 1
		prnt( ' >       ', COLOR.green )
	end
end


local function frameStart ()

	--NOTE init
	_s.g[#_s.g + 1] = getGameState()
	s2 = s
	s = _s.g[#_s.g]
	f = #_s.g
	_padsNew = {{}, {}}
	gui.use_surface( 'client' )
	clientUpdateCache()
	prcntPadVert = 0	--TODO proper config
	if s.g.menu ~= MENU.ingame then
		prcntPadVert = 15
	else
		prcntPadVert = 25
	end
	_s.lineCurr.left = math.floor( cClient.bufferheight * cClient.getwindowsize * prcntPadVert / 100 / _c.pxLineH )
	_s.lineCurr.center = _s.lineCurr.left
	_s.lineCurr.right = _s.lineCurr.left

	--NOTE inputs
	historyInput()
	ctlSettings()
	p2ToDummy()
	p2Control()
	joypad.set( _padsNew[1], 1 )
	joypad.set( _padsNew[2], 2 )

end
local function frameEnd ()

	--NOTE game logic
	if s.g.combo < _s.g[#_s.g - 1].g.combo then
		-- memory.writebyte( _c.addr[_s.p2].health, _c.maxHP )	--DEBUG
		_s.lastComboDmg = _c.maxHP - _s.g[#_s.g - 1][_s.p2].health
	end
	historyHit()
	refillHP()
	memory.writebyte( _c.addr.g.timer, 98 )	--TODO config or find ingame timer setting address
	hboxes = tonum( _s.hitboxes )
	if s.g.hitbox1 ~= hboxes then
		memory.writebyte( _c.addr.g.hitbox1, hboxes )
		memory.writebyte( _c.addr.g.hitbox2, hboxes )
	end

	--NOTE output
	if s.g.menu ~= s2.g.menu or s.g.pause ~= s2.g.pause or #_s.g < 4 or cClient2.isChanged then
		gui.clearGraphics()
		if s.g.menu == MENU.ingame then	--TODO config
			_s.prntColCurr = 'left'
			lHeight = 6
			width = 220
			if s.g.pause == 1 then
				if _c.menuPauseColInvert then
					lHeight = 23.4
					width = 340
					if _c.menuPauseColInvertCenter then
						width = 550
					end
				end
			end
			drawRect( 0, ( _s.lineCurr[_s.prntColCurr] + 0.5 ) * _c.pxLineH, width, lHeight * _c.pxLineH, '#BB16161d' )
		end
	end
	if s.g.menu == MENU.main or s.g.menu == MENU.VS then
		prntLeft( '          Pick "VS GAME" & enter 2 Players mode ( NOT DEKU! )' )

		prntRight()
		prntRight( "To start the match you can control P2's cursor while holding [L]          " )
	elseif s.g.menu == MENU.ingame then
		_s.prntColCurr = 'left'
		if _c.menuPauseColInvert and not _c.menuPauseColInvertCenter and s.g.pause == 1 then _s.prntColCurr = 'right' end

		prnt( 'Combo: ' .. s.g.combo .. ' (' .. s.g.lastCombo .. ')' )

		prnt()
		prnt( 'Damage: ' .. _c.maxHP - s[_s.p2].health .. ' (' .. _s.lastComboDmg .. ')' )
		prnt( 'Stun: ' .. s[_s.p2].stun .. '/' .. s[_s.p2].limitStun .. " - " .. s[_s.p2].timerStun )
		prntComboDamageMax()
		if _DEBUG then prntStateDummy() end

		prnt()
		prntHistoryHit()
		prntHistoryInput()

		_s.prntColCurr = 'right'
		if _c.menuPauseColInvert and s.g.pause == 1 then
			if _c.menuPauseColInvertCenter then
				_s.prntColCurr = 'center'
			else
				_s.prntColCurr = 'left'
			end
		end

		if s.g.pause == 0 then
			prntReplay()
		else
			prntMenu()
		end
	end

end


gui.clearGraphics()
gui.cleartext()
gui.clearImageCache()
event.unregisterbyname( 'ALO120T_frameStart' )
event.unregisterbyname( 'ALO120T_frameEnd' )

event.onframestart( frameStart, 'ALO120T_frameStart' )
event.onframeend( frameEnd, 'ALO120T_frameEnd' )

-- while true do
-- 	frameStart()
-- 	frameEnd()
-- 	emu.frameadvance()
-- end

if not _DEBUG then
	event.onexit( function () 
		event.unregisterbyname( 'frameStart' )
		event.unregisterbyname( 'frameEnd' )
		gui.clearGraphics()
		gui.cleartext()
		gui.clearImageCache()
	end)
	while true do emu.frameadvance() end
end
