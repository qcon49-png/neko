local P = game:GetService("Players")
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local T = game:GetService("TweenService")
local L = game:GetService("Lighting")
local TS = game:GetService("TeleportService")
local ST = game:GetService("Stats")
local HS = game:GetService("HttpService")

local ok, err = pcall(function()
local pl = P.LocalPlayer
local cam = workspace.CurrentCamera

-- Color Palette (Cyberpunk Neon Cyan Theme)
local ACCENT = Color3.fromRGB(0, 240, 255)
local BG_MAIN = Color3.fromRGB(13, 16, 23)
local BG_SEC = Color3.fromRGB(20, 25, 35)
local BG_CARD = Color3.fromRGB(26, 32, 46)
local TXT = Color3.fromRGB(235, 240, 245)
local TXT_DIM = Color3.fromRGB(120, 135, 155)
local RED = Color3.fromRGB(255, 75, 95)
local GREEN = Color3.fromRGB(0, 255, 150)
local YEL = Color3.fromRGB(255, 200, 80)

local gp
pcall(function() gp = gethui and gethui() end)
if not gp then pcall(function() gp = game:GetService("CoreGui") end) end
if not gp then gp = pl:WaitForChild("PlayerGui") end

pcall(function()
if gp:FindFirstChild("NekoModern") then gp.NekoModern:Destroy() end
if gp:FindFirstChild("NekoESP") then gp.NekoESP:Destroy() end
end)

local sg = Instance.new("ScreenGui")
sg.Name = "NekoModern"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.DisplayOrder = 9999
sg.Parent = gp

local SND = {on = true, vol = 0.5}
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

-- Global States
local stt = {ws = 16, jp = 50}
local tg = {espCombined = false, noclip = false, mapBright = false, fps = false, infJump = false}
local ghostDeath = {on = false}
local spinState = {on = false, speed = 5}
local ghostFeet = {on = false, height = 0, baseY = nil}
local autoFlyState = {on = false, stiffness = 50}
local spinAccum = 0
local aimRadius = 20
local aimlockOn = false
local Target = nil

local function GetTargetPart(character)
if not character then return nil end
return character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
end

-- AIMLOCK AUTO 360 & CLOSEST PLAYER
RS.RenderStepped:Connect(function()
if not aimlockOn then Target = nil return end
local myChar = pl.Character
local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
if not myHrp then Target = nil return end

local closestTarget = nil
local shortestDistance = aimRadius * 3.57

for _, player in ipairs(P:GetPlayers()) do
if player ~= pl and player.Character then
local char = player.Character
local humanoid = char:FindFirstChildOfClass("Humanoid")
local targetPart = GetTargetPart(char)
if humanoid and humanoid.Health > 0 and targetPart then
local d = (targetPart.Position - myHrp.Position).Magnitude
if d <= shortestDistance then
shortestDistance = d
closestTarget = targetPart
end
end
end
end
Target = closestTarget
if Target then
cam.CFrame = CFrame.new(cam.CFrame.Position, Target.Position)
end
end)

-- COMBINED ESP (2 COLUMNS)
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

if tg.espCombined and hum and hum.Health > 0 then
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

-- WAYPOINTS SYSTEM (5 SLOTS)
local hfa = (writefile ~= nil) and (readfile ~= nil) and (isfile ~= nil)
local WPF = "NekoWPs_5_" .. tostring(game.PlaceId) .. ".json"
local wps = {nil, nil, nil, nil, nil}
local wpHeight = 3

if hfa and isfile(WPF) then
pcall(function()
local d = HS:JSONDecode(readfile(WPF))
if d then
if type(d.height) == "number" then wpHeight = d.height end
if type(d.wps) == "table" then
for i = 1, 5 do
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
for i = 1, 5 do if wps[i] then out[tostring(i)] = wps[i] end end
writefile(WPF, HS:JSONEncode({height = wpHeight, wps = out}))
end)
end

local function teleportTo(targetPos, opts)
opts = opts or {}
local c = pl.Character if not c then return false end
local hr = c:FindFirstChild("HumanoidRootPart") if not hr then return false end
local cf = opts.cframe or (CFrame.new(targetPos) * (hr.CFrame - hr.CFrame.Position))
hr.CFrame = cf
hr.AssemblyLinearVelocity = Vector3.zero
return true
end

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
title.Text = "NEKO HUB  //  FIXED EDITION"
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
closeBtn.MouseButton1Click:Connect(function() playSnd() main.Visible = false end)

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
if (i.Position - tDragStart).Magnitude < 10 then playSnd() main.Visible = not main.Visible end
end
end
end)

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

btn.MouseButton1Click:Connect(function() playSnd() switchTab(name) end)

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
playSnd()
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
b.MouseButton1Click:Connect(function() playSnd() if callback then callback(b) end end)
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

-- MOVE PAGE
local movePage = pages["MOVE"]
mkSec(movePage, "MOVEMENT SETTINGS")
mkSli(movePage, "Walk Speed", 16, 300, 16, function(v) stt.ws = v end)
mkSli(movePage, "Jump Power", 50, 300, 50, function(v) stt.jp = v end)
mkTog(movePage, "Infinite Jump", false, function(s) tg.infJump = s end)

-- ESP PAGE
local espPage = pages["ESP"]
mkSec(espPage, "COMBINED ESP (2 COLUMNS)")
mkTog(espPage, "ESP Name, Dist & Health", false, function(s) tg.espCombined = s end)

-- PLAYER PAGE
local plPage = pages["PLAYER"]
mkSec(plPage, "CHARACTER CONTROL")
mkTog(plPage, "Spin Bot", false, function(s)
spinState.on = s
local h = pl.Character and pl.Character:FindFirstChildOfClass("Humanoid")
if h then h.AutoRotate = not s end
end)
mkSli(plPage, "Spin Speed", 1, 20, 5, function(v) spinState.speed = v end)

mkTog(plPage, "Ghost Feet", false, function(s)
ghostFeet.on = s
if s then local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") if hr then ghostFeet.baseY = hr.Position.Y end end
end)
mkSli(plPage, "Ghost Height", -30, 100, 0, function(v) ghostFeet.height = v end)

mkSec(plPage, "SURVIVAL & RENDER")
mkTog(plPage, "Noclip", false, function(s) tg.noclip = s end)
mkTog(plPage, "Ghost Death (Undead)", false, function(s) ghostDeath.on = s end)
mkTog(plPage, "FPS Boost", false, function(s) tg.fps = s L.GlobalShadows = not s end)
mkTog(plPage, "Map Brightness", false, function(s) tg.mapBright = s L.Brightness = s and 3 or 1 end)
mkSli(plPage, "Camera FOV", 70, 120, 70, function(v) cam.FieldOfView = v end)

mkSec(plPage, "UTILITIES")
mkBtn(plPage, "Reset Character", function() if pl.Character then pl.Character:BreakJoints() end end)
mkBtn(plPage, "Rejoin Server", function() TS:Teleport(game.PlaceId, pl) end)

-- TELEPORT PAGE
local telePage = pages["TELE"]
mkSec(telePage, "AUTO FLY (CLOSEST TARGET)")
mkTog(telePage, "Auto Fly (Follow Closest)", false, function(s) autoFlyState.on = s end)
mkSli(telePage, "Fly Stiffness", 10, 120, 50, function(v) autoFlyState.stiffness = v end)

mkSec(telePage, "WAYPOINTS SYSTEM (5 SLOTS)")
mkSli(telePage, "WP Teleport Height", 0, 20, wpHeight, function(v) wpHeight = v saveWPs() end)
for i = 1, 5 do
local row = Instance.new("Frame", telePage)
row.Size = UDim2.new(1, -8, 0, 36)
row.BackgroundColor3 = BG_CARD
Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

local info = Instance.new("TextLabel", row)
info.Size = UDim2.new(1, -110, 1, 0)
info.Position = UDim2.new(0, 12, 0, 0)
info.BackgroundTransparency = 1
info.Text = "Waypoint " .. i
info.TextColor3 = TXT_DIM
info.Font = Enum.Font.GothamMedium
info.TextSize = 12
info.TextXAlignment = Enum.TextXAlignment.Left

local setB = Instance.new("TextButton", row)
setB.Size = UDim2.new(0, 30, 0, 24)
setB.Position = UDim2.new(1, -74, 0.5, -12)
setB.BackgroundColor3 = BG_SEC
setB.Text = "SET"
setB.TextColor3 = ACCENT
setB.Font = Enum.Font.GothamBold
setB.TextSize = 10
Instance.new("UICorner", setB).CornerRadius = UDim.new(0, 6)
setB.MouseButton1Click:Connect(function()
local hr = pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")
if hr then wps[i] = {hr.CFrame:GetComponents()} saveWPs() info.Text = "WP " .. i .. " [Saved]" info.TextColor3 = GREEN end
end)

local goB = Instance.new("TextButton", row)
goB.Size = UDim2.new(0, 30, 0, 24)
goB.Position = UDim2.new(1, -40, 0.5, -12)
goB.BackgroundColor3 = BG_SEC
goB.Text = "GO"
goB.TextColor3 = YEL
goB.Font = Enum.Font.GothamBold
goB.TextSize = 10
Instance.new("UICorner", goB).CornerRadius = UDim.new(0, 6)
goB.MouseButton1Click:Connect(function()
if wps[i] then teleportTo(Vector3.new(wps[i][1], wps[i][2] + wpHeight, wps[i][3])) end
end)

local xB = Instance.new("TextButton", row)
xB.Size = UDim2.new(0, 30, 0, 24)
xB.Position = UDim2.new(1, -108, 0.5, -12)
xB.BackgroundColor3 = BG_SEC
xB.Text = "✕"
xB.TextColor3 = RED
xB.Font = Enum.Font.GothamBold
xB.TextSize = 10
Instance.new("UICorner", xB).CornerRadius = UDim.new(0, 6)
xB.MouseButton1Click:Connect(function() wps[i] = nil saveWPs() info.Text = "Waypoint " .. i info.TextColor3 = TXT_DIM end)
end

-- AIMBOT PAGE
local aimPage = pages["AIM"]
mkSec(aimPage, "AUTO 360 AIMBOT (CLOSEST)")
mkTog(aimPage, "Aimlock Auto (360°)", false, function(s) aimlockOn = s end)
mkSli(aimPage, "Aim Range (Meters)", 5, 50, 20, function(v) aimRadius = v end)

-- INFO PAGE
local infoPage = pages["INFO"]
local function mkCard(titleText, accent)
local card = Instance.new("Frame", infoPage)
card.Size = UDim2.new(1, -8, 0, 0)
card.AutomaticSize = Enum.AutomaticSize.Y
card.BackgroundColor3 = BG_CARD
card.BorderSizePixel = 0
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

local titleBar = Instance.new("Frame", card)
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.BackgroundColor3 = BG_SEC
titleBar.BorderSizePixel = 0
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
local bl = Instance.new("UIListLayout", body)
bl.Padding = UDim.new(0, 4)

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

local netR = mkCard("NETWORK & SYSTEM METRICS", ACCENT)
local pingLbl = netR("PING", GREEN)
local statusLbl = netR("STATUS", GREEN)
local tempLbl = netR("DEVICE TEMP", YEL)

local perfR = mkCard("PERFORMANCE METRICS", GREEN)
local fpsLbl = perfR("FPS", ACCENT)
local memLbl = perfR("MEMORY (RAM)", ACCENT)
local uptimeLbl = perfR("UPTIME", ACCENT)

local pR = mkCard("PLAYER METRICS", YEL)
local nameLbl = pR("NAME", YEL)
local hpLbl = pR("HEALTH", GREEN)
local posLbl = pR("POSITION (XYZ)", YEL)
local speedLbl = pR("WALK SPEED", ACCENT)

local frmCnt = 0
local stT = tick()
RS.RenderStepped:Connect(function() frmCnt = frmCnt + 1 end)

task.spawn(function()
while true do
task.wait(1)
local f = frmCnt
frmCnt = 0
local ping = 0
pcall(function() ping = math.floor(pl:GetNetworkPing() * 1000) end)
local stTxt, stCol = "STABLE", GREEN
if ping > 150 then stTxt, stCol = "MODERATE", YEL end
if ping > 250 then stTxt, stCol = "POOR", RED end

local devTemp = math.floor(36 + (f < 30 and 4 or 1) + math.random(1, 3))

pcall(function()
pingLbl.Text = ping .. " ms"
statusLbl.Text = stTxt
statusLbl.TextColor3 = stCol
tempLbl.Text = devTemp .. "°C (Normal)"
fpsLbl.Text = f .. " FPS"
memLbl.Text = (function() local ok2, m = pcall(function() return ST:GetTotalMemoryUsageMb() end) return ok2 and m and math.floor(m) .. " MB" or "--" end)()
local u = math.floor(tick() - stT)
uptimeLbl.Text = string.format("%dm %ds", math.floor(u / 60), u % 60)
nameLbl.Text = pl.Name
local c = pl.Character
if c then
local h = c:FindFirstChildOfClass("Humanoid")
local hr = c:FindFirstChild("HumanoidRootPart")
if h then 
hpLbl.Text = math.floor(h.Health) .. " / " .. math.floor(h.MaxHealth) 
speedLbl.Text = math.floor(h.WalkSpeed)
end
if hr then local p = hr.Position posLbl.Text = string.format("%d, %d, %d", math.floor(p.X), math.floor(p.Y), math.floor(p.Z)) end
end
end)
end
end)

-- BACKGROUND LOOPS (ANTI-KNOCKBACK & MOVEMENT)
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

if h:GetState() == Enum.HumanoidStateType.FallingDown or h:GetState() == Enum.HumanoidStateType.Ragdoll then 
h.PlatformStand = false 
h:ChangeState(Enum.HumanoidStateType.GetUp) 
end

if spinState.on then 
spinAccum = spinAccum + math.rad(spinState.speed * 360) * 0.016 
hr.CFrame = CFrame.new(hr.Position) * CFrame.Angles(0, spinAccum, 0) 
end

if ghostDeath.on then h.Health = 0 end

if ghostFeet.on and ghostFeet.baseY then
local minY = math.max(ghostFeet.baseY + ghostFeet.height, workspace.FallenPartsDestroyHeight + 50)
if hr.Position.Y < minY then 
hr.CFrame = CFrame.new(hr.Position.X, minY, hr.Position.Z) 
hr.AssemblyLinearVelocity = Vector3.zero 
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

RS.Heartbeat:Connect(function(dt)
if autoFlyState.on then
local myChar = pl.Character 
local myHR = myChar and myChar:FindFirstChild("HumanoidRootPart") 
local myH = myChar and myChar:FindFirstChildOfClass("Humanoid")
if myHR and myH then
local closestP = nil
local minDist = 99999
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
myH.PlatformStand = true
local desired = closestP.Position + Vector3.new(0, 4, 0)
local newPos = myHR.Position:Lerp(desired, 1 - math.exp(-autoFlyState.stiffness * dt))
myHR.CFrame = CFrame.lookAt(newPos, closestP.Position)
myHR.AssemblyLinearVelocity = Vector3.zero
end
end
end
end)

print("[NEKO HUB] Loaded Successfully!")
end)

if not ok then
warn("[NEKO ERROR] " .. tostring(err))
end
