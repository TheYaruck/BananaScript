-- LocalScript (поместить в StarterGui)
local Players = game:GetService("Players")

local UserInputService = game:GetService("UserInputService")

local TweenService = game:GetService("TweenService")

local RunService = game:GetService("RunService")


local localPlayer = Players.LocalPlayer

local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Singleton runtime: prevents duplicate loops and input listeners when the script is re-run.
local runtimeEnvironment = _G
if type(getgenv) == "function" then
    local ok, executorEnvironment = pcall(getgenv)
    if ok and type(executorEnvironment) == "table" then
        runtimeEnvironment = executorEnvironment
    end
end

local RUNTIME_KEY = "__FAE_HUB_VOID_RUNTIME"
local previousRuntime = runtimeEnvironment[RUNTIME_KEY]
if type(previousRuntime) == "table" and type(previousRuntime.Stop) == "function" then
    pcall(function()
        previousRuntime:Stop()
    end)
end

local runtime = {
    running = true,
    connections = {},
    cleanupCallbacks = {},
}

function runtime:Stop()
    if not self.running then
        return
    end
    self.running = false

    for _, connection in ipairs(self.connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(self.connections)

    for _, cleanup in ipairs(self.cleanupCallbacks) do
        pcall(cleanup)
    end
    table.clear(self.cleanupCallbacks)
end

runtimeEnvironment[RUNTIME_KEY] = runtime

local function trackConnect(signal, callback)
    local connection = signal:Connect(callback)
    if runtime.running then
        table.insert(runtime.connections, connection)
    else
        connection:Disconnect()
    end
    return connection
end
-- === 0. ОЧИСТКА СТАРОГО GUI ===
local OLD_GUI_NAME = "SpeedAndEspGui"

local existingGui = playerGui:FindFirstChild(OLD_GUI_NAME)

if existingGui then

    existingGui:Destroy()

end
-- Переменные состояния
local homeCFrame = nil

local espEnabled = false

local antiRagdollEnabled = false

local reachEnabled = false


local fastStealEggEnabled = false
local autoStealEnabled = false
-- Optional restrictive mode: disables instant teleports and the powerful-hit action.
-- This does not bypass server checks; it prevents the riskiest local actions.
local safeModeEnabled = false
local autoStealWaitingForClear = false
local autoStealClearSince = nil
local autoStealLastTriggerAt = 0
local wasCarryingEgg = false
local candidateSince = nil

-- Auto-Steal only accepts a NEW object added under Workspace.Carried after it is enabled.
-- Old pets/visuals already present at activation are baselined and cannot trigger it.
local autoStealKnownCarriedInstances = setmetatable({}, { __mode = "k" })
local autoStealFreshCarryParts = setmetatable({}, { __mode = "k" })
local autoStealMarkerWasActive = false
local autoStealMarkerFresh = false

local selectedTargetPlayer = nil

local excludedFriends = {}

local activeEspObjects = {}
-- === 1. ИНТЕРФЕЙС FAE HUB ===
local screenGui = Instance.new("ScreenGui")

screenGui.Name = OLD_GUI_NAME

screenGui.ResetOnSpawn = false
-- Global ZIndex ensures the separate settings window remains clickable above the main panel.
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

screenGui.Parent = playerGui

-- Temporary Fast Steal status toast. It replaces persistent button status messages.
local stealToastSerial = 0
local activeStealToastTween = nil
local stealToastFrame = Instance.new("Frame")
stealToastFrame.Name = "StealStatusToast"
stealToastFrame.AnchorPoint = Vector2.new(0.5, 0)
stealToastFrame.Size = UDim2.new(0, 360, 0, 54)
stealToastFrame.Position = UDim2.new(0.5, 0, 0, 18)
stealToastFrame.BackgroundColor3 = Color3.fromRGB(25, 24, 38)
stealToastFrame.BackgroundTransparency = 0.04
stealToastFrame.BorderSizePixel = 0
stealToastFrame.Visible = false
stealToastFrame.ZIndex = 100
stealToastFrame.Parent = screenGui

local stealToastCorner = Instance.new("UICorner")
stealToastCorner.CornerRadius = UDim.new(0, 10)
stealToastCorner.Parent = stealToastFrame

local stealToastStroke = Instance.new("UIStroke")
stealToastStroke.Color = Color3.fromRGB(151, 104, 255)
stealToastStroke.Thickness = 1.25
stealToastStroke.Transparency = 0.15
stealToastStroke.Parent = stealToastFrame

local stealToastLabel = Instance.new("TextLabel")
stealToastLabel.Name = "Message"
stealToastLabel.Size = UDim2.new(1, -22, 1, -8)
stealToastLabel.Position = UDim2.new(0, 11, 0, 4)
stealToastLabel.BackgroundTransparency = 1
stealToastLabel.Text = ""
stealToastLabel.TextColor3 = Color3.fromRGB(248, 246, 255)
stealToastLabel.TextSize = 13
stealToastLabel.Font = Enum.Font.GothamSemibold
stealToastLabel.TextWrapped = true
stealToastLabel.TextXAlignment = Enum.TextXAlignment.Center
stealToastLabel.TextYAlignment = Enum.TextYAlignment.Center
stealToastLabel.ZIndex = 101
stealToastLabel.Parent = stealToastFrame

local function showStealToast(message, isSuccess)
    stealToastSerial += 1
    local thisSerial = stealToastSerial

    if activeStealToastTween then
        pcall(function() activeStealToastTween:Cancel() end)
        activeStealToastTween = nil
    end

    stealToastLabel.Text = tostring(message or "")
    stealToastFrame.BackgroundColor3 = isSuccess
        and Color3.fromRGB(24, 43, 37)
        or Color3.fromRGB(45, 29, 38)
    stealToastStroke.Color = isSuccess
        and Color3.fromRGB(70, 205, 135)
        or Color3.fromRGB(224, 103, 125)
    stealToastFrame.BackgroundTransparency = 0.04
    stealToastLabel.TextTransparency = 0
    stealToastStroke.Transparency = 0.15
    stealToastFrame.Visible = true

    task.delay(4.5, function()
        if thisSerial ~= stealToastSerial or not stealToastFrame.Parent then
            return
        end
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        activeStealToastTween = TweenService:Create(stealToastFrame, tweenInfo, {
            BackgroundTransparency = 1,
        })
        activeStealToastTween:Play()
        TweenService:Create(stealToastLabel, tweenInfo, {TextTransparency = 1}):Play()
        TweenService:Create(stealToastStroke, tweenInfo, {Transparency = 1}):Play()
        activeStealToastTween.Completed:Wait()
        if thisSerial == stealToastSerial and stealToastFrame.Parent then
            stealToastFrame.Visible = false
            activeStealToastTween = nil
        end
    end)
end

-- Кнопка Скрытия/Открытия меню
local toggleGuiBtn = Instance.new("TextButton")

toggleGuiBtn.Name = "ToggleGuiBtn"

toggleGuiBtn.Size = UDim2.new(0, 116, 0, 34)

toggleGuiBtn.Position = UDim2.new(1, -132, 0, 14)

toggleGuiBtn.BackgroundColor3 = Color3.fromRGB(24, 23, 36)

toggleGuiBtn.BorderSizePixel = 0

toggleGuiBtn.Text = "◈  VOID HUB"

toggleGuiBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

toggleGuiBtn.TextSize = 13

toggleGuiBtn.Font = Enum.Font.GothamBold

toggleGuiBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")

toggleCorner.CornerRadius = UDim.new(0, 8)

toggleCorner.Parent = toggleGuiBtn

local toggleStroke = Instance.new("UIStroke")

toggleStroke.Color = Color3.fromRGB(151, 104, 255)

toggleStroke.Thickness = 1.25

toggleStroke.Parent = toggleGuiBtn
-- Основная панель
local mainFrame = Instance.new("Frame")

mainFrame.Name = "MainFrame"

mainFrame.Size = UDim2.new(0, 620, 0, 455)

mainFrame.Position = UDim2.new(1, -635, 0, 58)

mainFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 21)

mainFrame.BorderSizePixel = 0

mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")

corner.CornerRadius = UDim.new(0, 16)

corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")

stroke.Color = Color3.fromRGB(151, 104, 255)

stroke.Thickness = 1.5

stroke.Parent = mainFrame

local function toggleMenu()

    mainFrame.Visible = not mainFrame.Visible

end

trackConnect(toggleGuiBtn.MouseButton1Click, toggleMenu)

trackConnect(UserInputService.InputBegan, function(input, gpe)

    if not gpe and input.KeyCode == Enum.KeyCode.RightShift then

        toggleMenu()

    end

end)
-- Шапка
local titleLabel = Instance.new("TextLabel")

titleLabel.Name = "TitleLabel"

titleLabel.Size = UDim2.new(1, 0, 0, 45)

titleLabel.BackgroundColor3 = Color3.fromRGB(25, 24, 38)

titleLabel.BorderSizePixel = 0

titleLabel.Text = "◈  VOID  /  FAE HUB"

titleLabel.TextColor3 = Color3.fromRGB(242, 238, 255)

titleLabel.TextSize = 16

titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = mainFrame

local titlePadding = Instance.new("UIPadding")
titlePadding.PaddingLeft = UDim.new(0, 0)
titlePadding.Parent = titleLabel

local titleCorner = Instance.new("UICorner")

titleCorner.CornerRadius = UDim.new(0, 16)

titleCorner.Parent = titleLabel

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 8)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 55)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(238, 230, 255)
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleLabel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local settingsGearBtn = Instance.new("TextButton")
settingsGearBtn.Name = "SettingsGearBtn"
settingsGearBtn.Size = UDim2.new(0, 28, 0, 28)
settingsGearBtn.Position = UDim2.new(0, 8, 0, 8)
settingsGearBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 55)
settingsGearBtn.BorderSizePixel = 0
settingsGearBtn.Text = "⚙"
settingsGearBtn.TextColor3 = Color3.fromRGB(238, 230, 255)
settingsGearBtn.TextSize = 17
settingsGearBtn.Font = Enum.Font.GothamBold
settingsGearBtn.AutoButtonColor = true
settingsGearBtn.ZIndex = closeBtn.ZIndex + 1
settingsGearBtn.Parent = titleLabel

local settingsGearCorner = Instance.new("UICorner")
settingsGearCorner.CornerRadius = UDim.new(0, 8)
settingsGearCorner.Parent = settingsGearBtn

local settingsGearStroke = Instance.new("UIStroke")
settingsGearStroke.Color = Color3.fromRGB(151, 104, 255)
settingsGearStroke.Thickness = 1
settingsGearStroke.Transparency = 0.2
settingsGearStroke.Parent = settingsGearBtn

trackConnect(settingsGearBtn.MouseEnter, function()
    TweenService:Create(settingsGearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(70, 48, 95)}):Play()
end)
trackConnect(settingsGearBtn.MouseLeave, function()
    TweenService:Create(settingsGearBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 35, 55)}):Play()
end)

trackConnect(closeBtn.MouseButton1Click, function()
    mainFrame.Visible = false
end)
-- Перетаскивание
local dragging, dragStart, startPos

local function pointInsideGui(guiObject, point)
    if not guiObject or not guiObject.Visible then return false end
    local pos = guiObject.AbsolutePosition
    local size = guiObject.AbsoluteSize
    return point.X >= pos.X and point.X <= pos.X + size.X
        and point.Y >= pos.Y and point.Y <= pos.Y + size.Y
end

trackConnect(titleLabel.InputBegan, function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if pointInsideGui(closeBtn, input.Position) or pointInsideGui(settingsGearBtn, input.Position) then
            return
        end

        dragging = true

        dragStart = input.Position

        startPos = mainFrame.Position

        trackConnect(input.Changed, function()

            if input.UserInputState == Enum.UserInputState.End then

                dragging = false

            end

        end)

    end

end)

trackConnect(UserInputService.InputChanged, function(input)

    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then

        local delta = input.Position - dragStart

        mainFrame.Position = UDim2.new(

            startPos.X.Scale,

            startPos.X.Offset + delta.X,

            startPos.Y.Scale,

            startPos.Y.Offset + delta.Y

        )

    end

end)
-- Колонки
local leftScroll = Instance.new("ScrollingFrame")

leftScroll.Size = UDim2.new(0, 250, 1, -58)

leftScroll.Position = UDim2.new(0, 10, 0, 52)

leftScroll.BackgroundTransparency = 1

leftScroll.BorderSizePixel = 0

leftScroll.ScrollBarThickness = 4

leftScroll.ScrollBarImageColor3 = Color3.fromRGB(151, 104, 255)

leftScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

leftScroll.Parent = mainFrame

local leftLayout = Instance.new("UIListLayout")

leftLayout.SortOrder = Enum.SortOrder.LayoutOrder

leftLayout.Padding = UDim.new(0, 6)

leftLayout.Parent = leftScroll

local rightFrame = Instance.new("Frame")

rightFrame.Size = UDim2.new(0, 330, 1, -58)

rightFrame.Position = UDim2.new(0, 270, 0, 52)

rightFrame.BackgroundTransparency = 1

rightFrame.Parent = mainFrame

local rightLayout = Instance.new("UIListLayout")

rightLayout.SortOrder = Enum.SortOrder.LayoutOrder

rightLayout.Padding = UDim.new(0, 6)

rightLayout.Parent = rightFrame

local function createCategoryHeader(text, parent, order)

    local header = Instance.new("TextLabel")

    header.Size = UDim2.new(1, 0, 0, 22)

    header.BackgroundTransparency = 1

    header.Text = "◆  " .. text

    header.TextColor3 = Color3.fromRGB(176, 158, 224)

    header.TextSize = 12

    header.Font = Enum.Font.GothamBold

    header.LayoutOrder = order

    header.Parent = parent

end

local THEME_BASE = Color3.fromRGB(29, 29, 44)
local THEME_HOVER = Color3.fromRGB(47, 39, 69)
local THEME_ACTIVE = Color3.fromRGB(91, 63, 145)

local function createButton(name, text, baseColor, hoverColor, parent, order)
    baseColor = THEME_BASE
    hoverColor = THEME_HOVER

    local btn = Instance.new("TextButton")

    btn.Name = name

    btn.Size = UDim2.new(1, 0, 0, 34)
    if parent:GetAttribute("FAEHighLayer") then
        btn.ZIndex = 32
    end

    btn.BackgroundColor3 = baseColor

    btn.BorderSizePixel = 0

    btn.Text = text

    btn.TextColor3 = Color3.fromRGB(255, 255, 255)

    btn.TextSize = 12

    btn.Font = Enum.Font.GothamSemibold

    btn.LayoutOrder = order

    btn.Parent = parent

    local btnCorner = Instance.new("UICorner")

    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Color3.fromRGB(107, 83, 151)
    btnStroke.Transparency = 0.72
    btnStroke.Thickness = 1
    btnStroke.Parent = btn

    trackConnect(btn.MouseEnter, function()

        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()

    end)

    trackConnect(btn.MouseLeave, function()

        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = baseColor}):Play()

    end)

    return btn

end

-- === ОТДЕЛЬНОЕ ОКНО НАСТРОЕК: открывается шестерёнкой в шапке FAE HUB ===
local settingsFrame = Instance.new("Frame")
settingsFrame.Name = "SettingsWindow"
-- Extra room at the bottom for a separated, selectable, read-only credits section.
settingsFrame.Size = UDim2.new(0, 300, 0, 228)
settingsFrame.Position = UDim2.new(1, -970, 0, 58)
settingsFrame.BackgroundColor3 = Color3.fromRGB(13, 14, 21)
settingsFrame.BorderSizePixel = 0
settingsFrame.Visible = false
settingsFrame.ZIndex = 50
settingsFrame.Parent = screenGui

local settingsCorner = Instance.new("UICorner")
settingsCorner.CornerRadius = UDim.new(0, 14)
settingsCorner.Parent = settingsFrame

local settingsStroke = Instance.new("UIStroke")
settingsStroke.Color = Color3.fromRGB(151, 104, 255)
settingsStroke.Thickness = 1.5
settingsStroke.Parent = settingsFrame

local settingsTitle = Instance.new("TextLabel")
settingsTitle.Name = "SettingsTitle"
settingsTitle.Size = UDim2.new(1, 0, 0, 40)
settingsTitle.BackgroundColor3 = Color3.fromRGB(25, 24, 38)
settingsTitle.BorderSizePixel = 0
settingsTitle.Text = "⚙  НАСТРОЙКИ FAE HUB"
settingsTitle.TextColor3 = Color3.fromRGB(242, 238, 255)
settingsTitle.TextSize = 13
settingsTitle.Font = Enum.Font.GothamBold
settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
settingsTitle.ZIndex = 51
settingsTitle.Parent = settingsFrame

local settingsTitlePadding = Instance.new("UIPadding")
settingsTitlePadding.PaddingLeft = UDim.new(0, 12)
settingsTitlePadding.Parent = settingsTitle

local settingsTitleCorner = Instance.new("UICorner")
settingsTitleCorner.CornerRadius = UDim.new(0, 14)
settingsTitleCorner.Parent = settingsTitle

local settingsCloseBtn = Instance.new("TextButton")
settingsCloseBtn.Name = "SettingsCloseBtn"
settingsCloseBtn.Size = UDim2.new(0, 26, 0, 26)
settingsCloseBtn.Position = UDim2.new(1, -33, 0, 7)
settingsCloseBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 55)
settingsCloseBtn.BorderSizePixel = 0
settingsCloseBtn.Text = "×"
settingsCloseBtn.TextColor3 = Color3.fromRGB(238, 230, 255)
settingsCloseBtn.TextSize = 21
settingsCloseBtn.Font = Enum.Font.GothamBold
settingsCloseBtn.ZIndex = 52
settingsCloseBtn.Parent = settingsTitle

local settingsCloseCorner = Instance.new("UICorner")
settingsCloseCorner.CornerRadius = UDim.new(0, 7)
settingsCloseCorner.Parent = settingsCloseBtn

local settingsContent = Instance.new("Frame")
settingsContent.Name = "SettingsContent"
settingsContent.Size = UDim2.new(1, -20, 0, 172)
settingsContent.Position = UDim2.new(0, 10, 0, 48)
settingsContent.BackgroundTransparency = 1
settingsContent.ZIndex = 51
settingsContent:SetAttribute("FAEHighLayer", true)
settingsContent.Parent = settingsFrame

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Padding = UDim.new(0, 8)
settingsLayout.Parent = settingsContent

trackConnect(settingsGearBtn.MouseButton1Click, function()
    settingsFrame.Visible = not settingsFrame.Visible
end)

trackConnect(settingsCloseBtn.MouseButton1Click, function()
    settingsFrame.Visible = false
end)

-- Settings window can be dragged independently by its title bar.
local settingsDragging = false
local settingsDragStart = nil
local settingsStartPos = nil

trackConnect(settingsTitle.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if pointInsideGui(settingsCloseBtn, input.Position) then return end
        settingsDragging = true
        settingsDragStart = input.Position
        settingsStartPos = settingsFrame.Position
    end
end)

trackConnect(UserInputService.InputChanged, function(input)
    if settingsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - settingsDragStart
        settingsFrame.Position = UDim2.new(
            settingsStartPos.X.Scale, settingsStartPos.X.Offset + delta.X,
            settingsStartPos.Y.Scale, settingsStartPos.Y.Offset + delta.Y
        )
    end
end)

trackConnect(UserInputService.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        settingsDragging = false
    end
end)

local btnNoAutoTeleport = createButton(
    "BtnNoAutoTeleport",
    "🛡️ Безопасный режим: ВЫКЛ",
    THEME_BASE,
    THEME_HOVER,
    settingsContent,
    1
)
btnNoAutoTeleport.ZIndex = 52
btnNoAutoTeleport.Size = UDim2.new(1, 0, 0, 36)

local btnEggDiagnostic = createButton(
    "BtnEggDiagnostic",
    "🔍 Диагностика яйца / пета",
    THEME_BASE,
    THEME_HOVER,
    settingsContent,
    2
)
btnEggDiagnostic.ZIndex = 52
btnEggDiagnostic.Size = UDim2.new(1, 0, 0, 36)

-- === READ-ONLY, SELECTABLE CREDITS SECTION ===
-- TextBox is used so the player can focus, select and copy the text.
-- TextEditable=false prevents changes through the UI. The runtime guard below
-- also restores the fixed attribution if another running script changes Text.
local creditsHeader = Instance.new("TextLabel")
creditsHeader.Name = "CreditsSectionHeader"
creditsHeader.Size = UDim2.new(1, 0, 0, 14)
creditsHeader.BackgroundTransparency = 1
creditsHeader.BorderSizePixel = 0
creditsHeader.Text = "СВЕДЕНИЯ"
creditsHeader.TextColor3 = Color3.fromRGB(150, 143, 171)
creditsHeader.TextSize = 10
creditsHeader.Font = Enum.Font.GothamBold
creditsHeader.TextXAlignment = Enum.TextXAlignment.Left
creditsHeader.LayoutOrder = 3
creditsHeader.ZIndex = 52
creditsHeader.Parent = settingsContent

local creditsDivider = Instance.new("Frame")
creditsDivider.Name = "CreditsDivider"
creditsDivider.Size = UDim2.new(1, 0, 0, 1)
creditsDivider.BackgroundColor3 = Color3.fromRGB(69, 58, 91)
creditsDivider.BorderSizePixel = 0
creditsDivider.LayoutOrder = 4
creditsDivider.ZIndex = 52
creditsDivider.Parent = settingsContent

local creditsSitesText = "chatgpt.com / gemini.google.com"
local creditsSitesBox = Instance.new("TextBox")
creditsSitesBox.Name = "CreditsSitesReadOnly"
creditsSitesBox.Size = UDim2.new(1, 0, 0, 20)
creditsSitesBox.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
creditsSitesBox.BackgroundTransparency = 0.15
creditsSitesBox.BorderSizePixel = 0
creditsSitesBox.ClearTextOnFocus = false
creditsSitesBox.TextEditable = false
creditsSitesBox.MultiLine = false
creditsSitesBox.TextWrapped = false
creditsSitesBox.Text = creditsSitesText
creditsSitesBox.TextColor3 = Color3.fromRGB(177, 171, 194)
creditsSitesBox.TextSize = 10
creditsSitesBox.Font = Enum.Font.Gotham
creditsSitesBox.TextXAlignment = Enum.TextXAlignment.Center
creditsSitesBox.TextYAlignment = Enum.TextYAlignment.Center
creditsSitesBox.LayoutOrder = 5
creditsSitesBox.ZIndex = 52
creditsSitesBox.Parent = settingsContent

local creditsSitesCorner = Instance.new("UICorner")
creditsSitesCorner.CornerRadius = UDim.new(0, 5)
creditsSitesCorner.Parent = creditsSitesBox

local creditsText = "Started by Gemini, finished by ChatGPT"
local creditsBox = Instance.new("TextBox")
creditsBox.Name = "CreditsAttributionReadOnly"
creditsBox.Size = UDim2.new(1, 0, 0, 20)
creditsBox.BackgroundColor3 = Color3.fromRGB(19, 19, 29)
creditsBox.BackgroundTransparency = 0.15
creditsBox.BorderSizePixel = 0
creditsBox.ClearTextOnFocus = false
creditsBox.TextEditable = false
creditsBox.MultiLine = false
creditsBox.TextWrapped = false
creditsBox.Text = creditsText
creditsBox.TextColor3 = Color3.fromRGB(150, 143, 171)
creditsBox.TextSize = 9
creditsBox.Font = Enum.Font.Gotham
creditsBox.TextXAlignment = Enum.TextXAlignment.Center
creditsBox.TextYAlignment = Enum.TextYAlignment.Center
creditsBox.LayoutOrder = 6
creditsBox.ZIndex = 52
creditsBox.Parent = settingsContent

local creditsBoxCorner = Instance.new("UICorner")
creditsBoxCorner.CornerRadius = UDim.new(0, 5)
creditsBoxCorner.Parent = creditsBox

local function keepCreditTextFixed(textBox, fixedText)
    trackConnect(textBox:GetPropertyChangedSignal("Text"), function()
        if textBox.Parent and textBox.Text ~= fixedText then
            textBox.Text = fixedText
        end
    end)
end

keepCreditTextFixed(creditsSitesBox, creditsSitesText)
keepCreditTextFixed(creditsBox, creditsText)

-- === ЛЕВАЯ КОЛОНКА ===
createCategoryHeader("👤 КЛАСС: ИГРОК", leftScroll, 1)

local btn32   = createButton("Btn32",   "⚡ Скорость: 32",       Color3.fromRGB(46, 204, 113), Color3.fromRGB(56, 214, 123), leftScroll, 2)

local btn8    = createButton("Btn8",    "🐢 Скорость: 8",        Color3.fromRGB(231, 76, 60),  Color3.fromRGB(241, 86, 70),  leftScroll, 3)

local btnRag  = createButton("BtnRag",  "🛡️ Анти-рагдолл: ВЫКЛ", Color3.fromRGB(52, 73, 94),   Color3.fromRGB(62, 83, 104), leftScroll, 4)

-- Fast Steal sits between the Player and Teleport categories.
createCategoryHeader("🥚🐾 FAST STEAL EGG / PET", leftScroll, 6)

local btnFastStealEgg = createButton(
    "BtnFastStealEgg",
    "🥚🐾 Fast Steal Egg/Pet: " .. (fastStealEggEnabled and "ВКЛ" or "ВЫКЛ"),
    THEME_BASE,
    THEME_HOVER,
    leftScroll,
    7
)

local btnSetBase = createButton(
    "BtnSetEggBase",
    "📍 Запомнить дом / базу",
    THEME_BASE,
    THEME_HOVER,
    leftScroll,
    8
)

local btnAutoSteal = createButton(
    "BtnAutoSteal",
    "🔁 Авто-стил: ВЫКЛ",
    THEME_BASE,
    THEME_HOVER,
    leftScroll,
    9
)

createCategoryHeader("🌀 КЛАСС: ТЕЛЕПОРТ", leftScroll, 10)

local btnSave = createButton("BtnSave", "📌 Сохранить точку дома",   Color3.fromRGB(241, 196, 15), Color3.fromRGB(251, 206, 25), leftScroll, 11)

local btnTp   = createButton("BtnTp",   "🌀 ТП домой",   Color3.fromRGB(155, 89, 182), Color3.fromRGB(165, 99, 192), leftScroll, 12)

createCategoryHeader("👁️ ВИЗУАЛЫ", leftScroll, 13)

local btnEsp   = createButton("BtnEsp",  "👁️ Подсветка (ESP): " .. (espEnabled and "ВКЛ" or "ВЫКЛ"), espEnabled and THEME_ACTIVE or THEME_BASE, Color3.fromRGB(62, 162, 229), leftScroll, 14)

btnEsp.BackgroundColor3 = espEnabled and THEME_ACTIVE or THEME_BASE
btnFastStealEgg.BackgroundColor3 = fastStealEggEnabled and THEME_ACTIVE or THEME_BASE
btnAutoSteal.BackgroundColor3 = autoStealEnabled and THEME_ACTIVE or THEME_BASE
btnNoAutoTeleport.BackgroundColor3 = safeModeEnabled and THEME_ACTIVE or THEME_BASE
-- Preserve the ON color after the generic button hover animation ends.
trackConnect(btnAutoSteal.MouseLeave, function()
    local restingColor = autoStealEnabled and THEME_ACTIVE or THEME_BASE
    TweenService:Create(btnAutoSteal, TweenInfo.new(0.2), {BackgroundColor3 = restingColor}):Play()
end)
-- Синхронизация текста кнопки анти-рагдолла при загрузке
if antiRagdollEnabled then

    btnRag.Text = "🛡️ Анти-рагдолл: ВКЛ"

    btnRag.BackgroundColor3 = THEME_ACTIVE

end
-- === ПРАВАЯ КОЛОНКА ===
createCategoryHeader("🎯 БОЙ", rightFrame, 1)

local btnReach   = createButton("BtnReach",   "🎯 Мощный Удар: " .. (reachEnabled and "ВКЛ" or "ВЫКЛ"), reachEnabled and THEME_ACTIVE or THEME_BASE, Color3.fromRGB(202, 67, 53), rightFrame, 2)

btnReach.BackgroundColor3 = reachEnabled and THEME_ACTIVE or THEME_BASE

createCategoryHeader("👥 СПИСОК ИГРОКОВ И ЦЕЛЕЙ", rightFrame, 3)

local playerListContainer = Instance.new("Frame")

playerListContainer.Size = UDim2.new(1, 0, 0, 260)

playerListContainer.BackgroundColor3 = Color3.fromRGB(17, 17, 27)

playerListContainer.BorderSizePixel = 0

playerListContainer.LayoutOrder = 4

playerListContainer.Parent = rightFrame

local containerCorner = Instance.new("UICorner")

containerCorner.CornerRadius = UDim.new(0, 10)

containerCorner.Parent = playerListContainer

local playerScroll = Instance.new("ScrollingFrame")

playerScroll.Size = UDim2.new(1, -6, 1, -6)

playerScroll.Position = UDim2.new(0, 3, 0, 3)

playerScroll.BackgroundTransparency = 1

playerScroll.BorderSizePixel = 0

playerScroll.ScrollBarThickness = 4

playerScroll.ScrollBarImageColor3 = Color3.fromRGB(151, 104, 255)

playerScroll.Parent = playerListContainer

local playerLayout = Instance.new("UIListLayout")

playerLayout.SortOrder = Enum.SortOrder.LayoutOrder

playerLayout.Padding = UDim.new(0, 4)

playerLayout.Parent = playerScroll

local function renderPlayerList()

    for _, child in ipairs(playerScroll:GetChildren()) do

        if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end

    end

    local order = 1

    local autoBtn = Instance.new("TextButton")

    autoBtn.Size = UDim2.new(1, 0, 0, 28)

    autoBtn.BackgroundColor3 = (selectedTargetPlayer == nil) and Color3.fromRGB(151, 104, 255) or Color3.fromRGB(28, 30, 44)

    autoBtn.BorderSizePixel = 0

    autoBtn.Text = "⚡ [ Ближайший ИГРОК ]"

    autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    autoBtn.TextSize = 10

    autoBtn.Font = Enum.Font.GothamBold

    autoBtn.LayoutOrder = order

    autoBtn.Parent = playerScroll

    order = order + 1

    local autoCorner = Instance.new("UICorner")

    autoCorner.CornerRadius = UDim.new(0, 6)

    autoCorner.Parent = autoBtn

    trackConnect(autoBtn.MouseButton1Click, function()

        selectedTargetPlayer = nil

        renderPlayerList()

    end)

    for _, p in ipairs(Players:GetPlayers()) do

        if p.UserId ~= localPlayer.UserId then

            local isFriend = excludedFriends[p] == true

            local itemFrame = Instance.new("Frame")

            itemFrame.Size = UDim2.new(1, 0, 0, 28)

            itemFrame.BackgroundTransparency = 1

            itemFrame.LayoutOrder = order

            itemFrame.Parent = playerScroll

            order = order + 1

            local selectBtn = Instance.new("TextButton")

            selectBtn.Size = UDim2.new(0.48, 0, 1, 0)

            selectBtn.BackgroundColor3 = (selectedTargetPlayer == p) and Color3.fromRGB(151, 104, 255) or (isFriend and Color3.fromRGB(39, 174, 96) or Color3.fromRGB(28, 30, 44))

            selectBtn.BorderSizePixel = 0

            selectBtn.Text = (isFriend and "🤝 " or "⚠️ ") .. p.DisplayName

            selectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

            selectBtn.TextSize = 10

            selectBtn.Font = Enum.Font.GothamSemibold

            selectBtn.Parent = itemFrame

            local sCorner = Instance.new("UICorner")

            sCorner.CornerRadius = UDim.new(0, 6)

            sCorner.Parent = selectBtn

            trackConnect(selectBtn.MouseButton1Click, function()

                selectedTargetPlayer = p

                renderPlayerList()

            end)

            local tpToBtn = Instance.new("TextButton")

            tpToBtn.Size = UDim2.new(0.22, 0, 1, 0)

            tpToBtn.Position = UDim2.new(0.50, 0, 0, 0)

            tpToBtn.BackgroundColor3 = Color3.fromRGB(142, 68, 173)

            tpToBtn.BorderSizePixel = 0

            tpToBtn.Text = "🌀 ТП"

            tpToBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

            tpToBtn.TextSize = 9
            tpToBtn.Font = Enum.Font.GothamBold

            tpToBtn.Parent = itemFrame

            local tCorner = Instance.new("UICorner")

            tCorner.CornerRadius = UDim.new(0, 6)

            tCorner.Parent = tpToBtn

            trackConnect(tpToBtn.MouseButton1Click, function()
                if safeModeEnabled then
                    showStealToast("Безопасный режим: телепорт к игрокам отключён", false)
                    return
                end

                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    localPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                end
            end)

            local friendBtn = Instance.new("TextButton")

            friendBtn.Size = UDim2.new(0.26, 0, 1, 0)

            friendBtn.Position = UDim2.new(0.74, 0, 0, 0)

            friendBtn.BackgroundColor3 = isFriend and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(52, 73, 94)

            friendBtn.BorderSizePixel = 0

            friendBtn.Text = isFriend and "✅ Друг" or "🤝 Друг"

            friendBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

            friendBtn.TextSize = 9

            friendBtn.Font = Enum.Font.GothamBold

            friendBtn.Parent = itemFrame

            local exCorner = Instance.new("UICorner")

            exCorner.CornerRadius = UDim.new(0, 6)

            exCorner.Parent = friendBtn

            trackConnect(friendBtn.MouseButton1Click, function()

                excludedFriends[p] = not isFriend

                renderPlayerList()

            end)

        end

    end

    local allBtn = Instance.new("TextButton")

    allBtn.Size = UDim2.new(1, 0, 0, 28)

    allBtn.BackgroundColor3 = (selectedTargetPlayer == "ALL") and Color3.fromRGB(231, 76, 60) or Color3.fromRGB(150, 40, 40)

    allBtn.BorderSizePixel = 0

    allBtn.Text = "💥 УДАРИТЬ ВСЕХ (КРОМЕ ДРУЗЕЙ)"

    allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

    allBtn.TextSize = 10

    allBtn.Font = Enum.Font.GothamBold

    allBtn.LayoutOrder = order

    allBtn.Parent = playerScroll

    local allCorner = Instance.new("UICorner")

    allCorner.CornerRadius = UDim.new(0, 6)

    allCorner.Parent = allBtn

    trackConnect(allBtn.MouseButton1Click, function()

        selectedTargetPlayer = "ALL"

        renderPlayerList()

    end)

    playerScroll.CanvasSize = UDim2.new(0, 0, 0, (order + 1) * 32)

end

renderPlayerList()

trackConnect(Players.PlayerAdded, function()
    task.defer(renderPlayerList)
end)

trackConnect(Players.PlayerRemoving, function(plr)

    if selectedTargetPlayer == plr then selectedTargetPlayer = nil end

    excludedFriends[plr] = nil

    renderPlayerList()

end)
-- === 2. ФУНКЦИОНАЛ ИГРОКА ===
-- The selected speed is reapplied once when the local character respawns.
-- The game server may still override client-side WalkSpeed changes.
local selectedWalkSpeed = nil

local function setSpeed(speed)
    if type(speed) ~= "number" or speed <= 0 then
        return
    end

    selectedWalkSpeed = speed

    local character = localPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = selectedWalkSpeed
    end
end

-- Anti-ragdoll: disable the Humanoid ragdoll-related states locally and
-- remember their previous values so the toggle can restore them safely.
-- This does not remove server-created constraints or override server authority.
local ANTI_RAGDOLL_STATES = {
    Enum.HumanoidStateType.Ragdoll,
    Enum.HumanoidStateType.FallingDown,
    Enum.HumanoidStateType.PlatformStanding,
}

local antiRagdollPreviousStates = setmetatable({}, { __mode = "k" })

local function applyAntiRagdoll(character, enabled)
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return
    end

    if enabled then
        if not antiRagdollPreviousStates[humanoid] then
            local previousStates = {}
            for _, state in ipairs(ANTI_RAGDOLL_STATES) do
                local ok, wasEnabled = pcall(function()
                    return humanoid:GetStateEnabled(state)
                end)
                if ok then
                    previousStates[state] = wasEnabled
                end
            end
            antiRagdollPreviousStates[humanoid] = previousStates
        end

        local currentState = humanoid:GetState()
        for _, state in ipairs(ANTI_RAGDOLL_STATES) do
            pcall(function()
                humanoid:SetStateEnabled(state, false)
            end)
        end

        if currentState == Enum.HumanoidStateType.Ragdoll
            or currentState == Enum.HumanoidStateType.FallingDown
            or currentState == Enum.HumanoidStateType.PlatformStanding
            or humanoid.PlatformStand then
            pcall(function()
                humanoid.PlatformStand = false
                humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            end)
        end
    else
        local previousStates = antiRagdollPreviousStates[humanoid]
        if previousStates then
            for state, wasEnabled in pairs(previousStates) do
                pcall(function()
                    humanoid:SetStateEnabled(state, wasEnabled)
                end)
            end
            antiRagdollPreviousStates[humanoid] = nil
        end

        if humanoid.PlatformStand then
            pcall(function()
                humanoid.PlatformStand = false
            end)
        end
    end
end

local function toggleAntiRagdoll()
    antiRagdollEnabled = not antiRagdollEnabled

    btnRag.Text = antiRagdollEnabled and "🛡️ Анти-рагдолл: ВКЛ" or "🛡️ Анти-рагдолл: ВЫКЛ"
    btnRag.BackgroundColor3 = antiRagdollEnabled and THEME_ACTIVE or THEME_BASE

    if localPlayer.Character then
        applyAntiRagdoll(localPlayer.Character, antiRagdollEnabled)
    end
end

-- Restore the selected local settings for a newly spawned character.
trackConnect(localPlayer.CharacterAdded, function(newCharacter)
    local humanoid = newCharacter:WaitForChild("Humanoid", 8)
    if not runtime.running or not humanoid then
        return
    end

    if selectedWalkSpeed then
        humanoid.WalkSpeed = selectedWalkSpeed
    end

    if antiRagdollEnabled then
        applyAntiRagdoll(newCharacter, true)
    end
end)

trackConnect(btnSave.MouseButton1Click, function()

    local character = localPlayer.Character

    if character and character:FindFirstChild("HumanoidRootPart") then

        homeCFrame = character.HumanoidRootPart.CFrame

        local oldText = btnSave.Text

        btnSave.Text = "✅ Сохранено!"

        task.delay(1.2, function()

            if btnSave and btnSave.Parent then btnSave.Text = oldText end

        end)

    end

end)

trackConnect(btnTp.MouseButton1Click, function()
    if safeModeEnabled then
        showStealToast("Безопасный режим: мгновенный телепорт отключён", false)
        return
    end

    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not character or not root or not root:IsA("BasePart") then
        btnTp.Text = "❌ Персонаж не готов"
        task.delay(1.2, function()
            if btnTp and btnTp.Parent then btnTp.Text = "🌀 ТП домой" end
        end)
        return
    end

    if not homeCFrame then
        btnTp.Text = "❌ Сначала сохрани точку"
        task.delay(1.2, function()
            if btnTp and btnTp.Parent then btnTp.Text = "🌀 ТП домой" end
        end)
        return
    end

    local targetCFrame = homeCFrame + Vector3.new(0, 2, 0)
    local ok = pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        character:PivotTo(targetCFrame)
    end)

    if not ok then
        btnTp.Text = "❌ Локальный TP не выполнен"
        task.delay(1.2, function()
            if btnTp and btnTp.Parent then btnTp.Text = "🌀 ТП домой" end
        end)
        return
    end

    btnTp.Text = "⏳ Проверка телепорта..."
    task.delay(0.65, function()
        if not btnTp or not btnTp.Parent then return end
        local currentCharacter = localPlayer.Character
        local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
        if currentRoot and currentRoot:IsA("BasePart")
            and (currentRoot.Position - targetCFrame.Position).Magnitude > 12 then
            btnTp.Text = "⚠️ Сервер вернул назад"
        else
            btnTp.Text = "✅ Телепорт выполнен"
        end
        task.delay(1.5, function()
            if btnTp and btnTp.Parent then btnTp.Text = "🌀 ТП домой" end
        end)
    end)
end)

local function refreshHitButtons()
    if btnReach and btnReach.Parent then
        btnReach.Text = reachEnabled and "🎯 Мощный Удар: ВКЛ" or "🎯 Мощный Удар: ВЫКЛ"
        btnReach.BackgroundColor3 = reachEnabled and THEME_ACTIVE or THEME_BASE
    end
end

local function toggleReach()
    -- Safe mode is a real restriction, not an anti-cheat evasion setting.
    if safeModeEnabled then
        reachEnabled = false
        refreshHitButtons()
        showStealToast("Безопасный режим: «Мощный удар» отключён", false)
        return
    end
    reachEnabled = not reachEnabled
    refreshHitButtons()
end

-- НАДЕЖНЫЙ УДАР (С ЗАЩИТОЙ ОТ САМОУДАРА ПО USERID И КОРРЕКТНЫМ ОБХОДОМ ЯИЦ)
local function executeBurstHit(sourcePart, targetChar)
    local myCharacter = localPlayer.Character
    if not sourcePart or not sourcePart.Parent or not targetChar or not myCharacter then
        return
    end

    -- The source part must belong to our current character/tool.
    if not sourcePart:IsDescendantOf(myCharacter) then
        return
    end

    -- Never let our own character (or any of its descendants) be treated as a target.
    if targetChar == myCharacter or targetChar:IsDescendantOf(myCharacter) then
        return
    end

    -- Only process a real, living character belonging to another player.
    local targetPlr = Players:GetPlayerFromCharacter(targetChar)
    if not targetPlr or targetPlr == localPlayer or targetPlr.UserId == localPlayer.UserId then
        return
    end
    if targetPlr.Character ~= targetChar or not targetChar:IsDescendantOf(workspace) then
        return
    end

    local targetHumanoid = targetChar:FindFirstChildOfClass("Humanoid")
    if not targetHumanoid or targetHumanoid.Health <= 0 then
        return
    end

    -- Executor-only touch function may be unavailable in some environments.
    if type(firetouchinterest) ~= "function" then
        return
    end

    -- Use one real body part rather than firing touch events against every
    -- accessory/limb. Touching every descendant can create duplicate/phantom hits.
    -- Never change another character's CanTouch property from the client.
    local targetPart = targetChar:FindFirstChild("HumanoidRootPart")
        or targetChar:FindFirstChild("UpperTorso")
        or targetChar:FindFirstChild("Torso")
        or targetChar:FindFirstChild("Head")

    if not targetPart or not targetPart:IsA("BasePart") then
        return
    end

    -- Final self-hit guard immediately before the touch call.
    if localPlayer.Character ~= myCharacter
        or targetPlr == localPlayer
        or targetPlr.UserId == localPlayer.UserId
        or targetPlr.Character ~= targetChar
        or targetChar == localPlayer.Character
        or targetPart:IsDescendantOf(myCharacter)
        or sourcePart:IsDescendantOf(targetChar) then
        return
    end

    pcall(function()
        if sourcePart.Parent
            and targetPart.Parent
            and localPlayer.Character == myCharacter
            and targetPlr.Character == targetChar
            and targetPlr ~= localPlayer
            and targetChar ~= localPlayer.Character then
            firetouchinterest(sourcePart, targetPart, 0)
            firetouchinterest(sourcePart, targetPart, 1)
        end
    end)
end

local hitActionBusy = false
local lastHitActionAt = 0

local function performHitAction()
    -- Safe mode blocks the touch-based hit path as well as the toggle.
    if safeModeEnabled then
        return
    end
    -- Prevent repeated manual clicks from firing overlapping bursts.
    if hitActionBusy or (os.clock() - lastHitActionAt) < 0.75 then
        return
    end

    local character = localPlayer.Character

    if not character then return end

    local tool = character:FindFirstChildOfClass("Tool")
    local partToUse = tool and tool:FindFirstChild("Handle")

    -- Do not use our HumanoidRootPart as a substitute for a weapon Handle.
    if not partToUse or not partToUse:IsA("BasePart") or not partToUse:IsDescendantOf(character) then
        return
    end

    hitActionBusy = true
    lastHitActionAt = os.clock()
    task.delay(0.35, function()
        hitActionBusy = false
    end)

    if partToUse then

        local currentPlayers = Players:GetPlayers()

        if selectedTargetPlayer == "ALL" then

            for _, p in ipairs(currentPlayers) do

                if p.UserId ~= localPlayer.UserId and not excludedFriends[p] and p.Character then

                    task.spawn(executeBurstHit, partToUse, p.Character)

                end

            end

        elseif typeof(selectedTargetPlayer) == "Instance" and selectedTargetPlayer:IsA("Player") then

            if selectedTargetPlayer.UserId ~= localPlayer.UserId and selectedTargetPlayer.Character and not excludedFriends[selectedTargetPlayer] then

                task.spawn(executeBurstHit, partToUse, selectedTargetPlayer.Character)

            end

        else

            local closestChar = nil

            local shortestDist = math.huge

            local myRoot = character:FindFirstChild("HumanoidRootPart")

            if myRoot then

                for _, p in ipairs(currentPlayers) do

                    if p.UserId ~= localPlayer.UserId and not excludedFriends[p] and p.Character then

                        local tRoot = p.Character:FindFirstChild("HumanoidRootPart") or p.Character:FindFirstChildOfClass("BasePart")

                        if tRoot then

                            local dist = (tRoot.Position - myRoot.Position).Magnitude

                            if dist < shortestDist then

                                shortestDist = dist

                                closestChar = p.Character

                            end

                        end

                    end

                end

            end

            if closestChar then

                task.spawn(executeBurstHit, partToUse, closestChar)

            end

        end

    end

end

trackConnect(UserInputService.InputBegan, function(input, gameProcessed)
    -- Ignore clicks already consumed by the GUI, otherwise pressing a panel
    -- button can accidentally trigger the hit action too.
    if not gameProcessed and reachEnabled
        and input.UserInputType == Enum.UserInputType.MouseButton1 then
        performHitAction()
    end
end)

trackConnect(btn32.MouseButton1Click, function() setSpeed(32) end)

trackConnect(btn8.MouseButton1Click, function() setSpeed(8) end)

trackConnect(btnRag.MouseButton1Click, toggleAntiRagdoll)

trackConnect(btnReach.MouseButton1Click, toggleReach)


-- === FAST STEAL EGG / PET ===
-- Detects attached carried eggs and front-held pets, with a name/attribute fallback.
local eggTeleportBusy = false
local eggKnownInstances = setmetatable({}, { __mode = "k" })
local eggKnownWorldParts = setmetatable({}, { __mode = "k" })
local eggObservedCharacter = nil

local function captureEggBase(character)
    character = character or localPlayer.Character
    if not character then
        return false
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        root = character:WaitForChild("HumanoidRootPart", 8)
    end

    if not root or not root:IsA("BasePart") then
        return false
    end

    homeCFrame = root.CFrame
    return true
end

local function snapshotCharacter(character)
    eggKnownInstances = setmetatable({}, { __mode = "k" })
    eggKnownWorldParts = setmetatable({}, { __mode = "k" })
    eggObservedCharacter = character
    if character then
        -- Mark everything already present as old. New descendants are stored with
        -- a timestamp so we can re-check them briefly while the game welds/moves
        -- the carried visual into position above the avatar.
        for _, item in ipairs(character:GetDescendants()) do
            eggKnownInstances[item] = true
        end

        -- Baseline nearby world parts too. This avoids treating a pre-existing
        -- map part/effect next to the avatar as a newly carried egg.
        local head = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
        if head and head:IsA("BasePart") then
            local ok, parts = pcall(function()
                return workspace:GetPartBoundsInRadius(head.Position, 8)
            end)
            if ok and parts then
                for _, part in ipairs(parts) do
                    eggKnownWorldParts[part] = true
                end
            end
        end
    end
end

local function nameSuggestsEgg(name)
    name = string.lower(tostring(name or ""))
    return string.find(name, "egg", 1, true) ~= nil
        or string.find(name, "яйц", 1, true) ~= nil
end

local function hasEggMarker(root)
    if not root then
        return false
    end

    if nameSuggestsEgg(root.Name) and (root:IsA("Tool") or root:IsA("Model")
        or root:IsA("Accessory") or root:IsA("BasePart")) then
        return true
    end

    for attributeName, attributeValue in pairs(root:GetAttributes()) do
        if nameSuggestsEgg(attributeName) and attributeValue == true then
            return true
        end
    end

    for _, item in ipairs(root:GetDescendants()) do
        if nameSuggestsEgg(item.Name) then
            if item:IsA("Tool") or item:IsA("Model") or item:IsA("Accessory")
                or item:IsA("BasePart") or item:IsA("BoolValue") then
                if not item:IsA("BoolValue") or item.Value == true then
                    return true
                end
            end
        end
    end

    return false
end

local BODY_PART_NAMES = {
    head = true, humanoidrootpart = true, torso = true,
    uppertorso = true, lowertorso = true,
    leftarm = true, rightarm = true, leftleg = true, rightleg = true,
    leftupperarm = true, leftlowerarm = true, lefthand = true,
    rightupperarm = true, rightlowerarm = true, righthand = true,
    leftupperleg = true, leftlowerleg = true, leftfoot = true,
    rightupperleg = true, rightlowerleg = true, rightfoot = true,
}

local function getParts(instance)
    local parts = {}
    if instance:IsA("BasePart") then
        table.insert(parts, instance)
    end
    for _, descendant in ipairs(instance:GetDescendants()) do
        if descendant:IsA("BasePart") then
            table.insert(parts, descendant)
        end
    end
    return parts
end

local IGNORE_CARRY_OBJECT_NAMES = {
    attachment = true, particleemitter = true, trail = true, beam = true,
    highlight = true, billboardgui = true, surfacegui = true,
    sparkles = true, fire = true, smoke = true, weld = true,
    weldconstraint = true, motor6d = true, mesh = true,
}

local function getCarryCandidate(item, character)
    if not item or not character or not item.Parent then
        return nil
    end

    -- Walk upward to the newly attached top-level item, but do not walk through
    -- a body part. This keeps a child mesh tied to its accessory/model.
    local candidate = item
    while candidate.Parent and candidate.Parent ~= character
        and not candidate.Parent:IsA("BasePart") do
        candidate = candidate.Parent
    end

    if candidate == character or BODY_PART_NAMES[string.lower(candidate.Name)] then
        return nil
    end

    if not (candidate:IsA("Tool") or candidate:IsA("Accessory")
        or candidate:IsA("Model") or candidate:IsA("BasePart")
        or candidate:IsA("Folder")) then
        return nil
    end

    if IGNORE_CARRY_OBJECT_NAMES[string.lower(candidate.Name)] then
        return nil
    end

    return candidate
end

local function isNewObjectAboveHead(item, character)
    local candidate = getCarryCandidate(item, character)
    if not candidate then
        return false
    end

    local head = character:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then
        head = character:FindFirstChild("HumanoidRootPart")
    end
    if not head or not head:IsA("BasePart") then
        return false
    end

    -- Geometry fallback covers eggs above the head and pets held in front.
    -- Only newly added non-body objects reach this function.
    local root = character:FindFirstChild("HumanoidRootPart")
    for _, part in ipairs(getParts(candidate)) do
        if not BODY_PART_NAMES[string.lower(part.Name)] then
            local offset = part.Position - head.Position
            local sizeMagnitude = part.Size.Magnitude
            local aboveHead = offset.Y >= 0.9 and offset.Magnitude <= 5.5
            local heldInFront = false
            if root and root:IsA("BasePart") then
                local localOffset = root.CFrame:PointToObjectSpace(part.Position)
                heldInFront = localOffset.Z <= -0.6
                    and localOffset.Z >= -8
                    and math.abs(localOffset.X) <= 4.5
                    and localOffset.Y >= -4.5
                    and localOffset.Y <= 5.5
                    and localOffset.Magnitude <= 8
            end
            if (aboveHead or heldInFront)
                and sizeMagnitude >= 0.8
                and sizeMagnitude <= 16 then
                return true
            end
        end
    end

    return false
end

-- The F9 log showed carried items can live outside Character/Backpack:
-- it lives under Workspace.Carried (example path: Carried.Specter.Specter)
-- while its AssemblyRootPart is this character's HumanoidRootPart. Detect that
-- exact relationship directly; do not depend on the object's name or whether
-- it was present when the initial baseline was captured.
local carriedPartState = setmetatable({}, { __mode = "k" })

local function isPhysicallyConnectedToRoot(part, root)
    if not part or not root then
        return false
    end

    if part.AssemblyRootPart == root then
        return true
    end

    local ok, connectedParts = pcall(function()
        return part:GetConnectedParts(true)
    end)
    if ok and connectedParts then
        for _, connectedPart in ipairs(connectedParts) do
            if connectedPart == root then
                return true
            end
        end
    end

    return false
end

local function isInFrontCarryZone(part, root)
    if not part or not root or not part:IsA("BasePart") then
        return false
    end

    local localPosition = root.CFrame:PointToObjectSpace(part.Position)
    local distance = (part.Position - root.Position).Magnitude
    local sizeMagnitude = part.Size.Magnitude
    -- Roblox local forward is -Z. Pet visuals may sit in front of the hands;
    -- eggs may be above the head. This heuristic is limited to Workspace.Carried.
    return localPosition.Z <= -0.6
        and localPosition.Z >= -11
        and math.abs(localPosition.X) <= 6
        and localPosition.Y >= -6
        and localPosition.Y <= 7
        and distance <= 13
        and sizeMagnitude >= 1
        and sizeMagnitude <= 24
end

local function hasWorkspaceCarriedObject(character)
    if not character then
        return false, nil, "no-character"
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local carriedFolder = workspace:FindFirstChild("Carried")
    if not root or not root:IsA("BasePart") or not carriedFolder then
        return false, nil, "no-carried-folder-or-root"
    end

    local now = os.clock()
    for _, item in ipairs(carriedFolder:GetDescendants()) do
        if item:IsA("BasePart") and item.Parent then
            local distance = (item.Position - root.Position).Magnitude
            -- A real assembly connection to OUR HumanoidRootPart is the strongest
            -- signal that this Workspace.Carried item belongs to our character.
            -- Do not reject it just because its visual pivot is far from the root:
            -- this game reports carried pets (e.g. Velociraptor.A_17) at 20+ studs.
            if isPhysicallyConnectedToRoot(item, root) then
                carriedPartState[item] = {
                    lastDistance = distance,
                    lastFront = nil,
                    lastSeen = now,
                }
                return true, item, "connected-to-character"
            end

            local inFront = isInFrontCarryZone(item, root)
            local state = carriedPartState[item]
            if not state then
                -- A newly created carried visual appearing in the front zone
                -- can represent a pet in the player's hands. Keep its positive
                -- signal alive long enough for the normal 0.45s debounce.
                state = {
                    lastDistance = distance,
                    lastFront = inFront,
                    lastSeen = now,
                    frontDetectedUntil = inFront and (now + 1.5) or nil,
                }
                carriedPartState[item] = state
                if inFront then
                    return true, item, "new-front-held-object"
                end
            else
                local approached = state.lastDistance > 10 and distance <= 8
                local movedIntoFront = state.lastFront ~= true and inFront
                state.lastDistance = distance
                state.lastFront = inFront
                state.lastSeen = now
                if inFront and (approached or movedIntoFront) then
                    state.frontDetectedUntil = now + 1.5
                end
                if not inFront then
                    state.frontDetectedUntil = nil
                end
                if inFront and state.frontDetectedUntil and now <= state.frontDetectedUntil then
                    return true, item, "front-held-object"
                end
            end
        end
    end

    return false, nil, "no-attached-carry-object"
end

local function isCarryingLoot()
    local character = localPlayer.Character
    if not character then
        return false
    end

    -- Refresh the character baseline after respawn, but do not return early:
    -- the carried visual can already be present under Workspace.Carried.
    if eggObservedCharacter ~= character then
        snapshotCharacter(character)
    end

    -- Highest-confidence game-specific detector, grounded in the user's F9 log.
    -- This intentionally runs before the older name/new-object heuristics.
    local carriedObjectFound = hasWorkspaceCarriedObject(character)
    if carriedObjectFound then
        return true
    end

    -- Explicit names/attributes win and may be detected even if the object was
    -- already present when the toggle was enabled.
    if hasEggMarker(character) then
        return true
    end
    for attributeName, attributeValue in pairs(character:GetAttributes()) do
        local key = string.lower(tostring(attributeName))
        if attributeValue == true and
            (key == "carryingegg" or key == "hascarriedegg" or key == "iscarryingegg") then
            return true
        end
    end

    -- Fallback: only consider newly added objects, and only for a short window.
    -- The outer loop also requires the signal to persist for 0.45 seconds.
    local now = os.clock()
    for _, item in ipairs(character:GetDescendants()) do
        local firstSeen = eggKnownInstances[item]
        if firstSeen == nil then
            firstSeen = now
            eggKnownInstances[item] = firstSeen
        end

        if type(firstSeen) == "number" and (now - firstSeen) <= 5
            and isNewObjectAboveHead(item, character) then
            return true
        end
    end

    -- Some games keep the carry visual in Workspace and weld it to the avatar.
    -- This path requires a physical connection to our own character, excluding
    -- random eggs/parts merely passing near the head.
    local head = character:FindFirstChild("Head")
    if not head or not head:IsA("BasePart") then
        head = character:FindFirstChild("HumanoidRootPart")
    end
    if head and head:IsA("BasePart") then
        local ok, nearbyParts = pcall(function()
            return workspace:GetPartBoundsInRadius(head.Position, 6)
        end)
        if ok and nearbyParts then
            for _, part in ipairs(nearbyParts) do
                if part:IsA("BasePart") and not part:IsDescendantOf(character) then
                    local firstSeen = eggKnownWorldParts[part]
                    if firstSeen == nil then
                        firstSeen = os.clock()
                        eggKnownWorldParts[part] = firstSeen
                    end

                    local offset = part.Position - head.Position
                    local assemblyRoot = part.AssemblyRootPart
                    local connected = assemblyRoot ~= nil and assemblyRoot:IsDescendantOf(character)

                    if not connected then
                        local connectedOk, connectedParts = pcall(function()
                            return part:GetConnectedParts(true)
                        end)
                        if connectedOk and connectedParts then
                            for _, connectedPart in ipairs(connectedParts) do
                                if connectedPart:IsDescendantOf(character) then
                                    connected = true
                                    break
                                end
                            end
                        end
                    end

                    if type(firstSeen) == "number"
                        and os.clock() - firstSeen <= 5
                        and connected
                        and offset.Y >= 0.9
                        and offset.Magnitude <= 5.5
                        and part.Size.Magnitude >= 0.8
                        and part.Size.Magnitude <= 12 then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- Auto mode intentionally uses stronger signals than the manual fallback:
-- a newly added connected object under Workspace.Carried, or a newly activated
-- explicit carry attribute. Nearby/front-of-player geometry alone is not enough.
local function hasExplicitCarryingMarker(character)
    if not character then
        return false
    end

    -- Only explicit true attributes qualify here. An accessory/model merely named
    -- "Egg" is not enough, because exiting or spawning an egg can add such visuals.
    for attributeName, attributeValue in pairs(character:GetAttributes()) do
        local key = string.lower(tostring(attributeName))
        if attributeValue == true and
            (key == "carryingegg" or key == "hascarriedegg" or key == "iscarryingegg") then
            return true
        end
    end

    return false
end

local function seedAutoStealCarryBaseline()
    autoStealKnownCarriedInstances = setmetatable({}, { __mode = "k" })
    autoStealFreshCarryParts = setmetatable({}, { __mode = "k" })

    local character = localPlayer.Character
    local carriedFolder = workspace:FindFirstChild("Carried")
    if carriedFolder then
        for _, item in ipairs(carriedFolder:GetDescendants()) do
            autoStealKnownCarriedInstances[item] = true
        end
    end

    -- If an explicit marker is already active when Auto-Steal is switched on,
    -- do not treat that existing state as a new pickup.
    autoStealMarkerWasActive = hasExplicitCarryingMarker(character)
    autoStealMarkerFresh = false
end

local function isFreshCarrySignalForAuto()
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local carriedFolder = workspace:FindFirstChild("Carried")
    if not character or not root or not root:IsA("BasePart") or not carriedFolder then
        autoStealMarkerWasActive = hasExplicitCarryingMarker(character)
        autoStealMarkerFresh = false
        return false
    end

    local now = os.clock()
    local foundFreshConnectedPart = false
    local seenThisPass = {}

    for _, item in ipairs(carriedFolder:GetDescendants()) do
        seenThisPass[item] = true

        if item:IsA("BasePart") and item.Parent then
            if not autoStealKnownCarriedInstances[item] then
                -- New instance under Workspace.Carried since Auto-Steal was armed.
                autoStealKnownCarriedInstances[item] = true
                autoStealFreshCarryParts[item] = {
                    addedAt = now,
                    active = false,
                }
            end

            local record = autoStealFreshCarryParts[item]
            local connected = isPhysicallyConnectedToRoot(item, root)
            if record then
                if connected and (now - record.addedAt) <= 10 then
                    record.active = true
                elseif not connected and record.active then                    -- This fresh item was dropped/de-attached. It must not re-trigger
                    -- if the game later reuses the same physical instance.
                    autoStealFreshCarryParts[item] = nil
                    record = nil
                elseif not connected and (now - record.addedAt) > 10 then
                    autoStealFreshCarryParts[item] = nil
                    record = nil
                end

                if record and connected and record.active then
                    foundFreshConnectedPart = true
                end
            end
        end
    end

    -- Remove tracking for items that were taken out of Workspace.Carried.
    for item in pairs(autoStealFreshCarryParts) do
        if not seenThisPass[item] then
            autoStealFreshCarryParts[item] = nil
        end
    end

    local markerActive = hasExplicitCarryingMarker(character)
    if markerActive and not autoStealMarkerWasActive then
        autoStealMarkerFresh = true
    elseif not markerActive then
        autoStealMarkerFresh = false
    end
    autoStealMarkerWasActive = markerActive

    return foundFreshConnectedPart or autoStealMarkerFresh
end

-- Diagnostic-only button: list nearby/attached instances so the game's actual
-- carried-egg representation can be identified instead of guessing by name.
local function runEggDiagnostic()
    local character = localPlayer.Character
    local head = character and (character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart"))
    print("========== FAE EGG DIAGNOSTIC ==========")
    print("Fast Steal enabled:", fastStealEggEnabled, "Auto Steal enabled:", autoStealEnabled,
        "Base saved:", homeCFrame ~= nil)
    print("Character:", character and character:GetFullName() or "nil")

    if not character or not head or not head:IsA("BasePart") then
        warn("[EGG-DEBUG] Character/head not ready")
        btnEggDiagnostic.Text = "🔍 Нет персонажа"
        task.delay(2, function()
            if btnEggDiagnostic and btnEggDiagnostic.Parent then
                btnEggDiagnostic.Text = "🔍 Диагностика яйца / пета"
            end
        end)
        return
    end

    local markedCharacter = hasEggMarker(character)
    local backpack = localPlayer:FindFirstChildOfClass("Backpack")
    local markedBackpack = backpack and hasEggMarker(backpack) or false
    print("Named egg marker in Character:", markedCharacter)
    print("Named egg marker in Backpack:", markedBackpack)
    local carriedFound, carriedPart, carriedReason = hasWorkspaceCarriedObject(character)
    print("Workspace.Carried attached/front-held by own character:", carriedFound, "Reason:", carriedReason)
    if carriedPart then
        print("Attached carried part:", carriedPart.ClassName, carriedPart:GetFullName(),
            "DistanceFromRoot:", string.format("%.2f", (carriedPart.Position - character.HumanoidRootPart.Position).Magnitude))
    end
    print("Current egg/pet detector result:", isCarryingLoot())

    local candidates = {}
    for _, item in ipairs(character:GetDescendants()) do
        local allowed = item:IsA("Model") or item:IsA("Tool") or item:IsA("Accessory")
            or (item:IsA("BasePart") and not BODY_PART_NAMES[string.lower(item.Name)])
        if allowed and not BODY_PART_NAMES[string.lower(item.Name)] then
            local closestDistance = math.huge
            for _, part in ipairs(getParts(item)) do
                local distance = (part.Position - head.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                end
            end
            if closestDistance <= 12 then
                table.insert(candidates, {
                    item = item,
                    distance = closestDistance,
                    path = item:GetFullName(),
                })
            end
        end
    end
    table.sort(candidates, function(a, b) return a.distance < b.distance end)

    print("--- Closest candidates inside Character (max 20) ---")
    if #candidates == 0 then print("No non-body objects within 12 studs") end
    for i = 1, math.min(#candidates, 20) do
        local c = candidates[i]
        print(string.format("CHAR %02d | %.2f studs | %s | %s", i, c.distance, c.item.ClassName, c.path))
    end

    local nearby = {}
    local ok, parts = pcall(function()
        return workspace:GetPartBoundsInRadius(head.Position, 8)
    end)
    if ok and parts then
        for _, part in ipairs(parts) do
            if part:IsA("BasePart") and not part:IsDescendantOf(character) then
                table.insert(nearby, {
                    part = part,
                    distance = (part.Position - head.Position).Magnitude,
                    path = part:GetFullName(),
                    assembly = part.AssemblyRootPart and part.AssemblyRootPart:GetFullName() or "nil",
                })
            end
        end
    end
    table.sort(nearby, function(a, b) return a.distance < b.distance end)
    print("--- Nearby Workspace parts (max 15) ---")
    if #nearby == 0 then print("No external physical parts within 8 studs (or query failed)") end
    for i = 1, math.min(#nearby, 15) do
        local c = nearby[i]
        print(string.format("WORLD %02d | %.2f studs | %s | %s | AssemblyRoot=%s", i, c.distance, c.part.ClassName, c.path, c.assembly))
    end
    print("========== END EGG DIAGNOSTIC ==========")

    btnEggDiagnostic.Text = "✅ Диагностика в F9"
    task.delay(2.5, function()
        if btnEggDiagnostic and btnEggDiagnostic.Parent then
            btnEggDiagnostic.Text = "🔍 Диагностика яйца / пета"
        end
    end)
end

trackConnect(btnEggDiagnostic.MouseButton1Click, runEggDiagnostic)

-- Establish a baseline for objects already carried by OTHER players. This
-- prevents an unrelated pet that happens to be in front at script startup
-- from triggering a false teleport. A later move into the local front zone,
-- or a physical connection to our character, can still be detected.
local function seedCarriedPartState()
    local carriedFolder = workspace:FindFirstChild("Carried")
    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not carriedFolder or not root or not root:IsA("BasePart") then
        return
    end

    local now = os.clock()
    for _, item in ipairs(carriedFolder:GetDescendants()) do
        if item:IsA("BasePart") then
            carriedPartState[item] = {
                lastDistance = (item.Position - root.Position).Magnitude,
                lastFront = isInFrontCarryZone(item, root),
                lastSeen = now,
            }
        end
    end
end

local function teleportToEggBase()
    if safeModeEnabled then
        showStealToast("Предмет обнаружен • безопасный режим: телепорт пропущен", true)
        return
    end

    if eggTeleportBusy then
        return
    end

    if not homeCFrame then
        showStealToast("База не сохранена • нажми «Запомнить дом / базу» на базе", false)
        return
    end

    local character = localPlayer.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not root:IsA("BasePart") then
        showStealToast("Персонаж ещё не готов к телепорту", false)
        return
    end

    eggTeleportBusy = true
    local targetCFrame = homeCFrame + Vector3.new(0, 4, 0)
    local teleportOk = pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        character:PivotTo(targetCFrame)
    end)

    if not teleportOk then
        eggTeleportBusy = false
        showStealToast("Не удалось выполнить локальный телепорт", false)
        return
    end

    showStealToast("Предмет обнаружен • проверяю возврат на базу…", true)
    task.delay(0.8, function()
        eggTeleportBusy = false
        local currentCharacter = localPlayer.Character
        local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
        local serverReturned = currentRoot and currentRoot:IsA("BasePart")
            and (currentRoot.Position - targetCFrame.Position).Magnitude > 12
        if serverReturned then
            showStealToast("Сервер вернул персонажа назад • предмет мог уже засчитаться", false)
        else
            showStealToast("Проверка завершена • персонаж остался на базе", true)
        end
    end)
end

if localPlayer.Character then
    snapshotCharacter(localPlayer.Character)
    task.spawn(function()
        if not homeCFrame then
            captureEggBase(localPlayer.Character)
        end
    end)
end

trackConnect(localPlayer.CharacterAdded, function(character)
    snapshotCharacter(character)
    task.spawn(function()
        if not homeCFrame then
            captureEggBase(character)
        end
    end)
end)

trackConnect(btnSetBase.MouseButton1Click, function()
    if captureEggBase(localPlayer.Character) then
        btnSetBase.Text = "✅ База сохранена"
        task.delay(1.3, function()
            if btnSetBase and btnSetBase.Parent then
                btnSetBase.Text = "📍 Запомнить дом / базу"
            end
        end)
    else
        btnSetBase.Text = "❌ Персонаж не готов"
        task.delay(1.3, function()
            if btnSetBase and btnSetBase.Parent then
                btnSetBase.Text = "📍 Запомнить дом / базу"
            end
        end)
    end
end)

local function setFastStealEggEnabled(enabled)
    fastStealEggEnabled = enabled and true or false
    if fastStealEggEnabled then
        btnFastStealEgg.Text = autoStealEnabled
            and "🥚🐾 Fast Steal Egg/Pet: ВКЛ (авто)"
            or "🥚🐾 Fast Steal Egg/Pet: ВКЛ (F6 / ожидание)"
    else
        btnFastStealEgg.Text = "🥚🐾 Fast Steal Egg/Pet: ВЫКЛ (F6)"
    end
    btnFastStealEgg.BackgroundColor3 = fastStealEggEnabled and THEME_ACTIVE or THEME_BASE
end

local function setAutoStealEnabled(enabled)
    autoStealEnabled = enabled and true or false
    autoStealWaitingForClear = false
    autoStealClearSince = nil
    candidateSince = nil
    wasCarryingEgg = false

    if autoStealEnabled then
        setFastStealEggEnabled(true)
        seedAutoStealCarryBaseline()
        btnAutoSteal.Text = "🔁 Авто-стил: ВКЛ"
        btnAutoSteal.BackgroundColor3 = THEME_ACTIVE
    else
        setFastStealEggEnabled(false)
        btnAutoSteal.Text = "🔁 Авто-стил: ВЫКЛ"
        btnAutoSteal.BackgroundColor3 = THEME_BASE
    end
end

trackConnect(btnFastStealEgg.MouseButton1Click, function()
    -- Clicking the manual control exits auto mode first.
    if autoStealEnabled then
        setAutoStealEnabled(false)
        setFastStealEggEnabled(true)
    else
        setFastStealEggEnabled(not fastStealEggEnabled)
    end
end)

trackConnect(btnAutoSteal.MouseButton1Click, function()
    setAutoStealEnabled(not autoStealEnabled)
end)

-- This is a safety alternative, not a movement-masking mode: when ON, carry
-- detection still works but the script never moves the character automatically.
trackConnect(btnNoAutoTeleport.MouseButton1Click, function()
    safeModeEnabled = not safeModeEnabled
    if safeModeEnabled then
        -- Turning this on immediately disables an already-armed powerful-hit action.
        reachEnabled = false
        refreshHitButtons()
    end
    btnNoAutoTeleport.Text = safeModeEnabled
        and "🛡️ Безопасный режим: ВКЛ"
        or "🛡️ Безопасный режим: ВЫКЛ"
    btnNoAutoTeleport.BackgroundColor3 = safeModeEnabled and THEME_ACTIVE or THEME_BASE
    showStealToast(safeModeEnabled
        and "Безопасный режим включён: мгновенные ТП и мощный удар отключены; Fast Steal — только уведомление"
        or "Безопасный режим выключен: ограничения сняты", true)
end)

trackConnect(btnNoAutoTeleport.MouseLeave, function()
    local restingColor = safeModeEnabled and THEME_ACTIVE or THEME_BASE
    TweenService:Create(btnNoAutoTeleport, TweenInfo.new(0.2), {BackgroundColor3 = restingColor}):Play()
end)

-- F6 controls manual Fast Steal. When Auto-Steal is on, F6 safely turns it off.
trackConnect(UserInputService.InputBegan, function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F6 then
        if autoStealEnabled then
            setAutoStealEnabled(false)
        else
            setFastStealEggEnabled(not fastStealEggEnabled)
        end
    end
end)

seedCarriedPartState()

-- Auto-Steal intentionally defaults to OFF. On activation it baselines every
-- existing Workspace.Carried instance. A trigger requires a newly added connected
-- item (or a newly activated explicit carry attribute), not a stale pet/egg visual.
-- After a trigger it waits until that signal clears for 0.9s before accepting another.
task.spawn(function()
    while runtime.running do
        task.wait(0.15)
        if not runtime.running then
            break
        end

        if not fastStealEggEnabled then
            wasCarryingEgg = false
            candidateSince = nil
            autoStealClearSince = nil
        else
            -- Auto mode is stricter: ignore pre-existing carry visuals and
            -- broad geometric guesses. Require a NEW confirmed connection/marker.
            local candidate
            if autoStealEnabled then
                candidate = isFreshCarrySignalForAuto()
            else
                candidate = isCarryingLoot()
            end

            if autoStealEnabled and autoStealWaitingForClear then
                if candidate then
                    autoStealClearSince = nil
                else
                    autoStealClearSince = autoStealClearSince or os.clock()
                    local clearLongEnough = (os.clock() - autoStealClearSince) >= 0.9
                    local cooldownPassed = (os.clock() - autoStealLastTriggerAt) >= 1.5
                    if clearLongEnough and cooldownPassed then
                        autoStealWaitingForClear = false
                        autoStealClearSince = nil
                        candidateSince = nil
                        wasCarryingEgg = false
                    end
                end
            else
                if candidate then
                    candidateSince = candidateSince or os.clock()
                else
                    candidateSince = nil
                end

                -- Require a continuous positive signal to reduce one-frame false positives.
                local carryingEgg = candidate and candidateSince ~= nil
                    and (os.clock() - candidateSince) >= 0.45

                if carryingEgg and not wasCarryingEgg then
                    snapshotCharacter(localPlayer.Character)

                    if autoStealEnabled then
                        autoStealWaitingForClear = true
                        autoStealClearSince = nil
                        autoStealLastTriggerAt = os.clock()
                    else
                        -- Manual Fast Steal remains one-shot, as before.
                        setFastStealEggEnabled(false)
                    end
                    teleportToEggBase()
                end

                wasCarryingEgg = carryingEgg and true or false
            end
        end
    end
end)

-- === 3. ESP ДЛЯ ИГРОКОВ ===
local function clearEsp()
    for _, item in ipairs(activeEspObjects) do
        if typeof(item) == "RBXScriptConnection" then
            pcall(function() item:Disconnect() end)
        elseif item then
            pcall(function() item:Destroy() end)
        end
    end
    activeEspObjects = {}
end

table.insert(runtime.cleanupCallbacks, clearEsp)

local function applyEspSystem()

    clearEsp()

    if not espEnabled then return end

    for _, p in ipairs(Players:GetPlayers()) do

        if p.UserId ~= localPlayer.UserId and p.Character then

            local char = p.Character

            local isFriend = excludedFriends[p] == true

            local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildOfClass("BasePart")

            local humanoid = char:FindFirstChildOfClass("Humanoid")

            if head and humanoid then

                local highlight = Instance.new("Highlight")

                highlight.Name = "PlayerHighlight"

                highlight.FillColor = Color3.fromRGB(255, 0, 0)

                highlight.OutlineColor = Color3.fromRGB(255, 35, 35)

                highlight.FillTransparency = 0.12
                highlight.OutlineTransparency = 0

                highlight.Adornee = char

                highlight.Parent = char

                table.insert(activeEspObjects, highlight)

                -- Large VISUAL-ONLY hitbox outline. It does not resize or alter
                -- server collision; it is shown for every non-local player.
                local rootPart = char:FindFirstChild("HumanoidRootPart")
                if rootPart and rootPart:IsA("BasePart") then
                    local box = Instance.new("BoxHandleAdornment")
                    box.Name = "PlayerVisualHitbox"
                    box.Adornee = rootPart
                    box.Size = Vector3.new(9, 12, 9)
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.Transparency = 0.28
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Parent = rootPart
                    table.insert(activeEspObjects, box)
                end

                local billboard = Instance.new("BillboardGui")

                billboard.Name = "ESPBillboard"

                billboard.Adornee = head

                billboard.Size = UDim2.new(0, 150, 0, 40)

                billboard.StudsOffset = Vector3.new(0, 2.5, 0)

                billboard.AlwaysOnTop = true

                billboard.Parent = head

                table.insert(activeEspObjects, billboard)

                local nameLabel = Instance.new("TextLabel")

                nameLabel.Size = UDim2.new(1, 0, 0, 18)

                nameLabel.BackgroundTransparency = 1

                nameLabel.Text = (isFriend and "🤝 [ДРУГ] " or "⚠️ [ВРАГ] ") .. p.DisplayName

                nameLabel.TextColor3 = isFriend and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)

                nameLabel.TextStrokeTransparency = 0

                nameLabel.Font = Enum.Font.GothamBold

                nameLabel.TextSize = 12

                nameLabel.Parent = billboard

                local healthBackground = Instance.new("Frame")

                healthBackground.Size = UDim2.new(0.8, 0, 0, 6)

                healthBackground.Position = UDim2.new(0.1, 0, 0, 22)

                healthBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

                healthBackground.BorderSizePixel = 0

                healthBackground.Parent = billboard

                local healthBgCorner = Instance.new("UICorner")

                healthBgCorner.CornerRadius = UDim.new(0, 3)

                healthBgCorner.Parent = healthBackground

                local healthBar = Instance.new("Frame")

                healthBar.Size = UDim2.new(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 0, 1, 0)

                healthBar.BackgroundColor3 = isFriend and Color3.fromRGB(46, 204, 113) or Color3.fromRGB(231, 76, 60)

                healthBar.BorderSizePixel = 0

                healthBar.Parent = healthBackground

                local healthBarCorner = Instance.new("UICorner")

                healthBarCorner.CornerRadius = UDim.new(0, 3)

                healthBarCorner.Parent = healthBar

                local hpConnection

                hpConnection = trackConnect(humanoid.HealthChanged, function(health)
                    if healthBar and healthBar.Parent then
                        local percentage = math.clamp(health / math.max(humanoid.MaxHealth, 1), 0, 1)
                        healthBar:TweenSize(UDim2.new(percentage, 0, 1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
                    end
                end)
                table.insert(activeEspObjects, hpConnection)

            end

        end

    end

end

local function hookEspPlayer(player)
    if player == localPlayer then
        return
    end
    trackConnect(player.CharacterAdded, function()
        task.delay(0.7, function()
            if runtime.running and espEnabled then
                applyEspSystem()
            end
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    hookEspPlayer(player)
end
trackConnect(Players.PlayerAdded, function(player)
    hookEspPlayer(player)
    task.delay(0.8, function()
        if runtime.running and espEnabled then
            applyEspSystem()
        end
    end)
end)
trackConnect(Players.PlayerRemoving, function()
    task.defer(function()
        if runtime.running and espEnabled then
            applyEspSystem()
        end
    end)
end)

local function toggleEsp()

    espEnabled = not espEnabled

    btnEsp.Text = espEnabled and "👁️ Подсветка (ESP): ВКЛ" or "👁️ Подсветка (ESP): ВЫКЛ"

    btnEsp.BackgroundColor3 = espEnabled and THEME_ACTIVE or THEME_BASE

    if not espEnabled then

        clearEsp()

    else

        applyEspSystem()

    end

end

trackConnect(btnEsp.MouseButton1Click, toggleEsp)