-- GrokMainScript: Script principal com Aimbot e ESP por Ic3 Corp
-- Versão 3.2 (Outubro 2025) - By Grok (xAI)
-- Requer UniversalGrokLIB.lua
-- AVISO: Este script pode causar suspensão permanente da conta. Use por sua conta e risco!

local libUrl = "https://raw.githubusercontent.com/Lk28s/GROKUILIB-IC3-CORP/refs/heads/main/UniversalGrokLIB.lua"
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
local window = ui:CreateWindow("GrokLib - Ic3 Corp")

-- Configurações globais
_G.ESPEnabled = false
_G.AimbotEnabled = false
_G.AimbotTarget = "Head" -- "Head" or "Torso"
_G.FOVSize = 90
_G.MaxDistance = 700
_G.TeamCheck = true
_G.WallCheck = true
_G.ESPColor = Color3.fromRGB(0, 255, 0)
_G.AimbotSmoothness = 0.1

-- Serviços
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Cam = workspace.CurrentCamera

-- Desenhos
local FOVring = Drawing.new("Circle")
FOVring.Visible = true
FOVring.Thickness = 1
FOVring.Color = Color3.fromRGB(128, 0, 128)
FOVring.Filled = false
FOVring.Radius = _G.FOVSize
FOVring.Position = Cam.ViewportSize / 2
FOVring.Transparency = 0.1

-- Funções utilitárias
local function isSafe()
    return game and Players and Players.LocalPlayer and Players.LocalPlayer.Character
end

local function isTeamMate(player)
    local localPlayer = Players.LocalPlayer
    return _G.TeamCheck and localPlayer and player and localPlayer.Team == player.Team
end

local function isVisible(target)
    if not _G.WallCheck then return true end
    if not isSafe() then return false end
    local ray = Ray.new(Cam.CFrame.Position, (target.Position - Cam.CFrame.Position).Unit * 300)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, {Players.LocalPlayer.Character})
    return hit and hit:IsDescendantOf(target.Parent)
end

local function updateDrawings()
    if Cam and Cam.ViewportSize then
        FOVring.Position = Cam.ViewportSize / 2
        FOVring.Radius = _G.FOVSize
    end
end

-- ESP
local function drawESP(player)
    if not isSafe() or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = player.Character.HumanoidRootPart
    local distance = (hrp.Position - Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
    if distance > _G.MaxDistance then return end

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
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and not isTeamMate(player) then
            spawn(function() drawESP(player) end)
        end
    end
end

-- Aimbot
local function lookAt(target)
    if not Cam or not target or not target.Position then return end
    local lookVector = (target.Position - Cam.CFrame.Position).Unit
    if lookVector.Magnitude > 0 then
        local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
        Cam.CFrame = Cam.CFrame:Lerp(newCFrame, _G.AimbotSmoothness)
    end
end

local function getClosestPlayerInFOV()
    if not isSafe() then return nil end
    local nearest = nil
    local last = math.huge
    local playerMousePos = Cam.ViewportSize / 2
    local localPlayer = Players.LocalPlayer

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and (not _G.TeamCheck or player.Team ~= localPlayer.Team) and isSafe() and player.Character and player.Character:FindFirstChild(_G.AimbotTarget) then
            local part = player.Character[_G.AimbotTarget]
            local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
            local distance = (Vector2.new(ePos.X, ePos.Y) - playerMousePos).Magnitude

            if distance < last and isVisible and distance < _G.FOVSize and distance < _G.MaxDistance and isVisible(part) then
                last = distance
                nearest = part
            end
        end
    end

    return nearest
end

local function aimbotLoop()
    spawn(function()
        while _G.AimbotEnabled and wait(0.1) do
            if not isSafe() then break end
            local target = getClosestPlayerInFOV()
            if target then
                lookAt(target)
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
    _G.TeamCheck = state
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("Team Check", _G.TeamCheck and "Ativado" or "Desativado", 2, {Title = _G.TeamCheck and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)})
end)

window:AddToggle("Wall Check", function(state)
    _G.WallCheck = state
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("Wall Check", _G.WallCheck and "Ativado" or "Desativado", 2, {Title = _G.WallCheck and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)})
end)

window:AddSlider("FOV", 50, 200, 90, function(value)
    _G.FOVSize = value
    updateDrawings()
    window:AddNotification("FOV", "Definido para " .. value, 2, {Title = Color3.fromRGB(0, 150, 255)})
end)

window:AddSlider("Max Distance", 500, 1000, 700, function(value)
    _G.MaxDistance = value
    if _G.ESPEnabled then updateESP() end
    window:AddNotification("Max Distance", "Definido para " .. value .. " studs", 2, {Title = Color3.fromRGB(0, 150, 255)})
end)

window:AddSlider("Aimbot Smoothness", 0.05, 0.5, 0.1, function(value)
    _G.AimbotSmoothness = value
    window:AddNotification("Aimbot Smoothness", "Definido para " .. value, 2, {Title = Color3.fromRGB(0, 150, 255)})
end)

-- Loop de atualização
RunService.RenderStepped:Connect(function()
    if Cam then
        updateDrawings()
        if _G.AimbotEnabled then
            local target = getClosestPlayerInFOV()
            if target and target.Position then
                lookAt(target)
            end
        end
        if _G.ESPEnabled then
            updateESP()
        end
    end
end)

print("Janela criada!")
