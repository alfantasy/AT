require 'lib.moonloader'
local encoding = require 'encoding' -- ���������� ��������
local inicfg = require 'inicfg' -- ������ � ini
local sampev = require "lib.samp.events" -- ����������� �������� ���������, ��������� � ������� ������� ������� SA:MP, � �� ������ ���������� � LUA
local imgui = require 'imgui' -- ������� imgui ����
local lib_a	= import 'lib/libsfor.lua'
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
------- ����������� ���� ������ ��������� -----------

function showNotification(handle, text_not)
	lib_a.addNotify("{87CEEB}" .. handle, text_not, 2, 1, 6)
end

local directIni = "AdminTool\\cfgmute.ini"

local fa = require 'faicons'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
	if fa_font == nil then  
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
end 	

function getMyNick()
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        local nick = sampGetPlayerNickname(id)
        return nick
    end
end

imgui.ToggleButton = require('imgui_addons').ToggleButton

local cfg = inicfg.load({
    settings = {
        automute_mat = false,
        automute_osk = false,
        automute_rod = false,
        automute_upom = false,
        mp_tp = false,
        admin_state = false,
        show_transparency = false,
        color1 = "{FFFFFF}",
        color2 = "{FFFFFF}",
        color3 = "{FFFFFF}",
        color4 = "{FFFFFF}",
        color5 = "{FFFFFF}",
        color6 = "{FFFFFF}",
        color6 = "{FFFFFF}",
        color7 = "{FFFFFF}",
        color8 = "{FFFFFF}",
        color9 = "{FFFFFF}",
        color10 = "{FFFFFF}",
        color11 = "{FFFFFF}",
        color12 = "{FFFFFF}",
        color13 = "{FFFFFF}",
        color14 = "{FFFFFF}",
        color15 = "{FFFFFF}",
        color16 = "{FFFFFF}",
        posX = 1000,
        posY = 800,
        show_mute_day = false,
        show_mute_now = false,
        show_report_day = false,
        show_report_now = false,
        show_jail_day = false,
        show_jail_now = false,
        show_ban_day = false,
        show_ban_now = false,
        show_kick_day = false,
        show_kick_now = false,
        show_online_day = false,
        show_online_now = false,
        show_afk_day = false,
        show_afk_now = false,
        show_nick_id = false, 
        show_time = false, 
    },
	static = {
		dayReport = 0,
		dayTime = 1,
		today = os.date("%a"),
		online = 0,
		afk = 0,
		full = 0,
        dayMute = 0,
        dayJail = 0,
        dayBan = 0,
        dayKick = 0,
	}
}, directIni)
inicfg.save(cfg, directIni)

local changePosition = false
local sessionOnline = imgui.ImInt(0)
local sessionAfk = imgui.ImInt(0)
local sessionFull = imgui.ImInt(0)
local dayFull = imgui.ImInt(cfg.static.full)
local nowTime = os.date("%H:%M:%S", os.time())
local LsessionReport = 0
local LsessionMute = 0 
local LsessionBan = 0 
local LsessionKick = 0 
local LsessionJail = 0 

local ini = {
    textrule = imgui.ImBuffer(65536),
    admin_state = imgui.ImBool(cfg.settings.admin_state),
    mp_tp = imgui.ImBool(cfg.settings.mp_tp),
    automute_mat = imgui.ImBool(cfg.settings.automute_mat),
    automute_osk = imgui.ImBool(cfg.settings.automute_osk),
    automute_rod = imgui.ImBool(cfg.settings.automute_rod),
    automute_upom = imgui.ImBool(cfg.settings.automute_upom),
    color1 = imgui.ImBuffer(tostring(cfg.settings.color1), 50),
    color2 = imgui.ImBuffer(tostring(cfg.settings.color2), 50),
    color3 = imgui.ImBuffer(tostring(cfg.settings.color3), 50),
    color4 = imgui.ImBuffer(tostring(cfg.settings.color4), 50),
    color5 = imgui.ImBuffer(tostring(cfg.settings.color5), 50),
    color6 = imgui.ImBuffer(tostring(cfg.settings.color6), 50),
    color7 = imgui.ImBuffer(tostring(cfg.settings.color7), 50),
    color8 = imgui.ImBuffer(tostring(cfg.settings.color8), 50),
    color9 = imgui.ImBuffer(tostring(cfg.settings.color9), 50),
    color10 = imgui.ImBuffer(tostring(cfg.settings.color10), 50),
    color11 = imgui.ImBuffer(tostring(cfg.settings.color11), 50),
    color12 = imgui.ImBuffer(tostring(cfg.settings.color12), 50),
    color13 = imgui.ImBuffer(tostring(cfg.settings.color13), 50),
    color14 = imgui.ImBuffer(tostring(cfg.settings.color14), 50),
    color15 = imgui.ImBuffer(tostring(cfg.settings.color15), 50),
    color16 = imgui.ImBuffer(tostring(cfg.settings.color16), 50),
    open_mp = imgui.ImBuffer(516), 
    set_dt = imgui.ImBuffer(500),
    mp_prize = imgui.ImBuffer(524),
    show_mute_day = imgui.ImBool(cfg.settings.show_mute_day), 
    show_mute_now = imgui.ImBool(cfg.settings.show_mute_now),
    show_ban_day = imgui.ImBool(cfg.settings.show_ban_day), 
    show_ban_now = imgui.ImBool(cfg.settings.show_ban_now),
    show_jail_day = imgui.ImBool(cfg.settings.show_jail_day), 
    show_jail_now = imgui.ImBool(cfg.settings.show_jail_now),
    show_kick_day = imgui.ImBool(cfg.settings.show_kick_day), 
    show_kick_now = imgui.ImBool(cfg.settings.show_kick_now),
    show_nick_id = imgui.ImBool(cfg.settings.show_nick_id), 
    show_afk_day = imgui.ImBool(cfg.settings.show_afk_day), 
    show_afk_now = imgui.ImBool(cfg.settings.show_afk_now),
    show_online_day = imgui.ImBool(cfg.settings.show_online_day), 
    show_online_now = imgui.ImBool(cfg.settings.show_online_now),
    show_report_day = imgui.ImBool(cfg.settings.show_report_day), 
    show_report_now = imgui.ImBool(cfg.settings.show_report_now),
    show_time = imgui.ImBool(cfg.settings.show_time),
    show_transparency = imgui.ImBool(cfg.settings.show_transparency)
}

local onscene = { "�����", "����", "���", "�����" } -- �������� ����� ����
local control_onscene = false -- ��������������� ����� ����
------ ��������� ��������� ����������, ���������� �� ������� ----------

local sw, sh = getScreenResolution() -- �������� �� �������������� ����� � ������ ����.

imgui.CenterText = require('imgui_addons').CenterText

local onscene_2 = { "����", "���", "������", "�����" }
local ph_rod = { 
    "���� ����", "mq", "���� � ������", "���� ���� �����", "���� ��� �����", "mqq", "mmq", 'mmqq', "matb v kanave",
}
local neosk = { "� ���" }
local control_onscene_1 = false
local control_onscene_2 = false

local ph_upom = {
    "�������", "russian roleplay", "evolve", "������"
}

local automute_settings = {
    input_phrase = imgui.ImBuffer(500),
    input_mute = imgui.ImBool(false),
    input_osk = imgui.ImBool(false),
    input_upom = imgui.ImBool(false),
    input_rod = imgui.ImBool(false),
    show_file_mute = imgui.ImBool(false),
    show_file_osk = imgui.ImBool(false), 
    show_file_upom = imgui.ImBool(false), 
    show_file_rod = imgui.ImBool(false),
    stream = imgui.ImBuffer(50000)
}


function check_file_mute()
    local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "r"))
    local t = file_check:read("*all")
    file_check:close() 
        return t
end

function check_file_osk()
    local file_check1 = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "r"))
    local t1 = file_check1:read("*all")
    file_check1:close() 
        return t1
end

function check_file_upom()
    local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "r"))
    local t = file_check:read("*all")
    file_check:close() 
        return t
end

function check_file_rod()
    local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "r"))
    local t = file_check:read("*all")
    file_check:close() 
        return t
end

function checkMessage(msg, arg)
    if arg == 1 then 
        if msg ~= nil then  
            for i, ph in ipairs(ph_rod) do  
                if string.find(msg, ph, 1, true) then  
                    return true, ph 
                end  
            end  
        end
    elseif arg == 2 then  
        if msg ~= nil then  
            for i, ph in ipairs(ph_upom) do  
                if string.find(msg, ph, 1, true) then  
                    return true, ph 
                end 
            end 
        end
    elseif arg == 3 then  
        if msg ~= nil then  
            for i, ph in ipairs(onscene_2) do  
                nmsg = string.split(msg, " ")
                for j, word in ipairs(nmsg) do  
                    if ph == string.rlower(word) then
                        return true, ph  
                    end  
                end
            end  
        end  
    elseif arg == 4 then  
        if msg ~= nil then  
            for i, ph in ipairs(onscene) do  
                nmsg = string.split(msg, " ")
                for j, word in ipairs(nmsg) do  
                    if ph == string.rlower(word) then
                        return true, ph  
                    end  
                end
            end  
        end
    end
end

function save() 
    inicfg.save(cfg, directIni)
end

local cjson = require"cjson"
local effil = require"effil"

local control_recon = false
local chip = false

local russian_characters = {
    [168] = '�', [184] = '�', [192] = '�', [193] = '�', [194] = '�', [195] = '�', [196] = '�', [197] = '�', [198] = '�', [199] = '�', [200] = '�', [201] = '�', [202] = '�', [203] = '�', [204] = '�', [205] = '�', [206] = '�', [207] = '�', [208] = '�', [209] = '�', [210] = '�', [211] = '�', [212] = '�', [213] = '�', [214] = '�', [215] = '�', [216] = '�', [217] = '�', [218] = '�', [219] = '�', [220] = '�', [221] = '�', [222] = '�', [223] = '�', [224] = '�', [225] = '�', [226] = '�', [227] = '�', [228] = '�', [229] = '�', [230] = '�', [231] = '�', [232] = '�', [233] = '�', [234] = '�', [235] = '�', [236] = '�', [237] = '�', [238] = '�', [239] = '�', [240] = '�', [241] = '�', [242] = '�', [243] = '�', [244] = '�', [245] = '�', [246] = '�', [247] = '�', [248] = '�', [249] = '�', [250] = '�', [251] = '�', [252] = '�', [253] = '�', [254] = '�', [255] = '�',
} 

local tag = "{00BFFF} [AM]" 

function asyncHttpRequest(method, url, args, resolve, reject)
	local request_thread = effil.thread(function(method, url, args)
		local requests = require"requests"
		local result, response = pcall(requests.request, method, url, args)
		if result then
			response.json, response.xml = nil, nil
			return true, response
		else
			return false, response
		end
	end)(method, url, args)

	if not resolve then
		resolve = function() end
	end
	if not reject then
		reject = function() end
	end
	lua_thread.create(function()
		local runner = request_thread
		while true do
			local status, err = runner:status()
			if not err then
				if status == "completed" then
					local result, response = runner:get()
					if result then
						resolve(response)
					else
						reject(response)
					end
					return
				elseif status == "canceled" then
					return reject(status)
				end
			else
				return reject(err)
			end
			wait(0)
		end
	end)
end

function distance_cord(lat1, lon1, lat2, lon2)
	if lat1 == nil or lon1 == nil or lat2 == nil or lon2 == nil or lat1 == "" or lon1 == "" or lat2 == "" or lon2 == "" then
		return 0
	end
	local dlat = math.rad(lat2 - lat1)
	local dlon = math.rad(lon2 - lon1)
	local sin_dlat = math.sin(dlat / 2)
	local sin_dlon = math.sin(dlon / 2)
	local a =
		sin_dlat * sin_dlat + math.cos(math.rad(lat1)) * math.cos(
			math.rad(lat2)
		) * sin_dlon * sin_dlon
	local c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
	local d = 6378 * c
	return d
end

function sampev.onDisplayGameText(style, time, text)
    if string.match(text, "~w~RECON ~r~OFF") then  
        --sampAddChatMessage("Recon Off")
        control_recon = false
    end
end

function sampev.onServerMessage(color, text)
	if chip and text:find("%[(.+)%] IP:") then
        local nick, ip2 = text:match("%[(.+)%] IP: (.+) | IP")
        ip1 = ip2
        return true
    end

    if text:find("�� ���������� ��") then  
        --sampAddChatMessage("Recon On", -1)
        control_recon = true         
    end

	local _, check_mat_id, _, check_mat = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
	local _, check_osk_id, _, check_osk = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")

    local hasForbiddenText, forbiddenText = checkMessage(check_osk, 1) 
    local hasForbiddenText_upom, forbiddenText_upom = checkMessage(check_osk, 2)

    if text:find('%[.*%] '..getMyNick()..'%['..getMyId()..'%] ������� (.*)%[(%d+)%]: (.*)') then 
		cfg.static.dayReport = cfg.static.dayReport + 1
		LsessionReport = LsessionReport + 1
		save()
		return true
	end	

    if text:find("������������� .+ �������%(.+%) ������ .+ �� .+ ������. �������: .+") then  
        amd_nick = text:match('������������� (.+) �������%(.+%) ������ .+ �� .+ ������. �������: .+') 
        if amd_nick:find(getMyNick()) then
            cfg.static.dayMute = cfg.static.dayMute + 1 
            LsessionMute = LsessionMute + 1 
            save()
        end
        return true 
    end 

    if text:find("������������� .+ �������%(.+%) ������ .+ � ������ �� .+ ������. �������: .+") then  
        amd_nick = text:match('������������� (.+) �������%(.+%) ������ .+ � ������ �� .+ ������. �������: .+') 
        if amd_nick:find(getMyNick()) then
            cfg.static.dayJail = cfg.static.dayJail + 1 
            LsessionJail = LsessionKick + 1 
            save()
        end 
        return true 
    end 
    
    if text:find("������������� .+ �������%(.+%) ������ .+ �� .+ ����. �������: .+") then  
        amd_nick = text:match('������������� (.+) �������%(.+%) ������ .+ �� .+ ����. �������: .+') 
        if amd_nick:find(getMyNick()) then
            cfg.static.dayBan = cfg.static.dayBan + 1 
            LsessionBan = LsessionBan + 1 
            save()
        end  
        return true 
    end 

    if text:find("������������� .+ ������ ������ .+. �������: .+") then  
        amd_nick = text:match('������������� (.+) ������ ������ .+. �������: .+') 
        if amd_nick:find(getMyNick()) then
            cfg.static.dayKick = cfg.static.dayKick + 1 
            LsessionKick = LsessionKick + 1 
            save()
        end 
        return true 
    end 

    if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then
        if text:find("������ (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)") then 
            local _, _, check_zb_id, check_zb = text:match("������ (.+) | {AFAFAF}(.+)%[(%d+)%]: (.+)")
            sampAddChatMessage(tag .. " ���� ������: " .. sampGetPlayerNickname(tonumber(check_zb_id)) .. "[" .. check_zb_id .."]: " .. check_zb)
            if ini.automute_osk.v or ini.automute_rod.v or ini.automute_upom.v or ini.automute_mat.v then  
                local osk_text, _ = checkMessage(check_zb, 3)
                local mat_text, _ = checkMessage(check_zb, 4)
                local ror_text, _ = checkMessage(check_zb, 1)
                local upom_text, _ = checkMessage(check_zb, 2)
                if osk_text and ini.automute_osk.v and control_recon == false then  
                    sampAddChatMessage(tag .. " ��������! �������� AutoMute! ���� ������� �������, �� ������� AT �������.")
                    sampAddChatMessage(tag .. " | " .. check_zb, -1)
                    sampAddChatMessage(tag .. " ================ AdminTool Loop Automute ==================")
                    sampSendChat("/rmute " .. check_zb_id .. " 400 �����������/��������")
                    showNotification("AutoMute", "��� ����������: " .. sampGetPlayerNickname(tonumber(check_zb_id)) .. "\n ������� �� �������: �����������/��������")
                end 
                if mat_text and ini.automute_mat.v and control_recon == false then  
                    sampAddChatMessage(tag .. " ��������! �������� AutoMute! ���� ������� �������, �� ������� AT �������.")
                    sampAddChatMessage(tag .. " | " .. check_zb, -1)
                    sampAddChatMessage(tag .. " ================ AdminTool Loop Automute ==================")
                    sampSendChat("/rmute " .. check_zb_id .. " 300 ����������� �������")
                    showNotification("AutoMute", "��� ����������: " .. sampGetPlayerNickname(tonumber(check_zb_id)) .. "\n ������� �� �������: ���")
                end
                if ror_text and ini.automute_rod.v and control_recon == false then 
                    sampAddChatMessage(tag .. " ��������! �������� AutoMute! ���� ������� �������, �� ������� AT �������.")
                    sampAddChatMessage(tag .. " | " .. check_zb, -1)
                    sampAddChatMessage(tag .. " ================ AdminTool Loop Automute ==================")
                    sampSendChat("/rmute " .. check_zb_id .. " 5000 �����������/�������� ������")
                    showNotification("AutoMute", "��� ����������: " .. sampGetPlayerNickname(tonumber(check_zb_id)) .. "\n ������� �� �������: ����������� ������")
                end
                if upom_text and ini.automute_upom.v and control_recon == false then  
                    sampAddChatMessage(tag .. " ��������! �������� AutoMute! ���� ������� �������, �� ������� AT �������.")
                    sampAddChatMessage(tag .. " | " .. check_zb, -1)
                    sampAddChatMessage(tag .. " ================ AdminTool Loop Automute ==================")
                    sampSendChat("/rmute " .. check_zb_id .. " 1000 ���������� ��������� ��������")
                    showNotification("AutoMute", "��� ����������: " .. sampGetPlayerNickname(tonumber(check_zb_id)) .. "\n ������� �� �������: ����.����.��������")
                end
            end
            return true  
        end
    end

    if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then
        if check_osk ~= nil and check_osk_id ~= nil and (ini.automute_mat.v or ini.automute_osk.v or ini.automute_rod.v or ini.automute_upom.v) then
            local string_os = string.split(check_osk, " ")
            for i, value in ipairs(onscene_2) do
                for j, val in ipairs(string_os) do
                    val = val:match("(%P+)")
                    if val ~= nil then
                        if value == string.rlower(val) and not check_osk:find(":�") and ini.automute_osk.v then
                            lua_thread.create(function()
                            sampAddChatMessage(tag .. " ��������! �������� AutoMute! ���� �������, �� ������� AT �������.")
                            sampAddChatMessage(tag .. " | " .. text, -1)
                            sampAddChatMessage(tag .. " ================ AdminTool Loop Automute ==================")
                                if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() and ini.automute_osk.v and control_recon == false then
                                    sampSendChat("/mute " .. check_osk_id .. " 400 " .. " �����������/��������.")
                                    showNotification("{87CEEdB}AdminTool", '����������� �����: {FFFFFF}' .. value .. '\n{FFFFFF}��� ����������: {FFFFFF}' .. sampGetPlayerNickname(tonumber(check_osk_id)))
                                end	
                            end)	
                        end
                    end
                end
            end
            for i, value in ipairs(onscene) do
                for j, val in ipairs(string_os) do
                    val = val:match("(%P+)")
                    if val ~= nil then
                        if value == string.rlower(val) and ini.automute_mat.v then
                            lua_thread.create(function()
                                sampAddChatMessage(tag .. " ��������! �������� AutoMute! ���� �������, �� ������� AT �������.")
                                sampAddChatMessage(tag .. " | " .. text, -1)
                                sampAddChatMessage(tag .. " ================ AdminTool Loop Automute ==================")
                                if not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() and ini.automute_mat.v and control_recon == false then
                                    sampSendChat("/mute " .. check_osk_id .. " 300 " .. " ����������� �������.")
                                    showNotification("AutoMute", "��� ����������: " .. sampGetPlayerNickname(tonumber(check_osk_id)) .. "\n ����������� �����: " .. value)
                                end
                            end)	
                        end
                    end
                end
            end
            if hasForbiddenText and ini.automute_rod.v and control_recon == false and not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground() then 
                sampAddChatMessage(tag .. " ��������! �������� AutoMute! ���� �������, �� ������� AT �������.")
                sampAddChatMessage(tag .. " | " .. text, -1)
                sampAddChatMessage(tag .. " ================ AdminTool Loop Automute ==================")
                sampSendChat("/mute " .. check_osk_id .. " 5000 �����������/�������� ������")
                showNotification("AutoMute", "��� ����������: " .. sampGetPlayerNickname(tonumber(check_osk_id)) .. "\n ������� �� �������: ����������� ������")
            end
            if hasForbiddenText_upom and ini.automute_upom.v and control_recon == false and not isGamePaused() and not isPauseMenuActive() and isGameWindowForeground()then  
                sampAddChatMessage(tag .. " ��������! �������� AutoMute! ���� �������, �� ������� AT �������.")
                sampAddChatMessage(tag .. " | " .. text, -1)
                sampAddChatMessage(tag .. " ================ AdminTool Loop Automute ==================")
                sampSendChat("/mute " .. check_osk_id .. " 1000 ���������� ��������� ��������")
                showNotification("AutoMute", "��� ����������: " .. sampGetPlayerNickname(tonumber(check_osk_id)) .. "\n ������� �� �������: ����.����.��������")
            end
            return true
        end
    end

end    

function main()
    while not isSampAvailable() do wait(0) end
	
    if not io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "r") then  
        file = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "w")
        for _, v in ipairs(ph_rod) do 
            file:write(v)
        end
        file:close()
    end

    local file_read_rod, c_line_rod = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", 'r'), 1

    if file_read_rod ~= nil then  
        file_read_rod:seek("set", 0)
        for line in file_read_rod:lines() do  
            ph_rod[c_line_rod] = line  
            c_line_rod = c_line_rod + 1 
        end  
        file_read_rod:close()
    end 

    sampRegisterChatCommand("s_rod", function(param)
        if param == nil then  
            return false 
        end 
        for _, val in ipairs(ph_rod) do 
            if string.rlower(param) == val then  
                sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ���� ����������� ������.")
                return false 
            end 
        end 
        local file_write_rod, c_line_rod = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "w"), 1
        ph_rod[#ph_rod + 1] = string.rlower(param)
        for _, val in ipairs(ph_rod) do 
            file_write_rod:write(val .. "\n")
        end 
        file_write_rod:close() 
        sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ������� ��������� � ������ ���� ����������� ������")
    end)

    sampRegisterChatCommand('d_rod', function(param)
		local file_write_rod, c_line_rod = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "w"), 1
		if param == nil then
			return false
		end
        local file_write_rod, c_line_rod = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "w"), 1
		for i, val in ipairs(ph_rod) do
			if val == string.rlower(param) then
				ph_rod[i] = nil
				control_onscene_2 = true
			else
				file_write_rod:write(val .. "\n")
			end
		end
        file_write_rod:close()
		if control_onscene_2 then
			sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ���� ������� ������� �� ������ ���� ����������� ������")
			control_onscene_2 = false
		else
			sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ��� � ������ ���� ����������� ������")
		end
	end)

    if not io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "r") then  
        file = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "w")
        for _, v in ipairs(ph_upom) do 
            file:write(v)
        end
        file:close()
    end

    local file_read_upom, c_line_upom = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "r"), -1

    if file_read_upom ~= nil then
		file_read_upom:seek("set", 0)
		for line in file_read_upom:lines() do
			ph_upom[c_line_upom] = line
			c_line_upom = c_line_upom + 1
		end
		file_read_upom:close()
	end

    sampRegisterChatCommand("s_upom", function(param)
        if param == nil then  
            return false 
        end 
        for _, val in ipairs(ph_upom) do 
            if string.rlower(param) == val then  
                sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ���� ���������� ��������� ��������.")
                return false 
            end 
        end 
        local file_read_upom, c_line_upom = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "w"), 1
        ph_upom[#ph_upom + 1] = string.rlower(param)
        for _, val in ipairs(ph_upom) do 
            file_read_upom:write(val .. "\n")
        end 
        file_read_upom:close() 
        sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ������� ��������� � ������ ���� ���������� ��������� ��������.")
    end)

    sampRegisterChatCommand('d_upom', function(param)
		local file_read_upom, c_line_upom = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "w"), 1
		if param == nil then
			return false
		end
        local file_read_upom, c_line_upom = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "w"), 1
		for i, val in ipairs(ph_upom) do
			if val == string.rlower(param) then
				ph_upom[i] = nil
				control_onscene_2 = true
			else
				file_read_upom:write(val .. "\n")
			end
		end
        file_read_upom:close()
		if control_onscene_2 then
			sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ���� ������� ������� �� ������ ���� ���������� ��������� ��������.")
			control_onscene_2 = false
		else
			sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ��� � ������ ���� ���������� ��������� ��������.")
		end
	end)

    local file_read_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "r"), 1

	if file_read_1 ~= nil then
		file_read_1:seek("set", 0)
		for line in file_read_1:lines() do
			onscene_2[c_line_1] = line
			c_line_1 = c_line_1 + 1
		end
		file_read_1:close()
	end

	sampRegisterChatCommand("chip", chip)

    sampRegisterChatCommand('s_osk', function(param)
		if param == nil then
			return false
		end
		for _, val in ipairs(onscene_2) do
			if string.rlower(param) == val then
				sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ �����������/��������.")
				return false
			end
		end
        local file_write_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
		onscene_2[#onscene_2 + 1] = string.rlower(param)
		for _, val in ipairs(onscene_2) do
			file_write_1:write(val .. "\n")
		end
		file_write_1:close()
		sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ������� ��������� � ������ �����������/��������.")
	end)

    sampRegisterChatCommand('d_osk', function(param)
		local file_write_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
		if param == nil then
			return false
		end
        local file_write_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
		for i, val in ipairs(onscene_2) do
			if val == string.rlower(param) then
				onscene_2[i] = nil
				control_onscene_2 = true
			else
				file_write_1:write(val .. "\n")
			end
		end
        file_write_1:close()
		if control_onscene_2 then
			sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ���� ������� ������� �� ������ �����������/��������.")
			control_onscene_2 = false
		else
			sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ��� � ������ �����������/��������.")
		end
	end)

    local file_read, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "r"), 1
	if file_read ~= nil then
		file_read:seek("set", 0)
		for line in file_read:lines() do
			onscene[c_line] = line
			c_line = c_line + 1
		end
		file_read:close()
	end
	-- ������ �����

	sampRegisterChatCommand('s_mat', function(param) -- ���������� ����
		if param == nil then
			return false
		end
		for _, val in ipairs(onscene) do
			if string.rlower(param) == val then
				sampAddChatMessage(tag .. " ����� \"" .. val .. "\" ��� ������������ � ������ ����������� �����.")
				return false
			end
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
		onscene[#onscene + 1] = string.rlower(param)
		for _, val in ipairs(onscene) do
			file_write:write(val .. "\n")
		end
		file_write:close()
		sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ������� ��������� � ������ ����������� �������.")
	end)
	sampRegisterChatCommand('d_mat', function(param) -- �������� ����
		if param == nil then
			return false
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
		for i, val in ipairs(onscene) do
			if val == string.rlower(param) then
				onscene[i] = nil
				control_onscene = true
			else
				file_write:write(val .. "\n")
			end
		end
		file_write:close()
		if control_onscene then
			sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ���� ������� ������� �� ������ ����������� �����.")
			control_onscene = false
		else
			sampAddChatMessage(tag .. " ����� \"" .. string.rlower(param) .. "\" ��� � ������ ������������.")
		end
	end)

    if cfg.static.today ~= os.date("%a") then 
		cfg.static.today = os.date("%a")
		cfg.static.online = 0
        cfg.static.full = 0
		cfg.static.afk = 0
		cfg.static.dayReport = 0
        cfg.static.dayKick = 0 
        cfg.static.dayBan = 0  
        cfg.static.dayJail = 0 
        cfg.static.dayMute = 0 
	  	dayFull.v = 0
		save()
    end

    lua_thread.create(time)

    while true do
        wait(0)

        imgui.Process = true

        if not ini.admin_state.v then 
            ini.admin_state.v = false
            imgui.ShowCursor = false  
            imgui.Process = false
        end    

        
        isPos()
    end
end

function chip(cl)
	ips = {}
	for word in string.gmatch(cl, "(%d+%p%d+%p%d+%p%d+)") do
		table.insert(ips, { query = word })
	end
	if #ips > 0 then
		data_json = cjson.encode(ips)
		asyncHttpRequest(
			"POST",
			"http://ip-api.com/batch?fields=25305&lang=ru",
			{ data = data_json },
			function(response)
				local rdata = cjson.decode(u8:decode(response.text))
				local text = ""
				for i = 1, #rdata do
					if rdata[i]["status"] == "success" then
						local distances =
							distance_cord(
								rdata[1]["lat"],
								rdata[1]["lon"],
								rdata[i]["lat"],
								rdata[i]["lon"]
							)
						text =
							text .. string.format(
								"\n{FFF500}IP - {FF0400}%s\n{FFF500}������ -{FF0400} %s\n{FFF500}����� -{FF0400} %s\n{FFF500}��������� -{FF0400} %s\n{FFF500}��������� -{FF0400} %d  \n\n",
								rdata[i]["query"],
								rdata[i]["country"],
								rdata[i]["city"],
								rdata[i]["isp"],
								distances
							)
               end
				end
				if text == "" then
					text = " \n\t{FFF500}������ �� �������"
				end
				showdialog("���������� � IP", text)
			end,
			function(err)
				showdialog("���������� � IP", "��������� ������ \n" .. err)
			end
		)
	end
end

function showdialog(name, rdata)
	sampShowDialog(
		math.random(1000),
		"{FF4444}" .. name,
		rdata,
		"�������",
		false,
		0
	)
end

function string.rlower(s)
    s = s:lower()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:lower()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 192 and ch <= 223 then -- upper russian characters
            output = output .. russian_characters[ch + 32]
        elseif ch == 168 then -- �
            output = output .. russian_characters[184]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function string.rupper(s)
    s = s:upper()
    local strlen = s:len()
    if strlen == 0 then return s end
    s = s:upper()
    local output = ''
    for i = 1, strlen do
        local ch = s:byte(i)
        if ch >= 224 and ch <= 255 then -- lower russian characters
            output = output .. russian_characters[ch - 32]
        elseif ch == 184 then -- �
            output = output .. russian_characters[168]
        else
            output = output .. string.char(ch)
        end
    end
    return output
end

function string.split(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end

function getMyId()
    local result, id = sampGetPlayerIdByCharHandle(playerPed)
    if result then
        return id
    end
end

function get_clock(time)
    local timezone_offset = 86400 - os.date('%H', 0) * 3600
    if tonumber(time) >= 86400 then onDay = true else onDay = false end
    return os.date((onDay and math.floor(time / 86400)..'� ' or '')..'%H:%M:%S', time + timezone_offset)
end

function time()
	startTime = os.time()
    while true do
        wait(1000)
        nowTime = os.date("%H:%M:%S", os.time()) 
        if sampGetGamestate() == 3 then 								
	        			
	        sessionOnline.v = sessionOnline.v + 1 							
	        sessionFull.v = os.time() - startTime 					
	        sessionAfk.v = sessionFull.v - sessionOnline.v		
			
			cfg.static.online = cfg.static.online + 1 				
	        cfg.static.full = dayFull.v + sessionFull.v 						
			cfg.static.afk = cfg.static.full - cfg.static.online

	    else
	    	startTime = startTime + 1
	    end
    end
end

function isPos() 
	if changePosition then
        showCursor(true, false)
        local mouseX, mouseY = getCursorPos()
        cfg.settings.posX, cfg.settings.posY = mouseX, mouseY
        if isKeyJustPressed(49) then
            showCursor(false, false)
            showNotification(tag, "������� ���������")
            changePosition = false
            save()
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

function EXPORTS.ActiveAutoMute()
    imgui.Text(fa.ICON_NEWSPAPER_O .. u8" �������")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
    if imgui.Button(u8"On/Off") then  
        imgui.OpenPopup('settingautomute')
    end    
    if imgui.BeginPopup('settingautomute') then  
        if imgui.ToggleButton(u8" ������� �� ��� ", ini.automute_mat) then 
            cfg.settings.automute_mat = ini.automute_mat.v 
            save() 
        end	
        if imgui.ToggleButton(u8" ������� �� ��� ", ini.automute_osk) then 
            cfg.settings.automute_osk = ini.automute_osk.v 
            save() 
        end	
        if imgui.ToggleButton(u8' ������� �� ��� ������', ini.automute_rod) then  
            cfg.settings.automute_rod = ini.automute_rod.v  
            save()
        end
        if imgui.ToggleButton(u8' ������� �� ����.����.��������', ini.automute_upom) then  
            cfg.settings.automute_upom = ini.automute_upom.v  
            save()
        end
        imgui.EndPopup()
    end    
end

function EXPORTS.ActiveMP()
    imgui.Text(u8"������ ������ ���������� ���������� ��������� � /mess �����.")
    imgui.Text(u8"�������� ����������, ���� ���� ���, ������ ��� ������� �� ���.")
    imgui.Text(u8"���� ������ ���� ������� ��������, ������ ������ � ������ ��.")
    imgui.Text(u8"��� �������� ��������� ������������ ������� /mp")
    imgui.Text(u8"/jm - jail �� ��������� ������ �����������.")
    imgui.Text(u8"Swat Tank - 601 ID, Shamal - 519 ID, ������� - 532 ID") 
    imgui.Text(u8"����� ���������� ������, ������� /veh ID 1 1")
    imgui.Text(u8"������� ��� ���������, �� ������ ����������� ����")
    imgui.Separator()
    x, y, z = getCharCoordinates(PLAYER_PED)
    imgui.Text(u8"���� ���������� X: " .. x .. " | Y: " .. y .. " | Z " .. z)
    imgui.Separator()
    if imgui.Button(u8"�������� �����", imgui.ImVec2(120,0)) then 
        imgui.OpenPopup('toolmp')
    end	
    imgui.SameLine()
    if imgui.Button(u8"������� ���� ��", imgui.ImVec2(200,0)) then 
        imgui.OpenPopup(u8'�������� ������ �����������')
    end	 
    if imgui.Button(u8"������������� �����������", imgui.ImVec2(300,0)) then 
        imgui.OpenPopup('zagmp') 
    end 
    imgui.Separator()
    imgui.Text("  ")
    imgui.CenterText(u8"�������� �����������")
    if imgui.CollapsingHeader(u8"������") then 
        imgui.Text(u8"������������� ���������� �����. �������������� �������.")
        imgui.Text(u8"���� �����������. ������������� �������� ������")
        imgui.Text(u8"������������� ������ � ��������� � ������� �������, ���� ������")
        imgui.Text(u8"���, ��� �������� ��������� - ���������")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"������ �����") then
        imgui.Text(u8"���������� �����, �������������� ������� ����.")
        imgui.Text(u8"������ ��������������� ��������, ����� Desert Eagle.")
        imgui.Text(u8"������������� �������� ���� ������� ������ �����")
        imgui.Text(u8"���������� - ��������, ���������� - ��������.")
        imgui.Text(u8"���������� � ��������� ������ �������� ����")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"������� �������") then  
        imgui.Text(u8"�������� �����, �������������� �������")
        imgui.Text(u8"������������� ����� �������, � ���������� ������� �������")
        imgui.Text(u8'��� �������� � ������� ������� "/try ����"')
        imgui.Text(u8'���� "������" - ����� ��������. ���� "��������" - ���')
        imgui.Text(u8'���, ��� �������� ��������� ���������')
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"������ ������") then  
        imgui.Text(u8"������� �������� �����, �������������� �������")
        imgui.Text(u8"������������� ������� ������� Shamal")
        imgui.Text(u8"������ ����������� �� ������ ��������")
        imgui.Text(u8"������������� �������� ����� � �����")
        imgui.Text(u8"���, ��� ��������� ��������� �� �������� ���������")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"���������") then  
        imgui.Text(u8"������������� ��������� � ������ ���������")
        imgui.Text(u8"��� ��������, ������������ �� ��������")
        imgui.Text(u8"����� = 1 ����. ���, ��� ������ 5 ������ - ����������")
        imgui.Text(u8"����� �������� ����� �������. ����, ���� ��� �� ��������� � �����")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"���������") then  
        imgui.Text(u8"�������� �����, ������������� ������������ �������")
        imgui.Text(u8"�� ������� Swat Tank, � �������� �������� �������")
        imgui.Text(u8"���������, ��� ������� �� ��������� - ����������")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"���� ��� ����") then  
        imgui.Text(u8"�������� �����, �������������� �������. \n������������� ������� ������� �� ��������")
        imgui.Text(u8"���, ��� ������� ��������� - �������")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"��������������� ��") then  
        imgui.Text(u8"�������� �����, �������������� �������� �������")
        imgui.Text(u8"�� ����� �� ����������� �������� ������� (/object)")
        imgui.Text(u8"������� ������, � ���������� �������� � ������� 10 �����")
        imgui.Text(u8"��� ������� �������, ����� ������ �� ������ ��� �����������")
        imgui.Text(u8"������� �������! ����� ����������� ������� �������")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"���� �����") then  
        imgui.Text(u8"����������� � ������.. ���� �����, �� ����")
        imgui.Text(u8"�������������� �������, ������������ �����")
        imgui.Text(u8"������ �������� ����� � ��, �� ���..")
        imgui.Text(u8"�� �������� ��� ��������, � ��� �������� ���� - ������")
        imgui.Text(u8"������, ��� ������� �������, ��� ������� �����������")
        imgui.Text(u8"���, ��� ������� ����� ����������.")
        imgui.Text(u8"��, ���������� �������� �����. ���� ����� = 1 ����")
        imgui.Text(u8"1 ���� - 1��.")
    end
    imgui.Separator()
    if imgui.CollapsingHeader(u8'������ ������') then 
        imgui.Text(u8"��� ��� ������, �����, �������")
        imgui.Text(u8"������������� ����� �������� (�����, �� ���.NRG-500)")
        imgui.Text(u8"������ �� � ���� ������� ���� ����� ��������")
        imgui.Text(u8"� ������ ���� 30 ������, ����� ������")
        imgui.Text(u8"����� ������ ������� ������ � ������� ���� �������")
        imgui.Text(u8"��� ������� ��� ������ - ��� � �������")
    end	
    if imgui.BeginPopup('zagmp') then 
        if imgui.Button(u8'����������� "������"') then
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,-2315,1545,18)
                    wait(2500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������. �������� /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������. �������� /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 1, 2)
                    sampSendDialogResponse(16068, 1, 0, "0")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    wait(200)
                    sampSendDialogResponse(5344, 1, 0, "������")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������" ������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            else 	
                lua_thread.create(function()
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������. �������� /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������. �������� /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "������")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������" ������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end
        end
        if imgui.Button(u8'������� �� "������"') then
            lua_thread.create(function()
                sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
                wait(500)
                sampSendChat("/mess 6 ����� ��������� ������������ /anim � /jp")
                wait(500)
                sampSendChat("/mess 6 ������� �����, ������ � ��� ���� ������, ����� ����������")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "������ �����"') then
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,1753,2072,1955)
                    wait(2500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ �����. �������� /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ �����. �������� /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 1, 2)
                    sampSendDialogResponse(16068, 1, 0, "0")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    wait(200)
                    sampSendDialogResponse(5344, 1, 0, "��")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������ �����" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ �����. �������� /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ �����. �������� /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "��")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������ �����" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)	
            end
        end
        if imgui.Button(u8'������� �� "������ �����"') then
            lua_thread.create(function()
                sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
                wait(500)
                sampSendChat("/mess 6 � ���� �������� ����� �������, ����� ����� ������ �� ���� ������.")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "������� �������"') then
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,1973,-978,1371)
                    wait(2500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������� �������. �������� /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������� �������. �������� /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 1, 2)
                    sampSendDialogResponse(16068, 1, 0, "0")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "��")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������� �������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������� �������. �������� /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������� �������. �������� /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "��")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������� �������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)	
            end	
        end
        if imgui.Button(u8'������� �� "������� �������"') then
            lua_thread.create(function()
                sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
                wait(500)
                sampSendChat("/mess 6 � ���� ����������� � ������� ������� /try - ����. ������ - �����. �������� - ����.")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "���������"') then
            if ini.mp_tp.v then 
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,-2304,872,59)
                    wait(2500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ���������. ��������: /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ���������. ��������: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 1, 2)
                    sampSendDialogResponse(16068, 1, 0, "0")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "���������")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "���������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ���������. ��������: /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ���������. ��������: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "���������")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "���������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)	
            end	
        end
        if imgui.Button(u8'������� �� "���������"') then
            lua_thread.create(function()
                sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
                wait(500)
                sampSendChat("/mess 6 � ���� ������������ Swat Tank, � ���� ������� ��� � ���������� �����.")
                wait(500)
                sampSendChat("/mess 6 ���������, ��� �������� - ����������.")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "������ ������"') then
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,2027,-2434,13)
                    wait(2500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ ������. ��������: /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ ������. ��������: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 1, 2)
                    sampSendDialogResponse(16068, 1, 0, "0")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "������ ������")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������ ������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ ������. ��������: /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ������ ������. ��������: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "������ ������")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������ ������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end		
        end
        if imgui.Button(u8'������� �� "������ ������"') then
            lua_thread.create(function()
                sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
                wait(500)
                sampSendChat("/mess 6 � ���� ������������ ������� Shamal, � ���� ������ ������� �� ������")
                wait(500)
                sampSendChat("/mess 6 ���� ����������� ������ �� ������, � � ���� ��������� �����.")
                wait(500)
                sampSendChat("/mess 6 ���, ��� ��������� ��������� �� �������� - ����������")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "���������"') then
            lua_thread.create(function()
                sampSendChat("/mess 10 ��������� ������! �������� �����������: ���������! ��������� �� �����")
                wait(500)
                sampSendChat("/mess 10 ������, � ������� ������� ����, � ��, ��� ��������� �������, ��� � /pm +")
                showNotification("{87CEEB}[AdminTool]", '����������� "���������" \n��������\n�������� �������')
            end)
        end
        if imgui.Button(u8'������� �� "���������"') then
            lua_thread.create(function()
                sampSendChat("/mess 6 � ����� ������ �� ����� ���������, � ��� ������.")
                wait(500)
                sampSendChat("/mess 6 ������, ��� �������� - �������� ���� ����")
                wait(500)
                sampSendChat("/mess 6 ����� ������ - 5. ���������� ���������� ��� � /pm ������ +")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "���� ��� ����') then  
            if ini.mp_tp.v then 
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,1547,-1359,329)
                    wait(2500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ���� ��� ����. ��������: /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ���� ��� ����. ��������: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 1, 2)
                    sampSendDialogResponse(16068, 1, 0, "0")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "�����")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "���� ��� ����" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ���� ��� ����. ��������: /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: ���� ��� ����. ��������: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "�����")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "���� ��� ����" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)	
            end	
        end
        if imgui.Button(u8'������� �� "���� ��� ����"') then  
            lua_thread.create(function()
                sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
                wait(500)
                sampSendChat("/mess 6 � ���� ������������ �������. ��� ������ - ������ ���")
                wait(500)
                sampSendChat("/mess 6 ���� ������ - ����������� � �����, � ��������.")
                wait(500)
                sampSendChat("/mess 6 ���, ��� ����� ��������� - ����������")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "�����������"') then  
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,626,-1891,3)
                    wait(2500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: �����������. ��������: /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: �����������. ��������: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 1, 2)
                    sampSendDialogResponse(16068, 1, 0, "0")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "��������������� ��")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "�����������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: �����������. ��������: /tpmp")
                    wait(500)
                    sampSendChat("/mess 10 ��������� ������! �������� �����������: �����������. ��������: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "��������������� ��")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "�����������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end	
        end
        if imgui.Button(u8'������� �� "�����������"') then  
            lua_thread.create(function()
                sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s � ����. �� ���������.")
                wait(500)
                sampSendChat("/mess 6 � ��� ������ ����� �������, ������� �������. � ������� 10 �����..")
                wait(500)
                sampSendChat("/mess 6 ...�� �������� ����������! ���� ������ ����������� - ������� ������!")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "���� �����"') then  
            lua_thread.create(function()
                sampSendChat("/mess 10 ��������� ������! �������� �����������: ���� �����! ��������� �� �����")
                wait(500)
                sampSendChat("/mess 10 ������, � ������� ������� ����, � ��, ��� ��������� �������, ��� � /pm +")
                showNotification("{87CEEB}[AdminTool]", '����������� "���� �����" \n��������\n�������� �����')
            end)
        end
        if imgui.Button(u8'������� �� "���� �����"') then
            lua_thread.create(function()
                sampSendChat("/mess 6 � ��������� �����, ������ ��� ��������� ��������")  
                wait(500)
                sampSendChat("/mess 6 ���� ������ - ������� �����, ��������� �����")
                wait(500)
                sampSendChat("/mess 6 ���, ��� �������� ����� - ����������")
                wait(500)
                sampSendChat("/mess 6 ���� ����� = ���� ����. ���� ���� - 1�� ������.")
            end)
        end
        imgui.Separator()
        if imgui.Button(u8'����������� "������ ������"') then 
            if ini.mp_tp.v then 
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,526,-1724,12)
                    wait(2500)
                    sampSendChat('/mess 10 ��������� ������! �������� ����������� "������ ������". /tpmp')
                    wait(500)
                    sampSendChat('/mess 10 ��������� ������! �������� ����������� "������ ������". /tpmp')
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 1, 2)
                    sampSendDialogResponse(16068, 1, 0, "0")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "������ ������")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������ ������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            else 	
                lua_thread.create(function()
                    sampSendChat('/mess 10 ��������� ������! �������� ����������� "������ ������". /tpmp')
                    wait(500)
                    sampSendChat('/mess 10 ��������� ������! �������� ����������� "������ ������". /tpmp')
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "������ ������")
                    sampSendChat("/mess 10 �������� /tpmp, ������ ����� � ������� �������")
                    showNotification("{87CEEB}[AdminTool]", '����������� "������ ������" \n������� �������\n������������ �������')
                    wait(200)
                    sampCloseCurrentDialogWithButton(0)
                end)
            end	
        end	
        if imgui.Button(u8'������� �� "������ ������"') then 
            lua_thread.create(function()
                sampSendChat('/mess 6 �������: ��, ����� ����, /s, /r, /fly - ���������.')
                wait(500)
                sampSendChat('/mess 6 ��� ���������� ������� ������, ����� ��� � ������� �������')
                wait(500)
                sampSendChat('/mess 6 �����, ��������� ��� ������ - ���������. �������� ���� �� ����������')
            end)
        end	
    imgui.EndPopup()
    end	
    if imgui.BeginPopupModal(u8'�������� ������ �����������', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then 
        imgui.BeginChild("##CreateMP", imgui.ImVec2(600, 225), true)
        imgui.Text(u8"�������� ������ �����������: ")
        imgui.SameLine()
        imgui.InputText(u8'##OpenThisMP', ini.open_mp)
        imgui.Text(u8"����� ������������ ���� (/dt): ")
        imgui.SameLine()
        imgui.InputText(u8'##SetDT', ini.set_dt)
        imgui.Text(u8"���� ����� ������ ���� ������� ��� ��")
        imgui.Text(u8"������, ��� ������� ������ ����������, ���� ���� ������� ������ ����� ������")
        imgui.InputTextMultiline("##RuleText", ini.textrule, imgui.ImVec2(-1, 110))
        if imgui.Button(u8'�������/������� ��') then 
            sampSendChat("/mess 10 ��������� ������! �������� �����������: " .. u8:decode(ini.open_mp.v))
            wait(500)
            sampSendChat("/mess 10 ��������� ������! �������� �����������: " .. u8:decode(ini.open_mp.v))
            sampSendChat("/mp")
            sampSendDialogResponse(5343, 1, 14)
            sampSendDialogResponse(16066, 1, 0)
            sampSendDialogResponse(16066, 0, 0)
            sampSendDialogResponse(16066, 1, 1)
            if #ini.set_dt.v > 0 then
                sampSendDialogResponse(16067, 1, 0, ini.set_dt.v)
            else  
                sampSendDialogResponse(16067, 1, 0, "467")
            end 
            sampSendDialogResponse(16066, 1, 2)
            sampSendDialogResponse(16068, 1, 0, "0")
            sampSendDialogResponse(16066, 0, 0)
            sampSendDialogResponse(5343, 1, 0)
            sampSendDialogResponse(5344, 1, 0, u8:decode(ini.open_mp.v))
            sampSendChat("/mess 10 ����� ������� �� �����������, ������� /tpmp")
            showNotification("AdminTool - MP", "����������� ���� �������.")
            wait(200)
            sampCloseCurrentDialogWithButton(0)
        end
        imgui.SameLine()
        if imgui.Button(u8"������� ���� �������") then  
            local refresh_text = ini.textrule.v:gsub("\n", "~")
            lua_thread.create(function()
                for bp in refresh_text:gmatch('[^~]+') do
                    wait(500)
                    sampSendChat("/mess 6 " .. u8:decode(tostring(bp)))
                 end
            end)
            ini.textrule.v = ""
        end 
        imgui.Separator()
        if imgui.Button(u8'��������.�������') then  
            lua_thread.create(function()
                sampSendChat("/mess 6 �������: ������ ������������ /passive, /fly, /r - /s, ����, /flycar")
                wait(500)
                sampSendChat("/mess 6 ������� �������� ��������������, �� ���������, ����..")
                wait(500)
                sampSendChat("/mess 6 ..��� �� ������������� ������������. ��������!")
            end)
        end
        imgui.EndChild()
        if imgui.Button(u8'�������') then  
            imgui.CloseCurrentPopup()
        end 
    imgui.EndPopup()	
    end
    if imgui.BeginPopup('toolmp') then
        if imgui.Button(u8'������ �������� ������ ����') then
            sampSendChat("/setweap " .. getMyId() .. " 38 " .. " 5000 ")
        end
        imgui.SameLine()
        if imgui.Button(u8"������ � ������������") then  
            lua_thread.create(function()
                sampSendChat("/mess 10 ������� ������, �������� ��� ��� ������! /tpmp")
                wait(500)
                sampSendChat("/mess 10 �������, �� ������ �����������!")
            end)
        end
        imgui.Separator()
        imgui.Text(u8"������ �����:")
        imgui.InputText(u8'������� ID', ini.mp_prize)
        if imgui.Button(u8'�����') then 
            lua_thread.create(function()
                sampSendChat("/mess 10 � ��� ���� ���������� � �����������!")
                wait(500)
                sampSendChat("/mess 10 � ��� ����� � ID: " .. u8:decode(ini.mp_prize.v))
                sampSendChat("/mpwin " .. ini.mp_prize.v)
                showNotification("AdminTool - MP", "�� ������ ���� ������ � ID " .. u8:decode(ini.mp_prize.v) .. ", ���\n������ ��������")
                wait(100)
                sampSetChatInputEnabled(true)
                sampSetChatInputText("/spp ")
                setVirtualKeyDown(VK_RETURN)
            end)
        end
    imgui.EndPopup()
    end
end    

function EXPORTS.up_automute()
    imgui.Text(u8"����� ����� ��������������� ����� �������� ��� �������������� � ��������.")
    imgui.Text(u8"����� ��������� �������� ����� � ���� ����. \n� ���� ��� ����������� ���������� � ��������� ������ ������������")
    imgui.Checkbox(u8'��������/������� ����� � ������ ����', automute_settings.input_mute)
    imgui.SameLine() 
    if imgui.Button(u8"�������� ����� ##1") then  
        automute_settings.show_file_mute.v = true  
    end
    imgui.Checkbox(u8'��������/������� ����� � ������ ����������� ������', automute_settings.input_rod)
    imgui.SameLine() 
    if imgui.Button(u8"�������� ����� ##2") then  
        automute_settings.show_file_rod.v = true  
    end
    imgui.Checkbox(u8'��������/������� ����� � ������ �����������/��������', automute_settings.input_osk)
    imgui.SameLine() 
    if imgui.Button(u8"�������� ����� ##3") then  
        automute_settings.show_file_osk.v = true  
    end
    imgui.Checkbox(u8"��������/������� ����� � ������ ���������� ��������", automute_settings.input_upom)
    imgui.SameLine() 
    if imgui.Button(u8"�������� ����� ##4") then  
        automute_settings.show_file_upom.v = true  
    end
    imgui.Separator()
    imgui.Text(u8"���� ����� ������ �����: \n(� ������ � ����������� �������� ��� ����������� ������ - ����� � �����)")
    imgui.InputText('##Phrase', automute_settings.input_phrase) 
    imgui.SameLine()
    if imgui.Button(fa.ICON_REFRESH) then  
        automute_settings.input_phrase.v = ""
    end
    if imgui.Button(u8"���������") then  
        if #automute_settings.input_phrase.v > 0 then  
            if automute_settings.input_mute.v then  
                for _, val in ipairs(onscene) do 
                    if string.rlower(u8:decode(automute_settings.input_phrase.v)) == val then  
                        showNotification("AutoMute", "������. ������ �����: \n\"" .. val .. "\" \n��� ���� � ������.")
                        return false
                    end 
                end 
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
                onscene[#onscene + 1] = string.rlower(u8:decode(automute_settings.input_phrase.v))
                for _, val in ipairs(onscene) do
                    file_write:write(val .. "\n")
                end
                file_write:close()
                showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" ������� ��������� � ������.")
            elseif automute_settings.input_osk.v then  
                for _, val in ipairs(onscene_2) do
                    if string.rlower(u8:decode(automute_settings.input_phrase.v)) == val then
                        showNotification("AutoMute", "������. ������ �����: \n\"" .. val .. "\" \n��� ���� � ������.")
                        return false
                    end
                end
                local file_write_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
                onscene_2[#onscene_2 + 1] = string.rlower(u8:decode(automute_settings.input_phrase.v))
                for _, val in ipairs(onscene_2) do
                    file_write_1:write(val .. "\n")
                end
                file_write_1:close()
                showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" ������� ��������� � ������.")
            elseif automute_settings.input_upom.v then  
                for _, val in ipairs(ph_upom) do 
                    if string.rlower(u8:decode(automute_settings.input_phrase.v)) == val then  
                        showNotification("AutoMute", "������. ������ �����: \n\"" .. val .. "\" \n��� ���� � ������.")
                        return false 
                    end 
                end 
                local file_read_upom, c_line_upom = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "w"), 1
                ph_upom[#ph_upom + 1] = string.rlower(u8:decode(automute_settings.input_phrase.v))
                for _, val in ipairs(ph_upom) do 
                    file_read_upom:write(val .. "\n")
                end 
                file_read_upom:close() 
                showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" ������� ��������� � ������.")
            elseif automute_settings.input_rod.v then  
                for _, val in ipairs(ph_rod) do 
                    if string.rlower(u8:decode(automute_settings.input_phrase.v)) == val then  
                        showNotification("AutoMute", "������. ������ �����: \n\"" .. val .. "\" \n��� ���� � ������.")
                        return false 
                    end 
                end 
                local file_write_rod, c_line_rod = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "w"), 1
                ph_rod[#ph_rod + 1] = string.rlower(u8:decode(automute_settings.input_phrase.v))
                for _, val in ipairs(ph_rod) do 
                    file_write_rod:write(val .. "\n")
                end 
                file_write_rod:close() 
                showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" ������� ��������� � ������.")
            end
        end
    end
    imgui.SameLine()
    if imgui.Button(u8"�������") then  
        if #automute_settings.input_phrase.v > 0 then  
            if automute_settings.input_mute.v then  
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
                for i, val in ipairs(onscene) do 
                    if val == string.rlower(u8:decode(automute_settings.input_phrase.v)) then  
                        onscene[i] = nil  
                        control_onscene = true 
                    else 
                        file_write:write(val .. "\n")
                    end 
                end 
                file_write:close()
                if control_onscene then  
                    showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" ������� ������� �� ������")
                    control_onscene = false  
                else
                    showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" �� ���������� � ������.")
                end
            elseif automute_settings.input_osk.v then  
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
                for i, val in ipairs(onscene_2) do 
                    if val == string.rlower(u8:decode(automute_settings.input_phrase.v)) then  
                        onscene_2[i] = nil  
                        control_onscene = true 
                    else 
                        file_write:write(val .. "\n")
                    end 
                end 
                file_write:close()
                if control_onscene then  
                    showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" ������� ������� �� ������")
                    control_onscene = false  
                else
                    showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" �� ���������� � ������.")
                end
            elseif automute_settings.input_upom.v then  
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\upom.txt", "w"), 1
                for i, val in ipairs(ph_upom) do 
                    if val == string.rlower(u8:decode(automute_settings.input_phrase.v)) then  
                        ph_upom[i] = nil  
                        control_onscene = true 
                    else 
                        file_write:write(val .. "\n")
                    end 
                end 
                file_write:close()
                if control_onscene then  
                    showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" ������� ������� �� ������")
                    control_onscene = false  
                end
                showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" �� ���������� � ������.")
            elseif automute_settings.input_rod.v then  
                local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\rod.txt", "w"), 1
                for i, val in ipairs(ph_rod) do 
                    if val == string.rlower(u8:decode(automute_settings.input_phrase.v)) then  
                        ph_rod[i] = nil  
                        control_onscene = true 
                    else 
                        file_write:write(val .. "\n")
                    end 
                end 
                file_write:close()
                if control_onscene then  
                    showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" ������� ������� �� ������")
                    control_onscene = false  
                else
                    showNotification("AutoMute", " �����: \n\"" .. string.rlower(u8:decode(automute_settings.input_phrase.v)) .. "\" �� ���������� � ������.")
                end
            end
        end
    end
    imgui.SameLine()
    if imgui.Button(u8"������� ��������") then  
        if automute_settings.show_file_mute.v then  
            automute_settings.show_file_mute.v = false 
        elseif automute_settings.show_file_osk.v then  
            automute_settings.show_file_osk.v = false  
        elseif automute_settings.show_file_rod.v then  
            automute_settings.show_file_rod.v = false  
        elseif automute_settings.show_file_upom.v then  
            automute_settings.show_file_upom.v = false  
        else 
            showNotification("AdminTool", "�� ���� �� ������������ ������\n�� ��������������� :(")
        end
    end
    imgui.Separator()
    if automute_settings.show_file_mute.v then 
        automute_settings.stream.v = check_file_mute()
        for line in automute_settings.stream.v:gmatch("[^\r\n]+") do
            imgui.Text(u8(line))
        end
    elseif automute_settings.show_file_osk.v then  
        automute_settings.stream.v = check_file_osk()
        for line in automute_settings.stream.v:gmatch("[^\r\n]+") do
            imgui.Text(u8(line))
        end
    elseif automute_settings.show_file_rod.v then  
        automute_settings.stream.v = check_file_rod()
        for line in automute_settings.stream.v:gmatch("[^\r\n]+") do
            imgui.Text(u8(line))
        end
    elseif automute_settings.show_file_upom.v then   
        automute_settings.stream.v = check_file_upom()
        for line in automute_settings.stream.v:gmatch("[^\r\n]+") do
            imgui.Text(u8(line))
        end
    else
        imgui.Text(u8"�� ���� ���� �� ���������������. :(")
    end
end

function EXPORTS.autoMP()
    imgui.Text(fa.ICON_MAP .. u8" ����-TP �� ��")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
    if imgui.ToggleButton(u8'##AutoTP', ini.mp_tp) then 
        cfg.settings.mp_tp = ini.mp_tp.v
        save() 
    end	
end     

function EXPORTS.AdminState()
    imgui.Text(fa.ICON_ADDRESS_BOOK .. u8" �����-�����") 
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
    if imgui.ToggleButton('##AdminState', ini.admin_state) then 
        cfg.settings.admin_state = ini.admin_state.v
        save()
    end
end    

function EXPORTS.AdminStateCheckbox()
    imgui.Text(u8" ����� ������� �������� ���� ���� ������, � ���� ����� ������ ����� ������� {RRGGBB}")
    if imgui.Checkbox(u8'���������� ���� ����������', ini.show_transparency) then  
        cfg.settings.show_transparency = ini.show_transparency.v  
        save() 
    end
    if imgui.Button(fa.ICON_FA_COGS .. u8" ��������� ���������") then  
        changePosition = true
        sampAddChatMessage(tag .. ' ����� ����������� ���������� - ������� 1')
    end    
    if imgui.Checkbox(u8'����� �������� � ID', ini.show_nick_id) then  
        cfg.settings.show_nick_id = ini.show_nick_id.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##Color1", ini.color1) then  
        cfg.settings.color1 = ini.color1.v  
        save() 
    end
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'����� �������', ini.show_time) then  
        cfg.settings.show_time = ini.show_time.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##Color2", ini.color2) then  
        cfg.settings.color2 = ini.color2.v  
        save() 
    end
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'����� ������� �� ����', ini.show_online_day) then  
        cfg.settings.show_online_day = ini.show_online_day.v  
        save() 
    end
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##Color3", ini.color3) then  
        cfg.settings.color3 = ini.color3.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'����� ������� �� �����', ini.show_online_now) then  
        cfg.settings.show_online_now = ini.show_online_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color4", ini.color4) then  
        cfg.settings.color4 = ini.color4.v  
        save() 
    end    
    if imgui.Checkbox(u8'����� AFK �� ����', ini.show_afk_day) then  
        cfg.settings.show_afk_day = ini.show_afk_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color5", ini.color5) then  
        cfg.settings.color5 = ini.color5.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'����� AFK �� �����', ini.show_afk_now) then  
        cfg.settings.show_afk_now = ini.show_afk_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color6", ini.color6) then  
        cfg.settings.color6 = ini.color6.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'����� �������� �� ����', ini.show_report_day) then  
        cfg.settings.show_report_day = ini.show_report_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color7", ini.color7) then  
        cfg.settings.color7 = ini.color7.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'����� �������� �� �����', ini.show_report_now) then  
        cfg.settings.show_report_now = ini.show_report_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color8", ini.color8) then  
        cfg.settings.color8 = ini.color8.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'����� ����� �� ����', ini.show_mute_day) then  
        cfg.settings.show_mute_day = ini.show_mute_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color9", ini.color9) then  
        cfg.settings.color9 = ini.color9.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'����� ����� �� �����', ini.show_mute_now) then  
        cfg.settings.show_mute_now = ini.show_mute_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color10", ini.color10) then  
        cfg.settings.color10 = ini.color10.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'����� ����� �� ����', ini.show_kick_day) then  
        cfg.settings.show_kick_day = ini.show_kick_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color11", ini.color11) then  
        cfg.settings.color11 = ini.color11.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'����� ����� �� �����', ini.show_kick_now) then  
        cfg.settings.show_kick_now = ini.show_kick_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color12", ini.color12) then  
        cfg.settings.color12 = ini.color12.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'����� ������� �� ����', ini.show_jail_day) then  
        cfg.settings.show_jail_day = ini.show_jail_day.v  
        save() 
    end   
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color13", ini.color13) then  
        cfg.settings.color13 = ini.color13.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'����� ������� �� �����', ini.show_jail_now) then  
        cfg.settings.show_jail_now = ini.show_jail_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color14", ini.color14) then  
        cfg.settings.color14 = ini.color14.v  
        save() 
    end    
    imgui.PopItemWidth()
    if imgui.Checkbox(u8'����� ����� �� ����', ini.show_ban_day) then  
        cfg.settings.show_ban_day = ini.show_ban_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color15", ini.color15) then  
        cfg.settings.color15 = ini.color15.v  
        save() 
    end    
    imgui.PopItemWidth()
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'����� ����� �� �����', ini.show_ban_now) then  
        cfg.settings.show_ban_now = ini.show_ban_now.v  
        save() 
    end    
    imgui.SameLine()
    imgui.PushItemWidth(65)
    if imgui.InputText("##color16", ini.color16) then  
        cfg.settings.color16 = ini.color16.v  
        save() 
    end    
    imgui.PopItemWidth()
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

    if ini.admin_state.v then 
        
        imgui.ShowCursor = false

        if cfg.settings.posX == 0 and cfg.settings.posY == 0 then  
            imgui.SetNextWindowPos(imgui.ImVec2(1786, 736), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))
        else
            imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.posX, cfg.settings.posY), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5)) 
        end

        if ini.show_transparency.v then  
            imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(1.00, 1.00, 1.00, 0.05))
        end

        imgui.Begin(u8'����������', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)

        if ini.show_nick_id.v then imgui.TextColoredRGB(ini.color1.v .. getMyNick() .. " || ID: " ..  getMyId()) end
        if ini.show_online_day.v then imgui.TextColoredRGB(ini.color3.v .. u8"������ �� ����: " .. get_clock(cfg.static.online)) end 
        if ini.show_online_now.v then imgui.TextColoredRGB(ini.color4.v .. u8"������ �� �����: " .. get_clock(sessionOnline.v)) end
        if ini.show_afk_day.v then imgui.TextColoredRGB(ini.color5.v .. u8"AFK �� ����: " .. get_clock(cfg.static.afk)) end
        if ini.show_afk_now.v then imgui.TextColoredRGB(ini.color6.v .. u8"AFK �� �����: " .. get_clock(sessionAfk.v)) end
        if ini.show_report_day.v then imgui.TextColoredRGB(ini.color7.v .. u8"�������� �� ����: " .. cfg.static.dayReport) end
        if ini.show_report_now.v then imgui.TextColoredRGB(ini.color8.v .. u8"�������� �� �����: " .. LsessionReport) end
        if ini.show_ban_day.v then imgui.TextColoredRGB(ini.color15.v .. u8"���� �� ����: " .. cfg.static.dayBan) end
        if ini.show_ban_now.v then imgui.TextColoredRGB(ini.color16.v .. u8"���� �� �����: " .. LsessionBan) end
        if ini.show_mute_day.v then imgui.TextColoredRGB(ini.color9.v .. u8"���� �� ����: " .. cfg.static.dayMute) end
        if ini.show_mute_now.v then imgui.TextColoredRGB(ini.color10.v .. u8"���� �� �����: " .. LsessionMute) end
        if ini.show_jail_day.v then imgui.TextColoredRGB(ini.color13.v .. u8"������ �� ����: " .. cfg.static.dayJail) end
        if ini.show_jail_now.v then imgui.TextColoredRGB(ini.color14.v .. u8"������ �� �����: " .. LsessionJail) end
        if ini.show_kick_day.v then imgui.TextColoredRGB(ini.color11.v .. u8"���� �� ����: " .. cfg.static.dayKick) end
        if ini.show_kick_now.v then imgui.TextColoredRGB(ini.color12.v .. u8"���� �� �����: " .. LsessionKick) end
        if ini.show_time.v then imgui.TextColoredRGB(ini.color2.v .. u8(os.date("%d.%m.%y | %H:%M:%S", os.time()))) end
        imgui.End()
        if ini.show_transparency.v then  
            imgui.PopStyleColor()
        end
    end    
end    

-- function onScriptTerminate(script, quitGame)
-- 	if script == thisScript() then 
-- 		if inicfg.save(cfg, directIni) then sampfuncsLog('{00FF00}AdminTool: {FFFFFF}��� ������ �������!') end
-- 	end
-- end

function grey_black()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2

	style.WindowPadding       = ImVec2(4, 6)
	style.WindowRounding      = 0
	style.ChildWindowRounding = 3
	style.FramePadding        = ImVec2(5, 4)
	style.FrameRounding       = 2
	style.ItemSpacing         = ImVec2(3, 3)
	style.TouchExtraPadding   = ImVec2(0, 0)
	style.IndentSpacing       = 21
	style.ScrollbarSize       = 14
	style.ScrollbarRounding   = 16
	style.GrabMinSize         = 10
	style.GrabRounding        = 5
	style.WindowTitleAlign    = ImVec2(0.50, 0.50)
	style.ButtonTextAlign     = ImVec2(0, 0)


    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
    colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
    colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
    colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
    colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
    colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
    colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
    colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
    colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
    colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
    colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
    colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
    colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
    colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
    colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
end

function EXPORTS.OffScript()
    imgui.Process = false
    imgui.ShowCursor = false
    thisScript():unload()
end 
    