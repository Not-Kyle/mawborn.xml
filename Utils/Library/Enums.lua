if getgenv().Mawborn.Library.Enumerations then
    return
end

local Enumerations = {};
local LastFired = {};

local Cooldown = 0.5;

local Logger = Import('Utils/Logging.lua');
local Utils = Import('Utils/Utils.lua');

local Host = Utils.Players and Utils.Players.LocalPlayer;
local Backpack = Host and Host:WaitForChild('Backpack', 5);

local function CheckRemotes(Parent: Instance, Remote: string)
    if not Parent then
        Logger:Warning('Parent to ' .. Remote .. ' was not found');

        return;
    end

    local RemoteEvent = Parent:FindFirstChild(Remote, true);

    if not RemoteEvent or not RemoteEvent:IsA('RemoteEvent') then
        Logger:Warning('[Remote]: ' .. Remote .. ' | Not found or not a RemoteEvent')
        return
    end

    return RemoteEvent;
end


local function SafeFire(Remote: RemoteEvent, ...)
    local Now = os.clock();

    if LastFired[Remote] and Now - LastFired[Remote] < Cooldown then
        return;
    end

    LastFired[Remote] = Now;

    local Success, Error = pcall(Remote.FireServer, Remote, ...)

    if not Success then
        Logger:Warning(Remote.Name .. ' call failed: ' .. tostring(Error))
    end
end


function Enumerations.SetClan(ClanId: number, Text: string)
    local Id = (ClanId ~= nil) and ClanId or 1;
    local Label = Text ~= nil and Text or '';

    if Utils.Remake then
        local FiringRemote = CheckRemotes(Utils.ReplicatedStorage, 'Game');

        if not FiringRemote then
            return
        end
        
        SafeFire(FiringRemote, 'Groups', 'Join', Id);
        return;
    end

    local Stank = CheckRemotes(Backpack, 'Stank');

    if not Stank then
        return
    end

    SafeFire(Stank, 'pick', {Name = Id, TextLabel = {Text = Label}});
    return;
end


function Enumerations.LeaveClan()
    if Utils.Remake then
        local FiringRemote = CheckRemotes(Utils.ReplicatedStorage, 'Game');

        if not FiringRemote then
            return
        end

        SafeFire(FiringRemote, 'Groups', 'Leave');
        return;
    end

    local Stank = CheckRemotes(Backpack, 'Stank');

    if not Stank then
        return
    end

    SafeFire(Stank, 'leave');
    return;
end

return Enumerations;
