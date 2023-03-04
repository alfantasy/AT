script_properties('work-in-pause')
require "lib.moonloader" -- подключение основной библиотеки mooloader
local ffi = require "ffi" -- cпец структура
local vkeys = require "vkeys" -- регистр для кнопок
local imgui = require 'imgui' -- регистр imgui окон
local encoding = require 'encoding' -- дешифровка форматов
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local mem = require "memory" -- библиотека, отвечающие за чтение памяти, и её факторы
local notfy	= import 'lib/lib_imgui_notf.lua'
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
ffi.cdef[[
	short GetKeyState(int nVirtKey);
	bool GetKeyboardLayoutNameA(char* pwszKLID);
	int GetLocaleInfoA(int Locale, int LCType, char* lpLCData, int cchData);
]]
local BuffSize = 32
local KeyboardLayoutName = ffi.new("char[?]", BuffSize)
local LocalInfo = ffi.new("char[?]", BuffSize)
chars = {
	["й"] = "q", ["ц"] = "w", ["у"] = "e", ["к"] = "r", ["е"] = "t", ["н"] = "y", ["г"] = "u", ["ш"] = "i", ["щ"] = "o", ["з"] = "p", ["х"] = "[", ["ъ"] = "]", ["ф"] = "a",
	["ы"] = "s", ["в"] = "d", ["а"] = "f", ["п"] = "g", ["р"] = "h", ["о"] = "j", ["л"] = "k", ["д"] = "l", ["ж"] = ";", ["э"] = "'", ["я"] = "z", ["ч"] = "x", ["с"] = "c", ["м"] = "v",
	["и"] = "b", ["т"] = "n", ["ь"] = "m", ["б"] = ",", ["ю"] = ".", ["Й"] = "Q", ["Ц"] = "W", ["У"] = "E", ["К"] = "R", ["Е"] = "T", ["Н"] = "Y", ["Г"] = "U", ["Ш"] = "I",
	["Щ"] = "O", ["З"] = "P", ["Х"] = "{", ["Ъ"] = "}", ["Ф"] = "A", ["Ы"] = "S", ["В"] = "D", ["А"] = "F", ["П"] = "G", ["Р"] = "H", ["О"] = "J", ["Л"] = "K", ["Д"] = "L",
	["Ж"] = ":", ["Э"] = "\"", ["Я"] = "Z", ["Ч"] = "X", ["С"] = "C", ["М"] = "V", ["И"] = "B", ["Т"] = "N", ["Ь"] = "M", ["Б"] = "<", ["Ю"] = ">"
}

local directIni = "AdminTool\\config.ini" -- создание специального файла, отвечающего за настройки.

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280) -- захват позиции костей
local control_wallhack = false

imgui.ToggleButton = require('imgui_addons').ToggleButton

local fai = require "fAwesome5"
local fai_font = nil  
local fai_glyph_ranges = imgui.ImGlyphRanges({ fai.min_range, fai.max_range })
function imgui.BeforeDrawFrame()
    if fai_font == nil then
        local font_config = imgui.ImFontConfig() -- to use 'imgui.ImFontConfig.new()' on error
        font_config.MergeMode = true

        fai_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fai_glyph_ranges)
    end
end

local fa = require 'faicons'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local target = -1
local keys = {
	["onfoot"] = {},
	["vehicle"] = {}
}

function showNotification(handle, text_not)
	notfy.addNotify("{87CEEB}" .. handle, text_not, 2, 1, 6)
end

function imgui.BeforeDrawFrame()
	if fa_font == nil then  
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
end 	

local tag = "{00BFFF} [AT]" -- локальная переменная, которая регистрирует тэг AT

function sampev.onPlayerSync(playerId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		keys["onfoot"] = {}

		keys["onfoot"]["W"] = (data.upDownKeys == 65408) or nil
		keys["onfoot"]["A"] = (data.leftRightKeys == 65408) or nil
		keys["onfoot"]["S"] = (data.upDownKeys == 00128) or nil
		keys["onfoot"]["D"] = (data.leftRightKeys == 00128) or nil

		keys["onfoot"]["Alt"] = (bit.band(data.keysData, 1024) == 1024) or nil
		keys["onfoot"]["Shift"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["onfoot"]["Tab"] = (bit.band(data.keysData, 1) == 1) or nil
		keys["onfoot"]["Space"] = (bit.band(data.keysData, 32) == 32) or nil
		keys["onfoot"]["F"] = (bit.band(data.keysData, 16) == 16) or nil
		keys["onfoot"]["C"] = (bit.band(data.keysData, 2) == 2) or nil

		keys["onfoot"]["RKM"] = (bit.band(data.keysData, 4) == 4) or nil
		keys["onfoot"]["LKM"] = (bit.band(data.keysData, 128) == 128) or nil
	end
end

function sampev.onVehicleSync(playerId, vehicleId, data)
	local result, id = sampGetPlayerIdByCharHandle(target)
	if result and id == playerId then
		keys["vehicle"] = {}

		keys["vehicle"]["W"] = (bit.band(data.keysData, 8) == 8) or nil
		keys["vehicle"]["A"] = (data.leftRightKeys == 65408) or nil
		keys["vehicle"]["S"] = (bit.band(data.keysData, 32) == 32) or nil
		keys["vehicle"]["D"] = (data.leftRightKeys == 00128) or nil

		keys["vehicle"]["H"] = (bit.band(data.keysData, 2) == 2) or nil
		keys["vehicle"]["Space"] = (bit.band(data.keysData, 128) == 128) or nil
		keys["vehicle"]["Ctrl"] = (bit.band(data.keysData, 1) == 1) or nil
		keys["vehicle"]["Alt"] = (bit.band(data.keysData, 4) == 4) or nil
		keys["vehicle"]["Q"] = (bit.band(data.keysData, 256) == 256) or nil
		keys["vehicle"]["E"] = (bit.band(data.keysData, 64) == 64) or nil
		keys["vehicle"]["F"] = (bit.band(data.keysData, 16) == 16) or nil

		keys["vehicle"]["Up"] = (data.upDownKeys == 65408) or nil
		keys["vehicle"]["Down"] = (data.upDownKeys == 00128) or nil
	end
end

function imgui.TextColoredRGB(text, render_text)
	local max_float = imgui.GetWindowWidth()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local ImVec4 = imgui.ImVec4

	local explode_argb = function(argb)
		local a = bit.band(bit.rshift(argb, 24), 0xFF)
		local r = bit.band(bit.rshift(argb, 16), 0xFF)
		local g = bit.band(bit.rshift(argb, 8), 0xFF)
		local b = bit.band(argb, 0xFF)
		return a, r, g, b
	end

	local getcolor = function(color)
		if color:sub(1, 6):upper() == 'SSSSSS' then
			local r, g, b = colors[1].x, colors[1].y, colors[1].z
			local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
			return ImVec4(r, g, b, a / 255)
		end
		local color = type(color) == 'string' and tonumber(color, 16) or color
		if type(color) ~= 'number' then return end
		local r, g, b, a = explode_argb(color)
		return imgui.ImColor(r, g, b, a):GetVec4()
	end

	local render_text = function(text_)
		for w in text_:gmatch('[^\r\n]+') do
			local text, colors_, m = {}, {}, 1
			w = w:gsub('{(......)}', '{%1FF}')
			while w:find('{........}') do
				local n, k = w:find('{........}')
				local color = getcolor(w:sub(n + 1, k - 1))
				if color then
					text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
					colors_[#colors_ + 1] = color
					m = n
				end
				w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
			end

			local length = imgui.CalcTextSize(w)
			if render_text == 2 then
				imgui.NewLine()
				imgui.SameLine(max_float / 2 - ( length.x / 2 ))
			elseif render_text == 3 then
				imgui.NewLine()
				imgui.SameLine(max_float - length.x - 5 )
			end
			if text[0] then
				for i = 0, #text do
					imgui.TextColored(colors_[i] or colors[1], text[i])
					imgui.SameLine(nil, 0)
				end
				imgui.NewLine()
			else imgui.Text(w) end
		end
	end

	render_text(text)
end

notepad_search = imgui.ImBuffer(256)
notepad_note = imgui.ImBuffer(65000)
toggle_input = imgui.ImBool(false)

local defTable = inicfg.load({
    set = {
        widthRenderLineOne = 1,
        widthRenderLineTwo = 1,
		secondToCloseTwo = 5,
		secondToClose = 5,
        sizeOffPolygon = 1,
        sizeOffPolygonTwo = 1,
        polygonNumber = 1,
        polygonNumberTwo = 1,
        rotationPolygonOne = 10,
        rotationPolygonTwo = 10,
        maxMyLines = 50,
        maxNotMyLines = 50,
		cbEndMy = true,
        cbEnd = true,
		staticObjectMy = 2905604013,
        dinamicObjectMy = 9013962961,
        pedPMy = 1862972872,
        carPMy = 6282572962,
        staticObject = 2905604013,
        dinamicObject = 9013962961,
        pedP = 1862972872,
        carP = 6282572962,
        bullettracer = false, 
        showMyBullet = false,  
        infinite_run = false, 
        wallhack = false,
        skeyposX = 0,
        skeyposY = 0,
        fontHelp = 10,
        translate_cmd = false,
    }
}, directIni)
inicfg.save(defTable, directIni)

local nel = {
    check = {
        bullettracer = imgui.ImBool(defTable.set.bullettracer),
        showMyBullet = imgui.ImBool(defTable.set.showMyBullet),
        cbEndMy = imgui.ImBool(defTable.set.cbEndMy),
        cbEnd = imgui.ImBool(defTable.set.cbEnd),
        infinite_run = imgui.ImBool(defTable.set.infinite_run),
        wallhack = imgui.ImBool(defTable.set.wallhack),
        translate_cmd = imgui.ImBool(defTable.set.translate_cmd),
    },
    intz = {
        secondToClose = imgui.ImInt(defTable.set.secondToClose),
        secondToCloseTwo = imgui.ImInt(defTable.set.secondToCloseTwo),
        widthRenderLineOne = imgui.ImInt(defTable.set.widthRenderLineOne),
        widthRenderLineTwo = imgui.ImInt(defTable.set.widthRenderLineTwo),
        sizeOffPolygon = imgui.ImInt(defTable.set.sizeOffPolygon),
        sizeOffPolygonTwo = imgui.ImInt(defTable.set.sizeOffPolygonTwo),
        polygonNumber = imgui.ImInt(defTable.set.polygonNumber),
        polygonNumberTwo = imgui.ImInt(defTable.set.polygonNumberTwo),
        rotationPolygonOne = imgui.ImInt(defTable.set.rotationPolygonOne),
        rotationPolygonTwo = imgui.ImInt(defTable.set.rotationPolygonTwo),
        maxMyLines = imgui.ImInt(defTable.set.maxMyLines),
        maxNotMyLines = imgui.ImInt(defTable.set.maxNotMyLines),
        fontHelp = imgui.ImInt(defTable.set.fontHelp),
    },
    ksync = {
        skey = imgui.ImBool(false),
    },
}

local changePosition = false

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end
function explode_samp_rgba(rgba)
    local b = bit.band(bit.rshift(rgba, 24), 0xFF)
    local r = bit.band(bit.rshift(rgba, 16), 0xFF)
    local g = bit.band(bit.rshift(rgba, 8), 0xFF)
    local a = bit.band(rgba, 0xFF)
    return a, r, g, b
end
function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

local bulletSyncMy = {lastId = 0, maxLines = nel.intz.maxMyLines.v}
for i = 1, bulletSyncMy.maxLines do
    bulletSyncMy[i] = { my = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
end

local bulletSync = {lastId = 0, maxLines = nel.intz.maxNotMyLines.v}
for i = 1, bulletSync.maxLines do
    bulletSync[i] = {other = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
end

local staticObject = imgui.ImFloat4( imgui.ImColor( explode_argb(defTable.set.staticObject) ):GetFloat4() )    
local dinamicObject = imgui.ImFloat4( imgui.ImColor( explode_argb(defTable.set.dinamicObject) ):GetFloat4() )   
local pedP = imgui.ImFloat4( imgui.ImColor( explode_argb(defTable.set.pedP) ):GetFloat4() )   
local carP = imgui.ImFloat4( imgui.ImColor( explode_argb(defTable.set.carP) ):GetFloat4() ) 
local staticObjectMy = imgui.ImFloat4( imgui.ImColor( explode_argb(defTable.set.staticObjectMy) ):GetFloat4() )    
local dinamicObjectMy = imgui.ImFloat4( imgui.ImColor( explode_argb(defTable.set.dinamicObjectMy) ):GetFloat4() )   
local pedPMy = imgui.ImFloat4( imgui.ImColor( explode_argb(defTable.set.pedPMy) ):GetFloat4() )   
local carPMy = imgui.ImFloat4( imgui.ImColor( explode_argb(defTable.set.carPMy) ):GetFloat4() )  

function save()
    inicfg.save(defTable, directIni)
end

function main()
    while not isSampAvailable() do wait(0) end


	sampRegisterChatCommand("keysync", function(playerId)
		if playerId == "off" then
			target = -1
            nel.ksync.skey.v = false
            imgui.Process = false
			return
		else
			playerId = tonumber(playerId)
			if playerId ~= nil then
				local pedExist, ped = sampGetCharHandleBySampPlayerId(playerId)
				if pedExist then
					target = ped
					nel.ksync.skey.v = true  
					imgui.Process = true
					return true
				end
				return
			end
		end
	end)
    inputHelpText = renderCreateFont("Arial", tonumber(nel.intz.fontHelp.v), FCR_BORDER + FCR_BOLD)
	lua_thread.create(inputChat)
	lua_thread.create(showInputHelp)

    file = io.open(getGameDirectory().."//moonloader//config//AdminTool//note.txt","r+");
    if file == nil then 
            file = io.open(getGameDirectory().."//moonloader//config//AdminTool//note.txt","w"); 
              sampAddChatMessage(tag .. "Файл note.txt отсуствует. Начинаю его создание.")
              file:close();
       end;
    
    loadNotePad()

    wallhack = lua_thread.create(drawWallhack)
    sampRegisterChatCommand("wh", cmd_wh)

    while true do
        wait(0)

        imgui.Process = true
        
        if not nel.ksync.skey.v and changePosition == false then 
            nel.ksync.skey.v = false
            imgui.ShowCursor = false  
            imgui.Process = false
        end    

        change_pos()

        local oTime = os.time()
		if nel.check.bullettracer.v then
            for i = 1, bulletSync.maxLines do
                if bulletSync[i].other.time >= oTime then
                    local result, wX, wY, wZ, wW, wH = convert3DCoordsToScreenEx(bulletSync[i].other.o.x, bulletSync[i].other.o.y, bulletSync[i].other.o.z, true, true)
                    local resulti, pX, pY, pZ, pW, pH = convert3DCoordsToScreenEx(bulletSync[i].other.t.x, bulletSync[i].other.t.y, bulletSync[i].other.t.z, true, true)
                    if result and resulti then
                        local xResolution = mem.getuint32(0x00C17044)
                        if wZ < 1 then
                            wX = xResolution - wX
                        end
                        if pZ < 1 then
                            pZ = xResolution - pZ
                        end 
                        renderDrawLine(wX, wY, pX, pY, nel.intz.widthRenderLineOne.v, bulletSync[i].other.color)
                        if nel.check.cbEnd.v then
                            renderDrawPolygon(pX, pY-1, 3 + nel.intz.sizeOffPolygonTwo.v, 3 + nel.intz.sizeOffPolygonTwo.v, 1 + nel.intz.polygonNumberTwo.v, nel.intz.rotationPolygonTwo.v, bulletSync[i].other.color)
                        end
                    end
                end
            end
        end
        if nel.check.showMyBullet.v then
            for i = 1, bulletSyncMy.maxLines do
                if bulletSyncMy[i].my.time >= oTime then
                    local result, wX, wY, wZ, wW, wH = convert3DCoordsToScreenEx(bulletSyncMy[i].my.o.x, bulletSyncMy[i].my.o.y, bulletSyncMy[i].my.o.z, true, true)
                    local resulti, pX, pY, pZ, pW, pH = convert3DCoordsToScreenEx(bulletSyncMy[i].my.t.x, bulletSyncMy[i].my.t.y, bulletSyncMy[i].my.t.z, true, true)
                    if result and resulti then
                        local xResolution = mem.getuint32(0x00C17044)
                        if wZ < 1 then
                            wX = xResolution - wX
                        end
                        if pZ < 1 then
                            pZ = xResolution - pZ
                        end 
                        renderDrawLine(wX, wY, pX, pY, nel.intz.widthRenderLineTwo.v, bulletSyncMy[i].my.color)
                        if nel.check.cbEndMy.v then
                            renderDrawPolygon(pX, pY-1, 3 + nel.intz.sizeOffPolygon.v, 3 + nel.intz.sizeOffPolygon.v, 1 + nel.intz.polygonNumber.v, nel.intz.rotationPolygonOne.v, bulletSyncMy[i].my.color)
                        end
                    end
                end
            end
        end 
        if nel.check.infinite_run.v then 
			mem.setint8(0xB7CEE4, 1)
		end	

    end
end

function showCursor(toggle)
    if toggle then
      sampSetCursorMode(CMODE_LOCKCAM)
    else
      sampToggleCursor(false)
    end
    cursorEnabled = toggle
end

function change_pos()
    if changePosition then
        if nel.ksync.skey.v then  
            defTable.set.skeyposX, defTable.set.skeyposY = getCursorPos()
            if isKeyJustPressed(49) then  
                showNotification(tag, "Успешно сохранено")
                changePosition = false 
                save()
                if target == -1 then  
                    nel.ksync.skey.v = false 
                    imgui.ShowCursor = false
                end    
            end 
        else
            nel.ksync.skey.v = true 
        end
    end
end  

function showInputHelp()
	while true do
		local chat = sampIsChatInputActive()
		if chat == true then
			local in1 = sampGetInputInfoPtr()
			local in1 = getStructElement(in1, 0x8, 4)
			local in2 = getStructElement(in1, 0x8, 4)
			local in3 = getStructElement(in1, 0xC, 4)
			fib = in3 + 41
			fib2 = in2 + 10
			local _, pID = sampGetPlayerIdByCharHandle(playerPed)
			local name = sampGetPlayerNickname(pID)
			local score = sampGetPlayerScore(pID)
			local color = sampGetPlayerColor(pID)
			local capsState = ffi.C.GetKeyState(20)
			local success = ffi.C.GetKeyboardLayoutNameA(KeyboardLayoutName)
			local errorCode = ffi.C.GetLocaleInfoA(tonumber(ffi.string(KeyboardLayoutName), 16), 0x00000002, LocalInfo, BuffSize)
			local localName = ffi.string(LocalInfo)
			local text = string.format(
				"%s :: {%0.6x}%s[%d] {ffffff}:: Капс: %s {FFFFFF}:: Язык: {ffeeaa}%s{ffffff}",
				os.date("%H:%M:%S"), bit.band(color,0xffffff), name, pID, getStrByState(capsState), string.match(localName, "([^%(]*)")
			)
			renderFontDrawText(inputHelpText, text, fib2, fib, 0xD7FFFFFF)
			end
		wait(0)
	end
end
function getStrByState(keyState)
	if keyState == 0 then
		return "{ffeeaa}Выкл{ffffff}"
	end
	return "{9EC73D}Вкл{ffffff}"
end
function translite(text)
	for k, v in pairs(chars) do
		text = string.gsub(text, k, v)
	end
	return text
end

function inputChat()
	while true do
		if(sampIsChatInputActive()) and nel.check.translate_cmd.v then
			local getInput = sampGetChatInputText()
			if(oldText ~= getInput and #getInput > 0)then
				local firstChar = string.sub(getInput, 1, 1)
				if(firstChar == "." or firstChar == "/")then
					local cmd, text = string.match(getInput, "^([^ ]+)(.*)")
					local nText = "/" .. translite(string.sub(cmd, 2)) .. text
					local chatInfoPtr = sampGetInputInfoPtr()
					local chatBoxInfo = getStructElement(chatInfoPtr, 0x8, 4)
					local lastPos = mem.getint8(chatBoxInfo + 0x11E)
					sampSetChatInputText(nText)
					mem.setint8(chatBoxInfo + 0x11E, lastPos)
					mem.setint8(chatBoxInfo + 0x119, lastPos)
					oldText = nText
				end
			end
		end
		wait(0)
	end
end

function cmd_wh(arg)
    if control_wallhack then 
        showNotification("AdminTool", "Выключен WallHack")
        control_wallhack = false 
        nel.check.wallhack.v = false
        nameTagOff()
    else 
        showNotification("AdminTool", "Включен WallHack")
        nameTagOn()
        nel.check.wallhack.v = true
        control_wallhack = true
    end	 
end

function getBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
  end
  

function drawWallhack()
	local peds = getAllChars()
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	while true do
		wait(0)
		for i = 0, sampGetMaxPlayerId() do
			if sampIsPlayerConnected(i) and (nel.check.wallhack.v or control_wallhack) then
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
	end
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


function loadNotePad()
	local file = io.open(getGameDirectory().."//moonloader//config//AdminTool//note.txt", "r")
	notepad_note.v = file:read("*a")
	file:close()
end

function imgui.NewInputText(lable, val, width, hint, hintpos)
    local hint = hint and hint or ''
    local hintpos = tonumber(hintpos) and tonumber(hintpos) or 1
    local cPos = imgui.GetCursorPos()
    imgui.PushItemWidth(width)
    local result = imgui.InputText(lable, val)
    if #val.v == 0 then
        local hintSize = imgui.CalcTextSize(hint)
        if hintpos == 2 then imgui.SameLine(cPos.x + (width - hintSize.x) / 2)
        elseif hintpos == 3 then imgui.SameLine(cPos.x + (width - hintSize.x - 5))
        else imgui.SameLine(cPos.x + 5) end
        imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 0.40), tostring(hint))
    end
    imgui.PopItemWidth()
    return result
end

function sampev.onSendBulletSync(data)
    if nel.check.showMyBullet.v and nel.check.bullettracer.v then
        if data.center.x ~= 0 then
            if data.center.y ~= 0 then
                if data.center.z ~= 0 then
                    bulletSyncMy.lastId = bulletSyncMy.lastId + 1
                    if bulletSyncMy.lastId < 1 or bulletSyncMy.lastId > bulletSyncMy.maxLines then
                        bulletSyncMy.lastId = 1
                    end
                    bulletSyncMy[bulletSyncMy.lastId].my.time = os.time() + nel.intz.secondToCloseTwo.v
                    bulletSyncMy[bulletSyncMy.lastId].my.o.x, bulletSyncMy[bulletSyncMy.lastId].my.o.y, bulletSyncMy[bulletSyncMy.lastId].my.o.z = data.origin.x, data.origin.y, data.origin.z
                    bulletSyncMy[bulletSyncMy.lastId].my.t.x, bulletSyncMy[bulletSyncMy.lastId].my.t.y, bulletSyncMy[bulletSyncMy.lastId].my.t.z = data.target.x, data.target.y, data.target.z
                    if data.targetType == 0 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = join_argb(255, staticObjectMy.v[1]*255, staticObjectMy.v[2]*255, staticObjectMy.v[3]*255)
                    elseif data.targetType == 1 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = join_argb(255, pedPMy.v[1]*255, pedPMy.v[2]*255, pedPMy.v[3]*255)
                    elseif data.targetType == 2 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = join_argb(255, carPMy.v[1]*255, carPMy.v[2]*255, carPMy.v[3]*255)
                    elseif data.targetType == 3 then
                        bulletSyncMy[bulletSyncMy.lastId].my.color = join_argb(255, dinamicObjectMy.v[1]*255, dinamicObjectMy.v[2]*255, dinamicObjectMy.v[3]*255)
                    end
                end
            end 
        end
    end
end 

function sampev.onBulletSync(playerid, data)
    if nel.check.bullettracer.v then
        if data.center.x ~= 0 then
            if data.center.y ~= 0 then
                if data.center.z ~= 0 then
                    bulletSync.lastId = bulletSync.lastId + 1
                    if bulletSync.lastId < 1 or bulletSync.lastId > bulletSync.maxLines then
                        bulletSync.lastId = 1
                    end
                    bulletSync[bulletSync.lastId].other.time = os.time() + nel.intz.secondToClose.v
                    bulletSync[bulletSync.lastId].other.o.x, bulletSync[bulletSync.lastId].other.o.y, bulletSync[bulletSync.lastId].other.o.z = data.origin.x, data.origin.y, data.origin.z
                    bulletSync[bulletSync.lastId].other.t.x, bulletSync[bulletSync.lastId].other.t.y, bulletSync[bulletSync.lastId].other.t.z = data.target.x, data.target.y, data.target.z
                    if data.targetType == 0 then
                        bulletSync[bulletSync.lastId].other.color = join_argb(255, staticObject.v[1]*255, staticObject.v[2]*255, staticObject.v[3]*255)
                    elseif data.targetType == 1 then
                        bulletSync[bulletSync.lastId].other.color = join_argb(255, pedP.v[1]*255, pedP.v[2]*255, pedP.v[3]*255)
                    elseif data.targetType == 2 then
                        bulletSync[bulletSync.lastId].other.color = join_argb(255, carP.v[1]*255, carP.v[2]*255, carP.v[3]*255)
                    elseif data.targetType == 3 then
                        bulletSync[bulletSync.lastId].other.color = join_argb(255, dinamicObject.v[1]*255, dinamicObject.v[2]*255, dinamicObject.v[3]*255)
                    end
                end
            end
        end
    end
end

function EXPORTS.ActiveMenu()
    imgui.Text(fa.ICON_FA_CROSSHAIRS .. u8" Трейсера пуль")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
    if imgui.ToggleButton('##Tracers', nel.check.bullettracer) then 
        defTable.set.bullettracer = nel.check.bullettracer.v
        save()
    end
    imgui.Separator()
    imgui.Text("")
    if imgui.Checkbox(u8"Отображать/Не отображать свои пули", nel.check.showMyBullet) then
        defTable.set.showMyBullet = nel.check.showMyBullet.v
        save()
    end 
    imgui.Separator()
    if nel.check.showMyBullet.v then
        if imgui.CollapsingHeader(u8"Настроить трейсер своих пуль") then


            imgui.Separator()
            imgui.PushItemWidth(175)
            if imgui.SliderInt("##bulletsMyTime", nel.intz.secondToCloseTwo, 5, 15) then
                defTable.set.secondToCloseTwo = nel.intz.secondToCloseTwo.v
                save()
            end imgui.SameLine() imgui.Text(u8"Время задержки трейсера")
            if imgui.SliderInt("##renderWidthLinesTwo", nel.intz.widthRenderLineTwo, 1, 10) then
                defTable.set.widthRenderLineTwo = nel.intz.widthRenderLineTwo.v
                save()
            end imgui.SameLine() imgui.Text(u8"Толщина линий")
            if imgui.SliderInt('##maxMyBullets', nel.intz.maxMyLines, 10, 300) then
                bulletSyncMy.maxLines = nel.intz.maxMyLines.v
                bulletSyncMy = {lastId = 0, maxLines = nel.intz.maxMyLines.v}
                for i = 1, bulletSyncMy.maxLines do
                    bulletSyncMy[i] = { my = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
                end
                defTable.set.maxMyLines = nel.intz.maxMyLines.v
                save()
            end imgui.SameLine() imgui.Text(u8"Максимальное количество линий")

            imgui.Separator()

            if imgui.Checkbox(u8"[Вкл/выкл] Окончания у трейсеров##1", nel.check.cbEndMy) then
                defTable.set.cbEndMy = nel.check.cbEndMy.v
                save()
            end

            if imgui.SliderInt('##sizeTraicerEnd', nel.intz.sizeOffPolygon, 1, 10) then
                defTable.set.sizeOffPolygon = nel.intz.sizeOffPolygon.v
                save()
            end  imgui.SameLine() imgui.Text(u8"Размер окончания трейсера")
            if imgui.SliderInt('##endNumbers', nel.intz.polygonNumber, 2, 10) then
                defTable.set.polygonNumber = nel.intz.polygonNumber.v 
                save()
            end imgui.SameLine() imgui.Text(u8"Количество углов на окончаниях")
            if imgui.SliderInt('##rotationOne', nel.intz.rotationPolygonOne, 0, 360) then
                defTable.set.rotationPolygonOne = nel.intz.rotationPolygonOne.v
                save()
            end imgui.SameLine() imgui.Text(u8"Градус поворота окончания")


            imgui.PopItemWidth()
            imgui.Separator()
            imgui.Text(u8"Укажите цвет трейсера, если вы попали в:")
            imgui.PushItemWidth(325)
            if imgui.ColorEdit4("##dinamicObjectMy", dinamicObjectMy) then
                defTable.set.dinamicObjectMy = join_argb(dinamicObjectMy.v[1] * 255, dinamicObjectMy.v[2] * 255, dinamicObjectMy.v[3] * 255, dinamicObjectMy.v[4] * 255)
                save()
            end imgui.SameLine() imgui.Text(u8"Динамический объект")
            if imgui.ColorEdit4("##staticObjectMy", staticObjectMy) then
                defTable.set.staticObjectMy = join_argb(staticObjectMy.v[1] * 255, staticObjectMy.v[2] * 255, staticObjectMy.v[3] * 255, staticObjectMy.v[4] * 255)
                save()
            end imgui.SameLine() imgui.Text(u8"Статический объект")
            if imgui.ColorEdit4("##pedMy", pedPMy) then
                defTable.set.pedPMy = join_argb(pedPMy.v[1] * 255, pedPMy.v[2] * 255, pedPMy.v[3] * 255, pedPMy.v[4] * 255)
                save()
            end imgui.SameLine() imgui.Text(u8"Игрока")
            if imgui.ColorEdit4("##carMy", carPMy) then
                defTable.set.carPMy = join_argb(carPMy.v[1] * 255, carPMy.v[2] * 255, carPMy.v[3] * 255, carPMy.v[4] * 255)
                save()
            end imgui.SameLine() imgui.Text(u8"Машину")
            imgui.PopItemWidth()
            imgui.Separator()
        end
    end 
    if imgui.CollapsingHeader(u8"Настроить трейсер чужих пуль") then
        imgui.Separator()
        imgui.PushItemWidth(175)
        if imgui.SliderInt("##secondsBullets", nel.intz.secondToClose, 5, 15) then
            defTable.set.secondToClose = nel.intz.secondToClose.v
            save()
        end imgui.SameLine() imgui.Text(u8"Время задержки трейсера")
        if imgui.SliderInt("##renderWidthLinesOne", nel.intz.widthRenderLineOne, 1, 10) then
            defTable.set.widthRenderLineOne = nel.intz.widthRenderLineOne.v
            save()
        end imgui.SameLine() imgui.Text(u8"Толщина линий")
        if imgui.SliderInt('##numberNotMyBullet', nel.intz.maxNotMyLines, 10, 300) then
            bulletSync.maxNotMyLines = nel.intz.maxNotMyLines.v
            bulletSync = {lastId = 0, maxLines = nel.intz.maxNotMyLines.v}
            for i = 1, bulletSync.maxLines do
                bulletSync[i] = { other = {time = 0, t = {x,y,z}, o = {x,y,z}, type = 0, color = 0}}
            end
            defTable.set.maxNotMyLines = nel.intz.maxNotMyLines.v
            save()
        end imgui.SameLine() imgui.Text(u8"Максимальное количество линий")

        imgui.Separator()

        if imgui.Checkbox(u8"[Вкл/выкл] Окончания у трейсеров##2", nel.check.cbEnd) then
            defTable.set.cbEnd = nel.check.cbEnd.v
            save()
        end

        if imgui.SliderInt('##sizeTraicerEndTwo', nel.intz.sizeOffPolygonTwo, 1, 10) then
            defTable.set.sizeOffPolygonTwo = nel.intz.sizeOffPolygonTwo.v
            save()
        end imgui.SameLine() imgui.Text(u8"Размер окончания трейсера")

        if imgui.SliderInt('##endNumbersTwo', nel.intz.polygonNumberTwo, 2, 10) then
            defTable.set.polygonNumberTwo = nel.intz.polygonNumberTwo.v 
            save()
        end imgui.SameLine() imgui.Text(u8"Количество углов на окончаниях")

        if imgui.SliderInt('##rotationTwo', nel.intz.rotationPolygonTwo, 0, 360) then
            defTable.set.rotationPolygonTwo = nel.intz.rotationPolygonTwo.v
            save() 
        end imgui.SameLine() imgui.Text(u8"Градус поворота окончания")

        imgui.PopItemWidth()
        imgui.Separator()
        imgui.Text(u8"Укажите цвет трейсера, если игрок попал в: ")
        imgui.PushItemWidth(325)
        if imgui.ColorEdit4("##dinamicObject", dinamicObject) then
            defTable.set.dinamicObject = join_argb(dinamicObject.v[1] * 255, dinamicObject.v[2] * 255, dinamicObject.v[3] * 255, dinamicObject.v[4] * 255)
            save()
        end imgui.SameLine() imgui.Text(u8"Динамический объект")
        if imgui.ColorEdit4("##staticObject", staticObject) then
            defTable.set.staticObject = join_argb(staticObject.v[1] * 255, staticObject.v[2] * 255, staticObject.v[3] * 255, staticObject.v[4] * 255)
            save()
        end imgui.SameLine() imgui.Text(u8"Статический объект")
        if imgui.ColorEdit4("##ped", pedP) then
            defTable.set.pedP = join_argb(pedP.v[1] * 255, pedP.v[2] * 255, pedP.v[3] * 255, pedP.v[4] * 255)
            save()
        end imgui.SameLine() imgui.Text(u8"Игрока")
        if imgui.ColorEdit4("##car", carP) then
            defTable.set.carP = join_argb(carP.v[1] * 255, carP.v[2] * 255, carP.v[3] * 255, carP.v[4] * 255)
            save()
        end imgui.SameLine() imgui.Text(u8"Машину")
        imgui.PopItemWidth()
        imgui.Separator()
    end 
end        

function EXPORTS.InfiniteRun()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
    imgui.Text(fa.ICON_BATTERY_FULL .. u8" Infinite Run") 
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 100)
    if imgui.ToggleButton('##InfiniteRun', nel.check.infinite_run) then 
        if nel.check.infinite_run.v then  
            showNotification("AdminTool", "Включен Infinite Run")
        else  
            showNotification("AdminTool", "Выключен Infinite Run")
        end 
        defTable.set.infinite_run = nel.check.infinite_run.v 
        save()
    end	
end    

function EXPORTS.Notepad()
    imgui.NewInputText("##Search", notepad_search, 170, u8"Поиск", 1) 				
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 85)
    if imgui.Button(u8"Сохранить") then
        toggle_input.v = false
        local file = io.open(getGameDirectory().."//moonloader//config//AdminTool//note.txt", "w")
        file:write(notepad_note.v)
        file:close()
    end
    imgui.Separator()
    if toggle_input.v then
        imgui.InputTextMultiline('##NotepadInput', notepad_note, imgui.ImVec2(-1, 498))
        imgui.Separator()
    else
        if #notepad_search.v > 0 then
            for line in notepad_note.v:gmatch("[^\r\n]+") do
                if line:find(notepad_search.v:gsub("%p", "%%%1")) then
                    imgui.TextColoredRGB(line)
                end
            end
        else
            for line in notepad_note.v:gmatch("[^\r\n]+") do
                imgui.TextColoredRGB(line)
            end
        end
        imgui.SetCursorPosX(0)
        imgui.SetCursorPosY(0)
        if imgui.InvisibleButton('##Click', imgui.ImVec2(-1, -1)) then
            toggle_input.v = true
        end
    end
end    

function EXPORTS.ActiveWHRe()
    imgui.Text(fai.ICON_FA_USER_TAG .. u8" WallHack")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 50)
    if imgui.ToggleButton('##WallHack', nel.check.wallhack) then 
        defTable.set.wallhack = nel.check.wallhack.v
        if nel.check.wallhack.v then 
            showNotification("AdminTool", "Включен WallHack")
            nameTagOn()
            control_wallhack = true
        else 
            showNotification("AdminTool", "Выключен WallHack")
            control_wallhack = false
            nameTagOff()
        end	
        save()
    end
end    

function EXPORTS.ActiveWH()
    imgui.Text(fai.ICON_FA_USER_TAG .. u8" WallHack")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
    if imgui.ToggleButton('##WallHack', nel.check.wallhack) then 
        defTable.set.wallhack = nel.check.wallhack.v
        if nel.check.wallhack.v then 
            showNotification("AdminTool", "Включен WallHack")
            nameTagOn()
            control_wallhack = true
        else 
            showNotification("AdminTool", "Выключен WallHack")
            control_wallhack = false
            nameTagOff()
        end	
        save()
    end
end    

function EXPORTS.ActiveBT()
    imgui.Text(fa.ICON_FA_CROSSHAIRS .. u8" Трейсера пуль")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 50)
    if imgui.ToggleButton('##Tracers', nel.check.bullettracer) then 
        defTable.set.bullettracer = nel.check.bullettracer.v
        save()
    end
end    

function EXPORTS.kposition()
    changePosition = true
    sampAddChatMessage(tag .. ' Чтобы подтвердить сохранение - нажмите 1')
end

function EXPORTS.translatecmd()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
    imgui.Text(fa.ICON_SIGN_LANGUAGE .. u8" Перевод команд")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 100)
    if imgui.ToggleButton("##Translate_cmd", nel.check.translate_cmd) then
        defTable.set.translate_cmd = nel.check.translate_cmd.v 
        save() 
    end
end   

function EXPORTS.changefont()
    imgui.Text(u8'Размер шрифта InputHelper')
    imgui.PushItemWidth(175)
    if imgui.SliderInt("##sizehelpfont", nel.intz.fontHelp, 1, 20) then
        inputHelpText = renderCreateFont("Arial", tonumber(nel.intz.fontHelp.v), FCR_BORDER + FCR_BOLD)
        defTable.set.fontHelp = nel.intz.fontHelp.v
        save()
    end	
end   

function onScriptTerminate(script, quitGame)
	if script == thisScript() then 
		if save() then sampfuncsLog('{00FF00}AdminTool: {FFFFFF}Настройки сохранены!!') end
	end
end


function EXPORTS.OffScript()
    imgui.ShowCursor = false
    thisScript():unload()
end    

function imgui.OnDrawFrame()
    if nel.ksync.skey.v then  
        imgui.ShowCursor = false 

        imgui.SetNextWindowPos(imgui.ImVec2(defTable.set.skeyposX, defTable.set.skeyposY), imgui.Cond.Always, imgui.ImVec2(1, 1))
		imgui.Begin("KEYS", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)
			if doesCharExist(target) then
				local plState = (isCharOnFoot(target) and "onfoot" or "vehicle")

				imgui.BeginGroup()
					imgui.SetCursorPosX(10 + 30 + 44)
					KeyCap("W", (keys[plState]["W"] ~= nil), imgui.ImVec2(30, 30))
					KeyCap("Tab", (keys[plState]["Tab"] ~= nil), imgui.ImVec2(30,30)); imgui.SameLine()
					KeyCap("A", (keys[plState]["A"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
					KeyCap("S", (keys[plState]["S"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
					KeyCap("D", (keys[plState]["D"] ~= nil), imgui.ImVec2(30, 30))
				imgui.EndGroup()
				imgui.SameLine(nil, 20)

				if plState == "onfoot" then
					imgui.BeginGroup()
						KeyCap("Shift", (keys[plState]["Shift"] ~= nil), imgui.ImVec2(75, 30)); imgui.SameLine()
						KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(55, 30))
						KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
					imgui.EndGroup()
					imgui.SameLine()
					imgui.BeginGroup()
						KeyCap("C", (keys[plState]["C"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
						KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
						KeyCap("RM", (keys[plState]["RKM"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
						KeyCap("LM", (keys[plState]["LKM"] ~= nil), imgui.ImVec2(30, 30))		
					imgui.EndGroup()
				else
					imgui.BeginGroup()
						KeyCap("Ctrl", (keys[plState]["Ctrl"] ~= nil), imgui.ImVec2(65, 30)); imgui.SameLine()
						KeyCap("Alt", (keys[plState]["Alt"] ~= nil), imgui.ImVec2(65, 30))
						KeyCap("Space", (keys[plState]["Space"] ~= nil), imgui.ImVec2(135, 30))
					imgui.EndGroup()
					imgui.SameLine()
					imgui.BeginGroup()
						KeyCap("Up", (keys[plState]["Up"] ~= nil), imgui.ImVec2(40, 30))
						KeyCap("Down", (keys[plState]["Down"] ~= nil), imgui.ImVec2(40, 30))	
					imgui.EndGroup()
					imgui.SameLine()
					imgui.BeginGroup()
						KeyCap("H", (keys[plState]["H"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
						KeyCap("F", (keys[plState]["F"] ~= nil), imgui.ImVec2(30, 30))
						KeyCap("Q", (keys[plState]["Q"] ~= nil), imgui.ImVec2(30, 30)); imgui.SameLine()
						KeyCap("E", (keys[plState]["E"] ~= nil), imgui.ImVec2(30, 30))
					imgui.EndGroup()
				end
			else
				imgui.Text(u8"Игрок не находится в зоне стрима AT. Игрок не был выбран скриптом.\nПроверьте правильность переменной.\nЕсли вы в режиме смены положения окна - игнорируйте данный текст.\nЕсли скрипт автоматически после смены положения окна не завершил его, перезагрузите скрипты (ALT+R)")
			end
		imgui.End()
    end    
end

function KeyCap(keyName, isPressed, size)
	u32 = imgui.ColorConvertFloat4ToU32
	local DL = imgui.GetWindowDrawList()
	local p = imgui.GetCursorScreenPos()
	local colors = {
		[true] = imgui.ImVec4(0.60, 0.60, 1.00, 1.00),
		[false] = imgui.ImVec4(0.60, 0.60, 1.00, 0.10)
	}

	if KEYCAP == nil then KEYCAP = {} end
	if KEYCAP[keyName] == nil then
		KEYCAP[keyName] = {
			status = isPressed,
			color = colors[isPressed],
			timer = nil
		}
	end

	local K = KEYCAP[keyName]
	if isPressed ~= K.status then
		K.status = isPressed
		K.timer = os.clock()
	end

	local rounding = 3.0
	local A = imgui.ImVec2(p.x, p.y)
	local B = imgui.ImVec2(p.x + size.x, p.y + size.y)
	if K.timer ~= nil then
		K.color = bringVec4To(colors[not isPressed], colors[isPressed], K.timer, 0.1)
	end
	local ts = imgui.CalcTextSize(keyName)
	local text_pos = imgui.ImVec2(p.x + (size.x / 2) - (ts.x / 2), p.y + (size.y / 2) - (ts.y / 2))

	imgui.Dummy(size)
	DL:AddRectFilled(A, B, u32(K.color), rounding)
	DL:AddRect(A, B, u32(colors[true]), rounding, _, 1)
	DL:AddText(text_pos, 0xFFFFFFFF, keyName)
end

function cyrillic(text)
    local convtbl = {
    	[230] = 155, [231] = 159, [247] = 164, [234] = 107, [250] = 144, [251] = 168,
    	[254] = 171, [253] = 170, [255] = 172, [224] = 097, [240] = 112, [241] = 099, 
    	[226] = 162, [228] = 154, [225] = 151, [227] = 153, [248] = 165, [243] = 121, 
    	[184] = 101, [235] = 158, [238] = 111, [245] = 120, [233] = 157, [242] = 166, 
    	[239] = 163, [244] = 063, [237] = 174, [229] = 101, [246] = 036, [236] = 175, 
    	[232] = 156, [249] = 161, [252] = 169, [215] = 141, [202] = 075, [204] = 077, 
    	[220] = 146, [221] = 147, [222] = 148, [192] = 065, [193] = 128, [209] = 067, 
    	[194] = 139, [195] = 130, [197] = 069, [206] = 079, [213] = 088, [168] = 069, 
    	[223] = 149, [207] = 140, [203] = 135, [201] = 133, [199] = 136, [196] = 131, 
    	[208] = 080, [200] = 133, [198] = 132, [210] = 143, [211] = 089, [216] = 142, 
    	[212] = 129, [214] = 137, [205] = 072, [217] = 138, [218] = 167, [219] = 145
    }
    local result = {}
    for i = 1, string.len(text) do
        local c = text:byte(i)
        result[i] = string.char(convtbl[c] or c)
    end
    return table.concat(result)
end

function bringVec4To(from, dest, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (dest.x - from.x) / 100),
            from.y + (count * (dest.y - from.y) / 100),
            from.z + (count * (dest.z - from.z) / 100),
            from.w + (count * (dest.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and dest or from, false
end