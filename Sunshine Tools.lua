script_name('FPS UP 2022')
script_author('Yokoyama')
script_version(0.4)

local imgui = require("imgui")
local sw, sh = getScreenResolution()
local encoding = require ("encoding")
local inicfg = require("inicfg")
local sampev = require('lib.samp.events')
local mem = require "memory"
local window = imgui.ImBool(false)
local tag = '{ffd500}[Sunshine Tools] {FFFFFF}'
local dlstatus = require('moonloader').download_status

encoding.default = "CP1251"
u8 = encoding.UTF8

defaultState = false
fmember = false
checkStat = false


local mainIni = inicfg.load({ -- CFG
    mode = 1, 
    settings = {
        rp_invite = false,
        prospammer = false,
        fastmute = false,
        fastuval = false,
        mutetext = 'Помехи в рацию.',
        uvaltext = 'Выселен.',
        prospamtext1 = 'Тут может быть ваш текст.',
        prospamtext2 = 'Тут может быть ваш текст.',
        prospamtext3 = 'Тут может быть ваш текст.'
    }
}, "sunshinetools")
local mutetext = imgui.ImBuffer(u8(mainIni.settings.mutetext), 256)
local uvaltext = imgui.ImBuffer(u8(mainIni.settings.uvaltext), 256)
local prospamtext1 = imgui.ImBuffer(u8(mainIni.settings.prospamtext1), 256)
local prospamtext2 = imgui.ImBuffer(u8(mainIni.settings.prospamtext2), 256)
local prospamtext3 = imgui.ImBuffer(u8(mainIni.settings.prospamtext3), 256)
local rp_invite = imgui.ImBool(mainIni.settings.rp_invite)
local prospammer = imgui.ImBool(mainIni.settings.prospammer)
local fastmute = imgui.ImBool(mainIni.settings.fastmute)
local fastuval = imgui.ImBool(mainIni.settings.fastuval)
local status = inicfg.load(mainIni, 'sunshinetools.ini')
if not doesFileExist('moonloader/config/sunshinetools.ini') then inicfg.save(mainIni, 'sunshinetools.ini') end

local update_state = false

local script_vers = 2
local script_vers_text = "1.05"

local update_url = "https://raw.githubusercontent.com/akaYokoyama/sunshine-tool/main/update.ini" -- тут тоже свою ссылку
local update_path = getWorkingDirectory() .. "/update.ini" -- и тут свою ссылку

local script_url = "" -- тут свою ссылку
local script_path = thisScript().path

local functionslist = [[
Функции Sunshine Tools:
/spamm - Профлудить правилами/информацией
/fm [ID] - Быстрый мут
/fu [ID] - Быстрое увольнение]]

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
    local font = renderCreateFont("Arial", 10, 5)
	sampAddChatMessage(tag..'Успешно загружен! Настройка: {ffd500}/sunt', -1)
    sampRegisterChatCommand('sunt', shelper)
    sampRegisterChatCommand('spamm', prospam)
	sampRegisterChatCommand("fm", fm)
    sampRegisterChatCommand("fu", fu)
	sampRegisterChatCommand('nick', nick)
	sampRegisterChatCommand('fmember', members)
	
	downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage("Есть обновление! Версия: " .. updateIni.info.vers_text, -1)
                update_state = true
            end
            os.remove(update_path)
        end
    end)


    while true do
        wait(0)
        imgui.Process = window.v
		n_result, n_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if rp_invite.v then
            local result, target = getCharPlayerIsTargeting(playerHandle)
            if result then result, playerid = sampGetPlayerIdByCharHandle(target) end 
            if result and isKeyDown(0x5A) then 
                name = sampGetPlayerNickname(playerid) 
				sampAddChatMessage(tag..'Приглашаю человека в семью...', -1)	
                sampSendChat('/me занес человека в базу данных')
                wait(3000)
                sampSendChat('/finvite '..playerid)
                    wait(250)
            end
	    end
		if update_state then
            downloadUrlToFile(script_url, script_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage("Скрипт успешно обновлен!", -1)
                    thisScript():reload()
                end
            end)
           break
   end
end

function encda()
    commandslist.v = u8:encode(functionslist)
end

commandslist = imgui.ImBuffer(65536)

function fm(param)
    if fastmute.v then
	if state then
		state = false
	elseif not param:match('%d+') then
		sampAddChatMessage(tag..'Правильный ввод: /fm [ID]', -1)
	else
			id = tonumber(param)
			state = true
			sampSendChat('/fmute '..param..' '..u8:decode(mutetext.v), -1)
			state = false
    end
	end
end

function members()         
	lua_thread.create(function ()
		wait(100)	
		sampSendChat('/family')
		fmember = true
	end)
end

function fu(param)
	if state then
		state = false
	elseif not param:match('%d+') then
		sampAddChatMessage(tag..'Правильный ввод: /fu [ID]', -1)
	else
		id = tonumber(param)
		state = true
		lua_thread.create(function()
            sampSendChat('/me Удалил человека из базы данных ', -1)
            wait(1500)
           sampSendChat('/funinvite '..param, -1)
		end)
	end
			
	state = false
	end
--end

function prospam()
	if prospammer.v then
        sampSendChat('/fam '..u8:decode(prospamtext1.v), -1)
        lua_thread.create(function()
            wait(1500)
            sampSendChat('/fam '..u8:decode(prospamtext2.v), -1)
            wait(1500)
            sampSendChat('/fam '..u8:decode(prospamtext3.v), -1)
        end)
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

function shelper()
    window.v = not window.v 
end
function imgui.OnDrawFrame()
    if window.v then  
        imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(720, 468), imgui.Cond.FirstUseEver)
        imgui.Begin('Sunshine Tools', window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoMove)
		imgui.BeginChild("##Nick", imgui.ImVec2(702, 30), true)
		imgui.TextColoredRGB('{ffd500}Ваш ник: {FFFFFF}' ..sampGetPlayerNickname(n_id).. ' ['.. n_id ..'] | {ffd500}Ваш ранг: {FFFFFF}')
		imgui.EndChild()
        imgui.BeginChild("##MainWindow", imgui.ImVec2(350, 350), true)
            switch(mainIni.mode)
            {
                function ()
					imgui.TextDisabled(u8'                    Функции лидера/заместителей')
                    imgui.PushItemWidth(82.5)
                    imgui.TextQuestion(u8'Автоматически будет отправлять инвайт с отыгровкой. Активация: ПКМ + Z')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Быстрый инвайт', rp_invite)
                    imgui.PushItemWidth(120)
                    imgui.TextQuestion(u8'Быстрая выдача мута члену банды. Активация: /fm [ID]')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Быстрый мут', fastmute)
                    if fastmute.v then
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'Причина мута', mutetext)
                    end
                    imgui.TextQuestion(u8'Быстрое увольнение члена банды. Активация: /fu [ID]')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Быстрое увольнение', fastuval)
                    imgui.PushItemWidth(290)
                    imgui.TextQuestion(u8'Проспамить правилами/информацией. Активация: /spamm')
                    imgui.SameLine()
                    imgui.Checkbox(u8'Быстрый флудер', prospammer)
                    if prospammer.v then
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'##1', prospamtext1)
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'##2', prospamtext2)
                        imgui.NullText()
                        imgui.SameLine()
                        imgui.InputText(u8'##3', prospamtext3)
                    end
					imgui.Separator()
					imgui.TextDisabled(u8'                              Функции состава')
                end,
                function ()			
                    mainIni.settings.rp_invite = rp_invite.v 
                    mainIni.settings.fastmute = fastmute.v
                    mainIni.settings.fastuval = fastuval.v
                    mainIni.settings.prospammer = prospammer.v
                    mainIni.settings.prospamtext1 = u8:decode(prospamtext1.v)
                    mainIni.settings.prospamtext2 = u8:decode(prospamtext2.v)
                    mainIni.settings.prospamtext3 = u8:decode(prospamtext3.v)
                    mainIni.settings.mutetext = u8:decode(mutetext.v)
                    mainIni.settings.uvaltext = u8:decode(uvaltext.v)
                    inicfg.save(mainIni, 'sunshinetools.ini')
                    sampAddChatMessage(tag.."Настройки успешно сохранены.", -1)
                    addOneOffSound(0.0, 0.0, 0.0, 1138)
                    mainIni.mode = 1
                end
            }
        imgui.EndChild()
        imgui.SameLine()
        imgui.BeginChild("##bindercommand", imgui.ImVec2(-1, 350), true)
        imgui.InputTextMultiline("##infocommand", commandslist, imgui.ImVec2(-1, 150), imgui.InputTextFlags.AutoSelectAll + imgui.InputTextFlags.ReadOnly)
        imgui.PushItemWidth(100)
        imgui.Separator()
        imgui.Text(u8'Sunshine Tools for Namalsk RP')
        imgui.Text(u8'Версия скрипта: 0.1 Alpha')
        imgui.Text(u8'Автор: Yokoyama')
        imgui.Separator()
        if imgui.Button(u8'Тех.Поддержка',imgui.ImVec2(165,20)) then
            os.execute('start https://t.me/akaYokoyama')
        end
        imgui.SameLine()
        if imgui.Button(u8'BlastHack',imgui.ImVec2(165,20)) then
            os.execute('start https://www.blast.hk/members/451428/')
        end
        imgui.EndChild()
        if imgui.Button(u8"Сохранить настройки", imgui.ImVec2(351, 45)) then mainIni.mode = 2 end
        imgui.SameLine()
        if imgui.Button(u8'Перезагрузить скрипт',imgui.ImVec2(171,45)) then
            lua_thread.create(function ()
                wait(100)
                sampAddChatMessage(tag..'Скрипт перезагружается..', -1)
                thisScript():reload()
            end)
        end
        imgui.SameLine()
        if imgui.Button(u8'Закрыть',imgui.ImVec2(171,45)) then
            window.v = false
        end
        imgui.End()
        encda()
    end
end

function imgui.TextQuestion(text)
    imgui.TextDisabled('(?)')
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450)
        imgui.TextUnformatted(text)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.NullText(text)
    imgui.TextDisabled('    ')
    end

function switch(key)
    return function(tab)
        local current = tab[key] or tab['default']
        if type(current) == 'function' then current() end
    end
end

w, h = getScreenResolution()
imgui.Process = false



function sampev.onShowDialog(did, style, title, b1, b2, text)
	if did == 147 and fmember == true then
		sampSendDialogResponse(did, 1, 2, _)
		fmember = false
	end
end
--[[function sampev.onShowDialog(did, style, title, b1, b2, text)
	if title:find("Члены семьи онлайн") then
		if text:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))..'%[%d+%]%c(%d+)') then
			x =( text:match(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(PLAYER_PED)))..'%[%d+]%c(%d+)'))
			 if x == 7 then
			 print(Yes)
			 end
		end
	end
end]]

function imgui.TextColoredRGB(text)
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
            if text[0] then
                for i = 0, #text do
                    imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
                    imgui.SameLine(nil, 0)
                end
                imgui.NewLine()
            else imgui.Text(u8(w)) end
        end
    end

    render_text(text)
end

function yellow()
	local style  = imgui.GetStyle()
    local colors = style.Colors
    local clr    = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 10
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
    colors[clr.TitleBg]                = ImVec4(0.14, 0.14, 0.14, 0.81);
    colors[clr.TitleBgActive]          = ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[clr.MenuBarBg]              = ImVec4(0.20, 0.20, 0.20, 1.00);
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.39);
    colors[clr.ScrollbarGrab]          = ImVec4(0.36, 0.36, 0.36, 1.00);
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.18, 0.22, 0.25, 1.00);
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 1.00);
    colors[clr.CheckMark]              = ImVec4(1.00, 0.79, 0.00, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.84, 0.68, 0, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.Button]                 = ImVec4(0.76, 0.6, 0, 0.85)
    colors[clr.ButtonHovered]          = ImVec4(0.84, 0.68, 0, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.Header]                 = ImVec4(0.84, 0.68, 0, 0.75)
    colors[clr.HeaderHovered]          = ImVec4(0.84, 0.68, 0, 0.90)
    colors[clr.HeaderActive]           = ImVec4(0.92, 0.77, 0, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.76, 0.6, 0, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.84, 0.68, 0, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.92, 0.77, 0, 0.95)
    colors[clr.CloseButton]            = ImVec4(0.40, 0.39, 0.38, 0.16);
    colors[clr.CloseButtonHovered]     = ImVec4(0.40, 0.39, 0.38, 0.39);
    colors[clr.CloseButtonActive]      = ImVec4(0.40, 0.39, 0.38, 1.00);
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.53, 0.33, 0.99, 1.00);
    colors[clr.ModalWindowDarkening]   = ImVec4(0.26, 0.26, 0.26, 0.60);
end
yellow()