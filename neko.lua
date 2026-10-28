-- ==================================================================
-- ===== NYT MODS v30 — AIM TAB FIXED (3 NÚT TO + LIST HOẠT ĐỘNG) ====
-- ==================================================================
local ok, err = pcall(function()
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
    local G3 = Color3.fromRGB(200, 255, 220)
    local DIM = Color3.fromRGB(0, 80, 40)
    local BG = Color3.fromRGB(5, 10, 8)
    local BG2 = Color3.fromRGB(8, 18, 12)
    local TX = Color3.fromRGB(180, 255, 200)
    local CY = Color3.fromRGB(0, 255, 255)
    local RED = Color3.fromRGB(255, 60, 80)
    local YEL = Color3.fromRGB(255, 220, 100)
    local ORG = Color3.fromRGB(255, 150, 50)
    local PURPLE = Color3.fromRGB(140, 60, 220)

    local gp
    pcall(function() gp = gethui and gethui() end)
    if not gp then pcall(function() gp = game:GetService("CoreGui") end) end
    if not gp then gp = pl:WaitForChild("PlayerGui") end

    pcall(function()
        if gp:FindFirstChild("HackerNeko") then gp.HackerNeko:Destroy() end
        if gp:FindFirstChild("NekoESP") then gp.NekoESP:Destroy() end
    end)
    pcall(function() RS:UnbindFromRenderStep("NekoAimLock") end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "HackerNeko"
    sg.ResetOnSpawn = false
    sg.IgnoreGuiInset = true
    sg.DisplayOrder = 9999
    sg.Parent = gp

    local SS = game:GetService("SoundService")
    local SND = {on = true, vol = 0.6}
    local function playSnd(n)
        if not SND.on then return end
        pcall(function()
            local sd = Instance.new("Sound")
            sd.SoundId = "rbxasset://sounds/clickfast.wav"
            sd.Volume = math.clamp(SND.vol * (0.6 + math.random() * 0.3), 0, 1)
            sd.PlaybackSpeed = 0.9 + math.random() * 0.3
            sd.Parent = SS
            sd:Play()
            task.delay(1, function() sd:Destroy() end)
        end)
    end

    local ef = Instance.new("Folder", gp)
    ef.Name = "NekoESP"
    local epf = Instance.new("Folder", ef)
    epf.Name = "Players"

    local stt = {ws = 16, jp = 50}
    local tg = {espLine = false, espName = false, espHp = false, espDist = false, espBody = false, noclip = false, mapBright = false, fps = false, infJump = false, antiKB = true}
    local ghostDeath = {on = false}
    local spinState = {on = false, speed = 5}
    local autoFlyState = {on = false, stiffness = 50}
    local ghostFeet = {on = false, height = 0, baseY = nil}
    local spinAccum = 0
    local spinSavedAutoRotate = nil
    local autoFlySavedPlatform = nil
    local tpSelected = nil
    local teleportTo
    local fovCustom = nil
    local nlSafe = nil
    local nlGroundT = 0

    local acS = {on = false, cps = 10, button = "Left", mode = "Toggle", humanize = false, limit = 0, points = {}}
    local acFrames, acStrokes, acLabels = {}, {}, {}
    local acAcc, acIdx, acSession, acTotal = 0, 1, 0, 0
    local acStamps = {}
    local acLastStat = 0
    local MAX_PER_FRAME = 30

    -- ===== DELTA AIM =====
    local AimlockEnabled = true
    local AutoFireEnabled = false
    local ShowNameEnabled = true
    local ShowDistEnabled = true
    local SelectedTargets = {}
    local Target = nil
    local FOVRadius = 180

    local FOVCircle = nil
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false
        FOVCircle.Radius = FOVRadius
        FOVCircle.Color = CY
        FOVCircle.Thickness = 1.5
        FOVCircle.Filled = false
        FOVCircle.Transparency = 0.5
    end)

    local function GetRainbowColor()
        local t = tick() * 2
        return Color3.fromRGB(math.sin(t)*127+128, math.sin(t+2)*127+128, math.sin(t+4)*127+128)
    end

    local function GetTargetPart(char)
        if not char then return nil end
        return char:FindFirstChild("Head")
            or char:FindFirstChild("HumanoidRootPart")
            or char:FindFirstChild("UpperTorso")
            or char:FindFirstChild("Torso")
            or char:FindFirstChildWhichIsA("BasePart")
    end

    -- Aim Indicator trên màn hình
    local aimIndicator = Instance.new("TextLabel", sg)
    aimIndicator.Size = UDim2.new(0, 400, 0, 30)
    aimIndicator.Position = UDim2.new(0.5, -200, 0, 25)
    aimIndicator.BackgroundTransparency = 1
    aimIndicator.Text = ""
    aimIndicator.TextColor3 = G
    aimIndicator.TextStrokeTransparency = 0.4
    aimIndicator.TextStrokeColor3 = Color3.new(0,0,0)
    aimIndicator.Font = Enum.Font.CodeBold
    aimIndicator.TextSize = 16
    aimIndicator.ZIndex = 5000
    aimIndicator.Visible = false

    -- Render loop aim
    RS.RenderStepped:Connect(function()
        if FOVCircle then
            FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            FOVCircle.Color = GetRainbowColor()
            FOVCircle.Radius = FOVRadius
            FOVCircle.Visible = AimlockEnabled
        end

        if Target then
            local humanoid = Target.Parent and Target.Parent:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then Target = nil end
        end

        local closestTarget = nil
        local shortestDistance = 1500

        if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = pl.Character.HumanoidRootPart.Position
            for player, isSelected in pairs(SelectedTargets) do
                if isSelected and player and player.Parent and player.Character then
                    local char = player.Character
                    local humanoid = char:FindFirstChildOfClass("Humanoid")
                    local targetPart = GetTargetPart(char)
                    if humanoid and humanoid.Health > 0 and targetPart then
                        local d = (targetPart.Position - myPos).Magnitude
                        if d < shortestDistance then
                            shortestDistance = d
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end

        Target = closestTarget

        if AimlockEnabled and Target then
            cam.CFrame = CFrame.new(cam.CFrame.Position, Target.Position)
            if aimIndicator.Visible then
                aimIndicator.Text = "🎯 LOCKED: " .. (Target.Parent and Target.Parent.Name or "?")
                aimIndicator.TextColor3 = G
            end
            if AutoFireEnabled then
                pcall(function()
                    VU:Button1Down(Vector2.new(0, 0))
                    task.wait()
                    VU:Button1Up(Vector2.new(0, 0))
                end)
            end
        else
            if aimIndicator.Visible and AimlockEnabled then
                aimIndicator.Text = "🎯 AIM ON — Chưa chọn mục tiêu"
                aimIndicator.TextColor3 = YEL
            end
        end
    end)

    local espLines = {}
    local drawingOK = (Drawing ~= nil and Drawing.new ~= nil)

    local hfa = (writefile ~= nil) and (readfile ~= nil) and (isfile ~= nil)
    local WPF = "NekoWPs_" .. tostring(game.PlaceId) .. ".json"
    local ACF = "NekoAC_" .. tostring(game.PlaceId) .. ".json"
    local wps = {nil, nil, nil, nil, nil, nil, nil, nil}
    local wpHeight = 3

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
        return CFrame.new(a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12])
    end

    if hfa and isfile(ACF) then
        pcall(function()
            local d = HS:JSONDecode(readfile(ACF))
            if d then
                for k, v in pairs(d) do
                    if k ~= "points" then acS[k] = v end
                end
            end
        end)
    end

    local function saveAC()
        if not hfa then return end
        pcall(function()
            local vp = workspace.CurrentCamera.ViewportSize
            local pts = {}
            for i, f in ipairs(acFrames) do
                local c = f.AbsolutePosition + f.AbsoluteSize / 2
                pts[i] = {c.X / vp.X, c.Y / vp.Y}
            end
            acS.points = pts
            writefile(ACF, HS:JSONEncode(acS))
        end)
    end

    -- ===== MAIN UI =====
    local toggleBtn = Instance.new("Frame", sg)
    toggleBtn.Size = UDim2.new(0, 48, 0, 48)
    toggleBtn.Position = UDim2.new(0, 30, 0, 120)
    toggleBtn.BackgroundColor3 = BG
    toggleBtn.BackgroundTransparency = 0.15
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Active = true
    toggleBtn.ZIndex = 500
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)
    local tglStk = Instance.new("UIStroke", toggleBtn) tglStk.Color = G tglStk.Thickness = 1.5
    local tglGlow = Instance.new("UIStroke", toggleBtn) tglGlow.Color = G tglGlow.Thickness = 6 tglGlow.Transparency = 0.9
    local iconLbl = Instance.new("TextLabel", toggleBtn)
    iconLbl.Size = UDim2.new(1, 0, 1, 0) iconLbl.BackgroundTransparency = 1
    iconLbl.Text = ">_" iconLbl.Font = Enum.Font.Code iconLbl.TextSize = 18 iconLbl.TextColor3 = G iconLbl.ZIndex = 501
    local dot = Instance.new("Frame", toggleBtn)
    dot.Size = UDim2.new(0, 5, 0, 5) dot.Position = UDim2.new(1, -9, 0, 4)
    dot.BackgroundColor3 = G dot.BorderSizePixel = 0 dot.ZIndex = 502
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 470, 0, 380) main.Position = UDim2.new(0, 30, 0, 120)
    main.BackgroundColor3 = BG main.BackgroundTransparency = 0.05 main.BorderSizePixel = 0
    main.Active = true main.Visible = false main.ZIndex = 100
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 4)
    local stk = Instance.new("UIStroke", main) stk.Color = G stk.Thickness = 1.5
    local stkGlow = Instance.new("UIStroke", main) stkGlow.Color = G stkGlow.Thickness = 5 stkGlow.Transparency = 0.85
    local stkGrad = Instance.new("UIGradient", stk)
    stkGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, G), ColorSequenceKeypoint.new(0.5, CY), ColorSequenceKeypoint.new(1, G)})

    local hd = Instance.new("Frame", main)
    hd.Size = UDim2.new(1, 0, 0, 28) hd.BackgroundColor3 = BG2 hd.BorderSizePixel = 0 hd.ZIndex = 110
    Instance.new("UICorner", hd).CornerRadius = UDim.new(0, 4)
    local title = Instance.new("TextLabel", hd)
    title.Size = UDim2.new(1, -120, 1, 0) title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1 title.Text = "> ROOT@NEKO:~$ ./run.sh"
    title.Font = Enum.Font.Code title.TextSize = 13 title.TextColor3 = G
    title.TextXAlignment = Enum.TextXAlignment.Left title.ZIndex = 112
    local cl = Instance.new("TextButton", hd)
    cl.Size = UDim2.new(0, 24, 0, 24) cl.Position = UDim2.new(1, -28, 0.5, -12)
    cl.BackgroundTransparency = 1 cl.Text = "X" cl.Font = Enum.Font.Code
    cl.TextSize = 14 cl.TextColor3 = RED cl.AutoButtonColor = false cl.ZIndex = 113
    local sndBtn = Instance.new("TextButton", hd)
    sndBtn.Size = UDim2.new(0, 24, 0, 24) sndBtn.Position = UDim2.new(1, -54, 0.5, -12)
    sndBtn.BackgroundTransparency = 1 sndBtn.Text = "♪" sndBtn.Font = Enum.Font.Code
    sndBtn.TextSize = 16 sndBtn.TextColor3 = G sndBtn.AutoButtonColor = false sndBtn.ZIndex = 113
    sndBtn.MouseButton1Click:Connect(function()
        SND.on = not SND.on sndBtn.TextColor3 = SND.on and G or DIM
    end)

    local sb = Instance.new("Frame", main)
    sb.Size = UDim2.new(0, 104, 1, -64) sb.Position = UDim2.new(0, 6, 0, 34)
    sb.BackgroundTransparency = 1 sb.BorderSizePixel = 0 sb.ZIndex = 110
    local sbl = Instance.new("UIListLayout", sb)
    sbl.Padding = UDim.new(0, 2) sbl.SortOrder = Enum.SortOrder.LayoutOrder

    local ct = Instance.new("Frame", main)
    ct.Size = UDim2.new(1, -120, 1, -64) ct.Position = UDim2.new(0, 116, 0, 34)
    ct.BackgroundColor3 = BG2 ct.BackgroundTransparency = 0.4 ct.BorderSizePixel = 0 ct.ZIndex = 110
    Instance.new("UICorner", ct).CornerRadius = UDim.new(0, 4)
    local cstk = Instance.new("UIStroke", ct) cstk.Color = DIM cstk.Thickness = 1

    local stBar = Instance.new("Frame", main)
    stBar.Size = UDim2.new(1, 0, 0, 22) stBar.Position = UDim2.new(0, 0, 1, -22)
    stBar.BackgroundColor3 = BG2 stBar.BorderSizePixel = 0 stBar.ZIndex = 110
    Instance.new("UICorner", stBar).CornerRadius = UDim.new(0, 4)
    local stLbl = Instance.new("TextLabel", stBar)
    stLbl.Size = UDim2.new(1, -100, 1, 0) stLbl.Position = UDim2.new(0, 8, 0, 0)
    stLbl.BackgroundTransparency = 1 stLbl.Text = "[ OK ] ready"
    stLbl.Font = Enum.Font.Code stLbl.TextSize = 11 stLbl.TextColor3 = G
    stLbl.TextXAlignment = Enum.TextXAlignment.Left stLbl.ZIndex = 111
    local fpsLbl = Instance.new("TextLabel", stBar)
    fpsLbl.Size = UDim2.new(0, 80, 1, 0) fpsLbl.Position = UDim2.new(1, -88, 0, 0)
    fpsLbl.BackgroundTransparency = 1 fpsLbl.Text = "-- FPS" fpsLbl.Font = Enum.Font.Code
    fpsLbl.TextSize = 11 fpsLbl.TextColor3 = CY fpsLbl.TextXAlignment = Enum.TextXAlignment.Right fpsLbl.ZIndex = 111

    local dlgOverlay = Instance.new("Frame", sg)
    dlgOverlay.Size = UDim2.new(1, 0, 1, 0) dlgOverlay.BackgroundColor3 = Color3.new(0,0,0)
    dlgOverlay.BackgroundTransparency = 0.6 dlgOverlay.BorderSizePixel = 0 dlgOverlay.Visible = false dlgOverlay.ZIndex = 900
    local dlg = Instance.new("Frame", sg)
    dlg.Size = UDim2.new(0, 340, 0, 380) dlg.Position = UDim2.new(0.5, -170, 0.5, -190)
    dlg.BackgroundColor3 = BG dlg.BorderSizePixel = 0 dlg.Visible = false dlg.Active = true dlg.ZIndex = 901
    Instance.new("UICorner", dlg).CornerRadius = UDim.new(0, 4)
    local dlgStk = Instance.new("UIStroke", dlg) dlgStk.Color = G dlgStk.Thickness = 1.5
    local dlgTitle = Instance.new("TextLabel", dlg)
    dlgTitle.Size = UDim2.new(1, -20, 0, 28) dlgTitle.Position = UDim2.new(0, 12, 0, 8)
    dlgTitle.BackgroundTransparency = 1 dlgTitle.Text = "> OPTIONS" dlgTitle.Font = Enum.Font.Code
    dlgTitle.TextSize = 12 dlgTitle.TextColor3 = G dlgTitle.TextXAlignment = Enum.TextXAlignment.Left dlgTitle.ZIndex = 902
    local dlgBody = Instance.new("ScrollingFrame", dlg)
    dlgBody.Size = UDim2.new(1, -16, 1, -52) dlgBody.Position = UDim2.new(0, 8, 0, 38)
    dlgBody.BackgroundTransparency = 1 dlgBody.BorderSizePixel = 0 dlgBody.ScrollBarThickness = 2
    dlgBody.ScrollBarImageColor3 = G dlgBody.CanvasSize = UDim2.new(0,0,0,0)
    dlgBody.AutomaticCanvasSize = Enum.AutomaticSize.Y dlgBody.ScrollingDirection = Enum.ScrollingDirection.Y dlgBody.ZIndex = 902
    local dlgLay = Instance.new("UIListLayout", dlgBody) dlgLay.Padding = UDim.new(0, 4) dlgLay.SortOrder = Enum.SortOrder.LayoutOrder

    local function dlgBtn(text, color, cb)
        local b = Instance.new("TextButton", dlgBody)
        b.Size = UDim2.new(1, -4, 0, 36) b.BackgroundColor3 = BG2 b.BackgroundTransparency = 0.3
        b.BorderSizePixel = 0 b.Text = "  > " .. text b.Font = Enum.Font.Code
        b.TextSize = 13 b.TextColor3 = color b.TextXAlignment = Enum.TextXAlignment.Left b.AutoButtonColor = false
        b.LayoutOrder = #dlgBody:GetChildren() * 10 b.ZIndex = 903
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
        local s = Instance.new("UIStroke", b) s.Color = DIM s.Thickness = 1
        b.MouseButton1Click:Connect(function() playSnd("click") if cb then pcall(cb) end end)
        return b
    end

    local function closeDlg()
        dlg.Visible = false dlgOverlay.Visible = false
        for _, ch in ipairs(dlgBody:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
    end

    dlgOverlay.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then closeDlg() end
    end)

    -- ===== PLAYER LIST WINDOW (Delta gốc) =====
    local playerListWindow = Instance.new("Frame", sg)
    playerListWindow.Size = UDim2.new(0, 220, 0, 300)
    playerListWindow.Position = UDim2.new(0.5, -110, 0.5, -150)
    playerListWindow.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    playerListWindow.BorderSizePixel = 0
    playerListWindow.Visible = false
    playerListWindow.Active = true
    playerListWindow.ZIndex = 2000
    Instance.new("UICorner", playerListWindow).CornerRadius = UDim.new(0, 8)
    local plStk = Instance.new("UIStroke", playerListWindow)
    plStk.Color = CY plStk.Thickness = 1.5

    local plTitle = Instance.new("TextLabel", playerListWindow)
    plTitle.Size = UDim2.new(1, -40, 0, 30)
    plTitle.Position = UDim2.new(0, 8, 0, 0)
    plTitle.BackgroundTransparency = 1
    plTitle.Text = "★ CHỌN MỤC TIÊU AIM ★"
    plTitle.TextColor3 = CY
    plTitle.Font = Enum.Font.CodeBold
    plTitle.TextSize = 12
    plTitle.TextXAlignment = Enum.TextXAlignment.Left
    plTitle.ZIndex = 2001

    local plClose = Instance.new("TextButton", playerListWindow)
    plClose.Size = UDim2.new(0, 30, 0, 30)
    plClose.Position = UDim2.new(1, -32, 0, 0)
    plClose.BackgroundTransparency = 1
    plClose.Text = "X"
    plClose.TextColor3 = RED
    plClose.Font = Enum.Font.CodeBold
    plClose.TextSize = 14
    plClose.AutoButtonColor = false
    plClose.ZIndex = 2001
    plClose.MouseButton1Click:Connect(function() playerListWindow.Visible = false end)

    local plScroll = Instance.new("ScrollingFrame", playerListWindow)
    plScroll.Size = UDim2.new(1, -16, 1, -80)
    plScroll.Position = UDim2.new(0, 8, 0, 34)
    plScroll.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    plScroll.BorderSizePixel = 0
    plScroll.ScrollBarThickness = 3
    plScroll.ScrollBarImageColor3 = G
    plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    plScroll.ZIndex = 2001
    local plLay = Instance.new("UIListLayout", plScroll)
    plLay.Padding = UDim.new(0, 4) plLay.SortOrder = Enum.SortOrder.LayoutOrder

    local plCount = Instance.new("TextLabel", playerListWindow)
    plCount.Size = UDim2.new(1, -16, 0, 20)
    plCount.Position = UDim2.new(0, 8, 1, -46)
    plCount.BackgroundTransparency = 1
    plCount.Text = "Đã chọn: 0 người"
    plCount.TextColor3 = YEL
    plCount.Font = Enum.Font.Code
    plCount.TextSize = 11
    plCount.TextXAlignment = Enum.TextXAlignment.Left
    plCount.ZIndex = 2001

    local function updateCount()
        local n = 0
        for _ in pairs(SelectedTargets) do n = n + 1 end
        plCount.Text = "Đã chọn: " .. n .. " người"
    end

    local plRefresh = Instance.new("TextButton", playerListWindow)
    plRefresh.Size = UDim2.new(1, -16, 0, 20)
    plRefresh.Position = UDim2.new(0, 8, 1, -22)
    plRefresh.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    plRefresh.Text = "🔄 LÀM MỚI DANH SÁCH"
    plRefresh.TextColor3 = Color3.fromRGB(255, 255, 200)
    plRefresh.Font = Enum.Font.Code
    plRefresh.TextSize = 11
    plRefresh.AutoButtonColor = false
    plRefresh.ZIndex = 2001
    Instance.new("UICorner", plRefresh).CornerRadius = UDim.new(0, 4)

    local function RefreshPlayerList()
        for _, child in ipairs(plScroll:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= pl then
                local playerRef = p
                local pBtn = Instance.new("TextButton", plScroll)
                pBtn.Size = UDim2.new(1, -8, 0, 32)

                local displayName = playerRef.Name
                local hasDist = false
                local dist = 0
                if playerRef.Character and playerRef.Character:FindFirstChild("HumanoidRootPart")
                    and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    hasDist = true
                    dist = math.floor((playerRef.Character.HumanoidRootPart.Position - pl.Character.HumanoidRootPart.Position).Magnitude)
                end

                if ShowNameEnabled and ShowDistEnabled and hasDist then
                    displayName = playerRef.Name .. " [" .. dist .. "m]"
                elseif ShowNameEnabled then
                    displayName = playerRef.Name
                elseif ShowDistEnabled and hasDist then
                    displayName = "[" .. dist .. "m]"
                end

                pBtn.BackgroundColor3 = SelectedTargets[playerRef] and Color3.fromRGB(40, 200, 70) or Color3.fromRGB(60, 60, 60)
                pBtn.Text = displayName
                pBtn.TextColor3 = Color3.new(1, 1, 1)
                pBtn.TextSize = 12
                pBtn.Font = Enum.Font.Code
                pBtn.AutoButtonColor = false
                pBtn.ZIndex = 2002
                Instance.new("UICorner", pBtn).CornerRadius = UDim.new(0, 4)

                pBtn.MouseButton1Click:Connect(function()
                    playSnd("click")
                    if SelectedTargets[playerRef] then
                        SelectedTargets[playerRef] = nil
                        pBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    else
                        SelectedTargets[playerRef] = true
                        pBtn.BackgroundColor3 = Color3.fromRGB(40, 200, 70)
                    end
                    updateCount()
                end)
            end
        end
        updateCount()
    end

    plRefresh.MouseButton1Click:Connect(function() playSnd("click") RefreshPlayerList() end)

    -- Manual drag cho player list
    do
        local drag, start, startPos = false, nil, nil
        plTitle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true start = i.Position startPos = playerListWindow.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - start
                playerListWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)
    end

    P.PlayerRemoving:Connect(function(p)
        SelectedTargets[p] = nil
        if playerListWindow.Visible then RefreshPlayerList() end
    end)
    P.PlayerAdded:Connect(function(p) task.wait(2) if playerListWindow.Visible then RefreshPlayerList() end end)

    -- ===== TABS =====
    local tabs = {"MOVE", "ESP", "PLAYER", "TELE", "AIM", "INFO"}
    local pages, tabBtns = {}, {}
    local activeTab = nil

    local function mkTabBtn(parent, name, order)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, 0, 0, 32) b.BackgroundColor3 = BG2
        b.BackgroundTransparency = 0.5 b.BorderSizePixel = 0
        b.Text = name b.Font = Enum.Font.Code b.TextSize = 12
        b.TextColor3 = G2 b.TextXAlignment = Enum.TextXAlignment.Left
        b.AutoButtonColor = false b.LayoutOrder = order b.ZIndex = 111
        b.TextXAlignment = Enum.TextXAlignment.Center
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 3)
        return b
    end

    local function switchTab(name)
        activeTab = name
        for n, p in pairs(pages) do p.Visible = (n == name) end
        for n, b in pairs(tabBtns) do
            local on = (n == name)
            T:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = on and G or BG2, BackgroundTransparency = on and 0.15 or 0.5}):Play()
            b.TextColor3 = on and Color3.new(0, 0, 0) or G2
        end
    end

    for i, n in ipairs(tabs) do
        local p = Instance.new("ScrollingFrame", ct)
        p.Size = UDim2.new(1, -8, 1, -8) p.Position = UDim2.new(0, 4, 0, 4)
        p.BackgroundTransparency = 1 p.BorderSizePixel = 0 p.ScrollBarThickness = 3
        p.ScrollBarImageColor3 = G p.CanvasSize = UDim2.new(0,0,0,0)
        p.AutomaticCanvasSize = Enum.AutomaticSize.Y p.ScrollingDirection = Enum.ScrollingDirection.Y
        p.Visible = false p.ZIndex = 111
        local l = Instance.new("UIListLayout", p) l.Padding = UDim.new(0, 4) l.SortOrder = Enum.SortOrder.LayoutOrder
        pages[n] = p
        local b = mkTabBtn(sb, n, i)
        b.MouseButton1Click:Connect(function() playSnd("click") switchTab(n) end)
        tabBtns[n] = b
    end

    -- ===== HELPERS =====
    local function mkSec(parent, txt)
        local s = Instance.new("Frame", parent)
        s.Size = UDim2.new(1, -8, 0, 26) s.BackgroundTransparency = 1
        s.LayoutOrder = #parent:GetChildren() * 10
        local bar = Instance.new("Frame", s)
        bar.Size = UDim2.new(0, 3, 0, 12) bar.Position = UDim2.new(0, 4, 0.5, -6)
        bar.BackgroundColor3 = CY bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
        local l = Instance.new("TextLabel", s)
        l.Size = UDim2.new(1, -16, 1, 0) l.Position = UDim2.new(0, 14, 0, 0)
        l.BackgroundTransparency = 1 l.Text = txt l.Font = Enum.Font.Code
        l.TextSize = 12 l.TextColor3 = CY l.TextXAlignment = Enum.TextXAlignment.Left
    end

    local function mkTog(parent, name, default, cb)
        local state = default or false
        local row = Instance.new("TextButton", parent)
        row.Size = UDim2.new(1, -8, 0, 34) row.BackgroundColor3 = BG
        row.BackgroundTransparency = 0.3 row.BorderSizePixel = 0 row.Text = ""
        row.AutoButtonColor = false row.LayoutOrder = #parent:GetChildren() * 10 row.ZIndex = 112
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local rs = Instance.new("UIStroke", row) rs.Color = DIM rs.Thickness = 1 rs.Transparency = 0.5
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -70, 1, 0) lbl.Position = UDim2.new(0, 16, 0, 0)
        lbl.BackgroundTransparency = 1 lbl.Text = name lbl.Font = Enum.Font.Code
        lbl.TextSize = 12 lbl.TextColor3 = TX lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 113
        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(0, 40, 0, 20) track.Position = UDim2.new(1, -48, 0.5, -10)
        track.BackgroundColor3 = DIM track.BorderSizePixel = 0 track.ZIndex = 113
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame", track)
        knob.Size = UDim2.new(0, 14, 0, 14) knob.Position = UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = G2 knob.BorderSizePixel = 0 knob.ZIndex = 114
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
        local function render(anim)
            local ti = TweenInfo.new(anim and 0.15 or 0, Enum.EasingStyle.Quad)
            T:Create(track, ti, {BackgroundColor3 = state and G or DIM}):Play()
            T:Create(knob, ti, {Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = state and Color3.new(0,0,0) or G2}):Play()
            lbl.TextColor3 = state and G3 or TX
        end
        render(false)
        row.MouseButton1Click:Connect(function()
            state = not state render(true) playSnd("click")
            if cb then pcall(cb, state) end
        end)
        return row
    end

    local function mkSli(parent, name, mn, mx, dv, cb)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, -8, 0, 46) row.BackgroundColor3 = BG
        row.BackgroundTransparency = 0.3 row.BorderSizePixel = 0
        row.LayoutOrder = #parent:GetChildren() * 10 row.ZIndex = 112
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local rs = Instance.new("UIStroke", row) rs.Color = DIM rs.Thickness = 1 rs.Transparency = 0.5
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -80, 0, 18) lbl.Position = UDim2.new(0, 10, 0, 4)
        lbl.BackgroundTransparency = 1 lbl.Text = name lbl.Font = Enum.Font.Code
        lbl.TextSize = 12 lbl.TextColor3 = TX lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.ZIndex = 113
        local val = Instance.new("TextLabel", row)
        val.Size = UDim2.new(0, 64, 0, 18) val.Position = UDim2.new(1, -72, 0, 4)
        val.BackgroundTransparency = 1 val.Text = tostring(dv) val.Font = Enum.Font.Code
        val.TextSize = 12 val.TextColor3 = G val.TextXAlignment = Enum.TextXAlignment.Right val.ZIndex = 113
        local track = Instance.new("Frame", row)
        track.Size = UDim2.new(1, -20, 0, 6) track.Position = UDim2.new(0, 10, 0, 32)
        track.BackgroundColor3 = DIM track.BorderSizePixel = 0 track.ZIndex = 113
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)
        local pct = math.clamp((dv - mn) / (mx - mn), 0, 1)
        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new(pct, 0, 1, 0) fill.BackgroundColor3 = G fill.BorderSizePixel = 0 fill.ZIndex = 114
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        local thumb = Instance.new("Frame", track)
        thumb.Size = UDim2.new(0, 16, 0, 16) thumb.Position = UDim2.new(pct, -8, 0.5, -8)
        thumb.BackgroundColor3 = Color3.new(1,1,1) thumb.BorderSizePixel = 0 thumb.ZIndex = 115
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
        local ts = Instance.new("UIStroke", thumb) ts.Color = G ts.Thickness = 2
        local hit = Instance.new("TextButton", row)
        hit.Size = UDim2.new(1, -12, 0, 28) hit.Position = UDim2.new(0, 6, 0, 18)
        hit.BackgroundTransparency = 1 hit.Text = "" hit.ZIndex = 116
        local drag = false
        local lastV = nil
        local function up(x)
            local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(p, 0, 1, 0) thumb.Position = UDim2.new(p, -8, 0.5, -8)
            local v = mn + (mx - mn) * p
            if mx >= 10 and math.floor(mx) == mx and math.floor(mn) == mn then
                v = math.floor(v + 0.5)
            else
                v = math.floor(v * 10) / 10
            end
            val.Text = tostring(v)
            if v ~= lastV then lastV = v if cb then pcall(cb, v) end end
        end
        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                drag = true pcall(function() parent.ScrollingEnabled = false end)
                up(i.Position.X)
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then up(i.Position.X) end
        end)
        UIS.InputEnded:Connect(function(i)
            if drag and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then
                drag = false pcall(function() parent.ScrollingEnabled = true end)
            end
        end)
    end

    local function mkBtn(parent, name, cb)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, -8, 0, 34) b.BackgroundColor3 = BG
        b.BackgroundTransparency = 0.3 b.BorderSizePixel = 0
        b.Text = "  > " .. name b.Font = Enum.Font.Code b.TextSize = 12
        b.TextColor3 = G b.TextXAlignment = Enum.TextXAlignment.Left b.AutoButtonColor = false
        b.LayoutOrder = #parent:GetChildren() * 10 b.ZIndex = 112
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local st = Instance.new("UIStroke", b) st.Color = DIM st.Thickness = 1
        b.MouseButton1Click:Connect(function()
            playSnd("click") b.Text = "  > [EXEC...]"
            if cb then task.spawn(function() pcall(cb) end) end
            task.wait(0.15) b.Text = "  > " .. name
        end)
        return b
    end

    -- ===== CUSTOM BIG BUTTON cho Tab AIM =====
    local function mkBigBtn(parent, name, color, cb)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, -8, 0, 52)
        b.BackgroundColor3 = color
        b.Text = name
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 15
        b.Font = Enum.Font.CodeBold
        b.AutoButtonColor = false
        b.LayoutOrder = #parent:GetChildren() * 10
        b.ZIndex = 112
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
        local stk2 = Instance.new("UIStroke", b)
        stk2.Color = color:Lerp(Color3.new(1, 1, 1), 0.5)
        stk2.Thickness = 2
        b.MouseButton1Click:Connect(function()
            playSnd("click")
            if cb then pcall(cb, b) end
        end)
        return b
    end

    -- ================= TAB AIM =================
    mkSec(pages["AIM"], "// AIMBOT CONTROLS")

    local aimLockBtn = mkBigBtn(pages["AIM"], "🎯 AIMLOCK: ON", G2, function(btn)
        AimlockEnabled = not AimlockEnabled
        if AimlockEnabled then
            btn.Text = "🎯 AIMLOCK: ON"
            btn.BackgroundColor3 = G2
        else
            btn.Text = "🎯 AIMLOCK: OFF"
            btn.BackgroundColor3 = RED
        end
    end)

    local autoFireBtn = mkBigBtn(pages["AIM"], "💥 AUTO FIRE: OFF", RED, function(btn)
        AutoFireEnabled = not AutoFireEnabled
        if AutoFireEnabled then
            btn.Text = "💥 AUTO FIRE: ON"
            btn.BackgroundColor3 = G2
        else
            btn.Text = "💥 AUTO FIRE: OFF"
            btn.BackgroundColor3 = RED
        end
    end)

    local openListBtn = mkBigBtn(pages["AIM"], "📋 MỞ DANH SÁCH CHỌN NGƯỜI AIM", PURPLE, function()
        playerListWindow.Visible = true
        RefreshPlayerList()
    end)

    local showIndicatorBtn = mkBigBtn(pages["AIM"], "👁️ AIM INDICATOR: ON", CY, function(btn)
        aimIndicator.Visible = not aimIndicator.Visible
        btn.Text = aimIndicator.Visible and "👁️ AIM INDICATOR: ON" or "👁️ AIM INDICATOR: OFF"
        btn.BackgroundColor3 = aimIndicator.Visible and CY or Color3.fromRGB(80, 80, 80)
    end)
    aimIndicator.Visible = true

    mkSec(pages["AIM"], "// CẤU HÌNH")
    mkTog(pages["AIM"], "HIỆN TÊN TRONG LIST", true, function(on) ShowNameEnabled = on if playerListWindow.Visible then RefreshPlayerList() end end)
    mkTog(pages["AIM"], "HIỆN KHOẢNG CÁCH", true, function(on) ShowDistEnabled = on if playerListWindow.Visible then RefreshPlayerList() end end)
    mkSli(pages["AIM"], "BÁN KÍNH FOV", 50, 800, 180, function(v)
        FOVRadius = v
        if FOVCircle then FOVCircle.Radius = v end
    end)
    mkBtn(pages["AIM"], "BỎ CHỌN TẤT CẢ", function()
        SelectedTargets = {}
        if playerListWindow.Visible then RefreshPlayerList() end
    end)

    -- ================= CÁC TAB CÒN LẠI (giữ nguyên) =================
    mkSec(pages["MOVE"], "// SPEED")
    mkSli(pages["MOVE"], "Walk Speed", 16, 500, 16, function(v) stt.ws = v end)
    mkSec(pages["MOVE"], "// JUMP")
    mkSli(pages["MOVE"], "Jump Power", 50, 300, 50, function(v) stt.jp = v end)
    mkTog(pages["MOVE"], "INFINITE JUMP", false, function(on) tg.infJump = on end)
    mkSec(pages["MOVE"], "// AUTO CLICKER")
    mkTog(pages["MOVE"], "AUTO CLICKER", false, function(on) acSetRunning(on) end)
    mkSli(pages["MOVE"], "CPS", 0, 500, 10, function(v) acS.cps = v end)
    mkBtn(pages["MOVE"], "CLICK BUTTON", function()
        acS.button = (acS.button == "Left") and "Right" or "Left"
    end)

    mkSec(pages["ESP"], "// ESP")
    mkTog(pages["ESP"], "ESP NAME", false, function(on) tg.espName = on applyESPToggles() scanESP() end)
    mkTog(pages["ESP"], "ESP HEALTH", false, function(on) tg.espHp = on applyESPToggles() scanESP() end)
    mkTog(pages["ESP"], "ESP DISTANCE", false, function(on) tg.espDist = on applyESPToggles() scanESP() end)
    mkTog(pages["ESP"], "ESP BODY", false, function(on) tg.espBody = on applyESPToggles() scanESP() end)

    mkSec(pages["PLAYER"], "// SURVIVAL")
    mkTog(pages["PLAYER"], "NOCLIP", false, function(on) tg.noclip = on setNoclip(on) end)
    mkTog(pages["PLAYER"], "ANTI-KB", true, function(on) tg.antiKB = on akbStates(on) end)
    mkTog(pages["PLAYER"], "FPS BOOST", false, function(on) tg.fps = on setFPS(on) end)
    mkTog(pages["PLAYER"], "MAP BRIGHT", false, function(on) tg.mapBright = on setMapBright(on) end)
    mkSec(pages["PLAYER"], "// UTILS")
    mkBtn(pages["PLAYER"], "RESET CHARACTER", function()
        local c = pl.Character if c then local h = c:FindFirstChildOfClass("Humanoid") if h then h.Health = 0 end end
    end)

    mkSec(pages["TELE"], "// TELEPORT")
    mkBtn(pages["TELE"], "REJOIN", function()
        pcall(function()
            if #P:GetPlayers() <= 1 then TS:Teleport(game.PlaceId, pl)
            else TS:TeleportToPlaceInstance(game.PlaceId, game.JobId, pl) end
        end)
    end)

    -- ========== Lighting / FPS / Noclip / AntiKB / ESP ==========
    local BASE_LIGHTING = {Brightness = L.Brightness, ClockTime = L.ClockTime, Ambient = L.Ambient, OutdoorAmbient = L.OutdoorAmbient, GlobalShadows = L.GlobalShadows, FogEnd = L.FogEnd, FogStart = L.FogStart, ExposureCompensation = L.ExposureCompensation}
    local function restoreLighting() pcall(function() for k, v in pairs(BASE_LIGHTING) do L[k] = v end end) end
    local function reapplyLighting()
        restoreLighting()
        if tg.fps then pcall(function() L.GlobalShadows = false L.FogEnd = 1e5 L.FogStart = 1e5 end) end
        if tg.mapBright then pcall(function() L.Brightness = 3 L.ClockTime = 14 L.Ambient = Color3.fromRGB(180, 180, 180) L.OutdoorAmbient = Color3.fromRGB(180, 180, 180) L.FogEnd = 1e5 L.FogStart = 1e5 L.GlobalShadows = false L.ExposureCompensation = 0.5 end) end
    end
    local fpsSaved = {active = false, gen = 0, parts = {}, effects = {}, postFx = {}, atmos = {}, conns = {}, qualityLevel = nil}
    local function enableFPS()
        if fpsSaved.active then return end
        fpsSaved.active = true fpsSaved.gen = fpsSaved.gen + 1
        local myGen = fpsSaved.gen
        fpsSaved.parts = {} fpsSaved.effects = {} fpsSaved.postFx = {} fpsSaved.atmos = {} fpsSaved.conns = {}
        pcall(function() if settings and settings().Rendering then fpsSaved.qualityLevel = settings().Rendering.QualityLevel settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end end)
        pcall(function() if setfpscap then setfpscap(999) end end)
        reapplyLighting()
        for _, v in ipairs(L:GetChildren()) do pcall(function()
            if v:IsA("PostEffect") and v.Enabled then fpsSaved.postFx[v] = true v.Enabled = false
            elseif v:IsA("Atmosphere") then fpsSaved.atmos[v] = v.Density v.Density = 0 end
        end) end
        task.spawn(function()
            local all = workspace:GetDescendants()
            for i = 1, #all do
                if fpsSaved.gen ~= myGen or not fpsSaved.active then return end
                local o = all[i]
                pcall(function()
                    if o:IsA("BasePart") then
                        if o.CastShadow then if not fpsSaved.parts[o] then fpsSaved.parts[o] = true end o.CastShadow = false end
                    elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then
                        if o.Enabled then if not fpsSaved.effects[o] then fpsSaved.effects[o] = true end o.Enabled = false end
                    end
                end)
                if i % 200 == 0 then task.wait() end
            end
        end)
    end
    local function disableFPS()
        if not fpsSaved.active then return end
        fpsSaved.active = false fpsSaved.gen = fpsSaved.gen + 1
        for _, c in ipairs(fpsSaved.conns) do pcall(function() c:Disconnect() end) end
        fpsSaved.conns = {} reapplyLighting()
        pcall(function() if settings and settings().Rendering and fpsSaved.qualityLevel then settings().Rendering.QualityLevel = fpsSaved.qualityLevel end end)
        for fx in pairs(fpsSaved.postFx) do pcall(function() if fx and fx.Parent then fx.Enabled = true end end) end
        fpsSaved.postFx = {}
        for at, d in pairs(fpsSaved.atmos) do pcall(function() if at and at.Parent then at.Density = d end end) end
        fpsSaved.atmos = {}
        for fx in pairs(fpsSaved.effects) do pcall(function() if fx and fx.Parent then fx.Enabled = true end end) end
        fpsSaved.effects = {}
        for p in pairs(fpsSaved.parts) do pcall(function() if p and p.Parent then p.CastShadow = true end end) end
        fpsSaved.parts = {}
    end
    local function setFPS(on) if on then enableFPS() else disableFPS() end end
    local function setMapBright(on) tg.mapBright = on reapplyLighting() end

    local noclipSaved = {}
    local function noclipApply(part)
        if not part:IsA("BasePart") then return end
        if noclipSaved[part] == nil then noclipSaved[part] = part.CanCollide end
        part.CanCollide = false
    end
    local function restoreCollide()
        for part, orig in pairs(noclipSaved) do pcall(function() if part and part.Parent then part.CanCollide = orig end end) end
        noclipSaved = {}
    end
    local function setNoclip(on)
        if not on then restoreCollide() end
    end
    RS.Stepped:Connect(function()
        if not tg.noclip then return end
        local c = pl.Character if not c then return end
        for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then noclipApply(p) end end
    end)

    local akbConn = nil
    local function akbStates(on)
        local c = pl.Character local h = c and c:FindFirstChildOfClass("Humanoid") if not h then return end
        for _, st in ipairs({Enum.HumanoidStateType.FallingDown, Enum.HumanoidStateType.Ragdoll}) do
            pcall(function() h:SetStateEnabled(st, not on) end)
        end
    end
    local function akbHook(char)
        if akbConn then akbConn:Disconnect() akbConn = nil end
        akbConn = char.DescendantAdded:Connect(function(d)
            if tg.antiKB then
                local movers = {BodyVelocity = true, BodyForce = true, BodyPosition = true, BodyGyro = true, LinearVelocity = true, VectorForce = true, AngularVelocity = true, Torque = true, BodyAngularVelocity = true}
                if movers[d.ClassName] then task.defer(function() pcall(function() d:Destroy() end) end) end
            end
        end)
        akbStates(tg.antiKB)
    end
    RS.Heartbeat:Connect(function()
        if not tg.antiKB then return end
        local c = pl.Character local h = c and c:FindFirstChildOfClass("Humanoid")
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        if not h or not hr or h.Health <= 0 then return end
        local st = h:GetState()
        if st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Ragdoll then
            if not autoFlyState.on then pcall(function() h.PlatformStand = false h:ChangeState(Enum.HumanoidStateType.GetUp) end) end
        end
    end)

    local evs = {}
    local function buildESP(char)
        if not char or char == pl.Character or evs[char] then return end
        local hr = char:FindFirstChild("HumanoidRootPart") local head = char:FindFirstChild("Head") or hr
        if not hr or not head then return end
        local fold = Instance.new("Folder", epf) fold.Name = char.Name
        local hl = Instance.new("Highlight", fold)
        hl.Adornee = char hl.FillColor = G hl.FillTransparency = 0.9 hl.OutlineColor = G
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop hl.Enabled = tg.espBody
        local infoBB = Instance.new("BillboardGui", fold)
        infoBB.Adornee = head infoBB.Size = UDim2.new(0, 220, 0, 50) infoBB.StudsOffset = Vector3.new(0, 2.8, 0)
        infoBB.AlwaysOnTop = true infoBB.LightInfluence = 0 infoBB.MaxDistance = 5000
        infoBB.Enabled = (tg.espName or tg.espDist)
        local nameLbl = Instance.new("TextLabel", infoBB)
        nameLbl.Size = UDim2.new(1, 0, 0, 30) nameLbl.BackgroundTransparency = 1 nameLbl.Text = char.Name
        nameLbl.TextColor3 = G nameLbl.TextStrokeTransparency = 0.1 nameLbl.Font = Enum.Font.Code
        nameLbl.TextSize = 20 nameLbl.Visible = tg.espName
        local distLbl = Instance.new("TextLabel", infoBB)
        distLbl.Size = UDim2.new(1, 0, 0, 18) distLbl.Position = UDim2.new(0, 0, 0, 30)
        distLbl.BackgroundTransparency = 1 distLbl.Text = "0m" distLbl.TextColor3 = YEL
        distLbl.Font = Enum.Font.Code distLbl.TextSize = 14 distLbl.Visible = tg.espDist
        local hpBB = Instance.new("BillboardGui", fold)
        hpBB.Adornee = hr hpBB.Size = UDim2.new(0, 6, 0, 40) hpBB.StudsOffset = Vector3.new(1.4, 0.3, 0)
        hpBB.AlwaysOnTop = true hpBB.LightInfluence = 0 hpBB.MaxDistance = 5000 hpBB.Enabled = tg.espHp
        local hpBg = Instance.new("Frame", hpBB)
        hpBg.Size = UDim2.new(1, 0, 1, 0) hpBg.BackgroundColor3 = Color3.fromRGB(0, 20, 10)
        hpBg.BackgroundTransparency = 0.2 hpBg.BorderSizePixel = 1 hpBg.BorderColor3 = G
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(0, 2)
        local hpFill = Instance.new("Frame", hpBg)
        hpFill.AnchorPoint = Vector2.new(0, 1) hpFill.Position = UDim2.new(0, 0, 1, 0)
        hpFill.Size = UDim2.new(1, 0, 1, 0) hpFill.BackgroundColor3 = G hpFill.BorderSizePixel = 0
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(0, 2)
        evs[char] = {folder = fold, hl = hl, infoBB = infoBB, nameLbl = nameLbl, distLbl = distLbl, hpBB = hpBB, hpFill = hpFill}
    end
    local function destroyESP(char)
        if evs[char] then pcall(function() evs[char].folder:Destroy() end) evs[char] = nil end
    end
    local function applyESPToggles()
        for char, data in pairs(evs) do
            if char.Parent then
                data.nameLbl.Visible = tg.espName data.distLbl.Visible = tg.espDist
                data.hpBB.Enabled = tg.espHp data.hl.Enabled = tg.espBody
                data.infoBB.Enabled = (tg.espName or tg.espDist)
            else destroyESP(char) end
        end
    end
    local function scanESP()
        if not (tg.espName or tg.espHp or tg.espDist or tg.espBody) then return end
        for _, p in ipairs(P:GetPlayers()) do
            local ch = p.Character
            if p ~= pl and ch and not evs[ch] and ch:FindFirstChild("HumanoidRootPart") then pcall(buildESP, ch) end
        end
        for ch in pairs(evs) do if not ch.Parent then destroyESP(ch) end end
    end
    task.spawn(function() while true do task.wait(1) scanESP() end end)

    -- Auto clicker
    local function acDoClick()
        if #acFrames == 0 then return end
        local f = acFrames[acIdx]
        acIdx = acIdx % #acFrames + 1
        if not f then return end
        local c = f.AbsolutePosition + f.AbsoluteSize / 2
        pcall(function() VU:ClickButton1(c) end)
        acTotal = acTotal + 1
    end
    local function acAddPoint(cx, cy)
        local f = Instance.new("Frame", sg)
        f.Size = UDim2.new(0, 50, 0, 50) f.Position = UDim2.new(0, cx - 25, 0, cy - 25)
        f.BackgroundTransparency = 1 f.ZIndex = 50
        local v = Instance.new("Frame", f) v.Size = UDim2.new(0, 2, 1, 0) v.Position = UDim2.new(0.5, -1, 0, 0)
        v.BackgroundColor3 = G v.BorderSizePixel = 0 v.ZIndex = 51
        local h = Instance.new("Frame", f) h.Size = UDim2.new(1, 0, 0, 2) h.Position = UDim2.new(0, 0, 0.5, -1)
        h.BackgroundColor3 = G h.BorderSizePixel = 0 h.ZIndex = 51
        table.insert(acFrames, f)
    end
    local function acSetRunning(v)
        acS.on = v acAcc = 0
    end

    -- Character lifecycle
    local function onCharSpawn(char)
        local hr = char:WaitForChild("HumanoidRootPart", 10)
        local h = char:WaitForChild("Humanoid", 10)
        if not hr or not h then return end
        akbHook(char)
    end
    pl.CharacterAdded:Connect(onCharSpawn)
    if pl.Character then task.spawn(function() onCharSpawn(pl.Character) end) end

    -- Toggle button drag
    local dragging = false
    local dragStart, dragStartPos
    local moved = false
    toggleBtn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true moved = false dragStart = i.Position dragStartPos = toggleBtn.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            if d.Magnitude > 5 then moved = true end
            toggleBtn.Position = UDim2.new(dragStartPos.X.Scale, dragStartPos.X.Offset + d.X, dragStartPos.Y.Scale, dragStartPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) and dragging then
            dragging = false
            if not moved then
                main.Visible = not main.Visible
                if not main.Visible then playerListWindow.Visible = false end
            end
        end
    end)
    main.Position = toggleBtn.Position

    cl.MouseButton1Click:Connect(function()
        main.Visible = false
        playerListWindow.Visible = false
    end)

    -- FPS counter
    local frmCnt = 0
    RS.RenderStepped:Connect(function() frmCnt = frmCnt + 1 end)
    task.spawn(function() while true do task.wait(1)
        pcall(function() fpsLbl.Text = math.floor(frmCnt) .. " FPS" frmCnt = 0 end)
    end end)

    -- Auto clicker loop
    RS.RenderStepped:Connect(function(dt)
        if acS.on and acS.cps > 0 then
            acAcc = acAcc + acS.cps * dt
            local n = math.floor(acAcc) acAcc = acAcc - n
            if n > 30 then n = 30 end
            for _ = 1, n do acDoClick() end
        end
    end)

    switchTab("AIM")
    playSnd("open")
    print("[NYT v30] AIM tab fixed — 3 nút to + list hoạt động")
end)

if not ok then
    warn("[NEKO ERROR] " .. tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "NEKO ERROR", Text = tostring(err), Duration = 15
        })
    end)
end