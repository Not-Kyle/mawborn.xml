local Service = setmetatable({}, {
    __index = function(self: Instance, ...)
        local Arguments = {...}
        local Key = select(1, Arguments);

        local Result = game:GetService(Key);
        
        if cloneref then
            return cloneref(Result);
        end

        rawset(self, Arguments, Result);
        return Result;
    end
})

local Workspace = Service.Workspace;
local Camera = Workspace and Workspace.CurrentCamera;

local Utils = {};

local Logger = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Logging.lua');

function Logger:FWarning(Name: string, Message: string)
    return Logger:Warning(string.format('[%s]: %'), Name, Message)
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
    local Result = Workspace:Raycast(Camera.CFrame.Position, Direction, RaycastParmam);

    return not Result;
end

return Utils;
