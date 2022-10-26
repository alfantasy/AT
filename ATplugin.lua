require "lib.moonloader" -- подключение основной библиотеки mooloader
local ffi = require "ffi" -- cпец структура
local font_admin_chat = require ("moonloader").font_flag -- шрифт для админ-чата
local vkeys = require "vkeys" -- регистр для кнопок
local imgui = require 'imgui' -- регистр imgui окон
local encoding = require 'encoding' -- дешифровка форматов
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local mem = require "memory" -- библиотека, отвечающие за чтение памяти, и её факторы
local notfy	= import 'lib/lib_imgui_notf.lua'
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
function showNotification(handle, text_not)
	notfy.addNotify("{87CEEB}" .. handle, text_not, 2, 1, 6)
end

local plugin_res, plugin = pcall(import, "module/ATother.lua")
local fa = require 'faicons'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

local fontsize = nil

local directIni = "AdminTool\\reconconfig.ini"

local tag = "{00BFFF} [AT] " -- локальная переменная, которая регистрирует тэг AT
local sw, sh = getScreenResolution() -- отвечает за второстепенную длину и ширину окон.

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar

local plre = inicfg.load({
    sett = {
        adminchat = false,
        anticheat = false,
		lcadm_imgui = false,
		Font = 10,
    },
    achat = {
        X = 48,
        Y = 298, 
        centered = 0,
        color = -1,
        nick = 1,
        lines = 10,
        Font = 10, 
		lines_imgui = 10,
		X_size = 50,
		Y_size = 50,
		X_imgui = 50,
		Y_imgui = 298,
    },
}, directIni)
inicfg.save(plre, directIni)

function save() 
    inicfg.save(plre, directIni)
end

local lem = {
    toggle = {
        adminchat = imgui.ImBool(plre.sett.adminchat),
		im_ac = imgui.ImBool(plre.sett.lcadm_imgui),
        anticheat = imgui.ImBool(plre.sett.anticheat),
    },
    int = {
        adminFont = imgui.ImInt(plre.achat.Font),
		X_size = imgui.ImInt(plre.achat.X_size),
		Y_size = imgui.ImInt(plre.achat.Y_size),
		Font = imgui.ImInt(plre.sett.Font),
    },
}

local admin_chat_lines = { 
	centered = imgui.ImInt(0),
	nick = imgui.ImInt(1),
	color = -1,
	lines = imgui.ImInt(10),
	X = 0,
	Y = 0,
	im_l = imgui.ImInt(10)
}

local ac_no_saved = {
	chat_lines = { },
	pos = false,
	X = 0,
	Y = 0,
	chat_imgui = { }
}

local msgs = {}
local changePosition = false
local rbutton = imgui.ImInt(0)
local changeint = 0

local line_ac = imgui.ImInt(16) 
local font_ac = renderCreateFont("Arial", tonumber(lem.int.adminFont.v), font_admin_chat.BOLD + font_admin_chat.SHADOW)

function saveAdminChat()
	plre.achat.X = admin_chat_lines.X
	plre.achat.Y = admin_chat_lines.Y
	plre.achat.centered = admin_chat_lines.centered.v
	plre.achat.nick = admin_chat_lines.nick.v
	plre.achat.color = admin_chat_lines.color
	plre.achat.lines = admin_chat_lines.lines.v
	plre.achat.lines_imgui = admin_chat_lines.im_l.v  
	save()
end

function loadAdminChat()
	admin_chat_lines.X = plre.achat.X
	admin_chat_lines.Y = plre.achat.Y
	admin_chat_lines.centered.v = plre.achat.centered
	admin_chat_lines.nick.v = plre.achat.nick
	admin_chat_lines.color = plre.achat.color
	admin_chat_lines.lines.v = plre.achat.lines
	admin_chat_lines.im_l.v = plre.achat.lines_imgui
	lem.int.adminFont.v = plre.achat.Font
end

function imgui.BeforeDrawFrame()
	if fa_font == nil then  
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
	if fontsize == nil then
        fontsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\SegoeUI.ttf', lem.int.Font.v, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) 
    end
end 

function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

local lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text

function sampev.onServerMessage(color, text)

    lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")

	local check_string = string.match(text, "[^%s]+")
	local check_string_2 = string.match(text, "[^%s]+")

    if text:find("%[(.+)%] IP:") then
        local nick, ip2 = text:match("%[(.+)%] IP: (.+) | IP")
        ip1 = ip2
        return true
    end

	if (lem.toggle.adminchat.v or lem.toggle.im_ac.v) and check_string ~= nil and string.find(check_string, "%[A%-(%d+)%]") ~= nil and string.find(text, "%[A%-(%d+)%] (.+) отключился") == nil then
		local lc_text_chat
		if lem.toggle.adminchat.v then  
			if admin_chat_lines.nick.v == 1 then
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = lc_lvl .. " • " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
				else
					admin_chat_lines.color = color
					lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} • " .. lc_lvl .. " • " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
				end
			else
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] • " .. lc_lvl
				else
					lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] • " .. lc_lvl .. " • " .. lc_adm
					admin_chat_lines.color = color
				end
			end
		end
		if lem.toggle.im_ac.v then  
			if admin_chat_lines.nick.v == 1 then
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = lc_lvl .. " *  " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
				else
					admin_chat_lines.color = color
					lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} *  " .. lc_lvl .. " *  " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
				end
			else
				if lc_adm == nil then
					lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
					lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] *  " .. lc_lvl
				else
					lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] *  " .. lc_lvl .. " *  " .. lc_adm
					admin_chat_lines.color = color
				end
			end
		end	
		if lem.toggle.adminchat.v then 
			for i = admin_chat_lines.lines.v, 1, -1 do
				if i ~= 1 then
					ac_no_saved.chat_lines[i] = ac_no_saved.chat_lines[i-1]
				else
					ac_no_saved.chat_lines[i] = lc_text_chat
				end
			end
		end	
		if lem.toggle.im_ac.v then 
			for i = admin_chat_lines.im_l.v, 1, -1 do
				if i ~= 1 then
					ac_no_saved.chat_imgui[i] = ac_no_saved.chat_imgui[i-1]
				else
					ac_no_saved.chat_imgui[i] = lc_text_chat
				end
			end 
		end		
		return false
	end		

end    

function main()
    while not isSampAvailable() do wait(0) end

    admin_chat = lua_thread.create_suspended(drawAdminChat)
    render_warn = lua_thread.create_suspended(renderWarnings)
    loadAdminChat()
	admin_chat:run()
	sampAddChatMessage(tag .. " Подгрузка плагина дополнительных функций.")

    while true do
        wait(0)

		imgui.Process = true

        if ac_no_saved.pos then
			change_adm_chat()
		end

		if not lem.toggle.im_ac.v then  
			lem.toggle.im_ac.v = false 
			imgui.Process = false 
			imgui.ShowCursor = false  
		end	

		changePos()
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

function changePos()
	if changePosition then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        plre.achat.X_imgui, plre.achat.Y_imgui = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            showNotification(tag, "Положение окна сохранено!")
            changePosition = false
            save()
        end
    end
end	

function change_adm_chat()
	if isKeyJustPressed(VK_RBUTTON) then
		admin_chat_lines.X = ac_no_saved.X
		admin_chat_lines.Y = ac_no_saved.Y
		ac_no_saved.pos = false
	elseif isKeyJustPressed(VK_LBUTTON) then
		ac_no_saved.pos = false
	else
		admin_chat_lines.X, admin_chat_lines.Y = getCursorPos()
	end
end

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

function drawAdminChat()
    while true do
		if lem.toggle.adminchat.v then
			if admin_chat_lines.centered.v == 0 then
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X, admin_chat_lines.Y+(lem.int.adminFont.v+4)*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			elseif admin_chat_lines.centered.v == 1 then
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]) / 2, admin_chat_lines.Y+lem.int.adminFont.v*(admin_chat_lines.lines.v - i)+5, join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			elseif admin_chat_lines.centered.v == 2 then
				for i = admin_chat_lines.lines.v, 1, -1 do
					if ac_no_saved.chat_lines[i] == nil then
						ac_no_saved.chat_lines[i] = " "
					end
					renderFontDrawText(font_ac, ac_no_saved.chat_lines[i], admin_chat_lines.X - renderGetFontDrawTextLength(font_ac, ac_no_saved.chat_lines[i]), admin_chat_lines.Y+lem.int.adminFont.v*(admin_chat_lines.lines.v - i), join_argb(explode_samp_rgba(admin_chat_lines.color)))
				end
			end
		end
        wait(1)
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

function imgui.OnDrawFrame()
    
    if lem.toggle.im_ac.v then  

		imgui.SetNextWindowSize(imgui.ImVec2(lem.int.X_size.v, lem.int.Y_size.v), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(plre.achat.X_imgui, plre.achat.Y_imgui), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.ShowCursor = false

        imgui.Begin(u8'AdminChat', nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize)
		
			for i = admin_chat_lines.im_l.v, 1, -1 do 
				if ac_no_saved.chat_imgui[i] ~= nil then	
					imgui.PushFont(fontsize)
						imgui.TextColoredRGB(u8(ac_no_saved.chat_imgui[i]))	
					imgui.PopFont()
				end	
			end
		imgui.End()
    end    
end

function EXPORTS.ActiveATChat()
    imgui.BeginChild('##AdminChat', imgui.ImVec2(230, 250), true)
	if imgui.RadioButton(u8"Imgui-чат ##1",rbutton,1) then  
		changeint = 1  
	end 
	imgui.SameLine() 
	if imgui.RadioButton(u8" Рендер-чат ##2", rbutton,2) then  
		changeint = 2 
	end	 
	imgui.Separator()
	if changeint == 1 then  
		imgui.Text(fa.ICON_TELEGRAM .. u8" Админ-чат") 
		imgui.SameLine()
		if imgui.ToggleButton('##AdminChat_Imgui', lem.toggle.im_ac) then 
			plre.sett.lcadm_imgui = lem.toggle.im_ac.v
			save()
		end	
		imgui.SameLine()
		imgui.TextQuestion('(?)', u8"Выводит отдельно от основного чата - административный, при помощи интерфейса imgui\nДля обновление настроек, необходимо перезагрузить скрипт (ALT+R)!")
		if imgui.Button(u8"Изменение положения окна") then  
			sampAddChatMessage(tag .. ' Чтобы сохранить положение - нажмите 1')
			changePosition = true
		end	
		imgui.Text(u8"Изменение ширины окна: ")
		imgui.PushItemWidth(80)
		if imgui.InputInt('##changenumberX_imgui', lem.int.X_size) then  
			plre.achat.X_size = lem.int.X_size.v 
			save()
		end	
		imgui.PopItemWidth()
		imgui.Text(u8"Изменение длины окна: ")
		imgui.PushItemWidth(80)
		if imgui.InputInt('##changenumberY_imgui', lem.int.Y_size) then  
			plre.achat.Y_size = lem.int.Y_size.v 
			save()
		end	
		imgui.PopItemWidth()
		imgui.Text(u8'Количество строк: ')
		imgui.PushItemWidth(80)
		imgui.InputInt('##changenumberlinesimgui', admin_chat_lines.im_l)
		imgui.PopItemWidth()
		imgui.Text(u8'Размер шрифта: ')
		imgui.PushItemWidth(80)
		if imgui.SliderInt('##changenumberfontsize', lem.int.Font, 1, 64) then  
			plre.sett.Font = lem.int.Font.v  
			save() 
		end	
		imgui.PopItemWidth()
		if imgui.Button(u8'Сохранить') then
			showNotification("Save Admin-Chat", "Настройки сохранены \nImgui-AdminChat")
			saveAdminChat()
			save()
		end
	end	
	if changeint == 2 then  
		imgui.Text(fa.ICON_TELEGRAM .. u8" Админ-чат")
		imgui.SameLine()
		if imgui.ToggleButton('##AdminChat_Render', lem.toggle.adminchat) then 
			plre.sett.adminchat = lem.toggle.adminchat.v
			save()
		end	
		imgui.SameLine()
		imgui.TextQuestion('(?)', u8"Выводит отдельно от основного чата - административный, при помощи рендера текста")
		imgui.Separator()
		if imgui.Button(u8'Положение чата') then
			ac_no_saved.X = admin_chat_lines.X; ac_no_saved.Y = admin_chat_lines.Y
			ac_no_saved.pos = true
		end
		imgui.Text(u8'Выравнивание чата: ')
		imgui.Combo("##Position", admin_chat_lines.centered,  {u8"По левый край.", u8"По центру.", u8"По правый край."})
		imgui.PushItemWidth(50)
		imgui.Text(u8'Размер шрифта:')
		if imgui.SliderInt("##sizeAcFont", lem.int.adminFont, 1, 20) then
			font_ac = renderCreateFont("Arial", tonumber(lem.int.adminFont.v), font_admin_chat.BOLD + font_admin_chat.SHADOW)
			plre.achat.Font = lem.int.adminFont.v
			save()
		end	
		imgui.PopItemWidth()
		imgui.Text(u8'Положение ника и уровня: ')
		imgui.Combo("##Pos", admin_chat_lines.nick, {u8"Справа.", u8"Слева."})
		imgui.Text(u8'Количество строк: ')
		imgui.PushItemWidth(80)
		imgui.InputInt(' ', admin_chat_lines.lines)
		imgui.PopItemWidth()
		if imgui.Button(u8'Сохранить!') then
			showNotification("Save Admin-Chat", "Настройка админ-чата сохранены\nRender-AdminChat")
			saveAdminChat()
		end
	end	
    imgui.EndChild()
end    

function EXPORTS.OffScript()
	imgui.ShowCursor = false
	thisScript():unload()
end
