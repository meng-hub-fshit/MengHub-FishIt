local isFarmingActive = false

     local function RunMasterFarm(Value)
         isFarmingActive = Value
         if Value then
             print("Master Farm Started - with Anti-AFK")
             spawn(function()
                 local lastActivity = tick()
                 while isFarmingActive do
                     -- Fishing sequence (sesuaikan dengan game)
                     local ReplicatedStorage = game:GetService("ReplicatedStorage")
                     local net = ReplicatedStorage.Packages._Index:FindFirstChild("sleitnick_net@0.2.0").net
                     if net then
                         local chargeArgs = {[4] = tick()}
                         net:FindFirstChild("RF/ChargeFishingRod"):InvokeServer(unpack(chargeArgs))
                         
                         local requestArgs = {[1] = math.random(-1, 1), [2] = math.random(0, 1), [3] = tick()}
                         net:FindFirstChild("RF/RequestFishingMinigameStarted"):InvokeServer(unpack(requestArgs))
                         
                         wait(1.5)  -- Atau gunakan delay dari UI jika perlu
                         
                         net:FindFirstChild("RE/FishingCompleted"):FireServer()
                         
                         -- Anti-AFK
                         if tick() - lastActivity > 1140 then
                             local VirtualInputManager = game:GetService("VirtualInputManager")
                             VirtualInputManager:SendMouseMoveEvent(500, 500, game)
                             lastActivity = tick()
                         end
                         
                         wait(0.5)
                     else
                         warn("Net not found!")
                         isFarmingActive = false
                     end
                 end
             end)
         else
             print("Master Farm Stopped")
         end
     end
return {
