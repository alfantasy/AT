script_name('AdminTool') -- íàçâàíèå ñêðèïòà
script_description('Ñêðèïò äëÿ îáëåã÷åíèÿ ðàáîòû àäìèíèñòðàòîðàì') -- îïèñàíèå ñêðèïòà

require "lib.moonloader" -- ïîäêëþ÷åíèå îñíîâíîé áèáëèîòåêè mooloader
local ffi 					= require "ffi" -- cïåö ñòðóêòóðà
local dlstatus 				= require('moonloader').download_status
local font_admin_chat 		= require ("moonloader").font_flag -- øðèôò äëÿ àäìèí-÷àòà
local vkeys 				= require "vkeys" -- ðåãèñòð äëÿ êíîïîê
local imgui 				= require 'imgui' -- ðåãèñòð imgui îêîí
local encoding 				= require 'encoding' -- äåøèôðîâêà ôîðìàòîâ
local inicfg 				= require 'inicfg' -- ðàáîòà ñ ini
local sampev 				= require "lib.samp.events" -- ïîäêëþ÷åíèå îñíîâíûõ áèáëèîòåê, ñâÿçàííûå ñ ïîòîêàì ïàêåòîâ èâåíòîâ SA:MP, è èõ ïðÿìîå ñîåäèíåíèå ñ LUA
local tab_board				= import ('lib/scoreboard.lua') -- ðåãèñòð äëÿ scoreboard
local notfy					= import 'lib/lib_imgui_notf.lua'
local rep_res, rep_pl 		= pcall(import, "ATreport.lua")
local plugin_res, plugin 	= pcall(import, "module/ATother.lua")
local plre_res, plre 	 	= pcall(import, "module/ATplugin.lua")
local plugin2_res, plugin2  = pcall(import, "module/ATautomute.lua")
local fa 					= require 'faicons'

local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
encoding.default = 'CP1251' -- ñìåíà êîäèðîâêè íà CP1251
u8 = encoding.UTF8 -- ïåðåèìåíîâêà ñòàíäòàðòíîãî ðåæèìà êîäèðîâêè UTF8 - u8

function imgui.BeforeDrawFrame()
	if fa_font == nil then  
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
end 	

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

ffi.cdef[[
struct stKillEntry
{
	char					szKiller[25];
	char					szVictim[25];
	uint32_t				clKillerColor; // D3DCOLOR
	uint32_t				clVictimColor; // D3DCOLOR
	uint8_t					byteType;
} __attribute__ ((packed));

struct stKillInfo
{
	int						iEnabled;
	struct stKillEntry		killEntry[5];
	int 					iLongestNickLength;
	int 					iOffsetX;
	int 					iOffsetY;
	void			    	*pD3DFont; // ID3DXFont
	void		    		*pWeaponFont1; // ID3DXFont
	void		   	    	*pWeaponFont2; // ID3DXFont
	void					*pSprite;
	void					*pD3DDevice;
	int 					iAuxFontInited;
	void 		    		*pAuxFont1; // ID3DXFont
	void 			    	*pAuxFont2; // ID3DXFont
} __attribute__ ((packed));
]]

colours = {
	-- The existing colours from San Andreas
	"0x080808FF", "0xF5F5F5FF", "0x2A77A1FF", "0x840410FF", "0x263739FF", "0x86446EFF", "0xD78E10FF", "0x4C75B7FF", "0xBDBEC6FF", "0x5E7072FF",
	"0x46597AFF", "0x656A79FF", "0x5D7E8DFF", "0x58595AFF", "0xD6DAD6FF", "0x9CA1A3FF", "0x335F3FFF", "0x730E1AFF", "0x7B0A2AFF", "0x9F9D94FF",
	"0x3B4E78FF", "0x732E3EFF", "0x691E3BFF", "0x96918CFF", "0x515459FF", "0x3F3E45FF", "0xA5A9A7FF", "0x635C5AFF", "0x3D4A68FF", "0x979592FF",
	"0x421F21FF", "0x5F272BFF", "0x8494ABFF", "0x767B7CFF", "0x646464FF", "0x5A5752FF", "0x252527FF", "0x2D3A35FF", "0x93A396FF", "0x6D7A88FF",
	"0x221918FF", "0x6F675FFF", "0x7C1C2AFF", "0x5F0A15FF", "0x193826FF", "0x5D1B20FF", "0x9D9872FF", "0x7A7560FF", "0x989586FF", "0xADB0B0FF",
	"0x848988FF", "0x304F45FF", "0x4D6268FF", "0x162248FF", "0x272F4BFF", "0x7D6256FF", "0x9EA4ABFF", "0x9C8D71FF", "0x6D1822FF", "0x4E6881FF",
	"0x9C9C98FF", "0x917347FF", "0x661C26FF", "0x949D9FFF", "0xA4A7A5FF", "0x8E8C46FF", "0x341A1EFF", "0x6A7A8CFF", "0xAAAD8EFF", "0xAB988FFF",
	"0x851F2EFF", "0x6F8297FF", "0x585853FF", "0x9AA790FF", "0x601A23FF", "0x20202CFF", "0xA4A096FF", "0xAA9D84FF", "0x78222BFF", "0x0E316DFF",
	"0x722A3FFF", "0x7B715EFF", "0x741D28FF", "0x1E2E32FF", "0x4D322FFF", "0x7C1B44FF", "0x2E5B20FF", "0x395A83FF", "0x6D2837FF", "0xA7A28FFF",
	"0xAFB1B1FF", "0x364155FF", "0x6D6C6EFF", "0x0F6A89FF", "0x204B6BFF", "0x2B3E57FF", "0x9B9F9DFF", "0x6C8495FF", "0x4D8495FF", "0xAE9B7FFF",
	"0x406C8FFF", "0x1F253BFF", "0xAB9276FF", "0x134573FF", "0x96816CFF", "0x64686AFF", "0x105082FF", "0xA19983FF", "0x385694FF", "0x525661FF",
	"0x7F6956FF", "0x8C929AFF", "0x596E87FF", "0x473532FF", "0x44624FFF", "0x730A27FF", "0x223457FF", "0x640D1BFF", "0xA3ADC6FF", "0x695853FF",
	"0x9B8B80FF", "0x620B1CFF", "0x5B5D5EFF", "0x624428FF", "0x731827FF", "0x1B376DFF", "0xEC6AAEFF", "0x000000FF",
	-- SA-MP extended colours (0.3x)
	"0x177517FF", "0x210606FF", "0x125478FF", "0x452A0DFF", "0x571E1EFF", "0x010701FF", "0x25225AFF", "0x2C89AAFF", "0x8A4DBDFF", "0x35963AFF",
	"0xB7B7B7FF", "0x464C8DFF", "0x84888CFF", "0x817867FF", "0x817A26FF", "0x6A506FFF", "0x583E6FFF", "0x8CB972FF", "0x824F78FF", "0x6D276AFF",
	"0x1E1D13FF", "0x1E1306FF", "0x1F2518FF", "0x2C4531FF", "0x1E4C99FF", "0x2E5F43FF", "0x1E9948FF", "0x1E9999FF", "0x999976FF", "0x7C8499FF",
	"0x992E1EFF", "0x2C1E08FF", "0x142407FF", "0x993E4DFF", "0x1E4C99FF", "0x198181FF", "0x1A292AFF", "0x16616FFF", "0x1B6687FF", "0x6C3F99FF",
	"0x481A0EFF", "0x7A7399FF", "0x746D99FF", "0x53387EFF", "0x222407FF", "0x3E190CFF", "0x46210EFF", "0x991E1EFF", "0x8D4C8DFF", "0x805B80FF",
	"0x7B3E7EFF", "0x3C1737FF", "0x733517FF", "0x781818FF", "0x83341AFF", "0x8E2F1CFF", "0x7E3E53FF", "0x7C6D7CFF", "0x020C02FF", "0x072407FF",
	"0x163012FF", "0x16301BFF", "0x642B4FFF", "0x368452FF", "0x999590FF", "0x818D96FF", "0x99991EFF", "0x7F994CFF", "0x839292FF", "0x788222FF",
	"0x2B3C99FF", "0x3A3A0BFF", "0x8A794EFF", "0x0E1F49FF", "0x15371CFF", "0x15273AFF", "0x375775FF", "0x060820FF", "0x071326FF", "0x20394BFF",
	"0x2C5089FF", "0x15426CFF", "0x103250FF", "0x241663FF", "0x692015FF", "0x8C8D94FF", "0x516013FF", "0x090F02FF", "0x8C573AFF", "0x52888EFF",
	"0x995C52FF", "0x99581EFF", "0x993A63FF", "0x998F4EFF", "0x99311EFF", "0x0D1842FF", "0x521E1EFF", "0x42420DFF", "0x4C991EFF", "0x082A1DFF",
	"0x96821DFF", "0x197F19FF", "0x3B141FFF", "0x745217FF", "0x893F8DFF", "0x7E1A6CFF", "0x0B370BFF", "0x27450DFF", "0x071F24FF", "0x784573FF",
	"0x8A653AFF", "0x732617FF", "0x319490FF", "0x56941DFF", "0x59163DFF", "0x1B8A2FFF", "0x38160BFF", "0x041804FF", "0x355D8EFF", "0x2E3F5BFF",
	"0x561A28FF", "0x4E0E27FF", "0x706C67FF", "0x3B3E42FF", "0x2E2D33FF", "0x7B7E7DFF", "0x4A4442FF", "0x28344EFF"
	}

local mcolor -- ëîêàëüíàÿ ïåðåìåííàÿ äëÿ ðåãèñòðàöèè ðàíäîìíîãî öâåòà

local player_info = {} -- èíôà î ÷åëèêå
local player_to_streamed = {} -- èíôà î ïðåñëåäóåìûì
local text_remenu = { "Î÷êè:", "Çäîðîâüå:", "Áðîíÿ:", "ÕÏ ìàøèíû:", "Ñêîðîñòü:", "Ping:", "Ïàòðîíû:", "Âûñòðåëû:", "Âðåìÿ âûñòðåëîâ:", "Âðåìÿ ÀÔÊ:", "P.Loss:", "VIP:", "Passive Ìîä:", "Turbo:", "Êîëëèçèÿ:" }
local control_recon_playerid = -1 -- êîíòðîëèðóåìàÿ ïåðåìåííàÿ çà èä èãðîêà
local control_tab_playerid = -1 -- â òàáå
local ip_player = nil -- ip èãðîêà
local control_recon_playernick -- íèê
local next_recon_playerid = nil -- ñëåäóþùèé èä
local control_recon = false -- êîíòðîëèðîâàíèå ðåêîíà
local control_info_load = false -- êîíòðîëèðîâàíèå çàãðóçêè èíôû
local right_re_menu = imgui.ImBool(true) -- ðåìåíþ ñïðàâà
local mouse_cursor = true -- ðàâåí ëè êóðñîð ïðàâäå
local check_cmd_re = false -- êîíòðîëü êîìàíäû î ñëåæêå
local accept_load = false -- çàãðóçêà ðåêîíà
local tool_re

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280) -- çàõâàò ïîçèöèè êîñòåé
local chat_logger_text = { } -- òåêñò ëîããåðà
local text_ru = { }
local accept_load_clog = false -- ïðèíÿòèå ïåðåìåííîé ëîããåðà

local script_version = 6 -- îñíîâíàÿ âåðñèÿ, ïåðåõâàòûâàåìàÿ ñàéòîì è ñêðèïòîì
local script_version_text = "12.6" -- òåêñòîâàÿ âåðñèÿ
local script_path = thisScript().path  -- ïàò÷
local script_url = "https://raw.githubusercontent.com/alfantasy/AT/main/ATmain.lua" 
local report_path = getWorkingDirectory() .. "ATreport.lua"
local report_url = "https://raw.githubusercontent.com/alfantasy/AT/main/ATreport.lua"
local mute_path = getWorkingDirectory() .. "\\module\\ATautomute.lua"
local mute_url = "https://raw.githubusercontent.com/alfantasy/AT/main/ATautomute.lua"
local pl1_path = getWorkingDirectory() .. "\\module\\ATother.lua"
local pl1_url = "https://raw.githubusercontent.com/alfantasy/AT/main/ATother.lua" 
local pl2_path = getWorkingDirectory() .. "\\module\\ATplugin.lua"
local pl2_url = "https://raw.githubusercontent.com/alfantasy/AT/main/ATplugin.lua" 

local update_path = getWorkingDirectory() .. '/upat.ini' -- îñíîâíîé ïàò÷
local update_url = "https://raw.githubusercontent.com/alfantasy/AT/main/upat.ini" -- çàãðóçêà ïàò÷à
local font_fa_url = "https://raw.githubusercontent.com/alfantasy/AdminTool/main/fontawesome-webfont.ttf"
local font_fa_path = getWorkingDirectory() .. '\\resource\\font\\fontawesome-webfont.ttf'
local scoreboard_url = 'https://raw.githubusercontent.com/alfantasy/AT/main/scoreboard.lua'
local scoreboard_path = getWorkingDirectory() .. '\\lib\\scoreboard.lua'

local directIni = "AdminTool\\settings.ini" -- ñîçäàíèå ñïåöèàëüíîãî ôàéëà, îòâå÷àþùåãî çà íàñòðîéêè.
local massivIni = "AdminTool\\texts.ini" -- ñîçäàíèå ñïåöèàëüíîãî ôàéëà, îòâå÷àþùåãî çà áèíäåðíûå ýëåìåíòû AT

local textcfg = inicfg.load({
	flood_text = {},
	flood_name = {},
	makeadmin_text = {},
	makeadmin_name = {}
}, massivIni)
inicfg.save(textcfg, massivIni)

function TextSave() 
	inicfg.save(textcfg, massivIni)
end	

local ATcfg = inicfg.load({
	setting = {
		Push_Report = false,
		Chat_Logger = false,
		ATAlogin = false,
		AT_CTAB = false,
		ATHelloAdm = "",
		ATAdminPass = "",
		prefix_adm = "",
		prefix_STadm = "",
		prefix_Madm = "",
		prefix_ZGAadm = "",
		prefix_GAadm = "",
		prefix_Helper = "",
		prefix_Moderator = "",
		prefix_PGAadm = "",
		ATColor = "",
		ATColor_admins = "{FFFFFF}",
		styleImgui = 14,
		admFont = 10,
		good_game_prefix = false,
		recon_menu = false,
		show_admins = false,
		keysync = false,
		acX = 0,
		acY = 0,
	},
	keys = {
		ATWHkeys = "None",
		ATTool =  "F3",
		ATOnline = "None",
		ATReportAns = "None",
		ATReportRP = "None",
		ATReportRP1 = "None",
		ATReportRP2 = "None",
		P_Log = "None",
		ATRecon = "None",
		Re_menu = "None",
		ATStartForm = "None",
	},
}, directIni)
inicfg.save(ATcfg, directIni)

local render = {
	acpos = false, 
	acX = 0,
	acY = 0
}

function save()
    inicfg.save(ATcfg, directIni)
end

function imgui.Link(link)
	if status_hovered then
		local p = imgui.GetCursorScreenPos()
		imgui.TextColored(imgui.ImVec4(0, 0.5, 1, 1), link)
		imgui.GetWindowDrawList():AddLine(imgui.ImVec2(p.x, p.y + imgui.CalcTextSize(link).y), imgui.ImVec2(p.x + imgui.CalcTextSize(link).x, p.y + imgui.CalcTextSize(link).y), imgui.GetColorU32(imgui.ImVec4(0, 0.5, 1, 1)))
	else
		imgui.TextColored(imgui.ImVec4(0, 0.3, 0.8, 1), link)
	end
	if imgui.IsItemClicked() then os.execute('explorer '..link)
	elseif imgui.IsItemHovered() then
		status_hovered = true else status_hovered = false
	end
end

function showNotification(handle, text_not)
	notfy.addNotify("{87CEEB}" .. handle, text_not, 2, 1, 6)
end

----- Ââåäåííûå ëîêàëüíûå ïåðåìåííûå, êîòîðûå îòâå÷àþò çà imgui îêíî è/èëè îòíîñÿòñÿ ê íåìó -------
imgui.ToggleButton = require('imgui_addons').ToggleButton
imgui.Spinner = require('imgui_addons').Spinner
imgui.BufferingBar = require('imgui_addons').BufferingBar
local ATToolsMenu = imgui.ImBool(false)
local ATChatLogger = imgui.ImBool(false)
local ATre_menu = imgui.ImBool(false)
local chat_logger = imgui.ImBuffer(10000)
local chat_find = imgui.ImBuffer(256)
local btn_size = imgui.ImVec2(-0.1, 0)
local notev = imgui.ImBuffer(1024)
local colorsImGui = {
					u8"×åðíàÿ", -- 0
					u8"Ñåðî-÷åðíûé", -- 1
					u8"Áåëàÿ", -- 2
					u8"Sky Blue", -- 3
					u8"Ñèíèé", -- 4
					u8"Òåìíî-ãîëóáîé", -- 5
					u8"Êðàñíûé", -- 6
					u8"Òåìíî-êðàñíûé", -- 7
					u8"Êîðè÷íåâûé", -- 8
					u8"Ôèîëåòîâûé", -- 9
					u8"Ôèîëåòîâàÿ v2", -- 10
					u8"Ñàëàòîâûé", -- 11
					u8"Áåëî-çåëåíàÿ", -- 12
					u8"Æ¸ëòî-áåëàÿ", -- 13
					u8"Îñíîâíàÿ òåìà"} -- 14
					
local tag = "{00BFFF} [AT] " -- ëîêàëüíàÿ ïåðåìåííàÿ, êîòîðàÿ ðåãèñòðèðóåò òýã AT

local admins = {}	
					
local menuSelect = 0
local selectRecon = 0
local combo_select = imgui.ImInt(0) -- îòâå÷àåò çà êîìáî-øòó÷êè
local sw1, sh1 = getScreenResolution() -- îòâå÷àåò çà øèðèíó è äëèíó, êîðî÷å ãîâîðÿ - ðàçìåð îêíà.
local sw, sh = getScreenResolution() -- îòâå÷àåò çà âòîðîñòåïåííóþ äëèíó è øèðèíó îêîí.

local selectlogin = false
local scanspawn = false

local elm = {
	checkbox = {
		god_mode = imgui.ImBool(false),
		clist_adm = imgui.ImBool(false),
		open_pm = imgui.ImBool(false),
		take_report = imgui.ImBool(false),
		push_report = imgui.ImBool(ATcfg.setting.Push_Report),
		chat_logger = imgui.ImBool(ATcfg.setting.Chat_Logger),
		custom_tab = imgui.ImBool(ATcfg.setting.AT_CTAB),
		autoalogin = imgui.ImBool(ATcfg.setting.ATAlogin),
		good_game_prefix = imgui.ImBool(ATcfg.setting.good_game_prefix),
		atrecon = imgui.ImBool(ATcfg.setting.recon_menu),
		show_admins = imgui.ImBool(ATcfg.setting.show_admins),
		keysync = imgui.ImBool(ATcfg.setting.keysync),
	},
	int = {
		styleImgui = imgui.ImInt(ATcfg.setting.styleImgui),
		admFont = imgui.ImInt(ATcfg.setting.admFont),
	},
	input = {
       ATAdminPass = imgui.ImBuffer(tostring(ATcfg.setting.ATAdminPass), 50),
	   prefix_Madm = imgui.ImBuffer(tostring(ATcfg.setting.prefix_Madm), 50),
	   prefix_GAadm = imgui.ImBuffer(tostring(ATcfg.setting.prefix_GAadm), 50),
	   prefix_STadm = imgui.ImBuffer(tostring(ATcfg.setting.prefix_STadm), 50),
	   prefix_ZGAadm = imgui.ImBuffer(tostring(ATcfg.setting.prefix_ZGAadm), 50),
	   prefix_Helper = imgui.ImBuffer(tostring(ATcfg.setting.prefix_Helper), 50),
	   prefix_Moderator = imgui.ImBuffer(tostring(ATcfg.setting.prefix_Moderator), 50),
	   prefix_adm = imgui.ImBuffer(tostring(ATcfg.setting.prefix_adm), 50),
	   prefix_PGAadm = imgui.ImBuffer(tostring(ATcfg.setting.prefix_PGAadm), 50),
	   ATColor = imgui.ImBuffer(tostring(ATcfg.setting.ATColor), 50),
	   ATHelloAdm = imgui.ImBuffer(tostring(ATcfg.setting.ATHelloAdm), 50),
	   ATColor_admins = imgui.ImBuffer(tostring(ATcfg.setting.ATColor_admins), 50),
	   fld_name = imgui.ImBuffer(256),
	   fld_text = imgui.ImBuffer(65536),
	   adm_name = imgui.ImBuffer(200),
	   adm_text = imgui.ImBuffer(65535),
	},
	ac = {
		X = ATcfg.setting.acX,
		Y = ATcfg.setting.acY
	}
}	

local font_ac = renderCreateFont("Arial", tonumber(elm.int.admFont.v), font_admin_chat.BOLD + font_admin_chat.SHADOW)

------ Ââåäåííûå ëîêàëüíûå ïåðåìåííàÿ, îòâå÷àþùèå çà ïåðåâîä ñèìâîëîâ, èëè îñòàëüíûõ ñâîéñòâ ÷àòà -----------
local russian_characters = {
    [168] = '¨', [184] = '¸', [192] = 'À', [193] = 'Á', [194] = 'Â', [195] = 'Ã', [196] = 'Ä', [197] = 'Å', [198] = 'Æ', [199] = 'Ç', [200] = 'È', [201] = 'É', [202] = 'Ê', [203] = 'Ë', [204] = 'Ì', [205] = 'Í', [206] = 'Î', [207] = 'Ï', [208] = 'Ð', [209] = 'Ñ', [210] = 'Ò', [211] = 'Ó', [212] = 'Ô', [213] = 'Õ', [214] = 'Ö', [215] = '×', [216] = 'Ø', [217] = 'Ù', [218] = 'Ú', [219] = 'Û', [220] = 'Ü', [221] = 'Ý', [222] = 'Þ', [223] = 'ß', [224] = 'à', [225] = 'á', [226] = 'â', [227] = 'ã', [228] = 'ä', [229] = 'å', [230] = 'æ', [231] = 'ç', [232] = 'è', [233] = 'é', [234] = 'ê', [235] = 'ë', [236] = 'ì', [237] = 'í', [238] = 'î', [239] = 'ï', [240] = 'ð', [241] = 'ñ', [242] = 'ò', [243] = 'ó', [244] = 'ô', [245] = 'õ', [246] = 'ö', [247] = '÷', [248] = 'ø', [249] = 'ù', [250] = 'ú', [251] = 'û', [252] = 'ü', [253] = 'ý', [254] = 'þ', [255] = 'ÿ',
} 

local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function enc(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
            return string.char(c)
    end))
end

local translate = {
	["é"] = "q",
	["ö"] = "w",
	["ó"] = "e",
	["ê"] = "r",
	["å"] = "t",
	["í"] = "y",
	["ã"] = "u",
	["ø"] = "i",
	["ù"] = "o",
	["ç"] = "p",
	["õ"] = "[",
	["ú"] = "]",
	["ô"] = "a",
	["û"] = "s",
	["â"] = "d",
	["à"] = "f",
	["ï"] = "g",
	["ð"] = "h",
	["î"] = "j",
	["ë"] = "k",
	["ä"] = "l",
	["æ"] = ";",
	["ý"] = "'",
	["ÿ"] = "z",
	["÷"] = "x",
	["ñ"] = "c",
	["ì"] = "v",
	["è"] = "b",
	["ò"] = "n",
	["ü"] = "m",
	["á"] = ",",
	["þ"] = "."
}

function showFlood()
	imgui.Text(u8"Äàííûå êíîïêè îòâå÷àþò çà ìãíîâåííóþ îòïðàâó ôëóäà.") 
	imgui.Text(u8"Èíòåðâàë ìåæäó ôëóäîì 1-5 ìèíóò.")
	imgui.Text(u8"Ïðîñüáà, ïðè èñïîëüçîâàíèè, íàæàòü ëèøü ÎÄÈÍ ðàç íà êíîïêó.")
	imgui.Text(u8"P.S. Èñïîëüçóéòå ÷àùå êîìàíäó /online äëÿ âûäà÷è âàëþòû çà îíëàéí!")
	imgui.Text(u8"Íàæìèòå NumPad3 è ïðîèçîéäåò àâòîìàòè÷åñêàÿ âûäà÷à çà îíëàéí")
	imgui.Text('  ')
	imgui.Separator()
	imgui.Text('  ')
	if imgui.Button(u8"Ìåðîïðèÿòèÿ /join", imgui.ImVec2(200,0)) then 
		imgui.OpenPopup('joinmp')
	end 
	imgui.SameLine()
	if imgui.Button(u8"Îñòàëüíûå ôëóäû", imgui.ImVec2(200,0)) then 
		imgui.OpenPopup('mainflood')
	end	
	if imgui.Button(u8"Ôëóä ïðî GangWar", imgui.ImVec2(200,0)) then 
		imgui.OpenPopup('floodgw')
	end 
	imgui.SameLine()
	if imgui.Button(u8'Íàïîìèíàíèå öâåòîâ ê /mess') then
		sampAddChatMessage(tag .. "0 - {FFFFFF}áåëûé, 1 - {000000}÷åðíûé, 2 - {008000}çåëåíûé, 3 - {80FF00}ñâåòëî-çåëåíûé")
		sampAddChatMessage(tag .. "4 - {FF0000}êðàñíûé, 5 - {0000FF}ñèíèé, 6 - {FDFF00}æåëòûé, 7 - {FF9000}îðàíæåâûé")
		sampAddChatMessage(tag .. "8 - {B313E7}ôèîëåòîâûé, 9 - {49E789}áèðþçîâûé, 10 - {139BEC}ãîëóáîé")
		sampAddChatMessage(tag .. "11 - {2C9197}òåìíî-çåëåíûé, 12 - {DDB201}çîëîòîé, 13 - {B8B6B6}ñåðûé, 14 - {FFEE8A}ñâåòëî-æåëòûé")
		sampAddChatMessage(tag .. "15 - {FF9DB6}ðîçîâûé, 16 - {BE8A01}êîðè÷íåâûé, 17 - {E6284E}òåìíî-ðîçîâûé")
	end
	imgui.Text('  ')
	imgui.Separator()
	imgui.Text('  ')
	if imgui.Button(u8"Ñâîè ôëóäû", imgui.ImVec2(200,0)) then  
		imgui.OpenPopup('yoursmp')
	end	
	imgui.SameLine()
	if imgui.Button(u8"Ðåäàêòîð ôëóäîâ", imgui.ImVec2(200,0)) then  
		imgui.OpenPopup('editfloods') 
	end	
	imgui.Text('  ')
	imgui.Separator()
	imgui.Text('  ')
	if imgui.CollapsingHeader(u8'Ïîìîùü ïî ñîçäàíèþ ôëóäà / âñïîìîãàëêà') then 
		imgui.Text(u8"Ïðè ñîçäàíèè ôëóäà, ïîìíèòå, ÷òî ñòðî÷êè îòäåëÿþòñÿ ïðè ïîìîùè Enter")
		imgui.Text(u8"Â ñîçäàíèè êàæäîé ñòðî÷êè äîëæåí ó÷àñòâîâàòü öâåò /mess (îò 0 äî 17)")
		imgui.Text(u8"Ïðèìåð: ")
		imgui.Text(u8" 4 == ÈÍÔÎÐÌÀÖÈß ÐÄÑ ==")
		imgui.Text(u8" 6 Çàìó÷èëè ÷èòåðû? Ïèøèòå â ðåïîðò!")
		imgui.Text(u8" 4 == ÈÍÔÎÐÌÀÖÈß ÐÄÑ ==")
	end
	if imgui.BeginPopup('floodgw') then 
		if imgui.Button(u8"Aztecas vs Ballas") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 3 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs East Side Ballas ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 3 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		imgui.SameLine()
		if imgui.Button(u8"Aztecas vs Groove") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 2 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs Groove Street ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 2 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		if imgui.Button(u8"Aztecas vs Vagos") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 4 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs Los Santos Vagos ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 4 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		imgui.SameLine()
		if imgui.Button(u8"Aztecas vs Rifa") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 5 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 Varios Los Aztecas vs The Rifa ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 5 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		if imgui.Button(u8"Ballas vs Groove") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 6 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs Groove Street  ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 6 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		imgui.SameLine()
		if imgui.Button(u8"Ballas vs Rifa") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 7 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs The Rifa ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 7 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		if imgui.Button(u8"Groove vs Rifa") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 8 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 Groove Street  vs The Rifa ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 8 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		imgui.SameLine()
		if imgui.Button(u8"Groove vs Vagos") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 9 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 Groove Street vs Los Santos Vagos ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 9 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		if imgui.Button(u8"Vagos vs Rifa") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 10 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 Los Santos Vagos vs The Rifa ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 10 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
		imgui.SameLine()
		if imgui.Button(u8"Ballas vs Vagos") then  
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
			sampSendChat("/mess 11 Èãðà -  GangWar: /gw")
			sampSendChat("/mess 0 East Side Ballas vs Los Santos Vagos ")
			sampSendChat("/mess 0 Ïîìîãèòå ñâîèì áðàòüÿì, çàõîäèòå ÷åðåç /gw çà ëþáèìóþ áàíäó")
			sampSendChat("/mess 11 Èãðà - GangWar: /gw")
			sampSendChat("/mess 13 ------------------- GangWar -------------------")
		end
	imgui.EndPopup()
	end	
	if imgui.BeginPopup('mainflood') then 
		if imgui.Button(u8'Ôëóä ïðî ðåïîðòû') then
			sampSendChat("/mess 4 ===================== | Ðåïîðòû | ====================")
			sampSendChat("/mess 0 Çàìåòèëè ÷èòåðà èëè íàðóøèòåëÿ?")
			sampSendChat("/mess 4 Ââîäèòå /report, ïèøèòå òóäà ID íàðóøèòåëÿ/÷èòåðà!")
			sampSendChat("/mess 0 Íàøè àäìèíèñòðàòîðû îòâåòÿò âàì è ðàçáåðóòñÿ ñ íèìè. <3")
			sampSendChat("/mess 4 ===================== | Ðåïîðòû | ====================")
		end
		imgui.SameLine()
		if imgui.Button(u8'Ôëóä ïðî VIP') then
			sampSendChat("/mess 2 ===================== | VIP | ====================")
			sampSendChat("/mess 3 Âñåãäà õîòåë ñìîòðåòü íà ëþäåé ñâûøå?")
			sampSendChat("/mess 2 Òîáîé óïðàâëÿåò çàâèñòü? Óñòðàíè ýòî ñ ïîìîùüþ 10ê î÷êîâ.")
			sampSendChat("/mess 3 Ââîäè êîìàíäó /sellvip è òû ïîëó÷èøü VIP!")
			sampSendChat("/mess 2 ===================== | VIP | ====================")
		end
		if imgui.Button(u8'Ôëóä ïðî îïëàòó áèçíåñà/äîìà') then
			sampSendChat("/mess 5 ===================== | Áàíê | ====================")
			sampSendChat("/mess 10 Äîì èëè áèçíåñ íóæíî îïëà÷èâàòü. Êàê? -> ..")
			sampSendChat("/mess 0 Äëÿ ýòîãî íåîáõîäèìî, íàïèñàòü /tp, çàòåì Ðàçíîå -> Áàíê...")
			sampSendChat("/mess 0 ...ïîñëå ýòîãî ïðîéòè â Áàíê, îòêðûòü ñ÷åò è..")
			sampSendChat("/mess 10 ..è ùåëêíóòü ïî Îïëàòà äîìà èëè Îïëàòà áèçíåñà. Íà ýòîì âñå.")
			sampSendChat("/mess 5 ===================== | Áàíê | ====================")
		end
		if imgui.Button(u8'Ôëóä ïðî /dt 0-990 (ðåæèì òðåíèðîâêè)') then
			sampSendChat("/mess 6 =================== | Âèðòóàëüíûé ìèð | ==================")
			sampSendChat("/mess 0 Ïåðåñòðåëêè óìîòàëà? Îáûäåííûé ÄÌ, âå÷íàÿ ñòðåëüáà..")
			sampSendChat("/mess 0 Òåáå õî÷åòñÿ îòäîõíóòü? Ýòî ìîæíî èñïðàâèòü! <3")
			sampSendChat("/mess 0 Ñêîðåå ââîäè /dt 0-990. ×èñëî - ýòî âèðòóàëüíûé ìèð.")
			sampSendChat("/mess 0 Íå çàáóäüòå ñîîáùèòü äðóçüÿì ñâîé ìèð. Óäà÷íîé èãðû. :3")
			sampSendChat("/mess 6 =================== | Âèðòóàëüíûé ìèð  | ==================")
		end
			if imgui.Button(u8'Ôëóä ïðî /storm') then
			sampSendChat("/mess 2 ===================== | Øòîðì | ====================")
			sampSendChat("/mess 3 Âñåãäà õîòåëè çàðàáîòàòü ðóáëè ? Ó âàñ åñòü âîçìîæíîñòü!")
			sampSendChat("/mess 2 Ââîäè êîìàíäó /storm , ïîñëå ÷åãî ïîäîéòèòå ê NPC ... ")
			sampSendChat("/mess 3 ...íàæìèòå ïðèñîåäèíèòñÿ ê øòóðìó.")
			sampSendChat("/mess 2 Êîãäà íàáåð¸òñÿ íóæíîå êîëè÷èñòâî èãðîêîâ øòóðì íà÷í¸òñÿ.")
			sampSendChat("/mess 2 ===================== | Øòîðì | ====================")
		end
		if imgui.Button(u8'Ôëóä ïðî /arena') then
			sampSendChat("/mess 7 ===================== | Àðåíà | ====================")
			sampSendChat("/mess 0 Õî÷åøü èñïûòàòü ñâîè íàâûêè â ñòðåëüáå?")
			sampSendChat("/mess 7 Ñêîðåå ââîäè /arena, âûáåðè ñâîå ïîëå áîÿ.")
			sampSendChat("/mess 0 Ïåðåñòðåëÿé âñåõ, ïîáåäè èõ. Ïîêàæè, êòî óìååò ïîêàçàòü ñåáÿ. <3")
			sampSendChat("/mess 7 ===================== | Àðåíà | ====================")
		end
		imgui.SameLine()
		if imgui.Button(u8'Ôëóä ïðî VK group') then
			sampSendChat("/mess 15 ===================== | ÂÊîíòàêòå | ====================")
			sampSendChat("/mess 0 Âñåãäà õîòåë ïîó÷àñòâîâàòü â êîíêóðñå?")
			sampSendChat("/mess 15 Â òâîåé ãîëîâå ïîÿâèëèñü ìûñëè, êàê óëó÷øèòü ñåðâåð?")
			sampSendChat("/mess 0 Çàõîäè â íàøó ãðóïïó ÂÊîíòàêòå: https://vk.com/dmdriftgta")
			sampSendChat("/mess 15 ===================== | ÂÊîíòàêòå | ====================")
		end
		if imgui.Button(u8'Ôëóä ïðî àâòîñàëîí') then
			sampSendChat("/mess 12 ===================== | Àâòîñàëîí | ====================")
			sampSendChat("/mess 0 Ó òåáÿ ïîÿâèëèñü êîèíû? Òû õî÷åøü ëè÷íóþ òà÷êó?")
			sampSendChat("/mess 12 Ââîäè êîìàíäó /tp -> Ðàçíîå -> Àâòîñàëîíû")
			sampSendChat("/mess 0 Âûáèðàé íóæíûé àâòîñàëîí, êóïè ìàøèíó çà RDS êîèíû. È êàòàéñÿ :3")
			sampSendChat("/mess 12 ===================== | Àâòîñàëîí | ====================")
		end
		if imgui.Button(u8'Ôëóä ïðî ñàéò RDS') then
			sampSendChat("/mess 8 ===================== | Äîíàò | ====================")
			sampSendChat("/mess 15 Õî÷åøü çàäîíàòèòü íà ñâîé ëþáèìûé ñåðâåð RDS? :> ")
			sampSendChat("/mess 15 Òû ýòî ìîæåøü ñäåëàòü ñ ðàäîñòüþ! Ñàéò: myrds.ru :3 ")
			sampSendChat("/mess 15 È ÷åðåç îñíîâàòåëÿ: @empirerosso, è òàêæå..")
			sampSendChat("/mess 15 .. ÷åðåç íàøåãî ðóêîâîäèòåëÿ: @sheeeshys ")
			sampSendChat("/mess 8 ===================== | Äîíàò | ====================")
		end
		imgui.SameLine()
		if imgui.Button(u8'Ôëóä ïðî /gw') then
			sampSendChat("/mess 10 ===================== | Capture | ====================")
			sampSendChat("/mess 5 Òåáå íðàâèòñÿ èãðàòü çà áàíäû â GTA:SA? Îíè òóò òîæå åñòü! :>")
			sampSendChat("/mess 5 Ñäåëàé ýòî ñ ïîìîùüþ /gw, åäü íà òåððèòîðèþ ñ äðóçüÿìè")
			sampSendChat("/mess 5 ×òîáû íà÷àòü âîåâàòü çà òåððèòîðèþ, ââåäè êîìàíäó /capture XD")
			sampSendChat("/mess 10 ===================== | Capture | ====================")
		end
		if imgui.Button(u8"Ôëóä ïðî ãðóïïó Ñåé÷àñ íà RDS") then
			sampSendChat("/mess 2 ================== | Ñâîáîäíàÿ ãðóïïà RDS | =================")
			sampSendChat("/mess 11 Äàâíî õîòåëè ñêèíóòü ñâîè ñêðèíû, è ïîêàçàòü äðóãèì?")
			sampSendChat("/mess 2 Ïîïðîáîâàòü ïðîäàòü ÷òî-íèáóäü, íî â èãðå íèêòî íå îòçûâàåòñÿ?")
			sampSendChat("/mess 11 Âû ìîæåòå ïîñåòèòü ñâîáîäíóþ ãðóïïó: https://vk.com/freerds")
			sampSendChat("/mess 2 ================== | Ñâîáîäíàÿ ãðóïïà RDS | =================")
		end
		if imgui.Button(u8"Ôëóä ïðî /gangwar") then 
			sampSendChat("/mess 16 ===================== | Ñðàæåíèÿ | ====================")
			sampSendChat("/mess 13 Õîòåëè ñðàçèòüñÿ ñ äðóãèìè áàíäàìè? Âûïóñòèòü ãíåâ?")
			sampSendChat("/mess 16 Âû ìîæåòå ñåáå ýòî ïîçâîëèòü! Ìîæåòå ïîáîðîòü äðóãèå áàíäû")
			sampSendChat("/mess 13 Êîìàíäà /gangwar, âûáèðàåòå òåððèòîðèþ è ñðàæàåòåñü çà íå¸.")
			sampSendChat("/mess 16 ===================== | Ñðàæåíèÿ | ====================")
		end 
		imgui.SameLine()
		if imgui.Button(u8"Ôëóä ïðî ðàáîòû") then
			sampSendChat("/mess 14 ===================== | Ðàáîòû | ====================")
			sampSendChat("/mess 13 Íå õâàòàåò äåíåã íà îðóæèå? Íå õâàòàåò íà ìàøèíêó?")
			sampSendChat("/mess 13 Ðàäè íàøèõ ÄÌåðîâ è äðèôòåðîâ, ïðèäóìàíû ðàáîòû äëÿ äåíüæàò")
			sampSendChat("/mess 13 ×åðíûé äåíü îòêðûò, ïåðåõîäè /tp -> Ðàáîòû")
			sampSendChat("/mess 14 ===================== | Ðàáîòû | ====================")
		end
		if imgui.Button(u8"Ôëóä î ìîäå") then  
			sampSendChat("/mess 13 ===================== | Ìîä RDS | ====================")
			sampSendChat("/mess 0 Ïîñâÿùàåì âàñ â ìîä RDS. Ïðåæäå âñåãî, ìû Drift Server")
			sampSendChat("/mess 13 Òàêæå ó íàñ åñòü äîïîëíåíèÿ, ýòî GangWar, DM ñ ýëåìåíòàìè RPG")
			sampSendChat("/mess 0 Áîëüøèíñòâî êîìàíä è âñå îñòàëüíîå óêàçàíî â /help")
			sampSendChat("/mess 13 ===================== | Ìîä RDS | ====================")
		end
		imgui.SameLine()
		if imgui.Button(u8'Ôëóä ïðî /trade') then
			sampSendChat("/mess 9 ===================== | Òðåéä | ====================")
			sampSendChat("/mess 3 Õîòèòå ðàçíûå àêñåññóàðû, à äîëãî èãðàòü íå õî÷åòñÿ è åñòü âèðòû/î÷êè/êîèíû/ðóáëè?")
			sampSendChat("/mess 9 Ââåäèòå /trade, ïîäîéäèòå ê çàíÿòîé ëàâêè, ñïðîñèòå ó ÷åëîâåêà è êóïèòå ïðåäìåò.")
			sampSendChat("/mess 3 Òàêæå, ñïðàâà îò ëàâîê åñòü NPC Àðìàí, ó íåãî òàêæå ìîæíî ÷òî-òî âçÿòü.")
			sampSendChat("/mess 9 ===================== | Òðåéä | ====================")
		end
		if imgui.Button(u8'Ôëóä ïðî ôîðóì') then 
			sampSendChat("/mess 4 ===================== | Ôîðóì | ====================")
			sampSendChat('/mess 0 Åñòü æàëîáû íà èãðîêîâ/àäìèíîâ? Åñòü âîïðîñû? Õîòèòå èãðàòü ñ òåëåôîíà?')
			sampSendChat('/mess 4 Ó íàñ åñòü ôîðóì - https://forumrds.ru. Òàì åñòü ïîëåçíàÿ èíôà :D')
			sampSendChat('/mess 0 Êðîìå ýòîãî, òàì åñòü êóðèëêà è ãàëåðåÿ. Âåñåëèòåñü, èãðîêè <3')
			sampSendChat("/mess 4 ===================== | Ôîðóì  | ====================")
		end	
		if imgui.Button(u8'Ôëóä ïðî íàáîð àäì') then 
			sampSendChat("/mess 15 ===================== | Íàáîð | ====================")
			sampSendChat('/mess 17 Äîðîãèå èãðîêè! Âû çíàåòå ïðàâèëà íàøåãî ïðîåêòà?')
			sampSendChat('/mess 15 Åñëè âû êîãäà-òî õîòåëè ñòàòü àäìèíîì, òî ýòî âàø øàíñ!')
			sampSendChat('/mess 17 Óæå íà ôîðóìå îòêðûòû çàÿâêè! Óñïåéòå ïîäàòü: https://forumrds.ru')
			sampSendChat("/mess 15 ===================== | Íàáîð | ====================")
		end
		if imgui.Button(u8'Ñïàâí êàðîâ íà 15 ñåêóíä') then
			sampSendChat("/mess 14 Óâàæàåìûå èãðîêè. Ñåé÷àñ áóäåò ðåñïàâí âñåãî ñåðâåðíîãî òðàíñïîðòà")
			sampSendChat("/mess 14 Çàéìèòå âîäèòåëüñêèå ìåñòà, è ïðîäîëæàéòå äðèôòèòü, íàøè ëþáèìûå :3")
			sampSendChat("/delcarall ")
			sampSendChat("/spawncars 15 ")
			local tag = "{00BFFF} [AT]" -- ëîêàëüíàÿ ïåðåìåííàÿ, êîòîðàÿ ðåãèñòðèðóåò òýã AT
			showNotification(tag, "Ðåñïàâí ò/ñ íà÷àëñÿ")
		end
	    if imgui.Button(u8'Êâåñòû') then
		    sampSendChat("/mess 8 =================| Êâåñòû NPC |=================")
		    sampSendChat("/mess 0 Íå ìîæåòå íàéòè NPC êîòîðûå äàþò êâåñòû? :D")
		    sampSendChat("/mess 0 È òàê ãäå æå èõ íàéòè , - ALT(/mm) - Òåëåïîðòû - ...")
		    sampSendChat("/mess 0 ...Âàñèëèé Àíäðîèä, Áðîäÿãà Äèìàí, è íà êàæäîì ñïàâíå...")
		    sampSendChat("/mess 0 ...NPC Êåéí. Ïðèÿòíîé èãðû íà RDS <3")
		    sampSendChat("/mess 8 =================| Êâåñòû NPC |=================")
		end	
	imgui.EndPopup()
	end	
	if imgui.BeginPopup('joinmp') then 
		if imgui.Button(u8'Ìåðîïðèÿòèå "Äåðáè" ') then 
			sampSendChat("/mess 8 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Äåðáè»! Æåëàþùèì: /derby")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Äåðáè»! Æåëàþùèì: /derby")
			sampSendChat("/mess 8 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Ïàðêóð" ') then 
			sampSendChat("/mess 10 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ïàðêóð»! Æåëàþùèì: /parkour")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ïàðêóð»! Æåëàþùèì: /parkour")
			sampSendChat("/mess 10 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Áåéñäæàìïèíã" ') then 
			sampSendChat("/mess 5 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Áåéñäæàìïèíã»! Æåëàþùèì: /basejumping")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Áåéñäæàìïèíã»! Æåëàþùèì: /basejumping")
			sampSendChat("/mess 5 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Ìÿñîðóáêà" ') then 
			sampSendChat("/mess 4 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ìÿñîðóáêà»! Æåëàþùèì: /myasorubka")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ìÿñîðóáêà»! Æåëàþùèì: /myasorubka")
			sampSendChat("/mess 4 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "PUBG" ') then 
			sampSendChat("/mess 9 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «PUBG»! Æåëàþùèì: /pubg")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «PUBG»! Æåëàþùèì: /pubg")
			sampSendChat("/mess 9 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Ïèðàòñêèå ïðèêëþ÷åíèÿ" ') then 
			sampSendChat("/mess 15 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ïèðàòñêèå ïðèêëþ÷åíèÿ»! Æåëàþùèì: /pirate")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ïèðàòñêèå ïðèêëþ÷åíèÿ»! Æåëàþùèì: /pirate")
			sampSendChat("/mess 15 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "DAMAGE DM" ') then 
			sampSendChat("/mess 4 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «DAMAGE DEATHMATCH»! Æåëàþùèì: /damagedm")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «DAMAGE DEATHMATCH»! Æåëàþùèì: /damagedm")
			sampSendChat("/mess 4 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "KILL DM" ') then 
			sampSendChat("/mess 17 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «KILL DEATHMATCH»! Æåëàþùèì: /killdm")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «KILL DEATHMATCH»! Æåëàþùèì: /killdm")
			sampSendChat("/mess 17 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Áîè íà êóëàêàõ" ') then 
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Áîé íà êóëàêàõ»! Æåëàþùèì: /box")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Áîé íà êóëàêàõ»! Æåëàþùèì: /box")
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Äðèôò ãîíêè" ') then 
			sampSendChat("/mess 7 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Äðèôò ãîíêè»! Æåëàþùèì: /drace")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Äðèôò ãîíêè»! Æåëàþùèì: /drace")
			sampSendChat("/mess 7 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "PaintBall" ') then 
			sampSendChat("/mess 12 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «PaintBall»! Æåëàþùèì: /paintball")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «PaintBall»! Æåëàþùèì: /paintball")
			sampSendChat("/mess 12 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Ãîíêè" ') then 
			sampSendChat("/mess 6 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ãîíêè»! Æåëàþùèì: /race")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ãîíêè»! Æåëàþùèì: /race")
			sampSendChat("/mess 6 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Çîìáè ïðîòèâ ëþäåé" ') then 
			sampSendChat("/mess 13 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Çîìáè ïðîòèâ ëþäåé»! Æåëàþùèì: /zombie")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Çîìáè ïðîòèâ ëþäåé»! Æåëàþùèì: /zombie")
			sampSendChat("/mess 13 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Íîâîãîäíÿÿ ñêàçêà" ') then 
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Íîâîãîäíÿÿ ñêàçêà»! Æåëàþùèì: /ny")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Íîâîãîäíÿÿ ñêàçêà»! Æåëàþùèì: /ny")
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Among Us" ') then 
			sampSendChat("/mess 16 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Among Us»! Æåëàþùèì: /amongus")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Among Us»! Æåëàþùèì: /amongus")
			sampSendChat("/mess 16 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Ïðÿòêè" ') then 
			sampSendChat("/mess 11 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ïðÿòêè»! Æåëàþùèì: /join -> 16 «Ïðÿòêè»")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ïðÿòêè»! Æåëàþùèì: /join -> 16 «Ïðÿòêè»")
			sampSendChat("/mess 11 ===================| [Event-Game-RDS] |==================")
		end	
		if imgui.Button(u8'Ìåðîïðèÿòèå "Äîãîíÿëêè" ') then 
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Äîãîíÿëêè»! Æåëàþùèì: /catchup")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Äîãîíÿëêè»! Æåëàþùèì: /catchup")
			sampSendChat("/mess 3 ===================| [Event-Game-RDS] |==================")
		end
		if imgui.Button(u8'Ìåðîïðèÿòèå "Ïîáåãóøêè çà ÿéöàìè" ') then 
			sampSendChat("/mess 11 ===================| [Event-Game-RDS] |==================")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ïîáåãóøêè çà ÿéöàìè»! Æåëàþùèì: /join -> 18")
			sampSendChat("/mess 0 [MP-/join] Ïðîâîäèòñÿ ìåðîïðèÿòèå «Ïîáåãóøêè çà ÿéöàìè»! Æåëàþùèì: /join -> 18")
			sampSendChat("/mess 11 ===================| [Event-Game-RDS] |==================")
		end	
	imgui.EndPopup()
	end	
	if imgui.BeginPopup('yoursmp') then  
		if #textcfg.flood_name > 0 then  
			for key_bind, name_bind in pairs(textcfg.flood_name) do  
				if imgui.Button(name_bind.. '##'..key_bind) then  
					play_flood(key_bind)
				end	
			end	
		else 
			imgui.Text(u8"Ïóñòî!")
			if imgui.Button(u8"Ñîçäàòü!") then  
				imgui.OpenPopup(u8'CreateFlood')	 
			end	
		end	
		if imgui.BeginPopupModal(u8'CreateFlood', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.BeginChild("##EditFlood", imgui.ImVec2(600, 225), true)
			imgui.Text(u8'Íàçâàíèå ôëóäà:'); imgui.SameLine()
			imgui.PushItemWidth(130)
			imgui.InputText("##name_flood", elm.input.fld_name)
			imgui.PopItemWidth()
			imgui.PushItemWidth(100)
			imgui.Separator()
			imgui.Text(u8'Òåêñò áèíäà:')
			imgui.PushItemWidth(300)
			imgui.InputTextMultiline("##text_flood", elm.input.fld_text, imgui.ImVec2(-1, 110))
			imgui.PopItemWidth()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
			if imgui.Button(u8'Çàêðûòü##bind1', imgui.ImVec2(100,30)) then
				elm.input.fld_name.v, elm.input.fld_text.v = '', ''
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if #elm.input.fld_name.v > 0 and #elm.input.fld_text.v > 0 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
				if imgui.Button(u8'Ñîõðàíèòü##bind1', imgui.ImVec2(100,30)) then
					if not EditOldBind then
						local refresh_text = elm.input.fld_text.v:gsub("\n", "~")
						table.insert(textcfg.flood_name, elm.input.fld_name.v)
						table.insert(textcfg.flood_text, refresh_text)
							if TextSave() then
								sampAddChatMessage(tag .. 'Ôëóä"' ..u8:decode(elm.input.fld_name.v).. '" óñïåøíî ñîçäàí!', -1)
								elm.input.fld_name.v, elm.input.fld_text.v = '', ''
							end
						imgui.CloseCurrentPopup()
						else
							local refresh_text = elm.input.fld_text.v:gsub("\n", "~")
							table.insert(textcfg.flood_name, getpos, elm.input.fld_name.v)
							table.insert(textcfg.flood_text, getpos, refresh_text)
							table.remove(textcfg.flood_name, getpos + 1)
							table.remove(textcfg.flood_text, getpos + 1)
						if TextSave() then
							sampAddChatMessage(tag .. 'Áèíä"' ..u8:decode(elm.input.fld_name.v).. '" óñïåøíî îòðåäàêòèðîâàí!', -1)
							elm.input.fld_name.v, elm.input.fld_text.v = '', '', 2500
						end
						EditOldBind = false
						imgui.CloseCurrentPopup()
					end
				end
			end
			imgui.EndChild()
			imgui.EndPopup()
		end	
		imgui.EndPopup()
	end	
	if imgui.BeginPopupModal(u8'editfloods', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.BeginChild("##EditFloods", imgui.ImVec2(600, 225), true)
		if #textcfg.flood_name > 0 then
			for key_bind, name_bind in pairs(textcfg.flood_name) do
			imgui.Button(name_bind..'##'..key_bind, imgui.ImVec2(270, 22))
			imgui.SameLine()
			if imgui.Button(u8'Ðåäàêòèðîâàòü##'..key_bind, imgui.ImVec2(100, 22)) then
				EditOldBind = true
				getpos = key_bind
				local returnwrapped = tostring(textcfg.flood_text[key_bind]):gsub('~', '\n')
				elm.input.fld_text.v = returnwrapped
				elm.input.fld_name.v = tostring(textcfg.flood_name[key_bind])
				imgui.OpenPopup(u8'CreateFlood')
			end
			imgui.SameLine()
			if imgui.Button(u8'Óäàëèòü##'..key_bind, imgui.ImVec2(60, 22)) then
				sampAddChatMessage(tag .. 'Áèíä "' ..u8:decode(textcfg.flood_name[key_bind])..'" óäàëåí!', -1)
				table.remove(textcfg.flood_name, key_bind)
				table.remove(textcfg.flood_text, key_bind)
				TextSave()
			end
		end
		if imgui.Button(u8"Ñîçäàòü!") then  
			imgui.OpenPopup(u8'CreateFlood')	 
		end	
		else
			imgui.Text(u8('Çäåñü ïîêà ïóñòî :('))
			if imgui.Button(u8"Ñîçäàòü!") then  
				imgui.OpenPopup(u8'CreateFlood')	 
			end	
		end
		if imgui.BeginPopupModal(u8'CreateFlood', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.BeginChild("##EditFlood", imgui.ImVec2(600, 225), true)
			imgui.Text(u8'Íàçâàíèå ôëóäà:'); imgui.SameLine()
			imgui.PushItemWidth(130)
			imgui.InputText("##name_flood1", elm.input.fld_name)
			imgui.PopItemWidth()
			imgui.PushItemWidth(100)
			imgui.Separator()
			imgui.Text(u8'Òåêñò áèíäà:')
			imgui.PushItemWidth(300)
			imgui.InputTextMultiline("##text_flood1", elm.input.fld_text, imgui.ImVec2(-1, 110))
			imgui.PopItemWidth()
	
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
			if imgui.Button(u8'Çàêðûòü##bind1', imgui.ImVec2(100,30)) then
				elm.input.fld_name.v, elm.input.fld_text.v = '', ''
				imgui.CloseCurrentPopup()
			end
			imgui.SameLine()
			if #elm.input.fld_name.v > 0 and #elm.input.fld_text.v > 0 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
				if imgui.Button(u8'Ñîõðàíèòü##bind1', imgui.ImVec2(100,30)) then
					if not EditOldBind then
						local refresh_text = elm.input.fld_text.v:gsub("\n", "~")
						table.insert(textcfg.flood_name, elm.input.fld_name.v)
						table.insert(textcfg.flood_text, refresh_text)
						if TextSave() then
							sampAddChatMessage(tag .. 'Ôëóä"' ..u8:decode(elm.input.fld_name.v ).. '" óñïåøíî ñîçäàí!', -1)
							elm.input.fld_name.v, elm.input.fld_text.v = '', ''
						end
							imgui.CloseCurrentPopup()
						else
							local refresh_text = elm.input.fld_text.v:gsub("\n", "~")
							table.insert(textcfg.flood_name, getpos, elm.input.fld_name.v)
							table.insert(textcfg.flood_text, getpos, refresh_text)
							table.remove(textcfg.flood_name, getpos + 1)
							table.remove(textcfg.flood_text, getpos + 1)
						if TextSave() then
							sampAddChatMessage(tag .. 'Áèíä"' ..u8:decode(elm.input.fld_name.v).. '" óñïåøíî îòðåäàêòèðîâàí!', -1)
							elm.input.fld_name.v, elm.input.fld_text.v = '', '', 2500
						end
						EditOldBind = false
						imgui.CloseCurrentPopup()
					end
				end
			end
			imgui.EndChild()
			imgui.EndPopup()
		end	
		imgui.EndChild()
		if imgui.Button(u8"Çàêðûòü") then  
			imgui.CloseCurrentPopup()
		end	
		imgui.EndPopup()
	end	
end	

function play_flood(num)
	lua_thread.create(function()
		if num ~= -1 then
			for bp in textcfg.flood_text[num]:gmatch('[^~]+') do
				sampSendChat("/mess " .. u8:decode(tostring(bp)))
			end
			num = -1
		end
	end)
end	

function sampev.onSendSpawn()
	if selectlogin == true then 
		scanspawn = false 
	elseif selectlogin == false then
		scanspawn = true 
	end
end	

function sampev.onShowDialog(id, style, title, button1, button2, text)
	if title == "Mobile" then -- ñþäà àéäè íóæíîãî äèàëîãà
        if text:match(control_recon_playernick) then
           t_online = "Ìîáèëüíûé ëàóí÷åð"
		   else
		   t_online = "Êëèåíò SAMP"
        end
		sampAddChatMessage("")
		sampAddChatMessage(tag .."Èãðîê {EE1010}".. control_recon_playernick .. "["..control_recon_playerid.."] {CCCCCC}èñïîëüçóåò {EE1010}".. t_online)
		sampAddChatMessage("")
    end
	
	if check_report or id == 2349 then
	 if title:find("(%d+) (.+)") then
        nickname = text:match("(.+)")
     end
	end 

	if elm.checkbox.show_admins.v then 
		if id == 0 and title:find("Àäìèíèñòðàöèÿ ïðîåêòà") then
			admins = {}
			local j = 0
			text = text .. "\n"
			for i = 0, text:len()-1 do 
				local s = text:sub(i, i)
				if s == "\n" then 
					local line = text:sub(j, i)
					line = line:gsub("{......}", "")
					if line:match("(.+)%((%d+)%) %((.+)%)") then
						local nick, id, prefix, lvl, vig, rep = line:match("(.+)%((%d+)%) %((.+)%) | Óðîâåíü: (%d+) | Âûãîâîðû: (%d+) èç 3 | Ðåïóòàöèÿ: (%d+)")
						local admin = {
							nick = nick,
							id = id,
							prefix = prefix,
							lvl = lvl,
							vig = vig,
							rep = rep
						}
						table.insert(admins, admin)
					else
						local nick, id, lvl, vig, rep = line:match("(.+)%((%d+)%) | Óðîâåíü: (%d+) | Âûãîâîðû: (%d+) èç 3 | Ðåïóòàöèÿ: (%d+)")
						local admin = {
							nick = nick,
							id = id,
							lvl = lvl,
							vig = vig,
							rep = rep
						}
						table.insert(admins, admin)
					end
					j = i
				end
			end
		end
	end
end

function sampev.onServerMessage(color, text)

	if text:find("%[(.+)%] IP:") then
        local nick, ip2 = text:match("%[(.+)%] IP: (.+) | IP")
        ip1 = ip2
        return true
    end

	chatlog = io.open(getFileName(), "r+")
    chatlog:seek("end", 0);
	chatTime = "[" .. os.date("*t").hour .. ":" .. os.date("*t").min .. ":" .. os.date("*t").sec .. "] "
    chatlog:write(enc(chatTime .. text) .. "\n")
    chatlog:flush()
	chatlog:close()
	if text:find("Âû îòêëþ÷èëè ìèãàíèå âàøåãî íèêíåéìà") then  
		elm.checkbox.clist_adm.v = false 
	elseif text:find("Âàø íèêíåéì òåïåðü ìèãàåò ðàçíûìè öâåòàìè!")	then 
		elm.checkbox.clist_adm.v = true 
	end	

	if text:find("%[A%] Àäìèíèñòðàòîð (.+)%[(%d+)%] %(%d+ level%) àâòîðèçîâàëñÿ â àäìèí ïàíåëè") or text:find("%[A%-(%d+)%] (.+) îòêëþ÷èëñÿ") then 
		if elm.checkbox.show_admins.v then 
			sampSendChat("/admins ")
		end	
		return true 
	end	

	local check_string = string.match(text, "[^%s]+")

	if check_string == '(Æàëîáà/Âîïðîñ)' and elm.checkbox.push_report.v then
		showNotification("[AT - Óâåäîìëåíèå]", "Ïîñòóïèë íîâûé ðåïîðò.")
		return true
	end	

	if text == "Âû îòêëþ÷èëè ìåíþ ïðè íàáëþäåíèè" and elm.checkbox.atrecon.v then
		sampSendChat("/remenu")
		return false
	end
	if text == "Âû âêëþ÷èëè ìåíþ ïðè íàáëþäåíèè" then
		control_recon = true
		if recon_to_player then
			control_info_load = true
			accept_load = false
		end
		return false
	end
	if text == "Âû îòêëþ÷èëè ìåíþ ïðè íàáëþäåíèè" and not elm.checkbox.atrecon.v then
		control_recon = false
		return false
	end
	if text == "Èãðîê íå â ñåòè" and recon_to_player then
		recon_to_player = false
		showNotification(tag, "Èãðîê íå â ñåòè!")
		if elm.checkbox.keysync.v then 
			lua_thread.create(function()
				wait(1)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/keysync off")
				setVirtualKeyDown(VK_RETURN)
			end)
		elseif elm.checkbox.keysync.v == false then
			lua_thread.create(function()
				wait(1)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/keysync off")
				setVirtualKeyDown(VK_RETURN)
			end)
		end	
		sampSendChat("/reoff")
	end
end

function main()
	while not isSampAvailable() do wait(100) end
	sampRegisterChatCommand("prf1", function(arg)
		sampSendChat("/prefix " .. arg .. " Õåëïåð " .. elm.input.prefix_Helper.v)
	end)
	sampRegisterChatCommand("prf2", function(arg)
		sampSendChat("/prefix " .. arg .. " Ìîäåðàòîð " .. elm.input.prefix_Moderator.v)
	end)
	sampRegisterChatCommand("prf3", function(arg)
		sampSendChat("/prefix " .. arg .. " Ìë.Àäìèíèñòðàòîð " .. elm.input.prefix_Madm.v)
	end)
	sampRegisterChatCommand("prf4", function(arg)
		sampSendChat("/prefix " .. arg .. " Àäìèíèñòðàòîð " .. elm.input.prefix_adm.v)
	end)
	sampRegisterChatCommand("prf5", function(arg)
		sampSendChat("/prefix " .. arg .. " Ñò.Àäìèíèñòðàòîð " .. elm.input.prefix_STadm.v)
	end)
	sampRegisterChatCommand("prf6", function(arg)
		sampSendChat("/prefix " .. arg .. " Ïîìîùíèê.Ãëàâ.Àäìèíèñòðàòîðà " .. elm.input.prefix_PGAadm.v)
	end)
	sampRegisterChatCommand("prf7", function(arg)
		sampSendChat("/prefix " .. arg .. " Çàì.Ãëàâ.Àäìèíèñòðàòîðà " .. elm.input.prefix_ZGAadm.v)
	end)
	sampRegisterChatCommand("prf8", function(arg)
		sampSendChat("/prefix " .. arg .. " Ãëàâíûé.Àäìèíèñòðàòîð. " .. elm.input.prefix_GAadm.v)
	end)

	_, watermark_id = sampGetPlayerIdByCharHandle(playerPed)
    watermark_nick = sampGetPlayerNickname(watermark_id)
	
	downloadUrlToFile(update_url, update_path, function(id, status)
		updateIni = inicfg.load(nil, update_path)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
			if tonumber(updateIni.info.version) > script_version then 
				sampAddChatMessage(tag .. " Äîñòóïíî îáíîâëåíèå. Äëÿ îáíîâëåíèå ïåðåéäèòå â ìåíþ -> «Íàñòðîéêè» -> «Îáíîâèòü»", -1)
			end
		end
	end)
	chatlogDirectory = getWorkingDirectory() .. "\\config\\AdminTool\\chatlog"
    if not doesDirectoryExist(chatlogDirectory) then
        createDirectory(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog")
    end
	if not doesDirectoryExist(getWorkingDirectory() .. "/config/AdminTool") then
		createDirectory(getWorkingDirectory() .. "/config/AdminTool")
	end

	font_watermark = renderCreateFont("Arial", 10, font_admin_chat.BOLD)

	lua_thread.create(function()
		while true do 
			renderFontDrawText(font_watermark, " {6A5ACD}[AdminTool]{FFFFFF} version - " .. script_version_text .. "", 10, sh-20, 0xCCFFFFFF)

			wait(1)
		end	
	end)

	check_cmd = lua_thread.create_suspended(function()
		wait(1000)
		check_cmd_re = false
	end)
	load_chat_log = lua_thread.create_suspended(loadChatLog)
	load_info_player = lua_thread.create_suspended(loadPlayerInfo)
	draw_re_menu = lua_thread.create_suspended(drawRePlayerInfo)
	renderadmin = lua_thread.create_suspended(renderAdmins)
	sampRegisterChatCommand("rep_fr", function()
		local fileonrp = io.open(getGameDirectory().."//moonloader//config//AdminTool//rpforms.txt","r+")
		local waitsc = 6000
		local delay = 500
		lua_thread.create(function()
		sampAddChatMessage(tag .. "Äîðîãîé àäìèíèñòðàòîð, ïðîèçâîäèòñÿ çàïóñê ôîðì èç ôàéëà rpforms.txt")
		wait(1000)
		if fileonrp then
			for line in fileonrp:lines() do
				sampSendChat(u8:decode(line))
				wait(delay)
			end
			sampAddChatMessage(tag .. "Âûäà÷à ôîðì çàâåðøåíà")
		end
		end)
		end)
		
		fileonrp = io.open(getGameDirectory().."//moonloader//config//AdminTool//rpforms.txt","r+");
		if fileonrp == nil then 
				fileonrp = io.open(getGameDirectory().."//moonloader//config//AdminTool//rpforms.txt","w"); 
			  	sampAddChatMessage(tag .. "Ôàéë rpforms.txt îòñóñòâóåò. Íà÷èíàþ åãî ñîçäàíèå.")
			  	fileonrp:close();
		   end;
	sampRegisterChatCommand("tpcord", tpcord)
	sampRegisterChatCommand("delch", delch)
	sampRegisterChatCommand("tpad", function()
		sampAddChatMessage(tag .. " Òåëåïîðòàöèÿ íà àäìèíèñòðàòèâíûé îñòðîâ.. ")
		setCharCoordinates(PLAYER_PED,3321,2308,35)
	end)
	sampRegisterChatCommand("ahi", function()
		sampSendChat("/a " .. u8:decode(elm.input.ATHelloAdm.v))
	end)

	sampRegisterChatCommand("tool", function()
		ATToolsMenu.v = not ATToolsMenu.v 
		imgui.Process = ATToolsMenu.v 
	end)

	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ ìóòîâ -------
	sampRegisterChatCommand("fd1", cmd_fd1)
	sampRegisterChatCommand("fd2", cmd_fd2)
	sampRegisterChatCommand("fd3", cmd_fd3)
	sampRegisterChatCommand("fd4", cmd_fd4)
	sampRegisterChatCommand("fd5", cmd_fd5)
	sampRegisterChatCommand("fd6", cmd_fd6)
	sampRegisterChatCommand("fd7", cmd_fd7)
	sampRegisterChatCommand("fd8", cmd_fd8)
	sampRegisterChatCommand("fd9", cmd_fd9)
	sampRegisterChatCommand("fd10", cmd_fd10)
	sampRegisterChatCommand("po1", cmd_po1)
	sampRegisterChatCommand("po2", cmd_po2)
	sampRegisterChatCommand("po3", cmd_po3)
	sampRegisterChatCommand("po4", cmd_po4)
	sampRegisterChatCommand("po5", cmd_po5)
	sampRegisterChatCommand("po6", cmd_po6)
	sampRegisterChatCommand("po7", cmd_po7)
	sampRegisterChatCommand("po8", cmd_po8)
	sampRegisterChatCommand("po9", cmd_po9)
	sampRegisterChatCommand("po10", cmd_po10)
	sampRegisterChatCommand("m", cmd_m)
	sampRegisterChatCommand("ok", cmd_ok)
	sampRegisterChatCommand("oa", cmd_oa)
	sampRegisterChatCommand("kl", cmd_kl)
	sampRegisterChatCommand("up", cmd_up)
	sampRegisterChatCommand("or", cmd_or)
	sampRegisterChatCommand("nm", cmd_nm)
	sampRegisterChatCommand("nm1", cmd_nm1)
	sampRegisterChatCommand("nm2", cmd_nm2)
	sampRegisterChatCommand("ia", cmd_ia)
	sampRegisterChatCommand("rz", cmd_rz)
	sampRegisterChatCommand("zs", cmd_zs)
	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ ìóòîâ -------

	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ ìóòîâ ðåïîðòà -------
	sampRegisterChatCommand("rrz", cmd_rrz)
	sampRegisterChatCommand("roa", cmd_roa)
	sampRegisterChatCommand("ror", cmd_ror)
	sampRegisterChatCommand("rpo", cmd_rpo)
	sampRegisterChatCommand("rpo2", cmd_rpo2)
	sampRegisterChatCommand("rpo3", cmd_rpo3)
	sampRegisterChatCommand("rpo4", cmd_rpo4)
	sampRegisterChatCommand("rpo5", cmd_rpo5)
	sampRegisterChatCommand("rpo6", cmd_rpo6)
	sampRegisterChatCommand("rpo7", cmd_rpo7)
	sampRegisterChatCommand("rpo8", cmd_rpo8)
	sampRegisterChatCommand("rpo9", cmd_rpo9)
	sampRegisterChatCommand("rpo10", cmd_rpo10)
	sampRegisterChatCommand("cp", cmd_cp)
	sampRegisterChatCommand("cp2", cmd_cp2)
	sampRegisterChatCommand("cp3", cmd_cp3)
	sampRegisterChatCommand("cp4", cmd_cp4)
	sampRegisterChatCommand("cp5", cmd_cp5)
	sampRegisterChatCommand("cp6", cmd_cp6)
	sampRegisterChatCommand("cp7", cmd_cp7)
	sampRegisterChatCommand("cp8", cmd_cp8)
	sampRegisterChatCommand("cp9", cmd_cp9)
	sampRegisterChatCommand("cp10", cmd_cp10)
	sampRegisterChatCommand("rnm", cmd_rnm)
	sampRegisterChatCommand("rnm1", cmd_rnm1)
	sampRegisterChatCommand("rnm2", cmd_rnm2)
	sampRegisterChatCommand("rup", cmd_rup)
	sampRegisterChatCommand("rok", cmd_rok)
	sampRegisterChatCommand("rm", cmd_rm)
	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ ìóòîâ ðåïîðòà -------

	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ äæàéëîâ -------
	sampRegisterChatCommand("sk", cmd_sk)
	sampRegisterChatCommand("dz", cmd_dz)
	sampRegisterChatCommand("dz1", cmd_dz1)
	sampRegisterChatCommand("dz2", cmd_dz2)
	sampRegisterChatCommand("jm", cmd_jm)
	sampRegisterChatCommand("td", cmd_td)
	sampRegisterChatCommand("skw", cmd_skw)
	sampRegisterChatCommand("ngw", cmd_ngw)
	sampRegisterChatCommand("dbgw", cmd_dbgw)
	sampRegisterChatCommand("fsh", cmd_fsh)
	sampRegisterChatCommand("bag", cmd_bag)
	sampRegisterChatCommand("pmx", cmd_pmx)
	sampRegisterChatCommand("pk", cmd_pk)
	sampRegisterChatCommand("zv", cmd_zv)
	sampRegisterChatCommand("jch", cmd_jch)
	sampRegisterChatCommand("dgw", cmd_dgw)
	sampRegisterChatCommand("sch", cmd_sch)
	sampRegisterChatCommand("jcw", cmd_jcw)
	sampRegisterChatCommand("tdbz", cmd_tdbz)
	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ äæàéëîâ -------

	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ áàíîâ -------
	sampRegisterChatCommand('bosk', function(param)
        lua_thread.create(function()
            if param:match("(%d+)") then
                if sampIsPlayerConnected(param) then
                    sampSendChat('/getip ' .. param)
                    wait(100)
                    sampSendChat("/sban " .. param .. " 30 Îñêîðáëåíèå ïðîåêòà")
                    if ip1 then
                        sampSendChat("/banip " .. ip1 .. " 30 Îñêîðáëåíèå ïðîåêòà")
                    else
                        sampAddChatMessage(tag .. " Try again | Ýòà îøèáêà îçíà÷àåò.. ", -1)
						sampAddChatMessage(tag .. " ..÷òî ñêðèïò íå âèäèò ñòðî÷êè IP, ëèáî íå íàøåë å¸", -1)
                    end
                else
                    sampAddChatMessage(tag .. " Èãðîê íå ïîäêëþ÷¸í!", -1)
                end
            else
                sampAddChatMessage(tag .. ' Âû íå ââåëè ID!', -1)
            end
        end)
    end)
	sampRegisterChatCommand('brekl', function(param)
        lua_thread.create(function()
            if param:match("(%d+)") then
                if sampIsPlayerConnected(param) then
                    sampSendChat('/getip ' .. param)
                    wait(100)
                    sampSendChat("/sban " .. param .. " 999 Ðåêëàìà èíîãî ïðîåêòà")
                    if ip1 then
                        sampSendChat("/banip " .. ip1 .. " 999 Ðåêëàìà èíîãî ïðîåêòà")
                    else
						showNotification(tag, "Ïîïðîáóéòå åù¸ ðàç! \n IP íå áûë çàõâà÷åí")
                    end
                else
					showNotification(tag, "Èãðîê íå ïîäêëþ÷åí!")
                end
            else
				showNotification(tag, "Èñïîëüçóéòå /brekl [PlayerID]")
            end
        end)
    end)
	sampRegisterChatCommand("pl", cmd_pl)
	sampRegisterChatCommand("ch", cmd_ch)
	sampRegisterChatCommand("ob", cmd_ob)
	sampRegisterChatCommand("hl", cmd_hl)
	sampRegisterChatCommand("nk", cmd_nk)
	sampRegisterChatCommand("menk", cmd_menk)
	sampRegisterChatCommand("gcnk", cmd_gcnk)
	sampRegisterChatCommand("bnm", cmd_bnm)
	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ áàíîâ -------

	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ ìóòîâ â îôôëàéíå -------
	sampRegisterChatCommand("am", cmd_am)
	sampRegisterChatCommand("aok", cmd_aok)
	sampRegisterChatCommand("afd", cmd_afd)
	sampRegisterChatCommand("apo", cmd_apo)
	sampRegisterChatCommand("aoa", cmd_aoa)
	sampRegisterChatCommand("aup", cmd_aup)
	sampRegisterChatCommand("anm", cmd_anm)
	sampRegisterChatCommand("anm1", cmd_anm1)
	sampRegisterChatCommand("anm2", cmd_anm2)
	sampRegisterChatCommand("aor", cmd_aor)
	sampRegisterChatCommand("aia", cmd_aia)
	sampRegisterChatCommand("akl", cmd_akl)
	sampRegisterChatCommand("arz", cmd_arz)
	sampRegisterChatCommand("azs", cmd_azs)
	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ ìóòîâ â îôôëàéíå -------

	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ äæàéëîâ â îôôëàéíå -------
	sampRegisterChatCommand("ajcw", cmd_ajcw)
	sampRegisterChatCommand("ask", cmd_ask)
	sampRegisterChatCommand("adz", cmd_adz)
	sampRegisterChatCommand("adz1", cmd_adz1)
	sampRegisterChatCommand("adz2", cmd_adz2)
	sampRegisterChatCommand("afsh", cmd_afsh)
	sampRegisterChatCommand("atd", cmd_atd)
	sampRegisterChatCommand("abag", cmd_abag)
	sampRegisterChatCommand("apk", cmd_apk)
	sampRegisterChatCommand("azv", cmd_azv)
	sampRegisterChatCommand("askw", cmd_askw)
	sampRegisterChatCommand("angw", cmd_angw)
	sampRegisterChatCommand("adbgw", cmd_adbgw)
	sampRegisterChatCommand("adgw", cmd_adgw)
	sampRegisterChatCommand("ajch", cmd_ajch)
	sampRegisterChatCommand("apmx", cmd_apmx)
	sampRegisterChatCommand("asch", cmd_asch)
	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ äæàéëîâ â îôôëàéíå -------

	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ êèêîâ -------
	sampRegisterChatCommand("dj", cmd_dj)
	sampRegisterChatCommand("gnk1", cmd_gnk1)
	sampRegisterChatCommand("gnk2", cmd_gnk2)
	sampRegisterChatCommand("gnk3", cmd_gnk3)
	sampRegisterChatCommand("cafk", cmd_cafk)
	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ êèêîâ -------

	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ áàíîâ â îôôëàéíå -------
	sampRegisterChatCommand("aob", cmd_aob)
	sampRegisterChatCommand("ahl", cmd_ahl)
	sampRegisterChatCommand("ahli", cmd_ahli)
	sampRegisterChatCommand("apl", cmd_apl)
	sampRegisterChatCommand("ach", cmd_ach)
	sampRegisterChatCommand("achi", cmd_achi)
	sampRegisterChatCommand("ank", cmd_ank)
	sampRegisterChatCommand("amenk", cmd_amenk)
	sampRegisterChatCommand("agcnk", cmd_agcnk)
	sampRegisterChatCommand("agcnkip", cmd_agcnkip)
	sampRegisterChatCommand("rdsob", cmd_rdsob)
	sampRegisterChatCommand("rdsip", cmd_rdsip)
	sampRegisterChatCommand("abnm", cmd_abnm)
	------- Êîìàíäû èñêëþ÷èòåëüíî äëÿ áàíîâ â îôôëàéíå -------
	
	------ Êîìàíäû, èñïîëüçóåìûå â âñïîìîãàòåëüíûõ ñëó÷àÿõ -------
	sampRegisterChatCommand("u", cmd_u)
	sampRegisterChatCommand("uu", cmd_uu)
	sampRegisterChatCommand("uj", cmd_uj)
	sampRegisterChatCommand("as", cmd_as)
	sampRegisterChatCommand("stw", cmd_stw)
	sampRegisterChatCommand("ru", cmd_ru)
	sampRegisterChatCommand("aheal", function(id)
		lua_thread.create(function()
			sampSendClickPlayer(id, 0)
			wait(200)
			sampSendDialogResponse(500, 1, 4)
			wait(200)
			sampCloseCurrentDialogWithButton(0)
		end)
	end)
	sampRegisterChatCommand("akill", function(id)
		lua_thread.create(function()
			sampSendClickPlayer(id, 0)
			wait(200)
			sampSendDialogResponse(500, 1, 7)
			wait(200)
			sampSendDialogResponse(48, 1, _, "kill")
			wait(200)
			sampCloseCurrentDialogWithButton(0)
		end)
	end)
	------ Êîìàíäû, èñïîëüçóåìûå â âñïîìîãàòåëüíûõ ñëó÷àÿõ -------

	sampRegisterChatCommand('spp', function()
	local playerid_to_stream = playersToStreamZone()
	for _, v in pairs(playerid_to_stream) do
	sampSendChat('/aspawn ' .. v)
	end
	end)
	-- çàñïàâíè âñåõ âîêðóãå ñòðèìà

	sampRegisterChatCommand('cfind', function(param)
		if param == nil then
			text_ru = { }
			ATChatLogger.v = true
			imgui.Process = true
			chat_logger_text = readChatlog()
			readRussian()
		else
			text_ru = { }
			ATChatLogger.v = true
			imgui.Process = true
			chat_find.v = u8:encode(param)
			chat_logger_text = readChatlog()
			readRussian()
		end
		load_chat_log:run()
	end)
	-- àêòèâàöèÿ ÷àò-ëîããåðà

	sampRegisterChatCommand("sendpass", function()
		sampAddChatMessage(tag .. "Ïàðîëü: " .. u8:decode(elm.input.ATAdminPass.v))
	end)

	------------------ Ïîêàç çàïóñêà ñêðèïòà -------------------------
	sampAddChatMessage(tag .. " Ñêðèïò áûë èíèöèàëèçèðîâàí! Äëÿ ïðîâåðêè ââåäèòå /tool")
	------------------ Ïîêàç çàïóñêà ñêðèïòà -------------------------

	_, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	nick = sampGetPlayerNickname(id)

	renderadmin:run()

	while true do

		wait(0)

		imgui.Process = true	

		if render.acpos then  
			change_show_admins()
		end	

		if isKeyDown(strToIdKeys(ATcfg.keys.ATRecon)) and (sampIsChatInputActive() == false) and ATToolsMenu.v == false then  
			lua_thread.create(function()
				wait(1000)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/re " )
			end)
		end	
			
		if elm.checkbox.autoalogin.v == true and selectlogin == false and scanspawn then
			-- lua_thread.create(function()
			-- 	if sampGetCurrentDialogId() == 1227 and elm.input.ATAdminPass.v and sampIsDialogActive() then
        	-- 	    sampSendDialogResponse(1227, 1, _, u8:decode(elm.input.ATAdminPass.v))
			-- 		sampCloseCurrentDialogWithButton(1227, 1)
			-- 	end
			-- end)
			wait(10000)
			sampAddChatMessage(tag .. "Àâòîðèçèðóþñü ïîä àäìèíêîé!", -1)
			if sampIsChatInputActive() == false and sampIsDialogActive() == false and elm.input.ATAdminPass.v and selectlogin == false then  
				wait(3000)
				sampSendChat("/alogin " .. u8:decode(elm.input.ATAdminPass.v))
				selectlogin = true
				scanspawn = false
			end
		end
		-- àâòîìàòè÷åñêèé ââîä ïàðîëÿ

		if isKeyDown(strToIdKeys(ATcfg.keys.ATOnline)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and ATToolsMenu.v == false then
			sampSendChat("/online")
			wait(100)
			local c = math.floor(sampGetPlayerCount(false) / 10)
			sampSendDialogResponse(1098, 1, c - 1)
			sampCloseCurrentDialogWithButton(0)
			wait(650)
		end
		-- ââåäåííûé êëþ÷ êëàâèøè ïî âûäà÷å çà online

		if isKeyJustPressed(strToIdKeys(ATcfg.keys.ATTool)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) then
			wait(100)
			ATToolsMenu.v = not ATToolsMenu.v
			imgui.Process = ATToolsMenu.v
		end
		-- ââåäåííûé êëþ÷ êëàâèøè ïî /tool

		if isKeyDown(strToIdKeys(ATcfg.keys.ATReportRP)) and sampIsDialogActive() and ATToolsMenu.v == false then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. " | Ïðèÿòíîé èãðû íà RDS <3 ")
			wait(650)
		end 
		-- ââåäåííûé êëþ÷ êëàâèøè ïî /ans
		
		if isKeyDown(strToIdKeys(ATcfg.keys.ATReportRP1)) and sampIsDialogActive() and ATToolsMenu.v == false then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. " | Óäà÷íîãî âðåìÿïðåïðîâîæäåíèÿ. ")
			wait(650)
		end
		-- ââåäåííûé êëþ÷ êëàâèøè ïî NumPad / (/ans)

		if sampGetCurrentDialogEditboxText() == '.ñö' or sampGetCurrentDialogEditboxText() == '/cw' then  
			sampSetCurrentDialogEditboxText(elm.input.ATColor.v)
		end  

		if isKeyJustPressed(0x09) and elm.checkbox.custom_tab.v then
			tab_board.ActivetedScoreboard()
		end

		if isKeyDown(strToIdKeys(ATcfg.keys.ATReportRP2)) and sampIsChatInputActive() and ATToolsMenu.v == false then
			local string = string.sub(sampGetChatInputText(), 0, string.len(sampGetChatInputText()) - 1)
			sampSetChatInputText(string .. " | Ïðèÿòíîé èãðû íà RDS! <3")
			wait(650)
		end

		if isKeyJustPressed(strToIdKeys(ATcfg.keys.ATReportAns)) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and ATToolsMenu.v == false then
			sampSendChat("/ans ")
			sampSendDialogResponse (2348, 1, 0)
		end

		if isKeyDown(strToIdKeys(ATcfg.keys.ATWHkeys)) and ATToolsMenu.v == false then  
			lua_thread.create(function()
				wait(1)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/wh")
				setVirtualKeyDown(VK_RETURN)
			end)
		end

		if control_recon and recon_to_player then
			if control_info_load then
				control_info_load = false
				load_info_player:run()
				ATre_menu.v = true
				imgui.Process = true
				tool_re = 0
			end
		else
			ATre_menu.v = false
		end
		if not sampIsPlayerConnected(control_recon_playerid) then
			ATre_menu.v = false
			control_recon_playerid = -1
		end

        if isKeyJustPressed(VK_RBUTTON) and not sampIsChatInputActive() and not sampIsDialogActive() and control_recon and recon_to_player then
			imgui.ShowCursor = not imgui.ShowCursor
			wait(600)
        end

        if isKeyDown(VK_NumPad6) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendChat("/re " .. control_recon_playerid+1)
		end

		if isKeyDown(VK_NumPad4) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendChat("/re " .. control_recon_playerid-1)
		end

		if isKeyDown(VK_R) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendClickTextdraw(132)
			if elm.checkbox.keysync.v then 
				lua_thread.create(function()
					wait(1000)
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/keysync " .. control_recon_playerid)
					setVirtualKeyDown(VK_RETURN)
				end)
			elseif elm.checkbox.keysync.v == false then
				lua_thread.create(function()
					wait(1)
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/keysync off")
					setVirtualKeyDown(VK_RETURN)
				end)
			end
		end

		if isKeyDown(VK_Q) and (sampIsChatInputActive() == false) and (sampIsDialogActive() == false) and control_recon and recon_to_player then
			sampSendChat("/reoff " )
			recon_to_player = false
			imgui.ShowCursor = false
			if elm.checkbox.keysync.v then 
				wait(1)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/keysync off")
				setVirtualKeyDown(VK_RETURN)
				control_recon_playerid = -1
			elseif elm.checkbox.keysync.v == false then 
				wait(1)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/keysync off")
				setVirtualKeyDown(VK_RETURN)
				control_recon_playerid = -1
			end	
		end

		if not ATToolsMenu.v and not ATre_menu.v and not ATChatLogger.v then 
			imgui.Process = false 
			imgui.ShowCursor = false
		end	

		if ATToolsMenu.v then  
			sampSetChatInputEnabled(false)
		end	

		if sampGetDialogCaption() == "{ff8587}Àäìèíèñòðàöèÿ ïðîåêòà (îíëàéí)" and elm.checkbox.show_admins.v then 
			sampCloseCurrentDialogWithButton(0)
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

function change_show_admins()
	if isKeyJustPressed(VK_RBUTTON) then
		elm.ac.X = render.acX
		elm.ac.Y = render.acY
		render.acpos = false
	elseif isKeyJustPressed(VK_LBUTTON) then
		render.acpos = false
		ATcfg.setting.acX = elm.ac.X 
		ATcfg.setting.acY = elm.ac.Y
		save()
		showNotification("AdminTool - Save Settings", "Íàñòðîéêè ñîõðàíåíû óñïåøíî")
	else
		elm.ac.X, elm.ac.Y = getCursorPos()
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

function playersToStreamZone()
	local peds = getAllChars()
	local streaming_player = {}
	local _, pid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	for key, v in pairs(peds) do
		local result, id = sampGetPlayerIdByCharHandle(v)
		if result and id ~= pid and id ~= tonumber(control_recon_playerid) then
			streaming_player[key] = id
		end
	end
	return streaming_player
end

function tpcord(coords)
	local x, y, z = coords:match('(.+) (.+) (.+)') 
	setCharCoordinates(PLAYER_PED, x, y, z)
end  
-- òåëåïîðòàöèÿ ïî êîîðäèíàòàì

function delch(arg)
	notfy.addNotify("{87CEEB}AdminTool", 'Âèçóàëüíàÿ î÷èñòêà ÷àòà íà÷àëàñü', 2, 1, 6)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
	sampAddChatMessage("", -1)
end

function color() -- ôóíêöèÿ, âûïîëíÿþùàÿ ðàíäîìíèçàöèþ è âûâîä ðàíäîìíîãî öâåòà ñ ïîìîùüþ ñïåöèàëüíîãî os.time()
	mcolor = "{"
	math.randomseed( os.time() )
	for i = 1, 6 do
		local b = math.random(1, 16)
		if b == 1 then
			mcolor = mcolor .. "A"
		end
		if b == 2 then
			mcolor = mcolor .. "B"
		end
		if b == 3 then
			mcolor = mcolor .. "C"
		end
		if b == 4 then
			mcolor = mcolor .. "D"
		end
		if b == 5 then
			mcolor = mcolor .. "E"
		end
		if b == 6 then
			mcolor = mcolor .. "F"
		end
		if b == 7 then
			mcolor = mcolor .. "0"
		end
		if b == 8 then
			mcolor = mcolor .. "1"
		end
		if b == 9 then
			mcolor = mcolor .. "2"
		end
		if b == 10 then
			mcolor = mcolor .. "3"
		end
		if b == 11 then
			mcolor = mcolor .. "4"
		end
		if b == 12 then
			mcolor = mcolor .. "5"
		end
		if b == 13 then
			mcolor = mcolor .. "6"
		end
		if b == 14 then
			mcolor = mcolor .. "7"
		end
		if b == 15 then
			mcolor = mcolor .. "8"
		end
		if b == 16 then
			mcolor = mcolor .. "9"
		end
	end
	mcolor = mcolor .. '}'
	return mcolor
end

function renderAdmins()
	while true do
		if elm.checkbox.show_admins.v then
			if #admins > 0 then
				for i = 1, #admins do
					local admin = admins[i]
					local text
					if admin.prefix then
						text = string.format("%s[%s] %s | %s óðîâåíü | %s âûãîâîðîâ | %s ðåïóòàöèè.", admin.nick, admin.id, admin.prefix, admin.lvl, admin.vig, admin.rep)
					else
						text = string.format("%s[%s] | %s óðîâåíü | %s âûãîâîðîâ | %s ðåïóòàöèè.", admin.nick, admin.id, admin.lvl, admin.vig, admin.rep)
					end
					text = text:gsub("\n", "")
					renderFontDrawText(font_ac, elm.input.ATColor_admins.v .. text, elm.ac.X, elm.ac.Y+(elm.int.admFont.v+4)*(i+12), 0xFF9999FF)
				end
			end
		end	
		wait(1)
	end
end

function cmd_zs(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 600 " .. " Çëîóï.ñèìâîëàìè ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd1(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 120 " .. " Ñïàì/Ôëóä")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd2(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 240 " .. " Ñïàì/Ôëóä - x2 ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd3(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 360 " .. " Ñïàì/Ôëóä - x3 ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end

end

function cmd_fd4(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 480 " .. " Ñïàì/Ôëóä - x4 ")
	else
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd5(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 600 " .. " Ñïàì/Ôëóä - x5 ")
	else
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd6(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 720 " .. " Ñïàì/Ôëóä - x6 ")
	else
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd7(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 840 " .. " Ñïàì/Ôëóä - x7 ")
	else
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd8(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 960 " .. " Ñïàì/Ôëóä - x8 ")
	else
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd9(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 1080 " .. " Ñïàì/Ôëóä - x9 ")
	else
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fd10(arg)
	if #arg > 0 then 
		sampSendChat("/mute " .. arg .. " 1200 " .. " Ñïàì/Ôëóä - x10 ")
	else
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po1(arg)
	if #arg > 0 then
		sampSendChat("/mute "  .. arg .. " 120 " .. " Ïîïðîøàéíè÷åñòâî")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po2(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 240 " .. " Ïîïðîøàéíè÷åñòâî - x2")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po3(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 360 " .. " Ïîïðîøàéíè÷åñòâî - x3")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po4(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 480 " .. " Ïîïðîøàéíè÷åñòâî - x4")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po5(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 600 " .. " Ïîïðîøàéíè÷åñòâî - x5")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po6(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 720 " .. " Ïîïðîøàéíè÷åñòâî - x6")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po7(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 840 " .. " Ïîïðîøàéíè÷åñòâî - x7")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po8(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 960 " .. " Ïîïðîøàéíè÷åñòâî - x8")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po9(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 1080 " .. " Ïîïðîøàéíè÷åñòâî - x9")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_po10(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 1200 " .. " Ïîïðîøàéíè÷åñòâî - x10")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end


function cmd_m(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 300 " .. " Íåöåíçóðíàÿ ëåêñèêà. ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ia(arg)
	if #arg > 0 then
		sampSendChat("/mute " ..  arg .. " 2500 " .. " Âûäà÷à ñåáÿ çà àäìèíèñòðàöèþ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_kl(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 3000 " .. " Êëåâåòà íà àäìèíèñòðàöèþ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_oa(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 2500 " .. " Îñê/Óíèæ.àäìèíèñòðàöèè  ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ok(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 400 " .. " Îñêîðáëåíèå/Óíèæåíèå. ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_nm1(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 2500 " .. " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_nm2(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 5000 " ..  " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_or(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 5000 " .. " Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_nm(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 900 " .. " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_up(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 1000 " .. " Óïîìèíàíèå ñòîðîííèõ ïðîåêòîâ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rz(arg)
	if #arg > 0 then
		sampSendChat("/mute " .. arg .. " 5000 " .. " Ðîçæèã ìåæíàö. ðîçíè")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end	
------- Ôóíêöèè, îòíîñÿùèåñÿ ê ìóòàì -------

------- Ôóíêöèè, îòíîñÿùèåñÿ ê ìóòàì çà ðåïîðò -------
function cmd_rup(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 1000 " .. " Óïîìèíàíèå ñòîðîííèõ ïðîåêòîâ. ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ror(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 5000 " .. " Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 120 " .. " caps/offtop in report ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp2(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 240 " .. " caps/offtop in report - x2")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp3(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 360 " .. " caps/offtop in report - x3")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp4(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 480 " .. " caps/offtop in report - x4")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp5(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 600 " .. " caps/offtop in report - x5")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp6(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 720 " .. " caps/offtop in report - x6")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp7(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 840 " .. " caps/offtop in report - x7")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp8(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 960 " .. " caps/offtop in report - x8")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp9(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 1080 " .. " caps/offtop in report - x9")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cp10(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 1200 " .. " caps/offtop in report - x10")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 120 " .. " Ïîïðîøàéíè÷åñòâî ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo2(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 240 " .. " Ïîïðîøàéíè÷åñòâî - x2")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo3(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 360 " .. " Ïîïðîøàéíè÷åñòâî - x3")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo4(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 480 " .. " Ïîïðîøàéíè÷åñòâî - x4")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo5(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 600 " .. " Ïîïðîøàéíè÷åñòâî - x5")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo6(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 720 " .. " Ïîïðîøàéíè÷åñòâî - x6")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo7(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 840 " .. " Ïîïðîøàéíè÷åñòâî - x7")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo8(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 960 " .. " Ïîïðîøàéíè÷åñòâî - x8")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo9(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 1080 " .. " Ïîïðîøàéíè÷åñòâî - x9")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rpo10(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 1200 " .. " Ïîïðîøàéíè÷åñòâî - x10")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rm(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 300 " .. " Íåöåíçóðíàÿ ëåêñèêà. ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_roa(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 2500 " .. " Îñê/Óíèæ.àäìèíèñòðàöèè  ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rnm(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 900 " .. " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rnm1(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 2500 " .. " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rnm2(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 5000 " ..  " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rok(arg)
	if #arg > 0 then
		sampSendChat("/rmute " .. arg .. " 400 " .. " Îñêîðáëåíèå/Óíèæåíèå. ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rrz(arg)
	if #arg > 0 then 
		sampSendChat("/rmute " .. arg .. " 5000 " .. " Ðîçæèã ìåæíàö. ðîçíè")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end	
------- Ôóíêöèè, îòíîñÿùèåñÿ ê ìóòàì çà ðåïîðò -------

------- Ôóíêöèè, îòíîñÿùèåñÿ ê äæàéëàì -------
function cmd_sk(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " Spawn Kill")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_dz(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " DM/DB in zz")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_dz1(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 600 " .. " DM/DB in zz x2")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_dz2(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " DM/DB in zz x3")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_dz3(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 1200 " .. " DM/DB in zz x4")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_td(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " DB/car in trade ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_jm(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " Íàðóøåíèå ïðàâèë ÌÏ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_pmx(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " Ñåðüåçíàÿ ïîìåõà èãðîêàì ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_skw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 600 " .. " SK in /gw ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_dgw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 500 " .. " Èñïîëüçîâàíèå íàðêîòèêîâ in /gw ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ngw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 600 " .. " Èñïîëüçîâàíèå çàïðåùåííûõ êîìàíä in /gw ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_dbgw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 600 " .. " Èñïîëüçîâàíèå âåðòîëåòà in /gw ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_fsh(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " Èñïîëüçîâàíèå SpeedHack/FlyCar ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_bag(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 300 " .. " Èãðîâîé áàãîþç (deagle in car)")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_pk(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " Èñïîëüçîâàíèå ïàðêóð ìîäà ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_jch(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 3000 " .. " Èñïîëüçîâàíèå ÷èòåðñêîãî ñêðèïòà/ÏÎ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_zv(arg)
	if #arg > 0 then
		sampSendChat("/jail " ..  arg .. " 3000 " .. " Çëîóïîòðåáëåíèå VIP`om ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_sch(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " Èñïîëüçîâàíèå çàïðåùåííûõ ñêðèïòîâ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_jcw(arg)
	if #arg > 0 then
		sampSendChat("/jail " .. arg .. " 900 " .. " Èñïîëüçîâàíèå ClickWarp/Metla (È×Ñ)")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_tdbz(arg)
	if #arg > 0 then  
		sampSendChat("/jail " .. arg .. " 900 " .. " ÄÁ ñ Êîâøîì (zz)")
	else  
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)	
	end 
end	
------- Ôóíêöèè, îòíîñÿùèåñÿ ê äæàéëàì -------

------- Ôóíêöèè, îòíîñÿùèåñÿ ê áàíàì -------
function cmd_hl(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
		sampSendChat("/ans " .. arg .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 3 " .. " Îñêîðáëåíèå/Óíèæåíèå/Ìàò â õåëïåðå")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)	
	end
end

function cmd_pl(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
		sampSendChat("/ans " .. arg .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
		sampSendChat("/ban " .. arg .. " 7 " .. " Ïëàãèàò íèêà àäìèíèñòðàòîðà ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ob(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
		sampSendChat("/ans " .. arg .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 7 " .. " Îáõîä ïðîøëîãî áàíà ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end 	

function cmd_ch(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
		sampSendChat("/ans " .. arg .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 7 " .. " Èñïîëüçîâàíèå ÷èòåðñêîãî ñêðèïòà/ÏÎ. ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_gcnk(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
		sampSendChat("/ans " .. arg .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 7 " .. " Áàíäà, ñîäåðæàùàÿ íåöåíçóðíóþ ëåêñèíó ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_menk(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
		sampSendChat("/ans " .. arg .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
		sampSendChat("/ban " .. arg .. " 7 " .. " Íèê, ñîäåðæàþùèé çàïðåùåííûå ñëîâà ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_nk(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
		sampSendChat("/ans " .. arg .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
		sampSendChat("/ban " .. arg .. " 7 " .. " Íèê, ñîäåðæàùèé íåöåíçóðíóþ ëåêñèêó ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_bnm(arg)
	if #arg > 0 then
		sampSendChat("/ans " .. arg .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
		sampSendChat("/ans " .. arg .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
		sampSendChat("/iban " .. arg .. " 7 " .. " Íåàäåêâàòíîå ïîâåäåíèå")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end	
------- Ôóíêöèè, îòíîñÿùèåñÿ ê áàíàì -------

------- Ôóíêöèè, îòíîñÿùèåñÿ ê äæàéëàì â îôôëàéíå -------
function cmd_asch(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " Èñïîëüçîâàíèå çàïðåùåííûõ ñêðèïòîâ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ajch(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 3000 " .. " Èñïîëüçîâàíèå ÷èòåðñêîãî ñêðèïòà/ÏÎ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_azv(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " ..  arg .. " 3000 " .. " Çëîóïîòðåáëåíèå VIP`om ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_adgw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 500 " .. " Èñïîëüçîâàíèå íàðêîòèêîâ in /gw ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ask(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " SpawnKill ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_adz(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " DM/DB in zz ")	
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_adz1(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 600 " .. " DM/DB in zz x2")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_adz2(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " DM/DB in zz x3")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_adz3(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 1200 " .. " DM/DB in zz x4")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_atd(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " DB/car in trade ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ajm(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " Íàðóøåíèå ïðàâèë ÌÏ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_apmx(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " Ñåðüåçíàÿ ïîìåõà èãðîêàì ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_askw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 600 " .. " SK in /gw ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_angw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 600 " .. " Èñïîëüçîâàíèå çàïðåùåííûõ êîìàíä in /gw ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_adbgw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 600 " .. " db-âåðò, ñòðåëüáà ñ àâò/ìîòî/êðûøè in /gw ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_afsh(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " Èñïîëüçîâàíèå SpeedHack/FlyCar ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_abag(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 300 " .. " Èãðîâîé áàãîþç (deagle in car)")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_apk(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " Èñïîëüçîâàíèå ïàðêóð ìîäà ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ajcw(arg)
	if #arg > 0 then
		sampSendChat("/prisonakk " .. arg .. " 900 " .. " Èñïîëüçîâàíèå ClickWarp/Metla (È×Ñ)")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end
------- Ôóíêöèè, îòíîñÿùèåñÿ ê äæàéëàì â îôôëàéíå -------

------- Ôóíêöèè, îòíîñÿùèåñÿ ê ìóòàì â îôôëàéíå -------
function cmd_azs(arg)
	if #arg > 0 then  
		sampSendChat("/muteakk"  .. arg .. " 600 " .. " Çëîóï.ñèìâîëàìè")
	else  
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end 
end		

function cmd_afd(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 120 " .. " Ñïàì/Ôëóä")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_apo(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 120 " .. " Ïîïðîøàéíè÷åñòâî ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_am(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 300 " .. " Íåöåíçóðíàÿ ëåêñèêà.")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_aok(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 400 " .. " Îñêîðáëåíèå/Óíèæåíèå. ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_anm(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 900 " .. " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_anm1(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 2500 " .. " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_anm2(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 5000 " .. " Íåàäåêâàòíîå ïîâåäåíèå ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_aoa(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 2500 " .. " Îñê/Óíèæ.àäìèíèñòðàöèè ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_aor(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 5000 " .. " Îñêîðáëåíèå/Óïîìèíàíèå ðîäíûõ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_aup(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 1000 " .. " Óïîìèíàíèå èíîãî ïðîåêòà ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end 

function cmd_aia(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 2500 " .. " Âûäà÷à ñåáÿ çà àäìèíèñòðàòîðà ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_akl(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 3000 " .. " Êëåâåòà íà àäìèíèñòðàöèþ ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_arz(arg)
	if #arg > 0 then
		sampSendChat("/muteakk " .. arg .. " 5000 " .. " Ðîçæèã ìåæíàö. ðîçíè ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end	
------- Ôóíêöèè, îòíîñÿùèåñÿ ê ìóòàì â îôôëàéíå -------

------- Ôóíêöèè, îòíîñÿùèåñÿ ê êèêàì -------
function cmd_dj(arg)
	if #arg > 0 then
		sampSendChat("/kick " .. arg .. " dm in jail ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_gnk1(arg)
	if #arg > 0 then
		sampSendChat("/kick " .. arg .. " Ñìåíèòå íèêíåéì. 1/3 ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_gnk2(arg)
	if #arg > 0 then
		sampSendChat("/kick " .. arg .. " Ñìåíèòå íèêíåéì. 2/3 ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_gnk3(arg)
	if #arg > 0 then
		sampSendChat("/kick " .. arg .. " Ñìåíèòå íèêíåéì. 3/3 ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end

function cmd_cafk(arg)
	if #arg > 0 then
		sampSendChat("/kick " .. arg .. " AFK in /arena ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè ID íàðóøèòåëÿ! ", -1)
	end
end
------- Ôóíêöèè, îòíîñÿùèåñÿ ê êèêàì -------

-------- Ôóíêöèè, îòíîñÿùèåñÿ ê áàíàì â îôôëàéíå -----------
function cmd_amenk(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 7 " .. " Íèê, ñîäåðæàþùèé çàïðåùåííûå ñëîâà ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end


function cmd_ahl(arg)
	if #arg > 0 then
		sampSendChat("/offban " .. arg .. " 3 " .. " Îñê/Óíèæåíèå/Ìàò â õåëïåðå")
		sampSendChat("/offstats " .. arg)
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ahli(arg)
	if #arg > 0 then
		sampSendChat("/banip " .. arg .. " 3 " .. " Îñê/Óíèæåíèå/Ìàò â õåëïåðå")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè IP íàðóøèòåëÿ! ", -1)
	end
end

function cmd_aob(arg)
	if #arg > 0 then
		sampSendChat("/offban " .. arg .. " 7 " .. " Îáõîä áàíà ")
		sampSendChat("/offstats " .. arg)
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_apl(arg)
	if #arg > 0 then
		sampSendChat("/offban " .. arg .. " 7 " .. " Ïëàãèàò íèêíåéìà àäìèíèñòðàòîðà")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ach(arg)
	if #arg > 0 then
		sampSendChat("/offban " .. arg .. " 7 " .. "  Èñïîëüçîâàíèå ÷èòåðñêîãî ñêðèïòà/ÏÎ ")
		sampSendChat("/offstats " .. arg)
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_achi(arg)
	if #arg > 0 then
		sampSendChat("/banip " .. arg .. " 7 " .. " È×Ñ/ÏÎ (ip) ") 
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè IP íàðóøèòåëÿ! ", -1)
	end
end

function cmd_ank(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 7 " .. " Íèê, ñîäåðæàùèé íåöåíçóðùèíó ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_agcnk(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 7 " .. " Áàíäà, ñîäåðæèò íåöåíçóðùèíó")
		sampSendChat("/offstats " .. arg)
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end

function cmd_agcnkip(arg)
	if #arg > 0 then
		sampSendChat("/banip " .. arg .. " 7 "  .. " Áàíäà, ñîäåðæèò íåöåíçóðùèíó (ip)")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè IP íàðóøèòåëÿ! ", -1)
	end
end

function cmd_rdsob(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 30 " .. " Îáìàí àäìèíèñòðàöèè/èãðîêîâ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè NICK íàðóøèòåëÿ! ", -1)
	end
end	

function cmd_rdsip(arg)
	if #arg > 0 then
		sampSendChat("/banip " .. arg .. " 30 " .. " Îáìàí àäìèíèñòðàöèè/èãðîêîâ")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè IP íàðóøèòåëÿ! ", -1)
	end
end	

function cmd_abnm(arg)
	if #arg > 0 then
		sampSendChat("/banakk " .. arg .. " 7 " .. " Íåàäåêâàòíîå ïîâåäåíèå")
	else 
		sampAddChatMessage(tag .. "Âû çàáûëè ââåñòè IP íàðóøèòåëÿ! ", -1)
	end
end	
-------- Ôóíêöèè, îòíîñÿùèåñÿ ê áàíàì â îôôëàéíå -----------

------ Ôóíêöèè, èñïîëüçóåìûå â âñïîìîãàòåëüíûõ ñëó÷àÿõ -------
function cmd_u(arg)
	sampSendChat("/unmute " .. arg)
end  

function cmd_uu(arg)
	sampSendChat("/unmute " .. arg)
	sampSendChat("/ans " .. arg .. " Èçâèíÿåìñÿ çà îøèáêó, íàêàçàíèå ñíÿòî. Ïðèÿòíîé èãðû")
end

function cmd_uj(arg)
	sampSendChat("/unjail " .. arg)
	sampSendChat("/ans " .. arg .. " Èçâèíÿåìñÿ çà îøèáêó, íàêàçàíèå ñíÿòî. Ïðèÿòíîé èãðû")
end

function cmd_stw(arg)
	sampSendChat("/setweap " .. arg .. " 38 5000 ")
end  

function cmd_as(arg)
	sampSendChat("/aspawn " .. arg)
end

function cmd_ru(arg)
	sampSendChat("/rmute " .. arg .. " 5 " .. "  Mistake/Îøèáêà")
	sampSendChat("/ans " .. arg .. " Èçâèíÿåìñÿ çà îøèáêó, íàêàçàíèå ñíÿòî. Ïðèÿòíîé èãðû.")
end
------ Ôóíêöèè, èñïîëüçóåìûå â âñïîìîãàòåëüíûõ ñëó÷àÿõ -------

------------------- Ðàçäåë îòâå÷àþùèé çà ÷òåíèå/çàïèñü ChatLogger ------------------------
function readRussian()
    for key,v in pairs(chat_logger_text) do 
        local text = u8:encode(dec(v))
        table.insert(text_ru, text)
    end 
end        

function readChatlog()
	local file_check = assert(io.open(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt", "r"))
	local t = file_check:read("*all")
	sampAddChatMessage(tag .. " ×òåíèå ôàéëà. ", -1)
	file_check:close()
	t = t:gsub("{......}", "")
	local final_text = {}
	final_text = string.split(t, "\n")
	sampAddChatMessage(tag .. " Ôàéë ïðî÷èòàí. ", -1)
		return final_text
end

function loadChatLog()
	wait(6000)
	accept_load_clog = true
end

function  getFileName()
    if not doesFileExist(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt") then
        f = io.open(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt","w")
        f:close()
        file = string.format(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
        return file
    else
        file = string.format(getWorkingDirectory() .. "\\config\\AdminTool\\chatlog\\" .. os.date("!*t").day .. "-" .. os.date("!*t").month .. "-" .. os.date("!*t").year .. ".txt")
        return file  
    end
end
------------------- Ðàçäåë îòâå÷àþùèé çà ÷òåíèå/çàïèñü ChatLogger ------------------------

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
        elseif ch == 168 then -- ¨
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
        elseif ch == 184 then -- ¸
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
------------------ Ôóíêöèè, îòâå÷àþùèå çà ïåðåâîä ñèìâîëîâ --------------------------------

------ Ôóíêöèè, îòâå÷àþùèå çà RGB-color ----------
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
------ Ôóíêöèè, îòâå÷àþùèå çà RGB-color ----------

------------- Ôóíêöèè, îòâå÷àþùèå çà ïðèâÿçêó/îòâÿçêó êëàâèø -----------------
function getDownKeys()
    local curkeys = ""
    local bool = false
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
            if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
                curkeys = v
            end
        end
    end
    for k, v in pairs(vkeys) do
        if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
            if tostring(curkeys):len() == 0 then
                curkeys = v
            else
                curkeys = curkeys .. " " .. v
            end
            bool = true
        end
    end
    return curkeys, bool
end

function getDownKeysText()
	tKeys = string.split(getDownKeys(), " ")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.id_to_name(tonumber(tKeys[i]))
			else
				str = str .. "+" .. vkeys.id_to_name(tonumber(tKeys[i]))
			end
		end
		return str
	else
		return "None"
	end
end

function strToIdKeys(str)
	tKeys = string.split(str, "+")
	if #tKeys ~= 0 then
		for i = 1, #tKeys do
			if i == 1 then
				str = vkeys.name_to_id(tKeys[i], false)
			else
				str = str .. " " .. vkeys.name_to_id(tKeys[i], false)
			end
		end
		return tostring(str)
	else
		return "(("
	end
end

function isKeysDown(keylist, pressed)
    local tKeys = string.split(keylist, " ")
    if pressed == nil then
        pressed = false
    end
    if tKeys[1] == nil then
        return false
    end
    local bool = false
    local key = #tKeys < 2 and tonumber(tKeys[1]) or tonumber(tKeys[2])
    local modified = tonumber(tKeys[1])
    if #tKeys < 2 then
        if not isKeyDown(VK_RMENU) and not isKeyDown(VK_LMENU) and not isKeyDown(VK_LSHIFT) and not isKeyDown(VK_RSHIFT) and not isKeyDown(VK_LCONTROL) and not isKeyDown(VK_RCONTROL) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    else
        if isKeyDown(modified) and not wasKeyReleased(modified) then
            if wasKeyPressed(key) and not pressed then
                bool = true
            elseif isKeyDown(key) and pressed then
                bool = true
            end
        end
    end
    if nextLockKey == keylist then
        if pressed and not wasKeyReleased(key) then
            bool = false
        else
            bool = false
            nextLockKey = ""
        end
    end
    return bool
end
------------- Ôóíêöèè, îòâå÷àþùèå çà ïðèâÿçêó/îòâÿçêó êëàâèø -----------------

function textSplit(str, delim, plain)
    local tokens, pos, plain = {}, 1, not (plain == false) --[[ delimiter is plain text by default ]]
    repeat
        local npos, epos = string.find(str, delim, pos, plain)
        table.insert(tokens, string.sub(str, pos, npos and npos - 1))
        pos = epos and epos + 1
    until not pos
    return tokens
end

function sampev.onTextDrawSetString(id, text)
	if id == 2059 and elm.checkbox.atrecon.v then
		player_info = textSplit(text, "~n~")
	end
end

function sampev.onShowTextDraw(id, data)
	if (id >= 3 and id <= 38 or 
	id == 266 or id == 344 or 
	id == 2057 or id == 359 or id == 2050 or id == 367 or id == 411
	or id == 104 or id == 105 or id == 106 or id == 107 or id == 108 
	or id == 110 or id == 111 or id == 109 or id == 130 or id == 139 
	or id == 138 or id == 122 or id == 132 or id == 350 or id == 133 
	or id == 103 or id == 134 or id == 135 or id == 136 or id == 137 
	or id == 126 or id == 114 or id == 113 or id == 119 or id == 131 
	or id == 132 or id == 129 or id == 123 or id == 117 or id == 112 
	or id == 116 or id == 119 or id == 120 or id == 118 or id == 121 
	or id == 124 or id == 125 or id == 127 or id == 128 or id == 115 
	or id == 2060 or id == 354 or id == 136 or id == 2056 or id == 140 
	or id == 141 or id == 142 or id == 145 or id == 146 or id == 144 
	or id == 147 or id == 148 or id == 149 or id == 149 or id == 150 
	or id == 143 or id == 153 or id == 154 or id == 152 or id == 155 
	or id == 156 or id == 157 or id == 158 or id == 151 or id == 159
	or id == 160 or id == 2052 or id == 179 or id == 165 or id == 437
	or id == 164 or id == 180 or id == 162 or id == 178 or id == 181 or id == 166 or id == 170 
	or id == 174 or id == 182 or id == 172 or id == 175 or id == 171 or id == 183 or id == 184 
	or id == 177 or id == 171 or id == 161 or id == 169 or id == 167 or id == 176 or id == 413) and elm.checkbox.atrecon.v then
		return false
	end
	if id == 2059 then  
		return false  
	end	
	if id == 428 or id == 431 then  
		sampAddChatMessage(data,-1)
	end	
end

function sampev.onSendCommand(command)
	local id = string.match(command, "/re (%d+)")
	if id ~= nil and not check_cmd_re and elm.checkbox.atrecon.v then
		recon_to_player = true
		if control_recon then
			control_info_load = true
			accept_load = false
		end
		control_recon_playerid = id
		if elm.checkbox.atrecon.v and sampIsPlayerConnected(control_recon_playerid) then
			check_cmd_re = true
			sampSendChat("/re " .. id)
			check_cmd:run()
			sampSendChat("/remenu")
			selectRecon = 1
			if elm.checkbox.keysync.v then 
				lua_thread.create(function()
					wait(1000)
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/keysync " .. control_recon_playerid)
					setVirtualKeyDown(VK_RETURN)
				end)
			elseif elm.checkbox.keysync.v == false then
				lua_thread.create(function()
					wait(1)
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/keysync off")
					setVirtualKeyDown(VK_RETURN)
				end)
			end
		elseif elm.checkbox.atrecon.v and not sampIsPlayerConnected(control_recon_playerid) then  
			if elm.checkbox.keysync.v then 
				lua_thread.create(function()
					wait(1000)
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/keysync off" )
					setVirtualKeyDown(VK_RETURN)
				end)
			elseif elm.checkbox.keysync.v == false then
				lua_thread.create(function()
					wait(1)
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/keysync off")
					setVirtualKeyDown(VK_RETURN)
				end)
			end
		end
	end
	if command == "/reoff" then
		if elm.checkbox.keysync.v then 
			lua_thread.create(function()
				wait(1)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/keysync off")
				setVirtualKeyDown(VK_RETURN)
			end)
		elseif elm.checkbox.keysync.v == false then
			lua_thread.create(function()
				wait(1)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/keysync off")
				setVirtualKeyDown(VK_RETURN)
			end)
		end
		recon_to_player = false
		imgui.ShowCursor = false
		control_recon_playerid = -1
	end
end

function loadPlayerInfo()
	wait(3000)
	accept_load = true
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

function onWindowMessage(msg, wparam, lparam)
	if(msg == 0x100 or msg == 0x101) and elm.checkbox.custom_tab.v then
		if wparam == VK_TAB then
			consumeWindowMessage(true, false)
		end
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

function imgui.Tooltip(text)
	if imgui.IsItemHovered() then
	   imgui.BeginTooltip()
	   imgui.Text(text)
	   imgui.EndTooltip()
	end
 end

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

local helloText = [[
	Äîáðîãî âðåìåíè ñóòîê. Ñïàñèáî çà ñêà÷èâàíèå äàííîãî ñêðèïòà! 
	{00BFFF}AdminTool {FFFFFF}ïðåäíàçíà÷åí äëÿ òîãî, ÷òîáû óïðîñòèòü ðàáîòó àäìèíèñòðàöèè.
	Ñâîè ïðåäëîæåíèÿ ïî ïîâîäó îáíîâëåíèé ìîæíî íàïèñàòü â ãðóïïó VK:
	https://vk.com/infsy
	Âû íàõîäèòåñü â íóëåâîì îêíå îñíîâíîãî ìåíþ! ×òîáû ïåðåéòè äàëüøå
	ïðîñòî ïåðåõîäèòå ïî ïóíêòàì ñëåâà, êîòîðûå âû âèäèòå
	Àâòîð äàííîãî ñêðèïòà: Åãîð Ôåäîñååâ, VK: {00BFFF}https://vk.com/alfantasy
	Õîðîøåé ðàáîòû âàì, êîëëåãà! :3
]]

function imgui.OnDrawFrame()

	if not ATToolsMenu.v and not ATre_menu.v and not ATChatLogger.v then 
		imgui.Process = false 
		imgui.ShowCursor = false
	end	

	if elm.int.styleImgui.v == 0 then
        black()
        ATcfg.setting.styleImgui = elm.int.styleImgui.v
        save()
    elseif elm.int.styleImgui.v == 1 then
        grey_black()
        ATcfg.setting.styleImgui = elm.int.styleImgui.v
        save()
	elseif elm.int.styleImgui.v == 2 then
		white()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v
		save()
    elseif elm.int.styleImgui.v == 3 then
        skyblue()
        ATcfg.setting.styleImgui = elm.int.styleImgui.v
        save()
    elseif elm.int.styleImgui.v == 4 then
        blue()
        ATcfg.setting.styleImgui = elm.int.styleImgui.v
        save()
    elseif elm.int.styleImgui.v == 5 then
        blackblue()
        ATcfg.setting.styleImgui = elm.int.styleImgui.v
        save()
    elseif elm.int.styleImgui.v == 6 then
        red()
        ATcfg.setting.styleImgui = elm.int.styleImgui.v
        save()
	elseif elm.int.styleImgui.v == 7 then 
		blackred()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v 
		save()
	elseif elm.int.styleImgui.v == 8 then 
		brown()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v 
		save()
	elseif elm.int.styleImgui.v == 9 then 
		violet()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v 
		save()
	elseif elm.int.styleImgui.v == 10 then  
		purple2()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v  
		save()
	elseif elm.int.styleImgui.v == 11 then  
		salat()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v  
		save()
	elseif elm.int.styleImgui.v == 12 then  
		yellow_green()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v  
		save()
	elseif elm.int.styleImgui.v == 13 then  
		banana()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v  
		save()
	elseif elm.int.styleImgui.v == 14 then  
		royalblue()
		ATcfg.setting.styleImgui = elm.int.styleImgui.v  
		save()
	end
	
	if ATToolsMenu.v then

		imgui.SetNextWindowSize(imgui.ImVec2(650, 400), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 2), sh1 / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		imgui.ShowCursor = true

		imgui.Begin(fa.ICON_SERVER .. u8" AdminTool [AT] ", ATToolsMenu, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
		imgui.BeginChild("##menuSecond", imgui.ImVec2(36, 362), true)
		imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
		imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10) 
		if imgui.Button(fai.ICON_FA_USER_COG, imgui.ImVec2(27,0)) then
			menuSelect = 1
		end
		imgui.Tooltip(u8"Îñíîâíûå ôóíêöèè AT")
		if imgui.Button(fa.ICON_ADDRESS_BOOK, imgui.ImVec2(27,0)) then  
			menuSelect = 12
		end	
		imgui.Tooltip(u8"Àäìèíèñòðàòèâíàÿ ñòàòèñòèêà")
        if imgui.Button(fa.ICON_FA_KEYBOARD, imgui.ImVec2(27,0)) then
            menuSelect = 2
        end
		imgui.Tooltip(u8"Ãîðÿ÷èå êëàâèøè")
		if imgui.Button(fa.ICON_FA_CROSSHAIRS, imgui.ImVec2(27,0)) then 
			menuSelect = 5 
		end	
		imgui.Tooltip(u8"Òðåéñåð ïóëü")
        if imgui.Button(fa.ICON_RSS, imgui.ImVec2(27,0)) then
            menuSelect = 3
        end
		imgui.Tooltip(u8"Ïîìîùü ïî /ans")
        if imgui.Button(fa.ICON_FA_LIST, imgui.ImVec2(27,0)) then
            menuSelect = 4
        end
		imgui.Tooltip(u8"Ôëóäû")
        if imgui.Button(fa.ICON_FILE_TEXT, imgui.ImVec2(27,0)) then
			menuSelect = 9
        end
		imgui.Tooltip(u8"Áëîêíîò")
        if imgui.Button(fa.ICON_FA_TEXT_HEIGHT, imgui.ImVec2(27,0)) then
            menuSelect = 6
        end
		imgui.Tooltip(u8"Ìåðîïðèÿòèÿ")
        if imgui.Button(fa.ICON_FA_COMMENTS, imgui.ImVec2(27,0)) then
            menuSelect = 7
        end
		imgui.Tooltip(u8"Íàêàçàíèÿ")
		if imgui.Button(fa.ICON_FA_REPLY, imgui.ImVec2(27,0)) then
            menuSelect = 8
        end
		imgui.Tooltip(u8"Ñïåöèàëüíûå ôóíêöèè")
		if imgui.Button(fa.ICON_CALCULATOR, imgui.ImVec2(27,0)) then  
			menuSelect = 13
		end	
		imgui.Tooltip(u8"Áèíäåð")
        if imgui.Button(fa.ICON_FA_COGS, imgui.ImVec2(27,0)) then
            menuSelect = 10
        end
		imgui.Tooltip(u8"Íàñòðîéêè")
		if imgui.Button(fa.ICON_POWER_OFF, imgui.ImVec2(27,0)) then  
			lua_thread.create(function()
				wait(200)
				sampAddChatMessage(tag .. " Âûãðóçêà ïðîöåññà AdminTool! Ïåðåçàãðóçêà: ALT+R")
				ATToolsMenu.v = false
				wait(200)
				plre.OffScript()
				plugin.OffScript()
				plugin2.OffScript()
				notfy.OffNotf()
				thisScript():unload()
			end)
		end  
		imgui.Tooltip(u8"Âûêëþ÷åíèå âñåãî AT.\nÅñëè íåîáõîäèìî ïåðåçàãðóçèòü, òî íàæìèòå ALT+R")
		imgui.PopStyleVar(1)
		imgui.PopStyleVar(1)
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("##menuSelectable", imgui.ImVec2(600, 362), true)
        if menuSelect == 0 then
            imgui.TextColoredRGB(u8(helloText))
        end
		if menuSelect == 1 then 
			imgui.Text(fa.ICON_REPLY .. u8" Ïàðîëü îò àäìèíêè ")
			imgui.SameLine()
			if imgui.InputText("", elm.input.ATAdminPass, imgui.InputTextFlags.Password) then 
				ATcfg.setting.ATAdminPass = elm.input.ATAdminPass.v
				save() 
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Ïðè ââîäå, ïàðîëü àâòîìàòè÷åñêè ñîõðàíÿåòñÿ â êîíôèã\nÏðè èíòåðôåéñå è ââîäå, áóäóò ïîêàçûâàòüñÿ *********')	
			if imgui.Button(fa.ICON_REFRESH .. u8"  Îáíîâèòü ##REFRESHTHISPASSWORD") then  
				elm.input.ATAdminPass.v = ''
				ATcfg.setting.ATAdminPass = elm.input.ATAdminPass.v  
				save()
			end	
			imgui.Separator()
			imgui.TextColoredRGB(fa.ICON_USER_CIRCLE .. u8' Áåññìåðòèå {808080}(/agm)')
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
			if imgui.ToggleButton('##AGM', elm.checkbox.god_mode) then 
				if elm.checkbox.god_mode.v then
					sampSendChat("/agm")
				else 
					sampSendChat("/agm")
				end 	
			end	
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
			imgui.Text(fai.ICON_FA_GEM .. u8" On/Off ìèã.êëèñò")
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 100)
			if imgui.ToggleButton("##Aclist", elm.checkbox.clist_adm) then 
				lua_thread.create(function()
					if elm.checkbox.clist_adm.v then 
						wait(3000)
						sampSendChat("/aclist")
					else
						wait(3000)
						sampSendChat("/aclist")
					end 
				end)	
			end		
			plugin2.autoMP()
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Ïðè îòêðûòèè ìåðîïðèÿòèÿ ÷åðåç AT\nàâòîìàòè÷åñêè ñîçäàåò òåëåïîðò íà ÌÏ')
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
			imgui.Text(fai.ICON_FA_SIGN_IN_ALT .. u8" AutoALogin")
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 100)
			if imgui.ToggleButton("##AutoALogin", elm.checkbox.autoalogin) then 
				ATcfg.setting.ATAlogin = elm.checkbox.autoalogin.v 
				save() 
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Àâòîìàòè÷åñêè àâòîðèçóåòñÿ ïîä àäìèíêó ïðè ââîäå /alogin\nÏàðîëü ìîæíî âûñòàâèòü â íà÷àëå!')
			imgui.Text(fa.ICON_BELL ..  u8" Óâåäîìëåíèÿ î ðåïîðòå")
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
			if imgui.ToggleButton("##Push_Report", elm.checkbox.push_report) then 
				ATcfg.setting.Push_Report = elm.checkbox.push_report.v 
				save() 
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Óâåäîìëÿåò î ïðèøåäøèõ ðåïîðòàõ.')
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
			imgui.Text(fa.ICON_ADDRESS_BOOK .. u8" ×àò-ëîããåð")
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 100)
			if imgui.ToggleButton("##Chat_Logger", elm.checkbox.chat_logger) then 
				ATcfg.setting.Chat_Logger = elm.checkbox.chat_logger.v 
				save() 
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Âûâîäèò ÷àò-ëîã âàì â îêíî // ëîãèðóåò ÷àò èãðû')
			plugin2.ActiveAutoMute()
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Çäåñü çàêëþ÷åí àâòîìóò çà ìàò è àâòîìóò çà îñêîðáëåíèÿ!")
			imgui.SameLine()
			plugin.translatecmd()
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Ïðè ââîäå êîìàíäû íà ðóññêîì, ïåðåâîäèò å¸ àâòîìàòè÷åñêè ïðàâèëüíî\nÏðèìåð: .ñôê - /car')
			imgui.Text(fa.ICON_OBJECT_GROUP .. u8" Ñustom ScoreBoard (TAB)")
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
			if imgui.ToggleButton("##AT_CTAB", elm.checkbox.custom_tab) then 
				if elm.checkbox.custom_tab.v then  
					showNotification("AdminTool", "Âêëþ÷åí Custom ScoreBoard (TAB)")
				else 	
					showNotification("AdminTool", "Âûêëþ÷åí Custom ScoreBoard (TAB)")
				end	
				ATcfg.setting.AT_CTAB = elm.checkbox.custom_tab.v 
				save() 
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Êëàññè÷åñêèé ScoreBoard (TAB) çàìåíÿåòñÿ ScoreBoard îò alfantasyz feat. SatanHolograms')
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
			imgui.Text(fa.ICON_ADDRESS_CARD .. u8" Custom Recon-Menu")
			imgui.SameLine()
			plugin2.SetReconPos()
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 100)
			if imgui.ToggleButton('##RanReMenu', elm.checkbox.atrecon) then 
				if elm.checkbox.atrecon.v then  
					showNotification("AdminTool", "Âêëþ÷åí Custom Recon-Menu")
				else 	
					showNotification("AdminTool", "Âûêëþ÷åí Custom Recon-Menu")
				end	
				ATcfg.setting.recon_menu = elm.checkbox.atrecon.v
				save()
			end
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Êëàññè÷åñêîå (ñåðâåðíîå) ðåêîí-ìåíþ çàìåíÿåòñÿ ðåêîíîì-ìåíþ îò alfantasyz feat. SatanHolograms')	
			plugin.ActiveWH()
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Àêòèâèðóåò WallHack, ýòî ïåðåêëþ÷àòåëü \n Åñòü åù¸ êîìàíäà /wh')	
			imgui.SameLine()
			plugin.InfiniteRun()
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Àêòèâèðóåò áåñêîíå÷íûé áåã âàøåìó ïåðñîíàæó.')	
			imgui.Text(fa.ICON_USER .. u8" Render /admins")
			imgui.SameLine()
			if imgui.Button(fa.ICON_FA_COGS .. "##AdminShow") then   
				imgui.OpenPopup("adminshow") 
			end	
			imgui.SameLine() 
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 400)
			if imgui.ToggleButton("##ShowAdmins", elm.checkbox.show_admins) then 
				ATcfg.setting.show_admins = elm.checkbox.show_admins.v
				save() 
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Ðåíäåðèò /admins îòäåëüíî, àâòîìàòè÷åñêè çàêðûâàÿ äèàëîã\n Ôóíêöèÿ íàõîäèòñÿ íà ñòàäèè òåñòèðîâàíèÿ/ðàçðàáîòêè. \nÄëÿ âûâîäà ðåíäåðà, íåîáõîäèìî ïðîïèñûâàòü /admins (ÂÐÅÌÅÍÍÎ)")
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 300)
			imgui.Text(fa.ICON_FA_KEYBOARD .. u8" Ñèíõðîíèç.êëàâû èãðîêà")
			imgui.SameLine()
			if imgui.Button(fa.ICON_FA_COGS .. u8" ##ChangePos") then  
				imgui.OpenPopup('keypos')
			end	
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 100)
			if imgui.ToggleButton("##KeySyncOn", elm.checkbox.keysync) then  
				ATcfg.setting.keysync = elm.checkbox.keysync.v  
				save()
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Ïîêàçûâàåò íàæàòûå êëàâèøè èãðîêà â ðåêîíå.")
			imgui.SameLine()
			if imgui.BeginPopup("keypos") then  
				if imgui.Button(fa.ICON_FA_COGS .. u8" Èçìåíåíèå ïîëîæåíèÿ îêíà") then  
					plugin.kposition()
				end	
				imgui.EndPopup()
			end	
			if imgui.BeginPopup("adminshow") then   
				if imgui.Button(u8"Èçìåíåíèå ïîëîæåíèÿ ðåíäåðà") then  
					render.acX = elm.ac.X; render.acY = elm.ac.Y
					render.acpos = true 
				end
				imgui.Separator()
				imgui.Text(u8" Öâåò ðåíäåðà")
				imgui.Text(u8"Ìîæåòå ââåñòè ñâîé öâåò ðåíäåðà, èñïîëüçóÿ öâåòà HTML è {} \n òî-åñòü, ê ïðèìåðó çåëåíûé è íóæíî ââåñòè {008000}")
				if imgui.InputText("", elm.input.ATColor_admins) then 
					ATcfg.setting.ATColor_admin = elm.input.ATColor_admins.v 
					save() 
				end	
				imgui.Separator()
				imgui.Text(u8'Ðàçìåð øðèôòà')
				if imgui.SliderInt("##sizeAcFont", elm.int.admFont, 1, 20) then
					font_ac = renderCreateFont("Arial", tonumber(elm.int.admFont.v), font_admin_chat.BOLD + font_admin_chat.SHADOW)
					ATcfg.setting.admFont = elm.int.admFont.v
					save()
				end	
				imgui.EndPopup()
			end	
		end	
		if menuSelect == 2 then 
			imgui.Text("")
			imgui.Text(u8"Çàæàòûå êíîïêè: ")
			imgui.SameLine()
			imgui.Text(getDownKeysText())
			imgui.Text("")
			imgui.Separator()
			imgui.Text(u8"Îòêðûòèå èíòåðôåéñà (/tool): ")
			imgui.SameLine()
			imgui.Text(ATcfg.keys.ATTool)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 1", imgui.ImVec2(75, 0)) then
				ATcfg.keys.ATTool = getDownKeysText()
				save()
			end 
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 1") then 
				ATcfg.keys.ATTool = "None"
				save()
			end	
			imgui.Separator()
			imgui.Text(u8"Âûäà÷à çà îíëàéí: ")
			imgui.SameLine()
			imgui.Text(ATcfg.keys.ATOnline)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 2", imgui.ImVec2(75, 0)) then
				ATcfg.keys.ATOnline = getDownKeysText()
				save()
			end
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 2 ") then 
				ATcfg.keys.ATOnline = "None"
				save()
			end	
			imgui.Separator()
			imgui.Text(u8"Îòêðûòèå /ans: ")
			imgui.SameLine()
			imgui.Text(ATcfg.keys.ATReportAns)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 3", imgui.ImVec2(75, 0)) then
				ATcfg.keys.ATReportAns = getDownKeysText()
				save()
			end
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 3 ") then 
				ATcfg.keys.ATReportAns = "None"
				save()
			end	
			imgui.Separator()
			imgui.Text(u8'Âûâîä "Ïðèÿòíîé èãðû" â /ans: ' )
			imgui.SameLine()
			imgui.Text(ATcfg.keys.ATReportRP)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 4", imgui.ImVec2(75, 0)) then
				ATcfg.keys.ATReportRP = getDownKeysText()
				save()
			end
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 4 ") then 
				ATcfg.keys.ATReportRP = "None"
				save()
			end	
			imgui.Separator()
			imgui.Text(u8"Ñòàòèñòèêà èãðîêà ïðè ñëåæêå: ")
			imgui.SameLine()
			imgui.Text(ATcfg.keys.Re_menu)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 5", imgui.ImVec2(75, 0)) then
				ATcfg.keys.Re_menu = getDownKeysText()
				save()
			end
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 5 ") then 
				ATcfg.keys.ATRe_menu = "None"
				save()
			end	
			imgui.Separator()
			imgui.Text(u8'Âûâîä "Ïðèÿòíîãî âðåìÿïðåïðîâîæäåíèÿ" â /ans: ' )
			imgui.SameLine()
			imgui.Text(ATcfg.keys.ATReportRP1)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 6", imgui.ImVec2(75, 0)) then
				ATcfg.keys.ATReportRP1 = getDownKeysText()
				save()
			end
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 6 ") then 
				ATcfg.keys.ATReportRP1 = "None"
				save()
			end	
			imgui.Separator()
			imgui.Text(u8'Âûâîä "Ïðèÿòíîé èãðû" â ÷àò: ' )
			imgui.SameLine()
			imgui.Text(ATcfg.keys.ATReportRP2)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 7", imgui.ImVec2(75, 0)) then
				ATcfg.keys.ATReportRP2 = getDownKeysText()
				save()
			end
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 7 ") then 
				ATcfg.keys.ATReportRP2 = "None"
				save()
			end	
			imgui.Separator()
			imgui.Text(u8'Âêëþ÷åíèå/âûêëþ÷åíèå WallHack: ' )
			imgui.SameLine()
			imgui.Text(ATcfg.keys.ATWHkeys)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 8", imgui.ImVec2(75, 0)) then
				ATcfg.keys.ATWHkeys = getDownKeysText()
				save()
			end
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 8 ") then 
				ATcfg.keys.ATWHkeys = "None"
				save()
			end	
			imgui.Separator()
			imgui.Text(u8'Àâòîìàòè÷åñêîå íàïèñàíèå /re â ÷àò: ')
			imgui.SameLine()
			imgui.Text(ATcfg.keys.ATRecon)
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 162)
			if imgui.Button(u8"Çàïèñàòü. ## 9", imgui.ImVec2(75, 0)) then
				ATcfg.keys.ATRecon = getDownKeysText()
				save()
			end
			imgui.SameLine()
			if imgui.Button(u8"Î÷èñòèòü. ## 9 ") then 
				ATcfg.keys.ATRecon = "None"
				save()
			end	
		end	
		if menuSelect == 3 then 
			imgui.Text(u8"Òûêàéòå íà êíîïêó, îòêðîåòñÿ ñïðàâî÷íèê :D")
			imgui.Separator()
			if imgui.Button(u8"Æàëîáû íà êîãî-òî/÷òî-òî") then
				imgui.OpenPopup(u8'Æàëîáû íà êîãî/÷òî-òî')
			end 
			imgui.SameLine()
			if imgui.Button(u8"Âîïðîñû ïî êîìàíäàì, /help") then 
				imgui.OpenPopup(u8'helpcmd')
			end	
			if imgui.Button(u8"Ïîìîùü ïî áàíäå/ñåìüå") then 
				imgui.OpenPopup(u8'helpgang')
			end	
			imgui.SameLine()
			if imgui.Button(u8"Ïîìîùü ïî òåëåïîðòàöèè") then 
				imgui.OpenPopup(u8'helptp')
			end	
			if imgui.Button(u8"Ïîìîùü ïî ïðîäàæå/ïîêóïêå") then 
				imgui.OpenPopup(u8'helpsell')
			end	
			imgui.SameLine()
			if imgui.Button(u8"Ïîìîùü ïî ïåðåäà÷å ÷åãî-òî") then 
				imgui.OpenPopup(u8'helpgive')
			end	
			if imgui.Button(u8"Îñòàëüíûå âîïðîñû") then 
				imgui.OpenPopup(u8'otherqu')
			end	
			imgui.SameLine()
			if imgui.Button(u8"Ñêèíû") then 
				imgui.OpenPopup(u8'skins')
			end	
			imgui.SameLine()
			if imgui.Button(u8"Ãîðÿ÷èå êëàâèøè") then 
				imgui.OpenPopup(u8'hotkeys')
			end	
			if imgui.BeginPopup(u8'helpcmd') then 
				imgui.Text(u8"/h7 - vip ($ .ï7 ), /h8 - êìä íà ñâàäüáû ($ .ï8 )\n/h13 - çàðàáîòîê ($ .ï13 ) ")
				imgui.Text(u8"/int - Èíôà â èíåòå ($ .èíô ) \n/vp1 - /vp4 - ïðèâåëåãèè îò Premuim äî Ëè÷íîãî ($ .âï1 - .âï4)")
				imgui.Text(u8"/gadm - ïîëó÷åíèå àäì ($ .ïàäì)")
				imgui.EndPopup()
			end	
			if imgui.BeginPopup(u8'helpgang') then 
				imgui.Text(u8"/fp - êàê îòêðûòü ìåíþ ñåìüè ($ .îòô )\n/mg - êàê îòêðûòü ìåíþ áàíäû ($ .îòá )")
				imgui.Text(u8"/ugf - êàê èñêëþ÷èòü ÷åëîâåêà èç áàíäû/ñåìüè ($ .óãá )")
				imgui.Text(u8"/igf - êàê ïðèãëàñèòü èãðîêîâ â áàíäó/ñåìüþ ($ .ïãá )")
				imgui.Text(u8"/lgf - ïîêèíóòü ìàôèþ ($ .ïëì ) \n/pgf - âûéòè èç áàíäû/ñåìüè ($ .ïãô )")
				imgui.Text(u8"/vgf - âûãîâîð ó÷àñòíèêó áàíäû ($ .âóá ) ")
				imgui.EndPopup()
			end	
			if imgui.BeginPopup(u8'helptp') then 
				imgui.Text(u8"/avt - /tp àâòîñàëîí ($ .òàñ ) | ")
				imgui.Text(u8"/avt1 - /tp àâòîìàñòåðñêàÿ ($ .òàì ) | /bk - tp in bank ($ .áê ) ")
				imgui.Text(u8"/ktp - êàê òåëåïîðòèðîâàòüñÿ ($ .êòï ) \n/og - îãðàá.áàíêà ($ .îã )")
				imgui.EndPopup()
			end	
			if imgui.BeginPopup(u8'helpsell') then 
				imgui.Text(u8"/gak - êàê ïðîäàòü àêñåññóàðû ($ .êïà )")
				imgui.Text(u8"/tcm - îáìåí î÷êîâ/êîèíîâ/ðóáëåé ($ .îáì )")
				imgui.Text(u8"/smc - ïðîäàæà ìàøèíû ($ .ïì ) | /smh - ïðîäàæà äîìà ($ .ïä )")
				imgui.EndPopup()
			end	
			if imgui.BeginPopup(u8'helpgive') then 
				imgui.Text(u8"/gvm - ïåðåäà÷à äåíåã ($ .ãâì ) | /gvs - ïåðåäà÷à î÷êîâ ($ .ãâñ )")
				imgui.Text(u8"/gvr - ïåðåäà÷à ðóáëåé ($ .ãâð) | /gvc - ïåðåäà÷à êîèíîâ ($ .ãâê)")
				imgui.EndPopup()
			end	
			if imgui.BeginPopup(u8'otherqu') then 
				imgui.Text(u8"/html - öâåòà ($ .öâåò ) | /cr - /car ($ .êàð ) ")
				imgui.Text(u8"/gn - êàê âçÿòü îðóæèå ($ .ãàí ) \n/pd - êàê âçÿòü ïðåäìåòû ($ .ïåä )")
				imgui.Text(u8"/dtl - êàê èñêàòü äåòàëè ($ .èñê ) \n/krb - êàçèê, ðàáîòû, è áèçíåñ ($ .êðá )  ")
				imgui.Text(u8"/kmd - êàçèê, ìï, îáìåí íà trade, äîñòèæåíèÿ ($ .êìä )")
				imgui.Text(u8"/gvk - (no id)")
				imgui.Text(u8"/cpt - íà÷àòü êàïò ($ .êïò ) | /psv - ïàññèâíûé ðåæèì ($ .ïñâ )")
				imgui.Text(u8"/stp - /statpl (ïîêàç êîèíîâ, âèðòîâ) ($ .ñòï )")
				imgui.Text(u8"/msp - êàê ñïàâíèòü ìàøèíó ($ .ìñï ) \n/chap - ñìåíà ïàðîëÿ ($ .ñïð )")
				imgui.Text(u8"/hin - êàê äîáàâèòü ÷åëîâåêà â äîì ($ .ä÷ä )")
				imgui.Text(u8"/ctun - êàê ïðîòþíèòü ìàøèíó ($ .òþí )\n /zsk - çàñòðÿë ÷åëîâåê ($ .ç÷ )")
				imgui.Text(u8"/tdd - âèðòóàëüíûé ìèð ($ .äòò )")
				imgui.EndPopup()
			end	
			if imgui.BeginPopup(u8'skins') then 
				imgui.Text(u8"/cops - êîïû ($ .êîïû ) \n/bal - áàëëàñû ($ .áàë ) | /cro - ãðóâ ($ .ãðóâ ) ")
				imgui.Text(u8"/vg - âàãîñû ($ .âàã ) \n/rumf - ru.ìàôèÿ ($ .ðóìô ) | /var - âàðèîñû ($ .âàð )")
				imgui.Text(u8"/triad - òðèàäà ($ .òðèàä ) \n/mf - ìàôèÿ ($ .ìô )")
				imgui.EndPopup()
			end	
			if imgui.BeginPopup(u8'hotkeys') then 
				imgui.Text(u8"Êíîïêà HOME - æåëàåò â ÷àò ïðèÿòíîé èãðû")
				imgui.Text(u8"Íèæå âñå êëàâèøè ìîæíî ñìåíèòü! // Â íàñòðîéêàõ.")
				imgui.Text(u8"Numpad {.} - âûâîä ïðèÿòíîé èãðû ñ öâåòîì \nNumpad {/} - âûâîä óäà÷íîãî.. ")
				imgui.Text(u8"..âðåìÿïðåïðîâîæäåíèÿ ñ öâåòîì ")
				imgui.Text(u8"Numpad {-} - âûâîä ïðèÿòíîãî âðåìÿïðåïðîâîæäåíèÿ.. \níà ñåðâåðå ñ öâåòîì.")
				imgui.Text(u8"ßðêèé ïðèìåð èñïîëüçîâàíèÿ... \nÏðè ðó÷íîì ââîäå îòâåòà â äèàëîãîâîì îêíå /ans, ")
				imgui.Text(u8"âû òûêàåòå Numpad {.} è ó âàñ âûâåäåòñÿ:\nÏðèÿòíîé èãðû íà RDS ñ öâåòîì.")
				imgui.EndPopup()
			end	
			if imgui.BeginPopup(u8'Æàëîáû íà êîãî/÷òî-òî') then 
				imgui.Text(u8"/c - íà÷àë(à) ðàáîòàòü ïî æàëîáå ($ .í÷ ) | /hg - ïîìîãëè âàì ")
				imgui.Text(u8" .ñë - ñëåæó çà èãðîêîì (èñêëþ÷èòåëüíî $)  \n/tm - îæèäàéòå ($ .îæ )")
				imgui.Text(u8"/zba - æàëîáà íà àäìèíèñòðàòîðà ($ .æáà ) \n/zbp - æàëîáà íà èãðîêà ($ .æáè )")
				imgui.Text(u8"/vrm - ïðèÿòíîãî âðåìÿïðåïðîâîæäåíèÿ (no ID) \n/cl - èãðîê ÷èñò ")
				imgui.Text(u8"-ïð - ïðèÿòíîé èãðû (no ID) | /dis - èãðîê íå â ñåòè ($ .íâ )")
				imgui.Text(u8"/yt - óòî÷íèòå âàø âîïðîñ/çàïðîñ ($ .óò) \n/n - íåò íàðóøåíèé ó èãðîêà ($ .íí )")
				imgui.Text(u8"/rid - óòî÷íåíèå ID ($.óèä ) | /nac - èãðîê íàêàçàí ($ .íàê )")
				imgui.Text(u8"/msid - îøèáêà â ID | /pg - ïðîâåðèì ($ .ïð ) \n/gm - ãì íå ðîáèò ($ .ãì )")
				imgui.Text(u8"/enk - íèêàê ($ .íê ) | /nz - íå çàïðåùåíî ($ .íç ) \n/en - íå çíàåì ($ .íåç )")
				imgui.Text(u8"/yes - äà ($ .æäà ) | /net - íåò ($ .æíå ) \n/of - íå îôôòîïèòü ($ .îôô ) | /nv - íå âûäàåì ($ .íâä")
				imgui.Text(u8"/vbg - ñêîðåé âñåãî - áàã ($ .áàã ) | /plg - ïåðåçàéäèòå ($ .ðëã )")
				imgui.Text(u8"/trp - æàëîáó â /report")
				imgui.EndPopup()
			end	
		end	
		if menuSelect == 4 then 
			showFlood()
		end	
		if menuSelect == 5 then 
			plugin.ActiveMenu()
		end	
		if menuSelect == 6 then 
			plugin2.ActiveMP()
		end	
		if menuSelect == 7 then 
			imgui.Text(u8"×òîáû âûäàòü íàêàçàíèÿ, ââåäèòå êîìàíäó è ID íàðóøèòåëÿ")
			imgui.Text(u8"Ïðèìåð, áàí çà ÷èòû - /ch id")
			imgui.Text("")
			imgui.Separator()
			if imgui.CollapsingHeader(u8"Íàêàçàíèå â îíëàéíå") then 
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
				if imgui.CollapsingHeader(u8"Ban", imgui.ImVec2(50,0)) then  
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/ch - áàí çà ÷èòû")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/pl - áàí çà ïëàãèàò íèêà àäìèíà ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/nk - áàí çà íèê ñ îñêîì/óíèæåíèåì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/gcnk - áàí çà íàçâàíèå áàíäû ñ îñêîì/óíèæåíèåì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/brekl - áàí çà ðåêëàìå | for 18 lvl ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/hl - áàí çà îñê â õåëïåðå")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/ob - áàí çà îáõîä áàíà")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/menk  - áàí çà çàïðåò.ñëîâà â íèêå")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/bnm - áàí çà íåàäåêâàòà")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/bosk - áàí çà îñê ïðîåêòà | for 18 lvl ")
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
				if imgui.CollapsingHeader(u8"Jail", imgui.ImVec2(50,0)) then  
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/sk - jail çà SK in zz")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/dz - jail çà DM/DB in zz")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/dz1 - /dz3 - jail DM/DB in zz (x2-x4)")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/td - jail çà DB/car in /trade")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/tdbz - jail çà DB ñ Êîâøîì â ÇÇ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/fsh - /jail çà SH and FC")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/jm - jail çà íàðóøåíèå ïðàâèë ìåðîïðèÿòèÿ.")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/bag - jail çà áàãîþç")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/pk - jail çà ïàðêóð ìîä")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/zv - jail çà çëîóï.âèï")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/skw - jail çà SK íà /gw")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/ngw - jail çà èñïîëüçîâàíèå çàïðåò.êîìàíä íà /gw")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/dbgw - jail çà DB âåðò íà /gw | /jch - jail çà ÷èòû")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/pmx - jail çà ñåðüåçíàÿ ïîìåõà èãðîêàì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/dgw - jail çà íàðêîòèêè íà /gw")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/sch - jail çà çàïðåùåííûå ñêðèïòû")
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
				if imgui.CollapsingHeader(u8"Kick", imgui.ImVec2(50,0)) then  
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/dj - êèê çà dm in jail")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/gnk1 -- /gnk3 - êèê çà íåöåíçóðó â íèêå.")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/cafk - êèê çà àôê íà àðåíå")
				end  
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
				if imgui.CollapsingHeader(u8"Mute", imgui.ImVec2(50,0)) then  
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/m - ìóò çà ìàò | /rm - ìóò çà ìàò â ðåïîðò ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/ok - ìóò çà îñê ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/fd1 - /fd10 - ìóò çà ôëóä/ñïàì x1-x10")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/po1 - /po10 - ìóò çà ïîïðîøàéêó x1-x10")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/oa - ìóò çà îñê àäì ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/roa - ìóò çà îñê àäì â ðåïîðò")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/up - ìóò çà óïîì.ïðîåêò")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/rup - ìóò çà ó.ï â ðåïîðò")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/ia - ìóò çà âûäà÷ó ñåáÿ çà àäì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/kl - ìóò çà êëåâåòó íà àäì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/nm(900), /nm1(2500), /nm2(5000) - ìóò çà íåàäåêâàò. ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/rnm(900), /rnm1(2500), /rnm2(5000) - ìóò çà íåàäåêâàò â ðåï.")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/or - ìóò çà îñê ðîä")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/rz - ðîçæèã ìåæíàö.ðîçíè")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/zs - çëîóïîòðåáëåíèå ñèìâîëàìè")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/ror - ìóò çà îñê ðîä â ðåïîðò")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/cp - /cp10 - êàïñ/îôôòîï â ðåïîðò x1-x10")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"ÏÐÈÌÅ×ÀÍÈÅ Ê /cp (x1)! Ñóììèðîâàíèå ñ /cp2(x2)")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/rpo - /rpo10 - ïîïðîøàéêà â ðåïîðò x1-x10")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"ÏÐÈÌÅ×ÀÍÈÅ Ê /rpo (x1)! Ñóììèðîâàíèå ñ /rpo2(x2)")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/rkl - êëåâåòà íà àäì â ðåïîðò")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/rrz - ðîçæèã ìåæíàö.ðîçíè â ðåïîðò")
					
				end
			end 
			imgui.Text("")
			imgui.Separator()
			imgui.Text("")
			if imgui.CollapsingHeader(u8"Íàêàçàíèå â îôôëàéíå") then 
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
				if imgui.CollapsingHeader(u8"Ban") then  
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/apl - áàí çà ïëàãèàò íèê àäìèíà")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/ach (/achi) - áàí çà ÷èòû (ip)")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/ank - áàí çà íèê ñ îñê/óíèæ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/agcnk - áàí çà íàçâàíèå áàíäû ñ îñê/óíèæ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/agcnkip - áàí ïî IP çà íàçâàíèå áàíäû ñ îñê/óíèæ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/okpr/ip - îñê ïðîåêòà")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/svoakk/ip - áàí ïî àêê/IP ïî ðåêëàìå")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/ahl (/achi) - áàí çà îñê â õåëïåðå (ip)")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/aob - áàí çà îáõîä áàíà")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/rdsob - áàí çà îáìàí àäì/èãðîêîâ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/rdsip - áàí ïî IP çà îáìàí àäì/èãðîêîâ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/amenk - áàí çà çàïðåò.ñëîâà â íèêå")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/abnm - áàí çà íåàäåêâàòà")
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
				if imgui.CollapsingHeader(u8"Jail") then  
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/ask - jail çà SK in zz")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/adz - jail çà DM/DB in zz")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/adz1 - /adz3 - jail DM/DB in zz (x2-x4)")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/atd - jail çà DB/CAR in trade")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/afsh - jail çà SH ans FC")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/ajm - jail çà íàðóø.ïðàâèë ÌÏ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/abag - jail çà áàãîþç")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/apk - jail çà ïàðêóð ìîä")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/azv - jail çà çëîóï.âèï")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/askw - jail çà SK íà /gw")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/angw - èñï.çàïðåò.êîìàíä íà /gw")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/adbgw - jail çà DB âåðò íà /gw")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/ajch - jail çà ÷èòû")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/apmx - jail çà ñåðüåç.ïîìåõó")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/adgw - jail çà íàðêîòèêè íà /gw")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 425))
					imgui.Text(u8"/asch - jail çà çàïðåùåííûå ñêðèïòû")
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
				if imgui.CollapsingHeader(u8"Mute") then  
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/am - ìóò çà ìàò ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/aok - ìóò çà îñê ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/afd - ìóò çà ôëóä/ñïàì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/apo  - ìóò çà ïîïðîøàéêó")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/aoa - ìóò çà îñê.àäì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/aup - ìóò çà óïîìèíàíèå ïðîåêòîâ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/anm(900) /anm1(2500) /anm2(5000) - ìóò çà íåàäåêâàòà")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/aor - ìóò çà îñê/óïîì ðîäíûõ")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/aia - ìóò çà âûäà÷ó ñåáÿ çà àäì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/akl - ìóò çà êëåâåòó íà àäì")
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 450))
					imgui.Text(u8"/arz - ìóò çà ðîçæèã ìåæíàö.ðîçíè")
				end
			end 
		end	
		if menuSelect == 8 then 
			plre.ActiveATChat()
			imgui.SameLine()
			imgui.BeginChild('##Prefixs', imgui.ImVec2(260, 250), true)
			imgui.Text(u8"Ñîõðàíåíèå öâåòîâ äëÿ ïðåôèêñîâ") 
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'/prf1 - /prf8  âûäà÷à ïðåôèêñîâ \n 1 - Õåëïåð, 2 - Ìîäåðàòîð, 3 - Ìë.àäìèí, 4 - Àäìèí, 5 - Ñò.àäìèí, 6 - ÏÃÀ, 7 - ÇÃÀ, 8 - ÃÀ\n Ïðè ââîäå ïðåôèêñà â îêîøêè íèæå, îíè àâòîìàòè÷åñêè çàíîñÿòñÿ â êîíôèã')	
			if imgui.InputText(u8"Õåëïåð", elm.input.prefix_Helper) then 
				ATcfg.setting.prefix_Helper = elm.input.prefix_Helper.v 
				save() 
			end	 
			if imgui.InputText(u8"Ìîäåðàòîð", elm.input.prefix_Moderator) then 
				ATcfg.setting.prefix_Moderator = elm.input.prefix_Moderator.v 
				save() 
			end	 
			if imgui.InputText(u8"Ìë.Àäìèí", elm.input.prefix_Madm) then 
				ATcfg.setting.prefix_Madm = elm.input.prefix_Madm.v 
				save() 
			end	 
			if imgui.InputText(u8"Àäìèí", elm.input.prefix_adm) then 
				ATcfg.setting.prefix_adm = elm.input.prefix_adm.v 
				save() 
			end	 
			if imgui.InputText(u8"Ñò.Àäìèí", elm.input.prefix_STadm) then 
				ATcfg.setting.prefix_STadm = elm.input.prefix_STadm.v 
				save() 
			end	 
			if imgui.InputText(u8"ÏÃÀ", elm.input.prefix_PGAadm) then 
				ATcfg.setting.prefix_PGAadm = elm.input.prefix_PGAadm.v 
				save() 
			end	 
			if imgui.InputText(u8"ÇÃÀ", elm.input.prefix_ZGAadm) then 
				ATcfg.setting.prefix_ZGAadm = elm.input.prefix_ZGAadm.v 
				save() 
			end	 
			if imgui.InputText(u8"ÃÀ", elm.input.prefix_GAadm) then 
				ATcfg.setting.prefix_GAadm = elm.input.prefix_GAadm.v 
				save() 
			end	 
			imgui.EndChild()
		end	
		if menuSelect == 9 then 
			plugin.Notepad()
		end	
		if menuSelect == 10 then 
			imgui.PushItemWidth(130) imgui.Combo("##imguiStyle", elm.int.styleImgui, colorsImGui) imgui.PopItemWidth() imgui.SameLine() imgui.Text(u8" - Âûáîð òåìû ") 
			imgui.Separator()
			if imgui.Button(fa.ICON_FA_UPLOAD .. u8" Îáíîâèòü") then  
				menuSelect = 11 
			end	
			imgui.Separator()
			imgui.Text(fa.ICON_TAG .. u8" Ââîä ïðèâåòñòâèÿ àäìèíîâ (/ahi)")
			if imgui.InputText(u8"Text for HelloAdm", elm.input.ATHelloAdm) then 
				ATcfg.setting.ATHelloAdm = elm.input.ATHelloAdm.v 
				save()  
			end	
			imgui.Separator()
			plugin.changefont()
			imgui.Separator()
			imgui.Text(fa.ICON_TICKET .. u8" Ââîä öâåòà äëÿ îòâåòà â ðåïîðò. (îêíî)")
			imgui.Text(u8"Ïèøèòå {} è áåðåòå öâåò â HTML. Åãî ìîæíî âçÿòü ñ ñàéòà")
			imgui.Link("https://colorscheme.ru/html-colors.html")
			imgui.Text(u8"Ê ïðèìåðó, áåðåì SlateBlue è ïîëó÷àåòñÿ - {6A5ACD}")
			if imgui.InputText(u8"Color for report", elm.input.ATColor) then 
				ATcfg.setting.ATColor = elm.input.ATColor.v 
				save() 
			end
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Ñîáñòâåííûé öâåò ïðè îòâåòå íà ðåïîðò. Êîìàíäà - .ñö')	
			imgui.Separator()
			imgui.Text("")
			imgui.CenterText(u8"Íàñòðîéêè ìîæíî ïîñìîòðåòü â config/AdminTool")
			if imgui.CollapsingHeader(u8'Äîïîëíèòåëüíûå êîìàíäû') then 
				imgui.Text(u8"/tpcord x y z - òï êî êîðäàì, /delch - âèðò.î÷èñòêà ÷àòà")
				imgui.Text(u8"/tpad - òï íà îñòðîâ, /ahi - ïðèâåòñòâèå àäì")
				imgui.Text(u8"/u id - ðàçìóò ÷àòà, /uu id - ðàçìóò ÷àòà ñ èçâèíåíèÿìè, /uj id - ðàçäæàéë")
				imgui.Text(u8"/stw id - âûäà÷à ìèíèãàíà, /ru id - ðàçìóò ðåïîðòà, /as id - ñïàâí èãðîêà")
				imgui.Text(u8"/prf1 - /prf8 - âûäà÷à ïðåôèêñîâ")
				imgui.Text(u8"1 - Õåëïåð, 2 - Ìîäåðàòîð, 3 - Ìë.àäìèí, 4 - Àäìèí, 5 - Ñò.àäìèí, 6 - ÏÃÀ, \n7 - ÇÃÀ, 8 - ÃÀ")
			end	
			if imgui.Button(u8"Ïàíåëü âûñøåé àäìèíèñòðàöèè") then  
				menuSelect = 14 
			end	
		end	
		if menuSelect == 11 then  
			imgui.Text(u8" Íèæå ìîæíî îáíîâèòü AdminTool, âêëþ÷àÿ åãî ïëàãèíû è îñíîâíîé ñêðèïò.")
			imgui.Text(u8" version: " .. script_version_text  .. " | number GitHub: " .. script_version)
			imgui.Text(" ")
			imgui.Separator()
			if imgui.Button(u8"Îáíîâëåíèå îñíîâíîãî ñêðèïòà") then  
				lua_thread.create(function()
					showNotification(tag .. " - Update","Íà÷èíàþ çàãðóçêó îñíîâíîãî ñêðèïòà!")
					wait(500)
					downloadUrlToFile(script_url, script_path, function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. " Îñíîâíîé ñêðèïò çàêà÷åí è îáíîâëåí. ")
							sampAddChatMessage(tag .. " Âûïîëíÿþ ïåðåçàãðóçêó ñêðèïòà")
							thisScript():reload()
						end
					end)
				end)	
			end	
			imgui.SameLine()
			if imgui.Button(u8"Îáíîâëåíèå ïëàãèíà çà ðåïîðòû") then  
				lua_thread.create(function()
					showNotification(tag .. " - Update","Íà÷èíàþ çàãðóçêó ïëàãèíà çà ðåïîðòû!")
					wait(500)
					downloadUrlToFile(report_url, report_path, function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Ïëàãèí "ATReport" çàêà÷åí è îáíîâëåí. ')
							sampAddChatMessage(tag .. " Âûïîëíÿþ ïåðåçàãðóçêó ñêðèïòîâ")
							reloadScripts()
						end
					end)
				end)
			end	
			if imgui.Button(u8"Îáíîâëåíèå ïëàãèíà çà äîï.ôóíêöèé ¹1") then  
				lua_thread.create(function()
					showNotification(tag .. " - Update",'Íà÷èíàþ çàãðóçêó ïëàãèíà çà àâòîìóò')
					wait(500)
					downloadUrlToFile(mute_url, mute_path, function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Ïëàãèí "ATautomute" çàêà÷åí è îáíîâëåí. ')
							sampAddChatMessage(tag .. " Âûïîëíÿþ ïåðåçàãðóçêó ñêðèïòîâ")
							reloadScripts()
						end
					end)
				end)
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Ñîäåðæèò: ðàáîòó ñ ìåðîïðèÿòèÿìè, àâòîìóò - ìàò è îñê, àäìèí-ñòàòà")
			if imgui.Button(u8"Îáíîâëåíèå ïëàãèíà âñïîìîãàòåëüíûõ ôóíêöèé ¹2") then  
				lua_thread.create(function()
					showNotification(tag .. " - Update","Íà÷èíàþ çàãðóçêó ïëàãèíà \nâñïîìîãàòåëüíûõ ôóíêöèé!")
					wait(500)
					downloadUrlToFile(pl1_url, pl1_path, function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Ïëàãèí "ATother" çàêà÷åí è îáíîâëåí. ')
							sampAddChatMessage(tag .. " Âûïîëíÿþ ïåðåçàãðóçêó ñêðèïòîâ")
							reloadScripts()
						end
					end)
				end)
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Ñîäåðæèò: òðåéñåð ïóëü, WallHack, Infinite Run, Áëîêíîò")
			if imgui.Button(u8"Îáíîâëåíèå ïëàãèíà äîïîëíèòåëüíûõ ôóíêöèé ¹3") then  
				lua_thread.create(function()
					showNotification(tag .. " - Update","Íà÷èíàþ çàãðóçêó ïëàãèíà äîï.ôóíêöèé!")
					wait(500)
					downloadUrlToFile(pl2_url, pl2_path, function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Ïëàãèí "ATplugin" çàêà÷åí è îáíîâëåí. ')
							sampAddChatMessage(tag .. " Âûïîëíÿþ ïåðåçàãðóçêó ñêðèïòîâ")
							reloadScripts()
						end
					end)
				end)
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Ñîäåðæèò: àäìèíèñòðàòèâíûé ÷àò")
			if imgui.Button(u8"Îáíîâëåíèå áèáëèîòåêè TAB-Scoreboard") then  
				lua_thread.create(function()
					showNotification(tag .. " - Update","Íà÷èíàþ çàãðóçêó \náèáëèîòåêó TAB-Scoreboard")
					wait(500)
					downloadUrlToFile(scoreboard_url, scoreboard_path, function(id, status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Áèáëèîòåêà "TAB-Scoreboard" çàêà÷åíà è îáíîâëåíà. ')
							sampAddChatMessage(tag .. " Âûïîëíÿþ ïåðåçàãðóçêó ñêðèïòîâ")
							reloadScripts()
						end
					end)
				end)
			end	
			if imgui.Button(u8"Îáíîâëåíèå âñåãî ïàêåòà AT") then  
				lua_thread.create(function()
					downloadUrlToFile(report_url, report_path, function(id,status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Ïëàãèí "ATReport" çàêà÷åí')
						end	
					end)	
					wait(500)
					downloadUrlToFile(mute_url, mute_path, function(id,status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Ïëàãèí "ATautomute" çàêà÷åí ')
						end	
					end)	
					wait(500)
					downloadUrlToFile(pl1_url, pl1_path, function(id,status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Ïëàãèí "ATother" çàêà÷åí ')
						end	
					end)	
					wait(500)
					downloadUrlToFile(pl2_url, pl2_path, function(id,status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. ' Ïëàãèí "ATplugin" çàêà÷åí ')
						end	
					end)	
					wait(500)
					downloadUrlToFile(script_url, script_path, function(id,status)
						if status == dlstatus.STATUS_ENDDOWNLOADDATA then  
							sampAddChatMessage(tag .. "Îñíîâíîé ñêðèïò ãîòîâ!")
						end	
					end)	
					sampAddChatMessage(tag .. "Îáíîâëåí âåñü îñíîâíîé ïàêåò AdminTool! Âûïîëíÿþ ïåðåçàãðóçêó!")
					reloadScripts()
				end)	
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Ñîäåðæèò: âñå ñêðèïòû ïàêåòà AT, êðîìå øðèôòîâ è áèáëèîòåê")
		end	
		if menuSelect == 12 then  
			plugin2.AdminState()
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Âûâîäèò îêîøêî âàøåé àäìèèíñòðàòèâíîé ñòàòèñòèêè :3\nÏðî÷èå íàñòðîéêè àäìèíèñòðàòèâíîé ñòàòèñòèêè íèæå')	
			imgui.Separator()
			plugin2.AdminStateCheckbox()
		end	
		if menuSelect == 13 then  
			rep_pl.ActiveBinder()
		end	
		if menuSelect == 14 then  
			if imgui.Button(u8"Âûäà÷à ïîâûøåíèé/ñíÿòèé") then  
				imgui.OpenPopup(u8'OpenMakeAdmin')
			end	
			if imgui.BeginPopupModal(u8'OpenMakeAdmin', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then  
				imgui.BeginChild("##MakeAdmin", imgui.ImVec2(600, 225), true)
				imgui.Text(u8"Ïðè ñîçäàíèè áèíäà âûäà÷è ïî MakeAdmin, ó÷òèòå, ÷òî ïèøèòñÿ âñå â ñòîëáèê. \nÍåîáõîäèì íèê è óðîâåíü.")
				imgui.Text(u8"Ïðèìåð:")
				imgui.Text(u8"alfantasyz 18\nalfantasyz 0")
				imgui.Separator()
				if #textcfg.makeadmin_name > 0 then  
					for key_bind, name_bind in pairs(textcfg.makeadmin_name) do  
						if imgui.Button(name_bind.. '##'..key_bind) then  
							play_makeadmin(key_bind)
						end	
						imgui.SameLine()
						if imgui.Button(u8'Ðåäàêòèðîâàòü##'..key_bind, imgui.ImVec2(100, 22)) then
							EditOldBind = true
							getpos = key_bind
							local returnwrapped = tostring(textcfg.makeadmin_text[key_bind]):gsub('~', '\n')
							elm.input.adm_text.v = returnwrapped
							elm.input.adm_name.v = tostring(textcfg.makeadmin_name[key_bind])
							imgui.OpenPopup(u8'EditMakeAdmin')
						end
						imgui.SameLine()
						if imgui.Button(u8'Óäàëèòü##'..key_bind, imgui.ImVec2(60, 22)) then
							sampAddChatMessage(tag .. 'MakeAdmin "' ..u8:decode(textcfg.makeadmin_name[key_bind])..'" óäàëåí!', -1)
							table.remove(textcfg.makeadmin_name, key_bind)
							table.remove(textcfg.makeadmin_text, key_bind)
							TextSave()
						end
					end	
				else 
					imgui.Text(u8"Ïóñòî!")
				end	
				if imgui.Button(u8"Ñîçäàòü!") then  
					imgui.OpenPopup(u8'EditMakeAdmin')	 
				end	
				if imgui.BeginPopupModal(u8'EditMakeAdmin', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
					imgui.BeginChild("##EdMakeAdmin", imgui.ImVec2(600, 225), true)
					imgui.Text(u8'Íàçâàíèå MakeAdmin:'); imgui.SameLine()
					imgui.PushItemWidth(130)
					imgui.InputText("##name_adm", elm.input.adm_name)
					imgui.PopItemWidth()
					imgui.PushItemWidth(100)
					imgui.Separator()
					imgui.Text(u8'Òåêñò MakeAdmin:')
					imgui.PushItemWidth(300)
					imgui.InputTextMultiline("##text_adm", elm.input.adm_text, imgui.ImVec2(-1, 110))
					imgui.PopItemWidth()
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
					if imgui.Button(u8'Çàêðûòü##bind1', imgui.ImVec2(100,30)) then
						elm.input.adm_name.v, elm.input.adm_text.v = '', ''
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if #elm.input.adm_name.v > 0 and #elm.input.adm_text.v > 0 then
						imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
						if imgui.Button(u8'Ñîõðàíèòü##bind1', imgui.ImVec2(100,30)) then
							if not EditOld then
								local refresh_text = elm.input.adm_text.v:gsub("\n", "~")
								table.insert(textcfg.makeadmin_name, elm.input.adm_name.v)
								table.insert(textcfg.makeadmin_text, refresh_text)
								if TextSave() then
									sampAddChatMessage(tag .. 'MakeAdmin"' ..u8:decode(elm.input.adm_name.v).. '" óñïåøíî ñîçäàí!', -1)
									elm.input.adm_name.v, elm.input.adm_text.v = '', ''
								end
									imgui.CloseCurrentPopup()
								else
									local refresh_text = elm.input.adm_text.v:gsub("\n", "~")
									table.insert(textcfg.makeadmin_name, getpos, elm.input.adm_name.v)
									table.insert(textcfg.makeadmin_text, getpos, refresh_text)
									table.remove(textcfg.makeadmin_name, getpos + 1)
									table.remove(textcfg.makeadmin_text, getpos + 1)
								if TextSave() then
									sampAddChatMessage(tag .. 'MakeAdmin"' ..u8:decode(elm.input.adm_name.v).. '" óñïåøíî îòðåäàêòèðîâàí!', -1)
									elm.input.adm_name.v, elm.input.adm_text.v = '', ''
								end
								EditOld = false
								imgui.CloseCurrentPopup()
							end
						end
					end
					imgui.EndChild()
					imgui.EndPopup()
				end	
				imgui.EndChild()
				if imgui.Button(u8"Close") then  
					imgui.CloseCurrentPopup()
				end	
				imgui.EndPopup()
			end	
		end	
		imgui.EndChild()
		imgui.End()
	end

			if ATChatLogger.v then

				imgui.LockPlayer = true
				imgui.ShowCursor = true

				imgui.SetNextWindowSize(imgui.ImVec2(600, 350), imgui.Cond.FirstUseEver)
				imgui.SetNextWindowPos(imgui.ImVec2((sw1 / 4.5), sh1 / 4), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
				imgui.Begin(u8"×àò-ëîããåð", ATChatLogger)
				if elm.checkbox.chat_logger.v then
					if accept_load_clog then
						imgui.InputText(u8"Ïîèñê ñòðîêè", chat_find)
						if chat_find.v == "" then
							imgui.Text(u8'Ïðåäëîæåíèå/Ñëîâî íå áûëî ââåäåíî. Ââåäèòå ïîæàëóéñòà.\n')
							for key,v in pairs(text_ru) do 
								imgui.Text(v)
							end   
						else
							for key,v in pairs(text_ru) do 
								if v:find(chat_find.v) ~= nil then
									imgui.Text(v)
								end
							end   
						end
					else
						imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
						imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
						imgui.Spinner(20, 7)
					end
				else 
					imgui.CenterText(u8"Ïîäíàñòðîéêà ÷àò-ëîããåðà íå áûëà âêëþ÷åíà.")
					imgui.CenterText(u8"Q: Êàê åãî âêëþ÷èòü?")
					imgui.CenterText(u8"A: Âñå ïðîñòî! Çàõîäè â /tool. Ïîòîì æìÿêàé íà < Îñíîâíûå ôóíêöèè AT >")
					imgui.CenterText(u8"A: Æìÿêíóë? Íàæèìàé íà ïåðåêëþ÷àòåëü < ×àò-ëîããåð > è ïðîáóé åù¸ ðàç")
				end
				imgui.End()
			end

			if ATre_menu.v and control_recon and recon_to_player and elm.checkbox.atrecon.v then -- ðåêîí

				imgui.LockPlayer = false
		
				imgui.SetNextWindowPos(imgui.ImVec2(sw/2, sh/1.06), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 1))
				imgui.SetNextWindowSize(imgui.ImVec2(600, 60), imgui.Cond.FirstUseEver)
				imgui.Begin(u8"Íàêàçàíèÿ èãðîêà", false, 2+4+32 + imgui.WindowFlags.NoTitleBar)
					if imgui.Button(fa.ICON_ARROW_LEFT .. u8" BackID") then  
						sampSendChat("/re " .. control_recon_playerid-1)
					end
					imgui.SameLine()
					if imgui.Button(u8"Çàñïàâíèòü") then
						sampSendChat("/aspawn " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"Îáíîâèòü") then
						sampSendClickTextdraw(132)
						if elm.checkbox.keysync.v then 
							lua_thread.create(function()
								wait(1)
								sampSetChatInputEnabled(true)
								sampSetChatInputText("/keysync " .. control_recon_playerid)
								setVirtualKeyDown(VK_RETURN)
							end)
						elseif elm.checkbox.keysync.v == false then  
							lua_thread.create(function()
								wait(1)
								sampSetChatInputEnabled(true)
								sampSetChatInputText("/keysync off")
								setVirtualKeyDown(VK_RETURN)
							end)
						end	
					end
					imgui.SameLine()
					if imgui.Button(u8"Ñëàïíóòü") then  
						sampSendChat("/slap " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"Óáèòü") then  
						lua_thread.create(function()
							sampSendClickPlayer(control_recon_playerid, 0)
							wait(200)
							sampSendDialogResponse(500, 1, 7)
							wait(200)
							sampSendDialogResponse(48, 1, _, "kill")
							wait(200)
							sampCloseCurrentDialogWithButton(0)
						end)	
					end	
					imgui.SameLine()
					if imgui.Button(u8"Çàìîðîçèòü/Ðàçìîðîçèòü") then  
						sampSendChat("/freeze " .. control_recon_playerid)
					end
					imgui.SameLine()
					if imgui.Button(u8"Âûéòè") then
						sampSendChat("/reoff")
						if elm.checkbox.keysync.v then
							lua_thread.create(function()
								wait(1)
								sampSetChatInputEnabled(true)
								sampSetChatInputText("/keysync off")
								setVirtualKeyDown(VK_RETURN)
							end)
						elseif elm.checkbox.keysync.v == false then  
							lua_thread.create(function()
								wait(1)
								sampSetChatInputEnabled(true)
								sampSetChatInputText("/keysync off")
								setVirtualKeyDown(VK_RETURN)
							end)
						end	
						control_recon_playerid = -1
					end
					imgui.SameLine()
					if imgui.Button(u8"NextID" .. fa.ICON_ARROW_RIGHT) then  
						sampSendChat("/re " .. control_recon_playerid+1)
					end
					imgui.Separator()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.43-80)
					if imgui.Button(u8"Ïîñàäèòü") then
						selectRecon = 2
						tool_re = 1
					end
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.41)
					if imgui.Button(u8"Çàáàíèòü") then
						selectRecon = 2
						tool_re = 2
					end
					imgui.SameLine()
					imgui.SetCursorPosX(imgui.GetWindowWidth()/2.43+80)
					if imgui.Button(u8"Êèêíóòü") then
						selectRecon = 2
						tool_re = 3
					end
				imgui.End()
				

				--imgui.SetNextWindowSize(imgui.ImVec2(270, sh/2), imgui.Cond.FirstUseEver) -- 
				if right_re_menu.v then -- ðåêîí
					local recon_cfg = inicfg.load({
						settings = {
							reX = 0,
							reY = 0,
						},
					},"AdminTool\\cfgmute.ini")

					imgui.SetNextWindowSize(imgui.ImVec2(255, sh/2.15), imgui.Cond.FirstUseEver)
					imgui.SetNextWindowPos(imgui.ImVec2(recon_cfg.settings.reX+125, recon_cfg.settings.reY), imgui.Cond.FirstUseEver, imgui.ImVec2(1, 0.5)) 
					
					imgui.Begin(u8"##ReconMenu", nil, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)  --  
					if accept_load then
					imgui.BeginChild('##SelectMenuRecon', imgui.ImVec2(50, sh/2.15), true)
					imgui.PushStyleVar(imgui.StyleVar.FrameRounding, 10) 
					imgui.PushStyleVar(imgui.StyleVar.ButtonTextAlign, imgui.ImVec2(0.5, 0.5))
					if imgui.Button(fa.ICON_ADDRESS_CARD, imgui.ImVec2(40,25)) then  
						selectRecon = 1
					end		
					if imgui.Button(fai.ICON_FA_USERS_COG, imgui.ImVec2(40,25)) then  
						selectRecon = 2 
					end
					-- if imgui.Button(u8"A") then  
					-- 	sampAddChatMessage(tag .. " X: " .. tostring(recon_cfg.settings.reX) .. " | Y: " ..  tostring(recon_cfg.settings.reY), -1)
					-- end	
					imgui.PopStyleVar(1) 
					imgui.PopStyleVar(1) 
					imgui.EndChild()
					imgui.SameLine()
					imgui.BeginChild('##ShowInformation', imgui.ImVec2(200,sh/2.15), true)
					if selectRecon == 1 then  
						if not sampIsPlayerConnected(control_recon_playerid) then
							control_recon_playernick = "-"
						else
							control_recon_playernick = sampGetPlayerNickname(control_recon_playerid)
						end
						if imgui.Button(fa.ICON_FLOPPY_O .. "##CopyNick") then  
							setClipboardText(control_recon_playernick)
						end	
						imgui.SameLine()
						imgui.Text(u8"Èãðîê: " .. control_recon_playernick .. "[" .. control_recon_playerid .. "]") 
						imgui.Separator()
						for key, v in pairs(player_info) do
							if key == 2 then
								imgui.Text(u8:encode(text_remenu[2]) .. " " .. player_info[2])
								imgui.BufferingBar(tonumber(player_info[2])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 3 and tonumber(player_info[3]) ~= 0 then
								imgui.Text(u8:encode(text_remenu[3]) .. " " .. player_info[3])
								imgui.BufferingBar(tonumber(player_info[3])/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 4 and tonumber(player_info[4]) ~= -1 then
								imgui.Text(u8:encode(text_remenu[4]) .. " " .. player_info[4])
								imgui.BufferingBar(tonumber(player_info[4])/1000, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key == 5 then
								imgui.Text(u8:encode(text_remenu[5]) .. " " .. player_info[5])
								local speed, const = string.match(player_info[5], "(%d+) / (%d+)")
								if tonumber(speed) > tonumber(const) then
									speed = const
								end
								imgui.BufferingBar((tonumber(speed)*100/tonumber(const))/100, imgui.ImVec2(imgui.GetWindowWidth()-10, 10), false)
							end
							if key ~= 2 and key ~= 3 and key ~= 4 and key ~= 5 then
								imgui.Text(u8:encode(text_remenu[key]) .. " " .. player_info[key])
							end
						end
						imgui.Separator()
						id_suspeckt = "" .. control_recon_playerid
						plugin.ActiveWHRe()
						plugin.ActiveBT()
						imgui.Separator()
						if imgui.Button(u8"Âçàèìîäåéñòâîâàòü \nÄîï.äåéñòâèÿ") then  
							imgui.OpenPopup('ihavereconplayer')
						end 	
						if imgui.BeginPopup('ihavereconplayer') then  
						if imgui.Button(u8"Ñòàòèñòèêà äàííîãî èãðîêà") then  
							sampSendChat("/statpl " .. control_recon_playerid)
						end	
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"/statpl\nÊëèêàáåëüíî")
						if imgui.Button(u8"Âòîðàÿ ñòàòèñòèêà èãðîêà") then  
							sampSendChat("/offstats " .. control_recon_playernick)
						end
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Ïîêàç Reg/Last IP, /offstats\nÊëèêàáåëüíî")
						if imgui.Button(u8"Îñíîâíàÿ ñòàòèñòèêà èãðîêà") then 
							lua_thread.create(function()
								sampSendClickPlayer(control_recon_playerid, 0)
								wait(200)
								sampSendDialogResponse(500, 1, 10)
							end)
						end	
						if imgui.Button(u8"IP-àäðåñ èãðîêà") then 
							sampSendChat("/getip " .. control_recon_playerid)
						end	
						imgui.SameLine()
						if imgui.Button(fa.ICON_FLOPPY_O .. "##CopyIP") then  
							lua_thread.create(function()
								wait(1)
								sampSendChat("/getip " .. control_recon_playerid)
								wait(100)
								setClipboardText(ip1)
							end)
						end	
						imgui.SameLine()
						imgui.TextQuestion('(?)', u8"Êíîïêà 'Ñîõðàíèòü' ïîçâîëèò ñêîïèðîâàòü IP")
						if imgui.Button(u8"Îðóæèÿ èãðîêà") then  
							sampSendChat("/iwep " .. control_recon_playerid)
						end 
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Ïîêàç ãàíîâ èãðîêà, /iwep\nÊëèêàáåëüíî")
						if imgui.Button(u8"Îòîáðàòü îðóæèå") then  
							sampSendChat("/tweap " .. control_recon_playerid)
						end  
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"/tweap\nÊëèêàáåëüíî")
						if imgui.Button(u8"ÒÏ ê ïîäîçðåâàåìîìó") then  
							lua_thread.create(function()
								sampSendChat("/reoff")
								wait(200)
								sampSendChat("/agt " .. id_suspeckt)
							end)
						end	
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Òåëåïîðò ê èãðîêó çà êîòîðûì âû â ðåêîíå\nÊëèêàáåëüíî")
						if imgui.Button(u8"ÒÏ ïîäîçðåâàåìîãî ê ñåáå") then  
							lua_thread.create(function()
								sampSendChat("/reoff")
								wait(2000)
								sampSendChat("/gethere " ..id_suspeckt)
							end)
						end
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Òåëåïîðò èãðîêà ê ñåáå çà êîòîðûì âû â ðåêîíå\nÊëèêàáåëüíî")
						if imgui.Button(u8"Èíôîðìàöèÿ îá IP") then 
							lua_thread.create(function()
								wait(1)
								sampSendChat("/getip " .. control_recon_playerid)
								wait(100)
								sampSetChatInputEnabled(true)
								sampSetChatInputText("/chip " .. ip1)
								setVirtualKeyDown(VK_RETURN)
							end)
						end 
						imgui.SameLine()
						imgui.TextQuestion("(?)", u8"Ïîêàæåò èíôîðìàöèþ, ãäå IP è èíôó î íåì")	
						if imgui.Button(u8"Êëèåíò") then
							lua_thread.create(function()
							sampSendChat('/tonline')
							wait(100)
							sampCloseCurrentDialogWithButton(1)
							wait(100)
							check_report = true
							end)
						end
						imgui.SameLine()
						imgui.TextQuestion('(?)', u8"Ïðîâåðÿåò ñ êàêîãî óñòðîéñòâà èãðàåò èãðîê")
							imgui.EndPopup()
						end	
						imgui.Separator()
						imgui.Text(u8"Èãðîêè ðÿäîì:")
						local playerid_to_stream = playersToStreamZone()
						for _, v in pairs(playerid_to_stream) do
							if imgui.Button(" - " .. sampGetPlayerNickname(v) .. "[" .. v .. "] - ", imgui.ImVec2(-0.1, 0)) then
								sampSendChat("/re " .. v)
							end
						end
						imgui.Separator()
						imgui.Text(u8"Äëÿ ïîÿâëåíèÿ êóðñîðà \níàæìèòå ÏÊÌ.")
						imgui.Text(u8"Êëàâèøà: R - îáíîâèòü ðåêîí. \nÊëàâèøà: Q - âûéòè èç ðåêîíà")
						imgui.Text(u8"NumPad4 - ïðåäûäóùèé èãðîê \nNumPad6 - ñëåäóþùèé èãðîê")
					end	
					if selectRecon == 2 then  
						if tool_re == 1 then 
							if imgui.Button("Cheat", btn_size) then
								sampSendChat("/jail " .. control_recon_playerid .. " 3000 Èñïîëüçîâàíèå ÷èòåðñêîãî ñêðèïòà/ÏÎ")
							end
							if imgui.Button(u8"Èñï.çàïðåùåííûõ ñêðèïòîâ", btn_size) then  
								sampSendChat("/jail " .. control_recon_playerid .. " 900 Èñïîëüçîâàíèå ClickWarp/Metla (È×Ñ)")
							end	
							if imgui.Button(u8"Çëîóïîòðåáëåíèå VIP", btn_size) then
								sampSendChat("/jail " .. control_recon_playerid .. " 3000 Çëîóïîòðåáëåíèå VIP")
							end
							if imgui.Button("Speed Hack/Fly", btn_size) then
								sampSendChat("/jail " .. control_recon_playerid .. " 900 SpeedHack/Fly/Flycar")
							end
							if imgui.Button(u8"Ïîìåõà MP", btn_size) then
								sampSendChat("/jail " .. control_recon_playerid .. " 300 Íàðóøåíèå ïðàâèë MP.")
							end
							if imgui.Button("Spawn Kill", btn_size) then
								sampSendChat("/jail " .. control_recon_playerid .. " 300 Spawn Kill")
							end
							if imgui.Button("DM in ZZ", btn_size) then  
								sampSendChat("/jail " .. control_recon_playerid .. " 300 DM/DB in ZZ")
							end
							if imgui.Button(u8"Ïîìåõà èãðîêàì", btn_size) then  
								sampSendChat("/jail " .. control_recon_playerid .. " 300 Ñåðüåçíàÿ ïîìåõà èãðîêàì")
							end
							if imgui.Button(u8"Car in /trade", btn_size) then  
								sampSendChat("/jail " .. control_recon_playerid .. " 300 DB/Car in /trade")
							end
							if imgui.Button(u8"Èãðîâîé áàãîþç \n(äèãë â ìàøèíå)", btn_size) then  
								sampSendChat("/jail " .. control_recon_playerid .. " 300 Èãðîâîé áàãîþç (deagle in car)")
							end
							if imgui.Button(u8"Èñïîëüçîâàíèå \nâåðòîëåòà íà /gw", btn_size) then  
								sampSendChat("/jail " .. control_recon_playerid .. " 600 Èñï. âåðòîëåòà íà /gw")
							end
							if imgui.Button(u8"SpawnKill íà /gw", btn_size) then  
								sampSendChat("/jail " .. control_recon_playerid .. " 600 SK in /gw")
							end
							if imgui.Button(u8"Èñïîëüçîâàíèå \nçàïðåù.êîìàíä íà /gw", btn_size) then  
								sampSendChat("/jail " .. control_recon_playerid .. " 600 Èñï. çàïðåùåííûõ êîìàíä íà /gw")
							end
						end 
						if tool_re == 2 then  
							if imgui.Button("Cheat", btn_size) then
								sampSendChat("/ans " .. control_recon_playerid .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
								sampSendChat("/ans " .. control_recon_playerid .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
								sampSendChat("/iban " .. control_recon_playerid .. " 7 Èñïîëüçîâàíèå ÷èòåðñêîãî ñêðèïòà/ÏÎ")
							end
							if imgui.Button(u8"Ïëàãèàò íèêíåéìà \nàäìèíèñòðàòîðà", btn_size) then
								sampSendChat("/ans " .. control_recon_playerid .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
								sampSendChat("/ans " .. control_recon_playerid .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
								sampSendChat("/ban " .. control_recon_playerid .. " 7 Ïëàãèàò íèêà àäìèíèñòðàòîðà.")
							end
							if imgui.Button("Nick 3/3", btn_size) then
								sampSendChat("/ans " .. control_recon_playerid .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
								sampSendChat("/ans ".. control_recon_playerid .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
								sampSendChat("/ban " .. control_recon_playerid .. " 7 Íèê, ñîäåðæàùèé íåöåíçóðíóþ ëåêñèêó")
							end
							if imgui.Button(u8"Îñê/Óíèæåíèå/Ìàò â õåëïåðå", btn_size) then
								sampSendChat("/ans " .. control_recon_playerid .. " Óâàæàåìûé èãðîê, âû íàðóøàëè ïðàâèëà ñåðâåðà, è åñëè âû..")
								sampSendChat("/ans " .. control_recon_playerid .. " ..íå ñîãëàñíû ñ íàêàçàíèåì, íàïèøèòå æàëîáó íà ôîðóì https://forumrds.ru")
								sampSendChat("/ban " .. control_recon_playerid .. " 3 Îñêîðáëåíèå/Óíèæåíèå/Ìàò â õåëïåðå")
							end
						end	
						if tool_re == 3 then   
							if imgui.Button("AFK in /arena", btn_size) then
								sampSendChat("/kick " .. control_recon_playerid .. " AFK in /arena")
							end
							if imgui.Button("DM in Jail", btn_size) then
								sampSendChat("/kick " .. control_recon_playerid .. " dm in jail")
							end
							if imgui.Button("Nick 1/3", btn_size) then
								sampSendChat("/kick " .. control_recon_playerid .. " Nick 1/3")
							end
							if imgui.Button("Nick 2/3", btn_size) then
								sampSendChat("/kick " .. control_recon_playerid .. " Nick 2/3")
							end
							if imgui.Button("Nick 3/3", btn_size) then
								sampSendChat("/kick " .. control_recon_playerid .. " Nick 3/3")
							end
						end	
					end	
					imgui.EndChild()
					else
						imgui.SetCursorPosX(imgui.GetWindowWidth()/2.3)
						imgui.SetCursorPosY(imgui.GetWindowHeight()/2.3)
						imgui.Spinner(20, 7)
					end
					imgui.End()
				end
			end
end

function sampev.onPlayerDeathNotification(killerId, killedId, reason)
	local kill = ffi.cast('struct stKillInfo*', sampGetKillInfoPtr())
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)

	killer,killed,reasonkill = killerId,killedId,reason

	local n_killer = ( sampIsPlayerConnected(killerId) or killerId == myid ) and sampGetPlayerNickname(killerId) or nil
	local n_killed = ( sampIsPlayerConnected(killedId) or killedId == myid ) and sampGetPlayerNickname(killedId) or nil
	lua_thread.create(function()
		wait(0)
		if n_killer then kill.killEntry[4].szKiller = ffi.new('char[25]', ( n_killer .. '[' .. killerId .. ']' ):sub(1, 24) ) end
		if n_killed then kill.killEntry[4].szVictim = ffi.new('char[25]', ( n_killed .. '[' .. killedId .. ']' ):sub(1, 24) ) end
	end)
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
    style.FramePadding = imgui.ImVec2(4, 3)
    style.FrameRounding = 3.0
    style.ItemSpacing = imgui.ImVec2(4, 4)
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

function play_makeadmin(num)
	lua_thread.create(function()
		if num ~= -1 then
			for bp in textcfg.makeadmin_text[num]:gmatch('[^~]+') do
				sampSendChat("/makeadmin " .. u8:decode(tostring(bp)))
			end
			num = -1
		end
	end)
end	
