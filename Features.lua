-- =================================================================================
-- Rayfield UI Template for Fish It Hub - Step 43: MANUAL KEY SYSTEM (FIXED + NEW METHOD INTEGRATED)
-- Status: Memperbaiki struktur dan duplikasi kode di key system manual.
-- FIX TAMBAHAN: Integrasi metode baru untuk auto fishing tanpa mengubah yang lain.
-- METODE BARU: Hook __namecall untuk memaksa Args[2] = 1 pada RF/RequestFishingMinigameStarted.
-- =================================================================================

-- Load Rayfield UI Library (PAKAI LINK RESMI)
local success, Rayfield = pcall(function() return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))() end)
if not success then
    warn("Gagal load Rayfield library! Error:", Rayfield)
    return
end

-- ====================
-- GLOBAL VARIABLES & CFRAMES
-- ====================
-- (Biarkan sama)
local autoFishingActive = false; local autoFishingDelay = 10; local fishingCompleteDelay = 2; local autoFishingLoop = nil; local bypassPingActive = false; local autoRecastActive = false; local autoRecastDelay = 5; local autoSellActive = false; local autoSellThreshold = 30; local autoSellLoop = nil; local lastActivity = tick()
local selectedIsland = "Fisherman Island"; local selectedPlayerName = "None"
local floatingActive = false; local floatLoop = nil; local lockPosLoop = nil; local savedPosition = CFrame.new(); local disableCutsceneActive = false; local cutsceneRemoteHook = nil; local originalLighting = { ClockTime = game.Lighting.ClockTime, Brightness = game.Lighting.Brightness, Ambient = game.Lighting.Ambient, GlobalShadows = game.Lighting.GlobalShadows, FogEnd = game.Lighting.FogEnd }; local originalQuality = settings().Rendering.QualityLevel
local autoTeleportEventActive = false; local selectedEventName = "Megalodon Hunt"; local eventScanLoop = nil

-- ====================
-- EVENT KEYWORDS & CFRAMES
-- ====================
-- (Biarkan sama)
local EventKeywords = { ["Megalodon Hunt"] = "megalodon", ["Admin Event"] = "admin", ["Ghost Worm"] = "ghost worm", ["Worm Hunt"] = "worm", ["Shark Hunt"] = "shark", ["Ghost Shark Hunt"] = "ghost shark", ["Shocked"] = "shocked", ["Blackhole"] = "blackhole", ["Meteor Rain"] = "meteor" }
local IslandCFrames = { ["Ancient Jungle"] = CFrame.new(1478.29895, 427.588013, -613.499023, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Coral Reefs"] = CFrame.new(-3023.97119, 337.812927, 2195.60913, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Crater Island"] = CFrame.new(1010.01001, 252, 5078.45117, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Esoteric Depths"] = CFrame.new(1944.77881, 393.562927, 1371.35913, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Fisherman Island"] = CFrame.new(45.2788086, 252.562927, 2987.10913, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Kohana"] = CFrame.new(-650.971191, 208.693695, 711.10907, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Kohana Volcano"] = CFrame.new(-594.971252, 396.65213, 149.10907, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Mount Hallow"] = CFrame.new(2456.10791, 616.125, 3075.13892, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008, 1, 0, 0, 0, 1, 0, 0, 0, 1), ["Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298, 1, 0, 0, 0, 1, 0, 0, 0, 1) }

-- ====================
-- REMOTES & FUNCTIONS (Biarkan sama, tapi di luar CreateMainWindow)
-- ====================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local net = ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0")
if not net then warn("Path net tidak ditemukan!") else net = net.net; print("Net path found:", net) end
local RemoteChargeRod = net and net:FindFirstChild("RF/ChargeFishingRod")
local RemoteRequestMinigame = net and net:FindFirstChild("RF/RequestFishingMinigameStarted")
local RemoteFishingCompleted = net and net:FindFirstChild("RE/FishingCompleted")
local RemoteSellAllItems = net and net:FindFirstChild("RF/SellAllItems")
local RemoteUpdateFishingRadar = net and net:FindFirstChild("RF/UpdateFishingRadar")
local RemoteReplicateCutscene = net and net:FindFirstChild("RE/ReplicateCutscene")
local RFPurchaseBoat = net and net:FindFirstChild("RF/PurchaseBoat")
local RFPurchaseGear = net and net:FindFirstChild("RF/PurchaseGear")
local RFPurchaseWeatherEvent = net and net:FindFirstChild("RF/PurchaseWeatherEvent")
local RFPurchaseFishingRod = net and net:FindFirstChild("RF/PurchaseFishingRod")
print("Remotes found - ... SellAll:", RemoteSellAllItems)
print("Remotes Player Config - Radar:", RemoteUpdateFishingRadar, "Cutscene:", RemoteReplicateCutscene)
print("Remotes Shop - ... Rod:", RFPurchaseFishingRod)
if RemoteReplicateCutscene then pcall(function() RemoteReplicateCutscene.Name="Hooked_ReplicateCutscene"; local F=Instance.new("RemoteEvent",RemoteReplicateCutscene.Parent); F.Name="RE/ReplicateCutscene"; F.OnClientEvent:Connect(function(...)if not disableCutsceneActive then RemoteReplicateCutscene:Fire(...)end end); print("Hook Cutscene OK.")end) else print("Hook Cutscene FAIL.")end

-- ====================
-- NEW METHOD INTEGRATION (TAMBAHKAN DI SINI UNTUK AUTO FISHING)
-- ====================
-- Metode baru: Hook __namecall untuk memaksa Args[2] = 1 pada RF/RequestFishingMinigameStarted
local ReplicatedStorageHook = cloneref and cloneref(game:GetService("ReplicatedStorage")) or game:GetService("ReplicatedStorage")
local RE_RequestFishing = ReplicatedStorageHook.Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net:FindFirstChild("RF/RequestFishingMinigameStarted")
local OldHook
OldHook = hookmetamethod(game, "__namecall", function(Self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if Self == RE_RequestFishing and Method == "InvokeServer" then
        Args[2] = 1
        return OldHook(Self, table.unpack(Args))
    end
    return OldHook(Self, ...)
end)

local function GetFishCount() local p=game.Players.LocalPlayer; local c=0; local b=p:FindFirstChild("Backpack"); if b then for _,i in ipairs(b:GetChildren())do if i:IsA("Tool")and string.lower(i.Name):find("fish")then c=c+1 end end end; local inv=p:FindFirstChild("Inventory")or p:FindFirstChild("Data")and p.Data:FindFirstChild("Inventory"); if inv then for _,i in ipairs(inv:GetChildren())do if i:IsA("Tool")or i:IsA("StringValue")and string.lower(i.Name):find("fish")then c=c+1 end end end; return c end
local function SellAllNow() if RemoteSellAllItems then local s,r=pcall(function()RemoteSellAllItems:InvokeServer()end); if s then Rayfield:Notify({Title="Sell",Content="OK"})else Rayfield:Notify({Title="Sell Err",Content="Invoke? "..tostring(r)})end else Rayfield:Notify({Title="Sell Err",Content="Remote?"})end end
local function ToggleAutoSell(s) autoSellActive=s; if s then autoSellLoop=game:GetService("RunService").Heartbeat:Connect(function()if not autoSellActive then return end; if GetFishCount()>=autoSellThreshold then SellAllNow();task.wait(1)end end); Rayfield:Notify({Title="AutoSell",Content="ON"})else if autoSellLoop then autoSellLoop:Disconnect();autoSellLoop=nil end; Rayfield:Notify({Title="AutoSell",Content="OFF"})end end
local function ToggleBypassPing(s) bypassPingActive=s; pcall(function()settings().Network.IncomingReplicationLag=s and 0 or 0.1 end); Rayfield:Notify({Title="Bypass Ping",Content=s and "ON" or "OFF"})end
local function RunMasterFarm(V) autoFishingActive=V; if V then ToggleBypassPing(true); Rayfield:Notify({Title="Master Farm",Content="Started",Duration=3,Image=4483362458}); if autoFishingLoop then autoFishingLoop:Disconnect();autoFishingLoop=nil end; autoFishingLoop=task.spawn(function()lastActivity=tick(); while autoFishingActive do local cA={[4]=tick()}; if RemoteChargeRod then pcall(function()RemoteChargeRod:InvokeServer(unpack(cA))end)end; local rA={[1]=math.random(-1,1),[2]=math.random(0,1),[3]=tick()}; if RemoteRequestMinigame then pcall(function()RemoteRequestMinigame:InvokeServer(unpack(rA))end)end; wait(fishingCompleteDelay); if RemoteFishingCompleted then pcall(function()RemoteFishingCompleted:FireServer()end)end; if autoRecastActive then wait(autoRecastDelay); if RemoteChargeRod then pcall(function()RemoteChargeRod:InvokeServer(unpack(cA))end)end; if RemoteRequestMinigame then pcall(function()RemoteRequestMinigame:InvokeServer(unpack(rA))end)end end; if tick()-lastActivity>1140 then pcall(function()game:GetService("VirtualInputManager"):SendMouseMoveEvent(500,500,game)end);lastActivity=tick()end; wait(autoFishingDelay)end end) else if autoFishingLoop then autoFishingLoop=nil end; ToggleBypassPing(false); Rayfield:Notify({Title="Master Farm",Content="Stopped",Duration=3,Image=4483362458})end end
local function TeleportBrutal(tCF) local p=game.Players.LocalPlayer; local c=p.Character; if not c or not c:FindFirstChild("HumanoidRootPart")or not c:FindFirstChildOfClass("Humanoid")then Rayfield:Notify({Title="TP Err",Content="Char?"}); return end; local hrp=c.HumanoidRootPart; local h=c:FindFirstChildOfClass("Humanoid"); pcall(function()h:ChangeState(Enum.HumanoidStateType.Physics)end); local s,e=pcall(function()hrp.Anchored=true; c:SetPrimaryPartCFrame(tCF); local st=tick(); while tick()-st<1 do if not hrp or not hrp.Parent then break end; hrp.CFrame=tCF; game:GetService("RunService").Heartbeat:Wait()end; hrp.Anchored=false end); pcall(function()h:ChangeState(Enum.HumanoidStateType.Running)end); if not s then Rayfield:Notify({Title="TP Err",Content="Err: "..tostring(e)})end; task.wait(0.1); if(hrp.Position-tCF.Position).Magnitude>20 then Rayfield:Notify({Title="TP FAIL",Content="Rubberband."})end end
local function TeleportToIsland(iN) local cf=IslandCFrames[iN]; if not cf then Rayfield:Notify({Title="TP Err",Content="CFrame?"}); return end; Rayfield:Notify({Title="TP",Content="To "..iN}); TeleportBrutal(cf) end
local function TeleportToPlayer(pN) local p=game.Players:FindFirstChild(pN); if not p then Rayfield:Notify({Title="TP Err",Content="Player?"}); return end; if not p.Character or not p.Character:FindFirstChild("HumanoidRootPart")then Rayfield:Notify({Title="TP Err",Content="Char?"}); return end; local cf=p.Character.HumanoidRootPart.CFrame; Rayfield:Notify({Title="TP",Content="To "..pN}); TeleportBrutal(cf) end
local function RespawnNow() local p=game.Players.LocalPlayer; local c=p.Character; if c then c:BreakJoints(); p:LoadCharacter(); p.CharacterAdded:Wait(); Rayfield:Notify({Title="Respawn",Content="OK"}); TeleportBrutal(IslandCFrames["Fisherman Island"])else Rayfield:Notify({Title="Respawn Err",Content="Char?"})end end
local function ToggleFloating(s) floatingActive=s; if s then Rayfield:Notify({Title="Floating",Content="ON"}); floatLoop=game:GetService("RunService").Heartbeat:Connect(function()if not floatingActive then return end; local c=game.Players.LocalPlayer.Character; if c and c:FindFirstChild("Humanoid")then c.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)end end)else Rayfield:Notify({Title="Floating",Content="OFF"}); if floatLoop then floatLoop:Disconnect();floatLoop=nil end; local c=game.Players.LocalPlayer.Character; if c and c:FindFirstChild("Humanoid")then c.Humanoid:ChangeState(Enum.HumanoidStateType.Running)end end end
local function ToggleFishingRadar(s) if RemoteUpdateFishingRadar then pcall(function()RemoteUpdateFishingRadar:InvokeServer(s)end); Rayfield:Notify({Title="Radar",Content=s and "ON" or "OFF"})else Rayfield:Notify({Title="Radar Err",Content="Remote?"})end end
local function ToggleDarkMode(s) if s then Rayfield:Notify({Title="Dark",Content="ON"}); game.Lighting.ClockTime=0; game.Lighting.Brightness=1; game.Lighting.Ambient=Color3.fromRGB(20,20,20)else Rayfield:Notify({Title="Dark",Content="OFF"}); game.Lighting.ClockTime=originalLighting.ClockTime; game.Lighting.Brightness=originalLighting.Brightness; game.Lighting.Ambient=originalLighting.Ambient end end
local function ToggleAntiLag(s) if s then Rayfield:Notify({Title="AntiLag",Content="ON"}); game.Lighting.GlobalShadows=false; game.Lighting.FogEnd=999999; settings().Rendering.QualityLevel=Enum.QualityLevel.Level01 else Rayfield:Notify({Title="AntiLag",Content="OFF"}); game.Lighting.GlobalShadows=originalLighting.GlobalShadows; game.Lighting.FogEnd=originalLighting.FogEnd; settings().Rendering.QualityLevel=originalQuality end end
local function ToggleDisableCutscene(s) disableCutsceneActive=s; Rayfield:Notify({Title="NoCutscene",Content=s and "ON" or "OFF"})end
local function ToggleLockPosition(s) if s then local p=game.Players.LocalPlayer; local c=p.Character; if not c or not c:FindFirstChild("HumanoidRootPart")then Rayfield:Notify({Title="Lock Err",Content="Char?"}); return end; savedPosition=c.HumanoidRootPart.CFrame; Rayfield:Notify({Title="Lock",Content="ON"}); lockPosLoop=game:GetService("RunService").Heartbeat:Connect(function()local p=game.Players.LocalPlayer; local c=p.Character; if not c or not c:FindFirstChild("HumanoidRootPart")then ToggleLockPosition(false); return end; c.HumanoidRootPart.CFrame=savedPosition end)else Rayfield:Notify({Title="Lock",Content="OFF"}); if lockPosLoop then lockPosLoop:Disconnect();lockPosLoop=nil end end end
local function ToggleAutoTeleportEvent(s) autoTeleportEventActive=s; if s then local kw=EventKeywords[selectedEventName]; if not kw then Rayfield:Notify({Title="Event Err",Content="Keyword?"}); return end; Rayfield:Notify({Title="Event Scan",Content="Scan '"..kw.."'..."}); eventScanLoop=game:GetService("RunService").Heartbeat:Connect(function()if not autoTeleportEventActive then return end; pcall(function()for _,c in ipairs(game:GetService("Workspace"):GetChildren())do if string.find(string.lower(c.Name),kw)then Rayfield:Notify({Title="Event Found!",Content="TP to "..c.Name}); local cf=c:GetPrimaryPartCFrame(); task.spawn(function()TeleportBrutal(cf)end); break end end end)end)else Rayfield:Notify({Title="Event Scan",Content="Stop"}); if eventScanLoop then eventScanLoop:Disconnect();eventScanLoop=nil end end end

-- ====================
-- FUNGSI BUAT BIKIN UI UTAMA (BARU)
-- ====================
local function CreateMainWindow()
    local Window = Rayfield:CreateWindow({
        Name = "Fish It Hub - Step 43: Manual Key System", -- Ganti Nama
        LoadingTitle = "Mengdut Hub",
        LoadingSubtitle = "by Mengdut - Loading...",
        Theme = "Default"
    })

    if not Window then
        warn("ERROR FATAL: 'Window' GAGAL DIBUAT setelah login!")
        return -- Stop kalau gagal
    else
        print("Main Window object created:", Window)
    end

    -- ====================
    -- TAB 1: AUTO FISHING
    -- ====================
    local AutoFishingTab=Window:CreateTab("Auto Fishing",4483362458); AutoFishingTab:CreateSection("Sub Menu Auto Fishing"); AutoFishingTab:CreateToggle({Name="Auto Fishing (Master Farm)",CurrentValue=false,Flag="AutoFishing",Callback=function(s)pcall(function()RunMasterFarm(s)end)end}); AutoFishingTab:CreateSlider({Name="Auto Fishing Delay",Range={0.1,10},Increment=0.1,Suffix="s",CurrentValue=10,Flag="AutoFishingDelay",Callback=function(v)pcall(function()autoFishingDelay=v end)end}); AutoFishingTab:CreateSlider({Name="Fishing Complete Delay",Range={0.1,10},Increment=0.1,Suffix="s",CurrentValue=2,Flag="FishingCompleteDelay",Callback=function(v)pcall(function()fishingCompleteDelay=v end)end}); AutoFishingTab:CreateToggle({Name="Auto Recast/Anti Stuck",CurrentValue=false,Flag="AutoRecast",Callback=function(s)pcall(function()autoRecastActive=s end)end}); AutoFishingTab:CreateSlider({Name="Auto Recast Delay",Range={0.1,10},Increment=0.1,Suffix="s",CurrentValue=5,Flag="AutoRecastDelay",Callback=function(v)pcall(function()autoRecastDelay=v end)end}); AutoFishingTab:CreateButton({Name="Respawn Now",Callback=function()pcall(function()task.spawn(RespawnNow)end)end})

    -- ====================
    -- TAB 2: AUTO SELL
    -- ====================
    local AutoSellTab=Window:CreateTab("Auto Sell",4483362458); AutoSellTab:CreateSection("Sub Menu Auto Sell"); AutoSellTab:CreateButton({Name="Sell All Now",Callback=function()pcall(SellAllNow)end}); AutoSellTab:CreateToggle({Name="Auto Sell Caught Fish",CurrentValue=false,Flag="AutoSellCaughtFish",Callback=function(s)pcall(function()ToggleAutoSell(s)end)end}); AutoSellTab:CreateSlider({Name="Auto Sell Threshold",Range={1,100},Increment=1,Suffix=" Fish",CurrentValue=30,Flag="AutoSellThreshold",Callback=function(v)pcall(function()autoSellThreshold=v;Rayfield:Notify({Title="Thresh Upd",Content=v.." fish"})end)end})

    -- ====================
    -- TAB 3: TELEPORT
    -- ====================
    local TeleportTab=Window:CreateTab("Teleport",4483362458); TeleportTab:CreateSection("Sub Menu Teleport Island"); local islandOptions={"Ancient Jungle","Coral Reefs","Crater Island","Esoteric Depths","Fisherman Island","Kohana","Kohana Volcano","Lost Isle","Mount Hallow","Tropical Grove","Weather Machine"}; selectedIsland="Fisherman Island"; TeleportTab:CreateDropdown({Name="Select Island(s)",Options=islandOptions,CurrentOption=selectedIsland,Flag="AutoFarmIsland",Callback=function(o)pcall(function()selectedIsland=o end)end}); TeleportTab:CreateButton({Name="Teleport to Selected Island",Callback=function()pcall(function()task.spawn(function()TeleportToIsland(selectedIsland)end)end)end})
    TeleportTab:CreateSection("Sub Menu Teleport Player"); local playerNames={}; for _,p in ipairs(game.Players:GetPlayers())do if p.Name~=game.Players.LocalPlayer.Name then table.insert(playerNames,p.Name)end end; if #playerNames==0 then table.insert(playerNames,"N/A (Sendirian)")end; selectedPlayerName=playerNames[1]; TeleportTab:CreateDropdown({Name="Select Player",Options=playerNames,CurrentOption=selectedPlayerName,Flag="PlayerSelectDropdown",Callback=function(n)pcall(function()selectedPlayerName=n end)end}); TeleportTab:CreateButton({Name="Teleport to Selected Player",Callback=function()pcall(function()task.spawn(function()if selectedPlayerName~="N/A (Sendirian)"then TeleportToPlayer(selectedPlayerName)else Rayfield:Notify({Title="Err",Content="No other players."})end end)end)end})

    -- ====================
    -- TAB 4: EVENT
    -- ====================
    local EventTab=Window:CreateTab("Event",4483362458); EventTab:CreateSection("Sub Menu Event"); local eventOptions={"Megalodon Hunt","Admin Event","Ghost Worm","Worm Hunt","Shark Hunt","Ghost Shark Hunt","Shocked","Blackhole","Meteor Rain"}; selectedEventName="Megalodon Hunt"; EventTab:CreateDropdown({Name="Select Event",Options=eventOptions,CurrentOption=selectedEventName,Flag="SelectEvent",Callback=function(o)pcall(function()selectedEventName=o;if autoTeleportEventActive then ToggleAutoTeleportEvent(false);ToggleAutoTeleportEvent(true)end end)end}); EventTab:CreateToggle({Name="Auto Teleport Spawned Event",CurrentValue=false,Flag="AutoTeleportEvent",Callback=function(s)pcall(function()ToggleAutoTeleportEvent(s)end)end})

    -- ====================
    -- TAB 5: PLAYER CONFIG
    -- ====================
    local PlayerConfigTab=Window:CreateTab("Player Config",4483362458); PlayerConfigTab:CreateSection("Sub Menu Player Config"); PlayerConfigTab:CreateToggle({Name="Floating",Flag="Floating",Callback=function(s)pcall(function()ToggleFloating(s)end)end}); PlayerConfigTab:CreateToggle({Name="Dark/Night Mode",Flag="DarkMode",Callback=function(s)pcall(function()ToggleDarkMode(s)end)end}); PlayerConfigTab:CreateToggle({Name="Anti Lag/Low Texture",Flag="AntiLag",Callback=function(s)pcall(function()ToggleAntiLag(s)end)end}); PlayerConfigTab:CreateToggle({Name="Disable Cutscene Animation",Flag="DisableCutscene",Callback=function(s)pcall(function()ToggleDisableCutscene(s)end)end}); PlayerConfigTab:CreateToggle({Name="Fishing Radar",Flag="FishingRadar",Callback=function(s)pcall(function()ToggleFishingRadar(s)end)end}); PlayerConfigTab:CreateToggle({Name="Lock Player Position",Flag="LockPos",Callback=function(s)pcall(function()ToggleLockPosition(s)end)end})

    -- ====================
    -- TAB 6: SHOP
    -- ====================
    local ShopTab = Window:CreateTab("Shop", 4483362458); local BoatsSection=ShopTab:CreateSection("Buy Boats"); local boats={{name="Small Boat",id=1},{name="Kayak",id=2},{name="Jetski",id=3},{name="Highfield Boat",id=4},{name="Speed Boat",id=5},{name="Fishing Boat",id=6},{name="Mini Yacht",id=7}}; for _,b in ipairs(boats)do ShopTab:CreateButton({Name="Buy "..b.name,Callback=function()pcall(function()task.spawn(function()if RFPurchaseBoat then RFPurchaseBoat:InvokeServer(b.id); Rayfield:Notify({Title="Shop",Content="Purchased "..b.name.."!",Duration=3,Image=4483362458})else Rayfield:Notify({Title="Shop Err",Content="Remote?"})end end)end)end})end; local GearsSection=ShopTab:CreateSection("Buy Gears"); ShopTab:CreateButton({Name="Buy Fishing Radar",Callback=function()pcall(function()task.spawn(function()if RFPurchaseGear then RFPurchaseGear:InvokeServer(81); Rayfield:Notify({Title="Shop",Content="Radar OK",Duration=3,Image=4483362458})else Rayfield:Notify({Title="Shop Err",Content="Remote?"})end end)end)end}); ShopTab:CreateButton({Name="Buy Diving Gear",Callback=function()pcall(function()task.spawn(function()if RFPurchaseGear then RFPurchaseGear:InvokeServer(105); Rayfield:Notify({Title="Shop",Content="Diving OK",Duration=3,Image=4483362458})else Rayfield:Notify({Title="Shop Err",Content="Remote?"})end end)end)end}); local WeatherSection=ShopTab:CreateSection("Buy Weather"); local weathers={"Cloudy","Snow","Storm","Radiant","SharkHunt","Wind"}; for _,w in ipairs(weathers)do ShopTab:CreateButton({Name="Buy "..w,Callback=function()pcall(function()task.spawn(function()if RFPurchaseWeatherEvent then RFPurchaseWeatherEvent:InvokeServer(w); Rayfield:Notify({Title="Shop",Content=w.." OK",Duration=3,Image=4483362458})else Rayfield:Notify({Title="Shop Err",Content="Remote?"})end end)end)end})end; local RodsSection=ShopTab:CreateSection("Buy Fishing Rods"); local rods={{name="Luck Rod",id=79},{name="Carbon Rod",id=76},{name="Grass Rod",id=85},{name="Damascus Rod",id=77},{name="Ice Rod",id=78},{name="Lucky Rod",id=4},{name="Midnight Rod",id=80},{name="Steampunk Rod",id=6},{name="Chrome Rod",id=7}}; for _,r in ipairs(rods)do ShopTab:CreateButton({Name="Buy "..r.name,Callback=function()pcall(function()task.spawn(function()if RFPurchaseFishingRod then RFPurchaseFishingRod:InvokeServer(r.id); Rayfield:Notify({Title="Shop",Content=r.name.." OK",Duration=3,Image=4483362458})else Rayfield:Notify({Title="Shop Err",Content="Remote?"})end end)end)end})end

    -- Final Notification
    local notifySuccess, notifyErr = pcall(function()
        Rayfield:Notify({
            Title = "Mengdut Hub Loaded!",
            Content = "Key system berhasil. UI utama siap digunakan.",
            Duration = 10
        })
    end)
    if not notifySuccess then print("Error in final notify:", notifyErr) end

end -- Akhir dari CreateMainWindow()

-- ====================
-- MANUAL KEY SYSTEM SETUP (DIPERBAIKI)
-- ====================
local isAuthenticated = false
local validKeys = {"password123"} -- Ganti dengan kunci valid Anda

-- Buat Window untuk Key System
local KeyWindow = Rayfield:CreateWindow({
    Name = "Fish It Hub - Key System",
    LoadingTitle = "Mengdut Hub",
    LoadingSubtitle = "by Mengdut - Enter Key...",
    Theme = "Default"
})

if not KeyWindow then
    warn("ERROR FATAL: KeyWindow GAGAL DIBUAT!")
    return
end

-- Buat Tab Key System
local KeyTab = KeyWindow:CreateTab("Enter Key", 4483362458)
KeyTab:CreateSection("Authentication")
local KeyInput = KeyTab:CreateInput({
    Name = "Enter Access Key",
    PlaceholderText = "Masukkan kunci akses",
    RemoveTextAfterFocusLost = false, -- Biarin teks gak hilang
    Callback = function(Text) end -- Callback input gak perlu ngapa2in
})
local SubmitButton = KeyTab:CreateButton({
    Name = "Submit Key",
    Callback = function()
        -- Bungkus pcall biar aman
        local success, err = pcall(function()
            local enteredKey = KeyInput.CurrentValue

            -- Cek key kosong (lebih bersih)
            if not enteredKey or enteredKey:match("^%s*$") then -- Cek spasi doang juga
                Rayfield:Notify({Title="Error", Content="Key kosong!", Duration=5})
                return
            end

            -- Validasi key
            local isValid = false
            for _, key in ipairs(validKeys) do
                if enteredKey == key then
                    isValid = true
                    break
                end
            end

            if isValid then
                isAuthenticated = true
                Rayfield:Notify({ Title = "Success", Content = "Key valid! Akses diberikan.", Duration = 5, Image = 4483362458 })
                
                -- "Tutup" window login (gak bisa destroy, cuma set nil)
                KeyWindow = nil 
                
                -- PANGGIL FUNGSI UNTUK MEMBUAT UI UTAMA
                CreateMainWindow() 

            else
                -- Key invalid
                Rayfield:Notify({ Title = "Error", Content = "Key tidak valid. Coba lagi.", Duration = 5, Image = 4483362458 })
            end
        end)
        if not success then
            warn("Callback error in Submit Key:", err)
            Rayfield:Notify({Title="Callback Error", Content="Ada error di callback. Cek console.", Duration=5})
        end
    end,
})

-- Script berhenti di sini sampai key dimasukkan dan valid, baru CreateMainWindow() dipanggil.
