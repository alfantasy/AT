require 'lib.moonloader'
local imgui = require 'imgui' -- ������� imgui ����
local encoding = require 'encoding' -- ���������� ��������
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
encoding.default = 'CP1251' -- ����� ��������� �� CP1251
u8 = encoding.UTF8 -- ������������ ������������� ������ ��������� UTF8 - u8
local directIni = "AdminTool\\reports.ini"
local lib_a	= import 'lib\\libsfor.lua'
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
		[u8"����� �����"] = "������ ����� ������� ����.",
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
		[u8"��������� ������/������"] = "�������� ���� ������/������",
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
        [u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 14 �����",
		[u8"��� �������� �������"] = "������� �����, ��� �� /help -> 18 �����"
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
		[u8"��� �������� ������"] = "/givemoney IDPlayer money",
		[u8"��� �������� ����"] = "/givescore IDPlayer score",
		[u8"��� �������� �����"] = "/giverub IDPlayer rub | � ������� VIP (/help -> 7)",
		[u8"��� �������� �����"] = "/givecoin IDPlayer coin | � ������� VIP (/help -> 7)",
        [u8"��� ���������� ������"] = "������ ���������� ����� ����� � /help -> 14 �����",
	},
	["HelpBuz"] = {
		[u8"���� ������"] = "������� /cpanel ", 
		[u8"������� ������"] = "/biz > ������� ������ �����������",
		[u8"���� ����������"] = "������� /biz ",
		[u8"���� �����"] = "������� /clubpanel ",
		[u8"���������� ���������"] = "������� /help -> 9",
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

	sampfuncsLog(tag .. "������, ���������� �� ������� ������� ���������.")

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
	sampRegisterChatCommand("ngm", cmd_ngm)

	sampRegisterChatCommand("senderre", function()
		sampAddChatMessage("ita idd: " .. reid_rep, -1)
	end)

    while true do
        wait(0)

        if isKeyDown(109) and sampIsDialogActive() then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. "��������� ������������������� �� ������� RDS!")
			wait(650)
		end
		-- ��������� ���� ������� �� NumPad - (/ans)

		if sampGetCurrentDialogEditboxText() == '/gvk' then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color() .. "https://vk.com/dmdriftgta")
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/cxtn' then  
			sampSetCurrentDialogEditboxText('{FFFFFF}/count time || /dmcount time' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.�' or sampGetCurrentDialogEditboxText() == '/w' then  
			sampSetCurrentDialogEditboxText(color())
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rfh' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/car' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rgf' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������� ����������, ��� ������ ����� �� /trade. ����� �������, /sell ����� �����')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/n.y' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> �/� -> ������ ' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ufy' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> ������ ' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/lnn' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/dt 0-990 / ����������� ��� ' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gtl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> �������� ' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/bcr' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� �� ���� �����. ����� ������������ �� /garage. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yp' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ���������. '  .. color() .. ' | �������� ��������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;lf' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}��. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;yt' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}���. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yr' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�����. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jna' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/familypanel ' .. color() .. ' | �������� ������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jn,' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> ������� ���� ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}��������. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rh,' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������, ������, ������. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/rvl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������, ��, ����������, ������, ����� ����� �� �����(/trade)' .. color() .. ' | �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/uv' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}GodMode (������) �� ������� �� ��������. ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/hku' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}���������� ���������. '  .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ydl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ������. ' .. color() .. ' | �������� �������������������� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/jaa' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ���������. ' .. color() .. ' | �������� ��������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ytp' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}�� �����.' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/,fu' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� - ��� ���. ' .. color() .. ' | �������� ������������������� ')
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
			sampSetCurrentDialogEditboxText('{FFFFFF}��� ����, ����� ������ ����, ����� ������ /capture | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��1' or sampGetCurrentDialogEditboxText() == '/dg1' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� � ����������� Premuim VIP (/help -> 7) | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��2' or sampGetCurrentDialogEditboxText() == '/dg2' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� � ����������� Diamond VIP (/help -> 7) | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��3' or sampGetCurrentDialogEditboxText() == '/dg3' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� � ����������� Platinum VIP (/help -> 7) | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��4' or sampGetCurrentDialogEditboxText() == '/dg4' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� � ����������� "������" VIP (/help -> 7) | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/gflv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������� �����, ��� �� /help -> 18 �����. | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/rjgs' then
			sampSetCurrentDialogEditboxText('{FFFFFF}265-267, 280-286, 288, 300-304, 306, 307, 309-311 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/,fk' then
			sampSetCurrentDialogEditboxText('{FFFFFF}102-104| ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/uhed' then
			sampSetCurrentDialogEditboxText('{FFFFFF}105-107 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/heva' then
			sampSetCurrentDialogEditboxText('{FFFFFF}111-113 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/dfh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}114-116 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.�����' or sampGetCurrentDialogEditboxText() == '/nhbfl' then
			sampSetCurrentDialogEditboxText('{FFFFFF}117-188, 120 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/dfu' then
			sampSetCurrentDialogEditboxText('{FFFFFF}108-110 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/va' then
			sampSetCurrentDialogEditboxText('{FFFFFF}124-127 | ' .. color() .. ' �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/cgh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/mm -> �������� -> ������� ������ | ' .. color() .. '  �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/vcg' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/mm -> ������������ �������� -> ��� ����������| ' .. color() .. '  �������� ����! ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/ebl' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�������� ID ����������/������ � /report ' .. color() .. ' | �������� �������������������. ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/cng' then
			sampSetCurrentDialogEditboxText('{FFFFFF}����� ���������� �����, �����, ����� � �.�. - /statpl ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}��� �������� �����, ��������� ������ /givemoney IDPlayer ����� | ' .. color() .. ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udc' then
			sampSetCurrentDialogEditboxText('{FFFFFF}��� �������� �����, ���������� ������ /givescore IDPlayer ����� |' .. color() .. ' � Diamond VIP.')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/gv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/sellmycar IDPlayer ����(1-3) RDScoin (������), � ���: /car | ' .. color() .. ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/de,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}����� ������ ������� ��������� �����, ���� �������: /gvig ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/px' then
			sampSetCurrentDialogEditboxText('{FFFFFF}���� �� ��������, ������� /spawn | /kill, ' .. color() .. ' �� �� ����� ��� ������! ')
		end

		if sampGetCurrentDialogEditboxText() == '/prk' or sampGetCurrentDialogEditboxText() == '.���' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/parkour - ��������� �� ������ | '  .. color() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '/drb' or sampGetCurrentDialogEditboxText() == '.���' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/derby - ��������� �� ����� | '  .. color() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gcd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/passive ' .. color() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/bya' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� ����� ������ � ���������. '  .. color() ..  ' �������� ����!')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/ju' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ �� ����� "���������� �����", ����� ����� ����� �������� �� ALT � ����� �� ������� ������ �� �����' .. color() ..  ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/j;' then
			sampSetCurrentDialogEditboxText('{FFFFFF}��������. '  .. color() ..  ' ��������� ������������������� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.����' or sampGetCurrentDialogEditboxText() == '/wdtn' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}https://colorscheme.ru/html-colors.html ' .. color() .. ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/;,f' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ������ �� �������������� �� ����� https://forumrds.ru')
		end

		if sampGetCurrentDialogEditboxText() == '.���'or sampGetCurrentDialogEditboxText() == '/;,b'  then
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ������ �������� ������ �� ������ �� ����� https://forumrds.ru')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yx' then
				sampSetCurrentDialogEditboxText('{FFFFFF}�����(�) ������ �� ����� ������! ' .. color() .. ' �������� ���� �� ������� RDS. <3 ')
				wait(2000)
				if tonumber(id_punish) ~= nil then 
					sampSendChat("/re " .. id_punish)
				else 	
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/re " )
				end	
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/bx' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� ����. ' .. color() .. ' �������� ���� �� ������� RDS. <3 ')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.��' then
				sampSetCurrentDialogEditboxText('{FFFFFF}����� �� ������ �������, ��������. :3 ')
				wait(2000)
				if tonumber(id_punish) ~= nil then 
					sampSendChat("/re " .. id_punish)
				else 	
					sampSetChatInputEnabled(true)
					sampSetChatInputText("/re " )
				end	
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.�7' or sampGetCurrentDialogEditboxText() == '/g7' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� ����� ����� � /help -> 7 �����. | '  .. color() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.�13' or sampGetCurrentDialogEditboxText() == '/g13' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� ����� ����� � /help -> 14 �����. | '  .. color() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.�8' or sampGetCurrentDialogEditboxText() == '/g8' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ���������� ����� ����� � /help -> 8 �����. | '  .. color() ..  ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/yfr' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� �������. | '  .. color() ..  '  �������� ���� �� RDS! <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yy' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�� ���� ��������� �� ������. | ' .. color() .. ' �������� ���� �� RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/yd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������ ����� �� � ����. | ' .. color() .. ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/,r' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�������� ������/��� ����� � ������� /bank ��� /tp -> ������ -> ���� ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/nfc' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/tp -> ������ -> ���������� |' .. color() .. '  �������� ���� �� RDS. <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/nfv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/tp -> ������ -> ���������� -> �������������� | ' .. color() .. ' �������� ���� �� RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gua' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/gleave (�����) || /fleave (�����)| ' .. color() .. ' �������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gkv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/leave (�������� �����)| ' .. color() .. ' �������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/en' then
			sampSetCurrentDialogEditboxText('{FFFFFF}�������� ���� ������/������. ' .. color() .. ' ������� ���� <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/gu,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/ginvite (�����) || /finvite (�����) | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/eu,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/guninvite (�����) || /funinvite (�����) | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/giverub IDPlayer rub | � ������� (/help -> 7) | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/udr' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/givecoin IDPlayer coin | � ������� (/help -> 7) | ' .. color() .. ' ������� ���� �� RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.��' or sampGetCurrentDialogEditboxText() == '/gd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}������� ���. | ' .. color() .. ' ������� ���� �� RDS <3')
		end

        if sampGetCurrentDialogEditboxText() == '.���' or sampGetCurrentDialogEditboxText() == '/fgh' then 
            sampSendDialogResponse(2351, 1, 0, '{FFFFFF}������� ��� ������! ' .. color() .. '������� ����!')
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

function color() -- �������, ����������� ������������� � ����� ���������� ����� � ������� ������������ os.time()
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
function cmd_ngm(arg)
	sampSendChat("/ans " .. arg .. " ������ ����� ������� ����. // �������� ���� �� RDS <3")
end

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
	sampSendChat("/ans " .. arg .. " ������ ������ ���������� ����� � /help -> 14 �����. | �������� ���� �� RDS. <3 ")
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
	sampSendChat("/ans " .. arg .. " �������� ���� ������/������. | �������� ���� �� RDS <3")
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
	sampSendChat("/ans " .. arg .. " ������� �����, ��� �� /help -> 18 �����. | �������� ���� �� RDS. <3")
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
			if pid_rep == nil then  
				pid_rep = "None"
			end
			rep_text = u8:encode(text_rep)
			id_punish = rep_text:match("(%d+)")
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
		imgui.SwitchContext()
        lib_a.black()
    elseif tonumber(ATcfg2.setting.styleImgui) == 1 then
		imgui.SwitchContext()
        lib_a.grey_black()
	elseif tonumber(ATcfg2.setting.styleImgui) == 2 then
		imgui.SwitchContext()
		lib_a.white()
    elseif tonumber(ATcfg2.setting.styleImgui) == 3 then
		imgui.SwitchContext()
        lib_a.skyblue()
    elseif tonumber(ATcfg2.setting.styleImgui) == 4 then
		imgui.SwitchContext()
        lib_a.blue()
    elseif tonumber(ATcfg2.setting.styleImgui) == 5 then
		imgui.SwitchContext()
        lib_a.blackblue()
    elseif tonumber(ATcfg2.setting.styleImgui) == 6 then
		imgui.SwitchContext()
        lib_a.red()
	elseif tonumber(ATcfg2.setting.styleImgui) == 7 then 
		imgui.SwitchContext()
		lib_a.blackred()
	elseif tonumber(ATcfg2.setting.styleImgui) == 8 then 
		imgui.SwitchContext()
		lib_a.brown()
	elseif tonumber(ATcfg2.setting.styleImgui) == 9 then 
		imgui.SwitchContext()
		lib_a.violet()
	elseif tonumber(ATcfg2.setting.styleImgui) == 10 then  
		imgui.SwitchContext()
		lib_a.purple2()
	elseif tonumber(ATcfg2.setting.styleImgui) == 11 then  
		imgui.SwitchContext()
		lib_a.salat()
	elseif tonumber(ATcfg2.setting.styleImgui) == 12 then  
		imgui.SwitchContext()
		lib_a.yellow_green()
	elseif tonumber(ATcfg2.setting.styleImgui) == 13 then  
		imgui.SwitchContext()
		lib_a.banana()
	elseif tonumber(ATcfg2.setting.styleImgui) == 14 then  
		imgui.SwitchContext()
		lib_a.royalblue()
	end

    if rep.imgui.v then 

        imgui.SetNextWindowPos(imgui.ImVec2((sw2 / 2) - 500 , (sh2 / 2) + 40), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(380, 230), imgui.Cond.FirstUseEver)
        imgui.Begin(u8"������ �� �������", rep.imgui, imgui.WindowFlags.NoResize)
        local btn_size = imgui.ImVec2(-0.1, 0)

		if report_ans == 0 then  
			if (nick_rep or pid_rep or rep_text) and sampGetCurrentDialogId() == 2349 then  
				imgui.Text(u8"������ ��: " .. nick_rep .. "[" .. pid_rep .. "]")
				imgui.Separator()
			 	imgui.Text(u8(u8:decode(rep_text)))
				imgui.Separator()
			elseif (nick_rep == nil or pid_rep == nil or rep_text == nil or text_rep == nil) then
			 	imgui.Text(u8"������ �� ����������.")
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
			imgui.SameLine() 
			if imgui.Button(fa.ICON_FA_TEXT_HEIGHT .. ("##SendColor")) then  
				rep.text.v = color()
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"������ ��������� ���� ����� �������.")
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
			imgui.Separator()
			if imgui.Button(fa.ICON_FA_EYE .. u8" ������ �� ��") then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					sampSendDialogResponse(2350, 1, 0)
					wait(200)
					sampSendDialogResponse(2351, 1, 0, '{FFFFFF}�����(�) ������ �� ����� ������! ' .. color() .. ' // �������� ���� �� ������� RDS <3')
					wait(200)
					sampCloseCurrentDialogWithButton(13)
					if tonumber(id_punish) ~= nil then 
						sampSendChat("/re " .. id_punish)
					else 	
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/re " )
					end	
					rep.imgui.v = false  
					imgui.ShowCursor = false
				end)
			end	
			imgui.SameLine()
			if imgui.Button(fa.ICON_REDDIT_ALIEN .. u8" �����") then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					sampSendDialogResponse(2350, 1, 0)
					wait(200)
					sampSendDialogResponse(2351, 1, 0, '{FFFFFF}����� �� ������ �������! ' .. color() .. ' // �������� ���� �� ������� RDS <3')
					wait(200)
					sampCloseCurrentDialogWithButton(13)
					if tonumber(id_punish) ~= nil then 
						sampSendChat("/re " .. id_punish)
					else 	
						sampSetChatInputEnabled(true)
						sampSetChatInputText("/re " )
					end	
					rep.imgui.v = false  
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()		
			if imgui.Button(fa.ICON_BAN .. u8" �������") then
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					sampSendDialogResponse(2350, 1, 0)
					wait(200)
					sampSendDialogResponse(2351, 1, 0, '{FFFFFF}������ ����� �������! ' .. color() .. ' // �������� ���� �� ������� RDS <3')
					wait(200)
					sampCloseCurrentDialogWithButton(13)
					rep.imgui.v = false  
					imgui.ShowCursor = false
				end)
			end
			imgui.SameLine()
			if imgui.Button(fa.ICON_COMMENTING_O .. u8" �������� ID") then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					sampSendDialogResponse(2350, 1, 0)
					wait(200)
					sampSendDialogResponse(2351, 1, 0, '{FFFFFF}�������� ID ����������/������ � /report ' .. color() .. ' // �������� ���� �� ������� RDS <3')
					wait(200)
					sampCloseCurrentDialogWithButton(13)
					rep.imgui.v = false  
					imgui.ShowCursor = false
				end)
			end	
			if imgui.Button(fa.ICON_FA_EDIT .. u8" �������� ��") then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					sampSendDialogResponse(2350, 1, 0)
					wait(200)
					sampSendDialogResponse(2351, 1, 0, '{FFFFFF}�������� ���� ������/������ ' .. color() .. ' // �������� ���� �� ������� RDS <3')
					wait(200)
					sampCloseCurrentDialogWithButton(13)
					rep.imgui.v = false  
					imgui.ShowCursor = false
				end)
			end	
			imgui.SameLine()
			if imgui.Button(fa.ICON_CHECK .. u8" �������� ������ ##SEND") then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					sampSendDialogResponse(2350, 1, 0)
					wait(200)
					sampSendDialogResponse(2351, 1, 0, '{FFFFFF}������� ��� ������! ' .. color() .. '������� ����!')
					wait(200)
					sampCloseCurrentDialogWithButton(13)
					wait(200)
					sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "] | " .. text_rep)
				end)	
			end
			if imgui.Button(fa.ICON_QUESTION_CIRCLE .. u8" ������ �� AT") then  
				report_ans = 1
			end	
			imgui.SameLine()
			if imgui.Button(fa.ICON_FA_SAVE .. u8" ����������� ������") then  
				report_ans = 2
			end	
			imgui.Separator()
			if imgui.Checkbox(u8"��������� � ������", rep.ggp) then 
				ATrep.main.good_game_prefix = rep.ggp.v 
				save() 
			end
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'������������� ��� ������ ����� �������� ����� ������ �������� ����!')	
			imgui.SetCursorPosY(imgui.GetWindowWidth() - 178)
			imgui.Separator()
			imgui.SetCursorPosY(imgui.GetWindowWidth() - 173)
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
						rep.text.v = " "
						rep.imgui.v = false
					end)
				else 
					lua_thread.create(function()
						sampSendDialogResponse(2349, 1, 0)
						sampSendDialogResponse(2350, 1, 0)
						wait(200)
						local settext2 = '{FFFFFF}' .. rep.text.v 
						sampSendDialogResponse(2351, 1, 0, u8:decode(settext2) .. color() .. ' // �������� ���� �� ������� RDS <3')	
						wait(200)
						sampCloseCurrentDialogWithButton(13)
						rep.text.v = " "
						rep.imgui.v = false
					end)
				end	
			end	
			imgui.SameLine()
			imgui.SetCursorPosX(imgui.GetWindowWidth() - 80)
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
			if imgui.Button(fa.ICON_OBJECT_GROUP .. u8" �� ����-��/���-��", imgui.ImVec2(135, 0)) then  -- reporton key
				check_ans = 1  
			end	
			if imgui.Button(fa.ICON_LIST .. u8" ������� (/help)", imgui.ImVec2(135, 0)) then  -- HelpCMD key
				check_ans = 2 
			end 	
			if imgui.Button(fa.ICON_USERS .. u8" �����/�����", imgui.ImVec2(135, 0)) then  -- HelpGangFamilyMafia key
				check_ans = 3
			end	
			if imgui.Button(fa.ICON_MAP_MARKER .. u8" ���������", imgui.ImVec2(135, 0)) then  -- HelpTP key
				check_ans = 4
			end	
			if imgui.Button(fa.ICON_SHOPPING_BAG .. u8" �������", imgui.ImVec2(135, 0)) then  -- HelpBuz key
				check_ans = 5 
			end	
			if imgui.Button(fa.ICON_MONEY .. u8" �������/�������", imgui.ImVec2(135, 0)) then  -- HelpSellBuy key
				check_ans = 6 
			end	
			if imgui.Button(fa.ICON_BOLT .. u8" ���������", imgui.ImVec2(135, 0)) then  -- HelpSettings key
				check_ans = 7
			end	
			if imgui.Button(fa.ICON_HOME .. u8" ����", imgui.ImVec2(135, 0)) then  -- HelpHouses key
				check_ans = 8 
			end	
			if imgui.Button(fa.ICON_MALE .. u8" �����", imgui.ImVec2(135, 0)) then  -- HelpSkins key
				check_ans = 9 
			end	
			if imgui.Button(fa.ICON_BARCODE .. u8" ��������� ������", imgui.ImVec2(135, 0)) then  -- HelpDefault key
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
				imgui.Text(u8"�������������/����������� ������ \n������ ���� �������� \n������ ��������������")
			end	
			if check_ans == 1 then  
				for key, v in pairs(questions) do
					if key == "reporton" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if check_ans == 2 then 
				for key, v in pairs(questions) do
					if key == "HelpCmd" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if check_ans == 3 then  
				for key, v in pairs(questions) do
					if key == "HelpGangFamilyMafia" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if check_ans == 4 then  
				for key, v in pairs(questions) do
					if key == "HelpTP" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if check_ans == 6 then  
				for key, v in pairs(questions) do
					if key == "HelpSellBuy" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if check_ans == 10 then  
				for key, v in pairs(questions) do
					if key == "HelpDefault" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if check_ans == 9 then  
				for key, v in pairs(questions) do
					if key == "HelpSkins" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							 end
						 end
					end
				end
			end	
			if check_ans == 7 then  
				for key, v in pairs(questions) do
					if key == "HelpSettings" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if check_ans == 8 then  
				for key, v in pairs(questions) do
					if key == "HelpHouses" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
							end
						end
					end
				end
			end	
			if check_ans == 5 then  
				for key, v in pairs(questions) do
					if key == "HelpBuz" then
						for key_2, v_2 in pairs(questions[key]) do
							if imgui.Button(key_2) then
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color() .. ' // �������� ���� �� ������� RDS <3'
									sampSendDialogResponse(2349, 1, 0)
									sampSendDialogResponse(2350, 1, 0)
									wait(200)
									sampSendDialogResponse(2351, 1, 0, settext)
									wait(200)
									sampCloseCurrentDialogWithButton(13)
									end)
								end
								report_ans = 0
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
				sampSendDialogResponse(2349, 1, 0)
				sampSendDialogResponse(2350, 1, 0)
				wait(200)
				sampSendDialogResponse(2351, 1, 0, u8:decode(tostring(bp)))
				wait(200)
				sampCloseCurrentDialogWithButton(13)
				-- sampAddChatMessage(u8:decode(tostring(bp)), -1)
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

function EXPORTS.OffScript()
	imgui.ShowCursor = false
	imgui.Process = false
	thisScript():unload()
end