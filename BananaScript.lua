--========================================================
-- 🍌 BANANA SCRIPT
-- MODERN UI EDITION
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

--========================================================
-- SETTINGS
--========================================================

local ESPEnabled = true

local TeleportEnabled = false
local TeleportDistance = 10
local TeleportOffset = 3
local ResetVelocityOnTeleport = true

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

local CurrentTPTab = "FORWARD"

--========================================================
-- TELEPORT POINTS
--========================================================

local TeleportPoints = {
	[1] = nil,
	[2] = nil,
	[3] = nil,
	[4] = nil,
	[5] = nil
}

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

local BG = Color3.fromRGB(10, 11, 15)
local PANEL = Color3.fromRGB(17, 19, 25)
local PANEL_2 = Color3.fromRGB(21, 23, 30)

local CARD = Color3.fromRGB(27, 30, 39)
local CARD_HOVER = Color3.fromRGB(35, 38, 49)
local CARD_ACTIVE = Color3.fromRGB(54, 46, 20)

local YELLOW = Color3.fromRGB(255, 207, 55)
local YELLOW_LIGHT = Color3.fromRGB(255, 224, 105)

local WHITE = Color3.fromRGB(245, 246, 250)
local GRAY = Color3.fromRGB(145, 149, 162)
local DARK_GRAY = Color3.fromRGB(95, 99, 112)

local GREEN = Color3.fromRGB(70, 205, 105)
local RED = Color3.fromRGB(220, 75, 75)
local BLUE = Color3.fromRGB(82, 135, 215)

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
-- UI HELPERS
--========================================================

local function Tween(Object, Properties, Duration)
	return TweenService:Create(
		Object,
		TweenInfo.new(
			Duration or 0.15,
			Enum.EasingStyle.Quad,
			Enum.EasingDirection.Out
		),
		Properties
	)
end

local function AddCorner(Object, Radius)
	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, Radius or 12)
	Corner.Parent = Object
	return Corner
end

local function AddStroke(Object, Color, Thickness, Transparency)
	local Stroke = Instance.new("UIStroke")
	Stroke.Color = Color
	Stroke.Thickness = Thickness or 1
	Stroke.Transparency = Transparency or 0
	Stroke.Parent = Object
	return Stroke
end

local function Button(parent, text, y, height)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(1, -28, 0, height or 46)
	B.Position = UDim2.new(0, 14, 0, y)
	B.BackgroundColor3 = CARD
	B.Text = text
	B.TextColor3 = WHITE
	B.TextSize = 13
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = parent

	AddCorner(B, 12)
	AddStroke(B, Color3.fromRGB(48, 51, 62), 1, 0)

	B.MouseEnter:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B, {
				BackgroundColor3 = CARD_HOVER
			}, 0.12):Play()
		end
	end)

	B.MouseLeave:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B, {
				BackgroundColor3 = CARD
			}, 0.12):Play()
		end
	end)

	return B
end

local function Box(parent, value, y, width)
	local B = Instance.new("TextBox")
	B.Size = UDim2.new(
		0,
		width or (parent.AbsoluteSize.X - 28),
		0,
		38
	)
	B.Position = UDim2.new(0, 14, 0, y)
	B.BackgroundColor3 = PANEL
	B.TextColor3 = WHITE
	B.PlaceholderColor3 = DARK_GRAY
	B.Text = tostring(value)
	B.TextSize = 13
	B.Font = Enum.Font.GothamBold
	B.ClearTextOnFocus = false
	B.Parent = parent

	AddCorner(B, 10)
	AddStroke(B, Color3.fromRGB(45, 48, 58), 1, 0)

	return B
end

local function SetButton(B, active, color)
	B:SetAttribute("Active", active)

	if active then
		Tween(B, {
			BackgroundColor3 = color
		}, 0.12):Play()
	else
		Tween(B, {
			BackgroundColor3 = CARD
		}, 0.12):Play()
	end
end

local function Section(parent, text, y)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -28, 0, 24)
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

local function KeyButton(parent, text, y)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(0, 110, 0, 40)
	B.Position = UDim2.new(1, -124, 0, y)
	B.BackgroundColor3 = CARD
	B.Text = text
	B.TextColor3 = WHITE
	B.TextSize = 12
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = parent

	AddCorner(B, 10)
	AddStroke(B, Color3.fromRGB(48, 51, 62), 1)

	B.MouseEnter:Connect(function()
		Tween(B, {
			BackgroundColor3 = CARD_HOVER
		}, 0.12):Play()
	end)

	B.MouseLeave:Connect(function()
		Tween(B, {
			BackgroundColor3 = CARD
		}, 0.12):Play()
	end)

	return B
end

local function CreateCard(parent, position, size)
	local F = Instance.new("Frame")
	F.Position = position
	F.Size = size
	F.BackgroundColor3 = PANEL_2
	F.BorderSizePixel = 0
	F.Parent = parent

	AddCorner(F, 14)
	AddStroke(F, Color3.fromRGB(42, 45, 56), 1)

	return F
end

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

AddCorner(OpenButton, 100)
AddStroke(OpenButton, YELLOW, 2, 0)

OpenButton.MouseEnter:Connect(function()
	Tween(OpenButton, {
		BackgroundColor3 = CARD_HOVER
	}, 0.12):Play()
end)

OpenButton.MouseLeave:Connect(function()
	Tween(OpenButton, {
		BackgroundColor3 = PANEL
	}, 0.12):Play()
end)

--========================================================
-- MAIN FRAME
--========================================================

local Frame = Instance.new("Frame")
Frame.Name = "Main"
Frame.Size = UDim2.new(0, 390, 0, 670)
Frame.Position = UDim2.new(0, 25, 0.5, -335)
Frame.BackgroundColor3 = BG
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

AddCorner(Frame, 22)
AddStroke(Frame, YELLOW, 1.5, 0.15)

--========================================================
-- HEADER
--========================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 95)
Header.BackgroundColor3 = PANEL
Header.BorderSizePixel = 0
Header.Parent = Frame

AddCorner(Header, 22)

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
BananaIcon.Size = UDim2.new(0, 56, 0, 56)
BananaIcon.Position = UDim2.new(0, 15, 0, 18)
BananaIcon.BackgroundColor3 = YELLOW
BananaIcon.Text = "🍌"
BananaIcon.TextSize = 29
BananaIcon.Font = Enum.Font.GothamBold
BananaIcon.Parent = Header

AddCorner(BananaIcon, 16)

--========================================================
-- HEADER TEXT
--========================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 0, 28)
Title.Position = UDim2.new(0, 84, 0, 13)
Title.BackgroundTransparency = 1
Title.Text = "BANANA SCRIPT"
Title.TextColor3 = WHITE
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -180, 0, 20)
Subtitle.Position = UDim2.new(0, 85, 0, 41)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Modern UI • ChatGPT × TheYaruck"
Subtitle.TextColor3 = GRAY
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = Header

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(0, 74, 0, 22)
Status.Position = UDim2.new(0, 84, 0, 65)
Status.BackgroundColor3 = Color3.fromRGB(24, 65, 38)
Status.Text = "● ONLINE"
Status.TextColor3 = GREEN
Status.TextSize = 9
Status.Font = Enum.Font.GothamBold
Status.Parent = Header

AddCorner(Status, 100)

--========================================================
-- HEADER BUTTONS
--========================================================

local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 38, 0, 38)
SettingsButton.Position = UDim2.new(1, -100, 0, 25)
SettingsButton.BackgroundColor3 = CARD
SettingsButton.Text = "⚙"
SettingsButton.TextColor3 = WHITE
SettingsButton.TextSize = 19
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.AutoButtonColor = false
SettingsButton.Parent = Header

AddCorner(SettingsButton, 11)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 38, 0, 38)
CloseButton.Position = UDim2.new(1, -52, 0, 25)
CloseButton.BackgroundColor3 = CARD
CloseButton.Text = "×"
CloseButton.TextColor3 = WHITE
CloseButton.TextSize = 23
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

AddCorner(CloseButton, 11)

local function AddButtonHover(B)
	B.MouseEnter:Connect(function()
		Tween(B, {
			BackgroundColor3 = CARD_HOVER
		}, 0.12):Play()
	end)

	B.MouseLeave:Connect(function()
		Tween(B, {
			BackgroundColor3 = CARD
		}, 0.12):Play()
	end)
end

AddButtonHover(SettingsButton)
AddButtonHover(CloseButton)

--========================================================
-- MAIN TABS
--========================================================

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 44)
TabBar.Position = UDim2.new(0, 10, 0, 103)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Frame

local function MakeTab(text, x)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(1/3, -5, 1, 0)
	B.Position = UDim2.new(x, 0, 0, 0)
	B.BackgroundColor3 = CARD
	B.Text = text
	B.TextColor3 = WHITE
	B.TextSize = 11
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = TabBar

	AddCorner(B, 11)

	B.MouseEnter:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B, {
				BackgroundColor3 = CARD_HOVER
			}, 0.12):Play()
		end
	end)

	B.MouseLeave:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B, {
				BackgroundColor3 = CARD
			}, 0.12):Play()
		end
	end)

	return B
end

local BananaTab = MakeTab("🍌  BANANA", 0)
local BLBuyTab = MakeTab("🛒  BL BUY", 1/3)
local ChatTab = MakeTab("💬  CHAT", 2/3)

--========================================================
-- CONTENT HOLDER
--========================================================

local ContentHolder = Instance.new("Frame")
ContentHolder.Size = UDim2.new(1, -20, 1, -160)
ContentHolder.Position = UDim2.new(0, 10, 0, 155)
ContentHolder.BackgroundTransparency = 1
ContentHolder.Parent = Frame

local function CreateContent()
	local S = Instance.new("ScrollingFrame")
	S.Size = UDim2.new(1, 0, 1, 0)
	S.BackgroundTransparency = 1
	S.BorderSizePixel = 0
	S.ScrollBarThickness = 3
	S.ScrollBarImageColor3 = YELLOW
	S.CanvasSize = UDim2.new(0, 0, 0, 1000)
	S.Visible = false
	S.Parent = ContentHolder
	return S
end

local BananaContent = CreateContent()
local BLContent = CreateContent()
local ChatContent = CreateContent()

--========================================================
-- BANANA CONTENT
--========================================================

Section(BananaContent, "👁  VISUALS", 10)

local ESPButton = Button(
	BananaContent,
	"👁   ESP: ON",
	38
)

--========================================================
-- TELEPORT HEADER
--========================================================

Section(BananaContent, "🚀  TELEPORT", 98)

local TeleportCard = CreateCard(
	BananaContent,
	UDim2.new(0, 14, 0, 128),
	UDim2.new(1, -28, 0, 300)
)

local TeleportTitle = Instance.new("TextLabel")
TeleportTitle.Size = UDim2.new(1, -24, 0, 25)
TeleportTitle.Position = UDim2.new(0, 12, 0, 9)
TeleportTitle.BackgroundTransparency = 1
TeleportTitle.Text = "Teleport Center"
TeleportTitle.TextColor3 = WHITE
TeleportTitle.TextSize = 14
TeleportTitle.TextXAlignment = Enum.TextXAlignment.Left
TeleportTitle.Font = Enum.Font.GothamBold
TeleportTitle.Parent = TeleportCard

local TeleportSubtitle = Instance.new("TextLabel")
TeleportSubtitle.Size = UDim2.new(1, -24, 0, 20)
TeleportSubtitle.Position = UDim2.new(0, 12, 0, 32)
TeleportSubtitle.BackgroundTransparency = 1
TeleportSubtitle.Text = "Choose a teleport mode"
TeleportSubtitle.TextColor3 = GRAY
TeleportSubtitle.TextSize = 10
TeleportSubtitle.TextXAlignment = Enum.TextXAlignment.Left
TeleportSubtitle.Font = Enum.Font.Gotham
TeleportSubtitle.Parent = TeleportCard

--========================================================
-- TELEPORT SUBTABS
--========================================================

local TPTabBar = Instance.new("Frame")
TPTabBar.Size = UDim2.new(1, -24, 0, 38)
TPTabBar.Position = UDim2.new(0, 12, 0, 60)
TPTabBar.BackgroundTransparency = 1
TPTabBar.Parent = TeleportCard

local TPTabButtons = {}

local function MakeTPTab(name, text, x)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(0.25, -4, 1, 0)
	B.Position = UDim2.new(x, 0, 0, 0)
	B.BackgroundColor3 = CARD
	B.Text = text
	B.TextColor3 = GRAY
	B.TextSize = 9
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = TPTabBar

	AddCorner(B, 9)

	TPTabButtons[name] = B

	B.MouseEnter:Connect(function()
		if CurrentTPTab ~= name then
			Tween(B, {
				BackgroundColor3 = CARD_HOVER
			}, 0.1):Play()
		end
	end)

	B.MouseLeave:Connect(function()
		if CurrentTPTab ~= name then
			Tween(B, {
				BackgroundColor3 = CARD
			}, 0.1):Play()
		end
	end)

	return B
end

local ForwardTab = MakeTPTab(
	"FORWARD",
	"🚀 FORWARD",
	0
)

local PlayerTab = MakeTPTab(
	"PLAYER",
	"👤 PLAYER",
	0.25
)

local PointsTab = MakeTPTab(
	"POINTS",
	"📍 POINTS",
	0.50
)

local TPSettingsTab = MakeTPTab(
	"SETTINGS",
	"⚙ SETTINGS",
	0.75
)

--========================================================
-- TELEPORT SUBPANELS
--========================================================

local function CreateTPPanel()
	local P = Instance.new("Frame")
	P.Size = UDim2.new(1, -24, 0, 184)
	P.Position = UDim2.new(0, 12, 0, 106)
	P.BackgroundTransparency = 1
	P.Visible = false
	P.Parent = TeleportCard
	return P
end

local ForwardPanel = CreateTPPanel()
local PlayerPanel = CreateTPPanel()
local PointsPanel = CreateTPPanel()
local TPSettingsPanel = CreateTPPanel()

--========================================================
-- FORWARD PANEL
--========================================================

local TeleportButton = Button(
	ForwardPanel,
	"🌀   TELEPORT: OFF",
	4,
	40
)

local ForwardLabel = Instance.new("TextLabel")
ForwardLabel.Size = UDim2.new(1, -4, 0, 18)
ForwardLabel.Position = UDim2.new(0, 2, 0, 51)
ForwardLabel.BackgroundTransparency = 1
ForwardLabel.Text = "DISTANCE"
ForwardLabel.TextColor3 = GRAY
ForwardLabel.TextSize = 9
ForwardLabel.TextXAlignment = Enum.TextXAlignment.Left
ForwardLabel.Font = Enum.Font.GothamBold
ForwardLabel.Parent = ForwardPanel

local DistanceBox = Instance.new("TextBox")
DistanceBox.Size = UDim2.new(1, -4, 0, 34)
DistanceBox.Position = UDim2.new(0, 2, 0, 71)
DistanceBox.BackgroundColor3 = PANEL
DistanceBox.TextColor3 = WHITE
DistanceBox.PlaceholderColor3 = DARK_GRAY
DistanceBox.Text = tostring(TeleportDistance)
DistanceBox.TextSize = 12
DistanceBox.Font = Enum.Font.GothamBold
DistanceBox.ClearTextOnFocus = false
DistanceBox.Parent = ForwardPanel

AddCorner(DistanceBox, 9)
AddStroke(DistanceBox, Color3.fromRGB(45, 48, 58), 1)

local TPButton = Button(
	ForwardPanel,
	"🚀   TP FORWARD",
	114,
	42
)

--========================================================
-- PLAYER PANEL
--========================================================

local PlayerListButton = Button(
	PlayerPanel,
	"👤   SELECT PLAYER",
	4,
	40
)

local RefreshPlayersButton = Button(
	PlayerPanel,
	"🔄   REFRESH PLAYERS",
	50,
	40
)

local TPToPlayerButton = Button(
	PlayerPanel,
	"🚀   TP TO PLAYER",
	96,
	42
)

local SelectedInfo = Instance.new("TextLabel")
SelectedInfo.Size = UDim2.new(1, -4, 0, 18)
SelectedInfo.Position = UDim2.new(0, 2, 0, 145)
SelectedInfo.BackgroundTransparency = 1
SelectedInfo.Text = "Select another player to teleport"
SelectedInfo.TextColor3 = DARK_GRAY
SelectedInfo.TextSize = 9
SelectedInfo.Font = Enum.Font.Gotham
SelectedInfo.TextXAlignment = Enum.TextXAlignment.Left
SelectedInfo.Parent = PlayerPanel

--========================================================
-- POINTS PANEL
--========================================================

local PointRows = {}

for i = 1, 5 do
	local Row = Instance.new("Frame")
	Row.Size = UDim2.new(1, 0, 0, 31)
	Row.Position = UDim2.new(0, 0, 0, (i - 1) * 34)
	Row.BackgroundTransparency = 1
	Row.Parent = PointsPanel

	local NameLabel = Instance.new("TextLabel")
	NameLabel.Size = UDim2.new(0, 55, 1, 0)
	NameLabel.Position = UDim2.new(0, 0, 0, 0)
	NameLabel.BackgroundTransparency = 1
	NameLabel.Text = "POINT " .. i
	NameLabel.TextColor3 = WHITE
	NameLabel.TextSize = 9
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.TextXAlignment = Enum.TextXAlignment.Left
	NameLabel.Parent = Row

	local StateLabel = Instance.new("TextLabel")
	StateLabel.Size = UDim2.new(0, 50, 1, 0)
	StateLabel.Position = UDim2.new(0, 55, 0, 0)
	StateLabel.BackgroundTransparency = 1
	StateLabel.Text = "EMPTY"
	StateLabel.TextColor3 = DARK_GRAY
	StateLabel.TextSize = 8
	StateLabel.Font = Enum.Font.GothamBold
	StateLabel.Parent = Row

	local SaveButton = Instance.new("TextButton")
	SaveButton.Size = UDim2.new(0, 72, 0, 29)
	SaveButton.Position = UDim2.new(1, -150, 0, 1)
	SaveButton.BackgroundColor3 = CARD
	SaveButton.Text = "SAVE"
	SaveButton.TextColor3 = WHITE
	SaveButton.TextSize = 9
	SaveButton.Font = Enum.Font.GothamBold
	SaveButton.AutoButtonColor = false
	SaveButton.Parent = Row

	AddCorner(SaveButton, 8)

	local TPPointButton = Instance.new("TextButton")
	TPPointButton.Size = UDim2.new(0, 72, 0, 29)
	TPPointButton.Position = UDim2.new(1, -74, 0, 1)
	TPPointButton.BackgroundColor3 = CARD
	TPPointButton.Text = "TP"
	TPPointButton.TextColor3 = WHITE
	TPPointButton.TextSize = 9
	TPPointButton.Font = Enum.Font.GothamBold
	TPPointButton.AutoButtonColor = false
	TPPointButton.Parent = Row

	AddCorner(TPPointButton, 8)

	PointRows[i] = {
		Row = Row,
		State = StateLabel,
		Save = SaveButton,
		TP = TPPointButton
	}
end

--========================================================
-- TP SETTINGS PANEL
--========================================================

local TPOffsetLabel = Instance.new("TextLabel")
TPOffsetLabel.Size = UDim2.new(1, -4, 0, 18)
TPOffsetLabel.Position = UDim2.new(0, 2, 0, 2)
TPOffsetLabel.BackgroundTransparency = 1
TPOffsetLabel.Text = "PLAYER TP OFFSET"
TPOffsetLabel.TextColor3 = GRAY
TPOffsetLabel.TextSize = 9
TPOffsetLabel.TextXAlignment = Enum.TextXAlignment.Left
TPOffsetLabel.Font = Enum.Font.GothamBold
TPOffsetLabel.Parent = TPSettingsPanel

local TPOffsetBox = Instance.new("TextBox")
TPOffsetBox.Size = UDim2.new(1, -4, 0, 34)
TPOffsetBox.Position = UDim2.new(0, 2, 0, 22)
TPOffsetBox.BackgroundColor3 = PANEL
TPOffsetBox.TextColor3 = WHITE
TPOffsetBox.Text = tostring(TeleportOffset)
TPOffsetBox.TextSize = 12
TPOffsetBox.Font = Enum.Font.GothamBold
TPOffsetBox.ClearTextOnFocus = false
TPOffsetBox.Parent = TPSettingsPanel

AddCorner(TPOffsetBox, 9)
AddStroke(TPOffsetBox, Color3.fromRGB(45, 48, 58), 1)

local ResetVelocityButton = Instance.new("TextButton")
ResetVelocityButton.Size = UDim2.new(1, -4, 0, 40)
ResetVelocityButton.Position = UDim2.new(0, 2, 0, 66)
ResetVelocityButton.BackgroundColor3 = CARD
ResetVelocityButton.TextColor3 = WHITE
ResetVelocityButton.TextSize = 11
ResetVelocityButton.Font = Enum.Font.GothamBold
ResetVelocityButton.AutoButtonColor = false
ResetVelocityButton.Parent = TPSettingsPanel

AddCorner(ResetVelocityButton, 10)

local TPSettingsInfo = Instance.new("TextLabel")
TPSettingsInfo.Size = UDim2.new(1, -4, 0, 45)
TPSettingsInfo.Position = UDim2.new(0, 2, 0, 115)
TPSettingsInfo.BackgroundTransparency = 1
TPSettingsInfo.Text = "Offset changes the height used when teleporting to a player."
TPSettingsInfo.TextColor3 = DARK_GRAY
TPSettingsInfo.TextSize = 9
TPSettingsInfo.Font = Enum.Font.Gotham
TPSettingsInfo.TextWrapped = true
TPSettingsInfo.TextXAlignment = Enum.TextXAlignment.Left
TPSettingsInfo.Parent = TPSettingsPanel

--========================================================
-- TELEPORT SUBTAB SWITCH
--========================================================

local function SetTPTab(tab)
	CurrentTPTab = tab

	ForwardPanel.Visible = false
	PlayerPanel.Visible = false
	PointsPanel.Visible = false
	TPSettingsPanel.Visible = false

	for Name, ButtonObject in pairs(TPTabButtons) do
		ButtonObject:SetAttribute("Active", Name == tab)

		if Name == tab then
			Tween(ButtonObject, {
				BackgroundColor3 = CARD_ACTIVE,
				TextColor3 = YELLOW_LIGHT
			}, 0.12):Play()
		else
			Tween(ButtonObject, {
				BackgroundColor3 = CARD,
				TextColor3 = GRAY
			}, 0.12):Play()
		end
	end

	if tab == "FORWARD" then
		ForwardPanel.Visible = true
	elseif tab == "PLAYER" then
		PlayerPanel.Visible = true
	elseif tab == "POINTS" then
		PointsPanel.Visible = true
	elseif tab == "SETTINGS" then
		TPSettingsPanel.Visible = true
	end
end

ForwardTab.MouseButton1Click:Connect(function()
	SetTPTab("FORWARD")
end)

PlayerTab.MouseButton1Click:Connect(function()
	SetTPTab("PLAYER")
end)

PointsTab.MouseButton1Click:Connect(function()
	SetTPTab("POINTS")
end)

TPSettingsTab.MouseButton1Click:Connect(function()
	SetTPTab("SETTINGS")
end)

--========================================================
-- OTHER BANANA FEATURES
--========================================================

Section(BananaContent, "⚡  MOVEMENT", 445)

local SpeedButton = Button(
	BananaContent,
	"⚡   SPEED: OFF",
	474
)

local SpeedBox = Box(
	BananaContent,
	WalkSpeed,
	522
)

Section(BananaContent, "🧱  WALLHACK", 577)

local WallhackButton = Button(
	BananaContent,
	"🧱   WALLHACK: OFF",
	605
)

Section(BananaContent, "✈️  FLY", 663)

local FlyButton = Button(
	BananaContent,
	"✈️   FLY: OFF",
	691
)

local FlyBox = Box(
	BananaContent,
	FlySpeed,
	739
)

Section(BananaContent, "🛡️  AFK", 794)

local AFKButton = Button(
	BananaContent,
	"🛡️   FULL AFK: OFF",
	822
)

BananaContent.CanvasSize = UDim2.new(0, 0, 0, 890)

--========================================================
-- BL BUY CONTENT
--========================================================

Section(BLContent, "🛒  AUTO BUY", 10)

local AutoBuyButton = Button(
	BLContent,
	"🛒   AUTO BUY: OFF",
	38
)

Section(BLContent, "⏱  INTERVAL", 98)

local AutoBuyBox = Box(
	BLContent,
	AutoBuyMS,
	126
)

Section(BLContent, "⚓  CHARACTER", 186)

local AnchoredButton = Button(
	BLContent,
	"⚓   ANCHORED: OFF",
	214
)

Section(BLContent, "💰  MONEY", 272)

local MoneyLabel = Instance.new("TextLabel")
MoneyLabel.Size = UDim2.new(1, -28, 0, 78)
MoneyLabel.Position = UDim2.new(0, 14, 0, 304)
MoneyLabel.BackgroundColor3 = CARD
MoneyLabel.Text = "$ 0"
MoneyLabel.TextColor3 = YELLOW_LIGHT
MoneyLabel.TextSize = 24
MoneyLabel.Font = Enum.Font.GothamBold
MoneyLabel.Parent = BLContent

AddCorner(MoneyLabel, 14)
AddStroke(MoneyLabel, Color3.fromRGB(48, 51, 62), 1)

BLContent.CanvasSize = UDim2.new(0, 0, 0, 410)

--========================================================
-- CHAT CONTENT
--========================================================

Section(ChatContent, "💃  DANCE 2", 10)

local DanceButton = Button(
	ChatContent,
	"💃   DANCE 2: OFF",
	38
)

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
DanceKeyLabel.Size = UDim2.new(0, 150, 0, 40)
DanceKeyLabel.Position = UDim2.new(0, 14, 0, 140)
DanceKeyLabel.BackgroundTransparency = 1
DanceKeyLabel.Text = "HOTKEY"
DanceKeyLabel.TextColor3 = WHITE
DanceKeyLabel.TextSize = 12
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
MouseKeyLabel.Size = UDim2.new(0, 150, 0, 40)
MouseKeyLabel.Position = UDim2.new(0, 14, 0, 286)
MouseKeyLabel.BackgroundTransparency = 1
MouseKeyLabel.Text = "MOUSE HOTKEY"
MouseKeyLabel.TextColor3 = WHITE
MouseKeyLabel.TextSize = 12
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
SettingsFrame.Size = UDim2.new(0, 325, 0, 235)
SettingsFrame.Position = UDim2.new(0, 50, 0.5, -117)
SettingsFrame.BackgroundColor3 = PANEL
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 20
SettingsFrame.Active = true
SettingsFrame.Parent = ScreenGui

AddCorner(SettingsFrame, 18)
AddStroke(SettingsFrame, YELLOW, 2, 0.2)

local SettingsDragBar = Instance.new("Frame")
SettingsDragBar.Size = UDim2.new(1, -60, 0, 55)
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

AddCorner(SettingsClose, 11)

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

AddCorner(ChatGPTLink, 10)

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

AddCorner(CopyLinkButton, 10)

local MoreSettings = Instance.new("TextLabel")
MoreSettings.Size = UDim2.new(1, -36, 0, 25)
MoreSettings.Position = UDim2.new(0, 18, 0, 187)
MoreSettings.BackgroundTransparency = 1
MoreSettings.Text = "🍌 Banana Script • Modern UI Edition"
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

	BananaTab:SetAttribute("Active", false)
	BLBuyTab:SetAttribute("Active", false)
	ChatTab:SetAttribute("Active", false)

	for _, tabButton in ipairs({
		BananaTab,
		BLBuyTab,
		ChatTab
	}) do
		Tween(tabButton, {
			BackgroundColor3 = CARD,
			TextColor3 = WHITE
		}, 0.12):Play()
	end

	if tab == "BANANA" then
		BananaContent.Visible = true
		BananaTab:SetAttribute("Active", true)

		Tween(BananaTab, {
			BackgroundColor3 = CARD_ACTIVE,
			TextColor3 = YELLOW_LIGHT
		}, 0.12):Play()

	elseif tab == "BLBUY" then
		BLContent.Visible = true
		BLBuyTab:SetAttribute("Active", true)

		Tween(BLBuyTab, {
			BackgroundColor3 = CARD_ACTIVE,
			TextColor3 = YELLOW_LIGHT
		}, 0.12):Play()

	elseif tab == "CHAT" then
		ChatContent.Visible = true
		ChatTab:SetAttribute("Active", true)

		Tween(ChatTab, {
			BackgroundColor3 = CARD_ACTIVE,
			TextColor3 = YELLOW_LIGHT
		}, 0.12):Play()
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
-- UPDATE BUTTONS
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

	DanceKeyButton.Text =
		DanceHotkey.Name

	MouseKeyButton.Text =
		MouseUnlockKey.Name

	ResetVelocityButton.Text =
		ResetVelocityOnTeleport
		and "💨   RESET VELOCITY: ON"
		or "💨   RESET VELOCITY: OFF"

	if SelectedPlayer then
		SelectedInfo.Text =
			"Selected: " .. tostring(SelectedPlayer)
	else
		SelectedInfo.Text =
			"Select another player to teleport"
	end

	for i = 1, 5 do
		if TeleportPoints[i] then
			PointRows[i].State.Text = "SAVED"
			PointRows[i].State.TextColor3 = GREEN
			PointRows[i].Save.Text = "SAVE"
		else
			PointRows[i].State.Text = "EMPTY"
			PointRows[i].State.TextColor3 = DARK_GRAY
			PointRows[i].Save.Text = "SAVE"
		end
	end
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
		UpdateButtons()
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

	UpdateButtons()
end)

RefreshPlayersButton.MouseButton1Click:Connect(function()
	RefreshPlayerList()
	UpdateButtons()
end)

--========================================================
-- TP TO PLAYER
--========================================================

TPToPlayerButton.MouseButton1Click:Connect(function()

	if not Character
		or not RootPart
		or not SelectedPlayer
		or AFKEnabled then
		return
	end

	local Target = Players:FindFirstChild(SelectedPlayer)

	if not Target or not Target.Character then
		return
	end

	local TargetCharacter = Target.Character
	local TargetRoot =
		TargetCharacter:FindFirstChild("HumanoidRootPart")

	if not TargetRoot then
		return
	end

	local TargetCFrame =
		TargetRoot.CFrame
		+ Vector3.new(0, TeleportOffset, 0)

	if ResetVelocityOnTeleport then
		RootPart.AssemblyLinearVelocity = Vector3.zero
		RootPart.AssemblyAngularVelocity = Vector3.zero
	end

	pcall(function()
		Character:PivotTo(TargetCFrame)
	end)

	if RootPart and RootPart.Parent then

		RootPart.CFrame = TargetCFrame

		if ResetVelocityOnTeleport then
			RootPart.AssemblyLinearVelocity = Vector3.zero
			RootPart.AssemblyAngularVelocity = Vector3.zero
		end

	end
end)

--========================================================
-- TELEPORT POINTS
--========================================================

local function SaveTeleportPoint(index)

	if not Character
		or not RootPart
		or AFKEnabled then
		return false
	end

	TeleportPoints[index] = RootPart.CFrame

	return true
end

local function TeleportToPoint(index)

	if not Character
		or not RootPart
		or not TeleportPoints[index]
		or AFKEnabled then
		return
	end

	local PointCFrame = TeleportPoints[index]

	if ResetVelocityOnTeleport then
		RootPart.AssemblyLinearVelocity = Vector3.zero
		RootPart.AssemblyAngularVelocity = Vector3.zero
	end

	pcall(function()
		Character:PivotTo(PointCFrame)
	end)

	if RootPart and RootPart.Parent then
		RootPart.CFrame = PointCFrame

		if ResetVelocityOnTeleport then
			RootPart.AssemblyLinearVelocity = Vector3.zero
			RootPart.AssemblyAngularVelocity = Vector3.zero
		end
	end
end

for i = 1, 5 do

	local Index = i

	PointRows[i].Save.MouseButton1Click:Connect(function()

		if SaveTeleportPoint(Index) then

			PointRows[Index].State.Text = "SAVED"
			PointRows[Index].State.TextColor3 = GREEN
			PointRows[Index].Save.Text = "✅ SAVED"

			task.delay(1.2, function()

				if PointRows[Index]
					and PointRows[Index].Save
					and PointRows[Index].Save.Parent then

					PointRows[Index].Save.Text = "SAVE"
				end

			end)
		end
	end)

	PointRows[i].TP.MouseButton1Click:Connect(function()
		TeleportToPoint(Index)
	end)

	PointRows[i].Save.MouseEnter:Connect(function()
		Tween(PointRows[Index].Save, {
			BackgroundColor3 = CARD_HOVER
		}, 0.1):Play()
	end)

	PointRows[i].Save.MouseLeave:Connect(function()
		Tween(PointRows[Index].Save, {
			BackgroundColor3 = CARD
		}, 0.1):Play()
	end)

	PointRows[i].TP.MouseEnter:Connect(function()
		Tween(PointRows[Index].TP, {
			BackgroundColor3 = CARD_HOVER
		}, 0.1):Play()
	end)

	PointRows[i].TP.MouseLeave:Connect(function()
		Tween(PointRows[Index].TP, {
			BackgroundColor3 = CARD
		}, 0.1):Play()
	end)
end

--========================================================
-- PLAYER REMOVING
--========================================================

Players.PlayerRemoving:Connect(function(p)

	if p.Name == SelectedPlayer then
		SelectedPlayer = nil

		task.defer(function()
			RefreshPlayerList()
			UpdateButtons()
		end)
	end
end)

RefreshPlayerList()

--========================================================
-- TELEPORT FORWARD
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

	TeleportEnabled =
		not TeleportEnabled

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
-- TP SETTINGS
--========================================================

TPOffsetBox.FocusLost:Connect(function()

	local N = tonumber(TPOffsetBox.Text)

	if N then
		TeleportOffset =
			math.clamp(N, 0, 50)
	end

	TPOffsetBox.Text =
		tostring(TeleportOffset)

end)

ResetVelocityButton.MouseButton1Click:Connect(function()

	ResetVelocityOnTeleport =
		not ResetVelocityOnTeleport

	UpdateButtons()

end)

--========================================================
-- SPEED
--========================================================

SpeedBox.FocusLost:Connect(function()

	local N = tonumber(SpeedBox.Text)

	if N then
		WalkSpeed =
			math.clamp(N, 1, 400)
	end

	SpeedBox.Text =
		tostring(WalkSpeed)

	if SpeedEnabled and Humanoid then
		Humanoid.WalkSpeed =
			WalkSpeed
	end
end)

SpeedButton.MouseButton1Click:Connect(function()

	SpeedEnabled =
		not SpeedEnabled

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

	WallhackEnabled =
		not WallhackEnabled

	UpdateButtons()
end)

--========================================================
-- FLY
--========================================================

FlyBox.FocusLost:Connect(function()

	local N = tonumber(FlyBox.Text)

	if N then
		FlySpeed =
			math.clamp(N, 1, 400)
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
					Direction.Unit
					* FlySpeed
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

	FlyEnabled =
		not FlyEnabled

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

	AFKEnabled =
		not AFKEnabled

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
			for _, Part in ipairs(
				Character:GetDescendants()
			) do

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

	for _, part in ipairs(
		Character:GetDescendants()
	) do

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
			math.max(
				1,
				math.floor(N)
			)
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
					table.insert(
						Prompts,
						obj
					)
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

	for _, name in ipairs(
		PreferredNames
	) do

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

	if Humanoid.RigType ~=
		Enum.HumanoidRigType.R6 then
		return
	end

	local Animator =
		Humanoid:FindFirstChildOfClass(
			"Animator"
		)

	if not Animator then

		Animator =
			Instance.new("Animator")

		Animator.Parent =
			Humanoid
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

	if Humanoid.RigType ~=
		Enum.HumanoidRigType.R6 then

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
--========================================================

local function ForceMouseUnlock()

	pcall(function()
		UIS.MouseBehavior =
			Enum.MouseBehavior.Default
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
	Tween(CopyLinkButton, {
		BackgroundColor3 = CARD_HOVER
	}, 0.12):Play()
end)

CopyLinkButton.MouseLeave:Connect(function()
	Tween(CopyLinkButton, {
		BackgroundColor3 = CARD
	}, 0.12):Play()
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

		CopyLinkButton.Text =
			"✅  COPIED!"

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
MainDragArea.Size = UDim2.new(1, -150, 0, 95)
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

	if GameProcessed then
		return
	end

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

	if FlyEnabled
		and not AFKEnabled then

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

	if AFKEnabled
		and RootPart then

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

SetTPTab("FORWARD")
SetTab("BANANA")

RefreshPlayerList()
UpdateButtons()
UpdateESP()
UpdateMoney()

print(
	"🍌 Banana Script + Modern TP Categories + BL BUY + CHAT loaded successfully!"
)
