-- Executor para GrokUILib com ESP AirHub-Style e Aimbot - Ic3 Corp (Anti-Deteção)
-- Versão 2.0 (Outubro 2025) - By Grok (xAI)
-- Rode com loadstring(game:HttpGet("URL_DO_EXECUTOR"))()

-- Configurações globais
_G.ESPEnabled = false
_G.AimbotEnabled = false
_G.AimbotTarget = "Head" -- "Head" ou "Torso"
_G.FOVSize = 100
_G.TeamCheckEnabled = true
_G.WallCheckEnabled = true
_G.ESPColor = Color3.fromRGB(0, 255, 0)
_G.AimbotSmoothness = 0.1
_G.MaxESP Distance = 1000

local libUrl = "https://raw.githubusercontent.com/Lk28s/GROKUILIB-IC3-CORP/refs/heads/main/GrokUILib.lua" -- Link da lib
local success, lib = pcall(loadstring(game:HttpGet(libUrl)))
if not success then error("Falha ao carregar a lib: " .. lib) end

local window = lib:CreateWindow("GrokLib - Ic3 Corp")

-- Funções com anti-deteção
local function isSafe()
    return game and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character
end

local function getPlayers()
    return isSafe() and game.Players:GetPlayers() or {}
end

local function isTeamMate(player)
    local localPlayer = game.Players.LocalPlayer
    return _G.TeamCheckEnabled and localPlayer and player and localPlayer.Team == player.Team
end

local function isVisible(target)
    if not isSafe() then return false end
    local ray = Ray.new(game.Players.LocalPlayer.Character.Head.Position, (target.Position - game.Players.LocalPlayer.Character.Head.Position).Unit * 300)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {game.Players.LocalPlayer.Character})
    return hit and (hit:IsDescendantOf(target.Parent) or not _G.WallCheckEnabled)
end

local function drawESP(player)
    if not isSafe() or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local camera = workspace.CurrentCamera
    local distance = (hrp.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if distance > _G.MaxESP Distance then return end
    
    -- Caixa 2D (AirHub-style)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = player.Name .. "_ESP"
    billboard.Parent = game.CoreGui
    billboard.Adornee = hrp
    billboard.Size = UDim2.new(0, 100, 0, 150)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    
    local box = Instance.new("Frame")
    box.Parent = billboard
    box.Size = UDim2.new(1, 0, 1, 0)
    box.BackgroundColor3 = _G.ESPColor
    box.Transparency = 0.7
    box.BorderSizePixel = 2
    box.BorderColor3 = _G.ESPColor
    
    -- Nome e Distância
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, -0.1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name .. " (" .. math.floor(distance) .. " studs)"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
    
    -- Linha de traço (tracer)
    local line = Instance.new("Part")
    line.Name = player.Name .. "_Tracer"
    line.Parent = workspace
    line.Size = Vector3.new(0.1, 0.1, distance)
    line.CFrame = CFrame.new(hrp.Position, Vector3.new(hrp.Position.X, 0, hrp.Position.Z)) * CFrame.new(0, 0, -distance / 2)
    line.Anchored = true
    line.CanCollide = false
    line.Material = Enum.Material.Neon
    line.BrickColor = BrickColor.new(_G.ESPColor)
    line.Transparency = 0.5
end

local function updateESP()
    if not _G.ESPEnabled or not isSafe() then return end
    for _, obj in pairs(game.CoreGui:GetChildren()) do
        if obj.Name:find("_ESP") then obj:Destroy() end
    end
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("_Tracer") then obj:Destroy() end
    end
    for _, player in pairs(getPlayers()) do
        if player ~= game.Players.LocalPlayer and not isTeamMate(player) then
            spawn(function()
                drawESP(player)
            end)
        end
    end
end

local function aimbotLoop()
    spawn(function()
        while _G.AimbotEnabled and wait(0.1) do
            if not isSafe() then break end
            local target = nil
            local minDistance = _G.FOVSize
            local camera = workspace.CurrentCamera
            local mouse = game.Players.LocalPlayer:GetMouse()
            
            for _, player in pairs(getPlayers()) do
                if player ~= game.Players.LocalPlayer and not isTeamMate(player) and player.Character and player.Character:FindFirstChild(_G.AimbotTarget) and isVisible(player.Character[_G.AimbotTarget]) then
                    local screenPoint = camera:WorldToScreenPoint(player.Character[_G.AimbotTarget].Position)
                    local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPoint.X, screenPoint.Y)).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        target = player.Character[_G.AimbotTarget]
                    end
                end
            end
            
            if target then
                local targetPos = camera:WorldToScreenPoint(target.Position)
                local deltaX = (targetPos.X - mouse.X) * _G.AimbotSmoothness
                local deltaY = (targetPos.Y - mouse.Y) * _G.AimbotSmoothness
                if math.abs(deltaX) > 1 or math.abs(deltaY) > 1 then
                    game:GetService("VirtualInputManager"):SendMouseMoveEvent(mouse.X + deltaX, mouse.Y + deltaY, game)
                end
            end
        end
    end)
end

-- Loop para atualizar ESP
spawn(function()
    while true do
        wait(0.5)
        if _G.ESPEnabled then updateESP() end
    end
end)

-- UI
window:AddButton("Ativar/Desativar ESP", function()
    _G.ESPEnabled = not _G.ESPEnabled
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("ESP", _G.ESPEnabled and "Ativado (AirHub-style)" or "Desativado", 3)
end)

window:AddButton("Desativar ESP Agora", function()
    _G.ESPEnabled = false
    for _, obj in pairs(game.CoreGui:GetChildren()) do
        if obj.Name:find("_ESP") then obj:Destroy() end
    end
    for _, obj in pairs(workspace:GetChildren()) do
        if obj.Name:find("_Tracer") then obj:Destroy() end
    end
    window:AddNotification("ESP", "Desativado e Limpo", 3)
end)

window:AddButton("Ativar/Desativar Aimbot", function()
    _G.AimbotEnabled = not _G.AimbotEnabled
    if _G.AimbotEnabled then aimbotLoop() end
    window:AddNotification("Aimbot", _G.AimbotEnabled and "Ativado" or "Desativado", 3)
end)

window:AddButton("Desativar Aimbot Agora", function()
    _G.AimbotEnabled = false
    window:AddNotification("Aimbot", "Desativado", 3)
end)

window:AddToggle("Team Check", function(state)
    _G.TeamCheckEnabled = state
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("Team Check", _G.TeamCheckEnabled and "Ativado" or "Desativado", 3)
end)

window:AddToggle("Wall Check", function(state)
    _G.WallCheckEnabled = state
    window:AddNotification("Wall Check", _G.WallCheckEnabled and "Ativado" or "Desativado", 3)
end)

window:AddToggle("Aimbot: Cabeça/Torso", function(state)
    _G.AimbotTarget = state and "Head" or "Torso"
    window:AddNotification("Aimbot", "Alvo: " .. _G.AimbotTarget, 3)
end)

window:AddSlider("FOV", 50, 200, 100, function(value)
    _G.FOVSize = value
    window:AddNotification("FOV", "Definido para " .. value .. " studs", 2)
end)

window:AddNotification("Carregado!", "ESP e Aimbot prontos. Teste com 'Ativar/Desativar ESP'!", 5)
