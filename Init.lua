--[[
    Script Developed by themadscientists
    Gui Library: Kavo by xHeptc
]]

if shared.Gui then
    shared.Gui = nil;
    shared.Entity = nil;
end

cloneref = cloneref or function(obj: Instance)
    return obj;
end

local loadByBuild = function(name: string)
    if shared.Developer then
        if isfile('Scientist Hub/'..name) then
            return loadfile('Scientist Hub/'..name)()
        else
            warn('Failed to load ' .. name .. ' (DOESNT EXIST)!')
        end
    else
        return loadstring(game:HttpGet('https://raw.githubusercontent.com/themadscientists/ScientistsHub/refs/heads/main/'..name))()
    end
end

if shared.Developer then
    warn('Developer Mode Active, may be buggy!')
end

local players = cloneref(game:GetService('Players'))

local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua'))();
local Window = Library.CreateLib('The Scientists Hub', 'GrapeTheme');

local Client = Window:NewTab('Client'):NewSection('Modules');

Client:NewKeybind('UI Toggle', 'The key you want to toggle the ui with.', Enum.KeyCode.RightShift, function()
	Library:ToggleUI()
end)

shared.Gui = {
    Window = Window,
    Library = Library,
    Tabs = {
        ['Client'] = Client,
    }
}

shared.Entity = {
    getAlive = function(ent: Model)
        ent = ent or players.LocalPlayer.Character

        if not ent:IsA('Model') then
            return false;
        end

        if not ent:FindFirstChildOfClass('Humanoid') then
            return false;
        end

        if ent:FindFirstChildOfClass('Humanoid').Health < 0.1 then
            return false;
        end

        return true;
    end,
    getChar = function(plr: Player)
        plr = plr or players.LocalPlayer

        return plr.Character or nil
    end,
    getRoot = function(plr: Player)
        plr = plr or players.LocalPlayer

        return plr.Character and plr.Character.PrimaryPart or nil
    end,
}

local Games = loadByBuild('Games.lua')

loadByBuild('Games/Universal.lua')
for index, value in Games do
    for _, value2 in value do
        if game.PlaceId == value2 then
            loadByBuild('Games/'..index..'.lua')
            break
        end
    end
end