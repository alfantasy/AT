require 'lib.moonloader'
local vkeys = require "vkeys" -- ������� ��� ������
local imgui = require 'imgui' -- ������� imgui ����
local encoding = require 'encoding' -- ���������� ��������
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
local directIni = "AdminTool\\reports.ini"
local ATrep = inicfg.load({
    main = {
        good_game_prefix = false,
		posX = 0,
		posY = 0,
    },
	bind_name = {},
	bind_text = {},
	bind_delay = {},
}, directIni)
inicfg.save(ATrep, directIni)

local sw2, sh2 = getScreenResolution()

local fa = require 'faicons'
local fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
function imgui.BeforeDrawFrame()
	if fa_font == nil then  
		local font_config = imgui.ImFontConfig()
		font_config.MergeMode = true 
		fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fontawesome-webfont.ttf', 14.0, font_config, fa_glyph_ranges)
	end	
end 

function save() 
    inicfg.save(ATrep, directIni)
end    

local report_ans = 0
local check_ans = 0

local rep = { 
    imgui = imgui.ImBool(false),
	window_ans = imgui.ImBool(false),
	binder_delay = imgui.ImInt(2500),
	binder_text = imgui.ImBuffer(65536),
	binder_name = imgui.ImBuffer(256),
    text = imgui.ImBuffer(4096),
    report = imgui.ImBool(false),
    ggp = imgui.ImBool(ATrep.main.good_game_prefix),
	posX = ATrep.main.posX,
	posY = ATrep.main.posY
}

local questions = {
    ["reporton"] = {
        [u8"������ ������ �� ������"] = "�����(�) ������ �� ����� ������!",
		[u8"��� ��������"] = "��������� �����, ������ ������ ���!",
		[u8"��� ����� ���� � �������"] = "������ ���������� ��������� � ���������.",
		[u8"������ �� ������"] = "������ ������ �� �������������� �� ����� https://forumrds.ru",
		[u8"������ �� ������"] = "�� ������ �������� ������ �� ������ �� ����� https://forumrds.ru",
        [u8"������ �� ���-����"] = "�� ������ �������� ������ �� ����� https://forumrds.ru",
		[u8"������� ���"] = "������� ���",
		[u8"��������"] = "��������",
		[u8"��������� �������������������"] = "��������� ������������������� �� Russian Drift Server!",
		[u8"����� ������ �� ������"] = "�� ���� ��������� �� ������� ������",
		[u8"����� ����"] = " ������ ����� ����",
		[u8"����� �� � ����"] = "������ ����� �� � ����",
		[u8"��������� ������/������"] = "�������� ��� ������/������",
		[u8"��������� ID"] = "�������� ID ����������/������ � /report",
		[u8"����� �������"] = "������ ����� �������",
		[u8"��������"] = "��������",
		[u8"�� �� ��������"] = "GodMode (������) �� ������� �� ��������",
		[u8"��� ������"] = "� ������ ������ ����� � ������������� �� ��������.",
		[u8"������ ����� ���������"] = "������ ����� ��� ���������.",
		[u8"��� ����� ���������"] = "������ ��� ����� ����� ���������.",
		[u8"������ ����� ����������"] = "������ ������ ����� ����� ����������.",
		[u8"�����������"] = "������ ����, ��������� �����.",
        [u8"���������"] = "���������",
		[u8"�����"] = "�����",
		[u8"��"] = "��",
		[u8"���"] = "���",
		[u8"�� ���������"] = "�� ���������",
		[u8"�� �����"] = "�� �����",
		[u8"������ ���������"] = "�� ���������",
		[u8"�� ������"] = "�� ������",
		[u8"��� ���"] = "������ ����� - ��� ���",
		[u8"�����������"] = "���������� ���������"

    },
	["HelpHouses"] = {
		[u8"��� �������� ������ � ������"] = "/hpanel -> ����1-3 -> �������� -> ������ ���� -> ��������� ������",
		[u8"� ����� ��� �������"] = "/hpanel -> ����1-3 -> �������� -> ������� ��� ����������� || /sellmyhouse (������)",
		[u8"��� ������ ���"] = "�������� �� ����� (�������, �� �������) � ������� F.",
        [u8"��� ������� ���� ����"] = "/hpanel"
	},
	["HelpCmd"] = {
		[u8"������� VIP`�"] = "������ ���������� ����� ����� � /help -> 7 �����",
        [u8"���������� � �����"] = "������ ���������� ����� ������ � ���������",
		[u8"���������� Premuim"] = "������ ����� � ����������� Premuim VIP (/help -> 7)",
		[u8"���������� Diamond"] = "������ ����� � ����������� Diamond VIP (/help -> 7) ",
		[u8"���������� Platinum"] = "������ ����� � ����������� Platinum VIP (/help -> 7)",
		[u8"���������� ������"] = "������ ����� � ����������� ������� VIP (/help -> 7)",
		[u8"������� ��� �������"] = "������ ���������� ����� ����� � /help -> 8 �����",
        [u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 13 �����",
		[u8"��� �������� �������"] = "������� �����, ��� �� /help -> 17 �����"
	},
	["HelpGangFamilyMafia"] = {
		[u8"��� ������� ���� �����"] = "/menu (/mm) - ALT/Y -> ������� ����",
		[u8"��� ������� ���� �����"] = "/fpanel ",
		[u8"��� ��������� ������"] = "/guninvite (�����) || /funinvite (�����)",
		[u8"��� ���������� ������"] = "/ginvite (�����) || /finvite (�����)",
		[u8"��� �������� �����/�����"] = "/gleave (�����) || /fleave (�����)",
        [u8"��� ������ ����"] = "/grank IDPlayer ����",
		[u8"��� �������� �����"] = "/leave",
		[u8"��� ������ �������"] = "/gvig // ������ ���� �������",
	},
	["HelpTP"] = {
		[u8"��� �� � ���������"] = "tp -> ������ -> ����������",
		[u8"��� �� � ��������������"] = "/tp -> ������ -> ���������� -> ��������������",
		[u8"��� �� � ����"] = "/bank || /tp -> ������ -> ����",
		[u8"��� ���� ��"] = "/tp (�� ��������), /g (/goto) id (� ������) � VIP (/help -> 7 �����)",
        [u8"��� �� �� ������"] = "/tp -> ������"
	},
	["HelpSellBuy"] = {
		[u8"��� ������� ����"] = "������� ���������� ��� ������ ����� �� /trade. ����� �������, ������� F ����� �����",
		[u8"��� �������� ������"] = "����� �������� ������, ������� /trade, � ��������� � NPC ������, ����� ������",
		[u8"� ��� ������� �����"] = "/sellmycar IDPlayer ����1-5 ����� || /car -> ����1-5 -> ������� �����������",
        [u8"� ��� ������� ������"] = "/biz > ������� ������ �����������",
	},
	["HelpMoneys"] = {
		[u8"��� �������� ������"] = "/givemoney IDPlayer money",
		[u8"��� �������� ����"] = "/givescore IDPlayer score",
		[u8"��� �������� �����"] = "/giverub IDPlayer rub | � ������� VIP (/help -> 7)",
		[u8"��� �������� �����"] = "/givecoin IDPlayer coin | � ������� VIP (/help -> 7)",
        [u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 13 �����",
	},
	["HelpBuz"] = {
		[u8"���� ������"] = "������� /cpanel ", 
		[u8"������� ������"] = "/biz > ������� ������ �����������",
		[u8"���� ����������"] = "������� /biz ",
		[u8"���� �����"] = "������� /clubpanel ",
	},
	["HelpDefault"] = {
		[u8"IP RDS 01"] = "46.174.52.246:7777",
		[u8"IP RDS 02"] = "46.174.55.87:7777",
		[u8"IP RDS 03"] = "46.174.49.170:7777",
		[u8"IP RDS 04"] = "46.174.55.169:7777",
		[u8"IP RDS 05"] = "62.122.213.75:7777",
		[u8"���� � ������� HTML"] = "https://colorscheme.ru/html-colors.html",
		[u8"���� � ������� HTML 2"] = "https://htmlcolorcodes.com",
		[u8"��� ��������� ����"] = "���� � ���� HTML {RRGGBB}. ������� - 008000. ����� {} � ������ ���� ����� ������ {008000}�������",
		[u8"������ �� ���.������"] = "https://vk.com/dmdriftgta | ������ �������",
        [u8"������ �� �����"] = "https://forumrds.ru | ����� �������",
        [u8"��� �������� ���/������"] = "�������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ����",
		[u8"��� ����� ��������� ������"] = "����������� ������� /car",
		[u8"��� �������� ����"] = '������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����',
		[u8"��� �������� ������"] = "������ ���������� �� ���� �����. ����� ������������ �� /garage",
		[u8"��� ������ ����"] = "��� ����, ����� ������ ����, ����� ������ /capture",
		[u8"��� ������ ���/����"] = "/passive ",
		[u8"/statpl"] = "����� ���������� ������, ����, �����, �����, ����� - /statpl",
		[u8"����� ������"] = "/mm -> �������� -> ������� ������",
		[u8"����� �����"] = "/mm -> ������������ �������� -> ��� ����������",
        [u8"��� ����� ������"] = "/menu (/mm) - ALT/Y -> ������",
		[u8"��� ����� ��������"] = "/menu (/mm) - ALT/Y -> ��������",
        [u8"��� ������� ����"] = "/mm (/mn) || Alt/Y",
		[u8"��� ������ �����"] = "/menu (/mm) - ALT/Y -> �/� -> ������",
		[u8"���� ����� �������"] = "/kill | /tp | /spawn",
		[u8"��� ������� �� �����/����"] = "/join | ���� ������������� �������, ������� �� �����",
		[u8"����������� ���"] = "/dt 0-990 / ����������� ���",
        [u8"�������� ������/�������"] = "/quests | /dquest | /bquest",
		[u8"�������� � �������"] = "�������� � �������."
	},
	["HelpSkins"] = {
		[u8"���� �� �������"] = " https://gtaxmods.com/skins-id.html.",
		[u8"����"] = "65-267, 280-286, 288, 300-304, 306, 307, 309-311",
		[u8"�������"] = "102-104",
		[u8"����"] = "105-107",
		[u8"�����"] = "117-118, 120",
		[u8"������"] = "108-110",
		[u8"��.�����"] = "111-113",
		[u8"�������"] = "114-116",
		[u8"�����"] = "124-127"
	},
	["HelpSettings"] = {
		[u8"�����/������ �������"] = "/menu (ALT/Y) -> ��������� -> 1 �����.",
		[u8"���������� �������� �� �����"] = "/menu (ALT/Y) -> ��������� -> 2 �����.",
		[u8"On/Off ������ ���������"] = "/menu (ALT/Y) -> ��������� -> 3 �����.",
		[u8"������� �� ��������"] = "/menu (ALT/Y) -> ��������� -> 4 �����.",
		[u8"���������� ���������� DM Stats"] = "/menu (ALT/Y) -> ��������� -> 5 �����.",
		[u8"������ ��� ������������"] = "/menu (ALT/Y) -> ��������� -> 6 �����.",
		[u8"���������� ���������"] = "/menu (ALT/Y) -> ��������� -> 7 �����.",
		[u8"���������� Drift Lvl"] = "/menu (ALT/Y) -> ��������� -> 8 �����.",
		[u8"����� � ����/���� �����"] = "/menu (ALT/Y) -> ��������� -> 9 �����.",
		[u8"����� �������� ����"] = "/menu (ALT/Y) -> ��������� -> 10 �����.",
		[u8"On/Off ����������� � �����"] = "/menu (ALT/Y) -> ��������� -> 11 �����.",
		[u8"����� �� �� TextDraw"] = "/menu (ALT/Y) -> ��������� -> 12 �����.",
		[u8"On/Off ����"] = "/menu -> ��������� (ALT/Y) -> 13 �����.",
		[u8"On/Off FPS ����������"] = "/menu (ALT/Y) -> ��������� -> 15 �����.",
		[u8"On/Off �����������"] = "/menu (ALT/Y) -> ��������� -> 16 �����",
		[u8"On/Off �����.�����"] = "/menu (ALT/Y) -> ��������� -> 17 �����",
		[u8"On/Off ����.�����"] = "/menu (ALT/Y) -> ��������� -> 18 �����",
		[u8"On/Off ���.������ ��� �����"] = "/menu (ALT/Y) -> ��������� -> 19 �����",
		[u8"������ ��.����"] = "/menu (ALT/Y) -> ��������� -> 20 �����",
	}
}

local tag = "{00BFFF} [AT] " -- ��������� ����������, ������� ������������ ��� AT

function main()
    while not isSampAvailable() do wait(0) end

	sampAddChatMessage(tag .. " ������������� �������, ����������� �� �������.")

    sampRegisterChatCommand("tdd", cmd_tdd)
	sampRegisterChatCommand("gadm", cmd_gadm)
	sampRegisterChatCommand("enk", cmd_enk)
	sampRegisterChatCommand("gak", cmd_gak)
	sampRegisterChatCommand("ctun", cmd_ctun)
	sampRegisterChatCommand("gn", cmd_gn)
	sampRegisterChatCommand("pd", cmd_pd)
	sampRegisterChatCommand("dtl", cmd_dtl)
	sampRegisterChatCommand("nz", cmd_nz)
	sampRegisterChatCommand("yes", cmd_yes)
	sampRegisterChatCommand("net", cmd_net)
	sampRegisterChatCommand("nt", cmd_nt)
	sampRegisterChatCommand("fp", cmd_fp)
	sampRegisterChatCommand("mg", cmd_mg)
	sampRegisterChatCommand("pg", cmd_pg)
	sampRegisterChatCommand("krb", cmd_krb)
	sampRegisterChatCommand("kmd", cmd_kmd)
	sampRegisterChatCommand("gm", cmd_gm)
	sampRegisterChatCommand("plg", cmd_plg)
	sampRegisterChatCommand("vbg", cmd_vbg)
	sampRegisterChatCommand("en", cmd_en)
	sampRegisterChatCommand("of", cmd_of)
	sampRegisterChatCommand("nv", cmd_nv)
	sampRegisterChatCommand("bk", cmd_bk)
	sampRegisterChatCommand("h7", cmd_h7)
	sampRegisterChatCommand("h8", cmd_h8)
	sampRegisterChatCommand("h13", cmd_h13)
	sampRegisterChatCommand("zba", cmd_zba)
	sampRegisterChatCommand("zbp", cmd_zbp)
	sampRegisterChatCommand("int", cmd_int)
	sampRegisterChatCommand("og", cmd_og)
	sampRegisterChatCommand("dis", cmd_dis)
	sampRegisterChatCommand("avt", cmd_avt)
	sampRegisterChatCommand("avt1", cmd_avt1)
	sampRegisterChatCommand("pgf", cmd_pgf)
	sampRegisterChatCommand("igf", cmd_igf)
	sampRegisterChatCommand("msid", cmd_msid)
	sampRegisterChatCommand("al", cmd_al)
	sampRegisterChatCommand("c", cmd_c)
	sampRegisterChatCommand("cl", cmd_cl)
	sampRegisterChatCommand("yt", cmd_yt)
	sampRegisterChatCommand("n", cmd_n)
	sampRegisterChatCommand("nac", cmd_nac)
	sampRegisterChatCommand("hg", cmd_hg)
	sampRegisterChatCommand("tm", cmd_tm)
	sampRegisterChatCommand("cpt", cmd_cpt)
	sampRegisterChatCommand("psv", cmd_psv)
	sampRegisterChatCommand("drb", cmd_drb)
	sampRegisterChatCommand("prk", cmd_prk)
	sampRegisterChatCommand("zsk", cmd_zsk)
	sampRegisterChatCommand("vgf", cmd_vgf)
	sampRegisterChatCommand("stp", cmd_stp)
	sampRegisterChatCommand("rid", cmd_rid)
	sampRegisterChatCommand("gvs", cmd_gvs)
	sampRegisterChatCommand("gvm", cmd_gvm)
	sampRegisterChatCommand("msp", cmd_msp)
	sampRegisterChatCommand("chap", cmd_chap)
	sampRegisterChatCommand("lgf", cmd_lgf)
	sampRegisterChatCommand("trp", cmd_trp)
	sampRegisterChatCommand("cops", cmd_cops)
	sampRegisterChatCommand("bal", cmd_bal)
	sampRegisterChatCommand("cro", cmd_cro)
	sampRegisterChatCommand("vg", cmd_vg)
	sampRegisterChatCommand("rumf", cmd_rumf)
	sampRegisterChatCommand("var", cmd_var)
	sampRegisterChatCommand("triad", cmd_triad)
	sampRegisterChatCommand("mf", cmd_mf)
	sampRegisterChatCommand("smc", cmd_smc)
	sampRegisterChatCommand("html", cmd_html)
	sampRegisterChatCommand("ugf", cmd_ugf)
	sampRegisterChatCommand("vp1", cmd_vp1)
	sampRegisterChatCommand("vp2", cmd_vp2)
	sampRegisterChatCommand("vp3", cmd_vp3)
	sampRegisterChatCommand("vp4", cmd_vp4)
	sampRegisterChatCommand("ktp", cmd_ktp)
	sampRegisterChatCommand("tcm", cmd_tcm)
	sampRegisterChatCommand("gfi", cmd_gfi)
	sampRegisterChatCommand("hin", cmd_hin)
	sampRegisterChatCommand("smh", cmd_smh)
	sampRegisterChatCommand("cr", cmd_cr)
	sampRegisterChatCommand("hct", cmd_hct)
	sampRegisterChatCommand("gvr", cmd_gvr)
	sampRegisterChatCommand("gvc", cmd_gvc)

    while true do
        wait(0)

        if isKeyDown(109) and sampIsDialogActive() then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color1() .. "��������� ������������������� �� ������� RDS!")
			wait(650)
		end
		-- ��������� ���� ������� �� NumPad - (/ans)

		if sampGetCurrentDialogEditboxText() == '/gvk' then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color1() .. "https://vk.com/dmdriftgta")
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/cxtn' then  
			sampSetCurrentDialogEditboxText('{FFFFFF}/count time || /dmcount time' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.�' or sampGetCurrentDialogEditboxText() == '/w' then  
			sampSetCurrentDialogEditboxText(color1())
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rfh' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/car' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rgf' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������� ����������, ��� ������ ����� �� /trade. ����� �������, /sell ����� �����')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/n.y' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> �/� -> ������ ' .. color1() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ufy' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> ������ ' .. color1() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/lnn' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/dt 0-990 / ����������� ��� ' .. color1() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gtl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> �������� ' .. color1() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/bcr' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� �� ���� �����. ����� ������������ �� /garage. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yp' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ���������. '  .. color1() .. ' | �������� ��������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;lf' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}��. ' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;yt' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}���. ' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yr' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�����. ' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jna' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/familypanel ' .. color1() .. ' | �������� ������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jn,' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> ������� ���� ' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}��������. ' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rh,' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������, ������, ������. ' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rvl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������, ��, ����������, ������, ����� ����� �� �����(/trade)' .. color1() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/uv' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}GodMode (������) �� ������� �� ��������. ' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/hku' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}���������� ���������. '  .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ydl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ������. ' .. color1() .. ' | �������� �������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jaa' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ���������. ' .. color1() .. ' | �������� ��������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ytp' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� �����.' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/,fu' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� - ��� ���. ' .. color1() .. ' | �������� ������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '/smh' or sampGetCurrentDialogEditboxText() == '.���' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/sellmyhouse (������)  ||  /hpanel -> ���� -> �������� -> ������� ��� �����������')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/lxl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/hpanel -> ����1-3 -> �������� -> ������ ���� | �������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/j,v' then
			sampSetCurrentDialogEditboxText('{FFFFFF}����� �������� ������, ������� /trade, � ��������� � NPC ������, ����� ������') 
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rng' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/tp (�� ��������), /g (/goto) id (� ������) � VIP (/help -> 7 �����)') 
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rgn' then
			sampSetCurrentDialogEditboxText('{FFFFFF}��� ����, ����� ������ ����, ����� ������ /capture | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��1' or sampGetCurrentDialogEditboxText() == '/dg1' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� � ����������� Premuim VIP (/help -> 7) | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��2' or sampGetCurrentDialogEditboxText() == '/dg2' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� � ����������� Diamond VIP (/help -> 7) | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��3' or sampGetCurrentDialogEditboxText() == '/dg3' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� � ����������� Platinum VIP (/help -> 7) | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��4' or sampGetCurrentDialogEditboxText() == '/dg4' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� � ����������� "������" VIP (/help -> 7) | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/gflv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������� �����, ��� �� /help -> 17 �����. | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/rjgs' then
			sampSetCurrentDialogEditboxText('{FFFFFF}265-267, 280-286, 288, 300-304, 306, 307, 309-311 | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/,fk' then
			sampSetCurrentDialogEditboxText('{FFFFFF}102-104| ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/uhed' then
			sampSetCurrentDialogEditboxText('{FFFFFF}105-107 | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/heva' then
			sampSetCurrentDialogEditboxText('{FFFFFF}111-113 | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/dfh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}114-116 | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.�����' or sampGetCurrentDialogEditboxText() == '/nhbfl' then
			sampSetCurrentDialogEditboxText('{FFFFFF}117-188, 120 | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/dfu' then
			sampSetCurrentDialogEditboxText('{FFFFFF}108-110 | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/va' then
			sampSetCurrentDialogEditboxText('{FFFFFF}124-127 | ' .. color1() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/cgh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/mm -> �������� -> ������� ������ | ' .. color1() .. '  �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/vcg' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/mm -> ������������ �������� -> ��� ����������| ' .. color1() .. '  �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ebl' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�������� ID ����������/������ � /report ' .. color1() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/cng' then
			sampSetCurrentDialogEditboxText('{FFFFFF}����� ���������� �����, �����, ����� � �.�. - /statpl ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}��� �������� �����, ��������� ������ /givemoney IDPlayer ����� | ' .. color1() .. ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udc' then
			sampSetCurrentDialogEditboxText('{FFFFFF}��� �������� �����, ���������� ������ /givescore IDPlayer ����� |' .. color1() .. ' � Diamond VIP.')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/gv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/sellmycar IDPlayer ����(1-3) RDScoin (������), � ���: /car | ' .. color1() .. ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/de,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}����� ������ ������� ��������� �����, ���� �������: /gvig ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/px' then
			sampSetCurrentDialogEditboxText('{FFFFFF}���� �� ��������, ������� /spawn | /kill, ' .. color1() .. ' �� �� ����� ��� ������! ')
		end

		if sampGetCurrentDialogEditboxText() == '/prk' or sampGetCurrentDialogEditboxText() == '.���' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/parkour - ��������� �� ������ | '  .. color1() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '/drb' or sampGetCurrentDialogEditboxText() == '.���' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/derby - ��������� �� ����� | '  .. color1() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gcd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/passive ' .. color1() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/bya' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� ����� ������ � ���������. '  .. color1() ..  ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/ju' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����' .. color1() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/j;' then
			sampSetCurrentDialogEditboxText('{FFFFFF}��������. '  .. color1() ..  ' ��������� ������������������� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/wdtn' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}https://colorscheme.ru/html-colors.html ' .. color1() .. ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;,f' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ������ �� �������������� �� ����� https://forumrds.ru')
		end

		if sampGetCurrentDialogEditboxText() == '.���'or sampGetCurrentDialogEditboxText() == '/;,b'  then
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ������ �������� ������ �� ������ �� ����� https://forumrds.ru')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yx' then
				sampSetCurrentDialogEditboxText('{FFFFFF}�����(�) ������ �� ����� ������! ' .. color1() .. ' �������� ���� �� ������� RDS. <3 ')
				wait(1000)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/re " )
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/bx' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� ����. ' .. color1() .. ' �������� ���� �� ������� RDS. <3 ')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.��' then
				sampSetCurrentDialogEditboxText('{FFFFFF}����� �� ������ �������, ��������. :3 ')
				wait(1000)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/re " )
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.�7' or sampGetCurrentDialogEditboxText() == '/g7' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� ����� ����� � /help -> 7 �����. | '  .. color1() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.�13' or sampGetCurrentDialogEditboxText() == '/g13' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� ����� ����� � /help -> 13 �����. | '  .. color1() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.�8' or sampGetCurrentDialogEditboxText() == '/g8' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� ����� ����� � /help -> 8 �����. | '  .. color1() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/yfr' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� �������. | '  .. color1() ..  '  �������� ���� �� RDS! <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yy' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ���� ��������� �� ������. | ' .. color1() .. ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� �� � ����. | ' .. color1() .. ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/,r' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ���� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/nfc' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/tp -> ������ -> ���������� |' .. color1() .. '  �������� ���� �� RDS. <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/nfv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/tp -> ������ -> ���������� -> �������������� | ' .. color1() .. ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gua' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/gleave (�����) || /fleave (�����)| ' .. color1() .. ' �������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gkv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/leave (�������� �����)| ' .. color1() .. ' �������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/en' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�������� ��� ������/������. ' .. color1() .. ' ������� ���� <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gu,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/ginvite (�����) || /finvite (�����) | ' .. color1() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/eu,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/guninvite (�����) || /funinvite (�����) | ' .. color1() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/giverub IDPlayer rub | � ������� (/help -> 7) | ' .. color1() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udr' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/givecoin IDPlayer coin | � ������� (/help -> 7) | ' .. color1() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/gd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������� ���. | ' .. color1() .. ' ������� ���� �� RDS <3')
		end

        if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/fgh' then 
            sampSendDialogResponse(2351, 1, 0, '{FFFFFF}������� ��� ������! ' .. color1() .. '������� ����!')
            wait(200)
            sampCloseCurrentDialogWithButton(13)
            wait(200)
            sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "] | " .. text_rep)
        end    

		if string.find(sampGetChatInputText(), "%-��") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "-��", "| �������� ���� �� RDS <3"))
		end

		if string.find(sampGetChatInputText(), "%/vrm") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/vrm", "��������� ������������������� �� Russian Drift Server!"))
		end

		if string.find(sampGetChatInputText(), "%/gvk") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/gvk", "https://vk.com/dmdriftgta"))
		end

		if sampGetCurrentDialogId() == 2352 then  
			sampCloseCurrentDialogWithButton(1)
		end
    end
end

function color1() -- �������, ����������� ������������� � ����� ���������� ����� � ������� ������������ os.time()
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
	--print(mcolor)
	mcolor = mcolor .. '}'
	return mcolor
end 

------- �������, ����������� � ������� ������� -------
function cmd_tcm(arg)
	sampSendChat("/ans " .. arg .. " ����� �������� ������, ������� /trade, � ��������� � NPC ������, ����� ������ ")
end 

function cmd_tm(arg)
	sampSendChat("/ans " .. arg .. " ��������. | ��������� ������������������� �� RDS <3 ")
end

function cmd_zsk(arg)
	sampSendChat("/ans " .. arg .. " ���� �� ��������, ������� /spawn | /kill, �� �� ����� ��� ������! ")
end

function cmd_vgf(arg)
	sampSendChat("/ans " .. arg .. " ����� ������ ������� ��������� �����, ���� �������: /gvig ")
end

function cmd_html(arg)
	sampSendChat("/ans ".. arg .. " https://colorscheme.ru/html-colors.html | �������� ����! ")
end

function cmd_ktp(arg)
	sampSendChat("/ans " .. arg .. " /tp (�� ��������), /g (/goto) id (� ������) � VIP (/help -> 7 �����) ")
end

function cmd_vp1(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� � ����������� Premuim VIP (/help -> 7)  | �������� ����! <3 ")
end

function cmd_vp2(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� � ����������� Diamond VIP (/help -> 7) | �������� ����! <3 ")
end

function cmd_vp3(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� � ����������� Platinum VIP (/help -> 7) | �������� ����! <3 ")
end

function cmd_vp4(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� � ����������� ������� VIP (/help -> 7) | �������� ����! <3 ")
end

function cmd_chap(arg)
	sampSendChat("/ans " .. arg .. " /mm -> �������� -> ������� ������ | �������� ����! <3 ")
end

function cmd_msp(arg)
	sampSendChat("/ans " .. arg .. " /mm -> ������������ �������� -> ��� ���������� | �������� ���� �� RDS. <3 ")
end

function cmd_trp(arg)
	sampSendChat("/ans " .. arg .. " /report | �������� ���� �� RDS. <3 ")
end

function cmd_rid(arg)
	sampSendChat("/ans " .. arg .. " �������� ID ����������/������ � /report | �������� �������������������. ")
end

function cmd_bk(arg)
	sampSendChat("/ans " .. arg .. " �������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ���� ")
end

function cmd_h7(arg)
	sampSendChat("/ans " .. arg .. " ���������� ���������� ����� � /help -> 7 �����. | �������� ���� �� RDS. <3 ")
end

function cmd_h8(arg)
	sampSendChat("/ans " .. arg .. " ������ ������ ���������� ����� � /help -> 8 �����. | �������� ���� �� RDS. <3 ")
end

function cmd_h13(arg)
	sampSendChat("/ans " .. arg .. " ������ ������ ���������� ����� � /help -> 13 �����. | �������� ���� �� RDS. <3 ")
end

function cmd_zba(arg)
	sampSendChat("/ans " .. arg .. " ����� ������� �� ���? ������ ������ �� ����� https://forumrds.ru")
end

function cmd_zbp(arg)
	sampSendChat("/ans " .. arg .. " ������ ������ �� ������ �� ����� https://forumrds.ru")
end

function cmd_avt(arg)
	sampSendChat("/ans " .. arg .. " /tp -> ������ -> ���������� | �������� ����!")
end

function cmd_avt1(arg)
 sampSendChat("/ans " .. arg .. " /tp -> ������ -> ���������� -> �������������� | �������� ����!")
end

function cmd_pgf(arg)
	sampSendChat("/ans " .. arg .. " /gleave (�����) || /fleave (�����)| �������� ���� �� RDS <3")
end

function cmd_lgf(arg)
	sampSendChat("/ans " .. arg .. " /leave (�������� �����) | �������� ���� �� RDS <3")
end

function cmd_igf(arg)
	sampSendChat("/ans " .. arg .. " /ginvite (�����) || /finvite (�����) | ������� ���� �� RDS <3" )
end

function cmd_ugf(arg)
	sampSendChat("/ans " .. arg .. " /guninvite (�����) || /funinvite (�����) | ������� ���� �� RDS <3 ")
end

function cmd_cops(arg)
	sampSendChat("/ans " .. arg .. " 265-267, 280-286, 288, 300-304, 306, 307, 309-311 | ������� ���� �� RDS <3")
end

function cmd_bal(arg)
	sampSendChat("/ans " .. arg .. "  102-104 | ������� ���� �� RDS <3")
end

function cmd_cro(arg)
	sampSendChat("/ans " .. arg .. " 105-107 | ������� ���� �� RDS <3")
end

function cmd_rumf(arg)
	sampSendChat("/ans " .. arg .. " 111-113 | ������� ���� �� RDS <3")
end

function cmd_vg(arg)
	sampSendChat("/ans " .. arg .. " 108-110 | ������� ���� �� RDS <3 ")
end

function cmd_var(arg)
	sampSendChat("/ans " .. arg .. " 114-116 | ������� ���� �� RDS <3")
end

function cmd_triad(arg)
	sampSendChat("/ans " .. arg .. " 117-118, 120  | ������� ���� �� RDS <3")
end

function cmd_mf(arg)
	sampSendChat("/ans " .. arg .. " 124-127 | ������� ���� �� RDS <3")
end

function cmd_gvm(arg)
	sampSendChat("/ans " .. arg .. " ��� �������� �����, ��������� ������ /givemoney IDPlayer ����� | �������� ����!' ")
end

function cmd_gvs(arg)
	sampSendChat("/ans " .. arg .. " ��� �������� �����, ���������� ������ /givescore IDPlayer ����� | � Diamond VIP. ")
end

function cmd_cpt(arg)
	sampSendChat("/ans " .. arg .. " ��� ����, ����� ������ ����, ����� ������ /capture | �������� ����! ")
end

function cmd_psv(arg)
	sampSendChat("/ans " .. arg .. " /passive - ��������� �����, ��� ����, ����� ��� �� ����� �����.  ")
end

function cmd_dis(arg)
	sampSendChat("/ans " ..  arg .. " ����� �� � ����. | �������� ���� �� RDS <3 ")
end

function cmd_nac(arg)
	sampSendChat("/ans " .. arg .. " ����� �������. | �������� ���� �� RDS <3")
end

function cmd_cl(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� ����. | �������� ���� �� RDS <3")
end

function cmd_yt(arg)
	sampSendChat("/ans " .. arg .. " �������� ��� ������/������. | �������� ���� �� RDS <3")
end

function cmd_drb(arg)
	sampSendChat("/ans " .. arg .. " /derby - ��������� �� ����� | �������� ���� �� RDS 02 <3 ")
end

function cmd_smc(arg)
	sampSendChat("/ans " .. arg .. " /sellmycar IDPlayer ����(1-3) RDScoin (������), � ���: /car ")
end

function cmd_c(arg)
	lua_thread.create(function()
		sampSendChat("/ans " .. arg .. " �����(�) ������ �� ����� ������. | �������� ���� �� RDS <3")
		wait(1000)
		sampSetChatInputEnabled(true)
		sampSetChatInputText("/re " )
	end)
end

function cmd_stp(arg)
	sampSendChat("/ans " .. arg .. " ����� ���������� �����, �����, ����� � �.�. - /statpl ")
end

function cmd_prk(arg)
	sampSendChat("ans ".. arg .. " /parkour - ��������� �� ������ | �������� ���� �� RDS 02 <3 ")
end

function cmd_n(arg)
	sampSendChat("/ans " .. arg .. " �� ���� ��������� �� ������. | �������� ���� �� RDS <3")
end

function cmd_hg(arg)
	sampSendChat("/ans " .. arg .. " ������� ���. | ��������� ������������������� �� RDS <3 ")
end

function cmd_int(arg)
	sampSendChat("/ans " .. arg .. " ������ ���������� ����� ������ � ���������. �������� ����! ")
end

function cmd_og(arg)
	sampSendChat("/ans " .. arg ..  '������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����')
end

function cmd_msid(arg)
	sampSendChat("/ans " .. arg .. " ������������! ��������� ������ � ID! ��������� �����. ")
	sampSendChat("/ans " .. arg .. " ��������� ������������������� �� Russian Drift Server! ")
end

function cmd_al(arg)
	sampSendChat("/ans " .. arg .. " ������������! �� ������ ������ /alogin! ")
	sampSendChat("/ans " .. arg .. " ������� ������� /alogin � ���� ������, ����������.")
end

function cmd_gfi(arg)
	sampSendChat("/ans " .. arg .. " /funinvite id (� �����), /ginvite id (� �����) ")
end

function cmd_hin(arg)
	sampSendChat("/ans " .. arg .. ' /hpanel -> ����1-3 -> �������� -> ������ ���� | �������� ���� �� RDS <3 ')
end

function cmd_gn(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> ������ | �������� ������������������")
end

function cmd_pd(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> �������� | �������� ������������������")
end

function cmd_dtl(arg)
	sampSendChat("/ans " .. arg .. " ������ ���������� �� ���� �����. ����� ������������ �� /garage. | �������� ������������������")
end

function cmd_nz(arg)
	sampSendChat("/ans " .. arg .. " �� ���������. | �������� ������������������")
end

function cmd_y(arg)
	sampSendChat("/ans " .. arg .. " ��. | �������� ������������������")
end

function cmd_net(arg)
	sampSendChat("/ans " .. arg .. " ���. | �������� ������������������")
end

function cmd_gak(arg)
	sampSendChat("/ans" .. arg .. " ������� ����������, ��� ������ ����� �� /trade. ����� �������, F � ����� ")
end

function cmd_enk(arg)
	sampSendChat("/ans " .. arg .. " �����. | �������� ������������������")
end

function cmd_fp(arg)
	sampSendChat("/ans " .. arg .. " /familypanel | �������� ������������������")
end

function cmd_mg(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> ������� ���� | �������� ������������������")
end

function cmd_pg(arg)
	sampSendChat("/ans " .. arg .. " ��������. | �������� ������������������")
end

function cmd_krb(arg)
	sampSendChat("/ans " .. arg .. " ������, ������, ������. | �������� ������������������")
end

function cmd_kmd(arg)
	sampSendChat("/ans " .. arg .. " ������, ��, ����������, ������, ����� ����� �� �����(/trade) | �������� ���� �� RDS <3")
end

function cmd_gm(arg)
	sampSendChat("/ans " .. arg .. " GodMode (������) �� ������� �� ��������. | �������� ������������������")
end

function cmd_plg(arg)
	sampSendChat("/ans " .. arg .. " ���������� ���������. | �������� ������������������")
end

function cmd_nv(arg)
	sampSendChat("/ans " .. arg .. " �� ������. | �������� ������������������")
end

function cmd_of(arg)
	sampSendChat("/ans " .. arg .. " �� ���������. | �������� ������������������")
end

function cmd_en(arg)
	sampSendChat("/ans " .. arg .. " �� �����. | �������� ������������������")
end

function cmd_vbg(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� - ��� ���. | �������� ������������������")
end

function cmd_ctun(arg)
	sampSendChat("/ans " .. arg .. ' /menu (/mm) - ALT/Y -> �/� -> ������ | �������� ���� �� RDS <3')
end

function cmd_cr(arg)
	sampSendChat("/ans " .. arg .. ' /car | �������� ���� �� ������� RDS <3 ')
end

function cmd_zsk(arg)
	sampSendChat("/ans " .. arg .. " ���� �� ��������, ������� /spawn | /kill | �������� ���� �� RDS <3")
end

function cmd_smh(arg)
	sampSendChat("/ans " .. arg .. " /sellmyhouse (������)  ||  /hpanel -> ���� -> �������� -> ������� ��� ����������� ")
end

function cmd_gadm(arg)
	sampSendChat("/ans " .. arg .. " ������� �����, ��� �� /help -> 17 �����. | �������� ���� �� RDS. <3")
end

function cmd_hct(arg)
	sampSendChat("/ans " .. arg .. " /count time || /dmcount time | �������� ���� �� RDS. <3 ")
end

function cmd_gvr(arg)
	sampSendChat("/ans " .. arg .. " /giverub IDPlayer rub | � ������� (/help -> 7) | �������� ����!")
end

function cmd_gvc(arg)
	sampSendChat("/ans " .. arg .. " /givecoin IDPlayer coin | � ������� (/help -> 7) | �������� ����!")
end

function cmd_tdd(arg)
	sampSendChat("/ans " .. arg .. " /dt 0-990 / ����������� ��� | �������� ����!")
end
------- �������, ����������� � ������� ������� -------

function sampGetPlayerIdByNickname(nick)
    nick = tostring(nick)
    local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if nick == sampGetPlayerNickname(myid) then return myid end
    for i = 0, 1003 do
      if sampIsPlayerConnected(i) and sampGetPlayerNickname(i) == nick then
        return i
      end
    end
  end

function sampev.onShowDialog(id, style, title, button1, button2, text)
    if id == 2349 then
        if text:match("�����: {......}(%S+)") and text:match("������:\n{......}(.*)\n\n{......}") then
            nick_rep = text:match("�����: {......}(%S+)")
            text_rep = text:match("������:\n{......}(.*)\n\n{......}")	
			pid_rep = sampGetPlayerIdByNickname(nick_rep)
			rep_text = u8:encode(text_rep)
        end
		if not rep.imgui.v then  
			rep.imgui.v = true  
			imgui.Process = true
		end
	else  
		rep.imgui.v = false  
		imgui.Process = false
		imgui.ShowCursor = false
    end
end

function imgui.OnDrawFrame()

	if not rep.imgui.v then  
		imgui.Process = false  
		imgui.ShowCursor = false  
	end

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

    if rep.imgui.v then 

        imgui.SetNextWindowPos(imgui.ImVec2((sw2 / 2) - 500 , (sh2 / 2) + 40), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(550, 305), imgui.Cond.FirstUseEver)
        imgui.Begin(u8"������ �� �������", rep.imgui)
        local btn_size = imgui.ImVec2(-0.1, 0)

		if report_ans == 0 then  
			imgui.Text(u8" �� ������ �������� �� ��������������� ������ ����! \n�� ������ ������ ���� �����, ���� ��������������� ���������� ������� �� AT")
			--imgui.Text(u8(nick_rep .. " [" .. pid_rep .. "]: " .. u8:decode(rep_text)))
			if imgui.Button(fa.ICON_CHECK .. u8" �������� ������ ##SEND") then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					sampSendDialogResponse(2350, 1, 0)
					wait(200)
					sampSendDialogResponse(2351, 1, 0, '{FFFFFF}������� ��� ������! ' .. color1() .. '������� ����!')
					wait(200)
					sampCloseCurrentDialogWithButton(13)
					wait(200)
					sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "] | " .. text_rep)
				end)	
			end
			imgui.Separator()
			imgui.InputText(u8"##�����", rep.text)
			imgui.SameLine() 
			if imgui.Button(fa.ICON_REFRESH .. ("##RefreshText//RemoveText")) then  
				rep.text.v = "" 
			end	
			if #rep.text.v > 0 then
				imgui.SameLine() 
				if imgui.Button(fa.ICON_FA_SAVE .. ("##SaveReport")) then  
					imgui.OpenPopup(u8'������')
				end	
			end	
			if imgui.BeginPopupModal(u8'������', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
				imgui.Text(u8'�������� �����:'); imgui.SameLine()
				imgui.PushItemWidth(130)
				imgui.InputText("##rep.binder_name", rep.binder_name)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
					rep.binder_name.v = ''
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if #rep.binder_name.v > 0 then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
						if not EditOldBind then
							local refresh_text = rep.text.v:gsub("\n", "~")
							table.insert(ATrep.bind_name, rep.binder_name.v)
							table.insert(ATrep.bind_text, refresh_text)
							if save() then
								sampAddChatMessage(tag .. '����"' ..u8:decode(rep.binder_name.v).. '" ������� ������!', -1)
								rep.binder_name.v, rep.text.v = '', ''
							end
								imgui.CloseCurrentPopup()
							else
								local refresh_text = rep.text.v:gsub("\n", "~")
								table.insert(ATrep.bind_name, getpos, rep.binder_name.v)
								table.insert(ATrep.bind_text, getpos, refresh_text)
								table.remove(ATrep.bind_name, getpos + 1)
								table.remove(ATrep.bind_text, getpos + 1)
							if save() then
								sampAddChatMessage(tag .. '����"' ..u8:decode(rep.binder_name.v).. '" ������� ��������������!', -1)
								rep.binder_name.v, rep.text.v = '', ''
							end
							EditOldBind = false
							imgui.CloseCurrentPopup()
						end
					end
				end
				imgui.EndChild()
				imgui.EndPopup()
			end	
			if imgui.Button(u8"��������") then  
				if not rep.ggp.v then 
					lua_thread.create(function()
						sampSendDialogResponse(2349, 1, 0)
						sampSendDialogResponse(2350, 1, 0)
						wait(200)
						local settext2 = '{FFFFFF}' .. rep.text.v
						sampSendDialogResponse(2351, 1, 0, u8:decode(settext2))	
						wait(200)
						sampCloseCurrentDialogWithButton(13)
						rep.imgui.v = false
					end)
				else 
					lua_thread.create(function()
						sampSendDialogResponse(2349, 1, 0)
						sampSendDialogResponse(2350, 1, 0)
						wait(200)
						local settext2 = '{FFFFFF}' .. rep.text.v 
						sampSendDialogResponse(2351, 1, 0, u8:decode(settext2) .. color1() .. ' // �������� ���� �� ������� RDS <3')	
						wait(200)
						sampCloseCurrentDialogWithButton(13)
						rep.imgui.v = false
					end)
				end	
			end		
			imgui.Separator()
			if imgui.Button(fa.ICON_QUESTION_CIRCLE .. u8" ������ �� AT") then  
				report_ans = 1
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"������� ������, ������� ���������������� � AT ��������������")
			if imgui.Button(fa.ICON_FA_SAVE .. u8" ����������� ������") then  
				report_ans = 2
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"������� ������, ������� �� ��������� � /binder")
			imgui.Separator()
			if imgui.Checkbox(u8"��������� � ������", rep.ggp) then 
				ATrep.main.good_game_prefix = rep.ggp.v 
				save() 
			end
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'������������� ��� ������ ����� �������� ����� ������ �������� ����!')	
			imgui.SetCursorPosY(imgui.GetWindowWidth() - 295)
			imgui.Separator()
			imgui.SetCursorPosY(imgui.GetWindowWidth() - 270)
			if imgui.Button(fa.ICON_WINDOW_CLOSE .. u8" ������� ##CLOSE") then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 0, 0)
					wait(200)
					sampSendDialogResponse(2348, 0, 0)
					rep.imgui.v = false  
					imgui.ShowCursor = false
				end)	
			end	
		end
		if report_ans == 1 then  
			imgui.BeginChild("##menuSecond", imgui.ImVec2(150, 275), true)
			if imgui.Button(fa.ICON_OBJECT_GROUP .. u8" �� ����-��/���-��", imgui.ImVec2(140, 0)) then  -- reporton key
				check_ans = 1  
			end	
			if imgui.Button(fa.ICON_LIST .. u8" ������� (/help)", imgui.ImVec2(140, 0)) then  -- HelpCMD key
				check_ans = 2 
			end 	
			if imgui.Button(fa.ICON_USERS .. u8" �����/�����", imgui.ImVec2(140, 0)) then  -- HelpGangFamilyMafia key
				check_ans = 3
			end	
			if imgui.Button(fa.ICON_MAP_MARKER .. u8" ���������", imgui.ImVec2(140, 0)) then  -- HelpTP key
				check_ans = 4
			end	
			if imgui.Button(fa.ICON_SHOPPING_BAG .. u8" �������", imgui.ImVec2(140, 0)) then  -- HelpBuz key
				check_ans = 5 
			end	
			if imgui.Button(fa.ICON_MONEY .. u8" �������/�������", imgui.ImVec2(140, 0)) then  -- HelpSellBuy key
				check_ans = 6 
			end	
			if imgui.Button(fa.ICON_BOLT .. u8" ���������", imgui.ImVec2(140, 0)) then  -- HelpSettings key
				check_ans = 7
			end	
			if imgui.Button(fa.ICON_HOME .. u8" ����", imgui.ImVec2(140, 0)) then  -- HelpHouses key
				check_ans = 8 
			end	
			if imgui.Button(fa.ICON_MALE .. u8" �����", imgui.ImVec2(140, 0)) then  -- HelpSkins key
				check_ans = 9 
			end	
			if imgui.Button(fa.ICON_BARCODE .. u8" ��������� ������", imgui.ImVec2(140, 0)) then  -- HelpDefault key
				check_ans = 10
			end	
			imgui.Separator()
			if imgui.Button(fa.ICON_BACKWARD .. u8" �����") then  
				report_ans = 0 
			end	
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##menuSelectable", imgui.ImVec2(390, 275), true)
			if check_ans == 0 then  
				imgui.Text(u8"�������������/����������� ������ ������ ���� \n�������� ������ ��������������")
			end	
			if check_ans == 1 then  
				for key, v in pairs(questions) do
					if key == "reporton" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							end
						end
					end
				end
			end	
			if check_ans == 2 then 
				for key, v in pairs(questions) do
					if key == "HelpCmd" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			if check_ans == 3 then  
				for key, v in pairs(questions) do
					if key == "HelpGangFamilyMafia" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			if check_ans == 4 then  
				for key, v in pairs(questions) do
					if key == "HelpTP" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			if check_ans == 6 then  
				for key, v in pairs(questions) do
					if key == "HelpSellBuy" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			if check_ans == 6 then
				for key, v in pairs(questions) do
					if key == "HelpMoneys" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
										local settext = '{FFFFFF}' .. v_2
										sampSendDialogResponse(2349, 1, 0)
										sampSendDialogResponse(2350, 1, 0)
										wait(200)
										sampSendDialogResponse(2351, 1, 0, settext)
										wait(200)
										sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end  
			end	
			if check_ans == 10 then  
				for key, v in pairs(questions) do
					if key == "HelpDefault" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			if check_ans == 9 then  
				for key, v in pairs(questions) do
					if key == "HelpSkins" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			if check_ans == 7 then  
				for key, v in pairs(questions) do
					if key == "HelpSettings" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			if check_ans == 8 then  
				for key, v in pairs(questions) do
					if key == "HelpHouses" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			if check_ans == 5 then  
				for key, v in pairs(questions) do
					if key == "HelpBuz" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2, btn_size) then
								if not rep.ggp.v then
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								else
									lua_thread.create(function()
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
							 end
						 end
					end
				end
			end	
			imgui.EndChild()
		end	
		if report_ans == 2 then  
			if #ATrep.bind_name > 0 then  
				for key_bind, name_bind in pairs(ATrep.bind_name) do  
					if imgui.Button(name_bind.. '##'..key_bind) then  
						play_bind_ans(key_bind)
					end	
				end	
			else 
				imgui.Text(u8"�����!")
				if imgui.Button(u8"�������!") then  
					imgui.OpenPopup(u8'������')	 
				end	
			end	
			if imgui.BeginPopupModal(u8'������', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
				imgui.Text(u8'�������� �����:'); imgui.SameLine()
				imgui.PushItemWidth(130)
				imgui.InputText("##rep.binder_name", rep.binder_name)
				imgui.PopItemWidth()
				imgui.PushItemWidth(100)
				imgui.Separator()
				imgui.Text(u8'����� �����:')
				imgui.PushItemWidth(300)
				imgui.InputTextMultiline("##rep.binder_text", rep.binder_text, imgui.ImVec2(-1, 110))
				imgui.PopItemWidth()
	
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
					rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if #rep.binder_name.v > 0 and #rep.binder_text.v > 0 then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
						if not EditOldBind then
							local refresh_text = rep.binder_text.v:gsub("\n", "~")
							table.insert(ATrep.bind_name, rep.binder_name.v)
							table.insert(ATrep.bind_text, refresh_text)
							table.insert(ATrep.bind_delay, rep.binder_delay.v)
							if save() then
								sampAddChatMessage(tag .. '����"' ..u8:decode(rep.binder_name.v).. '" ������� ������!', -1)
								rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
							end
								imgui.CloseCurrentPopup()
							else
								local refresh_text = rep.binder_text.v:gsub("\n", "~")
								table.insert(ATrep.bind_name, getpos, rep.binder_name.v)
								table.insert(ATrep.bind_text, getpos, refresh_text)
								table.insert(ATrep.bind_delay, getpos, rep.binder_delay.v)
								table.remove(ATrep.bind_name, getpos + 1)
								table.remove(ATrep.bind_text, getpos + 1)
								table.remove(ATrep.bind_delay, getpos + 1)
							if save() then
								sampAddChatMessage(tag .. '����"' ..u8:decode(rep.binder_name.v).. '" ������� ��������������!', -1)
								rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
							end
							EditOldBind = false
							imgui.CloseCurrentPopup()
						end
					end
	
				end
				imgui.EndChild()
				imgui.EndPopup()
			end
			imgui.Separator()
			if imgui.Button(fa.ICON_BACKWARD .. u8" �����") then  
				report_ans = 0 
			end	
		end	
        imgui.End()
    end

			-- if imgui.Button(u8'�������������� ����') then
			-- 	lua_thread.create(function()
			-- 		rep.binder.v = false
			-- 		rep.window_ans.v = true
			-- 		showCursor(true, true)
			-- 		checkCursor = true
			-- 		sampSetCursorMode(4)
			-- 		sampAddChatMessage(tag .. " ������� {69b2ff}SPACE{FFFFFF} ����� ��������� �������")
			-- 		while checkCursor do
			-- 			local cX, cY = getCursorPos()
			-- 			rep.posX, rep.posY = cX, cY
			-- 			if isKeyDown(32) then
			-- 				sampSetCursorMode(0)
			-- 				ATrep.main.posX, ATrep.main.posY = rep.posX, rep.posY
			-- 				checkCursor = false
			-- 				showCursor(false, false)
			-- 				rep.binder.v = true
			-- 				rep.window_ans.v = false
			-- 				if save() then sampAddChatMessage(tag .. "�������������� ���������!", -1) end
			-- 			end
			-- 			wait(0)
			-- 		end
			-- 	end)
			-- end
		

	-- if rep.window_ans.v then  

	-- 	imgui.SetNextWindowPos(imgui.ImVec2(rep.posX, rep.posY), imgui.Cond.Always)
	-- 	imgui.SetNextWindowSize(imgui.ImVec2(125, -1), imgui.Cond.Appearing)
	-- 	imgui.Begin(u8"##window_ans", rep.window_ans, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar)
	-- 	if #ATrep.bind_name > 0 then  
	-- 		for key_bind, name_bind in pairs(ATrep.bind_name) do  
	-- 			if imgui.Button(name_bind.. '##'..key_bind) then  
	-- 				play_bind(key_bind)
	-- 			end	
	-- 		end	
	-- 	else 
	-- 		imgui.Text(u8"�����!")
	-- 		if imgui.Button(u8"�������!") then  
	-- 			imgui.OpenPopup(u8'������')	 
	-- 		end	
	-- 	end	
	-- 	if imgui.BeginPopupModal(u8'������', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
	-- 		imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
	-- 		imgui.Text(u8'�������� �����:'); imgui.SameLine()
	-- 		imgui.PushItemWidth(130)
	-- 		imgui.InputText("##rep.binder_name", rep.binder_name)
	-- 		imgui.PopItemWidth()
	-- 		imgui.PushItemWidth(100)
	-- 		imgui.InputInt(u8("�������� ����� �������� � �������������"), rep.binder_delay)
	-- 		imgui.PopItemWidth()
	-- 		if rep.binder_delay.v <= 0 then
	-- 			rep.binder_delay.v = 1
	-- 		elseif rep.binder_delay.v >= 60001 then
	-- 			rep.binder_delay.v = 60000
	-- 		end
	-- 		imgui.Separator()
	-- 		imgui.Text(u8'����� �����:')
	-- 		imgui.PushItemWidth(300)
	-- 		imgui.InputTextMultiline("##rep.binder_text", rep.binder_text, imgui.ImVec2(-1, 110))
	-- 		imgui.PopItemWidth()

	-- 		imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
	-- 		if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
	-- 			rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
	-- 			imgui.CloseCurrentPopup()
	-- 		end
	-- 		imgui.SameLine()
	-- 		if #rep.binder_name.v > 0 and #rep.binder_text.v > 0 then
	-- 			imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
	-- 			if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
	-- 				if not EditOldBind then
	-- 					local refresh_text = rep.binder_text.v:gsub("\n", "~")
	-- 					table.insert(ATrep.bind_name, rep.binder_name.v)
	-- 					table.insert(ATrep.bind_text, refresh_text)
	-- 					table.insert(ATrep.bind_delay, rep.binder_delay.v)
	-- 					if save() then
	-- 						sampAddChatMessage(tag .. '����"' ..u8:decode(rep.binder_name.v).. '" ������� ������!', -1)
	-- 						rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
	-- 					end
	-- 						if rep.window_ans.v then
	-- 							lua_thread.create(function()
	-- 								rep.window_ans.v = false
	-- 								wait(0)
	-- 								rep.window_ans.v = true
	-- 							end)
	-- 						end
	-- 						imgui.CloseCurrentPopup()
	-- 					else
	-- 						local refresh_text = rep.binder_text.v:gsub("\n", "~")
	-- 						table.insert(ATrep.bind_name, getpos, rep.binder_name.v)
	-- 						table.insert(ATrep.bind_text, getpos, refresh_text)
	-- 						table.insert(ATrep.bind_delay, getpos, rep.binder_delay.v)
	-- 						table.remove(ATrep.bind_name, getpos + 1)
	-- 						table.remove(ATrep.bind_text, getpos + 1)
	-- 						table.remove(ATrep.bind_delay, getpos + 1)
	-- 					if save() then
	-- 						sampAddChatMessage(tag .. '����"' ..u8:decode(rep.binder_name.v).. '" ������� ��������������!', -1)
	-- 						rep.binder_name.v, rep.binder_text.v, rep.rep.binder_delay.v = '', '', 2500
	-- 					end
	-- 					EditOldBind = false
	-- 					imgui.CloseCurrentPopup()
	-- 				end
	-- 			end

	-- 		end
	-- 		imgui.EndChild()
	-- 		imgui.EndPopup()
	-- 	end
	-- 	imgui.End()
	-- end
end

function play_bind(num)
	lua_thread.create(function()
		if num ~= -1 then
			for bp in ATrep.bind_text[num]:gmatch('[^~]+') do
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/ans  " ..u8:decode(tostring(bp)))
				wait(200)
				wait(ATrep.bind_delay[num])
			end
			num = -1
		end
	end)
end

function play_bind_ans(num)
	lua_thread.create(function()
		if num ~= -1 then
			for bp in ATrep.bind_text[num]:gmatch('[^~]+') do
				-- sampSendDialogResponse(2349, 1, 0)
				-- sampSendDialogResponse(2350, 1, 0)
				-- wait(200)
				-- sampSendDialogResponse(2351, 1, 0, u8:decode(tostring(bp)))
				-- wait(200)
				-- sampCloseCurrentDialogWithButton(13)
				sampAddChatMessage(u8:decode(tostring(bp)), -1)
			end
			num = -1
		end
	end)
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

function closeAnsWithText(text)
	lua_thread.create(function()
	sampSendDialogResponse(2349, 1, 0)
	sampSendDialogResponse(2350, 1, 0)
	wait(200)
	sampSendDialogResponse(2351, 1, 0, text)
	wait(200)
	sampCloseCurrentDialogWithButton(13)
	rep.imgui.v = false
	imgui.Process = false
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

function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function EXPORTS.ActiveBinder()
	imgui.Text(u8"����� �� ������ ������� ����������� ������ \n� ����������������� � ���� � ���������� ������� �� �������!")
	imgui.Text(u8'��� ������� �� ������ "����������� ������", ���� ������ ��� � �����! \n�������� ����, ������� �������������! <3')
	imgui.Separator()
	imgui.Text(" ")
	imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 2)
	if imgui.Button(u8'�������') then
		imgui.OpenPopup(u8'������')
	end
	imgui.Text(" ")
	imgui.Separator()

	if #ATrep.bind_name > 0 then
		for key_bind, name_bind in pairs(ATrep.bind_name) do
		imgui.Button(name_bind..'##'..key_bind, imgui.ImVec2(270, 22))
		imgui.SameLine()
		if imgui.Button(u8'�������������##'..key_bind, imgui.ImVec2(100, 22)) then
			EditOldBind = true
			getpos = key_bind
			local returnwrapped = tostring(ATrep.bind_text[key_bind]):gsub('~', '\n')
			rep.binder_text.v = returnwrapped
			rep.binder_name.v = tostring(ATrep.bind_name[key_bind])
			rep.binder_delay.v = tostring(ATrep.bind_delay[key_bind])
			imgui.OpenPopup(u8'������')
		end
		imgui.SameLine()
		if imgui.Button(u8'�������##'..key_bind, imgui.ImVec2(60, 22)) then
			sampAddChatMessage(tag .. '���� "' ..u8:decode(ATrep.bind_name[key_bind])..'" ������!', -1)
			table.remove(ATrep.bind_name, key_bind)
			table.remove(ATrep.bind_text, key_bind)
			table.remove(ATrep.bind_delay, key_bind)
			save()
		end
	end
	else
		imgui.Text(u8('����� ���� ����� :('))
	end
	if imgui.BeginPopupModal(u8'������', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
		imgui.Text(u8'�������� �����:'); imgui.SameLine()
		imgui.PushItemWidth(130)
		imgui.InputText("##binder_name", rep.binder_name)
		imgui.PopItemWidth()
		imgui.PushItemWidth(100)
		imgui.Separator()
		imgui.Text(u8'����� �����:')
		imgui.PushItemWidth(300)
		imgui.InputTextMultiline("##rep.binder_text", rep.binder_text, imgui.ImVec2(-1, 110))
		imgui.PopItemWidth()

		imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
		if imgui.Button(u8'�������##bind1', imgui.ImVec2(100,30)) then
			rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if #rep.binder_name.v > 0 and #rep.binder_text.v > 0 then
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
			if imgui.Button(u8'���������##bind1', imgui.ImVec2(100,30)) then
				if not EditOldBind then
					local refresh_text = rep.binder_text.v:gsub("\n", "~")
					table.insert(ATrep.bind_name, rep.binder_name.v)
					table.insert(ATrep.bind_text, refresh_text)
					table.insert(ATrep.bind_delay, rep.binder_delay.v)
					if save() then
						sampAddChatMessage(tag .. '����"' ..u8:decode(rep.binder_name.v).. '" ������� ������!', -1)
						rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
					end
						imgui.CloseCurrentPopup()
					else
						local refresh_text = rep.binder_text.v:gsub("\n", "~")
						table.insert(ATrep.bind_name, getpos, rep.binder_name.v)
						table.insert(ATrep.bind_text, getpos, refresh_text)
						table.insert(ATrep.bind_delay, getpos, rep.binder_delay.v)
						table.remove(ATrep.bind_name, getpos + 1)
						table.remove(ATrep.bind_text, getpos + 1)
						table.remove(ATrep.bind_delay, getpos + 1)
					if save() then
						sampAddChatMessage(tag .. '����"' ..u8:decode(rep.binder_name.v).. '" ������� ��������������!', -1)
						rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
					end
					EditOldBind = false
					imgui.CloseCurrentPopup()
				end
			end

		end
		imgui.EndChild()
		imgui.EndPopup()
	end  
end			