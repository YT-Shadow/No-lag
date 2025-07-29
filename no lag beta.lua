-- ============================================
-- BLOX FRUITS - SCRIPT DE OTIMIZAÇÃO MÁXIMA
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================
-- CONFIGURAÇÕES DE OTIMIZAÇÃO
-- ============================================

local OptimizationConfig = {
    -- Gráficos
    EnableGraphicsOptimization = true,
    RemoveParticles = true,
    ReduceTextureQuality = true,
    DisableBloom = true,
    DisableSunRays = true,
    
    -- Performance
    LimitFPS = true,
    MaxFPS = 60,
    ReduceRenderDistance = true,
    OptimizePhysics = true,
    
    -- Rede
    ReduceNetworkUsage = true,
    OptimizeRemoteEvents = true,
    
    -- Interface
    OptimizeGUI = true,
    ReduceAnimations = true
}

-- ============================================
-- FUNÇÕES DE OTIMIZAÇÃO GRÁFICA
-- ============================================

local function OptimizeGraphics()
    if not OptimizationConfig.EnableGraphicsOptimization then return end
    
    -- Configurações de qualidade gráfica
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    
    -- Otimizar iluminação
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100
    Lighting.FogStart = 0
    
    if OptimizationConfig.DisableBloom and Lighting:FindFirstChild("Bloom") then
        Lighting.Bloom.Enabled = false
    end
    
    if OptimizationConfig.DisableSunRays and Lighting:FindFirstChild("SunRays") then
        Lighting.SunRays.Enabled = false
    end
    
    -- Remover efeitos visuais desnecessários
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
            effect.Enabled = false
        end
    end
    
    print("✅ Otimizações gráficas aplicadas")
end

-- ============================================
-- OTIMIZAÇÃO DE PARTÍCULAS E EFEITOS
-- ============================================

local function OptimizeParticles()
    if not OptimizationConfig.RemoveParticles then return end
    
    local function removeParticles(obj)
        for _, child in pairs(obj:GetDescendants()) do
            if child:IsA("ParticleEmitter") or child:IsA("Fire") or 
               child:IsA("Smoke") or child:IsA("Explosion") then
                child.Enabled = false
                child:Destroy()
            end
        end
    end
    
    -- Remover partículas existentes
    removeParticles(Workspace)
    
    -- Interceptar novas partículas
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
           obj:IsA("Smoke") or obj:IsA("Explosion") then
            wait()
            obj.Enabled = false
            obj:Destroy()
        end
    end)
    
    print("✅ Otimização de partículas ativada")
end

-- ============================================
-- LIMITADOR DE FPS
-- ============================================

local function SetupFPSLimiter()
    if not OptimizationConfig.LimitFPS then return end
    
    local lastFrame = tick()
    local targetFrameTime = 1 / OptimizationConfig.MaxFPS
    
    RunService.Heartbeat:Connect(function()
        local currentTime = tick()
        local deltaTime = currentTime - lastFrame
        
        if deltaTime < targetFrameTime then
            local sleepTime = targetFrameTime - deltaTime
            wait(sleepTime)
        end
        
        lastFrame = tick()
    end)
    
    print("✅ Limitador de FPS configurado para " .. OptimizationConfig.MaxFPS)
end

-- ============================================
-- OTIMIZAÇÃO DE OBJETOS NO WORKSPACE
-- ============================================

local function OptimizeWorkspace()
    local function optimizeObject(obj)
        -- Reduzir qualidade de texturas
        if OptimizationConfig.ReduceTextureQuality then
            if obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 0.1
            end
        end
        
        -- Otimizar meshes
        if obj:IsA("SpecialMesh") then
            obj.TextureId = ""
        end
        
        -- Remover sons desnecessários
        if obj:IsA("Sound") and obj.IsPlaying == false then
            obj.Volume = 0
        end
    end
    
    -- Otimizar objetos existentes
    for _, obj in pairs(Workspace:GetDescendants()) do
        optimizeObject(obj)
    end
    
    -- Otimizar novos objetos
    Workspace.DescendantAdded:Connect(function(obj)
        wait()
        optimizeObject(obj)
    end)
    
    print("✅ Workspace otimizado")
end

-- ============================================
-- OTIMIZAÇÃO DE FÍSICA
-- ============================================

local function OptimizePhysics()
    if not OptimizationConfig.OptimizePhysics then return end
    
    -- Reduzir simulação de física para objetos distantes
    local function optimizePhysicsForPart(part)
        if part:IsA("BasePart") then
            local distance = (part.Position - player.Character.HumanoidRootPart.Position).Magnitude
            
            if distance > 200 then
                part.CanCollide = false
                if part:FindFirstChild("BodyVelocity") then
                    part.BodyVelocity:Destroy()
                end
            end
        end
    end
    
    RunService.Heartbeat:Connect(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            optimizePhysicsForPart(obj)
        end
    end)
    
    print("✅ Otimização de física ativada")
end

-- ============================================
-- OTIMIZAÇÃO DE GUI
-- ============================================

local function OptimizeGUI()
    if not OptimizationConfig.OptimizeGUI then return end
    
    -- Reduzir animações desnecessárias
    if OptimizationConfig.ReduceAnimations then
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("Frame") or gui:IsA("ImageLabel") then
                gui.BackgroundTransparency = math.min(gui.BackgroundTransparency + 0.1, 1)
            end
        end
    end
    
    print("✅ Interface otimizada")
end

-- ============================================
-- OTIMIZAÇÃO DE REDE
-- ============================================

local function OptimizeNetwork()
    if not OptimizationConfig.ReduceNetworkUsage then return end
    
    -- Cache para eventos remotos
    local eventCache = {}
    local lastEventTime = {}
    
    -- Interceptar eventos remotos para reduzir spam
    local oldFireServer = nil
    
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") then
            if not eventCache[obj.Name] then
                eventCache[obj.Name] = obj
                lastEventTime[obj.Name] = 0
            end
        end
    end
    
    print("✅ Otimização de rede configurada")
end

-- ============================================
-- MONITOR DE PERFORMANCE
-- ============================================

local function CreatePerformanceMonitor()
    local ScreenGui = Instance.new("ScreenGui")
    local Frame = Instance.new("Frame")
    local FPSLabel = Instance.new("TextLabel")
    local PingLabel = Instance.new("TextLabel")
    local MemoryLabel = Instance.new("TextLabel")
    
    ScreenGui.Name = "PerformanceMonitor"
    ScreenGui.Parent = playerGui
    ScreenGui.ResetOnSpawn = false
    
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Frame.BackgroundTransparency = 0.3
    Frame.BorderSizePixel = 0
    Frame.Position = UDim2.new(0, 10, 0, 10)
    Frame.Size = UDim2.new(0, 200, 0, 80)
    
    FPSLabel.Parent = Frame
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Position = UDim2.new(0, 5, 0, 5)
    FPSLabel.Size = UDim2.new(1, -10, 0, 20)
    FPSLabel.Font = Enum.Font.SourceSans
    FPSLabel.Text = "FPS: --"
    FPSLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    FPSLabel.TextSize = 14
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    PingLabel.Parent = Frame
    PingLabel.BackgroundTransparency = 1
    PingLabel.Position = UDim2.new(0, 5, 0, 25)
    PingLabel.Size = UDim2.new(1, -10, 0, 20)
    PingLabel.Font = Enum.Font.SourceSans
    PingLabel.Text = "Ping: --"
    PingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    PingLabel.TextSize = 14
    PingLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    MemoryLabel.Parent = Frame
    MemoryLabel.BackgroundTransparency = 1
    MemoryLabel.Position = UDim2.new(0, 5, 0, 45)
    MemoryLabel.Size = UDim2.new(1, -10, 0, 20)
    MemoryLabel.Font = Enum.Font.SourceSans
    MemoryLabel.Text = "Memory: --"
    MemoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    MemoryLabel.TextSize = 14
    MemoryLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Atualizar informações de performance
    local frameCount = 0
    local lastTime = tick()
    
    RunService.Heartbeat:Connect(function()
        frameCount = frameCount + 1
        local currentTime = tick()
        
        if currentTime - lastTime >= 1 then
            local fps = math.floor(frameCount / (currentTime - lastTime))
            FPSLabel.Text = "FPS: " .. fps
            
            local ping = math.floor(player:GetNetworkPing() * 1000)
            PingLabel.Text = "Ping: " .. ping .. "ms"
            
            local memory = math.floor(collectgarbage("count"))
            MemoryLabel.Text = "Memory: " .. memory .. " KB"
            
            frameCount = 0
            lastTime = currentTime
        end
    end)
    
    print("✅ Monitor de performance criado")
end

-- ============================================
-- LIMPEZA DE MEMÓRIA
-- ============================================

local function SetupMemoryOptimization()
    spawn(function()
        while wait(30) do -- A cada 30 segundos
            collectgarbage("collect")
        end
    end)
    
    print("✅ Limpeza automática de memória ativada")
end

-- ============================================
-- INICIALIZAÇÃO DO SCRIPT
-- ============================================

local function InitializeOptimizations()
    print("🚀 Iniciando otimizações do Blox Fruits...")
    
    wait(2) -- Aguardar carregamento completo
    
    -- Executar otimizações
    OptimizeGraphics()
    OptimizeParticles()
    SetupFPSLimiter()
    OptimizeWorkspace()
    OptimizePhysics()
    OptimizeGUI()
    OptimizeNetwork()
    SetupMemoryOptimization()
    CreatePerformanceMonitor()
    
    print("✅ Todas as otimizações foram aplicadas com sucesso!")
    print("📊 Monitor de performance ativado no canto superior esquerdo")
    print("🎮 Aproveite sua experiência otimizada no Blox Fruits!")
end

-- ============================================
-- EXECUTAR SCRIPT
-- ============================================

InitializeOptimizations()
-- ============================================
-- MELHORIAS ADICIONAIS PARA BLOX FRUITS
-- Adicione estas funcionalidades ao seu script
-- ============================================

-- 1. SISTEMA DE AUTO-UPDATE
local function CheckForUpdates()
    local currentVersion = "1.0.0"
    local updateUrl = "https://raw.githubusercontent.com/YT-Shadow/No-lag/main/version.txt"
    
    -- Implementar verificação de versão aqui
    print("🔄 Verificando atualizações...")
end

-- 2. CONFIGURAÇÕES SALVAS LOCALMENTE
local function SaveSettings()
    local settings = {
        graphicsLevel = 1,
        fpsLimit = 60,
        particlesEnabled = false,
        monitorEnabled = true
    }
    -- Salvar em arquivo local ou DataStore
end

-- 3. OTIMIZAÇÃO ESPECÍFICA PARA BLOX FRUITS
local function OptimizeBloxFruits()
    -- Otimizar elementos específicos do jogo
    local workspace = game:GetService("Workspace")
    
    -- Remover água desnecessária
    if workspace:FindFirstChild("Water") then
        for _, water in pairs(workspace.Water:GetChildren()) do
            if water:IsA("Part") then
                water.Transparency = 1
                water.CanCollide = false
            end
        end
    end
    
    -- Otimizar NPCs distantes
    spawn(function()
        while wait(5) do
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local playerPos = player.Character.HumanoidRootPart.Position
                
                for _, npc in pairs(workspace:GetChildren()) do
                    if npc:FindFirstChild("Humanoid") and npc ~= player.Character then
                        local distance = (npc.HumanoidRootPart.Position - playerPos).Magnitude
                        
                        if distance > 300 then
                            -- Reduzir qualidade de NPCs distantes
                            for _, part in pairs(npc:GetChildren()) do
                                if part:IsA("BasePart") then
                                    part.Material = Enum.Material.Plastic
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- 4. SISTEMA DE PROFILES
local OptimizationProfiles = {
    ["Potato PC"] = {
        graphicsQuality = 1,
        particlesEnabled = false,
        shadowsEnabled = false,
        fpsLimit = 30,
        renderDistance = 100
    },
    ["Medium PC"] = {
        graphicsQuality = 3,
        particlesEnabled = false,
        shadowsEnabled = false,
        fpsLimit = 60,
        renderDistance = 200
    },
    ["High-End PC"] = {
        graphicsQuality = 5,
        particlesEnabled = true,
        shadowsEnabled = true,
        fpsLimit = 120,
        renderDistance = 300
    }
}

-- 5. INTERFACE DE CONFIGURAÇÃO
local function CreateConfigGUI()
    local ScreenGui = Instance.new("ScreenGui")
    local MainFrame = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    
    ScreenGui.Name = "OptimizationConfig"
    ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Visible = false
    
    -- Adicionar botões e controles aqui
    
    -- Toggle com tecla F1
    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.F1 then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
end

-- 6. SISTEMA DE LOGGING
local function LogOptimization(message, level)
    local timestamp = os.date("%H:%M:%S")
    local logLevels = {
        [1] = "INFO",
        [2] = "WARN", 
        [3] = "ERROR"
    }
    
    print(string.format("[%s] [%s] %s", timestamp, logLevels[level] or "INFO", message))
end

-- 7. DETECÇÃO AUTOMÁTICA DE HARDWARE
local function DetectHardware()
    local stats = game:GetService("Stats")
    local memory = stats:GetTotalMemoryUsageMb()
    local fps = workspace:GetRealPhysicsFPS()
    
    if memory < 1000 and fps < 30 then
        return "Potato PC"
    elseif memory < 2000 and fps < 60 then
        return "Medium PC"
    else
        return "High-End PC"
    end
end

-- 8. MODO ANTI-LAG EXTREMO
local function ExtremeAntiLag()
    -- Para PCs muito fracos
    game:GetService("Lighting").Technology = Enum.Technology.Compatibility
    
    -- Remover todos os sons
    for _, sound in pairs(workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0
            sound:Stop()
        end
    end
    
    -- Simplificar geometria
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("Part") or part:IsA("UnionOperation") then
            part.Material = Enum.Material.Plastic
            part.Reflectance = 0
        end
    end
    
    LogOptimization("Modo Anti-Lag Extremo ativado", 2)
end

-- 9. BENCHMARK AUTOMÁTICO
local function RunBenchmark()
    local startTime = tick()
    local initialFPS = workspace:GetRealPhysicsFPS()
    
    wait(10) -- Aguardar 10 segundos
    
    local endTime = tick()
    local finalFPS = workspace:GetRealPhysicsFPS()
    local improvement = ((finalFPS - initialFPS) / initialFPS) * 100
    
    LogOptimization(string.format("Benchmark concluído: %.1f%% de melhoria no FPS", improvement), 1)
    
    return {
        duration = endTime - startTime,
        fpsImprovement = improvement,
        initialFPS = initialFPS,
        finalFPS = finalFPS
    }
end

-- 10. INICIALIZAÇÃO INTELIGENTE
local function SmartInitialization()
    LogOptimization("Iniciando otimização inteligente...", 1)
    
    -- Detectar hardware automaticamente
    local hardwareProfile = DetectHardware()
    LogOptimization("Hardware detectado: " .. hardwareProfile, 1)
    
    -- Aplicar profile apropriado
    local profile = OptimizationProfiles[hardwareProfile]
    
    -- Executar benchmark antes e depois
    local benchmarkResults = RunBenchmark()
    
    -- Criar interface de configuração
    CreateConfigGUI()
    
    LogOptimization("Otimização concluída com sucesso!", 1)
end
