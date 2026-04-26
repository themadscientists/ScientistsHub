--[[
    Game: https://www.roblox.com/games/119265221596002/Sword-Fighting-Pit
    Developed by: themadscientists
]]

local Gui = shared.Gui;
local Entity = shared.Entity;

cloneref = cloneref or function(obj: Instance)
    return obj;
end

local players = cloneref(game:GetService('Players'))
local runService = cloneref(game:GetService('RunService'))
local replStorage = cloneref(game:GetService('ReplicatedStorage'))

local WibiPit = {
    Remotes = {
        Attack = replStorage:WaitForChild('Remotes'):FindFirstChild('Attack'),
        Rebirth = replStorage:WaitForChild("Remotes"):WaitForChild("Rebirth"),
        BuyAbility = replStorage:WaitForChild("Remotes"):WaitForChild("BuyAbility"),
        EquipAbility = replStorage:WaitForChild("Remotes"):WaitForChild("EquipAbility"),
        TriggerAbility = replStorage:WaitForChild("Remotes"):WaitForChild("TriggerAbility"),
    },
    Paths = {
        Knockback = replStorage:WaitForChild('KnockbackVelocity'),
    },
}

local getAttackable = function(obj)
    if not Entity.getAlive(obj) then
        return false
    end;

    if obj == Entity.getChar() then
        return false
    end;

    return obj and obj.PrimaryPart and obj.PrimaryPart.CFrame.Y < 135
end

local getNearestEntity = function(data: {range: number})
    local nearest, dist = nil, math.huge;

    for _, value in players:GetPlayers() do
        if not value then
            return
        end

        if not getAttackable(value.Character) then
            continue
        end;

        local Distance = players.LocalPlayer:DistanceFromCharacter(value.Character.PrimaryPart.CFrame.Position);

        if Distance <= data.range and Distance < dist then
            nearest = value;
            dist = Distance
        end
    end

    return nearest;
end

local Combat = Gui.Window:NewTab('Combat'):NewSection('Modules');
local Utility = Gui.Window:NewTab('Utility'):NewSection('Modules');
Gui.Tabs['Combat'] = Combat;
Gui.Tabs['Utility'] = Combat;

local Killaura = false; Combat:NewToggle('Killaura', 'Automatically attacks players around you.', function(value: boolean)
    Killaura = value;
end)

local attackCooldown = tick()
runService:BindToRenderStep('Killaura', 9999, function()
    if not Killaura then
        return
    end;

    if not Entity.getAlive() then
        return
    end;

    if not Entity.getRoot() then
        return
    end

    local nearestEntity = getNearestEntity({range = 10});

    if nearestEntity and (tick() - attackCooldown) > 0.3 then
        WibiPit.Remotes.Attack:FireServer(
            (Entity.getRoot().CFrame.Position - nearestEntity.Character.PrimaryPart.CFrame.Position).Unit,
            nearestEntity.Character:FindFirstChild('Hitbox')
        )

        attackCooldown = tick()
    end
end)

local TargetStrafe = false; Combat:NewToggle('Target Strafe', 'automatically dodges the enemies attacks.', function(value: boolean)
    TargetStrafe = value;
end)

local getLowestAttackble = function()
    local lowest, hp = nil, math.huge;

    for index, value in players:GetPlayers() do
        if not getAttackable(value.Character) then
            continue
        end;

        if value.Character and value.Character:FindFirstChild('Humanoid') and value.Character.Humanoid.Health < hp then
            lowest = value
            hp = value.Character.Humanoid.Health
        end
    end

    return lowest
end

local lastAttacking = nil

runService:BindToRenderStep('Target Strafe', 9999, function()
    if not TargetStrafe then
        return
    end;

    if not Entity.getAlive() then
        return
    end;

    local nearestEntity = getNearestEntity({range = 18});

    --[[if nearestEntity and (tick() - attackCooldown) > 0.25 then
        Entity.getRoot().CFrame = CFrame.lookAt(nearestEntity.Character.PrimaryPart.CFrame.Position + Vector3.new(0, 8, 0) - nearestEntity.Character.PrimaryPart.CFrame.LookVector * 2, nearestEntity.Character.PrimaryPart.CFrame.Position)
        Entity.getRoot().Velocity = Vector3.zero
    elseif nearestEntity and (tick() - attackCooldown) < 0.2 and (tick() - attackCooldown) > 0.15 then
        Entity.getRoot().CFrame = CFrame.lookAt(nearestEntity.Character.PrimaryPart.CFrame.Position + Vector3.new(0, 15, 0) - nearestEntity.Character.PrimaryPart.CFrame.LookVector * 2, nearestEntity.Character.PrimaryPart.CFrame.Position)
        Enity.getRoot().Velocity = Vector3.zero
    end]]

    if lastAttacking and getAttackable(lastAttacking.Character) then
        Entity.getRoot().CFrame = CFrame.lookAt(lastAttacking.Character.PrimaryPart.CFrame.Position + Vector3.new(0, 7, 0), lastAttacking.Character.PrimaryPart.CFrame.Position)
        Entity.getRoot().Velocity = Vector3.zero

        return
    end

    if nearestEntity then
        Entity.getRoot().CFrame = CFrame.lookAt(nearestEntity.Character.PrimaryPart.CFrame.Position + Vector3.new(0, 7, 0), nearestEntity.Character.PrimaryPart.CFrame.Position)
        Entity.getRoot().Velocity = Vector3.zero
    end
end)

Combat:NewToggle('No Knockback', 'Allows your character to not take knockback', function(value: boolean)
    WibiPit.Paths.Knockback.MaxForce = value and 0 or 100000
end)

local avPart = Instance.new('Part')
avPart.Parent = workspace
avPart.Size = Vector3.new(1000, 3, 1000)
avPart.Position = Vector3.new(0, -11, 0)
avPart.Transparency = 1
avPart.CanCollide = false
avPart.Anchored = true

Gui.Tabs['Movement']:NewToggle('Water Walk', 'Allows you to walk on water', function(value: boolean)
    avPart.CanCollide = value
end)

local sCon = nil; Gui.Tabs['Movement']:NewToggle('Safe Water Walk', 'safer version', function(value: boolean)
    avPart.CanCollide = value

    sCon = avPart.Touched:Connect(function()
        Entity.getRoot().CFrame = CFrame.new(Vector3.new(0, 0, 0))
    end)

    if not value then
        sCon:Disconnect()
    end
end)

local AutoPlay = false; Combat:NewToggle('Auto Play', 'auto play the game', function(value: boolean)
    AutoPlay = value
end)

runService:BindToRenderStep('AutoPlay', 9999, function()
    if not AutoPlay then
        return
    end

    if not Entity.getAlive() then
        return
    end

    local char = Entity.getChar()

    local bestNearestToAttack = getLowestAttackble()

    if bestNearestToAttack and lastAttacking ~= bestNearestToAttack then
        Entity.getRoot().CFrame = bestNearestToAttack.Character.PrimaryPart.CFrame
        lastAttacking = bestNearestToAttack
    end

    if players.LocalPlayer.hiddenstats.Gold.Value > 350 and not players.LocalPlayer.Abilities:FindFirstChild('Heal') then
        WibiPit.Remotes.BuyAbility:FireServer('Heal')
    end

    if players.LocalPlayer.hiddenstats.Ability.Value ~= 'Heal' then
        WibiPit.Remotes.EquipAbility:FireServer('Heal')
    end

    if char and char:FindFirstChild('Humanoid') and char.Humanoid.Health < 50 and players.LocalPlayer.hiddenstats.Ability.Value == 'Heal' then
        WibiPit.Remotes.TriggerAbility:FireServer('Heal')
    end
end)

local ARebirth = false; Utility:NewToggle('Auto Rebirth', 'Automatically rebirths for you.', function(value: boolean)
    ARebirth = value;
end)

runService:BindToRenderStep('ARebirth', 9999, function()
    if not ARebirth then
        return
    end

    local maxLevelNeeded = math.clamp(10 + players.LocalPlayer.hiddenstats.Rebirths.Value * 5, 10, players.LocalPlayer.hiddenstats.MaxLevel.Value)

    if players.LocalPlayer.hiddenstats.Level.Value >= maxLevelNeeded then
        WibiPit.Remotes.Rebirth:FireServer();
    end
end)