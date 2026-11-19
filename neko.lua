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
local selectedFlyTarget = nil
local flyWasEnabled = false
local flyAttachment = nil
local flyAlignPosition = nil
local spinAccum = 0

-- ESP System (2D Box / Rainbow Tracer / Name + Distance)
local espTable = {}
local espFlags = {line = false, box = false, info = false}

-- Bộ đếm ESP nhỏ ở góc trái dưới, tự căn theo độ phân giải điện thoại.
local espCounter = Instance.new("TextLabel")
espCounter.Name = "ESP_PlayerCounter"
espCounter.Size = UDim2.fromOffset(104, 25)
espCounter.AnchorPoint = Vector2.new(0, 1)
espCounter.Position = UDim2.new(0, 9, 1, -9)
espCounter.BackgroundColor3 = BG_MAIN
espCounter.BackgroundTransparency = 0.12
espCounter.BorderSizePixel = 0
espCounter.Text = "ESP  0 PLAYERS"
espCounter.TextColor3 = ACCENT
espCounter.Font = Enum.Font.GothamBold
espCounter.TextSize = 10
espCounter.Visible = false
espCounter.ZIndex = 90
espCounter.Parent = sg
Instance.new("UICorner", espCounter).CornerRadius = UDim.new(0, 6)
local espCounterStroke = Instance.new("UIStroke", espCounter)
espCounterStroke.Color = ACCENT
espCounterStroke.Thickness = 1
espCounterStroke.Transparency = 0.25

local function makeESPObject(player)
    local data = {}
    local function frame(parent, color, thickness)
        local o = Instance.new("Frame")
        o.BorderSizePixel = 0
        o.BackgroundColor3 = color or Color3.new(1, 1, 1)
        o.Visible = false
        o.Parent = sg
        return o
    end
    data.line = frame(sg)
    data.box = frame(sg)
    data.box.BackgroundTransparency = 1
    data.box.BorderSizePixel = 0
    data.boxStroke = Instance.new("UIStroke", data.box)
    data.boxStroke.Thickness = 1.5
    data.label = Instance.new("TextLabel")
    data.label.BackgroundColor3 = BG_MAIN
    data.label.BackgroundTransparency = 0.2
    data.label.BorderSizePixel = 0
    data.label.Font = Enum.Font.GothamBold
    data.label.TextSize = 11
    data.label.TextColor3 = Color3.new(1, 1, 1)
    data.label.TextStrokeTransparency = 0.5
    data.label.Size = UDim2.fromOffset(150, 18)
    data.label.AnchorPoint = Vector2.new(0.5, 1)
    data.label.Visible = false
    data.label.Parent = sg
    local corner = Instance.new("UICorner", data.label)
    corner.CornerRadius = UDim.new(0, 4)
    espTable[player] = data
end

local function hideESP(data)
    data.line.Visible = false
    data.box.Visible = false
    data.label.Visible = false
end

RS.RenderStepped:Connect(function()
    cam = workspace.CurrentCamera or cam
    if not cam then return end
    local myChar = pl.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local viewport = cam.ViewportSize
    local visiblePlayerCount = 0
    local espEnabled = espFlags.line or espFlags.box or espFlags.info
    espCounter.Visible = espEnabled
    espCounter.Position = UDim2.new(0, 9, 1, -9)
    -- Điểm gốc cố định ở giữa cạnh dưới màn hình, nhích lên để tránh sát mép.
    local bottom = Vector2.new(viewport.X * 0.5, viewport.Y * 0.88)
    local hue = (os.clock() * 0.22) % 1
    local rainbow = Color3.fromHSV(hue, 1, 1)

    for player, data in pairs(espTable) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not player.Parent or not root or not hum or hum.Health <= 0 or not myRoot then
            hideESP(data)
        else
            local distance = (root.Position - myRoot.Position).Magnitude / 3.57
            local center, onScreen = cam:WorldToViewportPoint(root.Position)
            if not onScreen then
                hideESP(data)
            else
                visiblePlayerCount = visiblePlayerCount + 1
                local cf, size = char:GetBoundingBox()
                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge
                for x = -1, 1, 2 do
                    for y = -1, 1, 2 do
                        for z = -1, 1, 2 do
                            local corner = cf:PointToWorldSpace(Vector3.new(size.X*x/2, size.Y*y/2, size.Z*z/2))
                            local point, visible = cam:WorldToViewportPoint(corner)
                            if visible then
                                minX, minY = math.min(minX, point.X), math.min(minY, point.Y)
                                maxX, maxY = math.max(maxX, point.X), math.max(maxY, point.Y)
                            end
                        end
                    end
                end
                local validBox = minX < maxX and minY < maxY
                if espFlags.line then
                    -- Nối chính xác từ điểm giữa phía dưới màn hình tới tâm người chơi.
                    -- Đặt Frame tại trung điểm để Rotation không làm lệch đầu line.
                    local target = Vector2.new(center.X, center.Y)
                    local delta = target - bottom
                    local length = delta.Magnitude

                    data.line.AnchorPoint = Vector2.new(0.5, 0.5)
                    data.line.Position = UDim2.fromOffset(
                        (bottom.X + target.X) * 0.5,
                        (bottom.Y + target.Y) * 0.5
                    )
                    data.line.Size = UDim2.fromOffset(length, 2)
                    data.line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
                    data.line.BackgroundColor3 = rainbow
                    data.line.Visible = length > 1
                else
                    data.line.Visible = false
                end

                if espFlags.box and validBox then
                    data.box.Position = UDim2.fromOffset(minX, minY)
                    data.box.Size = UDim2.fromOffset(maxX - minX, maxY - minY)
                    data.boxStroke.Color = rainbow
                    data.box.Visible = true
                else data.box.Visible = false end

                if espFlags.info and validBox then
                    data.label.Text = player.DisplayName .. "  |  " .. math.floor(distance) .. "m"
                    data.label.Position = UDim2.fromOffset((minX + maxX) / 2, minY - 2)
                    data.label.TextColor3 = rainbow
                    data.label.Visible = true
                else data.label.Visible = false end
            end
        end
    end

    if espEnabled then
        espCounter.Text = "ESP  " .. tostring(visiblePlayerCount) .. " PLAYERS"
        espCounter.Visible = true
    else
        espCounter.Visible = false
    end
end)

P.PlayerAdded:Connect(function(player)
    if player ~= pl then makeESPObject(player) end
end)
P.PlayerRemoving:Connect(function(player)
    local data = espTable[player]
    if data then
        data.line:Destroy(); data.box:Destroy(); data.label:Destroy()
        espTable[player] = nil
    end
end)
for _, player in ipairs(P:GetPlayers()) do
    if player ~= pl then makeESPObject(player) end
end

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
    
    -- Auto Fly: bám mục tiêu bằng AlignPosition có giới hạn tốc độ,
    -- tránh CFrame teleport từng frame gây giật và văng xa khi tắt.
    if tg.autoFly then
        local myHR = c and c:FindFirstChild("HumanoidRootPart")
        local targetHR, targetHum
        if selectedFlyTarget and selectedFlyTarget:IsA("Player") then
            local targetChar = selectedFlyTarget.Character
            targetHR = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
        elseif selectedFlyTarget and selectedFlyTarget:IsA("Model") then
            targetHR = selectedFlyTarget.PrimaryPart or selectedFlyTarget:FindFirstChild("HumanoidRootPart") or selectedFlyTarget:FindFirstChildWhichIsA("BasePart", true)
            targetHum = selectedFlyTarget:FindFirstChildOfClass("Humanoid")
        elseif selectedFlyTarget and selectedFlyTarget:IsA("BasePart") then
            targetHR = selectedFlyTarget
        end

        if myHR and h and h.Health > 0 and targetHR and (not targetHum or targetHum.Health > 0) then
            if not flyAttachment or flyAttachment.Parent ~= myHR then
                if flyAlignPosition then flyAlignPosition:Destroy() end
                if flyAttachment then flyAttachment:Destroy() end

                flyAttachment = Instance.new("Attachment")
                flyAttachment.Name = "NekoFlyAttachment"
                flyAttachment.Parent = myHR

                flyAlignPosition = Instance.new("AlignPosition")
                flyAlignPosition.Name = "NekoFlyFollow"
                flyAlignPosition.Mode = Enum.PositionAlignmentMode.OneAttachment
                flyAlignPosition.Attachment0 = flyAttachment
                flyAlignPosition.ApplyAtCenterOfMass = true
                flyAlignPosition.RigidityEnabled = false
                flyAlignPosition.MaxForce = math.max(myHR.AssemblyMass * workspace.Gravity * 10, 50000)
                flyAlignPosition.MaxVelocity = 34
                flyAlignPosition.Responsiveness = math.clamp(autoFlyStiffness * 0.45, 8, 42)
                flyAlignPosition.Parent = myHR
            end

            flyWasEnabled = true
            flyAlignPosition.Position = targetHR.Position + Vector3.new(0, 4, 0)
            flyAlignPosition.Responsiveness = math.clamp(autoFlyStiffness * 0.45, 8, 42)
        else
            -- Mục tiêu mất kết nối/chết: tháo lực điều khiển, không để lực cũ kéo nhân vật.
            if flyAlignPosition then flyAlignPosition:Destroy(); flyAlignPosition = nil end
            if flyAttachment then flyAttachment:Destroy(); flyAttachment = nil end
            if flyWasEnabled and myHR then myHR.AssemblyLinearVelocity = Vector3.zero end
            flyWasEnabled = false
        end
    elseif flyWasEnabled or flyAlignPosition or flyAttachment then
        flyWasEnabled = false
        if flyAlignPosition then flyAlignPosition:Destroy(); flyAlignPosition = nil end
        if flyAttachment then flyAttachment:Destroy(); flyAttachment = nil end

        local char = pl.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            -- Xóa toàn bộ quán tính do Auto Fly tạo ra để không bị phóng văng.
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if hum then
            hum.PlatformStand = false
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
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
local main = Instance.new("Frame", sg)
main.Size = UDim2.fromOffset(760, 390)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = BG_MAIN
main.BorderSizePixel = 0
main.Active = true
main.Visible = false
main.ZIndex = 100
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = ACCENT
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.22
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local mainScale = Instance.new("UIScale", main)
local function updateMenuScale()
    local currentCamera = workspace.CurrentCamera
    local v = currentCamera and currentCamera.ViewportSize or Vector2.new(900, 700)
    -- Vivo V2025 portrait/landscape: giữ menu trọn trong vùng hiển thị.
    local scaleX = (v.X - 20) / 760
    local scaleY = (v.Y - 28) / 390
    mainScale.Scale = math.clamp(math.min(scaleX, scaleY, 1), 0.38, 1)
    main.Position = UDim2.fromScale(0.5, 0.5)
end
updateMenuScale()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    updateMenuScale()
    local currentCamera = workspace.CurrentCamera
    if currentCamera then
        currentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMenuScale)
    end
end)
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMenuScale)
end

local mainGradient = Instance.new("UIGradient", main)
mainGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(17, 23, 35)), ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 12, 19))})
mainGradient.Rotation = 90

local topBar = Instance.new("Frame", main)
topBar.Size = UDim2.new(1, 0, 0, 44)
topBar.BackgroundColor3 = BG_SEC
topBar.BorderSizePixel = 0
topBar.ZIndex = 101
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NEKO HUB  /  CONTROL PANEL"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left

local subtitle = Instance.new("TextLabel", topBar)
subtitle.Size = UDim2.new(0, 190, 1, 0)
subtitle.Position = UDim2.new(1, -225, 0, 0)
subtitle.BackgroundTransparency = 1
subtitle.Text = "●  READY  |  NEON EDITION"
subtitle.TextColor3 = GREEN
subtitle.Font = Enum.Font.GothamMedium
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Right

local closeBtn = Instance.new("TextButton", topBar)
closeBtn.Size = UDim2.new(0, 32, 0, 28)
closeBtn.Position = UDim2.new(1, -40, 0.5, -14)
closeBtn.BackgroundColor3 = BG_CARD
closeBtn.Text = "—"
closeBtn.TextColor3 = RED
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() main.Visible = false end) -- Ẩn menu, không tắt các chức năng đang bật

-- Menu cố định chính giữa màn hình, không có bong bóng nổi.
-- Chạm đồng thời 3 ngón để mở lại khi menu đang ẩn.
local activeTouches = {}
local function countTouches()
    local n = 0
    for _ in pairs(activeTouches) do n += 1 end
    return n
end
UIS.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Touch then
        activeTouches[input] = true
        if countTouches() >= 3 and not main.Visible then
            main.Visible = true
        end
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        activeTouches[input] = nil
    end
end)

-- Tabs
local sideBar = Instance.new("Frame", main)
sideBar.Size = UDim2.new(0, 132, 1, -56)
sideBar.Position = UDim2.new(0, 10, 0, 50)
sideBar.BackgroundTransparency = 1
local sideLay = Instance.new("UIListLayout", sideBar)
sideLay.Padding = UDim.new(0, 6)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -154, 1, -56)
content.Position = UDim2.new(0, 144, 0, 50)
content.BackgroundTransparency = 1

local tabs = {"MOVE", "ESP", "PLAYER", "TELE", "AIM", "INFO"}
local tabLabels = {MOVE="  DI CHUYỂN", ESP="  ESP", PLAYER="  NHÂN VẬT", TELE="  DỊCH CHUYỂN", AIM="  AIM", INFO="  THÔNG TIN"}
local pages = {}

local function switchTab(name)
    for n, p in pairs(pages) do p.Visible = (n == name) end
    for _, b in ipairs(sideBar:GetChildren()) do
        if b:IsA("TextButton") then
            local active = (b.Name == "Tab_" .. name)
            T:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = active and ACCENT or BG_SEC, TextColor3 = active and BG_MAIN or TXT_DIM}):Play()
        end
    end
end

for i, name in ipairs(tabs) do
    local btn = Instance.new("TextButton", sideBar)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = (i == 1) and ACCENT or BG_SEC
    btn.Name = "Tab_" .. name
    btn.Text = tabLabels[name] or ("  " .. name)
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
    s.Size = UDim2.new(1, -8, 0, 26)
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
    b.Size = UDim2.new(1, -8, 0, 40)
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
    b.Size = UDim2.new(1, -8, 0, 40)
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
mkSec(espPage, "ESP NGƯỜI CHƠI  /  VISUAL")
mkTog(espPage, "Rainbow Line  •  Nối về giữa đáy màn hình", false, function(s) espFlags.line = s end)
mkTog(espPage, "2D Box  •  Khung bao quanh nhân vật", false, function(s) espFlags.box = s end)
mkTog(espPage, "Name + Distance  •  Tên và khoảng cách", false, function(s) espFlags.info = s end)
local espHint = Instance.new("TextLabel", espPage)
espHint.Size = UDim2.new(1, -8, 0, 42)
espHint.BackgroundColor3 = BG_SEC
espHint.BackgroundTransparency = 0.12
espHint.BorderSizePixel = 0
espHint.Text = "Bật/tắt từng hiệu ứng riêng. Màu RGB cầu vồng tự động chuyển liên tục."
espHint.TextColor3 = TXT_DIM
espHint.Font = Enum.Font.Gotham
espHint.TextSize = 11
espHint.TextWrapped = true
Instance.new("UICorner", espHint).CornerRadius = UDim.new(0, 8)

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
mkSec(telePage, "AUTO FLY  /  FOLLOW TARGET")

-- Danh sách mục tiêu trong map dùng chung cho Teleport và Auto Fly.
local selectedTargetLabel = Instance.new("TextLabel", telePage)
selectedTargetLabel.Size = UDim2.new(1, -8, 0, 24)
selectedTargetLabel.BackgroundTransparency = 1
selectedTargetLabel.Text = "MỤC TIÊU: CHƯA CHỌN"
selectedTargetLabel.TextColor3 = ACCENT
selectedTargetLabel.Font = Enum.Font.GothamBold
selectedTargetLabel.TextSize = 11
selectedTargetLabel.TextXAlignment = Enum.TextXAlignment.Left

local targetScroll = Instance.new("ScrollingFrame", telePage)
targetScroll.Name = "MapTargetList"
targetScroll.Size = UDim2.new(1, -8, 0, 150)
targetScroll.BackgroundColor3 = BG_CARD
targetScroll.BorderSizePixel = 0
targetScroll.ScrollBarThickness = 3
targetScroll.ScrollBarImageColor3 = ACCENT
targetScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
targetScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
targetScroll.ScrollingDirection = Enum.ScrollingDirection.Y
Instance.new("UICorner", targetScroll).CornerRadius = UDim.new(0, 7)
local targetListLayout = Instance.new("UIListLayout", targetScroll)
targetListLayout.Padding = UDim.new(0, 3)
targetListLayout.SortOrder = Enum.SortOrder.LayoutOrder
local targetListPadding = Instance.new("UIPadding", targetScroll)
targetListPadding.PaddingTop = UDim.new(0, 4)
targetListPadding.PaddingBottom = UDim.new(0, 4)
targetListPadding.PaddingLeft = UDim.new(0, 4)
targetListPadding.PaddingRight = UDim.new(0, 4)

local function getMapTargetRoot(target)
    if not target or not target.Parent then return nil end
    if target:IsA("Player") then
        local ch = target.Character
        return ch and ch:FindFirstChild("HumanoidRootPart")
    elseif target:IsA("Model") then
        return target.PrimaryPart or target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart", true)
    elseif target:IsA("BasePart") then
        return target
    end
    return nil
end

local function getMapTargetName(target)
    if target:IsA("Player") then return target.DisplayName end
    return target.Name
end

local function refreshMapTargets()
    for _, child in ipairs(targetScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end

    local myRoot = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    local found, seen = {}, {}
    for _, item in ipairs(workspace:GetDescendants()) do
        local candidate
        if item:IsA("Model") and not item:FindFirstChildOfClass("Humanoid") then
            candidate = item
        elseif item:IsA("BasePart") and item.Parent and not item.Parent:IsA("Model") then
            candidate = item
        end

        if candidate and not seen[candidate] then
            local root = getMapTargetRoot(candidate)
            if root and not (pl.Character and candidate == pl.Character) then
                local distance = myRoot and (root.Position - myRoot.Position).Magnitude or math.huge
                table.insert(found, {instance = candidate, distance = distance})
                seen[candidate] = true
            end
        end
    end

    table.sort(found, function(a, b) return a.distance < b.distance end)
    for index, entry in ipairs(found) do
        if index > 100 then break end
        local item = entry.instance
        local row = Instance.new("TextButton", targetScroll)
        row.Name = "Target_" .. tostring(index)
        row.Size = UDim2.new(1, -4, 0, 30)
        row.BackgroundColor3 = item == selectedFlyTarget and BG_SEC or BG_MAIN
        row.BorderSizePixel = 0
        row.AutoButtonColor = true
        row.Text = string.format("  %s   •   %.1f studs", getMapTargetName(item), entry.distance)
        row.TextColor3 = item == selectedFlyTarget and GREEN or TXT
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Font = Enum.Font.GothamMedium
        row.TextSize = 10
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        row.MouseButton1Click:Connect(function()
            selectedFlyTarget = item
            selectedTargetLabel.Text = "MỤC TIÊU: " .. getMapTargetName(item)
            selectedTargetLabel.TextColor3 = GREEN
            for _, other in ipairs(targetScroll:GetChildren()) do
                if other:IsA("TextButton") then
                    other.BackgroundColor3 = other == row and BG_SEC or BG_MAIN
                    other.TextColor3 = other == row and GREEN or TXT
                end
            end
        end)
    end

    if #found == 0 then
        local empty = Instance.new("TextLabel", targetScroll)
        empty.Size = UDim2.new(1, -4, 0, 30)
        empty.BackgroundTransparency = 1
        empty.Text = "Không tìm thấy mục tiêu trong map"
        empty.TextColor3 = TXT_DIM
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 10
    end
end

mkBtn(telePage, "↻  Làm mới danh sách mục tiêu", refreshMapTargets)
mkBtn(telePage, "TELEPORT  →  Mục tiêu đã chọn", function(btn)
    local targetRoot = getMapTargetRoot(selectedFlyTarget)
    local myRoot = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot and myRoot then
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 4)
    else
        btn.Text = "   Hãy chọn mục tiêu hợp lệ trước"
    end
end)
refreshMapTargets()

mkTog(telePage, "Auto Fly  •  Bay theo mục tiêu đã chọn", false, function(s)
    tg.autoFly = s
    if not s then
        local char = pl.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = false
            hum.Sit = false
            hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end)
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