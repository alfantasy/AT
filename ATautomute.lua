require 'lib.moonloader'
local encoding = require 'encoding' -- дешифровка форматов
local inicfg = require 'inicfg' -- работа с ini
local sampev = require "lib.samp.events" -- подключение основных библиотек, связанные с потокам пакетов ивентов SA:MP, и их прямое соединение с LUA
local imgui = require 'imgui' -- регистр imgui окон
local notfy	= import 'lib/lib_imgui_notf.lua'
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
------- Подключение всех нужных библиотек -----------

function showNotification(handle, text_not)
	notfy.addNotify("{87CEEB}" .. handle, text_not, 2, 1, 6)
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
        automute_osk = false,
        automute_mat = false,
        mp_tp = false,
        admin_state = false,
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
    admin_state = imgui.ImBool(cfg.settings.admin_state),
    mp_tp = imgui.ImBool(cfg.settings.mp_tp),
    automute_mat = imgui.ImBool(cfg.settings.automute_mat),
    automute_osk = imgui.ImBool(cfg.settings.automute_osk),
    open_mp = imgui.ImBuffer(516), 
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
    show_time = imgui.ImBool(cfg.settings.show_time)
}

local onscene = { "блять", "сука", "хуй", "нахуй" } -- основная сцена мата
local control_onscene = false -- контролирование сцены мата
local log_onscene = { } -- лог сцены
local date_onscene = {} -- дата сцены
------ Введенные локальные переменные, отвечающие за автомут ----------

local onscene_2 = { "пидр", "лох", "гандон", "уебан" }
local neosk = { "я лох" }
local control_onscene_1 = false
local control_onscene_2 = false
local log_onscene_1 = { }
local date_onscene_1 = {}

function save() 
    inicfg.save(cfg, directIni)
end

local cjson = require"cjson"
local effil = require"effil"

local chip = false

local russian_characters = {
    [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
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

function sampev.onServerMessage(color, text)

	if chip and text:find("%[(.+)%] IP:") then
        local nick, ip2 = text:match("%[(.+)%] IP: (.+) | IP")
        ip1 = ip2
        return true
    end

	local _, check_mat_id, _, check_mat = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")
	local _, check_osk_id, _, check_osk = string.match(text, "(.+)%((.+)%): {(.+)}(.+)")

    if text:find('%[.*%] '..getMyNick()..'%['..getMyId()..'%] ответил (.*)%[(%d+)%]: (.*)') then 
		cfg.static.dayReport = cfg.static.dayReport + 1
		LsessionReport = LsessionReport + 1
		save()
		return true
	end	

    if text:find("Администратор .+ заткнул%(.+%) игрока .+ на .+ секунд. Причина: .+") then  
        amd_nick = text:match('Администратор (.+) заткнул%(.+%) игрока .+ на .+ секунд. Причина: .+') 
        if amd_nick:find(getMyNick()) then
            cfg.static.dayMute = cfg.static.dayMute + 1 
            sampAddChatMessage("plus", -1)
            LsessionMute = LsessionMute + 1 
            save()
        end
        return true 
    end 

    if text:find("Администратор .+ посадил%(.+%) игрока .+ в тюрьму на .+ секунд. Причина: .+") then  
        amd_nick = text:match('Администратор (.+) посадил%(.+%) игрока .+ в тюрьму на .+ секунд. Причина: .+') 
        if amd_nick:find(getMyNick()) then
            cfg.static.dayJail = cfg.static.dayJail + 1 
            LsessionJail = LsessionKick + 1 
            save()
        end 
        return true 
    end 
    
    if text:find("Администратор .+ забанил%(.+%) игрока .+ на .+ дней. Причина: .+") then  
        amd_nick = text:match('Администратор (.+) забанил%(.+%) игрока .+ на .+ дней. Причина: .+') 
        if amd_nick:find(getMyNick()) then
            cfg.static.dayBan = cfg.static.dayBan + 1 
            LsessionBan = LsessionKick + 1 
            save()
        end  
        return true 
    end 

    if text:find("Администратор .+ кикнул игрока .+. Причина: .+") then  
        amd_nick = text:match('Администратор (.+) кикнул игрока .+. Причина: .+') 
        if amd_nick:find(getMyNick()) then
            cfg.static.dayKick = cfg.static.dayKick + 1 
            LsessionKick = LsessionKick + 1 
            save()
        end 
        return true 
    end 

    if check_mat ~= nil and check_mat_id ~= nil and ini.automute_mat.v then
		local string_os = string.split(check_mat, " ")
		for i, value in ipairs(onscene) do
			for j, val in ipairs(string_os) do
				val = val:match("(%P+)")
				if val ~= nil then
					if value == string.rlower(val) then
						lua_thread.create(function()
							sampAddChatMessage(tag .. text)
							if not isGamePaused() and not isPauseMenuActive() then
								sampSendChat("/mute " .. check_mat_id .. " 300 " .. " Нецензурная лексика.")
                                showNotification("AutoMute", "Ник нарушителя: " .. sampGetPlayerNickname(tonumber(check_mat_id)) .. "\n Запрещенное слово: " .. value)
							end
						end)	
					end
				end
			end
		end
		return true
	end
	if check_osk ~= nil and check_osk_id ~= nil and ini.automute_osk.v then
		local string_os = string.split(check_osk, " ")
		for i, value in ipairs(onscene_2) do
			for j, val in ipairs(string_os) do
				val = val:match("(%P+)")
				if val ~= nil then
					if value == string.rlower(val) and not check_osk:find(":я") then
						lua_thread.create(function()
						sampAddChatMessage(tag .. text)
							if not isGamePaused() and not isPauseMenuActive() then
								sampSendChat("/mute " .. check_osk_id .. " 400 " .. " Оскорбление/Унижение.")
								showNotification("{87CEEB}AdminTool", 'Запрещенное слово: {FFFFFF}' .. value .. '\n{FFFFFF}Ник нарушителя: {FFFFFF}' .. sampGetPlayerNickname(tonumber(check_osk_id)))
							end	
						end)	
					end
				end
			end
		end
		return true
	end

end    

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function main()
    while not isSampAvailable() do wait(0) end
    
    local file_read_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "r"), 1

	if file_read_1 ~= nil then
		file_read_1:seek("set", 0)
		for line in file_read_1:lines() do
			onscene_2[c_line_1] = line
			c_line_1 = c_line_1 + 1
		end
		file_read_1:close()
	end

    sampRegisterChatCommand("textcmd", function()
        sampAddChatMessage("Администатор "..getMyNick().." заткнул%(%-а%) игрока .+ на %d+ секунд. Причина: .+", -1)
    end)

	sampRegisterChatCommand("chip", chip)

    sampRegisterChatCommand('s_osk', function(param)
		if param == nil then
			return false
		end
		for _, val in ipairs(onscene_2) do
			if string.rlower(param) == val then
				sampAddChatMessage(tag .. "Слово \"" .. val .. "\" уже присутствует в списке оскорблений/унижений.")
				return false
			end
		end
		onscene_2[#onscene_2 + 1] = string.rlower(param)
		local file_write_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
		for _, val in ipairs(onscene_2) do
			file_write_1:write(val .. "\n")
		end
		file_write_1:close()
		sampAddChatMessage(tag .. "Слово \"" .. string.rlower(param) .. "\" успешно добавлено в список оскорблений/унижений.")
	end)

    sampRegisterChatCommand('d_osk', function(param)
		local file_write_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
		if param == nil then
			return false
		end
		for i, val in ipairs(onscene_2) do
			local file_write_1, c_line_1 = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\osk.txt", "w"), 1
			if val == string.rlower(param) then
				onscene_2[i] = nil
				control_onscene_2 = true
			else
				file_write_1:write(val .. "\n")
			end
		end
		if control_onscene_2 then
			sampAddChatMessage(tag .. "Слово \"" .. string.rlower(param) .. "\" было успешно удалено из списка оскорблений/унижений.")
			control_onscene_2 = false
		else
			sampAddChatMessage(tag .. "Слова \"" .. string.rlower(param) .. "\" нет в списке оскорблений/унижений.")
		end
		file_write_1:close()
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
	-- чтение файла

	sampRegisterChatCommand('s_mat', function(param) -- сохранение мата
		if param == nil then
			return false
		end
		for _, val in ipairs(onscene) do
			if string.rlower(param) == val then
				sampAddChatMessage(tag .. "Слово \"" .. val .. "\" уже присутствует в списке нецензурной брани.")
				return false
			end
		end
		local file_write, c_line = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\AutoMute\\mat.txt", "w"), 1
		onscene[#onscene + 1] = string.rlower(param)
		for _, val in ipairs(onscene) do
			file_write:write(val .. "\n")
		end
		file_write:close()
		sampAddChatMessage(tag .. "Слово \"" .. string.rlower(param) .. "\" успешно добавлено в список нецензурной лексики.")
	end)
	sampRegisterChatCommand('d_mat', function(param) -- удаление мата
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
			sampAddChatMessage(tag .. "Слово \"" .. string.rlower(param) .. "\" было успешно удалено из списка нецензурной брани.")
			control_onscene = false
		else
			sampAddChatMessage(tag .. "Слова \"" .. string.rlower(param) .. "\" нет в списке нецензурщины.")
		end
	end)

    if cfg.static.today ~= os.date("%a") then 
		cfg.static.today = os.date("%a")
		cfg.static.online = 0
        cfg.static.full = 0
		cfg.static.afk = 0
		cfg.static.dayReport = 0
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
								"\n{FFF500}IP - {FF0400}%s\n{FFF500}Страна -{FF0400} %s\n{FFF500}Город -{FF0400} %s\n{FFF500}Провайдер -{FF0400} %s\n{FFF500}Растояние -{FF0400} %d  \n\n",
								rdata[i]["query"],
								rdata[i]["country"],
								rdata[i]["city"],
								rdata[i]["isp"],
								distances
							)
               end
				end
				if text == "" then
					text = " \n\t{FFF500}Ничего не найдено"
				end
				showdialog("Информация о IP", text)
			end,
			function(err)
				showdialog("Информация о IP", "Произошла ошибка \n" .. err)
			end
		)
	end
end

function showdialog(name, rdata)
	sampShowDialog(
		math.random(1000),
		"{FF4444}" .. name,
		rdata,
		"Закрыть",
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
        elseif ch == 168 then -- Ё
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
        elseif ch == 184 then -- ё
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
    return os.date((onDay and math.floor(time / 86400)..'д ' or '')..'%H:%M:%S', time + timezone_offset)
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
            sampAddChatMessage(tag .. ' Сохранено.')
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
    imgui.Text(fa.ICON_NEWSPAPER_O .. u8" Авто-мут за мат")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
    if imgui.ToggleButton("##AutoMuteMat", ini.automute_mat) then 
        cfg.settings.automute_mat = ini.automute_mat.v 
        save() 
    end	
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 200)
    imgui.Text(fa.ICON_NEWSPAPER_O .. u8" Авто-мут за оск")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 50)
    if imgui.ToggleButton("##AutoMuteOsk", ini.automute_osk) then 
        cfg.settings.automute_osk = ini.automute_osk.v 
        save() 
    end	
end

function EXPORTS.ActiveMP()
    imgui.Text(u8"Данные кнопки отправляют мгновенные сообщения в /mess сразу.")
    imgui.Text(u8"Нажимать необходимо, лишь ОДИН раз, скрипт все сделает за вас.")
    imgui.Text(u8"Ваша задача лишь открыть телепорт, нажать кнопки и ввести МП.")
    imgui.Text(u8"Для открытия телепорта используется команда /mp")
    imgui.Text(u8"/jm - jail за нарушение правил мероприятия.")
    imgui.Text(u8"Swat Tank - 601 ID, Shamal - 519 ID, Комбайн - 532 ID") 
    imgui.Text(u8"Чтобы заспавнить машину, введите /veh ID 1 1")
    imgui.Text(u8"Вопросы для Викторины, вы должны приготовить сами")
    imgui.Separator()
    if imgui.Button(u8"Полезные штуки", imgui.ImVec2(120,0)) then 
        imgui.OpenPopup('toolmp')
    end	
    imgui.SameLine()
    if imgui.Button(u8"Создать свое МП", imgui.ImVec2(200,0)) then 
        imgui.OpenPopup('createmp')
    end	 
    if imgui.Button(u8"Заготовленные мероприятия", imgui.ImVec2(300,0)) then 
        imgui.OpenPopup('zagmp') 
    end 
    imgui.Separator()
    imgui.CenterText(u8"Описание мероприятий")
    if imgui.CollapsingHeader(u8"Прятки") then 
        imgui.Text(u8"Первоначально собирается строй. Рассказываются правила.")
        imgui.Text(u8"Люди разбегаются. Администратор начинает искать")
        imgui.Text(u8"Администратор бегает с миниганом и убивает каждого, кого найдет")
        imgui.Text(u8"Тот, кто остается последним - побеждает")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"Король дигла") then
        imgui.Text(u8"Собирается строй, рассказываются правила игры.")
        imgui.Text(u8"Игроки восстанавливают здоровье, берут Desert Eagle.")
        imgui.Text(u8"Администратор выбирает двух игроков каждый раунд")
        imgui.Text(u8"Погибающий - выбывает, победитель - остается.")
        imgui.Text(u8"Победивший в последнем раунде получает приз")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"Русская рулетка") then  
        imgui.Text(u8"Делается строй, рассказываются правила")
        imgui.Text(u8"Администратор берет миниган, и начинается русская рулетка")
        imgui.Text(u8'Это делается с помощью команды "/try убил"')
        imgui.Text(u8'Если "удачно" - игрок погибает. Если "неудачно" - жив')
        imgui.Text(u8'Тот, кто остается последним побеждает')
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"Крылья смерти") then  
        imgui.Text(u8"Сначала делается строй, рассказываются правила")
        imgui.Text(u8"Администратор спавнит самолет Shamal")
        imgui.Text(u8"Игроки запрыгивают на крылья самолета")
        imgui.Text(u8"Администратор начинает полет и трюки")
        imgui.Text(u8"Тот, кто останется последний на самолете побеждает")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"Викторина") then  
        imgui.Text(u8"Администратор объявляет о начале Викторины")
        imgui.Text(u8"Тем временем, телепортация не задается")
        imgui.Text(u8"Ответ = 1 балл. Тот, кто набрал 5 баллов - победитель")
        imgui.Text(u8"Можно задавать любые вопросы. Даже, если они не связанные с модом")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"Поливалка") then  
        imgui.Text(u8"Делается строй, администратор рассказывает правила")
        imgui.Text(u8"Он спавнит Swat Tank, и начинает поливать игроков")
        imgui.Text(u8"Последний, кто остался на платформе - победитель")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"Живи или умри") then  
        imgui.Text(u8"Делается строй, рассказываются правила. \nАдминистратор сбивает игроков на комбайне")
        imgui.Text(u8"Тот, кто остался последний - победил")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"Развлекательное МП") then  
        imgui.Text(u8"Делается строй, рассказывается короткие правила")
        imgui.Text(u8"Им можно на мероприятии выдавать объекты (/object)")
        imgui.Text(u8"Слушать музыку, и веселиться всячески в течении 10 минут")
        imgui.Text(u8"При желании игроков, можно выдать им оружие для перестрелки")
        imgui.Text(u8"БОЛЬШАЯ ПРОСЬБА! ПОСЛЕ МЕРОПРИЯТИЯ ЗАБРАТЬ ОБЪЕКТЫ")
    end 
    imgui.Separator()
    if imgui.CollapsingHeader(u8"Поле чудес") then  
        imgui.Text(u8"Объявляется о начале.. Поле чудес, ТП нету")
        imgui.Text(u8"Рассказываются правила, загадывается слово")
        imgui.Text(u8"Игроки выбирают буквы в ЛС, но как..")
        imgui.Text(u8"Им задаются три варианта, а они выбирают один - верный")
        imgui.Text(u8"Первый, кто написал вариант, тот вариант учитывается")
        imgui.Text(u8"Тот, кто отгадал слово победитель.")
        imgui.Text(u8"Но, участникам выдаются вирты. Одна буква = 1 балл")
        imgui.Text(u8"1 балл - 1кк.")
    end
    imgui.Separator()
    if imgui.CollapsingHeader(u8'Догони админа') then 
        imgui.Text(u8"Все как всегда, строй, правила")
        imgui.Text(u8"Администратор берет мотоцикл (любой, но жел.NRG-500)")
        imgui.Text(u8"Игроки же в свою очередь тоже берут мотоцикл")
        imgui.Text(u8"У админа есть 30 секунд, чтобы уехать")
        imgui.Text(u8"Игрок обязан скинуть админа и ударить того кулаком")
        imgui.Text(u8"Кто сделает это первым - тот и победил")
    end	
    if imgui.BeginPopup('zagmp') then 
        if imgui.Button(u8'Мероприятия "Прятки"') then
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,-2315,1545,18)
                    wait(2500)
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Прятки. Желающие /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Прятки. Желающие /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Прятки")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Прятки" успешно создано\nТелепортация открыта')
                end)
            else 	
                lua_thread.create(function()
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Прятки. Желающие /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Прятки. Желающие /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Прятки")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Прятки" успешно создано\nТелепортация открыта')
                end)
            end
        end
        if imgui.Button(u8'Правила МП "Прятки"') then
            sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
            sampSendChat("/mess 6 Правила знаем, значит у вас есть минута, чтобы спрятаться")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Король дигла"') then
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,1753,2072,1955)
                    wait(2500)
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Король Дигла. Желающие /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Король Дигла. Желающие /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "КД")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Король дигла" \nуспешно создано\nТелепортация открыта')
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Король Дигла. Желающие /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Король Дигла. Желающие /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "КД")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Король дигла" \nуспешно создано\nТелепортация открыта')
                end)	
            end
        end
        if imgui.Button(u8'Правила МП "Король дигла"') then
            sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
            sampSendChat("/mess 6 Я буду вызывать двоих игроков, после начну отсчет от пяти секунд.")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Русская рулетка"') then
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,1973,-978,1371)
                    wait(2500)
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Русская рулетка. Желающие /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Русская рулетка. Желающие /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "РР")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Русская рулетка" \nуспешно создано\nТелепортация открыта')
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Русская рулетка. Желающие /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Русская рулетка. Желающие /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "РР")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Русская рулетка" \nуспешно создано\nТелепортация открыта')
                end)	
            end	
        end
        if imgui.Button(u8'Правила МП "Русская рулетка"') then
            sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
            sampSendChat("/mess 6 Я буду действовать с помощью команды /try - убил. Удачно - убиты. Неудачно - живы.")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Поливалка"') then
            if ini.mp_tp.v then 
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,-2304,872,59)
                    wait(2500)
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Поливалка. Желающие: /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Поливалка. Желающие: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Поливалка")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем комадны")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Поливалка" \nуспешно создано\nТелепортация открыта')
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Поливалка. Желающие: /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Поливалка. Желающие: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Поливалка")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем комадны")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Поливалка" \nуспешно создано\nТелепортация открыта')
                end)	
            end	
        end
        if imgui.Button(u8'Правила МП "Поливалка"') then
            sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
            sampSendChat("/mess 6 Я буду использовать Swat Tank, и буду сбивать вас с выбранного места.")
            sampSendChat("/mess 6 Последний, кто остается - победитель.")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Крылья смерти"') then
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,2027,-2434,13)
                    wait(2500)
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Крылья смерти. Желающие: /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Крылья смерти. Желающие: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Крылья смерти")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Крылья смерти" \nуспешно создано\nТелепортация открыта')
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Крылья смерти. Желающие: /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Крылья смерти. Желающие: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Крылья смерти")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Крылья смерти" \nуспешно создано\nТелепортация открыта')
                end)
            end		
        end
        if imgui.Button(u8'Правила МП "Крылья смерти"') then
            sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
            sampSendChat("/mess 6 Я буду использовать самолет Shamal, а ваша задача залезть на крылья")
            sampSendChat("/mess 6 Ваша последующая задача не упасть, а я буду выполнять трюки.")
            sampSendChat("/mess 6 Тот, кто останется последним на самолете - победитель")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Викторина"') then
            sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Викторина! Телепорта не будет")
            sampSendChat("/mess 10 Сейчас, я объясню правила игры, и те, кто прочитает правила, мне в /pm +")
            showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Викторина" \nзапущена\nГотовьте вопросы')
        end
        if imgui.Button(u8'Правила МП "Викторина"') then
            sampSendChat("/mess 6 Я задаю вопрос из любой категории, и жду ответа.")
            sampSendChat("/mess 6 Первый, кто отвечает - получает один балл")
            sampSendChat("/mess 6 Всего баллов - 5. Готовность отправляем мне в /pm знаком +")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Живи или умри') then  
            if ini.mp_tp.v then 
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,1547,-1359,329)
                    wait(2500)
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Живи или умри. Желающие: /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Живи или умри. Желающие: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "ЖилиУ")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Живи или умри" \nуспешно создано\nТелепортация открыта')
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Живи или умри. Желающие: /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Живи или умри. Желающие: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "ЖилиУ")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Живи или умри" \nуспешно создано\nТелепортация открыта')
                end)	
            end	
        end
        if imgui.Button(u8'Правила МП "Живи или умри"') then  
            sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
            sampSendChat("/mess 6 Я буду использовать комбайн. Моя задача - давить вас")
            sampSendChat("/mess 6 Ваша задача - разбегаться в крыше, и выживать.")
            sampSendChat("/mess 6 Тот, кто будет последним - победитель")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Развлечение"') then  
            if ini.mp_tp.v then
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,626,-1891,3)
                    wait(2500)
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Развлечение. Желающие: /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Развлечение. Желающие: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Развлекательное МП")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Развлечение" \nуспешно создано\nТелепортация открыта')
                end)
            else 
                lua_thread.create(function()
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Развлечение. Желающие: /tpmp")
                    sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Развлечение. Желающие: /tpmp")
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Развлекательное МП")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Развлечение" \nуспешно создано\nТелепортация открыта')
                end)
            end	
        end
        if imgui.Button(u8'Правила МП "Развлечение"') then  
            sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s и баги. ДМ запрещено.")
            sampSendChat("/mess 6 Я вам ставлю любые объекты, ставите бумбокс. В течении 10 минут..")
            sampSendChat("/mess 6 ...вы свободно веселитесь! Цель самого мероприятия - собрать сервер!")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Поле чудес"') then  
            lua_thread.create(function()
                sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: Поле чудес! Телепорта не будет")
                sampSendChat("/mess 10 Сейчас, я объясню правила игры, и те, кто прочитает правила, мне в /pm +")
                showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Поле чудес" \nзапущена\nГотовьте слово')
            end)
        end
        if imgui.Button(u8'Правила МП "Поле чудес"') then
            sampSendChat("/mess 6 Я загадываю слово, говорю его примерное значение")  
            sampSendChat("/mess 6 Ваша задача - угадать слово, открывать буквы")
            sampSendChat("/mess 6 Тот, кто отгадает слово - победитель")
            sampSendChat("/mess 6 Одна буква = один балл. Один балл - 1кк виртов.")
        end
        imgui.Separator()
        if imgui.Button(u8'Мероприятие "Догони админа"') then 
            if ini.mp_tp.v then 
                lua_thread.create(function()
                    setCharCoordinates(PLAYER_PED,526,-1724,12)
                    wait(2500)
                    sampSendChat('/mess 10 Уважаемые игроки! Проходит меропряитие "Догони админа". /tpmp')
                    sampSendChat('/mess 10 Уважаемые игроки! Проходит меропряитие "Догони админа". /tpmp')
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 14)
                    sampSendDialogResponse(16066, 1, 0)
                    sampSendDialogResponse(16066, 0, 0)
                    sampSendDialogResponse(16066, 1, 1)
                    sampSendDialogResponse(16067, 1, 0, "359")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Догони админа")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Догони админа" \nуспешно создано\nТелепортация открыта')
                end)
            else 	
                lua_thread.create(function()
                    sampSendChat('/mess 10 Уважаемые игроки! Проходит меропряитие "Догони админа". /tpmp')
                    sampSendChat('/mess 10 Уважаемые игроки! Проходит меропряитие "Догони админа". /tpmp')
                    sampSendChat("/mp")
                    sampSendDialogResponse(5343, 1, 0)
                    sampSendDialogResponse(5344, 1, 0, "Догони админа")
                    sampSendChat("/mess 10 Активнее /tpmp, делаем строй и ожидаем команды")
                    showNotification("{87CEEB}[AdminTool]", 'Мероприятие "Догони админа" \nуспешно создано\nТелепортация открыта')
                end)
            end	
        end	
        if imgui.Button(u8'Правила МП "Догони админа"') then 
            sampSendChat('/mess 6 Правила: ДМ, любые баги, /s, /r, /fly - запрещено.')
            sampSendChat('/mess 6 Вам необходимо догнать админа, сбить его и ударить кулаком')
            sampSendChat('/mess 6 Игрок, сделавший это первым - побеждает. Use only motocycles')
        end	
    imgui.EndPopup()
    end	
    if imgui.BeginPopup('createmp') then 
        imgui.Text(u8"Название своего мероприятия:")
        imgui.InputText(u8'', ini.open_mp)
        if imgui.Button(u8'Вывод') then 
            sampSendChat("/mess 10 Уважаемые игроки! Проходит мероприятие: " .. u8:decode(ini.open_mp.v))
            sampSendChat("/mp")
            sampSendDialogResponse(5343, 1, 14)
            sampSendDialogResponse(16066, 1, 0)
            sampSendDialogResponse(16066, 0, 0)
            sampSendDialogResponse(16066, 1, 1)
            sampSendDialogResponse(16067, 1, 0, "359")
            sampSendDialogResponse(5343, 1, 0)
            sampSendDialogResponse(5344, 1, 0, u8:decode(ini.open_mp.v))
            sampSendChat("/mess 10 Чтобы попасть на мероприятие, введите /tpmp")
            showNotification("AdminTool - MP", "Мероприятие было создано.")
        end
        imgui.Separator()
        if imgui.Button(u8'Стандарт.правила') then  
            sampSendChat("/mess 6 Правила: Нельзя использовать /passive, /fly, /r - /s, баги, /flycar")
            sampSendChat("/mess 6 Следуем командам администратора, ДМ запрещено, если..")
            sampSendChat("/mess 6 ..это не предусмотрено мероприятием. Начинаем!")
        end
    imgui.EndPopup()	
    end
    if imgui.BeginPopup('toolmp') then
        if imgui.Button(u8'Выдача минигана самому себе') then
            sampSendChat("/setweap " .. getMyId() .. " 38 " .. " 5000 ")
        end
        imgui.SameLine()
        if imgui.Button(u8"Призыв к телепортации") then  
            sampSendChat("/mess 10 Дорогие игроки, телепорт все ещё открыт! /tpmp")
            sampSendChat("/mess 10 Успейте, до начала мероприятия!")
        end
        imgui.Separator()
        imgui.Text(u8"Выдача приза:")
        imgui.InputText(u8'Введите ID', ini.mp_prize)
        if imgui.Button(u8'Вывод') then 
            lua_thread.create(function()
                sampSendChat("/mess 10 У нас есть победитель в мероприятии!")
                sampSendChat("/mess 10 И это игрок с ID: " .. u8:decode(ini.mp_prize.v))
                sampSendChat("/mpwin " .. ini.mp_prize.v)
                showNotification("AdminTool - MP", "Вы выдали приз игроку с ID " .. u8:decode(ini.mp_prize.v) .. ", вам\nвыдана зарплата")
                wait(100)
                sampSetChatInputEnabled(true)
                sampSetChatInputText("/spp ")
                setVirtualKeyDown(VK_RETURN)
            end)
        end
    imgui.EndPopup()
    end
end    

function EXPORTS.autoMP()
    imgui.Text(fa.ICON_MAP .. u8" Авто-TP на МП")
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
    if imgui.ToggleButton(u8'##AutoTP', ini.mp_tp) then 
        cfg.settings.mp_tp = ini.mp_tp.v
        save() 
    end	
end     

function EXPORTS.AdminState()
    imgui.Text(fa.ICON_ADDRESS_BOOK .. u8" Админ-стата") 
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
    if imgui.ToggleButton('##AdminState', ini.admin_state) then 
        cfg.settings.admin_state = ini.admin_state.v
        save()
    end
end    

function EXPORTS.AdminStateCheckbox()
    if imgui.Button(fa.ICON_FA_COGS .. u8" Изменение положения") then  
        changePosition = true
        sampAddChatMessage(tag .. ' Чтобы подтвердить сохранение - нажмите 1')
    end    
    if imgui.Checkbox(u8'Показ никнейма и ID', ini.show_nick_id) then  
        cfg.settings.show_nick_id = ini.show_nick_id.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ времени', ini.show_time) then  
        cfg.settings.show_time_id = ini.show_time.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ онлайна за день', ini.show_online_day) then  
        cfg.settings.show_online_day = ini.show_online_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ онлайна за сеанс', ini.show_online_now) then  
        cfg.settings.show_online_now = ini.show_online_now.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ AFK за день', ini.show_afk_day) then  
        cfg.settings.show_afk_day = ini.show_afk_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ AFK за сеанс', ini.show_afk_now) then  
        cfg.settings.show_afk_now = ini.show_afk_now.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ репортов за день', ini.show_report_day) then  
        cfg.settings.show_report_day = ini.show_report_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ репортов за сеанс', ini.show_report_now) then  
        cfg.settings.show_report_now = ini.show_report_now.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ мутов за день', ini.show_mute_day) then  
        cfg.settings.show_mute_day = ini.show_mute_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ мутов за сеанс', ini.show_mute_now) then  
        cfg.settings.show_mute_now = ini.show_mute_now.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ киков за день', ini.show_kick_day) then  
        cfg.settings.show_kick_day = ini.show_kick_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ киков за сеанс', ini.show_kick_now) then  
        cfg.settings.show_kick_now = ini.show_kick_now.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ джайлов за день', ini.show_jail_day) then  
        cfg.settings.show_jail_day = ini.show_jail_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ джайлов за сеанс', ini.show_jail_now) then  
        cfg.settings.show_jail_now = ini.show_jail_now.v  
        save() 
    end    
    if imgui.Checkbox(u8'Показ банов за день', ini.show_ban_day) then  
        cfg.settings.show_ban_day = ini.show_ban_day.v  
        save() 
    end    
    imgui.SameLine()
    imgui.SetCursorPosX(imgui.GetWindowWidth() - 250)
    if imgui.Checkbox(u8'Показ банов за сеанс', ini.show_ban_now) then  
        cfg.settings.show_ban_now = ini.show_ban_now.v  
        save() 
    end    
end    

function imgui.OnDrawFrame()

    if ini.admin_state.v then 
        
        imgui.ShowCursor = false

        imgui.SetNextWindowPos(imgui.ImVec2(cfg.settings.posX, cfg.settings.posY), imgui.Cond.FirsUseEver, imgui.ImVec2(0.5, 0.5))

        imgui.Begin(u8'Статистика', nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar)

        if ini.show_nick_id.v then imgui.Text(getMyNick() .. " || ID: " ..  getMyId()) end
        if ini.show_online_day.v then imgui.Text(u8"Онлайн за день: " .. get_clock(cfg.static.online)) end 
        if ini.show_online_now.v then imgui.Text(u8"Онлайн за сеанс: " .. get_clock(sessionOnline.v)) end
        if ini.show_afk_day.v then imgui.Text(u8"AFK за день: " .. get_clock(cfg.static.afk)) end
        if ini.show_afk_now.v then imgui.Text(u8"AFK за сеанс: " .. get_clock(sessionAfk.v)) end
        if ini.show_report_day.v then imgui.Text(u8"Репортов за день: " .. cfg.static.dayReport) end
        if ini.show_report_now.v then imgui.Text(u8"Репортов за сеанс: " .. LsessionReport) end
        if ini.show_ban_day.v then imgui.Text(u8"Баны за день: " .. cfg.static.dayBan) end
        if ini.show_ban_now.v then imgui.Text(u8"Баны за сеанс: " .. LsessionBan) end
        if ini.show_mute_day.v then imgui.Text(u8"Муты за день: " .. cfg.static.dayMute) end
        if ini.show_mute_now.v then imgui.Text(u8"Муты за сеанс: " .. LsessionMute) end
        if ini.show_jail_day.v then imgui.Text(u8"Джаилы за день: " .. cfg.static.dayJail) end
        if ini.show_jail_now.v then imgui.Text(u8"Джаилы за сеанс: " .. LsessionJail) end
        if ini.show_kick_day.v then imgui.Text(u8"Кики за день: " .. cfg.static.dayKick) end
        if ini.show_kick_now.v then imgui.Text(u8"Кики за сеанс: " .. LsessionKick) end
        if ini.show_time.v then imgui.CenterText(u8(os.date("%d.%m.%y | %H:%M:%S", os.time()))) end
        imgui.End()
    end    

end    

function onScriptTerminate(script, quitGame)
	if script == thisScript() then 
		if inicfg.save(cfg, directIni) then sampfuncsLog('{00FF00}AdminTool: {FFFFFF}Ваш онлайн сохранён!') end
	end
end


function EXPORTS.OffScript()
    imgui.Process = false
    imgui.ShowCursor = false
    thisScript():unload()
end 
    