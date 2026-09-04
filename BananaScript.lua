```lua
--// 🍌 BANANA SCRIPT 2.0
--// UI redesign by ChatGPT & TheYaruck

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

--==================================================
-- SETTINGS
--==================================================

local ESPEnabled = true

local TeleportEnabled = false
local TeleportDistance = 10

local SpeedEnabled = false
local WalkSpeed = 32

local ExtraJumpsEnabled = false
local ExtraJumps = 5
local JumpsDone = 0

local WallhackEnabled = false

local FlyEnabled = false
local FlySpeed = 50
local FlyConnection
local FlyVelocity
local FlyAttachment
local FlyOrientation

local AFKEnabled = false

local Character
local Humanoid
local RootPart

--==================================================
-- CHARACTER
--==================================================

local function SetupCharacter(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	RootPart = char:WaitForChild("HumanoidRootPart")

	JumpsDone = 0

	if SpeedEnabled then
		Humanoid.WalkSpeed = WalkSpeed
	else
		Humanoid.WalkSpeed = 16
	end

	if AFKEnabled then
		RootPart.Anchored = true
	end
end

if Player.Character then
	SetupCharacter(Player.Character)
end

Player.CharacterAdded:Connect(function(char)
	task.wait(0.2)
	SetupCharacter(char)
end)

--==================================================
-- GUI
--==================================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BananaScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

--==================================================
-- COLORS
--==================================================

local COLORS = {
	Background = Color3.fromRGB(12, 13, 18),
	Panel = Color3.fromRGB(19, 20, 27),
	Panel2 = Color3.fromRGB(24, 25, 33),
	Card = Color3.fromRGB(27, 28, 38),
	CardHover = Color3.fromRGB(34, 35, 47),

	Yellow = Color3.fromRGB(255, 204, 55),
	YellowLight = Color3.fromRGB(255, 222, 90),

	White = Color3.fromRGB(240, 241, 245),
	Gray = Color3.fromRGB(150, 153, 165),
	DarkGray = Color3.fromRGB(85, 88, 100),

	Green = Color3.fromRGB(75, 190, 105),
	Red = Color3.fromRGB(225, 75, 85),
	Blue = Color3.fromRGB(80, 130, 230),
	Purple = Color3.fromRGB(150, 90, 220),
	Cyan = Color3.fromRGB(55, 180, 210),
	Orange = Color3.fromRGB(230, 150, 55),
}

--==================================================
-- UTILITY
--==================================================

local function Corner(object, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = object
	return c
end

local function Stroke(object, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = object
	return s
end

local function Tween(object, info, properties)
	return TweenService:Create(object, info, properties)
end

local FastTween = TweenInfo.new(
	0.15,
	Enum.EasingStyle.Quad,
	Enum.EasingDirection.Out
)

local SmoothTween = TweenInfo.new(
	0.25,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

--==================================================
-- OPEN BUTTON
--==================================================

local OpenButton = Instance.new("TextButton")
OpenButton.Name = "OpenButton"
OpenButton.Size = UDim2.new(0, 64, 0, 64)
OpenButton.Position = UDim2.new(0, 24, 0.5, -32)
OpenButton.BackgroundColor3 = COLORS.Panel
OpenButton.Text = "🍌"
OpenButton.TextSize = 31
OpenButton.Font = Enum.Font.GothamBold
OpenButton.AutoButtonColor = false
OpenButton.Visible = false
OpenButton.Parent = ScreenGui

Corner(OpenButton, 20)
Stroke(OpenButton, COLORS.Yellow, 2, 0.15)

OpenButton.MouseEnter:Connect(function()
	Tween(OpenButton, FastTween, {
		BackgroundColor3 = COLORS.CardHover,
		Size = UDim2.new(0, 70, 0, 70)
	}):Play()
end)

OpenButton.MouseLeave:Connect(function()
	Tween(OpenButton, FastTween, {
		BackgroundColor3 = COLORS.Panel,
		Size = UDim2.new(0, 64, 0, 64)
	}):Play()
end)

--==================================================
-- MAIN FRAME
--==================================================

local Frame = Instance.new("Frame")
Frame.Name = "MainFrame"
Frame.Size = UDim2.new(0, 390, 0, 650)
Frame.Position = UDim2.new(0, 28, 0.5, -325)
Frame.BackgroundColor3 = COLORS.Background
Frame.BorderSizePixel = 0
Frame.ClipsDescendants = true
Frame.Parent = ScreenGui

Corner(Frame, 24)
Stroke(Frame, COLORS.Yellow, 2, 0.18)

--==================================================
-- HEADER
--==================================================

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 105)
Header.BackgroundColor3 = COLORS.Panel
Header.BorderSizePixel = 0
Header.Parent = Frame

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Rotation = 90
HeaderGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(31, 32, 42)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(19, 20, 27))
})
HeaderGradient.Parent = Header

local HeaderBottom = Instance.new("Frame")
HeaderBottom.Size = UDim2.new(1, -36, 0, 1)
HeaderBottom.Position = UDim2.new(0, 18, 1, -1)
HeaderBottom.BackgroundColor3 = COLORS.Yellow
HeaderBottom.BackgroundTransparency = 0.75
HeaderBottom.BorderSizePixel = 0
HeaderBottom.Parent = Header

--==================================================
-- BANANA ICON
--==================================================

local BananaIcon = Instance.new("TextLabel")
BananaIcon.Size = UDim2.new(0, 58, 0, 58)
BananaIcon.Position = UDim2.new(0, 18, 0, 18)
BananaIcon.BackgroundColor3 = COLORS.Yellow
BananaIcon.Text = "🍌"
BananaIcon.TextSize = 31
BananaIcon.Font = Enum.Font.GothamBold
BananaIcon.Parent = Header

Corner(BananaIcon, 17)

--==================================================
-- TITLE
--==================================================

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 0, 28)
Title.Position = UDim2.new(0, 88, 0, 18)
Title.BackgroundTransparency = 1
Title.Text = "BANANA SCRIPT"
Title.TextColor3 = COLORS.YellowLight
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBlack
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -180, 0, 18)
Subtitle.Position = UDim2.new(0, 89, 0, 47)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "ChatGPT  •  TheYaruck"
Subtitle.TextColor3 = COLORS.Gray
Subtitle.TextSize = 11
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Font = Enum.Font.GothamMedium
Subtitle.Parent = Header

--==================================================
-- STATUS
--==================================================

local Status = Instance.new("Frame")
Status.Size = UDim2.new(0, 94, 0, 27)
Status.Position = UDim2.new(0, 88, 0, 70)
Status.BackgroundColor3 = Color3.fromRGB(35, 55, 40)
Status.BorderSizePixel = 0
Status.Parent = Header

Corner(Status, 9)

local StatusDot = Instance.new("Frame")
StatusDot.Size = UDim2.new(0, 7, 0, 7)
StatusDot.Position = UDim2.new(0, 10, 0.5, -3)
StatusDot.BackgroundColor3 = COLORS.Green
StatusDot.BorderSizePixel = 0
StatusDot.Parent = Status

Corner(StatusDot, 10)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -25, 1, 0)
StatusText.Position = UDim2.new(0, 23, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "SYSTEM ON"
StatusText.TextColor3 = Color3.fromRGB(150, 230, 165)
StatusText.TextSize = 9
StatusText.Font = Enum.Font.GothamBold
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = Status

--==================================================
-- HEADER BUTTONS
--==================================================

local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 38, 0, 38)
SettingsButton.Position = UDim2.new(1, -95, 0, 31)
SettingsButton.BackgroundColor3 = COLORS.Card
SettingsButton.Text = "⚙"
SettingsButton.TextColor3 = COLORS.White
SettingsButton.TextSize = 18
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.AutoButtonColor = false
SettingsButton.Parent = Header

Corner(SettingsButton, 12)

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 38, 0, 38)
CloseButton.Position = UDim2.new(1, -49, 0, 31)
CloseButton.BackgroundColor3 = COLORS.Card
CloseButton.Text = "×"
CloseButton.TextColor3 = COLORS.White
CloseButton.TextSize = 24
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

Corner(CloseButton, 12)

local function HeaderHover(button)
	button.MouseEnter:Connect(function()
		Tween(button, FastTween, {
			BackgroundColor3 = COLORS.CardHover
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		Tween(button, FastTween, {
			BackgroundColor3 = COLORS.Card
		}):Play()
	end)
end

HeaderHover(SettingsButton)
HeaderHover(CloseButton)

--==================================================
-- SCROLLING CONTENT
--==================================================

local Content = Instance.new("ScrollingFrame")
Content.Name = "Content"
Content.Size = UDim2.new(1, 0, 1, -105)
Content.Position = UDim2.new(0, 0, 0, 105)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = COLORS.Yellow
Content.ScrollBarImageTransparency = 0.25
Content.CanvasSize = UDim2.new(0, 0, 0, 1080)
Content.Parent = Frame

--==================================================
-- SECTION TITLE
--==================================================

local function Section(text, y)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -40, 0, 25)
	Label.Position = UDim2.new(0, 20, 0, y)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = COLORS.Gray
	Label.TextSize = 10
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Enum.Font.GothamBlack
	Label.Parent = Content

	return Label
end

--==================================================
-- FEATURE CARD
--==================================================

local function FeatureCard(icon, title, description, y)
	local Card = Instance.new("Frame")
	Card.Size = UDim2.new(1, -36, 0, 64)
	Card.Position = UDim2.new(0, 18, 0, y)
	Card.BackgroundColor3 = COLORS.Card
	Card.BorderSizePixel = 0
	Card.Parent = Content

	Corner(Card, 15)
	Stroke(Card, Color3.fromRGB(50, 52, 65), 1, 0.2)

	local Icon = Instance.new("TextLabel")
	Icon.Size = UDim2.new(0, 42, 0, 42)
	Icon.Position = UDim2.new(0, 11, 0.5, -21)
	Icon.BackgroundColor3 = COLORS.Panel2
	Icon.Text = icon
	Icon.TextSize = 20
	Icon.Font = Enum.Font.GothamBold
	Icon.Parent = Card

	Corner(Icon, 12)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -145, 0, 20)
	TitleLabel.Position = UDim2.new(0, 64, 0, 12)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = title
	TitleLabel.TextColor3 = COLORS.White
	TitleLabel.TextSize = 13
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Parent = Card

	local Desc = Instance.new("TextLabel")
	Desc.Size = UDim2.new(1, -145, 0, 17)
	Desc.Position = UDim2.new(0, 64, 0, 33)
	Desc.BackgroundTransparency = 1
	Desc.Text = description
	Desc.TextColor3 = COLORS.Gray
	Desc.TextSize = 9
	Desc.TextXAlignment = Enum.TextXAlignment.Left
	Desc.Font = Enum.Font.Gotham
	Desc.Parent = Card

	return Card
end

--==================================================
-- TOGGLE
--==================================================

local function Toggle(parent, y, active, callback)
	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Size = UDim2.new(0, 52, 0, 28)
	ToggleButton.Position = UDim2.new(1, -64, 0.5, -14)
	ToggleButton.BackgroundColor3 = active and COLORS.Green or COLORS.DarkGray
	ToggleButton.Text = ""
	ToggleButton.AutoButtonColor = false
	ToggleButton.Parent = parent

	Corner(ToggleButton, 20)

	local Circle = Instance.new("Frame")
	Circle.Size = UDim2.new(0, 22, 0, 22)
	Circle.Position = active
		and UDim2.new(1, -25, 0.5, -11)
		or UDim2.new(0, 3, 0.5, -11)
	Circle.BackgroundColor3 = Color3.fromRGB(245, 245, 245)
	Circle.BorderSizePixel = 0
	Circle.Parent = ToggleButton

	Corner(Circle, 20)

	local state = active

	ToggleButton.MouseEnter:Connect(function()
		Tween(ToggleButton, FastTween, {
			BackgroundTransparency = 0.1
		}):Play()
	end)

	ToggleButton.MouseLeave:Connect(function()
		Tween(ToggleButton, FastTween, {
			BackgroundTransparency = 0
		}):Play()
	end)

	ToggleButton.MouseButton1Click:Connect(function()
		state = not state

		Tween(ToggleButton, FastTween, {
			BackgroundColor3 = state and COLORS.Green or COLORS.DarkGray
		}):Play()

		Tween(Circle, FastTween, {
			Position = state
				and UDim2.new(1, -25, 0.5, -11)
				or UDim2.new(0, 3, 0.5, -11)
		}):Play()

		callback(state)
	end)

	return ToggleButton
end

--==================================================
-- INPUT BOX
--==================================================

local function InputBox(parent, value, y, callback)
	local Box = Instance.new("TextBox")
	Box.Size = UDim2.new(0, 92, 0, 34)
	Box.Position = UDim2.new(1, -104, 0.5, -17)
	Box.BackgroundColor3 = COLORS.Panel2
	Box.TextColor3 = COLORS.White
	Box.Text = tostring(value)
	Box.TextSize = 12
	Box.Font = Enum.Font.GothamBold
	Box.ClearTextOnFocus = false
	Box.TextXAlignment = Enum.TextXAlignment.Center
	Box.Parent = parent

	Corner(Box, 10)
	Stroke(Box, Color3.fromRGB(60, 62, 75), 1, 0.15)

	Box.FocusLost:Connect(function()
		local number = tonumber(Box.Text)

		if number then
			callback(number)
		end

		Box.Text = tostring(value)
	end)

	return Box
end

--==================================================
-- CARDS
--==================================================

Section("VISUALS", 18)

local ESPCard = FeatureCard(
	"👁",
	"ESP",
	"See other players through walls",
	47
)

local ESPToggle = Toggle(
	ESPCard,
	0,
	ESPEnabled,
	function(state)
		ESPEnabled = state

		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= Player and player.Character then
				local highlight = player.Character:FindFirstChild("BananaESP")

				if highlight then
					highlight.Enabled = ESPEnabled
				end
			end
		end
	end
)

Section("MOVEMENT", 128)

local TeleportCard = FeatureCard(
	"🌀",
	"Teleport",
	"Toggle teleport mode",
	157
)

Toggle(
	TeleportCard,
	0,
	TeleportEnabled,
	function(state)
		TeleportEnabled = state
	end
)

local TPDCard = FeatureCard(
	"🚀",
	"Teleport Distance",
	"Distance for forward teleport",
	229
)

local DistanceBox = InputBox(
	TPDCard,
	TeleportDistance,
	0,
	function(number)
		TeleportDistance = math.clamp(number, 1, 1000)
	end
)

local TPCard = Instance.new("TextButton")
TPCard.Size = UDim2.new(1, -36, 0, 48)
TPCard.Position = UDim2.new(0, 18, 0, 301)
TPCard.BackgroundColor3 = Color3.fromRGB(45, 50, 75)
TPCard.Text = "🚀   TELEPORT FORWARD"
TPCard.TextColor3 = COLORS.White
TPCard.TextSize = 12
TPCard.Font = Enum.Font.GothamBold
TPCard.AutoButtonColor = false
TPCard.Parent = Content

Corner(TPCard, 13)

TPCard.MouseEnter:Connect(function()
	Tween(TPCard, FastTween, {
		BackgroundColor3 = Color3.fromRGB(58, 65, 100)
	}):Play()
end)

TPCard.MouseLeave:Connect(function()
	Tween(TPCard, FastTween, {
		BackgroundColor3 = Color3.fromRGB(45, 50, 75)
	}):Play()
end)

TPCard.MouseButton1Click:Connect(function()
	if TeleportEnabled and RootPart and not AFKEnabled then
		RootPart.CFrame += RootPart.CFrame.LookVector * TeleportDistance
	end
end)

local SpeedCard = FeatureCard(
	"⚡",
	"Walk Speed",
	"Change your movement speed",
	365
)

Toggle(
	SpeedCard,
	0,
	SpeedEnabled,
	function(state)
		SpeedEnabled = state

		if Humanoid then
			Humanoid.WalkSpeed = state and WalkSpeed or 16
		end
	end
)

local SpeedValueCard = FeatureCard(
	"⚡",
	"Speed Value",
	"Maximum 200",
	437
)

local SpeedBox = InputBox(
	SpeedValueCard,
	WalkSpeed,
	0,
	function(number)
		WalkSpeed = math.clamp(number, 1, 200)

		if SpeedEnabled and Humanoid then
			Humanoid.WalkSpeed = WalkSpeed
		end

		SpeedBox.Text = tostring(WalkSpeed)
	end
)

Section("ABILITIES", 507)

local JumpCard = FeatureCard(
	"🦘",
	"Extra Jumps",
	"Jump multiple times in the air",
	536
)

Toggle(
	JumpCard,
	0,
	ExtraJumpsEnabled,
	function(state)
		ExtraJumpsEnabled = state
		JumpsDone = 0
	end
)

local JumpValueCard = FeatureCard(
	"🔢",
	"Extra Jump Amount",
	"Maximum 100",
	608
)

local JumpsBox = InputBox(
	JumpValueCard,
	ExtraJumps,
	0,
	function(number)
		ExtraJumps = math.clamp(math.floor(number), 0, 100)
		JumpsBox.Text = tostring(ExtraJumps)
	end
)

local WallCard = FeatureCard(
	"🧱",
	"Wallhack",
	"Walk through physical walls",
	680
)

Toggle(
	WallCard,
	0,
	WallhackEnabled,
	function(state)
		WallhackEnabled = state
	end
)

local FlyCard = FeatureCard(
	"✈️",
	"Fly",
	"Fly freely around the map",
	752
)

Toggle(
	FlyCard,
	0,
	FlyEnabled,
	function(state)
		FlyEnabled = state

		if FlyEnabled and not AFKEnabled then
			StartFly()
		else
			FlyEnabled = false
			StopFly()
		end
	end
)

local FlySpeedCard = FeatureCard(
	"💨",
	"Fly Speed",
	"Maximum 300",
	824
)

local FlyBox = InputBox(
	FlySpeedCard,
	FlySpeed,
	0,
	function(number)
		FlySpeed = math.clamp(number, 1, 300)
		FlyBox.Text = tostring(FlySpeed)
	end
)

Section("SAFETY", 896)

local AFKCard = FeatureCard(
	"🛡️",
	"Full AFK",
	"Freeze and protect your character",
	925
)

Toggle(
	AFKCard,
	0,
	AFKEnabled,
	function(state)
		AFKEnabled = state

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
				for _, part in ipairs(Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
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
				Humanoid.WalkSpeed = SpeedEnabled and WalkSpeed or 16
			end
		end
	end
)

--==================================================
-- ESP
--==================================================

local function CreateESP(char)
	if char == Player.Character then
		return
	end

	if char:FindFirstChild("BananaESP") then
		return
	end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "BananaESP"
	Highlight.FillColor = COLORS.Yellow
	Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
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

			local Highlight = OtherPlayer.Character:FindFirstChild("BananaESP")

			if Highlight then
				Highlight.Enabled = ESPEnabled
			end
		end
	end
end

for _, OtherPlayer in ipairs(Players:GetPlayers()) do
	if OtherPlayer ~= Player then
		OtherPlayer.CharacterAdded:Connect(function(char)
			task.wait(0.4)
			CreateESP(char)
		end)
	end
end

Players.PlayerAdded:Connect(function(OtherPlayer)
	OtherPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.4)
		CreateESP(char)
	end)
end)

--==================================================
-- EXTRA JUMPS
--==================================================

UIS.JumpRequest:Connect(function()
	if not ExtraJumpsEnabled or not Humanoid or not RootPart then
		return
	end

	if AFKEnabled or FlyEnabled then
		return
	end

	local State = Humanoid:GetState()

	local Grounded =
		State == Enum.HumanoidStateType.Running
		or State == Enum.HumanoidStateType.Landed
		or State == Enum.HumanoidStateType.RunningNoPhysics

	if Grounded then
		JumpsDone = 0
		return
	end

	if JumpsDone < ExtraJumps then
		JumpsDone += 1

		Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

		local V = RootPart.AssemblyLinearVelocity

		RootPart.AssemblyLinearVelocity = Vector3.new(
			V.X,
			Humanoid.JumpPower,
			V.Z
		)
	end
end)

--==================================================
-- FLY
--==================================================

function StopFly()
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

function StartFly()
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
	FlyOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	FlyOrientation.Attachment0 = FlyAttachment
	FlyOrientation.MaxTorque = math.huge
	FlyOrientation.Responsiveness = 15
	FlyOrientation.RigidityEnabled = false
	FlyOrientation.Parent = RootPart

	FlyConnection = RunService.RenderStepped:Connect(function()
		if not FlyEnabled or not RootPart or not FlyVelocity then
			return
		end

		local Camera = workspace.CurrentCamera

		local Forward = Camera.CFrame.LookVector
		local Right = Camera.CFrame.RightVector

		local Direction = Vector3.zero

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
			Direction = Direction.Unit * FlySpeed
		end

		FlyVelocity.VectorVelocity = Direction

		local Look = Camera.CFrame.LookVector

		FlyOrientation.CFrame = CFrame.lookAt(
			Vector3.zero,
			Look
		)

		if UIS:IsKeyDown(Enum.KeyCode.W) then
			FlyOrientation.CFrame =
				CFrame.lookAt(Vector3.zero, Look)
				* CFrame.Angles(math.rad(-12), 0, 0)
		elseif UIS:IsKeyDown(Enum.KeyCode.S) then
			FlyOrientation.CFrame =
				CFrame.lookAt(Vector3.zero, Look)
				* CFrame.Angles(math.rad(12), 0, 0)
		end
	end)
end

--==================================================
-- SETTINGS WINDOW
--==================================================

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 330, 0, 245)
SettingsFrame.Position = UDim2.new(0, 58, 0.5, -122)
SettingsFrame.BackgroundColor3 = COLORS.Panel
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 50
SettingsFrame.Parent = ScreenGui

Corner(SettingsFrame, 22)
Stroke(SettingsFrame, COLORS.Yellow, 2, 0.15)

local SettingsHeader = Instance.new("Frame")
SettingsHeader.Size = UDim2.new(1, 0, 0, 65)
SettingsHeader.BackgroundColor3 = COLORS.Panel2
SettingsHeader.BorderSizePixel = 0
SettingsHeader.ZIndex = 51
SettingsHeader.Parent = SettingsFrame

Corner(SettingsHeader, 22)

local SettingsFix = Instance.new("Frame")
SettingsFix.Size = UDim2.new(1, 0, 0, 20)
SettingsFix.Position = UDim2.new(0, 0, 1, -20)
SettingsFix.BackgroundColor3 = COLORS.Panel2
SettingsFix.BorderSizePixel = 0
SettingsFix.ZIndex = 51
SettingsFix.Parent = SettingsHeader

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -70, 0, 40)
SettingsTitle.Position = UDim2.new(0, 20, 0, 12)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "⚙   SETTINGS"
SettingsTitle.TextColor3 = COLORS.YellowLight
SettingsTitle.TextSize = 18
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.Font = Enum.Font.GothamBlack
SettingsTitle.ZIndex = 52
SettingsTitle.Parent = SettingsHeader

local SettingsClose = Instance.new("TextButton")
SettingsClose.Size = UDim2.new(0, 36, 0, 36)
SettingsClose.Position = UDim2.new(1, -50, 0, 14)
SettingsClose.BackgroundColor3 = COLORS.Card
SettingsClose.Text = "×"
SettingsClose.TextColor3 = COLORS.White
SettingsClose.TextSize = 22
SettingsClose.Font = Enum.Font.GothamBold
SettingsClose.AutoButtonColor = false
SettingsClose.ZIndex = 52
SettingsClose.Parent = SettingsHeader

Corner(SettingsClose, 11)

local ChatGPTLabel = Instance.new("TextLabel")
ChatGPTLabel.Size = UDim2.new(1, -40, 0, 20)
ChatGPTLabel.Position = UDim2.new(0, 20, 0, 83)
ChatGPTLabel.BackgroundTransparency = 1
ChatGPTLabel.Text = "CREATED WITH"
ChatGPTLabel.TextColor3 = COLORS.Gray
ChatGPTLabel.TextSize = 9
ChatGPTLabel.TextXAlignment = Enum.TextXAlignment.Left
ChatGPTLabel.Font = Enum.Font.GothamBlack
ChatGPTLabel.ZIndex = 51
ChatGPTLabel.Parent = SettingsFrame

local ChatGPTBox = Instance.new("TextLabel")
ChatGPTBox.Size = UDim2.new(1, -40, 0, 45)
ChatGPTBox.Position = UDim2.new(0, 20, 0, 108)
ChatGPTBox.BackgroundColor3 = COLORS.Card
ChatGPTBox.Text = "🤖   ChatGPT"
ChatGPTBox.TextColor3 = COLORS.White
ChatGPTBox.TextSize = 13
ChatGPTBox.Font = Enum.Font.GothamBold
ChatGPTBox.ZIndex = 51
ChatGPTBox.Parent = SettingsFrame

Corner(ChatGPTBox, 12)

local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, -40, 0, 25)
Version.Position = UDim2.new(0, 20, 0, 168)
Version.BackgroundTransparency = 1
Version.Text = "Banana Script 2.0   •   UI Edition"
Version.TextColor3 = COLORS.Gray
Version.TextSize = 10
Version.Font = Enum.Font.Gotham
Version.ZIndex = 51
Version.Parent = SettingsFrame

--==================================================
-- SETTINGS EVENTS
--==================================================

SettingsButton.MouseButton1Click:Connect(function()
	SettingsFrame.Visible = true

	SettingsFrame.Size = UDim2.new(0, 330, 0, 225)

	Tween(SettingsFrame, SmoothTween, {
		Size = UDim2.new(0, 330, 0, 245)
	}):Play()
end)

SettingsClose.MouseButton1Click:Connect(function()
	SettingsFrame.Visible = false
end)

--==================================================
-- CLOSE / OPEN
--==================================================

CloseButton.MouseButton1Click:Connect(function()
	Frame.Visible = false
	SettingsFrame.Visible = false
	OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
	Frame.Visible = true
	OpenButton.Visible = false
end)

--==================================================
-- DRAG MAIN WINDOW
--==================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = true
		DragStart = Input.Position
		StartPosition = Frame.Position
	end
end)

UIS.InputChanged:Connect(function(Input)
	if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
		local Delta = Input.Position - DragStart

		Frame.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		Dragging = false
	end
end)

--==================================================
-- DRAG OPEN BUTTON
--==================================================

local OpenDragging = false
local OpenDragStart
local OpenStartPosition

OpenButton.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		OpenDragging = true
		OpenDragStart = Input.Position
		OpenStartPosition = OpenButton.Position
	end
end)

UIS.InputChanged:Connect(function(Input)
	if OpenDragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
		local Delta = Input.Position - OpenDragStart

		OpenButton.Position = UDim2.new(
			OpenStartPosition.X.Scale,
			OpenStartPosition.X.Offset + Delta.X,
			OpenStartPosition.Y.Scale,
			OpenStartPosition.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
		OpenDragging = false
	end
end)

--==================================================
-- HEARTBEAT
--==================================================

RunService.Heartbeat:Connect(function()
	if SpeedEnabled and Humanoid and not AFKEnabled then
		if Humanoid.WalkSpeed ~= WalkSpeed then
			Humanoid.WalkSpeed = WalkSpeed
		end
	end

	if WallhackEnabled and Character and not AFKEnabled then
		for _, Part in ipairs(Character:GetDescendants()) do
			if Part:IsA("BasePart") then
				Part.CanCollide = false
			end
		end
	end

	if AFKEnabled and RootPart then
		RootPart.Anchored = true
		RootPart.AssemblyLinearVelocity = Vector3.zero
		RootPart.AssemblyAngularVelocity = Vector3.zero
	end
end)

--==================================================
-- RESPAWN
--==================================================

Player.CharacterAdded:Connect(function()
	task.wait(0.5)

	UpdateESP()

	if FlyEnabled then
		StartFly()
	end
end)

--==================================================
-- START
--==================================================

UpdateESP()
```
