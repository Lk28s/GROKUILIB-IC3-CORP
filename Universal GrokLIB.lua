-- Universal GrokLIB: Biblioteca UI mínima para Roblox by Ic3 Corp
-- Versão 1.9 (Outubro 2025) - By Grok (xAI)
-- Licença: Livre para uso

local GrokUILib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function createFrame(parent, size, position, color, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 300, 0, 200)
    frame.Position = position or UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = parent
    if cornerRadius then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, cornerRadius)
        corner.Parent = frame
    end
    return frame
end

local function createLabel(parent, text, size, position, textColor)
    local label = Instance.new("TextLabel")
    label.Size = size or UDim2.new(1, 0, 0, 20)
    label.Position = position or UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Font = Enum.Font.SourceSans
    label.Parent = parent
    return label
end

function GrokUILib.new()
    local self = {}
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GrokUILib"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    
    function self:CreateWindow(title)
        local window = createFrame(screenGui, UDim2.new(0, 300, 0, 300), UDim2.new(0.5, -150, 0.5, -150), Color3.fromRGB(30, 30, 30), 8)
        local titleBar = createFrame(window, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Color3.fromRGB(20, 20, 20), 8)
        createLabel(titleBar, title, UDim2.new(1, 0, 1, 0), UDim2.new(0, 10, 0, 0))
        
        local dragging, dragStart, startPos = false, nil, nil
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging, dragStart, startPos = true, input.Position, window.Position
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        
        local content = createFrame(window, UDim2.new(1, 0, 1, -30), UDim2.new(0, 0, 0, 30))
        content.BackgroundTransparency = 1
        
        local yOffset = 5
        function window:AddButton(text, callback)
            createFrame(content, UDim2.new(1, -10, 0, 25), UDim2.new(0, 5, 0, yOffset), Color3.fromRGB(50, 50, 50), 5)
            createLabel(content, text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 5, 0, yOffset))
            yOffset = yOffset + 30
            content.Size = UDim2.new(1, 0, 0, yOffset)
            window.Size = UDim2.new(0, 300, 0, 30 + yOffset + 10)
        end
        
        return window
    end
    
    return self
end

return GrokUILib
