-- ==================================================================
-- ============ HACKER NEKO v12.5 (LIFE PRISON FIXED) ===============
-- ==================================================================
local ok, err = pcall(function()

local P=game:GetService("Players")
local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local T=game:GetService("TweenService")
local L=game:GetService("Lighting")
local TS=game:GetService("TeleportService")
local ST=game:GetService("Stats")
local HS=game:GetService("HttpService")
local pl=P.LocalPlayer
local cam=workspace.CurrentCamera

local G   = Color3.fromRGB(0,255,120)
local G2  = Color3.fromRGB(0,180,80)
local G3  = Color3.fromRGB(200,255,220)
local DIM = Color3.fromRGB(0,80,40)
local BG  = Color3.fromRGB(5,10,8)
local BG2 = Color3.fromRGB(8,18,12)
local TX  = Color3.fromRGB(180,255,200)
local CY  = Color3.fromRGB(0,255,255)
local RED = Color3.fromRGB(255,60,80)
local YEL = Color3.fromRGB(255,220,100)
local ORG = Color3.fromRGB(255,150,50)

local gp
pcall(function() gp = gethui and gethui() end)
if not gp then pcall(function() gp = game:GetService("CoreGui") end) end
if not gp then gp = pl:WaitForChild("PlayerGui") end
pcall(function()
    if gp:FindFirstChild("HackerNeko") then gp.HackerNeko:Destroy() end
    if gp:FindFirstChild("NekoESP") then gp.NekoESP:Destroy() end
end)

local sg=Instance.new("ScreenGui")
sg.Name="HackerNeko" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=9999
sg.Parent=gp

local ef=Instance.new("Folder",gp) ef.Name="NekoESP"
local epf=Instance.new("Folder",ef) epf.Name="Players"

local stt={ws=16,jp=50}
local tg={espLine=false,espName=false,espHp=false,espDist=false,espBody=false,
    noclip=false,mapBright=false,fps=false,infJump=false}
local aa={enabled=false,speed=200,atkSpd=false,hoverOn=false,hoverDist=0,target=nil}
local hitboxOn = true
local hitboxRange = 15

local fovCircle = {
    enabled = false,
    radius = 150,
    drawing = nil,
}

local aim = {
    enabled = false,
    smooth = 1,
    target = nil,
    silent = true, -- [FIX] Silent aim bật mặc định
}

local teleportTo

local hfa=(writefile~=nil) and (readfile~=nil) and (isfile~=nil)
local WPF="NekoWPs_"..tostring(game.PlaceId)..".json"
local wps = {nil, nil, nil, nil, nil, nil, nil, nil}
local wpHeight = 3

if hfa and isfile(WPF) then
    pcall(function()
        local d = HS:JSONDecode(readfile(WPF))
        if d then
            if type(d.height) == "number" then wpHeight = d.height end
            if type(d.wps) == "table" then
                for i=1,8 do
                    if type(d.wps[i]) == "table" then wps[i] = d.wps[i] end
                end
            end
        end
    end)
end
local function saveWPs()
    if not hfa then return end
    pcall(function()
        writefile(WPF, HS:JSONEncode({height=wpHeight, wps=wps}))
    end)
end
local function cfFromArr(arr)
    if not arr then return nil end
    return CFrame.new(arr[1],arr[2],arr[3],arr[4],arr[5],arr[6],arr[7],arr[8],arr[9],arr[10],arr[11],arr[12])
end

local toggleBtn=Instance.new("Frame",sg)
toggleBtn.Size=UDim2.new(0,48,0,48) toggleBtn.Position=UDim2.new(0,30,0,120)
toggleBtn.BackgroundColor3=BG toggleBtn.BackgroundTransparency=0.15
toggleBtn.BorderSizePixel=0 toggleBtn.Active=true toggleBtn.ZIndex=500
Instance.new("UICorner",toggleBtn).CornerRadius=UDim.new(0,6)
local tglStk=Instance.new("UIStroke",toggleBtn) tglStk.Color=G tglStk.Thickness=1.5
local tglGlow=Instance.new("UIStroke",toggleBtn) tglGlow.Color=G tglGlow.Thickness=6 tglGlow.Transparency=0.9
local iconLbl=Instance.new("TextLabel",toggleBtn)
iconLbl.Size=UDim2.new(1,0,1,0) iconLbl.BackgroundTransparency=1
iconLbl.Text=">_" iconLbl.Font=Enum.Font.Code iconLbl.TextSize=18 iconLbl.TextColor3=G iconLbl.ZIndex=501
local dot=Instance.new("Frame",toggleBtn)
dot.Size=UDim2.new(0,5,0,5) dot.Position=UDim2.new(1,-9,0,4)
dot.BackgroundColor3=G dot.BorderSizePixel=0 dot.ZIndex=502
Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

local main=Instance.new("Frame",sg)
main.Size=UDim2.new(0,420,0,340)
main.Position=UDim2.new(0,30,0,120)
main.BackgroundColor3=BG main.BackgroundTransparency=0.05
main.BorderSizePixel=0 main.Active=true main.Draggable=true main.Visible=false main.ZIndex=100
Instance.new("UICorner",main).CornerRadius=UDim.new(0,4)
local stk=Instance.new("UIStroke",main) stk.Color=G stk.Thickness=1.5
local stkGlow=Instance.new("UIStroke",main) stkGlow.Color=G stkGlow.Thickness=5 stkGlow.Transparency=0.85

local rainFrame=Instance.new("Frame",main)
rainFrame.Size=UDim2.new(1,-4,1,-4) rainFrame.Position=UDim2.new(0,2,0,2)
rainFrame.BackgroundTransparency=1 rainFrame.ClipsDescendants=true rainFrame.ZIndex=1
local rainCols={}
local RAIN_STR=""
for j=1,18 do RAIN_STR=RAIN_STR..(math.random()>0.5 and "1" or "0").."\n" end
for i=1,4 do
    local lbl=Instance.new("TextLabel",rainFrame)
    lbl.Size=UDim2.new(0,12,0,200) lbl.Position=UDim2.new(0,(i-1)*100,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=RAIN_STR lbl.Font=Enum.Font.Code lbl.TextSize=11
    lbl.TextColor3=G2 lbl.TextTransparency=0.92 lbl.TextYAlignment=Enum.TextYAlignment.Top lbl.ZIndex=1
    table.insert(rainCols,{lbl=lbl,offset=math.random()*200,speed=20+math.random()*40})
end

local hd=Instance.new("Frame",main)
hd.Size=UDim2.new(1,0,0,22) hd.BackgroundColor3=BG2 hd.BorderSizePixel=0 hd.ZIndex=110
Instance.new("UICorner",hd).CornerRadius=UDim.new(0,4)
local hdFix=Instance.new("Frame",hd)
hdFix.Size=UDim2.new(1,0,0,6) hdFix.Position=UDim2.new(0,0,1,-6)
hdFix.BackgroundColor3=BG2 hdFix.BorderSizePixel=0 hdFix.ZIndex=111

local title=Instance.new("TextLabel",hd)
title.Size=UDim2.new(1,-50,1,0) title.Position=UDim2.new(0,10,0,0)
title.BackgroundTransparency=1 title.Text="" title.Font=Enum.Font.Code title.TextSize=11
title.TextColor3=G title.TextXAlignment=Enum.TextXAlignment.Left title.ZIndex=112

local cursor=Instance.new("TextLabel",hd)
cursor.Size=UDim2.new(0,10,1,0) cursor.Position=UDim2.new(1,-46,0,0)
cursor.BackgroundTransparency=1 cursor.Text="█" cursor.Font=Enum.Font.Code cursor.TextSize=11
cursor.TextColor3=G cursor.ZIndex=112

local cl=Instance.new("TextButton",hd)
cl.Size=UDim2.new(0,20,0,20) cl.Position=UDim2.new(1,-24,.5,-10)
cl.BackgroundTransparency=1 cl.Text="✕" cl.Font=Enum.Font.Code cl.TextSize=13
cl.TextColor3=RED cl.AutoButtonColor=false cl.ZIndex=113

local sb=Instance.new("Frame",main)
sb.Size=UDim2.new(0,86,1,-52) sb.Position=UDim2.new(0,6,0,26)
sb.BackgroundTransparency=1 sb.BorderSizePixel=0 sb.ZIndex=110
local sbl=Instance.new("UIListLayout",sb)
sbl.Padding=UDim.new(0,2) sbl.SortOrder=Enum.SortOrder.LayoutOrder

local ct=Instance.new("Frame",main)
ct.Size=UDim2.new(1,-98,1,-52) ct.Position=UDim2.new(0,92,0,26)
ct.BackgroundColor3=BG2 ct.BackgroundTransparency=0.4 ct.BorderSizePixel=0 ct.ZIndex=110
Instance.new("UICorner",ct).CornerRadius=UDim.new(0,4)
local cstk=Instance.new("UIStroke",ct) cstk.Color=DIM cstk.Thickness=1

local stBar=Instance.new("Frame",main)
stBar.Size=UDim2.new(1,0,0,16) stBar.Position=UDim2.new(0,0,1,-16)
stBar.BackgroundColor3=BG2 stBar.BorderSizePixel=0 stBar.ZIndex=110
Instance.new("UICorner",stBar).CornerRadius=UDim.new(0,4)

local stLbl=Instance.new("TextLabel",stBar)
stLbl.Size=UDim2.new(1,-100,1,0) stLbl.Position=UDim2.new(0,8,0,0)
stLbl.BackgroundTransparency=1 stLbl.Text="[ OK ] ready"
stLbl.Font=Enum.Font.Code stLbl.TextSize=9 stLbl.TextColor3=G
stLbl.TextXAlignment=Enum.TextXAlignment.Left stLbl.ZIndex=111

local fpsLbl=Instance.new("TextLabel",stBar)
fpsLbl.Size=UDim2.new(0,80,1,0) fpsLbl.Position=UDim2.new(1,-88,0,0)
fpsLbl.BackgroundTransparency=1 fpsLbl.Text="-- FPS" fpsLbl.Font=Enum.Font.Code
fpsLbl.TextSize=9 fpsLbl.TextColor3=CY fpsLbl.TextXAlignment=Enum.TextXAlignment.Right fpsLbl.ZIndex=111

local dlgOverlay=Instance.new("Frame",sg)
dlgOverlay.Size=UDim2.new(1,0,1,0) dlgOverlay.BackgroundColor3=Color3.new(0,0,0)
dlgOverlay.BackgroundTransparency=.6 dlgOverlay.BorderSizePixel=0 dlgOverlay.Visible=false dlgOverlay.ZIndex=900
local dlg=Instance.new("Frame",sg)
dlg.Size=UDim2.new(0,340,0,380) dlg.Position=UDim2.new(.5,-170,.5,-190)
dlg.BackgroundColor3=BG dlg.BorderSizePixel=0 dlg.Visible=false dlg.Active=true dlg.ZIndex=901
Instance.new("UICorner",dlg).CornerRadius=UDim.new(0,4)
local dlgStk=Instance.new("UIStroke",dlg) dlgStk.Color=G dlgStk.Thickness=1.5
local dlgTitle=Instance.new("TextLabel",dlg)
dlgTitle.Size=UDim2.new(1,-20,0,28) dlgTitle.Position=UDim2.new(0,12,0,8)
dlgTitle.BackgroundTransparency=1 dlgTitle.Text="> OPTIONS" dlgTitle.Font=Enum.Font.Code
dlgTitle.TextSize=12 dlgTitle.TextColor3=G dlgTitle.TextXAlignment=Enum.TextXAlignment.Left dlgTitle.ZIndex=902
local dlgBody=Instance.new("ScrollingFrame",dlg)
dlgBody.Size=UDim2.new(1,-16,1,-52) dlgBody.Position=UDim2.new(0,8,0,38)
dlgBody.BackgroundTransparency=1 dlgBody.BorderSizePixel=0 dlgBody.ScrollBarThickness=2
dlgBody.ScrollBarImageColor3=G dlgBody.CanvasSize=UDim2.new(0,0,0,0)
dlgBody.AutomaticCanvasSize=Enum.AutomaticSize.Y dlgBody.ScrollingDirection=Enum.ScrollingDirection.Y dlgBody.ZIndex=902
local dlgLay=Instance.new("UIListLayout",dlgBody) dlgLay.Padding=UDim.new(0,4) dlgLay.SortOrder=Enum.SortOrder.LayoutOrder

local function dlgBtn(text,color,cb)
    local b=Instance.new("TextButton",dlgBody)
    b.Size=UDim2.new(1,-4,0,30) b.BackgroundColor3=BG2 b.BackgroundTransparency=0.3
    b.BorderSizePixel=0 b.Text="  > "..text b.Font=Enum.Font.Code
    b.TextSize=11 b.TextColor3=color b.TextXAlignment=Enum.TextXAlignment.Left b.AutoButtonColor=false
    b.LayoutOrder=#dlgBody:GetChildren()*10 b.ZIndex=903
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    local s=Instance.new("UIStroke",b) s.Color=DIM s.Thickness=1
    b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    return b
end
local function closeDlg()
    dlg.Visible=false dlgOverlay.Visible=false
    for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
end
dlgOverlay.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then closeDlg() end
end)

local tabs={"MOVE","ESP","COMBAT","PLAYER","TELE","INFO"}
local pages={} local tabBtns={}

local function switchTab(name)
    for n,p in pairs(pages) do p.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        if n==name then
            b.bg.BackgroundColor3=G b.bg.BackgroundTransparency=0.15
            b.txt.TextColor3=Color3.new(0,0,0) b.pfx.Text="> " b.pfx.TextColor3=Color3.new(0,0,0)
        else
            b.bg.BackgroundColor3=BG2 b.bg.BackgroundTransparency=0.5
            b.txt.TextColor3=G2 b.pfx.Text="  " b.pfx.TextColor3=G2
        end
    end
end

for _,n in ipairs(tabs) do
    local p=Instance.new("ScrollingFrame",ct)
    p.Size=UDim2.new(1,-8,1,-8) p.Position=UDim2.new(0,4,0,4)
    p.BackgroundTransparency=1 p.BorderSizePixel=0 p.ScrollBarThickness=2
    p.ScrollBarImageColor3=G p.CanvasSize=UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize=Enum.AutomaticSize.Y p.ScrollingDirection=Enum.ScrollingDirection.Y
    p.Visible=false p.ZIndex=111
    local l=Instance.new("UIListLayout",p) l.Padding=UDim.new(0,3) l.SortOrder=Enum.SortOrder.LayoutOrder
    pages[n]=p
end
for i,n in ipairs(tabs) do
    local b=Instance.new("TextButton",sb)
    b.Size=UDim2.new(1,0,0,22) b.BackgroundColor3=BG2 b.BackgroundTransparency=0.5
    b.BorderSizePixel=0 b.Text="" b.AutoButtonColor=false b.LayoutOrder=i b.ZIndex=111
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    local pfx=Instance.new("TextLabel",b)
    pfx.Size=UDim2.new(0,14,1,0) pfx.Position=UDim2.new(0,4,0,0)
    pfx.BackgroundTransparency=1 pfx.Text="  " pfx.Font=Enum.Font.Code pfx.TextSize=10
    pfx.TextColor3=G2 pfx.TextXAlignment=Enum.TextXAlignment.Left pfx.ZIndex=112
    local txt=Instance.new("TextLabel",b)
    txt.Size=UDim2.new(1,-20,1,0) txt.Position=UDim2.new(0,18,0,0)
    txt.BackgroundTransparency=1 txt.Text=n txt.Font=Enum.Font.Code txt.TextSize=10
    txt.TextColor3=G2 txt.TextXAlignment=Enum.TextXAlignment.Left txt.ZIndex=112
    b.MouseButton1Click:Connect(function() switchTab(n) end)
    tabBtns[n]={bg=b,txt=txt,pfx=pfx}
end

local function mkSec(parent,txt)
    local s=Instance.new("Frame",parent)
    s.Size=UDim2.new(1,-8,0,16) s.BackgroundTransparency=1
    s.LayoutOrder=#parent:GetChildren()*10
    local bar=Instance.new("Frame",s)
    bar.Size=UDim2.new(0,2,0,10) bar.Position=UDim2.new(0,4,.5,-5)
    bar.BackgroundColor3=CY bar.BorderSizePixel=0
    local l=Instance.new("TextLabel",s)
    l.Size=UDim2.new(1,-16,1,0) l.Position=UDim2.new(0,12,0,0)
    l.BackgroundTransparency=1 l.Text=txt l.Font=Enum.Font.Code l.TextSize=9
    l.TextColor3=CY l.TextXAlignment=Enum.TextXAlignment.Left
end
local function mkTog(parent,name,default,cb)
    local state=default or false
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,-8,0,22) row.BackgroundColor3=BG
    row.BackgroundTransparency=0.4 row.BorderSizePixel=0
    row.LayoutOrder=#parent:GetChildren()*10 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
    local lead=Instance.new("Frame",row)
    lead.Size=UDim2.new(0,2,0,10) lead.Position=UDim2.new(0,4,.5,-5)
    lead.BackgroundColor3=DIM lead.BorderSizePixel=0 lead.ZIndex=113
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-68,1,0) lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=name lbl.Font=Enum.Font.Code
    lbl.TextSize=9 lbl.TextColor3=TX lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=113
    local btn=Instance.new("TextButton",row)
    btn.Size=UDim2.new(0,44,0,16) btn.Position=UDim2.new(1,-48,.5,-8)
    btn.BackgroundColor3=BG2 btn.BorderSizePixel=0 btn.Text="[OFF]"
    btn.Font=Enum.Font.Code btn.TextSize=9 btn.TextColor3=DIM btn.AutoButtonColor=false btn.ZIndex=113
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,3)
    if state then btn.Text="[ON ]" btn.TextColor3=Color3.new(0,0,0) btn.BackgroundColor3=G lead.BackgroundColor3=G end
    btn.MouseButton1Click:Connect(function()
        state=not state
        if state then
            btn.Text="[ON ]" btn.TextColor3=Color3.new(0,0,0) btn.BackgroundColor3=G lead.BackgroundColor3=G
        else
            btn.Text="[OFF]" btn.TextColor3=DIM btn.BackgroundColor3=BG2 lead.BackgroundColor3=DIM
        end
        if cb then pcall(cb,state) end
    end)
    return btn
end
local function mkSli(parent,name,mn,mx,dv,cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,-8,0,32) row.BackgroundColor3=BG
    row.BackgroundTransparency=0.4 row.BorderSizePixel=0
    row.LayoutOrder=#parent:GetChildren()*10 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-12,0,12) lbl.Position=UDim2.new(0,8,0,3)
    lbl.BackgroundTransparency=1 lbl.Text=name.." ["..tostring(dv).."]"
    lbl.Font=Enum.Font.Code lbl.TextSize=9 lbl.TextColor3=TX
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=113
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-16,0,4) track.Position=UDim2.new(0,8,0,22)
    track.BackgroundColor3=DIM track.BorderSizePixel=0 track.ZIndex=113
    local pct=math.clamp((dv-mn)/(mx-mn),0,1)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0) fill.BackgroundColor3=G fill.BorderSizePixel=0 fill.ZIndex=114
    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,8,0,8) thumb.Position=UDim2.new(pct,-4,.5,-4)
    thumb.BackgroundColor3=G thumb.BorderSizePixel=0 thumb.ZIndex=115
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local hit=Instance.new("TextButton",row)
    hit.Size=UDim2.new(1,-16,0,20) hit.Position=UDim2.new(0,8,0,14)
    hit.BackgroundTransparency=1 hit.Text="" hit.ZIndex=116
    local drag=false
    local function up(x)
        local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        fill.Size=UDim2.new(p,0,1,0) thumb.Position=UDim2.new(p,-4,.5,-4)
        local v=mn+(mx-mn)*p
        if mx>=10 and math.floor(mx)==mx and math.floor(mn)==mn then v=math.floor(v+.5) else v=math.floor(v*10)/10 end
        lbl.Text=name.." ["..tostring(v).."]"
        if cb then pcall(cb,v) end
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true up(i.Position.X) end
    end)
    hit.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then up(i.Position.X) end
    end)
    hit.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
end
local function mkBtn(parent,name,cb)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,-8,0,22) b.BackgroundColor3=BG
    b.BackgroundTransparency=0.3 b.BorderSizePixel=0
    b.Text="  > "..name b.Font=Enum.Font.Code b.TextSize=10
    b.TextColor3=G b.TextXAlignment=Enum.TextXAlignment.Left b.AutoButtonColor=false
    b.LayoutOrder=#parent:GetChildren()*10 b.ZIndex=112
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    local s=Instance.new("UIStroke",b) s.Color=DIM s.Thickness=1
    b.MouseButton1Click:Connect(function()
        b.Text="  > [EXEC...]"
        task.wait(0.15)
        b.Text="  > "..name
        if cb then pcall(cb) end
    end)
    return b
end

local BASE_LIGHTING = {
    Brightness = L.Brightness, ClockTime = L.ClockTime,
    Ambient = L.Ambient, OutdoorAmbient = L.OutdoorAmbient,
    GlobalShadows = L.GlobalShadows,
    EnvironmentDiffuseScale = L.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = L.EnvironmentSpecularScale,
    ShadowSoftness = L.ShadowSoftness,
    FogEnd = L.FogEnd, FogStart = L.FogStart,
    ExposureCompensation = L.ExposureCompensation,
}
local function restoreLightingBase()
    pcall(function() for k, v in pairs(BASE_LIGHTING) do L[k] = v end end)
end
local function reapplyLighting()
    restoreLightingBase()
    if tg.fps then
        pcall(function()
            L.GlobalShadows = false
            L.EnvironmentDiffuseScale = 0
            L.EnvironmentSpecularScale = 0
            L.ShadowSoftness = 0
            L.FogEnd = 100000 L.FogStart = 100000
        end)
    end
    if tg.mapBright then
        pcall(function()
            L.Brightness = 3 L.ClockTime = 14
            L.Ambient = Color3.fromRGB(180,180,180)
            L.OutdoorAmbient = Color3.fromRGB(180,180,180)
            L.FogEnd = 100000 L.FogStart = 100000
            L.GlobalShadows = false
            L.ExposureCompensation = 0.5
        end)
    end
end

local fpsSaved = {active=false, gen=0, parts={}, effects={}, postFx={}, atmos={}, terrain={}, conns={}, qualityLevel=nil}
local fpsQueue = {}
local fpsQueueRunning = false

local function fpsKill(o)
    if not fpsSaved.active then return end
    pcall(function()
        if o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation") then
            if o.CastShadow then
                if not fpsSaved.parts[o] then fpsSaved.parts[o] = true end
                o.CastShadow = false
            end
        elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
            or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles")
            or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then
            if o.Enabled then
                if not fpsSaved.effects[o] then fpsSaved.effects[o] = true end
                o.Enabled = false
            end
        end
    end)
end

local function processFPSQueue()
    if fpsQueueRunning then return end
    fpsQueueRunning = true
    task.spawn(function()
        while fpsSaved.active and #fpsQueue > 0 do
            local batch = {}
            for i = 1, math.min(50, #fpsQueue) do
                table.insert(batch, table.remove(fpsQueue, 1))
            end
            for _, o in ipairs(batch) do
                if o and o.Parent then fpsKill(o) end
            end
            task.wait()
        end
        fpsQueueRunning = false
    end)
end

local function enableFPS()
    if fpsSaved.active then return end
    fpsSaved.active = true
    fpsSaved.gen = fpsSaved.gen + 1
    local myGen = fpsSaved.gen
    fpsSaved.parts = {} fpsSaved.effects = {} fpsSaved.postFx = {} fpsSaved.atmos = {} fpsSaved.conns = {}

    pcall(function()
        if settings and settings().Rendering then
            fpsSaved.qualityLevel = settings().Rendering.QualityLevel
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end
    end)
    pcall(function() if setfpscap then setfpscap(999) end end)
    reapplyLighting()

    for _, v in ipairs(L:GetChildren()) do
        pcall(function()
            if v:IsA("PostEffect") and v.Enabled then
                fpsSaved.postFx[v] = true v.Enabled = false
            elseif v:IsA("Atmosphere") then
                fpsSaved.atmos[v] = v.Density v.Density = 0
            end
        end)
    end
    pcall(function()
        local t = workspace:FindFirstChildOfClass("Terrain")
        if t then
            fpsSaved.terrain = {WaterWaveSize=t.WaterWaveSize, WaterReflectance=t.WaterReflectance, WaterTransparency=t.WaterTransparency}
            t.WaterWaveSize = 0 t.WaterReflectance = 0 t.WaterTransparency = 1
            pcall(function() t.Decoration = false end)
        end
    end)
    task.spawn(function()
        local all = workspace:GetDescendants()
        for i = 1, #all do
            if fpsSaved.gen ~= myGen or not fpsSaved.active then return end
            fpsKill(all[i])
            if i % 200 == 0 then task.wait() end
        end
    end)
    table.insert(fpsSaved.conns, workspace.DescendantAdded:Connect(function(o)
        if not fpsSaved.active then return end
        table.insert(fpsQueue, o) processFPSQueue()
    end))
    table.insert(fpsSaved.conns, L.DescendantAdded:Connect(function(o)
        if not fpsSaved.active then return end
        if o:IsA("PostEffect") then
            pcall(function() if o.Enabled then fpsSaved.postFx[o] = true o.Enabled = false end end)
        elseif o:IsA("Atmosphere") then
            pcall(function() if fpsSaved.atmos[o] == nil then fpsSaved.atmos[o] = o.Density end o.Density = 0 end)
        else fpsKill(o) end
    end))
end

local function disableFPS()
    if not fpsSaved.active then return end
    fpsSaved.active = false
    fpsSaved.gen = fpsSaved.gen + 1
    for _, c in ipairs(fpsSaved.conns) do pcall(function() c:Disconnect() end) end
    fpsSaved.conns = {}
    reapplyLighting()
    pcall(function()
        if settings and settings().Rendering and fpsSaved.qualityLevel then
            settings().Rendering.QualityLevel = fpsSaved.qualityLevel
        end
    end)
    pcall(function()
        local t = workspace:FindFirstChildOfClass("Terrain")
        if t then
            for k, v in pairs(fpsSaved.terrain) do t[k] = v end
            pcall(function() t.Decoration = true end)
        end
    end)
    fpsSaved.terrain = {}
    for fx in pairs(fpsSaved.postFx) do pcall(function() if fx and fx.Parent then fx.Enabled = true end end) end
    fpsSaved.postFx = {}
    for at, d in pairs(fpsSaved.atmos) do pcall(function() if at and at.Parent then at.Density = d end end) end
    fpsSaved.atmos = {}
    for fx in pairs(fpsSaved.effects) do pcall(function() if fx and fx.Parent then fx.Enabled = true end end) end
    fpsSaved.effects = {}
    for p in pairs(fpsSaved.parts) do pcall(function() if p and p.Parent then p.CastShadow = true end end) end
    fpsSaved.parts = {}
    pcall(function() if setfpscap then setfpscap(240) end end)
end

local function setFPS(on) if on then enableFPS() else disableFPS() end end

local mbPostFx = {} local mbAtmos = {}
local function setMapBright(on)
    if on then
        tg.mapBright = true
        reapplyLighting()
        mbPostFx = {} mbAtmos = {}
        for _, v in ipairs(L:GetChildren()) do
            pcall(function()
                if v:IsA("PostEffect") and v.Enabled then
                    mbPostFx[v] = true v.Enabled = false
                elseif v:IsA("Atmosphere") then
                    mbAtmos[v] = v.Density v.Density = 0
                end
            end)
        end
    else
        tg.mapBright = false
        reapplyLighting()
        for fx in pairs(mbPostFx) do
            pcall(function() if not tg.fps and fx and fx.Parent then fx.Enabled = true end end)
        end
        for at, d in pairs(mbAtmos) do
            pcall(function() if not tg.fps and at and at.Parent then at.Density = d end end)
        end
        mbPostFx = {} mbAtmos = {}
    end
end

-- ============ [FIX] TELEPORT - CHỐNG ANTI-TELE ==================
local teleportBusy = false
teleportTo = function(targetPos, opts)
    opts = opts or {}
    if teleportBusy and not opts.force then return false end
    local c = pl.Character
    if not c then return false end
    local hr = c:FindFirstChild("HumanoidRootPart")
    if not hr then return false end

    teleportBusy = true
    local startPos = hr.Position

    task.spawn(function()
        local dist = (targetPos - startPos).Magnitude
        local steps = math.clamp(math.ceil(dist / 40), 1, 15)
        local stepDelay = 0.035
        for i = 1, steps do
            if not hr or not hr.Parent then teleportBusy = false return end
            local alpha = i / steps
            local pos = startPos:Lerp(targetPos, alpha)
            hr.CFrame = CFrame.new(pos)
            hr.AssemblyLinearVelocity = Vector3.zero
            hr.AssemblyAngularVelocity = Vector3.zero
            task.wait(stepDelay)
        end
        if hr and hr.Parent then
            hr.CFrame = CFrame.new(targetPos)
            hr.AssemblyLinearVelocity = Vector3.zero
        end
        teleportBusy = false
    end)
    return true
end

local fallProtectUntil = 0
local fallLastHp = 0

local function setupNoFallDmg(char)
    local h = char:WaitForChild("Humanoid", 5)
    if not h then return end
    pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
    fallLastHp = h.Health
    h.HealthChanged:Connect(function(newHp)
        if newHp < fallLastHp and tick() < fallProtectUntil then
            h.Health = fallLastHp
            return
        end
        fallLastHp = h.Health
    end)
end

RS.Heartbeat:Connect(function()
    local c = pl.Character
    local hr = c and c:FindFirstChild("HumanoidRootPart")
    if not hr then return end
    if hr.AssemblyLinearVelocity.Y < -75 then
        fallProtectUntil = tick() + 2
    end
end)

-- ==================================================================
-- ============ [FIX] PRISON LIFE: VIOLATION DETECTION ==============
-- ==================================================================
-- Phát hiện tù nhân đang vi phạm (ra khỏi nhà tù / có súng / Wanted)
local PRISON_BOUNDS = {
    -- Vùng nhà tù chính của Prison Life (có thể tinh chỉnh nếu bản mod khác)
    center = Vector3.new(0, 0, 0),
    radius = 500, -- Bán kính vùng tù nhân được coi là "hợp lệ"
}

local function getPlayerRole(p)
    if not p or not p.Parent then return "none" end
    local teamName = p.Team and string.lower(p.Team.Name) or ""
    -- [FIX] Detect chính xác hơn theo Prison Life
    if teamName:find("guard") or teamName:find("police") or teamName:find("cop")
        or teamName:find("officer") or teamName:find("swat") or teamName:find("warden") then
        return "guard"
    end
    if teamName:find("criminal") or teamName:find("escape") or teamName:find("fugitive") then
        return "criminal"
    end
    if teamName:find("prison") or teamName:find("inmate") or teamName:find("convict") then
        return "prisoner"
    end
    -- Fallback dùng TeamColor
    if p.TeamColor then
        local c = p.TeamColor.Color
        if c.R > 0.5 and c.B > 0.5 then return "guard" end -- tím/xanh
        if c.R > 0.7 and c.G > 0.4 and c.B < 0.3 then return "prisoner" end -- cam
    end
    return "other"
end

-- [FIX] Phát hiện tù nhân vi phạm để cảnh sát aim
local function isViolatingPrisoner(p)
    if not p or not p.Character then return false end
    local char = p.Character
    
    -- 1) Kiểm tra attribute Wanted/Status (Prison Life có dùng)
    local attrs = {"Wanted", "WantedLevel", "Arrestable", "Status", "Hostile", "IsArrestable"}
    for _, a in ipairs(attrs) do
        local v = char:GetAttribute(a) or p:GetAttribute(a)
        if v then
            if type(v) == "boolean" and v then return true end
            if type(v) == "number" and v > 0 then return true end
            if type(v) == "string" and v ~= "" and v ~= "None" and v ~= "Innocent" then
                return true
            end
        end
    end
    
    -- 2) Tù nhân cầm vũ khí (súng) = vi phạm
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local n = string.lower(tool.Name)
        if n:find("gun") or n:find("pistol") or n:find("smg") or n:find("rifle")
            or n:find("shotgun") or n:find("weapon") or n:find("knife")
            or n:find("bat") or n:find("baton") then
            return true
        end
    end
    
    -- 3) Ra khỏi vùng nhà tù = vi phạm
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local pos = hrp.Position
        -- Nếu tù nhân đi ra khỏi vùng an toàn của nhà tù
        local distFromCenter = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(PRISON_BOUNDS.center.X, 0, PRISON_BOUNDS.center.Z)).Magnitude
        if distFromCenter > PRISON_BOUNDS.radius then
            return true
        end
        -- Hoặc nếu Y quá cao (leo tường) hoặc quá thấp (đào hầm)
        if pos.Y > 100 or pos.Y < -50 then
            return true
        end
    end
    
    -- 4) Kiểm tra GUI/TextLabel hiển thị trạng thái vi phạm
    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("TextLabel") or d:IsA("BillboardGui") then
            local txt = ""
            if d:IsA("TextLabel") then txt = d.Text else
                for _, sub in ipairs(d:GetDescendants()) do
                    if sub:IsA("TextLabel") then txt = txt.." "..sub.Text end
                end
            end
            local lt = string.lower(txt)
            if lt:find("wanted") or lt:find("arrest") or lt:find("hostile")
                or lt:find("escape") or lt:find("vi phạm") then
                return true
            end
        end
    end
    
    return false
end

-- [FIX] Địch để aim: cảnh sát chỉ aim tù nhân vi phạm, tù nhân aim cảnh sát
local function isEnemyForAim(p)
    if p == pl then return false end
    if not p.Character then return false end
    local h = p.Character:FindFirstChildOfClass("Humanoid")
    if not h or h.Health <= 0 then return false end

    local myRole = getPlayerRole(pl)
    local theirRole = getPlayerRole(p)

    if myRole == "guard" then
        -- [FIX] Chỉ aim tù nhân/criminal KHI họ vi phạm
        if theirRole == "prisoner" or theirRole == "criminal" then
            return isViolatingPrisoner(p)
        end
        return false
    elseif myRole == "prisoner" or myRole == "criminal" then
        -- Tù nhân/criminal aim cảnh sát (luôn hợp lệ)
        return theirRole == "guard"
    end

    -- Fallback: khác team
    if pl.Team and p.Team and pl.Team == p.Team then return false end
    return true
end

local function getAimPriority(p)
    local theirRole = getPlayerRole(p)
    if theirRole == "criminal" then return 1
    elseif theirRole == "prisoner" then return 2
    elseif theirRole == "guard" then return 2
    end
    return 3
end

-- ==================================================================
-- ============ [FIX] HITBOX - chạy nền nhưng an toàn hơn ===========
-- ==================================================================
local hitboxTick = 0
RS.Heartbeat:Connect(function(dt)
    if not hitboxOn then return end
    hitboxTick = hitboxTick + dt
    if hitboxTick < 0.02 then return end -- ~50Hz
    hitboxTick = 0

    local c = pl.Character
    local hrp = c and c:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, p in ipairs(P:GetPlayers()) do
        if p ~= pl and p.Character and isEnemyForAim(p) then
            local tHrp = p.Character:FindFirstChild("HumanoidRootPart")
            if tHrp then
                local d = (tHrp.Position - hrp.Position).Magnitude
                if d <= hitboxRange then
                    -- [FIX] Chỉ đánh vào Head + HRP để tránh spam
                    local head = p.Character:FindFirstChild("Head")
                    if head then
                        pcall(function()
                            firetouchinterest(hrp, head, 0)
                            firetouchinterest(hrp, head, 1)
                        end)
                    end
                    pcall(function()
                        firetouchinterest(hrp, tHrp, 0)
                        firetouchinterest(hrp, tHrp, 1)
                    end)
                end
            end
        end
    end
end)

-- ============ FORWARD DECLARE setNoclip ============
local setNoclip

local function onCharSpawn(char)
    local hr = char:WaitForChild("HumanoidRootPart", 10)
    local h = char:WaitForChild("Humanoid", 10)
    if not hr or not h then return end
    task.wait(0.4)
    if not hr.Parent then return end
    pcall(function() hr:SetNetworkOwner(pl) end)
    setupNoFallDmg(char)
    if tg.noclip then
        task.wait(0.2)
        if setNoclip then setNoclip(true) end
    end
end
pl.CharacterAdded:Connect(onCharSpawn)
if pl.Character then
    task.spawn(function()
        local hr = pl.Character:WaitForChild("HumanoidRootPart", 5)
        if hr then
            pcall(function() hr:SetNetworkOwner(pl) end)
            setupNoFallDmg(pl.Character)
        end
    end)
end

-- ==================================================================
-- ============ [FIX] ATTACK REMOTES - Quét kỹ hơn ==================
-- ==================================================================
local attackRemotes={}
local function scanAttackRemotes()
    local tmp={}
    local keywords={"attack","hit","damage","swing","slash","strike","punch","kick",
        "fire","shoot","melee","combat","weapon","sword","action","kill","click"}
    local function scanContainer(cont)
        for _,o in ipairs(cont:GetChildren()) do
            local ok2,isRemote=pcall(function() return o:IsA("RemoteEvent") or o:IsA("RemoteFunction") end)
            if ok2 and isRemote then
                local n=string.lower(o.Name)
                for _,k in ipairs(keywords) do
                    if n:find(k) then table.insert(tmp,{obj=o,isFunc=o:IsA("RemoteFunction")}) break end
                end
            end
        end
    end
    pcall(function() scanContainer(game:GetService("ReplicatedStorage")) end)
    pcall(function()
        local rs = game:GetService("ReplicatedStorage")
        local rem = rs:FindFirstChild("Remotes")
        if rem then scanContainer(rem) end
    end)
    local c=pl.Character
    if c then
        local tool=c:FindFirstChildOfClass("Tool")
        if tool then
            for _,o in ipairs(tool:GetDescendants()) do
                if o:IsA("RemoteEvent") then table.insert(tmp,{obj=o,isFunc=false})
                elseif o:IsA("RemoteFunction") then table.insert(tmp,{obj=o,isFunc=true}) end
            end
        end
    end
    attackRemotes=tmp
end
task.spawn(function() task.wait(2) scanAttackRemotes() end)
pl.CharacterAdded:Connect(function(c)
    task.wait(1) scanAttackRemotes()
    c.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.3) scanAttackRemotes() end end)
end)
if pl.Character then
    pl.Character.ChildAdded:Connect(function(ch) if ch:IsA("Tool") then task.wait(0.3) scanAttackRemotes() end end)
end

local function fireAttack()
    local c=pl.Character
    if not c then return end
    local tool=c:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    for _,r in ipairs(attackRemotes) do
        if r.obj and r.obj.Parent then
            pcall(function()
                if r.isFunc then r.obj:InvokeServer() else r.obj:FireServer() end
            end)
        end
    end
end

local function aaApplySpeed()
    local c=pl.Character if not c then return end
    for _,v in ipairs(c:GetDescendants()) do
        if v:IsA("NumberValue") then
            local n=string.lower(v.Name)
            if n:find("cooldown") or n:find("cd") or n:find("delay") or n:find("rate") or n:find("reload") then
                pcall(function() v.Value=0 end)
            end
        end
    end
    local tool=c:FindFirstChildOfClass("Tool")
    if tool then
        for _,v in ipairs(tool:GetDescendants()) do
            if v:IsA("NumberValue") then
                local n=string.lower(v.Name)
                if n:find("cooldown") or n:find("cd") or n:find("delay") or n:find("rate") then
                    pcall(function() v.Value=0 end)
                end
            end
        end
        pcall(function() tool.Enabled=true end)
    end
end
local function aaDisableAnims()
    local c=pl.Character if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid") if not h then return end
    local animator=h:FindFirstChildOfClass("Animator")
    if animator then
        for _,tr in ipairs(animator:GetPlayingAnimationTracks()) do
            pcall(function() tr:AdjustSpeed(4) end)
        end
    end
end
local aaAccum=0
RS.Heartbeat:Connect(function(dt)
    if not aa.enabled or not aa.target or not aa.target.Parent then aaAccum=0 return end
    local spd=aa.speed if spd<1 then spd=1 end
    aaAccum=aaAccum+spd*dt
    local count=math.floor(aaAccum)
    if count<1 then return end
    aaAccum=aaAccum-count
    for i=1,count do fireAttack() end
    aaDisableAnims()
    if aa.atkSpd then aaApplySpeed() end
end)

local aaLastTp = 0
RS.Heartbeat:Connect(function()
    if not aa.enabled or not aa.target or not aa.target.Parent then return end
    local tc = aa.target.Character if not tc then return end
    local thr = tc:FindFirstChild("HumanoidRootPart") if not thr then return end
    local c = pl.Character
    local hr = c and c:FindFirstChild("HumanoidRootPart") if not hr then return end

    local now = tick()
    if now - aaLastTp < 0.15 then return end

    local targetPos = thr.Position + Vector3.new(0, aa.hoverDist, 0)
    if (hr.Position - targetPos).Magnitude > 2 then
        pcall(function() hr:SetNetworkOwner(pl) end)
        hr.CFrame = CFrame.new(targetPos)
        hr.AssemblyLinearVelocity = Vector3.zero
        hr.AssemblyAngularVelocity = Vector3.zero
        aaLastTp = now
    end
end)

-- ============ FOV CIRCLE CHECK ============
local function isInFovCircle(worldPos)
    if not fovCircle.enabled then return true end
    local screenPos, onScreen = cam:WorldToViewportPoint(worldPos)
    if not onScreen then return false end
    local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
    local diff = Vector2.new(screenPos.X, screenPos.Y) - center
    return diff.Magnitude <= fovCircle.radius
end

-- ============ FIND AIM TARGET - ƯU TIÊN HEAD ============
local function findAimTarget()
    local camPos = cam.CFrame.Position
    local camLook = cam.CFrame.LookVector
    local bestTarget, bestScore = nil, math.huge

    for _, p in ipairs(P:GetPlayers()) do
        if isEnemyForAim(p) then
            local head = p.Character:FindFirstChild("Head")
            if head and isInFovCircle(head.Position) then
                local dir = head.Position - camPos
                local dist = dir.Magnitude
                if dist > 0.5 and dist < 1500 then
                    local dot = math.clamp(camLook.Unit:Dot(dir.Unit), -1, 1)
                    local angle = math.deg(math.acos(dot))
                    local priority = getAimPriority(p)
                    local score = angle * 10 + priority * 200 + dist * 0.1
                    if score < bestScore then
                        bestScore = score
                        bestTarget = {part = head, player = p}
                    end
                end
            end
        end
    end
    return bestTarget
end

-- ==================================================================
-- ============ [FIX] SILENT AIM 100% HIT ===========================
-- ==================================================================
-- Ghi đè Mouse.Hit / Mouse.Target để đạn luôn bay vào mục tiêu
local mouse = pl:GetMouse()
local mouseMT = getrawmetatable and getrawmetatable(mouse)
local origMouseIndex
if mouseMT and setreadonly then
    origMouseIndex = mouseMT.__index
    pcall(function()
        setreadonly(mouseMT, false)
        mouseMT.__index = newcclosure(function(t, k)
            if aim.enabled and aim.target and aim.target.Character then
                local tgtHead = aim.target.Character:FindFirstChild("Head")
                if tgtHead and tgtHead.Parent then
                    if k == "Hit" then
                        return CFrame.new(tgtHead.Position)
                    elseif k == "Target" then
                        return tgtHead
                    end
                end
            end
            if type(origMouseIndex) == "function" then
                return origMouseIndex(t, k)
            else
                return mouse[k]
            end
        end)
        setreadonly(mouseMT, true)
    end)
end

-- Hook __namecall để redirect argument vị trí khi gun bắn
local mt = getrawmetatable and getrawmetatable(game)
if mt and setreadonly and hookmetamethod then
    pcall(function()
        local oldNamecall = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod and getnamecallmethod() or ""
            if aim.enabled and aim.target and aim.target.Character then
                -- Nếu là FireServer/InvokeServer tới remote liên quan đến bắn
                if method == "FireServer" or method == "InvokeServer" then
                    local selfName = type(self) == "Instance" and self.Name or ""
                    local n = string.lower(selfName)
                    if n:find("gun") or n:find("fire") or n:find("shoot")
                        or n:find("click") or n:find("attack") or n:find("hit") then
                        local tgtHead = aim.target.Character and aim.target.Character:FindFirstChild("Head")
                        if tgtHead and tgtHead.Parent then
                            -- Thay thế argument Vector3/CFrame nào gần nhất bằng target
                            local args = {...}
                            for i, a in ipairs(args) do
                                if typeof(a) == "Vector3" then
                                    args[i] = tgtHead.Position
                                elseif typeof(a) == "CFrame" then
                                    args[i] = CFrame.new(tgtHead.Position)
                                end
                            end
                            return oldNamecall(self, table.unpack(args))
                        end
                    end
                end
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

-- ==================================================================
-- ============ [FIX] AIMLOCK - SNAP + BÙ PING + SILENT =============
-- ==================================================================
pcall(function()
    RS:UnbindFromRenderStep("NekoAimlock")
end)
RS:BindToRenderStep("NekoAimlock", Enum.RenderPriority.Camera.Value + 1, function(dt)
    if not aim.enabled then
        aim.target = nil
        return
    end

    local found = findAimTarget()
    if not found or not found.part or not found.part.Parent then
        aim.target = nil
        return
    end
    aim.target = found.player

    local head = found.part
    local char = found.player.Character
    if not char then return end
    local hr = char:FindFirstChild("HumanoidRootPart")

    local camPos = cam.CFrame.Position
    local aimPos = head.Position

    -- [FIX] Bù ping để aim chính xác
    if hr then
        local ping = pl:GetNetworkPing()
        local comp = ping * 1.5 + 0.03
        aimPos = aimPos + hr.AssemblyLinearVelocity * comp
    end

    cam.CFrame = CFrame.lookAt(camPos, aimPos)
end)

-- ============ FOV CIRCLE RENDER ============
local drawingOK = (Drawing ~= nil and Drawing.new ~= nil)
if drawingOK then
    pcall(function()
        fovCircle.drawing = Drawing.new("Circle")
        fovCircle.drawing.Thickness = 1.5
        fovCircle.drawing.NumSides = 60
        fovCircle.drawing.Filled = false
        fovCircle.drawing.Transparency = 1
        fovCircle.drawing.Color = Color3.fromRGB(0, 255, 120)
        fovCircle.drawing.Visible = false
    end)
end

RS.RenderStepped:Connect(function(dt)
    if not drawingOK or not fovCircle.drawing then return end
    pcall(function()
        if not fovCircle.enabled then
            fovCircle.drawing.Visible = false
            return
        end
        local center = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)
        fovCircle.drawing.Position = center
        fovCircle.drawing.Radius = fovCircle.radius
        fovCircle.drawing.Visible = true
    end)
end)

-- ============ ESP PLAYER ============
local evs={} local trcs={}
local function measureBody(char)
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head")
    if not hrp or not head then return nil end
    local topY=head.Position.Y+head.Size.Y/2
    local bottomY
    local rl=char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("RightFoot")
    if rl then bottomY=rl.Position.Y-rl.Size.Y/2 else bottomY=hrp.Position.Y-2.8 end
    return {center=(topY+bottomY)/2-hrp.Position.Y,height=topY-bottomY,width=2.4}
end

local function buildESP(char)
    if not char or char==pl.Character then return end
    if evs[char] then return end
    local hr=char:FindFirstChild("HumanoidRootPart")
    local head=char:FindFirstChild("Head") or hr
    if not hr or not head then return end

    local fold=Instance.new("Folder",epf) fold.Name=char.Name
    local hl=Instance.new("Highlight",fold)
    hl.Adornee=char hl.FillColor=G hl.FillTransparency=0.9 hl.OutlineColor=G hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Enabled=tg.espBody

    local infoBB=Instance.new("BillboardGui",fold)
    infoBB.Adornee=head infoBB.Size=UDim2.new(0,220,0,50) infoBB.StudsOffset=Vector3.new(0,2.8,0)
    infoBB.AlwaysOnTop=true infoBB.LightInfluence=0 infoBB.MaxDistance=5000
    infoBB.Enabled=(tg.espName or tg.espDist)

    local nameLbl=Instance.new("TextLabel",infoBB)
    nameLbl.Size=UDim2.new(1,0,0,30) nameLbl.BackgroundTransparency=1 nameLbl.Text=char.Name
    nameLbl.TextColor3=G nameLbl.TextStrokeTransparency=0.1 nameLbl.TextStrokeColor3=Color3.new(0,0,0)
    nameLbl.Font=Enum.Font.Code nameLbl.TextSize=20 nameLbl.TextXAlignment=Enum.TextXAlignment.Center
    nameLbl.Visible=tg.espName

    local distLbl=Instance.new("TextLabel",infoBB)
    distLbl.Size=UDim2.new(1,0,0,18) distLbl.Position=UDim2.new(0,0,0,30)
    distLbl.BackgroundTransparency=1 distLbl.Text="0m" distLbl.TextColor3=YEL
    distLbl.TextStrokeTransparency=0.2 distLbl.TextStrokeColor3=Color3.new(0,0,0)
    distLbl.Font=Enum.Font.Code distLbl.TextSize=14 distLbl.TextXAlignment=Enum.TextXAlignment.Center
    distLbl.Visible=tg.espDist

    local hpBB=Instance.new("BillboardGui",fold)
    hpBB.Adornee=hr hpBB.Size=UDim2.new(0,6,0,40) hpBB.StudsOffset=Vector3.new(1.4,0.3,0)
    hpBB.AlwaysOnTop=true hpBB.LightInfluence=0 hpBB.MaxDistance=5000
    hpBB.Enabled=tg.espHp

    local hpBg=Instance.new("Frame",hpBB)
    hpBg.Size=UDim2.new(1,0,1,0) hpBg.BackgroundColor3=Color3.fromRGB(0,20,10)
    hpBg.BackgroundTransparency=0.2 hpBg.BorderSizePixel=1 hpBg.BorderColor3=G
    Instance.new("UICorner",hpBg).CornerRadius=UDim.new(0,2)
    local hpFill=Instance.new("Frame",hpBg)
    hpFill.AnchorPoint=Vector2.new(0,1) hpFill.Position=UDim2.new(0,0,1,0)
    hpFill.Size=UDim2.new(1,0,1,0) hpFill.BackgroundColor3=G hpFill.BorderSizePixel=0
    Instance.new("UICorner",hpFill).CornerRadius=UDim.new(0,2)

    local m=measureBody(char)
    local fxBB=Instance.new("BillboardGui",fold)
    fxBB.Adornee=hr fxBB.Size=UDim2.new(0,60,0,140)
    fxBB.StudsOffset=m and Vector3.new(0,m.center,0) or Vector3.new(0,0.3,0)
    fxBB.AlwaysOnTop=true fxBB.LightInfluence=0 fxBB.MaxDistance=1500 fxBB.ClipsDescendants=true
    fxBB.Enabled=tg.espBody

    local scans={}
    for i=1,4 do
        local s=Instance.new("Frame",fxBB)
        s.Size=UDim2.new(1,0,0,i<=2 and 2 or 1) s.BackgroundColor3=i%2==0 and G3 or G
        s.BackgroundTransparency=i<=2 and 0 or 0.4 s.BorderSizePixel=0
        local gr=Instance.new("UIGradient",s)
        gr.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)})
        table.insert(scans,{obj=s,speed=0.3+i*0.1,offset=math.random(),dir=(i%2==0) and 1 or -1})
    end
    local dots={}
    for i=1,5 do
        local d=Instance.new("Frame",fxBB)
        local sz=math.random(2,3)
        d.Size=UDim2.new(0,sz,0,sz) d.BackgroundColor3=G3 d.BackgroundTransparency=0.3 d.BorderSizePixel=0
        Instance.new("UICorner",d).CornerRadius=UDim.new(1,0)
        table.insert(dots,{obj=d,x=math.random(),y=math.random(),speed=0.15+math.random()*0.25,dir=math.random()>0.5 and 1 or -1})
    end
    local ring=Instance.new("Frame",fxBB)
    ring.AnchorPoint=Vector2.new(.5,.5) ring.Position=UDim2.new(.5,0,.5,0)
    ring.Size=UDim2.new(0,20,0,20) ring.BackgroundTransparency=1 ring.BorderSizePixel=0
    local ringStroke=Instance.new("UIStroke",ring) ringStroke.Color=G3 ringStroke.Thickness=1.5 ringStroke.Transparency=.3
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
    local dataTop=Instance.new("TextLabel",fxBB)
    dataTop.Size=UDim2.new(1,0,0,10) dataTop.Position=UDim2.new(0,0,0,-12)
    dataTop.BackgroundTransparency=1 dataTop.Text=""
    dataTop.TextColor3=G dataTop.TextStrokeTransparency=.4 dataTop.TextStrokeColor3=Color3.new(0,0,0)
    dataTop.Font=Enum.Font.Code dataTop.TextSize=8 dataTop.TextXAlignment=Enum.TextXAlignment.Center

    evs[char]={folder=fold,hl=hl,infoBB=infoBB,nameLbl=nameLbl,distLbl=distLbl,hpBB=hpBB,hpFill=hpFill,
               fxBB=fxBB,scans=scans,dots=dots,ring=ring,ringStroke=ringStroke,dataTop=dataTop,
               _mCache=nil, _mFrame=0}
end

local function destroyESP(char)
    if evs[char] then pcall(function() evs[char].folder:Destroy() end) evs[char]=nil end
end
local function applyESPToggles()
    for char,data in pairs(evs) do
        if char.Parent then
            data.nameLbl.Visible=tg.espName
            data.distLbl.Visible=tg.espDist
            data.hpBB.Enabled=tg.espHp
            data.fxBB.Enabled=tg.espBody
            data.hl.Enabled=tg.espBody
            data.infoBB.Enabled=(tg.espName or tg.espDist)
        else destroyESP(char) end
    end
end

task.spawn(function()
    while true do
        task.wait(2)
        if tg.espName or tg.espHp or tg.espDist or tg.espBody or tg.espLine then
            local c = pl.Character
            local hr = c and c:FindFirstChild("HumanoidRootPart")
            if hr then
                for _,p in ipairs(P:GetPlayers()) do
                    if p~=pl and p.Character and not evs[p.Character] then
                        if p.Character:FindFirstChild("HumanoidRootPart") then
                            buildESP(p.Character)
                        end
                    end
                end
            end
        end
    end
end)

local noclipSaved = {}
local noclipConn = nil
local function noclipApply(part)
    if not part:IsA("BasePart") then return end
    if noclipSaved[part] == nil then noclipSaved[part] = part.CanCollide end
    part.CanCollide = false
end
setNoclip = function(on)
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    local c = pl.Character
    if on then
        for part, orig in pairs(noclipSaved) do
            pcall(function() if part and part.Parent then part.CanCollide = orig end end)
        end
        noclipSaved = {}
        if c then
            for _, p in ipairs(c:GetDescendants()) do noclipApply(p) end
            noclipConn = c.DescendantAdded:Connect(noclipApply)
        end
    else
        for part, orig in pairs(noclipSaved) do
            pcall(function() if part and part.Parent then part.CanCollide = orig end end)
        end
        noclipSaved = {}
    end
end

task.spawn(function()
    while true do
        task.wait(0.05)
        if tg.noclip then
            local c = pl.Character
            if c then
                for _, p in ipairs(c:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        p.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- ==================================================================
-- ============ [FIX] FAST FIRE + NO RELOAD =========================
-- ==================================================================
-- Sửa: Đặt cooldown về 0, set ammo đầy, gọi Activate với delay hợp lý
-- Tránh spam quá nhanh gây flag anti-cheat
local extras = { fastFire = false, noReload = false }
local lastFF = 0
local FF_DELAY = 0.05 -- ~20 lần/giây

RS.Heartbeat:Connect(function()
    if not (extras.fastFire or extras.noReload) then return end
    local c = pl.Character
    if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if not tool then return end

    -- Quét cả NumberValue, IntValue, StringValue chứa số
    for _, v in ipairs(tool:GetDescendants()) do
        local n = string.lower(v.Name)
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            if extras.fastFire then
                if n:find("cooldown") or n:find("firerate") or n:find("firedelay")
                   or n:find("rate") or n:find("delay") or n:find("cd")
                   or n:find("reload") or n:find("fire") then
                    pcall(function() v.Value = 0 end)
                end
            end
            if extras.noReload then
                if n:find("reload") or n:find("ammo") or n:find("clip") or n:find("mag") then
                    pcall(function()
                        if n:find("max") then v.Value = 9999
                        else v.Value = 9999 end
                    end)
                end
            end
        end
    end

    -- [FIX] Fast Fire thực sự: gọi Activate liên tục với rate-limit
    if extras.fastFire then
        local now = tick()
        if now - lastFF >= FF_DELAY then
            lastFF = now
            pcall(function() tool:Activate() end)
            -- Gọi remote bắn (nếu tìm được)
            for _, r in ipairs(attackRemotes) do
                if r.obj and r.obj.Parent then
                    pcall(function()
                        if r.isFunc then r.obj:InvokeServer()
                        else r.obj:FireServer() end
                    end)
                end
            end
        end
    end
end)

-- ==================================================================
-- ============ ANTI-KICK + ANTI-BAN ================================
-- ==================================================================
local antiKickOn = false
local antiBanOn  = false
local SAFE_JOBID   = game.JobId
local SAFE_PLACEID = game.PlaceId
local lastRejoin   = 0

local kickHooked = false
local function setupKickHook()
    if kickHooked then return end
    if not (getrawmetatable and setreadonly and newcclosure and getnamecallmethod) then
        stLbl.Text="[!] Executor không hỗ trợ anti-kick"
        stLbl.TextColor3=YEL
        return
    end
    local okHook = pcall(function()
        local mt = getrawmetatable(game)
        local oldNC = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            if antiKickOn and self == pl and getnamecallmethod() == "Kick" then
                return
            end
            return oldNC(self, ...)
        end)
        setreadonly(mt, true)
    end)
    kickHooked = okHook
end

pl.AncestryChanged:Connect(function(_, parent)
    if parent then return end
    if not antiBanOn then return end
    if tick() - lastRejoin < 10 then return end
    if SAFE_JOBID == "" or SAFE_PLACEID == 0 then return end
    lastRejoin = tick()
    task.spawn(function()
        pcall(function()
            TS:TeleportToPlaceInstance(SAFE_PLACEID, SAFE_JOBID, pl)
        end)
    end)
end)

-- ============ POPULATE UI ============
mkSec(pages["MOVE"],"// SPEED")
mkSli(pages["MOVE"],"Walk Speed",16,500,16,function(v) stt.ws=v end)
mkSec(pages["MOVE"],"// JUMP")
mkSli(pages["MOVE"],"Jump Power",50,300,50,function(v) stt.jp=v end)
mkTog(pages["MOVE"],"INFINITE JUMP",false,function(on) tg.infJump=on end)

mkSec(pages["ESP"],"// PLAYER ESP")
mkTog(pages["ESP"],"ESP LINE (RAINBOW)",false,function(on) tg.espLine=on end)
mkTog(pages["ESP"],"ESP NAME",false,function(on) tg.espName=on applyESPToggles() end)
mkTog(pages["ESP"],"ESP HEALTH",false,function(on) tg.espHp=on applyESPToggles() end)
mkTog(pages["ESP"],"ESP DISTANCE",false,function(on) tg.espDist=on applyESPToggles() end)
mkTog(pages["ESP"],"ESP BODY FX",false,function(on) tg.espBody=on applyESPToggles() end)

mkSec(pages["COMBAT"],"// AUTO ATTACK")
local aaTargetBtn=mkBtn(pages["COMBAT"],"TARGET: (none)",function() end)
local function openTargetPicker()
    dlgTitle.Text="> SELECT TARGET PLAYER"
    for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=pl then
            dlgBtn(p.Name, G, function()
                aa.target=p aaTargetBtn.Text="  > TARGET: "..p.Name closeDlg()
            end)
        end
    end
    dlgBtn("CANCEL",RED,function() closeDlg() end)
    dlg.Visible=true dlgOverlay.Visible=true
end
aaTargetBtn.MouseButton1Click:Connect(function() openTargetPicker() end)
mkTog(pages["COMBAT"],"AUTO ATTACK",false,function(on)
    if on and not aa.target then aaTargetBtn.Text="  > TARGET: chon truoc!" return end
    aa.enabled=on aa.atkSpd=on aa.hoverOn=on
    if on then aaLastTp = 0 end
end)

mkSec(pages["COMBAT"],"// WEAPON BUFF")
mkTog(pages["COMBAT"],"FAST FIRE [FIX]",false,function(on)
    extras.fastFire = on
    if on then
        stLbl.Text="[ OK ] Fast Fire ON (20/s)"
        stLbl.TextColor3=G
    end
end)
mkTog(pages["COMBAT"],"NO RELOAD [FIX]",false,function(on)
    extras.noReload = on
    if on then
        stLbl.Text="[ OK ] No Reload ON"
        stLbl.TextColor3=G
    end
end)

mkSec(pages["COMBAT"],"// HITBOX (chạy nền)")
mkTog(pages["COMBAT"],"HITBOX EXPAND [FIX]",true,function(on) hitboxOn = on end)

mkSec(pages["COMBAT"],"// FOV CIRCLE")
mkTog(pages["COMBAT"],"BẬT VÒNG FOV",false,function(on) fovCircle.enabled = on end)
mkSli(pages["COMBAT"],"FOV Size",50,400,150,function(v) fovCircle.radius = v end)

mkSec(pages["COMBAT"],"// AIMLOCK [FIX - GUARD MODE]")
mkTog(pages["COMBAT"],"AIMLOCK (chỉ địch hợp lệ)",false,function(on)
    aim.enabled = on
    aim.smooth = 1
    if on then
        local role = getPlayerRole(pl)
        local hint = ""
        if role == "guard" then hint = " (chỉ tù vi phạm)"
        elseif role == "prisoner" or role == "criminal" then hint = " (chỉ cảnh sát)" end
        stLbl.Text = "[ OK ] Aimlock ON"..hint
        stLbl.TextColor3 = G
    else
        stLbl.Text = "[ OK ] Aimlock: OFF"
        stLbl.TextColor3 = DIM
    end
end)
mkTog(pages["COMBAT"],"SILENT AIM (đạn 100% trúng)",true,function(on) aim.silent = on end)

mkSec(pages["PLAYER"],"// PERFORMANCE")
mkTog(pages["PLAYER"],"FPS BOOST",false,function(on) tg.fps=on setFPS(on) end)
mkTog(pages["PLAYER"],"MAP BRIGHT",false,function(on) tg.mapBright=on setMapBright(on) end)
mkSec(pages["PLAYER"],"// SURVIVAL")
mkTog(pages["PLAYER"],"NOCLIP (SMOOTH)",false,function(on) tg.noclip=on setNoclip(on) end)
mkTog(pages["PLAYER"],"ANTI-KICK",false,function(on)
    antiKickOn = on
    if on then setupKickHook() end
end)
mkTog(pages["PLAYER"],"ANTI-BAN (auto rejoin)",false,function(on) antiBanOn = on end)
mkSec(pages["PLAYER"],"// CAMERA")
mkSli(pages["PLAYER"],"FOV",70,120,70,function(v) cam.FieldOfView=v end)
mkSec(pages["PLAYER"],"// UTILITIES")
mkBtn(pages["PLAYER"],"RESET CHARACTER",function()
    local c=pl.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Health=0 end end
end)
mkBtn(pages["PLAYER"],"REJOIN SERVER",function()
    pcall(function() TS:TeleportToPlaceInstance(game.PlaceId,game.JobId,pl) end)
end)

mkSec(pages["TELE"],"// TELEPORT TO PLAYER")
local tpTargetBtn=mkBtn(pages["TELE"],"SELECT PLAYER",function() end)
local tpSelected=nil
local function openTpPicker()
    dlgTitle.Text="> SELECT PLAYER"
    for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=pl then
            dlgBtn(p.Name,G,function()
                tpSelected=p tpTargetBtn.Text="  > "..p.Name closeDlg()
            end)
        end
    end
    dlgBtn("CANCEL",RED,function() closeDlg() end)
    dlg.Visible=true dlgOverlay.Visible=true
end
tpTargetBtn.MouseButton1Click:Connect(function() openTpPicker() end)
local tpCD=false
mkBtn(pages["TELE"],"TELEPORT TO PLAYER",function()
    if not tpSelected or tpCD then return end
    local c=pl.Character
    local hr=c and c:FindFirstChild("HumanoidRootPart") if not hr then return end
    local th=tpSelected.Character and tpSelected.Character:FindFirstChild("HumanoidRootPart")
    if not th then return end
    tpCD=true
    teleportTo(th.Position+Vector3.new(0,4,0))
    task.wait(1)
    tpCD=false
end)

mkSec(pages["TELE"],"// WAYPOINTS (8 SLOT)")
mkSli(pages["TELE"],"WP Height",0,20,wpHeight,function(v) wpHeight=v saveWPs() end)

local wpRows = {}
local function buildWPRow(index)
    local row = Instance.new("Frame",pages["TELE"])
    row.Size = UDim2.new(1,-8,0,26)
    row.BackgroundColor3 = BG
    row.BackgroundTransparency = 0.3
    row.BorderSizePixel = 0
    row.LayoutOrder = #pages["TELE"]:GetChildren()*10
    row.ZIndex = 112
    Instance.new("UICorner",row).CornerRadius = UDim.new(0,3)

    local badge = Instance.new("TextLabel",row)
    badge.Size = UDim2.new(0,24,1,0)
    badge.Position = UDim2.new(0,4,0,0)
    badge.BackgroundTransparency = 1
    badge.Text = "#"..index
    badge.Font = Enum.Font.Code
    badge.TextSize = 10
    badge.TextColor3 = CY
    badge.TextXAlignment = Enum.TextXAlignment.Left
    badge.ZIndex = 113

    local info = Instance.new("TextLabel",row)
    info.Size = UDim2.new(1,-140,1,0)
    info.Position = UDim2.new(0,30,0,0)
    info.BackgroundTransparency = 1
    info.Text = "EMPTY"
    info.Font = Enum.Font.Code
    info.TextSize = 9
    info.TextColor3 = DIM
    info.TextXAlignment = Enum.TextXAlignment.Left
    info.ZIndex = 113

    local function mkMiniBtn(xOffset, text, color, cb)
        local b = Instance.new("TextButton",row)
        b.Size = UDim2.new(0,30,0,18)
        b.Position = UDim2.new(1,xOffset,0.5,-9)
        b.BackgroundColor3 = BG2
        b.BorderSizePixel = 0
        b.Text = text
        b.Font = Enum.Font.Code
        b.TextSize = 8
        b.TextColor3 = color
        b.AutoButtonColor = false
        b.ZIndex = 113
        Instance.new("UICorner",b).CornerRadius = UDim.new(0,2)
        b.MouseButton1Click:Connect(function()
            b.Text = "..."
            task.wait(0.1)
            b.Text = text
            if cb then pcall(cb) end
        end)
        return b
    end

    mkMiniBtn(-102,"SET",G,function()
        local c = pl.Character
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        if hr then
            wps[index] = {hr.CFrame:GetComponents()}
            saveWPs()
            info.Text = "READY"
            info.TextColor3 = G
        end
    end)
    mkMiniBtn(-68,"GO",CY,function()
        if wps[index] then
            local sc = cfFromArr(wps[index])
            if sc then
                teleportTo(sc.Position + Vector3.new(0,wpHeight,0))
                stLbl.Text = "[ OK ] Teleport #"..index
                stLbl.TextColor3 = G
            end
        else
            stLbl.Text = "[ ! ] Slot "..index.." trống"
            stLbl.TextColor3 = YEL
        end
    end)
    mkMiniBtn(-34,"✕",RED,function()
        wps[index] = nil
        saveWPs()
        info.Text = "EMPTY"
        info.TextColor3 = DIM
    end)

    if wps[index] then
        info.Text = "READY"
        info.TextColor3 = G
    end
    wpRows[index] = {row=row, info=info}
end
for i=1,8 do buildWPRow(i) end

task.spawn(function()
    while true do
        task.wait(2)
        local c = pl.Character
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        local myPos = hr and hr.Position
        if myPos then
            for i=1,8 do
                local r = wpRows[i]
                if r and wps[i] then
                    local sc = cfFromArr(wps[i])
                    if sc then
                        local d = (sc.Position - myPos).Magnitude / 3.57
                        r.info.Text = string.format("READY (%.0fm)", d)
                    end
                end
            end
        end
    end
end)

local infoRoot=Instance.new("Frame",pages["INFO"])
infoRoot.Size=UDim2.new(1,-8,0,0)
infoRoot.AutomaticSize=Enum.AutomaticSize.Y
infoRoot.BackgroundTransparency=1 infoRoot.LayoutOrder=10 infoRoot.ZIndex=115
local irl=Instance.new("UIListLayout",infoRoot)
irl.Padding=UDim.new(0,6) irl.SortOrder=Enum.SortOrder.LayoutOrder
local infoRefs={}
local function makeCard(title,accent)
    local card=Instance.new("Frame",infoRoot)
    card.Size=UDim2.new(1,0,0,0) card.AutomaticSize=Enum.AutomaticSize.Y
    card.BackgroundColor3=BG card.BackgroundTransparency=0.35 card.BorderSizePixel=0 card.ZIndex=116
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,4)
    local cs=Instance.new("UIStroke",card) cs.Color=accent cs.Thickness=1 cs.Transparency=0.5
    local titleBar=Instance.new("Frame",card)
    titleBar.Size=UDim2.new(1,0,0,20) titleBar.BackgroundColor3=BG2
    titleBar.BackgroundTransparency=0.3 titleBar.BorderSizePixel=0 titleBar.ZIndex=117
    Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,4)
    local bar=Instance.new("Frame",titleBar)
    bar.Size=UDim2.new(0,2,0,10) bar.Position=UDim2.new(0,6,.5,-5)
    bar.BackgroundColor3=accent bar.BorderSizePixel=0 bar.ZIndex=118
    local tl=Instance.new("TextLabel",titleBar)
    tl.Size=UDim2.new(1,-14,1,0) tl.Position=UDim2.new(0,14,0,0)
    tl.BackgroundTransparency=1 tl.Text=title tl.Font=Enum.Font.Code
    tl.TextSize=10 tl.TextColor3=accent tl.TextXAlignment=Enum.TextXAlignment.Left tl.ZIndex=118
    local body=Instance.new("Frame",card)
    body.Size=UDim2.new(1,-12,0,0) body.Position=UDim2.new(0,6,0,24)
    body.AutomaticSize=Enum.AutomaticSize.Y body.BackgroundTransparency=1 body.ZIndex=117
    local bl=Instance.new("UIListLayout",body)
    bl.Padding=UDim.new(0,3) bl.SortOrder=Enum.SortOrder.LayoutOrder
    local function row(name,color)
        local r=Instance.new("Frame",body)
        r.Size=UDim2.new(1,0,0,14) r.BackgroundTransparency=1 r.ZIndex=118
        local l=Instance.new("TextLabel",r)
        l.Size=UDim2.new(0.5,0,1,0) l.BackgroundTransparency=1 l.Text=name
        l.Font=Enum.Font.Code l.TextSize=9 l.TextColor3=DIM l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=119
        local v=Instance.new("TextLabel",r)
        v.Size=UDim2.new(0.5,0,1,0) v.Position=UDim2.new(0.5,0,0,0) v.BackgroundTransparency=1
        v.Text="--" v.Font=Enum.Font.Code v.TextSize=10 v.TextColor3=color or G
        v.TextXAlignment=Enum.TextXAlignment.Right v.ZIndex=119
        return v
    end
    return row
end
local netRow=makeCard("NETWORK",CY)
infoRefs.ping=netRow("PING",G)
infoRefs.pStat=netRow("STATUS",G)
local perfRow=makeCard("PERFORMANCE",G)
infoRefs.fps=perfRow("FPS",CY)
infoRefs.fpsAvg=perfRow("FPS AVG",CY)
infoRefs.mem=perfRow("MEMORY",CY)
infoRefs.uptime=perfRow("UPTIME",CY)
local pRow=makeCard("PLAYER",YEL)
infoRefs.name=pRow("NAME",YEL)
infoRefs.hp=pRow("HEALTH",G)
infoRefs.pos=pRow("POSITION",YEL)
infoRefs.role=pRow("ROLE",CY) -- [FIX] hiển thị role
local srvRow=makeCard("SERVER",G3)
infoRefs.game=srvRow("GAME",G3)
infoRefs.place=srvRow("PLACE ID",G3)
infoRefs.players=srvRow("PLAYERS",G3)
local sysRow=makeCard("SYSTEM",ORG)
infoRefs.time=sysRow("TIME",ORG)
infoRefs.ver=sysRow("VERSION",ORG)
infoRefs.active=sysRow("ACTIVE",G)

local fpsHist={}
local stT=tick()
local frmCnt=0
RS.RenderStepped:Connect(function() frmCnt=frmCnt+1 end)

task.spawn(function()
    while true do
        task.wait(2)
        if pages["INFO"] and pages["INFO"].Visible then
            local fps=math.floor(frmCnt/2) frmCnt=0
            table.insert(fpsHist,fps)
            if #fpsHist>20 then table.remove(fpsHist,1) end
            local sum=0
            for _,v in ipairs(fpsHist) do sum=sum+v end
            local avg=#fpsHist>0 and math.floor(sum/#fpsHist) or 0
            local ping=0
            pcall(function() ping=math.floor(pl:GetNetworkPing()*1000) end)
            local stTxt,stCol="GOOD",G
            if ping>150 then stTxt,stCol="BAD",YEL end
            if ping>250 then stTxt,stCol="POOR",RED end
            pcall(function()
                infoRefs.ping.Text=ping.." ms"
                infoRefs.pStat.Text=stTxt infoRefs.pStat.TextColor3=stCol
                infoRefs.fps.Text=fps.." fps"
                infoRefs.fpsAvg.Text=avg.." fps"
                infoRefs.mem.Text=(function() local ok,m=pcall(function() return ST:GetTotalMemoryUsageMb() end) return ok and m and math.floor(m).." MB" or "--" end)()
                local u=math.floor(tick()-stT)
                infoRefs.uptime.Text=string.format("%dm %ds",math.floor(u/60),u%60)
                infoRefs.name.Text=pl.Name
                infoRefs.role.Text=getPlayerRole(pl):upper() -- [FIX]
                local c=pl.Character
                if c then
                    local h=c:FindFirstChildOfClass("Humanoid")
                    local hr=c:FindFirstChild("HumanoidRootPart")
                    if h then infoRefs.hp.Text=math.floor(h.Health).." / "..math.floor(h.MaxHealth) end
                    if hr then
                        local p=hr.Position
                        infoRefs.pos.Text=string.format("%d,%d,%d",math.floor(p.X),math.floor(p.Y),math.floor(p.Z))
                    end
                end
                infoRefs.game.Text=string.sub(game.Name or "?",1,24)
                infoRefs.place.Text=tostring(game.PlaceId)
                infoRefs.players.Text=#P:GetPlayers().." / "..P.MaxPlayers
                infoRefs.time.Text=os.date("%H:%M:%S")
                infoRefs.ver.Text="v12.5-FIX"
                local a={}
                if tg.espLine then table.insert(a,"LINE") end
                if tg.espName then table.insert(a,"NAME") end
                if tg.espHp then table.insert(a,"HP") end
                if tg.espDist then table.insert(a,"DIST") end
                if tg.espBody then table.insert(a,"BODY") end
                if tg.noclip then table.insert(a,"NOCLIP") end
                if tg.mapBright then table.insert(a,"BRIGHT") end
                if tg.fps then table.insert(a,"FPS+") end
                if aa.enabled then table.insert(a,"AA") end
                if hitboxOn then table.insert(a,"HITBOX") end
                if aim.enabled then table.insert(a,"AIM") end
                if aim.silent then table.insert(a,"SILENT") end
                if fovCircle.enabled then table.insert(a,"FOV") end
                if extras.fastFire then table.insert(a,"FF") end
                if extras.noReload then table.insert(a,"NR") end
                if antiKickOn then table.insert(a,"AK") end
                if antiBanOn then table.insert(a,"AB") end
                infoRefs.active.Text=(#a==0) and "none" or table.concat(a,",")
            end)
        end
    end
end)

switchTab("MOVE")

local titleTarget="> ROOT@NEKO:~$ ./run.sh"
local bootRunning=false
local function bootSequence()
    if bootRunning then return end
    bootRunning=true
    stLbl.Text="> init kernel... [OK]"
    task.wait(0.15)
    stLbl.Text="[ OK ] ready"
    task.spawn(function()
        title.Text=""
        for i=1,#titleTarget do title.Text=string.sub(titleTarget,1,i) task.wait(0.012) end
    end)
    bootRunning=false
end

local menuOpen=false
local function showMenu()
    if menuOpen then return end
    menuOpen=true
    main.Visible=true
    main.Size=UDim2.new(0,0,0,0) main.BackgroundTransparency=1
    T:Create(main,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,420,0,340), BackgroundTransparency=0.05
    }):Play()
    stk.Transparency=1
    T:Create(stk,TweenInfo.new(0.25),{Transparency=0}):Play()
    bootSequence()
end
local function hideMenu()
    if not menuOpen then return end
    menuOpen=false
    local tw=T:Create(main,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
        Size=UDim2.new(0,0,0,0), BackgroundTransparency=1
    })
    tw:Play()
    tw.Completed:Connect(function() main.Visible=false end)
end
cl.MouseButton1Click:Connect(hideMenu)

task.spawn(function()
    local tGlow = 0 local tCursor = 0
    while true do
        task.wait(0.06)
        tGlow = tGlow + 0.06 tCursor = tCursor + 0.06
        tglGlow.Transparency = 0.7 + math.abs(math.sin(tGlow * 2)) * 0.2
        if menuOpen then
            for _,c in ipairs(rainCols) do
                c.offset = c.offset + c.speed * 0.12
                if c.offset > 200 then c.offset = -200 end
                c.lbl.Position = UDim2.new(c.lbl.Position.X.Scale, c.lbl.Position.X.Offset, 0, c.offset)
            end
            if tCursor >= 0.6 then tCursor = 0 cursor.Visible = not cursor.Visible end
        end
    end
end)

local dragging=false local dragStart,dragStartPos local moved=false
toggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        dragging=true moved=false dragStart=i.Position dragStartPos=toggleBtn.Position
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        if d.Magnitude>5 then moved=true end
        toggleBtn.Position=UDim2.new(dragStartPos.X.Scale,dragStartPos.X.Offset+d.X,dragStartPos.Y.Scale,dragStartPos.Y.Offset+d.Y)
        if menuOpen then main.Position=toggleBtn.Position end
    end
end)
UIS.InputEnded:Connect(function(i)
    if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and dragging then
        dragging=false
        if not moved then if menuOpen then hideMenu() else showMenu() end end
    end
end)
main.Position=toggleBtn.Position

local rT=0
local drawingAvailable=(Drawing~=nil and Drawing.new~=nil)
local espFrame=0

RS.RenderStepped:Connect(function(dt)
    rT=tick() espFrame=espFrame+1
    if tg.espLine and drawingAvailable and (espFrame % 2 == 0) then
        local ct2=Vector2.new(cam.ViewportSize.X/2,0)
        local rb=Color3.fromHSV(rT%4/4,1,1)
        for _,p in ipairs(P:GetPlayers()) do
            if p~=pl and p.Character then
                local hr=p.Character:FindFirstChild("HumanoidRootPart")
                local h=p.Character:FindFirstChildOfClass("Humanoid")
                if hr and h and h.Health>0 then
                    local tr=trcs[p]
                    if not tr then
                        local okk,r=pcall(function() return Drawing.new("Line") end)
                        if okk and r then r.Thickness=2 r.Transparency=1 trcs[p]=r tr=r end
                    end
                    if tr then
                        local v,on2=cam:WorldToViewportPoint(hr.Position)
                        if on2 then tr.From=ct2 tr.To=Vector2.new(v.X,v.Y) tr.Color=rb tr.Visible=true
                        else tr.Visible=false end
                    end
                elseif trcs[p] then trcs[p].Visible=false end
            end
        end
    elseif not tg.espLine and next(trcs) then
        for _,t2 in pairs(trcs) do pcall(function() t2:Remove() end) end
        trcs={}
    end

    if tg.espName or tg.espHp or tg.espDist or tg.espBody then
        local myChar=pl.Character
        local myHR=myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myPos=myHR and myHR.Position
        for char,data in pairs(evs) do
            if not char.Parent then destroyESP(char)
            else
                local hr2=char:FindFirstChild("HumanoidRootPart")
                local h2=char:FindFirstChildOfClass("Humanoid")
                if hr2 and h2 then
                    if tg.espDist and myPos then
                        local d=(hr2.Position-myPos).Magnitude/3.57
                        data.distLbl.Text=string.format("%.1fm",d)
                    end
                    if tg.espHp then
                        local hp=math.clamp(h2.Health/math.max(h2.MaxHealth,1),0,1)
                        data.hpFill.Size=UDim2.new(1,0,hp,0)
                        if hp>0.6 then data.hpFill.BackgroundColor3=Color3.fromRGB(0,255,100)
                        elseif hp>0.3 then data.hpFill.BackgroundColor3=YEL
                        else data.hpFill.BackgroundColor3=RED end
                    end
                    if tg.espBody then
                        data._mFrame = data._mFrame + 1
                        if data._mFrame >= 20 or not data._mCache then
                            data._mCache = measureBody(char) data._mFrame = 0
                        end
                        local m = data._mCache
                        if m then
                            data.fxBB.StudsOffset=Vector3.new(0,m.center,0)
                            local dist=(cam.CFrame.Position-hr2.Position).Magnitude
                            if dist>0.1 then
                                local pxPerStud=cam.ViewportSize.Y/(2*dist*math.tan(math.rad(cam.FieldOfView/2)))
                                data.fxBB.Size=UDim2.new(0,math.floor(m.width*pxPerStud),0,math.floor(m.height*pxPerStud))
                            end
                        end
                        for _,s in ipairs(data.scans) do
                            local y=((s.offset+rT*s.speed*s.dir)%1+1)%1
                            s.obj.Position=UDim2.new(0,0,y,0)
                        end
                        for _,d in ipairs(data.dots) do
                            d.y=d.y+rT*d.speed*d.dir*0.01
                            if d.y>1.1 then d.y=-0.1 elseif d.y<-0.1 then d.y=1.1 end
                            d.obj.Position=UDim2.new(d.x,0,d.y,0)
                        end
                        local ringT=(rT*0.6)%1
                        data.ring.Size=UDim2.new(ringT,0,ringT,0)
                        data.ringStroke.Transparency=ringT*0.9
                        local hp2=math.floor(h2.Health/math.max(h2.MaxHealth,1)*100)
                        data.dataTop.Text="HP:"..hp2.."%"
                        if data.hl then
                            data.hl.FillTransparency=0.85+math.abs(math.sin(rT*2.5))*0.05
                        end
                    end
                end
            end
        end
    end
end)

-- ==================================================================
-- ============ [FIX] SPEED - Dùng BodyVelocity an toàn =============
-- ==================================================================
local speedBV = nil
local function ensureSpeedBV(hr)
    if speedBV and speedBV.Parent == hr then return speedBV end
    if speedBV then pcall(function() speedBV:Destroy() end) end -- [FIX] destroy cũ
    speedBV = Instance.new("BodyVelocity")
    speedBV.Name = "NekoSpeed"
    speedBV.MaxForce = Vector3.new(1e5, 0, 1e5)
    speedBV.P = 1e4
    speedBV.Parent = hr
    return speedBV
end

RS.Heartbeat:Connect(function(dt)
    local c = pl.Character
    if not c then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    local hr = c:FindFirstChild("HumanoidRootPart")
    if not h or not hr or h.Health <= 0 then return end

    -- [FIX] Chỉ set khi cần, tránh spam
    if h.WalkSpeed ~= 16 then h.WalkSpeed = 16 end

    if stt.ws > 16 then
        local bv = ensureSpeedBV(hr)
        local md = h.MoveDirection
        if md.Magnitude > 0.1 then
            bv.Velocity = md.Unit * stt.ws
        else
            bv.Velocity = Vector3.zero
        end
    else
        if speedBV and speedBV.Parent then
            speedBV.Velocity = Vector3.zero
        end
    end

    if stt.jp > 50 then h.UseJumpPower = true h.JumpPower = stt.jp end
end)

UIS.JumpRequest:Connect(function()
    if tg.infJump then
        local c=pl.Character
        local h=c and c:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

P.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        task.wait(1)
        if tg.espName or tg.espHp or tg.espDist or tg.espBody then
            buildESP(c) applyESPToggles()
        end
    end)
end)
for _,p in ipairs(P:GetPlayers()) do
    if p~=pl and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        buildESP(p.Character)
    end
end
applyESPToggles()

task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local f = math.floor(frmCnt/2)
            fpsLbl.Text=f.." FPS"
            frmCnt=0
        end)
    end
end)

-- [FIX] Thông báo role của mình khi load
task.spawn(function()
    task.wait(3)
    local role = getPlayerRole(pl)
    print("[HACKER NEKO v12.5-FIX] loaded. Role: "..role)
    stLbl.Text = "[ OK ] Role: "..role:upper()
    stLbl.TextColor3 = G
end)

end)

if not ok then
    warn("[HACKER NEKO ERROR] "..tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="HACKER NEKO ERROR", Text=tostring(err), Duration=15
        })
    end)
end