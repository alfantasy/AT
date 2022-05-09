script_name('ImGui Scoreboard')
script_description('ImGui SA:MP Scoreboard Modded Yamada, feat. alfantasy')
script_dependencies('SAMPFUNCS', 'Dear ImGui')
script_moonloader(025)

require 'moonloader'
require 'SAMPFUNCS'
local imgui = require 'imgui'
local tag = "{87CEEB}[SC-AT]  {4169E1}" -- локальная переменная, которая регистрирует тэг AT
local vkeys = require 'vkeys'
local bitex = require 'bitex'
local SE = require 'lib.samp.events'
local memory = require 'memory'
local encoding = require 'encoding'
local inicfg = require 'inicfg'
u8 = encoding.UTF8
encoding.default = 'CP1251'

local combo_select = imgui.ImInt(0) -- отвечает за комбо-штучки

function showNotification(handle, text_not)
	notfy.addNotify("{87CEEB}" .. handle, text_not, 2, 1, 6)
end

local russian_characters = {
	[168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
}
local quitReason = {
  "вылетел / краш",
  "вышел из игры",
  "кикнут / забанен"
}
local allset = inicfg.load({
	set = {
		type = 1,
		titlebar = 0,
		streamcheck = false,
		npcshow = false,
		fontSize = 2,
		nickType = 0,
		list = 0
	},
	cheat = {
		clog = false
	}
}, "..\\config\\AdminTool\\scoreboard.ini")
local groups = inicfg.load({
	friend = {},
	admin = {},
	enemy = {}
}, "..\\config\\AdminTool\\playergroupscoreboard.ini")
if allset.set.fontSize < 0 or allset.set.fontSize > 4 then
	allset.set.fontSize = 2
end
local cfg = nil
local copColor = {
	[12] = {11},
	[6] = {29},
	[3] = {5, 19},
	[8] = {15},
	[23] = {16},
	[24] = {17},
	[25] = {18}
}

local sizesFont = {"12", "13", "14", "15", "16"}
local sFont = {}
local style = imgui.GetStyle()
local colors = style.Colors
local clr = imgui.Col
local ImVec4 = imgui.ImVec4


local ToScreen = convertGameScreenCoordsToWindowScreenCoords
local show_main_window = imgui.ImBool(false)
local show_set_window = imgui.ImBool(false)
local searchBuf = imgui.ImBuffer(256)
local createThemBuf = imgui.ImBuffer(32)
local playerCount = 0
local streamCheck = imgui.ImBool(allset.set.streamcheck)
local cStyle = imgui.ImInt(0)
local cType = imgui.ImInt(allset.set.type)
local bTitlebar = imgui.ImInt(allset.set.titlebar)
local cSize = imgui.ImInt(allset.set.fontSize)
local cNType = imgui.ImInt(allset.set.nickType)
local bNpcShow = imgui.ImBool(allset.set.npcshow)
local bConnectLog = imgui.ImBool(allset.cheat.clog)
local logConFilter = imgui.ImBuffer(128)
local ScrollToButton = false
local logConnect = {}
local thems = {}
local themsId = {}
local notThems = false
local focusId = -1
local scrollToId = false
local gameInit = false
local pMarker = {}
local bMarkPlayer = imgui.ImBool(false)
local mColor = {}
local cFilter = imgui.ImInt(allset.set.list)
local cSetGroup = imgui.ImInt(0)

function main()
	if not isSampLoaded() then return end
	while not isSampAvailable() do wait(0) end

	local h, n = findFirstFile('moonloader\\resource\\scoreboard\\*')
	local i = 1
	while true do
		wait(0)
		if h then
			if n then
				if doesDirectoryExist("moonloader\\resource\\scoreboard\\" .. n) and n ~= "." and n ~= ".." then
					table.insert(thems, n)
					themsId[tostring(n)] = i
					if allset.set.curTheme == n then
						cStyle.v = i - 1
					end
					i = i + 1
				end
				n = findNextFile(h)
			else
				findClose(h)
				if #thems == 0 then
					thems[1] = "main"
					themsId["main"] = 1
					notThems = true
					loadTheme()
				end
			end
		end
		imgui.Process = show_main_window.v
		for k, v in pairs(pMarker) do
			local result, ped = sampGetCharHandleBySampPlayerId(k)
			if result then
				local color = sampGetPlayerColor(k)
				if doesBlipExist(pMarker[k]) then
					if mColor[v] ~= color then
						removeBlip(v)
						pMarker[k] = addBlipForChar(ped)
						mColor[pMarker[k]] = color
						changeBlipColour(pMarker[k], alpha255(color))
						changeBlipDisplay(pMarker[k], 3)
						setBlipAlwaysDisplayOnZoomedRadar(pMarker[k], true)
					end
				else
					pMarker[k] = addBlipForChar(ped)
					mColor[pMarker[k]] = color
					changeBlipColour(pMarker[k], alpha255(color))
					changeBlipDisplay(pMarker[k], 3)
					setBlipAlwaysDisplayOnZoomedRadar(pMarker[k], true)
				end
			end
		end
	end
end

function toggleScoreboard(flag)
	if type(flag) == 'boolean' then
		show_main_window.v = flag
	else
		show_main_window.v = not show_main_window.v
	end
	if show_main_window.v then
		if focusId > -1 then
			scrollToId = true
		end
		if bConnectLog.v then
			ScrollToButton = true
		end
	end
end

function getLocalPlayerId()
	local _, id = sampGetPlayerIdByCharHandle(playerPed)
	return id
end

function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100 or msg == 0x101) then
		if(wparam == VK_ESCAPE and show_main_window.v) and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			if(msg == 0x101)then
				toggleScoreboard(false)
			end
		end
	end
end


local glyph_ranges = nil
function imgui.BeforeDrawFrame()
    if not fontChanged then
        fontChanged = true
        glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
        imgui.GetIO().Fonts:Clear()
        imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arialbd.ttf', 14, nil, glyph_ranges)
				for _, v in ipairs(sizesFont) do
					sFont[tonumber(v)] = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arialbd.ttf', tonumber(v), nil, glyph_ranges)
				end
				imgui.RebuildFonts()
    end
end
function imgui.OnDrawFrame()

	local ATcfg2 = inicfg.load({
        setting = {
            styleImgui = 0,
        }	
    }, "AdminTool\\settings.ini")

    if tonumber(ATcfg2.setting.styleImgui) == 0 then
        black()
    elseif tonumber(ATcfg2.setting.styleImgui) == 1 then
        grey_black()
	elseif tonumber(ATcfg2.setting.styleImgui) == 2 then
		white()
    elseif tonumber(ATcfg2.setting.styleImgui) == 3 then
        skyblue()
    elseif tonumber(ATcfg2.setting.styleImgui) == 4 then
        blue()
    elseif tonumber(ATcfg2.setting.styleImgui) == 5 then
        blackblue()
    elseif tonumber(ATcfg2.setting.styleImgui) == 6 then
        red()
	elseif tonumber(ATcfg2.setting.styleImgui) == 7 then 
		blackred()
	elseif tonumber(ATcfg2.setting.styleImgui) == 8 then 
		brown()
	elseif tonumber(ATcfg2.setting.styleImgui) == 9 then 
		violet()
	elseif tonumber(ATcfg2.setting.styleImgui) == 10 then  
		purple2()
	elseif tonumber(ATcfg2.setting.styleImgui) == 11 then  
		salat()
	elseif tonumber(ATcfg2.setting.styleImgui) == 12 then  
		yellow_green()
	elseif tonumber(ATcfg2.setting.styleImgui) == 13 then  
		banana()
	elseif tonumber(ATcfg2.setting.styleImgui) == 14 then  
		royalblue()
	end

	if show_main_window.v then
		if show_set_window.v then
			local x, y = ToScreen(510, 30)
			local w, h = ToScreen(638, 175)
			imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 4.0))
			imgui.SetNextWindowPos(imgui.ImVec2(w-220, y), imgui.Cond.FirstUseEver, imgui.ImVec2(0.0, 0.0))
			imgui.SetNextWindowSize(imgui.ImVec2(220, 270), imgui.Cond.FirstUseEver)
			imgui.Begin(u8'Настройки', show_set_window, 2+4+32 + imgui.WindowFlags.AlwaysAutoResize)
			imgui.Separator()
			imgui.AlignTextToFramePadding()
			if imgui.CollapsingHeader(u8"Общие настройки") then
				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Размер окна:")
				imgui.SameLine()
				imgui.PushItemWidth(127)
				if imgui.Combo("##type", cType, {u8"Маленький", u8"Средний", u8"Большой", u8"На весь экран"}) and #thems > 0 then
					allset.set.type = cType.v
				end
				imgui.Separator()
				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Заголовок:")
				imgui.SameLine()
				imgui.PushItemWidth(139)
				if imgui.Combo("##header", bTitlebar, {u8"Стандарт", u8"Только текст", u8"Скрыть"}) then
					allset.set.titlebar = bTitlebar.v
				end
				imgui.Separator()
				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Размер текста:")
				imgui.SameLine()
				imgui.PushItemWidth(116)
				if imgui.Combo("##size", cSize, sizesFont) then
					allset.set.fontSize = cSize.v
				end
				imgui.Separator()
				imgui.AlignTextToFramePadding()
				imgui.Text(u8"Ники игроков:")
				imgui.SameLine()
				imgui.PushItemWidth(120)
				if imgui.Combo("##ntype", cNType, {u8"Стандарт", u8"Цвет отдельно", u8"Без цвета"}) then
					allset.set.nickType = cNType.v
				end
			end
			imgui.Separator()
			if imgui.Checkbox(u8"Журнал подключений", bConnectLog) then
				allset.cheat.clog = bConnectLog.v
			end
			if imgui.Checkbox(u8"Показывать NPC", bNpcShow) then
				allset.set.npcshow = bNpcShow.v
			end
			imgui.Separator()
			if imgui.Button(u8"Сохранить изменения", imgui.ImVec2(212, 0)) then
				if notThems then
					inicfg.save(cfg, "..\\resource\\scoreboard\\main\\data.ini")
					notThems = false
				else
					inicfg.save(cfg, "..\\resource\\scoreboard\\" .. allset.set.curTheme .. "\\data.ini")
				end
				sampAddChatMessage(tag .. "Настройки TAB`борда сохранены.")
				inicfg.save(allset, "..\\config\\AdminTool\\scoreboard.ini")
			end
			imgui.End()
			imgui.PopStyleVar()
		end
		playerCount = 0
		local xOffset = 0
		if bConnectLog.v then
			local x, y = ToScreen(0, 0)
			local w, h = ToScreen(180, 448)
			xOffset = w-x
			imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 4.0))
			imgui.SetNextWindowPos(imgui.ImVec2(x, y), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowSize(imgui.ImVec2(w-x, h), imgui.Cond.FirstUseEver)
			imgui.Begin(u8"##connectLogBar", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoBringToFrontOnFocus)
			imgui.SetWindowFontScale(1.05)
			imgui.AlignTextToFramePadding()
			imgui.Text(u8"Журнал подключений:")
			imgui.SetWindowFontScale(1.0)
			imgui.SameLine(w-x-153)
			imgui.PushItemWidth(150)
			imgui.InputText("##logConFilter", logConFilter)
			if not imgui.IsItemActive() and logConFilter.v:len() == 0 then
				local r, g, b, a = imgui.ImColor(colors[1]):GetRGBA()
				imgui.SameLine(w-x-150)
				imgui.TextColored(imgui.ImColor(r, g, b, 180):GetVec4(), u8"Поиск по журналу")
			end
			imgui.PopItemWidth()
			imgui.Separator()
			local _, hb = ToScreen(_, 428)
			imgui.BeginChild("##connectLog", imgui.ImVec2(w-x-4, hb))
			imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(1, 2))
			if #logConnect > 0 then
				local fCount = 0
				local viewLog = {}
				for k, v in ipairs(logConnect) do
					if logConFilter.v:len() > 0 then
						if string.find(string.rlower(v), string.rlower(u8:decode(logConFilter.v)), 1, true) then
							table.insert(viewLog, v)
							fCount = fCount + 1
						end
					else
						table.insert(viewLog, v)
					end
				end
				local clipper = imgui.ImGuiListClipper(#viewLog)
				while clipper:Step() do
					for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
						imgui.Text(u8(viewLog[i]))
						if (imgui.IsItemClicked(0) or imgui.IsItemClicked(1)) and (logConFilter.v:len() == 0 or fCount > 0) then
							setClipboardText(viewLog[i])
						end
					end
				end
				if logConFilter.v:len() > 0 and fCount == 0 then
					imgui.Text(u8"Совпадения не найдены ...")
				end
			else
				imgui.Text(u8"Журнал пуст ...")
			end
			if ScrollToButton then
				imgui.SetScrollHere()
				ScrollToButton = false
			end
			imgui.PopStyleVar()
			imgui.EndChild()
			imgui.End()
			imgui.PopStyleVar()
		end
		if allset.set.type == 0 then
			x, y = ToScreen(160, 90)
			w, h = ToScreen(480, 358)
			if bConnectLog.v then
				x = x + xOffset / 2
				w = w + xOffset / 2
			end
		elseif allset.set.type == 1 then
			x, y = ToScreen(130, 60)
			w, h = ToScreen(510, 388)
			if bConnectLog.v then
				x = x + xOffset / 2
				w = w + xOffset / 2
			end
		elseif allset.set.type == 2 then
			x, y = ToScreen(100, 30)
			w, h = ToScreen(540, 418)
			if bConnectLog.v then
				x = x + xOffset / 2
				w = w + xOffset / 2
			end
		elseif allset.set.type == 3 then
			if bConnectLog.v then
				x, y = ToScreen(181, 0)
				w, h = ToScreen(640, 448)
			else
				x, y = ToScreen(0, 0)
				w, h = ToScreen(640, 448)
			end
		end
		imgui.SetNextWindowPos(imgui.ImVec2(x, y), _, imgui.ImVec2(0.0, 0.0))
		imgui.SetNextWindowSize(imgui.ImVec2(w-x , h-y))
		local servername = u8(sampGetCurrentServerName())
		imgui.PushFont(sFont[tonumber(sizesFont[allset.set.fontSize + 1])])
		imgui.Begin(servername, show_main_window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoScrollbar + (bTitlebar.v > 0 and imgui.WindowFlags.NoTitleBar or 0))

		local snSize
		if bTitlebar.v == 1 then
			snSize = imgui.CalcTextSize(servername)
		end
		imgui.SetCursorPos(imgui.ImVec2(bTitlebar.v == 1 and ((w-x) / 2) - (snSize.x / 2) or 6, bTitlebar.v == 0 and 24 or 3))
		if bTitlebar.v == 1 then
			imgui.Text(servername)
			imgui.Separator()
		end
		imgui.AlignTextToFramePadding()
		imgui.Indent(4); imgui.Text(u8('Всего: ' .. sampGetPlayerCount(false) .. ' | Рядом: ' .. sampGetPlayerCount(true)-1))
		local bText = u8"Настройки"
		local sText = u8"Поиск игроков"
		local stText = u8"В зоне стрима"
		local bSize = imgui.CalcTextSize(bText)
		local sSize = imgui.CalcTextSize(sText)
		local stSize = imgui.CalcTextSize(stText)
		local cColumns = 4
		if streamCheck.v then
			cColumns = cColumns + 2
		end
		if cNType.v == 1 then
			cColumns = cColumns + 1
		end
		if cFilter.v > 0 then
			cColumns = cColumns + 1
		end
		-- Search
		imgui.SameLine(w-x-155)
		imgui.PushItemWidth(150)
		imgui.PushAllowKeyboardFocus(false)
		imgui.InputText("##search", searchBuf, imgui.InputTextFlags.EnterReturnsTrue + imgui.InputTextFlags.CharsNoBlank)
		local iSize = imgui.GetItemRectSize()
		imgui.PopAllowKeyboardFocus()
		imgui.PopItemWidth()
		if not imgui.IsItemActive() and #searchBuf.v == 0 then
			local r, g, b, a = imgui.ImColor(colors[1]):GetRGBA()
			imgui.SameLine(w-x-153)
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImColor(r, g, b, 180):GetVec4())
			imgui.Text(sText)
			imgui.PopStyleColor()
		end
		-- Button
		imgui.SameLine(w-x-(bSize.x + 155 + 9))
		if imgui.Button(bText) then
			show_set_window.v = not show_set_window.v
		end
		-- Combo
		imgui.SameLine(w-x-(bSize.x + 155 + 115 + 9))
		imgui.PushItemWidth(110)
		if imgui.Combo("##PlayerListFilter", cFilter, {u8"Без групп", u8"Все игроки", u8"Друзья", u8"Админы", u8"Враги", u8"С маркером"}) then
			allset.set.list = cFilter.v
		end
		imgui.PopItemWidth()
		-- Checkbox
		imgui.SameLine(w-x-(stSize.x + bSize.x + 155 + 115 + 9 + 30))
		if imgui.Checkbox(stText, streamCheck) then
			allset.set.streamcheck = streamCheck.v
		end

		imgui.Columns(cColumns)
		imgui.Separator()
		imgui.NewLine()
		imgui.SameLine(2)
		imgui.SetColumnWidth(-1, 32); imgui.Text('ID'); imgui.NextColumn()
		imgui.SetColumnWidth(-1, w-x-(streamCheck.v and 280 or 160)-(cFilter.v > 0 and 70 or 0)-(cNType.v == 1 and 90 or 0)); imgui.Text(u8'Никнейм'); imgui.NextColumn()
		if cFilter.v > 0 then
			imgui.SetColumnWidth(-1, 70); imgui.Text(u8'Группа'); imgui.NextColumn()
		end
		if streamCheck.v then
			imgui.SetColumnWidth(-1, 40); imgui.Text(u8'Афк'); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 80); imgui.Text(u8'Дистанция'); imgui.NextColumn()
		end
		if cNType.v == 1 then
			imgui.SetColumnWidth(-1, 90); imgui.Text(u8'Цвет'); imgui.NextColumn()
		end
		imgui.SetColumnWidth(-1, 70); imgui.Text(u8'Счет'); imgui.NextColumn()
		imgui.SetColumnWidth(-1, 70); imgui.Text(u8'Пинг'); imgui.NextColumn()
		imgui.Columns(1)
		imgui.Separator()
		imgui.BeginChild("##scroll", imgui.ImVec2(0, 0), false)
		imgui.Columns(cColumns)
		imgui.SetColumnWidth(-1, 32);imgui.NextColumn()
		imgui.SetColumnWidth(-1, w-x-(streamCheck.v and 280 or 160)-(cFilter.v > 0 and 70 or 0)-(cNType.v == 1 and 70 or 0)); imgui.NextColumn()
		if cFilter.v > 0 then
			imgui.SetColumnWidth(-1, 70); imgui.NextColumn()
		end
		if streamCheck.v then
			imgui.SetColumnWidth(-1, 40); imgui.NextColumn()
			imgui.SetColumnWidth(-1, 80); imgui.NextColumn()
		end
		if cNType.v == 1 then
			imgui.SetColumnWidth(-1, 90); imgui.NextColumn()
		end
		imgui.SetColumnWidth(-1, 70);imgui.NextColumn()
		imgui.SetColumnWidth(-1, 70); imgui.NextColumn()
		local local_player_id = getLocalPlayerId()
		if(#searchBuf.v < 1 and not streamCheck.v and cFilter.v < 2) then
			drawScoreboardPlayer(local_player_id)
		else
			if (string.find(sampGetPlayerNickname(local_player_id):lower(), searchBuf.v:lower(), 1, true) or local_player_id == tonumber(searchBuf.v)) and not streamCheck.v and cFilter.v < 2 then
				drawScoreboardPlayer(local_player_id)
			end
		end
		local viewPlayers = {}
		for i = 0, sampGetMaxPlayerId(false) do
			if local_player_id ~= i and sampIsPlayerConnected(i) and (not bNpcShow.v and not sampIsPlayerNpc(i) or bNpcShow.v) then
				local isInStream = sampGetCharHandleBySampPlayerId(i)
				if(#searchBuf.v > 0) then
					if(string.find(sampGetPlayerNickname(i):lower(), searchBuf.v:lower(), 1, true) or i == tonumber(searchBuf.v))then
						if not streamCheck.v or (streamCheck.v and isInStream) then
							local nickname = encoding.UTF8(sampGetPlayerNickname(i))
							local group, gId = getPlayerSGroup(nickname)
							if not ((cFilter.v > 1 and cFilter.v < 5 and gId ~= cFilter.v - 1) or (cFilter.v == 5 and pMarker[i] == nil)) then
								table.insert(viewPlayers, i)
							end
						end
					end
				else
					if not streamCheck.v or (streamCheck.v and isInStream) then
						local nickname = encoding.UTF8(sampGetPlayerNickname(i))
						local group, gId = getPlayerSGroup(nickname)
						if not ((cFilter.v > 1 and cFilter.v < 5 and gId ~= cFilter.v - 1) or (cFilter.v == 5 and pMarker[i] == nil)) then
							table.insert(viewPlayers, i)
						end
					end
				end
			end
		end
		if #viewPlayers > 0 then
			local clipper = imgui.ImGuiListClipper(#viewPlayers)
			while clipper:Step() do
				for i = clipper.DisplayStart + 1, clipper.DisplayEnd do
					drawScoreboardPlayer(viewPlayers[i])
				end
			end
		end

		imgui.Columns(1)
		if(playerCount == 0)then
			imgui.SameLine(5.0); imgui.Text(u8"Список пуст ...")
		end
		imgui.Separator()
		imgui.EndChild()

		imgui.End()
		imgui.PopFont()
	end
end

function getPlayerSGroup(name)
	local name = tostring(name)
	if #name < 1 then
		return nil
	end
	local group, groupId = nil, 0
	if groups.friend[name] then
		group = "Друг"
		groupId = 1
	elseif groups.admin[name] then
		group = "Админ"
		groupId = 2
	elseif groups.enemy[name] then
		group = "Враг"
		groupId = 3
	end
	return group, groupId
end

function getDistanceToPlayer(playerId)
	if sampIsPlayerConnected(playerId) then
		local result, ped = sampGetCharHandleBySampPlayerId(playerId)
		if result and doesCharExist(ped) then
			local myX, myY, myZ = getCharCoordinates(playerPed)
			local playerX, playerY, playerZ = getCharCoordinates(ped)
			return getDistanceBetweenCoords3d(myX, myY, myZ, playerX, playerY, playerZ)
		end
	end
	return nil
end

function drawScoreboardPlayer(id)
	local pop
	local playerInStream, ped = sampGetCharHandleBySampPlayerId(id)
	local nickname = encoding.UTF8(sampGetPlayerNickname(id))
	local group, gId = getPlayerSGroup(nickname)
	local score = sampGetPlayerScore(id)
	local ping = sampGetPlayerPing(id)
	local color = sampGetPlayerColor(id)
	local health = playerInStream and tostring(sampGetPlayerHealth(id)) or "-"
	local armor = playerInStream and tostring(sampGetPlayerArmor(id)) or "-"
	local model = playerInStream and tostring(getCharModel(ped)) or "-"
	local speed = playerInStream and tostring(math.floor(getCharSpeed(ped))) or "-"
	local distance = getDistanceToPlayer(id)
	local r, g, b = bitex.bextract(color, 16, 8), bitex.bextract(color, 8, 8), bitex.bextract(color, 0, 8)
	local imgui_RGBA = imgui.ImVec4(r / 255.0, g / 255.0, b / 255.0, 1)
	playerCount = playerCount + 1
	imgui.NewLine()
	imgui.SameLine(2)
	if imgui.Selectable(tostring(id), id == focusId, imgui.SelectableFlags.SpanAllColumns + imgui.SelectableFlags.AllowDoubleClick) then
		if imgui.IsMouseDoubleClicked(0) then
			sampSendClickPlayer(id, 0)
			lua_thread.create(function ()
				wait(150)
				toggleScoreboard(false)
			end)
		else
			focusId = focusId == id and -1 or id
		end
	end

	imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 3.0))
	if id ~= getLocalPlayerId() and imgui.BeginPopupContextItem() then
		imgui.BeginChild("##pMenu", imgui.ImVec2(150, 138))
		pop = true
		imgui.TextColored(imgui_RGBA, nickname .. "[" .. id .. "]")
		local btnSize = imgui.ImVec2(-0.001, 0.0)
		imgui.Separator()
		if id ~= getLocalPlayerId() then
			bMarkPlayer.v = pMarker[id] and true or false
			if imgui.Checkbox(u8"Показать маркер", bMarkPlayer) then
				if pMarker[id] then
					if doesBlipExist(pMarker[id]) then
						removeBlip(pMarker[id])
					end
					mColor[pMarker[id]] = nil
					pMarker[id] = nil
					sampAddChatMessage(tag .. "Маркер игрока " .. nickname .. " удален")
				elseif playerInStream then
					pMarker[id] = addBlipForChar(ped)
					local mCol = alpha255(color)
					changeBlipColour(pMarker[id], mCol)
					mColor[pMarker[id]] = color
					changeBlipDisplay(pMarker[id], 3)
					setBlipAlwaysDisplayOnZoomedRadar(pMarker[id], true)
					sampAddChatMessage(tag .. "Маркер игрока " .. nickname .. " установлен" )
				else
					pMarker[id] = -1
					sampAddChatMessage(tag .. "Игрока " .. nickname .. " сейчас нет рядом. Маркер будет установлен при поялении игрока в зоне стрима.")
				end
				imgui.CloseCurrentPopup()
			end
			if imgui.Button(u8'Следить', btnSize) then
				imgui.CloseCurrentPopup()
				toggleScoreboard(false)
				sampSendChat("/re " .. id)
			end
			if imgui.Button(u8'Забанить', btnSize) then
				imgui.CloseCurrentPopup()
				toggleScoreboard(false)
				sampSetChatInputText("/ban " .. id .. " ")
				sampSetChatInputEnabled(true)
			end
			if imgui.Button(u8'Кикнуть', btnSize) then
				imgui.CloseCurrentPopup()
				toggleScoreboard(false)
				sampSetChatInputText("/kick " .. id .. " ")
				sampSetChatInputEnabled(true)
			end
			if imgui.Button(u8'Посадить', btnSize) then
				imgui.CloseCurrentPopup()
				toggleScoreboard(false)
				sampSetChatInputText("/jail " .. id .. " ")
				sampSetChatInputEnabled(true)
			end
			if imgui.Button(u8'Замутить', btnSize) then
				imgui.CloseCurrentPopup()
				toggleScoreboard(false)
				sampSetChatInputText("/mute " .. id .. " ")
				sampSetChatInputEnabled(true)
			end
		end
		if imgui.Button(u8'Копировать никнейм', btnSize) then
			setClipboardText(nickname)
			imgui.CloseCurrentPopup()
		end
		imgui.Text(u8"Группа игрока:")
		imgui.PushItemWidth(-0.001)
		_, cSetGroup.v = getPlayerSGroup(nickname)
		if imgui.Combo("##cSetGroup", cSetGroup, {u8"Без группы", u8"Друг", u8"Админ", u8"Враг"}) then
			if cSetGroup.v == 0 then
				groups.friend[tostring(nickname)] = nil
				groups.admin[tostring(nickname)] = nil
				groups.enemy[tostring(nickname)] = nil
			elseif cSetGroup.v == 1 then
				groups.friend[tostring(nickname)] = true
				groups.admin[tostring(nickname)] = nil
				groups.enemy[tostring(nickname)] = nil
			elseif cSetGroup.v == 2 then
				groups.friend[tostring(nickname)] = nil
				groups.admin[tostring(nickname)] = true
				groups.enemy[tostring(nickname)] = nil
			elseif cSetGroup.v == 3 then
				groups.friend[tostring(nickname)] = nil
				groups.admin[tostring(nickname)] = nil
				groups.enemy[tostring(nickname)] = true
			end
			imgui.CloseCurrentPopup()
		end
		imgui.PopItemWidth()
		imgui.EndChild()
		imgui.EndPopup()
	else
		pop = false
	end
	imgui.PopStyleVar()
	if imgui.IsItemHovered() and not pop and id ~= getLocalPlayerId() then
		imgui.BeginTooltip();
		imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(4.0, 3.0))
		imgui.PushStyleVar(imgui.StyleVar.ItemSpacing, imgui.ImVec2(4.0, 2.0))
		imgui.BeginChild("##Test", imgui.ImVec2(157, (tonumber(sizesFont[allset.set.fontSize + 1]) + 2) * 7 + 7), true)
		imgui.Text(nickname .. "[" .. id .. "]")
		imgui.Separator()
		imgui.Text(u8(string.format("В зоне стрима: %s", playerInStream and "Да" or "Нет")))
		imgui.Text(u8(string.format("Афк: %s", playerInStream and (sampIsPlayerPaused(id) and "Да" or "Нет") or "-")))
		imgui.Text(u8(string.format("Жизни: %s", health)))
		imgui.Text(u8(string.format("Броня: %s", armor)))
		imgui.Text(u8(string.format("Скин: %s", model)))
		imgui.Text(u8(string.format("Скорость: %s", speed)))
		imgui.EndChild()
		imgui.Separator()
		imgui.PopStyleVar(2)
		imgui.EndTooltip();
	end

	imgui.NextColumn()

	if cNType.v == 0 then
		imgui.TextColored(imgui_RGBA, nickname)
	else
		imgui.Text(nickname)
	end
	imgui.NextColumn()
	if allset.set.list > 0 then
		if gId == 0 then
			imgui.Text(u8("-"))
		else
			local color
			if gId == 1 then
				color = imgui.ImColor(10, 140, 10, 255):GetVec4()
			elseif gId == 2 then
				color = imgui.ImColor(230, 230, 10, 255):GetVec4()
			elseif gId == 3 then
				color = imgui.ImColor(180, 10, 10, 255):GetVec4()
			end
			imgui.TextColored(color, u8(group))
		end
		imgui.NextColumn()
	end
	if streamCheck.v then
		imgui.Text(sampIsPlayerPaused(id) and u8"Да" or u8"Нет"); imgui.NextColumn()
		imgui.Text(string.format("%0.1f", distance)); imgui.NextColumn()
	end
	if cNType.v == 1 then
		imgui.TextColored(imgui_RGBA, "0x" .. string.upper(string.format("%0.8s", bit.tohex(color)))); imgui.NextColumn()
	end
	imgui.Text(tostring(score)); imgui.NextColumn()
	imgui.Text(tostring(ping)); imgui.NextColumn()

	if scrollToId and focusId > -1 and focusId == id then
		scrollToId = false
		imgui.SetScrollHere(0.43)
	end
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		for k, v in pairs(pMarker) do
			if doesBlipExist(v) then
				removeBlip(v)
			end
		end
		if not doesDirectoryExist("moonloader\\config") then
			createDirectory("moonloader\\config")
		end
		if notThems then
			inicfg.save(cfg, "..\\resource\\scoreboard\\main\\data.ini")
			notThems = false
		else
			inicfg.save(cfg, "..\\resource\\scoreboard\\" .. allset.set.curTheme .. "\\data.ini")
		end
		inicfg.save(allset, "..\\config\\AdminTool\\scoreboard")
		inicfg.save(groups, "..\\config\\AdminTool\\playergroupscoreboard.ini")
	end
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
function SE.onPlayerJoin(id, color, isNpc, nickname)
	if gameInit then
		addConLog(string.format("%s[%d] подключился", nickname, id))
	end
end
function SE.onPlayerQuit(id, reason)
	if gameInit then
		addConLog(string.format("%s[%d] %s", sampGetPlayerNickname(id), id, quitReason[reason+1]))
	end
end
function SE.onRequestClassResponse()
	gameInit = true
end
function SE.onShowDialog()
	gameInit = true
end
function SE.onServerMessage()
	gameInit = true
end
function addConLog(string)
	logConnect[#logConnect+1] = string.format("[%s] %s", os.date("%H:%M:%S"), string)
end
function explode_color(color)
	local a = bit.band(bit.rshift(color, 24), 0xFF)
	local r = bit.band(bit.rshift(color, 16), 0xFF)
	local g = bit.band(bit.rshift(color, 8), 0xFF)
	local b = bit.band(color, 0xFF)
	return a, r, g, b
 end

 function join_color(a, r, g, b)
	local color = b  -- b
	color = bit.bor(color, bit.lshift(g, 8))  -- g
	color = bit.bor(color, bit.lshift(r, 16)) -- r
	color = bit.bor(color, bit.lshift(a, 24)) -- a
	return color
 end

 function convertARGBToRGBA(color)
	local color = tonumber(color)
	local a, r, g, b = explode_color(color)
	return join_color(r, g, b, a)
end

function convertRGBAToARGB(color)
	local color = tonumber(color)
	local r, g, b, a = explode_color(color)
	return join_color(a, r, g, b)
end
function alpha255(color)
	local color = tonumber(color)
	local a, r, g, b = explode_color(color)
	return join_color(r, g, b, 255)
end

function EXPORTS.ActivetedScoreboard()
	if not show_main_window.v then
		if not sampIsChatInputActive() then
			toggleScoreboard(true)
		end
	else
		toggleScoreboard(false)
	end
end

function salat()
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

    colors[clr.FrameBg]                = ImVec4(0.42, 0.48, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.85, 0.98, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.85, 0.98, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.42, 0.48, 0.16, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.42, 0.48, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.42, 0.48, 0.16, 1.00)
    colors[clr.CheckMark]              = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.77, 0.88, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.85, 0.98, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.82, 0.98, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.85, 0.98, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.85, 0.98, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.85, 0.98, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.63, 0.75, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.63, 0.75, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.85, 0.98, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.85, 0.98, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.85, 0.98, 0.26, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.85, 0.98, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function blackred()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2

    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 6
    style.ChildWindowRounding = 5
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 10.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 8
    style.GrabRounding = 1
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)

    colors[clr.Text]                   = ImVec4(0.95, 0.96, 0.98, 1.00);
    colors[clr.TextDisabled]           = ImVec4(0.29, 0.29, 0.29, 1.00);
    colors[clr.WindowBg]               = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.ChildWindowBg]          = ImVec4(0.12, 0.12, 0.12, 1.00);
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[clr.Border]                 = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.BorderShadow]           = ImVec4(1.00, 1.00, 1.00, 0.10);
    colors[clr.FrameBg]                = ImVec4(0.22, 0.22, 0.22, 1.00);
    colors[clr.FrameBgHovered]         = ImVec4(0.18, 0.18, 0.18, 1.00);
    colors[clr.FrameBgActive]          = ImVec4(0.09, 0.12, 0.14, 1.00);
    colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrab]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.SliderGrabActive]       = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.Button]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ButtonHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ButtonActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.Header]                 = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.HeaderHovered]          = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.HeaderActive]           = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.ResizeGrip]             = ImVec4(1.00, 0.28, 0.28, 1.00);
    colors[clr.ResizeGripHovered]      = ImVec4(1.00, 0.39, 0.39, 1.00);
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 0.19, 0.19, 1.00);
    colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[clr.PlotHistogram]          = ImVec4(1.00, 0.21, 0.21, 1.00);
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.18, 0.18, 1.00);
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 0.32, 0.32, 1.00);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
end

function violet()
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

    colors[clr.FrameBg]                = ImVec4(0.442, 0.115, 0.718, 0.540)
    colors[clr.FrameBgHovered]         = ImVec4(0.389, 0.190, 0.718, 0.400)
    colors[clr.FrameBgActive]          = ImVec4(0.441, 0.125, 0.840, 0.670)
    colors[clr.TitleBg]                = ImVec4(0.557, 0.143, 0.702, 1.000)
    colors[clr.TitleBgActive]          = ImVec4(0.557, 0.143, 0.702, 1.000)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.557, 0.143, 0.702, 1.000)
    colors[clr.CheckMark]              = ImVec4(0.643, 0.190, 0.862, 1.000)
    colors[clr.SliderGrab]             = ImVec4(0.434, 0.100, 0.757, 1.000)
    colors[clr.SliderGrabActive]       = ImVec4(0.434, 0.100, 0.757, 1.000)
    colors[clr.Button]                 = ImVec4(0.423, 0.142, 0.829, 1.000)
    colors[clr.ButtonHovered]          = ImVec4(0.508, 0.000, 1.000, 1.000)
    colors[clr.ButtonActive]           = ImVec4(0.508, 0.000, 1.000, 1.000)
    colors[clr.Header]                 = ImVec4(0.628, 0.098, 0.884, 0.310)
    colors[clr.HeaderHovered]          = ImVec4(0.695, 0.000, 0.983, 0.800)
    colors[clr.HeaderActive]           = ImVec4(0.695, 0.000, 0.983, 0.800)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.644, 0.021, 0.945, 0.800)
    colors[clr.ResizeGripHovered]      = ImVec4(0.644, 0.021, 0.945, 0.800)
    colors[clr.ResizeGripActive]       = ImVec4(0.644, 0.021, 0.945, 0.800)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function blue()
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

    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function brown()
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

   colors[clr.FrameBg]                = ImVec4(0.48, 0.23, 0.16, 0.54)
   colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.43, 0.26, 0.40)
   colors[clr.FrameBgActive]          = ImVec4(0.98, 0.43, 0.26, 0.67)
   colors[clr.TitleBg]                = ImVec4(0.48, 0.23, 0.16, 1.00)
   colors[clr.TitleBgActive]          = ImVec4(0.48, 0.23, 0.16, 1.00)
   colors[clr.TitleBgCollapsed]       = ImVec4(0.48, 0.23, 0.16, 1.00)
   colors[clr.CheckMark]              = ImVec4(0.98, 0.43, 0.26, 1.00)
   colors[clr.SliderGrab]             = ImVec4(0.88, 0.39, 0.24, 1.00)
   colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.43, 0.26, 1.00)
   colors[clr.Button]                 = ImVec4(0.98, 0.43, 0.26, 0.40)
   colors[clr.ButtonHovered]          = ImVec4(0.98, 0.43, 0.26, 1.00)
   colors[clr.ButtonActive]           = ImVec4(0.98, 0.28, 0.06, 1.00)
   colors[clr.Header]                 = ImVec4(0.98, 0.43, 0.26, 0.31)
   colors[clr.HeaderHovered]          = ImVec4(0.98, 0.43, 0.26, 0.80)
   colors[clr.HeaderActive]           = ImVec4(0.98, 0.43, 0.26, 1.00)
   colors[clr.Separator]              = colors[clr.Border]
   colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.25, 0.10, 0.78)
   colors[clr.SeparatorActive]        = ImVec4(0.75, 0.25, 0.10, 1.00)
   colors[clr.ResizeGrip]             = ImVec4(0.98, 0.43, 0.26, 0.25)
   colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.43, 0.26, 0.67)
   colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.43, 0.26, 0.95)
   colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
   colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.50, 0.35, 1.00)
   colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.43, 0.26, 0.35)
   colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
   colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
   colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
   colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
   colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
   colors[clr.ComboBg]                = colors[clr.PopupBg]
   colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
   colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
   colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
   colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
   colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
   colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
   colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
   colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
   colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
   colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
   colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
   colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
   colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function red()
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

    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function blackblue()
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

    colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end	

function skyblue()
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

	colors[clr.Text]   				= ImVec4(0.00, 0.00, 0.00, 0.51)
	colors[clr.TextDisabled]   		= ImVec4(0.24, 0.24, 0.24, 1.00)
	colors[clr.WindowBg]              = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.ChildWindowBg]         = ImVec4(0.96, 0.96, 0.96, 1.00)
	colors[clr.PopupBg]               = ImVec4(0.92, 0.92, 0.92, 1.00)
	colors[clr.Border]                = ImVec4(0.86, 0.86, 0.86, 1.00)
	colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]               = ImVec4(0.88, 0.88, 0.88, 1.00)
	colors[clr.FrameBgHovered]        = ImVec4(0.82, 0.82, 0.82, 1.00)
	colors[clr.FrameBgActive]         = ImVec4(0.76, 0.76, 0.76, 1.00)
	colors[clr.TitleBg]               = ImVec4(0.00, 0.45, 1.00, 0.82)
	colors[clr.TitleBgCollapsed]      = ImVec4(0.00, 0.45, 1.00, 0.82)
	colors[clr.TitleBgActive]         = ImVec4(0.00, 0.45, 1.00, 0.82)
	colors[clr.MenuBarBg]             = ImVec4(0.00, 0.37, 0.78, 1.00)
	colors[clr.ScrollbarBg]           = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ScrollbarGrab]         = ImVec4(0.00, 0.35, 1.00, 0.78)
	colors[clr.ScrollbarGrabHovered]  = ImVec4(0.00, 0.33, 1.00, 0.84)
	colors[clr.ScrollbarGrabActive]   = ImVec4(0.00, 0.31, 1.00, 0.88)
	colors[clr.ComboBg]               = ImVec4(0.92, 0.92, 0.92, 1.00)
	colors[clr.CheckMark]             = ImVec4(0.00, 0.49, 1.00, 0.59)
	colors[clr.SliderGrab]            = ImVec4(0.00, 0.49, 1.00, 0.59)
	colors[clr.SliderGrabActive]      = ImVec4(0.00, 0.39, 1.00, 0.71)
	colors[clr.Button]                = ImVec4(0.00, 0.49, 1.00, 0.59)
	colors[clr.ButtonHovered]         = ImVec4(0.00, 0.49, 1.00, 0.71)
	colors[clr.ButtonActive]          = ImVec4(0.00, 0.49, 1.00, 0.78)
	colors[clr.Header]                = ImVec4(0.00, 0.49, 1.00, 0.78)
	colors[clr.HeaderHovered]         = ImVec4(0.00, 0.49, 1.00, 0.71)
	colors[clr.HeaderActive]          = ImVec4(0.00, 0.49, 1.00, 0.78)
	colors[clr.ResizeGrip]            = ImVec4(0.00, 0.39, 1.00, 0.59)
	colors[clr.ResizeGripHovered]     = ImVec4(0.00, 0.27, 1.00, 0.59)
	colors[clr.ResizeGripActive]      = ImVec4(0.00, 0.25, 1.00, 0.63)
	colors[clr.CloseButton]           = ImVec4(0.00, 0.35, 0.96, 0.71)
	colors[clr.CloseButtonHovered]    = ImVec4(0.00, 0.31, 0.88, 0.69)
	colors[clr.CloseButtonActive]     = ImVec4(0.00, 0.25, 0.88, 0.67)
	colors[clr.PlotLines]             = ImVec4(0.00, 0.39, 1.00, 0.75)
	colors[clr.PlotLinesHovered]      = ImVec4(0.00, 0.39, 1.00, 0.75)
	colors[clr.PlotHistogram]         = ImVec4(0.00, 0.39, 1.00, 0.75)
	colors[clr.PlotHistogramHovered]  = ImVec4(0.00, 0.35, 0.92, 0.78)
	colors[clr.TextSelectedBg]        = ImVec4(0.00, 0.47, 1.00, 0.59)
	colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35)
end

function royalblue()
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

	colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.60, 0.60, 0.60, 1.00)
	colors[clr.WindowBg] = ImVec4(0.11, 0.10, 0.11, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PopupBg] = ImVec4(0.30, 0.30, 0.30, 1.00)
	colors[clr.Border] = ImVec4(0.86, 0.86, 0.86, 1.00)
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ImVec4(0.21, 0.20, 0.21, 0.60)
	colors[clr.FrameBgHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.TitleBgActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.00, 0.46, 0.65, 0.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.00, 0.46, 0.65, 0.44)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.00, 0.46, 0.65, 0.74)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ComboBg] = ImVec4(0.15, 0.14, 0.15, 1.00)
	colors[clr.CheckMark] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.SliderGrab] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.SliderGrabActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.Button] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.Header] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.00, 0.46, 0.65, 1.00)
	colors[clr.ResizeGrip] = ImVec4(1.00, 1.00, 1.00, 0.30)
	colors[clr.ResizeGripHovered] = ImVec4(1.00, 1.00, 1.00, 0.60)
	colors[clr.ResizeGripActive] = ImVec4(1.00, 1.00, 1.00, 0.90)
	colors[clr.CloseButton] = ImVec4(1.00, 0.10, 0.24, 0.00)
	colors[clr.CloseButtonHovered] = ImVec4(0.00, 0.10, 0.24, 0.00)
	colors[clr.CloseButtonActive] = ImVec4(1.00, 0.10, 0.24, 0.00)
	colors[clr.PlotLines] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotLinesHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotHistogram] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.PlotHistogramHovered] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.TextSelectedBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ModalWindowDarkening] = ImVec4(0.00, 0.00, 0.00, 0.00)
end

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

function black() 
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
	colors[clr.Text] = ImVec4(0.80, 0.80, 0.83, 1.00) 
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00) 
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00) 
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00) 
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00) 
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88) 
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00) 
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00) 
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00) 
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00) 
	colors[clr.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00) 
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75) 
	colors[clr.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00) 
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00) 
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00) 
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31) 
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00) 
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00) 
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00) 
	colors[clr.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31) 
	colors[clr.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31) 
	colors[clr.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00) 
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00) 
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00) 
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00) 
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00) 
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00) 
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00) 
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00) 
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00) 
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00) 
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16) 
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39) 
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00) 
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63) 
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00) 
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63) 
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00) 
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43) 
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73) 
end 

function white()
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
	colors[clr.Text] = ImVec4(0.00, 0.00, 0.00, 1.00); 
	colors[clr.TextDisabled] = ImVec4(0.50, 0.50, 0.50, 1.00); 
	colors[clr.WindowBg] = ImVec4(0.86, 0.86, 0.86, 1.00); 
	colors[clr.ChildWindowBg] = ImVec4(0.71, 0.71, 0.71, 1.00);
	colors[clr.PopupBg] = ImVec4(0.79, 0.79, 0.79, 1.00); 
	colors[clr.Border] = ImVec4(0.00, 0.00, 0.00, 0.36); 
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.10); 
	colors[clr.FrameBg] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.FrameBgHovered] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.FrameBgActive] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.TitleBg] = ImVec4(1.00, 1.00, 1.00, 0.81); 
	colors[clr.TitleBgActive] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 1.00, 1.00, 0.51); 
	colors[clr.MenuBarBg] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.ScrollbarBg] = ImVec4(1.00, 1.00, 1.00, 0.86); 
	colors[clr.ScrollbarGrab] = ImVec4(0.37, 0.37, 0.37, 1.00); 
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.60, 0.60, 0.60, 1.00); 
	colors[clr.ScrollbarGrabActive] = ImVec4(0.21, 0.21, 0.21, 1.00); 
	colors[clr.ComboBg] = ImVec4(0.61, 0.61, 0.61, 1.00); 
	colors[clr.CheckMark] = ImVec4(0.42, 0.42, 0.42, 1.00); 
	colors[clr.SliderGrab] = ImVec4(0.51, 0.51, 0.51, 1.00); 
	colors[clr.SliderGrabActive] = ImVec4(0.65, 0.65, 0.65, 1.00); 
	colors[clr.Button] = ImVec4(0.52, 0.52, 0.52, 0.83); 
	colors[clr.ButtonHovered] = ImVec4(0.58, 0.58, 0.58, 0.83); 
	colors[clr.ButtonActive] = ImVec4(0.44, 0.44, 0.44, 0.83); 
	colors[clr.Header] = ImVec4(0.65, 0.65, 0.65, 1.00); 
	colors[clr.HeaderHovered] = ImVec4(0.73, 0.73, 0.73, 1.00); 
	colors[clr.HeaderActive] = ImVec4(0.53, 0.53, 0.53, 1.00); 
	colors[clr.Separator] = ImVec4(0.46, 0.46, 0.46, 1.00); 
	colors[clr.SeparatorHovered] = ImVec4(0.45, 0.45, 0.45, 1.00); 
	colors[clr.SeparatorActive] = ImVec4(0.45, 0.45, 0.45, 1.00); 
	colors[clr.ResizeGrip] = ImVec4(0.23, 0.23, 0.23, 1.00); 
	colors[clr.ResizeGripHovered] = ImVec4(0.32, 0.32, 0.32, 1.00); 
	colors[clr.ResizeGripActive] = ImVec4(0.14, 0.14, 0.14, 1.00); 
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16); 
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39); 
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00); 
	colors[clr.PlotLines] = ImVec4(0.61, 0.61, 0.61, 1.00); 
	colors[clr.PlotLinesHovered] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.PlotHistogram] = ImVec4(0.70, 0.70, 0.70, 1.00); 
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.TextSelectedBg] = ImVec4(0.62, 0.62, 0.62, 1.00); 
	colors[clr.ModalWindowDarkening] = ImVec4(0.26, 0.26, 0.26, 0.60); 
end

function banana()
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

	colors[clr.Text] = ImVec4(0.00, 0.00, 0.00, 1.00) 
	colors[clr.TextDisabled] = ImVec4(1.00, 0.06, 0.00, 1.00) 
	colors[clr.WindowBg] = ImVec4(1.00, 0.99, 0.97, 0.81) 
	colors[clr.ChildWindowBg] = ImVec4(1.00, 0.03, 0.03, 0.00) 
	colors[clr.PopupBg] = ImVec4(1.00, 1.00, 1.00, 0.71) 
	colors[clr.Border] = ImVec4(0.00, 0.00, 0.00, 1.00) 
	colors[clr.BorderShadow] = ImVec4(0.00, 0.00, 0.00, 0.00) 
	colors[clr.FrameBg] = ImVec4(1.00, 0.76, 0.00, 0.63) 
	colors[clr.FrameBgHovered] = ImVec4(1.00, 0.76, 0.00, 0.63) 
	colors[clr.FrameBgActive] = ImVec4(1.00, 0.00, 0.00, 1.00) 
	colors[clr.TitleBg] = ImVec4(1.00, 0.78, 0.09, 0.63) 
	colors[clr.TitleBgActive] = ImVec4(1.00, 0.76, 0.00, 0.71) 
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.76, 0.00, 0.63) 
	colors[clr.MenuBarBg] = ImVec4(1.00, 0.76, 0.00, 0.63) 
	colors[clr.ScrollbarBg] = ImVec4(1.00, 0.75, 0.00, 0.63) 
	colors[clr.ScrollbarGrab] = ImVec4(0.40, 0.39, 0.34, 1.00) 
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.08, 0.08, 0.08, 1.00) 
	colors[clr.ScrollbarGrabActive] = ImVec4(0.02, 0.02, 0.02, 1.00) 
	colors[clr.ComboBg] = ImVec4(1.00, 0.76, 0.00, 0.63) 
	colors[clr.CheckMark] = ImVec4(0.06, 0.06, 0.06, 1.00) 
	colors[clr.SliderGrab] = ImVec4(1.00, 0.75, 0.00, 0.54) 
	colors[clr.SliderGrabActive] = ImVec4(1.00, 0.00, 0.00, 1.00) 
	colors[clr.Button] = ImVec4(1.00, 0.88, 0.00, 1.00) 
	colors[clr.ButtonHovered] = ImVec4(0.32, 1.00, 0.00, 1.00) 
	colors[clr.ButtonActive] = ImVec4(0.00, 1.00, 0.78, 1.00) 
	colors[clr.Header] = ImVec4(1.00, 0.76, 0.00, 1.00) 
	colors[clr.HeaderHovered] = ImVec4(1.00, 0.76, 0.00, 0.63) 
	colors[clr.HeaderActive] = ImVec4(1.00, 0.99, 0.04, 0.00) 
	colors[clr.Separator] = ImVec4(0.00, 0.06, 1.00, 1.00) 
	colors[clr.SeparatorHovered] = ImVec4(0.71, 0.39, 0.39, 0.54) 
	colors[clr.SeparatorActive] = ImVec4(0.71, 0.39, 0.39, 0.54) 
	colors[clr.ResizeGrip] = ImVec4(0.71, 0.39, 0.39, 0.54) 
	colors[clr.ResizeGripHovered] = ImVec4(0.84, 0.66, 0.66, 0.66) 
	colors[clr.ResizeGripActive] = ImVec4(0.84, 0.66, 0.66, 0.66) 
	colors[clr.CloseButton] = ImVec4(0.00, 0.00, 0.00, 1.00) 
	colors[clr.CloseButtonHovered] = ImVec4(0.98, 0.39, 0.36, 1.00) 
	colors[clr.CloseButtonActive] = ImVec4(0.98, 0.39, 0.36, 1.00) 
	colors[clr.PlotLines] = ImVec4(0.00, 0.01, 0.00, 1.00) 
	colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00) 
	colors[clr.PlotHistogram] = ImVec4(0.78, 0.61, 0.03, 1.00) 
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00) 
	colors[clr.TextSelectedBg] = ImVec4(0.14, 0.14, 0.14, 0.35) 
	colors[clr.ModalWindowDarkening] = ImVec4(0.18, 0.18, 0.18, 0.35)
end

function purple2() 
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

	colors[clr.FrameBg] = ImVec4(0.46, 0.11, 0.29, 1.00) 
	colors[clr.FrameBgHovered] = ImVec4(0.69, 0.16, 0.43, 1.00) 
	colors[clr.FrameBgActive] = ImVec4(0.58, 0.10, 0.35, 1.00) 
	colors[clr.TitleBg] = ImVec4(0.00, 0.00, 0.00, 1.00) 
	colors[clr.TitleBgActive] = ImVec4(0.61, 0.16, 0.39, 1.00) 
	colors[clr.TitleBgCollapsed] = ImVec4(0.00, 0.00, 0.00, 0.51) 
	colors[clr.CheckMark] = ImVec4(0.94, 0.30, 0.63, 1.00) 
	colors[clr.SliderGrab] = ImVec4(0.85, 0.11, 0.49, 1.00) 
	colors[clr.SliderGrabActive] = ImVec4(0.89, 0.24, 0.58, 1.00) 
	colors[clr.Button] = ImVec4(0.46, 0.11, 0.29, 1.00) 
	colors[clr.ButtonHovered] = ImVec4(0.69, 0.17, 0.43, 1.00) 
	colors[clr.ButtonActive] = ImVec4(0.59, 0.10, 0.35, 1.00) 
	colors[clr.Header] = ImVec4(0.46, 0.11, 0.29, 1.00) 
	colors[clr.HeaderHovered] = ImVec4(0.69, 0.16, 0.43, 1.00) 
	colors[clr.HeaderActive] = ImVec4(0.58, 0.10, 0.35, 1.00) 
	colors[clr.Separator] = ImVec4(0.69, 0.16, 0.43, 1.00) 
	colors[clr.SeparatorHovered] = ImVec4(0.58, 0.10, 0.35, 1.00) 
	colors[clr.SeparatorActive] = ImVec4(0.58, 0.10, 0.35, 1.00) 
	colors[clr.ResizeGrip] = ImVec4(0.46, 0.11, 0.29, 0.70) 
	colors[clr.ResizeGripHovered] = ImVec4(0.69, 0.16, 0.43, 0.67) 
	colors[clr.ResizeGripActive] = ImVec4(0.70, 0.13, 0.42, 1.00) 
	colors[clr.TextSelectedBg] = ImVec4(1.00, 0.78, 0.90, 0.35) 
	colors[clr.Text] = ImVec4(1.00, 1.00, 1.00, 1.00) 
	colors[clr.TextDisabled] = ImVec4(0.60, 0.19, 0.40, 1.00) 
	colors[clr.WindowBg] = ImVec4(0.06, 0.06, 0.06, 0.94) 
	colors[clr.ChildWindowBg] = ImVec4(1.00, 1.00, 1.00, 0.00) 
	colors[clr.PopupBg] = ImVec4(0.08, 0.08, 0.08, 0.94) 
	colors[clr.ComboBg] = ImVec4(0.08, 0.08, 0.08, 0.94) 
	colors[clr.Border] = ImVec4(0.49, 0.14, 0.31, 1.00) 
	colors[clr.BorderShadow] = ImVec4(0.49, 0.14, 0.31, 0.00) 
	colors[clr.MenuBarBg] = ImVec4(0.15, 0.15, 0.15, 1.00) 
	colors[clr.ScrollbarBg] = ImVec4(0.02, 0.02, 0.02, 0.53) 
	colors[clr.ScrollbarGrab] = ImVec4(0.31, 0.31, 0.31, 1.00) 
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00) 
	colors[clr.ScrollbarGrabActive] = ImVec4(0.51, 0.51, 0.51, 1.00) 
	colors[clr.CloseButton] = ImVec4(0.41, 0.41, 0.41, 0.50) 
	colors[clr.CloseButtonHovered] = ImVec4(0.98, 0.39, 0.36, 1.00) 
	colors[clr.CloseButtonActive] = ImVec4(0.98, 0.39, 0.36, 1.00) 
	colors[clr.ModalWindowDarkening] = ImVec4(0.80, 0.80, 0.80, 0.35) 
end

function yellow_green() 
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
	colors[clr.Text] = ImVec4(0.131, 0.131, 0.131, 1.000); 
	colors[clr.TextDisabled] = ImVec4(0.597, 0.597, 0.597, 1.000); 
	colors[clr.WindowBg] = ImVec4(0.15, 0.46, 0.00, 1.00); 
	colors[clr.ChildWindowBg] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.PopupBg] = ImVec4(0.15, 0.45, 0.00, 1.00); 
	colors[clr.Border] = ImVec4(1.000, 1.000, 1.000, 0.000); 
	colors[clr.BorderShadow] = ImVec4(1.000, 1.000, 1.000, 0.000); 
	colors[clr.FrameBg] = ImVec4(0.19, 0.57, 0.00, 1.00); 
	colors[clr.FrameBgHovered] = ImVec4(0.237, 0.717, 0.000, 1.000); 
	colors[clr.FrameBgActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.TitleBg] = ImVec4(1.00, 1.00, 1.00, 0.81); 
	colors[clr.TitleBgActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 1.00, 1.00, 0.51); 
	colors[clr.MenuBarBg] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.ScrollbarBg] = ImVec4(0.163, 0.497, 0.000, 1.000); 
	colors[clr.ScrollbarGrab] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.237, 0.717, 0.000, 1.000); 
	colors[clr.ScrollbarGrabActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.ComboBg] = ImVec4(0.15, 0.45, 0.00, 1.00); 
	colors[clr.CheckMark] = ImVec4(0.00, 0.00, 0.00, 1.00); 
	colors[clr.SliderGrab] = ImVec4(1.00, 1.00, 1.00, 1.00); 
	colors[clr.SliderGrabActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.Button] = ImVec4(0.19, 0.56, 0.00, 1.00); 
	colors[clr.ButtonHovered] = ImVec4(0.237, 0.717, 0.000, 1.000);
	colors[clr.ButtonActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.Header] = ImVec4(0.15, 0.45, 0.00, 1.00); 
	colors[clr.HeaderHovered] = ImVec4(0.237, 0.717, 0.000, 1.000); 
	colors[clr.HeaderActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.Separator] = ImVec4(0.50, 0.50, 0.50, 1.00); 
	colors[clr.SeparatorHovered] = ImVec4(0.237, 0.717, 0.000, 1.000); 
	colors[clr.SeparatorActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.ResizeGrip] = ImVec4(0.15, 0.45, 0.00, 1.00); 
	colors[clr.ResizeGripHovered] = ImVec4(0.237, 0.717, 0.000, 1.000); 
	colors[clr.ResizeGripActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16); 
	colors[clr.CloseButtonHovered] = ImVec4(0.237, 0.717, 0.000, 1.000); 
	colors[clr.CloseButtonActive] = ImVec4(1.000, 1.000, 1.000, 1.000); 
	colors[clr.PlotLines] = ImVec4(0.759, 0.759, 0.759, 1.000); 
	colors[clr.PlotLinesHovered] = ImVec4(0.237, 0.717, 0.000, 1.000); 
	colors[clr.PlotHistogram] = ImVec4(0.23, 0.69, 0.00, 1.00); 
	colors[clr.PlotHistogramHovered] = ImVec4(0.237, 0.717, 0.000, 1.000); 
	colors[clr.TextSelectedBg] = ImVec4(0.25, 0.73, 0.00, 1.00); 
	colors[clr.ModalWindowDarkening] = ImVec4(0.26, 0.26, 0.26, 0.60); 
end