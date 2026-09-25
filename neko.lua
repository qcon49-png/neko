-- ==================================================================
-- ============ HACKER NEKO v11.4 — 3008 EDITION ====================
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
local is3008 = (game.PlaceId == 2768379856)  -- Place ID của game 3008

-- ============ COLORS ============
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
local PRP = Color3.fromRGB(200,120,255)

-- ============ GUI PARENT ============
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

-- ============ STATE ============
local stt={ws=16,jp=50}
local tg={
    espLine=false,espName=false,espHp=false,espDist=false,espBody=false,
    noclip=false,mapBright=false,fps=false,infJump=false,
    -- 3008 toggles
    gridSnap=false, rotSnap=false, itemHighlight=false, itemEsp=false,
    autoPickup=false, nightVision=false, resourceTracker=false,
    autoEat=false, autoHeal=false, speedHack=false,
    employeeEsp=false, employeeAlert=false, flyMode=false,
    noClip3008=false, infStamina=false
}
local aa={enabled=false,speed=200,atkSpd=false,hoverOn=false,hoverDist=0,target=nil}
local teleportTo

-- ============ 3008 CONFIG ============
local C3008 = {
    gridSize = 0.25,      -- kích thước lưới snap
    rotSnapDeg = 90,      -- mốc xoay
    autoEatThreshold = 30, -- % đói để tự ăn
    autoHealThreshold = 50,-- % máu để tự heal
    employeeAlertRange = 30, -- mét cảnh báo nhân viên
    shelterCF = nil,      -- vị trí căn cứ đã lưu
}

-- ============ WAYPOINT STORAGE ============
local WPF="HackerNekoWP_"..tostring(game.PlaceId)..".json"
local hfa=(writefile~=nil) and (readfile~=nil) and (isfile~=nil)
local wd={height=3,slots={
    {name="SLOT_1",pts={{name="P1",cf=nil},{name="P2",cf=nil}}},
    {name="SLOT_2",pts={{name="P1",cf=nil},{name="P2",cf=nil}}},
    {name="SLOT_3",pts={{name="P1",cf=nil},{name="P2",cf=nil}}}
}}
if hfa and isfile(WPF) then
    pcall(function()
        local d=HS:JSONDecode(readfile(WPF))
        if d then
            if d.height then wd.height=d.height end
            if type(d.slots)=="table" then
                for i=1,3 do
                    local s=d.slots[i]
                    if type(s)=="table" then
                        if s.name then wd.slots[i].name=s.name end
                        if type(s.pts)=="table" then
                            for j=1,2 do
                                local p=s.pts[j]
                                if type(p)=="table" then
                                    if p.name then wd.slots[i].pts[j].name=p.name end
                                    if p.cf then wd.slots[i].pts[j].cf=p.cf end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end
local function svW() if not hfa then return end pcall(function() writefile(WPF,HS:JSONEncode(wd)) end) end

-- ============ TOGGLE BUTTON ============
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

-- ============ MAIN WINDOW ============
local main=Instance.new("Frame",sg)
main.Size=UDim2.new(0,420,0,340)
main.Position=UDim2.new(0,30,0,120)
main.BackgroundColor3=BG main.BackgroundTransparency=0.05
main.BorderSizePixel=0 main.Active=true main.Draggable=true main.Visible=false main.ZIndex=100
Instance.new("UICorner",main).CornerRadius=UDim.new(0,4)
local stk=Instance.new("UIStroke",main) stk.Color=G stk.Thickness=1.5
local stkGlow=Instance.new("UIStroke",main) stkGlow.Color=G stkGlow.Thickness=5 stkGlow.Transparency=0.85

-- RAIN
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

-- DIALOG
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

-- ============ TABS ============
local tabs={"MOVE","ESP","COMBAT","PLAYER","3008","TELE","INFO"}
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

-- ============ HELPERS ============
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

-- ==================================================================
-- ============ MASTER LIGHTING SNAPSHOT (FIX MAP BRIGHT) ===========
-- ==================================================================
local BASE_LIGHTING = {
    Brightness = L.Brightness,
    ClockTime = L.ClockTime,
    Ambient = L.Ambient,
    OutdoorAmbient = L.OutdoorAmbient,
    GlobalShadows = L.GlobalShadows,
    EnvironmentDiffuseScale = L.EnvironmentDiffuseScale,
    EnvironmentSpecularScale = L.EnvironmentSpecularScale,
    ShadowSoftness = L.ShadowSoftness,
    FogEnd = L.FogEnd,
    FogStart = L.FogStart,
    ExposureCompensation = L.ExposureCompensation,
}

local function restoreLightingBase()
    pcall(function()
        for k, v in pairs(BASE_LIGHTING) do L[k] = v end
    end)
end

local function reapplyLighting()
    restoreLightingBase()
    if tg.fps then
        pcall(function()
            L.GlobalShadows = false
            L.EnvironmentDiffuseScale = 0
            L.EnvironmentSpecularScale = 0
            L.ShadowSoftness = 0
            L.FogEnd = 100000
            L.FogStart = 100000
        end)
    end
    if tg.mapBright then
        pcall(function()
            L.Brightness = 3
            L.ClockTime = 14
            L.Ambient = Color3.fromRGB(180,180,180)
            L.OutdoorAmbient = Color3.fromRGB(180,180,180)
            L.FogEnd = 100000
            L.FogStart = 100000
            L.GlobalShadows = false
            L.ExposureCompensation = 0.5
        end)
    end
    if tg.nightVision then
        pcall(function()
            L.Brightness = math.max(L.Brightness, 2)
            L.Ambient = Color3.fromRGB(100,100,100)
            L.OutdoorAmbient = Color3.fromRGB(100,100,100)
        end)
    end
end

-- ==================================================================
-- ============ FPS BOOST (FIX RESTORE + BATCH QUEUE) ==============
-- ==================================================================
local fpsSaved = {
    active = false,
    gen = 0,
    parts = {},
    effects = {},
    postFx = {},
    atmos = {},
    terrain = {},
    conns = {},
    qualityLevel = nil,
}
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
    fpsSaved.parts = {}
    fpsSaved.effects = {}
    fpsSaved.postFx = {}
    fpsSaved.atmos = {}
    fpsSaved.conns = {}

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
                fpsSaved.postFx[v] = true
                v.Enabled = false
            elseif v:IsA("Atmosphere") then
                fpsSaved.atmos[v] = v.Density
                v.Density = 0
            end
        end)
    end

    pcall(function()
        local t = workspace:FindFirstChildOfClass("Terrain")
        if t then
            fpsSaved.terrain = {
                WaterWaveSize = t.WaterWaveSize,
                WaterReflectance = t.WaterReflectance,
                WaterTransparency = t.WaterTransparency,
            }
            t.WaterWaveSize = 0
            t.WaterReflectance = 0
            t.WaterTransparency = 1
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

    table.insert(fpsSaved.conns,
        workspace.DescendantAdded:Connect(function(o)
            if not fpsSaved.active then return end
            table.insert(fpsQueue, o)
            processFPSQueue()
        end)
    )
    table.insert(fpsSaved.conns,
        L.DescendantAdded:Connect(function(o)
            if not fpsSaved.active then return end
            if o:IsA("PostEffect") then
                pcall(function()
                    if o.Enabled then
                        fpsSaved.postFx[o] = true
                        o.Enabled = false
                    end
                end)
            elseif o:IsA("Atmosphere") then
                pcall(function()
                    if fpsSaved.atmos[o] == nil then fpsSaved.atmos[o] = o.Density end
                    o.Density = 0
                end)
            else
                fpsKill(o)
            end
        end)
    )
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

    for fx in pairs(fpsSaved.postFx) do
        pcall(function() if fx and fx.Parent then fx.Enabled = true end end)
    end
    fpsSaved.postFx = {}

    for at, d in pairs(fpsSaved.atmos) do
        pcall(function() if at and at.Parent then at.Density = d end end)
    end
    fpsSaved.atmos = {}

    for fx in pairs(fpsSaved.effects) do
        pcall(function() if fx and fx.Parent then fx.Enabled = true end end)
    end
    fpsSaved.effects = {}

    for p in pairs(fpsSaved.parts) do
        pcall(function() if p and p.Parent then p.CastShadow = true end end)
    end
    fpsSaved.parts = {}

    pcall(function() if setfpscap then setfpscap(240) end end)
end

local function setFPS(on)
    if on then enableFPS() else disableFPS() end
end

-- ==================================================================
-- ============ MAP BRIGHT (FIX TẮT ĐƯỢC) ==========================
-- ==================================================================
local mbPostFx = {}
local mbAtmos = {}
local function setMapBright(on)
    if on then
        tg.mapBright = true
        reapplyLighting()
        mbPostFx = {}
        mbAtmos = {}
        for _, v in ipairs(L:GetChildren()) do
            pcall(function()
                if v:IsA("PostEffect") and v.Enabled then
                    mbPostFx[v] = true
                    v.Enabled = false
                elseif v:IsA("Atmosphere") then
                    mbAtmos[v] = v.Density
                    v.Density = 0
                end
            end)
        end
    else
        tg.mapBright = false
        reapplyLighting()
        for fx in pairs(mbPostFx) do
            pcall(function()
                if not tg.fps and fx and fx.Parent then fx.Enabled = true end
            end)
        end
        for at, d in pairs(mbAtmos) do
            pcall(function()
                if not tg.fps and at and at.Parent then at.Density = d end
            end)
        end
        mbPostFx = {}
        mbAtmos = {}
    end
end

-- ==================================================================
-- ============ NIGHT VISION (3008) =================================
-- ==================================================================
local function setNightVision(on)
    tg.nightVision = on
    reapplyLighting()
    if on then
        pcall(function()
            for _, v in ipairs(L:GetChildren()) do
                if v:IsA("Atmosphere") then v.Density = 0 end
                if v:IsA("ColorCorrectionEffect") then v.Enabled = false end
            end
        end)
    else
        pcall(function()
            for _, v in ipairs(L:GetChildren()) do
                if v:IsA("ColorCorrectionEffect") then v.Enabled = true end
            end
        end)
    end
end

-- ==================================================================
-- ============ BG SAFETY ==========================================
-- ==================================================================
local lastSafeCF = nil
local bgConn = nil
local MAX_FALL = 45
local function setupBgSafety(char)
    if bgConn then bgConn:Disconnect() bgConn=nil end
    local h = char:WaitForChild("Humanoid", 5)
    if not h then return end
    local hr = char:WaitForChild("HumanoidRootPart", 5)
    if not hr then return end
    pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
    pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false) end)
    local lastHp = h.Health
    local protectUntil = 0
    h.HealthChanged:Connect(function(newHp)
        if newHp < lastHp and tick() < protectUntil then
            h.Health = lastHp
            return
        end
        lastHp = h.Health
    end)
    bgConn = RS.Heartbeat:Connect(function()
        if not hr or not hr.Parent then return end
        local v = hr.AssemblyLinearVelocity
        if v.Y < -MAX_FALL then
            hr.AssemblyLinearVelocity = Vector3.new(v.X, -MAX_FALL, v.Z)
            protectUntil = tick() + 1.5
        end
        if hr.Position.Y > 5 then lastSafeCF = hr.CFrame end
        if hr.Position.Y < -30 and lastSafeCF then
            pcall(function()
                hr:SetNetworkOwner(pl)
                char:PivotTo(lastSafeCF + Vector3.new(0, 5, 0))
                hr.AssemblyLinearVelocity = Vector3.zero
                hr.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)
end
pl.CharacterAdded:Connect(function(c) task.wait(0.3) setupBgSafety(c) end)
if pl.Character then setupBgSafety(pl.Character) end

-- ==================================================================
-- ============ 3008 GRID SNAP (XÂY NHÀ) ===========================
-- ==================================================================
local snapConn = nil
local function snapPosition(pos, grid)
    grid = grid or C3008.gridSize
    return Vector3.new(
        math.floor(pos.X / grid + 0.5) * grid,
        math.floor(pos.Y / grid + 0.5) * grid,
        math.floor(pos.Z / grid + 0.5) * grid
    )
end

local function snapRotation(cf, deg)
    deg = deg or C3008.rotSnapDeg
    local rx, ry, rz = cf:ToEulerAnglesYXZ()
    local snapRad = math.rad(deg)
    rx = math.floor(rx / snapRad + 0.5) * snapRad
    ry = math.floor(ry / snapRad + 0.5) * snapRad
    rz = math.floor(rz / snapRad + 0.5) * snapRad
    return CFrame.Angles(rx, ry, rz) + cf.Position
end

local function startGridSnap()
    if snapConn then snapConn:Disconnect() end
    snapConn = RS.RenderStepped:Connect(function()
        if not tg.gridSnap and not tg.rotSnap then return end
        local char = pl.Character
        if not char then return end
        -- Tìm model đang cầm (thường nằm trong nhân vật hoặc trong một folder riêng)
        local held = nil
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Model") and obj.PrimaryPart then
                held = obj
                break
            end
        end
        if not held then
            -- Thử tìm trong workspace (một số game đặt model đang cầm ở đây)
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj:IsA("Model") and obj:GetAttribute("Held") then
                    held = obj
                    break
                end
            end
        end
        if held and held.PrimaryPart then
            local currentCF = held:GetPivot()
            local newPos = currentCF.Position
            local newRot = currentCF.Rotation
            if tg.gridSnap then
                newPos = snapPosition(newPos)
            end
            if tg.rotSnap then
                newRot = snapRotation(CFrame.new(newPos) * currentCF.Rotation).Rotation
            end
            held:PivotTo(CFrame.new(newPos) * newRot)
        end
    end)
end

-- ==================================================================
-- ============ 3008 ITEM HIGHLIGHT + ESP ==========================
-- ==================================================================
local itemHighlights = {}
local itemBBs = {}
local itemScanConn = nil

local function is3008Item(inst)
    -- Tool trực tiếp
    if inst:IsA("Tool") then return true end
    -- Model có tên chứa các từ khóa đồ nội thất
    local n = string.lower(inst.Name)
    local furniture = {"pallet","shelf","chair","table","bed","lamp","crate","door","fence","wall","rug","sign","mirror","drawer","cabinet","sofa","couch","bench","counter","fridge","stove","micro","speaker","tv","monitor","ladder","stand","box","basket","cart","pillow","mattress"}
    for _, k in ipairs(furniture) do
        if n:find(k) then return true end
    end
    return false
end

local function buildItemHighlight(inst)
    if itemHighlights[inst] then return end
    local target = inst
    if inst:IsA("Model") then
        target = inst:FindFirstChildWhichIsA("BasePart", true)
    end
    if not target then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = inst
    hl.FillColor = G
    hl.FillTransparency = 0.7
    hl.OutlineColor = G
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ef
    itemHighlights[inst] = hl
end

local function destroyItemHighlight(inst)
    if itemHighlights[inst] then
        pcall(function() itemHighlights[inst]:Destroy() end)
        itemHighlights[inst] = nil
    end
end

local function scan3008Items()
    if not tg.itemHighlight and not tg.itemEsp then return end
    task.spawn(function()
        local all = workspace:GetDescendants()
        for i = 1, #all do
            if not tg.itemHighlight and not tg.itemEsp then return end
            local o = all[i]
            if o and o.Parent and not itemHighlights[o] and is3008Item(o) then
                if tg.itemHighlight then buildItemHighlight(o) end
                if tg.itemEsp then
                    local part = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local bb = Instance.new("BillboardGui")
                        bb.Adornee = part
                        bb.Size = UDim2.new(0, 120, 0, 18)
                        bb.StudsOffset = Vector3.new(0, 1.5, 0)
                        bb.AlwaysOnTop = true
                        bb.MaxDistance = 2000
                        bb.LightInfluence = 0
                        local l = Instance.new("TextLabel", bb)
                        l.Size = UDim2.new(1,0,1,0)
                        l.BackgroundTransparency = 0.4
                        l.BackgroundColor3 = Color3.fromRGB(0, 40, 20)
                        l.Text = o.Name
                        l.Font = Enum.Font.Code
                        l.TextSize = 10
                        l.TextColor3 = G
                        l.TextStrokeTransparency = 0.3
                        l.TextStrokeColor3 = Color3.new(0,0,0)
                        bb.Parent = ef
                        itemBBs[o] = bb
                    end
                end
            end
            if i % 80 == 0 then task.wait() end
        end
    end)
end

local function clear3008Items()
    for inst, hl in pairs(itemHighlights) do
        pcall(function() if hl and hl.Parent then hl:Destroy() end end)
    end
    itemHighlights = {}
    for inst, bb in pairs(itemBBs) do
        pcall(function() if bb and bb.Parent then bb:Destroy() end end)
    end
    itemBBs = {}
end

local function enable3008ItemScan()
    if itemScanConn then return end
    scan3008Items()
    itemScanConn = workspace.DescendantAdded:Connect(function(o)
        if not tg.itemHighlight and not tg.itemEsp then return end
        task.wait(0.2)
        if o and o.Parent and is3008Item(o) then
            if tg.itemHighlight then buildItemHighlight(o) end
            if tg.itemEsp then
                local part = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    local bb = Instance.new("BillboardGui")
                    bb.Adornee = part
                    bb.Size = UDim2.new(0, 120, 0, 18)
                    bb.StudsOffset = Vector3.new(0, 1.5, 0)
                    bb.AlwaysOnTop = true
                    bb.MaxDistance = 2000
                    bb.LightInfluence = 0
                    local l = Instance.new("TextLabel", bb)
                    l.Size = UDim2.new(1,0,1,0)
                    l.BackgroundTransparency = 0.4
                    l.BackgroundColor3 = Color3.fromRGB(0, 40, 20)
                    l.Text = o.Name
                    l.Font = Enum.Font.Code
                    l.TextSize = 10
                    l.TextColor3 = G
                    l.TextStrokeTransparency = 0.3
                    l.TextStrokeColor3 = Color3.new(0,0,0)
                    bb.Parent = ef
                    itemBBs[o] = bb
                end
            end
        end
    end)
end

local function disable3008ItemScan()
    if itemScanConn then itemScanConn:Disconnect() itemScanConn = nil end
    clear3008Items()
end

-- ==================================================================
-- ============ 3008 EMPLOYEE ESP ==================================
-- ==================================================================
local empHighlights = {}
local function buildEmployeeEsp(model)
    if empHighlights[model] then return end
    local hr = model:FindFirstChild("HumanoidRootPart")
    if not hr then return end
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.FillColor = RED
    hl.FillTransparency = 0.6
    hl.OutlineColor = RED
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ef
    local bb = Instance.new("BillboardGui")
    bb.Adornee = hr
    bb.Size = UDim2.new(0, 140, 0, 22)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.MaxDistance = 3000
    bb.LightInfluence = 0
    local l = Instance.new("TextLabel", bb)
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 0.4
    l.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
    l.Text = "⚠ "..model.Name
    l.Font = Enum.Font.Code
    l.TextSize = 11
    l.TextColor3 = RED
    l.TextStrokeTransparency = 0.3
    l.TextStrokeColor3 = Color3.new(0,0,0)
    bb.Parent = ef
    empHighlights[model] = {hl=hl, bb=bb, hr=hr}
end

local function clearEmployeeEsp()
    for m, data in pairs(empHighlights) do
        pcall(function() if data.hl then data.hl:Destroy() end end)
        pcall(function() if data.bb then data.bb:Destroy() end end)
    end
    empHighlights = {}
end

local function scanEmployees()
    if not tg.employeeEsp then return end
    task.spawn(function()
        local all = workspace:GetDescendants()
        for i = 1, #all do
            if not tg.employeeEsp then return end
            local o = all[i]
            if o and o.Parent and o:IsA("Model") and not empHighlights[o] then
                local hum = o:FindFirstChildOfClass("Humanoid")
                if hum and o:FindFirstChild("HumanoidRootPart") then
                    -- Kiểm tra không phải nhân vật người chơi
                    local isPlayer = false
                    for _, p in ipairs(P:GetPlayers()) do
                        if p.Character == o then isPlayer = true break end
                    end
                    if not isPlayer then
                        buildEmployeeEsp(o)
                    end
                end
            end
            if i % 60 == 0 then task.wait() end
        end
    end)
end

-- Cảnh báo nhân viên gần
local empAlertConn = nil
local function startEmployeeAlert()
    if empAlertConn then empAlertConn:Disconnect() end
    empAlertConn = RS.Heartbeat:Connect(function()
        if not tg.employeeAlert then return end
        local c = pl.Character
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        if not hr then return end
        local nearest, minD = nil, C3008.employeeAlertRange
        for m in pairs(empHighlights) do
            if m.Parent then
                local mhr = m:FindFirstChild("HumanoidRootPart")
                if mhr then
                    local d = (mhr.Position - hr.Position).Magnitude
                    if d < minD then minD = d nearest = m end
                end
            end
        end
        if nearest then
            stLbl.Text = "⚠ EMPLOYEE NEARBY: "..math.floor(minD).."m"
            stLbl.TextColor3 = RED
        else
            stLbl.Text = "[ OK ] ready"
            stLbl.TextColor3 = G
        end
    end)
end

-- ==================================================================
-- ============ 3008 AUTO PICKUP (NHẶT GẦN) ========================
-- ==================================================================
local autoPickConn = nil
local function startAutoPickup3008()
    if autoPickConn then autoPickConn:Disconnect() end
    autoPickConn = RS.Heartbeat:Connect(function()
        if not tg.autoPickup then return end
        local c = pl.Character
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        if not hr then return end
        -- Tìm item gần nhất trong bán kính 5m
        local bestPart, bestD = nil, 5
        for inst in pairs(itemHighlights) do
            if inst.Parent then
                local part = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    local d = (part.Position - hr.Position).Magnitude
                    if d < bestD then bestD = d bestPart = part end
                end
            end
        end
        if bestPart then
            pcall(function()
                if firetouchinterest then
                    firetouchinterest(hr, bestPart, 0)
                    task.wait()
                    firetouchinterest(hr, bestPart, 1)
                end
                local pp = bestPart:FindFirstChildOfClass("ProximityPrompt")
                if pp and fireproximityprompt then fireproximityprompt(pp) end
            end)
        end
    end)
end

-- ==================================================================
-- ============ 3008 AUTO EAT / HEAL ===============================
-- ==================================================================
local autoEatConn = nil
local function startAutoEatHeal()
    if autoEatConn then autoEatConn:Disconnect() end
    autoEatConn = RS.Heartbeat:Connect(function()
        if not tg.autoEat and not tg.autoHeal then return end
        local c = pl.Character
        if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h then return end
        -- Tìm food/medkit trong backpack
        local backpack = pl:FindFirstChild("Backpack")
        if not backpack then return end
        local food, med = nil, nil
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local n = string.lower(tool.Name)
                if n:find("food") or n:find("apple") or n:find("bread") or n:find("soda") or n:find("meat") or n:find("fish") then
                    food = tool
                elseif n:find("medkit") or n:find("bandage") or n:find("heal") or n:find("health") then
                    med = tool
                end
            end
        end
        -- Tự heal nếu máu thấp
        if tg.autoHeal and med and h.Health / h.MaxHealth * 100 < C3008.autoHealThreshold then
            pcall(function() med.Parent = c med:Activate() end)
        end
        -- Tự ăn nếu đói (3008 có attribute Hunger)
        if tg.autoEat and food then
            local hunger = c:GetAttribute("Hunger") or 100
            if hunger < C3008.autoEatThreshold then
                pcall(function() food.Parent = c food:Activate() end)
            end
        end
    end)
end

-- ==================================================================
-- ============ 3008 RESOURCE TRACKER ==============================
-- ==================================================================
local resourceGui = nil
local function updateResourceTracker()
    if not tg.resourceTracker then
        if resourceGui then resourceGui.Enabled = false end
        return
    end
    if not resourceGui then
        resourceGui = Instance.new("ScreenGui")
        resourceGui.Name = "Neko3008Res"
        resourceGui.ResetOnSpawn = false
        resourceGui.IgnoreGuiInset = true
        resourceGui.DisplayOrder = 9998
        resourceGui.Parent = gp
        local f = Instance.new("Frame", resourceGui)
        f.Size = UDim2.new(0, 180, 0, 100)
        f.Position = UDim2.new(1, -190, 0, 100)
        f.BackgroundColor3 = BG
        f.BackgroundTransparency = 0.2
        f.BorderSizePixel = 0
        Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)
        local s = Instance.new("UIStroke", f)
        s.Color = G s.Thickness = 1
        local title = Instance.new("TextLabel", f)
        title.Size = UDim2.new(1, 0, 0, 20)
        title.BackgroundTransparency = 1
        title.Text = "> RESOURCES"
        title.Font = Enum.Font.Code
        title.TextSize = 10
        title.TextColor3 = G
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Position = UDim2.new(0, 8, 0, 2)
        resourceGui:SetAttribute("Title", title)
        -- Các dòng
        local lines = {}
        local names = {"FOOD", "DRINK", "MEDKIT", "MATERIAL"}
        for i, n in ipairs(names) do
            local row = Instance.new("Frame", f)
            row.Size = UDim2.new(1, -12, 0, 16)
            row.Position = UDim2.new(0, 6, 0, 24 + (i-1)*18)
            row.BackgroundTransparency = 1
            local l = Instance.new("TextLabel", row)
            l.Size = UDim2.new(0.6, 0, 1, 0)
            l.BackgroundTransparency = 1
            l.Text = n
            l.Font = Enum.Font.Code
            l.TextSize = 9
            l.TextColor3 = DIM
            l.TextXAlignment = Enum.TextXAlignment.Left
            local v = Instance.new("TextLabel", row)
            v.Size = UDim2.new(0.4, 0, 1, 0)
            v.Position = UDim2.new(0.6, 0, 0, 0)
            v.BackgroundTransparency = 1
            v.Text = "0"
            v.Font = Enum.Font.Code
            v.TextSize = 10
            v.TextColor3 = G
            v.TextXAlignment = Enum.TextXAlignment.Right
            lines[n] = v
        end
        resourceGui:SetAttribute("Lines", lines)
    else
        resourceGui.Enabled = true
    end
    -- Cập nhật số lượng
    local lines = resourceGui:GetAttribute("Lines")
    if not lines then return end
    local backpack = pl:FindFirstChild("Backpack")
    if not backpack then return end
    local counts = {FOOD=0, DRINK=0, MEDKIT=0, MATERIAL=0}
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            local n = string.lower(tool.Name)
            if n:find("food") or n:find("apple") or n:find("bread") or n:find("meat") or n:find("fish") then
                counts.FOOD = counts.FOOD + 1
            elseif n:find("soda") or n:find("water") or n:find("drink") or n:find("juice") then
                counts.DRINK = counts.DRINK + 1
            elseif n:find("medkit") or n:find("bandage") or n:find("heal") then
                counts.MEDKIT = counts.MEDKIT + 1
            elseif n:find("pallet") or n:find("shelf") or n:find("wood") or n:find("plank") then
                counts.MATERIAL = counts.MATERIAL + 1
            end
        end
    end
    for n, v in pairs(counts) do
        if lines[n] then lines[n].Text = tostring(v) end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(updateResourceTracker)
    end
end)

-- ==================================================================
-- ============ ESP PLAYER (giữ nguyên) ============================
-- ==================================================================
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
    hpBB.Adornee=hr hpBB.Size=UDim2.new(0,12,0,70) hpBB.StudsOffset=Vector3.new(2.3,0.5,0)
    hpBB.AlwaysOnTop=true hpBB.LightInfluence=0 hpBB.MaxDistance=5000
    hpBB.Enabled=tg.espHp

    local hpBg=Instance.new("Frame",hpBB)
    hpBg.Size=UDim2.new(1,0,1,0) hpBg.BackgroundColor3=Color3.fromRGB(0,20,10)
    hpBg.BackgroundTransparency=0.2 hpBg.BorderSizePixel=1 hpBg.BorderColor3=G
    Instance.new("UICorner",hpBg).CornerRadius=UDim.new(0,4)
    local hpFill=Instance.new("Frame",hpBg)
    hpFill.AnchorPoint=Vector2.new(0,1) hpFill.Position=UDim2.new(0,0,1,0)
    hpFill.Size=UDim2.new(1,0,1,0) hpFill.BackgroundColor3=G hpFill.BorderSizePixel=0
    Instance.new("UICorner",hpFill).CornerRadius=UDim.new(0,4)

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
            for _,p in ipairs(P:GetPlayers()) do
                if p~=pl and p.Character and not evs[p.Character] then
                    if p.Character:FindFirstChild("HumanoidRootPart") then
                        buildESP(p.Character)
                    end
                end
            end
        end
    end
end)

-- ==================================================================
-- ============ NOCLIP (FIX SNAPSHOT) ==============================
-- ==================================================================
local noclipSaved = {}
local noclipConn = nil
local function noclipApply(part)
    if not part:IsA("BasePart") then return end
    if noclipSaved[part] == nil then
        noclipSaved[part] = part.CanCollide
    end
    part.CanCollide = false
end
local function setNoclip(on)
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
pl.CharacterAdded:Connect(function(c)
    if tg.noclip then task.wait(0.3) setNoclip(true) end
end)

-- ==================================================================
-- ============ 3008 SPEED HACK ====================================
-- ==================================================================
local speed3008Conn = nil
local function startSpeed3008()
    if speed3008Conn then speed3008Conn:Disconnect() end
    speed3008Conn = RS.Heartbeat:Connect(function()
        if not tg.speedHack then return end
        local c = pl.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h then
            h.WalkSpeed = stt.ws * 1.5  -- tăng 50%
        end
    end)
end

-- ==================================================================
-- ============ 3008 INFINITE STAMINA ==============================
-- ==================================================================
local staminaConn = nil
local function startInfStamina()
    if staminaConn then staminaConn:Disconnect() end
    staminaConn = RS.Heartbeat:Connect(function()
        if not tg.infStamina then return end
        local c = pl.Character
        if c then
            local energy = c:GetAttribute("Energy")
            if energy ~= nil then
                pcall(function() c:SetAttribute("Energy", 100) end)
            end
        end
    end)
end

-- ==================================================================
-- ============ 3008 FLY MODE ======================================
-- ==================================================================
local flyConn = nil
local function startFly()
    if flyConn then flyConn:Disconnect() end
    local bodyVel, bodyGyro = nil, nil
    flyConn = RS.Heartbeat:Connect(function()
        if not tg.flyMode then
            if bodyVel then bodyVel:Destroy() bodyVel = nil end
            if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
            return
        end
        local c = pl.Character
        local hr = c and c:FindFirstChild("HumanoidRootPart")
        if not hr then return end
        if not bodyVel then
            bodyVel = Instance.new("BodyVelocity")
            bodyVel.MaxForce = Vector3.new(1e5,1e5,1e5)
            bodyVel.P = 1000
            bodyVel.Parent = hr
        end
        if not bodyGyro then
            bodyGyro = Instance.new("BodyGyro")
            bodyGyro.MaxTorque = Vector3.new(1e5,1e5,1e5)
            bodyGyro.P = 1000
            bodyGyro.D = 50
            bodyGyro.Parent = hr
        end
        bodyGyro.CFrame = cam.CFrame
        local move = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
        bodyVel.Velocity = move * 80
    end)
end

-- ==================================================================
-- ============ 3008 NO CLIP =======================================
-- ==================================================================
-- (Đã có Noclip chung ở trên, dùng cùng cơ chế)

-- ==================================================================
-- ============ POPULATE UI ========================================
-- ==================================================================
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
mkSli(pages["COMBAT"],"Hover Dist",0,10,0,function(v) aa.hoverDist=v end)
local aaTargetBtn=mkBtn(pages["COMBAT"],"TARGET: (none)",function() end)
local function openTargetPicker()
    dlgTitle.Text="> SELECT TARGET PLAYER"
    for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=pl then
            dlgBtn(p.Name, G, function()
                aa.target=p
                aaTargetBtn.Text="  > TARGET: "..p.Name
                closeDlg()
            end)
        end
    end
    dlgBtn("CANCEL",RED,function() closeDlg() end)
    dlg.Visible=true dlgOverlay.Visible=true
end
aaTargetBtn.MouseButton1Click:Connect(function() openTargetPicker() end)
mkTog(pages["COMBAT"],"AUTO ATTACK",false,function(on)
    if on and not aa.target then
        aaTargetBtn.Text="  > TARGET: chon truoc!"
        return
    end
    aa.enabled=on aa.atkSpd=on aa.hoverOn=on
end)

mkSec(pages["PLAYER"],"// PERFORMANCE")
mkTog(pages["PLAYER"],"FPS BOOST",false,function(on) tg.fps=on setFPS(on) end)
mkTog(pages["PLAYER"],"MAP BRIGHT",false,function(on) tg.mapBright=on setMapBright(on) end)
mkSec(pages["PLAYER"],"// SURVIVAL")
mkTog(pages["PLAYER"],"NOCLIP (SMOOTH)",false,function(on) tg.noclip=on setNoclip(on) end)
mkSec(pages["PLAYER"],"// CAMERA")
mkSli(pages["PLAYER"],"FOV",70,120,70,function(v) cam.FieldOfView=v end)
mkSec(pages["PLAYER"],"// UTILITIES")
mkBtn(pages["PLAYER"],"RESET CHARACTER",function()
    local c=pl.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Health=0 end end
end)
mkBtn(pages["PLAYER"],"REJOIN SERVER",function()
    pcall(function() TS:TeleportToPlaceInstance(game.PlaceId,game.JobId,pl) end)
end)

-- ==================================================================
-- ============ TAB 3008 ============================================
-- ==================================================================
mkSec(pages["3008"],"// XÂY NHÀ (BUILDING)")
mkTog(pages["3008"],"GRID SNAP (XÂY NHÀ)",false,function(on)
    tg.gridSnap = on
    if on then startGridSnap() end
end)
mkSli(pages["3008"],"GRID SIZE",0.1,2.0,C3008.gridSize,function(v) C3008.gridSize=v end)
mkTog(pages["3008"],"ROTATION SNAP (90°)",false,function(on)
    tg.rotSnap = on
    if on then startGridSnap() end
end)
mkSli(pages["3008"],"ROTATION MỐC (°)",15,180,C3008.rotSnapDeg,function(v) C3008.rotSnapDeg=v end)

mkSec(pages["3008"],"// ITEM (ĐỒ NỘI THẤT)")
mkTog(pages["3008"],"ITEM HIGHLIGHT",false,function(on)
    tg.itemHighlight = on
    if on then enable3008ItemScan() else disable3008ItemScan() end
end)
mkTog(pages["3008"],"ITEM ESP (TÊN + KHOẢNG CÁCH)",false,function(on)
    tg.itemEsp = on
    if on then enable3008ItemScan() else disable3008ItemScan() end
end)
mkTog(pages["3008"],"AUTO PICKUP GẦN (5m)",false,function(on)
    tg.autoPickup = on
    if on then startAutoPickup3008() end
end)

mkSec(pages["3008"],"// SINH TỒN")
mkTog(pages["3008"],"NIGHT VISION",false,function(on) setNightVision(on) end)
mkTog(pages["3008"],"RESOURCE TRACKER",false,function(on) tg.resourceTracker = on end)
mkTog(pages["3008"],"AUTO EAT (ĐÓI < 30%)",false,function(on) tg.autoEat = on startAutoEatHeal() end)
mkTog(pages["3008"],"AUTO HEAL (MÁU < 50%)",false,function(on) tg.autoHeal = on startAutoEatHeal() end)
mkTog(pages["3008"],"INFINITE STAMINA",false,function(on) tg.infStamina = on startInfStamina() end)

mkSec(pages["3008"],"// NHÂN VIÊN (EMPLOYEE)")
mkTog(pages["3008"],"EMPLOYEE ESP",false,function(on)
    tg.employeeEsp = on
    if on then scanEmployees() else clearEmployeeEsp() end
end)
mkTog(pages["3008"],"EMPLOYEE ALERT (30m)",false,function(on)
    tg.employeeAlert = on
    if on then startEmployeeAlert() end
end)

mkSec(pages["3008"],"// DI CHUYỂN NÂNG CAO")
mkTog(pages["3008"],"SPEED HACK (x1.5)",false,function(on) tg.speedHack = on startSpeed3008() end)
mkTog(pages["3008"],"FLY MODE",false,function(on) tg.flyMode = on startFly() end)
mkTog(pages["3008"],"NO CLIP 3008",false,function(on) tg.noClip3008 = on setNoclip(on) end)

mkSec(pages["3008"],"// CĂN CỨ (SHELTER)")
local shelterBtn = mkBtn(pages["3008"],"LƯU VỊ TRÍ CĂN CỨ",function()
    local c = pl.Character
    local hr = c and c:FindFirstChild("HumanoidRootPart")
    if hr then
        C3008.shelterCF = {hr.CFrame:GetComponents()}
        if hfa then
            pcall(function()
                writefile("HackerNeko3008Shelter.json", HS:JSONEncode(C3008.shelterCF))
            end)
        end
        stLbl.Text = "[ OK ] Đã lưu căn cứ!"
        stLbl.TextColor3 = G
    end
end)
mkBtn(pages["3008"],"TELEPORT VỀ CĂN CỨ",function()
    if not C3008.shelterCF then
        -- Thử load từ file
        if hfa and isfile("HackerNeko3008Shelter.json") then
            pcall(function()
                C3008.shelterCF = HS:JSONDecode(readfile("HackerNeko3008Shelter.json"))
            end)
        end
    end
    if C3008.shelterCF then
        local cc = C3008.shelterCF
        local sc = CFrame.new(cc[1],cc[2],cc[3],cc[4],cc[5],cc[6],cc[7],cc[8],cc[9],cc[10],cc[11],cc[12])
        teleportTo(sc.Position)
    else
        stLbl.Text = "[ ! ] Chưa lưu căn cứ!"
        stLbl.TextColor3 = RED
    end
end)

-- Load shelter nếu có file
if hfa and isfile("HackerNeko3008Shelter.json") then
    pcall(function()
        C3008.shelterCF = HS:JSONDecode(readfile("HackerNeko3008Shelter.json"))
    end)
end

-- ==================================================================
-- ============ TELE TAB ===========================================
-- ==================================================================
mkSec(pages["TELE"],"// TELEPORT TO PLAYER")
local tpTargetBtn=mkBtn(pages["TELE"],"SELECT PLAYER",function() end)
local tpSelected=nil
local function openTpPicker()
    dlgTitle.Text="> SELECT PLAYER"
    for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=pl then
            dlgBtn(p.Name,G,function()
                tpSelected=p
                tpTargetBtn.Text="  > "..p.Name
                closeDlg()
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
    teleportTo(th.Position+Vector3.new(0,3,0))
    task.wait(.5)
    tpCD=false
end)
mkSec(pages["TELE"],"// QUICK MOVE")
mkBtn(pages["TELE"],"UP +50m",function()
    local c=pl.Character
    if c and c:FindFirstChild("HumanoidRootPart") then teleportTo(c.HumanoidRootPart.Position+Vector3.new(0,50,0)) end
end)
mkBtn(pages["TELE"],"FORWARD +20m",function()
    local c=pl.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        teleportTo(c.HumanoidRootPart.Position+c.HumanoidRootPart.CFrame.LookVector*20)
    end
end)
mkSec(pages["TELE"],"// WAYPOINTS")
mkSli(pages["TELE"],"WP Height",-10,30,wd.height,function(v) wd.height=v svW() end)
for si=1,3 do
    local sIdx=si
    local slotBtn=mkBtn(pages["TELE"],"[ "..wd.slots[sIdx].name.." ]",function() end)
    slotBtn.MouseButton1Click:Connect(function()
        dlgTitle.Text="> SLOT: "..wd.slots[sIdx].name
        for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
        for pi2=1,2 do
            local pt2=wd.slots[sIdx].pts[pi2]
            local statusStr=pt2.cf and "[SAVED]" or "[EMPTY]"
            dlgBtn(pt2.name.."  "..statusStr,G,function()
                closeDlg() task.wait(0.05)
                dlgTitle.Text="> "..pt2.name
                for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
                dlgBtn("SET POSITION",G,function()
                    local c=pl.Character
                    local hr=c and c:FindFirstChild("HumanoidRootPart")
                    if hr then pt2.cf={hr.CFrame:GetComponents()} svW() end
                    closeDlg()
                end)
                dlgBtn("TELEPORT",CY,function()
                    if pt2.cf then
                        local cc=pt2.cf
                        local sc=CFrame.new(cc[1],cc[2],cc[3],cc[4],cc[5],cc[6],cc[7],cc[8],cc[9],cc[10],cc[11],cc[12])
                        teleportTo(sc.Position+Vector3.new(0,wd.height,0))
                    end
                    closeDlg()
                end)
                dlgBtn("DELETE",RED,function() pt2.cf=nil svW() closeDlg() end)
                dlgBtn("CLOSE",DIM,function() closeDlg() end)
                dlg.Visible=true dlgOverlay.Visible=true
            end)
        end
        dlgBtn("CLOSE",DIM,function() closeDlg() end)
        dlg.Visible=true dlgOverlay.Visible=true
    end)
end

-- ==================================================================
-- ============ INFO TAB ===========================================
-- ==================================================================
local infoRoot=Instance.new("Frame",pages["INFO"])
infoRoot.Size=UDim2.new(1,-8,0,0)
infoRoot.AutomaticSize=Enum.AutomaticSize.Y
infoRoot.BackgroundTransparency=1
infoRoot.LayoutOrder=10
infoRoot.ZIndex=115
local irl=Instance.new("UIListLayout",infoRoot)
irl.Padding=UDim.new(0,6)
irl.SortOrder=Enum.SortOrder.LayoutOrder
local infoRefs={}
local function makeCard(title,accent)
    local card=Instance.new("Frame",infoRoot)
    card.Size=UDim2.new(1,0,0,0)
    card.AutomaticSize=Enum.AutomaticSize.Y
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
                infoRefs.pStat.Text=stTxt
                infoRefs.pStat.TextColor3=stCol
                infoRefs.fps.Text=fps.." fps"
                infoRefs.fpsAvg.Text=avg.." fps"
                infoRefs.mem.Text=(function() local ok,m=pcall(function() return ST:GetTotalMemoryUsageMb() end) return ok and m and math.floor(m).." MB" or "--" end)()
                local u=math.floor(tick()-stT)
                infoRefs.uptime.Text=string.format("%dm %ds",math.floor(u/60),u%60)
                infoRefs.name.Text=pl.Name
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
                infoRefs.ver.Text="v11.4"
                local a={}
                if tg.espLine then table.insert(a,"LINE") end
                if tg.espName then table.insert(a,"NAME") end
                if tg.espHp then table.insert(a,"HP") end
                if tg.espDist then table.insert(a,"DIST") end
                if tg.espBody then table.insert(a,"BODY") end
                if tg.noclip then table.insert(a,"NOCLIP") end
                if tg.mapBright then table.insert(a,"BRIGHT") end
                if tg.fps then table.insert(a,"FPS+") end
                if tg.gridSnap then table.insert(a,"GRID") end
                if tg.nightVision then table.insert(a,"NV") end
                if tg.employeeEsp then table.insert(a,"EMP") end
                if tg.speedHack then table.insert(a,"SPD") end
                if tg.flyMode then table.insert(a,"FLY") end
                if aa.enabled then table.insert(a,"AA") end
                infoRefs.active.Text=(#a==0) and "none" or table.concat(a,",")
            end)
        end
    end
end)

switchTab(is3008 and "3008" or "MOVE")

-- ==================================================================
-- ============ BOOT + MENU ========================================
-- ==================================================================
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
    local tGlow = 0
    local tCursor = 0
    while true do
        task.wait(0.06)
        tGlow = tGlow + 0.06
        tCursor = tCursor + 0.06
        tglGlow.Transparency = 0.7 + math.abs(math.sin(tGlow * 2)) * 0.2
        if menuOpen then
            for _,c in ipairs(rainCols) do
                c.offset = c.offset + c.speed * 0.12
                if c.offset > 200 then c.offset = -200 end
                c.lbl.Position = UDim2.new(c.lbl.Position.X.Scale, c.lbl.Position.X.Offset, 0, c.offset)
            end
            if tCursor >= 0.6 then
                tCursor = 0
                cursor.Visible = not cursor.Visible
            end
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

-- ==================================================================
-- ============ RENDER LOOP ========================================
-- ==================================================================
local rT=0
local drawingAvailable=(Drawing~=nil and Drawing.new~=nil)
local espFrame=0

RS.RenderStepped:Connect(function(dt)
    rT=tick()
    espFrame=espFrame+1

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
                            data._mCache = measureBody(char)
                            data._mFrame = 0
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

-- Movement Heartbeat
RS.Heartbeat:Connect(function(dt)
    local c=pl.Character
    if c then
        local h=c:FindFirstChildOfClass("Humanoid")
        local hr=c:FindFirstChild("HumanoidRootPart")
        if h and hr and h.Health>0 then
            if stt.ws>16 then
                h.WalkSpeed=stt.ws
                if h.MoveDirection.Magnitude>.1 then
                    local v=h.MoveDirection.Unit*stt.ws
                    hr.AssemblyLinearVelocity=Vector3.new(v.X,hr.AssemblyLinearVelocity.Y,v.Z)
                end
            else h.WalkSpeed=16 end
            if stt.jp>50 then h.UseJumpPower=true h.JumpPower=stt.jp end
        end
    end
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

-- ESP player scan loop (throttled)
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

-- Employee cleanup loop
task.spawn(function()
    while true do
        task.wait(3)
        if tg.employeeEsp then
            for m in pairs(empHighlights) do
                if not m.Parent then
                    pcall(function() if empHighlights[m].hl then empHighlights[m].hl:Destroy() end end)
                    pcall(function() if empHighlights[m].bb then empHighlights[m].bb:Destroy() end end)
                    empHighlights[m] = nil
                end
            end
        end
        if tg.itemHighlight or tg.itemEsp then
            for m in pairs(itemHighlights) do
                if not m.Parent then
                    pcall(function() if itemHighlights[m] then itemHighlights[m]:Destroy() end end)
                    itemHighlights[m] = nil
                end
            end
            for m in pairs(itemBBs) do
                if not m.Parent then
                    pcall(function() if itemBBs[m] then itemBBs[m]:Destroy() end end)
                    itemBBs[m] = nil
                end
            end
        end
    end
end)

print("[HACKER NEKO v11.4 — 3008 EDITION] loaded"..(is3008 and " [3008 DETECTED]" or ""))

end)

if not ok then
    warn("[HACKER NEKO ERROR] "..tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="HACKER NEKO ERROR", Text=tostring(err), Duration=15
        })
    end)
end