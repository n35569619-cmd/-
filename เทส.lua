local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "SensitivityUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- กล่องหลัก
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 150)
frame.Position = UDim2.new(0.5, -130, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

-- หัวข้อ
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 10, 0, 8)
title.BackgroundTransparency = 1
title.Text = "Sensitivity"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = frame

-- ช่องตัวเลข
local valueBox = Instance.new("TextBox")
valueBox.Size = UDim2.new(0, 100, 0, 40)
valueBox.Position = UDim2.new(0.5, -50, 0, 55)
valueBox.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
valueBox.BorderSizePixel = 0
valueBox.Text = "10"
valueBox.TextColor3 = Color3.fromRGB(255, 255, 255)
valueBox.TextSize = 18
valueBox.Font = Enum.Font.Gotham
valueBox.ClearTextOnFocus = false
valueBox.Parent = frame

local boxCorner = Instance.new("UICorner")
boxCorner.CornerRadius = UDim.new(0, 10)
boxCorner.Parent = valueBox

-- ปุ่มลด
local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0, 40, 0, 40)
minus.Position = UDim2.new(0, 15, 0, 55)
minus.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
minus.BorderSizePixel = 0
minus.Text = "-"
minus.TextColor3 = Color3.fromRGB(255, 255, 255)
minus.TextSize = 24
minus.Parent = frame

local minusCorner = Instance.new("UICorner")
minusCorner.CornerRadius = UDim.new(0, 10)
minusCorner.Parent = minus

-- ปุ่มเพิ่ม
local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0, 40, 0, 40)
plus.Position = UDim2.new(1, -55, 0, 55)
plus.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
plus.BorderSizePixel = 0
plus.Text = "+"
plus.TextColor3 = Color3.fromRGB(255, 255, 255)
plus.TextSize = 24
plus.Parent = frame

local plusCorner = Instance.new("UICorner")
plusCorner.CornerRadius = UDim.new(0, 10)
plusCorner.Parent = plus

local sensitivity = 10

local function updateValue(value)
	sensitivity = math.clamp(math.floor(value), 1, 100)
    	valueBox.Text = tostring(sensitivity)
        end

        minus.MouseButton1Click:Connect(function()
        	updateValue(sensitivity - 1)
            end)

            plus.MouseButton1Click:Connect(function()
            	updateValue(sensitivity + 1)
                end)

                valueBox.FocusLost:Connect(function()
                	local value = tonumber(valueBox.Text)

                    	if value then
                        		updateValue(value)
                                	else
                                    		updateValue(sensitivity)
                                            	end
                                                end)