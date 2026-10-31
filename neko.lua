local P=game:GetService("Players") local RS=game:GetService("RunService") local UIS=game:GetService("UserInputService") local T=game:GetService("TweenService") local L=game:GetService("Lighting") local TS=game:GetService("TeleportService") local ST=game:GetService("Stats") local HS=game:GetService("HttpService") local pl=P.LocalPlayer local cam=workspace.CurrentCamera

local C={BG=Color3.fromRGB(15,15,20),PANEL=Color3.fromRGB(30,30,40),PINK=Color3.fromRGB(255,20,147),TEXT=Color3.fromRGB(255,255,255),OFF=Color3.fromRGB(60,60,70),GREEN=Color3.fromRGB(0,255,100),YELLOW=Color3.fromRGB(255,200,50),RED=Color3.fromRGB(255,60,60)}

local gp=(gethui and gethui()) or game:GetService("CoreGui")
if gp:FindFirstChild("NekoHack") then gp.NekoHack:Destroy() end
if gp:FindFirstChild("NekoESP") then gp.NekoESP:Destroy() end

local sg=Instance.new("ScreenGui",gp) sg.Name="NekoHack" sg.ResetOnSpawn=false sg.IgnoreGuiInset=true sg.DisplayOrder=9999
local ef=Instance.new("Folder",gp) ef.Name="NekoESP"
local epf=Instance.new("Folder",ef) epf.Name="Players"

local stt={ws=16,hh=10,jp=50,fov=70,wpHeight=3}
local tg={ghost=false,hover=false,espLine=false,espName=false,espHp=false,espDist=false,espBody=false,fps=false,infJump=false,aimE=false,aimA=false,autoFly=false,npcEsp=false}

-- ================= WAYPOINT DATA (5 điểm) =================
local WPF="NekoWP_"..tostring(game.PlaceId)..".json"
local hfa=(writefile~=nil) and (readfile~=nil) and (isfile~=nil)
local wd={height=3,points={{name="WP 1",cf=nil},{name="WP 2",cf=nil},{name="WP 3",cf=nil},{name="WP 4",cf=nil},{name="WP 5",cf=nil}}}

if hfa and isfile(WPF) then 
    pcall(function() 
        local d=HS:JSONDecode(readfile(WPF)) 
        if d then 
            if d.height then wd.height=d.height end 
            if type(d.points)=="table" then 
                for i=1,5 do 
                    if d.points[i] then 
                        if d.points[i].name then wd.points[i].name=d.points[i].name end 
                        if d.points[i].cf then wd.points[i].cf=d.points[i].cf end 
                    end 
                end 
            end 
        end 
    end) 
end
local function svW() if not hfa then return end pcall(function() writefile(WPF,HS:JSONEncode(wd)) end) end

-- ================= UI MENU =================
local main=Instance.new("Frame",sg)
main.Size=UDim2.new(0,700,0,420)
main.Position=UDim2.new(0.5,-350,0.5,-210)
main.BackgroundColor3=C.BG main.BorderSizePixel=0 main.Visible=false main.Active=true main.Draggable=true
Instance.new("UICorner",main).CornerRadius=UDim.new(0,10)
local ms=Instance.new("UIStroke",main) ms.Color=C.PINK ms.Thickness=2

local hd=Instance.new("Frame",main)
hd.Size=UDim2.new(1,0,0,40) hd.BackgroundColor3=C.PANEL hd.BorderSizePixel=0
Instance.new("UICorner",hd).CornerRadius=UDim.new(0,10)
local hFix=Instance.new("Frame",hd) hFix.Size=UDim2.new(1,0,0,10) hFix.Position=UDim2.new(0,0,1,-10) hFix.BackgroundColor3=C.PANEL hFix.BorderSizePixel=0
local title=Instance.new("TextLabel",hd) title.Size=UDim2.new(1,-40,1,0) title.Position=UDim2.new(0,15,0,0) title.BackgroundTransparency=1 title.Text="NEKO HACK" title.Font=Enum.Font.GothamBold title.TextSize=16 title.TextColor3=C.PINK title.TextXAlignment=Enum.TextXAlignment.Left
local xBtn=Instance.new("TextButton",hd) xBtn.Size=UDim2.new(0,30,0,30) xBtn.Position=UDim2.new(1,-35,0.5,-15) xBtn.BackgroundTransparency=1 xBtn.Text="X" xBtn.Font=Enum.Font.GothamBold xBtn.TextSize=18 xBtn.TextColor3=C.PINK xBtn.AutoButtonColor=false
xBtn.MouseButton1Click:Connect(function() main.Visible=false end)

local sb=Instance.new("Frame",main)
sb.Size=UDim2.new(0,130,1,-50) sb.Position=UDim2.new(0,5,0,45) sb.BackgroundColor3=C.PANEL sb.BorderSizePixel=0
Instance.new("UICorner",sb).CornerRadius=UDim.new(0,8)
local sbl=Instance.new("UIListLayout",sb) sbl.Padding=UDim.new(0,5) sbl.SortOrder=Enum.SortOrder.LayoutOrder sbl.HorizontalAlignment=Enum.HorizontalAlignment.Center
local pad=Instance.new("Frame",sb) pad.Size=UDim2.new(1,0,0,5) pad.BackgroundTransparency=1 pad.LayoutOrder=0

local ct=Instance.new("Frame",main)
ct.Size=UDim2.new(1,-145,1,-50) ct.Position=UDim2.new(0,140,0,45) ct.BackgroundColor3=C.PANEL ct.BorderSizePixel=0
Instance.new("UICorner",ct).CornerRadius=UDim.new(0,8)

local tabs={"Movement","ESP","Player","Follow","NPC","Info"}
local pg={}
for i,n in ipairs(tabs) do
    local p=Instance.new("ScrollingFrame",ct)
    p.Size=UDim2.new(1,-10,1,-10) p.Position=UDim2.new(0,5,0,5)
    p.BackgroundTransparency=1 p.BorderSizePixel=0 p.ScrollBarThickness=3 p.ScrollBarImageColor3=C.PINK
    p.AutomaticCanvasSize=Enum.AutomaticSize.Y p.Visible=(i==1)
    local l=Instance.new("UIListLayout",p) l.Padding=UDim.new(0,5) l.SortOrder=Enum.SortOrder.LayoutOrder
    pg[n]=p
end

local tb={}
local function swT(name)
    for n,p in pairs(pg) do p.Visible=(n==name) end
    for n,b in pairs(tb) do
        if n==name then b.f.BackgroundColor3=C.PINK b.f.TextColor3=Color3.new(1,1,1) else b.f.BackgroundColor3=C.BG b.f.TextColor3=C.TEXT end
    end
end
for i,n in ipairs(tabs) do
    local t=Instance.new("TextButton",sb)
    t.Size=UDim2.new(1,-10,0,35) t.BackgroundColor3=C.BG t.BorderSizePixel=0 t.Text=n t.Font=Enum.Font.GothamBold t.TextSize=13 t.TextColor3=C.TEXT t.LayoutOrder=i
    Instance.new("UICorner",t).CornerRadius=UDim.new(0,6)
    t.MouseButton1Click:Connect(function() swT(n) end)
    tb[n]={f=t}
end

-- ================= UI HELPERS =================
local function mkSec(pr,txt)
    local s=Instance.new("Frame",pr) s.Size=UDim2.new(1,0,0,20) s.BackgroundTransparency=1 s.LayoutOrder=#pr:GetChildren()*10
    local l=Instance.new("TextLabel",s) l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=1 l.Text=txt l.Font=Enum.Font.GothamBold l.TextSize=12 l.TextColor3=C.PINK l.TextXAlignment=Enum.TextXAlignment.Left
end
local function mkTog(pr,nm,cbf)
    local c=Instance.new("Frame",pr) c.Size=UDim2.new(1,-4,0,36) c.BackgroundColor3=C.BG c.BorderSizePixel=0 c.LayoutOrder=#pr:GetChildren()*10
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel",c) l.Size=UDim2.new(1,-70,1,0) l.Position=UDim2.new(0,10,0,0) l.BackgroundTransparency=1 l.Text=nm l.Font=Enum.Font.Gotham l.TextSize=12 l.TextColor3=C.TEXT l.TextXAlignment=Enum.TextXAlignment.Left
    local p=Instance.new("TextButton",c) p.Size=UDim2.new(0,50,0,24) p.Position=UDim2.new(1,-60,0.5,-12) p.BackgroundColor3=C.OFF p.BorderSizePixel=0 p.Text="OFF" p.Font=Enum.Font.GothamBold p.TextSize=10 p.TextColor3=C.TEXT
    Instance.new("UICorner",p).CornerRadius=UDim.new(1,0)
    local s=false
    p.MouseButton1Click:Connect(function()
        s=not s
        if s then p.BackgroundColor3=C.GREEN p.Text="ON" p.TextColor3=Color3.new(0,0,0) else p.BackgroundColor3=C.OFF p.Text="OFF" p.TextColor3=C.TEXT end
        if cbf then pcall(cbf,s) end
    end)
end
local function mkSli(pr,nm,mn,mx,dv,cbf)
    local c=Instance.new("Frame",pr) c.Size=UDim2.new(1,-4,0,40) c.BackgroundColor3=C.BG c.BorderSizePixel=0 c.LayoutOrder=#pr:GetChildren()*10
    Instance.new("UICorner",c).CornerRadius=UDim.new(0,6)
    local l=Instance.new("TextLabel",c) l.Size=UDim2.new(1,-20,0,16) l.Position=UDim2.new(0,10,0,4) l.BackgroundTransparency=1 l.Text=nm..": "..tostring(dv) l.Font=Enum.Font.Gotham l.TextSize=12 l.TextColor3=C.TEXT l.TextXAlignment=Enum.TextXAlignment.Left
    local tr=Instance.new("Frame",c) tr.Size=UDim2.new(1,-20,0,6) tr.Position=UDim2.new(0,10,0,26) tr.BackgroundColor3=C.OFF tr.BorderSizePixel=0
    Instance.new("UICorner",tr).CornerRadius=UDim.new(1,0)
    local pc=math.clamp((dv-mn)/(mx-mn),0,1)
    local f=Instance.new("Frame",tr) f.Size=UDim2.new(pc,0,1,0) f.BackgroundColor3=C.PINK f.BorderSizePixel=0
    Instance.new("UICorner",f).CornerRadius=UDim.new(1,0)
    local bt=Instance.new("TextButton",tr) bt.Size=UDim2.new(1,0,4,0) bt.Position=UDim2.new(0,0,-1.5,0) bt.BackgroundTransparency=1 bt.Text=""
    local drg=false
    local function up(x)
        local p=math.clamp((x-tr.AbsolutePosition.X)/tr.AbsoluteSize.X,0,1)
        f.Size=UDim2.new(p,0,1,0)
        local v=minV or (mn+(mx-mn)*p)
        v=math.floor(v + 0.5)
        l.Text=nm..": "..tostring(v)
        if cbf then cbf(v) end
    end
    bt.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=true up(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if drg and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then up(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drg=false end end)
end
local function mkBtn(pr,nm,cbf)
    local b=Instance.new("TextButton",pr) b.Size=UDim2.new(1,-4,0,34) b.BackgroundColor3=C.BG b.BorderSizePixel=0 b.Text=nm b.Font=Enum.Font.GothamBold b.TextSize=12 b.TextColor3=C.TEXT b.LayoutOrder=#pr:GetChildren()*10
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function() if cbf then pcall(cbf) end end)
    return b
end

-- ================= CHỨC NĂNG =================
local function teleportTo(pos)
    local c=pl.Character if not c then return end
    local hr=c:FindFirstChild("HumanoidRootPart") if not hr then return end
    pcall(function() hr:SetNetworkOwner(pl) end) task.wait(0.1)
    hr.AssemblyLinearVelocity=Vector3.zero hr.AssemblyAngularVelocity=Vector3.zero
    local tgt=CFrame.new(pos+Vector3.new(0,3,0))
    hr.CFrame=tgt RS.Heartbeat:Wait()
    pcall(function() hr:SetNetworkOwner(pl) end) hr.CFrame=tgt hr.AssemblyLinearVelocity=Vector3.zero
end

-- 1. MOVEMENT
mkSec(pg.Movement,"// MOVEMENT")
mkSli(pg.Movement,"Walk Speed",16,200,16,function(v) stt.ws=v end)
mkSli(pg.Movement,"Jump Power",50,300,50,function(v) stt.jp=v end)
mkTog(pg.Movement,"Infinite Jump",function(on) tg.infJump=on end)
mkSli(pg.Movement,"Hover Height",2,20,10,function(v) stt.hh=v end)
mkTog(pg.Movement,"Chân Ma (Lơ lửng)",function(on) tg.hover=on end)

-- 2. ESP
mkSec(pg.ESP,"// ESP PLAYER")
mkTog(pg.ESP,"ESP Line",function(on) tg.espLine=on end)
mkTog(pg.ESP,"ESP Name",function(on) tg.espName=on applyESPToggles() end)
mkTog(pg.ESP,"ESP Health",function(on) tg.espHp=on applyESPToggles() end)
mkTog(pg.ESP,"ESP Distance",function(on) tg.espDist=on applyESPToggles() end)
mkTog(pg.ESP,"ESP Body (Hologram)",function(on) tg.espBody=on applyESPToggles() end)

-- 3. PLAYER
mkSec(pg.Player,"// PLAYER")
mkTog(pg.Player,"Ghost (Xuyên tường)",function(on) tg.ghost=on tGhost(on) end)
mkTog(pg.Player,"FPS Boost",function(on) tg.fps=on tFPS(on) end)
mkTog(pg.Player,"Aimlock Enemy",function(on) tg.aimE=on end)
mkTog(pg.Player,"Aimlock All",function(on) tg.aimA=on end)
mkSli(pg.Player,"FOV",70,120,70,function(v) cam.FieldOfView=v end)
mkBtn(pg.Player,"Reset Character",function() local c=pl.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Health=0 end end end)
mkBtn(pg.Player,"Rejoin Server",function() pcall(function() TS:TeleportToPlaceInstance(game.PlaceId,game.JobId,pl) end) end)

-- 4. FOLLOW (AUTO FLY + WAYPOINT)
mkSec(pg.Follow,"// AUTO FLY")
local fTarget=nil
local fListFrame=Instance.new("Frame",pg.Follow) fListFrame.Size=UDim2.new(1,-4,0,0) fListFrame.AutomaticSize=Enum.AutomaticSize.Y fListFrame.BackgroundColor3=C.BG fListFrame.LayoutOrder=#pg.Follow:GetChildren()*10
Instance.new("UICorner",fListFrame).CornerRadius=UDim.new(0,6)
local fLay=Instance.new("UIListLayout",fListFrame) fLay.Padding=UDim.new(0,2) fLay.SortOrder=Enum.SortOrder.LayoutOrder
local fBtn=mkBtn(pg.Follow,"CHỌN PLAYER",function()
    for _,c in ipairs(fListFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for i,p in ipairs(P:GetPlayers()) do
        if p~=pl then
            local r=Instance.new("TextButton",fListFrame) r.Size=UDim2.new(1,-8,0,24) r.BackgroundColor3=C.OFF r.BorderSizePixel=0 r.Text="> "..p.Name r.Font=Enum.Font.Gotham r.TextSize=12 r.TextColor3=C.TEXT r.TextXAlignment=Enum.TextXAlignment.Left r.LayoutOrder=i
            Instance.new("UICorner",r).CornerRadius=UDim.new(0,4)
            r.MouseButton1Click:Connect(function() fTarget=p fBtn.Text="MỤC TIÊU: "..p.Name end)
        end
    end
end)
mkTog(pg.Follow,"BẬT AUTO FLY",function(on) tg.autoFly=on end)

mkSec(pg.Follow,"// WAYPOINTS (5 Điểm)")
mkSli(pg.Follow,"Độ cao TP",-10,30,3,function(v) stt.wpHeight=v end)
for i=1,5 do
    local idx=i
    local pt=wd.points[idx]
    local row=Instance.new("Frame",pg.Follow) row.Size=UDim2.new(1,-4,0,35) row.BackgroundColor3=C.BG row.LayoutOrder=#pg.Follow:GetChildren()*10
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    
    local txt=Instance.new("TextBox",row) txt.Size=UDim2.new(0,100,0,24) txt.Position=UDim2.new(0,5,0.5,-12) txt.BackgroundColor3=C.OFF txt.BorderSizePixel=0 txt.Text=" "..pt.name txt.Font=Enum.Font.Gotham txt.TextSize=12 txt.TextColor3=C.TEXT txt.ClearTextOnFocus=false
    Instance.new("UICorner",txt).CornerRadius=UDim.new(0,4)
    txt.FocusLost:Connect(function() pt.name=string.gsub(txt.Text,"^%s+","") svW() end)
    
    local setB=Instance.new("TextButton",row) setB.Size=UDim2.new(0,35,0,24) setB.Position=UDim2.new(1,-120,0.5,-12) setB.BackgroundColor3=pt.cf and C.GREEN or C.PINK setB.BorderSizePixel=0 setB.Text="SET" setB.Font=Enum.Font.GothamBold setB.TextSize=11 setB.TextColor3=pt.cf and Color3.new(0,0,0) or C.TEXT
    Instance.new("UICorner",setB).CornerRadius=UDim.new(0,4)
    
    local tpB=Instance.new("TextButton",row) tpB.Size=UDim2.new(0,45,0,24) tpB.Position=UDim2.new(1,-80,0.5,-12) tpB.BackgroundColor3=C.PINK tpB.BorderSizePixel=0 tpB.Text="TELE" tpB.Font=Enum.Font.GothamBold tpB.TextSize=11 tpB.TextColor3=C.TEXT
    Instance.new("UICorner",tpB).CornerRadius=UDim.new(0,4)
    
    local xB=Instance.new("TextButton",row) xB.Size=UDim2.new(0,25,0,24) xB.Position=UDim2.new(1,-30,0.5,-12) xB.BackgroundColor3=C.RED xB.BorderSizePixel=0 xB.Text="X" xB.Font=Enum.Font.GothamBold xB.TextSize=11 xB.TextColor3=C.TEXT
    Instance.new("UICorner",xB).CornerRadius=UDim.new(0,4)
    
    setB.MouseButton1Click:Connect(function()
        local c=pl.Character if not c then return end local hr=c:FindFirstChild("HumanoidRootPart") if not hr then return end
        pt.cf={hr.CFrame:GetComponents()} svW() setB.BackgroundColor3=C.GREEN setB.TextColor3=Color3.new(0,0,0)
    end)
    tpB.MouseButton1Click:Connect(function()
        if not pt.cf then return end
        local cc=pt.cf
        local sc=CFrame.new(cc[1],cc[2],cc[3],cc[4],cc[5],cc[6],cc[7],cc[8],cc[9],cc[10],cc[11],cc[12])
        teleportTo(sc.Position+Vector3.new(0,stt.wpHeight,0))
    end)
    xB.MouseButton1Click:Connect(function()
        pt.cf=nil svW() setB.BackgroundColor3=C.PINK setB.TextColor3=C.TEXT
    end)
end

-- 5. NPC
mkSec(pg.NPC,"// NPC ESP")
mkTog(pg.NPC,"Bật tô màu NPC",function(on) tg.npcEsp=on end)

-- 6. INFO
local ip=pg.Info
local function mkIR(pr,lb) local r=Instance.new("Frame",pr) r.Size=UDim2.new(1,-4,0,20) r.BackgroundTransparency=1 r.LayoutOrder=#pr:GetChildren()*10 local l=Instance.new("TextLabel",r) l.Size=UDim2.new(0.5,0,1,0) l.BackgroundTransparency=1 l.Text=" "..lb l.Font=Enum.Font.Gotham l.TextSize=11 l.TextColor3=Color3.fromRGB(150,150,150) l.TextXAlignment=Enum.TextXAlignment.Left local v=Instance.new("TextLabel",r) v.Size=UDim2.new(0.5,0,1,0) v.Position=UDim2.new(0.5,0,0,0) v.BackgroundTransparency=1 v.Text="..." v.Font=Enum.Font.GothamBold v.TextSize=11 v.TextColor3=C.TEXT v.TextXAlignment=Enum.TextXAlignment.Right return v end
local wF=mkIR(ip,"FPS") local wP=mkIR(ip,"PING") local wH=mkIR(ip,"HEALTH") local wPl=mkIR(ip,"PLAYERS") local wU=mkIR(ip,"UPTIME") local wEn=mkIR(ip,"ENTITIES")

-- ================= LOGIC (HEARTBEAT) =================
local function applyESPToggles()
    for char,data in pairs(evs) do
        if char.Parent then
            data.nameLbl.Visible=tg.espName
            data.distLbl.Visible=tg.espDist
            data.hpBB.Enabled=tg.espHp
            data.fxBB.Enabled=tg.espBody
            data.hl.Enabled=tg.espBody
            data.infoBB.Enabled=(tg.espName or tg.espDist)
        end
    end
end

local function tGhost(on)
    local ch=pl.Character if not ch then return end
    local h=ch:FindFirstChildOfClass("Humanoid") if not h then return end
    if on then
        for _,pt in ipairs(ch:GetDescendants()) do
            if pt:IsA("BasePart") then pt.CanCollide=false pt.CanQuery=false pt.CanTouch=false pt.LocalTransparencyModifier=1 end
        end
    else
        for _,pt in ipairs(ch:GetDescendants()) do
            if pt:IsA("BasePart") then pt.CanCollide=true pt.CanQuery=true pt.CanTouch=true pt.LocalTransparencyModifier=0 end
        end
    end
end

local function tFPS(on)
    if on then
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Fire") or o:IsA("Smoke") then o.Enabled=false end
        end
        L.GlobalShadows=false L.FogEnd=1000
    else
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Fire") or o:IsA("Smoke") then o.Enabled=true end
        end
        L.GlobalShadows=true L.FogEnd=100000
    end
end

-- ESP Logic
local evs={}
local trcs={}
local function buildESP(char)
    if not char or char==pl.Character then return end
    task.spawn(function()
        local hr=char:WaitForChild("HumanoidRootPart",5) if not hr then return end
        local head=char:FindFirstChild("Head") or hr
        if evs[char] then evs[char].folder:Destroy() evs[char]=nil end
        local fold=Instance.new("Folder",epf) fold.Name=char.Name
        local hl=Instance.new("Highlight",fold) hl.Adornee=char hl.FillColor=C.PINK hl.FillTransparency=0.8 hl.OutlineColor=C.PINK hl.OutlineTransparency=0 hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
        
        local info=Instance.new("BillboardGui",fold) info.Adornee=head info.Size=UDim2.new(0,200,0,40) info.StudsOffset=Vector3.new(0,2.5,0) info.AlwaysOnTop=true
        local n=Instance.new("TextLabel",info) n.Size=UDim2.new(1,0,0,25) n.BackgroundTransparency=1 n.Text=char.Name n.TextColor3=C.PINK n.Font=Enum.Font.GothamBold n.TextSize=18 n.TextStrokeTransparency=0.2
        local d=Instance.new("TextLabel",info) d.Size=UDim2.new(1,0,0,15) d.Position=UDim2.new(0,0,0,25) d.BackgroundTransparency=1 d.Text="0m" d.TextColor3=C.YELLOW d.Font=Enum.Font.Gotham n.TextSize=12
        
        local hpBB=Instance.new("BillboardGui",fold) hpBB.Adornee=hr hpBB.Size=UDim2.new(0,10,0,60) hpBB.StudsOffset=Vector3.new(2,0,0) hpBB.AlwaysOnTop=true
        local hpBg=Instance.new("Frame",hpBB) hpBg.Size=UDim2.new(1,0,1,0) hpBg.BackgroundColor3=C.OFF Instance.new("UICorner",hpBg).CornerRadius=UDim.new(0,4)
        local hpF=Instance.new("Frame",hpBg) hpF.AnchorPoint=Vector2.new(0,1) hpF.Position=UDim2.new(0,0,1,0) hpF.Size=UDim2.new(1,0,1,0) hpF.BackgroundColor3=C.GREEN Instance.new("UICorner",hpF).CornerRadius=UDim.new(0,4)
        
        evs[char]={folder=fold,hl=hl,infoBB=info,nameLbl=n,distLbl=d,hpBB=hpBB,hpFill=hpF,fxBB=Instance.new("BillboardGui")}
    end)
end

-- NPC ESP Logic
local function scanNPCs()
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
            local isP=false
            for _,p in ipairs(P:GetPlayers()) do if p.Character==obj then isP=true break end end
            if not isP then
                if not obj:FindFirstChild("NekoNPCHL") then
                    local h=Instance.new("Highlight",obj) h.Name="NekoNPCHL" h.FillColor=C.YELLOW h.OutlineColor=Color3.new(1,1,1) h.FillTransparency=0.6 h.OutlineTransparency=0 h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                end
            end
        end
    end
end

-- ================= RENDER LOOPS =================
RS.Heartbeat:Connect(function()
    local c=pl.Character if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid") local hr=c:FindFirstChild("HumanoidRootPart")
    if not h or not hr then return end
    
    -- WalkSpeed
    if not tg.hover then h.WalkSpeed = (stt.ws>16) and stt.ws or 16 end
    if stt.jp>50 then h.UseJumpPower=true h.JumpPower=stt.jp end
    
    -- Hover
    if tg.hover then
        h.HipHeight=stt.hh h:SetStateEnabled(Enum.HumanoidStateType.Falling,false) h:SetStateEnabled(Enum.HumanoidStateType.Freefall,false) pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end)
    else
        if h.HipHeight>2 then h.HipHeight=2 end
        h:SetStateEnabled(Enum.HumanoidStateType.Falling,true) h:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
    end
    
    -- Auto Fly
    if tg.autoFly and fTarget and fTarget.Character then
        local tHrp=fTarget.Character:FindFirstChild("HumanoidRootPart")
        if tHrp then
            local targetPos=tHrp.Position + (tHrp.CFrame.LookVector * -4) + Vector3.new(0,3,0)
            local dir=(targetPos - hr.Position)
            if dir.Magnitude > 1 then
                hr.AssemblyLinearVelocity = dir.Unit * math.clamp(dir.Magnitude * 5, 0, 60)
                h:SetStateEnabled(Enum.HumanoidStateType.Falling,false)
            else
                hr.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

-- ESP Update & NPC Scan
local scanCD=0
local espCD=0
RS.Heartbeat:Connect(function()
    local t=tick()
    -- NPC Scan
    if tg.npcEsp and t-scanCD>2 then
        scanCD=t
        scanNPCs()
    elseif not tg.npcEsp and t-scanCD>0 then
        scanCD=t
        for _,o in ipairs(workspace:GetDescendants()) do if o.Name=="NekoNPCHL" then o:Destroy() end end
    end
    
    -- ESP Player Update
    if tg.espName or tg.espHp or tg.espDist or tg.espBody or tg.espLine then
        local myPos=pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") and pl.Character.HumanoidRootPart.Position
        for _,p in ipairs(P:GetPlayers()) do
            if p~=pl and p.Character then
                if not evs[p.Character] then buildESP(p.Character) end
                if evs[p.Character] and myPos then
                    local hr2=p.Character:FindFirstChild("HumanoidRootPart") local h2=p.Character:FindFirstChildOfClass("Humanoid")
                    if hr2 and h2 then
                        if tg.espDist then evs[p.Character].distLbl.Text=string.format("%.1fm",(hr2.Position-myPos).Magnitude/3.57) end
                        if tg.espHp then local hp=math.clamp(h2.Health/h2.MaxHealth,0,1) evs[p.Character].hpFill.Size=UDim2.new(1,0,hp,0) evs[p.Character].hpFill.BackgroundColor3=hp>0.6 and C.GREEN or (hp>0.3 and C.YELLOW or C.RED) end
                    end
                end
            end
        end
    end
end)

-- Aimlock
RS.RenderStepped:Connect(function()
    if tg.aimE or tg.aimA then
        local c=pl.Character if not c or not c:FindFirstChild("HumanoidRootPart") then return end
        local hds={} for _,p in ipairs(P:GetPlayers()) do if p~=pl and p.Character then local hd=p.Character:FindFirstChild("Head") local h=p.Character:FindFirstChildOfClass("Humanoid") if hd and h and h.Health>0 then local isE=true if p.Team and pl.Team and p.Team==pl.Team then isE=false end if tg.aimA or (tg.aimE and isE) then table.insert(hds,hd) end end end end
        if #hds>0 then
            local cn=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2) local bt,bd=nil,math.huge
            for _,h in ipairs(hds) do local sp,on2=cam:WorldToViewportPoint(h.Position) if on2 then local dd=(Vector2.new(sp.X,sp.Y)-cn).Magnitude if dd<bd then bd=dd bt=h end end end
            if bt then cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,bt.Position),0.3) end
        end
    end
end)

-- Info Loop
local stT=tick()
local fCnt=0 RS.RenderStepped:Connect(function() fCnt=fCnt+1 end)
task.spawn(function()
    while true do
        task.wait(1)
        wF.Text = fCnt.." FPS" fCnt=0
        wP.Text = math.floor(pl:GetNetworkPing()*1000).." ms"
        if pl.Character then local h=pl.Character:FindFirstChildOfClass("Humanoid") if h then wH.Text=math.floor(h.Health).."/"..math.floor(h.MaxHealth) end end
        wPl.Text = #P:GetPlayers().."/"..P.MaxPlayers
        local u=math.floor(tick()-stT) wU.Text=math.floor(u/60).."m "..(u%60).."s"
        wEn.Text = #workspace:GetChildren().." obj"
    end
end)

UIS.JumpRequest:Connect(function() if tg.infJump then local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid") if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end end)

-- ================= BONG BÓNG ĐƠN GIẢN =================
local orb=Instance.new("Frame",sg)
orb.Size=UDim2.new(0,70,0,70) orb.Position=UDim2.new(0,30,0,100) orb.BackgroundColor3=C.PINK orb.BorderSizePixel=0
Instance.new("UICorner",orb).CornerRadius=UDim.new(1,0)
local orbStroke=Instance.new("UIStroke",orb) orbStroke.Color=Color3.new(1,1,1) orbStroke.Thickness=3
local orbImg=Instance.new("ImageLabel",orb)
orbImg.Size=UDim2.new(1,-6,1,-6) orbImg.Position=UDim2.new(0.5,0,0.5,0) orbImg.AnchorPoint=Vector2.new(0.5,0.5) orbImg.BackgroundTransparency=1 orbImg.Image="rbxthumb://type=Asset&id=82041614098010&w=150&h=150"
Instance.new("UICorner",orbImg).CornerRadius=UDim.new(1,0)

local drOrb=false local obX,obY=30,100 local dsPos,sOrb
orb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drOrb=true dsPos=i.Position obX=orb.Position.X.Offset obY=orb.Position.Y.Offset sOrb=Vector2.new(obX,obY) end end)
UIS.InputChanged:Connect(function(i) if drOrb and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then local d=i.Position-dsPos orb.Position=UDim2.new(0,sOrb.X+d.X,0,sOrb.Y+d.Y) end end)
orb.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then if (i.Position-dsPos).Magnitude<5 then main.Visible=not main.Visible end drOrb=false end end)

swT("Movement")
print("NEKO LOADED - SIMPLE")