-- LocalScript
-- ใส่ใน StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local speed = 16
local infiniteJump = false
local noclip = false
local flying = false
local flySpeed = 50

-- Lock / FOV
local fovLock = false
local fovSize = 120
local lockedPlayer = nil
local lockConnection = nil

-- =========================
-- GUI
-- =========================

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControlUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 320)
frame.Position = UDim2.new(0.5, -170, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 14)
frameCorner.Parent = frame

-- =========================
-- Header
-- =========================

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -50, 0, 42)
header.Position = UDim2.new(0, 45, 0, 0)
header.BackgroundTransparency = 1
header.Text = "Player Control"
header.TextColor3 = Color3.fromRGB(255,255,255)
header.TextSize = 19
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = frame

-- =========================
-- Close
-- =========================

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 32, 0, 32)
close.Position = UDim2.new(0, 8, 0, 5)
close.BackgroundColor3 = Color3.fromRGB(255,70,70)
close.Text = "×"
close.TextColor3 = Color3.fromRGB(255,255,255)
close.TextSize = 23
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Parent = frame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0,8)
closeCorner.Parent = close

-- =========================
-- Helpers
-- =========================

local function createRow(text, y, width)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, width or 160, 0, 38)
	label.Position = UDim2.new(0, 15, 0, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(235,235,235)
	label.TextSize = 16
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	return label
end

local function getHumanoid()
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function createToggle(x, y, width, offText, onText, callback)

	local button = Instance.new("TextButton")

	button.Size = UDim2.new(0, width, 0, 34)
	button.Position = UDim2.new(1, x, 0, y)

	button.BackgroundColor3 = Color3.fromRGB(55,55,65)
	button.Text = offText
	button.TextColor3 = Color3.fromRGB(255,255,255)
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold
	button.BorderSizePixel = 0
	button.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,9)
	corner.Parent = button

	local enabled = false

	button.MouseButton1Click:Connect(function()

		enabled = not enabled

		if enabled then
			button.Text = onText
			button.BackgroundColor3 = Color3.fromRGB(255,140,0)
		else
			button.Text = offText
			button.BackgroundColor3 = Color3.fromRGB(55,55,65)
		end

		if callback then
			callback(enabled)
		end

	end)

	return button
end

local function createSpeedBox(x, y, width, defaultValue, callback)

	local box = Instance.new("TextBox")

	box.Size = UDim2.new(0, width, 0, 34)
	box.Position = UDim2.new(1, x, 0, y)

	box.BackgroundColor3 = Color3.fromRGB(50,50,60)
	box.Text = tostring(defaultValue)
	box.TextColor3 = Color3.fromRGB(255,255,255)
	box.TextSize = 16
	box.Font = Enum.Font.GothamBold
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Parent = frame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,9)
	corner.Parent = box

	box.FocusLost:Connect(function()
		callback(box)
	end)

	return box
end

-- =========================
-- ความเร็ว
-- =========================

createRow("ความเร็ว", 50)

createSpeedBox(-105, 52, 90, speed, function(box)

	local value = tonumber(box.Text)

	if value then

		speed = math.clamp(math.floor(value), 1, 100)

		box.Text = tostring(speed)

		local humanoid = getHumanoid()

		if humanoid then
			humanoid.WalkSpeed = speed
		end

	else

		box.Text = tostring(speed)

	end

end)

-- =========================
-- บิน
-- =========================

createRow("บิน", 92, 100)

local flyKeys = {
	Up = false,
	Down = false
}

local flyConnection = nil

local function setPlatformStand(state)

	local humanoid = getHumanoid()

	if humanoid then
		humanoid.PlatformStand = state
	end

end

local function setRootAnchored(state)

	local character = player.Character

	local root =
		character
		and character:FindFirstChild("HumanoidRootPart")

	if root then
		root.Anchored = state
	end

end

local function startFly()

	setPlatformStand(true)
	setRootAnchored(true)

	flyConnection = RunService.RenderStepped:Connect(function(dt)

		local character = player.Character

		local humanoid =
			character
			and character:FindFirstChildOfClass("Humanoid")

		local root =
			character
			and character:FindFirstChild("HumanoidRootPart")

		if not humanoid or not root then
			return
		end

		local camera = workspace.CurrentCamera

		if not camera then
			return
		end

		local moveDir = humanoid.MoveDirection

		local forward = Vector3.new(
			camera.CFrame.LookVector.X,
			0,
			camera.CFrame.LookVector.Z
		)

		local right = Vector3.new(
			camera.CFrame.RightVector.X,
			0,
			camera.CFrame.RightVector.Z
		)

		if forward.Magnitude > 0 then
			forward = forward.Unit
		end

		if right.Magnitude > 0 then
			right = right.Unit
		end

		local forwardAmount = moveDir:Dot(forward)
		local rightAmount = moveDir:Dot(right)

		local movement =
			camera.CFrame.LookVector * forwardAmount
			+ camera.CFrame.RightVector * rightAmount

		if flyKeys.Up then
			movement += Vector3.new(0,1,0)
		end

		if flyKeys.Down then
			movement -= Vector3.new(0,1,0)
		end

		if movement.Magnitude > 0 then

			root.CFrame =
				CFrame.new(
					root.Position + movement.Unit * flySpeed * dt,
					root.Position + movement.Unit
				)

		end

	end)

end

local function stopFly()

	if flyConnection then

		flyConnection:Disconnect()
		flyConnection = nil

	end

	setRootAnchored(false)
	setPlatformStand(false)

end

createSpeedBox(-195, 94, 80, flySpeed, function(box)

	local value = tonumber(box.Text)

	if value then

		flySpeed =
			math.clamp(
				math.floor(value),
				1,
				300
			)

		box.Text = tostring(flySpeed)

	else

		box.Text = tostring(flySpeed)

	end

end)

createToggle(
	-105,
	94,
	90,
	"ปิด",
	"เปิด",
	function(enabled)

		flying = enabled

		if flying then
			startFly()
		else
			stopFly()
		end

	end
)

UserInputService.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Space then

		flyKeys.Up = true

	elseif input.KeyCode == Enum.KeyCode.LeftShift
		or input.KeyCode == Enum.KeyCode.RightShift then

		flyKeys.Down = true

	end

end)

UserInputService.InputEnded:
