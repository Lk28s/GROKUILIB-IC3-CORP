-- Universal GrokLIB: Biblioteca UI modular para Roblox by Ic3 Corp
-- Versão 2.4 (Outubro 2025) - By Grok (xAI)
-- Licença: Livre para uso em projetos

local GrokUILib = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function createScreenGui(name, displayOrder)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = name or "GrokUILib"
    screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = displayOrder or 10 -- Prioridade alta
    return screenGui
end

local function createFrame(parent, size, position, color, cornerRadius)
    local frame = Instance.new("Frame")
    frame.Size = size or UDim2.new(0, 300, 0, 200)
    frame.Position = position or UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = color or Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
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

local function createButton(parent, text, callback)
    local button = createFrame(parent, UDim2.new(1, -10, 0, 25), UDim2.new(0, 5, 0, 0), Color3.fromRGB(50, 50, 50), 5)
    local btnLabel = createLabel(button, text, UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0))
    btnLabel.BackgroundTransparency = 1
    btnLabel.TextScaled = false
    btnLabel.TextSize = 14

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 70, 70)}):Play()
            task.wait(0.1)
            TweenService:Create(button, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
            if callback then callback() end
        end
    end)
    button.Active = true
    return button
end

local function createToggle(parent, text, default, callback)
    local toggleFrame = createFrame(parent, UDim2.new(1, -10, 0, 25), UDim2.new(0, 5, 0, 0), Color3.fromRGB(50, 50, 50), 5)
    createLabel(toggleFrame, text, UDim2.new(0.7, 0, 1, 0), UDim2.new(0, 5, 0, 0))
    
    local toggle = createFrame(toggleFrame, UDim2.new(0, 20, 0, 15), UDim2.new(1, -25, 0.5, -7.5), Color3.fromRGB(100, 100, 100), 5)
    local state = default or false
    toggle.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    
    toggle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            if callback then callback(state) end
        end
    end)
    toggle.Active = true
    return toggleFrame
end

local function createSlider(parent, text, min, max, default, callback)
    local sliderFrame = createFrame(parent, UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 0), Color3.fromRGB(50, 50, 50), 5)
    local label = createLabel(sliderFrame, text .. ": " .. default, UDim2.new(1, 0, 0.5, 0), UDim2.new(0, 0, 0, 0))
    
    local sliderBar = createFrame(sliderFrame, UDim2.new(1, -10, 0, 10), UDim2.new(0, 5, 0.75, 0), Color3.fromRGB(70, 70, 70), 3)
    local sliderKnob = createFrame(sliderBar, UDim2.new(0, 10, 1, 0), UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 255, 255), 5)
    local value = default or min
    local dragging = false
    
    local function updateSlider(x)
        local relativeX = math.clamp((x - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
        sliderKnob.Position = UDim2.new(relativeX, -5, 0, -5)
        value = math.floor(min + (max - min) * relativeX)
        label.Text = text .. ": " .. value
        if callback then callback(value) end
    end
    
    sliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    updateSlider(sliderBar.AbsolutePosition.X + (sliderBar.AbsoluteSize.X * ((default - min) / (max - min))))
    return sliderFrame
end

local function createNotification(screenGui, title, description, duration, colors)
    local notifSize = description and UDim2.new(0, 250, 0, 80) or UDim2.new(0, 250, 0, 50)
    local notifFrame = createFrame(screenGui, notifSize, UDim2.new(1, 10, 1, -90), colors and colors.Background or Color3.fromRGB(30, 30, 30), 8)
    
    createLabel(notifFrame, title, UDim2.new(1, -10, 0, 20), UDim2.new(0, 5, 0, 5), colors and colors.Title or Color3.fromRGB(255, 255, 255))
    if description then
        local descLabel = createLabel(notifFrame, description, UDim2.new(1, -10, 0, 20), UDim2.new(0, 5, 0, 25), colors and colors.Description or Color3.fromRGB(200, 200, 200))
        descLabel.TextScaled = false
        descLabel.TextSize = 12
    end
    
    TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -260, 1, -90)}):Play()
    
    task.spawn(function()
        task.wait(duration or 3)
        TweenService:Create(notifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, -260, 1, -150)}):Play()
        task.wait(0.5)
        notifFrame:Destroy()
    end)
end

function GrokUILib.new()
    local self = {}
    local screenGuiMain = createScreenGui("GrokUILibMain", 10)
    local screenGuiMini = createScreenGui("GrokUILibMini", 11) -- Prioridade maior que o main

    local mainWindow = nil
    local isMinimized = false

    -- Mini Hub
    local miniFrame = createFrame(screenGuiMini, UDim2.new(0, 50, 0, 50), UDim2.new(1, -60, 0, 10), Color3.fromRGB(40, 40, 40), 5)
    miniFrame.Active = true
    miniFrame.Draggable = true -- Para arrastar o mini hub (se suportado)

    local minimizeButton = createButton(miniFrame, "Min", function()
        if mainWindow and not isMinimized then
            mainWindow.Frame.Visible = false
            isMinimized = true
            createNotification(screenGuiMini, "Mini Hub", "Hub minimizado", 2)
        end
    end)

    local maximizeButton = createButton(miniFrame, "Max", function()
        if mainWindow and isMinimized then
            mainWindow.Frame.Visible = true
            isMinimized = false
            createNotification(screenGuiMini, "Mini Hub", "Hub maximizado", 2)
        end
    end)

    -- Ajusta o layout do mini hub
    minimizeButton.Position = UDim2.new(0, 5, 0, 5)
    maximizeButton.Position = UDim2.new(0, 5, 0, 30)

    function self:CreateWindow(title)
        local window = {}
        mainWindow = window -- Armazena a referência
        local frame = createFrame(screenGuiMain, UDim2.new(0, 300, 0, 300), UDim2.new(0.5, -150, 0.5, -150), Color3.fromRGB(30, 30, 30), 8)
        local titleBar = createFrame(frame, UDim2.new(1, 0, 0, 30), UDim2.new(0, 0, 0, 0), Color3.fromRGB(20, 20, 20), 8)
        createLabel(titleBar, title, UDim2.new(1, 0, 1, 0), UDim2.new(0, 10, 0, 0))
        
        local content = createFrame(frame, UDim2.new(1, 0, 1, -30), UDim2.new(0, 0, 0, 30))
        content.BackgroundTransparency = 1
        
        local yOffset = 5
        
        function window:AddButton(text, callback)
            local button = createButton(content, text, callback)
            button.Position = UDim2.new(0, 5, 0, yOffset)
            yOffset = yOffset + 30
            content.Size = UDim2.new(1, 0, 0, yOffset)
            frame.Size = UDim2.new(0, 300, 0, 30 + yOffset + 10)
        end
        
        function window:AddToggle(text, callback)
            local toggle = createToggle(content, text, false, callback)
            toggle.Position = UDim2.new(0, 5, 0, yOffset)
            yOffset = yOffset + 30
            content.Size = UDim2.new(1, 0, 0, yOffset)
            frame.Size = UDim2.new(0, 300, 0, 30 + yOffset + 10)
        end
        
        function window:AddSlider(text, min, max, default, callback)
            local slider = createSlider(content, text, min or 0, max or 100, default, callback)
            slider.Position = UDim2.new(0, 5, 0, yOffset)
            yOffset = yOffset + 45
            content.Size = UDim2.new(1, 0, 0, yOffset)
            frame.Size = UDim2.new(0, 300, 0, 30 + yOffset + 10)
        end
        
        function window:AddNotification(title, description, duration, colors)
            createNotification(screenGuiMain, title, description, duration, colors)
        end
        
        window.Frame = frame
        setmetatable(window, { __index = frame })
        
        return window
    end
    
    function self:Destroy()
        screenGuiMain:Destroy()
        screenGuiMini:Destroy()
    end
    
    return self
end

return GrokUILib
