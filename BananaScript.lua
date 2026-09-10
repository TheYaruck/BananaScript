--========================================================
-- 🍌 BANANA SCRIPT
-- UI EDITION
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- SETTINGS
--========================================================

local ESPEnabled = true

local TeleportEnabled = false
local TeleportDistance = 10

local SpeedEnabled = false
local WalkSpeed = 32

local WallhackEnabled = false

local FlyEnabled = false
local FlySpeed = 50
local FlyConnection
local FlyVelocity
local FlyAttachment
local FlyOrientation

local AFKEnabled = false

local MouseUnlockEnabled = false
local MouseUnlockKey = Enum.KeyCode.LeftAlt
local SelectingMouseKey = false

local AutoBuyEnabled = false
local AutoBuyMS = 100
local AnchoredEnabled = false

local DanceEnabled = false
local DanceHotkey = Enum.KeyCode.Y
local ChoosingDanceKey = false
local DanceTrack = nil

local SelectedPlayer = nil

local Character
local Humanoid
local RootPart

--========================================================
-- CHARACTER
--========================================================

local function SetupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")

	if SpeedEnabled then
		Humanoid.WalkSpeed = WalkSpeed
	else
		Humanoid.WalkSpeed = 16
	end

	if AFKEnabled then
		RootPart.Anchored = true
	end

	if AnchoredEnabled then
		for _, part in ipairs(Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
	end
end

if Player.Character then
	SetupCharacter(Player.Character)
end

--========================================================
-- COLORS
--========================================================

local BG = Color3.fromRGB(13, 14, 18)
local PANEL = Color3.fromRGB(20, 21, 27)
local CARD = Color3.fromRGB(27, 29, 37)
local CARD_HOVER = Color3.fromRGB(34, 36, 46)

local YELLOW = Color3.fromRGB(255, 207, 55)
local YELLOW_LIGHT = Color3.fromRGB(255, 224, 105)

local WHITE = Color3.fromRGB(245, 246, 250)
local GRAY = Color3.fromRGB(145, 149, 162)
local DARK_GRAY = Color3.fromRGB(95, 99, 112)

local GREEN = Color3.fromRGB(70, 205, 105)
local RED = Color3.fromRGB(220, 75, 75)

--========================================================
-- CLEAN OLD GUI
--========================================================

local OldGui = PlayerGui:FindFirstChild("BananaScript")
if OldGui then
	OldGui:Destroy()
end

pcall(function()
	RunService:UnbindFromRenderStep("BananaMouseUnlock")
end)

--========================================================
-- GUI
--========================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BananaScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--========================================================
-- OPEN BUTTON
--========================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 58, 0, 58)
OpenButton.Position = UDim2.new(0, 24, 0.5, -29)
OpenButton.BackgroundColor3 = PANEL
OpenButton.Text = "🍌"
OpenButton.TextSize = 30
OpenButton.Font = Enum.Font.GothamBold
OpenButton.Visible = false
OpenButton.AutoButtonColor = false
OpenButton.Active = true
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = YELLOW
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

--========================================================
-- MAIN FRAME
--========================================================

local Frame = Instance.new("Frame")
Frame.Name = "Main"
Frame.Size = UDim2.new(0, 370, 0, 650)
Frame.Position = UDim2.new(0, 25, 0.5, -325)
Frame.BackgroundColor3 = BG
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 20)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = YELLOW
FrameStroke.Thickness = 1.5
FrameStroke.Transparency = 0.2
FrameStroke.Parent = Frame

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 92)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = Frame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 22)
HeaderFix.Position = UDim2.new(0, 0, 1, -22)
HeaderFix.BackgroundColor3 = PANEL
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

--========================================================
-- HEADER ICON
--========================================================

local BananaIcon = Instance.new("TextLabel")
BananaIcon.Size = UDim2.new(0, 54, 0, 54)
BananaIcon.Position = UDim2.new(0, 15, 0, 19)
BananaIcon.BackgroundColor3 = YELLOW
BananaIcon.Text = "🍌"
BananaIcon.TextSize = 29
BananaIcon.Font = Enum.Font.GothamBold
BananaIcon.Parent = Header

local BananaCorner = Instance.new("UICorner")
BananaCorner.CornerRadius = UDim.new(0, 16)
BananaCorner.Parent = BananaIcon

--========================================================
-- HEADER TITLE
--========================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -170, 0, 29)
Title.Position = UDim2.new(0, 82, 0, 14)
Title.BackgroundTransparency = 1
Title.Text = "BANANA SCRIPT"
Title.TextColor3 = WHITE
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -170, 0, 20)
Subtitle.Position = UDim2.new(0, 83, 0, 43)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "ChatGPT × TheYaruck"
Subtitle.TextColor3 = GRAY
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = Header

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 70, 0, 23)
Status.Position = UDim2.new(0, 82, 0, 64)
Status.BackgroundColor3 = Color3.fromRGB(25, 70, 40)
Status.Text = "● ONLINE"
Status.TextColor3 = GREEN
Status.TextSize = 10
Status.Font = Enum.Font.GothamBold
Status.Parent = Header

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(1, 0)
StatusCorner.Parent = Status

--========================================================
-- HEADER BUTTONS
--========================================================

local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 38, 0, 38)
SettingsButton.Position = UDim2.new(1, -100, 0, 27)
SettingsButton.BackgroundColor3 = CARD
SettingsButton.Text = "⚙"
SettingsButton.TextColor3 = WHITE
SettingsButton.TextSize = 19
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.AutoButtonColor = false
SettingsButton.Parent = Header

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 11)
SettingsCorner.Parent = SettingsButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 38, 0, 38)
CloseButton.Position = UDim2.new(1, -52, 0, 27)
CloseButton.BackgroundColor3 = CARD
CloseButton.Text = "×"
CloseButton.TextColor3 = WHITE
CloseButton.TextSize = 23
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 11)
CloseCorner.Parent = CloseButton

--========================================================
-- TABS
--========================================================

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 42)
TabBar.Position = UDim2.new(0, 10, 0, 98)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Frame

local function MakeTab(text, x)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(1/3, -4, 1, 0)
	B.Position = UDim2.new(x, 0, 0, 0)
	B.BackgroundColor3 = CARD
	B.Text = text
	B.TextColor3 = WHITE
	B.TextSize = 11
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = TabBar

	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 10)
	C.Parent = B

	return B
end

local BananaTab = MakeTab("🍌 BANANA", 0)
local BLBuyTab = MakeTab("🛒 BL BUY", 1/3)
local ChatTab = MakeTab("💬 CHAT", 2/3)

--========================================================
-- CONTENT HOLDER
--========================================================

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -20, 1, -152)
ContentHolder.Position = UDim2.new(0, 10, 0, 145)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = Frame

local function CreateContent()
	local S = Instance.new("ScrollingFrame")
	S.Size = UDim2.new(1, 0, 1, 0)
	S.BackgroundTransparency = 1
	S.BorderSizePixel = 0
	S.ScrollBarThickness = 3
	S.ScrollBarImageColor3 = YELLOW
	S.CanvasSize = UDim2.new(0, 0, 0, 900)
	S.Visible = false
	S.Parent = ContentHolder
	return S
end

local BananaContent = CreateContent()
local BLContent = CreateContent()
local ChatContent = CreateContent()

--========================================================
-- UI HELPERS
--========================================================

local function Section(parent, text, y)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -28, 0, 25)
	Label.Position = UDim2.new(0, 14, 0, y)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = YELLOW
	Label.TextSize = 11
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Enum.Font.GothamBold
	Label.Parent = parent
	return Label
end

local function Button(parent, text, y)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(1, -28, 0, 46)
	B.Position = UDim2.new(0, 14, 0, y)
	B.BackgroundColor3 = CARD
	B.Text = text
	B.TextColor3 = WHITE
	B.TextSize = 13
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = parent

	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 12)
	C.Parent = B

	local S = Instance.new("UIStroke")
	S.Color = Color3.fromRGB(48, 51, 62)
	S.Thickness = 1
	S.Parent = B

	B.MouseEnter:Connect(function()
		if not B:GetAttribute("Active") then
			B.BackgroundColor3 = CARD_HOVER
		end
	end)

	B.MouseLeave:Connect(function()
		if not B:GetAttribute("Active") then
			B.BackgroundColor3 = CARD
		end
	end)

	return B
end

local function Box(parent, value, y)
	local B = Instance.new("TextBox")
	B.Size = UDim2.new(1, -28, 0, 38)
	B.Position = UDim2.new(0, 14, 0, y)
	B.BackgroundColor3 = PANEL
	B.TextColor3 = WHITE
	B.PlaceholderColor3 = DARK_GRAY
	B.Text = tostring(value)
	B.TextSize = 13
	B.Font = Enum.Font.GothamBold
	B.ClearTextOnFocus = false
	B.Parent = parent

	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 10)
	C.Parent = B

	local S = Instance.new("UIStroke")
	S.Color = Color3.fromRGB(45, 48, 58)
	S.Thickness = 1
	S.Parent = B

	return B
end

local function SetButton(B, active, color)
	B:SetAttribute("Active", active)

	if active then
		B.BackgroundColor3 = color
	else
		B.BackgroundColor3 = CARD
	end
end

local function KeyButton(parent, text, y)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(0, 110, 0, 42)
	B.Position = UDim2.new(1, -124, 0, y)
	B.BackgroundColor3 = CARD
	B.Text = text
	B.TextColor3 = WHITE
	B.TextSize = 12
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = parent

	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 10)
	C.Parent = B

	return B
end

--========================================================
-- BANANA CONTENT
--========================================================

Section(BananaContent, "👁  VISUALS", 10)
local ESPButton = Button(BananaContent, "👁   ESP: ON", 38)

Section(BananaContent, "🌀  TELEPORT", 98)
local TeleportButton = Button(BananaContent, "🌀   TELEPORT: OFF", 126)
local DistanceBox = Box(BananaContent, TeleportDistance, 178)
local TPButton = Button(BananaContent, "🚀   TP FORWARD", 224)

Section(BananaContent, "👤  PLAYER TELEPORT", 286)
local PlayerListButton = Button(BananaContent, "👤   SELECT PLAYER", 314)
local RefreshPlayersButton = Button(BananaContent, "🔄   REFRESH PLAYERS", 366)
local TPToPlayerButton = Button(BananaContent, "🚀   TP TO PLAYER", 418)

Section(BananaContent, "⚡  MOVEMENT", 480)
local SpeedButton = Button(BananaContent, "⚡   SPEED: OFF", 508)
local SpeedBox = Box(BananaContent, WalkSpeed, 560)

Section(BananaContent, "🧱  WALLHACK", 618)
local WallhackButton = Button(BananaContent, "🧱   WALLHACK: OFF", 646)

Section(BananaContent, "✈️  FLY", 704)
local FlyButton = Button(BananaContent, "✈️   FLY: OFF", 732)
local FlyBox = Box(BananaContent, FlySpeed, 784)

Section(BananaContent, "🛡️  AFK", 842)
local AFKButton = Button(BananaContent, "🛡️   FULL AFK: OFF", 870)

BananaContent.CanvasSize = UDim2.new(0, 0, 0, 940)

--========================================================
-- BL BUY CONTENT
--========================================================

Section(BLContent, "🛒  AUTO BUY", 10)
local AutoBuyButton = Button(BLContent, "🛒   AUTO BUY: OFF", 38)

Section(BLContent, "⏱  INTERVAL", 98)
local AutoBuyBox = Box(BLContent, AutoBuyMS, 126)

Section(BLContent, "⚓  CHARACTER", 186)
local AnchoredButton = Button(BLContent, "⚓   ANCHORED: OFF", 214)

Section(BLContent, "💰  MONEY", 272)

local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Size = UDim2.new(1, -28, 0, 70)
MoneyLabel.Position = UDim2.new(0, 14, 0, 304)
MoneyLabel.BackgroundColor3 = CARD
MoneyLabel.Text = "$ 0"
MoneyLabel.TextColor3 = YELLOW_LIGHT
MoneyLabel.TextSize = 24
MoneyLabel.Font = Enum.Font.GothamBold
MoneyLabel.Parent = BLContent

local MoneyCorner = Instance.new("UICorner")
MoneyCorner.CornerRadius = UDim.new(0, 12)
MoneyCorner.Parent = MoneyLabel

BLContent.CanvasSize = UDim2.new(0, 0, 0, 410)

--========================================================
-- CHAT CONTENT
--========================================================

Section(ChatContent, "💃  DANCE 2", 10)
local DanceButton = Button(ChatContent, "💃   DANCE 2: OFF", 38)

local DanceInfo = Instance.new("TextLabel")
DanceInfo.Size = UDim2.new(1, -28, 0, 45)
DanceInfo.Position = UDim2.new(0, 14, 0, 92)
DanceInfo.BackgroundTransparency = 1
DanceInfo.Text = "R6 ONLY • Animation: 182436842"
DanceInfo.TextColor3 = GRAY
DanceInfo.TextSize = 11
DanceInfo.Font = Enum.Font.Gotham
DanceInfo.TextXAlignment = Enum.TextXAlignment.Left
DanceInfo.Parent = ChatContent

local DanceKeyLabel = Instance.new("TextLabel")
DanceKeyLabel.Size = UDim2.new(0, 150, 0, 42)
DanceKeyLabel.Position = UDim2.new(0, 14, 0, 140)
DanceKeyLabel.BackgroundTransparency = 1
DanceKeyLabel.Text = "HOTKEY"
DanceKeyLabel.TextColor3 = WHITE
DanceKeyLabel.TextSize = 13
DanceKeyLabel.Font = Enum.Font.GothamBold
DanceKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
DanceKeyLabel.Parent = ChatContent

local DanceKeyButton = KeyButton(
	ChatContent,
	DanceHotkey.Name,
	140
)

Section(ChatContent, "🖱  MOUSE", 204)

local MouseUnlockButton = Button(
	ChatContent,
	"🖱   MOUSE UNLOCK: OFF",
	232
)

local MouseKeyLabel = Instance.new("TextLabel")
MouseKeyLabel.Size = UDim2.new(0, 150, 0, 42)
MouseKeyLabel.Position = UDim2.new(0, 14, 0, 286)
MouseKeyLabel.BackgroundTransparency = 1
MouseKeyLabel.Text = "MOUSE HOTKEY"
MouseKeyLabel.TextColor3 = WHITE
MouseKeyLabel.TextSize = 13
MouseKeyLabel.Font = Enum.Font.GothamBold
MouseKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
MouseKeyLabel.Parent = ChatContent

local MouseKeyButton = KeyButton(
	ChatContent,
	MouseUnlockKey.Name,
	286
)

ChatContent.CanvasSize = UDim2.new(0, 0, 0, 360)

--========================================================
-- SETTINGS WINDOW
--========================================================

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 320, 0, 225)
SettingsFrame.Position = UDim2.new(0, 50, 0.5, -112)
SettingsFrame.BackgroundColor3 = PANEL
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 20
SettingsFrame.Active = true
SettingsFrame.Parent = ScreenGui

local SettingsCorner2 = Instance.new("UICorner")
SettingsCorner2.CornerRadius = UDim.new(0, 18)
SettingsCorner2.Parent = SettingsFrame

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Color = YELLOW
SettingsStroke.Thickness = 2
SettingsStroke.Transparency = 0.2
SettingsStroke.Parent = SettingsFrame

local SettingsDragBar = Instance.new("Frame")
SettingsDragBar.Size = UDim2.new(1, -60, 0, 55)
SettingsDragBar.Position = UDim2.new(0, 0, 0, 0)
SettingsDragBar.BackgroundTransparency = 1
SettingsDragBar.ZIndex = 20
SettingsDragBar.Active = true
SettingsDragBar.Parent = SettingsFrame

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -70, 0, 40)
SettingsTitle.Position = UDim2.new(0, 18, 0, 12)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "⚙️  SETTINGS"
SettingsTitle.TextColor3 = YELLOW_LIGHT
SettingsTitle.TextSize = 19
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.ZIndex = 21
SettingsTitle.Parent = SettingsFrame

local SettingsClose = Instance.new("TextButton")
SettingsClose.Size = UDim2.new(0, 36, 0, 36)
SettingsClose.Position = UDim2.new(1, -50, 0, 14)
SettingsClose.BackgroundColor3 = CARD
SettingsClose.Text = "×"
SettingsClose.TextColor3 = WHITE
SettingsClose.TextSize = 22
SettingsClose.Font = Enum.Font.GothamBold
SettingsClose.AutoButtonColor = false
SettingsClose.ZIndex = 21
SettingsClose.Parent = SettingsFrame

local SettingsCloseCorner = Instance.new("UICorner")
SettingsCloseCorner.CornerRadius = UDim.new(0, 11)
SettingsCloseCorner.Parent = SettingsClose

local ChatGPTLabel = Instance.new("TextLabel")
ChatGPTLabel.Size = UDim2.new(1, -36, 0, 25)
ChatGPTLabel.Position = UDim2.new(0, 18, 0, 65)
ChatGPTLabel.BackgroundTransparency = 1
ChatGPTLabel.Text = "Created with ChatGPT"
ChatGPTLabel.TextColor3 = GRAY
ChatGPTLabel.TextSize = 13
ChatGPTLabel.TextXAlignment = Enum.TextXAlignment.Left
ChatGPTLabel.Font = Enum.Font.GothamBold
ChatGPTLabel.ZIndex = 21
ChatGPTLabel.Parent = SettingsFrame

local ChatGPTLink = Instance.new("TextLabel")
ChatGPTLink.Size = UDim2.new(1, -36, 0, 38)
ChatGPTLink.Position = UDim2.new(0, 18, 0, 95)
ChatGPTLink.BackgroundColor3 = CARD
ChatGPTLink.Text = "chatgpt.com"
ChatGPTLink.TextColor3 = Color3.fromRGB(100, 180, 255)
ChatGPTLink.TextSize = 13
ChatGPTLink.Font = Enum.Font.GothamBold
ChatGPTLink.TextXAlignment = Enum.TextXAlignment.Center
ChatGPTLink.ZIndex = 21
ChatGPTLink.Parent = SettingsFrame

local ChatGPTLinkCorner = Instance.new("UICorner")
ChatGPTLinkCorner.CornerRadius = UDim.new(0, 10)
ChatGPTLinkCorner.Parent = ChatGPTLink

--========================================================
-- COPY BUTTON
--========================================================

local CopyLinkButton = Instance.new("TextButton")
CopyLinkButton.Size = UDim2.new(1, -36, 0, 38)
CopyLinkButton.Position = UDim2.new(0, 18, 0, 140)
CopyLinkButton.BackgroundColor3 = CARD
CopyLinkButton.Text = "📋  COPY LINK"
CopyLinkButton.TextColor3 = WHITE
CopyLinkButton.TextSize = 12
CopyLinkButton.Font = Enum.Font.GothamBold
CopyLinkButton.AutoButtonColor = false
CopyLinkButton.ZIndex = 21
CopyLinkButton.Parent = SettingsFrame

local CopyLinkCorner = Instance.new("UICorner")
CopyLinkCorner.CornerRadius = UDim.new(0, 10)
CopyLinkCorner.Parent = CopyLinkButton

local MoreSettings = Instance.new("TextLabel")
MoreSettings.Size = UDim2.new(1, -36, 0, 25)
MoreSettings.Position = UDim2.new(0, 18, 0, 187)
MoreSettings.BackgroundTransparency = 1
MoreSettings.Text = "🍌 Banana Script • UI Edition"
MoreSettings.TextColor3 = DARK_GRAY
MoreSettings.TextSize = 12
MoreSettings.Font = Enum.Font.Gotham
MoreSettings.ZIndex = 21
MoreSettings.Parent = SettingsFrame

--========================================================
-- TAB SWITCH
--========================================================

local function SetTab(tab)
	BananaContent.Visible = false
	BLContent.Visible = false
	ChatContent.Visible = false

	BananaTab.BackgroundColor3 = CARD
	BLBuyTab.BackgroundColor3 = CARD
	ChatTab.BackgroundColor3 = CARD

	if tab == "BANANA" then
		BananaContent.Visible = true
		BananaTab.BackgroundColor3 = Color3.fromRGB(55, 47, 20)

	elseif tab == "BLBUY" then
		BLContent.Visible = true
		BLBuyTab.BackgroundColor3 = Color3.fromRGB(55, 47, 20)

	elseif tab == "CHAT" then
		ChatContent.Visible = true
		ChatTab.BackgroundColor3 = Color3.fromRGB(55, 47, 20)
	end
end

BananaTab.MouseButton1Click:Connect(function()
	SetTab("BANANA")
end)

BLBuyTab.MouseButton1Click:Connect(function()
	SetTab("BLBUY")
end)

ChatTab.MouseButton1Click:Connect(function()
	SetTab("CHAT")
end)

--========================================================
-- BUTTON STATES
--========================================================

local function UpdateButtons()

	SetButton(
		ESPButton,
		ESPEnabled,
		Color3.fromRGB(48, 130, 75)
	)

	ESPButton.Text =
		ESPEnabled
		and "👁   ESP: ON"
		or "👁   ESP: OFF"

	SetButton(
		TeleportButton,
		TeleportEnabled,
		Color3.fromRGB(70, 82, 160)
	)

	TeleportButton.Text =
		TeleportEnabled
		and "🌀   TELEPORT: ON"
		or "🌀   TELEPORT: OFF"

	SetButton(
		SpeedButton,
		SpeedEnabled,
		Color3.fromRGB(170, 115, 35)
	)

	SpeedButton.Text =
		SpeedEnabled
		and "⚡   SPEED: ON"
		or "⚡   SPEED: OFF"

	SetButton(
		WallhackButton,
		WallhackEnabled,
		Color3.fromRGB(40, 125, 155)
	)

	WallhackButton.Text =
		WallhackEnabled
		and "🧱   WALLHACK: ON"
		or "🧱   WALLHACK: OFF"

	SetButton(
		FlyButton,
		FlyEnabled,
		Color3.fromRGB(55, 125, 185)
	)

	FlyButton.Text =
		FlyEnabled
		and "✈️   FLY: ON"
		or "✈️   FLY: OFF"

	SetButton(
		AFKButton,
		AFKEnabled,
		Color3.fromRGB(85, 95, 108)
	)

	AFKButton.Text =
		AFKEnabled
		and "🛡️   FULL AFK: ON"
		or "🛡️   FULL AFK: OFF"

	SetButton(
		AutoBuyButton,
		AutoBuyEnabled,
		Color3.fromRGB(80, 140, 75)
	)

	AutoBuyButton.Text =
		AutoBuyEnabled
		and "🛒   AUTO BUY: ON"
		or "🛒   AUTO BUY: OFF"

	SetButton(
		AnchoredButton,
		AnchoredEnabled,
		Color3.fromRGB(100, 90, 120)
	)

	AnchoredButton.Text =
		AnchoredEnabled
		and "⚓   ANCHORED: ON"
		or "⚓   ANCHORED: OFF"

	SetButton(
		DanceButton,
		DanceEnabled,
		Color3.fromRGB(135, 75, 160)
	)

	DanceButton.Text =
		DanceEnabled
		and "💃   DANCE 2: ON"
		or "💃   DANCE 2: OFF"

	SetButton(
		MouseUnlockButton,
		MouseUnlockEnabled,
		Color3.fromRGB(55, 115, 155)
	)

	MouseUnlockButton.Text =
		MouseUnlockEnabled
		and "🖱   MOUSE UNLOCK: ON"
		or "🖱   MOUSE UNLOCK: OFF"

	DanceKeyButton.Text = DanceHotkey.Name
	MouseKeyButton.Text = MouseUnlockKey.Name
end

--========================================================
-- ESP
--========================================================

local function CreateESP(char)
	if not char or char == Player.Character then
		return
	end

	if char:FindFirstChild("BananaESP") then
		local Existing = char.BananaESP
		Existing.Enabled = ESPEnabled
		return
	end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "BananaESP"
	Highlight.FillColor = YELLOW
	Highlight.OutlineColor = WHITE
	Highlight.FillTransparency = 0.45
	Highlight.OutlineTransparency = 0
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.Enabled = ESPEnabled
	Highlight.Parent = char
end

local function UpdateESP()
	for _, OtherPlayer in ipairs(Players:GetPlayers()) do
		if OtherPlayer ~= Player and OtherPlayer.Character then
			CreateESP(OtherPlayer.Character)

			local Highlight =
				OtherPlayer.Character:FindFirstChild("BananaESP")

			if Highlight then
				Highlight.Enabled = ESPEnabled
			end
		end
	end
end

ESPButton.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled
	UpdateESP()
	UpdateButtons()
end)

--========================================================
-- PLAYER LIST
--========================================================

local function RefreshPlayerList()
	local list = {}

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player then
			table.insert(list, p)
		end
	end

	if #list == 0 then
		SelectedPlayer = nil
		PlayerListButton.Text = "👤   NO OTHER PLAYERS"
		return
	end

	if SelectedPlayer then
		for _, p in ipairs(list) do
			if p.Name == SelectedPlayer then
				PlayerListButton.Text = "👤   " .. SelectedPlayer
				return
			end
		end
	end

	SelectedPlayer = list[1].Name
	PlayerListButton.Text = "👤   " .. SelectedPlayer
end

PlayerListButton.MouseButton1Click:Connect(function()
	local list = {}

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Player then
			table.insert(list, p)
		end
	end

	if #list == 0 then
		SelectedPlayer = nil
		PlayerListButton.Text = "👤   NO OTHER PLAYERS"
		return
	end

	local index = 0

	for i, p in ipairs(list) do
		if p.Name == SelectedPlayer then
			index = i
			break
		end
	end

	index = (index % #list) + 1

	SelectedPlayer = list[index].Name
	PlayerListButton.Text = "👤   " .. SelectedPlayer
end)

RefreshPlayersButton.MouseButton1Click:Connect(
	RefreshPlayerList
)

TPToPlayerButton.MouseButton1Click:Connect(function()
	if not RootPart or not SelectedPlayer or AFKEnabled then
		return
	end

	local Target = Players:FindFirstChild(SelectedPlayer)

	if Target and Target.Character then
		local TargetRoot =
			Target.Character:FindFirstChild("HumanoidRootPart")

		if TargetRoot then
			RootPart.CFrame =
				TargetRoot.CFrame
				+ Vector3.new(0, 3, 0)
		end
	end
end)

Players.PlayerRemoving:Connect(function(p)
	if p.Name == SelectedPlayer then
		SelectedPlayer = nil
		task.defer(RefreshPlayerList)
	end
end)

RefreshPlayerList()

--========================================================
-- TELEPORT
--========================================================

DistanceBox.FocusLost:Connect(function()
	local N = tonumber(DistanceBox.Text)

	if N then
		TeleportDistance =
			math.clamp(N, 1, 1000)
	end

	DistanceBox.Text =
		tostring(TeleportDistance)
end)

TeleportButton.MouseButton1Click:Connect(function()
	TeleportEnabled = not TeleportEnabled
	UpdateButtons()
end)

TPButton.MouseButton1Click:Connect(function()
	if TeleportEnabled
		and RootPart
		and not AFKEnabled then

		RootPart.CFrame +=
			RootPart.CFrame.LookVector
			* TeleportDistance
	end
end)

--========================================================
-- SPEED
--========================================================

SpeedBox.FocusLost:Connect(function()
	local N = tonumber(SpeedBox.Text)

	if N then
		WalkSpeed =
			math.clamp(N, 1, 200)
	end

	SpeedBox.Text =
		tostring(WalkSpeed)

	if SpeedEnabled and Humanoid then
		Humanoid.WalkSpeed = WalkSpeed
	end
end)

SpeedButton.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled

	if Humanoid then
		Humanoid.WalkSpeed =
			SpeedEnabled
			and WalkSpeed
			or 16
	end

	UpdateButtons()
end)

--========================================================
-- WALLHACK
--========================================================

WallhackButton.MouseButton1Click:Connect(function()
	WallhackEnabled = not WallhackEnabled
	UpdateButtons()
end)

--========================================================
-- FLY
--========================================================

FlyBox.FocusLost:Connect(function()
	local N = tonumber(FlyBox.Text)

	if N then
		FlySpeed =
			math.clamp(N, 1, 300)
	end

	FlyBox.Text =
		tostring(FlySpeed)
end)

local function StopFly()

	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection = nil
	end

	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity = nil
	end

	if FlyOrientation then
		FlyOrientation:Destroy()
		FlyOrientation = nil
	end

	if FlyAttachment then
		FlyAttachment:Destroy()
		FlyAttachment = nil
	end

	if Humanoid then
		Humanoid.PlatformStand = false
		Humanoid.AutoRotate = true
	end

	if RootPart then
		RootPart.AssemblyLinearVelocity = Vector3.zero
		RootPart.AssemblyAngularVelocity = Vector3.zero
	end
end

local function StartFly()

	StopFly()

	if not Humanoid or not RootPart then
		return
	end

	Humanoid.PlatformStand = true
	Humanoid.AutoRotate = false

	FlyAttachment = Instance.new("Attachment")
	FlyAttachment.Name = "BananaFlyAttachment"
	FlyAttachment.Parent = RootPart

	FlyVelocity = Instance.new("LinearVelocity")
	FlyVelocity.Name = "BananaFlyVelocity"
	FlyVelocity.Attachment0 = FlyAttachment
	FlyVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	FlyVelocity.MaxForce = math.huge
	FlyVelocity.VectorVelocity = Vector3.zero
	FlyVelocity.Parent = RootPart

	FlyOrientation = Instance.new("AlignOrientation")
	FlyOrientation.Name = "BananaFlyOrientation"
	FlyOrientation.Mode =
		Enum.OrientationAlignmentMode.OneAttachment
	FlyOrientation.Attachment0 = FlyAttachment
	FlyOrientation.MaxTorque = math.huge
	FlyOrientation.Responsiveness = 15
	FlyOrientation.RigidityEnabled = false
	FlyOrientation.Parent = RootPart

	FlyConnection =
		RunService.RenderStepped:Connect(function()

			if not FlyEnabled
				or not RootPart
				or not FlyVelocity then

				return
			end

			local Camera =
				workspace.CurrentCamera

			if not Camera then
				return
			end

			local Forward =
				Camera.CFrame.LookVector

			local Right =
				Camera.CFrame.RightVector

			local Direction =
				Vector3.zero

			if UIS:IsKeyDown(Enum.KeyCode.W) then
				Direction += Forward
			end

			if UIS:IsKeyDown(Enum.KeyCode.S) then
				Direction -= Forward
			end

			if UIS:IsKeyDown(Enum.KeyCode.D) then
				Direction += Right
			end

			if UIS:IsKeyDown(Enum.KeyCode.A) then
				Direction -= Right
			end

			if UIS:IsKeyDown(Enum.KeyCode.Space) then
				Direction += Vector3.new(0, 1, 0)
			end

			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
				Direction -= Vector3.new(0, 1, 0)
			end

			if Direction.Magnitude > 0 then
				Direction =
					Direction.Unit * FlySpeed
			end

			FlyVelocity.VectorVelocity =
				Direction

			local Look =
				Camera.CFrame.LookVector

			FlyOrientation.CFrame =
				CFrame.lookAt(
					Vector3.zero,
					Look
				)
		end)
end

FlyButton.MouseButton1Click:Connect(function()

	FlyEnabled = not FlyEnabled

	if FlyEnabled and not AFKEnabled then
		StartFly()
	else
		FlyEnabled = false
		StopFly()
	end

	UpdateButtons()
end)

--========================================================
-- AFK
--========================================================

AFKButton.MouseButton1Click:Connect(function()

	AFKEnabled = not AFKEnabled

	if AFKEnabled then

		if FlyEnabled then
			FlyEnabled = false
			StopFly()
		end

		if Humanoid then
			Humanoid.WalkSpeed = 0
			Humanoid.AutoRotate = false
			Humanoid.PlatformStand = true
		end

		if Character then
			for _, Part in ipairs(Character:GetDescendants()) do
				if Part:IsA("BasePart") then
					Part.CanCollide = false
				end
			end
		end

		if RootPart then
			RootPart.Anchored = true
		end

	else

		if RootPart then
			RootPart.Anchored = false
		end

		if Humanoid then
			Humanoid.PlatformStand = false
			Humanoid.AutoRotate = true

			Humanoid.WalkSpeed =
				SpeedEnabled
				and WalkSpeed
				or 16
		end
	end

	UpdateButtons()
end)

--========================================================
-- ANCHORED
--========================================================

local function ApplyAnchored(value)

	if not Character then
		return
	end

	for _, part in ipairs(Character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Anchored = value
		end
	end
end

AnchoredButton.MouseButton1Click:Connect(function()

	AnchoredEnabled =
		not AnchoredEnabled

	ApplyAnchored(AnchoredEnabled)

	UpdateButtons()
end)

--========================================================
-- AUTO BUY
--========================================================

AutoBuyBox.FocusLost:Connect(function()

	local N =
		tonumber(AutoBuyBox.Text)

	if N then
		AutoBuyMS =
			math.max(1, math.floor(N))
	end

	AutoBuyBox.Text =
		tostring(AutoBuyMS)
end)

local function TriggerPrompt(prompt)

	if not prompt
		or not prompt:IsA("ProximityPrompt") then
		return
	end

	pcall(function()

		if typeof(fireproximityprompt) == "function" then
			fireproximityprompt(prompt)
			return
		end

		prompt:InputHoldBegin()
		task.wait(
			math.max(
				prompt.HoldDuration,
				0
			)
		)
		prompt:InputHoldEnd()
	end)
end

AutoBuyButton.MouseButton1Click:Connect(function()
	AutoBuyEnabled =
		not AutoBuyEnabled

	UpdateButtons()
end)

task.spawn(function()

	while task.wait() do

		if AutoBuyEnabled then

			local Prompts = {}

			for _, obj in ipairs(
				workspace:GetDescendants()
			) do

				if obj:IsA("ProximityPrompt") then
					table.insert(Prompts, obj)
				end
			end

			for _, prompt in ipairs(Prompts) do

				if not AutoBuyEnabled then
					break
				end

				TriggerPrompt(prompt)

				task.wait(
					AutoBuyMS / 1000
				)
			end

		else
			task.wait(0.2)
		end
	end
end)

--========================================================
-- MONEY
--========================================================

local function FindMoney()

	local leaderstats =
		Player:FindFirstChild("leaderstats")

	if not leaderstats then
		return nil
	end

	local PreferredNames = {
		"Cash",
		"Money",
		"Coins",
		"Brainrot",
		"Points"
	}

	for _, name in ipairs(PreferredNames) do

		local obj =
			leaderstats:FindFirstChild(name)

		if obj
			and (
				obj:IsA("IntValue")
				or obj:IsA("NumberValue")
			) then

			return obj
		end
	end

	for _, obj in ipairs(
		leaderstats:GetChildren()
	) do

		if obj:IsA("IntValue")
			or obj:IsA("NumberValue") then

			return obj
		end
	end

	return nil
end

local function UpdateMoney()

	local money =
		FindMoney()

	if money then

		local value =
			money.Value

		MoneyLabel.Text =
			"$ "
			.. tostring(value)

	else
		MoneyLabel.Text =
			"$ 0"
	end
end

task.spawn(function()

	while task.wait(1) do
		UpdateMoney()
	end
end)

--========================================================
-- DANCE 2
--========================================================

local DANCE_ID = "182436842"

local function StopDance()

	if DanceTrack then

		pcall(function()
			DanceTrack:Stop(0.15)
		end)

		pcall(function()
			DanceTrack:Destroy()
		end)

		DanceTrack = nil
	end
end

local function StartDance()

	StopDance()

	if not Humanoid then
		return
	end

	if Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		return
	end

	local Animator =
		Humanoid:FindFirstChildOfClass(
			"Animator"
		)

	if not Animator then

		Animator =
			Instance.new("Animator")

		Animator.Parent = Humanoid
	end

	local Animation =
		Instance.new("Animation")

	Animation.AnimationId =
		"rbxassetid://" .. DANCE_ID

	local Success, Track =
		pcall(function()
			return Animator:LoadAnimation(
				Animation
			)
		end)

	Animation:Destroy()

	if not Success or not Track then
		return
	end

	Track.Priority =
		Enum.AnimationPriority.Action

	Track.Looped = true

	Track:Play(0.15)

	DanceTrack = Track
end

local function ToggleDance()

	if not Humanoid then
		return
	end

	if Humanoid.RigType ~= Enum.HumanoidRigType.R6 then
		DanceEnabled = false
		UpdateButtons()
		return
	end

	DanceEnabled =
		not DanceEnabled

	if DanceEnabled then
		StartDance()
	else
		StopDance()
	end

	UpdateButtons()
end

DanceButton.MouseButton1Click:Connect(
	ToggleDance
)

--========================================================
-- MOUSE UNLOCK
-- ИСПРАВЛЕНО
--========================================================

local function ForceMouseUnlock()

	pcall(function()
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end)

	pcall(function()
		UIS.MouseIconEnabled = true
	end)

end

local function EnableMouseUnlock()

	pcall(function()
		RunService:UnbindFromRenderStep(
			"BananaMouseUnlock"
		)
	end)

	-- Ставим MouseBehavior каждый кадр.
	-- Это не меняет интерфейс, только исправляет
	-- работу самой функции Mouse Unlock.

	RunService:BindToRenderStep(
		"BananaMouseUnlock",
		Enum.RenderPriority.Last.Value,
		function()

			if MouseUnlockEnabled then
				ForceMouseUnlock()
			end

		end
	)

	ForceMouseUnlock()
end

local function DisableMouseUnlock()

	pcall(function()
		RunService:UnbindFromRenderStep(
			"BananaMouseUnlock"
		)
	end)

	pcall(function()
		UIS.MouseBehavior =
			Enum.MouseBehavior.Default
	end)

	pcall(function()
		UIS.MouseIconEnabled = true
	end)
end

MouseUnlockButton.MouseButton1Click:Connect(function()

	MouseUnlockEnabled =
		not MouseUnlockEnabled

	if MouseUnlockEnabled then
		EnableMouseUnlock()
	else
		DisableMouseUnlock()
	end

	UpdateButtons()
end)

--========================================================
-- SETTINGS
--========================================================

SettingsButton.MouseButton1Click:Connect(function()
	SettingsFrame.Visible = true
end)

SettingsClose.MouseButton1Click:Connect(function()
	SettingsFrame.Visible = false
end)

--========================================================
-- COPY CHATGPT LINK
--========================================================

CopyLinkButton.MouseEnter:Connect(function()
	CopyLinkButton.BackgroundColor3 = CARD_HOVER
end)

CopyLinkButton.MouseLeave:Connect(function()
	CopyLinkButton.BackgroundColor3 = CARD
end)

CopyLinkButton.MouseButton1Click:Connect(function()

	local Success = false

	pcall(function()

		if typeof(setclipboard) == "function" then

			setclipboard("chatgpt.com")
			Success = true

		elseif typeof(toclipboard) == "function" then

			toclipboard("chatgpt.com")
			Success = true

		end

	end)

	if Success then

		CopyLinkButton.Text = "✅  COPIED!"

		task.delay(1.2, function()

			if CopyLinkButton
				and CopyLinkButton.Parent then

				CopyLinkButton.Text =
					"📋  COPY LINK"
			end
		end)

	else

		CopyLinkButton.Text =
			"❌  COPY UNAVAILABLE"

		task.delay(1.5, function()

			if CopyLinkButton
				and CopyLinkButton.Parent then

				CopyLinkButton.Text =
					"📋  COPY LINK"
			end
		end)
	end
end)

--========================================================
-- MAIN WINDOW DRAG
--========================================================

local MainDragging = false
local MainDragStart
local MainStartPosition

local MainDragArea = Instance.new("Frame")
MainDragArea.Size = UDim2.new(1, -150, 0, 92)
MainDragArea.Position = UDim2.new(0, 0, 0, 0)
MainDragArea.BackgroundTransparency = 1
MainDragArea.Active = true
MainDragArea.Parent = Header

MainDragArea.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		MainDragging = true

		MainDragStart =
			Input.Position

		MainStartPosition =
			Frame.Position
	end
end)

UIS.InputChanged:Connect(function(Input)

	if MainDragging
		and Input.UserInputType ==
			Enum.UserInputType.MouseMovement then

		local Delta =
			Input.Position
			- MainDragStart

		Frame.Position =
			UDim2.new(
				MainStartPosition.X.Scale,
				MainStartPosition.X.Offset
					+ Delta.X,

				MainStartPosition.Y.Scale,
				MainStartPosition.Y.Offset
					+ Delta.Y
			)
	end
end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		MainDragging = false
	end
end)

--========================================================
-- SETTINGS DRAG
--========================================================

local SettingsDragging = false
local SettingsDragStart
local SettingsStartPosition

SettingsDragBar.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		SettingsDragging = true

		SettingsDragStart =
			Input.Position

		SettingsStartPosition =
			SettingsFrame.Position
	end
end)

UIS.InputChanged:Connect(function(Input)

	if SettingsDragging
		and Input.UserInputType ==
			Enum.UserInputType.MouseMovement then

		local Delta =
			Input.Position
			- SettingsDragStart

		SettingsFrame.Position =
			UDim2.new(
				SettingsStartPosition.X.Scale,
				SettingsStartPosition.X.Offset
					+ Delta.X,

				SettingsStartPosition.Y.Scale,
				SettingsStartPosition.Y.Offset
					+ Delta.Y
			)
	end
end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		SettingsDragging = false
	end
end)

--========================================================
-- OPEN BUTTON DRAG FIX
--========================================================

local OpenDragging = false
local OpenDragMoved = false
local OpenDragStart
local OpenStartPosition

local DRAG_THRESHOLD = 7

OpenButton.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		OpenDragging = true
		OpenDragMoved = false

		OpenDragStart =
			Input.Position

		OpenStartPosition =
			OpenButton.Position
	end
end)

UIS.InputChanged:Connect(function(Input)

	if OpenDragging
		and Input.UserInputType ==
			Enum.UserInputType.MouseMovement then

		local Delta =
			Input.Position
			- OpenDragStart

		if Delta.Magnitude >=
			DRAG_THRESHOLD then

			OpenDragMoved = true
		end

		OpenButton.Position =
			UDim2.new(
				OpenStartPosition.X.Scale,
				OpenStartPosition.X.Offset
					+ Delta.X,

				OpenStartPosition.Y.Scale,
				OpenStartPosition.Y.Offset
					+ Delta.Y
			)
	end
end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1
		and OpenDragging then

		OpenDragging = false

		if not OpenDragMoved then

			Frame.Visible = true
			OpenButton.Visible = false
		end

		OpenDragMoved = false
	end
end)

--========================================================
-- CLOSE MAIN
--========================================================

CloseButton.MouseButton1Click:Connect(function()

	Frame.Visible = false
	OpenButton.Visible = true
end)

--========================================================
-- KEY PICKERS
--========================================================

DanceKeyButton.MouseButton1Click:Connect(function()

	ChoosingDanceKey = true
	DanceKeyButton.Text = "PRESS KEY"
end)

MouseKeyButton.MouseButton1Click:Connect(function()

	SelectingMouseKey = true
	MouseKeyButton.Text = "PRESS KEY"
end)

--========================================================
-- UNIFIED INPUT
--========================================================

UIS.InputBegan:Connect(function(Input, GameProcessed)

	--====================================================
	-- DANCE KEY SELECTION
	--====================================================

	if ChoosingDanceKey then

		if Input.UserInputType ==
			Enum.UserInputType.Keyboard then

			DanceHotkey =
				Input.KeyCode

			ChoosingDanceKey = false

			DanceKeyButton.Text =
				DanceHotkey.Name

			return
		end
	end

	--====================================================
	-- MOUSE UNLOCK KEY SELECTION
	--====================================================

	if SelectingMouseKey then

		if Input.UserInputType ==
			Enum.UserInputType.Keyboard then

			MouseUnlockKey =
				Input.KeyCode

			SelectingMouseKey = false

			MouseKeyButton.Text =
				MouseUnlockKey.Name

			return
		end
	end

	--====================================================
	-- MOUSE UNLOCK HOTKEY
	--====================================================

	if Input.UserInputType ==
		Enum.UserInputType.Keyboard
		and Input.KeyCode ==
		MouseUnlockKey then

		MouseUnlockEnabled =
			not MouseUnlockEnabled

		if MouseUnlockEnabled then
			EnableMouseUnlock()
		else
			DisableMouseUnlock()
		end

		UpdateButtons()
		return
	end

	--====================================================
	-- GAME PROCESSED
	--====================================================

	if GameProcessed then
		return
	end

	--====================================================
	-- DANCE 2 HOTKEY
	--====================================================

	if Input.UserInputType ==
		Enum.UserInputType.Keyboard
		and Input.KeyCode ==
		DanceHotkey then

		ToggleDance()
		return
	end
end)

--========================================================
-- RESPAWN
--========================================================

Player.CharacterAdded:Connect(function(char)

	task.wait(0.5)

	SetupCharacter(char)

	if FlyEnabled and not AFKEnabled then
		StartFly()
	end

	if DanceEnabled then
		task.wait(0.2)
		StartDance()
	end

	if AnchoredEnabled then
		ApplyAnchored(true)
	end

	if MouseUnlockEnabled then
		EnableMouseUnlock()
	end

	UpdateESP()
	UpdateButtons()
end)

--========================================================
-- PLAYER ESP CONNECTIONS
--========================================================

for _, OtherPlayer in ipairs(
	Players:GetPlayers()
) do

	if OtherPlayer ~= Player then

		OtherPlayer.CharacterAdded:Connect(
			function(char)

				task.wait(0.4)

				CreateESP(char)
			end
		)
	end
end

Players.PlayerAdded:Connect(
	function(OtherPlayer)

		OtherPlayer.CharacterAdded:Connect(
			function(char)

				task.wait(0.4)

				CreateESP(char)
			end
		)
	end
)

--========================================================
-- MAIN HEARTBEAT
--========================================================

RunService.Heartbeat:Connect(function()

	if SpeedEnabled
		and Humanoid
		and not AFKEnabled then

		if Humanoid.WalkSpeed
			~= WalkSpeed then

			Humanoid.WalkSpeed =
				WalkSpeed
		end
	end

	if WallhackEnabled
		and Character
		and not AFKEnabled then

		for _, Part in ipairs(
			Character:GetDescendants()
		) do

			if Part:IsA("BasePart") then
				Part.CanCollide = false
			end
		end
	end

	if AFKEnabled and RootPart then

		RootPart.Anchored = true

		RootPart.AssemblyLinearVelocity =
			Vector3.zero

		RootPart.AssemblyAngularVelocity =
			Vector3.zero
	end

	if AnchoredEnabled
		and Character
		and not AFKEnabled then

		for _, Part in ipairs(
			Character:GetDescendants()
		) do

			if Part:IsA("BasePart")
				and not Part.Anchored then

				Part.Anchored = true
			end
		end
	end
end)

--========================================================
-- START
--========================================================

SetTab("BANANA")
RefreshPlayerList()
UpdateButtons()
UpdateESP()
UpdateMoney()

print("🍌 Banana Script + BL BUY + CHAT + PLAYER TELEPORT loaded successfully!")
