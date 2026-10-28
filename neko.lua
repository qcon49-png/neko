-- ==================================================================
-- ===== NYT MODS v33 — BOX ESP RAINBOW + TERMUX LOGO (TỐI GIẢN) ====
-- ==================================================================
local ok, err = pcall(function()
    local P = game:GetService("Players")
    local RS = game:GetService("RunService")
    local UIS = game:GetService("UserInputService")
    local T = game:GetService("TweenService")
    local L = game:GetService("Lighting")
    local TS = game:GetService("TeleportService")
    local pl = P.LocalPlayer
    local cam = workspace.CurrentCamera

    -- Màu sắc
    local BG = Color3.fromRGB(20, 20, 25)
    local BG2 = Color3.fromRGB(30, 30, 35)
    local NEON_GREEN = Color3.fromRGB(0, 255, 120)
    local RED = Color3.fromRGB(255, 60, 60)
    local TEXT = Color3.fromRGB(220, 220, 220)
    local TEXT_DIM = Color3.fromRGB(150, 150, 150)

    local gp = gethui and gethui() or game:GetService("CoreGui")
    pcall(function()
        if gp:FindFirstChild("HackerNeko") then gp.HackerNeko:Destroy() end
        if gp:FindFirstChild("NekoESP") then gp.NekoESP:Destroy() end
    end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "HackerNeko" sg.ResetOnSpawn = false sg.IgnoreGuiInset = true sg.DisplayOrder = 9999 sg.Parent = gp

    -- ===== BIẾN TOÀN CỤC =====
    local stt = {ws = 16, jp = 50}
    local tg = {espBoxLine = false, espNameDist = false, espHp = false, noclip = false, antiKB = true, fps = false}

    -- Delta Aim Variables
    local AimlockEnabled = true
    local SelectedTargets = {}
    local Target = nil
    local FOVRadius = 180
    local FOVCircle = nil
    
    pcall(function()
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Visible = false FOVCircle.Thickness = 1.5 FOVCircle.Filled = false FOVCircle.Transparency = 0.5
    end)

    local function GetRainbowColor()
        local t = tick() * 2
        return Color3.fromRGB(math.sin(t)*127+128, math.sin(t+2)*127+128, math.sin(t+4)*127+128)
    end

    local function GetTargetPart(char)
        if not char then return nil end
        return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
    end

    -- ===== LOGIC AIM (CHỈ KÉO CAM) =====
    RS.RenderStepped:Connect(function()
        if FOVCircle then
            FOVCircle.Position = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
            FOVCircle.Color = GetRainbowColor() FOVCircle.Radius = FOVRadius FOVCircle.Visible = AimlockEnabled
        end
        if Target then
            local hum = Target.Parent and Target.Parent:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then Target = nil end
        end
        local closest, shortest = nil, 1500
        if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = pl.Character.HumanoidRootPart.Position
            for p, isSel in pairs(SelectedTargets) do
                if isSel and p.Parent and p.Character then
                    local hum = p.Character:FindFirstChildOfClass("Humanoid")
                    local part = GetTargetPart(p.Character)
                    if hum and hum.Health > 0 and part then
                        local d = (part.Position - myPos).Magnitude
                        if d < shortest then shortest = d closest = part end
                    end
                end
            end
        end
        Target = closest
        if AimlockEnabled and Target then
            cam.CFrame = CFrame.new(cam.CFrame.Position, Target.Position)
        end
    end)

    -- ===== LOGIC ESP (BOX + LINE + NAME) =====
    local espTable = {}

    local function DrawESP()
        for p, data in pairs(espTable) do
            if not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") or not p.Character:FindFirstChild("Head") then
                if data.box then data.box:Remove() end
                if data.line then data.line:Remove() end
                if data.bb then data.bb:Destroy() end
                espTable[p] = nil
            else
                local char = p.Character
                local hrp = char.HumanoidRootPart
                local head = char.Head
                local hum = char:FindFirstChildOfClass("Humanoid")

                -- Drawing Box & Line
                if tg.espBoxLine and hum and hum.Health > 0 then
                    local topPos, onScreen1 = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local botPos, onScreen2 = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    
                    if onScreen1 or onScreen2 then
                        local height = math.abs(topPos.Y - botPos.Y)
                        local width = height / 2
                        local x, y = topPos.X - width/2, topPos.Y
                        local color = GetRainbowColor()

                        if not data.box then
                            data.box = Drawing.new("Square") data.box.Thickness = 1 data.box.Filled = false
                        end
                        data.box.Size = Vector2.new(width, height)
                        data.box.Position = Vector2.new(x, y)
                        data.box.Color = color data.box.Visible = true

                        if not data.line then
                            data.line = Drawing.new("Line") data.line.Thickness = 1.5
                        end
                        data.line.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                        data.line.To = Vector2.new(topPos.X, botPos.Y)
                        data.line.Color = color data.line.Visible = true
                    else
                        if data.box then data.box.Visible = false end
                        if data.line then data.line.Visible = false end
                    end
                else
                    if data.box then data.box.Visible = false end
                    if data.line then data.line.Visible = false end
                end

                -- Name + Distance
                if tg.espNameDist then
                    if not data.bb then
                        data.bb = Instance.new("BillboardGui", gp)
                        data.bb.Adornee = head data.bb.Size = UDim2.new(0, 200, 0, 20)
                        data.bb.StudsOffset = Vector3.new(0, 2.5, 0) data.bb.AlwaysOnTop = true
                        data.txt = Instance.new("TextLabel", data.bb)
                        data.txt.Size = UDim2.new(1, 0, 1, 0) data.txt.BackgroundTransparency = 1
                        data.txt.TextColor3 = NEON_GREEN data.txt.Font = Enum.Font.Code
                        data.txt.TextSize = 14 data.txt.TextStrokeTransparency = 0.5
                    end
                    local dist = math.floor((hrp.Position - pl.Character.HumanoidRootPart.Position).Magnitude / 3.57)
                    data.txt.Text = p.Name .. " [" .. dist .. "m]"
                    data.bb.Enabled = true
                else
                    if data.bb then data.bb.Enabled = false end
                end

                -- Health
                if tg.espHp then
                    -- Giữ nguyên logic máu nếu cần, hoặc bỏ qua để nhẹ
                end
            end
        end
    end

    RS.RenderStepped:Connect(function()
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= pl and not espTable[p] then espTable[p] = {} end
        end
        DrawESP()
    end)

    -- ===== UI BUILDER =====
    local function createBtn(parent, text, isActive, callback)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, -10, 0, 36) b.BackgroundColor3 = isActive and NEON_GREEN or BG2
        b.Text = text b.TextColor3 = isActive and Color3.new(0,0,0) or TEXT
        b.Font = Enum.Font.SourceSansBold b.TextSize = 14 b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function() if callback then callback(b) end end)
        return b
    end

    local function createTog(parent, text, state, callback)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(1, -10, 0, 36) b.BackgroundColor3 = state and NEON_GREEN or BG2
        b.Text = (state and "[ ON ] " or "[ OFF ] ") .. text
        b.TextColor3 = state and Color3.new(0,0,0) or TEXT_DIM
        b.TextXAlignment = Enum.TextXAlignment.Left b.Font = Enum.Font.SourceSansBold b.TextSize = 13 b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        b.MouseButton1Click:Connect(function()
            state = not state
            b.Text = (state and "[ ON ] " or "[ OFF ] ") .. text
            b.BackgroundColor3 = state and NEON_GREEN or BG2
            b.TextColor3 = state and Color3.new(0,0,0) or TEXT_DIM
            if callback then callback(state) end
        end)
        return b
    end

    local function createSli(parent, text, min, max, default, callback)
        local f = Instance.new("Frame", parent)
        f.Size = UDim2.new(1, -10, 0, 40) f.BackgroundColor3 = BG2
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(1, -10, 0, 20) lbl.Position = UDim2.new(0, 8, 0, 2)
        lbl.BackgroundTransparency = 1 lbl.Text = text .. ": " .. default
        lbl.TextColor3 = TEXT lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Font = Enum.Font.SourceSansBold lbl.TextSize = 13
        local bar = Instance.new("Frame", f)
        bar.Size = UDim2.new(1, -16, 0, 4) bar.Position = UDim2.new(0, 8, 0, 26)
        bar.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1) bar.BorderSizePixel = 0
        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = NEON_GREEN fill.BorderSizePixel = 0
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

    -- ===== MAIN WINDOW =====
    local main = Instance.new("Frame", sg)
    main.Size = UDim2.new(0, 360, 0, 280) main.Position = UDim2.new(0.5, -180, 0.5, -140)
    main.BackgroundColor3 = BG main.BorderSizePixel = 0 main.Active = true main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
    
    local topBar = Instance.new("Frame", main)
    topBar.Size = UDim2.new(1, 0, 0, 30) topBar.BackgroundColor3 = BG2 topBar.BorderSizePixel = 0
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)
    local fix = Instance.new("Frame", topBar) fix.Size = UDim2.new(1, 0, 0, 10) fix.Position = UDim2.new(0, 0, 1, -10) fix.BackgroundColor3 = BG2 fix.BorderSizePixel = 0
    
    local title = Instance.new("TextLabel", topBar)
    title.Size = UDim2.new(1, -40, 1, 0) title.Position = UDim2.new(0, 10, 0, 0) title.BackgroundTransparency = 1
    title.Text = "NYT MODS v33" title.TextColor3 = NEON_GREEN title.Font = Enum.Font.Code title.TextSize = 14 title.TextXAlignment = Enum.TextXAlignment.Left
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 30, 0, 30) closeBtn.Position = UDim2.new(1, -30, 0, 0) closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X" closeBtn.TextColor3 = RED closeBtn.Font = Enum.Font.SourceSansBold closeBtn.TextSize = 16
    closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

    -- Nút bong bóng Termux
    local toggleBtn = Instance.new("TextButton", sg)
    toggleBtn.Size = UDim2.new(0, 50, 0, 50) toggleBtn.Position = UDim2.new(0, 20, 0.3, 0)
    toggleBtn.BackgroundColor3 = BG toggleBtn.Text = ">_" toggleBtn.TextColor3 = NEON_GREEN
    toggleBtn.Font = Enum.Font.Code toggleBtn.TextSize = 20 toggleBtn.AutoButtonColor = false
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    
    local glow = Instance.new("UIStroke", toggleBtn) glow.Color = NEON_GREEN glow.Thickness = 2
    
    -- Kéo thả nút Menu
    local dragging, dragStart, startPos = false, nil, nil
    toggleBtn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true dragStart = i.Position startPos = toggleBtn.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - dragStart toggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then 
        if dragging then
            dragging = false
            if (i.Position - dragStart).Magnitude < 10 then main.Visible = not main.Visible end
        end
    end end)

    -- Tabs
    local tabs = {"AIM", "PLAYER", "ESP"}
    local pages = {} 
    local sideBar = Instance.new("Frame", main)
    sideBar.Size = UDim2.new(0, 80, 1, -30) sideBar.Position = UDim2.new(0, 0, 0, 30)
    sideBar.BackgroundTransparency = 1
    local sideLay = Instance.new("UIListLayout", sideBar) sideLay.Padding = UDim.new(0, 4) sideLay.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -80, 1, -30) content.Position = UDim2.new(0, 80, 0, 30)
    content.BackgroundTransparency = 1

    local function switchTab(name)
        for n, p in pairs(pages) do p.Visible = (n == name) end
        for _, b in ipairs(sideBar:GetChildren()) do 
            if b:IsA("TextButton") then 
                if b.Text == name then b.BackgroundColor3 = NEON_GREEN b.TextColor3 = Color3.new(0,0,0)
                else b.BackgroundColor3 = BG2 b.TextColor3 = TEXT_DIM end
            end 
        end
    end

    for i, name in ipairs(tabs) do
        local btn = Instance.new("TextButton", sideBar)
        btn.Size = UDim2.new(0, 70, 0, 32) btn.BackgroundColor3 = BG2 btn.Text = name
        btn.TextColor3 = TEXT_DIM btn.Font = Enum.Font.SourceSansBold btn.TextSize = 12 btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        
        local page = Instance.new("ScrollingFrame", content)
        page.Size = UDim2.new(1, -4, 1, -4) page.Position = UDim2.new(0, 4, 0, 4)
        page.BackgroundTransparency = 1 page.BorderSizePixel = 0 page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = NEON_GREEN page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y page.Visible = false
        local lay = Instance.new("UIListLayout", page) lay.Padding = UDim.new(0, 6) lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pages[name] = page
        if i == 1 then btn.BackgroundColor3 = NEON_GREEN btn.TextColor3 = Color3.new(0,0,0) page.Visible = true end
    end

    -- ================= TAB AIM =================
    local aimPage = pages["AIM"]
    createBtn(aimPage, "🎯 AIMLOCK: ON", true, function(b)
        AimlockEnabled = not AimlockEnabled
        b.Text = AimlockEnabled and "🎯 AIMLOCK: ON" or "🎯 AIMLOCK: OFF"
        b.BackgroundColor3 = AimlockEnabled and NEON_GREEN or BG2
        b.TextColor3 = AimlockEnabled and Color3.new(0,0,0) or TEXT
    end)
    
    createSli(aimPage, "FOV Radius", 50, 800, FOVRadius, function(v) FOVRadius = v end)
    
    createBtn(aimPage, "📋 DANH SÁCH CHỌN MỤC TIÊU", false, function()
        listWindow.Visible = true RefreshList()
    end)

    -- ================= TAB PLAYER =================
    local plPage = pages["PLAYER"]
    createSli(plPage, "Walk Speed", 16, 300, 16, function(v) stt.ws = v end)
    createSli(plPage, "Jump Power", 50, 300, 50, function(v) stt.jp = v end)
    createTog(plPage, "NOCLIP (XUYÊN TƯỜNG)", false, function(s) tg.noclip = s end)
    createTog(plPage, "ANTI-KNOCKBACK (CHỐNG ĐẨY)", true, function(s) tg.antiKB = s end)

    -- Logic Player
    RS.Heartbeat:Connect(function()
        local c = pl.Character local h = c and c:FindFirstChildOfClass("Humanoid") local hr = c and c:FindFirstChild("HumanoidRootPart")
        if h and hr and h.Health > 0 then
            if stt.ws > 16 then local md = h.MoveDirection if md.Magnitude > 0.1 then hr.AssemblyLinearVelocity = Vector3.new(md.Unit.X * stt.ws, hr.AssemblyLinearVelocity.Y, md.Unit.Z * stt.ws) end end
            if stt.jp > 50 then h.UseJumpPower = true h.JumpPower = stt.jp end
            if tg.antiKB and (h:GetState() == Enum.HumanoidStateType.FallingDown or h:GetState() == Enum.HumanoidStateType.Ragdoll) then h.PlatformStand = false h:ChangeState(Enum.HumanoidStateType.GetUp) end
        end
    end)
    RS.Stepped:Connect(function()
        if tg.noclip and pl.Character then
            for _, p in ipairs(pl.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
        end
    end)

    -- ================= TAB ESP =================
    local espPage = pages["ESP"]
    createTog(espPage, "BOX & LINE (RAINBOW)", false, function(s) tg.espBoxLine = s end)
    createTog(espPage, "NAME & DISTANCE (NEON)", false, function(s) tg.espNameDist = s end)
    
    -- ================= TAB MISC =================
    local miscPage = pages["MISC"]
    if miscPage then
        createBtn(miscPage, "RESET CHARACTER", false, function() if pl.Character then pl.Character:BreakJoints() end end)
        createBtn(miscPage, "REJOIN SERVER", false, function() TS:Teleport(game.PlaceId, pl) end)
    end

    -- ===== DANH SÁCH CHỌN MỤC TIÊU =====
    local listWindow = Instance.new("Frame", sg)
    listWindow.Size = UDim2.new(0, 200, 0, 260) listWindow.Position = UDim2.new(0.5, -100, 0.5, -130)
    listWindow.BackgroundColor3 = BG listWindow.BorderSizePixel = 0 listWindow.Visible = false listWindow.ZIndex = 2000
    Instance.new("UICorner", listWindow).CornerRadius = UDim.new(0, 6)
    local lTitle = Instance.new("TextLabel", listWindow) lTitle.Size = UDim2.new(1,0,0,25) lTitle.BackgroundColor3 = BG2 lTitle.Text = "CHỌN MỤC TIÊU" lTitle.TextColor3 = NEON_GREEN lTitle.Font = Enum.Font.SourceSansBold lTitle.TextSize = 12
    local lClose = Instance.new("TextButton", lTitle) lClose.Size = UDim2.new(0,25,0,25) lClose.Position = UDim2.new(1,-25,0,0) lClose.BackgroundTransparency = 1 lClose.Text = "X" lClose.TextColor3 = RED lClose.Font = Enum.Font.SourceSansBold lClose.MouseButton1Click:Connect(function() listWindow.Visible = false end)
    
    local lScroll = Instance.new("ScrollingFrame", listWindow)
    lScroll.Size = UDim2.new(1, -10, 1, -50) lScroll.Position = UDim2.new(0, 5, 0, 30) lScroll.BackgroundTransparency = 1 lScroll.BorderSizePixel = 0 lScroll.ScrollBarThickness = 2 lScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local lLay = Instance.new("UIListLayout", lScroll) lLay.Padding = UDim.new(0, 4)

    function RefreshList()
        for _, c in ipairs(lScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= pl then
                local b = Instance.new("TextButton", lScroll)
                b.Size = UDim2.new(1, 0, 0, 30) b.BackgroundColor3 = SelectedTargets[p] and NEON_GREEN or BG2
                b.TextColor3 = SelectedTargets[p] and Color3.new(0,0,0) or TEXT
                b.Font = Enum.Font.SourceSansBold b.TextSize = 12 b.AutoButtonColor = false
                local txt = p.Name
                if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
                    txt = txt .. " [" .. math.floor((p.Character.HumanoidRootPart.Position - pl.Character.HumanoidRootPart.Position).Magnitude) .. "m]"
                end
                b.Text = txt
                b.MouseButton1Click:Connect(function()
                    SelectedTargets[p] = not SelectedTargets[p]
                    b.BackgroundColor3 = SelectedTargets[p] and NEON_GREEN or BG2
                    b.TextColor3 = SelectedTargets[p] and Color3.new(0,0,0) or TEXT
                end)
            end
        end
    end

    -- Kéo thả List
    local ld, ls, lp = false, nil, nil
    lTitle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then ld = true ls = i.Position lp = listWindow.Position end end)
    UIS.InputChanged:Connect(function(i) if ld and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then local d = i.Position - ls listWindow.Position = UDim2.new(lp.X.Scale, lp.X.Offset + d.X, lp.Y.Scale, lp.Y.Offset + d.Y) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then ld = false end end)

    print("[NYT v33] Loaded — Box ESP + Termux UI")
end)

if not ok then
    warn("[NEKO ERROR] " .. tostring(err))
end