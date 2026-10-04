-- ==================================================================
-- ========================= NYT MODS V3 =============================
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

local G=Color3.fromRGB(0,255,120) local G2=Color3.fromRGB(0,180,80) local G3=Color3.fromRGB(200,255,220)
local DIM=Color3.fromRGB(0,80,40) local BG=Color3.fromRGB(5,10,8) local BG2=Color3.fromRGB(8,18,12)
local TX=Color3.fromRGB(180,255,200) local CY=Color3.fromRGB(0,255,255)
local RED=Color3.fromRGB(255,60,80) local YEL=Color3.fromRGB(255,220,100) local ORG=Color3.fromRGB(255,150,50)

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

-- ===== SOUND: ASMR bàn phím cơ ("lục cục") =====
-- Tự tạo file WAV tiếng gõ phím (cạch + thock) rồi phát bằng getcustomasset.
-- Executor không hỗ trợ writefile/getcustomasset thì dùng tạm âm thanh có sẵn của Roblox.
local SS=game:GetService("SoundService")
local SND={on=true,vol=0.6}
local KB={down={},up={},space={}}
local KBVAR={down=4,up=3,space=3}
local FALLBACK={down="rbxasset://sounds/clickfast.wav",up="rbxasset://sounds/clickfast.wav",space="rbxasset://sounds/button.wav"}

local function buildWav(kind,seed)
    local rate=22050
    local dur=(kind=="down" and 0.09) or (kind=="up" and 0.055) or 0.14
    local n=math.floor(rate*dur)
    local rng=Random.new(seed)
    local f1=(kind=="space") and rng:NextNumber(110,135) or rng:NextNumber(170,215)
    local f2=f1*2.3
    local prev=0
    local out={}
    for i=0,n-1 do
        local t=i/rate
        local nz=rng:NextNumber(-1,1)
        local hp=nz-prev prev=nz
        local v
        if kind=="down" then
            v=hp*math.exp(-t*110)*0.55+math.sin(2*math.pi*f1*t)*math.exp(-t*48)*0.55+math.sin(2*math.pi*f2*t)*math.exp(-t*80)*0.2
        elseif kind=="up" then
            v=hp*math.exp(-t*170)*0.35+math.sin(2*math.pi*(f1*2.2)*t)*math.exp(-t*110)*0.18
        else
            v=hp*math.exp(-t*80)*0.45+math.sin(2*math.pi*f1*t)*math.exp(-t*26)*0.8+math.sin(2*math.pi*f2*t)*math.exp(-t*60)*0.25
        end
        if i<24 then v=v*(i/24) end
        v=math.clamp(v,-1,1)
        out[#out+1]=string.pack("<i2",math.floor(v*30000))
    end
    local data=table.concat(out)
    return "RIFF"..string.pack("<I4",36+#data).."WAVEfmt "..string.pack("<I4I2I2I4I4I2I2",16,1,1,rate,rate*2,2,16).."data"..string.pack("<I4",#data)..data
end

task.spawn(function()
    local getAsset=getcustomasset or getsynasset
    if not (writefile and isfile and getAsset) then return end
    for kind,cnt in pairs(KBVAR) do
        for i=1,cnt do
            local name="NekoKB_v1_"..kind..i..".wav"
            local ok,res=pcall(function()
                if not isfile(name) then
                    writefile(name,buildWav(kind,i*97+(kind=="up" and 7 or (kind=="space" and 13 or 0))))
                end
                return getAsset(name)
            end)
            if ok and type(res)=="string" and res~="" then table.insert(KB[kind],res) end
            task.wait()
        end
    end
end)

local function playKey(kind,vol,pitch)
    if not SND.on then return end
    pcall(function()
        local list=KB[kind]
        local custom=#list>0
        local sd=Instance.new("Sound")
        sd.SoundId=custom and list[math.random(1,#list)] or FALLBACK[kind]
        sd.Volume=math.clamp(SND.vol*(vol or 1)*(0.85+math.random()*0.3),0,2)
        local pit=(pitch or 1)*(0.94+math.random()*0.12)
        if not custom then
            if kind=="up" then pit=pit*0.75 elseif kind=="space" then pit=pit*0.55 end
        end
        sd.PlaybackSpeed=pit
        sd.Parent=SS
        sd:Play()
        task.delay(1.2,function() sd:Destroy() end)
    end)
end
local function keystroke(vol,pitch,space)
    playKey(space and "space" or "down",vol,pitch)
    task.delay(0.045+math.random()*0.05,function() playKey("up",vol*0.6,pitch) end)
end
local function playSnd(name,pitch)
    if not SND.on then return end
    if name=="click" then keystroke(1,pitch)
    elseif name=="tick" then playKey("down",0.45,pitch or 1.15)
    elseif name=="on" then keystroke(1.1,1.05,true)
    elseif name=="off" then keystroke(1,0.9,true)
    elseif name=="open" then
        task.spawn(function()
            for _=1,5 do keystroke(0.7+math.random()*0.3,1+math.random()*0.15) task.wait(0.055+math.random()*0.05) end
            keystroke(1.1,0.95,true)
        end)
    end
end

local ef=Instance.new("Folder",gp) ef.Name="NekoESP"
local epf=Instance.new("Folder",ef) epf.Name="Players"

local stt={ws=16,jp=50}
local tg={espLine=false,espName=false,espHp=false,espDist=false,espBody=false,
    noclip=false,mapBright=false,fps=false,infJump=false,antiKB=true}

local teleportTo
local fovCustom=nil
local nlSafe=nil local nlGroundT=0

local hfa=(writefile~=nil) and (readfile~=nil) and (isfile~=nil)
local WPF="NekoWPs_"..tostring(game.PlaceId)..".json"
local wps = {nil,nil,nil,nil,nil,nil,nil,nil}
local wpHeight = 3

if hfa and isfile(WPF) then
    pcall(function()
        local d=HS:JSONDecode(readfile(WPF))
        if d then
            if type(d.height)=="number" then wpHeight=d.height end
            if type(d.wps)=="table" then
                for i=1,8 do
                    local w=d.wps[tostring(i)] or d.wps[i]
                    if type(w)=="table" then wps[i]=w end
                end
            end
        end
    end)
end
local function saveWPs()
    if not hfa then return end
    pcall(function()
        local out={}
        for i=1,8 do if wps[i] then out[tostring(i)]=wps[i] end end
        writefile(WPF,HS:JSONEncode({height=wpHeight,wps=out}))
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
main.Size=UDim2.new(0,470,0,380) main.Position=UDim2.new(0,30,0,120)
main.BackgroundColor3=BG main.BackgroundTransparency=0.05
main.BorderSizePixel=0 main.Active=true main.Visible=false main.ZIndex=100
Instance.new("UICorner",main).CornerRadius=UDim.new(0,4)
local stk=Instance.new("UIStroke",main) stk.Color=G stk.Thickness=1.5
local stkGlow=Instance.new("UIStroke",main) stkGlow.Color=G stkGlow.Thickness=5 stkGlow.Transparency=0.85
local stkGrad=Instance.new("UIGradient",stk)
stkGrad.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,G),ColorSequenceKeypoint.new(0.5,CY),ColorSequenceKeypoint.new(1,G)})

-- ===== HUD DECOR: góc khung + tia quét (scanline) =====
local brackets={}
local function corner(ax,ay)
    local ox=(ax==0) and -3 or 3
    local oy=(ay==0) and -3 or 3
    local hz=Instance.new("Frame",main)
    hz.Size=UDim2.new(0,18,0,2) hz.AnchorPoint=Vector2.new(ax,ay) hz.Position=UDim2.new(ax,ox,ay,oy)
    hz.BackgroundColor3=CY hz.BorderSizePixel=0 hz.ZIndex=130
    local vz=Instance.new("Frame",main)
    vz.Size=UDim2.new(0,2,0,18) vz.AnchorPoint=Vector2.new(ax,ay) vz.Position=UDim2.new(ax,ox,ay,oy)
    vz.BackgroundColor3=CY vz.BorderSizePixel=0 vz.ZIndex=130
    table.insert(brackets,hz) table.insert(brackets,vz)
end
corner(0,0) corner(1,0) corner(0,1) corner(1,1)

local scanClip=Instance.new("Frame",main)
scanClip.Size=UDim2.new(1,-4,1,-4) scanClip.Position=UDim2.new(0,2,0,2)
scanClip.BackgroundTransparency=1 scanClip.ClipsDescendants=true scanClip.ZIndex=140
local scan=Instance.new("Frame",scanClip)
scan.Size=UDim2.new(1,0,0,26) scan.Position=UDim2.new(0,0,0,-30)
scan.BackgroundColor3=G scan.BackgroundTransparency=0.82 scan.BorderSizePixel=0 scan.ZIndex=141
local scanGrad=Instance.new("UIGradient",scan) scanGrad.Rotation=90
scanGrad.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(0.5,0),NumberSequenceKeypoint.new(1,1)})

-- ===== MATRIX RAIN =====
local rainFrame=Instance.new("Frame",main)
rainFrame.Size=UDim2.new(1,-4,1,-4) rainFrame.Position=UDim2.new(0,2,0,2)
rainFrame.BackgroundTransparency=1 rainFrame.ClipsDescendants=true rainFrame.ZIndex=1
local rainCols={}
local HEXC="0123456789ABCDEF"
local function rainStr(n)
    local t={}
    for j=1,n do local k=math.random(1,16) t[j]=string.sub(HEXC,k,k) end
    return table.concat(t,"\n")
end
for i=1,16 do
    local lbl=Instance.new("TextLabel",rainFrame)
    lbl.Size=UDim2.new(0,12,0,400) lbl.Position=UDim2.new(0,(i-1)*29+6,0,-math.random(0,380))
    lbl.BackgroundTransparency=1 lbl.Text=rainStr(26) lbl.Font=Enum.Font.Code lbl.TextSize=11
    lbl.TextColor3=G2 lbl.TextTransparency=0.8 lbl.TextYAlignment=Enum.TextYAlignment.Top lbl.ZIndex=1
    table.insert(rainCols,{lbl=lbl,offset=-math.random(0,380),speed=30+math.random()*60})
end

local hd=Instance.new("Frame",main)
hd.Size=UDim2.new(1,0,0,28) hd.BackgroundColor3=BG2 hd.BorderSizePixel=0 hd.ZIndex=110
Instance.new("UICorner",hd).CornerRadius=UDim.new(0,4)
local hdFix=Instance.new("Frame",hd)
hdFix.Size=UDim2.new(1,0,0,6) hdFix.Position=UDim2.new(0,0,1,-6)
hdFix.BackgroundColor3=BG2 hdFix.BorderSizePixel=0 hdFix.ZIndex=111

local title=Instance.new("TextLabel",hd)
title.Size=UDim2.new(1,-50,1,0) title.Position=UDim2.new(0,10,0,0)
title.BackgroundTransparency=1 title.Text="" title.Font=Enum.Font.Code title.TextSize=13
title.TextColor3=G title.TextXAlignment=Enum.TextXAlignment.Left title.ZIndex=112

local cursor=Instance.new("TextLabel",hd)
cursor.Size=UDim2.new(0,10,1,0) cursor.Position=UDim2.new(1,-76,0,0)
cursor.BackgroundTransparency=1 cursor.Text="█" cursor.Font=Enum.Font.Code cursor.TextSize=13
cursor.TextColor3=G cursor.ZIndex=112

local cl=Instance.new("TextButton",hd)
cl.Size=UDim2.new(0,24,0,24) cl.Position=UDim2.new(1,-28,.5,-12)
cl.BackgroundTransparency=1 cl.Text="✕" cl.Font=Enum.Font.Code cl.TextSize=16
cl.TextColor3=RED cl.AutoButtonColor=false cl.ZIndex=113

local sndBtn=Instance.new("TextButton",hd)
sndBtn.Size=UDim2.new(0,24,0,24) sndBtn.Position=UDim2.new(1,-54,.5,-12)
sndBtn.BackgroundTransparency=1 sndBtn.Text="♪" sndBtn.Font=Enum.Font.Code sndBtn.TextSize=16
sndBtn.TextColor3=G sndBtn.AutoButtonColor=false sndBtn.ZIndex=113
sndBtn.MouseButton1Click:Connect(function()
    SND.on=not SND.on
    sndBtn.TextColor3=SND.on and G or DIM
    if SND.on then playSnd("on") end
end)

local sb=Instance.new("Frame",main)
sb.Size=UDim2.new(0,104,1,-64) sb.Position=UDim2.new(0,6,0,34)
sb.BackgroundTransparency=1 sb.BorderSizePixel=0 sb.ZIndex=110
local sbl=Instance.new("UIListLayout",sb)
sbl.Padding=UDim.new(0,2) sbl.SortOrder=Enum.SortOrder.LayoutOrder

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
stLbl.BackgroundTransparency=1 stLbl.Text="[ OK ] ready"
stLbl.Font=Enum.Font.Code stLbl.TextSize=11 stLbl.TextColor3=G
stLbl.TextXAlignment=Enum.TextXAlignment.Left stLbl.ZIndex=111

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
    b.BorderSizePixel=0 b.Text="  > "..text b.Font=Enum.Font.Code
    b.TextSize=13 b.TextColor3=color b.TextXAlignment=Enum.TextXAlignment.Left b.AutoButtonColor=false
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

local tabs={"MOVE","ESP","PLAYER","TELE","INFO"}
local TAB_SHAPE={MOVE="diamond",ESP="ring",PLAYER="circle",TELE="boxin",INFO="square"}
local pages={} local tabBtns={}
local activeTab=nil

-- gõ chữ lên thanh trạng thái (hiệu ứng terminal)
local stToken=0
local function typeStatus(text,color)
    stToken=stToken+1
    local my=stToken
    stLbl.TextColor3=color or G
    task.spawn(function()
        for i=1,#text do
            if my~=stToken then return end
            stLbl.Text=string.sub(text,1,i)
            if main.Visible and i%3==0 then playKey("down",0.22,1.25+math.random()*0.3) end
            task.wait(0.016)
        end
    end)
end

local flash=Instance.new("Frame",ct)
flash.Size=UDim2.new(1,0,1,0) flash.BackgroundColor3=G flash.BackgroundTransparency=1
flash.BorderSizePixel=0 flash.ZIndex=150
Instance.new("UICorner",flash).CornerRadius=UDim.new(0,4)

-- icon dạng hình khối (không dùng emoji)
local function mkShape(parent,kind)
    local box=Instance.new("Frame",parent)
    box.Size=UDim2.new(0,18,0,18) box.Position=UDim2.new(0,8,.5,-9) box.BackgroundTransparency=1 box.ZIndex=112
    local parts={}
    local function fr(sz,rot,round,hollow)
        local f=Instance.new("Frame",box)
        f.Size=sz f.AnchorPoint=Vector2.new(.5,.5) f.Position=UDim2.new(.5,0,.5,0)
        f.Rotation=rot f.ZIndex=113 f.BorderSizePixel=0
        if round then Instance.new("UICorner",f).CornerRadius=UDim.new(1,0) end
        if hollow then
            f.BackgroundTransparency=1
            local st=Instance.new("UIStroke",f) st.Thickness=1.5
            table.insert(parts,{st=st})
        else
            table.insert(parts,{f=f})
        end
    end
    if kind=="diamond" then fr(UDim2.new(0,11,0,11),45,false,false)
    elseif kind=="ring" then fr(UDim2.new(0,16,0,16),0,true,true) fr(UDim2.new(0,5,0,5),0,true,false)
    elseif kind=="circle" then fr(UDim2.new(0,13,0,13),0,true,false)
    elseif kind=="boxin" then fr(UDim2.new(0,15,0,15),0,false,true) fr(UDim2.new(0,6,0,6),0,false,false)
    else fr(UDim2.new(0,12,0,12),0,false,false) end
    return function(col)
        for _,p in ipairs(parts) do
            if p.f then p.f.BackgroundColor3=col else p.st.Color=col end
        end
    end
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
    local pg=pages[name]
    pg.Position=UDim2.new(0,20,0,4)
    T:Create(pg,TweenInfo.new(0.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=UDim2.new(0,4,0,4)}):Play()
    flash.BackgroundTransparency=0.8
    T:Create(flash,TweenInfo.new(0.35),{BackgroundTransparency=1}):Play()
    typeStatus("> cd /"..string.lower(name).." ... [OK]")
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
    local setColor=mkShape(b,TAB_SHAPE[n])
    setColor(G2)
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
    bar.Size=UDim2.new(0,3,0,12) bar.Position=UDim2.new(0,4,.5,-6)
    bar.BackgroundColor3=CY bar.BorderSizePixel=0
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
    row.Size=UDim2.new(1,-8,0,34) row.BackgroundColor3=BG
    row.BackgroundTransparency=0.3 row.BorderSizePixel=0 row.Text="" row.AutoButtonColor=false
    row.LayoutOrder=#parent:GetChildren()*10 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local rs=Instance.new("UIStroke",row) rs.Color=DIM rs.Thickness=1 rs.Transparency=0.5
    local lead=Instance.new("Frame",row)
    lead.Size=UDim2.new(0,3,0,16) lead.Position=UDim2.new(0,5,.5,-8)
    lead.BackgroundColor3=DIM lead.BorderSizePixel=0 lead.ZIndex=113
    Instance.new("UICorner",lead).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-70,1,0) lbl.Position=UDim2.new(0,16,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=name lbl.Font=Enum.Font.Code
    lbl.TextSize=12 lbl.TextColor3=TX lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=113
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
    row.MouseEnter:Connect(function() T:Create(rs,TweenInfo.new(0.12),{Color=G2,Transparency=0}):Play() end)
    row.MouseLeave:Connect(function() T:Create(rs,TweenInfo.new(0.12),{Color=DIM,Transparency=0.5}):Play() end)
    row.MouseButton1Click:Connect(function()
        state=not state
        render(true)
        playSnd(state and "on" or "off")
        stToken=stToken+1
        stLbl.Text="[ "..(state and "ON " or "OFF").." ] "..name
        stLbl.TextColor3=state and G or DIM
        if cb then pcall(cb,state) end
    end)
    return row
end

local function mkSli(parent,name,mn,mx,dv,cb)
    local row=Instance.new("Frame",parent)
    row.Size=UDim2.new(1,-8,0,46) row.BackgroundColor3=BG
    row.BackgroundTransparency=0.3 row.BorderSizePixel=0
    row.LayoutOrder=#parent:GetChildren()*10 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,6)
    local rs=Instance.new("UIStroke",row) rs.Color=DIM rs.Thickness=1 rs.Transparency=0.5
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(1,-80,0,18) lbl.Position=UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency=1 lbl.Text=name
    lbl.Font=Enum.Font.Code lbl.TextSize=12 lbl.TextColor3=TX
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=113
    local val=Instance.new("TextLabel",row)
    val.Size=UDim2.new(0,64,0,18) val.Position=UDim2.new(1,-72,0,4)
    val.BackgroundTransparency=1 val.Text=tostring(dv)
    val.Font=Enum.Font.Code val.TextSize=12 val.TextColor3=G
    val.TextXAlignment=Enum.TextXAlignment.Right val.ZIndex=113
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
    local drag=false local lastV=nil local lastSnd=0
    local function up(x)
        local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        fill.Size=UDim2.new(p,0,1,0) thumb.Position=UDim2.new(p,-8,.5,-8)
        local v=mn+(mx-mn)*p
        if mx>=10 and math.floor(mx)==mx and math.floor(mn)==mn then v=math.floor(v+.5) else v=math.floor(v*10)/10 end
        val.Text=tostring(v)
        if v~=lastV then
            lastV=v
            if cb then pcall(cb,v) end
            if tick()-lastSnd>0.06 then lastSnd=tick() playSnd("tick",0.8+p*0.8) end
        end
    end
    hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true
            pcall(function() parent.ScrollingEnabled=false end)
            up(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then up(i.Position.X) end
    end)
    UIS.InputEnded:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then
            drag=false
            pcall(function() parent.ScrollingEnabled=true end)
        end
    end)
end

local function mkBtn(parent,name,cb)
    local b=Instance.new("TextButton",parent)
    b.Size=UDim2.new(1,-8,0,34) b.BackgroundColor3=BG
    b.BackgroundTransparency=0.3 b.BorderSizePixel=0
    b.Text="  > "..name b.Font=Enum.Font.Code b.TextSize=12
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
        task.wait(0.15)
        b.Text="  > "..name
    end)
    return b
end

local BASE_LIGHTING={Brightness=L.Brightness,ClockTime=L.ClockTime,Ambient=L.Ambient,OutdoorAmbient=L.OutdoorAmbient,
    GlobalShadows=L.GlobalShadows,EnvironmentDiffuseScale=L.EnvironmentDiffuseScale,EnvironmentSpecularScale=L.EnvironmentSpecularScale,
    ShadowSoftness=L.ShadowSoftness,FogEnd=L.FogEnd,FogStart=L.FogStart,ExposureCompensation=L.ExposureCompensation}
local function restoreLightingBase() pcall(function() for k,v in pairs(BASE_LIGHTING) do L[k]=v end end) end
local function reapplyLighting()
    restoreLightingBase()
    if tg.fps then pcall(function() L.GlobalShadows=false L.EnvironmentDiffuseScale=0 L.EnvironmentSpecularScale=0 L.ShadowSoftness=0 L.FogEnd=100000 L.FogStart=100000 end) end
    if tg.mapBright then pcall(function() L.Brightness=3 L.ClockTime=14 L.Ambient=Color3.fromRGB(180,180,180) L.OutdoorAmbient=Color3.fromRGB(180,180,180) L.FogEnd=100000 L.FogStart=100000 L.GlobalShadows=false L.ExposureCompensation=0.5 end) end
end

local fpsSaved={active=false,gen=0,parts={},effects={},postFx={},atmos={},terrain={},conns={},qualityLevel=nil}
local fpsQueue={} local fpsQueueRunning=false
local function fpsKill(o)
    if not fpsSaved.active then return end
    pcall(function()
        if o:IsA("BasePart") or o:IsA("MeshPart") or o:IsA("UnionOperation") then
            if o.CastShadow then if not fpsSaved.parts[o] then fpsSaved.parts[o]=true end o.CastShadow=false end
        elseif o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles")
            or o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight") then
            if o.Enabled then if not fpsSaved.effects[o] then fpsSaved.effects[o]=true end o.Enabled=false end
        end
    end)
end
local function processFPSQueue()
    if fpsQueueRunning then return end
    fpsQueueRunning=true
    task.spawn(function()
        while fpsSaved.active and #fpsQueue>0 do
            local batch={}
            for i=1,math.min(50,#fpsQueue) do table.insert(batch,table.remove(fpsQueue,1)) end
            for _,o in ipairs(batch) do if o and o.Parent then fpsKill(o) end end
            task.wait()
        end
        fpsQueueRunning=false
    end)
end
local function enableFPS()
    if fpsSaved.active then return end
    fpsSaved.active=true fpsSaved.gen=fpsSaved.gen+1
    local myGen=fpsSaved.gen
    fpsSaved.parts={} fpsSaved.effects={} fpsSaved.postFx={} fpsSaved.atmos={} fpsSaved.conns={}
    pcall(function() if settings and settings().Rendering then fpsSaved.qualityLevel=settings().Rendering.QualityLevel settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 end end)
    pcall(function() if setfpscap then setfpscap(999) end end)
    reapplyLighting()
    for _,v in ipairs(L:GetChildren()) do
        pcall(function()
            if v:IsA("PostEffect") and v.Enabled then fpsSaved.postFx[v]=true v.Enabled=false
            elseif v:IsA("Atmosphere") then fpsSaved.atmos[v]=v.Density v.Density=0 end
        end)
    end
    pcall(function()
        local t=workspace:FindFirstChildOfClass("Terrain")
        if t then fpsSaved.terrain={WaterWaveSize=t.WaterWaveSize,WaterReflectance=t.WaterReflectance,WaterTransparency=t.WaterTransparency}
            t.WaterWaveSize=0 t.WaterReflectance=0 t.WaterTransparency=1
            pcall(function() t.Decoration=false end)
        end
    end)
    task.spawn(function()
        local all=workspace:GetDescendants()
        for i=1,#all do
            if fpsSaved.gen~=myGen or not fpsSaved.active then return end
            fpsKill(all[i])
            if i%200==0 then task.wait() end
        end
    end)
    table.insert(fpsSaved.conns,workspace.DescendantAdded:Connect(function(o) if not fpsSaved.active then return end table.insert(fpsQueue,o) processFPSQueue() end))
    table.insert(fpsSaved.conns,L.DescendantAdded:Connect(function(o)
        if not fpsSaved.active then return end
        if o:IsA("PostEffect") then pcall(function() if o.Enabled then fpsSaved.postFx[o]=true o.Enabled=false end end)
        elseif o:IsA("Atmosphere") then pcall(function() if fpsSaved.atmos[o]==nil then fpsSaved.atmos[o]=o.Density end o.Density=0 end)
        else fpsKill(o) end
    end))
end
local function disableFPS()
    if not fpsSaved.active then return end
    fpsSaved.active=false fpsSaved.gen=fpsSaved.gen+1
    for _,c in ipairs(fpsSaved.conns) do pcall(function() c:Disconnect() end) end
    fpsSaved.conns={}
    reapplyLighting()
    pcall(function() if settings and settings().Rendering and fpsSaved.qualityLevel then settings().Rendering.QualityLevel=fpsSaved.qualityLevel end end)
    pcall(function() local t=workspace:FindFirstChildOfClass("Terrain") if t then for k,v in pairs(fpsSaved.terrain) do t[k]=v end pcall(function() t.Decoration=true end) end end)
    fpsSaved.terrain={}
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
        for _,v in ipairs(L:GetChildren()) do
            pcall(function()
                if v:IsA("PostEffect") and v.Enabled then mbPostFx[v]=true v.Enabled=false
                elseif v:IsA("Atmosphere") then mbAtmos[v]=v.Density v.Density=0 end
            end)
        end
    else
        tg.mapBright=false reapplyLighting()
        for fx in pairs(mbPostFx) do pcall(function() if not tg.fps and fx and fx.Parent then fx.Enabled=true end end) end
        for at,d in pairs(mbAtmos) do pcall(function() if not tg.fps and at and at.Parent then at.Density=d end end) end
        mbPostFx={} mbAtmos={}
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if tg.mapBright then
            pcall(function()
                L.Brightness=3 L.ClockTime=14 L.Ambient=Color3.fromRGB(180,180,180) L.OutdoorAmbient=Color3.fromRGB(180,180,180)
                L.FogEnd=100000 L.FogStart=100000 L.GlobalShadows=false L.ExposureCompensation=0.5
            end)
        end
    end
end)

-- TELEPORT (dịch chuyển tức thì, không bay)
teleportTo=function(targetPos,opts)
    opts=opts or {}
    local c=pl.Character if not c then return false end
    local hr=c:FindFirstChild("HumanoidRootPart") if not hr then return false end
    local cf=opts.cframe or (CFrame.new(targetPos)*(hr.CFrame-hr.CFrame.Position))
    local function snap()
        hr.CFrame=cf
        hr.AssemblyLinearVelocity=Vector3.zero
        hr.AssemblyAngularVelocity=Vector3.zero
    end
    snap()
    task.spawn(function()
        for _=1,4 do -- giữ vị trí vài khung hình, tránh bị game kéo ngược lại
            RS.Heartbeat:Wait()
            if not hr.Parent then return end
            if (hr.Position-cf.Position).Magnitude>3 then snap() end
        end
    end)
    nlSafe=cf nlGroundT=tick()
    return true
end

-- ============ NOCLIP (mượt, chống rơi void, chống kẹt) ============
local setNoclip
local noclipSaved={}
local nlSaved={}
local nlRP=RaycastParams.new() nlRP.FilterType=Enum.RaycastFilterType.Exclude

local function noclipApply(part)
    if not part:IsA("BasePart") then return end
    if noclipSaved[part]==nil then noclipSaved[part]=part.CanCollide end
    part.CanCollide=false
end
local function restoreCollide()
    for part,orig in pairs(noclipSaved) do pcall(function() if part and part.Parent then part.CanCollide=orig end end) end
    noclipSaved={}
end
local function inWall(hr,c)
    local op=OverlapParams.new() op.FilterType=Enum.RaycastFilterType.Exclude op.FilterDescendantsInstances={c}
    local ok,parts=pcall(function() return workspace:GetPartBoundsInBox(hr.CFrame,Vector3.new(1.8,4.5,1),op) end)
    if not ok then return false end
    for _,p in ipairs(parts) do if p.CanCollide then return true end end
    return false
end
local function nlHumanoid(on)
    local c=pl.Character local h=c and c:FindFirstChildOfClass("Humanoid") if not h then return end
    if on then
        if nlSaved.auto==nil then nlSaved.auto=h.AutoJumpEnabled end
        pcall(function() h.AutoJumpEnabled=false end) -- không tự nhảy khi chạm tường
        pcall(function() if nlSaved.pauto==nil then nlSaved.pauto=pl.AutoJumpEnabled end pl.AutoJumpEnabled=false end)
        pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Climbing,false) end) -- không bám vào thang/tường
    else
        if nlSaved.auto~=nil then pcall(function() h.AutoJumpEnabled=nlSaved.auto end) nlSaved.auto=nil end
        if nlSaved.pauto~=nil then pcall(function() pl.AutoJumpEnabled=nlSaved.pauto end) nlSaved.pauto=nil end
        pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.Climbing,true) end)
    end
end
setNoclip=function(on)
    local c=pl.Character
    local hr=c and c:FindFirstChild("HumanoidRootPart")
    if on then
        if hr then nlSafe=hr.CFrame nlGroundT=tick() end
        nlHumanoid(true)
    else
        if hr and inWall(hr,c) then -- tắt noclip khi đang trong tường: đưa ra chỗ an toàn
            hr.CFrame=(nlSafe or hr.CFrame)+Vector3.new(0,3,0)
            hr.AssemblyLinearVelocity=Vector3.zero
        end
        restoreCollide()
        nlHumanoid(false)
    end
end
RS.Stepped:Connect(function()
    if not tg.noclip then return end
    local c=pl.Character if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then noclipApply(p) end
    end
end)
RS.Heartbeat:Connect(function() -- chống rơi xuống lòng đất / void
    if not tg.noclip then return end
    local c=pl.Character
    local hr=c and c:FindFirstChild("HumanoidRootPart")
    local h=c and c:FindFirstChildOfClass("Humanoid")
    if not hr or not h or h.Health<=0 then return end
    local now=tick()
    if h.FloorMaterial~=Enum.Material.Air then nlSafe=hr.CFrame nlGroundT=now return end
    if not nlSafe then return end
    local y=hr.Position.Y
    local rescue=false
    if y<workspace.FallenPartsDestroyHeight+40 then
        rescue=true
    elseif now-nlGroundT<1.5 and y<nlSafe.Position.Y-3 then
        nlRP.FilterDescendantsInstances={c}
        local r=workspace:Raycast(hr.Position,Vector3.new(0,15,0),nlRP)
        if r and r.Instance.CanCollide then rescue=true end -- có sàn phía trên = vừa lọt xuống
    end
    if rescue then
        hr.CFrame=nlSafe+Vector3.new(0,3,0)
        hr.AssemblyLinearVelocity=Vector3.zero hr.AssemblyAngularVelocity=Vector3.zero
        nlGroundT=now
    end
end)

-- ============ ANTI KNOCKBACK (chạy ngầm) ============
local MOVERS={BodyVelocity=true,BodyForce=true,BodyThrust=true,BodyPosition=true,BodyAngularVelocity=true,
    BodyGyro=true,LinearVelocity=true,VectorForce=true,AngularVelocity=true,Torque=true}
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
        if tg.antiKB and MOVERS[d.ClassName] then
            task.defer(function() pcall(function() d:Destroy() end) end)
        end
    end)
    akbStates(tg.antiKB)
end
RS.Heartbeat:Connect(function()
    if not tg.antiKB then return end
    local c=pl.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    local hr=c and c:FindFirstChild("HumanoidRootPart")
    if not h or not hr or h.Health<=0 then return end
    local st=h:GetState()
    if st==Enum.HumanoidStateType.FallingDown or st==Enum.HumanoidStateType.Ragdoll or st==Enum.HumanoidStateType.PlatformStand then
        pcall(function() h.PlatformStand=false h:ChangeState(Enum.HumanoidStateType.GetUp) end)
    end
    if h.PlatformStand then h.PlatformStand=false end
    if h.WalkSpeed<1 and not h.Sit then h.WalkSpeed=16 end -- hết bị đứng hình
    local v=hr.AssemblyLinearVelocity
    local cap=math.max(h.WalkSpeed,stt.ws,16)
    local hv=Vector3.new(v.X,0,v.Z)
    local limit=cap*1.8+14
    local ny=v.Y
    local maxUp=math.max(h.JumpPower,stt.jp,50)*1.4+12
    if ny>maxUp then ny=maxUp end
    if hv.Magnitude>limit then
        local md=h.MoveDirection
        local keep=(md.Magnitude>0.1) and (md.Unit*cap) or Vector3.zero
        hr.AssemblyLinearVelocity=Vector3.new(keep.X,ny,keep.Z)
    elseif ny~=v.Y then
        hr.AssemblyLinearVelocity=Vector3.new(v.X,ny,v.Z)
    end
    if hr.AssemblyAngularVelocity.Magnitude>20 then hr.AssemblyAngularVelocity=Vector3.zero end
end)
RS.Stepped:Connect(function() -- người khác không đẩy/hất được mình bằng va chạm
    if not tg.antiKB then return end
    for _,p in ipairs(P:GetPlayers()) do
        local ch=(p~=pl) and p.Character
        if ch then
            for _,part in ipairs(ch:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then part.CanCollide=false end
            end
        end
    end
end)

local function onCharSpawn(char)
    local hr=char:WaitForChild("HumanoidRootPart",10)
    local h=char:WaitForChild("Humanoid",10)
    if not hr or not h then return end
    akbHook(char)
    task.wait(0.4)
    if not hr.Parent then return end
    nlSaved={}
    if tg.noclip then task.wait(0.2) if setNoclip then setNoclip(true) end end
end
pl.CharacterAdded:Connect(onCharSpawn)
if pl.Character then task.spawn(function() onCharSpawn(pl.Character) end) end

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
               fxBB=fxBB,scans=scans,dots=dots,ring=ring,ringStroke=ringStroke,dataTop=dataTop,_mCache=nil,_mFrame=0}
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
local function scanESP()
    if not (tg.espName or tg.espHp or tg.espDist or tg.espBody) then return end
    for _,p in ipairs(P:GetPlayers()) do
        local ch=p.Character
        if p~=pl and ch and not evs[ch] and ch:FindFirstChild("HumanoidRootPart") then pcall(buildESP,ch) end
    end
    for ch in pairs(evs) do if not ch.Parent then destroyESP(ch) end end
end
task.spawn(function() while true do task.wait(1) scanESP() end end)

-- ============ POPULATE UI ============
mkSec(pages["MOVE"],"// SPEED")
mkSli(pages["MOVE"],"Walk Speed",16,500,16,function(v) stt.ws=v end)
mkSec(pages["MOVE"],"// JUMP")
mkSli(pages["MOVE"],"Jump Power",50,300,50,function(v) stt.jp=v end)
mkTog(pages["MOVE"],"INFINITE JUMP",false,function(on) tg.infJump=on end)

mkSec(pages["ESP"],"// PLAYER ESP")
mkTog(pages["ESP"],"ESP LINE (RAINBOW)",false,function(on)
    tg.espLine=on
    if on and not (Drawing and Drawing.new) then stLbl.Text="[ ! ] Executor không hỗ trợ Drawing" stLbl.TextColor3=YEL end
end)
mkTog(pages["ESP"],"ESP NAME",false,function(on) tg.espName=on applyESPToggles() scanESP() end)
mkTog(pages["ESP"],"ESP HEALTH",false,function(on) tg.espHp=on applyESPToggles() scanESP() end)
mkTog(pages["ESP"],"ESP DISTANCE",false,function(on) tg.espDist=on applyESPToggles() scanESP() end)
mkTog(pages["ESP"],"ESP BODY FX",false,function(on) tg.espBody=on applyESPToggles() scanESP() end)

mkSec(pages["PLAYER"],"// PERFORMANCE")
mkTog(pages["PLAYER"],"FPS BOOST",false,function(on) tg.fps=on setFPS(on) end)
mkTog(pages["PLAYER"],"MAP BRIGHT",false,function(on) tg.mapBright=on setMapBright(on) end)
mkSec(pages["PLAYER"],"// SURVIVAL")
mkTog(pages["PLAYER"],"NOCLIP (SMOOTH)",false,function(on) tg.noclip=on setNoclip(on) end)
mkTog(pages["PLAYER"],"ANTI KNOCKBACK (auto)",true,function(on) tg.antiKB=on akbStates(on) end)
mkSec(pages["PLAYER"],"// CAMERA")
mkSli(pages["PLAYER"],"FOV",70,120,70,function(v) cam.FieldOfView=v fovCustom=(v~=70) and v or nil end)
mkSec(pages["PLAYER"],"// SOUND")
mkSli(pages["PLAYER"],"Volume",0,100,60,function(v) SND.vol=v/100 end)
mkSec(pages["PLAYER"],"// UTILITIES")
mkBtn(pages["PLAYER"],"RESET CHARACTER",function()
    local c=pl.Character
    if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Health=0 end end
end)
mkBtn(pages["PLAYER"],"REJOIN SERVER",function()
    local okk=pcall(function()
        if #P:GetPlayers()<=1 then TS:Teleport(game.PlaceId,pl) else TS:TeleportToPlaceInstance(game.PlaceId,game.JobId,pl) end
    end)
    if not okk then stLbl.Text="[ ! ] Rejoin lỗi" stLbl.TextColor3=RED end
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
    if not tpSelected then stLbl.Text="[ ! ] Chọn người chơi trước" stLbl.TextColor3=YEL return end
    if tpCD then return end
    local c=pl.Character
    local hr=c and c:FindFirstChild("HumanoidRootPart") if not hr then return end
    local th=tpSelected.Character and tpSelected.Character:FindFirstChild("HumanoidRootPart")
    if not th then stLbl.Text="[ ! ] Người đó chưa có nhân vật" stLbl.TextColor3=YEL return end
    tpCD=true
    teleportTo(th.Position+Vector3.new(0,4,0))
    stLbl.Text="[ OK ] Teleport -> "..tpSelected.Name stLbl.TextColor3=G
    task.wait(1)
    tpCD=false
end)

mkSec(pages["TELE"],"// WAYPOINTS (8 SLOT)")
mkSli(pages["TELE"],"WP Height",0,20,wpHeight,function(v) wpHeight=v saveWPs() end)

local wpRows={}
local function buildWPRow(index)
    local row=Instance.new("Frame",pages["TELE"])
    row.Size=UDim2.new(1,-8,0,34) row.BackgroundColor3=BG
    row.BackgroundTransparency=0.3 row.BorderSizePixel=0
    row.LayoutOrder=#pages["TELE"]:GetChildren()*10 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
    local badge=Instance.new("TextLabel",row)
    badge.Size=UDim2.new(0,24,1,0) badge.Position=UDim2.new(0,4,0,0)
    badge.BackgroundTransparency=1 badge.Text="#"..index badge.Font=Enum.Font.Code
    badge.TextSize=12 badge.TextColor3=CY badge.TextXAlignment=Enum.TextXAlignment.Left badge.ZIndex=113
    local info=Instance.new("TextLabel",row)
    info.Size=UDim2.new(1,-140,1,0) info.Position=UDim2.new(0,30,0,0)
    info.BackgroundTransparency=1 info.Text="EMPTY" info.Font=Enum.Font.Code
    info.TextSize=11 info.TextColor3=DIM info.TextXAlignment=Enum.TextXAlignment.Left info.ZIndex=113
    local function mkMiniBtn(xOffset,text,color,cb)
        local b=Instance.new("TextButton",row)
        b.Size=UDim2.new(0,32,0,24) b.Position=UDim2.new(1,xOffset,0.5,-12)
        b.BackgroundColor3=BG2 b.BorderSizePixel=0 b.Text=text b.Font=Enum.Font.Code
        b.TextSize=11 b.TextColor3=color b.AutoButtonColor=false b.ZIndex=113
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,2)
        b.MouseButton1Click:Connect(function() playSnd("click") b.Text="..." task.wait(0.1) b.Text=text if cb then pcall(cb) end end)
        return b
    end
    mkMiniBtn(-102,"SET",G,function()
        local c=pl.Character
        local hr=c and c:FindFirstChild("HumanoidRootPart")
        if hr then wps[index]={hr.CFrame:GetComponents()} saveWPs() info.Text="READY" info.TextColor3=G end
    end)
    mkMiniBtn(-68,"GO",CY,function()
        if wps[index] then
            local sc=cfFromArr(wps[index])
            if sc then
                teleportTo(sc.Position+Vector3.new(0,wpHeight,0),{cframe=sc+Vector3.new(0,wpHeight,0)})
                stLbl.Text="[ OK ] Teleport #"..index stLbl.TextColor3=G
            end
        else
            stLbl.Text="[ ! ] Slot "..index.." trống" stLbl.TextColor3=YEL
        end
    end)
    mkMiniBtn(-34,"✕",RED,function() wps[index]=nil saveWPs() info.Text="EMPTY" info.TextColor3=DIM end)
    if wps[index] then info.Text="READY" info.TextColor3=G end
    wpRows[index]={row=row,info=info}
end
for i=1,8 do buildWPRow(i) end

task.spawn(function()
    while true do
        task.wait(2)
        local c=pl.Character
        local hr=c and c:FindFirstChild("HumanoidRootPart")
        local myPos=hr and hr.Position
        if myPos then
            for i=1,8 do
                local r=wpRows[i]
                if r and wps[i] then
                    local sc=cfFromArr(wps[i])
                    if sc then
                        local d=(sc.Position-myPos).Magnitude/3.57
                        r.info.Text=string.format("READY (%.0fm)",d)
                    end
                end
            end
        end
    end
end)

local infoRoot=Instance.new("Frame",pages["INFO"])
infoRoot.Size=UDim2.new(1,-8,0,0) infoRoot.AutomaticSize=Enum.AutomaticSize.Y
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
    titleBar.Size=UDim2.new(1,0,0,24) titleBar.BackgroundColor3=BG2
    titleBar.BackgroundTransparency=0.3 titleBar.BorderSizePixel=0 titleBar.ZIndex=117
    Instance.new("UICorner",titleBar).CornerRadius=UDim.new(0,4)
    local bar=Instance.new("Frame",titleBar)
    bar.Size=UDim2.new(0,2,0,10) bar.Position=UDim2.new(0,6,.5,-5)
    bar.BackgroundColor3=accent bar.BorderSizePixel=0 bar.ZIndex=118
    local tl=Instance.new("TextLabel",titleBar)
    tl.Size=UDim2.new(1,-14,1,0) tl.Position=UDim2.new(0,14,0,0)
    tl.BackgroundTransparency=1 tl.Text=title tl.Font=Enum.Font.Code
    tl.TextSize=12 tl.TextColor3=accent tl.TextXAlignment=Enum.TextXAlignment.Left tl.ZIndex=118
    local body=Instance.new("Frame",card)
    body.Size=UDim2.new(1,-12,0,0) body.Position=UDim2.new(0,6,0,28)
    body.AutomaticSize=Enum.AutomaticSize.Y body.BackgroundTransparency=1 body.ZIndex=117
    local bl=Instance.new("UIListLayout",body)
    bl.Padding=UDim.new(0,3) bl.SortOrder=Enum.SortOrder.LayoutOrder
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
local netRow=makeCard("NETWORK",CY)
infoRefs.ping=netRow("PING",G) infoRefs.pStat=netRow("STATUS",G)
local perfRow=makeCard("PERFORMANCE",G)
infoRefs.fps=perfRow("FPS",CY) infoRefs.fpsAvg=perfRow("FPS AVG",CY)
infoRefs.mem=perfRow("MEMORY",CY) infoRefs.uptime=perfRow("UPTIME",CY)
local pRow=makeCard("PLAYER",YEL)
infoRefs.name=pRow("NAME",YEL) infoRefs.hp=pRow("HEALTH",G) infoRefs.pos=pRow("POSITION",YEL)
local srvRow=makeCard("SERVER",G3)
infoRefs.game=srvRow("GAME",G3) infoRefs.place=srvRow("PLACE ID",G3) infoRefs.players=srvRow("PLAYERS",G3)
local sysRow=makeCard("SYSTEM",ORG)
infoRefs.time=sysRow("TIME",ORG) infoRefs.ver=sysRow("VERSION",ORG) infoRefs.active=sysRow("ACTIVE",G)

local fpsHist={} local stT=tick() local frmCnt=0
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
                infoRefs.mem.Text=(function() local ok2,m=pcall(function() return ST:GetTotalMemoryUsageMb() end) return ok2 and m and math.floor(m).." MB" or "--" end)()
                local u=math.floor(tick()-stT)
                infoRefs.uptime.Text=string.format("%dm %ds",math.floor(u/60),u%60)
                infoRefs.name.Text=pl.Name
                local c=pl.Character
                if c then
                    local h=c:FindFirstChildOfClass("Humanoid")
                    local hr=c:FindFirstChild("HumanoidRootPart")
                    if h then infoRefs.hp.Text=math.floor(h.Health).." / "..math.floor(h.MaxHealth) end
                    if hr then local p=hr.Position infoRefs.pos.Text=string.format("%d,%d,%d",math.floor(p.X),math.floor(p.Y),math.floor(p.Z)) end
                end
                infoRefs.game.Text=string.sub(game.Name or "?",1,24)
                infoRefs.place.Text=tostring(game.PlaceId)
                infoRefs.players.Text=#P:GetPlayers().." / "..P.MaxPlayers
                infoRefs.time.Text=os.date("%H:%M:%S")
                infoRefs.ver.Text="v14-CHILL"
                local a={}
                if tg.espLine then table.insert(a,"LINE") end
                if tg.espName then table.insert(a,"NAME") end
                if tg.espHp then table.insert(a,"HP") end
                if tg.espDist then table.insert(a,"DIST") end
                if tg.espBody then table.insert(a,"BODY") end
                if tg.noclip then table.insert(a,"NOCLIP") end
                if tg.mapBright then table.insert(a,"BRIGHT") end
                if tg.fps then table.insert(a,"FPS+") end
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
    task.spawn(function()
        title.Text=""
        for i=1,#titleTarget do
            title.Text=string.sub(titleTarget,1,i)
            if i%2==1 then playKey("down",0.35,1+math.random()*0.25) end
            task.wait(0.03)
        end
        bootRunning=false
    end)
    task.spawn(function()
        for _,ln in ipairs({"> init kernel ... [OK]","> mount /dev/neko ... [OK]","> access granted"}) do
            typeStatus(ln) task.wait(0.4)
        end
    end)
end

local menuOpen=false
local function showMenu()
    if menuOpen then return end
    menuOpen=true
    playSnd("open")
    main.Visible=true
    main.Size=UDim2.new(0,0,0,0) main.BackgroundTransparency=1
    T:Create(main,TweenInfo.new(0.22,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,470,0,380),BackgroundTransparency=0.05}):Play()
    stk.Transparency=1
    T:Create(stk,TweenInfo.new(0.25),{Transparency=0}):Play()
    local basePos=main.Position
    task.spawn(function() -- giật hình (glitch) lúc mở
        for _=1,5 do
            main.Position=UDim2.new(basePos.X.Scale,basePos.X.Offset+math.random(-5,5),basePos.Y.Scale,basePos.Y.Offset+math.random(-2,2))
            task.wait(0.03)
        end
        main.Position=basePos
    end)
    bootSequence()
end
local function hideMenu()
    if not menuOpen then return end
    menuOpen=false
    playSnd("click")
    local tw=T:Create(main,TweenInfo.new(0.18,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{Size=UDim2.new(0,0,0,0),BackgroundTransparency=1})
    tw:Play()
    tw.Completed:Connect(function() if not menuOpen then main.Visible=false end end)
end
cl.MouseButton1Click:Connect(hideMenu)

task.spawn(function()
    local tGlow=0 local tCursor=0
    local nextGlitch=2 local glitchUntil=0
    while true do
        task.wait(0.06)
        tGlow=tGlow+0.06 tCursor=tCursor+0.06
        tglGlow.Transparency=0.7+math.abs(math.sin(tGlow*2))*0.2
        stkGrad.Rotation=(tGlow*60)%360
        if menuOpen then
            stkGlow.Transparency=0.72+math.abs(math.sin(tGlow*1.5))*0.2
            for _,c in ipairs(rainCols) do
                c.offset=c.offset+c.speed*0.06
                if c.offset>380 then
                    c.offset=-380 c.lbl.Text=rainStr(26)
                end
                c.lbl.Position=UDim2.new(0,c.lbl.Position.X.Offset,0,c.offset)
            end
            for _,b in ipairs(brackets) do b.BackgroundTransparency=0.05+math.abs(math.sin(tGlow*3))*0.5 end
            scan.Position=UDim2.new(0,0,0,((tGlow*90)%440)-30)
            if tGlow>=nextGlitch then nextGlitch=tGlow+2.5+math.random()*3 glitchUntil=tGlow+0.18 end
            if tGlow<glitchUntil then
                title.TextColor3=(math.random()>0.5) and CY or RED
                title.Position=UDim2.new(0,10+math.random(-3,3),0,math.random(-1,1))
            else
                title.TextColor3=G title.Position=UDim2.new(0,10,0,0)
            end
            if tCursor>=0.6 then tCursor=0 cursor.Visible=not cursor.Visible end
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
    end
end)
UIS.InputEnded:Connect(function(i)
    if (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) and dragging then
        dragging=false
        if not moved then if menuOpen then hideMenu() else showMenu() end end
    end
end)
main.Position=toggleBtn.Position

do -- kéo menu bằng thanh tiêu đề (chuột + cảm ứng)
    local d2,ds2,sp2=false,nil,nil
    hd.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            d2=true ds2=i.Position sp2=main.Position
        end
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
local drawingAvailable=(Drawing~=nil and Drawing.new~=nil)
local espFrame=0

RS.RenderStepped:Connect(function(dt)
    rT=tick() espFrame=espFrame+1 cam=workspace.CurrentCamera or cam
    if fovCustom then cam.FieldOfView=fovCustom end
    if tg.espLine and drawingAvailable then
        local ct2=Vector2.new(cam.ViewportSize.X/2,0)
        local rb=Color3.fromHSV(rT%4/4,1,1)
        for _,p in ipairs(P:GetPlayers()) do
            if p~=pl then
                local ch=p.Character
                local hr=ch and ch:FindFirstChild("HumanoidRootPart")
                local h=ch and ch:FindFirstChildOfClass("Humanoid")
                local tr=trcs[p]
                if hr and h and h.Health>0 then
                    if not tr then
                        local okk,r=pcall(function() return Drawing.new("Line") end)
                        if okk and r then r.Thickness=2 r.Transparency=1 trcs[p]=r tr=r end
                    end
                    if tr then
                        local v,on2=cam:WorldToViewportPoint(hr.Position)
                        if on2 then tr.From=ct2 tr.To=Vector2.new(v.X,v.Y) tr.Color=rb tr.Visible=true else tr.Visible=false end
                    end
                elseif tr then tr.Visible=false end
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
                        data._mFrame=data._mFrame+1
                        if data._mFrame>=20 or not data._mCache then data._mCache=measureBody(char) data._mFrame=0 end
                        local m=data._mCache
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
                        if data.hl then data.hl.FillTransparency=0.85+math.abs(math.sin(rT*2.5))*0.05 end
                    end
                end
            end
        end
    end
end)

-- SPEED / JUMP (không đè WalkSpeed của game, không dùng BodyVelocity)
local jpSaved=nil
pl.CharacterAdded:Connect(function() jpSaved=nil end)
RS.Heartbeat:Connect(function()
    local c=pl.Character if not c then return end
    local h=c:FindFirstChildOfClass("Humanoid")
    local hr=c:FindFirstChild("HumanoidRootPart")
    if not h or not hr or h.Health<=0 then return end
    local oldBV=hr:FindFirstChild("NekoSpeed") if oldBV then oldBV:Destroy() end
    if stt.ws>16 then
        local md=h.MoveDirection
        if md.Magnitude>0.1 then
            local v=hr.AssemblyLinearVelocity
            local hv=md.Unit*stt.ws
            hr.AssemblyLinearVelocity=Vector3.new(hv.X,v.Y,hv.Z)
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
    if tg.infJump then
        local c=pl.Character
        local h=c and c:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

for _,p in ipairs(P:GetPlayers()) do
    if p~=pl and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then buildESP(p.Character) end
end
applyESPToggles()

task.spawn(function()
    while true do
        task.wait(2)
        pcall(function()
            local f=math.floor(frmCnt/2)
            fpsLbl.Text=f.." FPS"
            frmCnt=0
        end)
    end
end)

P.PlayerRemoving:Connect(function(p)
    if trcs[p] then pcall(function() trcs[p]:Remove() end) trcs[p]=nil end
    if p.Character then destroyESP(p.Character) end
    if tpSelected==p then tpSelected=nil tpTargetBtn.Text="  > SELECT PLAYER" end
end)

playSnd("open",1.2)
print("[HACKER NEKO v14 CHILL] loaded")

end)

if not ok then
    warn("[HACKER NEKO ERROR] "..tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="HACKER NEKO ERROR", Text=tostring(err), Duration=15
        })
    end)
end