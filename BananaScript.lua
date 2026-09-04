local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

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

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BananaScript"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 62, 0, 62)
OpenButton.Position = UDim2.new(0, 22, 0.5, -31)
OpenButton.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
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
OpenStroke.Color = Color3.fromRGB(255, 205, 55)
OpenStroke.Thickness = 2
OpenStroke.Parent = OpenButton

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 350, 0, 720)
Frame.Position = UDim2.new(0, 25, 0.5, -360)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local FrameCorner = Instance.new("UICorner")
FrameCorner.CornerRadius = UDim.new(0, 20)
FrameCorner.Parent = Frame

local FrameStroke = Instance.new("UIStroke")
FrameStroke.Color = Color3.fromRGB(255, 205, 55)
FrameStroke.Thickness = 2
FrameStroke.Transparency = 0.25
FrameStroke.Parent = Frame

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 88)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
Header.BorderSizePixel = 0
Header.Parent = Frame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 20)
HeaderCorner.Parent = Header

local HeaderFix = Instance.new("Frame")
HeaderFix.Size = UDim2.new(1, 0, 0, 25)
HeaderFix.Position = UDim2.new(0, 0, 1, -25)
HeaderFix.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
HeaderFix.BorderSizePixel = 0
HeaderFix.Parent = Header

local BananaIcon = Instance.new("TextLabel")
BananaIcon.Size = UDim2.new(0, 48, 0, 48)
BananaIcon.Position = UDim2.new(0, 16, 0, 18)
BananaIcon.BackgroundColor3 = Color3.fromRGB(255, 205, 55)
BananaIcon.Text = "🍌"
BananaIcon.TextSize = 27
BananaIcon.Font = Enum.Font.GothamBold
BananaIcon.Parent = Header

local BananaIconCorner = Instance.new("UICorner")
BananaIconCorner.CornerRadius = UDim.new(0, 14)
BananaIconCorner.Parent = BananaIcon

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 0, 30)
Title.Position = UDim2.new(0, 75, 0, 13)
Title.BackgroundTransparency = 1
Title.Text = "🍌Banana Script🍌"
Title.TextColor3 = Color3.fromRGB(255, 220, 80)
Title.TextSize = 21
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -100, 0, 20)
Subtitle.Position = UDim2.new(0, 76, 0, 45)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "ChatGPT & TheYaruck"
Subtitle.TextColor3 = Color3.fromRGB(150, 150, 165)
Subtitle.TextSize = 12
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Font = Enum.Font.Gotham
Subtitle.Parent = Header

local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 38, 0, 38)
SettingsButton.Position = UDim2.new(1, -100, 0, 25)
SettingsButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
SettingsButton.Text = "⚙️"
SettingsButton.TextColor3 = Color3.fromRGB(220, 220, 230)
SettingsButton.TextSize = 19
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.AutoButtonColor = false
SettingsButton.Parent = Header

local SettingsCorner = Instance.new("UICorner")
SettingsCorner.CornerRadius = UDim.new(0, 12)
SettingsCorner.Parent = SettingsButton

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 38, 0, 38)
CloseButton.Position = UDim2.new(1, -52, 0, 25)
CloseButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(220, 220, 230)
CloseButton.TextSize = 23
CloseButton.Font = Enum.Font.GothamBold
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 12)
CloseCorner.Parent = CloseButton

local Content = Instance.new("ScrollingFrame")
Content.Size = UDim2.new(1, 0, 1, -88)
Content.Position = UDim2.new(0, 0, 0, 88)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.ScrollBarImageColor3 = Color3.fromRGB(255, 205, 55)
Content.CanvasSize = UDim2.new(0, 0, 0, 1000)
Content.Parent = Frame

local function Section(text, y)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -36, 0, 24)
	Label.Position = UDim2.new(0, 18, 0, y)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Color3.fromRGB(255, 205, 55)
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Font = Enum.Font.GothamBold
	Label.Parent = Content
	return Label
end

local function Button(text, y)
	local B = Instance.new("TextButton")
	B.Size = UDim2.new(1, -36, 0, 46)
	B.Position = UDim2.new(0, 18, 0, y)
	B.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	B.Text = text
	B.TextColor3 = Color3.fromRGB(235, 235, 240)
	B.TextSize = 14
	B.Font = Enum.Font.GothamBold
	B.AutoButtonColor = false
	B.Parent = Content

	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 12)
	C.Parent = B

	local S = Instance.new("UIStroke")
	S.Color = Color3.fromRGB(55, 55, 68)
	S.Thickness = 1
	S.Parent = B

	B.MouseEnter:Connect(function()
		TweenService:Create(B, TweenInfo.new(0.12), {
			BackgroundColor3 = Color3.fromRGB(48, 48, 60)
		}):Play()
	end)

	B.MouseLeave:Connect(function()
		if not B:GetAttribute("Active") then
			TweenService:Create(B, TweenInfo.new(0.12), {
				BackgroundColor3 = Color3.fromRGB(35, 35, 45)
			}):Play()
		end
	end)

	return B
end

local function Box(value, y)
	local B = Instance.new("TextBox")
	B.Size = UDim2.new(1, -36, 0, 38)
	B.Position = UDim2.new(0, 18, 0, y)
	B.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
	B.TextColor3 = Color3.fromRGB(255, 255, 255)
	B.Text = tostring(value)
	B.TextSize = 14
	B.Font = Enum.Font.GothamBold
	B.ClearTextOnFocus = false
	B.Parent = Content

	local C = Instance.new("UICorner")
	C.CornerRadius = UDim.new(0, 10)
	C.Parent = B

	local S = Instance.new("UIStroke")
	S.Color = Color3.fromRGB(50, 50, 62)
	S.Parent = B

	return B
end

Section("👁  VISUALS", 15)
local ESPButton = Button("👁  ESP: ON", 43)

Section("🌀  TELEPORT", 105)
local TeleportButton = Button("🌀  TELEPORT: OFF", 133)
local DistanceBox = Box(TeleportDistance, 187)
local TPButton = Button("🚀  TP FORWARD", 235)

Section("⚡  WALK SPEED", 297)
local SpeedButton = Button("⚡  SPEED: OFF", 325)
local SpeedBox = Box(WalkSpeed, 379)

Section("🦘  EXTRA JUMPS", 441)
local ExtraJumpsButton = Button("🦘  EXTRA JUMPS: OFF", 469)
local JumpsBox = Box(ExtraJumps, 523)

Section("🧱  WALLHACK", 585)
local WallhackButton = Button("🧱  WALLHACK: OFF", 613)

Section("✈️  FLY", 675)
local FlyButton = Button("✈️  FLY: OFF", 703)
local FlyBox = Box(FlySpeed, 757)

Section("🛡️  AFK", 819)
local AFKButton = Button("🛡️  FULL AFK: OFF", 847)

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(0, 310, 0, 220)
SettingsFrame.Position = UDim2.new(0, 45, 0.5, -110)
SettingsFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
SettingsFrame.BorderSizePixel = 0
SettingsFrame.Visible = false
SettingsFrame.ZIndex = 20
SettingsFrame.Parent = ScreenGui

local SettingsCorner2 = Instance.new("UICorner")
SettingsCorner2.CornerRadius = UDim.new(0, 18)
SettingsCorner2.Parent = SettingsFrame

local SettingsStroke = Instance.new("UIStroke")
SettingsStroke.Color = Color3.fromRGB(255, 205, 55)
SettingsStroke.Thickness = 2
SettingsStroke.Transparency = 0.25
SettingsStroke.Parent = SettingsFrame

local SettingsTitle = Instance.new("TextLabel")
SettingsTitle.Size = UDim2.new(1, -70, 0, 40)
SettingsTitle.Position = UDim2.new(0, 18, 0, 12)
SettingsTitle.BackgroundTransparency = 1
SettingsTitle.Text = "⚙️ SETTINGS"
SettingsTitle.TextColor3 = Color3.fromRGB(255, 220, 80)
SettingsTitle.TextSize = 19
SettingsTitle.TextXAlignment = Enum.TextXAlignment.Left
SettingsTitle.Font = Enum.Font.GothamBold
SettingsTitle.ZIndex = 21
SettingsTitle.Parent = SettingsFrame

local SettingsClose = Instance.new("TextButton")
SettingsClose.Size = UDim2.new(0, 36, 0, 36)
SettingsClose.Position = UDim2.new(1, -50, 0, 14)
SettingsClose.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
SettingsClose.Text = "×"
SettingsClose.TextColor3 = Color3.fromRGB(220, 220, 230)
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
ChatGPTLabel.Text = "ChatGPT:"
ChatGPTLabel.TextColor3 = Color3.fromRGB(180, 180, 195)
ChatGPTLabel.TextSize = 13
ChatGPTLabel.TextXAlignment = Enum.TextXAlignment.Left
ChatGPTLabel.Font = Enum.Font.GothamBold
ChatGPTLabel.ZIndex = 21
ChatGPTLabel.Parent = SettingsFrame

local ChatGPTLink = Instance.new("TextLabel")
ChatGPTLink.Size = UDim2.new(1, -36, 0, 42)
ChatGPTLink.Position = UDim2.new(0, 18, 0, 95)
ChatGPTLink.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
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
MoreSettings.Text = "More settings coming soon..."
MoreSettings.TextColor3 = Color3.fromRGB(120, 120, 135)
MoreSettings.TextSize = 12
MoreSettings.Font = Enum.Font.Gotham
MoreSettings.ZIndex = 21
MoreSettings.Parent = SettingsFrame

local function SetButton(B, active, color)
	B:SetAttribute("Active", active)

	if active then
		B.BackgroundColor3 = color
	else
		B.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	end
end

local function UpdateButtons()
	SetButton(ESPButton, ESPEnabled, Color3.fromRGB(75, 155, 80))
	ESPButton.Text = ESPEnabled and "👁  ESP: ON" or "👁  ESP: OFF"

	SetButton(TeleportButton, TeleportEnabled, Color3.fromRGB(80, 95, 185))
	TeleportButton.Text = TeleportEnabled and "🌀  TELEPORT: ON" or "🌀  TELEPORT: OFF"

	SetButton(SpeedButton, SpeedEnabled, Color3.fromRGB(190, 130, 45))
	SpeedButton.Text = SpeedEnabled and "⚡  SPEED: ON" or "⚡  SPEED: OFF"

	SetButton(ExtraJumpsButton, ExtraJumpsEnabled, Color3.fromRGB(145, 85, 190))
	ExtraJumpsButton.Text = ExtraJumpsEnabled and "🦘  EXTRA JUMPS: ON" or "🦘  EXTRA JUMPS: OFF"

	SetButton(WallhackButton, WallhackEnabled, Color3.fromRGB(45, 145, 180))
	WallhackButton.Text = WallhackEnabled and "🧱  WALLHACK: ON" or "🧱  WALLHACK: OFF"

	SetButton(FlyButton, FlyEnabled, Color3.fromRGB(70, 150, 210))
	FlyButton.Text = FlyEnabled and "✈️  FLY: ON" or "✈️  FLY: OFF"

	SetButton(AFKButton, AFKEnabled, Color3.fromRGB(100, 110, 120))
	AFKButton.Text = AFKEnabled and "🛡️  FULL AFK: ON" or "🛡️  FULL AFK: OFF"
end

local function CreateESP(char)
	if char == Player.Character then
		return
	end

	if char:FindFirstChild("BananaESP") then
		return
	end

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "BananaESP"
	Highlight.FillColor = Color3.fromRGB(255, 205, 55)
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
		RootPart.CFrame += RootPart.CFrame.LookVector * TeleportDistance
	end
end)

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
		Humanoid.WalkSpeed = SpeedEnabled and WalkSpeed or 16
	end

	UpdateButtons()
end)

JumpsBox.FocusLost:Connect(function()
	local N = tonumber(JumpsBox.Text)

	if N then
		ExtraJumps = math.clamp(math.floor(N), 0, 100)
	end

	JumpsBox.Text = tostring(ExtraJumps)
end)

ExtraJumpsButton.MouseButton1Click:Connect(function()
	ExtraJumpsEnabled = not ExtraJumpsEnabled
	JumpsDone = 0
	UpdateButtons()
end)

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

WallhackButton.MouseButton1Click:Connect(function()
	WallhackEnabled = not WallhackEnabled
	UpdateButtons()
end)

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
			Humanoid.WalkSpeed = SpeedEnabled and WalkSpeed or 16
		end
	end

	UpdateButtons()
end)

SettingsButton.MouseButton1Click:Connect(function()
	SettingsFrame.Visible = true
end)

SettingsClose.MouseButton1Click:Connect(function()
	SettingsFrame.Visible = false
end)

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

CloseButton.MouseButton1Click:Connect(function()
	Frame.Visible = false
	OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
	Frame.Visible = true
	OpenButton.Visible = false
end)

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

Player.CharacterAdded:Connect(function()
	task.wait(0.5)
	UpdateESP()
	UpdateButtons()

	if FlyEnabled then
		StartFly()
	end
end)

UpdateButtons()
UpdateESP()
