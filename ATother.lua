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

local directIni = "AdminTool\\config.ini" -- создание специального файла, отвечающего за настройки.

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280) -- захват позиции костей
local control_wallhack = false

imgui.ToggleButton = require('imgui_addons').ToggleButton

local fa = require 'faicons'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
local fav = require 'fAwesome5'

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
        admin_state = false,
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
    }
}

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
		wait(10)
		for i = 0, sampGetMaxPlayerId() do
			if sampIsPlayerConnected(i) and control_wallhack then
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
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
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
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
    imgui.Text(fa.ICON_BATTERY_FULL .. u8" Infinite Run") 
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 50)
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

function EXPORTS.ActiveWH()
    imgui.Text(fa.ICON_USER_O .. u8" WallHack")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 50)
    if imgui.ToggleButton('##WallHack', nel.check.wallhack) then 
        defTable.set.wallhack = nel.check.wallhack.v
        if control_wallhack then 
            showNotification("AdminTool", "Выключен WallHack")
            control_wallhack = false 
            nameTagOff()
        else 
            showNotification("AdminTool", "Включен WallHack")
            nameTagOn()
            control_wallhack = true
        end	
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

function EXPORTS.OffScript()
    imgui.ShowCursor = false
    thisScript():unload()
end    