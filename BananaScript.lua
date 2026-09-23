local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local ESPEnabled=true
local ESPColorName="YELLOW"
local ESPColor
local ESPDistance=true
local ESPName=true
local ESPHealth=true
local ESPColors={
	{"YELLOW",Color3.fromRGB(255,207,55)},
	{"RED",Color3.fromRGB(235,75,75)},
	{"GREEN",Color3.fromRGB(70,205,105)},
	{"BLUE",Color3.fromRGB(80,150,235)},
	{"PURPLE",Color3.fromRGB(175,90,235)},
	{"WHITE",Color3.fromRGB(245,246,250)}
}
local TeleportEnabled=false
local TeleportDistance=10
local TeleportOffset=3
local ResetVelocityOnTeleport=true
local SpeedEnabled=false
local WalkSpeed=32
local DefaultGravity=workspace.Gravity
local GravityValue=DefaultGravity
local DefaultJumpPower=50
local JumpPowerValue=DefaultJumpPower
local RGBGlowEnabled=false
local RGBConnection=nil
local RGBStrokes={}
local WallhackEnabled=false
local FlyEnabled=false
local FlySpeed=50
local FlyConnection
local FlyVelocity
local FlyAttachment
local FlyOrientation
local AFKEnabled=false
local MouseUnlockEnabled=false
local MouseUnlockKey=Enum.KeyCode.LeftAlt
local SelectingMouseKey=false
local DanceEnabled=false
local DanceHotkey=Enum.KeyCode.Y
local ChoosingDanceKey=false
local DanceTrack=nil
local SelectedPlayer=nil
local CurrentTPTab="FORWARD"
local TeleportPoints={[1]=nil,[2]=nil,[3]=nil,[4]=nil,[5]=nil}
local Character
local Humanoid
local RootPart

local function SetupCharacter(char)
	Character=char
	Humanoid=char:WaitForChild("Humanoid")
	RootPart=char:WaitForChild("HumanoidRootPart")
	Humanoid.WalkSpeed=SpeedEnabled and WalkSpeed or 16
	Humanoid.UseJumpPower=true
	Humanoid.JumpPower=JumpPowerValue
	if AFKEnabled then
		RootPart.Anchored=true
	end
end

if Player.Character then
	SetupCharacter(Player.Character)
end

local BG=Color3.fromRGB(10,11,15)
local PANEL=Color3.fromRGB(17,19,25)
local PANEL_2=Color3.fromRGB(21,23,30)
local CARD=Color3.fromRGB(27,30,39)
local CARD_HOVER=Color3.fromRGB(35,38,49)
local CARD_ACTIVE=Color3.fromRGB(54,46,20)
local YELLOW=Color3.fromRGB(255,207,55)
local YELLOW_LIGHT=Color3.fromRGB(255,224,105)
local WHITE=Color3.fromRGB(245,246,250)
local GRAY=Color3.fromRGB(145,149,162)
local DARK_GRAY=Color3.fromRGB(95,99,112)
local GREEN=Color3.fromRGB(70,205,105)
ESPColor=ESPColors[1][2]

local OldGui=PlayerGui:FindFirstChild("BananaScript")
if OldGui then
	OldGui:Destroy()
end

pcall(function()
	RunService:UnbindFromRenderStep("BananaMouseUnlock")
end)

local ScreenGui=Instance.new("ScreenGui")
ScreenGui.Name="BananaScript"
ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.Parent=PlayerGui

local function Tween(Object,Properties,Duration)
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

local function AddCorner(Object,Radius)
	local Corner=Instance.new("UICorner")
	Corner.CornerRadius=UDim.new(0,Radius or 12)
	Corner.Parent=Object
	return Corner
end

local function AddStroke(Object,Color,Thickness,Transparency)
	local Stroke=Instance.new("UIStroke")
	Stroke.Color=Color
	Stroke.Thickness=Thickness or 1
	Stroke.Transparency=Transparency or 0
	Stroke.Parent=Object
	return Stroke
end

local function Button(parent,text,y,height)
	local B=Instance.new("TextButton")
	B.Size=UDim2.new(1,-28,0,height or 46)
	B.Position=UDim2.new(0,14,0,y)
	B.BackgroundColor3=CARD
	B.Text=text
	B.TextColor3=WHITE
	B.TextSize=13
	B.Font=Enum.Font.GothamBold
	B.AutoButtonColor=false
	B.Parent=parent
	AddCorner(B,12)
	AddStroke(B,Color3.fromRGB(48,51,62),1,0)

	B.MouseEnter:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B,{BackgroundColor3=CARD_HOVER},0.12):Play()
		end
	end)

	B.MouseLeave:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B,{BackgroundColor3=CARD},0.12):Play()
		end
	end)

	return B
end

local function MiniButton(parent,text,x,y,w)
	local B=Instance.new("TextButton")
	B.Size=UDim2.new(0,w or 175,0,38)
	B.Position=UDim2.new(0,x,0,y)
	B.BackgroundColor3=CARD
	B.Text=text
	B.TextColor3=WHITE
	B.TextSize=11
	B.Font=Enum.Font.GothamBold
	B.AutoButtonColor=false
	B.Parent=parent
	AddCorner(B,10)
	AddStroke(B,Color3.fromRGB(48,51,62),1)

	B.MouseEnter:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B,{BackgroundColor3=CARD_HOVER},0.1):Play()
		end
	end)

	B.MouseLeave:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B,{BackgroundColor3=CARD},0.1):Play()
		end
	end)

	return B
end

local function Box(parent,value,y,width)
	local B=Instance.new("TextBox")
	B.Size=UDim2.new(
		0,
		width or (parent.AbsoluteSize.X-28),
		0,
		38
	)
	B.Position=UDim2.new(0,14,0,y)
	B.BackgroundColor3=PANEL
	B.TextColor3=WHITE
	B.PlaceholderColor3=DARK_GRAY
	B.Text=tostring(value)
	B.TextSize=13
	B.Font=Enum.Font.GothamBold
	B.ClearTextOnFocus=false
	B.Parent=parent
	AddCorner(B,10)
	AddStroke(B,Color3.fromRGB(45,48,58),1,0)
	return B
end

local function SetButton(B,active,color)
	B:SetAttribute("Active",active)

	if active then
		Tween(B,{BackgroundColor3=color},0.12):Play()
	else
		Tween(B,{BackgroundColor3=CARD},0.12):Play()
	end
end

local function Section(parent,text,y)
	local Label=Instance.new("TextLabel")
	Label.Size=UDim2.new(1,-28,0,24)
	Label.Position=UDim2.new(0,14,0,y)
	Label.BackgroundTransparency=1
	Label.Text=text
	Label.TextColor3=YELLOW
	Label.TextSize=11
	Label.TextXAlignment=Enum.TextXAlignment.Left
	Label.Font=Enum.Font.GothamBold
	Label.Parent=parent
	return Label
end

local function KeyButton(parent,text,y)
	local B=Instance.new("TextButton")
	B.Size=UDim2.new(0,110,0,40)
	B.Position=UDim2.new(1,-124,0,y)
	B.BackgroundColor3=CARD
	B.Text=text
	B.TextColor3=WHITE
	B.TextSize=12
	B.Font=Enum.Font.GothamBold
	B.AutoButtonColor=false
	B.Parent=parent
	AddCorner(B,10)
	AddStroke(B,Color3.fromRGB(48,51,62),1)

	B.MouseEnter:Connect(function()
		Tween(B,{BackgroundColor3=CARD_HOVER},0.12):Play()
	end)

	B.MouseLeave:Connect(function()
		Tween(B,{BackgroundColor3=CARD},0.12):Play()
	end)

	return B
end

local function CreateCard(parent,position,size)
	local F=Instance.new("Frame")
	F.Position=position
	F.Size=size
	F.BackgroundColor3=PANEL_2
	F.BorderSizePixel=0
	F.Parent=parent
	AddCorner(F,14)
	AddStroke(F,Color3.fromRGB(42,45,56),1)
	return F
end

local OpenButton=Instance.new("TextButton")
OpenButton.Name="OpenButton"
OpenButton.Size=UDim2.new(0,58,0,58)
OpenButton.Position=UDim2.new(0,24,0.5,-29)
OpenButton.BackgroundColor3=PANEL
OpenButton.Text="🍌"
OpenButton.TextSize=30
OpenButton.Font=Enum.Font.GothamBold
OpenButton.Visible=false
OpenButton.AutoButtonColor=false
OpenButton.Active=true
OpenButton.Parent=ScreenGui
AddCorner(OpenButton,100)

local OpenStroke=AddStroke(OpenButton,YELLOW,2,0)

OpenButton.MouseEnter:Connect(function()
	Tween(OpenButton,{BackgroundColor3=CARD_HOVER},0.12):Play()
end)

OpenButton.MouseLeave:Connect(function()
	Tween(OpenButton,{BackgroundColor3=PANEL},0.12):Play()
end)

local Frame=Instance.new("Frame")
Frame.Name="Main"
Frame.Size=UDim2.new(0,390,0,670)
Frame.Position=UDim2.new(0.5,-195,0.5,-335)
Frame.BackgroundColor3=BG
Frame.BorderSizePixel=0
Frame.Parent=ScreenGui
AddCorner(Frame,22)

local FrameStroke=AddStroke(Frame,YELLOW,1.5,0.15)

local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,95)
Header.BackgroundColor3=PANEL
Header.BorderSizePixel=0
Header.Parent=Frame
AddCorner(Header,22)

local HeaderFix=Instance.new("Frame")
HeaderFix.Size=UDim2.new(1,0,0,22)
HeaderFix.Position=UDim2.new(0,0,1,-22)
HeaderFix.BackgroundColor3=PANEL
HeaderFix.BorderSizePixel=0
HeaderFix.Parent=Header

local BananaIcon=Instance.new("TextLabel")
BananaIcon.Size=UDim2.new(0,56,0,56)
BananaIcon.Position=UDim2.new(0,15,0,18)
BananaIcon.BackgroundColor3=YELLOW
BananaIcon.Text="🍌"
BananaIcon.TextSize=29
BananaIcon.Font=Enum.Font.GothamBold
BananaIcon.Parent=Header
AddCorner(BananaIcon,16)

local BananaIconStroke=AddStroke(BananaIcon,YELLOW,1.5,0)

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-180,0,28)
Title.Position=UDim2.new(0,84,0,13)
Title.BackgroundTransparency=1
Title.Text="BANANA SCRIPT"
Title.TextColor3=WHITE
Title.TextSize=21
Title.TextXAlignment=Enum.TextXAlignment.Left
Title.Font=Enum.Font.GothamBold
Title.Parent=Header

local Subtitle=Instance.new("TextLabel")
Subtitle.Size=UDim2.new(1,-180,0,20)
Subtitle.Position=UDim2.new(0,85,0,41)
Subtitle.BackgroundTransparency=1
Subtitle.Text="Modern UI • ChatGPT × TheYaruck"
Subtitle.TextColor3=GRAY
Subtitle.TextSize=11
Subtitle.TextXAlignment=Enum.TextXAlignment.Left
Subtitle.Font=Enum.Font.Gotham
Subtitle.Parent=Header

local Status=Instance.new("TextLabel")
Status.Size=UDim2.new(0,74,0,22)
Status.Position=UDim2.new(0,84,0,65)
Status.BackgroundColor3=Color3.fromRGB(24,65,38)
Status.Text="● ONLINE"
Status.TextColor3=GREEN
Status.TextSize=9
Status.Font=Enum.Font.GothamBold
Status.Parent=Header
AddCorner(Status,100)

local SettingsButton=Instance.new("TextButton")
SettingsButton.Size=UDim2.new(0,38,0,38)
SettingsButton.Position=UDim2.new(1,-100,0,25)
SettingsButton.BackgroundColor3=CARD
SettingsButton.Text="⚙"
SettingsButton.TextColor3=WHITE
SettingsButton.TextSize=19
SettingsButton.Font=Enum.Font.GothamBold
SettingsButton.AutoButtonColor=false
SettingsButton.Parent=Header
AddCorner(SettingsButton,11)

local CloseButton=Instance.new("TextButton")
CloseButton.Size=UDim2.new(0,38,0,38)
CloseButton.Position=UDim2.new(1,-52,0,25)
CloseButton.BackgroundColor3=CARD
CloseButton.Text="×"
CloseButton.TextColor3=WHITE
CloseButton.TextSize=23
CloseButton.Font=Enum.Font.GothamBold
CloseButton.AutoButtonColor=false
CloseButton.Parent=Header
AddCorner(CloseButton,11)

local function AddButtonHover(B)
	B.MouseEnter:Connect(function()
		Tween(B,{BackgroundColor3=CARD_HOVER},0.12):Play()
	end)

	B.MouseLeave:Connect(function()
		Tween(B,{BackgroundColor3=CARD},0.12):Play()
	end)
end

AddButtonHover(SettingsButton)
AddButtonHover(CloseButton)

local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(1,-20,0,44)
TabBar.Position=UDim2.new(0,10,0,103)
TabBar.BackgroundTransparency=1
TabBar.Parent=Frame

local function MakeTab(text,x)
	local B=Instance.new("TextButton")
	B.Size=UDim2.new(0.5,-5,1,0)
	B.Position=UDim2.new(x,0,0,0)
	B.BackgroundColor3=CARD
	B.Text=text
	B.TextColor3=WHITE
	B.TextSize=11
	B.Font=Enum.Font.GothamBold
	B.AutoButtonColor=false
	B.Parent=TabBar
	AddCorner(B,11)

	B.MouseEnter:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B,{BackgroundColor3=CARD_HOVER},0.12):Play()
		end
	end)

	B.MouseLeave:Connect(function()
		if not B:GetAttribute("Active") then
			Tween(B,{BackgroundColor3=CARD},0.12):Play()
		end
	end)

	return B
end

local BananaTab=MakeTab("🍌  BANANA",0)
local ChatTab=MakeTab("💬  CHAT",0.5)

local ContentHolder=Instance.new("Frame")
ContentHolder.Size=UDim2.new(1,-20,1,-157)
ContentHolder.Position=UDim2.new(0,10,0,157)
ContentHolder.BackgroundTransparency=1
ContentHolder.ClipsDescendants=true
ContentHolder.Parent=Frame

local function CreateContent()
	local S=Instance.new("ScrollingFrame")
	S.Size=UDim2.new(1,0,1,0)
	S.BackgroundTransparency=1
	S.BorderSizePixel=0
	S.ScrollBarThickness=3
	S.ScrollBarImageColor3=YELLOW
	S.ScrollingEnabled=true
	S.Active=true
	S.CanvasSize=UDim2.new(0,0,0,1000)
	S.Visible=false
	S.Parent=ContentHolder
	return S
end

local BananaContent=CreateContent()
local ChatContent=CreateContent()

Section(BananaContent,"👁  VISUALS",10)

local ESPButton=Button(BananaContent,"👁   ESP: ON",38,40)
local ESPColorButton=MiniButton(BananaContent,"🎨  ESP COLOR: YELLOW",14,86,176)
local ESPDistanceButton=MiniButton(BananaContent,"📏  ESP DISTANCE: ON",202,86,176)
local ESPNameButton=MiniButton(BananaContent,"🏷  ESP NAME: ON",14,130,176)
local ESPHealthButton=MiniButton(BananaContent,"❤️  ESP HEALTH: ON",202,130,176)

Section(BananaContent,"🚀  TELEPORT",180)

local TeleportCard=CreateCard(
	BananaContent,
	UDim2.new(0,14,0,210),
	UDim2.new(1,-28,0,350)
)

local TeleportTitle=Instance.new("TextLabel")
TeleportTitle.Size=UDim2.new(1,-24,0,25)
TeleportTitle.Position=UDim2.new(0,12,0,9)
TeleportTitle.BackgroundTransparency=1
TeleportTitle.Text="Teleport Center"
TeleportTitle.TextColor3=WHITE
TeleportTitle.TextSize=14
TeleportTitle.TextXAlignment=Enum.TextXAlignment.Left
TeleportTitle.Font=Enum.Font.GothamBold
TeleportTitle.Parent=TeleportCard

local TeleportSubtitle=Instance.new("TextLabel")
TeleportSubtitle.Size=UDim2.new(1,-24,0,20)
TeleportSubtitle.Position=UDim2.new(0,12,0,32)
TeleportSubtitle.BackgroundTransparency=1
TeleportSubtitle.Text="Choose a teleport mode"
TeleportSubtitle.TextColor3=GRAY
TeleportSubtitle.TextSize=10
TeleportSubtitle.TextXAlignment=Enum.TextXAlignment.Left
TeleportSubtitle.Font=Enum.Font.Gotham
TeleportSubtitle.Parent=TeleportCard

local TPTabBar=Instance.new("Frame")
TPTabBar.Size=UDim2.new(1,-24,0,38)
TPTabBar.Position=UDim2.new(0,12,0,60)
TPTabBar.BackgroundTransparency=1
TPTabBar.Parent=TeleportCard

local TPTabButtons={}

local function MakeTPTab(name,text,x)
	local B=Instance.new("TextButton")
	B.Size=UDim2.new(0.25,-4,1,0)
	B.Position=UDim2.new(x,0,0,0)
	B.BackgroundColor3=CARD
	B.Text=text
	B.TextColor3=GRAY
	B.TextSize=9
	B.Font=Enum.Font.GothamBold
	B.AutoButtonColor=false
	B.Parent=TPTabBar
	AddCorner(B,9)
	TPTabButtons[name]=B

	B.MouseEnter:Connect(function()
		if CurrentTPTab~=name then
			Tween(B,{BackgroundColor3=CARD_HOVER},0.1):Play()
		end
	end)

	B.MouseLeave:Connect(function()
		if CurrentTPTab~=name then
			Tween(B,{BackgroundColor3=CARD},0.1):Play()
		end
	end)

	return B
end

local ForwardTab=MakeTPTab("FORWARD","🚀 FORWARD",0)
local PlayerTab=MakeTPTab("PLAYER","👤 PLAYER",0.25)
local PointsTab=MakeTPTab("POINTS","📍 POINTS",0.5)
local TPSettingsTab=MakeTPTab("SETTINGS","⚙ SETTINGS",0.75)

local function CreateTPPanel(canvasHeight)
	local P=Instance.new("ScrollingFrame")
	P.Size=UDim2.new(1,-24,0,230)
	P.Position=UDim2.new(0,12,0,106)
	P.BackgroundTransparency=1
	P.BorderSizePixel=0
	P.ScrollBarThickness=3
	P.ScrollBarImageColor3=YELLOW
	P.ScrollingEnabled=true
	P.Active=true
	P.CanvasSize=UDim2.new(0,0,0,canvasHeight or 230)
	P.Visible=false
	P.Parent=TeleportCard
	return P
end

local ForwardPanel=CreateTPPanel(185)
local PlayerPanel=CreateTPPanel(325)
local PointsPanel=CreateTPPanel(185)
local TPSettingsPanel=CreateTPPanel(180)

local TeleportButton=Button(
	ForwardPanel,
	"🌀   TELEPORT: OFF",
	4,
	40
)

local ForwardLabel=Instance.new("TextLabel")
ForwardLabel.Size=UDim2.new(1,-4,0,18)
ForwardLabel.Position=UDim2.new(0,2,0,51)
ForwardLabel.BackgroundTransparency=1
ForwardLabel.Text="DISTANCE"
ForwardLabel.TextColor3=GRAY
ForwardLabel.TextSize=9
ForwardLabel.TextXAlignment=Enum.TextXAlignment.Left
ForwardLabel.Font=Enum.Font.GothamBold
ForwardLabel.Parent=ForwardPanel

local DistanceBox=Instance.new("TextBox")
DistanceBox.Size=UDim2.new(1,-4,0,34)
DistanceBox.Position=UDim2.new(0,2,0,71)
DistanceBox.BackgroundColor3=PANEL
DistanceBox.TextColor3=WHITE
DistanceBox.PlaceholderColor3=DARK_GRAY
DistanceBox.Text=tostring(TeleportDistance)
DistanceBox.TextSize=12
DistanceBox.Font=Enum.Font.GothamBold
DistanceBox.ClearTextOnFocus=false
DistanceBox.Parent=ForwardPanel
AddCorner(DistanceBox,9)
AddStroke(DistanceBox,Color3.fromRGB(45,48,58),1)

local TPButton=Button(
	ForwardPanel,
	"🚀   TP FORWARD",
	114,
	42
)

local TPToPlayerButton=Button(
	PlayerPanel,
	"🚀   TP TO PLAYER",
	4,
	38
)

local RefreshPlayersButton=Button(
	PlayerPanel,
	"🔄   REFRESH PLAYERS",
	48,
	38
)

local PlayerListFrame=Instance.new("ScrollingFrame")
PlayerListFrame.Size=UDim2.new(1,-4,0,170)
PlayerListFrame.Position=UDim2.new(0,2,0,92)
PlayerListFrame.BackgroundColor3=PANEL
PlayerListFrame.BorderSizePixel=0
PlayerListFrame.ScrollBarThickness=3
PlayerListFrame.ScrollBarImageColor3=YELLOW
PlayerListFrame.ScrollingEnabled=true
PlayerListFrame.Active=true
PlayerListFrame.CanvasSize=UDim2.new()
PlayerListFrame.Parent=PlayerPanel
AddCorner(PlayerListFrame,9)

local PlayerStatus=Instance.new("TextLabel")
PlayerStatus.Size=UDim2.new(1,-4,0,18)
PlayerStatus.Position=UDim2.new(0,2,0,272)
PlayerStatus.BackgroundTransparency=1
PlayerStatus.Text="✕  NO PLAYER SELECTED"
PlayerStatus.TextColor3=DARK_GRAY
PlayerStatus.TextSize=9
PlayerStatus.Font=Enum.Font.GothamBold
PlayerStatus.TextXAlignment=Enum.TextXAlignment.Left
PlayerStatus.Parent=PlayerPanel

local PlayerRows={}
local PointRows={}

for i=1,5 do
	local Row=Instance.new("Frame")
	Row.Size=UDim2.new(1,0,0,31)
	Row.Position=UDim2.new(0,0,0,(i-1)*34)
	Row.BackgroundTransparency=1
	Row.Parent=PointsPanel

	local NameLabel=Instance.new("TextLabel")
	NameLabel.Size=UDim2.new(0,55,1,0)
	NameLabel.BackgroundTransparency=1
	NameLabel.Text="POINT "..i
	NameLabel.TextColor3=WHITE
	NameLabel.TextSize=9
	NameLabel.Font=Enum.Font.GothamBold
	NameLabel.TextXAlignment=Enum.TextXAlignment.Left
	NameLabel.Parent=Row

	local StateLabel=Instance.new("TextLabel")
	StateLabel.Size=UDim2.new(0,50,1,0)
	StateLabel.Position=UDim2.new(0,55,0,0)
	StateLabel.BackgroundTransparency=1
	StateLabel.Text="EMPTY"
	StateLabel.TextColor3=DARK_GRAY
	StateLabel.TextSize=8
	StateLabel.Font=Enum.Font.GothamBold
	StateLabel.Parent=Row

	local SaveButton=Instance.new("TextButton")
	SaveButton.Size=UDim2.new(0,68,0,29)
	SaveButton.Position=UDim2.new(1,-212,0,1)
	SaveButton.BackgroundColor3=CARD
	SaveButton.Text="SAVE"
	SaveButton.TextColor3=WHITE
	SaveButton.TextSize=9
	SaveButton.Font=Enum.Font.GothamBold
	SaveButton.AutoButtonColor=false
	SaveButton.Parent=Row
	AddCorner(SaveButton,8)

	local DeleteButton=Instance.new("TextButton")
	DeleteButton.Size=UDim2.new(0,68,0,29)
	DeleteButton.Position=UDim2.new(1,-140,0,1)
	DeleteButton.BackgroundColor3=CARD
	DeleteButton.Text="DELETE"
	DeleteButton.TextColor3=WHITE
	DeleteButton.TextSize=9
	DeleteButton.Font=Enum.Font.GothamBold
	DeleteButton.AutoButtonColor=false
	DeleteButton.Parent=Row
	AddCorner(DeleteButton,8)

	local TPPointButton=Instance.new("TextButton")
	TPPointButton.Size=UDim2.new(0,68,0,29)
	TPPointButton.Position=UDim2.new(1,-68,0,1)
	TPPointButton.BackgroundColor3=CARD
	TPPointButton.Text="TP"
	TPPointButton.TextColor3=WHITE
	TPPointButton.TextSize=9
	TPPointButton.Font=Enum.Font.GothamBold
	TPPointButton.AutoButtonColor=false
	TPPointButton.Parent=Row
	AddCorner(TPPointButton,8)

	PointRows[i]={
		Row=Row,
		State=StateLabel,
		Save=SaveButton,
		Delete=DeleteButton,
		TP=TPPointButton
	}
end

local TPOffsetLabel=Instance.new("TextLabel")
TPOffsetLabel.Size=UDim2.new(1,-4,0,18)
TPOffsetLabel.Position=UDim2.new(0,2,0,2)
TPOffsetLabel.BackgroundTransparency=1
TPOffsetLabel.Text="PLAYER TP OFFSET"
TPOffsetLabel.TextColor3=GRAY
TPOffsetLabel.TextSize=9
TPOffsetLabel.TextXAlignment=Enum.TextXAlignment.Left
TPOffsetLabel.Font=Enum.Font.GothamBold
TPOffsetLabel.Parent=TPSettingsPanel

local TPOffsetBox=Instance.new("TextBox")
TPOffsetBox.Size=UDim2.new(1,-4,0,34)
TPOffsetBox.Position=UDim2.new(0,2,0,22)
TPOffsetBox.BackgroundColor3=PANEL
TPOffsetBox.TextColor3=WHITE
TPOffsetBox.Text=tostring(TeleportOffset)
TPOffsetBox.TextSize=12
TPOffsetBox.Font=Enum.Font.GothamBold
TPOffsetBox.ClearTextOnFocus=false
TPOffsetBox.Parent=TPSettingsPanel
AddCorner(TPOffsetBox,9)
AddStroke(TPOffsetBox,Color3.fromRGB(45,48,58),1)

local ResetVelocityButton=Instance.new("TextButton")
ResetVelocityButton.Size=UDim2.new(1,-4,0,40)
ResetVelocityButton.Position=UDim2.new(0,2,0,66)
ResetVelocityButton.BackgroundColor3=CARD
ResetVelocityButton.TextColor3=WHITE
ResetVelocityButton.TextSize=11
ResetVelocityButton.Font=Enum.Font.GothamBold
ResetVelocityButton.AutoButtonColor=false
ResetVelocityButton.Parent=TPSettingsPanel
AddCorner(ResetVelocityButton,10)

local TPSettingsInfo=Instance.new("TextLabel")
TPSettingsInfo.Size=UDim2.new(1,-4,0,45)
TPSettingsInfo.Position=UDim2.new(0,2,0,115)
TPSettingsInfo.BackgroundTransparency=1
TPSettingsInfo.Text="Offset changes the height used when teleporting to a player."
TPSettingsInfo.TextColor3=DARK_GRAY
TPSettingsInfo.TextSize=9
TPSettingsInfo.Font=Enum.Font.Gotham
TPSettingsInfo.TextWrapped=true
TPSettingsInfo.TextXAlignment=Enum.TextXAlignment.Left
TPSettingsInfo.Parent=TPSettingsPanel

local function SetTPTab(tab)
	CurrentTPTab=tab

	ForwardPanel.Visible=false
	PlayerPanel.Visible=false
	PointsPanel.Visible=false
	TPSettingsPanel.Visible=false

	for Name,B in pairs(TPTabButtons) do
		B:SetAttribute("Active",Name==tab)
		Tween(
			B,
			{
				BackgroundColor3=Name==tab and CARD_ACTIVE or CARD,
				TextColor3=Name==tab and YELLOW_LIGHT or GRAY
			},
			0.12
		):Play()
	end

	if tab=="FORWARD" then
		ForwardPanel.Visible=true
	elseif tab=="PLAYER" then
		PlayerPanel.Visible=true
	elseif tab=="POINTS" then
		PointsPanel.Visible=true
	else
		TPSettingsPanel.Visible=true
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

Section(BananaContent,"⚡  MOVEMENT",582)

local SpeedButton=Button(
	BananaContent,
	"⚡   SPEED: OFF",
	610
)

local SpeedBox=Box(
	BananaContent,
	WalkSpeed,
	658
)

Section(BananaContent,"🧱  WALLHACK",713)

local WallhackButton=Button(
	BananaContent,
	"🧱   WALLHACK: OFF",
	741
)

Section(BananaContent,"✈️  FLY",799)

local FlyButton=Button(
	BananaContent,
	"✈️   FLY: OFF",
	827
)

local FlyBox=Box(
	BananaContent,
	FlySpeed,
	875
)

Section(BananaContent,"🛡️  AFK",930)

local AFKButton=Button(
	BananaContent,
	"🛡️   FULL AFK: OFF",
	958
)

Section(BananaContent,"🪐  PHYSICS",1016)

local GravityBox=Box(
	BananaContent,
	GravityValue,
	1044
)

local JumpPowerBox=Box(
	BananaContent,
	JumpPowerValue,
	1092
)

local ResetPhysicsButton=Button(
	BananaContent,
	"🔄   RESET PHYSICS",
	1140
)

BananaContent.CanvasSize=UDim2.new(0,0,0,1208)

Section(ChatContent,"💃  DANCE 2",10)

local DanceButton=Button(
	ChatContent,
	"💃   DANCE 2: OFF",
	38
)

local DanceInfo=Instance.new("TextLabel")
DanceInfo.Size=UDim2.new(1,-28,0,45)
DanceInfo.Position=UDim2.new(0,14,0,92)
DanceInfo.BackgroundTransparency=1
DanceInfo.Text="R6 ONLY • Animation: 182436842"
DanceInfo.TextColor3=GRAY
DanceInfo.TextSize=11
DanceInfo.Font=Enum.Font.Gotham
DanceInfo.TextXAlignment=Enum.TextXAlignment.Left
DanceInfo.Parent=ChatContent

local DanceKeyLabel=Instance.new("TextLabel")
DanceKeyLabel.Size=UDim2.new(0,150,0,40)
DanceKeyLabel.Position=UDim2.new(0,14,0,140)
DanceKeyLabel.BackgroundTransparency=1
DanceKeyLabel.Text="HOTKEY"
DanceKeyLabel.TextColor3=WHITE
DanceKeyLabel.TextSize=12
DanceKeyLabel.Font=Enum.Font.GothamBold
DanceKeyLabel.TextXAlignment=Enum.TextXAlignment.Left
DanceKeyLabel.Parent=ChatContent

local DanceKeyButton=KeyButton(
	ChatContent,
	DanceHotkey.Name,
	140
)

Section(ChatContent,"🖱  MOUSE",204)

local MouseUnlockButton=Button(
	ChatContent,
	"🖱   MOUSE UNLOCK: OFF",
	232
)

local MouseKeyLabel=Instance.new("TextLabel")
MouseKeyLabel.Size=UDim2.new(0,150,0,40)
MouseKeyLabel.Position=UDim2.new(0,14,0,286)
MouseKeyLabel.BackgroundTransparency=1
MouseKeyLabel.Text="MOUSE HOTKEY"
MouseKeyLabel.TextColor3=WHITE
MouseKeyLabel.TextSize=12
MouseKeyLabel.Font=Enum.Font.GothamBold
MouseKeyLabel.TextXAlignment=Enum.TextXAlignment.Left
MouseKeyLabel.Parent=ChatContent

local MouseKeyButton=KeyButton(
	ChatContent,
	MouseUnlockKey.Name,
	286
)

ChatContent.CanvasSize=UDim2.new(0,0,0,360)

local SettingsFrame=Instance.new("Frame")
SettingsFrame.Size=UDim2.new(0,325,0,285)
SettingsFrame.Position=UDim2.new(0,50,0.5,-142)
SettingsFrame.BackgroundColor3=PANEL
SettingsFrame.BorderSizePixel=0
SettingsFrame.Visible=false
SettingsFrame.ZIndex=20
SettingsFrame.Active=true
SettingsFrame.Parent=ScreenGui
AddCorner(SettingsFrame,18)

local SettingsFrameStroke=AddStroke(SettingsFrame,YELLOW,2,0.2)

local SettingsDragBar=Instance.new("Frame")
SettingsDragBar.Size=UDim2.new(1,-60,0,55)
SettingsDragBar.BackgroundTransparency=1
SettingsDragBar.ZIndex=20
SettingsDragBar.Active=true
SettingsDragBar.Parent=SettingsFrame

local SettingsTitle=Instance.new("TextLabel")
SettingsTitle.Size=UDim2.new(1,-70,0,40)
SettingsTitle.Position=UDim2.new(0,18,0,12)
SettingsTitle.BackgroundTransparency=1
SettingsTitle.Text="⚙️  SETTINGS"
SettingsTitle.TextColor3=YELLOW_LIGHT
SettingsTitle.TextSize=19
SettingsTitle.TextXAlignment=Enum.TextXAlignment.Left
SettingsTitle.Font=Enum.Font.GothamBold
SettingsTitle.ZIndex=21
SettingsTitle.Parent=SettingsFrame

local SettingsClose=Instance.new("TextButton")
SettingsClose.Size=UDim2.new(0,36,0,36)
SettingsClose.Position=UDim2.new(1,-50,0,14)
SettingsClose.BackgroundColor3=CARD
SettingsClose.Text="×"
SettingsClose.TextColor3=WHITE
SettingsClose.TextSize=22
SettingsClose.Font=Enum.Font.GothamBold
SettingsClose.AutoButtonColor=false
SettingsClose.ZIndex=21
SettingsClose.Parent=SettingsFrame
AddCorner(SettingsClose,11)

local ChatGPTLabel=Instance.new("TextLabel")
ChatGPTLabel.Size=UDim2.new(1,-36,0,25)
ChatGPTLabel.Position=UDim2.new(0,18,0,65)
ChatGPTLabel.BackgroundTransparency=1
ChatGPTLabel.Text="Created with ChatGPT"
ChatGPTLabel.TextColor3=GRAY
ChatGPTLabel.TextSize=13
ChatGPTLabel.TextXAlignment=Enum.TextXAlignment.Left
ChatGPTLabel.Font=Enum.Font.GothamBold
ChatGPTLabel.ZIndex=21
ChatGPTLabel.Parent=SettingsFrame

local RGBButton=Instance.new("TextButton")
RGBButton.Size=UDim2.new(1,-36,0,38)
RGBButton.Position=UDim2.new(0,18,0,95)
RGBButton.BackgroundColor3=CARD
RGBButton.Text="🌈  RGB GLOW: OFF"
RGBButton.TextColor3=WHITE
RGBButton.TextSize=12
RGBButton.Font=Enum.Font.GothamBold
RGBButton.AutoButtonColor=false
RGBButton.ZIndex=21
RGBButton.Parent=SettingsFrame
AddCorner(RGBButton,10)

local RGBButtonStroke=AddStroke(
	RGBButton,
	Color3.fromRGB(48,51,62),
	1,
	0
)

local ChatGPTLink=Instance.new("TextLabel")
ChatGPTLink.Size=UDim2.new(1,-36,0,38)
ChatGPTLink.Position=UDim2.new(0,18,0,148)
ChatGPTLink.BackgroundColor3=CARD
ChatGPTLink.Text="chatgpt.com"
ChatGPTLink.TextColor3=Color3.fromRGB(100,180,255)
ChatGPTLink.TextSize=13
ChatGPTLink.Font=Enum.Font.GothamBold
ChatGPTLink.TextXAlignment=Enum.TextXAlignment.Center
ChatGPTLink.ZIndex=21
ChatGPTLink.Parent=SettingsFrame
AddCorner(ChatGPTLink,10)

local CopyLinkButton=Instance.new("TextButton")
CopyLinkButton.Size=UDim2.new(1,-36,0,38)
CopyLinkButton.Position=UDim2.new(0,18,0,194)
CopyLinkButton.BackgroundColor3=CARD
CopyLinkButton.Text="📋  COPY LINK"
CopyLinkButton.TextColor3=WHITE
CopyLinkButton.TextSize=12
CopyLinkButton.Font=Enum.Font.GothamBold
CopyLinkButton.AutoButtonColor=false
CopyLinkButton.ZIndex=21
CopyLinkButton.Parent=SettingsFrame
AddCorner(CopyLinkButton,10)

local MoreSettings=Instance.new("TextLabel")
MoreSettings.Size=UDim2.new(1,-36,0,25)
MoreSettings.Position=UDim2.new(0,18,0,240)
MoreSettings.BackgroundTransparency=1
MoreSettings.Text="🍌 Banana Script • Modern UI Edition"
MoreSettings.TextColor3=DARK_GRAY
MoreSettings.TextSize=12
MoreSettings.Font=Enum.Font.Gotham
MoreSettings.ZIndex=21
MoreSettings.Parent=SettingsFrame

local function SetTab(tab)
	BananaContent.Visible=tab=="BANANA"
	ChatContent.Visible=tab=="CHAT"

	for _,B in ipairs({BananaTab,ChatTab}) do
		local active=B==(tab=="BANANA" and BananaTab or ChatTab)
		B:SetAttribute("Active",active)
		Tween(
			B,
			{
				BackgroundColor3=active and CARD_ACTIVE or CARD,
				TextColor3=active and YELLOW_LIGHT or WHITE
			},
			0.12
		):Play()
	end
end

BananaTab.MouseButton1Click:Connect(function()
	SetTab("BANANA")
end)

ChatTab.MouseButton1Click:Connect(function()
	SetTab("CHAT")
end)

local function UpdateButtons()
	SetButton(ESPButton,ESPEnabled,Color3.fromRGB(48,130,75))
	ESPButton.Text=ESPEnabled and "👁   ESP: ON" or "👁   ESP: OFF"

	SetButton(TeleportButton,TeleportEnabled,Color3.fromRGB(70,82,160))
	TeleportButton.Text=TeleportEnabled and "🌀   TELEPORT: ON" or "🌀   TELEPORT: OFF"

	SetButton(SpeedButton,SpeedEnabled,Color3.fromRGB(170,115,35))
	SpeedButton.Text=SpeedEnabled and "⚡   SPEED: ON" or "⚡   SPEED: OFF"

	SetButton(WallhackButton,WallhackEnabled,Color3.fromRGB(40,125,155))
	WallhackButton.Text=WallhackEnabled and "🧱   WALLHACK: ON" or "🧱   WALLHACK: OFF"

	SetButton(FlyButton,FlyEnabled,Color3.fromRGB(55,125,185))
	FlyButton.Text=FlyEnabled and "✈️   FLY: ON" or "✈️   FLY: OFF"

	SetButton(AFKButton,AFKEnabled,Color3.fromRGB(85,95,108))
	AFKButton.Text=AFKEnabled and "🛡️   FULL AFK: ON" or "🛡️   FULL AFK: OFF"

	ESPColorButton.Text="🎨  ESP COLOR: "..ESPColorName
	ESPDistanceButton.Text="📏  ESP DISTANCE: "..(ESPDistance and "ON" or "OFF")
	ESPNameButton.Text="🏷  ESP NAME: "..(ESPName and "ON" or "OFF")
	ESPHealthButton.Text="❤️  ESP HEALTH: "..(ESPHealth and "ON" or "OFF")

	SetButton(ESPDistanceButton,ESPDistance,Color3.fromRGB(55,105,145))
	SetButton(ESPNameButton,ESPName,Color3.fromRGB(100,80,145))
	SetButton(ESPHealthButton,ESPHealth,Color3.fromRGB(145,65,75))

	DanceKeyButton.Text=DanceHotkey.Name
	MouseKeyButton.Text=MouseUnlockKey.Name

	ResetVelocityButton.Text=ResetVelocityOnTeleport
		and "💨   RESET VELOCITY: ON"
		or "💨   RESET VELOCITY: OFF"

	RGBButton.Text=RGBGlowEnabled
		and "🌈  RGB GLOW: ON"
		or "🌈  RGB GLOW: OFF"

	RGBButton.BackgroundColor3=RGBGlowEnabled
		and CARD_ACTIVE
		or CARD

	if SelectedPlayer then
		PlayerStatus.Text="✓  SELECTED: "..SelectedPlayer.." • IN GAME"
		PlayerStatus.TextColor3=GREEN
	else
		PlayerStatus.Text="✕  NO PLAYER SELECTED"
		PlayerStatus.TextColor3=DARK_GRAY
	end

	for i=1,5 do
		local saved=TeleportPoints[i]~=nil
		PointRows[i].State.Text=saved and "SAVED" or "EMPTY"
		PointRows[i].State.TextColor3=saved and GREEN or DARK_GRAY
		PointRows[i].Save.Text="SAVE"
	end
end

local function StartRGBGlow()
	if RGBConnection then
		RGBConnection:Disconnect()
		RGBConnection=nil
	end

	RGBConnection=RunService.RenderStepped:Connect(function()
		if not RGBGlowEnabled then
			return
		end

		local wave=(math.sin(os.clock()*2.4)+1)*0.5
		local color=Color3.fromHSV(
			0.075+wave*0.065,
			0.78,
			1
		)

		for _,stroke in ipairs(RGBStrokes) do
			if stroke and stroke.Parent then
				stroke.Color=color
			end
		end
	end)
end

local function StopRGBGlow()
	if RGBConnection then
		RGBConnection:Disconnect()
		RGBConnection=nil
	end

	for _,stroke in ipairs(RGBStrokes) do
		if stroke and stroke.Parent then
			stroke.Color=YELLOW
		end
	end
end

RGBStrokes={
	OpenStroke,
	FrameStroke,
	BananaIconStroke,
	SettingsFrameStroke,
	RGBButtonStroke
}

RGBButton.MouseButton1Click:Connect(function()
	RGBGlowEnabled=not RGBGlowEnabled

	if RGBGlowEnabled then
		StartRGBGlow()
	else
		StopRGBGlow()
	end

	UpdateButtons()
end)

local function CreateESP(char)
	if not char or char==Player.Character then
		return
	end

	local head=char:FindFirstChild("Head")
	local hum=char:FindFirstChildOfClass("Humanoid")

	if not head or not hum then
		return
	end

	local Highlight=char:FindFirstChild("BananaESP")

	if not Highlight then
		Highlight=Instance.new("Highlight")
		Highlight.Name="BananaESP"
		Highlight.FillTransparency=0.45
		Highlight.OutlineTransparency=0
		Highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
		Highlight.Parent=char
	end

	Highlight.FillColor=ESPColor
	Highlight.OutlineColor=WHITE
	Highlight.Enabled=ESPEnabled

	local Gui=char:FindFirstChild("BananaESPInfo")

	if not Gui then
		Gui=Instance.new("BillboardGui")
		Gui.Name="BananaESPInfo"
		Gui.Size=UDim2.new(0,190,0,76)
		Gui.StudsOffset=Vector3.new(0,3,0)
		Gui.AlwaysOnTop=true
		Gui.Adornee=head
		Gui.Parent=char

		local Frame=Instance.new("Frame")
		Frame.Name="Frame"
		Frame.Size=UDim2.new(1,0,1,0)
		Frame.BackgroundTransparency=1
		Frame.Parent=Gui

		local Name=Instance.new("TextLabel")
		Name.Name="PlayerName"
		Name.Size=UDim2.new(1,0,0,22)
		Name.BackgroundTransparency=1
		Name.TextSize=12
		Name.Font=Enum.Font.GothamBold
		Name.TextColor3=ESPColor
		Name.TextStrokeTransparency=0.3
		Name.Parent=Frame

		local Distance=Name:Clone()
		Distance.Name="Distance"
		Distance.Position=UDim2.new(0,0,0,20)
		Distance.TextSize=10
		Distance.Parent=Frame

		local BarBG=Instance.new("Frame")
		BarBG.Name="HealthBG"
		BarBG.Size=UDim2.new(0,140,0,7)
		BarBG.Position=UDim2.new(0.5,-70,0,44)
		BarBG.BackgroundColor3=Color3.fromRGB(35,35,35)
		BarBG.BorderSizePixel=0
		BarBG.Parent=Frame
		AddCorner(BarBG,6)

		local Bar=Instance.new("Frame")
		Bar.Name="Health"
		Bar.Size=UDim2.new(1,0,1,0)
		Bar.BackgroundColor3=GREEN
		Bar.BorderSizePixel=0
		Bar.Parent=BarBG
		AddCorner(Bar,6)
	end

	Gui.Enabled=ESPEnabled

	local F=Gui.Frame
	F.PlayerName.Text=char.Name
	F.PlayerName.TextColor3=ESPColor
	F.Distance.TextColor3=ESPColor
	F.HealthBG.Visible=ESPHealth

	return Gui,Highlight
end

local function UpdateESP()
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=Player and p.Character then
			local Gui,Highlight=CreateESP(p.Character)

			if Gui and Highlight then
				Highlight.Enabled=ESPEnabled
				Highlight.FillColor=ESPColor
				Highlight.OutlineColor=WHITE

				Gui.Enabled=
					ESPEnabled
					and (ESPName or ESPDistance or ESPHealth)

				Gui.Frame.PlayerName.Visible=ESPName
				Gui.Frame.Distance.Visible=ESPDistance
				Gui.Frame.HealthBG.Visible=ESPHealth
			end
		end
	end
end

local function CycleESPColor()
	for i,v in ipairs(ESPColors) do
		if v[1]==ESPColorName then
			local n=ESPColors[i%#ESPColors+1]
			ESPColorName=n[1]
			ESPColor=n[2]
			break
		end
	end

	UpdateESP()
	UpdateButtons()
end

ESPButton.MouseButton1Click:Connect(function()
	ESPEnabled=not ESPEnabled
	UpdateESP()
	UpdateButtons()
end)

ESPColorButton.MouseButton1Click:Connect(CycleESPColor)

ESPDistanceButton.MouseButton1Click:Connect(function()
	ESPDistance=not ESPDistance
	UpdateESP()
	UpdateButtons()
end)

ESPNameButton.MouseButton1Click:Connect(function()
	ESPName=not ESPName
	UpdateESP()
	UpdateButtons()
end)

ESPHealthButton.MouseButton1Click:Connect(function()
	ESPHealth=not ESPHealth
	UpdateESP()
	UpdateButtons()
end)

local function RefreshPlayerList()
	for _,row in pairs(PlayerRows) do
		row:Destroy()
	end

	PlayerRows={}

	local players={}

	for _,p in ipairs(Players:GetPlayers()) do
		if p~=Player then
			table.insert(players,p)
		end
	end

	table.sort(
		players,
		function(a,b)
			return a.Name:lower()<b.Name:lower()
		end
	)

	for i,p in ipairs(players) do
		local Row=Instance.new("TextButton")
		Row.Size=UDim2.new(1,-8,0,34)
		Row.Position=UDim2.new(0,4,0,(i-1)*37)
		Row.BackgroundColor3=
			p.Name==SelectedPlayer
			and CARD_ACTIVE
			or CARD

		Row.Text=""
		Row.AutoButtonColor=false
		Row.Parent=PlayerListFrame
		AddCorner(Row,8)

		local Name=Instance.new("TextLabel")
		Name.Size=UDim2.new(1,-90,1,0)
		Name.Position=UDim2.new(0,9,0,0)
		Name.BackgroundTransparency=1
		Name.Text=p.DisplayName.."  @"..p.Name
		Name.TextColor3=
			p.Name==SelectedPlayer
			and YELLOW_LIGHT
			or WHITE
		Name.TextSize=10
		Name.Font=Enum.Font.GothamBold
		Name.TextXAlignment=Enum.TextXAlignment.Left
		Name.TextTruncate=Enum.TextTruncate.AtEnd
		Name.Parent=Row

		local State=Instance.new("TextLabel")
		State.Size=UDim2.new(0,74,1,0)
		State.Position=UDim2.new(1,-80,0,0)
		State.BackgroundTransparency=1
		State.Text=
			p.Name==SelectedPlayer
			and "SELECTED"
			or "IN GAME"

		State.TextColor3=
			p.Name==SelectedPlayer
			and YELLOW_LIGHT
			or GREEN

		State.TextSize=8
		State.Font=Enum.Font.GothamBold
		State.TextXAlignment=Enum.TextXAlignment.Right
		State.Parent=Row

		Row.MouseButton1Click:Connect(function()
			SelectedPlayer=p.Name
			RefreshPlayerList()
			UpdateButtons()
		end)

		PlayerRows[p.Name]=Row
	end

	PlayerListFrame.CanvasSize=
		UDim2.new(
			0,
			0,
			0,
			math.max(#players*37,170)
		)

	if SelectedPlayer
		and not Players:FindFirstChild(SelectedPlayer) then
		SelectedPlayer=nil
	end
end

RefreshPlayersButton.MouseButton1Click:Connect(
	RefreshPlayerList
)

TPToPlayerButton.MouseButton1Click:Connect(function()
	if not RootPart
		or not SelectedPlayer
		or AFKEnabled then
		return
	end

	local Target=Players:FindFirstChild(SelectedPlayer)
	local TargetRoot=
		Target
		and Target.Character
		and Target.Character:FindFirstChild("HumanoidRootPart")

	if not TargetRoot then
		return
	end

	local CFrame=
		TargetRoot.CFrame
		+ Vector3.new(0,TeleportOffset,0)

	if ResetVelocityOnTeleport then
		RootPart.AssemblyLinearVelocity=Vector3.zero
		RootPart.AssemblyAngularVelocity=Vector3.zero
	end

	Character:PivotTo(CFrame)
	RootPart.CFrame=CFrame

	if ResetVelocityOnTeleport then
		RootPart.AssemblyLinearVelocity=Vector3.zero
		RootPart.AssemblyAngularVelocity=Vector3.zero
	end
end)

local function SaveTeleportPoint(index)
	if not Character
		or not RootPart
		or AFKEnabled then
		return false
	end

	TeleportPoints[index]=RootPart.CFrame
	return true
end

local function TeleportToPoint(index)
	if not Character
		or not RootPart
		or not TeleportPoints[index]
		or AFKEnabled then
		return
	end

	local PointCFrame=TeleportPoints[index]

	if ResetVelocityOnTeleport then
		RootPart.AssemblyLinearVelocity=Vector3.zero
		RootPart.AssemblyAngularVelocity=Vector3.zero
	end

	pcall(function()
		Character:PivotTo(PointCFrame)
	end)

	if RootPart and RootPart.Parent then
		RootPart.CFrame=PointCFrame

		if ResetVelocityOnTeleport then
			RootPart.AssemblyLinearVelocity=Vector3.zero
			RootPart.AssemblyAngularVelocity=Vector3.zero
		end
	end
end

for i=1,5 do
	local Index=i

	PointRows[i].Save.MouseButton1Click:Connect(function()
		if SaveTeleportPoint(Index) then
			PointRows[Index].State.Text="SAVED"
			PointRows[Index].State.TextColor3=GREEN
			PointRows[Index].Save.Text="✅ SAVED"

			task.delay(1,function()
				if PointRows[Index].Save.Parent then
					PointRows[Index].Save.Text="SAVE"
				end
			end)
		end
	end)

	PointRows[i].Delete.MouseButton1Click:Connect(function()
		TeleportPoints[Index]=nil
		PointRows[Index].State.Text="EMPTY"
		PointRows[Index].State.TextColor3=DARK_GRAY
		PointRows[Index].Save.Text="SAVE"
	end)

	PointRows[i].TP.MouseButton1Click:Connect(function()
		TeleportToPoint(Index)
	end)
end

Players.PlayerRemoving:Connect(function(p)
	if p.Name==SelectedPlayer then
		SelectedPlayer=nil
	end

	RefreshPlayerList()
	UpdateESP()
	UpdateButtons()
end)

Players.PlayerAdded:Connect(function(p)
	p.CharacterAdded:Connect(function(char)
		task.wait(0.4)
		CreateESP(char)
		RefreshPlayerList()
	end)

	RefreshPlayerList()
end)

DistanceBox.FocusLost:Connect(function()
	local N=tonumber(DistanceBox.Text)

	if N then
		TeleportDistance=math.clamp(N,1,1000)
	end

	DistanceBox.Text=tostring(TeleportDistance)
end)

TeleportButton.MouseButton1Click:Connect(function()
	TeleportEnabled=not TeleportEnabled
	UpdateButtons()
end)

TPButton.MouseButton1Click:Connect(function()
	if TeleportEnabled
		and RootPart
		and not AFKEnabled then

		RootPart.CFrame+=
			RootPart.CFrame.LookVector
			*TeleportDistance
	end
end)

TPOffsetBox.FocusLost:Connect(function()
	local N=tonumber(TPOffsetBox.Text)

	if N then
		TeleportOffset=math.clamp(N,0,50)
	end

	TPOffsetBox.Text=tostring(TeleportOffset)
end)

ResetVelocityButton.MouseButton1Click:Connect(function()
	ResetVelocityOnTeleport=not ResetVelocityOnTeleport
	UpdateButtons()
end)

SpeedBox.FocusLost:Connect(function()
	local N=tonumber(SpeedBox.Text)

	if N then
		WalkSpeed=math.clamp(N,1,400)
	end

	SpeedBox.Text=tostring(WalkSpeed)

	if SpeedEnabled and Humanoid then
		Humanoid.WalkSpeed=WalkSpeed
	end
end)

SpeedButton.MouseButton1Click:Connect(function()
	SpeedEnabled=not SpeedEnabled

	if Humanoid then
		Humanoid.WalkSpeed=
			SpeedEnabled
			and WalkSpeed
			or 16
	end

	UpdateButtons()
end)

local function ApplyPhysics()
	workspace.Gravity=GravityValue

	if Humanoid then
		Humanoid.UseJumpPower=true
		Humanoid.JumpPower=JumpPowerValue
	end
end

GravityBox.FocusLost:Connect(function()
	local N=tonumber(GravityBox.Text)

	if N then
		GravityValue=math.clamp(N,0,1000)
	end

	GravityBox.Text=tostring(GravityValue)
	ApplyPhysics()
end)

JumpPowerBox.FocusLost:Connect(function()
	local N=tonumber(JumpPowerBox.Text)

	if N then
		JumpPowerValue=math.clamp(N,0,500)
	end

	JumpPowerBox.Text=tostring(JumpPowerValue)
	ApplyPhysics()
end)

ResetPhysicsButton.MouseButton1Click:Connect(function()
	GravityValue=DefaultGravity
	JumpPowerValue=DefaultJumpPower
	GravityBox.Text=tostring(GravityValue)
	JumpPowerBox.Text=tostring(JumpPowerValue)
	ApplyPhysics()
end)

WallhackButton.MouseButton1Click:Connect(function()
	WallhackEnabled=not WallhackEnabled
	UpdateButtons()
end)

FlyBox.FocusLost:Connect(function()
	local N=tonumber(FlyBox.Text)

	if N then
		FlySpeed=math.clamp(N,1,400)
	end

	FlyBox.Text=tostring(FlySpeed)
end)

local function StopFly()
	if FlyConnection then
		FlyConnection:Disconnect()
		FlyConnection=nil
	end

	if FlyVelocity then
		FlyVelocity:Destroy()
		FlyVelocity=nil
	end

	if FlyOrientation then
		FlyOrientation:Destroy()
		FlyOrientation=nil
	end

	if FlyAttachment then
		FlyAttachment:Destroy()
		FlyAttachment=nil
	end

	if Humanoid then
		Humanoid.PlatformStand=false
		Humanoid.AutoRotate=true
	end

	if RootPart then
		RootPart.AssemblyLinearVelocity=Vector3.zero
		RootPart.AssemblyAngularVelocity=Vector3.zero
	end
end

local function StartFly()
	StopFly()

	if not Humanoid or not RootPart then
		return
	end

	Humanoid.PlatformStand=true
	Humanoid.AutoRotate=false

	FlyAttachment=Instance.new("Attachment")
	FlyAttachment.Name="BananaFlyAttachment"
	FlyAttachment.Parent=RootPart

	FlyVelocity=Instance.new("LinearVelocity")
	FlyVelocity.Name="BananaFlyVelocity"
	FlyVelocity.Attachment0=FlyAttachment
	FlyVelocity.RelativeTo=Enum.ActuatorRelativeTo.World
	FlyVelocity.MaxForce=math.huge
	FlyVelocity.VectorVelocity=Vector3.zero
	FlyVelocity.Parent=RootPart

	FlyOrientation=Instance.new("AlignOrientation")
	FlyOrientation.Name="BananaFlyOrientation"
	FlyOrientation.Mode=
		Enum.OrientationAlignmentMode.OneAttachment
	FlyOrientation.Attachment0=FlyAttachment
	FlyOrientation.MaxTorque=math.huge
	FlyOrientation.Responsiveness=15
	FlyOrientation.RigidityEnabled=false
	FlyOrientation.Parent=RootPart

	FlyConnection=RunService.RenderStepped:Connect(function()
		if not FlyEnabled
			or not RootPart
			or not FlyVelocity then
			return
		end

		local Camera=workspace.CurrentCamera

		if not Camera then
			return
		end

		local Forward=Camera.CFrame.LookVector
		local Right=Camera.CFrame.RightVector
		local Direction=Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then
			Direction+=Forward
		end

		if UIS:IsKeyDown(Enum.KeyCode.S) then
			Direction-=Forward
		end

		if UIS:IsKeyDown(Enum.KeyCode.D) then
			Direction+=Right
		end

		if UIS:IsKeyDown(Enum.KeyCode.A) then
			Direction-=Right
		end

		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			Direction+=Vector3.new(0,1,0)
		end

		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
			Direction-=Vector3.new(0,1,0)
		end

		if Direction.Magnitude>0 then
			Direction=
				Direction.Unit
				*FlySpeed
		end

		FlyVelocity.VectorVelocity=Direction

		local Look=Camera.CFrame.LookVector

		FlyOrientation.CFrame=
			CFrame.lookAt(
				Vector3.zero,
				Look
			)
	end)
end

FlyButton.MouseButton1Click:Connect(function()
	FlyEnabled=not FlyEnabled

	if FlyEnabled and not AFKEnabled then
		StartFly()
	else
		FlyEnabled=false
		StopFly()
	end

	UpdateButtons()
end)

AFKButton.MouseButton1Click:Connect(function()
	AFKEnabled=not AFKEnabled

	if AFKEnabled then
		if FlyEnabled then
			FlyEnabled=false
			StopFly()
		end

		if Humanoid then
			Humanoid.WalkSpeed=0
			Humanoid.AutoRotate=false
			Humanoid.PlatformStand=true
		end

		if Character then
			for _,Part in ipairs(Character:GetDescendants()) do
				if Part:IsA("BasePart") then
					Part.CanCollide=false
				end
			end
		end

		if RootPart then
			RootPart.Anchored=true
		end
	else
		if RootPart then
			RootPart.Anchored=false
		end

		if Humanoid then
			Humanoid.PlatformStand=false
			Humanoid.AutoRotate=true
			Humanoid.WalkSpeed=
				SpeedEnabled
				and WalkSpeed
				or 16
		end
	end

	UpdateButtons()
end)

local DANCE_ID="182436842"

local function StopDance()
	if DanceTrack then
		pcall(function()
			DanceTrack:Stop(0.15)
		end)

		pcall(function()
			DanceTrack:Destroy()
		end)

		DanceTrack=nil
	end
end

local function StartDance()
	StopDance()

	if not Humanoid then
		return
	end

	if Humanoid.RigType~=
		Enum.HumanoidRigType.R6 then
		return
	end

	local Animator=
		Humanoid:FindFirstChildOfClass("Animator")

	if not Animator then
		Animator=Instance.new("Animator")
		Animator.Parent=Humanoid
	end

	local Animation=Instance.new("Animation")
	Animation.AnimationId="rbxassetid://"..DANCE_ID

	local Success,Track=pcall(function()
		return Animator:LoadAnimation(Animation)
	end)

	Animation:Destroy()

	if not Success or not Track then
		return
	end

	Track.Priority=Enum.AnimationPriority.Action
	Track.Looped=true
	Track:Play(0.15)
	DanceTrack=Track
end

local function ToggleDance()
	if not Humanoid then
		return
	end

	if Humanoid.RigType~=
		Enum.HumanoidRigType.R6 then
		DanceEnabled=false
		UpdateButtons()
		return
	end

	DanceEnabled=not DanceEnabled

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

local function ForceMouseUnlock()
	pcall(function()
		UIS.MouseBehavior=Enum.MouseBehavior.Default
	end)

	pcall(function()
		UIS.MouseIconEnabled=true
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
		UIS.MouseBehavior=Enum.MouseBehavior.Default
	end)

	pcall(function()
		UIS.MouseIconEnabled=true
	end)
end

MouseUnlockButton.MouseButton1Click:Connect(function()
	MouseUnlockEnabled=not MouseUnlockEnabled

	if MouseUnlockEnabled then
		EnableMouseUnlock()
	else
		DisableMouseUnlock()
	end

	UpdateButtons()
end)

SettingsButton.MouseButton1Click:Connect(function()
	SettingsFrame.Visible=true
end)

SettingsClose.MouseButton1Click:Connect(function()
	SettingsFrame.Visible=false
end)

CopyLinkButton.MouseEnter:Connect(function()
	Tween(
		CopyLinkButton,
		{BackgroundColor3=CARD_HOVER},
		0.12
	):Play()
end)

CopyLinkButton.MouseLeave:Connect(function()
	Tween(
		CopyLinkButton,
		{BackgroundColor3=CARD},
		0.12
	):Play()
end)

CopyLinkButton.MouseButton1Click:Connect(function()
	local Success=false

	pcall(function()
		if typeof(setclipboard)=="function" then
			setclipboard("chatgpt.com")
			Success=true
		elseif typeof(toclipboard)=="function" then
			toclipboard("chatgpt.com")
			Success=true
		end
	end)

	if Success then
		CopyLinkButton.Text="✅  COPIED!"

		task.delay(1.2,function()
			if CopyLinkButton
				and CopyLinkButton.Parent then
				CopyLinkButton.Text="📋  COPY LINK"
			end
		end)
	else
		CopyLinkButton.Text="❌  COPY UNAVAILABLE"

		task.delay(1.5,function()
			if CopyLinkButton
				and CopyLinkButton.Parent then
				CopyLinkButton.Text="📋  COPY LINK"
			end
		end)
	end
end)

local MainDragging=false
local MainDragStart
local MainStartPosition

local MainDragArea=Instance.new("Frame")
MainDragArea.Size=UDim2.new(1,-150,0,95)
MainDragArea.Position=UDim2.new(0,0,0,0)
MainDragArea.BackgroundTransparency=1
MainDragArea.Active=true
MainDragArea.Parent=Header

MainDragArea.InputBegan:Connect(function(Input)
	if Input.UserInputType==
		Enum.UserInputType.MouseButton1 then

		MainDragging=true
		MainDragStart=Input.Position
		MainStartPosition=Frame.Position
	end
end)

UIS.InputChanged:Connect(function(Input)
	if MainDragging
		and Input.UserInputType==
			Enum.UserInputType.MouseMovement then

		local Delta=
			Input.Position
			-MainDragStart

		Frame.Position=
			UDim2.new(
				MainStartPosition.X.Scale,
				MainStartPosition.X.Offset+Delta.X,
				MainStartPosition.Y.Scale,
				MainStartPosition.Y.Offset+Delta.Y
			)
	end
end)

UIS.InputEnded:Connect(function(Input)
	if Input.UserInputType==
		Enum.UserInputType.MouseButton1 then
		MainDragging=false
	end
end)

local SettingsDragging=false
local SettingsDragStart
local SettingsStartPosition

SettingsDragBar.InputBegan:Connect(function(Input)
	if Input.UserInputType==
		Enum.UserInputType.MouseButton1 then

		SettingsDragging=true
		SettingsDragStart=Input.Position
		SettingsStartPosition=SettingsFrame.Position
	end
end)

UIS.InputChanged:Connect(function(Input)
	if SettingsDragging
		and Input.UserInputType==
			Enum.UserInputType.MouseMovement then

		local Delta=
			Input.Position
			-SettingsDragStart

		SettingsFrame.Position=
			UDim2.new(
				SettingsStartPosition.X.Scale,
				SettingsStartPosition.X.Offset+Delta.X,
				SettingsStartPosition.Y.Scale,
				SettingsStartPosition.Y.Offset+Delta.Y
			)
	end
end)

UIS.InputEnded:Connect(function(Input)
	if Input.UserInputType==
		Enum.UserInputType.MouseButton1 then
		SettingsDragging=false
	end
end)

local OpenDragging=false
local OpenDragMoved=false
local OpenDragStart
local OpenStartPosition
local DRAG_THRESHOLD=7

OpenButton.InputBegan:Connect(function(Input)
	if Input.UserInputType==
		Enum.UserInputType.MouseButton1 then

		OpenDragging=true
		OpenDragMoved=false
		OpenDragStart=Input.Position
		OpenStartPosition=OpenButton.Position
	end
end)

UIS.InputChanged:Connect(function(Input)
	if OpenDragging
		and Input.UserInputType==
			Enum.UserInputType.MouseMovement then

		local Delta=
			Input.Position
			-OpenDragStart

		if Delta.Magnitude>=DRAG_THRESHOLD then
			OpenDragMoved=true
		end

		OpenButton.Position=
			UDim2.new(
				OpenStartPosition.X.Scale,
				OpenStartPosition.X.Offset+Delta.X,
				OpenStartPosition.Y.Scale,
				OpenStartPosition.Y.Offset+Delta.Y
			)
	end
end)

UIS.InputEnded:Connect(function(Input)
	if Input.UserInputType==
		Enum.UserInputType.MouseButton1
		and OpenDragging then

		OpenDragging=false

		if not OpenDragMoved then
			Frame.Visible=true
			OpenButton.Visible=false
		end

		OpenDragMoved=false
	end
end)

CloseButton.MouseButton1Click:Connect(function()
	Frame.Visible=false
	OpenButton.Visible=true
end)

DanceKeyButton.MouseButton1Click:Connect(function()
	ChoosingDanceKey=true
	DanceKeyButton.Text="PRESS KEY"
end)

MouseKeyButton.MouseButton1Click:Connect(function()
	SelectingMouseKey=true
	MouseKeyButton.Text="PRESS KEY"
end)

UIS.InputBegan:Connect(function(Input,GameProcessed)
	if ChoosingDanceKey then
		if Input.UserInputType==
			Enum.UserInputType.Keyboard then

			DanceHotkey=Input.KeyCode
			ChoosingDanceKey=false
			DanceKeyButton.Text=DanceHotkey.Name
			return
		end
	end

	if SelectingMouseKey then
		if Input.UserInputType==
			Enum.UserInputType.Keyboard then

			MouseUnlockKey=Input.KeyCode
			SelectingMouseKey=false
			MouseKeyButton.Text=MouseUnlockKey.Name
			return
		end
	end

	if Input.UserInputType==
		Enum.UserInputType.Keyboard
		and Input.KeyCode==MouseUnlockKey then

		MouseUnlockEnabled=not MouseUnlockEnabled

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

	if Input.UserInputType==
		Enum.UserInputType.Keyboard
		and Input.KeyCode==DanceHotkey then

		ToggleDance()
		return
	end
end)

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

	if MouseUnlockEnabled then
		EnableMouseUnlock()
	end

	UpdateESP()
	UpdateButtons()
end)

local ESPUpdateClock=0

RunService.Heartbeat:Connect(function(dt)
	if SpeedEnabled
		and Humanoid
		and not AFKEnabled
		and Humanoid.WalkSpeed~=WalkSpeed then

		Humanoid.WalkSpeed=WalkSpeed
	end

	if WallhackEnabled
		and Character
		and not AFKEnabled then

		for _,Part in ipairs(Character:GetDescendants()) do
			if Part:IsA("BasePart") then
				Part.CanCollide=false
			end
		end
	end

	if AFKEnabled and RootPart then
		RootPart.Anchored=true
		RootPart.AssemblyLinearVelocity=Vector3.zero
		RootPart.AssemblyAngularVelocity=Vector3.zero
	end

	ESPUpdateClock+=dt

	if ESPUpdateClock>=0.1 then
		ESPUpdateClock=0

		for _,p in ipairs(Players:GetPlayers()) do
			if p~=Player and p.Character then
				local Gui,Highlight=CreateESP(p.Character)
				local head=p.Character:FindFirstChild("Head")
				local hum=p.Character:FindFirstChildOfClass("Humanoid")

				if Gui and Highlight and head and hum then
					Highlight.Enabled=ESPEnabled
					Highlight.FillColor=ESPColor

					Gui.Enabled=
						ESPEnabled
						and (ESPName or ESPDistance or ESPHealth)

					Gui.Frame.PlayerName.Visible=ESPName
					Gui.Frame.Distance.Visible=ESPDistance
					Gui.Frame.HealthBG.Visible=ESPHealth

					Gui.Frame.PlayerName.Text=
						p.DisplayName.."  @"..p.Name

					if RootPart then
						Gui.Frame.Distance.Text=
							math.floor(
								(RootPart.Position-head.Position).Magnitude
							).." studs"
					end

					Gui.Frame.Health.Size=
						UDim2.new(
							math.clamp(
								hum.MaxHealth>0
								and hum.Health/hum.MaxHealth
								or 0,
								0,
								1
							),
							0,
							1,
							0
						)
				end
			end
		end
	end
end)

SetTPTab("FORWARD")
SetTab("BANANA")
RefreshPlayerList()
UpdateButtons()
UpdateESP()

print("🍌 Banana Script v2 + Banana RGB Glow loaded successfully!")
