-- LocalScript
-- ใส่ใน StarterPlayer > StarterPlayerScripts
-- ใช้ในแผนที่/เกมของคุณเองเท่านั้น (เช่น ทดสอบระบบ หรือทำเป็น admin panel)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- =========================
-- SETTINGS
-- =========================

local settings = {
	walkSpeed = 16,
	flySpeed = 50,
	infiniteJump = false,
	noclip = false,
	flying = false,
	fovLock = false,
	fovSize = 120,
	aimSmoothness = 0.2, -- 0.05 = ล็อคไว / 0.5+ = นุ่มนวล
}

local flyUp = false
local flyDown = false
local flyConnection = nil
local noclipConnection = nil
local lockConnection = nil
local lockedPlayer = nil

local VIS_CHECK_INTERVAL = 0.1 -- วินาที ระหว่างเช็คกำแพง

-- =========================
-- CHARACTER HELPERS
-- =========================

local function getCharacter()
	return player.Character
end

local function getHumanoid()
	local character = getCharacter()
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
	local character = getCharacter()
	return character and character:FindFirstChild("HumanoidRootPart")
end

-- =========================
-- GUI
-- =========================

local gui = Instance.new("ScreenGui")
gui.Name = "PlayerControlUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(340, 320)
frame.Position = UDim2.new(0.5, -170, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1
frameStroke.Transparency = 0.5
frameStroke.Color = Color3.fromRGB(70, 70, 85)
frameStroke.Parent = frame

-- =========================
-- HEADER
-- =========================

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -55, 0, 42)
header.Position = UDim2.fromOffset(45, 0)
header.BackgroundTransparency = 1
header.Text = "Player Control"
header.TextColor3 = Color3.new(1, 1, 1)
header.TextSize = 19
header.Font = Enum.Font.GothamBold
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(32, 32)
close.Position = UDim2.fromOffset(8, 5)
close.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
close.Text = "×"
close.TextColor3 = Color3.new(1, 1, 1)
close.TextSize = 23
close.Font = Enum.Font.GothamBold
close.BorderSizePixel = 0
close.Parent = frame
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

-- =========================
-- UI HELPERS
-- =========================

local function createRow(text, y)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(170, 38)
	label.Position = UDim2.fromOffset(15, y)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(235, 235, 235)
	label.TextSize = 16
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame
end

local function createNumberBox(x, y, width, value, min, max, onChanged)
	local box = Instance.new("TextBox")
	box.Size = UDim2.fromOffset(width, 34)
	box.Position = UDim2.new(1, x, 0, y)
	box.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	box.Text = tostring(value)
	box.TextColor3 = Color3.new(1, 1, 1)
	box.TextSize = 16
	box.Font = Enum.Font.GothamBold
	box.BorderSizePixel = 0
	box.ClearTextOnFocus = false
	box.Parent = frame
	Instance.new("UICorner", box).CornerRadius = UDim.new(0, 9)

	local current = value

	box.FocusLost:Connect(function()
		local n = tonumber(box.Text)
		if n then
			current = math.clamp(math.floor(n + 0.5), min, max)
			box.Text = tostring(current)
			onChanged(current)
		else
			box.Text = tostring(current)
		end
	end)

	return box
end

local OFF_COLOR = Color3.fromRGB(55, 55, 65)
local ON_COLOR = Color3.fromRGB(255, 140, 0)

local function createToggle(x, y, width, offText, onText, onChanged)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(width, 34)
	button.Position = UDim2.new(1, x, 0, y)
	button.BorderSizePixel = 0
	button.TextSize = 14
	button.Font = Enum.Font.GothamBold
	button.Parent = frame
	Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)

	local enabled = false

	local function setState(state)
		enabled = state
		button.Text = state and onText or offText
		button.BackgroundColor3 = state and ON_COLOR or OFF_COLOR
	end

	button.MouseButton1Click:Connect(function()
		setState(not enabled)
		onChanged(enabled)
	end)

	setState(false)

	return setState
end

-- =========================
-- SPEED
-- =========================

createRow("ความเร็ว", 50)

createNumberBox(-105, 52, 90, settings.walkSpeed, 1, 100, function(value)
	settings.walkSpeed = value
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.WalkSpeed = value
	end
end)

-- =========================
-- FLY
-- =========================

createRow("บิน", 92)

createNumberBox(-195, 94, 80, settings.flySpeed, 1, 300, function(value)
	settings.flySpeed = value
end)

local function stopFly()
	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end
	local humanoid = getHumanoid()
	local root = getRoot()
	if humanoid then
		humanoid.PlatformStand = false
	end
	if root then
		root.Anchored = false
	end
end

local function startFly()
	stopFly() -- กันซ้ำซ้อน

	local humanoid = getHumanoid()
	local root = getRoot()
	if not humanoid or not root then
		return
	end

	humanoid.PlatformStand = true
	root.Anchored = true

	flyConnection = RunService.Heartbeat:Connect(function(dt)
		local humanoid = getHumanoid()
		local root = getRoot()
		local cam = workspace.CurrentCamera
		if not humanoid or not root or not cam then
			return
		end

		-- บินตามทิศกล้อง: มองขึ้นแล้วบินขึ้น
		local inputDir = humanoid.MoveDirection
		local direction = cam.CFrame.LookVector * inputDir.Z
			+ cam.CFrame.RightVector * inputDir.X

		if flyUp then
			direction += Vector3.yAxis
		end
		if flyDown then
			direction -= Vector3.yAxis
		end

		if direction.Magnitude > 0 then
			root.CFrame += direction.Unit * settings.flySpeed * dt
		end
	end)
end

local setFlyToggle = createToggle(-105, 94, 90, "ปิด", "เปิด", function(enabled)
	settings.flying = enabled
	if enabled then
		startFly()
	else
		stopFly()
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.Space then
		flyUp = true
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		flyDown = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.Space then
		flyUp = false
	elseif input.KeyCode == Enum.KeyCode.LeftShift then
		flyDown = false
	end
end)

-- =========================
-- INFINITE JUMP
-- =========================

createRow("กระโดดไม่จำกัด", 134)

local setJumpToggle = createToggle(-105, 136, 90, "ปิด", "เปิด", function(enabled)
	settings.infiniteJump = enabled
end)

UserInputService.JumpRequest:Connect(function()
	if not settings.infiniteJump then
		return
	end
	local humanoid = getHumanoid()
	if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- =========================
-- NOCLIP (เปิด connection เฉพาะตอนใช้)
-- =========================

local function setNoclip(enabled)
	if noclipConnection then
		noclipConnection:Disconnect()
		noclipConnection = nil
	end
	if enabled then
		noclipConnection = RunService.Stepped:Connect(function()
			local character = getCharacter()
			if not character then
				return
			end
			for _, part in character:GetDescendants() do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	end
end

createRow("ทะลุกำแพง", 176)

local setNoclipToggle = createToggle(-105, 178, 90, "ปิด", "เปิด", function(enabled)
	settings.noclip = enabled
	setNoclip(enabled)
end)

-- =========================
-- FOV CIRCLE
-- =========================

local fovCircle = Instance.new("Frame")
fovCircle.Name = "FOVCircle"
fovCircle.Size = UDim2.fromOffset(settings.fovSize * 2, settings.fovSize * 2)
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.ZIndex = 10
fovCircle.Parent = gui

Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 2
fovStroke.Color = Color3.fromRGB(255, 140, 0)
fovStroke.Parent = fovCircle

local centerDot = Instance.new("Frame")
centerDot.Size = UDim2.fromOffset(4, 4)
centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
centerDot.Position = UDim2.fromScale(0.5, 0.5)
centerDot.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
centerDot.BorderSizePixel = 0
centerDot.ZIndex = 11
centerDot.Parent = fovCircle
Instance.new("UICorner", centerDot).CornerRadius = UDim.new(1, 0)

-- =========================
-- AIM HELPERS
-- =========================

local lastVisCheck = 0
local lastVisResult = false

local function canSeeTarget(head)
	local now = os.clock()
	if now - lastVisCheck < VIS_CHECK_INTERVAL then
		return lastVisResult
	end
	lastVisCheck = now

	local cam = workspace.CurrentCamera
	if not cam or not head then
		lastVisResult = false
		return false
	end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { getCharacter() }
	params.IgnoreWater = true

	local result = workspace:Raycast(cam.CFrame.Position, head.Position - cam.CFrame.Position, params)

	lastVisResult = (not result) or result.Instance:IsDescendantOf(head.Parent)
	return lastVisResult
end

local function getScreenDistance(position)
	local cam = workspace.CurrentCamera
	if not cam then
		return math.huge, false
	end
	local screenPos, visible = cam:WorldToViewportPoint(position)
	if not visible or screenPos.Z <= 0 then
		return math.huge, false
	end
	local center = cam.ViewportSize / 2
	return (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude, true
end

local function getTargetHead(target)
	local character = target and target.Character
	if not character then
		return nil, nil
	end
	return character:FindFirstChildOfClass("Humanoid"), character:FindFirstChild("Head")
end

local function getBestFOVTarget()
	local bestPlayer, bestDistance = nil, math.huge
	for _, other in Players:GetPlayers() do
		if other ~= player then
			local humanoid, head = getTargetHead(other)
			if humanoid and head and humanoid.Health > 0 then
				local distance, visible = getScreenDistance(head.Position)
				if visible and distance <= settings.fovSize and canSeeTarget(head) then
					if distance < bestDistance then
						bestDistance = distance
						bestPlayer = other
					end
				end
			end
		end
	end
	return bestPlayer
end

local function isTargetValid(target)
	local humanoid, head = getTargetHead(target)
	if not humanoid or not head or humanoid.Health <= 0 then
		return false
	end
	local distance, visible = getScreenDistance(head.Position)
	if not visible or distance > settings.fovSize then
		return false
	end
	return canSeeTarget(head)
end

local function stopTargetLock()
	if lockConnection then
		lockConnection:Disconnect()
		lockConnection = nil
	end
	lockedPlayer = nil
	fovStroke.Color = Color3.fromRGB(255, 140, 0)
end

local function startTargetLock()
	stopTargetLock()
	lockedPlayer = getBestFOVTarget()
	if not lockedPlayer then
		return
	end

	lockConnection = RunService.RenderStepped:Connect(function(dt)
		if not settings.fovLock then
			return
		end

		-- เปลี่ยนเป้าเฉพาะตอนเป้าเดิมใช้ไม่ได้แล้ว
		if not isTargetValid(lockedPlayer) then
			lockedPlayer = getBestFOVTarget()
			if not lockedPlayer then
				fovStroke.Color = Color3.fromRGB(255, 140, 0)
				return
			end
		end

		local _, head = getTargetHead(lockedPlayer)
		if not head then
			return
		end

		fovStroke.Color = Color3.fromRGB(255, 60, 60)

		-- ล็อคแบบ smooth
		local cam = workspace.CurrentCamera
		if not cam then
			return
		end
		local targetCFrame = CFrame.lookAt(cam.CFrame.Position, head.Position)
		local alpha = 1 - math.exp(-dt / math.max(settings.aimSmoothness, 0.01))
		cam.CFrame = cam.CFrame:Lerp(targetCFrame, alpha)
	end)
end

-- =========================
-- LOCK UI
-- =========================

createRow("ล็อคหัว", 218)

createNumberBox(-195, 220, 80, settings.fovSize, 30, 400, function(value)
	settings.fovSize = value
	fovCircle.Size = UDim2.fromOffset(value * 2, value * 2)
end)

local setLockToggle = createToggle(-105, 220, 90, "ปิด", "เปิด", function(enabled)
	settings.fovLock = enabled
	fovCircle.Visible = enabled
	if enabled then
		startTargetLock()
	else
		stopTargetLock()
	end
end)

createRow("ความนุ่มล็อค", 260)

createNumberBox(-105, 262, 90, settings.aimSmoothness, 0.05, 1, function(value)
	settings.aimSmoothness = value
end)

-- =========================
-- RESPAWN / DEATH HANDLING
-- =========================

player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.WalkSpeed = settings.walkSpeed

	humanoid.Died:Connect(function()
		-- รีเซ็ตทุกอย่างตอนตาย
		if settings.flying then
			settings.flying = false
			stopFly()
			setFlyToggle(false)
		end
		if settings.noclip then
			settings.noclip = false
			setNoclip(false)
			setNoclipToggle(false)
		end
		if settings.fovLock then
			settings.fovLock = false
			fovCircle.Visible = false
			stopTargetLock()
			setLockToggle(false)
		end
	end)

	-- คืนค่าถ้า toggle ยังเปิดอยู่ตอนเกิดใหม่
	task.wait(0.2)
	if settings.noclip then
		for _, part in character:GetDescendants() do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
	if settings.flySpeed and settings.flying then
		startFly()
	end
	if settings.fovLock then
		startTargetLock()
	end
end)

-- =========================
-- DRAG UI
-- =========================

local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

header.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

-- =========================
-- MINIMIZE + HOTKEY
-- =========================

local miniButton = Instance.new("TextButton")
miniButton.Size = UDim2.fromOffset(55, 55)
miniButton.Position = frame.Position
miniButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
miniButton.Text = "+"
miniButton.TextColor3 = Color3.new(1, 1, 1)
miniButton.TextSize = 27
miniButton.Font = Enum.Font.GothamBold
miniButton.BorderSizePixel = 0
miniButton.Visible = false
miniButton.Parent = gui
Instance.new("UICorner", miniButton).CornerRadius = UDim.new(0, 15)

local function minimize()
	miniButton.Position = frame.Position
	frame.Visible = false
	miniButton.Visible = true
end

local function restore()
	frame.Position = miniButton.Position
	miniButton.Visible = false
	frame.Visible = true
end

close.MouseButton1Click:Connect(minimize)
miniButton.MouseButton1Click:Connect(restore)

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if frame.Visible then
			minimize()
		else
			restore()
		end
	end
end)
