if getgenv().Mawborn.Utils then
    return
end

local Service = setmetatable({}, {
    __index = function(self: Instance, ...)
        local Arguments = {...}
        rawset(self, Arguments, Arguments[1])
        
        if not cloneref then
            return game:GetService(Arguments[1]);
        end

        return cloneref(game:GetService(Arguments[1]));
    end
})

local Utils = {
    Stats = Service.Stats,
    CoreGui = Service.CoreGui,
    Players = Service.Players,
    Lighting = Service.Lighting,
    Workspace = Service.Workspace,
    GuiService = Service.GuiService,
    RunService = Service.RunService,
    StarterGui = Service.StarterGui,
    HttpService = Service.HttpService,
    TweenService = Service.TweenService,
    ScriptContext = Service.ScriptContext,
    TeleportService = Service.TeleportService,
    TextChatService = Service.TextChatService,
    UserInputService = Service.UserInputService,
    CollectionService = Service.CollectionService,
    ReplicatedStorage = Service.ReplicatedStorage,
    MarketplaceService = Service.MarketplaceService;
    ProximityPromptService = Service.ProximityPromptService,
};

local Host = Utils.Players and Utils.Players.LocalPlayer;

local PlaceId = game.PlaceId;
local JobId = game.JobId;
local Camera = Utils.Workspace and Utils.Workspace.CurrentCamera;

Utils.Streets = PlaceId == 455366377;
Utils.Prison = PlaceId == 15852982099;
Utils.Remake = PlaceId == 81769606750513;

Utils.BothOriginal = Utils.Streets or Utils.Prison;
Utils.BothPrisons = Utils.Prison or Utils.Remake;
Utils.All = Utils.Streets or Utils.Prison or Utils.Remake;

if Utils.Prison then
    game:shutdown(); -- I highly recommed not injecting Mawborn on prison, so you dont get logged for exploiting
end

local Creators = {
    [5388525718]  = {Name = 'hellokittysouljia'},
    [7705935312]  = {Name = 'mawborn'},
}

local Moderators = { -- Don't care about remake, gets taken down in 30 mins xd
    -- Level Definitions:
    -- 5 = Owner
    -- 4 = Close with Owner
    -- 3 = Mod (Can Ban)
    -- 2 = Kick Only
    -- 1 = Grey Loot Commands

    -- Global Moderators
    [57372642]  = {Name = 'Kotojo', Level = 5},
    [155145543] = {Name = 'Kaiits', Level = 4},
    [853076852] = {Name = 'Kaiits', Level = 4},
    [5162665695] = {Name = 'Cyrus', Level = 4},
    [14321011]  = {Name = 'AfroVs', Level = 4},

    -- Unknown Game Mods []
    [3631092729] = {Name = 'pawscribble', Level = 3},
    [680122427]  = {Name = 'chibisanu', Level = 3},

    Prison = {
        --[4370541]     = {Name = 'Chosen', Level = 3},
        [2323183756] = {Name = 'e8llie', Level = 3},
        [74287496]   = {Name = 'ImmScarrr', Level = 3},
        --[1189253064]  = {Name = 'digitalbows', Level = 3}, -- Unconfirmed but was in godmode when trying to kill
        --[7763803027]  = {Name = 'dttmfocus', Level = 3}, -- Also Unconfirmed but told by a player
        --[1395662432]  = {Name = 'randosewru', Level = 3},
        --[7118197747]  = {Name = 'running50fpsoneu', Level = 3}, -- No longer a mod
        --[5836017791]  = {Name = 'Momentshaspast', Level = 3},
        --[79746858]    = {Name = 'digitalboyheart', Level = 3},
        --[50098375]    = {Name = 'restwellkris', Level = 3},
    },

    Streets = {
        [90384746]    = {Name = 'Futures_Society', Level = 3},
        [141968373]   = {Name = 'OG_Thechosenone', Level = 3},
        [2830267496]  = {Name = 'lxxlikeheaven', Level = 3},
        [428555337]   = {Name = 'progamerpvp137', Level = 3},
        [8942221725]  = {Name = 'livemassacre', Level = 3},
    }
}

local TempKos = { -- // Temperaory KOS // Will be adding a KOS System that runs through files, will add someone automatically if I say so, by notification? Still thinking of ideas
    -- Levels:
    -- Level 3: Kill on sight or for a friend
    -- Level 2: Should probably kill this person
    -- Level 1: A bit annoying but can live
    -- Level 0: Troll or make mad

    [43377200]  = {Name = 'cosmicman233', Reason = 'A complete spurg', Level = 2},

    [105026789]  = {Name = 'dnd01092', Reason = 'Legit fight, big mouth (Funny when mad)', Level = 1},
    [202232476]  = {Name = 'Moxris', Reason = 'Being a sped', Level = 1},
    [5579968613]  = {Name = 'coastalgroove', Reason = 'Being a sped', Level = 1},

    [1372774669] = {Name = 'aacidbathfan', Reason = 'Funny to get mad', Level = 0},
    [1925953479] = {Name = 'vcsxadf AKA Bot', Reason = 'Call him a pedophile and he will crumble like a cookie, funny to mess with', Level = 0}, -- "Watches The Streets for pedophiles" he says. What a hero
    [1114660918] = {Name = 'meowingforzay', Reason = 'Extremly funny', Level = 0},
    [648643534]  = {Name = 'meowingforjes', Reason = 'Jes bf? Whoever Jes is but funny to make mad', Level = 0},
    [9485008174] = {Name = 'nehcoIe', Reason = 'femcel, wears a doxbin shirt. Just hype up her ego, its funny', Level = 0},
}

local Logger = Import('Utils/Logging.lua');

function Logger:FWarning(Name: string, Message: string)
    return Logger:Warning(string.format('[%s]: %'), Name, Message)
end


function Utils.PlaceId() : number
    return PlaceId;
end


function Utils.JobId() : number
    return JobId;
end


function Utils.AddService(ServiceName: string)
    return Service[ServiceName]
end


function Utils.Mods(Specific: boolean) : table
    if not Specific then Specific = true end

    if Specific then
        if Utils.Streets then
            return Moderators.Streets;
        end

        return Moderators.Prison;
    end

    return Moderators;
end

function Utils.AdminCheck(UserId: number, Player: Player) : boolean
    if not Utils.Remake and Utils.Mods()[UserId] then
        return true
    end

    if Utils.Remake and Player:IsInGroupAsync(34316646) then
        return true
    end
end


function Utils.Kos() : table
    return TempKos;
end


function Utils.KosCheck(UserId: number) : boolean
    if TempKos[UserId] then
        return true
    end
end


function Utils.Creators() : table
    return Creators;
end


function Utils.CreatorCheck(UserId: number) : boolean
    if Creators[UserId] then
        return true
    end
end


function Utils.GameTitle() : string
    return Utils.MarketplaceService and Place and Utils.MarketplaceService:GetProductInfo(Place).Name or 'N/A';
end


function Utils.Clipboard(Message: string)
    return (setclipboard or syn.write_clipboard or set_clipboard)(Message);
end


function Utils.Title(State: number, CustomText: string) : string
    local ScriptNames = {[1] = 'mawborn', [2] = 'mawborn.xml', [3] = 'Mawborn'};

    return ScriptNames[State] or CustomText;
end


function Utils.TagSystem() : ModuleScript
    return Utils.Streets and Utils.ReplicatedStorage and require(Utils.ReplicatedStorage:FindFirstChild('TagSystem'))
end -- greenbull | action | Action | creator | creatorslow | reloading | KO | gunslow | Dragging \\ PlayerGui.LocalScript


function Utils.FindPlayer(Target: string) : table
    local Target = string.lower(Target)
    local GetPlayers = Utils.Players:GetPlayers();

    local PlayerTable = {};

    local function Name(Index: Player, Property: string)
        return string.sub(string.lower(tostring(Index[Property])), 1, string.len(Target))
    end

    if table.find({'myself', 'client', 'self', 'host', 'me'}, Target) then
        return {Host};
    end

    if Target == 'all' or Target == 'users' then
        for _, Index in next, GetPlayers do
            if Index.Name ~= Host.Name then
                table.insert(PlayerTable, Index)
            end
        end

        return PlayerTable
    end

    for _, Index in next, GetPlayers do
        if Name(Index, 'Name') == Target or Name(Index, 'DisplayName') == Target then
            table.insert(PlayerTable, Index)
        end
    end

    if #PlayerTable == 0 then
        return
    end

    return PlayerTable
end


function Utils.GetName(Player: Player) : string
    return Player and Player.Name;
end


function Utils.GetDisplay(Player: Player) : string
    return Player and Player.DisplayName;
end


function Utils.Body(Player: Player, Name: string) : Model
    if not Player then
        Logger:FWarning(Name, 'Player indexed as nil');
        return;
    end

    return Player.Character or Player.CharacterAdded:Wait();
end


function Utils.Root(Player: Player) : BasePart
    local Character = Utils.Body(Player, 'Utils.Root')

    if not Character then
        return
    end

    local Humanoid = Character:FindFirstChildOfClass('Humanoid')
    local Root = Character:FindFirstChild('HumanoidRootPart')

    return Root or (Humanoid and Humanoid.RootPart)
end


function Utils.Humanoid(Player: Player) : Humanoid
    local Character = Utils.Body(Player, 'Utils.Humanoid')

    if not Character then
        return
    end

    return Character:FindFirstChildOfClass('Humanoid')
end


function Utils.Head(Player: Player) : BasePart
    local Character = Utils.Body(Player, 'Utils.Head')

    if not Character then
        return
    end

    return Character:FindFirstChild('Head')
end


function Utils.WallCheck(Body: Model, Character: Model, Part: BasePart) : boolean
    local RaycastParmam = RaycastParams.new();
    RaycastParmam.FilterType = Enum.RaycastFilterType.Blacklist;
    RaycastParmam.FilterDescendantsInstances = {Camera, Body, Character};

    local Direction = (Part.Position - Camera.CFrame.Position);
    local Result = Utils.Workspace:Raycast(Camera.CFrame.Position, Direction, RaycastParmam);

    return not Result;
end -- Body = Myself, Character = Other Player


function Utils.KnockedCheck(Player: Player)
    if not Player then return end

    Player:SetAttribute('Knocked', false)

    if Utils.Head(Player):FindFirstChild('Bone', true) then
        Player:SetAttribute('Knocked', true)
    end
end

return Utils;
