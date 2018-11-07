script_name("vancerp")
script_version_number(1)
script_description("Net")
script_author("Ivan Karimov")

local sampev = require 'lib.samp.events'
local inicfg = require 'inicfg'
local encoding = require 'encoding'
local json = require ("dkjson")
local font = renderCreateFont("Arial", 11, 13)
local сfont = renderCreateFont("Arial", 9, 13)
local config = inicfg.load(nil, "cfg.ini")
local admins = {}
local time = os.clock() * 1000
require "lib.moonloader"
require "lib.sampfuncs"

local ffi = require "ffi"
local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
require "lib.moonloader"
local mem = require "memory"

--// *** // *** //--
whVisible = "names" -- Мод ВХ по умолчанию. Моды написаны в комментарии ниже
optionsCommand = "names" -- Моды ВХ: bones - только кости / names - только ники, all - всё сразу
KEY = VK_F11 -- Кнопка активации ВХ
defaultState = false -- Запуск ВХ при старте игры
gm = false
airbrake = false
achecker = true
lchecker = true
hchecker = true
airBrkCoords = {}
tick = {Keys = {Up = 0, Down = 0, Plus = 0, Minus = 0, Num = {Plus = 0, Minus = 0}}, Fps = 0, Notification = 0, CoordsMaster = 0, ClickWarp = 0, Time = {Up = 165, Down = 165, PlusMinus = 150, NumPlusMinus = 150}}
--// *** // *** //--
encoding.default = 'CP1251'
u8 = encoding.UTF8

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	sampAddChatMessage("{FF8000}[VanceTools] {CED8F6}Скрипт загружен. (by I.Karimov)", 0xCED8F6)
	sampRegisterChatCommand("asetpos", function() _asetpos:run() end)
	_asetpos = lua_thread.create_suspended(achecker_setpos)
	sampRegisterChatCommand("lsetpos", function() _lsetpos:run() end)
	_lsetpos = lua_thread.create_suspended(lchecker_setpos)
	sampRegisterChatCommand("hsetpos", function() _hsetpos:run() end)
	_hsetpos = lua_thread.create_suspended(hchecker_setpos)
	sampRegisterChatCommand("csetpos", function() _csetpos:run() end)
	_csetpos = lua_thread.create_suspended(cheats_setpos)
	sampRegisterChatCommand("achecker", set_achecker)
	sampRegisterChatCommand("lchecker", set_lchecker)
	sampRegisterChatCommand("hchecker", set_hchecker)
	sampRegisterChatCommand("gm", GMstate)
	sampRegisterChatCommand("getreg", function(param) idreg=param _getregs:run() end)
	_getregs = lua_thread.create_suspended(getregs)
	
	initialise()
	lua_thread.create(checker)
	lua_thread.create(checker_show)
	lua_thread.create(wallhack)
	lua_thread.create(godmode)
	lua_thread.create(air)
	lua_thread.create(enableAir)
	while true do
	wait(0) end
end
function sampev.onPlayerStreamIn(id, team, model, pos, rot, color, fight)

end
function sampev.onPlayerStreamOut(id)

end
function sampev.onPlayerJoin(playerId, color, isNpc, nickname)
	checker()
end
function sampev.onPlayerQuit(playerId, reason)
	checker()
end
function initialise()
    ----------------------Настройки-------------------------
	if config == nil then
		cfg = io.open(getWorkingDirectory()..'\\config\\cfg.ini',"w")
		cfg:write("[settings]\naposX=1500\naposY=300\nlposX=1700\nlposY=400\nhposX=1200\nhposY=300")
		cfg:close()
	end
	connected = true
	------------------------Чекер----------------------------
	file = io.open(getWorkingDirectory().."\\config\\admins.txt","r")
	if file == nil then 
		file = io.open(getWorkingDirectory()..'\\config\\admins.txt',"w")
		file:write("Ivan_Karimov\nEdvard_Karimov\nDmitriy_Source\nSweet_Johnson")
		file:close()
		file = io.open(getWorkingDirectory().."\\config\\admins.txt","r")
	end
	file:close()
	
	file = io.open(getWorkingDirectory().."\\config\\leaders.txt","r")
	if file == nil then 
		file = io.open(getWorkingDirectory()..'\\config\\leaders.txt',"w")
		file:write("Ivan_Karimov\nEdvard_Karimov\nDmitriy_Source\nSweet_Johnson\n")
		file:close()
		file = io.open(getWorkingDirectory().."\\config\\leaders.txt","r")
	end
	file:close()

	file = io.open(getWorkingDirectory().."\\config\\helpers.txt","r")
	if file == nil then 
		file = io.open(getWorkingDirectory()..'\\config\\helpers.txt',"w")
		file:write("Ivan_Karimov\nEdvard_Karimov\nDmitriy_Source\nSweet_Johnson\n")
		file:close()
		file = io.open(getWorkingDirectory().."\\config\\helpers.txt","r")
	end
	file:close()	
	
	checker()
	---------------------------------------------------------
end
function wallhack()
while not sampIsLocalPlayerSpawned() do wait(100) end
	if defaultState and not nameTag then nameTagOn() end
	while true do
		wait(0)
		if wasKeyPressed(KEY) then
			if defaultState then sampAddChatMessage("[VanceTools] Вы дективировали WH.",0x3399ff) else sampAddChatMessage("[VanceTools] Вы активировали WH.",0x3399ff) end
			if defaultState then
				defaultState = false; 
				nameTagOff(); 
				while isKeyDown(KEY) do wait(100) end 
			else
				defaultState = true;
				if whVisible ~= "bones" and not nameTag then nameTagOn() end
				while isKeyDown(KEY) do wait(100) end 
			end 
		end
		if defaultState and whVisible ~= "names" then
			if not isPauseMenuActive() and not isKeyDown(VK_F8) then
				for i = 0, sampGetMaxPlayerId() do
				if sampIsPlayerConnected(i) then
					local result, cped = sampGetCharHandleBySampPlayerId(i)
					local color = sampGetPlayerColor(i)
					local aa, rr, gg, bb = explode_argb(color)
					local color = join_argb(255, rr, gg, bb)
					if result then
						if doesCharExist(cped) and isCharOnScreen(cped) then
							local t = {3, 4, 5, 51, 52, 41, 42, 31, 32, 33, 21, 22, 23, 2}
							for v = 1, #t do
								pos1X, pos1Y, pos1Z = getBodyPartCoordinates(t[v], cped)
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(t[v] + 1, cped)
								pos1, pos2 = convert3DCoordsToScreen(pos1X, pos1Y, pos1Z)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
							end
							for v = 4, 5 do
								pos2X, pos2Y, pos2Z = getBodyPartCoordinates(v * 10 + 1, cped)
								pos3, pos4 = convert3DCoordsToScreen(pos2X, pos2Y, pos2Z)
								renderDrawLine(pos1, pos2, pos3, pos4, 1, color)
							end
							local t = {53, 43, 24, 34, 6}
							for v = 1, #t do
								posX, posY, posZ = getBodyPartCoordinates(t[v], cped)
								pos1, pos2 = convert3DCoordsToScreen(posX, posY, posZ)
							end
						end
					end
				end
			end
			else
				nameTagOff()
				while isPauseMenuActive() or isKeyDown(VK_F8) do wait(0) end
				nameTagOn()
			end
		end
	end
end
function enableAir()
while true do wait (0)
if isKeyJustPressed(VK_RSHIFT) then -- airbrake
			config.settings.airbrake = not config.settings.airbrake
			if config.settings.airbrake then
				local posX, posY, posZ = getCharCoordinates(playerPed)
				airBrkCoords = {posX, posY, posZ, 0.0, 0.0, getCharHeading(playerPed)}
			end
		end
end
end
function air()
while true do wait(0)
local time = os.clock() * 1000
	if config.settings.airbrake then -- airbrake
			if isCharInAnyCar(playerPed) then heading = getCarHeading(storeCarCharIsInNoSave(playerPed))
			else heading = getCharHeading(playerPed) end
			local camCoordX, camCoordY, camCoordZ = getActiveCameraCoordinates()
			local targetCamX, targetCamY, targetCamZ = getActiveCameraPointAt()
			local angle = getHeadingFromVector2d(targetCamX - camCoordX, targetCamY - camCoordY)
			if isCharInAnyCar(playerPed) then difference = 0.79 else difference = 1.0 end
			setCharCoordinates(playerPed, airBrkCoords[1], airBrkCoords[2], airBrkCoords[3] - difference)
			if isKeyDown(VK_W) then
				airBrkCoords[1] = airBrkCoords[1] + config.settings.speed * math.sin(-math.rad(angle))
				airBrkCoords[2] = airBrkCoords[2] + config.settings.speed * math.cos(-math.rad(angle))
				if not isCharInAnyCar(playerPed) then setCharHeading(playerPed, angle)
				else setCarHeading(storeCarCharIsInNoSave(playerPed), angle) end
			elseif isKeyDown(VK_S) then
				airBrkCoords[1] = airBrkCoords[1] - config.settings.speed * math.sin(-math.rad(heading))
				airBrkCoords[2] = airBrkCoords[2] - config.settings.speed * math.cos(-math.rad(heading))
			end
			if isKeyDown(VK_A) then
				airBrkCoords[1] = airBrkCoords[1] - config.settings.speed * math.sin(-math.rad(heading - 90))
				airBrkCoords[2] = airBrkCoords[2] - config.settings.speed * math.cos(-math.rad(heading - 90))
			elseif isKeyDown(VK_D) then
				airBrkCoords[1] = airBrkCoords[1] - config.settings.speed * math.sin(-math.rad(heading + 90))
				airBrkCoords[2] = airBrkCoords[2] - config.settings.speed * math.cos(-math.rad(heading + 90))
			end
			if isKeyDown(VK_UP) then airBrkCoords[3] = airBrkCoords[3] + config.settings.speed / 2.0 end
			if isKeyDown(VK_DOWN) and airBrkCoords[3] > -95.0 then airBrkCoords[3] = airBrkCoords[3] - config.settings.speed / 2.0 end
			if not isSampfuncsConsoleActive() and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() then
				if isKeyDown(VK_OEM_PLUS) and time - tick.Keys.Plus > tick.Time.PlusMinus then
					if config.settings.speed < 14.9 then config.settings.speed = config.settings.speed + 0.5 end
					--post_of_notification(string.format('AirBrk speed changed to: %.1f.', config.settings.speed))
					tick.Keys.Plus = os.clock() * 1000
				elseif isKeyDown(VK_OEM_MINUS) and time - tick.Keys.Minus > tick.Time.PlusMinus then
					if config.settings.speed > 0.1 then config.settings.speed = config.settings.speed - 0.2 end
					--post_of_notification(string.format('AirBrk speed changed to: %.1f.', config.settings.speed))
					tick.Keys.Minus = os.clock() * 1000
			end
		end
	end
end
end
function godmode()
	while true do
	if gm then
	setCharProofs(playerPed, true, true, true, true, true)
	writeMemory(0x96916E, 1, 1, false)
	local isInVeh = isCharInAnyCar(playerPed)
	local veh = nil
	if isInVeh then veh = storeCarCharIsInNoSave(playerPed) end
		if isInVeh then
		setCarProofs(veh, true, true, true, true, true)
	end end
	wait(0) end
end
function checker()
	atext="" a=0
	ltext=""
	htext=""
	for i=0, 999 do
		if sampIsPlayerConnected(i) then
			name = sampGetPlayerNickname(i)
			file = io.open(getWorkingDirectory().."\\config\\admins.txt","r")
			for line in file:lines() do
				if line==name then atext=atext..line.."\n" a=a+1 end
			end
			file:close()
		end
	end
	for i=0, 999 do
		if sampIsPlayerConnected(i) then
			name = sampGetPlayerNickname(i)
			file = io.open(getWorkingDirectory().."\\config\\leaders.txt","r")
			for line in file:lines() do
				if line==name then ltext=ltext..line.."\n" end
			end
			file:close()
		end
	end
	for i=0, 999 do
		if sampIsPlayerConnected(i) then
			name = sampGetPlayerNickname(i)
			file = io.open(getWorkingDirectory().."\\config\\helpers.txt","r")
			for line in file:lines() do
				if line==name then htext=htext..line.."\n" end
			end
			file:close()
		end
	end
end
function checker_show()
	while true do
		--renderFontDrawText(font, "Администраторы в сети:", config.settings.aposX, config.settings.aposY-20, 0xFFF89306)
		--renderFontDrawText(font, atext, config.settings.aposX, config.settings.aposY, 0xFFFFFFFF)

		if achecker then renderFontDrawText(font, "Администраторы в сети:", config.settings.aposX, config.settings.aposY-20, 0xFFF89306)
		renderFontDrawText(font, atext, config.settings.aposX, config.settings.aposY, 0xFFFFFFFF) end
		if lchecker then renderFontDrawText(font, "Лидеры в сети:", config.settings.lposX, config.settings.lposY-20, 0xFF36F84A)
		renderFontDrawText(font, ltext, config.settings.lposX, config.settings.lposY, 0xFFFFFFFF) end
		if hchecker then renderFontDrawText(font, "Агенты в сети:", config.settings.hposX, config.settings.hposY-20, 0xFF3DA2FB) 
		renderFontDrawText(font, htext, config.settings.hposX, config.settings.hposY, 0xFFFFFFFF) end
		renderDrawBox(config.settings.cposX, config.settings.cposY, 140, 20, 0xAA000000, 1, 0x90000000)
		if gm then renderFontDrawText(сfont, "GM", config.settings.cposX+10, config.settings.cposY, 0xFF04B431) else renderFontDrawText(сfont, "GM", config.settings.cposX+10, config.settings.cposY, 0xFFBDBDBD) end
		if defaultState then renderFontDrawText(сfont, "WH", config.settings.cposX+40, config.settings.cposY, 0xFF04B431) else renderFontDrawText(сfont, "WH", config.settings.cposX+40, config.settings.cposY, 0xFFBDBDBD) end
		if config.settings.airbrake then renderFontDrawText(сfont, "AirBrake", config.settings.cposX+75, config.settings.cposY, 0xFF04B431) else renderFontDrawText(сfont, "AirBrake", config.settings.cposX+75, config.settings.cposY, 0xFFBDBDBD) end
		wait(0) 
	end
end
function cheats_setpos()
	while true do
		sampSetCursorMode(2)
		config.settings.cposX, config.settings.cposY = getCursorPos()
		inicfg.save(config, "cfg.ini")
		if isKeyJustPressed(1) then sampSetCursorMode(0) break end
		wait(0)
	end
end
function achecker_setpos()
	while true do
		sampSetCursorMode(2)
		config.settings.aposX, config.settings.aposY = getCursorPos()
		inicfg.save(config, "cfg.ini")
		if isKeyJustPressed(1) then sampSetCursorMode(0) break end
		wait(0)
	end
end
function lchecker_setpos()
	while true do
		sampSetCursorMode(2)
		config.settings.lposX, config.settings.lposY = getCursorPos()
		inicfg.save(config, "cfg.ini")
		if isKeyJustPressed(1) then sampSetCursorMode(0) break end
		wait(0)
	end
end
function hchecker_setpos()
	while true do
		sampSetCursorMode(2)
		config.settings.hposX, config.settings.hposY = getCursorPos()
		inicfg.save(config, "cfg.ini")
		if isKeyJustPressed(1) then sampSetCursorMode(0) break end
		wait(0)
	end
end
function getBodyPartCoordinates(id, handle)
  local pedptr = getCharPointer(handle)
  local vec = ffi.new("float[3]")
  getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
  return vec[0], vec[1], vec[2]
end

function nameTagOn()
	local pStSet = sampGetServerSettingsPtr();
	NTdist = mem.getfloat(pStSet + 39)
	NTwalls = mem.getint8(pStSet + 47)
	NTshow = mem.getint8(pStSet + 56)
	mem.setfloat(pStSet + 39, 1488.0)
	mem.setint8(pStSet + 47, 0)
	mem.setint8(pStSet + 56, 1)
	nameTag = true
end

function nameTagOff()
	local pStSet = sampGetServerSettingsPtr();
	mem.setfloat(pStSet + 39, NTdist)
	mem.setint8(pStSet + 47, NTwalls)
	mem.setint8(pStSet + 56, NTshow)
	nameTag = false
end

function join_argb(a, r, g, b)
  local argb = b  -- b
  argb = bit.bor(argb, bit.lshift(g, 8))  -- g
  argb = bit.bor(argb, bit.lshift(r, 16)) -- r
  argb = bit.bor(argb, bit.lshift(a, 24)) -- a
  return argb
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end
function GMstate()
	gm = not gm
	if gm then sampAddChatMessage("[VanceTools] GM активирован.",0x3399ff) else sampAddChatMessage("[VanceTools] GM деактивирован.", 0x3399ff) end
end
function set_achecker()
	achecker = not achecker
	if achecker then sampAddChatMessage("[VanceTools] Чекер админов включен.", 0x3399ff) else sampAddChatMessage("[VanceTools] Чекер админов выключен.", 0x3399ff) end
end
function set_lchecker()
	lchecker = not lchecker
	if lchecker then sampAddChatMessage("[VanceTools] Чекер лидеров включен.", 0x3399ff) else sampAddChatMessage("[VanceTools] Чекер лидеров выключен.", 0x3399ff) end
end
function set_hchecker()
	hchecker = not hchecker
	if hchecker then sampAddChatMessage("[VanceTools] Чекер саппортов включен.", 0x3399ff) else sampAddChatMessage("[VanceTools] Чекер саппортов выключен.", 0x3399ff) end
end
function getregs()
		sr=tonumber(idreg)
		if sr~=nil then
			name = sampGetPlayerNickname(idreg)
		else
			name=idreg

		end
		if name == "" then
		sampAddChatMessage("[A] Введите /getreg [ID игрока /ник]",0xFFA500)
		end
		if name ~= "" then

			sampSendChat("/getip "..name)

			rg1=nil rg2=nil
			
			while rg1==nil and rg2==nil do
			wait(500)
			regstr, _ , _ , _ = sampGetChatString(99)
			bp1=string.match(regstr, "R-IP: %d+.%d+.%d+.%d+")
			rg1=string.match(bp1, "%d+.%d+.%d+.%d+")
			bp2=string.match(regstr, "L.-$")
			print(bp2)
			rg2=string.match(bp2, "%d+.%d+.%d+.%d+")
			print(rg2)
			nameplayer=string.match(regstr,"[A-z]+_[A-z]+")
			wait(0)
			end
			
			local url = 'http://ip-api.com/json/'..rg1.."?lang=ru"
			local file_path = getWorkingDirectory() .. '/config/temp.txt'
			downloadUrlToFile(url, file_path)
			wait(300)
			local file = io.open(file_path)
			str=(file:read())
			file:close()
			local obj, o1, o2 = json.decode(str, 1, nil)
				if o2 then
					print("Error:", o2)
				else
					outreg1=u8:decode(obj.city)
					outreg2=u8:decode(obj.country)
					oreg=u8:decode(obj.regionName)
					la1=obj.lat
					lo1=obj.lon
					pr=obj.isp
				end
			local url2 = 'http://ip-api.com/json/'..rg2.."?lang=ru"
			downloadUrlToFile(url2, file_path)
			wait(300)
			file = io.open(file_path)
			str2=(file:read())
			file:close()
			local obj2, z1, z2 = json.decode(str2, 1, nil)
				if z2 then
					print("Error:", z2)
				else
					outreg3=u8:decode(obj2.city)
					outreg4=u8:decode(obj2.country)
					la2=obj2.lat
					lo2=obj2.lon
					oreg2=u8:decode(obj2.regionName)
					pr2=obj2.isp
				end
			regmain=""
			regmain=regmain.."{E6E6E6}Регистр. IP:		"..rg1.."\n".."{E6E6E6}Город регистрации:	"..outreg1.."\n".."{E6E6E6}Область:		"..oreg.."\n".."{E6E6E6}Страна:		"..outreg2.."\n".."{E6E6E6}Провайдер:		"..pr.."\n".."\n\n".."{E6E6E6}Послед. IP:		"..rg2.."\n".."{E6E6E6}Текущий город:	"..outreg3.."\n".."{E6E6E6}Область:		"..oreg2.."\n".."{E6E6E6}Страна:		"..outreg4
	
			rasstoyanie=math.floor(calcDist(la1,lo1,la2,lo2))
			vremya=math.floor(rasstoyanie/80)
			tt=rasstoyanie/80*60
			vremya2=math.floor(math.fmod(tt, 60))
			sampShowDialog(34343, "{0080FF}Регистрационные данные", "{E6E6E6}Ник игрока:		"..nameplayer.."\n".."\n\n"..regmain.."\n".."{E6E6E6}Провайдер:		"..pr2.."\n\n".."{E6E6E6}Расстояние:		"..rasstoyanie.." километров".."\n".."{E6E6E6}Время в пути:		"..vremya.." часа(ов) "..vremya2.." минут", "Закрыть", "", 0)	
		end
	end
		function calcDist(lat1, lon1, lat2, lon2)
    lat1= lat1*0.0174532925
    lat2= lat2*0.0174532925
    lon1= lon1*0.0174532925
    lon2= lon2*0.0174532925

    dlon = lon2-lon1
    dlat = lat2-lat1

    a = math.pow(math.sin(dlat/2),2) + math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dlon/2),2)
    c = 2 * math.asin(math.sqrt(a))
    dist = 6371 * c      -- multiply by 0.621371 to convert to miles
    return dist
	end