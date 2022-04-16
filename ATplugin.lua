script_name('ATRecon-plugin')
script_description('������-������, ���������� � AdminTool ������� ������')
script_properties('work-in-pause')

require "lib.moonloader" -- ����������� �������� ���������� mooloader
local ffi = require "ffi" -- c��� ���������
local font_admin_chat = require ("moonloader").font_flag -- ����� ��� �����-����
local vkeys = require "vkeys" -- ������� ��� ������
local imgui = require 'imgui' -- ������� imgui ����
local encoding = require 'encoding' -- ���������� ��������
local inicfg = require 'inicfg' -- ������ � ini
local sampev = require "lib.samp.events" -- ����������� �������� ���������, ��������� � ������� ������� ������� SA:MP, � �� ������ ���������� � LUA
local mem = require "memory" -- ����������, ���������� �� ������ ������, � � �������
local notfy	= import 'lib/lib_imgui_notf.lua'
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
function showNotification(handle, text_not)
	notfy.addNotify("{87CEEB}" .. handle, text_not, 2, 1, 6)
end

local plugin_res, plugin = pcall(import, "module/ATother.lua")
local fa = require 'faicons'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })

function imgui.BeforeDrawFrame()
	if fa_font == nil then  
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
end 

local directIni = "AdminTool\\reconconfig.ini"

local tag = "{00BFFF} [AT] " -- ��������� ����������, ������� ������������ ��� AT
local sw, sh = getScreenResolution() -- �������� �� �������������� ����� � ������ ����.

imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar

local plre = inicfg.load({
    sett = {
        adminchat = false,
        anticheat = false,
    },
    achat = {
        X = 48,
        Y = 298, 
        centered = 0,
        color = -1,
        nick = 1,
        lines = 10,
        Font = 10
    },
    acwarn = {
        X = 0,
        Y = 0,
        lines = 5
    }
}, directIni)
inicfg.save(plre, directIni)

function save() 
    inicfg.save(plre, directIni)
end

local lem = {
    toggle = {
        ATRecon = imgui.ImBool(plre.sett.recon),
        adminchat = imgui.ImBool(plre.sett.adminchat),
        anticheat = imgui.ImBool(plre.sett.anticheat),
    },
    int = {
        adminFont = imgui.ImInt(plre.achat.Font),
    },
    ac = {
        line = imgui.ImInt(plre.acwarn.lines),
        X = plre.acwarn.X, 
        Y = plre.acwarn.Y,
    }
}

local admin_chat_lines = { 
	centered = imgui.ImInt(0),
	nick = imgui.ImInt(1),
	color = -1,
	lines = imgui.ImInt(10),
	X = 0,
	Y = 0
}
-- ����� �����

local ac_no_saved = {
	chat_lines = { },
	pos = false,
	X = 0,
	Y = 0
}
-- �� �����������

local warn_no_saved = {
	pos = false,
	str_lines = { },  
	X = 0,
	Y = 0
}

local line_ac = imgui.ImInt(16) -- ����� ��� ����� �����
local font_ac = renderCreateFont("Arial", tonumber(lem.int.adminFont.v), font_admin_chat.BOLD + font_admin_chat.SHADOW)

function saveAdminChat()
	plre.achat.X = admin_chat_lines.X
	plre.achat.Y = admin_chat_lines.Y
	plre.achat.centered = admin_chat_lines.centered.v
	plre.achat.nick = admin_chat_lines.nick.v
	plre.achat.color = admin_chat_lines.color
	plre.achat.lines = admin_chat_lines.lines.v
	save()
end
-- ���������� ���������
function loadAdminChat()
	admin_chat_lines.X = plre.achat.X
	admin_chat_lines.Y = plre.achat.Y
	admin_chat_lines.centered.v = plre.achat.centered
	admin_chat_lines.nick.v = plre.achat.nick
	admin_chat_lines.color = plre.achat.color
	admin_chat_lines.lines.v = plre.achat.lines
	lem.int.adminFont.v = plre.achat.Font
end
-- �������� ���������

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

local ac_string = '' -- ������ ��������

function sampev.onServerMessage(color, text)

    lc_lvl, lc_adm, lc_color, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] %((.+){(.+)}%) (.+)%[(%d+)%]: {FFFFFF}(.+)")

	-- <AC-WARNING> {ffffff}Jeff_507[34]{82b76b} ������������� � ������������� ���-��������: {ffffff}Rapid fire [code: 026].

	local check_string = string.match(text, "[^%s]+")
	local check_string_2 = string.match(text, "[^%s]+")

    if text:find("%[(.+)%] IP:") then
        local nick, ip2 = text:match("%[(.+)%] IP: (.+) | IP")
        ip1 = ip2
        return true
    end

	if lem.toggle.adminchat.v and check_string ~= nil and string.find(check_string, "%[A%-(%d+)%]") ~= nil and string.find(text, "%[A%-(%d+)%] (.+) ����������") == nil then
		local lc_text_chat
		if admin_chat_lines.nick.v == 1 then
			if lc_adm == nil then
				lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
				lc_text_chat = lc_lvl .. " � " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text
			else
				admin_chat_lines.color = color
				lc_text_chat = lc_adm .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} � " .. lc_lvl .. " � " .. lc_nick .. "[" .. lc_id .. "] : {FFFFFF}" .. lc_text 
			end
		else
			if lc_adm == nil then
				lc_lvl, lc_nick, lc_id, lc_text = text:match("%[A%-(%d+)%] (.+)%[(%d+)%]: {FFFFFF}(.+)")
				lc_text_chat = "{FFFFFF}" .. lc_text .. " {" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "}: " .. lc_nick .. "[" .. lc_id .. "] � " .. lc_lvl
			else
				lc_text_chat = "{FFFFFF}" .. lc_text .. "{" .. (bit.tohex(join_argb(explode_samp_rgba(color)))):sub(3, 8) .. "} : " .. lc_nick .. "[" .. lc_id .. "] � " .. lc_lvl .. " � " .. lc_adm
				admin_chat_lines.color = color
			end
		end
		for i = admin_chat_lines.lines.v, 1, -1 do
			if i ~= 1 then
				ac_no_saved.chat_lines[i] = ac_no_saved.chat_lines[i-1]
			else
				ac_no_saved.chat_lines[i] = lc_text_chat
			end
		end
		return false
	end		

    if lem.toggle.anticheat.v and text:sub(1,13) == '<AC-WARNING>' then
		ac_string = text
		for i = lem.ac.line.v, 1, -1 do 
			if i ~= 1 then
				warn_no_saved.str_lines[i] = warn_no_saved.str_lines[i-1]
			else
				warn_no_saved.str_lines[i] = ac_string
			end
		end	
		return false
	end	
end    

function main()
    while not isSampAvailable() do wait(0) end
    
    admin_chat = lua_thread.create_suspended(drawAdminChat)

    loadAdminChat()
	admin_chat:run()

    an_tag = tag .. ' Anti-Cheat: '
    font_warn = renderCreateFont("Arial", 11, font_admin_chat.BOLD)
    lua_thread.create(function()
		while true do

			
			if lem.toggle.anticheat.v then 
				for i = lem.ac.line.v, 1, -1 do 
					if warn_no_saved.str_lines[i] == nil then
						warn_no_saved.str_lines[i] = " "
					end
					renderFontDrawText(font_warn, an_tag, lem.ac.X-5, lem.ac.Y-5, 0xCCFFFFFF)
					renderFontDrawText(font_warn, warn_no_saved.str_lines[i], lem.ac.X, lem.ac.Y + i*10, 0xCCFFFFFF)
				end
			end 
			wait(1)
		end
	end)

    while true do
        wait(0)

        if warn_no_saved.pos then
			change_warn()
		end

        if ac_no_saved.pos then
			change_adm_chat()
		end
    end
end

function change_warn()
	if isKeyJustPressed(VK_RBUTTON) then
		len.ac.X = ac_no_saved.X
		lem.ac.Y = ac_no_saved.Y
		warn_no_saved.pos = false
	elseif isKeyJustPressed(VK_LBUTTON) then
		warn_no_saved.pos = false
	else
		lem.ac.X, lem.ac.Y = getCursorPos()
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
			--x - renderGetFontDrawTextLength(font, text) / 2
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

-- function imgui.OnDrawFrame()

--     imgui.ShowCursor = check_mouse

--     if not ATre_menu.v then 
--         imgui.Process = false 
--     end    

    
-- end 

function EXPORTS.ActiveATChat()
    imgui.BeginChild('##AdminChat', imgui.ImVec2(230, 240), false)
    imgui.Text(fa.ICON_TELEGRAM .. u8" �����.���")
    imgui.SameLine()
    if imgui.ToggleButton('##AdminChat', lem.toggle.adminchat) then 
        plre.sett.adminchat = lem.toggle.adminchat.v
    end	
    imgui.Separator()
    if imgui.Button(u8'��������� ����') then
        ac_no_saved.X = admin_chat_lines.X; ac_no_saved.Y = admin_chat_lines.Y
        ac_no_saved.pos = true
    end
    imgui.Text(u8'������������ ����.')
    imgui.Combo("##Position", admin_chat_lines.centered, {u8"�� ����� ����.", u8"�� ������.", u8"�� ������ ����."})
    imgui.PushItemWidth(50)
    imgui.Text(u8'������ ������')
    if imgui.SliderInt("##sizeAcFont", lem.int.adminFont, 10, 20) then
        font_ac = renderCreateFont("Arial", tonumber(lem.int.adminFont.v), font_admin_chat.BOLD + font_admin_chat.SHADOW)
        plre.achat.Font = lem.int.adminFont.v
        save()
    end	
    imgui.PopItemWidth()
    imgui.Text(u8'��������� ���� � ������.')
    imgui.Combo("##Pos", admin_chat_lines.nick, {u8"������.", u8"�����."})
    imgui.Text(u8'���������� �����.')
    imgui.PushItemWidth(80)
    imgui.InputInt(' ', admin_chat_lines.lines)
    imgui.PopItemWidth()
    if imgui.Button(u8'���������.') then
        showNotification("Save Admin-Chat", "��������� ����������������� \n���� ���������")
        saveAdminChat()
    end
    imgui.EndChild()
end    

function EXPORTS.ActiveWarn()
    imgui.BeginChild("##Warnings", imgui.ImVec2(200,150), false)
    imgui.Text(fa.ICON_MINUS  .. u8" ���������� �������")
    imgui.SameLine()
    if imgui.ToggleButton("##Anti_Cheat", lem.toggle.anticheat) then 
        plre.sett.anticheat = lem.toggle.anticheat.v 
        save() 
    end	
    imgui.Separator()
    if imgui.Button(u8"��������� �����") then 
        warn_no_saved.X = lem.ac.X; warn_no_saved.Y = lem.ac.Y
        warn_no_saved.pos = true
    end 
    imgui.Text(u8'���������� �����.')
    imgui.PushItemWidth(80)
    imgui.InputInt(' ', lem.ac.line)
    imgui.PopItemWidth()

    if imgui.Button(u8"���������") then 
        plre.acwarn.X = lem.ac.X
        plre.acwarn.Y = lem.ac.Y
        plre.acwarn.lines = lem.ac.line.v

        save()
        showNotification("AdminTool - Save Settings", "��������� ��������� �������")
    end	
    imgui.EndChild()	
end    

function EXPORTS.OffScript()
	imgui.ShowCursor = false
	thisScript():unload()
end