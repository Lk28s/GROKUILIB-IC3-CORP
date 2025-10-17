-- GrokMainScript: Script principal com Aimbot e ESP por Ic3 Corp
-- Versão 3.0 (Outubro 2025) - By Grok (xAI)
-- Requer UniversalGrokLIB.lua

local libUrl = "https://raw.githubusercontent.com/Lk28s/GROKUILIB-IC3-CORP/refs/heads/main/Universal%20GrokLIB.lua"
local response = game:HttpGet(libUrl)
if not response or #response == 0 then
    warn("Falha ao baixar UniversalGrokLIB.lua")
    return
end

local loadSuccess, lib = pcall(loadstring(response))
if not loadSuccess or not lib or type(lib) ~= "table" or not lib.new then
    warn("Erro ao carregar a biblioteca:", lib)
    return
end

local ui = lib.new()
local window = ui:CreateWindow("GrokHUB - Ic3 Corp")

-- Configurações globais personalizáveis
_G.ESPEnabled = false
_G.AimbotEnabled = false
_G.AimbotTarget = "Head" -- "Head" or "Torso"
_G.FOVSize = 100
_G.TeamCheckEnabled = true
_G.WallCheckEnabled = true
_G.ESPColor = Color3.fromRGB(0, 255, 0)
_G.AimbotSmoothness = 0.1
_G.MaxESPDistance = 1000

-- Funções utilitárias
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

-- ESP
local function drawESP(player)
    if not isSafe() or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local distance = (hrp.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if distance > _G.MaxESPDistance then return end

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
    box.BorderSizePixel = 1

    local tracer = Instance.new("Frame")
    tracer.Parent = billboard
    tracer.Size = UDim2.new(0, 2, 0, 200)
    tracer.Position = UDim2.new(0.5, -1, 1, 0)
    tracer.BackgroundColor3 = _G.ESPColor
    tracer.BorderSizePixel = 0

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Parent = billboard
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, -0.1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name .. " (" .. math.floor(distance) .. " studs)"
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.SourceSansBold
end

local function updateESP()
    if not _G.ESPEnabled or not isSafe() then return end
    for _, obj in pairs(game.CoreGui:GetChildren()) do
        if obj.Name:find("_ESP") then obj:Destroy() end
    end
    for _, player in pairs(getPlayers()) do
        if player ~= game.Players.LocalPlayer and not isTeamMate(player) then
            spawn(function() drawESP(player) end)
        end
    end
end

-- Aimbot
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

-- UI Configurações
window:AddButton("Ativar/Desativar ESP", function()
    _G.ESPEnabled = not _G.ESPEnabled
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("ESP", _G.ESPEnabled and "Ativado" or "Desativado", 2, {Title = _G.ESPEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)})
end)

window:AddButton("Ativar/Desativar Aimbot", function()
    _G.AimbotEnabled = not _G.AimbotEnabled
    if _G.AimbotEnabled then aimbotLoop() end
    window:AddNotification("Aimbot", _G.AimbotEnabled and "Ativado" or "Desativado", 2, {Title = _G.AimbotEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)})
end)

window:AddToggle("Team Check", function(state)
    _G.TeamCheckEnabled = state
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("Team Check", _G.TeamCheckEnabled and "Ativado" or "Desativado", 2, {Title = _G.TeamCheckEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)})
end)

window:AddToggle("Wall Check", function(state)
    _G.WallCheckEnabled = state
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("Wall Check", _G.WallCheckEnabled and "Ativado" or "Desativado", 2, {Title = _G.WallCheckEnabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)})
end)

window:AddSlider("FOV", 50, 200, 100, function(value)
    _G.FOVSize = value
    window:AddNotification("FOV", "Definido para " .. value .. " studs", 2, {Title = Color3.fromRGB(0, 150, 255)})
end)

window:AddSlider("Max ESP Distance", 500, 2000, 1000, function(value)
    _G.MaxESPDistance = value
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("Max ESP Distance", "Definido para " .. value .. " studs", 2, {Title = Color3.fromRGB(0, 150, 255)})
end)

window:AddSlider("Aimbot Smoothness", 0.05, 0.5, 0.1, function(value)
    _G.AimbotSmoothness = value
    window:AddNotification("Aimbot Smoothness", "Definido para " .. value, 2, {Title = Color3.fromRGB(0, 150, 255)})
end)

local function updateLoop()
    RunService.RenderStepped:Connect(function()
        if _G.ESPEnabled then updateESP() end
    end)
end
updateLoop()

print("Janela criada!")

