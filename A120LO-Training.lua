
	-- -- -- --
	-- Asuka 120% LimitOver BURNING Fest.
	-- BizHawk Training Script
	-- + Game wiki: https://wiki.gbl.gg/w/Asuka_120_LimitOver
	-- + English netplay community: https://discord.gg/GpYn2Tx
	-- -- -- -- -- --


local _SCRIPT_VER = '2.1.0'
local _ORIGIN = 'https://github.com/VickGE/A120LO-LUA/blob/master/README.md'


--	bitzhawk namespaces
local bizstring = bizstring
local client = client
local console = console
local emu = emu
local event = event
local gui = gui
local joypad = joypad
local memory = memory
local userdata = userdata

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
local _c = {	-- constants / script setup
		pxLineH = 19,
		menuPauseColInvert = true,
		menuPauseColInvertCenter = true,
		menu = {	-- { Text, Value: {str, [color]}, [State, Game, Address] }
			['  '] = {
				A = {t = 'History', v = {{'OFF'}, {'INPUT', COLOR.green}, {'HIT'}}, s = {'modeHistory'}},
				B = {t = 'Hitbox Viewer', v = {{'OFF'}, {'ON'}}, s = {'hitboxes'}},
				C = {t = 'Reset Dmg Stats'},
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
				X = {t = 'Control P2', v = {{'OFF'}, {'INVERT', COLOR.green}, {'MIME', COLOR.lightblue}, {'MIRROR'}}, s = {'modeInvert'}},
			},
			['L+'] = {
				A = {t = 'P1 HP +Guts (%)', v = {{'100+50', COLOR.green}, {'99 +25'}, {'90 +15'}, {'80 + 5'}, {'70  / ', COLOR.orange}, {'50  / ', COLOR.orange}, {'30 -10', COLOR.red}, {'10 -15', COLOR.red}}, s = {'hpRefill', 'p1', 'mode'}},
				B = {t = 'P2 HP +Guts (%)', v = {{'100+50', COLOR.green}, {'99 +25'}, {'90 +15'}, {'80 + 5'}, {'70  / ', COLOR.orange}, {'50  / ', COLOR.orange}, {'30 -10', COLOR.red}, {'10 -15', COLOR.red}}, s = {'hpRefill', 'p2', 'mode'}},
				-- C = {t = 'Input Delay', v = {{'0', COLOR.green}, {'1', COLOR.lightblue}, {'2', COLOR.white}, {'3', COLOR.lightgray}, {'4', COLOR.yellow}, {'5', COLOR.orange}, {'6', COLOR.pink}, {'7', COLOR.crimson}, {'8', COLOR.purple}, {'9', COLOR.red}}, s = {'fInputDelay', 'f'}},
				C = {t = 'Input Delay', v = {{'0', COLOR.green}, {'2', COLOR.yellow}, {'4', COLOR.orange}, {'6', COLOR.pink}, {'8', COLOR.crimson}, {'10', COLOR.red}, {'SPIKES', COLOR.purple}}, s = {'fInputDelay', 'f'}},
			},
		},
		-- -- Game constants below
		maxHP = 192,	--NOTE max memory value
		addr = {
			g = {	-- game
					scene = 0x0FFB82,	-- 99: main; 1: VS; 2: ranking; 3: DM; 4: config; 150: ingame
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
local function randomExp (rate)
	if rate == nil then rate = 1 end

	return -math.log( math.random() ) / rate
end
-- local function randomGeom (prob)
-- 	if prob == nil then prob = 0.6321205588285577 end	-- 1 - math.exp( -1 )
-- 	return math.floor( randomExp( -math.log( 1 - prob ) ) )
-- end
local function lenTable (t)
	local count = 0
	for _ in pairs( t ) do count = count + 1 end
	return count
end
local function tblCopy (t, deep)
	if deep == nil then deep = false end

	local tmp
	if type( t ) == 'table' then
		tmp = {}
		for k, v in next, t, nil do
			if deep then
				tmp[tblCopy( k, deep )] = tblCopy( v, deep )
			else
				tmp[k] = v
			end
		end
		if deep then
			setmetatable( tmp, tblCopy( getmetatable( t ), deep ) )
		else
			setmetatable( tmp, getmetatable( t ) )
		end
	else -- number, string, boolean, etc
		tmp = t
	end
	return tmp
end
local function padStart (len, str, char, lenStr)
	if str == nil then str = '' end
	if len == nil then len = 0 end
	if char == nil then char = ' ' end
	if lenStr == nil then
		str = tostring( str )
		lenStr = #str
	end

	return string.rep( char, len - lenStr ) .. str
end
local function padEnd (len, str, char, lenStr)
	if str == nil then str = '' end
	if len == nil then len = 0 end
	if char == nil then char = ' ' end
	if lenStr == nil then lenStr = #str end

	return str .. string.rep( char, len - lenStr )
end

local function _tableSerialize (target, k, v, max)
	if type( v ) ~= 'table' then
		target[k] = v
	else
		local _lV = #v
		if v[1] == nil or _lV < max then
			local starting = math.max( _lV - max, 0 )
			for k2, v2 in pairs( v ) do
				local tmp = tonumber( k2 )
				if tmp == nil or tmp > starting then
					_tableSerialize( target, k .. '.' .. k2, v2, max )
				end
			end
		end
	end
end
local function tableSerialize (k, v, max)
	max = tonum( max ) or 0

	local tmp = {}
	_tableSerialize( tmp, k, v, max )
	return tmp
end


local SCENE = {
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

local GUTS = {
	[0] = 192,
	[1] = 191,
	[2] = 172,
	[3] = 153,
	[4] = 134,
	[5] = 96,	-- not actually a guts threshold, but halfway the main block at 50% max HP for conveniente
	[6] = 57,
	[7] = 19,
}
local BTN_FLAG = {
	A =   1,
	B =   2,
	X =   4,
	C =   8,	-- != A+B -> 1+2
	Y =  16,
	Z =  32,
	R =  64,	-- == 2+C+R ; !=2+C -> 8
	L = 128,	-- does nothing for the game's input reader
}

local function bToNumpad (b)
	local s = 0
	-- row
	if b.Left then s = s + 1
	elseif b.Right then s = s + 3
	else s = s + 2 end
	-- col
	if b.Up then s = 3 * 2 + s
	elseif b.Down then s = s
	else s = 3 * 1 + s end
	-- neutral
	if s == 5 then s = 0 end
	return s
end
local function getPadState (p)
	local tmpB = joypad.getimmediate( p )
	local flag = 0
	for k, v in pairs( tmpB ) do
		if v and BTN_FLAG[k] then
			flag = flag + BTN_FLAG[k]
		end
	end
	return {b = tmpB, s = bToNumpad( tmpB ), fB = flag }
end
local function getGameState ()
	local tmp = {}
	for cat, set in pairs( _c.addr ) do
		tmp[cat] = {}
		for key, val in pairs( set ) do
			tmp[cat][key] = memory.readbyte( val )
		end
	end
	return tmp
end

local _s = {	-- state
	f = 0,	-- scrip running frame counter
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
	hpRefill = {
		p1 = {
			mode = 4,	-- 0: _c.maxHP; ... guts ...; 7: 19
			trigger = true,
		},
		p2 = {
			mode = 4,
			trigger = true,
		},
	},
	modeInvert = 0,	-- 0: off; 1: invert; 2: mime; 3: mirrored
	modeGuard = 1,	-- 0: auto; 1: 1-hit; 2: off
	modeStun = 0,	-- 0: on; 1: 1-hit; 2: off
	modeStance = 0,	-- 0: stand; 1: crouch; 2: jump; 3: double jump; 4: hop; 5: high jump;
	fInputDelay = {
		f = 0,
		rand = 0,
		retries = 0,
	},
	hitboxes = true,
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
		pOrigin = 'p1',
		dekuMash = {},
		running = 0,
		invertSide = 0,
		fRewind = 0,
		frameUpTo = 0,
		skipped = 0,
		triggerHeld = false,
		curr = 0,
	},
	_prntInputsP1 = {{v = '', t = 0, tt = ''}},	-- meh; OLD: {{v = {b = 0, s = 0}, t = 0}}
	_prntDmgP1 = {{v = '', t = 0, tt = ''}},
	g = {},
}
local _sPads = {}	-- inputs
for _ = 1, 20 do	--NOTE lmao as long as it works
	table.insert( _s.g, getGameState() )
	table.insert( _sPads, {p1 = getPadState( 1 ), p2 = getPadState( 2 )} )
end
local _lSPads = #_sPads
local sPads = _sPads[_lSPads]	-- shortcut to state of current input
local s2Pads = sPads	-- shortcut to state of previous input
local _lS_g = #_s.g
local s = _s.g[_lS_g]	-- shortcut to state of current frame
local s2 = s	-- shortcut to state of previous frame
local sNew = {	-- temp object to carry changes for application from frameStart to frameEnd
	g = {},
	p1 = {},
	p2 = {},
}

local function strSplit (inputStr, sep)
	sep = sep or '%s'
	local t = {}
	for str in string.gmatch( inputStr, '([^'..sep..']+)' ) do
		table.insert( t, str )
	end
	return t
end
local function setScriptState ()
	for k, v in pairs( tableSerialize( '_s', _s, 0 ) ) do
		userdata.set( k, v )
	end
end
local function getScriptState ()
	for k, _ in pairs( tableSerialize( '_s', _s, 0 ) ) do
		if not ( k == '_s.modeHistory'	--TODO proper config
			or k == '_s.hitboxes'
			or k == '_s.fInputDelay.f'
			or string.find( k, '_s.p2Record.', 1, true )
			or string.find( k, '_s.hpRefill.', 1, true )
			or string.find( k, '_s.fInputDelay.f', 1, true )
		) then
			local valOld = userdata.get( k )
			local tmp = {_s = _s}

			local path = strSplit( k, '.' )
			local _lPath = #path
			local key = path[_lPath]
			for i, k2 in ipairs( path ) do
				if i < _lPath then
					tmp = tmp[k2]	--FIXME broken with arrays
				end
			end
			if valOld ~= nil then
				tmp[key] = valOld
			end
		end
	end
end

local cClient = {
	borderheight = 0,
	borderwidth = 0,
	bufferheight = 0,
	bufferwidth = 0,
	getwindowsize = 1,
}
local cClient2 = {}
local function clientUpdateCache ()
	for k, _ in pairs( cClient ) do
		cClient2[k] = cClient[k]
	end

	local mult = 1
	if s.g.scene ~= SCENE.ingame then mult = 0.5 end 	-- ???
	cClient.borderheight = client.borderheight()
	cClient.borderwidth = client.borderwidth()
	cClient.bufferheight = math.floor( client.bufferheight() * mult )
	cClient.bufferwidth = math.floor( client.bufferwidth() * mult )
	cClient.getwindowsize = client.getwindowsize()

	local diff = false
	for k, _ in pairs( cClient ) do
		if cClient[k] ~= cClient2[k] then
			diff = true
		end
	end
	cClient2.isChanged = diff
end

local PAD_NULL = {}
for key, _ in pairs( sPads.p1.b ) do
	if key ~= 'Start' and key ~= 'L' then
		PAD_NULL[key] = false
	end
end
local _padsNew = {p1 = {}, p2 = {}}
local function setPad ( btns, p )
	for key, val in pairs( btns ) do
		_padsNew['p' .. p][key] = val
	end
end
local function drawRect ( x, y, width, height, bg, outline )
	if outline == nil then outline = bg end

	local x2 = x + width
	local y2 = y + height
	if _s.prntColCurr == 'right' then	--FIXME heck
		x = cClient.bufferwidth * cClient.getwindowsize - x
		x2 = x - width
	end
	gui.drawBox( x, y, x2, y2, outline, bg, 'client' )
end
local function prnt (str, color, col, lenStr)
	if str == nil then str = '' end
	if col == nil then col = _s.prntColCurr end

	_s.lineCurr[col] = _s.lineCurr[col] + 1
	if str ~= '' then
		local colFix = col
		if col == 'center' then
			colFix = 'left'
			str = padStart( 50, str, ' ', lenStr )--NOTE slow if printing many lines
		elseif col == 'right' then
			local pad = 34
			if _c. menuPauseColInvert then pad = 22 end
			str = padEnd( pad, str, ' ', lenStr )	--NOTE slow if printing many lines
		end
		gui.text( _c.pxLineH, cClient.borderheight + _s.lineCurr[col] * _c.pxLineH, str, color, 'top' .. colFix )
	end
end
local function prntLeft (str, color)
	prnt( str, color, 'left' )
end
local function prntRight (str, color)
	prnt( str, color, 'right' )
end
local function prntRewind (lN, col)
	lN = lN or 1
	col = col or _s.prntColCurr

	_s.lineCurr[col] = _s.lineCurr[col] - lN
end


local function prntStateDummy ()
	local P2State = s[_s.p2].state2

	local msg = ''
	if P2State == 0 then msg = 'Lock'	-- hitstun, active move, recovery, jump windup/landing
	elseif P2State == 8 then msg = 'Grab'
	elseif P2State == 15 then msg = 'Idle'
	elseif P2State == 127 then msg = 'Clsh'	-- 0 takes priority if move can't be cancelled (like Asuka's A mash)
	else msg = padStart( 3, P2State .. ' ' ) end

	prnt( '   State: ' .. msg .. padStart( 3, s[_s.p2].state ) )
	prntRewind()

	local col = ''
	if _s.p1 == 'p1' then
		col = COLOR.white
	else
		col = COLOR.lightblue
	end
	prnt( bizstring.toupper( _s.p2 ), col )
end

local function refillHP ()
	if s.g.timer == 80 then	--TODO better roundstart detection
		_s.hpRefill.p1.trigger = true
		_s.hpRefill.p2.trigger = true
	end

	for _, p in ipairs( {'p1', 'p2'} ) do
		if s[p].health ~= GUTS[_s.hpRefill[p].mode] and s[p].timerStun == 0 and s2[p].timerStun > 1 then
			s[p].timerStun = 1	-- required for proper resets as it's used as check for when to refill, sometimes after far and high wallslams the timer has time to run down before getting back to neutral state
		end
		if s[p].state <= 1 and s[p].state2 == 15 and (
			_s.hpRefill[p].trigger
			or s[p].timerStun <= ( 192 - 192 / 2 ) and s[p].timerStun ~= 0
			or _s.modeStun == 1 and ( s2[p].state ~= 0 or s2[p].state2 ~= 15 )
		) then
			memory.writebyte( _c.addr[p].health, GUTS[_s.hpRefill[p].mode] )
			if _s.modeStun ~= 1 then
				memory.writebyte( _c.addr[p].stun, 0 )
				memory.writebyte( _c.addr[p].timerStun, 0 )
			end
		end
	end

	if _s.modeStun == 2 then
		memory.writebyte( _c.addr[_s.p2].stun, 0 )
	elseif _s.modeStun == 1 and s[_s.p2].state == 0 and s[_s.p2].stun == 0 then
		memory.writebyte( _c.addr[_s.p2].stun, s[_s.p2].limitStun - 1 )
	end
end
local function prntComboDamageMax ()
	if _s.lastComboDmg > _s.maxComboDmg then
		_s.lastMaxComboDmg = _s.maxComboDmg
		_s.maxComboDmg = _s.lastComboDmg
	end
	prnt( 'Max Dmg: ' .. _s.maxComboDmg .. ' (' .. _s.lastMaxComboDmg .. ')' )
end

local function fmtStick (n)
	local str = ''
	if n == 1 or n == 4 or n == 7 then str = str .. '<' else str = str .. ' ' end
	if n == 0 then str = str .. ' '
		elseif n == 7 or n == 8 or n == 9 then str = str .. '^'
		elseif n == 1 or n == 2 or n == 3 then str = str .. 'v'
		else str = str .. ' ' end
	if n == 3 or n == 6 or n == 9 then str = str .. '>' else str = str .. ' ' end
	return str
end
local function fmtButtons (bf)
	local str = ''
	if bit.band( BTN_FLAG.A, bf ) ~= 0 then str = str .. 'A' else str = str .. ' ' end
	if bit.band( BTN_FLAG.B, bf ) ~= 0 then str = str .. 'B' else str = str .. ' ' end
	if bit.band( BTN_FLAG.C, bf ) ~= 0 then str = str .. 'C' else str = str .. ' ' end
	if bit.band( BTN_FLAG.Z, bf ) ~= 0 then str = str .. 'Z' else str = str .. ' ' end
	if bit.band( BTN_FLAG.Y, bf ) ~= 0 then str = str .. 'Y' else str = str .. ' ' end
	if bit.band( BTN_FLAG.X, bf ) ~= 0 then str = str .. 'X' else str = str .. ' ' end
	-- if bit.band( BTN_FLAG.L, bf ) ~= 0 then str = str .. 'L' else str = str .. ' ' end
	if bit.band( BTN_FLAG.R, bf ) ~= 0 then str = str .. 'R' else str = str .. ' ' end
	return str
end
local function historyInput ()	-- _strHistorySepDrop inserted by historyHit()
	local inp = _s._prntInputsP1
	local _lInp = #inp

	local str = fmtStick( sPads.p1.s ) .. ' ' .. fmtButtons( sPads.p1.fB )
	if str ~= inp[_lInp].v then
		table.insert( inp, {v = str, t = 1, tt = '  1'} )
	else
		inp[_lInp].t = inp[_lInp].t + 1
		inp[_lInp].tt = string.format( '%3u', math.min( inp[_lInp].t, 999 ) )
	end
end

local _strHistorySepDrop = ' --  DROP    '
local function historyHit ()
	local dmg = _s._prntDmgP1
	local _lDmg = #dmg

	local diff = {
		h = s2[_s.p2].health - s[_s.p2].health,
		s = s[_s.p2].stun - s2[_s.p2].stun,
		m = ( s[_s.p1].meter - s2[_s.p1].meter ) * 120 / 192,
	}
	local totDiff = diff.h + diff.s + diff.m

	if totDiff >= 1	-- end of 120 spams history by updating meter every frame by ~0.75
		or s[_s.p2].state > 26 and s2[_s.p2].state <= 26	-- act
		or s[_s.p2].state == 0 and s2[_s.p2].state ~= 0	-- idle
		or s[_s.p2].state == 1 and s2[_s.p2].state ~= 1	-- crouch
		-- or sPads[_s.p1].b.R and not s2Pads[_s.p1].b.R	--DEBUG
	then
		local tmp = {v = nil, t = 1, tt = ''}
		if dmg[_lDmg].v ~= _strHistorySepDrop and (
			s.g.combo < s2.g.combo
			or s[_s.p2].health > s2[_s.p2].health
			or s[_s.p2].timerStun == 0 and s2[_s.p2].timerStun == 1
			or s[_s.p2].state ~= s2[_s.p2].state and (
				s[_s.p2].state == 27	-- tech
				or s[_s.p2].state <= 11	-- neutral (standing, crouch or jump)
			) or 29 <= s2[_s.p2].state and s2[_s.p2].state <= 31	-- blockstun
				and not ( 29 <= s[_s.p2].state and s[_s.p2].state <= 31 )
		) then
			tmp.v = _strHistorySepDrop
			table.insert( _s._prntInputsP1, tblCopy( tmp ) )
		elseif totDiff > 0 then
			tmp.v = string.format( '%3u%4u%6.2f', diff.h, diff.s, diff.m )
		end
		if tmp.v then
			table.insert( dmg, tmp )
			_lDmg = _lDmg + 1
		end
	else
		dmg[_lDmg].t = dmg[_lDmg].t + 1
		dmg[_lDmg].tt = string.format( '%3u', math.min( dmg[_lDmg].t, 999 ) )
	end
end


local function prntHistoryInput ()
	local inp = _s._prntInputsP1
	local _lInp = #inp

	local skipped = 0
	for i = 0, math.min( _lInp - 1, 40 + skipped ) do
		local tmp = inp[_lInp - i]
		if tmp.v == '           ' and tmp.t <= 9 and i > 0 then
			skipped = skipped + 1
		else
			local color = COLOR.white
			if tmp.v == _strHistorySepDrop then
				color = COLOR.lightgray
			end
			prnt( tmp.tt .. ' ' .. tmp.v, color, nil, 11 )
		end
	end
end
local function prntHistoryHit ()
	local dmg = _s._prntDmgP1
	local _lDmg = #dmg

	prnt( ' f  Dmg  Stn  Mtr', COLOR.lightgray )
	for i = 0, math.min( _lDmg - 1, 40 ) do
		local tmp = dmg[_lDmg - i]
		local color = COLOR.white
		if tmp.v == _strHistorySepDrop then
			color = COLOR.lightgray
		end
		prnt( tmp.tt .. ' ' .. tmp.v, color, nil, 20 )
	end
end

local function p2ToDummy ()
	local st = s[_s.p2].state

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
		if _s.offsQuickRec == -1 then _s.offsQuickRec = _s.f % 2 end
		local dirTech = ({'Left', 'Right'})[s[_s.p1].sideFacingLeft + 1]

		local tmp = {}
		local tech = true
		if st > 18 and st < 23 or st == 25 then	-- 22 ground-slam; 21 and 22 should be too late but don't hurt, 19 too early
			if _s.tech.ground then
				if _s.f % 2 == _s.offsQuickRec then tmp.Up = true end
			else tech = false end
		elseif st == 18 then	-- happens often after generic hitstun
			tech = false
			if _s.tech.wall then
				if _s.f % 2 == _s.offsQuickRec then tmp[dirTech] = true end
			end
		elseif s[_s.p2].state == 13 and s[_s.p2].state2 == 8 and _s.g[_lS_g - 9][_s.p2].state2 == 8 then	-- grab
			if _s.tech.throw then
				-- setPad( {[dirTech] = true}, 2 )	--NOTE you can tech with no direction if facing right	--TODO
				-- tech = false	--DEBUG
			else tech = false end
		elseif st == 26 then	-- air throw
			if _s.tech.throw then
				tmp[dirTech] = true
			else tech = false end
		elseif st == 17 then	-- generic hitstun
			if _s.tech.slide and s[_s.p1].sideFacingLeft == s[_s.p2].sideFacingLeft then
				if _s.f % 2 == _s.offsQuickRec then tmp[dirTech] = true end
			else tech = false end
		elseif st == 15 then	-- dizzy
			tech = false
			if _s.tech.dizzy then
				if _s.f % 2 == _s.offsQuickRec then
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
			if _s.f % 2 == _s.offsQuickRec then tmp.B = true end
		end
		if _s.p1 == 'p1' then setPad( tmp, 2 ) else setPad( tmp, 1 ) end
	end
end

local function pInvert (v)
	if v == nil then
		v = ( _s.modeInvert + 1 ) % 4
	end

	_s.modeInvert = v
	if v ~= 1 then
		_s.p1 = 'p1'
		_s.p2 = 'p2'
	else
		_s.p1 = 'p2'
		_s.p2 = 'p1'
	end
end
local function p2Control ()
	local r = _s.p2Record

	if s.g.scene == SCENE.VS and sPads.p1.b.L ~= s2Pads.p1.b.L then
		pInvert( ( _s.modeInvert + 1 ) % 2 )
	end
	if s.g.scene ~= s2.g.scene then
		r.running = 0
		r.dekuMash = {}
		pInvert( 0 )
		if s.g.scene == SCENE.VS and sPads.p1.b.L then pInvert( 1 ) end	-- otherwise if holding L trough menu transition it inverts until switching again
	end

	if s.g.pause == 1 then
		if s2.g.pause == 0 then
			r.dekuMash = {}
		end
		if r.running > 0 then
			r.skipped = r.skipped - 1
		end
	else
		if s2.g.pause == 0 and s2Pads.p1.b.Start and not sPads.p1.b.Start then
			local tmp = {}
			for key, val in pairs( sPads.p1.b ) do
				if val and key ~= 'Start' and key ~= 'L' then
					tmp[key] = true
				end
			end
			r.dekuMash = tmp
		end
		if _s.modeInvert > 0 or r.frameUpTo == -1 then	-- if manually inevrted or REC
			local tmp = {}
			for key, val in pairs( sPads.p1.b ) do
				if key ~= 'Start' and key ~= 'L' then
					tmp[key] = tmp[key] or val
				end
			end
			if _s.modeInvert == 3 and r.frameUpTo ~= -1 then
				local tmpLeft = tmp['Left']
				tmp['Left'] = tmp['Right']
				tmp['Right'] = tmpLeft
			end
			setPad( tmp, 2 )

			if _s.modeInvert == 1 or ( r.frameUpTo == -1 and _s.modeInvert == 0 ) then
				setPad( PAD_NULL, 1 )
			end
		end
		if s.g.scene == SCENE.ingame then
			if r.running > 0 then
				local starting = r.frameUpTo - r.fRewind

				local offset = ( _s.f - r.running + r.skipped ) % r.fRewind
				while _s.g[starting + offset].g.pause == 1 do
					offset = ( _s.f - r.running + r.skipped ) % r.fRewind
					r.skipped = r.skipped + 1
				end

				r.curr = starting + offset
				if offset == 0 then
					r.skipped = 0
					if _s.g[starting][_s.p2].sideFacingLeft == s[_s.p2].sideFacingLeft then
						r.invertSide = 1
					else
						r.invertSide = 0
					end
				end

				local tmp = {}
				for k, v in pairs( _sPads[r.curr][r.pOrigin].b ) do tmp[k] = v end
				tmp.Start = nil
				tmp.L = nil
				if r.invertSide == 1 and ( tmp.Left or tmp.Right ) then
					tmp.Left = not tmp.Left
					tmp.Right = not tmp.Right
				end
				if _s.p1 == 'p1' then setPad( tmp, 2 ) else setPad( tmp, 1 ) end
			elseif lenTable( r.dekuMash ) > 0 then
				local tmp = {}
				for key, val in pairs( r.dekuMash ) do
					if string.len( key ) > 1 then
						tmp[key] = val
					elseif _s.f % 2 > 0 then
						tmp[key] = val
					else
						tmp[key] = not val
					end
				end
				if _s.p1 == 'p1' then setPad( tmp, 2 ) else setPad( tmp, 1 ) end
			elseif _s.modeStance == 1 then
				local tmp = {Down = true}
				if _s.p1 == 'p1' then setPad( tmp, 2 ) else setPad( tmp, 1 ) end
			elseif _s.modeStance == 2 then
				if s.p2.state == 0 then
					local tmp = {Up = true}
					if _s.p1 == 'p1' then setPad( tmp, 2 ) else setPad( tmp, 1 ) end
				end
			elseif _s.modeStance == 3 then
				if s.p2.state == 0 or s.p2.state == 11 then
					local tmp = {Up = true}
					if _s.p1 == 'p1' then setPad( tmp, 2 ) else setPad( tmp, 1 ) end
				end
			elseif _s.modeStance == 4 then
				if s.p2.state == 0 then
					local tmp = {Down = true, Z = true}
					if _s.p1 == 'p1' then setPad( tmp, 2 ) else setPad( tmp, 1 ) end
				end
			elseif _s.modeStance == 5 then
				if s.p2.state == 0 then
					local tmp = {Z = true}
					if _s.p1 == 'p1' then setPad( tmp, 2 ) else setPad( tmp, 1 ) end
				end
			end
		end
	end
end

local cMenu = {}
local function menuUpdate ()
	cMenu = {}

	local colTxt = COLOR.lightgray
	if _c.menuPauseColInvert then colTxt = COLOR.white end

	for _, mod in ipairs( {'  ', 'R+', 'L+'} ) do if _c.menu[mod] then
		for _, b in ipairs( {'A', 'B', 'C', '', 'Z', 'Y', 'X'} ) do repeat
			if b == '' then
				table.insert( cMenu, {''} )
			else
				local e = {}
				local v
				local color = colTxt
				if not _c.menu[mod][b] then	--TODO other input methods
					do break end	-- continue
					-- e = {t = '--'}
					-- color = COLOR.lightgray
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
				local strV = {'', ''}
				if v ~= nil then
					local objV = e.v[tonum(v) + 1]
					if not objV[2] then
						if objV[1] == 'OFF' then objV[2] = COLOR.pink
						elseif objV[1] == 'ON' then objV[2] = COLOR.green
						else objV[2] = COLOR.yellow end
					end
					strV[1] = ':'
					strV[2] = objV[1]
					color = objV[2]
				end
				table.insert( cMenu, {string.format( '%-23s%6s', mod .. b .. ' : ' .. e.t .. strV[1], strV[2] ), color, nil, 29} )
			end
		do break end until true end
		table.insert( cMenu, {''} )
	end end
end
local function prntMenu ()
	local colTxt = COLOR.lightgray
	if _c.menuPauseColInvert then colTxt = COLOR.white end

	prnt( '   Hold [L] to record, press', colTxt, nil, 28 )
	prnt( '    again to save and replay', colTxt, nil, 28 )
	prnt()

	for _, v in ipairs( cMenu ) do
		prnt( unpack( v ) )
	end

	prntRewind()
	prnt( 'Exiting pause hold [Start] and', colTxt, nil, 30 )
	prnt( 'release with buttons to replay', colTxt, nil, 30 )
end

local function ctlSettings ()
	local r = _s.p2Record

	if s.g.pause == 1 then
		if not sPads.p1.b.L then
			if not sPads.p1.b.R then	-- raw b
				if sPads.p1.b.A and not s2Pads.p1.b.A then
						_s.modeHistory = ( _s.modeHistory + 1 ) % 3
				end
				if sPads.p1.b.B and not s2Pads.p1.b.B then
					_s.hitboxes = not _s.hitboxes
				end
				if sPads.p1.b.C and not s2Pads.p1.b.C then
					_s.lastMaxComboDmg = _s.maxComboDmg
					_s.lastComboDmg = 0
					_s.maxComboDmg = 0
					if s.p1.timerStun == 0 then
						sNew.p1.timerStun = 1
					end
					if s.p2.timerStun == 0 then
						sNew.p2.timerStun = 1
					end
				end
				if sPads.p1.b.Z and not s2Pads.p1.b.Z then
					_s.modeGuard = ( _s.modeGuard + 1 ) % 3
				end
				if sPads.p1.b.Y and not s2Pads.p1.b.Y then
					_s.modeStun = ( _s.modeStun + 1 ) % 3
				end
				if sPads.p1.b.X and not s2Pads.p1.b.X then
					_s.modeStance = ( _s.modeStance + 1 ) % 6
				end
			elseif sPads.p1.b.R then	--	 R+b
				if sPads.p1.b.A and not s2Pads.p1.b.A then
					_s.tech.dizzy = not _s.tech.dizzy
				end
				if sPads.p1.b.B and not s2Pads.p1.b.B then
					_s.tech.ground = not _s.tech.ground	--TODO ground-slam tech grouped with air and wakeup
				end
				if sPads.p1.b.C and not s2Pads.p1.b.C then
					_s.tech.wall = not _s.tech.wall
				end
				if sPads.p1.b.Z and not s2Pads.p1.b.Z then
					_s.tech.slide = not _s.tech.slide
				end
				if sPads.p1.b.Y and not s2Pads.p1.b.Y then
					_s.tech.throw = not _s.tech.throw
				end
				if sPads.p1.b.X and not s2Pads.p1.b.X then
					pInvert()
				end
			end
		else	-- L+b
			if sPads.p1.b.A and not s2Pads.p1.b.A then
				_s.hpRefill.p1.mode = ( _s.hpRefill.p1.mode + 1 ) % 8
				_s.hpRefill.p1.trigger = true
			end
			if sPads.p1.b.B and not s2Pads.p1.b.B then
				_s.hpRefill.p2.mode = ( _s.hpRefill.p2.mode + 1 ) % 8
				_s.hpRefill.p2.trigger = true
			end
			if sPads.p1.b.C and not s2Pads.p1.b.C then
				_s.fInputDelay.f = ( _s.fInputDelay.f + 1 ) % 6
			end
		end

		local btnChange = false
		if sPads.p1s ~= s2Pads.p1s then
			btnChange = true
		else
			for k, v in pairs( sPads.p1.b ) do
				if s2Pads.p1.b[k] ~= v then
					btnChange = true
					break
				end
			end
		end
		if btnChange then
			setScriptState()
			menuUpdate()
		end
	elseif s.g.scene == SCENE.ingame then
		local fHold = 45

		if _lS_g > fHold + 60 then
			r.triggerHeld = true
			for i = 1, fHold do
				if not _sPads[_s.f - i - 1].p1.b.L then
					r.triggerHeld = false
					break
				end
			end

			if r.triggerHeld then
				r.running = 0
			end

			if s2Pads.p1.b.L and not sPads.p1.b.L then
				if r.triggerHeld then	-- start recording
					r.running = 0
					r.frameUpTo = -1
					r.skipped = 0
					r.fRewind = _s.f
					r.pOrigin = _s.p2
				else
					if r.frameUpTo == -1 then	-- stop recording
						r.frameUpTo = _s.f
						r.fRewind = r.frameUpTo - r.fRewind
					else
						if r.running == 0 and r.frameUpTo > 0 then	--start playback
							r.running = _s.f
						else	-- stop playback
							r.running = 0
						end
					end
				end
			end
		end
	end
end

local cPrntReplay = {
	held = {
		{'[ ] Release to record'},
		{''},
		{'    Press [Start]'},
		{'    to cancel'},
	},
	rec = {
		{'[ ]  REC000000 - 0000s'},
	},
	play = {
		{'[ ]  PLAY00000 / 00000'},
	},
}
for k, v in pairs( cPrntReplay ) do
	for i, _ in ipairs( v ) do
		cPrntReplay[k][i][4] = #cPrntReplay[k][i][1]
	end
end
local function prntReplay ()
	local r = _s.p2Record

	if r.triggerHeld then
		if s.g.pause == 0 then
			for i, v in ipairs( cPrntReplay.held ) do
				prnt( unpack( v ) )
			end
		end
	elseif r.frameUpTo == -1 then
		local sTimer = math.floor( ( _s.f - r.fRewind ) / 60 )
		prnt( '[ ]  REC' .. string.format( '%6s - %-5s', _s.f - r.fRewind, sTimer .. 's' ), nil, nil, cPrntReplay.rec[1][4] )
		if sTimer % 2 == 0 then
			prntRewind()
			prnt( ' O', COLOR.red, nil, 2 )
		end
	elseif r.running > 0 then
		prnt( '[ ]  PLAY' .. string.format( '%5s / %-5s', r.curr % r.fRewind, r.fRewind ), nil, nil, cPrntReplay.play[1][4] )
		prntRewind()
		prnt( ' >', COLOR.green, nil, 2 )
	end
end


local function frameStart ()

	--NOTE emulation state
	table.insert( _sPads, {p1 = getPadState( 1 ), p2 = getPadState( 2 )} )
	_lSPads = _lSPads + 1
	s2Pads = sPads
	sPads = _sPads[_lSPads]
	_s.f = _lS_g - 20

	--NOTE frame config reset
	_padsNew = {p1 = {}, p2 = {}}
	sNew = {g = {}, p1 = {}, p2 = {}}
	gui.use_surface( 'client' )
	clientUpdateCache()
	local prcntPadVert = 0	--TODO proper config
	if s.g.scene ~= SCENE.ingame then
		prcntPadVert = 15
	else
		prcntPadVert = 25
	end
	_s.lineCurr.left = math.floor( cClient.bufferheight * cClient.getwindowsize * prcntPadVert / 100 / _c.pxLineH )
	_s.lineCurr.center = _s.lineCurr.left
	_s.lineCurr.right = _s.lineCurr.left

	--NOTE inputs
	if s.g.scene == SCENE.ingame and s.g.pause == 0 then
		historyInput()
	end
	ctlSettings()
	p2ToDummy()
	p2Control()
	for p, inputs in pairs( sPads ) do
		for b, _ in pairs( inputs.b ) do
			if _padsNew[p][b] ~= nil then
				sPads[p].b[b] = _padsNew[p][b]
			end
		end
		sPads[p].s = bToNumpad( sPads[p].b )
	end
	local tmpDelay = 0
	if s.g.scene == SCENE.ingame then
		local dly = _s.fInputDelay
		if dly.f < 6 then
			tmpDelay = dly.f * 2
			dly.rand = 0
			dly.retries = 0
		else	--FIXME also needs to fast forward to be able to catch up when reducing latency (just compress frames with the same inputs?)
			local tmpF = 2 + math.floor( randomExp( 0.9 ) * 5 )	--TODO replace with https://stackoverflow.com/a/16120286
			if tmpF < dly.rand + dly.retries then
				dly.rand = tmpF
				dly.retries = 0
			else
				dly.retries = dly.retries + 1
			end
			tmpDelay = dly.rand + dly.retries
		end
	end
	local tmpPads = {p1 = {}, p2 = {}}
	for p, inputs in pairs( _sPads[_lSPads - tmpDelay] ) do
		for b, v in pairs( inputs.b ) do
			tmpPads[p][b] = v
		end
	end
	joypad.set( tmpPads.p1, 1 )
	joypad.set( tmpPads.p2, 2 )

end
local function frameEnd ()

	--NOTE script state
	table.insert( _s.g, getGameState() )
	_lS_g = _lS_g + 1
	s2 = s
	s = _s.g[_lS_g]
	for k, v in pairs( sNew ) do
		for k2, v2 in pairs( v ) do
			s[k][k2] = v2
			-- memory.writebyte( _c.addr[k][k2], v2 )
		end
	end

	--NOTE game logic
	if s.g.scene == SCENE.ingame then
		if s.g.combo < _s.g[_lS_g - 1].g.combo then
			-- memory.writebyte( _c.addr[_s.p2].health, _c.maxHP )	--DEBUG
			_s.lastComboDmg = GUTS[_s.hpRefill[_s.p2].mode] - _s.g[_lS_g - 1][_s.p2].health
		end
		if s.g.pause == 0 then
			historyHit()
			refillHP()
			memory.writebyte( _c.addr.g.timer, 42 )
			local hboxes = tonum( _s.hitboxes )
			if s.g.hitbox1 ~= hboxes then
				memory.writebyte( _c.addr.g.hitbox1, hboxes )
				memory.writebyte( _c.addr.g.hitbox2, hboxes )
			end
		end
	end

	--NOTE output
	if s.g.scene ~= s2.g.scene or s.g.pause ~= s2.g.pause or _lS_g < 4 or cClient2.isChanged then
		gui.clearGraphics()
		if s.g.scene == SCENE.ingame then	--TODO proper config
			_s.prntColCurr = 'left'
			local lHeight = 5.8
			local width = 230
			if s.g.pause == 1 then
				if _c.menuPauseColInvert then
					lHeight = 26
					width = 340
					if _c.menuPauseColInvertCenter then
						width = 550
					end
				end
			end
			drawRect( 0, ( _s.lineCurr[_s.prntColCurr] + 0.5 ) * _c.pxLineH, width, lHeight * _c.pxLineH, '#BB16161d' )
		end
	end
	if s.g.scene == SCENE.main or s.g.scene == SCENE.VS then
		prntLeft( '          Pick "VS GAME" & enter 2 Players mode ( NOT DEKU! )' )

		prntRight()
		prntLeft( "           To start the match you can control P2's cursor while holding [L]          " )
	elseif s.g.scene == SCENE.ingame then
		_s.prntColCurr = 'left'
		if _c.menuPauseColInvert and not _c.menuPauseColInvertCenter and s.g.pause == 1 then _s.prntColCurr = 'right' end

		prnt( 'Combo: ' .. s.g.combo .. ' (' .. s.g.lastCombo .. ')' )
		prnt( 'Damage: ' .. GUTS[_s.hpRefill[_s.p2].mode] - s[_s.p2].health .. ' (' .. _s.lastComboDmg .. ')' )
		prntComboDamageMax()
		prnt( string.format( 'Stun: %2u / %u  %3uf', s[_s.p2].stun, s[_s.p2].limitStun, s[_s.p2].timerStun ) )
		prntStateDummy()

		prnt()
		if _s.modeHistory == 1 then
			prntHistoryInput()
		elseif _s.modeHistory == 2 then
			prntHistoryHit()
		end

		_s.prntColCurr = 'right'

		if s.g.pause == 0 or _c.menuPauseColInvertCenter then
			prntReplay()
		end

		if _c.menuPauseColInvert and s.g.pause == 1 then
			if _c.menuPauseColInvertCenter then
				_s.prntColCurr = 'center'
			else
				_s.prntColCurr = 'left'
			end
		end
		if s.g.pause == 1 then
			prntMenu()
		end
	end

	--NOTE cleanup
	joypad.set( {}, 1 )
	joypad.set( {}, 2 )
end
local function saveState ()

	setScriptState()

end
local function loadState ()

	getScriptState()
	_s.hpRefill.p1.trigger = true
	_s.hpRefill.p2.trigger = true
	menuUpdate()

end
local function luaCleanup ()

	gui.clearImageCache()
	gui.cleartext()
	gui.clearGraphics( 'client' )
	gui.clearGraphics( 'emucore' )
	joypad.set( {}, 1 )
	joypad.set( {}, 2 )

end

console.log( '' )
console.log( '' )
console.log( '- A120LO SCRIPT LOADED' )
luaCleanup()
loadState()

event.onframestart( frameStart, 'ALO120T_frameStart' )
event.onframeend( frameEnd, 'ALO120T_frameEnd' )
event.onsavestate( saveState, 'ALO120T_saveState' )
event.onloadstate( loadState, 'ALO120T_loadState' )
event.onexit( luaCleanup, 'ALO120T_exit' )
while true do emu.frameadvance() end
