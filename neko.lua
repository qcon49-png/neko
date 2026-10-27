-- ==================================================================
-- ================ NYT MODS V24 - AC + AIM (FOV CENTER) ============
-- ==================================================================
local ok, err = pcall(function()

local P=game:GetService("Players") local RS=game:GetService("RunService")
local UIS=game:GetService("UserInputService") local T=game:GetService("TweenService")
local L=game:GetService("Lighting") local TS=game:GetService("TeleportService")
local ST=game:GetService("Stats") local HS=game:GetService("HttpService")
local pl=P.LocalPlayer local cam=workspace.CurrentCamera

local G=Color3.fromRGB(0,255,120) local G2=Color3.fromRGB(0,180,80) local G3=Color3.fromRGB(200,255,220)
local DIM=Color3.fromRGB(0,80,40) local BG=Color3.fromRGB(5,10,8) local BG2=Color3.fromRGB(8,18,12)
local TX=Color3.fromRGB(180,255,200) local CY=Color3.fromRGB(0,255,255)
local RED=Color3.fromRGB(255,60,80) local YEL=Color3.fromRGB(255,220,100) local ORG=Color3.fromRGB(255,150,50)

local gp pcall(function() gp=gethui and gethui() end)
if not gp then pcall(function() gp=game:GetService("CoreGui") end) end
if not gp then gp=pl:WaitForChild("PlayerGui") end
pcall(function() if gp:FindFirstChild("HackerNeko") then gp.HackerNeko:Destroy() end
    if gp:FindFirstChild("NekoESP") then gp.NekoESP:Destroy() end end)

local sg=Instance.new("ScreenGui") sg.Name="HackerNeko" sg.ResetOnSpawn=false
sg.IgnoreGuiInset=true sg.DisplayOrder=9999 sg.Parent=gp

local SS=game:GetService("SoundService") local SND={on=true,vol=0.6}
local function playSnd(name)
    if not SND.on then return end
    pcall(function()
        local sd=Instance.new("Sound")
        sd.SoundId="rbxasset://sounds/clickfast.wav"
        sd.Volume=math.clamp(SND.vol*(0.6+math.random()*0.3),0,1)
        sd.PlaybackSpeed=0.9+math.random()*0.3
        sd.Parent=SS sd:Play()
        task.delay(1,function() sd:Destroy() end)
    end)
end

local ef=Instance.new("Folder",gp) ef.Name="NekoESP"
local epf=Instance.new("Folder",ef) epf.Name="Players"

local stt={ws=16,jp=50}
local tg={espLine=false,espName=false,espHp=false,espDist=false,espBody=false,
    noclip=false,mapBright=false,fps=false,infJump=false,antiKB=true}
local ghostDeath={on=false}
local spinState={on=false,speed=5}
local autoFlyState={on=false,stiffness=50}
local ghostFeet={on=false,height=0,baseY=nil}
local spinAccum=0 local spinSavedAutoRotate=nil local autoFlySavedPlatform=nil
local tpSelected=nil local teleportTo local fovCustom=nil
local nlSafe=nil local nlGroundT=0

local acS={on=false,cps=10,button="Left",mode="Toggle",humanize=false,limit=0,points={}}
local acFrames,acStrokes,acLabels={},{},{}
local acAcc,acIdx,acSession,acTotal=0,1,0,0
local acStamps={} local acLastStat=0
local MAX_PER_FRAME=30

local aimS={on=true,teamCheck=false,aliveCheck=true,wallCheck=true,
    triggerKey="MouseButton2",toggleMode=false,lockPart="Head",maxDist=3000,
    fovEnabled=true,fovVisible=true,fovAmount=250,
    fovColor=Color3.fromRGB(0,255,120),lockedColor=Color3.fromRGB(255,70,70),
    fovTransparency=0.5,fovThickness=1.5}
local aimRunning=false local aimLocked=nil local aimOriginalSens=nil
local aimCircle=nil
pcall(function()
    local okD,c=pcall(function() return Drawing.new("Circle") end)
    if okD and c then aimCircle=c end
end)

local hfa=(writefile~=nil) and (readfile~=nil) and (isfile~=nil)
local WPF="NekoWPs_"..tostring(game.PlaceId)..".json"
local ACF="NekoAC_"..tostring(game.PlaceId)..".json"
local wps={nil,nil,nil,nil,nil,nil,nil,nil} local wpHeight=3
if hfa and isfile(WPF) then pcall(function()
    local d=HS:JSONDecode(readfile(WPF))
    if d then
        if type(d.height)=="number" then wpHeight=d.height end
        if type(d.wps)=="table" then for i=1,8 do
            local w=d.wps[tostring(i)] or d.wps[i]
            if type(w)=="table" then wps[i]=w end end end
    end
end) end
local function saveWPs() if not hfa then return end pcall(function()
    local out={} for i=1,8 do if wps[i] then out[tostring(i)]=wps[i] end end
    writefile(WPF,HS:JSONEncode({height=wpHeight,wps=out})) end) end
local function cfFromArr(a) if not a then return nil end return CFrame.new(a[1],a[2],a[3],a[4],a[5],a[6],a[7],a[8],a[9],a[10],a[11],a[12]) end

if hfa and isfile(ACF) then pcall(function()
    local d=HS:JSONDecode(readfile(ACF))
    if d then for k,v in pairs(d) do if k~="points" then acS[k]=v end end end
end) end
local function saveAC() if not hfa then return end pcall(function()
    local vp=workspace.CurrentCamera.ViewportSize local pts={}
    for i,f in ipairs(acFrames) do
        local c=f.AbsolutePosition+f.AbsoluteSize/2
        pts[i]={c.X/vp.X,c.Y/vp.Y}
    end
    acS.points=pts
    writefile(ACF,HS:JSONEncode(acS))
end) end

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
main.Size=UDim2.new(0,470,0,380) main.Position=UDim2.new(0,30,0,120)
main.BackgroundColor3=BG main.BackgroundTransparency=0.05
main.BorderSizePixel=0 main.Active=true main.Visible=false main.ZIndex=100
Instance.new("UICorner",main).CornerRadius=UDim.new(0,4)
local stk=Instance.new("UIStroke",main) stk.Color=G stk.Thickness=1.5
local stkGlow=Instance.new("UIStroke",main) stkGlow.Color=G stkGlow.Thickness=5 stkGlow.Transparency=0.85
local stkGrad=Instance.new("UIGradient",stk)
stkGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,G),ColorSequenceKeypoint.new(0.5,CY),ColorSequenceKeypoint.new(1,G)})

local hd=Instance.new("Frame",main)
hd.Size=UDim2.new(1,0,0,28) hd.BackgroundColor3=BG2 hd.BorderSizePixel=0 hd.ZIndex=110
Instance.new("UICorner",hd).CornerRadius=UDim.new(0,4)
local title=Instance.new("TextLabel",hd)
title.Size=UDim2.new(1,-120,1,0) title.Position=UDim2.new(0,10,0,0)
title.BackgroundTransparency=1 title.Text="> ROOT@NEKO:~$ ./run.sh" title.Font=Enum.Font.Code
title.TextSize=13 title.TextColor3=G title.TextXAlignment=Enum.TextXAlignment.Left title.ZIndex=112
local cl=Instance.new("TextButton",hd)
cl.Size=UDim2.new(0,24,0,24) cl.Position=UDim2.new(1,-28,.5,-12)
cl.BackgroundTransparency=1 cl.Text="X" cl.Font=Enum.Font.Code cl.TextSize=14
cl.TextColor3=RED cl.AutoButtonColor=false cl.ZIndex=113
local sndBtn=Instance.new("TextButton",hd)
sndBtn.Size=UDim2.new(0,24,0,24) sndBtn.Position=UDim2.new(1,-54,.5,-12)
sndBtn.BackgroundTransparency=1 sndBtn.Text="♪" sndBtn.Font=Enum.Font.Code sndBtn.TextSize=16
sndBtn.TextColor3=G sndBtn.AutoButtonColor=false sndBtn.ZIndex=113
sndBtn.MouseButton1Click:Connect(function() SND.on=not SND.on sndBtn.TextColor3=SND.on and G or DIM end)

local sb=Instance.new("Frame",main)
sb.Size=UDim2.new(0,104,1,-64) sb.Position=UDim2.new(0,6,0,34)
sb.BackgroundTransparency=1 sb.BorderSizePixel=0 sb.ZIndex=110
local sbl=Instance.new("UIListLayout",sb) sbl.Padding=UDim.new(0,2) sbl.SortOrder=Enum.SortOrder.LayoutOrder
local ct=Instance.new("Frame",main)
ct.Size=UDim2.new(1,-120,1,-64) ct.Position=UDim2.new(0,116,0,34)
ct.BackgroundColor3=BG2 ct.BackgroundTransparency=0.4 ct.BorderSizePixel=0 ct.ZIndex=110
Instance.new("UICorner",ct).CornerRadius=UDim.new(0,4)
local cstk=Instance.new("UIStroke",ct) cstk.Color=DIM cstk.Thickness=1
local stBar=Instance.new("Frame",main)
stBar.Size=UDim2.new(1,0,0,22) stBar.Position=UDim2.new(0,0,1,-22)
stBar.BackgroundColor3=BG2 stBar.BorderSizePixel=0 stBar.ZIndex=110
Instance.new("UICorner",stBar).CornerRadius=UDim.new(0,4)
local stLbl=Instance.new("TextLabel",stBar)
stLbl.Size=UDim2.new(1,-100,1,0) stLbl.Position=UDim2.new(0,8,0,0)
stLbl.BackgroundTransparency=1 stLbl.Text="[ OK ] ready" stLbl.Font=Enum.Font.Code
stLbl.TextSize=11 stLbl.TextColor3=G stLbl.TextXAlignment=Enum.TextXAlignment.Left stLbl.ZIndex=111
local fpsLbl=Instance.new("TextLabel",stBar)
fpsLbl.Size=UDim2.new(0,80,1,0) fpsLbl.Position=UDim2.new(1,-88,0,0)
fpsLbl.BackgroundTransparency=1 fpsLbl.Text="-- FPS" fpsLbl.Font=Enum.Font.Code
fpsLbl.TextSize=11 fpsLbl.TextColor3=CY fpsLbl.TextXAlignment=Enum.TextXAlignment.Right fpsLbl.ZIndex=111

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
    b.Size=UDim2.new(1,-4,0,36) b.BackgroundColor3=BG2 b.BackgroundTransparency=0.3
    b.BorderSizePixel=0 b.Text="  > "..text b.Font=Enum.Font.Code b.TextSize=13 b.TextColor3=color
    b.TextXAlignment=Enum.TextXAlignment.Left b.AutoButtonColor=false
    b.LayoutOrder=#dlgBody:GetChildren()*10 b.ZIndex=903
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    local s=Instance.new("UIStroke",b) s.Color=DIM s.Thickness=1
    b.MouseButton1Click:Connect(function() playSnd("click") if cb then pcall(cb) end end)
    return b
end
local function closeDlg()
    dlg.Visible=false dlgOverlay.Visible=false
    for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
end
dlgOverlay.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then closeDlg() end
end)

local tabs={"MOVE","ESP","PLAYER","TELE","AIM","INFO"}
local TAB_SHAPE={MOVE="diamond",ESP="ring",PLAYER="circle",TELE="boxin",AIM="ring",INFO="square"}
local pages={} local tabBtns={} local activeTab=nil

local function mkShape(parent,kind)
    local box=Instance.new("Frame",parent)
    box.Size=UDim2.new(0,18,0,18) box.Position=UDim2.new(0,8,.5,-9) box.BackgroundTransparency=1 box.ZIndex=112
    local parts={}
    local function fr(sz,rot,round,hollow)
        local f=Instance.new("Frame",box)
        f.Size=sz f.AnchorPoint=Vector2.new(.5,.5) f.Position=UDim2.new(.5,0,.5,0)
        f.Rotation=rot f.ZIndex=113 f.BorderSizePixel=0
        if round then Instance.new("UICorner",f).CornerRadius=UDim.new(1,0) end
        if hollow then f.BackgroundTransparency=1
            local st=Instance.new("UIStroke",f) st.Thickness=1.5 table.insert(parts,{st=st})
        else table.insert(parts,{f=f}) end
    end
    if kind=="diamond" then fr(UDim2.new(0,11,0,11),45,false,false)
    elseif kind=="ring" then fr(UDim2.new(0,16,0,16),0,true,true) fr(UDim2.new(0,5,0,5),0,true,false)
    elseif kind=="circle" then fr(UDim2.new(0,13,0,13),0,true,false)
    elseif kind=="boxin" then fr(UDim2.new(0,15,0,15),0,false,true) fr(UDim2.new(0,6,0,6),0,false,false)
    else fr(UDim2.new(0,12,0,12),0,false,false) end
    return function(col) for _,p in ipairs(parts) do
        if p.f then p.f.BackgroundColor3=col else p.st.Color=col end end end
end

local function switchTab(name)
    activeTab=name
    for n,p in pairs(pages) do p.Visible=(n==name) end
    for n,b in pairs(tabBtns) do
        local on=(n==name)
        T:Create(b.bg,TweenInfo.new(0.15),{BackgroundColor3=on and G or BG2,BackgroundTransparency=on and 0.15 or 0.5}):Play()
        b.txt.TextColor3=on and Color3.new(0,0,0) or G2
        b.setColor(on and Color3.new(0,0,0) or G2)
    end
    local pg=pages[name] pg.Position=UDim2.new(0,20,0,4)
    T:Create(pg,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0,4,0,4)}):Play()
end

for _,n in ipairs(tabs) do
    local p=Instance.new("ScrollingFrame",ct)
    p.Size=UDim2.new(1,-8,1,-8) p.Position=UDim2.new(0,4,0,4)
    p.BackgroundTransparency=1 p.BorderSizePixel=0 p.ScrollBarThickness=3
    p.ScrollBarImageColor3=G p.CanvasSize=UDim2.new(0,0,0,0)
    p.AutomaticCanvasSize=Enum.AutomaticSize.Y p.ScrollingDirection=Enum.ScrollingDirection.Y
    p.Visible=false p.ZIndex=111
    local l=Instance.new("UIListLayout",p) l.Padding=UDim.new(0,3) l.SortOrder=Enum.SortOrder.LayoutOrder
    pages[n]=p
end
for i,n in ipairs(tabs) do
    local b=Instance.new("TextButton",sb)
    b.Size=UDim2.new(1,0,0,32) b.BackgroundColor3=BG2 b.BackgroundTransparency=0.5
    b.BorderSizePixel=0 b.Text="" b.AutoButtonColor=false b.LayoutOrder=i b.ZIndex=111
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
    local setColor=mkShape(b,TAB_SHAPE[n]) setColor(G2)
    local txt=Instance.new("TextLabel",b)
    txt.Size=UDim2.new(1,-36,1,0) txt.Position=UDim2.new(0,32,0,0)
    txt.BackgroundTransparency=1 txt.Text=n txt.Font=Enum.Font.Code txt.TextSize=12
    txt.TextColor3=G2 txt.TextXAlignment=Enum.TextXAlignment.Left txt.ZIndex=112
    b.MouseEnter:Connect(function() if activeTab~=n then T:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0.2}):Play() end end)
    b.MouseLeave:Connect(function() if activeTab~=n then T:Create(b,TweenInfo.new(0.1),{BackgroundTransparency=0.5}):Play() end end)
    b.MouseButton1Click:Connect(function() playSnd("click") switchTab(n) end)
    tabBtns[n]={bg=b,txt=txt,setColor=setColor}
end

local function mkSec(parent,txt)
    local s=Instance.new("Frame",parent)
    s.Size=UDim2.new(1,-8,0,26) s.BackgroundTransparency=1
    s.LayoutOrder=#parent:GetChildren()*10
    local bar=Instance.new("Frame",s)
    bar.Size=UDim2.new(0,3,0,12) bar.Position=UDim2.new(0,4,.5,-6) bar.BackgroundColor3=CY bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(1,0)
    local l=Instance.new("TextLabel",s)
    l.Size=UDim2.new(1,-16,1,0) l.Position=UDim2.new(0,14,0,0)
    l.BackgroundTransparency=1 l.Text=txt l.Font=Enum.Font.Code l.TextSize=12
    l.TextColor3=CY l.TextXAlignment=Enum.TextXAlignment.Left
    local ln=Instance.new("Frame",s)
    ln.Size=UDim2.new(1,-12,0,1) ln.Position=UDim2.new(0,6,1,-2)
    ln.BackgroundColor3=DIM ln.BackgroundTransparency=0.4 ln.BorderSizePixel=0
end

local function mkTog(parent,name,default,cb)
    local state=default or false
    local row=Instance.new("TextButton",parent)
    row.Size=UDim2.new(1,-8,0,34) row.BackgroundColor3=BG row.BackgroundTransparency=0.3
    row.BorderSizePixel=0 row.Text="" row.AutoButtonColor=false
    row.LayoutOrder=#parent:GetChildren()*10 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local rs=Instance.new("UIStroke",row) rs.Color=DIM rs.Thickness=1 rs.Transparency=0.5
    local lead=Instance.new("Frame",row)
    lead.Size=UDim2.new(0,3,0,16) lead.Position=UDim2.new(0,5,.5,-8) lead.BackgroundColor3=DIM
    lead.BorderSizePixel=0 lead.ZIndex=113
    Instance.new("UICorner",lead).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-70,1,0) lbl.Position=UDim2.new(0,16,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=name lbl.Font=Enum.Font.Code lbl.TextSize=12
    lbl.TextColor3=TX lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=113
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(0,40,0,20) track.Position=UDim2.new(1,-48,.5,-10)
    track.BackgroundColor3=DIM track.BorderSizePixel=0 track.ZIndex=113
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local knob=Instance.new("Frame",track)
    knob.Size=UDim2.new(0,14,0,14) knob.Position=UDim2.new(0,3,.5,-7)
    knob.BackgroundColor3=G2 knob.BorderSizePixel=0 knob.ZIndex=114
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local function render(anim)
        local ti=TweenInfo.new(anim and 0.15 or 0,Enum.EasingStyle.Quad)
        T:Create(track,ti,{BackgroundColor3=state and G or DIM}):Play()
        T:Create(lead,ti,{BackgroundColor3=state and G or DIM}):Play()
        T:Create(knob,ti,{Position=state and UDim2.new(1,-17,.5,-7) or UDim2.new(0,3,.5,-7),BackgroundColor3=state and Color3.new(0,0,0) or G2}):Play()
        lbl.TextColor3=state and G3 or TX
    end
    render(false)
    row.MouseButton1Click:Connect(function()
        state=not state render(true)
        playSnd(state and "on" or "off")
        stLbl.Text="[ "..(state and "ON " or "OFF").." ] "..name
        stLbl.TextColor3=state and G or DIM
        if cb then pcall(cb,state) end
    end)
    return row
end

local function mkSli(parent,name,mn,mx,dv,cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,-8,0,46) row.BackgroundColor3=BG row.BackgroundTransparency=0.3
    row.BorderSizePixel=0 row.LayoutOrder=#parent:GetChildren()*10 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local rs=Instance.new("UIStroke",row) rs.Color=DIM rs.Thickness=1 rs.Transparency=0.5
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-80,0,18) lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1 lbl.Text=name lbl.Font=Enum.Font.Code lbl.TextSize=12
    lbl.TextColor3=TX lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=113
    local val=Instance.new("TextLabel",row)
    val.Size=UDim2.new(0,64,0,18) val.Position=UDim2.new(1,-72,0,4)
    val.BackgroundTransparency=1 val.Text=tostring(dv) val.Font=Enum.Font.Code
    val.TextSize=12 val.TextColor3=G val.TextXAlignment=Enum.TextXAlignment.Right val.ZIndex=113
    local track=Instance.new("Frame",row)
    track.Size=UDim2.new(1,-20,0,6) track.Position=UDim2.new(0,10,0,32)
    track.BackgroundColor3=DIM track.BorderSizePixel=0 track.ZIndex=113
    Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
    local pct=math.clamp((dv-mn)/(mx-mn),0,1)
    local fill=Instance.new("Frame",track)
    fill.Size=UDim2.new(pct,0,1,0) fill.BackgroundColor3=G fill.BorderSizePixel=0 fill.ZIndex=114
    Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
    local thumb=Instance.new("Frame",track)
    thumb.Size=UDim2.new(0,16,0,16) thumb.Position=UDim2.new(pct,-8,.5,-8)
    thumb.BackgroundColor3=Color3.new(1,1,1) thumb.BorderSizePixel=0 thumb.ZIndex=115
    Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
    local ts=Instance.new("UIStroke",thumb) ts.Color=G ts.Thickness=2
    local hit=Instance.new("TextButton",row)
    hit.Size=UDim2.new(1,-12,0,28) hit.Position=UDim2.new(0,6,0,18)
    hit.BackgroundTransparency=1 hit.Text="" hit.ZIndex=116
    local drag=false local lastV=nil
    local function up(x)
        local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        fill.Size=UDim2.new(p,0,1,0) thumb.Position=UDim2.new(p,-8,.5,-8)
        local v=mn+(mx-mn)*p
        if mx>=10 and math.floor(mx)==mx and math.floor(mn)==mn then v=math.floor(v+.5)
        else v=math.floor(v*10)/10 end
        val.Text=tostring(v)
        if v~=lastV then lastV=v if cb then pcall(cb,v) end end
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true pcall(function() parent.ScrollingEnabled=false end) up(i.Position.X) end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then up(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
            drag=false pcall(function() parent.ScrollingEnabled=true end) end
    end)
end

local function mkBtn(parent,name,cb)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,-8,0,34) b.BackgroundColor3=BG b.BackgroundTransparency=0.3
    b.BorderSizePixel=0 b.Text="  > "..name b.Font=Enum.Font.Code b.TextSize=12
    b.TextColor3=G b.TextXAlignment=Enum.TextXAlignment.Left b.AutoButtonColor=false
    b.LayoutOrder=#parent:GetChildren()*10 b.ZIndex=112
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    local st=Instance.new("UIStroke",b) st.Color=DIM st.Thickness=1
    b.MouseEnter:Connect(function() T:Create(st,TweenInfo.new(0.12),{Color=G}):Play() end)
    b.MouseLeave:Connect(function() T:Create(st,TweenInfo.new(0.12),{Color=DIM}):Play() end)
    b.MouseButton1Click:Connect(function()
        playSnd("click")
        b.Text="  > [EXEC...]"
        if cb then task.spawn(function() pcall(cb) end) end
        task.wait(0.15) b.Text="  > "..name
    end)
    return b
end

local function acDoClick()
    if #acFrames==0 then return end
    local f=acFrames[acIdx] acIdx=acIdx%#acFrames+1 if not f then return end
    local c=f.AbsolutePosition+f.AbsoluteSize/2
    local x,y=c.X,c.Y
    if acS.humanize then x=x+math.random(-3,3) y=y+math.random(-3,3) end
    local clicked=false
    local VIM=game:FindService("VirtualInputManager")
    if VIM then
        local okk=pcall(function()
            local b=acS.button=="Right" and 1 or 0
            VIM:SendMouseButtonEvent(x,y,b,true,game,0)
            VIM:SendMouseButtonEvent(x,y,b,false,game,0)
        end)
        if okk then clicked=true end
    end
    if not clicked then
        local VU=game:FindService("VirtualUser")
        if VU then
            local okk=pcall(function()
                local v=Vector2.new(x,y)
                if acS.button=="Right" then VU:ClickButton2(v) else VU:ClickButton1(v) end
            end)
            if okk then clicked=true end
        end
    end
    if not clicked and type(mouse1click)=="function" and acS.button=="Left" then
        pcall(mouse1click) clicked=true
    end
    if clicked then
        acTotal=acTotal+1 acSession=acSession+1
        acStamps[#acStamps+1]=os.clock()
        local ring=f:FindFirstChildWhichIsA("Frame")
        if ring then
            local st=ring:FindFirstChildOfClass("UIStroke")
            if st then st.Transparency=0
                TweenService:Create(st,TweenInfo.new(0.2),{Transparency=0.4}):Play() end
        end
    end
end

local function acAddPoint(cx,cy)
    local f=Instance.new("Frame",sg)
    f.Size=UDim2.new(0,50,0,50) f.Position=UDim2.new(0,cx-25,0,cy-25)
    f.BackgroundTransparency=1 f.BorderSizePixel=0
    f.Active=not acS.on f.ZIndex=50
    local v=Instance.new("Frame",f)
    v.Size=UDim2.new(0,2,1,0) v.Position=UDim2.new(0.5,-1,0,0)
    v.BackgroundColor3=G v.BackgroundTransparency=0.1 v.BorderSizePixel=0 v.ZIndex=51
    local h=Instance.new("Frame",f)
    h.Size=UDim2.new(1,0,0,2) h.Position=UDim2.new(0,0,0.5,-1)
    h.BackgroundColor3=G h.BackgroundTransparency=0.1 h.BorderSizePixel=0 h.ZIndex=51
    local ring=Instance.new("Frame",f)
    ring.Size=UDim2.new(0,30,0,30) ring.Position=UDim2.new(0.5,-15,0.5,-15)
    ring.BackgroundTransparency=1 ring.BorderSizePixel=0 ring.ZIndex=52
    Instance.new("UICorner",ring).CornerRadius=UDim.new(1,0)
    local st=Instance.new("UIStroke",ring) st.Color=G st.Thickness=2 st.Transparency=0.3
    local dot=Instance.new("Frame",f)
    dot.Size=UDim2.new(0,6,0,6) dot.Position=UDim2.new(0.5,-3,0.5,-3)
    dot.BackgroundColor3=G dot.BorderSizePixel=0 dot.ZIndex=52
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local num=Instance.new("TextLabel",f)
    num.Size=UDim2.new(0,20,0,12) num.Position=UDim2.new(1,0,0,-4)
    num.BackgroundTransparency=1 num.Text=tostring(#acFrames+1) num.Font=Enum.Font.Code
    num.TextSize=11 num.TextColor3=G num.TextStrokeTransparency=0.3 num.ZIndex=53
    local drag,start,startPos=false,nil,nil
    f.InputBegan:Connect(function(i)
        if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and not acS.on then
            drag=true start=i.Position startPos=f.Position end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-start
            f.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            if drag then drag=false pcall(saveAC) end end
    end)
    table.insert(acFrames,f) table.insert(acStrokes,st) table.insert(acLabels,num)
end

local function acRemovePoint()
    if #acFrames<=1 then return end
    local f=table.remove(acFrames) if f then f:Destroy() end
    table.remove(acStrokes) table.remove(acLabels)
    for i,l in ipairs(acLabels) do l.Text=tostring(i) end
    saveAC()
end

local function acSetRunning(v)
    acS.on=v acAcc=0 acIdx=1 acSession=0
    for _,f in ipairs(acFrames) do f.Active=not v end
    if not v then saveAC() end
end

local function aimCancel()
    aimLocked=nil
    if aimCircle then pcall(function() aimCircle.Color=aimS.fovColor end) end
    if aimOriginalSens~=nil then pcall(function() UIS.MouseDeltaSensitivity=aimOriginalSens end) end
end
local function aimIsValid(player)
    if player==pl then return false end
    local char=player.Character if not char then return false end
    local part=char:FindFirstChild(aimS.lockPart) if not part then return false end
    local hum=char:FindFirstChildOfClass("Humanoid") if not hum then return false end
    if aimS.aliveCheck and hum.Health<=0 then return false end
    if aimS.teamCheck then
        if player.Team and pl.Team and player.Team==pl.Team then return false end
        if player.TeamColor==pl.TeamColor then return false end
    end
    if (cam.CFrame.Position-part.Position).Magnitude>aimS.maxDist then return false end
    return true,char,part
end
local function aimVisible(char,part)
    if not aimS.wallCheck then return true end
    local origin=cam.CFrame.Position
    local dir=part.Position-origin
    local rp=RaycastParams.new()
    rp.FilterType=Enum.RaycastFilterType.Exclude
    local filter={char}
    if pl.Character then table.insert(filter,pl.Character) end
    rp.FilterDescendantsInstances=filter
    pcall(function() rp.RespectCanCollide=true end)
    local res=workspace:Raycast(origin,dir,rp)
    if res and res.Instance and res.Instance.CanCollide then return false end
    return true
end
-- FIX: Dùng tâm màn hình cố định thay vì vị trí chuột
local function aimGetCandidates()
    local list={}
    local vp=cam.ViewportSize
    local center=Vector2.new(vp.X/2,vp.Y/2)
    local limit=aimS.fovEnabled and aimS.fovAmount or 99999
    for _,p in ipairs(P:GetPlayers()) do
        local valid,char,part=aimIsValid(p)
        if valid then
            local sp,onScreen=cam:WorldToViewportPoint(part.Position)
            if onScreen then
                local d=(center-Vector2.new(sp.X,sp.Y)).Magnitude
                if d<=limit and aimVisible(char,part) then
                    table.insert(list,{Player=p,Dist=d})
                end
            end
        end
    end
    table.sort(list,function(a,b) return a.Dist<b.Dist end)
    return list
end
local function aimAcquire()
    local list=aimGetCandidates()
    aimLocked=#list>0 and list[1].Player or nil
end
local function aimValidate()
    if not aimLocked then return false end
    local valid,char,part=aimIsValid(aimLocked)
    if not valid then aimCancel() return false end
    if not aimVisible(char,part) then aimCancel() return false end
    return true
end

local typing=false
UIS.TextBoxFocused:Connect(function() typing=true end)
UIS.TextBoxFocusReleased:Connect(function() typing=false end)
UIS.InputBegan:Connect(function(inp)
    if typing then return end
    local trig=aimS.triggerKey
    local match=false
    if inp.UserInputType==Enum.UserInputType[trig] then match=true end
    if not match and inp.UserInputType==Enum.UserInputType.Keyboard then
        local kc=Enum.KeyCode[#trig==1 and string.upper(trig) or trig]
        if kc and inp.KeyCode==kc then match=true end
    end
    if match then
        if aimS.toggleMode then
            aimRunning=not aimRunning
            if not aimRunning then aimCancel() end
        else aimRunning=true end
    end
end)
UIS.InputEnded:Connect(function(inp)
    if typing then return end
    if aimS.toggleMode then return end
    local trig=aimS.triggerKey
    local match=false
    if inp.UserInputType==Enum.UserInputType[trig] then match=true end
    if not match and inp.UserInputType==Enum.UserInputType.Keyboard then
        local kc=Enum.KeyCode[#trig==1 and string.upper(trig) or trig]
        if kc and inp.KeyCode==kc then match=true end
    end
    if match then aimRunning=false aimCancel() end
end)

local BASE_LIGHTING={Brightness=L.Brightness,ClockTime=L.ClockTime,Ambient=L.Ambient,
    OutdoorAmbient=L.OutdoorAmbient,GlobalShadows=L.GlobalShadows,FogEnd=L.FogEnd,
    FogStart=L.FogStart,ExposureCompensation=L.ExposureCompensation}
local function restoreLighting() pcall(function() for k,v in pairs(BASE_LIGHTING) do L[k]=v end end) end
local function reapplyLighting()
    restoreLighting()
    if tg.fps then pcall(function() L.GlobalShadows=false L.FogEnd=1e5 L.FogStart=1e5 end) end
    if tg.mapBright then pcall(function() L.Brightness=3 L.ClockTime=14
        L.Ambient=Color3.fromRGB(180,180,180) L.OutdoorAmbient=Color3.fromRGB(180,180,180)
        L.FogEnd=1e5 L.FogStart=1e5 L.GlobalShadows=false L.ExposureCompensation=0.5 end) end
end
local fpsSaved={active=false,gen=0,parts={},effects={},postFx={},atmos={},conns={},qualityLevel=nil}
local function enableFPS()
    if fpsSaved.active then return end
    fpsSaved.active=true fpsSaved.gen=fpsSaved.gen+1
    local myGen=fpsSaved.gen
    fpsSaved.parts={} fpsSaved.effects={} fpsSaved.postFx={} fpsSaved.atmos={} fpsSaved.conns={}
    pcall(function() if settings and settings().Rendering then
        fpsSaved.qualityLevel=settings().Rendering.QualityLevel
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end end)
    pcall(function() if setfpscap then setfpscap(999) end end)
    reapplyLighting()
    for _,v in ipairs(L:GetChildren()) do pcall(function()
        if v:IsA("PostEffect") and v.Enabled then fpsSaved.postFx[v]=true v.Enabled=false
        elseif v:IsA("Atmosphere") then fpsSaved.atmos[v]=v.Density v.Density=0 end end) end
    task.spawn(function()
        local all=workspace:GetDescendants()
        for i=1,#all do
            if fpsSaved.gen~=myGen or not fpsSaved.active then return end
            local o=all[i]
            pcall(function()
                if o:IsA("BasePart") then
                    if o.CastShadow then if not fpsSaved.parts[o] then fpsSaved.parts[o]=true end o.CastShadow=false end
                elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
                    or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then
                    if o.Enabled then if not fpsSaved.effects[o] then fpsSaved.effects[o]=true end o.Enabled=false end
                end
            end)
            if i%200==0 then task.wait() end
        end
    end)
    table.insert(fpsSaved.conns,workspace.DescendantAdded:Connect(function(o)
        if not fpsSaved.active then return end
        pcall(function()
            if o:IsA("BasePart") and o.CastShadow then
                if not fpsSaved.parts[o] then fpsSaved.parts[o]=true end
                o.CastShadow=false
            elseif (o:IsA("ParticleEmitter") or o:IsA("PointLight")) and o.Enabled then
                if not fpsSaved.effects[o] then fpsSaved.effects[o]=true end
                o.Enabled=false
            end
        end)
    end))
end
local function disableFPS()
    if not fpsSaved.active then return end
    fpsSaved.active=false fpsSaved.gen=fpsSaved.gen+1
    for _,c in ipairs(fpsSaved.conns) do pcall(function() c:Disconnect() end) end
    fpsSaved.conns={}
    reapplyLighting()
    pcall(function() if settings and settings().Rendering and fpsSaved.qualityLevel then
        settings().Rendering.QualityLevel=fpsSaved.qualityLevel end end)
    for fx in pairs(fpsSaved.postFx) do pcall(function() if fx and fx.Parent then fx.Enabled=true end end) end
    fpsSaved.postFx={}
    for at,d in pairs(fpsSaved.atmos) do pcall(function() if at and at.Parent then at.Density=d end end) end
    fpsSaved.atmos={}
    for fx in pairs(fpsSaved.effects) do pcall(function() if fx and fx.Parent then fx.Enabled=true end end) end
    fpsSaved.effects={}
    for p in pairs(fpsSaved.parts) do pcall(function() if p and p.Parent then p.CastShadow=true end end) end
    fpsSaved.parts={}
    pcall(function() if setfpscap then setfpscap(240) end end)
end
local function setFPS(on) if on then enableFPS() else disableFPS() end end
local mbPostFx={} local mbAtmos={}
local function setMapBright(on)
    if on then
        tg.mapBright=true reapplyLighting() mbPostFx={} mbAtmos={}
        for _,v in ipairs(L:GetChildren()) do pcall(function()
            if v:IsA("PostEffect") and v.Enabled then mbPostFx[v]=true v.Enabled=false
            elseif v:IsA("Atmosphere") then mbAtmos[v]=v.Density v.Density=0 end end) end
    else
        tg.mapBright=false reapplyLighting()
        for fx in pairs(mbPostFx) do pcall(function() if not tg.fps and fx and fx.Parent then fx.Enabled=true end end) end
        for at,d in pairs(mbAtmos) do pcall(function() if not tg.fps and at and at.Parent then at.Density=d end end) end
        mbPostFx={} mbAtmos={}
    end
end
task.spawn(function() while true do task.wait(0.5)
    if tg.mapBright then pcall(function()
        L.Brightness=3 L.ClockTime=14 L.Ambient=Color3.fromRGB(180,180,180)
        L.OutdoorAmbient=Color3.fromRGB(180,180,180) L.FogEnd=1e5 L.FogStart=1e5
        L.GlobalShadows=false L.ExposureCompensation=0.5 end) end
end end)

teleportTo=function(targetPos,opts)
    opts=opts or {}
    local c=pl.Character if not c then return false end
    local hr=c:FindFirstChild("HumanoidRootPart") if not hr then return false end
    local cf=opts.cframe or (CFrame.new(targetPos)*(hr.CFrame-hr.CFrame.Position))
    local function snap() hr.CFrame=cf hr.AssemblyLinearVelocity=Vector3.zero hr.AssemblyAngularVelocity=Vector3.zero end
    snap()
    task.spawn(function() for _=1,4 do RS.Heartbeat:Wait()
        if not hr.Parent then return end
        if (hr.Position-cf.Position).Magnitude>3 then snap() end end end)
    nlSafe=cf nlGroundT=tick()
    return true
end

local function setSpinState(on)
    spinState.on=on
    local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid") if not h then return end
    if on then
        if spinSavedAutoRotate==nil then spinSavedAutoRotate=h.AutoRotate end
        pcall(function() h.AutoRotate=false end)
    else
        if spinSavedAutoRotate~=nil then pcall(function() h.AutoRotate=spinSavedAutoRotate end) spinSavedAutoRotate=nil end
    end
end
RS.Heartbeat:Connect(function(dt)
    if not spinState.on or autoFlyState.on then return end
    local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart") if not hr then return end
    spinAccum=(spinAccum+math.rad(spinState.speed*360)*dt)%(math.pi*2)
    hr.CFrame=CFrame.new(hr.Position)*CFrame.Angles(0,spinAccum,0)
end)

RS.RenderStepped:Connect(function()
    if not ghostFeet.on or not ghostFeet.baseY or autoFlyState.on then return end
    local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart")
    local h=c and c:FindFirstChildOfClass("Humanoid")
    if not hr or not h or h.Health<=0 then return end
    local minY=math.max(ghostFeet.baseY+ghostFeet.height,workspace.FallenPartsDestroyHeight+50)
    local y=hr.Position.Y local v=hr.AssemblyLinearVelocity
    if y<minY then
        local rotY=select(2,hr.CFrame:ToEulerAnglesYXZ())
        hr.CFrame=CFrame.new(hr.Position.X,minY,hr.Position.Z)*CFrame.Angles(0,rotY,0)
        hr.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z)
    elseif y<minY+4 and v.Y<-1 then
        hr.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z)
    end
end)

RS.Heartbeat:Connect(function(dt)
    if autoFlySavedPlatform~=nil and (not autoFlyState.on or not tpSelected or not tpSelected.Character) then
        local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid")
        local hr=c and c:FindFirstChild("HumanoidRootPart")
        if h then pcall(function() h.PlatformStand=false end) end
        autoFlySavedPlatform=nil
        if hr and h then
            local rp=RaycastParams.new() rp.FilterType=Enum.RaycastFilterType.Exclude
            rp.FilterDescendantsInstances={c}
            local ray=workspace:Raycast(hr.Position,Vector3.new(0,-300,0),rp)
            local targetY=ray and ray.Position.Y+3.5 or hr.Position.Y+15
            local rotY=select(2,hr.CFrame:ToEulerAnglesYXZ())
            hr.CFrame=CFrame.new(hr.Position.X,targetY,hr.Position.Z)*CFrame.Angles(0,rotY,0)
            hr.AssemblyLinearVelocity=Vector3.zero hr.AssemblyAngularVelocity=Vector3.zero
            pcall(function() h:ChangeState(Enum.HumanoidStateType.GetUp) end)
        end
        if autoFlyState.on then autoFlyState.on=false end
        return
    end
    if not autoFlyState.on or not tpSelected then return end
    local myChar=pl.Character local myHR=myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myH=myChar and myChar:FindFirstChildOfClass("Humanoid")
    if not myHR or not myH then return end
    local tChar=tpSelected.Character local tHR=tChar and tChar:FindFirstChild("HumanoidRootPart")
    if not tHR then return end
    if autoFlySavedPlatform==nil then autoFlySavedPlatform=myH.PlatformStand end
    myH.PlatformStand=true
    local desired=tHR.Position+Vector3.new(0,4,0)
    local dist=(desired-myHR.Position).Magnitude
    local newPos=(dist>100) and desired or myHR.Position:Lerp(desired,1-math.exp(-autoFlyState.stiffness*dt))
    local look=tHR.Position-newPos
    local newCF=look.Magnitude>0.5 and CFrame.lookAt(newPos,tHR.Position) or CFrame.new(newPos)
    if spinState.on then
        spinAccum=(spinAccum+math.rad(spinState.speed*360)*dt)%(math.pi*2)
        newCF=newCF*CFrame.Angles(0,spinAccum,0)
    end
    myHR.CFrame=newCF
    myHR.AssemblyLinearVelocity=Vector3.zero myHR.AssemblyAngularVelocity=Vector3.zero
end)

RS.Stepped:Connect(function()
    local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart") if not hr then return end
    local v=hr.AssemblyLinearVelocity
    if v.Y<-30 then hr.AssemblyLinearVelocity=Vector3.new(v.X,-30,v.Z) end
end)

RS.Heartbeat:Connect(function()
    if not ghostDeath.on then return end
    local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid") if not h then return end
    pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Dead,false) end)
    if h.MaxHealth~=100 then pcall(function() h.MaxHealth=100 end) end
    if h.Health~=0 then pcall(function() h.Health=0 end) end
    if h:GetState()==Enum.HumanoidStateType.Dead then
        pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end)
    end
end)

local noclipSaved={} local nlSaved={} local nlRP=RaycastParams.new() nlRP.FilterType=Enum.RaycastFilterType.Exclude
local function noclipApply(part)
    if not part:IsA("BasePart") then return end
    if noclipSaved[part]==nil then noclipSaved[part]=part.CanCollide end
    part.CanCollide=false
end
local function restoreCollide()
    for part,orig in pairs(noclipSaved) do pcall(function() if part and part.Parent then part.CanCollide=orig end end) end
    noclipSaved={}
end
local setNoclip
local function nlHumanoid(on)
    local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid") if not h then return end
    if on then
        if nlSaved.auto==nil then nlSaved.auto=h.AutoJumpEnabled end
        pcall(function() h.AutoJumpEnabled=false end)
    else
        if nlSaved.auto~=nil then pcall(function() h.AutoJumpEnabled=nlSaved.auto end) nlSaved.auto=nil end
    end
end
setNoclip=function(on)
    local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart")
    if on then if hr then nlSafe=hr.CFrame nlGroundT=tick() end nlHumanoid(true)
    else restoreCollide() nlHumanoid(false) end
end
RS.Stepped:Connect(function()
    if not tg.noclip then return end
    local c=pl.Character if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then noclipApply(p) end end
end)
RS.Heartbeat:Connect(function()
    if not tg.noclip then return end
    local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart")
    local h=c and c:FindFirstChildOfClass("Humanoid")
    if not hr or not h or h.Health<=0 then return end
    local now=tick()
    if h.FloorMaterial~=Enum.Material.Air then nlSafe=hr.CFrame nlGroundT=now return end
    if not nlSafe then return end
    if hr.Position.Y<workspace.FallenPartsDestroyHeight+40 then
        hr.CFrame=nlSafe+Vector3.new(0,3,0) hr.AssemblyLinearVelocity=Vector3.zero nlGroundT=now
    end
end)

local akbConn=nil
local function akbStates(on)
    local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid") if not h then return end
    for _,st in ipairs({Enum.HumanoidStateType.FallingDown,Enum.HumanoidStateType.Ragdoll}) do
        pcall(function() h:SetStateEnabled(st,not on) end)
    end
end
local function akbHook(char)
    if akbConn then akbConn:Disconnect() akbConn=nil end
    akbConn=char.DescendantAdded:Connect(function(d)
        if tg.antiKB then
            local movers={BodyVelocity=true,BodyForce=true,BodyPosition=true,BodyGyro=true,
                LinearVelocity=true,VectorForce=true,AngularVelocity=true,Torque=true,BodyAngularVelocity=true}
            if movers[d.ClassName] then task.defer(function() pcall(function() d:Destroy() end) end) end
        end
    end)
    akbStates(tg.antiKB)
end
RS.Heartbeat:Connect(function()
    if not tg.antiKB then return end
    local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid")
    local hr=c and c:FindFirstChild("HumanoidRootPart")
    if not h or not hr or h.Health<=0 then return end
    local st=h:GetState()
    if st==Enum.HumanoidStateType.FallingDown or st==Enum.HumanoidStateType.Ragdoll then
        if not autoFlyState.on then pcall(function() h.PlatformStand=false h:ChangeState(Enum.HumanoidStateType.GetUp) end) end
    end
end)

local function onCharSpawn(char)
    local hr=char:WaitForChild("HumanoidRootPart",10)
    local h=char:WaitForChild("Humanoid",10)
    if not hr or not h then return end
    akbHook(char)
    pcall(function() h.BreakJointsOnDeath=false end)
    pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end)
    pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false) end)
    h.StateChanged:Connect(function(old,new)
        if new==Enum.HumanoidStateType.Landed then pcall(function() h.Health=h.MaxHealth end) end
        if new==Enum.HumanoidStateType.Dead and ghostDeath.on then
            task.defer(function()
                if not h or not h.Parent then return end
                pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Dead,false) h.MaxHealth=100 h.Health=0 end)
                pcall(function() h:ChangeState(Enum.HumanoidStateType.GetUp) end)
                task.wait(0.03)
                if h and h.Parent then pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end) end
            end)
        end
    end)
    task.wait(0.4) if not hr.Parent then return end
    nlSaved={}
    if tg.noclip then task.wait(0.2) if setNoclip then setNoclip(true) end end
    spinSavedAutoRotate=nil
    if spinState.on then
        local hh=char:FindFirstChildOfClass("Humanoid")
        if hh then spinSavedAutoRotate=hh.AutoRotate hh.AutoRotate=false end
    end
    autoFlySavedPlatform=nil
    if ghostFeet.on then
        task.wait(0.5)
        local hr2=char:FindFirstChild("HumanoidRootPart")
        if hr2 then ghostFeet.baseY=hr2.Position.Y end
    end
end
pl.CharacterAdded:Connect(onCharSpawn)
if pl.Character then task.spawn(function() onCharSpawn(pl.Character) end) end

local evs={} local trcs={}
local function measureBody(char)
    local hrp=char:FindFirstChild("HumanoidRootPart") local head=char:FindFirstChild("Head")
    if not hrp or not head then return nil end
    local topY=head.Position.Y+head.Size.Y/2
    local rl=char:FindFirstChild("Right Leg") or char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("RightFoot")
    local bottomY=rl and (rl.Position.Y-rl.Size.Y/2) or (hrp.Position.Y-2.8)
    return {center=(topY+bottomY)/2-hrp.Position.Y,height=topY-bottomY,width=2.4}
end
local function buildESP(char)
    if not char or char==pl.Character or evs[char] then return end
    local hr=char:FindFirstChild("HumanoidRootPart") local head=char:FindFirstChild("Head") or hr
    if not hr or not head then return end
    local fold=Instance.new("Folder",epf) fold.Name=char.Name
    local hl=Instance.new("Highlight",fold)
    hl.Adornee=char hl.FillColor=G hl.FillTransparency=0.9 hl.OutlineColor=G
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop hl.Enabled=tg.espBody
    local infoBB=Instance.new("BillboardGui",fold)
    infoBB.Adornee=head infoBB.Size=UDim2.new(0,220,0,50) infoBB.StudsOffset=Vector3.new(0,2.8,0)
    infoBB.AlwaysOnTop=true infoBB.LightInfluence=0 infoBB.MaxDistance=5000
    infoBB.Enabled=(tg.espName or tg.espDist)
    local nameLbl=Instance.new("TextLabel",infoBB)
    nameLbl.Size=UDim2.new(1,0,0,30) nameLbl.BackgroundTransparency=1 nameLbl.Text=char.Name
    nameLbl.TextColor3=G nameLbl.TextStrokeTransparency=0.1 nameLbl.Font=Enum.Font.Code
    nameLbl.TextSize=20 nameLbl.Visible=tg.espName
    local distLbl=Instance.new("TextLabel",infoBB)
    distLbl.Size=UDim2.new(1,0,0,18) distLbl.Position=UDim2.new(0,0,0,30)
    distLbl.BackgroundTransparency=1 distLbl.Text="0m" distLbl.TextColor3=YEL
    distLbl.Font=Enum.Font.Code distLbl.TextSize=14 distLbl.Visible=tg.espDist
    local hpBB=Instance.new("BillboardGui",fold)
    hpBB.Adornee=hr hpBB.Size=UDim2.new(0,6,0,40) hpBB.StudsOffset=Vector3.new(1.4,0.3,0)
    hpBB.AlwaysOnTop=true hpBB.LightInfluence=0 hpBB.MaxDistance=5000 hpBB.Enabled=tg.espHp
    local hpBg=Instance.new("Frame",hpBB)
    hpBg.Size=UDim2.new(1,0,1,0) hpBg.BackgroundColor3=Color3.fromRGB(0,20,10)
    hpBg.BackgroundTransparency=0.2 hpBg.BorderSizePixel=1 hpBg.BorderColor3=G
    Instance.new("UICorner",hpBg).CornerRadius=UDim.new(0,2)
    local hpFill=Instance.new("Frame",hpBg)
    hpFill.AnchorPoint=Vector2.new(0,1) hpFill.Position=UDim2.new(0,0,1,0)
    hpFill.Size=UDim2.new(1,0,1,0) hpFill.BackgroundColor3=G hpFill.BorderSizePixel=0
    Instance.new("UICorner",hpFill).CornerRadius=UDim.new(0,2)
    evs[char]={folder=fold,hl=hl,infoBB=infoBB,nameLbl=nameLbl,distLbl=distLbl,hpBB=hpBB,hpFill=hpFill,_mCache=nil,_mFrame=0}
end
local function destroyESP(char)
    if evs[char] then pcall(function() evs[char].folder:Destroy() end) evs[char]=nil end
end
local function applyESPToggles()
    for char,data in pairs(evs) do
        if char.Parent then
            data.nameLbl.Visible=tg.espName data.distLbl.Visible=tg.espDist
            data.hpBB.Enabled=tg.espHp data.hl.Enabled=tg.espBody
            data.infoBB.Enabled=(tg.espName or tg.espDist)
        else destroyESP(char) end
    end
end
local function scanESP()
    if not (tg.espName or tg.espHp or tg.espDist or tg.espBody) then return end
    for _,p in ipairs(P:GetPlayers()) do
        local ch=p.Character
        if p~=pl and ch and not evs[ch] and ch:FindFirstChild("HumanoidRootPart") then pcall(buildESP,ch) end
    end
    for ch in pairs(evs) do if not ch.Parent then destroyESP(ch) end end
end
task.spawn(function() while true do task.wait(1) scanESP() end end)

mkSec(pages["MOVE"],"// SPEED")
mkSli(pages["MOVE"],"Walk Speed",16,500,16,function(v) stt.ws=v end)
mkSec(pages["MOVE"],"// JUMP")
mkSli(pages["MOVE"],"Jump Power",50,300,50,function(v) stt.jp=v end)
mkTog(pages["MOVE"],"INFINITE JUMP",false,function(on) tg.infJump=on end)

mkSec(pages["MOVE"],"// AUTO CLICKER")
mkTog(pages["MOVE"],"AUTO CLICKER",false,function(on)
    acSetRunning(on)
    stLbl.Text=on and "[ OK ] AC ON - keo crosshair toi target" or "[ OFF ] AC"
    stLbl.TextColor3=on and G or DIM
    if on and main.Visible then hideMenu() end
end)
mkSli(pages["MOVE"],"Click Speed (cps)",0,500,10,function(v) acS.cps=v end)
mkBtn(pages["MOVE"],"CLICK BUTTON: LEFT",function()
    acS.button=(acS.button=="Left") and "Right" or "Left"
    stLbl.Text="[ OK ] Button: "..acS.button
end)
mkBtn(pages["MOVE"],"MODE: TOGGLE/HOLD",function()
    acS.mode=(acS.mode=="Toggle") and "Hold" or "Toggle"
    stLbl.Text="[ OK ] Mode: "..acS.mode
end)
mkTog(pages["MOVE"],"HUMANIZE (random)",false,function(on) acS.humanize=on end)
mkBtn(pages["MOVE"],"ADD CLICK POINT",function()
    local vp=workspace.CurrentCamera.ViewportSize
    acAddPoint(vp.X/2+#acFrames*40,vp.Y/2)
end)
mkBtn(pages["MOVE"],"REMOVE LAST POINT",function() acRemovePoint() end)
mkBtn(pages["MOVE"],"CLEAR ALL POINTS",function()
    if acS.on then return end
    for _,f in ipairs(acFrames) do f:Destroy() end
    acFrames,acStrokes,acLabels={},{},{} saveAC()
end)

mkSec(pages["ESP"],"// PLAYER ESP")
mkTog(pages["ESP"],"ESP NAME",false,function(on) tg.espName=on applyESPToggles() scanESP() end)
mkTog(pages["ESP"],"ESP HEALTH",false,function(on) tg.espHp=on applyESPToggles() scanESP() end)
mkTog(pages["ESP"],"ESP DISTANCE",false,function(on) tg.espDist=on applyESPToggles() scanESP() end)
mkTog(pages["ESP"],"ESP BODY (Highlight)",false,function(on) tg.espBody=on applyESPToggles() scanESP() end)

mkSec(pages["PLAYER"],"// SPIN")
mkTog(pages["PLAYER"],"SPIN",false,function(on) setSpinState(on) end)
mkSli(pages["PLAYER"],"Spin Speed",1,20,5,function(v) spinState.speed=v end)
mkSec(pages["PLAYER"],"// GHOST FEET")
mkTog(pages["PLAYER"],"GHOST FEET",false,function(on)
    ghostFeet.on=on
    if on then
        local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart")
        if hr then ghostFeet.baseY=hr.Position.Y stLbl.Text="[ OK ] BaseY="..math.floor(hr.Position.Y)
        else ghostFeet.on=false stLbl.Text="[ ! ] No char" end
    else ghostFeet.baseY=nil end
end)
mkSli(pages["PLAYER"],"Ghost Height",-30,100,0,function(v) ghostFeet.height=v end)
mkBtn(pages["PLAYER"],"CALIBRATE BASE",function()
    if not ghostFeet.on then return end
    local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart")
    if hr then ghostFeet.baseY=hr.Position.Y stLbl.Text="[ OK ] BaseY reset" end
end)
mkSec(pages["PLAYER"],"// SURVIVAL")
mkTog(pages["PLAYER"],"NOCLIP",false,function(on) tg.noclip=on setNoclip(on) end)
mkTog(pages["PLAYER"],"ANTI-KB",true,function(on) tg.antiKB=on akbStates(on) end)
mkTog(pages["PLAYER"],"GHOST DEATH (0/100)",false,function(on)
    ghostDeath.on=on
    local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid")
    if on and h then pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Dead,false) h.MaxHealth=100 h.Health=0 end)
    elseif h then pcall(function() h.MaxHealth=100 h.Health=100 end) end
end)
mkSec(pages["PLAYER"],"// PERFORMANCE")
mkTog(pages["PLAYER"],"FPS BOOST",false,function(on) tg.fps=on setFPS(on) end)
mkTog(pages["PLAYER"],"MAP BRIGHT",false,function(on) tg.mapBright=on setMapBright(on) end)
mkSec(pages["PLAYER"],"// CAMERA")
mkSli(pages["PLAYER"],"FOV",70,120,70,function(v) cam.FieldOfView=v fovCustom=(v~=70) and v or nil end)
mkSec(pages["PLAYER"],"// UTILS")
mkBtn(pages["PLAYER"],"RESET CHARACTER",function()
    local c=pl.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Health=0 end end
end)
mkBtn(pages["PLAYER"],"REJOIN",function()
    pcall(function()
        if #P:GetPlayers()<=1 then TS:Teleport(game.PlaceId,pl)
        else TS:TeleportToPlaceInstance(game.PlaceId,game.JobId,pl) end
    end)
end)

mkSec(pages["TELE"],"// TELEPORT")
local tpTargetBtn=mkBtn(pages["TELE"],"SELECT PLAYER",function()
    dlgTitle.Text="> SELECT PLAYER"
    for _,ch in ipairs(dlgBody:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
    for _,p in ipairs(P:GetPlayers()) do
        if p~=pl then dlgBtn(p.Name,G,function()
            tpSelected=p tpTargetBtn.Text="  > "..p.Name closeDlg() end)
        end
    end
    dlgBtn("CANCEL",RED,function() closeDlg() end)
    dlg.Visible=true dlgOverlay.Visible=true
end)
mkBtn(pages["TELE"],"TELEPORT TO PLAYER",function()
    if not tpSelected then return end
    local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart")
    local th=tpSelected.Character and tpSelected.Character:FindFirstChild("HumanoidRootPart")
    if hr and th then teleportTo(th.Position+Vector3.new(0,4,0)) end
end)
mkSec(pages["TELE"],"// AUTO FLY")
mkTog(pages["TELE"],"AUTO FLY",false,function(on) autoFlyState.on=on end)
mkSli(pages["TELE"],"Stiffness",10,120,50,function(v) autoFlyState.stiffness=v end)
mkSec(pages["TELE"],"// WAYPOINTS")
mkSli(pages["TELE"],"WP Height",0,20,wpHeight,function(v) wpHeight=v saveWPs() end)
for i=1,8 do
    local row=Instance.new("Frame",pages["TELE"])
    row.Size=UDim2.new(1,-8,0,34) row.BackgroundColor3=BG row.BackgroundTransparency=0.3
    row.BorderSizePixel=0 row.LayoutOrder=#pages["TELE"]:GetChildren()*10 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
    local info=Instance.new("TextLabel",row)
    info.Size=UDim2.new(1,-140,1,0) info.Position=UDim2.new(0,10,0,0)
    info.BackgroundTransparency=1 info.Text="#"..i.." EMPTY" info.Font=Enum.Font.Code
    info.TextSize=11 info.TextColor3=DIM info.TextXAlignment=Enum.TextXAlignment.Left info.ZIndex=113
    local function mini(x,txt,col,cb)
        local b=Instance.new("TextButton",row)
        b.Size=UDim2.new(0,32,0,24) b.Position=UDim2.new(1,x,0.5,-12)
        b.BackgroundColor3=BG2 b.BorderSizePixel=0 b.Text=txt b.Font=Enum.Font.Code
        b.TextSize=11 b.TextColor3=col b.AutoButtonColor=false b.ZIndex=113
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
        b.MouseButton1Click:Connect(function() if cb then pcall(cb) end end)
    end
    mini(-102,"SET",G,function()
        local c=pl.Character local hr=c and c:FindFirstChild("HumanoidRootPart")
        if hr then wps[i]={hr.CFrame:GetComponents()} saveWPs() info.Text="#"..i.." READY" info.TextColor3=G end
    end)
    mini(-68,"GO",CY,function()
        if wps[i] then local sc=cfFromArr(wps[i])
            if sc then teleportTo(sc.Position+Vector3.new(0,wpHeight,0),{cframe=sc+Vector3.new(0,wpHeight,0)}) end end
    end)
    mini(-34,"X",RED,function() wps[i]=nil saveWPs() info.Text="#"..i.." EMPTY" info.TextColor3=DIM end)
    if wps[i] then info.Text="#"..i.." READY" info.TextColor3=G end
end

mkSec(pages["AIM"],"// AIMBOT (FOV CENTER)")
mkTog(pages["AIM"],"AIMBOT ENABLED",true,function(on) aimS.on=on end)
mkTog(pages["AIM"],"TOGGLE MODE",false,function(on) aimS.toggleMode=on end)
mkTog(pages["AIM"],"TEAM CHECK",false,function(on) aimS.teamCheck=on end)
mkTog(pages["AIM"],"ALIVE CHECK",true,function(on) aimS.aliveCheck=on end)
mkTog(pages["AIM"],"WALL CHECK",true,function(on) aimS.wallCheck=on end)
mkBtn(pages["AIM"],"TRIGGER: "..aimS.triggerKey,function()
    aimS.triggerKey=(aimS.triggerKey=="MouseButton2") and "MouseButton1" or "MouseButton2"
    stLbl.Text="[ OK ] Trigger: "..aimS.triggerKey
end)
mkSli(pages["AIM"],"Max Distance",100,5000,3000,function(v) aimS.maxDist=v end)
mkSec(pages["AIM"],"// FOV")
mkTog(pages["AIM"],"FOV VISIBLE",true,function(on)
    aimS.fovVisible=on
    if aimCircle then aimCircle.Visible=on and aimS.on end
end)
mkSli(pages["AIM"],"FOV Radius",50,800,250,function(v) aimS.fovAmount=v if aimCircle then aimCircle.Radius=v end end)
mkSli(pages["AIM"],"FOV Thickness",1,5,1.5,function(v) aimS.fovThickness=v end)

local infoRefs={}
local infoRoot=Instance.new("Frame",pages["INFO"])
infoRoot.Size=UDim2.new(1,-8,0,0) infoRoot.AutomaticSize=Enum.AutomaticSize.Y
infoRoot.BackgroundTransparency=1 infoRoot.LayoutOrder=10 infoRoot.ZIndex=115
local irl=Instance.new("UIListLayout",infoRoot) irl.Padding=UDim.new(0,6) irl.SortOrder=Enum.SortOrder.LayoutOrder
local function mkCard(title,accent)
    local card=Instance.new("Frame",infoRoot)
    card.Size=UDim2.new(1,0,0,0) card.AutomaticSize=Enum.AutomaticSize.Y
    card.BackgroundColor3=BG card.BackgroundTransparency=0.35 card.BorderSizePixel=0 card.ZIndex=116
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,4)
    local titleBar=Instance.new("Frame",card)
    titleBar.Size=UDim2.new(1,0,0,24) titleBar.BackgroundColor3=BG2
    titleBar.BackgroundTransparency=0.3 titleBar.BorderSizePixel=0 titleBar.ZIndex=117
    Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,4)
    local tl=Instance.new("TextLabel",titleBar)
    tl.Size=UDim2.new(1,-14,1,0) tl.Position=UDim2.new(0,14,0,0)
    tl.BackgroundTransparency=1 tl.Text=title tl.Font=Enum.Font.Code
    tl.TextSize=12 tl.TextColor3=accent tl.TextXAlignment=Enum.TextXAlignment.Left tl.ZIndex=118
    local body=Instance.new("Frame",card)
    body.Size=UDim2.new(1,-12,0,0) body.Position=UDim2.new(0,6,0,28)
    body.AutomaticSize=Enum.AutomaticSize.Y body.BackgroundTransparency=1 body.ZIndex=117
    local bl=Instance.new("UIListLayout",body) bl.Padding=UDim.new(0,3) bl.SortOrder=Enum.SortOrder.LayoutOrder
    local function row(name,color)
        local r=Instance.new("Frame",body)
        r.Size=UDim2.new(1,0,0,18) r.BackgroundTransparency=1 r.ZIndex=118
        local l=Instance.new("TextLabel",r)
        l.Size=UDim2.new(0.5,0,1,0) l.BackgroundTransparency=1 l.Text=name
        l.Font=Enum.Font.Code l.TextSize=11 l.TextColor3=DIM l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=119
        local v=Instance.new("TextLabel",r)
        v.Size=UDim2.new(0.5,0,1,0) v.Position=UDim2.new(0.5,0,0,0) v.BackgroundTransparency=1
        v.Text="--" v.Font=Enum.Font.Code v.TextSize=12 v.TextColor3=color or G
        v.TextXAlignment=Enum.TextXAlignment.Right v.ZIndex=119
        return v
    end
    return row
end
local netR=mkCard("NETWORK",CY)
infoRefs.ping=netR("PING",G) infoRefs.pStat=netR("STATUS",G)
local perfR=mkCard("PERFORMANCE",G)
infoRefs.fps=perfR("FPS",CY) infoRefs.mem=perfR("MEMORY",CY) infoRefs.uptime=perfR("UPTIME",CY)
local acR=mkCard("AUTO CLICK",YEL)
infoRefs.acCps=acR("REAL CPS",CY) infoRefs.acTotal=acR("TOTAL",YEL) infoRefs.acSession=acR("SESSION",G)
local pR=mkCard("PLAYER",YEL)
infoRefs.name=pR("NAME",YEL) infoRefs.hp=pR("HP",G) infoRefs.pos=pR("POS",YEL)
local srvR=mkCard("SERVER",G3)
infoRefs.game=srvR("GAME",G3) infoRefs.players=srvR("PLAYERS",G3)
local sysR=mkCard("SYSTEM",ORG)
infoRefs.ver=sysR("VERSION",ORG) infoRefs.active=sysR("ACTIVE",G)

local frmCnt=0 local stT=tick()
RS.RenderStepped:Connect(function() frmCnt=frmCnt+1 end)
task.spawn(function() while true do task.wait(2)
    if pages["INFO"] and pages["INFO"].Visible then
        local f=frmCnt/2 frmCnt=0
        local ping=0 pcall(function() ping=math.floor(pl:GetNetworkPing()*1000) end)
        pcall(function()
            infoRefs.ping.Text=ping.." ms"
            infoRefs.pStat.Text=ping<150 and "GOOD" or (ping<250 and "BAD" or "POOR")
            infoRefs.fps.Text=math.floor(f).." fps"
            infoRefs.mem.Text=(function() local o,m=pcall(function() return ST:GetTotalMemoryUsageMb() end) return o and m and math.floor(m).." MB" or "--" end)()
            infoRefs.uptime.Text=math.floor(tick()-stT).."s"
            infoRefs.acCps.Text=#acStamps.." cps"
            infoRefs.acTotal.Text=tostring(acTotal)
            infoRefs.acSession.Text=tostring(acSession)
            infoRefs.name.Text=pl.Name
            local c=pl.Character
            if c then
                local h=c:FindFirstChildOfClass("Humanoid") local hr=c:FindFirstChild("HumanoidRootPart")
                if h then infoRefs.hp.Text=math.floor(h.Health).."/"..math.floor(h.MaxHealth) end
                if hr then local p=hr.Position infoRefs.pos.Text=string.format("%d,%d,%d",math.floor(p.X),math.floor(p.Y),math.floor(p.Z)) end
            end
            infoRefs.game.Text=string.sub(game.Name or "?",1,20)
            infoRefs.players.Text=#P:GetPlayers().."/"..P.MaxPlayers
            infoRefs.ver.Text="v24-FOVCENTER"
            local a={}
            if acS.on then table.insert(a,"AC") end
            if aimRunning then table.insert(a,"AIM") end
            if spinState.on then table.insert(a,"SPIN") end
            if ghostFeet.on then table.insert(a,"GHOST") end
            if ghostDeath.on then table.insert(a,"UNDEAD") end
            if autoFlyState.on then table.insert(a,"FLY") end
            infoRefs.active.Text=#a==0 and "none" or table.concat(a,",")
        end)
    end
end end)

local menuOpen=false
local function showMenu()
    if menuOpen then return end
    menuOpen=true playSnd("open")
    main.Visible=true
    main.Size=UDim2.new(0,0,0,0) main.BackgroundTransparency=1
    T:Create(main,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
        {Size=UDim2.new(0,470,0,380),BackgroundTransparency=0.05}):Play()
    stk.Transparency=1 T:Create(stk,TweenInfo.new(0.25),{Transparency=0}):Play()
end
local function hideMenu()
    if not menuOpen then return end
    menuOpen=false playSnd("click")
    local tw=T:Create(main,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),
        {Size=UDim2.new(0,0,0,0),BackgroundTransparency=1})
    tw:Play() tw.Completed:Connect(function() if not menuOpen then main.Visible=false end end)
end
cl.MouseButton1Click:Connect(hideMenu)

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
    end
end)
UIS.InputEnded:Connect(function(i)
    if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and dragging then
        dragging=false
        if not moved then if menuOpen then hideMenu() else showMenu() end end
    end
end)
main.Position=toggleBtn.Position

do local d2,ds2,sp2=false,nil,nil
    hd.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            d2=true ds2=i.Position sp2=main.Position end
    end)
    UIS.InputChanged:Connect(function(i)
        if d2 and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds2
            main.Position=UDim2.new(sp2.X.Scale,sp2.X.Offset+d.X,sp2.Y.Scale,sp2.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d2=false end
    end)
end

local rT=0
RS.RenderStepped:Connect(function(dt)
    rT=tick() cam=workspace.CurrentCamera or cam
    if fovCustom then cam.FieldOfView=fovCustom end

    if acS.on and acS.cps>0 then
        acAcc=acAcc+acS.cps*dt
        local n=math.floor(acAcc) acAcc=acAcc-n
        if n>MAX_PER_FRAME then n=MAX_PER_FRAME end
        for _=1,n do acDoClick() end
    end

    local now=os.clock()
    if now-acLastStat>0.25 then
        acLastStat=now
        while acStamps[1] and now-acStamps[1]>1 do table.remove(acStamps,1) end
    end

    if aimS.on and aimRunning and aimCircle then
        if not aimLocked then aimAcquire() else aimValidate() end
        if aimLocked then
            local char=aimLocked.Character
            local part=char and char:FindFirstChild(aimS.lockPart)
            if part then
                cam.CFrame=CFrame.new(cam.CFrame.Position,part.Position)
                UIS.MouseDeltaSensitivity=0
                aimCircle.Color=aimS.lockedColor
            end
        end
    end

    -- FIX: FOV circle ghim ở tâm màn hình
    if aimCircle and aimS.on then
        aimCircle.Radius=aimS.fovAmount
        aimCircle.Thickness=aimS.fovThickness
        aimCircle.Color=aimLocked and aimS.lockedColor or aimS.fovColor
        aimCircle.Transparency=aimS.fovTransparency
        aimCircle.NumSides=60
        aimCircle.Filled=false
        aimCircle.Visible=aimS.fovVisible
        local vp=cam.ViewportSize
        aimCircle.Position=Vector2.new(vp.X/2,vp.Y/2)
        if aimOriginalSens==nil then aimOriginalSens=UIS.MouseDeltaSensitivity end
    elseif aimCircle then
        aimCircle.Visible=false
    end

    if tg.espName or tg.espHp or tg.espDist or tg.espBody then
        local myChar=pl.Character local myHR=myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myPos=myHR and myHR.Position
        for char,data in pairs(evs) do
            if not char.Parent then destroyESP(char) else
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
                        data.hpFill.BackgroundColor3=hp>0.6 and Color3.fromRGB(0,255,100) or (hp>0.3 and YEL or RED)
                    end
                end
            end
        end
    end

    if acS.on then
        for _,st in ipairs(acStrokes) do st.Transparency=0.1+math.abs(math.sin(rT*4))*0.35 end
    end
end)

local jpSaved=nil
pl.CharacterAdded:Connect(function() jpSaved=nil end)
RS.Heartbeat:Connect(function()
    local c=pl.Character if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid") local hr=c:FindFirstChild("HumanoidRootPart")
    if not h or not hr or h.Health<=0 then return end
    if stt.ws>16 and not autoFlyState.on then
        local md=h.MoveDirection
        if md.Magnitude>0.1 then
            local v=hr.AssemblyLinearVelocity
            hr.AssemblyLinearVelocity=Vector3.new(md.Unit.X*stt.ws,v.Y,md.Unit.Z*stt.ws)
        end
    end
    if stt.jp>50 then
        if not jpSaved then jpSaved={use=h.UseJumpPower,power=h.JumpPower,height=h.JumpHeight} end
        h.UseJumpPower=true h.JumpPower=stt.jp
    elseif jpSaved then
        h.UseJumpPower=jpSaved.use h.JumpPower=jpSaved.power h.JumpHeight=jpSaved.height jpSaved=nil
    end
end)
UIS.JumpRequest:Connect(function()
    if tg.infJump and not autoFlyState.on then
        local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

for _,p in ipairs(P:GetPlayers()) do
    if p~=pl and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then buildESP(p.Character) end
end
applyESPToggles()

local vp=workspace.CurrentCamera.ViewportSize
if type(acS.points)=="table" and #acS.points>0 then
    for _,p in ipairs(acS.points) do
        if type(p)=="table" and p[1] and p[2] then acAddPoint(p[1]*vp.X,p[2]*vp.Y) end
    end
end
if #acFrames==0 then acAddPoint(vp.X/2,vp.Y/2) end

task.spawn(function() while true do task.wait(2)
    pcall(function() fpsLbl.Text=math.floor(frmCnt/2).." FPS" frmCnt=0 end)
end end)

P.PlayerRemoving:Connect(function(p)
    if tpSelected==p then tpSelected=nil tpTargetBtn.Text="  > SELECT PLAYER"
        if autoFlyState.on then autoFlyState.on=false end end
    if p.Character then destroyESP(p.Character) end
end)

switchTab("MOVE")
playSnd("open")
print("[NYT v24] loaded - FOV circle ghim giua man hinh, uu tien target gan tam")

end)

if not ok then
    warn("[NEKO ERROR] "..tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="NEKO ERROR", Text=tostring(err), Duration=15})
    end)
end