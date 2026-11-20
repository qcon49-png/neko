
-- [[ NEKO HUB — ULTRA EXTREME FPS v3 ]]
-- LOW-END ANDROID / LOW RAM / GPU LOAD REDUCTION

local P   = game:GetService("Players")
local RS  = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local T   = game:GetService("TweenService")
local L   = game:GetService("Lighting")
local ST  = game:GetService("Stats")
local SG  = game:GetService("StarterGui")

local pl = P.LocalPlayer

local ACCENT  = Color3.fromRGB(0, 240, 255)
local BG_MAIN = Color3.fromRGB(13, 16, 23)
local BG_SEC  = Color3.fromRGB(20, 25, 35)
local BG_CARD = Color3.fromRGB(26, 32, 46)
local TXT     = Color3.fromRGB(235, 240, 245)
local TXT_DIM = Color3.fromRGB(120, 135, 155)
local GREEN   = Color3.fromRGB(0, 255, 150)
local YEL     = Color3.fromRGB(255, 200, 80)
local RED     = Color3.fromRGB(255, 75, 95)

local tg = {fps = false}

if _G.__NEKO_FPS_CLEANUP then
    pcall(_G.__NEKO_FPS_CLEANUP)
    _G.__NEKO_FPS_CLEANUP = nil
end

-- =====================================================
-- EXTREME FPS CORE
-- =====================================================

local fpsSaved = setmetatable({}, {__mode = "k"})
local fpsQueue = {}

local queueHead = 1
local queueTail = 0

local fpsDescConn
local fpsLightConn

local fpsGlobals = {}

local MAX_QUEUE = 4000
local BUDGET = 12
local SCAN_BATCH = 40
local SCAN_DELAY = 0.03

local connections = {}
local running = true

local function addConnection(conn)
    connections[#connections + 1] = conn
    return conn
end

local function fpsRemember(obj, prop)
    if not obj or not obj.Parent then return end

    local bucket = fpsSaved[obj]

    if not bucket then
        bucket = {}
        fpsSaved[obj] = bucket
    end

    if bucket[prop] == nil then
        local ok, old = pcall(function()
            return obj[prop]
        end)

        if ok then
            bucket[prop] = old
        end
    end
end

local function fpsSet(obj, prop, value)
    fpsRemember(obj, prop)

    pcall(function()
        obj[prop] = value
    end)
end

local function queueClear()
    table.clear(fpsQueue)
    queueHead = 1
    queueTail = 0
end

local function queuePush(obj)
    if not obj or not obj.Parent then return end

    if queueTail - queueHead + 1 >= MAX_QUEUE then
        return
    end

    queueTail += 1
    fpsQueue[queueTail] = obj
end

local function queuePop()
    if queueHead > queueTail then
        return nil
    end

    local obj = fpsQueue[queueHead]
    fpsQueue[queueHead] = nil
    queueHead += 1

    if queueHead > queueTail then
        queueClear()
    end

    return obj
end

local function fpsOptimizeObject(obj)
    if not tg.fps or not obj or not obj.Parent then
        return
    end

    local myChar = pl.Character

    if myChar and obj:IsDescendantOf(myChar) then
        return
    end

    if obj:IsA("ParticleEmitter")
        or obj:IsA("Trail")
        or obj:IsA("Beam")
        or obj:IsA("Fire")
        or obj:IsA("Smoke")
        or obj:IsA("Sparkles")
        or obj:IsA("Explosion") then

        fpsSet(obj, "Enabled", false)

    elseif obj:IsA("Light") then

        fpsSet(obj, "Enabled", false)

    elseif obj:IsA("PostEffect") then

        fpsSet(obj, "Enabled", false)

    elseif obj:IsA("Highlight") then

        fpsSet(obj, "Enabled", false)

    elseif obj:IsA("SelectionBox")
        or obj:IsA("SelectionSphere")
        or obj:IsA("BoxHandleAdornment")
        or obj:IsA("CylinderHandleAdornment")
        or obj:IsA("SphereHandleAdornment")
        or obj:IsA("LineHandleAdornment")
        or obj:IsA("ImageHandleAdornment") then

        fpsSet(obj, "Visible", false)

    elseif obj:IsA("Atmosphere") then

        fpsSet(obj, "Density", 0)
        fpsSet(obj, "Haze", 0)
        fpsSet(obj, "Glare", 0)

    elseif obj:IsA("Sky") then

        fpsSet(obj, "StarCount", 0)
        fpsSet(obj, "CelestialBodiesShown", false)
        fpsSet(obj, "SunAngularSize", 0)
        fpsSet(obj, "MoonAngularSize", 0)

    elseif obj:IsA("Clouds") then

        fpsSet(obj, "Enabled", false)
        fpsSet(obj, "Cover", 0)
        fpsSet(obj, "Density", 0)

    elseif obj:IsA("Decal") or obj:IsA("Texture") then

        fpsSet(obj, "Transparency", 1)

    elseif obj:IsA("SurfaceGui") or obj:IsA("BillboardGui") then

        fpsSet(obj, "Enabled", false)

    elseif obj:IsA("MeshPart") then

        fpsSet(obj, "RenderFidelity", Enum.RenderFidelity.Performance)
        fpsSet(obj, "DoubleSided", false)
        fpsSet(obj, "CastShadow", false)
        fpsSet(obj, "Reflectance", 0)
        fpsSet(obj, "Material", Enum.Material.SmoothPlastic)

    elseif obj:IsA("BasePart") then

        fpsSet(obj, "CastShadow", false)
        fpsSet(obj, "Reflectance", 0)
        fpsSet(obj, "Material", Enum.Material.SmoothPlastic)
    end
end

-- =====================================================
-- GLOBAL GRAPHICS REDUCTION
-- =====================================================

local function fpsApplyGlobals()

    local terrain = workspace:FindFirstChildOfClass("Terrain")

    if terrain then
        fpsGlobals.Terrain = {
            Decoration = terrain.Decoration,
            WaterWaveSize = terrain.WaterWaveSize,
            WaterWaveSpeed = terrain.WaterWaveSpeed,
            WaterReflectance = terrain.WaterReflectance,
            WaterTransparency = terrain.WaterTransparency,
        }

        pcall(function()
            terrain.Decoration = false
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end)
    end

    pcall(function()
        fpsGlobals.GlobalWind = workspace.GlobalWind
        workspace.GlobalWind = Vector3.zero
    end)

    fpsGlobals.Lighting = {
        GlobalShadows = L.GlobalShadows,
        ShadowSoftness = L.ShadowSoftness,
        EnvironmentDiffuseScale = L.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = L.EnvironmentSpecularScale,
    }

    pcall(function()
        L.GlobalShadows = false
        L.ShadowSoftness = 0
        L.EnvironmentDiffuseScale = 0
        L.EnvironmentSpecularScale = 0
    end)

    pcall(function()
        fpsGlobals.CoreGuiAll =
            SG:GetCoreGuiEnabled(Enum.CoreGuiType.All)

        SG:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)
    end)

    pcall(function()
        local ugs =
            game:GetService("UserSettings"):GetService("UserGameSettings")

        fpsGlobals.SavedQuality = ugs.SavedQualityLevel
        ugs.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)

    pcall(function()
        if settings and settings().Rendering then
            local rs = settings().Rendering

            fpsGlobals.RenderSettings = {}

            for _, k in ipairs({
                "QualityLevel",
                "MeshPartDetail"
            }) do

                local ok, value = pcall(function()
                    return rs[k]
                end)

                if ok then
                    fpsGlobals.RenderSettings[k] = value
                end
            end

            pcall(function()
                rs.QualityLevel = Enum.QualityLevel.Level01
                rs.MeshPartDetail = Enum.MeshDetailLevel.Level01
            end)
        end
    end)

    pcall(function()
        if setfflag then
            setfflag("DFIntDebugFRMQualityLevelOverride", "1")
            setfflag("FFlagFastGPULightCulling3", "true")
            setfflag("FFlagRenderFixFog", "true")
            setfflag("DFIntS2PhysicsSenderRate", "10")
        end
    end)
end

local function fpsRestoreGlobals()

    if fpsGlobals.Terrain then
        local terrain = workspace:FindFirstChildOfClass("Terrain")

        if terrain then
            for k, v in pairs(fpsGlobals.Terrain) do
                pcall(function()
                    terrain[k] = v
                end)
            end
        end
    end

    if fpsGlobals.GlobalWind then
        pcall(function()
            workspace.GlobalWind = fpsGlobals.GlobalWind
        end)
    end

    if fpsGlobals.Lighting then
        for k, v in pairs(fpsGlobals.Lighting) do
            pcall(function()
                L[k] = v
            end)
        end
    end

    if fpsGlobals.CoreGuiAll ~= nil then
        pcall(function()
            SG:SetCoreGuiEnabled(
                Enum.CoreGuiType.All,
                fpsGlobals.CoreGuiAll
            )
        end)
    end

    if fpsGlobals.SavedQuality then
        pcall(function()
            game:GetService("UserSettings")
                :GetService("UserGameSettings")
                .SavedQualityLevel = fpsGlobals.SavedQuality
        end)
    end

    if fpsGlobals.RenderSettings then
        pcall(function()
            if settings and settings().Rendering then
                local rs = settings().Rendering

                for k, v in pairs(fpsGlobals.RenderSettings) do
                    pcall(function()
                        rs[k] = v
                    end)
                end
            end
        end)
    end

    fpsGlobals = {}
end

-- =====================================================
-- QUEUE WORKER
-- =====================================================

addConnection(RS.Heartbeat:Connect(function()

    if not tg.fps then return end

    local processed = 0

    while processed < BUDGET and queueHead <= queueTail do

        local obj = queuePop()

        if obj and obj.Parent then
            fpsOptimizeObject(obj)
        end

        processed += 1
    end

end))

-- =====================================================
-- INITIAL SCAN
-- =====================================================

local function fpsScan(list)

    for i = 1, #list do

        if not tg.fps or not running then
            break
        end

        local obj = list[i]

        if obj and obj.Parent then
            fpsOptimizeObject(obj)
        end

        if i % SCAN_BATCH == 0 then
            task.wait(SCAN_DELAY)
        end
    end

    table.clear(list)
end

-- =====================================================
-- FPS TOGGLE
-- =====================================================

local function setFPSBoost(enabled)

    tg.fps = enabled

    if enabled then

        queueClear()

        fpsApplyGlobals()

        if fpsDescConn then
            fpsDescConn:Disconnect()
        end

        fpsDescConn = workspace.DescendantAdded:Connect(function(obj)

            if not tg.fps then return end

            local myChar = pl.Character

            if myChar and obj:IsDescendantOf(myChar) then
                return
            end

            queuePush(obj)
        end)

        if fpsLightConn then
            fpsLightConn:Disconnect()
        end

        fpsLightConn = L.DescendantAdded:Connect(function(obj)

            if not tg.fps then return end

            queuePush(obj)
        end)

        task.spawn(function()

            if not tg.fps then return end

            local list = workspace:GetDescendants()
            fpsScan(list)

            if not tg.fps then return end

            local lightingList = L:GetDescendants()
            fpsScan(lightingList)

        end)

    else

        if fpsDescConn then
            fpsDescConn:Disconnect()
            fpsDescConn = nil
        end

        if fpsLightConn then
            fpsLightConn:Disconnect()
            fpsLightConn = nil
        end

        queueClear()

        task.spawn(function()

            local count = 0

            for obj, props in pairs(fpsSaved) do

                if not obj.Parent then
                    fpsSaved[obj] = nil
                else

                    for prop, old in pairs(props) do
                        pcall(function()
                            obj[prop] = old
                        end)
                    end

                    count += 1

                    if count % 100 == 0 then
                        task.wait(0.03)
                    end
                end
            end

            table.clear(fpsSaved)

            fpsRestoreGlobals()

        end)
    end
end

-- =====================================================
-- GUI
-- =====================================================

local gp = (gethui and gethui()) or game:GetService("CoreGui")

pcall(function()
    local old = gp:FindFirstChild("NekoFPSUI")

    if old then
        old:Destroy()
    end
end)

local sg = Instance.new("ScreenGui")
sg.Name = "NekoFPSUI"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 9999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = gp

-- =====================================================
-- FPS BUTTON
-- =====================================================

local btn = Instance.new("TextButton")

btn.Size = UDim2.fromOffset(240, 46)
btn.Position = UDim2.new(0, 15, 0.5, -23)
btn.BackgroundColor3 = BG_CARD
btn.Text = "   ULTRA FPS  •  Tối đa tốc độ"
btn.TextColor3 = TXT
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.Font = Enum.Font.GothamMedium
btn.TextSize = 12
btn.AutoButtonColor = false
btn.Active = true
btn.Parent = sg

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

local stroke = Instance.new("UIStroke", btn)
stroke.Color = ACCENT
stroke.Thickness = 1
stroke.Transparency = 0.4

local ind = Instance.new("Frame", btn)

ind.Size = UDim2.new(0, 36, 0, 18)
ind.Position = UDim2.new(1, -44, 0.5, -9)
ind.BackgroundColor3 = BG_SEC

Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

local dot = Instance.new("Frame", ind)

dot.Size = UDim2.new(0, 12, 0, 12)
dot.Position = UDim2.new(0, 4, 0.5, -6)
dot.BackgroundColor3 = TXT_DIM

Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

local fpsState = false

local function applyToggle()

    fpsState = not fpsState

    T:Create(ind, TweenInfo.new(0.2), {
        BackgroundColor3 = fpsState and ACCENT or BG_SEC
    }):Play()

    T:Create(dot, TweenInfo.new(0.2), {
        Position = UDim2.new(
            0,
            fpsState and 20 or 4,
            0.5,
            -6
        ),

        BackgroundColor3 = fpsState and BG_MAIN or TXT_DIM
    }):Play()

    setFPSBoost(fpsState)
end

-- =====================================================
-- BUTTON DRAG
-- =====================================================

local isDragging = false
local moved = false

local dragStart
local startPos

local DRAG_THRESHOLD = 6

addConnection(btn.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        isDragging = true
        moved = false

        dragStart = input.Position
        startPos = btn.Position
    end
end))

addConnection(UIS.InputChanged:Connect(function(input)

    if isDragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - dragStart

        if delta.Magnitude > DRAG_THRESHOLD then
            moved = true
        end

        btn.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end))

addConnection(UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        if isDragging then

            isDragging = false

            if not moved then
                applyToggle()
            end
        end
    end
end))

-- =====================================================
-- STATS BAR
-- =====================================================

local statsExpanded = false

local statsPanel = Instance.new("Frame", sg)

statsPanel.Size = UDim2.new(0, 160, 0, 30)
statsPanel.Position = UDim2.new(0.5, 0, 0, 8)
statsPanel.AnchorPoint = Vector2.new(0.5, 0)
statsPanel.BackgroundColor3 = BG_MAIN
statsPanel.BackgroundTransparency = 0.15
statsPanel.BorderSizePixel = 0
statsPanel.ZIndex = 100

Instance.new("UICorner", statsPanel).CornerRadius = UDim.new(0, 8)

local spStroke = Instance.new("UIStroke", statsPanel)
spStroke.Color = ACCENT
spStroke.Thickness = 1
spStroke.Transparency = 0.3

local grip = Instance.new("Frame", statsPanel)

grip.Size = UDim2.new(0, 12, 1, -8)
grip.Position = UDim2.new(0, 4, 0, 4)
grip.BackgroundColor3 = ACCENT
grip.BackgroundTransparency = 0.55
grip.BorderSizePixel = 0
grip.ZIndex = 100

Instance.new("UICorner", grip).CornerRadius = UDim.new(0, 3)

local statsLbl = Instance.new("TextLabel", statsPanel)

statsLbl.Size = UDim2.new(1, -55, 1, 0)
statsLbl.Position = UDim2.new(0, 22, 0, 0)
statsLbl.BackgroundTransparency = 1
statsLbl.Text = "FPS --"
statsLbl.TextColor3 = ACCENT
statsLbl.Font = Enum.Font.GothamBold
statsLbl.TextSize = 11
statsLbl.TextXAlignment = Enum.TextXAlignment.Left
statsLbl.ZIndex = 101

local statsToggle = Instance.new("TextButton", statsPanel)

statsToggle.Size = UDim2.new(0, 26, 0, 22)
statsToggle.Position = UDim2.new(1, -30, 0.5, -11)
statsToggle.BackgroundColor3 = BG_SEC
statsToggle.Text = "▼"
statsToggle.TextColor3 = ACCENT
statsToggle.Font = Enum.Font.GothamBold
statsToggle.TextSize = 12
statsToggle.AutoButtonColor = false
statsToggle.ZIndex = 102

Instance.new("UICorner", statsToggle).CornerRadius = UDim.new(0, 5)

local function applyStatsState()

    statsExpanded = not statsExpanded

    local cam = workspace.CurrentCamera

    local vp = (cam and cam.ViewportSize)
        or Vector2.new(800, 600)

    local targetW = statsExpanded
        and math.max(160, math.min(560, vp.X - 24))
        or 160

    T:Create(statsPanel, TweenInfo.new(0.2), {
        Size = UDim2.new(0, targetW, 0, 30)
    }):Play()

    statsToggle.Text = statsExpanded and "▲" or "▼"
    statsLbl.TextSize = statsExpanded and 10 or 11
end

addConnection(statsToggle.MouseButton1Click:Connect(applyStatsState))

-- =====================================================
-- STATS DRAG
-- =====================================================

local gripDrag = false

local gripStart
local panelStart

addConnection(grip.InputBegan:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        gripDrag = true
        gripStart = input.Position
        panelStart = statsPanel.Position
    end
end))

addConnection(UIS.InputChanged:Connect(function(input)

    if gripDrag and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then

        local delta = input.Position - gripStart

        statsPanel.Position = UDim2.new(
            panelStart.X.Scale,
            panelStart.X.Offset + delta.X,
            panelStart.Y.Scale,
            panelStart.Y.Offset + delta.Y
        )
    end
end))

addConnection(UIS.InputEnded:Connect(function(input)

    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        gripDrag = false
    end
end))

-- =====================================================
-- FPS COUNTER
-- =====================================================

local frameCount = 0

addConnection(RS.RenderStepped:Connect(function()
    frameCount += 1
end))

task.spawn(function()

    while running and sg.Parent do

        task.wait(0.5)

        if not running or not sg.Parent then
            break
        end

        local fps = frameCount * 2
        frameCount = 0

        local ft = fps > 0 and (1000 / fps) or 0

        local ping = 0

        pcall(function()
            ping = math.floor(pl:GetNetworkPing() * 1000)
        end)

        local lat = tostring(ping) .. "ms"

        pcall(function()

            local node = ST.Network.ServerStatsItem["Data Ping"]

            if node then
                local ok, value = pcall(function()
                    return node:GetValueString()
                end)

                if ok and value then
                    lat = value
                end
            end
        end)

        local mem = 0

        pcall(function()
            mem = ST:GetTotalMemoryUsageMB()
        end)

        local therm = 38
            + math.clamp((ft - 16.7) * 0.55, 0, 42)
            + math.clamp((mem - 400) / 200, 0, 15)

        therm = math.floor(math.clamp(therm, 35, 95))

        local fpsColor =
            (fps >= 50 and GREEN)
            or (fps >= 30 and YEL)
            or RED

        local thermColor =
            (therm < 55 and GREEN)
            or (therm < 75 and YEL)
            or RED

        if statsExpanded then

            statsLbl.Text = string.format(
                "FPS %d | FT %.1fms | PING %d | LAT %s | TEMP~ %d°C | %dMB",
                fps,
                ft,
                ping,
                lat,
                therm,
                math.floor(mem)
            )

            statsLbl.TextColor3 = fpsColor
            spStroke.Color = thermColor

        else

            statsLbl.Text = string.format(
                "FPS %d | TEMP~%d°C",
                fps,
                therm
            )

            statsLbl.TextColor3 = fpsColor
            spStroke.Color = thermColor
        end
    end
end)

-- =====================================================
-- CLEANUP
-- =====================================================

_G.__NEKO_FPS_CLEANUP = function()

    running = false

    if tg.fps then
        setFPSBoost(false)
    end

    if fpsDescConn then
        fpsDescConn:Disconnect()
        fpsDescConn = nil
    end

    if fpsLightConn then
        fpsLightConn:Disconnect()
        fpsLightConn = nil
    end

    for _, conn in ipairs(connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end

    table.clear(connections)
    queueClear()

    if sg and sg.Parent then
        sg:Destroy()
    end
end

print("[NEKO] ULTRA EXTREME FPS v3 LOADED")
