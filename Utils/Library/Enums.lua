if getgenv().Mawborn.Library.Enumerations then
    return
end

local OsClock = os.clock;
local Pcall, Tostring = pcall, tostring;
local TableFreeze = table.freeze;

local Enumerations = {};
local LastFired = {};

local Cooldown = 0.5;

local Logger = Import('Utils/Logging.lua');
local Utils = Import('Utils/Utils.lua');

local Host = Utils.Players and Utils.Players.LocalPlayer;
local Backpack = Host and Host:WaitForChild('Backpack', 5);

function Enumerations.CheckRemotes(Parent: Instance, Remote: string)
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


function Enumerations.SafeFire(Remote: RemoteEvent, ...)
    local Now = OsClock();

    if LastFired[Remote] and Now - LastFired[Remote] < Cooldown then
        return;
    end

    LastFired[Remote] = Now;

    local Success, Error = Pcall(Remote.FireServer, Remote, ...)

    if not Success then
        Logger:Warning(Remote.Name .. ' call failed: ' .. Tostring(Error))
    end
end


function Enumerations:SetClan(ClanId: number, Text: string)
    local Id = (ClanId ~= nil) and ClanId or 1;
    local Label = Text ~= nil and Text or '';

    if Utils.Remake then
        local FiringRemote = self.CheckRemotes(Utils.ReplicatedStorage, 'Game');

        if not FiringRemote then
            return
        end
        
        self.SafeFire(FiringRemote, 'Groups', 'Join', Id);
        return;
    end

    local Stank = self.CheckRemotes(Backpack, 'Stank');

    if not Stank then
        return
    end

    self.SafeFire(Stank, 'pick', {Name = Id, TextLabel = {Text = Label}});
    return;
end


function Enumerations:LeaveClan()
    if Utils.Remake then
        local FiringRemote = self.CheckRemotes(Utils.ReplicatedStorage, 'Game');

        if not FiringRemote then
            return
        end

        self.SafeFire(FiringRemote, 'Groups', 'Leave');
        return;
    end

    local Stank = self.CheckRemotes(Backpack, 'Stank');

    if not Stank then
        return
    end

    self.SafeFire(Stank, 'leave');
    return;
end

return TableFreeze(Enumerations);
