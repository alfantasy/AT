require 'lib.moonloader'
local vkeys = require "vkeys" -- регистр для кнопок
local imgui = require 'imgui' -- регистр imgui окон
local encoding = require 'encoding' -- дешифровка форматов
local inicfg = require 'inicfg'
local sampev = require 'lib.samp.events'
encoding.default = 'CP1251' -- смена кодировки на CP1251
u8 = encoding.UTF8 -- переименовка стандтартного режима кодировки UTF8 - u8
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
        [u8"Начало работы по жалобе"] = "Начал(а) работу по вашей жалобе!",
		[u8"Иду помогать"] = "Уважаемый игрок, сейчас помогу вам!",
		[u8"Нет такой инфы у админов"] = "Данную информацию узнавайте в интернете.",
		[u8"Жалоба на админа"] = "Пишите жалобу на администратора на форум https://forumrds.ru",
		[u8"Жалоба на игрока"] = "Вы можете оставить жалобу на игрока на форум https://forumrds.ru",
        [u8"Жалоба на что-либо"] = "Вы можете оставить жалобу на форум https://forumrds.ru",
		[u8"Помогли вам"] = "Помогли вам",
		[u8"Ожидайте"] = "Ожидайте",
		[u8"Приятного времяпрепровождения"] = "Приятного времяпрепровождения на Russian Drift Server!",
		[u8"Игрок ничего не сделал"] = "Не вижу нарушений со стороны игрока",
		[u8"Игрок чист"] = " Данный игрок чист",
		[u8"Игрок не в сети"] = "Данный игрок не в сети",
		[u8"Уточнение вопрос/репорт"] = "Уточните ваш вопрос/репорт",
		[u8"Уточнение ID"] = "Уточните ID нарушителя/читера в /report",
		[u8"Игрок наказан"] = "Данный игрок наказан",
		[u8"Проверим"] = "Проверим",
		[u8"ГМ не работает"] = "GodMode (ГодМод) на сервере не работает",
		[u8"Нет набора"] = "В данный момент набор в администрацию не проходит.",
		[u8"Сейчас сниму наказание"] = "Сейчас сниму вам наказание.",
		[u8"Баг будет исправлен"] = "Данный баг скоро будет исправлен.",
		[u8"Ошибка будет исправлена"] = "Данный ошибка скоро будет исправлена.",
		[u8"Приветствие"] = "Добрый день, уважаемый игрок.",
        [u8"Разрешено"] = "Разрешено",
		[u8"Никак"] = "Никак",
		[u8"Да"] = "Да",
		[u8"Нет"] = "Нет",
		[u8"Не запрещено"] = "Не запрещено",
		[u8"Не знаем"] = "Не знаем",
		[u8"Нельзя оффтопить"] = "Не оффтопьте",
		[u8"Не выдаем"] = "Не выдаем",
		[u8"Это баг"] = "Скорей всего - это баг",
		[u8"Перезайдите"] = "Попробуйте перезайти"

    },
	["HelpHouses"] = {
		[u8"Как добавить игрока в аренду"] = "/hpanel -> Слот1-3 -> Изменить -> Аренда дома -> Подселить соседа",
		[u8"А домик как продать"] = "/hpanel -> Слот1-3 -> Изменить -> Продать дом государству || /sellmyhouse (игроку)",
		[u8"Как купить дом"] = "Встаньте на пикап (зеленый, не красный) и нажмите F.",
        [u8"Как открыть меню дома"] = "/hpanel"
	},
	["HelpCmd"] = {
		[u8"Команды VIP`а"] = "Данную информацию можно найти в /help -> 7 пункт",
        [u8"Информация в инете"] = "Данную информацию можно узнать в интернете",
		[u8"Привелегия Premuim"] = "Данный игрок с привелегией Premuim VIP (/help -> 7)",
		[u8"Привелегия Diamond"] = "Данный игрок с привелегией Diamond VIP (/help -> 7) ",
		[u8"Привелегия Platinum"] = "Данный игрок с привелегией Platinum VIP (/help -> 7)",
		[u8"Привелегия Личный"] = "Данный игрок с привелегией «Личный» VIP (/help -> 7)",
		[u8"Команды для свадьбы"] = "Данную информацию можно найти в /help -> 8 пункт",
        [u8"Как заработать валюту"] = "Данную информацию можно найти в /help -> 13 пункт",
		[u8"Как получать админку"] = "Ожидать набор, или же /help -> 17 пункт"
	},
	["HelpGangFamilyMafia"] = {
		[u8"Как открыть меню банды"] = "/menu (/mm) - ALT/Y -> Система банд",
		[u8"Как открыть меню семьи"] = "/fpanel ",
		[u8"Как исключить игрока"] = "/guninvite (банда) || /funinvite (семья)",
		[u8"Как пригласить игрока"] = "/ginvite (банда) || /finvite (семья)",
		[u8"Как покинуть банду/семью"] = "/gleave (банда) || /fleave (семья)",
        [u8"Как выдать ранг"] = "/grank IDPlayer Ранг",
		[u8"Как покинуть мафию"] = "/leave",
		[u8"Как выдать выговор"] = "/gvig // Должна быть лидерка",
	},
	["HelpTP"] = {
		[u8"Как тп в автосалон"] = "tp -> Разное -> Автосалоны",
		[u8"Как тп в автомастерскую"] = "/tp -> Разное -> Автосалоны -> Автомастерская",
		[u8"Как тп в банк"] = "/bank || /tp -> Разное -> Банк",
		[u8"Как ваще тп"] = "/tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт)",
        [u8"Как тп на работы"] = "/tp -> Работы"
	},
	["HelpSellBuy"] = {
		[u8"Как продать аксы"] = "Продать аксессуары или купить можно на /trade. Чтобы продать, нажмите F около лавки",
		[u8"Как обменять валюту"] = "Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа",
		[u8"А как продать тачку"] = "/sellmycar IDPlayer Слот1-5 Сумма || /car -> Слот1-5 -> Продать государству",
        [u8"А как продать бизнес"] = "/biz > Продать бизнес государству",
	},
	["HelpMoneys"] = {
		[u8"Как передать деньги"] = "/givemoney IDPlayer money",
		[u8"Как передать очки"] = "/givescore IDPlayer score",
		[u8"Как передать рубли"] = "/giverub IDPlayer rub | С Личного VIP (/help -> 7)",
		[u8"Как передать коины"] = "/givecoin IDPlayer coin | С Личного VIP (/help -> 7)",
        [u8"Как заработать валюту"] = "Данную информацию можно найти в /help -> 13 пункт",
	},
	["HelpBuz"] = {
		[u8"Меню казино"] = "Введите /cpanel ", 
		[u8"Продать бизнес"] = "/biz > Продать бизнес государству",
		[u8"Меню бизнесмена"] = "Введите /biz ",
		[u8"Меню клуба"] = "Введите /clubpanel ",
	},
	["HelpDefault"] = {
		[u8"IP RDS 01"] = "46.174.52.246:7777",
		[u8"IP RDS 02"] = "46.174.55.87:7777",
		[u8"IP RDS 03"] = "46.174.49.170:7777",
		[u8"IP RDS 04"] = "46.174.55.169:7777",
		[u8"IP RDS 05"] = "62.122.213.75:7777",
		[u8"Сайт с цветами HTML"] = "https://colorscheme.ru/html-colors.html",
		[u8"Сайт с цветами HTML 2"] = "https://htmlcolorcodes.com",
		[u8"Как поставить цвет"] = "Цвет в коде HTML {RRGGBB}. Зеленый - 008000. Берем {} и ставим цвет перед словом {008000}Зеленый",
		[u8"Ссылка на офф.группу"] = "https://vk.com/dmdriftgta | Группа проекта",
        [u8"Ссылка на форум"] = "https://forumrds.ru | Форум проекта",
        [u8"Как оплатить дом/бизнес"] = "Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк",
		[u8"Где взять купленную машину"] = "Используйте команду /car",
		[u8"Как ограбить банк"] = 'Встать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте',
		[u8"Как детальки искать"] = "Детали разбросаны по всей карте. Обмен происходится на /garage",
		[u8"Как начать капт"] = "Для того, чтобы начать капт, нужно ввести /capture",
		[u8"Как пассив вкл/выкл"] = "/passive ",
		[u8"/statpl"] = "Чтобы посмотреть детали, очки, коины, рубли, вирты - /statpl",
		[u8"Смена пароля"] = "/mm -> Действия -> Сменить пароль",
		[u8"Спавн тачки"] = "/mm -> Транспортное средство -> Тип транспорта",
        [u8"Как взять оружие"] = "/menu (/mm) - ALT/Y -> Оружие",
		[u8"Как взять предметы"] = "/menu (/mm) - ALT/Y -> Предметы",
        [u8"Как открыть меню"] = "/mm (/mn) || Alt/Y",
		[u8"Как тюнить тачку"] = "/menu (/mm) - ALT/Y -> Т/С -> Тюнинг",
		[u8"Если игрок застрял"] = "/kill | /tp | /spawn",
		[u8"Как попасть на дерби/пабг"] = "/join | Есть внутриигровые команды, следите за чатом",
		[u8"Виртуальный мир"] = "/dt 0-990 / Виртуальный мир",
        [u8"Прогресс миссий/квестов"] = "/quests | /dquest | /bquest",
		[u8"Спросите у игроков"] = "Спросите у игроков."
	},
	["HelpSkins"] = {
		[u8"Сайт со скинами"] = " https://gtaxmods.com/skins-id.html.",
		[u8"Копы"] = "65-267, 280-286, 288, 300-304, 306, 307, 309-311",
		[u8"Балласы"] = "102-104",
		[u8"Грув"] = "105-107",
		[u8"Триад"] = "117-118, 120",
		[u8"Вагосы"] = "108-110",
		[u8"Ру.Мафия"] = "111-113",
		[u8"Вариосы"] = "114-116",
		[u8"Мафия"] = "124-127"
	},
	["HelpSettings"] = {
		[u8"Входы/Выходы игроков"] = "/menu (ALT/Y) -> Настройки -> 1 пункт.",
		[u8"Разрешение вызывать на дуель"] = "/menu (ALT/Y) -> Настройки -> 2 пункт.",
		[u8"On/Off Личные сообщения"] = "/menu (ALT/Y) -> Настройки -> 3 пункт.",
		[u8"Запросы на телепорт"] = "/menu (ALT/Y) -> Настройки -> 4 пункт.",
		[u8"Разрешение показывать DM Stats"] = "/menu (ALT/Y) -> Настройки -> 5 пункт.",
		[u8"Эффект при телепортации"] = "/menu (ALT/Y) -> Настройки -> 6 пункт.",
		[u8"Показывать спидометр"] = "/menu (ALT/Y) -> Настройки -> 7 пункт.",
		[u8"Показывать Drift Lvl"] = "/menu (ALT/Y) -> Настройки -> 8 пункт.",
		[u8"Спавн в доме/доме семью"] = "/menu (ALT/Y) -> Настройки -> 9 пункт.",
		[u8"Вызов главного меню"] = "/menu (ALT/Y) -> Настройки -> 10 пункт.",
		[u8"On/Off приглашение в банду"] = "/menu (ALT/Y) -> Настройки -> 11 пункт.",
		[u8"Выбор ТС на TextDraw"] = "/menu (ALT/Y) -> Настройки -> 12 пункт.",
		[u8"On/Off кейс"] = "/menu -> Настройки (ALT/Y) -> 13 пункт.",
		[u8"On/Off FPS показатель"] = "/menu (ALT/Y) -> Настройки -> 15 пункт.",
		[u8"On/Off Уведомления"] = "/menu (ALT/Y) -> Настройки -> 16 пункт",
		[u8"On/Off Уведы.акции"] = "/menu (ALT/Y) -> Настройки -> 17 пункт",
		[u8"On/Off Авто.Автор"] = "/menu (ALT/Y) -> Настройки -> 18 пункт",
		[u8"On/Off Фон.музыка при входе"] = "/menu (ALT/Y) -> Настройки -> 19 пункт",
		[u8"Кнопка гс.чата"] = "/menu (ALT/Y) -> Настройки -> 20 пункт",
	}
}

local tag = "{00BFFF} [AT] " -- локальная переменная, которая регистрирует тэг AT

function main()
    while not isSampAvailable() do wait(0) end

	sampAddChatMessage(tag .. " Инициализация плагина, отвечающего за репорты.")

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
			sampSetCurrentDialogEditboxText(string .. color1() .. "Приятного времяпрепровождения на сервере RDS!")
			wait(650)
		end
		-- введенный ключ клавиши по NumPad - (/ans)

		if sampGetCurrentDialogEditboxText() == '/gvk' then 
			local string = string.sub(sampGetCurrentDialogEditboxText(), 0, string.len(sampGetCurrentDialogEditboxText()) - 1)
			sampSetCurrentDialogEditboxText(string .. color1() .. "https://vk.com/dmdriftgta")
		end

		if sampGetCurrentDialogEditboxText() == '.счет' or sampGetCurrentDialogEditboxText() == '/cxtn' then  
			sampSetCurrentDialogEditboxText('{FFFFFF}/count time || /dmcount time' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.ц' or sampGetCurrentDialogEditboxText() == '/w' then  
			sampSetCurrentDialogEditboxText(color1())
		end

		if sampGetCurrentDialogEditboxText() == '.кар' or sampGetCurrentDialogEditboxText() == '/rfh' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/car' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.кпа' or sampGetCurrentDialogEditboxText() == '/rgf' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Продать аксессуары, или купить можно на /trade. Чтобы продать, /sell около лавки')
		end

		if sampGetCurrentDialogEditboxText() == '.тюн' or sampGetCurrentDialogEditboxText() == '/n.y' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> Т/С -> Тюнинг ' .. color1() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.ган' or sampGetCurrentDialogEditboxText() == '/ufy' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> Оружие ' .. color1() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.дтт' or sampGetCurrentDialogEditboxText() == '/lnn' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/dt 0-990 / Виртуальный мир ' .. color1() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.пед' or sampGetCurrentDialogEditboxText() == '/gtl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> Предметы ' .. color1() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.иск' or sampGetCurrentDialogEditboxText() == '/bcr' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Детали разбросаны по всей карте. Обмен происходится на /garage. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нз' or sampGetCurrentDialogEditboxText() == '/yp' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Не запрещено. '  .. color1() .. ' | Удачного времяпрепровожодения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.жда' or sampGetCurrentDialogEditboxText() == '/;lf' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Да. ' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.жне' or sampGetCurrentDialogEditboxText() == '/;yt' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Нет. ' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нк' or sampGetCurrentDialogEditboxText() == '/yr' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Никак. ' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.отф' or sampGetCurrentDialogEditboxText() == '/jna' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/familypanel ' .. color1() .. ' | Удачного времяпрепровождения ')
		end

		if sampGetCurrentDialogEditboxText() == '.отб' or sampGetCurrentDialogEditboxText() == '/jn,' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/menu (/mm) - ALT/Y -> Система банд ' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.пр' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Проверим. ' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.крб' or sampGetCurrentDialogEditboxText() == '/rh,' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Казино, работы, бизнес. ' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.кмд' or sampGetCurrentDialogEditboxText() == '/rvl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Казино, МП, достижения, работы, обмен очков на коины(/trade)' .. color1() .. ' | Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.гм' or sampGetCurrentDialogEditboxText() == '/uv' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}GodMode (ГодМод) на сервере не работает. ' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.рлг' or sampGetCurrentDialogEditboxText() == '/hku' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Попробуйте перезайти. '  .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нвд' or sampGetCurrentDialogEditboxText() == '/ydl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Не выдаем. ' .. color1() .. ' | Удачного времяпрепровожодения ')
		end

		if sampGetCurrentDialogEditboxText() == '.офф' or sampGetCurrentDialogEditboxText() == '/jaa' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Не оффтопьте. ' .. color1() .. ' | Удачного времяпрепровожодения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.нез' or sampGetCurrentDialogEditboxText() == '/ytp' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Не знаем.' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.баг' or sampGetCurrentDialogEditboxText() == '/,fu' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}Скорей всего - это баг. ' .. color1() .. ' | Удачного времяпрепровождения ')
		end

		if sampGetCurrentDialogEditboxText() == '/smh' or sampGetCurrentDialogEditboxText() == '.ыьр' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/sellmyhouse (игроку)  ||  /hpanel -> слот -> Изменить -> Продать дом государству')
		end

		if sampGetCurrentDialogEditboxText() == '.дчд' or sampGetCurrentDialogEditboxText() == '/lxl' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}/hpanel -> Слот1-3 -> Изменить -> Аренда дома | Приятной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.обм' or sampGetCurrentDialogEditboxText() == '/j,v' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа') 
		end

		if sampGetCurrentDialogEditboxText() == '.ктп' or sampGetCurrentDialogEditboxText() == '/rng' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт)') 
		end

		if sampGetCurrentDialogEditboxText() == '.кпт' or sampGetCurrentDialogEditboxText() == '/rgn' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Для того, чтобы начать капт, нужно ввести /capture | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вп1' or sampGetCurrentDialogEditboxText() == '/dg1' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок с привелегией Premuim VIP (/help -> 7) | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вп2' or sampGetCurrentDialogEditboxText() == '/dg2' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок с привелегией Diamond VIP (/help -> 7) | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вп3' or sampGetCurrentDialogEditboxText() == '/dg3' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок с привелегией Platinum VIP (/help -> 7) | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вп4' or sampGetCurrentDialogEditboxText() == '/dg4' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок с привелегией "Личный" VIP (/help -> 7) | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.падм' or sampGetCurrentDialogEditboxText() == '/gflv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Ожидать набор, или же /help -> 17 пункт. | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.копы' or sampGetCurrentDialogEditboxText() == '/rjgs' then
			sampSetCurrentDialogEditboxText('{FFFFFF}265-267, 280-286, 288, 300-304, 306, 307, 309-311 | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.бал' or sampGetCurrentDialogEditboxText() == '/,fk' then
			sampSetCurrentDialogEditboxText('{FFFFFF}102-104| ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.грув' or sampGetCurrentDialogEditboxText() == '/uhed' then
			sampSetCurrentDialogEditboxText('{FFFFFF}105-107 | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.румф' or sampGetCurrentDialogEditboxText() == '/heva' then
			sampSetCurrentDialogEditboxText('{FFFFFF}111-113 | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.вар' or sampGetCurrentDialogEditboxText() == '/dfh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}114-116 | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.триад' or sampGetCurrentDialogEditboxText() == '/nhbfl' then
			sampSetCurrentDialogEditboxText('{FFFFFF}117-188, 120 | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.ваг' or sampGetCurrentDialogEditboxText() == '/dfu' then
			sampSetCurrentDialogEditboxText('{FFFFFF}108-110 | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.мф' or sampGetCurrentDialogEditboxText() == '/va' then
			sampSetCurrentDialogEditboxText('{FFFFFF}124-127 | ' .. color1() .. ' Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.спр' or sampGetCurrentDialogEditboxText() == '/cgh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/mm -> Действия -> Сменить пароль | ' .. color1() .. '  Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.мсп' or sampGetCurrentDialogEditboxText() == '/vcg' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/mm -> Транспортное средство -> Тип транспорта| ' .. color1() .. '  Приятной игры! ')
		end

		if sampGetCurrentDialogEditboxText() == '.уид' or sampGetCurrentDialogEditboxText() == '/ebl' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Уточните ID нарушителя/читера в /report ' .. color1() .. ' | Удачного времяпрепровождения. ')
		end

		if sampGetCurrentDialogEditboxText() == '.стп' or sampGetCurrentDialogEditboxText() == '/cng' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Чтобы посмотреть коины, вирты, рубли и т.д. - /statpl ')
		end

		if sampGetCurrentDialogEditboxText() == '.гвм' or sampGetCurrentDialogEditboxText() == '/udv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Для перевода денег, необхдимо ввести /givemoney IDPlayer сумму | ' .. color1() .. ' Приятной игры!')
		end

		if sampGetCurrentDialogEditboxText() == '.гвс' or sampGetCurrentDialogEditboxText() == '/udc' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Для перевода очков, необходимо ввести /givescore IDPlayer сумму |' .. color1() .. ' С Diamond VIP.')
		end

		if sampGetCurrentDialogEditboxText() == '.пм' or sampGetCurrentDialogEditboxText() == '/gv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/sellmycar IDPlayer Слот(1-3) RDScoin (игроку), в гос: /car | ' .. color1() .. ' Приятной игры!')
		end

		if sampGetCurrentDialogEditboxText() == '.вуб' or sampGetCurrentDialogEditboxText() == '/de,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Чтобы выдать выговор участнику банды, есть команда: /gvig ')
		end

		if sampGetCurrentDialogEditboxText() == '.зч' or sampGetCurrentDialogEditboxText() == '/px' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Если вы застряли, введите /spawn | /kill, ' .. color1() .. ' но мы можем вам помочь! ')
		end

		if sampGetCurrentDialogEditboxText() == '/prk' or sampGetCurrentDialogEditboxText() == '.зкл' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/parkour - записатся на паркур | '  .. color1() ..  ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '/drb' or sampGetCurrentDialogEditboxText() == '.вки' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/derby - записатся на дерби | '  .. color1() ..  ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.псв' or sampGetCurrentDialogEditboxText() == '/gcd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/passive ' .. color1() ..  ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.инф' or sampGetCurrentDialogEditboxText() == '/bya' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данную информацию можно узнать в интернете. '  .. color1() ..  ' Приятной игры!')
		end

		if sampGetCurrentDialogEditboxText() == '.ог' or sampGetCurrentDialogEditboxText() == '/ju' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Встать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте' .. color1() ..  ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.ож' or sampGetCurrentDialogEditboxText() == '/j;' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Ожидайте. '  .. color1() ..  ' Приятного времяпрепровождения на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.цвет' or sampGetCurrentDialogEditboxText() == '/wdtn' then 
			sampSetCurrentDialogEditboxText('{FFFFFF}https://colorscheme.ru/html-colors.html ' .. color1() .. ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.жба' or sampGetCurrentDialogEditboxText() == '/;,f' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Пишите жалобу на администратора на форум https://forumrds.ru')
		end

		if sampGetCurrentDialogEditboxText() == '.жби'or sampGetCurrentDialogEditboxText() == '/;,b'  then
			sampSetCurrentDialogEditboxText('{FFFFFF}Вы можете оставить жалобу на игрока на форум https://forumrds.ru')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.нч' or sampGetCurrentDialogEditboxText() == '/yx' then
				sampSetCurrentDialogEditboxText('{FFFFFF}Начал(а) работу по вашей жалобе! ' .. color1() .. ' Приятной игры на сервере RDS. <3 ')
				wait(1000)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/re " )
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.ич' or sampGetCurrentDialogEditboxText() == '/bx' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок чист. ' .. color1() .. ' Приятной игры на сервере RDS. <3 ')
		end

		lua_thread.create(function()
			if sampGetCurrentDialogEditboxText() == '.сл' then
				sampSetCurrentDialogEditboxText('{FFFFFF}Слежу за данным игроком, ожидайте. :3 ')
				wait(1000)
				sampSetChatInputEnabled(true)
				sampSetChatInputText("/re " )
			end
		end)

		if sampGetCurrentDialogEditboxText() == '.п7' or sampGetCurrentDialogEditboxText() == '/g7' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данную информацию можно найти в /help -> 7 пункт. | '  .. color1() ..  ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.п13' or sampGetCurrentDialogEditboxText() == '/g13' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данную информацию можно найти в /help -> 13 пункт. | '  .. color1() ..  ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.п8' or sampGetCurrentDialogEditboxText() == '/g8' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данную информацию можно найти в /help -> 8 пункт. | '  .. color1() ..  ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.нак' or sampGetCurrentDialogEditboxText() == '/yfr' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок наказан. | '  .. color1() ..  '  Приятной игры на RDS! <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.нн' or sampGetCurrentDialogEditboxText() == '/yy' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Не вижу нарушений от игрока. | ' .. color1() .. ' Приятной игры на RDS <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.нв' or sampGetCurrentDialogEditboxText() == '/yd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Данный игрок не в сети. | ' .. color1() .. ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.бк' or sampGetCurrentDialogEditboxText() == '/,r' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк ')
		end

		if sampGetCurrentDialogEditboxText() == '.тас' or sampGetCurrentDialogEditboxText() == '/nfc' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/tp -> Разное -> Автосалоны |' .. color1() .. '  Приятной игры на RDS. <3')
		end

		if sampGetCurrentDialogEditboxText() == '.там' or sampGetCurrentDialogEditboxText() == '/nfv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/tp -> Разное -> Автосалоны -> Автомастерская | ' .. color1() .. ' Приятной игры на RDS. <3 ')
		end

		if sampGetCurrentDialogEditboxText() == '.пгф' or sampGetCurrentDialogEditboxText() == '/gua' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/gleave (банда) || /fleave (семья)| ' .. color1() .. ' Приятной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.плм' or sampGetCurrentDialogEditboxText() == '/gkv' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/leave (покинуть мафию)| ' .. color1() .. ' Приятной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.ут' or sampGetCurrentDialogEditboxText() == '/en' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Уточните ваш вопрос/репорт. ' .. color1() .. ' Удачной игры <3')
		end

		if sampGetCurrentDialogEditboxText() == '.пгб' or sampGetCurrentDialogEditboxText() == '/gu,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/ginvite (банда) || /finvite (семья) | ' .. color1() .. ' Удачной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.угб' or sampGetCurrentDialogEditboxText() == '/eu,' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/guninvite (банда) || /funinvite (семья) | ' .. color1() .. ' Удачной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.гвр' or sampGetCurrentDialogEditboxText() == '/udh' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/giverub IDPlayer rub | С Личного (/help -> 7) | ' .. color1() .. ' Удачной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.гвк' or sampGetCurrentDialogEditboxText() == '/udr' then
			sampSetCurrentDialogEditboxText('{FFFFFF}/givecoin IDPlayer coin | С Личного (/help -> 7) | ' .. color1() .. ' Удачной игры на RDS <3')
		end

		if sampGetCurrentDialogEditboxText() == '.пв' or sampGetCurrentDialogEditboxText() == '/gd' then
			sampSetCurrentDialogEditboxText('{FFFFFF}Помогли вам. | ' .. color1() .. ' Удачной игры на RDS <3')
		end

        if sampGetCurrentDialogEditboxText() == '.апр' or sampGetCurrentDialogEditboxText() == '/fgh' then 
            sampSendDialogResponse(2351, 1, 0, '{FFFFFF}Передам ваш репорт! ' .. color1() .. 'Удачной игры!')
            wait(200)
            sampCloseCurrentDialogWithButton(13)
            wait(200)
            sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "] | " .. text_rep)
        end    

		if string.find(sampGetChatInputText(), "%-пр") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "-пр", "| Приятной игры на RDS <3"))
		end

		if string.find(sampGetChatInputText(), "%/vrm") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/vrm", "Приятного времяпрепровождения на Russian Drift Server!"))
		end

		if string.find(sampGetChatInputText(), "%/gvk") then
			sampSetChatInputText(string.gsub(sampGetChatInputText(), "/gvk", "https://vk.com/dmdriftgta"))
		end

		if sampGetCurrentDialogId() == 2352 then  
			sampCloseCurrentDialogWithButton(1)
		end
    end
end

function color1() -- функция, выполняющая рандомнизацию и вывод рандомного цвета с помощью специального os.time()
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

------- Функции, относящиеся к быстрым ответам -------
function cmd_tcm(arg)
	sampSendChat("/ans " .. arg .. " Чтобы обменять валюту, введите /trade, и подойдите к NPC Арману, стоит справа ")
end 

function cmd_tm(arg)
	sampSendChat("/ans " .. arg .. " Ожидайте. | Приятного времяпрепровождения на RDS <3 ")
end

function cmd_zsk(arg)
	sampSendChat("/ans " .. arg .. " Если вы застряли, введите /spawn | /kill, но мы можем вам помочь! ")
end

function cmd_vgf(arg)
	sampSendChat("/ans " .. arg .. " Чтобы выдать выговор участнику банды, есть команда: /gvig ")
end

function cmd_html(arg)
	sampSendChat("/ans ".. arg .. " https://colorscheme.ru/html-colors.html | Приятной игры! ")
end

function cmd_ktp(arg)
	sampSendChat("/ans " .. arg .. " /tp (по локациям), /g (/goto) id (к игроку) с VIP (/help -> 7 пункт) ")
end

function cmd_vp1(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок с привелегией Premuim VIP (/help -> 7)  | Приятной игры! <3 ")
end

function cmd_vp2(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок с привелегией Diamond VIP (/help -> 7) | Приятной игры! <3 ")
end

function cmd_vp3(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок с привелегией Platinum VIP (/help -> 7) | Приятной игры! <3 ")
end

function cmd_vp4(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок с привелегией «Личный» VIP (/help -> 7) | Приятной игры! <3 ")
end

function cmd_chap(arg)
	sampSendChat("/ans " .. arg .. " /mm -> Действия -> Сменить пароль | Приятной игры! <3 ")
end

function cmd_msp(arg)
	sampSendChat("/ans " .. arg .. " /mm -> Транспортное средство -> Тип транспорта | Приятной игры на RDS. <3 ")
end

function cmd_trp(arg)
	sampSendChat("/ans " .. arg .. " /report | Приятной игры на RDS. <3 ")
end

function cmd_rid(arg)
	sampSendChat("/ans " .. arg .. " Уточните ID нарушителя/читера в /report | Удачного времяпрепровождения. ")
end

function cmd_bk(arg)
	sampSendChat("/ans " .. arg .. " Оплатить бизнес/дом можно с помощью /bank или /tp -> Разное -> Банк ")
end

function cmd_h7(arg)
	sampSendChat("/ans " .. arg .. " Посмотреть информацию можно в /help -> 7 пункт. | Приятной игры на RDS. <3 ")
end

function cmd_h8(arg)
	sampSendChat("/ans " .. arg .. " Узнать данную информацию можно в /help -> 8 пункт. | Приятной игры на RDS. <3 ")
end

function cmd_h13(arg)
	sampSendChat("/ans " .. arg .. " Узнать данную информацию можно в /help -> 13 пункт. | Приятной игры на RDS. <3 ")
end

function cmd_zba(arg)
	sampSendChat("/ans " .. arg .. " Админ наказал не так? Пишите жалобу на форум https://forumrds.ru")
end

function cmd_zbp(arg)
	sampSendChat("/ans " .. arg .. " Пишите жалобу на игрока на форум https://forumrds.ru")
end

function cmd_avt(arg)
	sampSendChat("/ans " .. arg .. " /tp -> Разное -> Автосалоны | Приятной игры!")
end

function cmd_avt1(arg)
 sampSendChat("/ans " .. arg .. " /tp -> Разное -> Автосалоны -> Автомастерская | Приятной игры!")
end

function cmd_pgf(arg)
	sampSendChat("/ans " .. arg .. " /gleave (банда) || /fleave (семья)| Приятной игры на RDS <3")
end

function cmd_lgf(arg)
	sampSendChat("/ans " .. arg .. " /leave (покинуть мафию) | Приятной игры на RDS <3")
end

function cmd_igf(arg)
	sampSendChat("/ans " .. arg .. " /ginvite (банда) || /finvite (семья) | Удачной игры на RDS <3" )
end

function cmd_ugf(arg)
	sampSendChat("/ans " .. arg .. " /guninvite (банда) || /funinvite (семья) | Удачной игры на RDS <3 ")
end

function cmd_cops(arg)
	sampSendChat("/ans " .. arg .. " 265-267, 280-286, 288, 300-304, 306, 307, 309-311 | Удачной игры на RDS <3")
end

function cmd_bal(arg)
	sampSendChat("/ans " .. arg .. "  102-104 | Удачной игры на RDS <3")
end

function cmd_cro(arg)
	sampSendChat("/ans " .. arg .. " 105-107 | Удачной игры на RDS <3")
end

function cmd_rumf(arg)
	sampSendChat("/ans " .. arg .. " 111-113 | Удачной игры на RDS <3")
end

function cmd_vg(arg)
	sampSendChat("/ans " .. arg .. " 108-110 | Удачной игры на RDS <3 ")
end

function cmd_var(arg)
	sampSendChat("/ans " .. arg .. " 114-116 | Удачной игры на RDS <3")
end

function cmd_triad(arg)
	sampSendChat("/ans " .. arg .. " 117-118, 120  | Удачной игры на RDS <3")
end

function cmd_mf(arg)
	sampSendChat("/ans " .. arg .. " 124-127 | Удачной игры на RDS <3")
end

function cmd_gvm(arg)
	sampSendChat("/ans " .. arg .. " Для перевода денег, необхдимо ввести /givemoney IDPlayer сумму | Приятной игры!' ")
end

function cmd_gvs(arg)
	sampSendChat("/ans " .. arg .. " Для перевода очков, необходимо ввести /givescore IDPlayer сумму | С Diamond VIP. ")
end

function cmd_cpt(arg)
	sampSendChat("/ans " .. arg .. " Для того, чтобы начать капт, нужно ввести /capture | Приятной игры! ")
end

function cmd_psv(arg)
	sampSendChat("/ans " .. arg .. " /passive - пассивный режим, для того, чтобы вас не могли убить.  ")
end

function cmd_dis(arg)
	sampSendChat("/ans " ..  arg .. " Игрок не в сети. | Приятной игры на RDS <3 ")
end

function cmd_nac(arg)
	sampSendChat("/ans " .. arg .. " Игрок наказан. | Приятной игры на RDS <3")
end

function cmd_cl(arg)
	sampSendChat("/ans " .. arg .. " Данный игрок чист. | Приятной игры на RDS <3")
end

function cmd_yt(arg)
	sampSendChat("/ans " .. arg .. " Уточните ваш запрос/вопрос. | Приятной игры на RDS <3")
end

function cmd_drb(arg)
	sampSendChat("/ans " .. arg .. " /derby - записатся на дерби | Приятной игры на RDS 02 <3 ")
end

function cmd_smc(arg)
	sampSendChat("/ans " .. arg .. " /sellmycar IDPlayer Слот(1-3) RDScoin (игроку), в гос: /car ")
end

function cmd_c(arg)
	lua_thread.create(function()
		sampSendChat("/ans " .. arg .. " Начал(а) работу по вашей жалобе. | Приятной игры на RDS <3")
		wait(1000)
		sampSetChatInputEnabled(true)
		sampSetChatInputText("/re " )
	end)
end

function cmd_stp(arg)
	sampSendChat("/ans " .. arg .. " Чтобы посмотреть коины, вирты, рубли и т.д. - /statpl ")
end

function cmd_prk(arg)
	sampSendChat("ans ".. arg .. " /parkour - записатся на паркур | Приятной игры на RDS 02 <3 ")
end

function cmd_n(arg)
	sampSendChat("/ans " .. arg .. " Не вижу нарушений от игрока. | Приятной игры на RDS <3")
end

function cmd_hg(arg)
	sampSendChat("/ans " .. arg .. " Помогли вам. | Приятного времяпрепровождения на RDS <3 ")
end

function cmd_int(arg)
	sampSendChat("/ans " .. arg .. " Данную информацию можно узнать в интернете. Приятной игры! ")
end

function cmd_og(arg)
	sampSendChat("/ans " .. arg ..  'Встать на пикап "Ограбление банка", после около ячеек нажимать на ALT и ехать на красный маркер на карте')
end

function cmd_msid(arg)
	sampSendChat("/ans " .. arg .. " Здравствуйте! Произошла ошибка в ID! Наказание снято. ")
	sampSendChat("/ans " .. arg .. " Приятного времяпрепровождения на Russian Drift Server! ")
end

function cmd_al(arg)
	sampSendChat("/ans " .. arg .. " Здравствуйте! Вы забыли ввести /alogin! ")
	sampSendChat("/ans " .. arg .. " Введите команду /alogin и свой пароль, пожалуйста.")
end

function cmd_gfi(arg)
	sampSendChat("/ans " .. arg .. " /funinvite id (в семью), /ginvite id (в банду) ")
end

function cmd_hin(arg)
	sampSendChat("/ans " .. arg .. ' /hpanel -> Слот1-3 -> Изменить -> Аренда дома | Приятной игры на RDS <3 ')
end

function cmd_gn(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> Оружие | Удачного времяпреповождения")
end

function cmd_pd(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> Предметы | Удачного времяпреповождения")
end

function cmd_dtl(arg)
	sampSendChat("/ans " .. arg .. " Детали разбросаны по всей карте. Обмен происходится на /garage. | Удачного времяпреповождения")
end

function cmd_nz(arg)
	sampSendChat("/ans " .. arg .. " Не запрещено. | Удачного времяпреповождения")
end

function cmd_y(arg)
	sampSendChat("/ans " .. arg .. " Да. | Удачного времяпреповождения")
end

function cmd_net(arg)
	sampSendChat("/ans " .. arg .. " Нет. | Удачного времяпреповождения")
end

function cmd_gak(arg)
	sampSendChat("/ans" .. arg .. " Продать аксессуары, или купить можно на /trade. Чтобы продать, F у лавки ")
end

function cmd_enk(arg)
	sampSendChat("/ans " .. arg .. " Никак. | Удачного времяпреповождения")
end

function cmd_fp(arg)
	sampSendChat("/ans " .. arg .. " /familypanel | Удачного времяпреповождения")
end

function cmd_mg(arg)
	sampSendChat("/ans " .. arg .. " /menu (/mm) - ALT/Y -> Система банд | Удачного времяпреповождения")
end

function cmd_pg(arg)
	sampSendChat("/ans " .. arg .. " Проверим. | Удачного времяпреповождения")
end

function cmd_krb(arg)
	sampSendChat("/ans " .. arg .. " Казино, работы, бизнес. | Удачного времяпреповождения")
end

function cmd_kmd(arg)
	sampSendChat("/ans " .. arg .. " Казино, МП, достижения, работы, обмен очков на коины(/trade) | Приятной игры на RDS <3")
end

function cmd_gm(arg)
	sampSendChat("/ans " .. arg .. " GodMode (ГодМод) на сервере не работает. | Удачного времяпреповождения")
end

function cmd_plg(arg)
	sampSendChat("/ans " .. arg .. " Попробуйте перезайти. | Удачного времяпреповождения")
end

function cmd_nv(arg)
	sampSendChat("/ans " .. arg .. " Не выдаем. | Удачного времяпреповождения")
end

function cmd_of(arg)
	sampSendChat("/ans " .. arg .. " Не оффтопьте. | Удачного времяпреповождения")
end

function cmd_en(arg)
	sampSendChat("/ans " .. arg .. " Не знаем. | Удачного времяпреповождения")
end

function cmd_vbg(arg)
	sampSendChat("/ans " .. arg .. " Скорей всего - это баг. | Удачного времяпреповождения")
end

function cmd_ctun(arg)
	sampSendChat("/ans " .. arg .. ' /menu (/mm) - ALT/Y -> Т/С -> Тюнинг | Приятной игры на RDS <3')
end

function cmd_cr(arg)
	sampSendChat("/ans " .. arg .. ' /car | Приятной игры на сервере RDS <3 ')
end

function cmd_zsk(arg)
	sampSendChat("/ans " .. arg .. " Если вы застряли, введите /spawn | /kill | Приятной игры на RDS <3")
end

function cmd_smh(arg)
	sampSendChat("/ans " .. arg .. " /sellmyhouse (игроку)  ||  /hpanel -> слот -> Изменить -> Продать дом государству ")
end

function cmd_gadm(arg)
	sampSendChat("/ans " .. arg .. " Ожидать набор, или же /help -> 17 пункт. | Приятной игры на RDS. <3")
end

function cmd_hct(arg)
	sampSendChat("/ans " .. arg .. " /count time || /dmcount time | Приятной игры на RDS. <3 ")
end

function cmd_gvr(arg)
	sampSendChat("/ans " .. arg .. " /giverub IDPlayer rub | С Личного (/help -> 7) | Приятной игры!")
end

function cmd_gvc(arg)
	sampSendChat("/ans " .. arg .. " /givecoin IDPlayer coin | С Личного (/help -> 7) | Приятной игры!")
end

function cmd_tdd(arg)
	sampSendChat("/ans " .. arg .. " /dt 0-990 / Виртуальный мир | Приятной игры!")
end
------- Функции, относящиеся к быстрым ответам -------

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
        if text:match("Игрок: {......}(%S+)") and text:match("Жалоба:\n{......}(.*)\n\n{......}") then
            nick_rep = text:match("Игрок: {......}(%S+)")
            text_rep = text:match("Жалоба:\n{......}(.*)\n\n{......}")	
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
        imgui.Begin(u8"Ответы на репорты", rep.imgui)
        local btn_size = imgui.ImVec2(-0.1, 0)

		if report_ans == 0 then  
			imgui.Text(u8" Вы можете ответить на соответствующий репорт ниже! \nВы можете ввести свой ответ, либо воспользоваться вариантами ответов от AT")
			--imgui.Text(u8(nick_rep .. " [" .. pid_rep .. "]: " .. u8:decode(rep_text)))
			if imgui.Button(fa.ICON_CHECK .. u8" Передать жалобу ##SEND") then  
				lua_thread.create(function()
					sampSendDialogResponse(2349, 1, 0)
					sampSendDialogResponse(2350, 1, 0)
					wait(200)
					sampSendDialogResponse(2351, 1, 0, '{FFFFFF}Передам ваш репорт! ' .. color1() .. 'Удачной игры!')
					wait(200)
					sampCloseCurrentDialogWithButton(13)
					wait(200)
					sampSendChat("/a " .. nick_rep .. "[" .. pid_rep .. "] | " .. text_rep)
				end)	
			end
			imgui.Separator()
			imgui.InputText(u8"##Ответ", rep.text)
			imgui.SameLine() 
			if imgui.Button(fa.ICON_REFRESH .. ("##RefreshText//RemoveText")) then  
				rep.text.v = "" 
			end	
			if #rep.text.v > 0 then
				imgui.SameLine() 
				if imgui.Button(fa.ICON_FA_SAVE .. ("##SaveReport")) then  
					imgui.OpenPopup(u8'Биндер')
				end	
			end	
			if imgui.BeginPopupModal(u8'Биндер', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
				imgui.Text(u8'Название бинда:'); imgui.SameLine()
				imgui.PushItemWidth(130)
				imgui.InputText("##rep.binder_name", rep.binder_name)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'Закрыть##bind1', imgui.ImVec2(100,30)) then
					rep.binder_name.v = ''
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if #rep.binder_name.v > 0 then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8'Сохранить##bind1', imgui.ImVec2(100,30)) then
						if not EditOldBind then
							local refresh_text = rep.text.v:gsub("\n", "~")
							table.insert(ATrep.bind_name, rep.binder_name.v)
							table.insert(ATrep.bind_text, refresh_text)
							if save() then
								sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(rep.binder_name.v).. '" успешно создан!', -1)
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
								sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(rep.binder_name.v).. '" успешно отредактирован!', -1)
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
			if imgui.Button(u8"Ответить") then  
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
						sampSendDialogResponse(2351, 1, 0, u8:decode(settext2) .. color1() .. ' // Приятной игры на сервере RDS <3')	
						wait(200)
						sampCloseCurrentDialogWithButton(13)
						rep.imgui.v = false
					end)
				end	
			end		
			imgui.Separator()
			if imgui.Button(fa.ICON_QUESTION_CIRCLE .. u8" Ответы от AT") then  
				report_ans = 1
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Выводит ответы, которые зарегистрированы в AT разработчиками")
			if imgui.Button(fa.ICON_FA_SAVE .. u8" Сохраненные ответы") then  
				report_ans = 2
			end	
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8"Выводит ответы, которые вы сохранили в /binder")
			imgui.Separator()
			if imgui.Checkbox(u8"Пожелание в ответе", rep.ggp) then 
				ATrep.main.good_game_prefix = rep.ggp.v 
				save() 
			end
			imgui.SameLine()
			imgui.TextQuestion('(?)', u8'Автоматически при ответе через кнопочки будет желать приятной игры!')	
			imgui.SetCursorPosY(imgui.GetWindowWidth() - 295)
			imgui.Separator()
			imgui.SetCursorPosY(imgui.GetWindowWidth() - 270)
			if imgui.Button(fa.ICON_WINDOW_CLOSE .. u8" Закрыть ##CLOSE") then  
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
			if imgui.Button(fa.ICON_OBJECT_GROUP .. u8" На кого-то/что-то", imgui.ImVec2(140, 0)) then  -- reporton key
				check_ans = 1  
			end	
			if imgui.Button(fa.ICON_LIST .. u8" Команды (/help)", imgui.ImVec2(140, 0)) then  -- HelpCMD key
				check_ans = 2 
			end 	
			if imgui.Button(fa.ICON_USERS .. u8" Банде/семья", imgui.ImVec2(140, 0)) then  -- HelpGangFamilyMafia key
				check_ans = 3
			end	
			if imgui.Button(fa.ICON_MAP_MARKER .. u8" Телепорты", imgui.ImVec2(140, 0)) then  -- HelpTP key
				check_ans = 4
			end	
			if imgui.Button(fa.ICON_SHOPPING_BAG .. u8" Бизнесы", imgui.ImVec2(140, 0)) then  -- HelpBuz key
				check_ans = 5 
			end	
			if imgui.Button(fa.ICON_MONEY .. u8" Продажа/Покупка", imgui.ImVec2(140, 0)) then  -- HelpSellBuy key
				check_ans = 6 
			end	
			if imgui.Button(fa.ICON_BOLT .. u8" Настройки", imgui.ImVec2(140, 0)) then  -- HelpSettings key
				check_ans = 7
			end	
			if imgui.Button(fa.ICON_HOME .. u8" Дома", imgui.ImVec2(140, 0)) then  -- HelpHouses key
				check_ans = 8 
			end	
			if imgui.Button(fa.ICON_MALE .. u8" Скины", imgui.ImVec2(140, 0)) then  -- HelpSkins key
				check_ans = 9 
			end	
			if imgui.Button(fa.ICON_BARCODE .. u8" Остальные ответы", imgui.ImVec2(140, 0)) then  -- HelpDefault key
				check_ans = 10
			end	
			imgui.Separator()
			if imgui.Button(fa.ICON_BACKWARD .. u8" Назад") then  
				report_ans = 0 
			end	
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild("##menuSelectable", imgui.ImVec2(390, 275), true)
			if check_ans == 0 then  
				imgui.Text(u8"Заготовленные/сохраненные ответы такого типа \nменяются только разработчиками")
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
									local settext = '{FFFFFF}' .. v_2 .. '' .. color1() .. ' // Приятной игры на сервере RDS <3'
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
				imgui.Text(u8"Пусто!")
				if imgui.Button(u8"Создать!") then  
					imgui.OpenPopup(u8'Биндер')	 
				end	
			end	
			if imgui.BeginPopupModal(u8'Биндер', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
				imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
				imgui.Text(u8'Название бинда:'); imgui.SameLine()
				imgui.PushItemWidth(130)
				imgui.InputText("##rep.binder_name", rep.binder_name)
				imgui.PopItemWidth()
				imgui.PushItemWidth(100)
				imgui.Separator()
				imgui.Text(u8'Текст бинда:')
				imgui.PushItemWidth(300)
				imgui.InputTextMultiline("##rep.binder_text", rep.binder_text, imgui.ImVec2(-1, 110))
				imgui.PopItemWidth()
	
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
				if imgui.Button(u8'Закрыть##bind1', imgui.ImVec2(100,30)) then
					rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
					imgui.CloseCurrentPopup()
				end
				imgui.SameLine()
				if #rep.binder_name.v > 0 and #rep.binder_text.v > 0 then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
					if imgui.Button(u8'Сохранить##bind1', imgui.ImVec2(100,30)) then
						if not EditOldBind then
							local refresh_text = rep.binder_text.v:gsub("\n", "~")
							table.insert(ATrep.bind_name, rep.binder_name.v)
							table.insert(ATrep.bind_text, refresh_text)
							table.insert(ATrep.bind_delay, rep.binder_delay.v)
							if save() then
								sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(rep.binder_name.v).. '" успешно создан!', -1)
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
								sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(rep.binder_name.v).. '" успешно отредактирован!', -1)
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
			if imgui.Button(fa.ICON_BACKWARD .. u8" Назад") then  
				report_ans = 0 
			end	
		end	
        imgui.End()
    end

			-- if imgui.Button(u8'Местоположение окна') then
			-- 	lua_thread.create(function()
			-- 		rep.binder.v = false
			-- 		rep.window_ans.v = true
			-- 		showCursor(true, true)
			-- 		checkCursor = true
			-- 		sampSetCursorMode(4)
			-- 		sampAddChatMessage(tag .. " Нажмите {69b2ff}SPACE{FFFFFF} чтобы сохранить позицию")
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
			-- 				if save() then sampAddChatMessage(tag .. "Местоположение сохранено!", -1) end
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
	-- 		imgui.Text(u8"Пусто!")
	-- 		if imgui.Button(u8"Создать!") then  
	-- 			imgui.OpenPopup(u8'Биндер')	 
	-- 		end	
	-- 	end	
	-- 	if imgui.BeginPopupModal(u8'Биндер', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
	-- 		imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
	-- 		imgui.Text(u8'Название бинда:'); imgui.SameLine()
	-- 		imgui.PushItemWidth(130)
	-- 		imgui.InputText("##rep.binder_name", rep.binder_name)
	-- 		imgui.PopItemWidth()
	-- 		imgui.PushItemWidth(100)
	-- 		imgui.InputInt(u8("Задержка между строками в миллисекундах"), rep.binder_delay)
	-- 		imgui.PopItemWidth()
	-- 		if rep.binder_delay.v <= 0 then
	-- 			rep.binder_delay.v = 1
	-- 		elseif rep.binder_delay.v >= 60001 then
	-- 			rep.binder_delay.v = 60000
	-- 		end
	-- 		imgui.Separator()
	-- 		imgui.Text(u8'Текст бинда:')
	-- 		imgui.PushItemWidth(300)
	-- 		imgui.InputTextMultiline("##rep.binder_text", rep.binder_text, imgui.ImVec2(-1, 110))
	-- 		imgui.PopItemWidth()

	-- 		imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
	-- 		if imgui.Button(u8'Закрыть##bind1', imgui.ImVec2(100,30)) then
	-- 			rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
	-- 			imgui.CloseCurrentPopup()
	-- 		end
	-- 		imgui.SameLine()
	-- 		if #rep.binder_name.v > 0 and #rep.binder_text.v > 0 then
	-- 			imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
	-- 			if imgui.Button(u8'Сохранить##bind1', imgui.ImVec2(100,30)) then
	-- 				if not EditOldBind then
	-- 					local refresh_text = rep.binder_text.v:gsub("\n", "~")
	-- 					table.insert(ATrep.bind_name, rep.binder_name.v)
	-- 					table.insert(ATrep.bind_text, refresh_text)
	-- 					table.insert(ATrep.bind_delay, rep.binder_delay.v)
	-- 					if save() then
	-- 						sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(rep.binder_name.v).. '" успешно создан!', -1)
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
	-- 						sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(rep.binder_name.v).. '" успешно отредактирован!', -1)
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
	imgui.Text(u8"Здесь вы можете создать собственные ответы \nи взаимодействовать с ними в интерфейсе ответов на репорты!")
	imgui.Text(u8'При нажатии на кнопку "Сохраненные ответы", ваши ответы там и будут! \nПриятной игры, дорогой администратор! <3')
	imgui.Separator()
	imgui.Text(" ")
	imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 2)
	if imgui.Button(u8'Создать') then
		imgui.OpenPopup(u8'Биндер')
	end
	imgui.Text(" ")
	imgui.Separator()

	if #ATrep.bind_name > 0 then
		for key_bind, name_bind in pairs(ATrep.bind_name) do
		imgui.Button(name_bind..'##'..key_bind, imgui.ImVec2(270, 22))
		imgui.SameLine()
		if imgui.Button(u8'Редактировать##'..key_bind, imgui.ImVec2(100, 22)) then
			EditOldBind = true
			getpos = key_bind
			local returnwrapped = tostring(ATrep.bind_text[key_bind]):gsub('~', '\n')
			rep.binder_text.v = returnwrapped
			rep.binder_name.v = tostring(ATrep.bind_name[key_bind])
			rep.binder_delay.v = tostring(ATrep.bind_delay[key_bind])
			imgui.OpenPopup(u8'Биндер')
		end
		imgui.SameLine()
		if imgui.Button(u8'Удалить##'..key_bind, imgui.ImVec2(60, 22)) then
			sampAddChatMessage(tag .. 'Бинд "' ..u8:decode(ATrep.bind_name[key_bind])..'" удален!', -1)
			table.remove(ATrep.bind_name, key_bind)
			table.remove(ATrep.bind_text, key_bind)
			table.remove(ATrep.bind_delay, key_bind)
			save()
		end
	end
	else
		imgui.Text(u8('Здесь пока пусто :('))
	end
	if imgui.BeginPopupModal(u8'Биндер', false, imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize) then
		imgui.BeginChild("##EditBinder", imgui.ImVec2(600, 225), true)
		imgui.Text(u8'Название бинда:'); imgui.SameLine()
		imgui.PushItemWidth(130)
		imgui.InputText("##binder_name", rep.binder_name)
		imgui.PopItemWidth()
		imgui.PushItemWidth(100)
		imgui.Separator()
		imgui.Text(u8'Текст бинда:')
		imgui.PushItemWidth(300)
		imgui.InputTextMultiline("##rep.binder_text", rep.binder_text, imgui.ImVec2(-1, 110))
		imgui.PopItemWidth()

		imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 100)
		if imgui.Button(u8'Закрыть##bind1', imgui.ImVec2(100,30)) then
			rep.binder_name.v, rep.binder_text.v, rep.binder_delay.v = '', '', 2500
			imgui.CloseCurrentPopup()
		end
		imgui.SameLine()
		if #rep.binder_name.v > 0 and #rep.binder_text.v > 0 then
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 100) / 1.01)
			if imgui.Button(u8'Сохранить##bind1', imgui.ImVec2(100,30)) then
				if not EditOldBind then
					local refresh_text = rep.binder_text.v:gsub("\n", "~")
					table.insert(ATrep.bind_name, rep.binder_name.v)
					table.insert(ATrep.bind_text, refresh_text)
					table.insert(ATrep.bind_delay, rep.binder_delay.v)
					if save() then
						sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(rep.binder_name.v).. '" успешно создан!', -1)
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
						sampAddChatMessage(tag .. 'Бинд"' ..u8:decode(rep.binder_name.v).. '" успешно отредактирован!', -1)
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