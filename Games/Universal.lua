--[[
    Game: Universal (all games)
    Developed by: themadscientists
]]

local Gui = shared.Gui;
local Entity = shared.Entity;

cloneref = cloneref or function(obj: Instance)
    return obj;
end

local runService = cloneref(game:GetService('RunService'))
local userInputService = cloneref(game:GetService('UserInputService'))

local Movement = Gui.Window:NewTab('Movement'):NewSection('Modules');
Gui.Tabs['Movement'] = Movement;

local Speed = false; Movement:NewToggle('Speed', 'Allows for faster movement.', function(value: number)
    Speed = value;
end)
local SpeedValue = 16; Movement:NewSlider('Speed Value', 'the amount of speed you change.', 100, 0, function(value: number)
    SpeedValue = value;
end)

runService:BindToRenderStep('Speed', 99999, function(dt: number)
    if not Speed then
        return
    end

    if not Entity.getAlive() then
        return
    end

    Entity.getRoot().CFrame += (Entity.getChar().Humanoid.MoveDirection * SpeedValue * dt);
end)

local Fly = false; Movement:NewKeybind('Fly', 'Allows you to move in the air freely.', Enum.KeyCode.R, function()
    Fly = not Fly;
end)

runService:BindToRenderStep('Fly', 99999, function(dt: number)
    if not Fly then
        return
    end

    if not Entity.getAlive() then
        return
    end

    Entity.getRoot().AssemblyLinearVelocity = Vector3.new(Entity.getRoot().AssemblyLinearVelocity.X, (userInputService:IsKeyDown('Space') and 40 or (userInputService:IsKeyDown('LeftShift') and -40 or 1)), Entity.getRoot().AssemblyLinearVelocity.Z)
end)