-- ==================================================================
-- ===== NYT MODS v37 — FULL 6 TABS + AIM 360 + BOX ESP =============
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

    -- ===== BIẾN TOÀN CỤC =====
    local stt = {ws = 16, jp = 50}
    local tg = {espLineBox = false, espNameDist = false, noclip = false, mapBright = false, fps = false, infJump = false, antiKB = true}
    local ghostDeath = {on = false}
    local spinState = {on = false, speed = 5}
    local ghostFeet = {on = false, height = 0, baseY = nil}
    local spinAccum = 0
    local spinSavedAutoRotate = nil
    local tpSelected = nil
    local teleportTo
    local nlSafe = nil
    local nlGroundT = 0
    local wps = {nil, nil, nil, nil, nil, nil, nil, nil}
    local wpHeight = 3

    -- ===== DELTA AIM GỐC (Không FOV, Auto 360) =====
    local AimlockEnabled = true
    local SelectedTargets = {}
    local Target = nil

    local function GetTargetPart(character)
        if not character then return nil end
        return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart") or character:FindFirstChildWhichIsA("BasePart")
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
            
            -- Kiểm tra xem có ai trong danh sách chọn không
            local hasSelected = false
            for _, isSelected in pairs(SelectedTargets) do 
                if isSelected then hasSelected = true break end 
            end

            if hasSelected then
                -- 1. Ưu tiên tìm trong danh sách đã tích
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
                -- 2. Nếu không chọn ai -> Aim 360 vào người gần nhất
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
        end
    end)

    -- ===== HÀM TẠO UI =====
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
            state = not state
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
        b.MouseButton1Click:Connect(function() if callback then callback(b) end end)
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

    -- ===== MAIN UI =====
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
    title.Text = "NYT v37" title.TextColor3 = G title.Font = Enum.Font.Code title.TextSize = 14 title.TextXAlignment = Enum.TextXAlignment.Left
    local closeBtn = Instance.new("TextButton", topBar)
    closeBtn.Size = UDim2.new(0, 32, 0, 32) closeBtn.Position = UDim2.new(1, -32, 0, 0) closeBtn.BackgroundTransparency = 1
    closeBtn.Text = "X" closeBtn.TextColor3 = RED closeBtn.Font = Enum.Font.SourceSansBold closeBtn.TextSize = 16
    closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

    -- Nút bong bóng Termux
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
        if dragging then dragging = false if (i.Position - dragStart).Magnitude < 10 then main.Visible = not main.Visible end end
    end end)

    -- Tabs
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
        btn.MouseButton1Click:Connect(function() switchTab(name) end)
        
        local page = Instance.new("ScrollingFrame", content)
        page.Size = UDim2.new(1, -4, 1, -4) page.Position = UDim2.new(0, 4, 0, 4)
        page.BackgroundTransparency = 1 page.BorderSizePixel = 0 page.ScrollBarThickness = 2
        page.ScrollBarImageColor3 = G page.CanvasSize = UDim2.new(0,0,0,0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y page.Visible = false
        local lay = Instance.new("UIListLayout", page) lay.Padding = UDim.new(0, 6) lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
        pages[name] = page
        if i == 1 then btn.BackgroundColor3 = G btn.TextColor3 = Color3.new(0,0,0) page.Visible = true end
    end

    -- ================= TAB AIM =================
    local aimPage = pages["AIM"]
    mkBtn(aimPage, "🎯 AIMLOCK: ON", function(b)
        AimlockEnabled = not AimlockEnabled
        b.Text = AimlockEnabled and "  🎯 AIMLOCK: ON" or "  🎯 AIMLOCK: OFF"
        b.TextColor3 = AimlockEnabled and G or RED
    end).TextColor3 = G

    mkBtn(aimPage, "📋 DANH SÁCH CHỌN MỤC TIÊU", function()
        listWindow.Visible = true RefreshList()
    end)

    -- ================= TAB MOVE =================
    local movePage = pages["MOVE"]
    mkSli(movePage, "Walk Speed", 16, 300, 16, function(v) stt.ws = v end)
    mkSli(movePage, "Jump Power", 50, 300, 50, function(v) stt.jp = v end)
    mkTog(movePage, "INFINITE JUMP", false, function(s) tg.infJump = s end)

    -- ================= TAB PLAYER =================
    local plPage = pages["PLAYER"]
    mkTog(plPage, "SPIN", false, function(s) 
        spinState.on = s 
        local h = pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
        if h then h.AutoRotate = not s end
    end)
    mkTog(plPage, "NOCLIP", false, function(s) tg.noclip = s end)
    mkTog(plPage, "ANTI-KNOCKBACK", true, function(s) tg.antiKB = s end)
    mkTog(plPage, "GHOST DEATH", false, function(s) ghostDeath.on = s end)
    mkTog(plPage, "FPS BOOST", false, function(s) tg.fps = s L.GlobalShadows = not s end)
    mkTog(plPage, "MAP BRIGHT", false, function(s) tg.mapBright = s L.Brightness = s and 3 or 1 end)
    mkBtn(plPage, "RESET CHARACTER", function() if pl.Character then pl.Character:BreakJoints() end end)
    mkBtn(plPage, "REJOIN SERVER", function() TS:Teleport(game.PlaceId, pl) end)

    -- ================= TAB ESP =================
    local espPage = pages["ESP"]
    mkTog(espPage, "BOX & LINE (RAINBOW)", false, function(s) tg.espLineBox = s end)
    mkTog(espPage, "NAME & DIST (NEON)", false, function(s) tg.espNameDist = s end)

    -- Logic ESP (Box, Line, Name+Dist)
    local espTable = {}
    RS.RenderStepped:Connect(function()
        for p, data in pairs(espTable) do
            if not p.Parent or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
                if data.box then data.box:Remove() end
                if data.line then data.line:Remove() end
                if data.bb then data.bb:Destroy() end
                espTable[p] = nil
            else
                local char = p.Character
                local hrp = char.HumanoidRootPart
                local head = char:FindFirstChild("Head") or hrp
                local hum = char:FindFirstChildOfClass("Humanoid")

                -- Vẽ Box và Line (Rainbow)
                if tg.espLineBox and hum and hum.Health > 0 then
                    local topPos, onScreen1 = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local botPos, onScreen2 = cam:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
                    if onScreen1 or onScreen2 then
                        local height = math.abs(topPos.Y - botPos.Y)
                        local width = height / 2
                        local color = Color3.fromRGB( math.sin(tick()*2)*127+128, math.sin(tick()*2+2)*127+128, math.sin(tick()*2+4)*127+128 )
                        if not data.box then data.box = Drawing.new("Square") data.box.Thickness = 1 data.box.Filled = false end
                        data.box.Size = Vector2.new(width, height) data.box.Position = Vector2.new(topPos.X - width/2, topPos.Y)
                        data.box.Color = color data.box.Visible = true
                        
                        if not data.line then data.line = Drawing.new("Line") data.line.Thickness = 1.5 end
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

                -- Vẽ Tên + Khoảng cách (Neon)
                if tg.espNameDist then
                    if not data.bb then
                        data.bb = Instance.new("BillboardGui", gp) data.bb.Adornee = head
                        data.bb.Size = UDim2.new(0, 200, 0, 20) data.bb.StudsOffset = Vector3.new(0, 2.5, 0) data.bb.AlwaysOnTop = true
                        data.txt = Instance.new("TextLabel", data.bb)
                        data.txt.Size = UDim2.new(1, 0, 1, 0) data.txt.BackgroundTransparency = 1
                        data.txt.TextColor3 = G data.txt.Font = Enum.Font.Code
                        data.txt.TextSize = 14 data.txt.TextStrokeTransparency = 0.5
                    end
                    local dist = math.floor((hrp.Position - pl.Character.HumanoidRootPart.Position).Magnitude / 3.57)
                    data.txt.Text = p.Name .. " [" .. dist .. "m]"
                    data.bb.Enabled = true
                else
                    if data.bb then data.bb.Enabled = false end
                end
            end
        end
    end)

    task.spawn(function() while true do task.wait(1)
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= pl and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and not espTable[p] then
                espTable[p] = {}
            end
        end
    end end)

    -- ================= TAB TELE =================
    local telePage = pages["TELE"]
    local tpBtn = mkBtn(telePage, "CHỌN NGƯỜI CHƠI", function()
        dlgTitle.Text = "> SELECT PLAYER"
        for _, ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        for _, p in ipairs(P:GetPlayers()) do
            if p ~= pl then
                dlgBtn(p.Name, G, function()
                    tpSelected = p
                    tpBtn.Text = "  " .. p.Name
                    closeDlg()
                end)
            end
        end
        dlgBtn("CANCEL", RED, function() closeDlg() end)
        dlg.Visible = true dlgOverlay.Visible = true
    end)
    
    mkBtn(telePage, "TELEPORT TỚI NGƯỜI CHƠI", function()
        if not tpSelected then return end
        local c = pl.Character local hr = c and c:FindFirstChild("HumanoidRootPart")
        local th = tpSelected.Character and tpSelected.Character:FindFirstChild("HumanoidRootPart")
        if hr and th then hr.CFrame = CFrame.new(th.Position + Vector3.new(0, 4, 0)) end
    end)

    -- Waypoints
    mkSli(telePage, "WP Height", 0, 20, wpHeight, function(v) wpHeight = v end)
    for i = 1, 8 do
        local row = Instance.new("Frame", telePage)
        row.Size = UDim2.new(1, -10, 0, 34) row.BackgroundColor3 = BG2 row.BorderSizePixel = 0
        row.LayoutOrder = #telePage:GetChildren() * 10
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
        local info = Instance.new("TextLabel", row)
        info.Size = UDim2.new(1, -100, 1, 0) info.Position = UDim2.new(0, 10, 0, 0)
        info.BackgroundTransparency = 1 info.Text = "WP "..i info.Font = Enum.Font.SourceSansBold
        info.TextSize = 12 info.TextColor3 = DIM_TX info.TextXAlignment = Enum.TextXAlignment.Left
        
        local setB = Instance.new("TextButton", row)
        setB.Size = UDim2.new(0, 30, 0, 24) setB.Position = UDim2.new(1, -70, 0.5, -12)
        setB.BackgroundColor3 = BG setB.Text = "SET" setB.TextColor3 = G setB.Font = Enum.Font.SourceSansBold setB.TextSize = 11
        setB.MouseButton1Click:Connect(function()
            local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
            if hr then wps[i] = {hr.CFrame:GetComponents()} info.Text = "WP "..i.." READY" info.TextColor3 = G end
        end)

        local goB = Instance.new("TextButton", row)
        goB.Size = UDim2.new(0, 30, 0, 24) goB.Position = UDim2.new(1, -36, 0.5, -12)
        goB.BackgroundColor3 = BG setB.Text = "GO" goB.Text = "GO" goB.TextColor3 = YEL goB.Font = Enum.Font.SourceSansBold goB.TextSize = 11
        goB.MouseButton1Click:Connect(function()
            if wps[i] then
                local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
                if hr then hr.CFrame = CFrame.new(wps[i][1], wps[i][2] + wpHeight, wps[i][3]) end
            end
        end)
    end

    -- ================= TAB INFO =================
    local infoPage = pages["INFO"]
    local infoLbl = Instance.new("TextLabel", infoPage)
    infoLbl.Size = UDim2.new(1, -10, 0, 100) infoLbl.BackgroundColor3 = BG2
    infoLbl.TextColor3 = TX infoLbl.Font = Enum.Font.Code infoLbl.TextSize = 14
    infoLbl.Text = "Đang tải..." infoLbl.LayoutOrder = 1
    Instance.new("UICorner", infoLbl).CornerRadius = UDim.new(0, 6)

    task.spawn(function() while true do task.wait(1)
        local ping = math.floor(pl:GetNetworkPing() * 1000)
        infoLbl.Text = string.format("Tên: %s\nPing: %d ms\nServer: %s", pl.Name, ping, game.Name)
    end end)

    -- Logic Player
    RS.Heartbeat:Connect(function()
        local c = pl.Character local h = c and c:FindFirstChildOfClass("Humanoid") local hr = c and c:FindFirstChild("HumanoidRootPart")
        if h and hr and h.Health > 0 then
            if stt.ws > 16 then local md = h.MoveDirection if md.Magnitude > 0.1 then hr.AssemblyLinearVelocity = Vector3.new(md.Unit.X * stt.ws, hr.AssemblyLinearVelocity.Y, md.Unit.Z * stt.ws) end end
            if stt.jp > 50 then h.UseJumpPower = true h.JumpPower = stt.jp end
            if tg.antiKB and (h:GetState() == Enum.HumanoidStateType.FallingDown or h:GetState() == Enum.HumanoidStateType.Ragdoll) then h.PlatformStand = false h:ChangeState(Enum.HumanoidStateType.GetUp) end
            if spinState.on then spinAccum = spinAccum + math.rad(spinState.speed * 360) * 0.016 hr.CFrame = CFrame.new(hr.Position) * CFrame.Angles(0, spinAccum, 0) end
            if ghostDeath.on and h.Health > 0 then h.Health = 0 end
        end
    end)
    RS.Stepped:Connect(function()
        if tg.noclip and pl.Character then for _, p in ipairs(pl.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end)

    -- ===== DIALOG (Dùng cho Tele) =====
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

    -- ===== DANH SÁCH CHỌN MỤC TIÊU =====
    local listWindow = Instance.new("Frame", sg)
    listWindow.Size = UDim2.new(0, 200, 0, 260) listWindow.Position = UDim2.new(0.5, -100, 0.5, -130)
    listWindow.BackgroundColor3 = BG listWindow.Visible = false listWindow.ZIndex = 2000
    Instance.new("UICorner", listWindow).CornerRadius = UDim.new(0, 6)
    local lTitle = Instance.new("TextLabel", listWindow) lTitle.Size = UDim2.new(1,0,0,25) lTitle.BackgroundColor3 = BG2 lTitle.Text = "CHỌN MỤC TIÊU" lTitle.TextColor3 = G lTitle.Font = Enum.Font.SourceSansBold lTitle.TextSize = 12
    local lClose = Instance.new("TextButton", lTitle) lClose.Size = UDim2.new(0,25,0,25) lClose.Position = UDim2.new(1,-25,0,0) lClose.BackgroundTransparency = 1 lClose.Text = "X" lClose.TextColor3 = RED lClose.Font = Enum.Font.SourceSansBold lClose.MouseButton1Click:Connect(function() listWindow.Visible = false end)
    
    local lScroll = Instance.new("ScrollingFrame", listWindow)
    lScroll.Size = UDim2.new(1, -10, 1, -50) lScroll.Position = UDim2.new(0, 5, 0, 30) lScroll.BackgroundTransparency = 1 lScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
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

    print("[NYT v37] Loaded — FULL 6 TABS + AIM 360")
end)

if not ok then warn("[NEKO ERROR] " .. tostring(err)) end