local Button =
    Tab:Button(
    {
        Title = T("最强战场"),
        Desc = T("加载最强战场菜单"),
        Locked = false,
        Callback = function()
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
            local StarterGui = game:GetService("StarterGui")
            local RunService = game:GetService("RunService")
            local TweenService = game:GetService("TweenService")
            local UserInputService = game:GetService("UserInputService")
            local VirtualInputManager = game:GetService("VirtualInputManager")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local Camera = game:GetService('Workspace').CurrentCamera

            local RunService = game:GetService("RunService")
            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer
            local Humanoid
            local HumanoidRootPart

            local function SafeDebugPrint(message)
                print("[DEBUG] " .. message)
            end

            local function InitializeHumanoid()
                local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                if character then
                    Humanoid = character:FindFirstChild("Humanoid")
                    if Humanoid then
                        HumanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                        if not HumanoidRootPart then
                            SafeDebugPrint("HumanoidRootPart not found for " .. LocalPlayer.Name)
                        else
                            SafeDebugPrint("HumanoidRootPart initialized for " .. LocalPlayer.Name)
                        end
                    else
                        SafeDebugPrint("Humanoid not found for " .. LocalPlayer.Name)
                    end
                end
            end

            if LocalPlayer.Character then
                InitializeHumanoid()
            end

            LocalPlayer.CharacterAdded:Connect(InitializeHumanoid)

            local kenConfiguration = {
                Main = {
                    Combat = {
                        AttackAura = false,
                        AutoParry = false
                    },
                    Farm = {
                        KillFarm = false,
                        AutoUltimate = true
                    }
                },
                Player = {
                    Character = {
                        OverwriteProperties = false,
                        WalkSpeed = 50,
                        JumpPower = 50
                    }
                }
            }

            local Functions = {}

            function Functions.BestTarget(MaxDistance)
                MaxDistance = MaxDistance or math.huge
                local Target = nil
                local MinKills = math.huge

                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
                        local rootPart = v.Character:FindFirstChild("HumanoidRootPart")
                        if rootPart then
                            local distance = (LocalPlayer.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
                            local kills = v:GetAttribute("Kills") or 0

                            if distance < MaxDistance and kills < MinKills then
                                Target = v
                                MaxDistance = distance
                                MinKills = kills
                            end
                        end
                    end
                end

                SafeDebugPrint("Best target found: " .. (Target and Target.Name or "None"))
                return Target
            end

            function Functions.UseAbility(Ability)
                if not LocalPlayer.Character then
                    return
                end
                local Tool = LocalPlayer.Backpack:FindFirstChild(Ability)
                if Tool then
                    SafeDebugPrint("Using ability: " .. Ability)
                    LocalPlayer.Character.Communicate:FireServer(
                        {
                            Tool = Tool,
                            Goal = "Console Move",
                            ToolName = tostring(Ability)
                        }
                    )
                else
                    SafeDebugPrint("Ability not found: " .. Ability)
                end
            end

            function Functions.RandomAbility()
                if not LocalPlayer.PlayerGui:FindFirstChild("Hotbar") then
                    return nil
                end
                local Hotbar = LocalPlayer.PlayerGui.Hotbar.Backpack.Hotbar
                local Abilities = {}

                for _, v in pairs(Hotbar:GetChildren()) do
                    if v.ClassName ~= "UIListLayout" and v.Visible and v.Base.ToolName.Text ~= "N/A" and not v.Base:FindFirstChild("Cooldown") then
                        table.insert(Abilities, v)
                    end
                end

                if #Abilities > 0 then
                    local RandomAbility = Abilities[math.random(1, #Abilities)]
                    return RandomAbility.Base.ToolName.Text
                else
                    SafeDebugPrint("No available abilities")
                    return nil
                end
            end

            function Functions.ActivateUltimate()
                local UltimateBar = LocalPlayer:GetAttribute("Ultimate") or 0
                if UltimateBar >= 100 then
                    LocalPlayer.Character.Communicate:FireServer(
                        {
                            MoveDirection = Vector3.new(0, 0, 0),
                            Key = Enum.KeyCode.G,
                            Goal = "KeyPress"
                        }
                    )
                    SafeDebugPrint("Ultimate activated")
                else
                    SafeDebugPrint("Ultimate not ready: " .. UltimateBar .. "%")
                end
            end

            function Functions.TeleportUnderPlayer(player)
                if not player.Character then
                    return
                end
                local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local targetCFrame = rootPart.CFrame * CFrame.new(0, -5, 0)
                    LocalPlayer.Character:SetPrimaryPartCFrame(targetCFrame)
                    SafeDebugPrint("Teleported under player: " .. player.Name)
                else
                    SafeDebugPrint("Failed to teleport under player: " .. player.Name)
                end
            end

            local Tab =
                Window:Tab(
                {
                    Title = T("最强战场"),
                    Icon = "bird",
                    Locked = false
                }
            )

            local Dropdown =
                Tab:Dropdown(
                {
                    Title = T("传送位置"),
                    Values = {T("地图"), T("山脉"), T("安全港"), T("秘密房间1"), T("秘密房间2")},
                    Value = T("地图"),
                    Callback = function(option)
                        if option == T("地图") then
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(63.4928513, 440.505829, -92.9229507)
                        elseif option == T("山脉") then
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(253.515198, 699.103455, 420.533813)
                        elseif option == T("安全港") then
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-774.454834, -137.237228, 126.384216)
                        elseif option == T("秘密房间1") then
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-62, 29, 20338)
                        elseif option == T("秘密房间2") then
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(1068, 133, 23015)
                        end
                    end
                }
            )

            local TPYW
            local Button =
                Tab:Button(
                {
                    Title = T("设置原位"),
                    Desc = T("设置原本的位置"),
                    Locked = false,
                    Callback = function()
                        TPYW = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
                    end
                }
            )

            local Button =
                Tab:Button(
                {
                    Title = T("传送原位"),
                    Desc = T("传送到原位"),
                    Locked = false,
                    Callback = function()
                        if TPYW then
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = TPYW
                        end
                    end
                }
            )

            local trashMasterToggle =
                Tab:Toggle(
                {
                    Title = T("不朝向好友"),
                    Desc = T("自动朝向不朝向好友"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        BCXZJHYT = state
                    end
                }
            )

            local AUTO_TRASH_MASTER = false
            local Toggle =
                Tab:Toggle(
                {
                    Title = T("自动垃圾桶"),
                    Desc = T("拾取+传送最近玩家身后+攻击"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        AUTO_TRASH_MASTER = state

                        if state then
                            task.spawn(
                                function()
                                    local Players = game:GetService("Players")
                                    local Workspace = game:GetService("Workspace")
                                    local RunService = game:GetService("RunService")
                                    local TRASH_RANGE = 15
                                    local PLAYER_RANGE = 100
                                    local PICKUP_DISTANCE = 2
                                    local ATTACK_DISTANCE = 2
                                    local HEIGHT_OFFSET = 3
                                    local localPlayer = Players.LocalPlayer
                                    local character, rootPart, humanoid

                                    local function updateCharacter()
                                        character = localPlayer.Character
                                        if character then
                                            rootPart = character:FindFirstChild("HumanoidRootPart")
                                            humanoid = character:FindFirstChildOfClass("Humanoid")
                                        else
                                            rootPart = nil
                                            humanoid = nil
                                        end
                                    end

                                    updateCharacter()
                                    localPlayer.CharacterAdded:Connect(updateCharacter)

                                    local function getTrashPart(trashModel)
                                        return trashModel:FindFirstChild("Handle") or trashModel:FindFirstChild("MainPart") or trashModel:FindFirstChild("TrashCan") or trashModel.PrimaryPart or trashModel:FindFirstChildWhichIsA("BasePart")
                                    end

                                    local function performAction(action)
                                        if AUTO_TRASH_MASTER and character then
                                            local communicate = character:FindFirstChild("Communicate")
                                            if communicate then
                                                communicate:FireServer({["Goal"] = action})
                                            end
                                        end
                                    end

                                    local function calculateOffsetPosition(targetPos, referencePos)
                                        local direction = (targetPos - referencePos).Unit
                                        direction = Vector3.new(direction.X, 0, direction.Z).Unit

                                        if direction.Magnitude < 0.1 then
                                            direction = Vector3.new(math.random(), 0, math.random()).Unit
                                        end

                                        return targetPos + (direction * PICKUP_DISTANCE)
                                    end

                                    local function calculateBehindPosition(targetRoot)
                                        local lookVector = targetRoot.CFrame.LookVector
                                        lookVector = Vector3.new(lookVector.X, 0, lookVector.Z).Unit

                                        return targetRoot.Position - (lookVector * ATTACK_DISTANCE)
                                    end

                                    local function findNearestPlayer()
                                        if not rootPart then
                                            return nil, nil
                                        end

                                        local nearestPlayer = nil
                                        local nearestDistance = math.huge
                                        local targetPosition = nil

                                        for _, targetPlayer in ipairs(Players:GetPlayers()) do
                                            if targetPlayer ~= localPlayer and targetPlayer.Character then
                                                local targetChar = targetPlayer.Character
                                                local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
                                                local targetHum = targetChar:FindFirstChildOfClass("Humanoid")

                                                if targetRoot and targetHum and targetHum.Health > 0 then
                                                    local distance = (rootPart.Position - targetRoot.Position).Magnitude
                                                    if distance <= PLAYER_RANGE and distance < nearestDistance then
                                                        nearestDistance = distance
                                                        nearestPlayer = targetPlayer
                                                        targetPosition = calculateBehindPosition(targetRoot)
                                                    end
                                                end
                                            end
                                        end

                                        return nearestPlayer, targetPosition
                                    end

                                    local function teleportTo(position, faceTarget)
                                        if rootPart and AUTO_TRASH_MASTER then
                                            local raycastParams = RaycastParams.new()
                                            raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                                            raycastParams.FilterDescendantsInstances = {character}

                                            local groundPosition = position
                                            local ray = Workspace:Raycast(position + Vector3.new(0, 10, 0), Vector3.new(0, -20, 0), raycastParams)
                                            if ray and ray.Position then
                                                groundPosition = ray.Position + Vector3.new(0, HEIGHT_OFFSET, 0)
                                            else
                                                groundPosition = position + Vector3.new(0, HEIGHT_OFFSET, 0)
                                            end

                                            if faceTarget then
                                                local lookVector = (faceTarget - groundPosition).Unit
                                                rootPart.CFrame = CFrame.new(groundPosition, groundPosition + lookVector)
                                            else
                                                rootPart.CFrame = CFrame.new(groundPosition)
                                            end
                                        end
                                    end

                                    while AUTO_TRASH_MASTER and game:GetService("RunService").Heartbeat:Wait() do
                                        pcall(
                                            function()
                                                updateCharacter()
                                                if not character or not rootPart or not humanoid or humanoid.Health <= 0 then
                                                    task.wait(1)
                                                    return
                                                end

                                                if not character:GetAttribute("HasTrashcan") then
                                                    local trashFolder = Workspace:FindFirstChild("Trash") or (Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Trash"))

                                                    if not trashFolder then
                                                        task.wait(1)
                                                        return
                                                    end

                                                    local nearestTrash, nearestDistance, trashPosition
                                                    for _, trashModel in ipairs(trashFolder:GetChildren()) do
                                                        if trashModel:IsA("Model") then
                                                            local trashPart = getTrashPart(trashModel)
                                                            if trashPart then
                                                                local distance = (rootPart.Position - trashPart.Position).Magnitude
                                                                if distance <= TRASH_RANGE and (not nearestDistance or distance < nearestDistance) then
                                                                    nearestTrash = trashModel
                                                                    nearestDistance = distance
                                                                    trashPosition = trashPart.Position
                                                                end
                                                            end
                                                        end
                                                    end

                                                    if nearestTrash and trashPosition then
                                                        local offsetPosition = calculateOffsetPosition(trashPosition, rootPart.Position)

                                                        teleportTo(offsetPosition, trashPosition)
                                                        task.wait(0.2)

                                                        local direction = (trashPosition - rootPart.Position).Unit
                                                        local lookVector = Vector3.new(direction.X, 0, direction.Z).Unit
                                                        if lookVector.Magnitude > 0.1 then
                                                            rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
                                                        end

                                                        performAction("LeftClick")
                                                        task.wait(0.15)
                                                        performAction("LeftClickRelease")

                                                        local waitTime = 0
                                                        while waitTime < 2 and AUTO_TRASH_MASTER do
                                                            if character:GetAttribute("HasTrashcan") then
                                                                SafeDebugPrint("成功拾取垃圾桶")
                                                                break
                                                            end
                                                            task.wait(0.1)
                                                            waitTime = waitTime + 0.1
                                                        end
                                                    else
                                                        task.wait(1)
                                                    end
                                                else
                                                    local nearestPlayer, behindPos = findNearestPlayer()

                                                    if nearestPlayer and behindPos then
                                                        local targetChar = nearestPlayer.Character
                                                        local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")

                                                        if not targetRoot then
                                                            task.wait(0.5)
                                                            return
                                                        end

                                                        teleportTo(behindPos, targetRoot.Position)
                                                        task.wait(0.2)

                                                        local direction = (targetRoot.Position - rootPart.Position).Unit
                                                        local lookVector = Vector3.new(direction.X, 0, direction.Z).Unit
                                                        if lookVector.Magnitude > 0.1 then
                                                            rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + lookVector)
                                                        end

                                                        performAction("LeftClick")
                                                        task.wait(0.1)
                                                        performAction("LeftClickRelease")

                                                        SafeDebugPrint("攻击玩家: " .. nearestPlayer.Name)

                                                        task.wait(1.5)
                                                    else
                                                        SafeDebugPrint("未找到可攻击玩家")
                                                        task.wait(1)
                                                    end
                                                end
                                            end
                                        )
                                    end
                                end
                            )
                        end
                    end
                }
            )

            local attackAuraConnection
            local Toggle =
                Tab:Toggle(
                {
                    Title = T("攻击光环"),
                    Desc = T("其他玩家靠近自动攻击"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        kenConfiguration.Main.Combat.AttackAura = state
                        SafeDebugPrint("攻击光环: " .. tostring(state))

                        if attackAuraConnection then
                            attackAuraConnection:Disconnect()
                            attackAuraConnection = nil
                        end

                        if state then
                            attackAuraConnection =
                                RunService.RenderStepped:Connect(
                                function()
                                    if not kenConfiguration.Main.Combat.AttackAura then
                                        return
                                    end
                                    if not HumanoidRootPart or not LocalPlayer.Character then
                                        return
                                    end

                                    local NearestTarget = Functions.BestTarget(5)
                                    if NearestTarget then
                                        Functions.TeleportUnderPlayer(NearestTarget)
                                        local RandomAbility = Functions.RandomAbility()
                                        if RandomAbility then
                                            Functions.UseAbility(RandomAbility)
                                        else
                                            if kenConfiguration.Main.Farm.AutoUltimate then
                                                Functions.ActivateUltimate()
                                            end
                                        end
                                    end
                                end
                            )
                        end
                    end
                }
            )

            local killFarmConnection
            local Toggle =
                Tab:Toggle(
                {
                    Title = T("自动战斗"),
                    Desc = T("角色自动战斗"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        kenConfiguration.Main.Farm.KillFarm = state
                        SafeDebugPrint("杀戮光环: " .. tostring(state))

                        if killFarmConnection then
                            killFarmConnection:Disconnect()
                            killFarmConnection = nil
                        end

                        if state then
                            killFarmConnection =
                                RunService.RenderStepped:Connect(
                                function()
                                    if not kenConfiguration.Main.Farm.KillFarm then
                                        return
                                    end
                                    if not HumanoidRootPart or not LocalPlayer.Character then
                                        return
                                    end

                                    local BestTarget = Functions.BestTarget()
                                    if BestTarget then
                                        Functions.TeleportUnderPlayer(BestTarget)
                                        local RandomAbility = Functions.RandomAbility()
                                        if RandomAbility then
                                            Functions.UseAbility(RandomAbility)
                                        else
                                            if kenConfiguration.Main.Farm.AutoUltimate then
                                                Functions.ActivateUltimate()
                                            end
                                        end
                                    end
                                end
                            )
                        end
                    end
                }
            )

            local ZDGJT = false
            local Toggle =
                Tab:Toggle(
                {
                    Title = T("自动攻击"),
                    Desc = T("角色自动攻击"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        ZDGJT = state
                        if state then
                            task.spawn(
                                function()
                                    while ZDGJT and task.wait(0.3) do
                                        if Character then
                                            local communicate = Character:FindFirstChild("Communicate")
                                            if communicate then
                                                communicate:FireServer({["Goal"] = "LeftClick"})
                                                task.wait(0.05)
                                                communicate:FireServer({["Goal"] = "LeftClickRelease"})
                                            end
                                        end
                                    end
                                end
                            )
                        end
                    end
                }
            )

            local Toggle =
                Tab:Toggle(
                {
                    Title = T("自动开大"),
                    Desc = T("角色自动使用终极"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        kenConfiguration.Main.Farm.AutoUltimate = state
                        SafeDebugPrint("自动终极技能: " .. tostring(state))
                    end
                }
            )

            local ELZRCSXKT = false
            local Toggle =
                Tab:Toggle(
                {
                    Title = T("抓人传虚空"),
                    Desc = T("使用英雄猎人角色2技能抓人传送虚空"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        ELZRCSXKT = state

                        local Players = game:GetService("Players")
                        local ReplicatedStorage = game:GetService("ReplicatedStorage")
                        local UserInputService = game:GetService("UserInputService")
                        local LocalPlayer = Players.LocalPlayer
                        local Backpack = LocalPlayer:WaitForChild("Backpack")
                        local targetToolName = "Lethal Whirlwind Stream"
                        if state then
                            Backpack.ChildAdded:Connect(
                                function(tool)
                                    if ELZRCSXKT and tool:IsA("Tool") and tool.Name == targetToolName then
                                        tool.Equipped:Connect(
                                            function()
                                                local A = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
                                                task.wait(1)
                                                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-62, 29, 20338)
                                                task.wait(3)
                                                game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = A
                                            end
                                        )
                                    end
                                end
                            )
                        end
                    end
                }
            )

            local ZDNLJTT = false
            local Toggle =
                Tab:Toggle(
                {
                    Title = T("自动垃圾桶"),
                    Desc = T("角色自动面向并拿垃圾桶"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        ZDNLJTT = state
                        if state then
                            task.spawn(
                                function()
                                    local Players = game:GetService("Players")
                                    local Workspace = game:GetService("Workspace")
                                    local TRASH_RANGE = 5

                                    while ZDNLJTT and task.wait(0.1) do
                                        pcall(
                                            function()
                                                local localPlayer = Players.LocalPlayer
                                                local character = localPlayer.Character

                                                if character then
                                                    local humanoid = character:FindFirstChild("Humanoid")
                                                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                                                    local trashFolder = Workspace:FindFirstChild("Trash") or (Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Trash"))

                                                    if trashFolder and rootPart then
                                                        local nearestTrash = nil
                                                        local nearestDistance = math.huge

                                                        for _, trashModel in pairs(trashFolder:GetChildren()) do
                                                            if trashModel:IsA("Model") then
                                                                local trashPosition = trashModel:GetPivot().Position
                                                                local distance = (rootPart.Position - trashPosition).Magnitude

                                                                if distance <= TRASH_RANGE and distance < nearestDistance then
                                                                    nearestDistance = distance
                                                                    nearestTrash = trashModel
                                                                end
                                                            end
                                                        end

                                                        if nearestTrash then
                                                            local trashPosition = nearestTrash:GetPivot().Position
                                                            local direction = (trashPosition - rootPart.Position).Unit

                                                            local lookVector = Vector3.new(direction.X, 0, direction.Z).Unit
                                                            rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + lookVector)

                                                            local communicate = character:FindFirstChild("Communicate")
                                                            if communicate and character:GetAttribute("HasTrashcan") == false then
                                                                communicate:FireServer({["Goal"] = "LeftClick"})
                                                                task.wait(0.05)
                                                                communicate:FireServer({["Goal"] = "LeftClickRelease"})
                                                            end
                                                        end
                                                    end
                                                end
                                            end
                                        )
                                    end
                                end
                            )
                        end
                    end
                }
            )

            local awdawdwaT = false
            local Toggle =
                Tab:Toggle(
                {
                    Title = T("取消冲刺后摇"),
                    Desc = T("m1reset+emotedash 自己把握好距离(手机勿用)"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        awdawdwaT = state

                        local plr = game:GetService("Players").LocalPlayer
                        local uis = game:GetService("UserInputService")
                        local isMobile = uis.TouchEnabled

                        getgenv()._TempestAlreadyRan = true

                        local frontDashArgs = {
                            [1] = {
                                Dash = Enum.KeyCode.W,
                                Key = Enum.KeyCode.Q,
                                Goal = "KeyPress"
                            }
                        }

                        local function frontDash()
                            if plr.Character then
                                local communicate = plr.Character:FindFirstChild("Communicate")
                                if communicate then
                                    communicate:FireServer(unpack(frontDashArgs))
                                end
                            end
                        end

                        local function stopAnimation(char, animationId)
                            local humanoid = char:FindFirstChildWhichIsA("Humanoid")
                            if humanoid then
                                local animator = humanoid:FindFirstChildWhichIsA("Animator")
                                if animator then
                                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                        if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. tostring(animationId) then
                                            track:Stop()
                                        end
                                    end
                                end
                            end
                        end

                        local function isAnimationRunning(char, animationId)
                            local humanoid = char:FindFirstChildWhichIsA("Humanoid")
                            if humanoid then
                                local animator = humanoid:FindFirstChildWhichIsA("Animator")
                                if animator then
                                    for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                                        if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. tostring(animationId) then
                                            return true
                                        end
                                    end
                                end
                            end
                            return false
                        end

                        local function getMovementAngle(hrp, moveDirection)
                            if moveDirection.Magnitude == 0 then
                                return 0
                            end

                            local relativeMoveDir = hrp.CFrame:VectorToObjectSpace(moveDirection)
                            local angle = math.deg(math.atan2(relativeMoveDir.Z, relativeMoveDir.X))

                            return (angle + 360) % 360
                        end

                        local inputBeganConnections = {}
                        local characterAddedConnections = {}
                        local dashButtonConnections = {}

                        local function setupNoEndlagDash()
                            if not plr.Character then
                                return
                            end

                            local connection =
                                uis.InputBegan:Connect(
                                function(input, t)
                                    if t then
                                        return
                                    end

                                    if awdawdwaT and input.KeyCode == Enum.KeyCode.Q and not uis:IsKeyDown(Enum.KeyCode.D) and not uis:IsKeyDown(Enum.KeyCode.A) and not uis:IsKeyDown(Enum.KeyCode.S) and plr.Character:FindFirstChild("UsedDash") then
                                        frontDash()
                                    end
                                end
                            )

                            table.insert(inputBeganConnections, connection)

                            local destroyConn =
                                plr.Character.Destroying:Connect(
                                function()
                                    for i, conn in ipairs(inputBeganConnections) do
                                        if conn == connection then
                                            conn:Disconnect()
                                            table.remove(inputBeganConnections, i)
                                            break
                                        end
                                    end
                                    destroyConn:Disconnect()
                                end
                            )
                        end

                        local function setupEmoteDash()
                            if not plr.Character then
                                return
                            end

                            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                            if not hrp then
                                return
                            end

                            local connection =
                                uis.InputBegan:Connect(
                                function(input, t)
                                    if t then
                                        return
                                    end

                                    if awdawdwaT and input.KeyCode == Enum.KeyCode.Q and not uis:IsKeyDown(Enum.KeyCode.W) and not uis:IsKeyDown(Enum.KeyCode.S) and not isAnimationRunning(plr.Character, 10491993682) then
                                        local vel = hrp:FindFirstChild("dodgevelocity")
                                        if vel then
                                            vel:Destroy()
                                            stopAnimation(plr.Character, 10480793962)
                                            stopAnimation(plr.Character, 10480796021)
                                        end
                                    end
                                end
                            )

                            table.insert(inputBeganConnections, connection)

                            local destroyConn =
                                plr.Character.Destroying:Connect(
                                function()
                                    for i, conn in ipairs(inputBeganConnections) do
                                        if conn == connection then
                                            conn:Disconnect()
                                            table.remove(inputBeganConnections, i)
                                            break
                                        end
                                    end
                                    destroyConn:Disconnect()
                                end
                            )
                        end

                        local function setupMobileDash()
                            if not isMobile or not plr.Character then
                                return
                            end

                            local dashButton
                            local playerGui = plr:FindFirstChild("PlayerGui")
                            if playerGui then
                                local touchGui = playerGui:FindFirstChild("TouchGui")
                                if touchGui then
                                    local controlFrame = touchGui:FindFirstChild("TouchControlFrame")
                                    if controlFrame then
                                        local jumpButton = controlFrame:FindFirstChild("JumpButton")
                                        if jumpButton then
                                            dashButton = jumpButton:FindFirstChild("DashButton")
                                        end
                                    end
                                end
                            end

                            if dashButton then
                                local connection =
                                    dashButton.MouseButton1Down:Connect(
                                    function()
                                        if not awdawdwaT or not plr.Character then
                                            return
                                        end

                                        local hum = plr.Character:FindFirstChild("Humanoid")
                                        local hrp = plr.Character:FindFirstChild("HumanoidRootPart")

                                        if not hum or not hrp then
                                            return
                                        end

                                        local angle = getMovementAngle(hrp, hum.MoveDirection)
                                        local directionResult = nil

                                        if angle == 0 then
                                            directionResult = "front"
                                        elseif angle >= 315 or angle < 45 then
                                            directionResult = "right"
                                        elseif angle >= 135 and angle < 225 then
                                            directionResult = "left"
                                        elseif angle >= 45 and angle < 135 then
                                            directionResult = "back"
                                        elseif angle >= 225 and angle < 315 then
                                            directionResult = "front"
                                        end

                                        if awdawdwaT and directionResult == "front" and not plr.Character:FindFirstChild("Freeze") and not plr.Character:FindFirstChild("Slowed") and not plr.Character:FindFirstChild("WallCombo") then
                                            frontDash()
                                        end

                                        if awdawdwaT and (directionResult == "left" or directionResult == "right") and not isAnimationRunning(plr.Character, 10491993682) then
                                            local vel = hrp:FindFirstChild("dodgevelocity")

                                            if vel then
                                                vel:Destroy()
                                                stopAnimation(plr.Character, 10480793962)
                                                stopAnimation(plr.Character, 10480796021)
                                            end
                                        end
                                    end
                                )

                                table.insert(dashButtonConnections, connection)

                                local destroyConn =
                                    plr.Character.Destroying:Connect(
                                    function()
                                        for i, conn in ipairs(dashButtonConnections) do
                                            if conn == connection then
                                                conn:Disconnect()
                                                table.remove(dashButtonConnections, i)
                                                break
                                            end
                                        end
                                        destroyConn:Disconnect()
                                    end
                                )
                            end
                        end

                        local function cleanupConnections()
                            for _, conn in ipairs(inputBeganConnections) do
                                conn:Disconnect()
                            end
                            for _, conn in ipairs(characterAddedConnections) do
                                conn:Disconnect()
                            end
                            for _, conn in ipairs(dashButtonConnections) do
                                conn:Disconnect()
                            end

                            inputBeganConnections = {}
                            characterAddedConnections = {}
                            dashButtonConnections = {}
                        end

                        if state then
                            if plr.Character then
                                setupNoEndlagDash()
                                setupEmoteDash()

                                if isMobile then
                                    setupMobileDash()
                                end
                            end

                            local charAddedConn1 = plr.CharacterAdded:Connect(setupNoEndlagDash)
                            local charAddedConn2 = plr.CharacterAdded:Connect(setupEmoteDash)

                            table.insert(characterAddedConnections, charAddedConn1)
                            table.insert(characterAddedConnections, charAddedConn2)

                            if isMobile then
                                local dashButtonConn =
                                    plr.PlayerGui.DescendantAdded:Connect(
                                    function(d)
                                        if d.Name == "DashButton" and plr.Character then
                                            setupMobileDash()
                                        end
                                    end
                                )

                                table.insert(characterAddedConnections, dashButtonConn)
                            end
                        else
                            cleanupConnections()
                        end
                    end
                }
            )

            local ZDFYT = false
            local Settings = {
                Autoparry = {
                    Toggle = ZDFYT,
                    Range = 25,
                    Delay = 0,
                    Fov = 180,
                    Facing = false,
                    Dodgerange = 3,
                    Aimhelper = false
                }
            }

            local anims = {
                ["rbxassetid://10469493270"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://10469630950"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://10469639222"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://10469643643"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13532562418"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13532600125"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13532604085"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13294471966"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13491635433"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13296577783"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13295919399"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13295936866"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13370310513"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13390230973"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13378751717"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13378708199"] = {[1] = 0, [2] = 0.30},
                ["rbxassetid://13500000000"] = {[1] = 0, [2] = 0.35},
                ["rbxassetid://13500000001"] = {[1] = 0.1, [2] = 0.4},
                ["rbxassetid://13500000002"] = {[1] = 0.05, [2] = 0.35},
                abilities = {}
            }

            local dodges = {
                ["rbxassetid://10479335397"] = {[1] = 0, [2] = 0.50},
                ["rbxassetid://13380255751"] = {[1] = 0, [2] = 0.50},
                ["rbxassetid://13500000003"] = {[1] = 0, [2] = 0.55},
                ["rbxassetid://13500000004"] = {[1] = 0.1, [2] = 0.6}
            }

            local barrages = {
                ["rbxassetid://10466974800"] = {[1] = 0.20, [2] = 1.80},
                ["rbxassetid://12534735382"] = {[1] = 0.20, [2] = 1.80},
                ["rbxassetid://13500000005"] = {[1] = 0.15, [2] = 1.75},
                ["rbxassetid://13500000006"] = {[1] = 0.25, [2] = 1.85}
            }

            local abilities = {
                ["rbxassetid://10468665991"] = {[1] = 0.15, [2] = 0.60},
                ["rbxassetid://13376869471"] = {[1] = 0.05, [2] = 1},
                ["rbxassetid://13376962659"] = {[1] = 0, [2] = 2},
                ["rbxassetid://12296882427"] = {[1] = 0.05, [2] = 1},
                ["rbxassetid://13309500827"] = {[1] = 0.05, [2] = 1},
                ["rbxassetid://13365849295"] = {[1] = 0, [2] = 1},
                ["rbxassetid://13377153603"] = {[1] = 0, [2] = 1},
                ["rbxassetid://12509505723"] = {[1] = 0.09, [2] = 2},
                ["rbxassetid://13500000007"] = {[1] = 0.1, [2] = 0.65},
                ["rbxassetid://13500000008"] = {[1] = 0.05, [2] = 1.1}
            }

            local closestplr, anim, plrDirection, unit, value, dodge
            local cd = false
            local parryCooldown = 0.2

            local Players = game:GetService("Players")
            local LocalPlayer = Players.LocalPlayer

            local function GetCharacterParts(char)
                if not char then
                    return nil, nil, nil
                end
                local root = char:FindFirstChild("HumanoidRootPart")
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local head = char:FindFirstChild("Head")
                return root, humanoid, head
            end

            function closest()
                local closestPlayers = {}
                local localChar = LocalPlayer.Character
                local localRoot, localHumanoid = GetCharacterParts(localChar)

                if not localRoot or not localHumanoid or localHumanoid.Health <= 0 then
                    return closestPlayers
                end

                local myPosition = localRoot.Position

                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        local char = player.Character
                        local theirRoot, theirHumanoid = GetCharacterParts(char)

                        if theirRoot and theirHumanoid and theirHumanoid.Health > 0 then
                            local distance = (myPosition - theirRoot.Position).Magnitude
                            if distance < Settings.Autoparry.Range then
                                table.insert(closestPlayers, player)
                            end
                        end
                    end
                end

                table.sort(
                    closestPlayers,
                    function(a, b)
                        local aRoot = GetCharacterParts(a.Character)
                        local bRoot = GetCharacterParts(b.Character)
                        if not aRoot or not bRoot then
                            return false
                        end
                        return (myPosition - aRoot.Position).Magnitude < (myPosition - bRoot.Position).Magnitude
                    end
                )

                return closestPlayers
            end

            function attackchecker()
                local char = LocalPlayer.Character
                if not char then
                    return false
                end

                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if not humanoid or humanoid.Health <= 0 then
                    return false
                end

                local animator = humanoid:FindFirstChild("Animator")
                if not animator then
                    return false
                end

                for _, animTrack in ipairs(animator:GetPlayingAnimationTracks()) do
                    local animId = animTrack.Animation and animTrack.Animation.AnimationId
                    if animId then
                        if anims[animId] or dodges[animId] or abilities[animId] or barrages[animId] then
                            return true
                        end
                    end
                end

                return false
            end

            function isfacing(enemyChar)
                if not Settings.Autoparry.Toggle then
                    return false
                end
                if not Settings.Autoparry.Facing then
                    return true
                end

                local localChar = LocalPlayer.Character
                local enemyHead = enemyChar and enemyChar:FindFirstChild("Head")
                local localHead = localChar and localChar:FindFirstChild("Head")

                if not localHead or not enemyHead then
                    return false
                end

                plrDirection = localHead.CFrame.LookVector
                unit = (enemyHead.CFrame.p - localHead.CFrame.p).Unit
                value = math.pow((plrDirection - unit).Magnitude / 2, 2)

                return value < (Settings.Autoparry.Fov / 360)
            end

            function allowed(enemyChar)
                if not enemyChar then
                    return false
                end

                local localChar = LocalPlayer.Character
                if not localChar then
                    return false
                end

                if localChar:FindFirstChild("M1ing") then
                    return false
                end
                if attackchecker() then
                    return false
                end

                return isfacing(enemyChar)
            end

            local durations = {
                ["anim"] = 0.3,
                ["dodge"] = 0.9,
                ["barrage"] = 0.9,
                ["ability"] = 0.6
            }

            function def(action)
                if cd then
                    return
                end
                task.wait(Settings.Autoparry.Delay)

                cd = true
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Communicate") then
                    char.Communicate:FireServer({["Goal"] = "KeyPress", ["Key"] = Enum.KeyCode.F})
                end

                task.wait(durations[action])

                if char and char:FindFirstChild("Communicate") then
                    char.Communicate:FireServer({["Goal"] = "KeyRelease", ["Key"] = Enum.KeyCode.F})
                end

                cd = false
            end

            function lookat(enemyChar)
                if not Settings.Autoparry.Aimhelper then
                    return
                end

                local localChar = LocalPlayer.Character
                if not localChar then
                    return
                end

                local localRoot = localChar:FindFirstChild("HumanoidRootPart")
                local enemyRoot = enemyChar and enemyChar:FindFirstChild("HumanoidRootPart")

                if localRoot and enemyRoot then
                    localRoot.CFrame = CFrame.lookAt(localRoot.Position, enemyRoot.Position)
                end
            end

            function parry()
                local closestPlayers = closest()

                for _, player in ipairs(closestPlayers) do
                    if not Settings.Autoparry.Toggle then
                        break
                    end

                    local enemyChar = player.Character
                    if not enemyChar then
                        continue
                    end

                    local enemyRoot, enemyHumanoid = GetCharacterParts(enemyChar)
                    if not enemyRoot or not enemyHumanoid or enemyHumanoid.Health <= 0 then
                        continue
                    end

                    local animator = enemyHumanoid:FindFirstChild("Animator")
                    if not animator then
                        continue
                    end

                    if not allowed(enemyChar) then
                        continue
                    end

                    for _, animTrack in ipairs(animator:GetPlayingAnimationTracks()) do
                        if not Settings.Autoparry.Toggle then
                            break
                        end

                        local animId = animTrack.Animation and animTrack.Animation.AnimationId
                        local animData = anims[animId]
                        local dodgeData = dodges[animId]
                        local abilityData = abilities[animId]
                        local barrageData = barrages[animId]

                        local timePos = animTrack.TimePosition

                        if animData and timePos >= animData[1] and timePos <= animData[2] then
                            task.spawn(
                                function()
                                    def("anim")
                                    lookat(enemyChar)
                                end
                            )
                            task.wait(parryCooldown)
                            break
                        elseif dodgeData and timePos >= dodgeData[1] and timePos <= dodgeData[2] then
                            task.spawn(
                                function()
                                    def("dodge")
                                    lookat(enemyChar)
                                end
                            )
                            task.wait(parryCooldown)
                            break
                        elseif barrageData and timePos >= barrageData[1] and timePos <= barrageData[2] then
                            task.spawn(
                                function()
                                    def("barrage")
                                    lookat(enemyChar)
                                end
                            )
                            task.wait(parryCooldown)
                            break
                        elseif abilityData and timePos >= abilityData[1] and timePos <= abilityData[2] then
                            task.spawn(
                                function()
                                    def("ability")
                                    lookat(enemyChar)
                                end
                            )
                            task.wait(parryCooldown)
                            break
                        end

                    end
                end
            end

            local Toggle =
                Tab:Toggle(
                {
                    Title = T("自动防御"),
                    Desc = T("角色自动防御(增强版)"),
                    Icon = "shield",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        Settings.Autoparry.Toggle = state
                        if state then
                            task.spawn(
                                function()
                                    while Settings.Autoparry.Toggle do
                                        pcall(parry)
                                        task.wait(0.05)
                                    end
                                end
                            )
                        end
                    end
                }
            )

            local YCDSHYT = false
            local Toggle =
                Tab:Toggle(
                {
                    Title = T("移除定身"),
                    Desc = T("角色无定身状态(如攻击4下之后的定身)"),
                    Icon = "bird",
                    Type = "Checkbox",
                    Default = false,
                    Callback = function(state)
                        YCDSHYT = state
                        if state then
                            task.spawn(
                                function()
                                    while YCDSHYT and task.wait(0.1) do
                                        pcall(
                                            function()
                                                local Freeze = LocalPlayer.Character:FindFirstChild("Freeze")
                                                if Freeze then
                                                    Freeze:Destroy()
                                                end
                                                local ComboStun = LocalPlayer.Character:FindFirstChild("ComboStun")
                                                if ComboStun then
                                                    ComboStun:Destroy()
                                                end
                                            end
                                        )
                                    end
                                end
                            )
                        end
                    end
                }
            )

            local Input =
                Tab:Input(
                {
                    Title = T("击杀数"),
                    Desc = T("伪造你的击杀数(仅自己可见)"),
                    Value = "",
                    InputIcon = "bird",
                    Type = "Input",
                    Placeholder = "",
                    Callback = function(input)
                        pcall(
                            function()
                                game:GetService("Players").LocalPlayer.leaderstats.Kills.Value = tonumber(input) or 0
                            end
                        )
                    end
                }
            )

            local Input =
                Tab:Input(
                {
                    Title = T("总击杀数"),
                    Desc = T("伪造你的总击杀数(仅自己可见)"),
                    Value = "",
                    InputIcon = "bird",
                    Type = "Input",
                    Placeholder = "",
                    Callback = function(input)
                        pcall(
                            function()
                                game:GetService("Players").LocalPlayer.leaderstats["Total Kills"].Value = tonumber(input) or 0
                            end
                        )
                    end
                }
            )
        end
    }
)