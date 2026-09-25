-- ==================================================================
-- ============ HACKER NEKO v12 - TELE FIX + FULL MAP ==============
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

local _vim
local function getVIM()
    if _vim then return _vim end
    local okk,v=pcall(function() return game:GetService("VirtualUser") end)
    _vim=okk and v or nil
    return _vim
end

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
local enf=Instance.new("Folder",ef) enf.Name="NPC"

local stt={ws=16,hh=10,tph=3,jp=50,fov=70}
local tg={hover=false,espLine=false,espName=false,espHp=false,espDist=false,espBody=false,
    espNPC=false,espItem=false,noclip=false,autoPick=false,mapBright=false,
    fps=false,infJump=false,aimE=false,aimA=false,antiAFK=false,trail=false}
local aa={enabled=false,speed=200,atkSpd=false,hoverOn=false,hoverDist=0,target=nil}
local teleportTo

-- WAYPOINT STORAGE
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

-- TOGGLE BUTTON
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
task.spawn(function()
    while toggleBtn.Parent do task.wait(0.8) dot.BackgroundTransparency=(dot.BackgroundTransparency==0 and 1 or 0) end
end)

-- MAIN
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
for i=1,8 do
    local lbl=Instance.new("TextLabel",rainFrame)
    lbl.Size=UDim2.new(0,12,0,300) lbl.Position=UDim2.new(0,(i-1)*50,0,0)
    lbl.BackgroundTransparency=1 lbl.Text="" lbl.Font=Enum.Font.Code lbl.TextSize=11
    lbl.TextColor3=G2 lbl.TextTransparency=0.92 lbl.TextYAlignment=Enum.TextYAlignment.Top lbl.ZIndex=1
    local s=""
    for j=1,60 do s=s..(math.random()>0.5 and "1" or "0").."\n" end
    lbl.Text=s
    table.insert(rainCols,{lbl=lbl,offset=math.random()*300,speed=20+math.random()*60})
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
task.spawn(function() while main.Parent do task.wait(0.6) cursor.Visible=not cursor.Visible end end)

local cl=Instance.new("TextButton",hd)
cl.Size=UDim2.new(0,20,0,20) cl.Position=UDim2.new(1,-24,.5,-10)
cl.BackgroundTransparency=1 cl.Text="✕" cl.Font=Enum.Font.Code cl.TextSize=13
cl.TextColor3=RED cl.AutoButtonColor=false cl.ZIndex=113
cl.MouseButton1Click:Connect(function() hideMenu() end)

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

-- TEXT DIALOG
local txtOverlay=Instance.new("Frame",sg)
txtOverlay.Size=UDim2.new(1,0,1,0) txtOverlay.BackgroundColor3=Color3.new(0,0,0)
txtOverlay.BackgroundTransparency=.6 txtOverlay.BorderSizePixel=0 txtOverlay.Visible=false txtOverlay.ZIndex=910
local txtDlg=Instance.new("Frame",sg)
txtDlg.Size=UDim2.new(0,320,0,180) txtDlg.Position=UDim2.new(.5,-160,.5,-90)
txtDlg.BackgroundColor3=BG txtDlg.BorderSizePixel=0 txtDlg.Visible=false txtDlg.Active=true txtDlg.ZIndex=911
Instance.new("UICorner",txtDlg).CornerRadius=UDim.new(0,4)
local txtStk=Instance.new("UIStroke",txtDlg) txtStk.Color=CY txtStk.Thickness=1.5
local txtTitle=Instance.new("TextLabel",txtDlg)
txtTitle.Size=UDim2.new(1,-20,0,26) txtTitle.Position=UDim2.new(0,14,0,12)
txtTitle.BackgroundTransparency=1 txtTitle.Text="> RENAME" txtTitle.Font=Enum.Font.Code
txtTitle.TextSize=12 txtTitle.TextColor3=CY txtTitle.TextXAlignment=Enum.TextXAlignment.Left txtTitle.ZIndex=912
local txtBox=Instance.new("TextBox",txtDlg)
txtBox.Size=UDim2.new(1,-28,0,44) txtBox.Position=UDim2.new(0,14,0,46)
txtBox.BackgroundColor3=Color3.fromRGB(0,25,15) txtBox.BorderSizePixel=0 txtBox.Text=""
txtBox.PlaceholderText="new name" txtBox.PlaceholderColor3=DIM
txtBox.Font=Enum.Font.Code txtBox.TextSize=14 txtBox.TextColor3=G
txtBox.ClearTextOnFocus=false txtBox.Active=true txtBox.ZIndex=912
Instance.new("UICorner",txtBox).CornerRadius=UDim.new(0,3)
local txtStk2=Instance.new("UIStroke",txtBox) txtStk2.Color=G txtStk2.Thickness=1
local txtCancel=Instance.new("TextButton",txtDlg)
txtCancel.Size=UDim2.new(0,130,0,36) txtCancel.Position=UDim2.new(0,14,1,-50)
txtCancel.BackgroundColor3=BG2 txtCancel.BorderSizePixel=0 txtCancel.Text="> CANCEL"
txtCancel.Font=Enum.Font.Code txtCancel.TextSize=12 txtCancel.TextColor3=RED txtCancel.AutoButtonColor=false txtCancel.ZIndex=912
Instance.new("UICorner",txtCancel).CornerRadius=UDim.new(0,3)
local txtSave=Instance.new("TextButton",txtDlg)
txtSave.Size=UDim2.new(0,130,0,36) txtSave.Position=UDim2.new(1,-144,1,-50)
txtSave.BackgroundColor3=G txtSave.BorderSizePixel=0 txtSave.Text="> SAVE"
txtSave.Font=Enum.Font.Code txtSave.TextSize=12 txtSave.TextColor3=Color3.new(0,0,0) txtSave.AutoButtonColor=false txtSave.ZIndex=912
Instance.new("UICorner",txtSave).CornerRadius=UDim.new(0,3)
local txtCb=nil
local function closeTxt() txtDlg.Visible=false txtOverlay.Visible=false txtCb=nil end
local function openTxt(t,default,cb)
    txtTitle.Text="> "..t txtBox.Text=default txtCb=cb
    txtDlg.Visible=true txtOverlay.Visible=true
    task.wait() pcall(function() txtBox:CaptureFocus() end)
end
txtOverlay.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then closeTxt() end
end)
txtCancel.MouseButton1Click:Connect(closeTxt)
txtSave.MouseButton1Click:Connect(function()
    local v=txtBox.Text
    if v=="" then v="---" end
    if txtCb then pcall(txtCb,v) end
    closeTxt()
end)

-- TABS
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

-- HELPERS
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

-- FPS BOOST
local fpsParts={} local fpsEffects={}
local fpsGen=0
local function killOne(o)
    if not o or not o.Parent then return end
    local cls=o.ClassName
    if cls=="ParticleEmitter" or cls=="Trail" or cls=="Beam" or cls=="Fire" or cls=="Smoke" or cls=="Sparkles" then
        if o.Enabled then table.insert(fpsEffects,{o,"Enabled",true}) o.Enabled=false end
    elseif cls=="PointLight" or cls=="SpotLight" or cls=="SurfaceLight" then
        if o.Enabled then table.insert(fpsEffects,{o,"Enabled",true}) o.Enabled=false end
    elseif cls=="BasePart" or cls=="MeshPart" or cls=="UnionOperation" then
        pcall(function() if o.CastShadow then table.insert(fpsParts,o) o.CastShadow=false end end)
    end
end
local function restoreFPS()
    for i=#fpsEffects,1,-1 do
        local e=fpsEffects[i]
        pcall(function() if e[1] and e[1].Parent then e[1][e[2]]=e[3] end end)
    end
    fpsEffects={}
    for i=1,#fpsParts do
        local p=fpsParts[i]
        pcall(function() if p and p.Parent then p.CastShadow=true end end)
    end
    fpsParts={}
end
local function tFPS(on)
    fpsGen=fpsGen+1
    local myGen=fpsGen
    if on then
        pcall(function()
            L.Brightness=2 L.ClockTime=14
            L.GlobalShadows=false
            L.EnvironmentDiffuseScale=0
            L.EnvironmentSpecularScale=0
            L.ShadowSoftness=0
        end)
        pcall(function() if setfpscap then setfpscap(144) end end)
        pcall(function()
            local t=workspace:FindFirstChildOfClass("Terrain")
            if t then t.WaterWaveSize=0 t.WaterReflectance=0 t.WaterTransparency=1 end
        end)
        task.spawn(function()
            local all=workspace:GetDescendants()
            for i=1,#all do
                if fpsGen~=myGen then return end
                if not tg.fps then return end
                pcall(killOne,all[i])
                if i%40==0 then task.wait() end
            end
        end)
    else
        pcall(function() if setfpscap then setfpscap(240) end end)
        restoreFPS()
        pcall(function()
            L.GlobalShadows=true
            L.EnvironmentDiffuseScale=1
            L.EnvironmentSpecularScale=1
        end)
    end
end

-- MAP BRIGHT
local savedLighting=nil
local function tMapBright(on)
    if on then
        if not savedLighting then
            savedLighting={
                Brightness=L.Brightness, ClockTime=L.ClockTime, Ambient=L.Ambient,
                OutdoorAmbient=L.OutdoorAmbient, FogEnd=L.FogEnd, FogStart=L.FogStart,
                GlobalShadows=L.GlobalShadows, ExposureCompensation=L.ExposureCompensation,
            }
        end
        pcall(function()
            L.Brightness=3 L.ClockTime=14
            L.Ambient=Color3.fromRGB(180,180,180)
            L.OutdoorAmbient=Color3.fromRGB(180,180,180)
            L.FogEnd=100000 L.FogStart=100000
            L.GlobalShadows=false L.ExposureCompensation=0.5
        end)
        for _,v in ipairs(L:GetChildren()) do
            pcall(function()
                if v:IsA("ColorCorrectionEffect") then v.Enabled=false end
                if v:IsA("Atmosphere") then v.Density=0 end
                if v:IsA("BloomEffect") then v.Intensity=0 end
                if v:IsA("BlurEffect") then v.Size=0 end
            end)
        end
    else
        if savedLighting then
            pcall(function()
                L.Brightness=savedLighting.Brightness
                L.ClockTime=savedLighting.ClockTime
                L.Ambient=savedLighting.Ambient
                L.OutdoorAmbient=savedLighting.OutdoorAmbient
                L.FogEnd=savedLighting.FogEnd
                L.FogStart=savedLighting.FogStart
                L.GlobalShadows=savedLighting.GlobalShadows
                L.ExposureCompensation=savedLighting.ExposureCompensation
            end)
            savedLighting=nil
        end
    end
end

-- BACKGROUND NO FALL DAMAGE + ANTI VOID
local lastSafeCF=nil
local voidConn=nil
local function setupAntiVoidAndNoFall(char)
    if voidConn then voidConn:Disconnect() end
    local h=char:WaitForChild("Humanoid",5)
    if not h then return end
    local hr=char:WaitForChild("HumanoidRootPart",5)
    if not hr then return end
    pcall(function() h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false) end)
    local lastHp=h.Health
    local isRestoring=false
    h.HealthChanged:Connect(function(newHp)
        if isRestoring then return end
        if newHp<lastHp then
            local state=h:GetState()
            if state==Enum.HumanoidStateType.Freefall or state==Enum.HumanoidStateType.FallingDown or state==Enum.HumanoidStateType.Landed then
                isRestoring=true h.Health=lastHp task.wait() isRestoring=false return
            end
        end
        lastHp=h.Health
    end)
    voidConn=RS.Heartbeat:Connect(function()
        if not hr or not hr.Parent then return end
        if hr.Position.Y>5 then lastSafeCF=hr.CFrame end
        if hr.Position.Y<-50 and lastSafeCF then
            pcall(function()
                hr:SetNetworkOwner(pl)
                char:PivotTo(lastSafeCF+Vector3.new(0,10,0))
                hr.AssemblyLinearVelocity=Vector3.zero
                hr.AssemblyAngularVelocity=Vector3.zero
            end)
        end
    end)
end

pl.CharacterAdded:Connect(function(c)
    task.wait(0.4)
    setupAntiVoidAndNoFall(c)
    if tg.espName or tg.espHp or tg.espDist or tg.espBody then
        task.wait(0.4)
        for _,p in ipairs(P:GetPlayers()) do
            if p~=pl and p.Character and not evs[p.Character] then buildESP(p.Character) end
        end
        applyESPToggles()
    end
end)
if pl.Character then setupAntiVoidAndNoFall(pl.Character) end

-- ATTACK REMOTES
local attackRemotes={}
local function scanAttackRemotes()
    local tmp={}
    local keywords={"attack","hit","damage","swing","slash","strike","punch","kick","fire","shoot","melee","combat","weapon","sword","action","kill"}
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

-- AUTO ATTACK
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

-- ================================================================
-- ==================== TELEPORT v12 (ROBUST) =====================
-- ================================================================
-- Đặc điểm:
--  - Freeze humanoid states trong lúc teleport (chống fall damage / snap back)
--  - Ray cast xuống tìm ground → đặt Y đúng (chống rớt xuống đất)
--  - Spam CFrame + PivotTo 20 frame (0.3s) chống anti-cheat pull-back
--  - SetNetworkOwner(pl) để giành quyền kiểm soát
--  - Tự chia step nếu khoảng cách > 500 stud (chống streaming drop)
-- ================================================================
local function findGroundY(x, z, yHint)
    local origin = Vector3.new(x, (yHint or 500) + 200, z)
    local dir = Vector3.new(0, -1, 0)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {pl.Character}
    local result = workspace:Raycast(origin, dir * 5000, params)
    if result then
        return result.Position.Y + 3.5, result.Instance
    end
    return nil, nil
end

teleportTo = function(targetPos)
    local c = pl.Character
    if not c then return end
    local hr = c:FindFirstChild("HumanoidRootPart")
    if not hr then return end
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end

    -- Tìm ground Y nếu target Y không hợp lệ (quá cao/thấp)
    local targetX, targetY, targetZ = targetPos.X, targetPos.Y, targetPos.Z
    local groundY = findGroundY(targetX, targetZ, targetY)
    if groundY and math.abs(targetY - groundY) > 3 then
        -- Nếu Y hiện tại cách ground > 5 stud → dùng ground Y
        if targetY > groundY + 20 or targetY < groundY - 20 then
            targetY = groundY
        end
    end
    local finalPos = Vector3.new(targetX, targetY, targetZ)
    local target = CFrame.new(finalPos)

    -- Lưu state để khôi phục
    local statesToDisable = {
        Enum.HumanoidStateType.FallingDown,
        Enum.HumanoidStateType.Ragdoll,
        Enum.HumanoidStateType.PlatformStanding,
        Enum.HumanoidStateType.Freefall,
    }
    local saved = {}
    for i, st in ipairs(statesToDisable) do
        pcall(function() saved[i] = h:GetStateEnabled(st) end)
        pcall(function() h:SetStateEnabled(st, false) end)
    end

    -- Giành quyền kiểm soát
    pcall(function() hr:SetNetworkOwner(pl) end)

    -- Chia step nếu xa > 500 stud (tránh streaming drop)
    local dist = (hr.Position - finalPos).Magnitude
    local steps = math.clamp(math.ceil(dist / 500), 1, 8)

    task.spawn(function()
        for s = 1, steps do
            if not hr.Parent or not c.Parent then break end
            local alpha = s / steps
            local stepPos = hr.Position:Lerp(finalPos, 1 / (steps - s + 1))
            local stepCF = CFrame.new(stepPos)
            pcall(function() c:PivotTo(stepCF) end)
            pcall(function() hr.CFrame = stepCF end)
            hr.AssemblyLinearVelocity = Vector3.zero
            hr.AssemblyAngularVelocity = Vector3.zero
            task.wait(0.05)
        end

        -- Spam CFrame 20 frame tại đích
        for i = 1, 20 do
            if not hr.Parent or not c.Parent or h.Health <= 0 then break end
            pcall(function() c:PivotTo(target) end)
            pcall(function() hr.CFrame = target end)
            hr.AssemblyLinearVelocity = Vector3.zero
            hr.AssemblyAngularVelocity = Vector3.zero
            task.wait()
        end

        -- Khôi phục state
        for i, st in ipairs(statesToDisable) do
            if saved[i] ~= nil then
                pcall(function() h:SetStateEnabled(st, saved[i]) end)
            end
        end
    end)
end

RS.Heartbeat:Connect(function()
    if not aa.hoverOn or not aa.target or not aa.target.Parent then return end
    local tc=aa.target.Character if not tc then return end
    local thr=tc:FindFirstChild("HumanoidRootPart") if not thr then return end
    local predicted=thr.Position+thr.AssemblyLinearVelocity*0.1
    teleportTo(predicted+Vector3.new(0,aa.hoverDist,0))
end)

-- ESP PLAYER
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
               fxBB=fxBB,scans=scans,dots=dots,ring=ring,ringStroke=ringStroke,dataTop=dataTop}
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

-- NPC / ITEM ESP
local npcEvs={} local itemEvs={}
local npcConn=nil local itemConn=nil
local function isPlayerCharacter(model)
    if not model then return false end
    for _,p in ipairs(P:GetPlayers()) do if p.Character==model then return true end end
    return false
end
local function buildNPCEsp(model)
    if npcEvs[model] then return end
    local hr=model:FindFirstChild("HumanoidRootPart") if not hr then return end
    local hum=model:FindFirstChildOfClass("Humanoid") if not hum then return end
    local fold=Instance.new("Folder",enf) fold.Name=model.Name
    local hl=Instance.new("Highlight",fold)
    hl.Adornee=model hl.FillColor=RED hl.FillTransparency=0.7 hl.OutlineColor=RED
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    local bb=Instance.new("BillboardGui",fold)
    bb.Adornee=hr bb.Size=UDim2.new(0,140,0,26) bb.StudsOffset=Vector3.new(0,3.2,0)
    bb.AlwaysOnTop=true bb.MaxDistance=3000 bb.LightInfluence=0
    local l=Instance.new("TextLabel",bb)
    l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=0.5
    l.BackgroundColor3=Color3.fromRGB(30,0,0) l.Text=model.Name
    l.Font=Enum.Font.Code l.TextSize=12 l.TextColor3=RED
    l.TextStrokeTransparency=0.3 l.TextStrokeColor3=Color3.new(0,0,0)
    npcEvs[model]={folder=fold,hl=hl,bb=bb}
end
local function destroyNPCEsp(model)
    if npcEvs[model] then pcall(function() npcEvs[model].folder:Destroy() end) npcEvs[model]=nil end
end
local function isPickable(inst)
    if inst:IsA("Tool") then return true end
    if inst:IsA("Model") then
        if inst:FindFirstChildOfClass("ProximityPrompt") or inst:FindFirstChildOfClass("ClickDetector") then return true end
        if inst:FindFirstChildWhichIsA("Tool", true) then return true end
    end
    return false
end
local function buildItemEsp(inst)
    if itemEvs[inst] then return end
    local target=inst
    if inst:IsA("Model") then target=inst:FindFirstChildWhichIsA("BasePart",true)
    elseif inst:IsA("Tool") then target=inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart",true) end
    if not target then return end
    local fold=Instance.new("Folder",enf) fold.Name=inst.Name
    local hl=Instance.new("Highlight",fold)
    hl.Adornee=inst hl.FillColor=YEL hl.FillTransparency=0.6 hl.OutlineColor=YEL
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    local bb=Instance.new("BillboardGui",fold)
    bb.Adornee=target bb.Size=UDim2.new(0,120,0,20) bb.StudsOffset=Vector3.new(0,1.5,0)
    bb.AlwaysOnTop=true bb.MaxDistance=2000 bb.LightInfluence=0
    local l=Instance.new("TextLabel",bb)
    l.Size=UDim2.new(1,0,1,0) l.BackgroundTransparency=0.5
    l.BackgroundColor3=Color3.fromRGB(30,25,0) l.Text=inst.Name
    l.Font=Enum.Font.Code l.TextSize=11 l.TextColor3=YEL
    l.TextStrokeTransparency=0.3 l.TextStrokeColor3=Color3.new(0,0,0)
    itemEvs[inst]={folder=fold,hl=hl,bb=bb,target=target}
end
local function destroyItemEsp(inst)
    if itemEvs[inst] then pcall(function() itemEvs[inst].folder:Destroy() end) itemEvs[inst]=nil end
end
local function scanNPCs()
    if not tg.espNPC then return end
    task.spawn(function()
        local all=workspace:GetDescendants()
        for i=1,#all do
            if not tg.espNPC then return end
            local o=all[i]
            if o and o.Parent and o:IsA("Model") and not npcEvs[o] and not evs[o] then
                local hum=o:FindFirstChildOfClass("Humanoid")
                if hum and o:FindFirstChild("HumanoidRootPart") and not isPlayerCharacter(o) then buildNPCEsp(o) end
            end
            if i%60==0 then task.wait() end
        end
    end)
end
local function scanItems()
    if not tg.espItem then return end
    task.spawn(function()
        local all=workspace:GetDescendants()
        for i=1,#all do
            if not tg.espItem then return end
            local o=all[i]
            if o and o.Parent and not itemEvs[o] and isPickable(o) then buildItemEsp(o) end
            if i%60==0 then task.wait() end
        end
    end)
end
local function enableNPCScan()
    if npcConn then return end
    scanNPCs()
    npcConn=workspace.DescendantAdded:Connect(function(o)
        if not tg.espNPC then return end
        if o:IsA("Model") then
            task.wait(0.15)
            if o.Parent and not npcEvs[o] then
                local hum=o:FindFirstChildOfClass("Humanoid")
                if hum and o:FindFirstChild("HumanoidRootPart") and not isPlayerCharacter(o) then buildNPCEsp(o) end
            end
        end
    end)
end
local function disableNPCScan()
    if npcConn then npcConn:Disconnect() npcConn=nil end
    for m in pairs(npcEvs) do destroyNPCEsp(m) end
end
local function enableItemScan()
    if itemConn then return end
    scanItems()
    itemConn=workspace.DescendantAdded:Connect(function(o)
        if not tg.espItem then return end
        task.wait(0.15)
        if o.Parent and not itemEvs[o] and isPickable(o) then buildItemEsp(o) end
    end)
end
local function disableItemScan()
    if itemConn then itemConn:Disconnect() itemConn=nil end
    for m in pairs(itemEvs) do destroyItemEsp(m) end
end
task.spawn(function()
    while true do
        task.wait(2)
        if tg.espNPC then for m in pairs(npcEvs) do if not m.Parent then destroyNPCEsp(m) end end end
        if tg.espItem then for m in pairs(itemEvs) do if not m.Parent then destroyItemEsp(m) end end
    end
end)
task.spawn(function()
    while true do
        task.wait(0.6)
        if tg.espName or tg.espHp or tg.espDist or tg.espBody or tg.espLine then
            for _,p in ipairs(P:GetPlayers()) do
                if p~=pl and p.Character and not evs[p.Character] then
                    if p.Character:FindFirstChild("HumanoidRootPart") then buildESP(p.Character) end
                end
            end
        end
    end
end)

-- NOCLIP
RS.Stepped:Connect(function()
    if not tg.noclip then return end
    local c=pl.Character if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide=false p.CanQuery=false p.CanTouch=false
        end
    end
end)

-- AUTO PICKUP
task.spawn(function()
    while true do
        task.wait(0.4)
        if tg.autoPick then
            local c=pl.Character
            local hr=c and c:FindFirstChild("HumanoidRootPart")
            if hr then
                local nearby={}
                for inst in pairs(itemEvs) do
                    if inst.Parent and itemEvs[inst].target and itemEvs[inst].target.Parent then
                        local pos=itemEvs[inst].target.Position
                        if (pos-hr.Position).Magnitude<12 then table.insert(nearby,itemEvs[inst].target) end
                    end
                end
                if #nearby==0 then
                    for _,o in ipairs(workspace:GetDescendants()) do
                        if isPickable(o) then
                            local part = o:IsA("BasePart") and o or o:FindFirstChildWhichIsA("BasePart",true)
                            if part and part.Parent and (part.Position-hr.Position).Magnitude<12 then table.insert(nearby,part) end
                        end
                    end
                end
                for _,part in ipairs(nearby) do
                    pcall(function()
                        if firetouchinterest then
                            firetouchinterest(hr,part,0) task.wait() firetouchinterest(hr,part,1)
                        end
                        if firetouchinterest then
                            for _,op in ipairs(c:GetDescendants()) do
                                if op:IsA("BasePart") then
                                    pcall(function()
                                        firetouchinterest(op,part,0) firetouchinterest(op,part,1)
                                    end)
                                end
                            end
                        end
                        if fireproximityprompt then
                            local pp=part:FindFirstChildOfClass("ProximityPrompt")
                            if pp then fireproximityprompt(pp) end
                        end
                    end)
                end
            end
        end
    end
end)

-- ANTI AFK / TRAIL
task.spawn(function()
    while true do
        task.wait(20)
        if tg.antiAFK then
            local vim=getVIM()
            if vim then pcall(function() vim:CaptureController() vim:ClickButton2(Vector2.new()) end) end
        end
    end
end)
local trailCache=nil local trailAtts={}
RS.Heartbeat:Connect(function()
    local c=pl.Character if not c then trailCache=nil return end
    local hr=c:FindFirstChild("HumanoidRootPart") if not hr then return end
    if tg.trail then
        if not trailCache or trailCache.Parent~=hr then
            if trailCache then trailCache:Destroy() end
            for _,a in ipairs(trailAtts) do if a and a.Parent then a:Destroy() end end
            trailAtts={}
            local a0=Instance.new("Attachment",hr) a0.Position=Vector3.new(0,0.5,0)
            local a1=Instance.new("Attachment",hr) a1.Position=Vector3.new(0,-0.5,0)
            trailAtts={a0,a1}
            local tr=Instance.new("Trail",hr)
            tr.Attachment0=a0 tr.Attachment1=a1 tr.Lifetime=1.2 tr.MinLength=0 tr.FaceCamera=true
            trailCache=tr
        end
        if trailCache then
            local hue=(tick()*0.4)%1
            trailCache.Color=ColorSequence.new(Color3.fromHSV(hue,1,1))
            trailCache.Transparency=NumberSequence.new(0.3)
        end
    else
        if trailCache then trailCache:Destroy() trailCache=nil end
        for _,a in ipairs(trailAtts) do if a and a.Parent then a:Destroy() end end
        trailAtts={}
    end
end)

-- POPULATE UI
mkSec(pages["MOVE"],"// SPEED")
mkSli(pages["MOVE"],"Walk Speed",16,500,16,function(v) stt.ws=v end)
mkSec(pages["MOVE"],"// JUMP")
mkSli(pages["MOVE"],"Jump Power",50,300,50,function(v) stt.jp=v end)
mkTog(pages["MOVE"],"INFINITE JUMP",false,function(on) tg.infJump=on end)
mkSec(pages["MOVE"],"// HOVER")
mkSli(pages["MOVE"],"Hover Height",2,20,10,function(v) stt.hh=v end)
mkTog(pages["MOVE"],"CHAN MA (hover)",false,function(on) tg.hover=on end)

mkSec(pages["ESP"],"// PLAYER ESP")
mkTog(pages["ESP"],"ESP LINE (RAINBOW)",false,function(on) tg.espLine=on end)
mkTog(pages["ESP"],"ESP NAME",false,function(on) tg.espName=on applyESPToggles() end)
mkTog(pages["ESP"],"ESP HEALTH",false,function(on) tg.espHp=on applyESPToggles() end)
mkTog(pages["ESP"],"ESP DISTANCE",false,function(on) tg.espDist=on applyESPToggles() end)
mkTog(pages["ESP"],"ESP BODY FX",false,function(on) tg.espBody=on applyESPToggles() end)
mkSec(pages["ESP"],"// NPC / ITEM ESP")
mkTog(pages["ESP"],"NPC / ZOMBIE ESP",false,function(on) tg.espNPC=on if on then enableNPCScan() else disableNPCScan() end end)
mkTog(pages["ESP"],"ITEM ESP (PICKABLE)",false,function(on) tg.espItem=on if on then enableItemScan() else disableItemScan() end end)

mkSec(pages["COMBAT"],"// AUTO ATTACK")
mkSli(pages["COMBAT"],"Atk Speed",1,200,200,function(v) aa.speed=v end)
mkSli(pages["COMBAT"],"Hover Dist",0,10,0,function(v) aa.hoverDist=v end)
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
end)
mkSec(pages["COMBAT"],"// AIMLOCK")
mkTog(pages["COMBAT"],"AIM ENEMY",false,function(on) tg.aimE=on end)
mkTog(pages["COMBAT"],"AIM ALL",false,function(on) tg.aimA=on end)

mkSec(pages["PLAYER"],"// PERFORMANCE")
mkTog(pages["PLAYER"],"FPS BOOST",false,function(on) tg.fps=on tFPS(on) end)
mkTog(pages["PLAYER"],"MAP BRIGHT",false,function(on) tg.mapBright=on tMapBright(on) end)
mkSec(pages["PLAYER"],"// SURVIVAL")
mkTog(pages["PLAYER"],"ANTI AFK",false,function(on) tg.antiAFK=on end)
mkTog(pages["PLAYER"],"NOCLIP (SMOOTH)",false,function(on) tg.noclip=on end)
mkTog(pages["PLAYER"],"AUTO PICKUP (12m)",false,function(on) tg.autoPick=on end)
mkSec(pages["PLAYER"],"// EFFECT")
mkTog(pages["PLAYER"],"TRAIL RAINBOW",false,function(on) tg.trail=on end)
mkSec(pages["PLAYER"],"// CAMERA")
mkSli(pages["PLAYER"],"FOV",70,120,70,function(v) cam.FieldOfView=v end)
mkSec(pages["PLAYER"],"// UTILITIES")
mkBtn(pages["PLAYER"],"RESET CHARACTER",function()
    local c=pl.Character if c then local h=c:FindFirstChildOfClass("Humanoid") if h then h.Health=0 end end
end)
mkBtn(pages["PLAYER"],"REJOIN SERVER",function()
    pcall(function() TS:TeleportToPlaceInstance(game.PlaceId,game.JobId,pl) end)
end)

-- ================================================================
-- =================== TELE TAB (FULL FIX) ========================
-- ================================================================
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
mkSli(pages["TELE"],"TP Height",-10,30,3,function(v) stt.tph=v end)

-- Nút tele đến player - dùng full teleportTo mạnh
local tpCD=false
mkBtn(pages["TELE"],"TELEPORT TO PLAYER",function()
    if not tpSelected then
        stLbl.Text="[ !! ] chon player truoc" return
    end
    if tpCD then return end
    local th=tpSelected.Character and tpSelected.Character:FindFirstChild("HumanoidRootPart")
    if not th then
        stLbl.Text="[ !! ] player chua spawn" return
    end
    tpCD=true
    stLbl.Text="[ .. ] teleporting to "..tpSelected.Name
    teleportTo(th.Position+Vector3.new(0,stt.tph,0))
    task.wait(0.8)
    tpCD=false
    stLbl.Text="[ OK ] teleported"
end)

-- Nút tele đến player - lặp nhiều lần (cực xa)
mkBtn(pages["TELE"],"TELEPORT x3 (XUYÊN MAP)",function()
    if not tpSelected then stLbl.Text="[ !! ] chon player truoc" return end
    task.spawn(function()
        for i=1,3 do
            local th=tpSelected.Character and tpSelected.Character:FindFirstChild("HumanoidRootPart")
            if not th then return end
            teleportTo(th.Position+Vector3.new(0,stt.tph,0))
            task.wait(0.6)
        end
        stLbl.Text="[ OK ] x3 done"
    end)
end)

mkSec(pages["TELE"],"// TELEPORT TO COORDINATES")
local coordXBox, coordYBox, coordZBox
local function makeCoordRow()
    local row=Instance.new("Frame",pages["TELE"])
    row.Size=UDim2.new(1,-8,0,26) row.BackgroundColor3=BG
    row.BackgroundTransparency=0.4 row.BorderSizePixel=0 row.ZIndex=112
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,3)
    row.LayoutOrder=#pages["TELE"]:GetChildren()*10
    local lbl=Instance.new("TextLabel",row)
    lbl.Size=UDim2.new(0,40,1,0) lbl.Position=UDim2.new(0,6,0,0)
    lbl.BackgroundTransparency=1 lbl.Text="X Y Z" lbl.Font=Enum.Font.Code
    lbl.TextSize=9 lbl.TextColor3=TX lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=113
    local function makeBox(xOff, def)
        local b=Instance.new("TextBox",row)
        b.Size=UDim2.new(0,74,0,18) b.Position=UDim2.new(0,xOff,.5,-9)
        b.BackgroundColor3=Color3.fromRGB(0,25,15) b.BorderSizePixel=0
        b.Text=def b.Font=Enum.Font.Code b.TextSize=11 b.TextColor3=G
        b.ClearTextOnFocus=false b.ZIndex=113
        Instance.new("UICorner",b).CornerRadius=UDim.new(0,3)
        local s=Instance.new("UIStroke",b) s.Color=DIM s.Thickness=1
        return b
    end
    coordXBox=makeBox(44, "0")
    coordYBox=makeBox(122, "5")
    coordZBox=makeBox(200, "0")
end
makeCoordRow()

mkBtn(pages["TELE"],"TELEPORT TO COORDINATES",function()
    local x=tonumber(coordXBox.Text) or 0
    local y=tonumber(coordYBox.Text) or 5
    local z=tonumber(coordZBox.Text) or 0
    teleportTo(Vector3.new(x,y,z))
end)

mkBtn(pages["TELE"],"USE MY COORDINATES",function()
    local c=pl.Character
    local hr=c and c:FindFirstChild("HumanoidRootPart")
    if hr then
        coordXBox.Text=tostring(math.floor(hr.Position.X))
        coordYBox.Text=tostring(math.floor(hr.Position.Y))
        coordZBox.Text=tostring(math.floor(hr.Position.Z))
    end
end)

mkSec(pages["TELE"],"// 3008 PRESETS")
mkBtn(pages["TELE"],"MAP CENTER (0, 5, 0)",function()
    teleportTo(Vector3.new(0,5,0))
end)
mkBtn(pages["TELE"],"SKY HIGH (my pos +1000Y)",function()
    local c=pl.Character
    local hr=c and c:FindFirstChild("HumanoidRootPart")
    if hr then teleportTo(hr.Position+Vector3.new(0,1000,0)) end
end)
mkBtn(pages["TELE"],"SPIRAL SCAN 8 HƯỚNG",function()
    local c=pl.Character
    local hr=c and c:FindFirstChild("HumanoidRootPart")
    if not hr then return end
    local start=hr.Position
    task.spawn(function()
        for i=1,8 do
            local angle=math.rad(i*45)
            local r=500
            local pos=Vector3.new(start.X+math.cos(angle)*r, start.Y, start.Z+math.sin(angle)*r)
            teleportTo(pos)
            task.wait(1)
        end
        teleportTo(start)
    end)
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
mkBtn(pages["TELE"],"BACK +20m",function()
    local c=pl.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        teleportTo(c.HumanoidRootPart.Position-c.HumanoidRootPart.CFrame.LookVector*20)
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
                dlgBtn("RENAME",YEL,function()
                    closeDlg() task.wait(0.1)
                    openTxt("RENAME POINT",pt2.name,function(t) pt2.name=t svW() end)
                end)
                dlgBtn("DELETE",RED,function() pt2.cf=nil svW() closeDlg() end)
                dlgBtn("CLOSE",DIM,function() closeDlg() end)
                dlg.Visible=true dlgOverlay.Visible=true
            end)
        end
        dlgBtn("RENAME SLOT",YEL,function()
            closeDlg() task.wait(0.1)
            openTxt("RENAME SLOT",wd.slots[sIdx].name,function(t)
                wd.slots[sIdx].name=t svW()
                slotBtn.Text="  > [ "..t.." ]"
            end)
        end)
        dlgBtn("CLOSE",DIM,function() closeDlg() end)
        dlg.Visible=true dlgOverlay.Visible=true
    end)
end

-- INFO tab
local infoRoot=Instance.new("Frame",pages["INFO"])
infoRoot.Size=UDim2.new(1,-8,0,0)
infoRoot.AutomaticSize=Enum.AutomaticSize.Y
infoRoot.BackgroundTransparency=1
infoRoot.LayoutOrder=10
infoRoot.ZIndex=115
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
        if pages["INFO"] and pages["INFO"].Visible then
            local fps=frmCnt*2 frmCnt=0
            table.insert(fpsHist,fps)
            if #fpsHist>30 then table.remove(fpsHist,1) end
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
                infoRefs.fps.Text=math.floor(fps).." fps"
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
                infoRefs.ver.Text="v12.0"
                local a={}
                if tg.hover then table.insert(a,"HOVER") end
                if tg.espLine then table.insert(a,"LINE") end
                if tg.espName then table.insert(a,"NAME") end
                if tg.espHp then table.insert(a,"HP") end
                if tg.espDist then table.insert(a,"DIST") end
                if tg.espBody then table.insert(a,"BODY") end
                if tg.espNPC then table.insert(a,"NPC") end
                if tg.espItem then table.insert(a,"ITEM") end
                if tg.noclip then table.insert(a,"NOCLIP") end
                if tg.autoPick then table.insert(a,"PICK") end
                if tg.mapBright then table.insert(a,"BRIGHT") end
                if tg.fps then table.insert(a,"FPS+") end
                if tg.antiAFK then table.insert(a,"AFK") end
                if tg.trail then table.insert(a,"TRAIL") end
                if aa.enabled then table.insert(a,"AA") end
                infoRefs.active.Text=(#a==0) and "none" or table.concat(a,",")
            end)
        end
        task.wait(0.5)
    end
end)

switchTab("MOVE")

-- BOOT
local BOOT_LINES={"> init kernel...","> load modules [OK]","> bypass AC...","> inject payload...","> conn established"}
local titleTarget="> ROOT@NEKO:~$ ./run.sh"
local bootRunning=false
local function typewriter(txt,lbl,spd,done)
    task.spawn(function()
        lbl.Text=""
        for i=1,#txt do lbl.Text=string.sub(txt,1,i) task.wait(spd) end
        if done then done() end
    end)
end
local function bootSequence()
    if bootRunning then return end
    bootRunning=true
    for _,line in ipairs(BOOT_LINES) do stLbl.Text=line stLbl.TextColor3=G task.wait(0.08) end
    stLbl.Text="[ OK ] ready"
    typewriter(titleTarget,title,0.015)
    task.wait(0.1)
    bootRunning=false
end

local menuOpen=false
local function showMenu()
    if menuOpen then return end
    menuOpen=true
    main.Visible=true
    main.Size=UDim2.new(0,0,0,0) main.BackgroundTransparency=1
    T:Create(main,TweenInfo.new(0.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,420,0,340), BackgroundTransparency=0.05
    }):Play()
    stk.Transparency=1
    T:Create(stk,TweenInfo.new(0.3),{Transparency=0}):Play()
    bootSequence()
end
function hideMenu()
    if not menuOpen then return end
    menuOpen=false
    local tw=T:Create(main,TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.In),{
        Size=UDim2.new(0,0,0,0), BackgroundTransparency=1
    })
    tw:Play()
    tw.Completed:Connect(function() main.Visible=false end)
end

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

-- RENDER LOOP
local rT=0
local drawingAvailable=(Drawing~=nil and Drawing.new~=nil)
RS.RenderStepped:Connect(function(dt)
    rT=tick()
    if menuOpen then
        for _,c in ipairs(rainCols) do
            c.offset=c.offset+c.speed*dt*2
            if c.offset>300 then c.offset=-300 end
            c.lbl.Position=UDim2.new(c.lbl.Position.X.Scale,c.lbl.Position.X.Offset,0,c.offset)
        end
    end
    tglGlow.Transparency=0.7+math.abs(math.sin(rT*2))*0.2

    if tg.espLine and drawingAvailable then
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
                        local m=measureBody(char)
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

    if tg.aimE or tg.aimA then
        local c=pl.Character
        if c and c:FindFirstChild("HumanoidRootPart") then
            local hds={}
            for _,p in ipairs(P:GetPlayers()) do
                if p~=pl and p.Character then
                    local hd=p.Character:FindFirstChild("Head")
                    local h=p.Character:FindFirstChildOfClass("Humanoid")
                    if hd and h and h.Health>0 then
                        local isE=true
                        if p.Team and pl.Team and p.Team==pl.Team then isE=false end
                        if tg.aimA or (tg.aimE and isE) then table.insert(hds,hd) end
                    end
                end
            end
            if #hds>0 then
                local cn=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
                local bt,bd=nil,math.huge
                for _,h in ipairs(hds) do
                    local sp,on2=cam:WorldToViewportPoint(h.Position)
                    if on2 then
                        local d=(Vector2.new(sp.X,sp.Y)-cn).Magnitude
                        if d<bd then bd=d bt=h end
                    end
                end
                if bt then cam.CFrame=cam.CFrame:Lerp(CFrame.lookAt(cam.CFrame.Position,bt.Position),.3) end
            end
        end
    end
end)

-- Movement
RS.Heartbeat:Connect(function(dt)
    pcall(function()
        local c=pl.Character
        if c then
            local h=c:FindFirstChildOfClass("Humanoid")
            local hr=c:FindFirstChild("HumanoidRootPart")
            if h and hr and h.Health>0 then
                if not tg.hover then
                    if stt.ws>16 then
                        h.WalkSpeed=stt.ws
                        if h.MoveDirection.Magnitude>.1 then
                            local v=h.MoveDirection.Unit*stt.ws
                            hr.AssemblyLinearVelocity=Vector3.new(v.X,hr.AssemblyLinearVelocity.Y,v.Z)
                        end
                    else h.WalkSpeed=16 end
                end
                if stt.jp>50 then h.UseJumpPower=true h.JumpPower=stt.jp end
                if tg.hover then
                    h.HipHeight=stt.hh
                    h:SetStateEnabled(Enum.HumanoidStateType.Falling,false)
                    h:SetStateEnabled(Enum.HumanoidStateType.Freefall,false)
                    h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
                    pcall(function() h:ChangeState(Enum.HumanoidStateType.Running) end)
                else
                    if h.HipHeight>2 then h.HipHeight=2 end
                    h:SetStateEnabled(Enum.HumanoidStateType.Falling,true)
                    h:SetStateEnabled(Enum.HumanoidStateType.Freefall,true)
                    h:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)
                end
            end
        end
    end)
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
        task.wait(1)
        pcall(function() fpsLbl.Text=math.floor(frmCnt).." FPS" frmCnt=0 end)
    end
end)

print("[HACKER NEKO v12] loaded - TELE FIX")

end)

if not ok then
    warn("[HACKER NEKO ERROR] "..tostring(err))
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title="HACKER NEKO ERROR", Text=tostring(err), Duration=15
        })
    end)
end