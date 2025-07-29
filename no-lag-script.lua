-- ============================================
-- BLOX FRUITS NO-LAG SCRIPT v1.2.0
-- Created by: YTShadowBloxBR
-- GitHub: https://github.com/YT-Shadow/No-lag
-- YouTube: https://youtube.com/@ytshadowbloxbr
-- Discord: https://discord.gg/gVkaxG7QqQ
-- ============================================

-- Verificação de segurança
if not game:IsLoaded() then
    game.Loaded:Wait()
end

-- Serviços principais
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES PERSONALIZÁVEIS
-- ============================================

local Config = {
    -- Performance
    MaxFPS = 60,                    -- FPS máximo (30, 60, 120, 999 para ilimitado)
    GraphicsQuality = "Auto",       -- Auto, Potato, Low, Medium, High
    
    -- Visual
    RemoveParticles = true,         -- Remove efeitos de partícula
    SimplifyWater = true,           -- Simplifica água
    ReduceShadows = true,           -- Reduz sombras
    OptimizeTextures = true,        -- Otimiza texturas
    
    -- Interface
    ShowPerformanceMonitor = true,  -- Monitor de FPS/Ping/RAM
    ShowOptimizationLog = true,     -- Log de otimizações aplicadas
    
    -- Avançado
    ExtremeMode = false,            -- Modo extremo (apenas para PCs muito fracos)
    SafeMode = false,               -- Modo seguro (menos otimizações, mais estável)
    AutoDetectHardware = true       -- Detecta hardware automaticamente
}

-- ============================================
-- SISTEMA DE LOGGING
-- ============================================

local function Log(message, level)
    local timestamp = os.date("[%H:%M:%S]")
    local levels = {
        [1] = "INFO",
        [2] = "WARN", 
        [3] = "ERROR",
        [4] = "SUCCESS"
    }
    
    local color = level == 4 and "✅" or level == 3 and "❌" or level == 2 and "⚠️" or "ℹ️"
    
    if Config.ShowOptimizationLog then
        print(string.format("%s %s [%s] %s", color, timestamp, levels[level] or "INFO", message))
    end
end

-- ============================================
-- DETECÇÃO AUTOMÁTICA DE HARDWARE
-- ============================================

local function DetectHardware()
    if not Config.AutoDetectHardware then return "Medium" end
    
    local memory = Stats:GetTotalMemoryUsageMb()
    local currentFPS = workspace:GetRealPhysicsFPS()
    
    Log("Detectando especificações do hardware...", 1)
    Log(string.format("Memória em uso: %.1f MB", memory), 1)
    Log(string.format("FPS atual: %.0f", currentFPS), 1)
    
    if memory > 3000 or currentFPS < 20 then
        Log("Hardware fraco detectado - Aplicando modo Potato", 2)
        return "Potato"
    elseif memory > 2000 or currentFPS < 40 then
        Log("Hardware médio detectado - Aplicando modo Low", 1)
        return "Low"
    elseif memory > 1500 and currentFPS > 45 then
        Log("Hardware bom detectado - Aplicando modo Medium", 1)
        return "Medium"
    else
        Log("Hardware potente detectado - Aplicando modo High", 4)
        return "High"
    end
end

-- ============================================
-- PROFILES DE OTIMIZAÇÃO
-- ============================================

local OptimizationProfiles = {
    ["Potato"] = {
        MaxFPS = 30,
        RemoveParticles = true,
        SimplifyWater = true,
        ReduceShadows = true,
        OptimizeTextures = true,
        ExtremeMode = true,
        QualityLevel = 1
    },
    ["Low"] = {
        MaxFPS = 45,
        RemoveParticles = true,
        SimplifyWater = true,
        ReduceShadows = true,
        OptimizeTextures = true,
        ExtremeMode = false,
        QualityLevel = 3
    },
    ["Medium"] = {
        MaxFPS = 60,
        RemoveParticles = false,
        SimplifyWater = false,
        ReduceShadows = true,
        OptimizeTextures = false,
        ExtremeMode = false,
        QualityLevel = 5
    },
    ["High"] = {
        MaxFPS = 120,
        RemoveParticles = false,
        SimplifyWater = false,
        ReduceShadows = false,
        OptimizeTextures = false,
        ExtremeMode = false,
        QualityLevel = 10
    }
}

-- ============================================
-- OTIMIZAÇÕES GRÁFICAS
-- ============================================

local function OptimizeGraphics()
    Log("Iniciando otimizações gráficas...", 1)
    
    -- Detectar e aplicar profile
    local hardwareLevel = Config.GraphicsQuality == "Auto" and DetectHardware() or Config.GraphicsQuality
    local profile = OptimizationProfiles[hardwareLevel] or OptimizationProfiles["Medium"]
    
    -- Aplicar configurações do profile
    for key, value in pairs(profile) do
        if Config[key] ~= nil then
            Config[key] = value
        end
    end
    
    -- Configurações de qualidade gráfica
    settings().Rendering.QualityLevel = Enum.QualityLevel["Level0" .. math.min(profile.QualityLevel, 10)]
    
    -- Otimizar iluminação
    if Config.ReduceShadows then
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Log("Sombras globais desabilitadas", 4)
    end
    
    -- Otimizar fog
    Lighting.FogEnd = Config.ExtremeMode and 50 or 100
    Lighting.FogStart = 0
    
    -- Remover efeitos pós-processamento
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    
    Log("Otimizações gráficas aplicadas com sucesso", 4)
end

-- ============================================
-- OTIMIZAÇÃO DE PARTÍCULAS
-- ============================================

local function OptimizeParticles()
    if not Config.RemoveParticles then return end
    
    Log("Removendo partículas desnecessárias...", 1)
    
    local particleCount = 0
    
    local function removeParticles(obj)
        for _, child in pairs(obj:GetDescendants()) do
            if child:IsA("ParticleEmitter") or child:IsA("Fire") or 
               child:IsA("Smoke") or child:IsA("Explosion") or
               child:IsA("Beam") or child:IsA("Trail") then
                child.Enabled = false
                child:Destroy()
                particleCount = particleCount + 1
            end
        end
    end
    
    -- Remover partículas existentes
    removeParticles(Workspace)
    removeParticles(playerGui)
    
    -- Interceptar novas partículas
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
           obj:IsA("Smoke") or obj:IsA("Explosion") or
           obj:IsA("Beam") or obj:IsA("Trail") then
            wait()
            obj.Enabled = false
            obj:Destroy()
        end
    end)
    
    Log(string.format("Removidas %d partículas", particleCount), 4)
end

-- ============================================
-- LIMITADOR DE FPS
-- ============================================

local function SetupFPSLimiter()
    if Config.MaxFPS >= 999 then 
        Log("FPS ilimitado configurado", 1)
        return 
    end
    
    Log(string.format("Limitando FPS para %d", Config.MaxFPS), 1)
    
    local lastFrame = tick()
    local targetFrameTime = 1 / Config.MaxFPS
    
    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        local deltaTime = currentTime - lastFrame
        
        if deltaTime < targetFrameTime then
            local sleepTime = targetFrameTime - deltaTime
            wait(sleepTime)
        end
        
        lastFrame = tick()
    end)
    
    Log("Limitador de FPS configurado", 4)
end

-- ============================================
-- OTIMIZAÇÃO DE ÁGUA
-- ============================================

local function OptimizeWater()
    if not Config.SimplifyWater then return end
    
    Log("Simplificando elementos de água...", 1)
    
    local waterCount = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("water") or obj.Name:lower():find("ocean") then
            if obj:IsA("Part") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
                obj.Transparency = math.min(obj.Transparency + 0.3, 0.8)
                waterCount = waterCount + 1
            end
        end
    end
    
    Log(string.format("Simplificados %d elementos de água", waterCount), 4)
end

-- ============================================
-- OTIMIZAÇÃO DE TEXTURAS
-- ============================================

local function OptimizeTextures()
    if not Config.OptimizeTextures then return end
    
    Log("Otimizando texturas...", 1)
    
    local textureCount = 0
    
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = math.min(obj.Transparency + 0.2, 0.9)
            textureCount = textureCount + 1
        elseif obj:IsA("SurfaceGui") then
            obj.LightInfluence = 0
            textureCount = textureCount + 1
        elseif obj:IsA("SpecialMesh") then
            obj.TextureId = ""
            textureCount = textureCount + 1
        end
    end
    
    Log(string.format("Otimizadas %d texturas", textureCount), 4)
end

-- ============================================
-- MODO EXTREMO
-- ============================================

local function ApplyExtremeMode()
    if not Config.ExtremeMode then return end
    
    Log("Aplicando modo extremo...", 2)
    
    -- Configurações extremas
    game:GetService("Lighting").Technology = Enum.Technology.Compatibility
    
    -- Remover todos os sons
    for _, sound in pairs(Workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0
            sound:Stop()
        end
    end
    
    -- Simplificar geometria
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("Part") or part:IsA("UnionOperation") then
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
        end
    end
    
    Log("Modo extremo aplicado", 4)
end

-- ============================================
-- MONITOR DE PERFORMANCE
-- ============================================

local function CreatePerformanceMonitor()
    if not Config.ShowPerformanceMonitor then return end
    
    Log("Criando monitor de performance...", 1)
    
    -- Remover monitor existente
    if playerGui:FindFirstChild("PerformanceMonitor") then
        playerGui.PerformanceMonitor:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local FPSLabel = Instance.new("TextLabel")
    local PingLabel = Instance.new("TextLabel")
    local MemoryLabel = Instance.new("TextLabel")
    local CPULabel = Instance.new("TextLabel")
    
    -- Configuração da GUI
    ScreenGui.Name = "PerformanceMonitor"
    ScreenGui.Parent = playerGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0, 10, 0, 10)
    MainFrame.Size = UDim2.new(0, 220, 0, 120)
    MainFrame.Active = true
    MainFrame.Draggable = true
    
    -- Adicionar cantos arredondados
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 5, 0, 2)
    Title.Size = UDim2.new(1, -10, 0, 20)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🚀 NO-LAG MONITOR"
    Title.TextColor3 = Color3.fromRGB(0, 255, 127)
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Center
    
    FPSLabel.Parent = MainFrame
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Position = UDim2.new(0, 5, 0, 25)
    FPSLabel.Size = UDim2.new(1, -10, 0, 18)
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.Text = "FPS: --"
    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPSLabel.TextSize = 11
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    PingLabel.Parent = MainFrame
    PingLabel.BackgroundTransparency = 1
    PingLabel.Position = UDim2.new(0, 5, 0, 45)
    PingLabel.Size = UDim2.new(1, -10, 0, 18)
    PingLabel.Font = Enum.Font.Gotham
    PingLabel.Text = "Ping: --"
    PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PingLabel.TextSize = 11
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    MemoryLabel.Parent = MainFrame
    MemoryLabel.BackgroundTransparency = 1
    MemoryLabel.Position = UDim2.new(0, 5, 0, 65)
    MemoryLabel.Size = UDim2.new(1, -10, 0, 18)
    MemoryLabel.Font = Enum.Font.Gotham
    MemoryLabel.Text = "RAM: --"
    MemoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MemoryLabel.TextSize = 11
    MemoryLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    CPULabel.Parent = MainFrame
    CPULabel.BackgroundTransparency = 1
    CPULabel.Position = UDim2.new(0, 5, 0, 85)
    CPULabel.Size = UDim2.new(1, -10, 0, 18)
    CPULabel.Font = Enum.Font.Gotham
    CPULabel.Text = "Status: Otimizado ✅"
    CPULabel.TextColor3 = Color3.fromRGB(0, 255, 127)
    CPULabel.TextSize = 11
    CPULabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Sistema de atualização de stats
    local frameCount = 0
    local lastTime = tick()
    
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 1 then
            local fps = math.floor(frameCount / (currentTime - lastTime))
            local ping = math.floor(player:GetNetworkPing() * 1000)
            local memory = math.floor(Stats:GetTotalMemoryUsageMb())
            
            -- Colorir FPS baseado na performance
            local fpsColor = fps >= 50 and Color3.fromRGB(0, 255, 0) or 
                           fps >= 30 and Color3.fromRGB(255, 255, 0) or 
                           Color3.fromRGB(255, 0, 0)
            
            FPSLabel.Text = string.format("FPS: %d", fps)
            FPSLabel.TextColor3 = fpsColor
            
            PingLabel.Text = string.format("Ping: %dms", ping)
            MemoryLabel.Text = string.format("RAM: %dMB", memory)
            
            frameCount = 0
            lastTime = currentTime
        end
    end)
    
    Log("Monitor de performance criado", 4)
end

-- ============================================
-- SISTEMA DE CONTROLES
-- ============================================

local function SetupControls()
    Log("Configurando controles (F1-F5)...", 1)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        
        if input.KeyCode == Enum.KeyCode.F1 then
            Log("F1 pressionado - Abrindo menu de configurações", 1)
            -- Implementar menu aqui
            
        elseif input.KeyCode == Enum.KeyCode.F2 then
            local monitor = playerGui:FindFirstChild("PerformanceMonitor")
            if monitor then
                monitor.Frame.Visible = not monitor.Frame.Visible
                Log("F2 pressionado - Toggle monitor de performance", 1)
            end
            
        elseif input.KeyCode == Enum.KeyCode.F3 then
            Config.ExtremeMode = not Config.ExtremeMode
            Log("F3 pressionado - Modo extremo: " .. tostring(Config.ExtremeMode), 2)
            if Config.ExtremeMode then
                ApplyExtremeMode()
            end
            
        elseif input.KeyCode == Enum.KeyCode.F4 then
            Log("F4 pressionado - Recarregando configurações", 1)
            InitializeOptimizations()
            
        elseif input.KeyCode == Enum.KeyCode.F5 then
            Log("F5 pressionado - Executando benchmark", 1)
            RunBenchmark()
        end
    end)
    
    Log("Controles configurados", 4)
end

-- ============================================
-- SISTEMA DE BENCHMARK
-- ============================================

local function RunBenchmark()
    Log("Iniciando benchmark de performance...", 1)
    
    local startTime = tick()
    local initialFPS = workspace:GetRealPhysicsFPS()
    local initialMemory = Stats:GetTotalMemoryUsageMb()
    
    wait(5) -- Aguardar 5 segundos para medição
    
    local endTime = tick()
    local finalFPS = workspace:GetRealPhysicsFPS()
    local finalMemory = Stats:GetTotalMemoryUsageMb()
    
    local fpsImprovement = ((finalFPS - initialFPS) / initialFPS) * 100
    local memoryReduction = ((initialMemory - finalMemory) / initialMemory) * 100
    
    Log("=== RESULTADO DO BENCHMARK ===", 4)
    Log(string.format("FPS: %.0f → %.0f (%.1f%% melhoria)", initialFPS, finalFPS, fpsImprovement), 4)
    Log(string.format("RAM: %.0fMB → %.0fMB (%.1f%% redução)", initialMemory, finalMemory, memoryReduction), 4)
    Log("=============================", 4)
end

-- ============================================
-- LIMPEZA AUTOMÁTICA DE MEMÓRIA
-- ============================================

local function SetupMemoryOptimization()
    Log("Configurando limpeza automática de memória...", 1)
    
    spawn(function()
        while wait(30) do -- A cada 30 segundos
            collectgarbage("collect")
            local memory = math.floor(Stats:GetTotalMemoryUsageMb())
            Log(string.format("Memória limpa - Uso atual: %dMB", memory), 1)
        end
    end)
    
    Log("Limpeza automática de memória ativada", 4)
end

-- ============================================
-- OTIMIZAÇÃO DE REDE
-- ============================================

local function OptimizeNetwork()
    Log("Otimizando conexão de rede...", 1)
    
    -- Reduzir qualidade de streaming
    settings().Network.IncomingReplicationLag = 0
    
    Log("Rede otimizada", 4)
end

-- ============================================
-- INICIALIZAÇÃO PRINCIPAL
-- ============================================

function InitializeOptimizations()
    Log("🚀 INICIANDO BLOX FRUITS NO-LAG SCRIPT v1.2.0", 4)
    Log("Criado por: YTShadowBloxBR", 1)
    Log("GitHub: https://github.com/YT-Shadow/No-lag", 1)
    
    wait(1) -- Aguardar carregamento
    
    -- Executar todas as otimizações
    OptimizeGraphics()
    OptimizeParticles()
    OptimizeWater()
    OptimizeTextures()
    ApplyExtremeMode()
    SetupFPSLimiter()
    OptimizeNetwork()
    SetupMemoryOptimization()
    CreatePerformanceMonitor()
    SetupControls()
    
    -- Aguardar um pouco e executar benchmark
    wait(3)
    RunBenchmark()
    
    Log("✅ TODAS AS OTIMIZAÇÕES FORAM APLICADAS COM SUCESSO!", 4)
    Log("📊 Monitor de performance ativo (F2 para toggle)", 1)
    Log("⌨️ Controles: F1=Menu | F2=Monitor | F3=Extremo | F4=Reload | F5=Benchmark", 1)
    Log("🎮 Aproveite sua experiência otimizada no Blox Fruits!", 4)
    Log("⭐ Se gostou, deixe uma star no GitHub!", 1)
end

-- ============================================
-- EXECUTAR SCRIPT
-- ============================================

-- Verificação de segurança final
local success, error = pcall(function()
    InitializeOptimizations()
end)

if not success then
    warn("❌ Erro ao executar script:", error)
    warn("💬 Reporte este erro no Discord: https://discord.gg/gVkaxG7QqQ")
end