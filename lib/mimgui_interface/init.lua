local StoolMenu = {}
local mimgui_blur = require("mimgui_blur") -- прикольное размытие
local imgui = require("mimgui") -- имхуй
-- класс для работы с менюхой
StoolMenu.MenuManager = {}
StoolMenu.MenuManager.__index = StoolMenu.MenuManager

-- функция для объявления нового объекта этого типа
function StoolMenu.MenuManager:new()
    local menu = {
        isOpen = false, -- активно ли текущее окно
        idxSelection = 0, -- индекс\номер выбранной вкладки
        subMenuList = {} -- список подменю\вкладок ({fa_иконка, заголовок, описание})
    }
    setmetatable(menu, self)
    return menu -- возвращаем объект
end

-- функция для добавления ОДНОГО пункта меню в таблицу
function StoolMenu.MenuManager:addMenu(icon, title, desc)
    table.insert(self.subMenuList, {["icon"] = icon, ["title"] = title, ["desc"] = desc})
end
-- функция которая добавит ВСЕ пункты меню из другой таблицы в нашу
function StoolMenu.MenuManager:addMenuList(_table)
    for _, subMenu in ipairs(_table) do
        self:addMenu(unpack(subMenu))
    end
end
-- функция которая возвращает список менюшек
function StoolMenu.MenuManager:getMenus()
    return self.subMenuList
end
-- функция для выбора вкладки (делает вкладку активной), принимает номер\индекс, либо название
function StoolMenu.MenuManager:select(menu)
    if type(menu) == "number" then
        if rawget(self.subMenuList, menu) then
            self.idxSelection = menu
        end
    elseif type(menu) == "string" then
        for _, v in ipairs(self.subMenuList) do
            if v.title == menu then
                self.idxSelection = k
                break
            end
        end
    end
end
-- вернет true или false в зависимости выбрана ли эта вкладка
function StoolMenu.MenuManager:isSelected(menu_num)
    return self.idxSelection == menu_num
end

-- имплементация менюхи
function imgui.BeginStoolMenu(winTitle, winVariable, winFlags, menu, vertMenuW, blur_d)
    local vertMenuW = vertMenuW or 40 -- ширина хуйни с кнопками\вкладками
    -- убираем отступы
    imgui.PushStyleVarVec2(imgui.StyleVar.WindowPadding, imgui.ImVec2(0, 0))
    -- imgui.PushStyleColor(imgui.Col.WindowBg,                imgui.ImVec4(0.03,0.03,0.03,0.9))
    -- красим
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    -- создаем контейнер
    imgui.Begin(
        winTitle, -- ... в котором задаем название
        winVariable, -- перетягиваем переменную
        -- imgui.WindowFlags.NoTitleBar + (winFlags or 0)
        (winFlags or 0) -- и задаем флаги
    )
    imgui.PopStyleColor(1) -- отлично
    imgui.PopStyleVar() -- поработали

    local winSz = imgui.GetWindowSize()
    local winPs = imgui.GetWindowPos()
    local winDrawList = imgui.GetWindowDrawList()
    local blur_d = blur_d or 50 -- blur density \ интенсивность размытия
    -- применяем размытие, если стоит либа
    if mimgui_blur then
        mimgui_blur.apply(winDrawList, blur_d)
    end
    -- рисую прикольную полоску
    imgui.SetCursorPos(imgui.ImVec2(0, 0))
    local curScrPos = imgui.GetCursorScreenPos()
    winDrawList:AddRectFilled(
        curScrPos,
        imgui.ImVec2(curScrPos.x + vertMenuW, curScrPos.y + winSz.y),
        -- imgui.GetColorU32Vec4(imgui.GetStyle().Colors[imgui.Col.WindowBg]),
        imgui.GetColorU32Vec4(imgui.ImVec4(0, 0, 0, 0.4)),
        1,
        1 + 4
    )

    -- красивый тайтлбар
    imgui.SetNextWindowPos(imgui.ImVec2(winPs.x, winPs.y - 35))
    imgui.Begin(
        winTitle .. "::titlebar",
        nil,
        imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove +
            imgui.WindowFlags.NoResize
    )
    imgui.Text(winTitle)
    imgui.End()

    -- красивая кнопка закрытия
    imgui.SetNextWindowPos(imgui.ImVec2(winPs.x + winSz.x - 30, winPs.y - 30))

    imgui.PushStyleColor(imgui.Col.WindowBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.Begin(
        winTitle .. "::closebtnframe",
        nil,
        imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove +
            imgui.WindowFlags.NoResize
    )
    -- красим и полируем кнопку
    imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.9, 0.4, 0.4, 1))
    imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1, 1, 1, 0.1))
    imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1, 1, 1, 0.2))
    imgui.PushStyleVarFloat(imgui.StyleVar.FrameRounding, 20)
    imgui.PushStyleVarFloat(imgui.StyleVar.FrameBorderSize, 1)
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0.9, 0.4, 0.4, 0.5))
    if imgui.Button("##" .. winTitle .. "::closebutton", imgui.ImVec2(15, 15)) then
        print("close...")
        menu.isOpen = false
    end
    imgui.PopStyleVar(2)
    imgui.PopStyleColor(6)
    imgui.End()

    -- кнопки менюшек
    imgui.SetCursorPosY(5)
    for k, v in pairs(menu:getMenus()) do
        imgui.SetCursorPosX(5)
        imgui.PushStyleColor(
            imgui.Col.Button,
            menu.idxSelection == k and imgui.GetStyle().Colors[imgui.Col.ButtonActive] or imgui.ImVec4(0, 0, 0, 0)
        )
        if
            imgui.Button(
                v.icon or k,
                imgui.ImVec2(vertMenuW - 10, vertMenuW - 10) -- типа авторазмер кнопки
            )
         then
            menu:select(k) -- при нажатии на кнопку будет выбираться соответствующая ей вкладка
        end
        -- подсказка при наведении мыши
        if imgui.IsItemHovered() then
            imgui.BeginTooltip()
            imgui.Text(v.icon .. " " .. v.title)
            imgui.Text(v.desc)
            imgui.EndTooltip()
        end
        imgui.PopStyleColor()
    end

    -- отрисовка элементов внутри вкладки, дальше всё, до свидания
    imgui.SetCursorPos(imgui.ImVec2(vertMenuW + 5, 5))
    imgui.BeginChild(winTitle .. "::child", imgui.ImVec2(winSz.x - 5, winSz.y - 5), false)
end

-- закрываем объект менюшки
function imgui.EndStoolMenu()
    imgui.EndChild()
    imgui.End()
end

return StoolMenu
