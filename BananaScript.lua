--========================================================
-- 🍌 BANANA SCRIPT
-- UI REDESIGN — MECHANICS PRESERVED
--========================================================

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

--========================================================
-- SETTINGS
--========================================================

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

--========================================================
-- CHARACTER
--========================================================

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
-- GUI
--========================================================

local PlayerGui = Player:WaitForChild("PlayerGui")

local OldGui = PlayerGui:FindFirstChild("BananaScript")
if OldGui then
	OldGui:Destroy()
end

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
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = YELLOW
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

--========================================================
-- MAIN PANEL
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

-- banana icon

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

-- title

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

-- status

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

-- settings

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

-- close

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
-- SCROLL CONTENT
--========================================================

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, -20, 1, -105)
Content.Position = UDim2.new(0, 10, 0, 98)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = YELLOW
Content.CanvasSize = UDim2.new(0, 0, 0, 1000)
Content.Parent = Frame

--========================================================
-- UI FUNCTIONS
--========================================================

local function Section(text, y)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -28, 0, 25)
	Label.Position = UDim2.new(0, 14, 0, y)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = YELLOW
	Label.TextSize = 11
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Enum.Font.GothamBold
	Label.Parent = Content

	return Label
end

local function Button(text, y)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(1, -28, 0, 46)
	B.Position = UDim2.new(0, 14, 0, y)
	B.BackgroundColor3 = CARD
	B.Text = text
	B.TextColor3 = WHITE
	B.TextSize = 13
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = Content

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

local function Box(value, y)
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
	B.Parent = Content

	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 10)
	C.Parent = B

	local S = Instance.new("UIStroke")
	S.Color = Color3.fromRGB(45, 48, 58)
	S.Thickness = 1
	S.Parent = B

	return B
end

--========================================================
-- FEATURES
--========================================================

Section("👁  VISUALS", 10)
local ESPButton = Button("👁   ESP: ON", 38)

Section("🌀  TELEPORT", 98)
local TeleportButton = Button("🌀   TELEPORT: OFF", 126)
local DistanceBox = Box(TeleportDistance, 178)
local TPButton = Button("🚀   TP FORWARD", 224)

Section("⚡  MOVEMENT", 286)
local SpeedButton = Button("⚡   SPEED: OFF", 314)
local SpeedBox = Box(WalkSpeed, 366)

Section("🦘  EXTRA JUMPS", 424)
local ExtraJumpsButton = Button("🦘   EXTRA JUMPS: OFF", 452)
local JumpsBox = Box(ExtraJumps, 504)

Section("🧱  WALLHACK", 562)
local WallhackButton = Button("🧱   WALLHACK: OFF", 590)

Section("✈️  FLY", 652)
local FlyButton = Button("✈️   FLY: OFF", 680)
local FlyBox = Box(FlySpeed, 732)

Section("🛡️  AFK", 790)
local AFKButton = Button("🛡️   FULL AFK: OFF", 818)

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
SettingsFrame.Parent = ScreenGui

local SettingsCorner2 = Instance.new("UICorner")
SettingsCorner2.CornerRadius = UDim.new(0, 18)
SettingsCorner2.Parent = SettingsFrame

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Color = YELLOW
SettingsStroke.Thickness = 2
SettingsStroke.Transparency = 0.2
SettingsStroke.Parent = SettingsFrame

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
ChatGPTLink.Size = UDim2.new(1, -36, 0, 42)
ChatGPTLink.Position = UDim2.new(0, 18, 0, 95)
ChatGPTLink.BackgroundColor3 = CARD
ChatGPTLink.Text = "https://chatgpt.com"
ChatGPTLink.TextColor3 = Color3.fromRGB(100, 180, 255)
ChatGPTLink.TextSize = 13
ChatGPTLink.Font = Enum.Font.GothamBold
ChatGPTLink.TextXAlignment = Enum.TextXAlignment.Center
ChatGPTLink.ZIndex = 21
ChatGPTLink.Parent = SettingsFrame

local ChatGPTLinkCorner = Instance.new("UICorner")
ChatGPTLinkCorner.CornerRadius = UDim.new(0, 10)
ChatGPTLinkCorner.Parent = ChatGPTLink

local MoreSettings = Instance.new("TextLabel")
MoreSettings.Size = UDim2.new(1, -36, 0, 30)
MoreSettings.Position = UDim2.new(0, 18, 0, 155)
MoreSettings.BackgroundTransparency = 1
MoreSettings.Text = "🍌 Banana Script • UI Edition"
MoreSettings.TextColor3 = DARK_GRAY
MoreSettings.TextSize = 12
MoreSettings.Font = Enum.Font.Gotham
MoreSettings.ZIndex = 21
MoreSettings.Parent = SettingsFrame

--========================================================
-- BUTTON STATE
--========================================================

local function SetButton(B, active, color)
	B:SetAttribute("Active", active)

	if active then
		B.BackgroundColor3 = color
	else
		B.BackgroundColor3 = CARD
	end
end

local function UpdateButtons()

	SetButton(
		ESPButton,
		ESPEnabled,
		Color3.fromRGB(48, 130, 75)
	)

	ESPButton.Text = ESPEnabled
		and "👁   ESP: ON"
		or "👁   ESP: OFF"

	SetButton(
		TeleportButton,
		TeleportEnabled,
		Color3.fromRGB(70, 82, 160)
	)

	TeleportButton.Text = TeleportEnabled
		and "🌀   TELEPORT: ON"
		or "🌀   TELEPORT: OFF"

	SetButton(
		SpeedButton,
		SpeedEnabled,
		Color3.fromRGB(170, 115, 35)
	)

	SpeedButton.Text = SpeedEnabled
		and "⚡   SPEED: ON"
		or "⚡   SPEED: OFF"

	SetButton(
		ExtraJumpsButton,
		ExtraJumpsEnabled,
		Color3.fromRGB(125, 75, 170)
	)

	ExtraJumpsButton.Text = ExtraJumpsEnabled
		and "🦘   EXTRA JUMPS: ON"
		or "🦘   EXTRA JUMPS: OFF"

	SetButton(
		WallhackButton,
		WallhackEnabled,
		Color3.fromRGB(40, 125, 155)
	)

	WallhackButton.Text = WallhackEnabled
		and "🧱   WALLHACK: ON"
		or "🧱   WALLHACK: OFF"

	SetButton(
		FlyButton,
		FlyEnabled,
		Color3.fromRGB(55, 125, 185)
	)

	FlyButton.Text = FlyEnabled
		and "✈️   FLY: ON"
		or "✈️   FLY: OFF"

	SetButton(
		AFKButton,
		AFKEnabled,
		Color3.fromRGB(85, 95, 108)
	)

	AFKButton.Text = AFKEnabled
		and "🛡️   FULL AFK: ON"
		or "🛡️   FULL AFK: OFF"
end

--========================================================
-- ESP
--========================================================

local function CreateESP(char)

	if char == Player.Character then
		return
	end

	if char:FindFirstChild("BananaESP") then
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

--========================================================
-- TELEPORT
--========================================================

DistanceBox.FocusLost:Connect(function()

	local N = tonumber(DistanceBox.Text)

	if N then
		TeleportDistance = math.clamp(N, 1, 1000)
	end

	DistanceBox.Text = tostring(TeleportDistance)
end)

TeleportButton.MouseButton1Click:Connect(function()

	TeleportEnabled = not TeleportEnabled

	UpdateButtons()
end)

TPButton.MouseButton1Click:Connect(function()

	if TeleportEnabled and RootPart and not AFKEnabled then

		RootPart.CFrame +=
			RootPart.CFrame.LookVector * TeleportDistance
	end
end)

--========================================================
-- SPEED
--========================================================

SpeedBox.FocusLost:Connect(function()

	local N = tonumber(SpeedBox.Text)

	if N then
		WalkSpeed = math.clamp(N, 1, 200)
	end

	SpeedBox.Text = tostring(WalkSpeed)

	if SpeedEnabled and Humanoid then
		Humanoid.WalkSpeed = WalkSpeed
	end
end)

SpeedButton.MouseButton1Click:Connect(function()

	SpeedEnabled = not SpeedEnabled

	if Humanoid then
		Humanoid.WalkSpeed =
			SpeedEnabled and WalkSpeed or 16
	end

	UpdateButtons()
end)

--========================================================
-- EXTRA JUMPS
--========================================================

JumpsBox.FocusLost:Connect(function()

	local N = tonumber(JumpsBox.Text)

	if N then
		ExtraJumps =
			math.clamp(math.floor(N), 0, 100)
	end

	JumpsBox.Text = tostring(ExtraJumps)
end)

ExtraJumpsButton.MouseButton1Click:Connect(function()

	ExtraJumpsEnabled = not ExtraJumpsEnabled

	JumpsDone = 0

	UpdateButtons()
end)

UIS.JumpRequest:Connect(function()

	if not ExtraJumpsEnabled
		or not Humanoid
		or not RootPart then
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

		Humanoid:ChangeState(
			Enum.HumanoidStateType.Jumping
		)

		local V = RootPart.AssemblyLinearVelocity

		RootPart.AssemblyLinearVelocity =
			Vector3.new(
				V.X,
				Humanoid.JumpPower,
				V.Z
			)
	end
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
		FlySpeed = math.clamp(N, 1, 300)
	end

	FlyBox.Text = tostring(FlySpeed)
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

		RootPart.AssemblyLinearVelocity =
			Vector3.zero

		RootPart.AssemblyAngularVelocity =
			Vector3.zero
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

	FlyConnection = RunService.RenderStepped:Connect(function()

		if not FlyEnabled
			or not RootPart
			or not FlyVelocity then
			return
		end

		local Camera = workspace.CurrentCamera

		if not Camera then
			return
		end

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

			Direction =
				Direction.Unit * FlySpeed
		end

		FlyVelocity.VectorVelocity = Direction

		local Look = Camera.CFrame.LookVector

		FlyOrientation.CFrame =
			CFrame.lookAt(
				Vector3.zero,
				Look
			)

		if UIS:IsKeyDown(Enum.KeyCode.W) then

			FlyOrientation.CFrame =
				CFrame.lookAt(
					Vector3.zero,
					Look
				)
				* CFrame.Angles(
					math.rad(-12),
					0,
					0
				)

		elseif UIS:IsKeyDown(Enum.KeyCode.S) then

			FlyOrientation.CFrame =
				CFrame.lookAt(
					Vector3.zero,
					Look
				)
				* CFrame.Angles(
					math.rad(12),
					0,
					0
				)
		end
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
				SpeedEnabled and WalkSpeed or 16
		end
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
-- MAIN HEARTBEAT
--========================================================

RunService.Heartbeat:Connect(function()

	if SpeedEnabled
		and Humanoid
		and not AFKEnabled then

		if Humanoid.WalkSpeed ~= WalkSpeed then
			Humanoid.WalkSpeed = WalkSpeed
		end
	end

	if WallhackEnabled
		and Character
		and not AFKEnabled then

		for _, Part in ipairs(Character:GetDescendants()) do

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
end)

--========================================================
-- CLOSE / OPEN
--========================================================

CloseButton.MouseButton1Click:Connect(function()

	Frame.Visible = false
	OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()

	Frame.Visible = true
	OpenButton.Visible = false
end)

--========================================================
-- DRAG MAIN WINDOW
--========================================================

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		Dragging = true

		DragStart = Input.Position
		StartPosition = Frame.Position
	end
end)

UIS.InputChanged:Connect(function(Input)

	if Dragging
		and Input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local Delta =
			Input.Position - DragStart

		Frame.Position = UDim2.new(
			StartPosition.X.Scale,
			StartPosition.X.Offset + Delta.X,
			StartPosition.Y.Scale,
			StartPosition.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		Dragging = false
	end
end)

--========================================================
-- DRAG OPEN BUTTON
--========================================================

local OpenDragging = false
local OpenDragStart
local OpenStartPosition

OpenButton.InputBegan:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		OpenDragging = true

		OpenDragStart = Input.Position
		OpenStartPosition = OpenButton.Position
	end
end)

UIS.InputChanged:Connect(function(Input)

	if OpenDragging
		and Input.UserInputType ==
		Enum.UserInputType.MouseMovement then

		local Delta =
			Input.Position - OpenDragStart

		OpenButton.Position = UDim2.new(
			OpenStartPosition.X.Scale,
			OpenStartPosition.X.Offset + Delta.X,
			OpenStartPosition.Y.Scale,
			OpenStartPosition.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(Input)

	if Input.UserInputType ==
		Enum.UserInputType.MouseButton1 then

		OpenDragging = false
	end
end)

--========================================================
-- CHARACTER RESPAWN
--========================================================

Player.CharacterAdded:Connect(function()

	task.wait(0.5)

	UpdateESP()
	UpdateButtons()

	if FlyEnabled then
		StartFly()
	end
end)

--========================================================
-- START
--========================================================

UpdateButtons()
UpdateESP()

print("🍌 Banana Script loaded successfully!")
