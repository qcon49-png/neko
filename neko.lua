local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local L = game:GetService("Lighting")
local TS = game:GetService("TeleportService")
local ST = game:GetService("Stats")

local ok, err = pcall(function()
local pl = P.LocalPlayer
local cam = workspace.CurrentCamera

-- Bảng màu
local ACCENT = Color3.fromRGB(0, 240, 255)
local BG_MAIN = Color3.fromRGB(13, 16, 23)
local BG_SEC = Color3.fromRGB(20, 25, 35)
local BG_CARD = Color3.fromRGB(26, 32, 46)
local TXT = Color3.fromRGB(235, 240, 245)
local TXT_DIM = Color3.fromRGB(120, 135, 155)
local RED = Color3.fromRGB(255, 75, 95)
local GREEN = Color3.fromRGB(0, 255, 150)
local YEL = Color3.fromRGB(255, 200, 80)

local gp = gethui and gethui() or game:GetService("CoreGui")
pcall(function()
    if gp:FindFirstChild("NekoModern") then gp.NekoModern:Destroy() end
end)

local sg = Instance.new("ScreenGui")
sg.Name = "NekoModern"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 9999
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Fix lỗi UI đen
sg.Parent = gp

local stt = {ws = 16, jp = 50}
local tg = {esp = false, noclip = false, fps = false, infJump = false, aimlock = false, autoFly = false}
local spinState = {on = false, speed = 5}
local autoFlyStiffness = 50
local spinAccum = 0

-- ESP System
local espTable = {}
RS.RenderStepped:Connect(function()
    for p, data in pairs(espTable) do
        if not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            if data.bb then data.bb:Destroy() end
            espTable[p] = nil
        else
            local char = p.Character
            local hrp = char.HumanoidRootPart
            local head = char:FindFirstChild("Head") or hrp
            local hum = char:FindFirstChildOfClass("Humanoid")

            if tg.esp and hum and hum.Health > 0 then
                if not data.bb then
                    data.bb = Instance.new("BillboardGui", gp)
                    data.bb.Adornee = head
                    data.bb.Size = UDim2.new(0, 140, 0, 40)
                    data.bb.StudsOffset = Vector3.new(0, 2.8, 0)
                    data.bb.AlwaysOnTop = true
                    
                    data.mainF = Instance.new("Frame", data.bb)
                    data.mainF.Size = UDim2.new(1, 0, 1, 0)
                    data.mainF.BackgroundTransparency = 0.4
                    data.mainF.BackgroundColor3 = BG_MAIN
                    Instance.new("UICorner", data.mainF).CornerRadius = UDim.new(0, 6)
                    local stroke = Instance.new("UIStroke", data.mainF)
                    stroke.Color = ACCENT
                    stroke.Thickness = 1

                    data.txtCol = Instance.new("TextLabel", data.mainF)
                    data.txtCol.Size = UDim2.new(1, 0, 0.5, 0)
                    data.txtCol.Position = UDim2.new(0, 0, 0, 2)
                    data.txtCol.BackgroundTransparency = 1
                    data.txtCol.TextColor3 = ACCENT
                    data.txtCol.Font = Enum.Font.GothamBold
                    data.txtCol.TextSize = 11
                    data.txtCol.TextXAlignment = Enum.TextXAlignment.Center

                    data.hpBg = Instance.new("Frame", data.mainF)
                    data.hpBg.Size = UDim2.new(0.8, 0, 0, 8)
                    data.hpBg.Position = UDim2.new(0.1, 0, 0.65, 0)
                    data.hpBg.BackgroundColor3 = BG_SEC
                    data.hpBg.BorderSizePixel = 0
                    Instance.new("UICorner", data.hpBg).CornerRadius = UDim.new(1, 0)

                    data.hpFill = Instance.new("Frame", data.hpBg)
                    data.hpFill.Size = UDim2.new(1, 0, 1, 0)
                    data.hpFill.BackgroundColor3 = GREEN
                    data.hpFill.BorderSizePixel = 0
                    Instance.new("UICorner", data.hpFill).CornerRadius = UDim.new(1, 0)
                end

                local dist = math.floor((hrp.Position - pl.Character.HumanoidRootPart.Position).Magnitude / 3.57)
                data.txtCol.Text = p.Name .. " [" .. dist .. "m]"
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                data.hpFill.Size = UDim2.new(pct, 0, 1, 0)
                data.hpFill.BackgroundColor3 = pct > 0.5 and GREEN or RED
                data.bb.Enabled = true
            else
                if data.bb then data.bb.Enabled = false end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= pl and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not espTable[p] then
                espTable[p] = {}
            end
        end
    end
end)

-- Aimlock (Gần nhất & Vào đầu)
RS.RenderStepped:Connect(function()
    if not tg.aimlock then return end
    local myChar = pl.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end

    local closestHead = nil
    local shortestDist = math.huge

    for _, player in ipairs(P:GetPlayers()) do
        if player ~= pl and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and head then
                local d = (head.Position - myHrp.Position).Magnitude
                if d < shortestDist then
                    shortestDist = d
                    closestHead = head
                end
            end
        end
    end
    if closestHead then
        cam.CFrame = CFrame.new(cam.CFrame.Position, closestHead.Position)
    end
end)

-- Background Loops
RS.Heartbeat:Connect(function(dt)
    local c = pl.Character 
    local h = c and c:FindFirstChildOfClass("Humanoid") 
    local hr = c and c:FindFirstChild("HumanoidRootPart")

    if h and hr and h.Health > 0 then
        if stt.ws > 16 then 
            local md = h.MoveDirection 
            if md.Magnitude > 0.1 then 
                hr.AssemblyLinearVelocity = Vector3.new(md.Unit.X * stt.ws, hr.AssemblyLinearVelocity.Y, md.Unit.Z * stt.ws) 
            end 
        end
        if stt.jp > 50 then h.UseJumpPower = true h.JumpPower = stt.jp end
        
        -- Spin Bot
        if spinState.on then 
            spinAccum = spinAccum + math.rad(spinState.speed * 360) * 0.016 
            hr.CFrame = CFrame.new(hr.Position) * CFrame.Angles(0, spinAccum, 0) 
        end
    end
    
    -- Auto Fly
    if tg.autoFly then
        local myHR = c and c:FindFirstChild("HumanoidRootPart") 
        if myHR and h then
            local closestP = nil
            local minDist = math.huge
            for _, p in ipairs(P:GetPlayers()) do
                if p ~= pl and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (p.Character.HumanoidRootPart.Position - myHR.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closestP = p.Character.HumanoidRootPart
                    end
                end
            end
            if closestP then
                h.PlatformStand = true
                local desired = closestP.Position + Vector3.new(0, 4, 0)
                local newPos = myHR.Position:Lerp(desired, 1 - math.exp(-autoFlyStiffness * dt))
                myHR.CFrame = CFrame.lookAt(newPos, closestP.Position)
                myHR.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

RS.Stepped:Connect(function()
    if tg.noclip and pl.Character then 
        for _, p in ipairs(pl.Character:GetDescendants()) do 
            if p:IsA("BasePart") then p.CanCollide = false end 
        end 
    end
end)

-- UI DESIGN
local toggleBtn = Instance.new("Frame", sg)
toggleBtn.Size = UDim2.new(0, 52, 0, 52)
toggleBtn.Position = UDim2.new(0, 20, 0.35, 0)
toggleBtn.BackgroundColor3 = BG_MAIN
toggleBtn.BorderSizePixel = 0
toggleBtn.Active = true
toggleBtn.ZIndex = 500
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 14)
local tGlow = Instance.new("UIStroke", toggleBtn)
tGlow.Color = ACCENT
tGlow.Thickness = 1.5
local tIcon = Instance.new("TextLabel", toggleBtn)
tIcon.Size = UDim2.new(1, 0, 1, 0)
tIcon.BackgroundTransparency = 1
tIcon.Text = "⚡"
tIcon.Font = Enum.Font.GothamBold
tIcon.TextSize = 22
tIcon.TextColor3 = ACCENT

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 480, 0, 360)
main.Position = UDim2.new(0.5, -240, 0.5, -180)
main.BackgroundColor3 = BG_MAIN
main.BorderSizePixel = 0
main.Active = true
main.Visible = false
main.ZIndex = 100
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = ACCENT
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.5

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 42)
topBar.BackgroundColor3 = BG_SEC
topBar.BorderSizePixel = 0
topBar.ZIndex = 101
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NEKO HUB // LITE"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = BG_CARD
closeBtn.Text = "✕"
closeBtn.TextColor3 = RED
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

-- Kéo thả
local dragging, dragStart, startPos = false, nil, nil
topBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = main.Position end end)
UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)

local tDragging, tDragStart, tStartPos = false, nil, nil
toggleBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then tDragging = true tDragStart = i.Position tStartPos = toggleBtn.Position end end)
UIS.InputChanged:Connect(function(i) if tDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - tDragStart toggleBtn.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + d.X, tStartPos.Y.Scale, tStartPos.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if tDragging then
            tDragging = false
            if (i.Position - tDragStart).Magnitude < 10 then main.Visible = not main.Visible end
        end
    end
end)

-- Tabs
local sideBar = Instance.new("Frame", main)
sideBar.Size = UDim2.new(0, 110, 1, -54)
sideBar.Position = UDim2.new(0, 10, 0, 48)
sideBar.BackgroundTransparency = 1
local sideLay = Instance.new("UIListLayout", sideBar)
sideLay.Padding = UDim.new(0, 6)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -136, 1, -54)
content.Position = UDim2.new(0, 126, 0, 48)
content.BackgroundTransparency = 1

local tabs = {"MOVE", "ESP", "PLAYER", "TELE", "AIM", "INFO"}
local pages = {}

local function switchTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for _, b in ipairs(sideBar:GetChildren()) do
        if b:IsA("TextButton") then
            local active = (b.Text == "  " .. name)
            T:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = active and ACCENT or BG_SEC, TextColor3 = active and BG_MAIN or TXT_DIM}):Play()
        end
    end
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", sideBar)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = (i == 1) and ACCENT or BG_SEC
    btn.Text = "  " .. name
    btn.TextColor3 = (i == 1) and BG_MAIN or TXT_DIM
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function() switchTab(name) end)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (i == 1)
    local lay = Instance.new("UIListLayout", page)
    lay.Padding = UDim.new(0, 8)
    pages[name] = page
end

-- UI Helpers
local function mkSec(parent, text)
    local s = Instance.new("Frame", parent)
    s.Size = UDim2.new(1, -8, 0, 22)
    s.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", s)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = "◈ " .. text
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextColor3 = ACCENT
    l.TextXAlignment = Enum.TextXAlignment.Left
    return s
end

local function mkTog(parent, text, default, callback)
    local state = default or false
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -8, 0, 36)
    b.BackgroundColor3 = BG_CARD
    b.Text = "   " .. text
    b.TextColor3 = TXT
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local ind = Instance.new("Frame", b)
    ind.Size = UDim2.new(0, 36, 0, 18)
    ind.Position = UDim2.new(1, -44, 0.5, -9)
    ind.BackgroundColor3 = state and ACCENT or BG_SEC
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame", ind)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, state and 20 or 4, 0.5, -6)
    dot.BackgroundColor3 = state and BG_MAIN or TXT_DIM
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    b.MouseButton1Click:Connect(function()
        state = not state
        T:Create(ind, TweenInfo.new(0.2), {BackgroundColor3 = state and ACCENT or BG_SEC}):Play()
        T:Create(dot, TweenInfo.new(0.2), {Position = UDim2.new(0, state and 20 or 4, 0.5, -6), BackgroundColor3 = state and BG_MAIN or TXT_DIM}):Play()
        if callback then callback(state) end
    end)
    return b
end

local function mkBtn(parent, text, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -8, 0, 36)
    b.BackgroundColor3 = BG_CARD
    b.Text = "   " .. text
    b.TextColor3 = TXT
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() if callback then callback(b) end end)
    return b
end

local function mkSli(parent, text, min, max, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -8, 0, 44)
    f.BackgroundColor3 = BG_CARD
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -16, 0, 20)
    lbl.Position = UDim2.new(0, 12, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -24, 0, 4)
    bar.Position = UDim2.new(0, 12, 0, 30)
    bar.BackgroundColor3 = BG_SEC
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = ACCENT
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local hit = Instance.new("TextButton", f)
    hit.Size = UDim2.new(1, 0, 1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""

    local drag = false
    hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local p = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0)
            local val = math.floor(min + (max - min) * p)
            lbl.Text = text .. ": " .. val
            if callback then callback(val) end
        end
    end)
    return f
end

-- POPULATE PAGES
local movePage = pages["MOVE"]
mkSec(movePage, "MOVEMENT")
mkSli(movePage, "Walk Speed", 16, 300, 16, function(v) stt.ws = v end)
mkSli(movePage, "Jump Power", 50, 300, 50, function(v) stt.jp = v end)
mkTog(movePage, "Infinite Jump", false, function(s) tg.infJump = s end)

local espPage = pages["ESP"]
mkSec(espPage, "VISUALS")
mkTog(espPage, "ESP Name, Dist & Health", false, function(s) tg.esp = s end)

local plPage = pages["PLAYER"]
mkSec(plPage, "CHARACTER")
mkTog(plPage, "Spin Bot", false, function(s)
    spinState.on = s
    local h = pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
    if h then h.AutoRotate = not s end
end)
mkSli(plPage, "Spin Speed", 1, 20, 5, function(v) spinState.speed = v end)
mkTog(plPage, "Noclip", false, function(s) tg.noclip = s end)

mkSec(plPage, "RENDER & UTILS")
mkTog(plPage, "FPS Boost", false, function(s) tg.fps = s L.GlobalShadows = not s end)
mkSli(plPage, "Camera FOV", 70, 120, 70, function(v) cam.FieldOfView = v end)
mkBtn(plPage, "Reset Character", function() if pl.Character then pl.Character:BreakJoints() end end)
mkBtn(plPage, "Rejoin Server", function() TS:Teleport(game.PlaceId, pl) end)

-- TELEPORT & DYNAMIC WAYPOINTS
local telePage = pages["TELE"]
mkSec(telePage, "AUTO FLY")
mkTog(telePage, "Auto Fly (Follow Closest)", false, function(s) tg.autoFly = s end)
mkSli(telePage, "Fly Stiffness", 10, 120, 50, function(v) autoFlyStiffness = v end)

mkSec(telePage, "DYNAMIC WAYPOINTS")
local wpContainer = Instance.new("Frame", telePage)
wpContainer.Size = UDim2.new(1, -8, 0, 0)
wpContainer.AutomaticSize = Enum.AutomaticSize.Y
wpContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", wpContainer).Padding = UDim.new(0, 4)

local wpList = {} 
local function refreshWPUI()
    for _, child in ipairs(wpContainer:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    for i, wp in ipairs(wpList) do
        local row = Instance.new("Frame", wpContainer)
        row.Size = UDim2.new(1, 0, 0, 32)
        row.BackgroundColor3 = BG_CARD
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        
        local info = Instance.new("TextLabel", row)
        info.Size = UDim2.new(1, -80, 1, 0)
        info.Position = UDim2.new(0, 10, 0, 0)
        info.BackgroundTransparency = 1
        info.Text = wp.name
        info.TextColor3 = TXT
        info.TextXAlignment = Enum.TextXAlignment.Left
        info.Font = Enum.Font.GothamMedium
        info.TextSize = 11
        
        local goB = Instance.new("TextButton", row)
        goB.Size = UDim2.new(0, 30, 0, 22)
        goB.Position = UDim2.new(1, -70, 0.5, -11)
        goB.BackgroundColor3 = BG_SEC
        goB.Text = "GO"
        goB.TextColor3 = GREEN
        goB.Font = Enum.Font.GothamBold
        goB.TextSize = 10
        Instance.new("UICorner", goB).CornerRadius = UDim.new(0, 4)
        goB.MouseButton1Click:Connect(function()
            local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
            if hr then hr.CFrame = wp.cframe end
        end)
        
        local xB = Instance.new("TextButton", row)
        xB.Size = UDim2.new(0, 30, 0, 22)
        xB.Position = UDim2.new(1, -34, 0.5, -11)
        xB.BackgroundColor3 = BG_SEC
        xB.Text = "✕"
        xB.TextColor3 = RED
        xB.Font = Enum.Font.GothamBold
        xB.TextSize = 10
        Instance.new("UICorner", xB).CornerRadius = UDim.new(0, 4)
        xB.MouseButton1Click:Connect(function()
            table.remove(wpList, i)
            refreshWPUI()
        end)
    end
end

mkBtn(telePage, "+ Add Current Position", function()
    local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    if hr then
        table.insert(wpList, {name = "Waypoint " .. (#wpList + 1), cframe = hr.CFrame})
        refreshWPUI()
    end
end)
wpContainer.Parent = telePage

-- AIM PAGE
local aimPage = pages["AIM"]
mkSec(aimPage, "AUTO AIM")
mkTog(aimPage, "Aimlock Head (Closest)", false, function(s) tg.aimlock = s end)

-- INFO PAGE
local infoPage = pages["INFO"]
local function mkCard(titleText, accent)
    local card = Instance.new("Frame", infoPage)
    card.Size = UDim2.new(1, -8, 0, 0)
    card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = BG_CARD
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    
    local titleBar = Instance.new("Frame", card)
    titleBar.Size = UDim2.new(1, 0, 0, 26)
    titleBar.BackgroundColor3 = BG_SEC
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 8)
    
    local tl = Instance.new("TextLabel", titleBar)
    tl.Size = UDim2.new(1, -14, 1, 0)
    tl.Position = UDim2.new(0, 12, 0, 0)
    tl.BackgroundTransparency = 1
    tl.Text = titleText
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 11
    tl.TextColor3 = accent
    tl.TextXAlignment = Enum.TextXAlignment.Left
    
    local body = Instance.new("Frame", card)
    body.Size = UDim2.new(1, -24, 0, 0)
    body.Position = UDim2.new(0, 12, 0, 30)
    body.AutomaticSize = Enum.AutomaticSize.Y
    body.BackgroundTransparency = 1
    Instance.new("UIListLayout", body).Padding = UDim.new(0, 4)
    
    local function row(name, color)
        local r = Instance.new("Frame", body)
        r.Size = UDim2.new(1, 0, 0, 18)
        r.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(0.5, 0, 1, 0)
        l.BackgroundTransparency = 1
        l.Text = name
        l.Font = Enum.Font.GothamMedium
        l.TextSize = 11
        l.TextColor3 = TXT_DIM
        l.TextXAlignment = Enum.TextXAlignment.Left
        local v = Instance.new("TextLabel", r)
        v.Size = UDim2.new(0.5, 0, 1, 0)
        v.Position = UDim2.new(0.5, 0, 0, 0)
        v.BackgroundTransparency = 1
        v.Text = "--"
        v.Font = Enum.Font.GothamBold
        v.TextSize = 11
        v.TextColor3 = color or ACCENT
        v.TextXAlignment = Enum.TextXAlignment.Right
        return v
    end
    return row
end

local netR = mkCard("NETWORK & SYSTEM", ACCENT)
local pingLbl = netR("PING", GREEN)
local perfR = mkCard("PERFORMANCE", GREEN)
local fpsLbl = perfR("FPS", ACCENT)
local memLbl = perfR("MEMORY", ACCENT)
local pR = mkCard("PLAYER METRICS", YEL)
local nameLbl = pR("NAME", YEL)
local hpLbl = pR("HEALTH", GREEN)

local frmCnt = 0
RS.RenderStepped:Connect(function() frmCnt = frmCnt + 1 end)

task.spawn(function()
    while true do
        task.wait(1)
        local f = frmCnt
        frmCnt = 0
        local ping = 0
        pcall(function() ping = math.floor(pl:GetNetworkPing() * 1000) end)
        
        pcall(function()
            pingLbl.Text = ping .. " ms"
            fpsLbl.Text = f .. " FPS"
            memLbl.Text = (function() local ok2, m = pcall(function() return ST:GetTotalMemoryUsageMb() end) return ok2 and m and math.floor(m) .. " MB" or "--" end)()
            nameLbl.Text = pl.Name
            local c = pl.Character
            if c then
                local h = c:FindFirstChildOfClass("Humanoid")
                if h then hpLbl.Text = math.floor(h.Health) .. " / " .. math.floor(h.MaxHealth) end
            end
        end)
    end
end)

print("[NEKO HUB] Lite Edition Loaded Successfully!")
end)

if not ok then
    warn("[NEKO ERROR] " .. tostring(err))
end