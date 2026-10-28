local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local L = game:GetService("Lighting")
local TS = game:GetService("TeleportService")
local ST = game:GetService("Stats")
local HS = game:GetService("HttpService")
local VU = game:GetService("VirtualUser")
local pl = P.LocalPlayer
local cam = workspace.CurrentCamera

local G = Color3.fromRGB(0, 255, 120)
local G2 = Color3.fromRGB(0, 180, 80)
local DIM = Color3.fromRGB(40, 40, 45)
local BG = Color3.fromRGB(20, 20, 25)
local BG2 = Color3.fromRGB(30, 30, 35)
local TX = Color3.fromRGB(220, 220, 220)
local DIM_TX = Color3.fromRGB(150, 150, 150)
local RED = Color3.fromRGB(255, 60, 80)
local YEL = Color3.fromRGB(255, 220, 100)
local CY = Color3.fromRGB(0, 255, 255)

local gp = gethui and gethui() or game:GetService("CoreGui")
pcall(function()
    if gp:FindFirstChild("HackerNeko") then gp.HackerNeko:Destroy() end
    if gp:FindFirstChild("NekoESP") then gp.NekoESP:Destroy() end
end)
pcall(function() RS:UnbindFromRenderStep("NekoAimLock") end)

local sg = Instance.new("ScreenGui")
sg.Name = "HackerNeko" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true sg.DisplayOrder = 9999 sg.Parent = gp

local ef = Instance.new("Folder", gp) ef.Name = "NekoESP"
local epf = Instance.new("Folder", ef) epf.Name = "Players"

local stt = {ws = 16, jp = 50}
local tg = {espLineBox = false, espNameDist = false, espHp = false, noclip = false, mapBright = false, fps = false, infJump = false, antiKB = true}
local ghostDeath = {on = false}
local spinState = {on = false, speed = 5}
local ghostFeet = {on = false, height = 0, baseY = nil}
local autoFlyState = {on = false, stiffness = 50}
local autoFireEnabled = false
local spinAccum = 0
local spinSavedAutoRotate = nil
local autoFlySavedPlatform = nil
local tpSelected = nil
local teleportTo
local fovCustom = nil
local nlSafe = nil
local nlGroundT = 0
local wps = {nil, nil, nil, nil, nil, nil, nil, nil}
local wpHeight = 3
local SND = {on = true, vol = 0.6}

local acS = {on = false, cps = 10, button = "Left", humanize = false}
local acFrames, acStrokes = {}, {}
local acAcc = 0
local acTotal, acSession = 0, 0
local acIdx = 1

local AimlockEnabled = true
local SelectedTargets = {}
local Target = nil

local hfa = (writefile ~= nil) and (readfile ~= nil) and (isfile ~= nil)
local WPF = "NekoWPs_" .. tostring(game.PlaceId) .. ".json"

if hfa and isfile(WPF) then
    pcall(function()
        local d = HS:JSONDecode(readfile(WPF))
        if d then
            if type(d.height) == "number" then wpHeight = d.height end
            if type(d.wps) == "table" then
                for i = 1, 8 do
                    local w = d.wps[tostring(i)] or d.wps[i]
                    if type(w) == "table" then wps[i] = w end
                end
            end
        end
    end)
end

local function saveWPs()
    if not hfa then return end
    pcall(function()
        local out = {}
        for i = 1, 8 do if wps[i] then out[tostring(i)] = wps[i] end end
        writefile(WPF, HS:JSONEncode({height = wpHeight, wps = out}))
    end)
end

local function cfFromArr(a)
    if not a then return nil end
    return CFrame.new(a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9], a[10], a[11], a[12])
end

local function GetTargetPart(character)
    if not character then return nil end
    return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
end

teleportTo = function(targetPos, opts)
    opts = opts or {}
    local c = pl.Character if not c then return false end
    local hr = c:FindFirstChild("HumanoidRootPart") if not hr then return false end
    local cf = opts.cframe or (CFrame.new(targetPos) * (hr.CFrame - hr.CFrame.Position))
    local function snap() hr.CFrame = cf hr.AssemblyLinearVelocity = Vector3.zero hr.AssemblyAngularVelocity = Vector3.zero end
    snap()
    task.spawn(function() for _ = 1, 4 do RS.Heartbeat:Wait()
        if not hr.Parent then return end
        if (hr.Position - cf.Position).Magnitude > 3 then snap() end
    end end)
    nlSafe = cf
    nlGroundT = tick()
    return true
end

local function playSnd()
    if not SND.on then return end
    pcall(function()
        local sd = Instance.new("Sound")
        sd.SoundId = "rbxasset://sounds/clickfast.wav"
        sd.Volume = SND.vol
        sd.Parent = game:GetService("SoundService")
        sd:Play()
        task.delay(1, function() sd:Destroy() end)
    end)
end

RS.RenderStepped:Connect(function()
    if Target then
        local hum = Target.Parent and Target.Parent:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then Target = nil end
    end
    local closestTarget = nil
    local shortestDistance = 1500
    if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
        local myPos = pl.Character.HumanoidRootPart.Position
        local hasSelected = false
        for _, isSelected in pairs(SelectedTargets) do if isSelected then hasSelected = true break end end

        if hasSelected then
            for player, isSelected in pairs(SelectedTargets) do
                if isSelected and player.Character then
                    local char = player.Character
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    local targetPart = GetTargetPart(char)
                    if humanoid and humanoid.Health > 0 and targetPart then
                        local d = (targetPart.Position - myPos).Magnitude
                        if d < shortestDistance then shortestDistance = d closestTarget = targetPart end
                    end
                end
            end
        else
            for _, player in ipairs(P:GetPlayers()) do
                if player ~= pl and player.Character then
                    local char = player.Character
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    local targetPart = GetTargetPart(char)
                    if humanoid and humanoid.Health > 0 and targetPart then
                        local d = (targetPart.Position - myPos).Magnitude
                        if d < shortestDistance then shortestDistance = d closestTarget = targetPart end
                    end
                end
            end
        end
    end
    Target = closestTarget
    if AimlockEnabled and Target then
        cam.CFrame = CFrame.new(cam.CFrame.Position, Target.Position)
        if autoFireEnabled then
            pcall(function() VU:Button1Down(Vector2.new(0,0)) task.wait() VU:Button1Up(Vector2.new(0,0)) end)
        end
    end
end)

local function mkTog(parent, text, default, callback)
    local state = default or false
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 34) b.BackgroundColor3 = state and G or BG2
    b.Text = (state and "[ ON ] " or "[ OFF ] ") .. text
    b.TextColor3 = state and Color3.new(0,0,0) or DIM_TX
    b.TextXAlignment = Enum.TextXAlignment.Left b.Font = Enum.Font.SourceSansBold b.TextSize = 13 b.AutoButtonColor = false
    b.LayoutOrder = #parent:GetChildren() * 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        state = not state playSnd()
        b.Text = (state and "[ ON ] " or "[ OFF ] ") .. text
        b.BackgroundColor3 = state and G or BG2
        b.TextColor3 = state and Color3.new(0,0,0) or DIM_TX
        if callback then callback(state) end
    end)
    return b
end

local function mkBtn(parent, text, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -10, 0, 34) b.BackgroundColor3 = BG2
    b.Text = "  " .. text b.TextColor3 = TX b.TextXAlignment = Enum.TextXAlignment.Left
    b.Font = Enum.Font.SourceSansBold b.TextSize = 13 b.AutoButtonColor = false
    b.LayoutOrder = #parent:GetChildren() * 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function() playSnd() if callback then callback(b) end end)
    return b
end

local function mkSli(parent, text, min, max, default, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, -10, 0, 40) f.BackgroundColor3 = BG2
    f.LayoutOrder = #parent:GetChildren() * 10
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -10, 0, 20) lbl.Position = UDim2.new(0, 8, 0, 2)
    lbl.BackgroundTransparency = 1 lbl.Text = text .. ": " .. default
    lbl.TextColor3 = TX lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.SourceSansBold lbl.TextSize = 13
    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -16, 0, 4) bar.Position = UDim2.new(0, 8, 0, 26)
    bar.BackgroundColor3 = DIM bar.BorderSizePixel = 0
    local fill = Instance.new("Frame", bar)
    fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = G fill.BorderSizePixel = 0
    local hit = Instance.new("TextButton", f)
    hit.Size = UDim2.new(1, 0, 0, 30) hit.Position = UDim2.new(0, 0, 0, 10)
    hit.BackgroundTransparency = 1 hit.Text = ""
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

local function mkSec(parent, text)
    local s = Instance.new("Frame", parent)
    s.Size = UDim2.new(1, -10, 0, 20) s.BackgroundTransparency = 1 s.LayoutOrder = #parent:GetChildren() * 10
    local l = Instance.new("TextLabel", s)
    l.Size = UDim2.new(1, 0, 1, 0) l.BackgroundTransparency = 1 l.Text = "// " .. text
    l.Font = Enum.Font.SourceSansBold l.TextSize = 12 l.TextColor3 = CY l.TextXAlignment = Enum.TextXAlignment.Left
    return s
end

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 380, 0, 320) main.Position = UDim2.new(0.5, -190, 0.5, -160)
main.BackgroundColor3 = BG main.BorderSizePixel = 0 main.Active = true main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 32) topBar.BackgroundColor3 = BG2 topBar.BorderSizePixel = 0
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)
local fix = Instance.new("Frame", topBar) fix.Size = UDim2.new(1, 0, 0, 10) fix.Position = UDim2.new(0, 0, 1, -10) fix.BackgroundColor3 = BG2 fix.BorderSizePixel = 0

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -40, 1, 0) title.Position = UDim2.new(0, 10, 0, 0) title.BackgroundTransparency = 1
title.Text = "NYT ALL" title.TextColor3 = G title.Font = Enum.Font.Code title.TextSize = 14 title.TextXAlignment = Enum.TextXAlignment.Left
local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 32, 0, 32) closeBtn.Position = UDim2.new(1, -32, 0, 0) closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X" closeBtn.TextColor3 = RED closeBtn.Font = Enum.Font.SourceSansBold closeBtn.TextSize = 16
closeBtn.MouseButton1Click:Connect(function() playSnd() main.Visible = false end)

local toggleBtn = Instance.new("TextButton", sg)
toggleBtn.Size = UDim2.new(0, 50, 0, 50) toggleBtn.Position = UDim2.new(0, 20, 0.3, 0)
toggleBtn.BackgroundColor3 = BG toggleBtn.Text = ">_" toggleBtn.TextColor3 = G
toggleBtn.Font = Enum.Font.Code toggleBtn.TextSize = 20 toggleBtn.AutoButtonColor = false
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
local glow = Instance.new("UIStroke", toggleBtn) glow.Color = G glow.Thickness = 2

local dragging, dragStart, startPos = false, nil, nil
toggleBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = toggleBtn.Position end end)
UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
    if dragging then dragging = false if (i.Position - dragStart).Magnitude < 10 then playSnd() main.Visible = not main.Visible end end
end end)

local tabs = {"MOVE", "ESP", "PLAYER", "TELE", "AIM", "INFO"}
local pages = {} 
local sideBar = Instance.new("Frame", main)
sideBar.Size = UDim2.new(0, 80, 1, -32) sideBar.Position = UDim2.new(0, 0, 0, 32)
sideBar.BackgroundTransparency = 1
local sideLay = Instance.new("UIListLayout", sideBar) sideLay.Padding = UDim.new(0, 4) sideLay.HorizontalAlignment = Enum.HorizontalAlignment.Center

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -80, 1, -32) content.Position = UDim2.new(0, 80, 0, 32)
content.BackgroundTransparency = 1

local function switchTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for _, b in ipairs(sideBar:GetChildren()) do 
        if b:IsA("TextButton") then 
            if b.Text == name then b.BackgroundColor3 = G b.TextColor3 = Color3.new(0,0,0)
            else b.BackgroundColor3 = BG2 b.TextColor3 = DIM_TX end
        end 
    end
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", sideBar)
    btn.Size = UDim2.new(0, 70, 0, 32) btn.BackgroundColor3 = BG2 btn.Text = name
    btn.TextColor3 = DIM_TX btn.Font = Enum.Font.SourceSansBold btn.TextSize = 12 btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function() playSnd() switchTab(name) end)
    
    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, -4, 1, -4) page.Position = UDim2.new(0, 4, 0, 4)
    page.BackgroundTransparency = 1 page.BorderSizePixel = 0 page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = G page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y page.Visible = false
    local lay = Instance.new("UIListLayout", page) lay.Padding = UDim.new(0, 6) lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
    pages[name] = page
    if i == 1 then btn.BackgroundColor3 = G btn.TextColor3 = Color3.new(0,0,0) page.Visible = true end
end

local movePage = pages["MOVE"]
mkSec(movePage, "SPEED")
mkSli(movePage, "Walk Speed", 16, 300, 16, function(v) stt.ws = v end)
mkSli(movePage, "Jump Power", 50, 300, 50, function(v) stt.jp = v end)
mkTog(movePage, "INFINITE JUMP", false, function(s) tg.infJump = s end)
mkSec(movePage, "AUTO CLICKER")
mkTog(movePage, "AUTO CLICKER", false, function(s) acS.on = s end)
mkSli(movePage, "Click Speed (CPS)", 1, 50, 10, function(v) acS.cps = v end)
mkBtn(movePage, "CLICK BUTTON: LEFT", function(b)
    acS.button = (acS.button == "Left") and "Right" or "Left"
    b.Text = "  CLICK BUTTON: " .. string.upper(acS.button)
end)
mkBtn(movePage, "ADD CLICK POINT", function()
    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 50, 0, 50) f.Position = UDim2.new(0.5, -25, 0.5, -25) f.BackgroundTransparency = 1
    local ring = Instance.new("Frame", f) ring.Size = UDim2.new(0, 30, 0, 30) ring.Position = UDim2.new(0.5, -15, 0.5, -15) ring.BackgroundTransparency = 1
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local st = Instance.new("UIStroke", ring) st.Color = G st.Thickness = 2
    local dragging, dragStart, startPos = false, nil, nil
    f.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = f.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    table.insert(acFrames, f) table.insert(acStrokes, st)
end)
mkBtn(movePage, "REMOVE LAST POINT", function()
    if #acFrames > 0 then
        local f = table.remove(acFrames) f:Destroy()
        table.remove(acStrokes)
    end
end)
mkBtn(movePage, "CLEAR ALL POINTS", function()
    for _, f in ipairs(acFrames) do f:Destroy() end
    acFrames = {} acStrokes = {}
end)

local espPage = pages["ESP"]
mkSec(espPage, "VISUALS")
mkTog(espPage, "BOX & LINE (RAINBOW)", false, function(s) tg.espLineBox = s end)
mkTog(espPage, "NAME & DIST (NEON)", false, function(s) tg.espNameDist = s end)
mkTog(espPage, "HEALTH BAR", false, function(s) tg.espHp = s end)

local plPage = pages["PLAYER"]
mkSec(plPage, "CHARACTER")
mkTog(plPage, "SPIN", false, function(s) 
    spinState.on = s 
    local h = pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
    if h then h.AutoRotate = not s end
end)
mkSli(plPage, "Spin Speed", 1, 20, 5, function(v) spinState.speed = v end)

mkTog(plPage, "GHOST FEET", false, function(s) 
    ghostFeet.on = s
    if s then local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") if hr then ghostFeet.baseY = hr.Position.Y end end
end)
mkSli(plPage, "Ghost Height", -30, 100, 0, function(v) ghostFeet.height = v end)
mkBtn(plPage, "CALIBRATE BASE", function()
    local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    if hr then ghostFeet.baseY = hr.Position.Y end
end)

mkSec(plPage, "SURVIVAL")
mkTog(plPage, "NOCLIP", false, function(s) tg.noclip = s end)
mkTog(plPage, "ANTI-KNOCKBACK", true, function(s) tg.antiKB = s end)
mkTog(plPage, "GHOST DEATH", false, function(s) ghostDeath.on = s end)

mkSec(plPage, "PERFORMANCE")
mkTog(plPage, "FPS BOOST", false, function(s) tg.fps = s L.GlobalShadows = not s end)
mkTog(plPage, "MAP BRIGHT", false, function(s) tg.mapBright = s L.Brightness = s and 3 or 1 end)
mkSli(plPage, "Camera FOV", 70, 120, 70, function(v) cam.FieldOfView = v fovCustom = (v ~= 70) and v or nil end)
mkSli(plPage, "Sound Volume", 0, 100, 60, function(v) SND.vol = v/100 end)

mkSec(plPage, "UTILS")
mkBtn(plPage, "RESET CHARACTER", function() if pl.Character then pl.Character:BreakJoints() end end)
mkBtn(plPage, "REJOIN SERVER", function() TS:Teleport(game.PlaceId, pl) end)

local telePage = pages["TELE"]
mkSec(telePage, "PLAYER TELEPORT")
local tpBtn = mkBtn(telePage, "CHỌN NGƯỜI CHƠI", function()
    dlgTitle.Text = "> SELECT PLAYER"
    for _, ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= pl then
            dlgBtn(p.Name, G, function() tpSelected = p tpBtn.Text = "  " .. p.Name closeDlg() end)
        end
    end
    dlgBtn("CANCEL", RED, function() closeDlg() end)
    dlg.Visible = true dlgOverlay.Visible = true
end)
mkBtn(telePage, "TELEPORT TỚI NGƯỜI CHƠI", function()
    if not tpSelected then return end
    local c = pl.Character local hr = c and c:FindFirstChild("HumanoidRootPart")
    local th = tpSelected.Character and tpSelected.Character:FindFirstChild("HumanoidRootPart")
    if hr and th then teleportTo(th.Position + Vector3.new(0, 4, 0)) end
end)
mkTog(telePage, "AUTO FLY (FOLLOW)", false, function(s) autoFlyState.on = s end)
mkSli(telePage, "Stiffness", 10, 120, 50, function(v) autoFlyState.stiffness = v end)

mkSec(telePage, "WAYPOINTS")
mkSli(telePage, "WP Height", 0, 20, wpHeight, function(v) wpHeight = v saveWPs() end)
for i = 1, 8 do
    local row = Instance.new("Frame", telePage)
    row.Size = UDim2.new(1, -10, 0, 34) row.BackgroundColor3 = BG2 row.BorderSizePixel = 0
    row.LayoutOrder = #telePage:GetChildren() * 10
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
    local info = Instance.new("TextLabel", row) info.Size = UDim2.new(1, -100, 1, 0) info.Position = UDim2.new(0, 10, 0, 0) info.BackgroundTransparency = 1 info.Text = "WP "..i info.TextColor3 = DIM_TX info.TextXAlignment = Enum.TextXAlignment.Left
    local setB = Instance.new("TextButton", row) setB.Size = UDim2.new(0, 30, 0, 24) setB.Position = UDim2.new(1, -70, 0.5, -12) setB.BackgroundColor3 = BG setB.Text = "SET" setB.TextColor3 = G setB.Font = Enum.Font.SourceSansBold setB.TextSize = 11
    setB.MouseButton1Click:Connect(function() local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") if hr then wps[i] = {hr.CFrame:GetComponents()} saveWPs() info.Text = "WP "..i.." READY" info.TextColor3 = G end end)
    local goB = Instance.new("TextButton", row) goB.Size = UDim2.new(0, 30, 0, 24) goB.Position = UDim2.new(1, -36, 0.5, -12) goB.BackgroundColor3 = BG goB.Text = "GO" goB.TextColor3 = YEL goB.Font = Enum.Font.SourceSansBold goB.TextSize = 11
    goB.MouseButton1Click:Connect(function() if wps[i] then local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") if hr then teleportTo(Vector3.new(wps[i][1], wps[i][2] + wpHeight, wps[i][3])) end end end)
    local xB = Instance.new("TextButton", row) xB.Size = UDim2.new(0, 30, 0, 24) xB.Position = UDim2.new(1, -102, 0.5, -12) xB.BackgroundColor3 = BG xB.Text = "X" xB.TextColor3 = RED xB.Font = Enum.Font.SourceSansBold xB.TextSize = 11
    xB.MouseButton1Click:Connect(function() wps[i] = nil saveWPs() info.Text = "WP "..i info.TextColor3 = DIM_TX end)
end

local aimPage = pages["AIM"]
mkSec(aimPage, "AIMBOT")
mkBtn(aimPage, "🎯 AIMLOCK: ON", function(b)
    AimlockEnabled = not AimlockEnabled
    b.Text = AimlockEnabled and "  🎯 AIMLOCK: ON" or "  🎯 AIMLOCK: OFF"
    b.TextColor3 = AimlockEnabled and G or RED
end).TextColor3 = G
mkTog(aimPage, "AUTO FIRE", false, function(s) autoFireEnabled = s end)
mkBtn(aimPage, "📋 DANH SÁCH CHỌN MỤC TIÊU", function() listWindow.Visible = true RefreshList() end)

local infoPage = pages["INFO"]
local function mkCard(title, accent)
    local card = Instance.new("Frame", infoPage)
    card.Size = UDim2.new(1, -10, 0, 0) card.AutomaticSize = Enum.AutomaticSize.Y
    card.BackgroundColor3 = BG card.BackgroundTransparency = 0.35 card.BorderSizePixel = 0
    card.LayoutOrder = #infoPage:GetChildren() * 10
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 4)
    local titleBar = Instance.new("Frame", card)
    titleBar.Size = UDim2.new(1, 0, 0, 24) titleBar.BackgroundColor3 = BG2
    titleBar.BackgroundTransparency = 0.3 titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 4)
    local tl = Instance.new("TextLabel", titleBar)
    tl.Size = UDim2.new(1, -14, 1, 0) tl.Position = UDim2.new(0, 14, 0, 0)
    tl.BackgroundTransparency = 1 tl.Text = title tl.Font = Enum.Font.Code
    tl.TextSize = 12 tl.TextColor3 = accent tl.TextXAlignment = Enum.TextXAlignment.Left
    local body = Instance.new("Frame", card)
    body.Size = UDim2.new(1, -12, 0, 0) body.Position = UDim2.new(0, 6, 0, 28)
    body.AutomaticSize = Enum.AutomaticSize.Y body.BackgroundTransparency = 1
    local bl = Instance.new("UIListLayout", body) bl.Padding = UDim.new(0, 3) bl.SortOrder = Enum.SortOrder.LayoutOrder
    local function row(name, color)
        local r = Instance.new("Frame", body)
        r.Size = UDim2.new(1, 0, 0, 18) r.BackgroundTransparency = 1
        local l = Instance.new("TextLabel", r)
        l.Size = UDim2.new(0.5, 0, 1, 0) l.BackgroundTransparency = 1 l.Text = name
        l.Font = Enum.Font.Code l.TextSize = 11 l.TextColor3 = DIM_TX l.TextXAlignment = Enum.TextXAlignment.Left
        local v = Instance.new("TextLabel", r)
        v.Size = UDim2.new(0.5, 0, 1, 0) v.Position = UDim2.new(0.5, 0, 0, 0) v.BackgroundTransparency = 1
        v.Text = "--" v.Font = Enum.Font.Code v.TextSize = 12 v.TextColor3 = color or G
        v.TextXAlignment = Enum.TextXAlignment.Right
        return v
    end
    return row
end

local netR = mkCard("NETWORK", CY)
local pingLbl = netR("PING", G) local statusLbl = netR("STATUS", G)
local perfR = mkCard("PERFORMANCE", G)
local fpsLbl = perfR("FPS", CY) local memLbl = perfR("MEMORY", CY) local uptimeLbl = perfR("UPTIME", CY)
local acR = mkCard("AUTO CLICK", YEL)
local cpsLbl = acR("REAL CPS", CY) local totalLbl = acR("TOTAL", YEL)
local pR = mkCard("PLAYER", YEL)
local nameLbl = pR("NAME", YEL) local hpLbl = pR("HEALTH", G) local posLbl = pR("POSITION", YEL)
local srvR = mkCard("SERVER", Color3.fromRGB(200,255,220))
local gameLbl = srvR("GAME", Color3.fromRGB(200,255,220)) local playersLbl = srvR("PLAYERS", Color3.fromRGB(200,255,220))
local sysR = mkCard("SYSTEM", Color3.fromRGB(255,150,50))
local timeLbl = sysR("TIME", Color3.fromRGB(255,150,50)) local verLbl = sysR("VERSION", Color3.fromRGB(255,150,50))

local frmCnt = 0
local stT = tick()
RS.RenderStepped:Connect(function() frmCnt = frmCnt + 1 end)
task.spawn(function() while true do task.wait(2)
    local f = frmCnt / 2 frmCnt = 0
    local ping = 0 pcall(function() ping = math.floor(pl:GetNetworkPing() * 1000) end)
    local stTxt, stCol = "GOOD", G
    if ping > 150 then stTxt, stCol = "BAD", YEL end
    if ping > 250 then stTxt, stCol = "POOR", RED end
    pcall(function()
        pingLbl.Text = ping .. " ms" statusLbl.Text = stTxt statusLbl.TextColor3 = stCol
        fpsLbl.Text = math.floor(f) .. " fps"
        memLbl.Text = (function() local ok2,m=pcall(function() return ST:GetTotalMemoryUsageMb() end) return ok2 and m and math.floor(m).." MB" or "--" end)()
        local u = math.floor(tick() - stT) uptimeLbl.Text = string.format("%dm %ds", math.floor(u/60), u%60)
        cpsLbl.Text = acS.cps .. " cps" totalLbl.Text = tostring(acTotal)
        nameLbl.Text = pl.Name
        local c = pl.Character
        if c then
            local h = c:FindFirstChildOfClass("Humanoid") local hr = c:FindFirstChild("HumanoidRootPart")
            if h then hpLbl.Text = math.floor(h.Health).." / "..math.floor(h.MaxHealth) end
            if hr then local p = hr.Position posLbl.Text = string.format("%d,%d,%d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z)) end
        end
        gameLbl.Text = string.sub(game.Name or "?", 1, 20) playersLbl.Text = #P:GetPlayers() .. " / " .. P.MaxPlayers
        timeLbl.Text = os.date("%H:%M:%S") verLbl.Text = "ALL-IN-ONE"
    end)
end end)

RS.RenderStepped:Connect(function(dt)
    if acS.on and acS.cps > 0 then
        acAcc = acAcc + acS.cps * dt
        local n = math.floor(acAcc) acAcc = acAcc - n
        if n > 0 then for _=1, n do pcall(function() VU:ClickButton1(Vector2.new(0,0)) acTotal = acTotal + 1 end) end end
    end
end)

local espTable = {}
RS.RenderStepped:Connect(function()
    for p, data in pairs(espTable) do
        if not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
            if data.box then data.box:Remove() end if data.line then data.line:Remove() end if data.bb then data.bb:Destroy() end if data.hpBB then data.hpBB:Destroy() end
            espTable[p] = nil
        else
            local char = p.Character local hrp = char.HumanoidRootPart local head = char:FindFirstChild("Head") or hrp local hum = char:FindFirstChildOfClass("Humanoid")
            if tg.espLineBox and hum and hum.Health > 0 then
                local topPos, onScreen1 = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local botPos, onScreen2 = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                if onScreen1 or onScreen2 then
                    local height = math.abs(topPos.Y - botPos.Y) local width = height / 2
                    local color = Color3.fromRGB( math.sin(tick()*2)*127+128, math.sin(tick()*2+2)*127+128, math.sin(tick()*2+4)*127+128 )
                    if not data.box then data.box = Drawing.new("Square") data.box.Thickness = 1 data.box.Filled = false end
                    data.box.Size = Vector2.new(width, height) data.box.Position = Vector2.new(topPos.X - width/2, topPos.Y)
                    data.box.Color = color data.box.Visible = true
                    if not data.line then data.line = Drawing.new("Line") data.line.Thickness = 1.5 end
                    data.line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y) data.line.To = Vector2.new(topPos.X, botPos.Y)
                    data.line.Color = color data.line.Visible = true
                else if data.box then data.box.Visible = false end if data.line then data.line.Visible = false end end
            else if data.box then data.box.Visible = false end if data.line then data.line.Visible = false end end

            if tg.espNameDist then
                if not data.bb then
                    data.bb = Instance.new("BillboardGui", gp) data.bb.Adornee = head
                    data.bb.Size = UDim2.new(0, 200, 0, 20) data.bb.StudsOffset = Vector3.new(0, 2.5, 0) data.bb.AlwaysOnTop = true
                    data.txt = Instance.new("TextLabel", data.bb) data.txt.Size = UDim2.new(1, 0, 1, 0) data.txt.BackgroundTransparency = 1
                    data.txt.TextColor3 = G data.txt.Font = Enum.Font.Code data.txt.TextSize = 14 data.txt.TextStrokeTransparency = 0.5
                end
                local dist = math.floor((hrp.Position - pl.Character.HumanoidRootPart.Position).Magnitude / 3.57)
                data.txt.Text = p.Name .. " [" .. dist .. "m]" data.bb.Enabled = true
            else if data.bb then data.bb.Enabled = false end end

            if tg.espHp and hum then
                if not data.hpBB then
                    data.hpBB = Instance.new("BillboardGui", gp) data.hpBB.Adornee = hrp data.hpBB.Size = UDim2.new(0, 4, 0, 40) data.hpBB.StudsOffset = Vector3.new(1.5, 0, 0) data.hpBB.AlwaysOnTop = true
                    local bg = Instance.new("Frame", data.hpBB) bg.Size = UDim2.new(1,0,1,0) bg.BackgroundColor3 = Color3.new(0,0,0) bg.BorderSizePixel = 0
                    data.hpFill = Instance.new("Frame", bg) data.hpFill.AnchorPoint = Vector2.new(0,1) data.hpFill.Position = UDim2.new(0,0,1,0) data.hpFill.Size = UDim2.new(1,0,1,0) data.hpFill.BackgroundColor3 = G data.hpFill.BorderSizePixel = 0
                end
                local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1) data.hpFill.Size = UDim2.new(1,0,pct,0)
                data.hpFill.BackgroundColor3 = pct > 0.5 and G or RED data.hpBB.Enabled = true
            else if data.hpBB then data.hpBB.Enabled = false end end
        end
    end
end)

task.spawn(function() while true do task.wait(1)
    for _, p in ipairs(P:GetPlayers()) do if p ~= pl and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not espTable[p] then espTable[p] = {} end end
end end)

RS.Heartbeat:Connect(function()
    local c = pl.Character local h = c and c:FindFirstChildOfClass("Humanoid") local hr = c and c:FindFirstChild("HumanoidRootPart")
    if h and hr and h.Health > 0 then
        if stt.ws > 16 then local md = h.MoveDirection if md.Magnitude > 0.1 then hr.AssemblyLinearVelocity = Vector3.new(md.Unit.X * stt.ws, hr.AssemblyLinearVelocity.Y, md.Unit.Z * stt.ws) end end
        if stt.jp > 50 then h.UseJumpPower = true h.JumpPower = stt.jp end
        if tg.antiKB and (h:GetState() == Enum.HumanoidStateType.FallingDown or h:GetState() == Enum.HumanoidStateType.Ragdoll) then h.PlatformStand = false h:ChangeState(Enum.HumanoidStateType.GetUp) end
        if spinState.on then spinAccum = spinAccum + math.rad(spinState.speed * 360) * 0.016 hr.CFrame = CFrame.new(hr.Position) * CFrame.Angles(0, spinAccum, 0) end
        if ghostDeath.on and h.Health > 0 then h.Health = 0 end
        if ghostFeet.on and ghostFeet.baseY then
            local minY = math.max(ghostFeet.baseY + ghostFeet.height, workspace.FallenPartsDestroyHeight + 50)
            if hr.Position.Y < minY then hr.CFrame = CFrame.new(hr.Position.X, minY, hr.Position.Z) hr.AssemblyLinearVelocity = Vector3.new(hr.AssemblyLinearVelocity.X, 0, hr.AssemblyLinearVelocity.Z) end
        end
    end
end)
RS.Stepped:Connect(function()
    if tg.noclip and pl.Character then for _, p in ipairs(pl.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
end)
RS.Heartbeat:Connect(function(dt)
    if autoFlyState.on and tpSelected and tpSelected.Character then
        local myChar = pl.Character local myHR = myChar and myChar:FindFirstChild("HumanoidRootPart") local myH = myChar and myChar:FindFirstChildOfClass("Humanoid")
        local tHR = tpSelected.Character:FindFirstChild("HumanoidRootPart")
        if myHR and myH and tHR then
            myH.PlatformStand = true
            local desired = tHR.Position + Vector3.new(0, 4, 0)
            local newPos = myHR.Position:Lerp(desired, 1 - math.exp(-autoFlyState.stiffness * dt))
            myHR.CFrame = CFrame.lookAt(newPos, tHR.Position)
            myHR.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

local listWindow = Instance.new("Frame", sg)
listWindow.Size = UDim2.new(0, 200, 0, 260) listWindow.Position = UDim2.new(0.5, -100, 0.5, -130)
listWindow.BackgroundColor3 = BG listWindow.Visible = false listWindow.ZIndex = 2000
Instance.new("UICorner", listWindow).CornerRadius = UDim.new(0, 6)
local lTitle = Instance.new("TextLabel", listWindow) lTitle.Size = UDim2.new(1,0,0,25) lTitle.BackgroundColor3 = BG2 lTitle.Text = "CHỌN MỤC TIÊU" lTitle.TextColor3 = G lTitle.Font = Enum.Font.SourceSansBold lTitle.TextSize = 12
local lClose = Instance.new("TextButton", lTitle) lClose.Size = UDim2.new(0,25,0,25) lClose.Position = UDim2.new(1,-25,0,0) lClose.BackgroundTransparency = 1 lClose.Text = "X" lClose.TextColor3 = RED lClose.Font = Enum.Font.SourceSansBold lClose.MouseButton1Click:Connect(function() listWindow.Visible = false end)
local lScroll = Instance.new("ScrollingFrame", listWindow) lScroll.Size = UDim2.new(1, -10, 1, -50) lScroll.Position = UDim2.new(0, 5, 0, 30) lScroll.BackgroundTransparency = 1 lScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local lLay = Instance.new("UIListLayout", lScroll) lLay.Padding = UDim.new(0, 4)

function RefreshList()
    for _, c in ipairs(lScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in ipairs(P:GetPlayers()) do
        if p ~= pl then
            local b = Instance.new("TextButton", lScroll)
            b.Size = UDim2.new(1, 0, 0, 30) b.BackgroundColor3 = SelectedTargets[p] and G or BG2
            b.TextColor3 = SelectedTargets[p] and Color3.new(0,0,0) or TX
            b.Font = Enum.Font.SourceSansBold b.TextSize = 12 b.AutoButtonColor = false
            local txt = p.Name
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                txt = txt .. " [" .. math.floor((p.Character.HumanoidRootPart.Position - pl.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
            end
            b.Text = txt
            b.MouseButton1Click:Connect(function()
                SelectedTargets[p] = not SelectedTargets[p]
                b.BackgroundColor3 = SelectedTargets[p] and G or BG2
                b.TextColor3 = SelectedTargets[p] and Color3.new(0,0,0) or TX
            end)
        end
    end
end

local dlgOverlay = Instance.new("Frame", sg)
dlgOverlay.Size = UDim2.new(1, 0, 1, 0) dlgOverlay.BackgroundColor3 = Color3.new(0,0,0)
dlgOverlay.BackgroundTransparency = 0.6 dlgOverlay.Visible = false dlgOverlay.ZIndex = 900
local dlg = Instance.new("Frame", sg)
dlg.Size = UDim2.new(0, 300, 0, 350) dlg.Position = UDim2.new(0.5, -150, 0.5, -175)
dlg.BackgroundColor3 = BG dlg.Visible = false dlg.ZIndex = 901
Instance.new("UICorner", dlg).CornerRadius = UDim.new(0, 8)
local dlgTitle = Instance.new("TextLabel", dlg) dlgTitle.Size = UDim2.new(1, -20, 0, 30) dlgTitle.Position = UDim2.new(0, 10, 0, 0) dlgTitle.BackgroundTransparency = 1 dlgTitle.TextColor3 = G dlgTitle.Font = Enum.Font.SourceSansBold
local dlgBody = Instance.new("ScrollingFrame", dlg) dlgBody.Size = UDim2.new(1, -20, 1, -40) dlgBody.Position = UDim2.new(0, 10, 0, 35) dlgBody.BackgroundTransparency = 1 dlgBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
local dlgLay = Instance.new("UIListLayout", dlgBody) dlgLay.Padding = UDim.new(0, 4)
local function dlgBtn(text, color, cb)
    local b = Instance.new("TextButton", dlgBody) b.Size = UDim2.new(1, 0, 0, 30) b.BackgroundColor3 = BG2 b.Text = "  "..text b.TextColor3 = color b.Font = Enum.Font.SourceSansBold b.TextSize = 12 b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    b.MouseButton1Click:Connect(function() if cb then cb() end end)
end
local function closeDlg() dlg.Visible = false dlgOverlay.Visible = false end
dlgOverlay.InputBegan:Connect(closeDlg)