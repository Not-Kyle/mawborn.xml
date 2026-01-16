if getgenv().Mawborn.Library.Enumerations then
    return
end

local Enumerations = {};

local Logger = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Logging.lua');
local Utils = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Utils.lua');

local Host, Backpack, Stank do
    Host = Utils.Players and Utils.Players.LocalPlayer;
    Backpack = Host and Host:WaitForChild('Backpack');
    Stank = Backpack and Backpack:FindFirstChild('Stank')
end

function Enumerations.SetClan(String: string, ClanId: number)
    if Utils.Remake then
        local FiringRemote = Utils.ReplicatedStorage:FindFirstChild('Game', true)

        FiringRemote:FireServer('Groups', 'Join', ClanId or 1)
        return
    end

    if not Stank then
        return
    end

    for _, Index in ipairs ({'pick', 'join'}) do
        local Success, Error = pcall(function()
            Stank:FireServer(Index, {
                Name = ClanId or 1,
                TextLabel = {Text = String or 'Label'},
            })
        end)

        if Success then
            break
        end

        if Error then
            Logger:Warning('Group method: "pick", not found! Trying "join"!')
        end
    end
end

function Enumerations.LeaveClan()
    if Utils.Remake then
        local FiringRemote = Utils.ReplicatedStorage:FindFirstChild('Game', true)

        FiringRemote:FireServer('Groups', 'Leave');
        return
    end

    if not Stank then
        return
    end
    
    Stank:FireServer('leave');
end

return Enumerations;
