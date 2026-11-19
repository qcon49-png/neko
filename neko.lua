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
local aimFovEnabled = false
local aimFovVisible = false
local aimFovRadius = 50
local aimFovCircle
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
    data.line2 = frame(sg) -- Đoạn line thứ hai, dùng để bỏ qua phần nằm sau nhân vật chính.
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
    data.line2.Visible = false
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
    -- Gốc line nằm chính giữa sát mép dưới màn hình.
    local bottom = Vector2.new(viewport.X * 0.5, viewport.Y - 1)

    -- Lấy vùng chiếm màn hình của nhân vật chính để line không vẽ đè xuyên qua người.
    local myMinX, myMinY = math.huge, math.huge
    local myMaxX, myMaxY = -math.huge, -math.huge
    if myChar then
        local myCF, mySize = myChar:GetBoundingBox()
        for x = -1, 1, 2 do
            for y = -1, 1, 2 do
                for z = -1, 1, 2 do
                    local worldCorner = myCF:PointToWorldSpace(Vector3.new(
                        mySize.X * x / 2, mySize.Y * y / 2, mySize.Z * z / 2
                    ))
                    local screenPoint, visible = cam:WorldToViewportPoint(worldCorner)
                    if visible then
                        myMinX = math.min(myMinX, screenPoint.X)
                        myMinY = math.min(myMinY, screenPoint.Y)
                        myMaxX = math.max(myMaxX, screenPoint.X)
                        myMaxY = math.max(myMaxY, screenPoint.Y)
                    end
                end
            end
        end
    end
    local hasMyScreenBounds = myMinX < myMaxX and myMinY < myMaxY

    local function drawLineSegment(lineObject, fromPoint, toPoint, color)
        local delta = toPoint - fromPoint
        local length = delta.Magnitude
        lineObject.AnchorPoint = Vector2.new(0.5, 0.5)
        lineObject.Position = UDim2.fromOffset(
            (fromPoint.X + toPoint.X) * 0.5,
            (fromPoint.Y + toPoint.Y) * 0.5
        )
        lineObject.Size = UDim2.fromOffset(length, 2)
        lineObject.Rotation = math.deg(math.atan2(delta.Y, delta.X))
        lineObject.BackgroundColor3 = color
        lineObject.Visible = length > 1
    end

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
                    local target = Vector2.new(center.X, center.Y)

                    -- Tìm đoạn giao giữa line (đáy màn hình -> mục tiêu) và khung nhân vật chính.
                    -- Phần nằm trong khung nhân vật sẽ bị bỏ, hai phần ngoài vẫn được vẽ.
                    local dx, dy = target.X - bottom.X, target.Y - bottom.Y
                    local tEnter, tExit = 0, 1
                    local intersects = false

                    if hasMyScreenBounds then
                        local p = {-dx, dx, -dy, dy}
                        local q = {
                            bottom.X - myMinX,
                            myMaxX - bottom.X,
                            bottom.Y - myMinY,
                            myMaxY - bottom.Y
                        }
                        local valid = true
                        for k = 1, 4 do
                            if math.abs(p[k]) < 1e-6 then
                                if q[k] < 0 then valid = false break end
                            else
                                local r = q[k] / p[k]
                                if p[k] < 0 then
                                    tEnter = math.max(tEnter, r)
                                else
                                    tExit = math.min(tExit, r)
                                end
                            end
                        end
                        intersects = valid and tEnter <= tExit and tExit >= 0 and tEnter <= 1
                    end

                    if intersects then
                        tEnter = math.clamp(tEnter, 0, 1)
                        tExit = math.clamp(tExit, 0, 1)
                        local before = Vector2.new(
                            bottom.X + dx * tEnter,
                            bottom.Y + dy * tEnter
                        )
                        local after = Vector2.new(
                            bottom.X + dx * tExit,
                            bottom.Y + dy * tExit
                        )

                        drawLineSegment(data.line, bottom, before, rainbow)
                        drawLineSegment(data.line2, after, target, rainbow)
                    else
                        drawLineSegment(data.line, bottom, target, rainbow)
                        data.line2.Visible = false
                    end
                else
                    data.line.Visible = false
                    data.line2.Visible = false
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
        data.line:Destroy(); data.line2:Destroy(); data.box:Destroy(); data.label:Destroy()
        espTable[player] = nil
    end
end)
for _, player in ipairs(P:GetPlayers()) do
    if player ~= pl then makeESPObject(player) end
end

-- Aimlock: chỉ chọn người chơi nằm trong vòng FOV cố định trên màn hình.
RS.RenderStepped:Connect(function()
    cam = workspace.CurrentCamera or cam
    if aimFovCircle and cam then
        local viewport = cam.ViewportSize
        aimFovCircle.Position = UDim2.fromOffset(viewport.X * 0.5, viewport.Y * 0.5)
        aimFovCircle.Size = UDim2.fromOffset(aimFovRadius * 2, aimFovRadius * 2)
        aimFovCircle.Visible = aimFovEnabled and aimFovVisible
    end

    if not tg.aimlock then return end
    local myChar = pl.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHrp or not cam then return end

    local screenCenter = cam.ViewportSize * 0.5
    local closestHead = nil
    local shortestScreenDist = math.huge

    for _, player in ipairs(P:GetPlayers()) do
        if player ~= pl and player.Character then
            local char = player.Character
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if humanoid and humanoid.Health > 0 and head then
                local point, onScreen = cam:WorldToViewportPoint(head.Position)
                if onScreen and point.Z > 0 then
                    local screenDist = (Vector2.new(point.X, point.Y) - screenCenter).Magnitude
                    local insideFov = (not aimFovEnabled) or screenDist <= aimFovRadius
                    if insideFov and screenDist < shortestScreenDist then
                        shortestScreenDist = screenDist
                        closestHead = head
                    end
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
        -- Spin Bot
        if spinState.on then 
            spinAccum = spinAccum + math.rad(spinState.speed * 360) * 0.016 
            hr.CFrame = CFrame.new(hr.Position) * CFrame.Angles(0, spinAccum, 0) 
        end
    end
    
    -- Auto Fly: dịch chuyển trực tiếp lên phía trên mục tiêu đã chọn.
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
            flyWasEnabled = true
            myHR.CFrame = targetHR.CFrame * CFrame.new(0, 4, 0)
            myHR.AssemblyLinearVelocity = Vector3.zero
            myHR.AssemblyAngularVelocity = Vector3.zero
        else
            flyWasEnabled = false
        end
    elseif flyWasEnabled or flyAlignPosition or flyAttachment then
        flyWasEnabled = false
        if flyAlignPosition then flyAlignPosition:Destroy(); flyAlignPosition = nil end
        if flyAttachment then flyAttachment:Destroy(); flyAttachment = nil end
        local root = c and c:FindFirstChild("HumanoidRootPart")
        if root then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end
        if h then
            h.PlatformStand = false
            h.Sit = false
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
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
main.Size = UDim2.new(1, -12, 1, -12)
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
mainStroke.Transparency = 0.12
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

local mainScale = Instance.new("UIScale", main)
local function updateMenuScale()
    -- Menu chiếm gần toàn màn hình, không thu nhỏ theo kích thước cố định.
    mainScale.Scale = 1
    main.Size = UDim2.new(1, -12, 1, -12)
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
topBar.ClipsDescendants = true
topBar.BorderSizePixel = 0
topBar.ZIndex = 101
Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel", topBar)
title.Size = UDim2.new(1, -250, 1, 0)
title.Position = UDim2.new(0, 18, 0, 0)
title.BackgroundTransparency = 1
title.Text = "NEKO HUB  /  CONTROL PANEL"
title.TextColor3 = ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 16
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
closeBtn.Size = UDim2.new(0, 34, 0, 30)
closeBtn.Position = UDim2.new(1, -44, 0.5, -15)
closeBtn.BackgroundColor3 = BG_CARD
closeBtn.Text = "—"
closeBtn.TextColor3 = RED
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.AutoButtonColor = false
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
closeBtn.MouseButton1Click:Connect(function() main.Visible = false end) -- Ẩn menu, không tắt các chức năng đang bật

-- Menu cố định chính giữa màn hình, không có bong bóng nổi.
-- Chạm đồng thời 4 ngón để mở lại khi menu đang ẩn.
local activeTouches = {}
local function countTouches()
    local n = 0
    for _ in pairs(activeTouches) do n += 1 end
    return n
end
UIS.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.Touch then
        activeTouches[input] = true
        if countTouches() >= 4 and not main.Visible then
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
sideBar.Size = UDim2.new(1, -24, 0, 42)
sideBar.Position = UDim2.new(0, 12, 0, 50)
sideBar.BackgroundTransparency = 1
local sideLay = Instance.new("UIListLayout", sideBar)
sideLay.FillDirection = Enum.FillDirection.Horizontal
sideLay.HorizontalAlignment = Enum.HorizontalAlignment.Left
sideLay.VerticalAlignment = Enum.VerticalAlignment.Center
sideLay.Padding = UDim.new(0, 6)

local content = Instance.new("Frame", main)
content.Size = UDim2.new(1, -24, 1, -104)
content.Position = UDim2.new(0, 12, 0, 98)
content.BackgroundTransparency = 1

local tabs = {"MOVE", "ESP", "PLAYER", "TELE", "AIM", "KILLER", "INFO"}
local tabLabels = {MOVE="  DI CHUYỂN", ESP="  ESP", PLAYER="  NHÂN VẬT", TELE="  DỊCH CHUYỂN", AIM="  AIM", KILLER="  KILLER", INFO="  THÔNG TIN"}
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
    btn.Size = UDim2.new(1/7, -6, 1, 0)
    btn.BackgroundColor3 = (i == 1) and ACCENT or BG_SEC
    btn.Name = "Tab_" .. name
    btn.Text = tabLabels[name] or ("  " .. name)
    btn.TextColor3 = (i == 1) and BG_MAIN or TXT_DIM
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.TextSize = 10
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(function() switchTab(name) end)

    local page = Instance.new("ScrollingFrame", content)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = (i == 1)
    local lay = Instance.new("UIListLayout", page)
    lay.Padding = UDim.new(0, 10)
    local pagePadding = Instance.new("UIPadding", page)
    pagePadding.PaddingTop = UDim.new(0, 4)
    pagePadding.PaddingBottom = UDim.new(0, 8)
    pagePadding.PaddingLeft = UDim.new(0, 3)
    pagePadding.PaddingRight = UDim.new(0, 6)
    pages[name] = page
end

-- UI Helpers
local function mkSec(parent, text)
    local s = Instance.new("Frame", parent)
    s.Size = UDim2.new(1, -8, 0, 32)
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
    b.Size = UDim2.new(1, -8, 0, 46)
    b.BackgroundColor3 = BG_CARD
    b.Text = "   " .. text
    b.TextColor3 = TXT
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
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
    f.Size = UDim2.new(1, -8, 0, 54)
    f.BackgroundColor3 = BG_CARD
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -16, 0, 23)
    lbl.Position = UDim2.new(0, 12, 0, 5)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. default
    lbl.TextColor3 = TXT
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 13

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(1, -24, 0, 4)
    bar.Position = UDim2.new(0, 12, 0, 36)
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
mkSli(movePage, "Walk Speed", 16, 100, 16, function(v) stt.ws = math.clamp(v, 16, 100) end)
mkTog(movePage, "Infinite Jump", false, function(s) tg.infJump = s end)

-- Infinite Jump: xử lý trực tiếp mỗi lần người chơi nhấn nút nhảy.
UIS.JumpRequest:Connect(function()
    if not tg.infJump then return end
    local character = pl.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local espPage = pages["ESP"]
mkSec(espPage, "ESP NGƯỜI CHƠI  /  VISUAL")
mkTog(espPage, "ESP  •  BẬT / TẮT TẤT CẢ", false, function(s)
    espFlags.line = s
    espFlags.box = s
    espFlags.info = s
end)
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
-- EXTREME FPS: aggressive but reversible local visual reduction.
-- Every changed property is snapshotted once and restored when the toggle is disabled.
local fpsSaved = setmetatable({}, {__mode = "k"})
local fpsOldShadows = L.GlobalShadows
local fpsOldEnvironment = {}
local fpsDescendantConnection = nil
local fpsApplying = false
local function fpsRemember(obj, property)
    if not obj or not obj.Parent then return end
    fpsSaved[obj] = fpsSaved[obj] or {}
    if fpsSaved[obj][property] == nil then
        local okRead, oldValue = pcall(function() return obj[property] end)
        if okRead then fpsSaved[obj][property] = oldValue end
    end
end
local function fpsSet(obj, property, value)
    fpsRemember(obj, property)
    pcall(function() obj[property] = value end)
end
local function fpsOptimizeObject(obj)
    if not tg.fps or not obj then return end
    -- Giảm tải hiệu ứng nặng nhưng giữ nguyên hậu kỳ, ánh sáng, sương,
    -- texture và vật liệu để tránh hình ảnh bị chói hoặc quá trống.
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
        fpsSet(obj, "Enabled", false)
    elseif obj:IsA("BasePart") then
        fpsSet(obj, "CastShadow", false)
        fpsSet(obj, "Reflectance", 0)
    end
end
local function setFPSBoost(enabled)
    tg.fps = enabled
    if enabled then
        fpsOldShadows = L.GlobalShadows
        fpsOldEnvironment = {
            GlobalShadows = L.GlobalShadows,
        }
        L.GlobalShadows = false
        if fpsDescendantConnection then fpsDescendantConnection:Disconnect() end
        fpsDescendantConnection = game.DescendantAdded:Connect(function(obj)
            if tg.fps then fpsOptimizeObject(obj) end
        end)
        -- Chia nhỏ lượt quét để tránh khựng mạnh ngay lúc bật FPS.
        task.spawn(function()
            local descendants = game:GetDescendants()
            for i, obj in ipairs(descendants) do
                if not tg.fps then break end
                fpsOptimizeObject(obj)
                if i % 250 == 0 then task.wait() end
            end
        end)
    else
        if fpsDescendantConnection then
            fpsDescendantConnection:Disconnect()
            fpsDescendantConnection = nil
        end
        for obj, properties in pairs(fpsSaved) do
            if obj and obj.Parent then
                for property, oldValue in pairs(properties) do
                    pcall(function() obj[property] = oldValue end)
                end
            end
        end
        table.clear(fpsSaved)
        L.GlobalShadows = fpsOldEnvironment.GlobalShadows ~= nil and fpsOldEnvironment.GlobalShadows or fpsOldShadows
        table.clear(fpsOldEnvironment)
    end
end
mkTog(plPage, "EXTREME FPS  •  Giảm tải hình ảnh tối đa", false, setFPSBoost)
mkSli(plPage, "Camera FOV", 70, 120, 70, function(v) cam.FieldOfView = v end)
mkBtn(plPage, "Reset Character", function() if pl.Character then pl.Character:BreakJoints() end end)
mkBtn(plPage, "Rejoin Server", function() TS:Teleport(game.PlaceId, pl) end)

-- TELEPORT & DYNAMIC WAYPOINTS
local telePage = pages["TELE"]
mkSec(telePage, "AUTO FLY  /  FOLLOW TARGET")

-- Dropdown chỉ liệt kê NGƯỜI CHƠI thật; dùng chung cho Teleport và Auto Fly.
local selectedTargetLabel = Instance.new("TextLabel", telePage)
selectedTargetLabel.Size = UDim2.new(1, -8, 0, 22)
selectedTargetLabel.BackgroundTransparency = 1
selectedTargetLabel.Text = "NGƯỜI CHƠI: CHƯA CHỌN"
selectedTargetLabel.TextColor3 = ACCENT
selectedTargetLabel.Font = Enum.Font.GothamBold
selectedTargetLabel.TextSize = 11
selectedTargetLabel.TextXAlignment = Enum.TextXAlignment.Left

local targetScroll
local targetDropdownButton = mkBtn(telePage, "CHỌN NGƯỜI CHƠI  ▼", function(btn)
    targetScroll.Visible = not targetScroll.Visible
    btn.Text = targetScroll.Visible and "CHỌN NGƯỜI CHƠI  ▲" or "CHỌN NGƯỜI CHƠI  ▼"
end)

targetScroll = Instance.new("ScrollingFrame", telePage)
targetScroll.Name = "PlayerTargetDropdown"
targetScroll.Size = UDim2.new(1, -8, 0, 132)
targetScroll.BackgroundColor3 = BG_CARD
targetScroll.BorderSizePixel = 0
targetScroll.ScrollBarThickness = 3
targetScroll.ScrollBarImageColor3 = ACCENT
targetScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
targetScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
targetScroll.ScrollingDirection = Enum.ScrollingDirection.Y
targetScroll.Visible = false
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
    if typeof(target) ~= "Instance" or not target:IsA("Player") or target == pl or not target.Parent then
        return nil
    end
    local character = target.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not humanoid or humanoid.Health <= 0 then return nil end
    return root
end

local function getMapTargetName(target)
    return target.DisplayName .. "  (@" .. target.Name .. ")"
end

local function refreshMapTargets()
    for _, child in ipairs(targetScroll:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then
            child:Destroy()
        end
    end

    local myRoot = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    local found = {}
    for _, player in ipairs(P:GetPlayers()) do
        if player ~= pl then
            local root = getMapTargetRoot(player)
            if root then
                local distance = myRoot and (root.Position - myRoot.Position).Magnitude or math.huge
                table.insert(found, {player = player, distance = distance})
            end
        end
    end

    table.sort(found, function(a, b) return a.distance < b.distance end)

    for index, entry in ipairs(found) do
        local player = entry.player
        local row = Instance.new("TextButton")
        row.Name = "PlayerTarget_" .. tostring(index)
        row.Size = UDim2.new(1, -4, 0, 30)
        row.BackgroundColor3 = player == selectedFlyTarget and BG_SEC or BG_MAIN
        row.BorderSizePixel = 0
        row.AutoButtonColor = true
        row.Text = string.format("  %s   •   %.1f studs", getMapTargetName(player), entry.distance)
        row.TextColor3 = player == selectedFlyTarget and GREEN or TXT
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Font = Enum.Font.GothamMedium
        row.TextSize = 10
        row.Parent = targetScroll
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

        row.MouseButton1Click:Connect(function()
            selectedFlyTarget = player
            selectedTargetLabel.Text = "ĐÃ CHỌN: " .. getMapTargetName(player)
            selectedTargetLabel.TextColor3 = GREEN
            targetScroll.Visible = false
            targetDropdownButton.Text = "CHỌN NGƯỜI CHƠI  ▼"
            for _, other in ipairs(targetScroll:GetChildren()) do
                if other:IsA("TextButton") then
                    other.BackgroundColor3 = other == row and BG_SEC or BG_MAIN
                    other.TextColor3 = other == row and GREEN or TXT
                end
            end
        end)
    end

    if #found == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -4, 0, 28)
        empty.BackgroundTransparency = 1
        empty.Text = "Không có người chơi nào khác"
        empty.TextColor3 = TXT_DIM
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 10
        empty.Parent = targetScroll
    end
end

mkBtn(telePage, "↻  CẬP NHẬT DANH SÁCH + KHOẢNG CÁCH", refreshMapTargets)
mkBtn(telePage, "TELEPORT  →  NGƯỜI CHƠI ĐÃ CHỌN", function(btn)
    local targetRoot = getMapTargetRoot(selectedFlyTarget)
    local myRoot = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    if targetRoot and myRoot then
        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
    else
        btn.Text = "   HÃY CHỌN NGƯỜI CHƠI CÒN TRONG GAME"
    end
end)
refreshMapTargets()

mkTog(telePage, "Auto Fly  •  Bám nhanh mục tiêu", false, function(s)
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
mkSec(aimPage, "AIM LOCK  /  FOV")

aimFovCircle = Instance.new("Frame")
aimFovCircle.Name = "AimFOVCircle"
aimFovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
aimFovCircle.Position = UDim2.fromScale(0.5, 0.5)
aimFovCircle.Size = UDim2.fromOffset(aimFovRadius * 2, aimFovRadius * 2)
aimFovCircle.BackgroundTransparency = 1
aimFovCircle.BorderSizePixel = 0
aimFovCircle.Visible = false
aimFovCircle.ZIndex = 80
aimFovCircle.Parent = sg
local aimFovStroke = Instance.new("UIStroke")
aimFovStroke.Color = ACCENT
aimFovStroke.Thickness = 1.5
aimFovStroke.Transparency = 0.12
aimFovStroke.Parent = aimFovCircle
local aimFovCorner = Instance.new("UICorner")
aimFovCorner.CornerRadius = UDim.new(1, 0)
aimFovCorner.Parent = aimFovCircle

mkTog(aimPage, "Aim Lock  •  Khóa mục tiêu gần tâm", false, function(s)
    tg.aimlock = s
end)
mkTog(aimPage, "Giới hạn mục tiêu trong FOV", false, function(s)
    aimFovEnabled = s
    if aimFovCircle then aimFovCircle.Visible = s and aimFovVisible end
end)
mkTog(aimPage, "Hiện / Ẩn vòng FOV", false, function(s)
    aimFovVisible = s
    if aimFovCircle then aimFovCircle.Visible = aimFovEnabled and s end
end)
local fovFixedHint = Instance.new("TextLabel", aimPage)
fovFixedHint.Size = UDim2.new(1, -8, 0, 30)
fovFixedHint.BackgroundColor3 = BG_SEC
fovFixedHint.BackgroundTransparency = 0.12
fovFixedHint.BorderSizePixel = 0
fovFixedHint.Text = "FOV FIXED  •  RADIUS 50"
fovFixedHint.TextColor3 = ACCENT
fovFixedHint.Font = Enum.Font.GothamBold
fovFixedHint.TextSize = 11
Instance.new("UICorner", fovFixedHint).CornerRadius = UDim.new(0, 8)

local aimHint = Instance.new("TextLabel", aimPage)
aimHint.Size = UDim2.new(1, -8, 0, 42)
aimHint.BackgroundColor3 = BG_SEC
aimHint.BackgroundTransparency = 0.12
aimHint.BorderSizePixel = 0
aimHint.Text = "FOV cố định tại tâm màn hình. Khi bật giới hạn FOV, Aim Lock chỉ chọn người chơi nằm bên trong vòng."
aimHint.TextColor3 = TXT_DIM
aimHint.Font = Enum.Font.Gotham
aimHint.TextSize = 11
aimHint.TextWrapped = true
Instance.new("UICorner", aimHint).CornerRadius = UDim.new(0, 8)

-- KILLER PAGE
local killerPage = pages["KILLER"]
local killerActive = false
local killerTarget = nil
local killerOldCameraMode, killerOldMinZoom, killerOldMaxZoom
local killerLastAttack = 0
local killerPromptProtection = false
local protectedPrompts = {}

mkSec(killerPage, "KILLER  /  CHỌN MỤC TIÊU")
local killerTargetLabel = Instance.new("TextLabel", killerPage)
killerTargetLabel.Size = UDim2.new(1, -8, 0, 24)
killerTargetLabel.BackgroundTransparency = 1
killerTargetLabel.Text = "MỤC TIÊU: CHƯA CHỌN"
killerTargetLabel.TextColor3 = ACCENT
killerTargetLabel.Font = Enum.Font.GothamBold
killerTargetLabel.TextSize = 11
killerTargetLabel.TextXAlignment = Enum.TextXAlignment.Left

local killerList = Instance.new("ScrollingFrame", killerPage)
killerList.Size = UDim2.new(1, -8, 0, 132)
killerList.BackgroundColor3 = BG_CARD
killerList.BorderSizePixel = 0
killerList.ScrollBarThickness = 3
killerList.ScrollBarImageColor3 = ACCENT
killerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
killerList.CanvasSize = UDim2.new(0, 0, 0, 0)
Instance.new("UICorner", killerList).CornerRadius = UDim.new(0, 7)
local killerLayout = Instance.new("UIListLayout", killerList)
killerLayout.Padding = UDim.new(0, 3)
local killerPadding = Instance.new("UIPadding", killerList)
killerPadding.PaddingTop = UDim.new(0, 4)
killerPadding.PaddingLeft = UDim.new(0, 4)
killerPadding.PaddingRight = UDim.new(0, 4)

local function refreshKillerTargets()
    for _, child in ipairs(killerList:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
    end
    local candidates = {}
    local myRoot = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
    for _, candidate in ipairs(P:GetPlayers()) do
        if candidate ~= pl then
            local root = getMapTargetRoot(candidate)
            if root then
                table.insert(candidates, {
                    player = candidate,
                    distance = myRoot and (root.Position - myRoot.Position).Magnitude or math.huge
                })
            end
        end
    end
    table.sort(candidates, function(a, b) return a.distance < b.distance end)
    for index, entry in ipairs(candidates) do
        local candidate = entry.player
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, -4, 0, 30)
        row.LayoutOrder = index
        row.BackgroundColor3 = candidate == killerTarget and BG_SEC or BG_MAIN
        row.BorderSizePixel = 0
        row.Text = string.format("  %s  •  %.0f studs", candidate.DisplayName, entry.distance)
        row.TextColor3 = candidate == killerTarget and GREEN or TXT
        row.TextXAlignment = Enum.TextXAlignment.Left
        row.Font = Enum.Font.GothamMedium
        row.TextSize = 10
        row.Parent = killerList
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
        row.MouseButton1Click:Connect(function()
            killerTarget = candidate
            selectedFlyTarget = candidate
            killerTargetLabel.Text = "ĐÃ CHỌN: " .. candidate.DisplayName
            killerTargetLabel.TextColor3 = GREEN
            refreshKillerTargets()
        end)
    end
    if #candidates == 0 then
        local empty = Instance.new("TextLabel")
        empty.Size = UDim2.new(1, -4, 0, 28)
        empty.BackgroundTransparency = 1
        empty.Text = "Không có mục tiêu hợp lệ"
        empty.TextColor3 = TXT_DIM
        empty.Font = Enum.Font.Gotham
        empty.TextSize = 10
        empty.Parent = killerList
    end
end

mkBtn(killerPage, "LÀM MỚI DANH SÁCH MỤC TIÊU", refreshKillerTargets)

local function killerFindWeapon()
    local character = pl.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local backpack = pl:FindFirstChildOfClass("Backpack")
    if not humanoid then return nil end
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then
                humanoid:EquipTool(item)
                return item
            end
        end
    end
    for _, item in ipairs(character:GetChildren()) do
        if item:IsA("Tool") then return item end
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then
        local nearestTool, nearestDistance
        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("Tool") and item.Parent == workspace then
                local handle = item:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    local distance = (handle.Position - root.Position).Magnitude
                    if distance <= 80 and (not nearestDistance or distance < nearestDistance) then
                        nearestTool, nearestDistance = item, distance
                    end
                end
            end
        end
        if nearestTool then
            local handle = nearestTool:FindFirstChild("Handle")
            if handle then root.CFrame = handle.CFrame + Vector3.new(0, 2, 0) end
            task.wait(0.15)
            pcall(function() humanoid:EquipTool(nearestTool) end)
            return nearestTool
        end
    end
    return nil
end

local function killerSetActive(enabled)
    killerActive = enabled
    if enabled then
        if not killerTarget or not getMapTargetRoot(killerTarget) then
            killerActive = false
            return false
        end
        local character = pl.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid then killerActive = false return false end
        killerOldCameraMode = pl.CameraMode
        killerOldMinZoom, killerOldMaxZoom = pl.CameraMinZoomDistance, pl.CameraMaxZoomDistance
        pl.CameraMode = Enum.CameraMode.LockFirstPerson
        pl.CameraMinZoomDistance, pl.CameraMaxZoomDistance = 0.5, 0.5
        tg.noclip = true
        tg.autoFly = false
        killerFindWeapon()
    else
        pl.CameraMode = killerOldCameraMode or Enum.CameraMode.Classic
        pl.CameraMinZoomDistance = killerOldMinZoom or 0.5
        pl.CameraMaxZoomDistance = killerOldMaxZoom or 128
        tg.noclip = false
    end
    return true
end

mkTog(killerPage, "KILLER  •  BẬT / TẮT", false, function(enabled)
    if not killerSetActive(enabled) then
        killerTargetLabel.Text = "HÃY CHỌN MỤC TIÊU CÒN SỐNG"
        killerTargetLabel.TextColor3 = RED
    end
end)

mkTog(killerPage, "Chặn prompt mua hàng", false, function(enabled)
    killerPromptProtection = enabled
    if not enabled then
        for prompt, wasEnabled in pairs(protectedPrompts) do
            if prompt and prompt.Parent then prompt.Enabled = wasEnabled end
        end
        table.clear(protectedPrompts)
    end
end)

local purchaseWords = {"buy", "purchase", "shop", "mua", "robux", "product"}
local ProximityPromptService = game:GetService("ProximityPromptService")
ProximityPromptService.PromptShown:Connect(function(prompt)
    if not killerPromptProtection or not prompt or not prompt.Parent then return end
    local promptText = string.lower((prompt.ActionText or "") .. " " .. (prompt.ObjectText or ""))
    for _, word in ipairs(purchaseWords) do
        if string.find(promptText, word, 1, true) then
            if protectedPrompts[prompt] == nil then
                protectedPrompts[prompt] = prompt.Enabled
            end
            prompt.Enabled = false
            break
        end
    end
end)

RS.Heartbeat:Connect(function()
    if not killerActive then return end
    local targetRoot = getMapTargetRoot(killerTarget)
    local character = pl.Character
    local myRoot = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local targetCharacter = killerTarget and killerTarget.Character
    local targetHead = targetCharacter and targetCharacter:FindFirstChild("Head")
    if not targetRoot or not myRoot or not humanoid or humanoid.Health <= 0 or not targetHead then
        killerSetActive(false)
        return
    end
    myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 4, 0)
    myRoot.AssemblyLinearVelocity = Vector3.zero
    cam = workspace.CurrentCamera or cam
    if cam then
        cam.CameraSubject = humanoid
        cam.CFrame = CFrame.new(cam.CFrame.Position, targetHead.Position)
    end
    local tool = killerFindWeapon()
    if tool and tool.Parent == character and os.clock() - killerLastAttack >= 0.18 then
        killerLastAttack = os.clock()
        pcall(function() tool:Activate() end)
    end
end)

refreshKillerTargets()

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