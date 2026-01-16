--[[ TODO:
Add A damage meter (Maybe a calculation that will tell you how many more hits out of the item you're holding to KO the player)
Add an Autostomp (Add whitelist to it)
Add Anti Groundhit
Add Loop Teleport to Player
Add Auto Equip
Add Autoheal -- (Works but not done)
Add Auto Cash or Auto Items
Add Corner Esp
Add Hitchams

Revert all Index calls to Namecall -- UPDATE, I think I did? If I missed one whatever
Change calls to being OOP

-- ALL OLD UPDATE IDEAS, WILL NOT BE ADDED. MAWBORN.XML WILL ALWAYS BE ON 0.9.95

-- //
    People or scripts who have contribed to the script in someway

    Calls - for letting me know about :GetBoundingBox()
    Xaxa - for giving me his Aimlock method
    Cyrus - for letting me know about using hookmetamethod __namecall correctly (I don't have it in this verison but in the private one I do)
    Lurk - I used the same bullet trails in pie.solutions (Gave it to me about 3 years ago)

    Ponyhook - for being a reference
-- \\

-- REMOTE NAMES IN "REMAKE"

> Stomp (Stomps players)
> Update (Updates your FOV)
> Drag (Starts drag)
> Touch (Used for melee)
> Shoot (Used for guns)
> Groups (Used for groups)
]]--

if getgenv().MawbornLoaded then
    return
end


if not game:IsLoaded() then
    game.Loaded:Wait()
end


local OsTime = (tick or os and os.time)()


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

getgenv().MawbornLoaded = true;

local Enums = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Library/Enums.lua');
local Utils = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Utils.lua');
local Logger = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Logging.lua');
local String = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Utils.lua');
local FileHandler = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/FileHandler.lua');
local TextProperties = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/TextProperties.lua');
local CommandHandler = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Comands.lua');

local Host, Body, Head, Root, Humanoid, Torso, Mouse, Camera, PlayerGui, Backpack, Hud, CashUi, AmmoUi, CurrentAmmo, GetMouse do
    Host = Utils.Players and Utils.Players.LocalPlayer;
    Body = Host and Host.Character or Host.CharacterAdded:Wait();
    Head = Body and Body:WaitForChild('Head');
    Humanoid = Body and Body:WaitForChild('Humanoid') or Body:FindFirstChildOfClass('Humanoid');
    Root = Body and Body:WaitForChild('HumanoidRootPart') or Humanoid.RootPart
    Torso = Body and Body:WaitForChild('Torso');

    Mouse = Host and Host:GetMouse()
    Camera = Utils.Workspace and Utils.Workspace.CurrentCamera;

    PlayerGui = Host and Host:WaitForChild('PlayerGui');
    Backpack = Host and Host:WaitForChild('Backpack');
    Hud = PlayerGui and PlayerGui:WaitForChild('HUD');
    CashUi = Hud and Hud:FindFirstChild('Cash');
    AmmoUi = Hud and Hud:FindFirstChild('Ammo');
    CurrentAmmo = Hud and Hud:FindFirstChild('CurrentAmmo');

    GetMouse = Body and Body:FindFirstChild('GetMouse');
end

local Place, Job, MousePosition, ExperienceChat, ChatFrame, ColorCorrection, SnaplineMethod, HttpRequest, Queueonteleport, DeathPosition do
    Place = game.PlaceId;
    Job = game.JobId;

    MousePosition = Utils.UserInputService and Utils.UserInputService:GetMouseLocation();

    ExperienceChat = Utils.CoreGui and Utils.CoreGui:FindFirstChild('ExperienceChat');
    ChatFrame = Utils.TextChatService and Utils.TextChatService:FindFirstChild('ChatWindowConfiguration');

    ColorCorrection = Utils.Lighting and Utils.Lighting:FindFirstChildOfClass('ColorCorrectionEffect')

    SnaplineMethod = Utils.UserInputService and Utils.UserInputService:GetMouseLocation()

    HttpRequest = (syn and syn.request) or (http and http.request) or http_request or request;
    Queueonteleport = (syn and syn.queue_on_teleport) or queueonteleport or (syn and syn.queueonteleport);

    DeathPosition = CFrame.new()
end

local AimlockTarget;
local AudioTarget;
local CamlockTarget;
local ClipboardTarget;
local CycleHSV;
local EspTarget;
local JumpConnection;
local Ping;
local TeleportTarget;
local UserIdTarget;
local ViewTarget;
local WatchRejoinTarget;
local Weapon;
local UnespTarget;

local TagBoomboxes = 'Hooked::Boomboxes';
local TagTools = 'Hooked::Items';
local TagTrails = 'Hooked::Trails';

local Lerping = 0;
local Speed = 0.01;

local Boomboxes = {};
local Debounce = {};
local EspConfig = {};
local GradientCache = {};
local Hash = {};
local ItemEspConfig = {};
local Lights = {};
local Movement = {};
local ProcessedItems = {};
local Pumpkins = {};
local Seats = {};
local VehicleSeats = {};
local WhitelistedItems = {};

local Colors = {
    ScriptColor = Color3.fromRGB(225, 225, 225),
    AccentColor = Color3.fromRGB(170, 170, 255),
    ModeratorColor = Color3.fromRGB(255, 170, 170),
    MouseColorOff = Color3.fromRGB(170, 170, 255),
    MouseColorOffTint = Color3.fromRGB(120, 120, 255),
    MouseColorOn = Color3.fromRGB(255, 0, 0),
    MouseColorOnTint = Color3.fromRGB(200, 0, 0),
}

local Items = {
    TextureIds = {
        ['rbxassetid://454819722']  = {Name = 'Flash Bang'},
        ['rbxassetid://454823039']  = {Name = 'Molotov'},
        ['rbxassetid://436966973']  = {Name = 'Grenade'},
        ['rbxassetid://441591885']  = {Name = 'Pipe Bomb'},

        ['rbxassetid://129400613975716'] = {Name = 'USAS'},
        ['rbxassetid://111628501676927'] = {Name = 'Uzi'},

        ['rbxassetid://12177147']  = {Name = 'Katana'},
        ['rbxassetid://511726139'] = {Name = 'Cash'},
    },

    MeshIds = {
        ['rbxassetid://137762422011047'] = {Name = 'Rifle'},
    }
}

local Originals = {
    Gravity = Utils.Workspace and Utils.Workspace.Gravity,
    FOV = Camera and Camera.FieldOfView,
    Zoom = Host and Host.CameraMaxZoomDistance,
    WalkSpeed = Humanoid and Humanoid.WalkSpeed,
    HipHeight = Humanoid and Humanoid.HipHeight,
    JumpPower = Humanoid and Humanoid.JumpPower,
}

for _, Connection in next, getconnections(Utils.ScriptContext.Error) do
    if Utils.Streets and getfenv(Connection.Function).script == PlayerGui.LocalScript then
        Connection:Disable() -- // Creds to Ponyhook
    end
end

-- UI's []

getgenv().mawborn = Instance.new('ScreenGui')
if syn and syn.product_gui then
    syn.protect_gui(mawborn)
end
mawborn.Name = 'mawborn.xml'
mawborn.Parent = gethui() or Utils.CoreGui;
mawborn.ResetOnSpawn = false
mawborn.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mawborn.IgnoreGuiInset = true


local function NewInstance(Type: string, Class: string, Properties: any) -- Thanks to Xaxa
    if Type == 'Draw' and Drawing then
        Class = Drawing.new(Class);
    end

    if Type == 'Instance' then
        Class = Instance.new(Class);

        if protectinstance then
            protectinstance(Class)
        end
    end

    for Index, Values in next, Properties do
        Class[Index] = Values;
    end

    return Class;
end


local Circle = NewInstance('Draw', 'Circle', {
    Filled = false;
    Transparency = 1;
    ZIndex = 1;
    NumSides = 250;
})

task.delay(2, function()
    while task.wait(0.5) do 
        Import('https://raw.githubusercontent.com/Ghost-Mountain/Apollon/refs/heads/main/Coil.lua');

        task.wait(10)
        break;
    end
end)

local Network = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Network.lua');
local Watermark = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Watermark.lua')
local Menu = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/NewMenu.lua')
local FileMenu = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Files.lua')
local ThemeMenu = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Themes.lua')

local mawborn = mawborn;

local Select = Select;
local Boolean = Boolean;

local CommandBar = CommandBar;
local OuterCommand = OuterCommand;
local OuterWatermark = OuterWatermark;
local OuterCommandBar = OuterCommandBar;

local OuterConfig = NewInstance('Instance', 'Frame', {
    Name = 'OuterConfig',
    AnchorPoint = Vector2.new(0.5, 0.5),
    Parent = mawborn,
    BackgroundColor3 = Color3.fromRGB(14, 14, 14),
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    Position = UDim2.fromScale(0.05, 0.52),
    Size = UDim2.fromOffset(176, 366),
    Visible = false;
})

local UICorner = NewInstance('Instance', 'UICorner', {
    CornerRadius = UDim.new(0, 4),
    Parent = OuterConfig,
})

local BorderInner = NewInstance('Instance', 'Frame', {
    Name = 'InnerConfig',
    Parent = OuterConfig,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderColor3 = Color3.fromRGB(27, 27, 27),
    BorderSizePixel = 1,
    Position = UDim2.fromScale(0.012, 0.007),
    Size = UDim2.fromOffset(172, 362),
})

local InnerConfig = NewInstance('Instance', 'Frame', {
    Name = 'InnerConfig',
    Parent = OuterConfig,
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderColor3 = Color3.fromRGB(225, 225, 255),
    BorderSizePixel = 1,
    BorderMode = Enum.BorderMode.Inset,
    Position = UDim2.fromScale(0.012, 0.007),
    Size = UDim2.fromOffset(172, 362),
})

local UIGradient = NewInstance('Instance', 'UIGradient', {
    Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(12, 12, 12)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))},
    Rotation = -90,
    Parent = InnerConfig,
})

local Health = NewInstance('Instance', 'TextLabel', {
    Parent = mawborn,
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(162, 18),
    Font = Enum.Font.Code,
    Text = '',
    TextColor3 = Colors.ScriptColor,
    TextSize = 13,
    TextStrokeTransparency = 0;
})

local Ko = NewInstance('Instance', 'TextLabel', {
    Parent = mawborn,
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(162, 18),
    Font = Enum.Font.Code,
    TextStrokeTransparency = 0;
    Text = '',
    TextColor3 = Colors.ScriptColor,
    TextSize = 13,
})

local Stam = NewInstance('Instance', 'TextLabel', {
    Parent = mawborn,
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    Size = UDim2.fromOffset(162, 18),
    Font = Enum.Font.Code,
    TextStrokeTransparency = 0;
    Text = '',
    TextColor3 = Colors.ScriptColor,
    TextSize = 13,
})

local GunInfoBillboard = NewInstance('Instance', 'BillboardGui', {
    Parent = mawborn;
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling;
    Active = true;
    Size = UDim2.fromScale(3, 1);
    LightInfluence = 0;
    AlwaysOnTop = true;
    StudsOffset = Vector3.new(4.5, 0.5, 0);
})

local AmmoText = NewInstance('Instance', 'TextLabel', {
    Parent = GunInfoBillboard;
    BackgroundColor3 = Color3.fromRGB(0, 0, 0);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Size = UDim2.fromScale(1, 1);
    Font = Enum.Font.Code;
    TextColor3 = Color3.fromRGB(225, 225, 225);
    Text = '';
    TextSize = 14;
    AnchorPoint = Vector2.new(0.5, 0.5),
    TextStrokeTransparency = 0;
    TextWrapped = true;
    TextXAlignment = Enum.TextXAlignment.Left;
    ZIndex = 2;
})

local ClipsText = NewInstance('Instance', 'TextLabel', {
    Parent = GunInfoBillboard;
    BackgroundColor3 = Color3.fromRGB(0, 0, 0);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Size = UDim2.fromScale(1, 1);
    Font = Enum.Font.Code;
    TextColor3 = Color3.fromRGB(225, 225, 225);
    AnchorPoint = Vector2.new(0.5, 0.5),
    TextSize = 14;
    Text = '';
    TextStrokeTransparency = 0;
    TextWrapped = true;
    TextXAlignment = Enum.TextXAlignment.Left;
    ZIndex = 2;
})


local OtherAmmo = NewInstance('Instance', 'TextLabel', {
    Parent = mawborn;
    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Position = UDim2.fromScale(0.3, 0.84);
    Size = UDim2.fromOffset(140, 25);
    Font = Enum.Font.Code;
    TextColor3 = Color3.fromRGB(225, 225, 225);
    TextSize = 14;
    Text = '';
    TextStrokeTransparency = 0;
    TextXAlignment = Enum.TextXAlignment.Left;
    Visible = false;
})

local OtherClip = NewInstance('Instance', 'TextLabel', {
    Parent = mawborn;
    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Position = UDim2.fromScale(0.6, 0.84);
    Size = UDim2.fromOffset(140, 25);
    Font = Enum.Font.Code;
    TextColor3 = Color3.fromRGB(225, 225, 225);
    TextSize = 14;
    Text = '';
    TextStrokeTransparency = 0;
    TextXAlignment = Enum.TextXAlignment.Left;
    Visible = false
})

local LogoFirst = NewInstance('Instance', 'TextLabel', {
    Parent = mawborn;
    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Size = UDim2.fromOffset(100, 20);
    Font = Enum.Font.Code;
    Text = 'mawborn';
    TextColor3 = Color3.fromRGB(225, 225, 225);
    TextSize = 14;
    TextStrokeTransparency = 0;
    TextXAlignment = Enum.TextXAlignment.Right;
    ZIndex = 3;
})

local LogoSecond = NewInstance('Instance', 'TextLabel', {
    Parent = mawborn;
    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Size = UDim2.fromOffset(100, 20);
    Font = Enum.Font.Code;
    Text = '.xml';
    TextColor3 = Color3.fromRGB(170, 170, 255);
    TextSize = 14;
    TextStrokeTransparency = 0;
    TextXAlignment = Enum.TextXAlignment.Left;
    ZIndex = 3;
})

local TopLeft = NewInstance('Instance', 'Frame', {
    Parent = LogoFirst;
    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Position = UDim2.fromScale(0.44, 0.4);
    Size = UDim2.fromOffset(5, -5);
    ZIndex = 3;
})

local TopLeftStroke = NewInstance('Instance', 'UIStroke', {
    Parent = TopLeft;
    BorderStrokePosition = Enum.BorderStrokePosition.Inner;
    Color = Color3.fromRGB(200, 200, 200);
    LineJoinMode = Enum.LineJoinMode.Round;
    Thickness = 0.5;
})

local BottomRight = NewInstance('Instance', 'Frame', {
    Parent = LogoSecond;
    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Position = UDim2.fromScale(0.31, 0.78);
    Rotation = 360;
    Size = UDim2.fromOffset(5, 5);
    ZIndex = 3;
})

local TopLeftStroke = NewInstance('Instance', 'UIStroke', {
    Parent = BottomRight;
    BorderStrokePosition = Enum.BorderStrokePosition.Inner;
    Color = Color3.fromRGB(200, 200, 200);
    LineJoinMode = Enum.LineJoinMode.Round;
    Thickness = 0.5;
})

local CircleCursor = NewInstance('Instance', 'Frame', {
    Parent = mawborn;
    AnchorPoint = Vector2.new(0.5, 0.5);
    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Position = UDim2.fromScale(0.81, 0.79);
    Size = UDim2.fromOffset(75, 75);
    ZIndex = 2
})

local UICornerOuter = NewInstance('Instance', 'UICorner', {
    CornerRadius = UDim.new(0, 60);
    Parent = CircleCursor;
})

local UIStrokeOuter = NewInstance('Instance', 'UIStroke', {
    Parent = CircleCursor;
    BorderStrokePosition = Enum.BorderStrokePosition.Inner;
    Color = Color3.fromRGB(255, 255, 255);
    LineJoinMode = Enum.LineJoinMode.Round;
    Thickness = 1;
    ZIndex = 2;
})

local UIGradientStroke = NewInstance('Instance', 'UIGradient', {
    Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(170, 170, 255)), ColorSequenceKeypoint.new(0.30, Color3.fromRGB(170, 170, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(225, 225, 225))};
    Parent = UIStrokeOuter
})

local CircleInner = NewInstance('Instance', 'Frame', {
    Parent = CircleCursor;
    BackgroundColor3 = Color3.fromRGB(200, 200, 200);
    BackgroundTransparency = 0.85;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Size = UDim2.fromOffset(75, 75);
})

local UICornerInner = NewInstance('Instance', 'UICorner', {
    CornerRadius = UDim.new(0, 60);
    Parent = CircleInner;
})

local UIGradientInner = NewInstance('Instance', 'UIGradient', {
    Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(120, 120, 255)), ColorSequenceKeypoint.new(0.30, Color3.fromRGB(170, 170, 255)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(225, 225, 225))};
    Parent = CircleInner;
})

local CursorImage = NewInstance('Instance', 'ImageLabel', {
    Parent = mawborn,
    AnchorPoint = Vector2.new(0.5, 0.5),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BackgroundTransparency = 1,
    BorderColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
    Image = 'rbxassetid://316279304',
    ImageTransparency = 0.020,
})

local Ratio = NewInstance('Instance', 'UIAspectRatioConstraint', {
    Parent = CursorImage,
})

local RatioCursorCircle = NewInstance('Instance', 'UIAspectRatioConstraint', {
    Parent = CircleCursor,
})

local InfoCursor = NewInstance('Instance', 'TextLabel', {
    Parent = mawborn;
    Name = 'InfoCursor';
    AnchorPoint = Vector2.new(-0.1, 0.1);
    BackgroundColor3 = Color3.fromRGB(255, 255, 255);
    BackgroundTransparency = 1;
    BorderColor3 = Color3.fromRGB(0, 0, 0);
    BorderSizePixel = 0;
    Position = UDim2.fromScale(0.04, 0.5);
    Font = Enum.Font.Code;
    TextColor3 = Color3.fromRGB(255, 255, 255);
    TextSize = 13;
    TextXAlignment = Enum.TextXAlignment.Left;
    TextStrokeTransparency = 0;
    Visible = false;
})

local Info = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0)
local TweenCursor = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 1)
local InfoSize = TweenInfo.new(0.85, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true, 0.8)

Utils.TweenService:Create(CursorImage, Info, {Rotation = 360}):Play()
Utils.TweenService:Create(CursorImage, InfoSize, {Size = UDim2.fromScale(0.045, 0.045)}):Play()
Utils.TweenService:Create(UIGradientStroke, TweenCursor, {Rotation = -360}):Play()
Utils.TweenService:Create(UIGradientInner, TweenCursor, {Rotation = 360}):Play()

local OffGradient = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Colors.MouseColorOnTint:Lerp(Colors.MouseColorOffTint, 1)),
    ColorSequenceKeypoint.new(0.3, Colors.MouseColorOn:Lerp(Colors.MouseColorOff, 1)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(225,225,225))
}

local function UpdateLabel() -- Don't feel like deleting all of them
end

CommandBar.FocusLost:Connect(function()
    if utf8.len(CommandBar.Text) > 0 then

        local _Info = TweenInfo.new( 0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
        Utils.TweenService:Create(OuterCommand, _Info, {Position = UDim2.fromOffset(775, -300)}):Play()

        CommandHandler.Execute(CommandBar.Text)

        CommandBar.Text = ''; 
        Debounce.CommandState = false;
    end
end)

-- Functions []


local function Notify(Title: string, Text: string, Time: number)
    if (Debounce.ScriptLoaded and Boolean.Notifications.Value) then
        Menu:Notify(string.format('[%s]: %s', Title, Text), Time or 2);
    end
end


local function ChatSpy()
    if not ExperienceChat and ExperienceChat:FindFirstChild('appLayout') then
        Logger:Warning('Chat not found')
        
        return
    end

    local AppLayout = ExperienceChat:FindFirstChild('appLayout');
    local HasChatWindow = AppLayout:FindFirstChild('chatWindow')
    ChatFrame.Enabled = true

    if HasChatWindow then
        HasChatWindow.Visible = true;
        HasChatWindow.Size = UDim2.fromScale(1, 0.8);
    end
end


local function StudDistance(Object: Instance, Object2: Instance) : number
    Object2 = Object2 or Root;

    return math.round((Object.Position - Object2.Position).Magnitude)
end


local function NoScale(Size: number, Part: Instance, Divided: number) : number
    Divided = Divided or 1.1

    return math.max(1, (Size - (StudDistance(Part) / 2000)) / Divided)
end


local function RefreshPlayer()
    if not Humanoid or Utils.Remake and Torso and Torso.Destroy then
        Torso:Destroy()
    end

    if not Utils.Remake then
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        Humanoid.Health = 0
        Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
    end
end


local function FindPlayer(Target: string) : table
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


local function InsertItem(Table: table, Item: Instance)
    Table[Item] = true;

    Item.Destroying:Once(function()
        Table[Item] = nil;
    end)
end


local function GrabItem(Table: table, Radius: number) : CFrame
    if not Root or not Table then return end
    Radius = (Radius or 50) * 3;
    
    local IndexItem;
    local ClosestDistance = math.huge;

    local ItemsArray = {};

    for Item, _ in next, Table do
        if typeof(Item) == 'Instance' and Item:IsA('BasePart') then
            table.insert(ItemsArray, Item)
        end
    end

    for _, Item in next, ItemsArray do
        if Item then
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Item.Position)
            local Distance = OnScreen and (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MousePosition).Magnitude

            if OnScreen and Distance < ClosestDistance and Distance <= Radius then
                ClosestDistance = Distance;
                IndexItem = Item;
            end
        end
    end

    if IndexItem and IndexItem.CFrame then
        return IndexItem.CFrame
    end
end


local function TargetPlayer(Radius: number) : Player?
    if not Root then return end
    Radius = (Radius or 50) * 3;

    local IndexPlayer;
    local ClosestDistance = math.huge;

    local PlayerTable = {};
    local GetPlayers = Utils.Players:GetPlayers();

    for _, Index in next, GetPlayers do
        if Index.Name ~= Host.Name then
            table.insert(PlayerTable, Index)
        end
    end

    if #PlayerTable == 0 then
        return
    end

    for _, Index in next, PlayerTable do
        if not Index then return end

        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Utils.Root().Position)
        local Distance = OnScreen and (Vector2.new(ScreenPosition.X, ScreenPosition.Y) - MousePosition).Magnitude

        if OnScreen and Distance < ClosestDistance and Distance <= Radius then
            ClosestDistance = Distance;
            IndexPlayer = Index;
        end
    end

    if not IndexPlayer then
        return
    end

    return IndexPlayer
end


local function RemoveItemEsp(Object: Instance)
    if not ItemEspConfig[Object] then return end

    for _, Index in next, ItemEspConfig[Object] do
        if Index.Remove then
            Index:Remove()
        end
    end

    ItemEspConfig[Object] = nil
end


local function RemoveEsp(Player: Player)
    if not EspConfig[Player] then return end

    for _, Index in next, EspConfig[Player] do
        if Index.Remove then
            Index:Remove()
        end
    end

    EspConfig[Player] = nil
end


local function AddEsp(Player: Player) -- Creds to Ponyhook for being a refrence
    if not Player then return end
    RemoveEsp(Player)

    local CreateEsp = {
        TopText = NewInstance('Draw', 'Text', {
            Center = true,
            Outline = true,
            Color = Colors.ScriptColor,
            OutlineColor = Color3.new(0, 0, 0),
            Font = Drawing.Fonts.Monospace;
            Size = 12,
            ZIndex = 3,
            Transparency = 1,
        }),

        BottomText = NewInstance('Draw', 'Text', {
            Center = true,
            Outline = true,
            Color = Colors.ScriptColor,
            OutlineColor = Color3.new(0, 0, 0),
            Font = Drawing.Fonts.Monospace;
            Size = 12,
            ZIndex = 3,
            Transparency = 1,
        }),

        Tracer = NewInstance('Draw', 'Line', {
            Transparency = 1,
            Thickness = Select.DrawingThickness.Value,
            ZIndex = 2,
        }),

        OutlineTracer = NewInstance('Draw', 'Line', {
            Transparency = 1,
            Thickness = Select.DrawingThickness.Value,
        }),

        Box = NewInstance('Draw', 'Square', {
            Thickness = Select.DrawingThickness.Value,
            Transparency = 1,
            Filled = false,
            Color = Colors.ScriptColor,
            ZIndex = 2,
        }),

        BoxOutline = NewInstance('Draw', 'Square', {
            Thickness = Select.DrawingThickness.Value,
            Transparency = 1,
            Filled = false,
            ZIndex = 1,
        }),

        HealthBarOutline = NewInstance('Draw', 'Square', {
            Thickness = Select.DrawingThickness.Value,
            Transparency = 1,
            Filled = false,
            ZIndex = 1,
        }),

        HealthBar = NewInstance('Draw', 'Square', {
            Thickness = Select.DrawingThickness.Value,
            Transparency = 1,
            Filled = false,
            ZIndex = 2,
        }),

        SideText = NewInstance('Draw', 'Text', {
            Center = true,
            Outline = true,
            Color = Color3.fromRGB(225,0,0),
            OutlineColor = Color3.new(0, 0, 0),
            Font = Drawing.Fonts.Monospace;
            Size = 12,
            ZIndex = 3,
            Transparency = 1,
        }),

        Chams = NewInstance('Instance', 'Highlight', {
            Enabled = true,
            FillTransparency = 0,
            Parent = Player.Character,
            DepthMode = Enum.HighlightDepthMode[Select.ChamsDepth.Value],
            OutlineColor = Select.ChamsOutlineColor.Value,
            OutlineTransparency = 0,
        }),

        CustomLines = {},
    }

    EspConfig[Player] = CreateEsp;
end


local function AddItemEsp(Object: Instance, Name: string)
    RemoveItemEsp(Object)

    local CreateItemEsp = {
        TopText = NewInstance('Draw', 'Text', {
            Center = true,
            Outline = true,
            Color = Colors.ScriptColor,
            OutlineColor = Color3.new(0, 0, 0),
            Font = Drawing.Fonts.Monospace;
            Size = 12,
            ZIndex = 3,
            Transparency = 1,
        }),

        Tracer = NewInstance('Draw', 'Line', {
            Transparency = 1,
            Thickness = Select.DrawingThickness.Value,
            Color = Colors.ScriptColor,
            ZIndex = 2,
        }),

        OutlineTracer = NewInstance('Draw', 'Line', {
            Transparency = 1,
            Thickness = Select.DrawingThickness.Value,
        }),

        Title = Name
    }

    ItemEspConfig[Object] = CreateItemEsp

    Object.Destroying:Once(function()
        RemoveItemEsp(Object)
    end)
end


local function UpdateItemEsp()
    local function SetVisible(Property: Instance, State: boolean)
        Property.Tracer.Visible = State;
        Property.TopText.Visible = State;
        Property.OutlineTracer.Visible = State;
    end

    for Property, Index in next, ItemEspConfig do
        local Object = Property
        local NotInBlacklist = true

        for ItemName in pairs(Select.ItemEspItems.Value) do
            if ItemName == Index.Title then
                NotInBlacklist = false
                break
            end
        end

        if Boolean.ItemEsp.Value and NotInBlacklist and Object then
            local ObjectPosition, OnScreen = Camera:WorldToViewportPoint(Object.Position)

            Index.Tracer.Thickness = Select.DrawingThickness.Value
            Index.OutlineTracer.Thickness = Select.DrawingThickness.Value + 3

            Index.TopText.Font = Drawing.Fonts[Select.EspFont.Value]
            Index.TopText.Size = NoScale(12, Object)

            Index.Tracer.Visible = Boolean.ItemTracers.Value
            Index.OutlineTracer.Visible = Boolean.ItemTracers.Value

            if OnScreen then
                Index.TopText.Text = Index.Title .. ' [' .. StudDistance(Object) .. ']'
                Index.TopText.Visible = true

                Index.Tracer.From = SnaplineMethod
                Index.Tracer.To = Vector2.new(ObjectPosition.X, ObjectPosition.Y)

                Index.OutlineTracer.From = SnaplineMethod
                Index.OutlineTracer.To = Vector2.new(ObjectPosition.X, ObjectPosition.Y)

                Index.TopText.Position =
                    Vector2.new(ObjectPosition.X, ObjectPosition.Y - NoScale(12, Object))
            else
                SetVisible(Index, false)
            end
        else
            SetVisible(Index, false)
        end
    end
end


local function UpdateEsp()
    local function SetVisible(Property: Instance, State: boolean)
        Property.Tracer.Visible = State;
        Property.OutlineTracer.Visible = State;

        Property.HealthBar.Visible = State;
        Property.HealthBarOutline.Visible = State;

        Property.Box.Visible = State;
        Property.BoxOutline.Visible = State;

        Property.TopText.Visible = State;
        Property.BottomText.Visible = State;
        Property.SideText.Visible = State;

        Property.Chams.Enabled = State;
    end

    for Property, Index in next, EspConfig do
        local Player = Property and Property.Character -- I should take the time to rename this for readability
        local UserId = Property and Property.UserId;

        local Creator = Utils.CreatorCheck(UserId)
        local Moderator = Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Property)
        local KosCheck = Boolean.KosCheck.Value and Utils.KosCheck(UserId)

        local EspHumanoid = Player and Player:FindFirstChildOfClass('Humanoid')
        local EspHead = Player and Player:FindFirstChild('Head')
        local EspRoot = Player and Player:FindFirstChild('HumanoidRootPart') or (EspHumanoid and EspHumanoid.RootPart)

        if not EspHumanoid or not EspHead or not EspRoot or EspHumanoid.Health <= 0 then
            SetVisible(Index, false)

            continue
        end

        if Boolean.Esp.Value and Player and EspHumanoid and EspHead then
            local Orientation, Size = Player:GetBoundingBox();

            local TopPosition = Orientation.Position + Vector3.new(0, Size.Y / 2, 0)
            local BottomPosition = Orientation.Position - Vector3.new(0, Size.Y / 2, 0)

            local TopPos = Camera:WorldToViewportPoint(TopPosition)
            local BottomPos = Camera:WorldToViewportPoint(BottomPosition)
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Orientation.Position)

            local Height = math.abs(TopPos.Y - BottomPos.Y)
            local Width = Height / 1.6
            local BoxPos = Vector2.new(ScreenPos.X - Width / 2, ScreenPos.Y - Height / 2)

            local Raycast = Utils.WallCheck(Body, Player, EspHead)

            if Creator then
                Index.Box.Color = CycleHSV
                Index.Tracer.Color = CycleHSV
                Index.Chams.FillColor = CycleHSV

            elseif Moderator then
                Index.Box.Color = Select.Colors.ModeratorColor.Value
                Index.Tracer.Color = Select.Colors.ModeratorColor.Value
                Index.Chams.FillColor = Select.Colors.ModeratorColor.Value

            elseif KosCheck then
                Index.Box.Color = Select.KosColor.Value
                Index.Tracer.Color = Select.KosColor.Value
                Index.Chams.FillColor = Select.KosColor.Value

            elseif Boolean.HitCheck.Value and StudDistance(EspHead) >= 156 then
                Index.Box.Color = Select.HitCheckColor.Value
                Index.Tracer.Color = Select.HitCheckColor.Value
                Index.Chams.FillColor = Select.HitCheckColor.Value
                
            elseif Boolean.EspTargetColor.Value and AimlockTarget == Property then
                Index.Box.Color = Select.TargetColorPicker.Value
                Index.Tracer.Color = Select.TargetColorPicker.Value
                Index.Chams.FillColor = Select.TargetColorPicker.Value

            else
                Index.Box.Color = Colors.ScriptColor
                Index.Tracer.Color = Colors.ScriptColor
                Index.Chams.FillColor = Colors.ScriptColor
            end

            Index.Box.Thickness = Select.DrawingThickness.Value;
            Index.Tracer.Thickness = Select.DrawingThickness.Value;
            Index.HealthBar.Thickness = Select.DrawingThickness.Value;
            Index.BoxOutline.Thickness = Select.DrawingThickness.Value + 2;
            Index.OutlineTracer.Thickness = Select.DrawingThickness.Value + 3;
            Index.HealthBarOutline.Thickness = Select.DrawingThickness.Value;

            Index.TopText.Font = Drawing.Fonts[Select.EspFont.Value];
            Index.SideText.Font = Drawing.Fonts[Select.EspFont.Value];
            Index.BottomText.Font = Drawing.Fonts[Select.EspFont.Value];

            EspHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            
            if OnScreen and Select.StudDistance.Value >= StudDistance(EspHead) then
                Index.TopText.Text = string.format('%s [%s]', Property.DisplayName, StudDistance(EspHead))

                if KosCheck then
                    Index.TopText.Text = string.format('%s [%s] Level: %s', Property.DisplayName, StudDistance(EspHead), Utils.Kos()[UserId].Level)
                end

                if Creator then
                    Index.TopText.Text = string.format('DEVELOPER: %s [%s]', Property.DisplayName, StudDistance(EspHead))
                end

                Index.SideText.Text = Raycast and '[visible]' or '[not visible]';

                Index.Box.Visible = Boolean.EspBox.Value;
                Index.Tracer.Visible = Boolean.EspSnapline.Value;
                Index.TopText.Visible = Boolean.EspText.Value;
                Index.SideText.Visible = Boolean.EspRaycast.Value;
                Index.HealthBar.Visible = Boolean.EspHealthBar.Value;
                Index.BottomText.Visible = Boolean.EspText.Value;
                Index.BoxOutline.Visible = Boolean.EspBox.Value;
                Index.OutlineTracer.Visible = Boolean.EspSnapline.Value;
                Index.HealthBarOutline.Visible = Boolean.EspHealthBar.Value;

                Index.SideText.Color = Raycast and Color3.fromRGB(0, 225, 0) or Color3.fromRGB(225, 0, 0);
                Index.Chams.OutlineColor = Boolean.ChamsOutline.Value and Select.ChamsOutlineColor.Value or Index.Chams.OutlineColor

                Index.Chams.OutlineTransparency = Boolean.ChamsOutline.Value and 0 or 1

                Index.Chams.Enabled = Boolean.EspChams.Value

                Index.Chams.DepthMode = Select.ChamsDepth.Value == 'Occluded' and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop

                for _, Data in next, Player:GetChildren() do
                    if Data:IsA('Tool') and Boolean.EspTool.Value then

                        Debounce.EspHoldingTool = true;

                        local Ammo = Data and Data:FindFirstChild('Ammo');
                        local Clips = Data and Data:FindFirstChild('Clips');
                        
                        if Ammo or Clips then
                            Index.BottomText.Text = string.format('[tool]: %s \n[clips]: %s\t[ammo]: %s',
                                Data.Name,
                                Clips and Clips.Value or 'n/a',
                                Ammo and Ammo.Value or 'n/a'
                            )

                            Debounce.EspToolHasAmmo = true;
                        else
                            Index.BottomText.Text = string.format('[tool]: %s', Data.Name or 'n/a');
                            Debounce.EspToolHasAmmo = false;
                        end
                    else
                        Index.BottomText.Text = ''
                        Debounce.EspHoldingTool = false;
                    end
                end

                Index.Box.Size = Vector2.new(Width, Height)
                Index.BoxOutline.Size = Vector2.new(Width, Height)

                Index.Box.Position = BoxPos;
                Index.BoxOutline.Position = BoxPos;

                Index.HealthBar.Size = Vector2.new(1, Height * (EspHumanoid.Health / EspHumanoid.MaxHealth))
                Index.HealthBarOutline.Size = Vector2.new(4, Height + 2)

                Index.HealthBar.Position = Vector2.new(BoxPos.X - 5, BottomPos.Y - (Height * (EspHumanoid.Health / EspHumanoid.MaxHealth)))
                Index.HealthBarOutline.Position = Vector2.new(BoxPos.X - 6, BoxPos.Y - 1)

                Index.HealthBar.Color = Color3.fromRGB(255 * (1 - (EspHumanoid.Health / EspHumanoid.MaxHealth)), 255 * (EspHumanoid.Health / EspHumanoid.MaxHealth), 0)

                Index.Tracer.From = SnaplineMethod
                Index.Tracer.To = Vector2.new(BottomPos.X, BottomPos.Y)

                Index.OutlineTracer.From = SnaplineMethod
                Index.OutlineTracer.To = Vector2.new(BottomPos.X, BottomPos.Y)

                Index.TopText.Position = Vector2.new(ScreenPos.X, BoxPos.Y - (NoScale(13, EspHead)));
                Index.BottomText.Position = Vector2.new(ScreenPos.X, BoxPos.Y + Height + 1)

                Index.TopText.Size = NoScale(12, EspHead)
                Index.BottomText.Size = NoScale(12, EspHead)
                Index.SideText.Size = NoScale(12, EspHead)

                if Debounce.EspHoldingTool and not Debounce.EspToolHasAmmo then
                    Index.SideText.Position = Vector2.new(ScreenPos.X, BoxPos.Y + Height + 11.5)

                elseif Debounce.EspHoldingTool and Debounce.EspToolHasAmmo then 
                    Index.SideText.Position = Vector2.new(ScreenPos.X, BoxPos.Y + Height + 25)

                else
                    Index.SideText.Position = Vector2.new(ScreenPos.X, BoxPos.Y + Height + 2.5)
                end
            else
                SetVisible(Index, false)
            end
        else
            SetVisible(Index, false)

            if EspHumanoid then
                EspHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
            end
        end
    end
end


local function Fly()
    local BodyVelocity = Torso:FindFirstChildOfClass('BodyVelocity')
    local AlignOrientation = Torso:FindFirstChildOfClass('AlignOrientation')
    local Float = Body:FindFirstChild('Float')
    local Att0 = Torso:FindFirstChild('Att0')
    local Att1 = Torso:FindFirstChild('Att1')

    if Boolean.Flying.Value 
        and not AlignOrientation 
        and not BodyVelocity 
        and not Float 
        and not Att0
        and not Att1 then
            
        repeat task.wait() until Torso and Humanoid

        if Boolean.LoopBlink.Value then
            Debounce.HadLoopBlinkOn = true;
            Boolean.LoopBlink.Value = false;
        end

        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        Humanoid:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)

        local FloatPart = NewInstance('Instance', 'Part', {
            Name = 'Float';
            Transparency = 1;
            Size = Vector3.new(100, 1, 100); -- Fuck it we ball
            Anchored = true;
            Parent = Body;
        })

        local Attachment0 = NewInstance('Instance', 'Attachment', {
            Name = 'Att0';
            Parent = Torso;
        })

        local Attachment1 = NewInstance('Instance', 'Attachment', {
            Name = 'Att1';
            Parent = Torso;
        })

        local AlignOrientation = NewInstance('Instance', 'AlignOrientation', {
            Name = 'AlignOrientation';
            Parent = Torso;
            Responsiveness = 200;
            MaxTorque = 10000;
            Attachment0 = Attachment0;
            Attachment1 = Attachment1;
            RigidityEnabled = false;
            MaxAngularVelocity = 9e9;
        })

        local FlightVelocity = NewInstance('Instance', 'BodyVelocity', {
            Name = 'BodyVelocity';
            P = 9e9;
            MaxForce = Vector3.new(9e9, 9e9, 9e9);
            Parent = Torso;
        })

        getgenv().UpdateFly = function()
            local FlySpeed = (Select.FlySpeed.Value or 4) * 25;

            local YAxis = math.atan2(-Camera.CFrame.LookVector.X, -Camera.CFrame.LookVector.Z)
            local TorsoAngles = CFrame.new(Torso.Position) * CFrame.Angles(0, YAxis, 0);
            local FlyVelocity = -Vector3.yAxis
            
            Humanoid.PlatformStand = false;
            FloatPart.CFrame = Torso.CFrame * CFrame.new(0,-3.5,0)

            if Movement.W then FlyVelocity += Camera.CFrame.LookVector * FlySpeed end
            if Movement.A then FlyVelocity += Camera.CFrame.RightVector * -FlySpeed end
            if Movement.S then FlyVelocity += Camera.CFrame.LookVector * -FlySpeed end
            if Movement.D then FlyVelocity += Camera.CFrame.RightVector * FlySpeed end

            if not (Movement.W or Movement.A or Movement.S or Movement.D) then
                FlyVelocity = Vector3.zero
            end

            FlightVelocity.Velocity = FlyVelocity
            Attachment1.CFrame = TorsoAngles:ToObjectSpace(FloatPart.CFrame)

            if Utils.UserInputService:IsKeyDown(Enum.KeyCode.Space) and not Debounce.Typing then
                Torso.CFrame += Vector3.new(0, 0.2, 0)
            end
        end
    end
end


local function KillFly()
    if not (Torso or Humanoid) then return end

    local BodyVelocity = Torso and Torso:FindFirstChildOfClass('BodyVelocity')
    local AlignOrientation = Torso and Torso:FindFirstChildOfClass('AlignOrientation')
    local Float = Body and Body:FindFirstChild('Float')
    local Att0 = Torso and Torso:FindFirstChild('Att0')
    local Att1 = Torso and Torso:FindFirstChild('Att1')
    
    if not (BodyVelocity or AlignOrientation or Att0 or Att1 or Float) then 
        return 
    end
    
    if Debounce.HadLoopBlinkOn then 
        Debounce.HadLoopBlinkOn = false;
        Boolean.LoopBlink.Value = true;
    end

    Humanoid:ChangeState(Enum.HumanoidStateType.Running)

    BodyVelocity.Parent = nil;
    AlignOrientation.Parent = nil;
    Att0.Parent = nil;
    Att1.Parent = nil;
    Float.Parent = nil;
end


local function Airwalk()
    if not Boolean.Airwalk.Value then return end
    if Body:FindFirstChild('Airwalk') then return end

    local AirwalkPart = NewInstance('Instance', 'Part', {
        Name = 'Airwalk';
        Transparency = 1;
        Size = Vector3.new(5, 1, 5);
        Anchored = true;
        Parent = Body;
        Massless = true;
    })
end


local function KillAirwalk()
    if Boolean.Airwalk.Value then return end

    local AirwalkPart = Body:FindFirstChild('Airwalk')
    if not AirwalkPart then return end

    AirwalkPart.Parent = nil
end


local function NoclipAddons(State: boolean)
    Debounce.SetNoclip = not State

    if Debounce.ItemsProcessed then
        for _, Index in next, WhitelistedItems do
            if not Index then return end

            Hash.LocalizeItem = WhitelistedItems[Index.Name]
            
            for _, Values in next, Hash.LocalizeItem:GetDescendants() do
                if Values and Values:IsA('BasePart') then
                    Values.CanCollide = Debounce.SetNoclip
                end
            end

            if Host and Host:GetAttribute('Dead') then
                WhitelistedItems[Index] = nil;
            end
        end
    end

    for _, Index in next, Body:GetDescendants() do -- goah
        if not Index then return end

        if Index.Name == 'KnuxRightPart' or Index.Name == 'KnuxLeftPart' then
            Index.CanCollide = Debounce.SetNoclip
        end

        if Index.Name == 'Baseball' then
            for _, Values in next, Index:GetDescendants() do

                if Values:IsA('BasePart') then
                    Values.CanCollide = Debounce.SetNoclip
                end
            end
        end

        if Index.Name == 'Handle' and Index:FindFirstChildOfClass('MeshPart') then -- Katana
            Index.CanCollide = Debounce.SetNoclip
        end
    end
end


local function TeleportTo(Position: CFrame, Delay: number)
    if not (Root and Utils.TweenService) then return end

    local Info = TweenInfo.new(Delay or Select.TeleportDelay.Value, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
    local TweenCreate = Utils.TweenService:Create(Root, Info, {CFrame = Position * Root.CFrame.Rotation + Vector3.new(0, 3, 0)})

    Debounce.TeleportCompleted = false
    Debounce.NoClip = false;

    if not Boolean.NoClip.Value then
        Boolean.NoClip.Value = true;
        NoclipAddons(true)
    else
        Debounce.NoClip = true;
    end

    TweenCreate.Completed:Connect(function()
        Debounce.TeleportCompleted = true

        if not Debounce.NoClip then
            Boolean.NoClip.Value = false;
            NoclipAddons(false)
        end
    end)

    TweenCreate:Play()
end


local function FindPartsOnMap(Index: Instance)
    if not Index then return end

    for _, Values in next, Index:GetDescendants() do
        if not Values then return end

        if Values:IsA('MeshPart') and not Index:GetAttribute('Labeled') then
            local MeshId = Items.MeshIds[Values.MeshId];
            local TextureId = Items.TextureIds[Values.TextureID]

            if MeshId then 
                Index:SetAttribute('Labeled', true)
                AddItemEsp(Values, MeshId.Name)
            end

            if TextureId then
                Index:SetAttribute('Labeled', true)
                AddItemEsp(Values, TextureId.Name)
            end
        end

        if Values:IsA('Part') then
            if Values.Color == Color3.fromRGB(17, 17, 17) then
                if Values:FindFirstChild('Barrel') then
                    AddItemEsp(Values, 'Sawed Off')
                end

                if Utils.Prison and Values:FindFirstChild('Eject') then
                    AddItemEsp(Values, 'Uzi')
                end
            end

            if Values.Color == Color3.fromRGB(150, 85, 85) and Values.Material == Enum.Material.Concrete then
                AddItemEsp(Values, 'Brick')
            end
        end
    end
end


local function GameData()
    for _, Index in next, Utils.Workspace:GetDescendants() do
        if Index:IsA('Seat') then
            table.insert(Seats, Index);
        end

        if Index:IsA('VehicleSeat') then
            table.insert(VehicleSeats, Index);
        end

        if Index:IsA('Part') and Index.Material == Enum.Material.Neon then
            table.insert(Lights, Index)

            if Index.Color == Color3.fromRGB(255, 0, 191) and Index.Name == 'RandomSpawner' then
                FindPartsOnMap(Index)

                InsertItem(Items, Index)
            end
        end

        if Index:IsA('SpotLight') then
            table.insert(Lights, Index)
        end

        if Index:IsA('PointLight') then
            if Index.Range == math.clamp(Index.Range, 16, 30) then
                table.insert(Lights, Index)
            end

            if Index.Range == math.clamp(Index.Range, 6, 12) then
                table.insert(Pumpkins, Index)
            end
        end
    end
end


local function SetInfinityZoom(State: boolean)
    if Host then
        Host.CameraMaxZoomDistance = (State and math.huge) or Originals.Zoom
    end
end


local function SetInfiniteJump(State: boolean)
    local JumpRequest = Utils.UserInputService and Utils.UserInputService.JumpRequest;

    if not JumpRequest then
        return
    end

    if State and Humanoid and not JumpConnection then
        JumpConnection = Utils.UserInputService.JumpRequest:Connect(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end

    if not State and JumpConnection then
        JumpConnection:Disconnect()
        JumpConnection = nil
    end
end


local function UpdateBulletCounterPositions()
    if not Weapon or not Weapon.Handle then
        return
    end

    ClipsText.Position = UDim2.fromScale(0, 0.5);

    if Utils.Streets then
        if CurrentAmmo then
            CurrentAmmo.Visible = false;
        end

        GunInfoBillboard.Parent = Weapon.Handle;
        GunInfoBillboard.StudsOffset = Vector3.new(3.2, 0.5, 1.5);

        OtherAmmo.Position = UDim2.fromScale(0.3, 0.875);
        OtherClip.Position = UDim2.fromScale(0.6, 0.875);
    end

    if Debounce.FirstPerson then
        ClipsText.Position = UDim2.fromScale(0, 0.1);

        if Utils.Streets then
            GunInfoBillboard.StudsOffset = Vector3.new(3.5, 0.2, 0);
        end
    end
end


local function UpdateBulletCounterVisible(State: boolean, State2: boolean)
    AmmoText.Visible = State;
    ClipsText.Visible = State;

    OtherClip.Visible = State2;
    OtherAmmo.Visible = State2;
end


local function UpdateBulletCounter()
    if not Weapon or not Weapon.Tool or not Weapon.Clips then 
        return
    end

    local Ammo = Weapon.Ammo;
    local Name = Weapon.Tool.Name;
    local Clips = Weapon.Clips;
    local Barrel = Weapon.Barrel;
    local MaxAmmo = (Utils.Streets and Weapon.MaxAmmo);

    if GunInfoBillboard.Parent ~= Barrel then
        GunInfoBillboard.Parent = Barrel;
    end

    AmmoText.TextColor3 = Colors.ScriptColor;
    ClipsText.TextColor3 = Colors.ScriptColor;
    OtherClip.TextColor3 = Colors.ScriptColor;
    OtherAmmo.TextColor3 = Colors.ScriptColor;

    AmmoText.Text = '[Ammo]: ' .. (Ammo and Ammo.Value or 0)
    ClipsText.Text = '[Clips]: ' .. (Clips and Clips.Value or 0)

    OtherAmmo.Text = '[Ammo]: ' .. (Ammo and Ammo.Value or 0)
    OtherClip.Text = '[Clips]: ' .. (Clips and Clips.Value or 0)

    if Boolean.LowAmmoIndicator.Value then
        local Threshold = 2;

        if Utils.Streets and MaxAmmo and MaxAmmo.Value == 30 then
            Threshold = 6;
        end

        if Name == 'Sawed off' or Name == 'Sawed Off' then
            Threshold = 1
        end

        if Name and Name == 'Uzi' then
            Threshold = 4
        end

        if Clips.Value <= 1 then
            ClipsText.TextColor3 = Color3.fromRGB(190, 0, 0)
            OtherClip.TextColor3 = Color3.fromRGB(190, 0, 0);
        end

        if Ammo.Value <= Threshold then
            AmmoText.TextColor3 = Color3.fromRGB(190, 0, 0);
            OtherAmmo.TextColor3 = Color3.fromRGB(190, 0, 0);
        end
    end
end


local function TypeCheckTool(Object: Instance)
    if Object and Object:IsA('Tool') or Object.Name == 'Baseball' or (Object:IsA('BasePart') and Object.Name == 'Handle') then

        if Object.Name == 'Road Sign' then
            return
        end

        return Object
    end

    return
end


local function FindTool(Object: Instance)
    if Object and TypeCheckTool(Object) and not Utils.CollectionService:HasTag(Object, TagTools) then
        Utils.CollectionService:AddTag(Object, TagTools)
    end
end


local function OnEquipped(Tool: Instance) : table
    if not Tool then return end

    return {
        Tool = Tool,
        Ammo = Tool and Tool:FindFirstChild('Ammo') or nil,
        Clips = Tool and Tool:FindFirstChild('Clips') or nil,
        Handle = Tool and Tool:FindFirstChild('Handle') or nil,
        Barrel = Tool and Tool:FindFirstChild('Barrel') or nil,
        MaxAmmo = Tool and Tool:FindFirstChild('MaxAmmo') or nil,
    }
end


local function InitializeTool(Tool: Instance)
    if not Tool or Tool:GetAttribute('Initialized') then return end

    Tool:SetAttribute('Initialize', true)

    Tool.Equipped:Connect(function()
        Weapon = OnEquipped(Tool)

        UpdateBulletCounterVisible(false, false);

        if Weapon and Weapon.Ammo then
            Hash.FromScreen = Select.BulletCounter.Value == 'From Screen';
            Hash.FromGun = Select.BulletCounter.Value == 'From Gun';

            UpdateBulletCounterVisible(Hash.FromGun, Hash.FromScreen);
        end

        Host:SetAttribute('HoldingTool', true)
    end)

    Tool.Unequipped:Connect(function()
        Weapon = nil

        UpdateBulletCounterVisible(false, false);
        Host:SetAttribute('HoldingTool', false)
    end)
end


local function OnGradient(Lerp: number) : ColorSequence
    local Key = math.floor(Lerp * 100)

    local Cached = GradientCache[Key]
    if Cached then return Cached end -- Searches if Gradient is cached, prevents caching on each frame

    Cached = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.MouseColorOffTint:Lerp(Colors.MouseColorOnTint, Lerp)),
        ColorSequenceKeypoint.new(0.3, Colors.MouseColorOff:Lerp(Colors.MouseColorOn, Lerp)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(225,225,225))
    }

    GradientCache[Key] = Cached
    return Cached
end


local function UpdateInfoCursor()
    if not Mouse or not Mouse.Target or not Mouse.Target.Parent then return end

    Lerping += Speed

    if Lerping > 1 then
        Lerping = 0;
    end

    local MouseTarget = Mouse and Mouse.Target;
    local MouseParent = MouseTarget and MouseTarget.Parent;
    local MouseName = MouseParent and tostring(MouseParent.Name);

    if not Boolean.CursorInfo.Value then
        InfoCursor.Visible = false
    end
    
    if MouseTarget then
        Hash.Head = MouseParent and Utils.Head(MouseParent);
        Hash.Humanoid = MouseParent and Utils.Humanoid(MouseParent);
        Hash.Root = MouseParent and Utils.Root(MouseParent);
        Hash.BodyColors = MouseParent and MouseParent:FindFirstChild('Body Colors'); -- For those grey lifeless bodies at spawns

        if not (Hash.Head and Hash.Humanoid and Hash.Root) or MouseName == Host.Name then
            UIGradientStroke.Color = OffGradient
            UIGradientInner.Color = OffGradient

            if Boolean.CursorInfo.Value then
                InfoCursor.Visible = false
            end

            return
        end

        if Utils.Streets and (MouseName == 'Spedsshed' or MouseName == 'Afro' or not Hash.BodyColors) then
            return
        end

        if Hash.Head or Hash.Humanoid or Hash.Root then
            Hash.Player = MouseName and Utils.Players[MouseName];
        end

        local _Head = Hash.Head or (MouseParent and Utils.Head(MouseParent));
        local _Humanoid = Hash.Humanoid or (MouseParent and Utils.Humanoid(MouseParent));
        local _Player = Hash.Player or (Utils.Players and MouseName and Utils.Players[MouseName]);

        local _Tool;
        local Gradient = OnGradient(Lerping);

        UIGradientInner.Color = Gradient;
        UIGradientStroke.Color = Gradient;

        if Boolean.CursorInfo.Value then
            InfoCursor.Visible = true;
        end

        if _Player and _Head and _Humanoid then
            for _, Index in next, _Player:GetChildren() do
                if Index:IsA('Tool') then
                    _Tool = Index;
                    
                    break
                end
            end

        -- [] Inilatize Text

            local Ammo = _Tool and _Tool:FindFirstChild('Ammo');
            local Clips = _Tool and _Tool:FindFirstChild('Clips');

            local StudFinder = StudDistance(Head, _Head);
            local Keybind = Utils.UserInputService:IsKeyDown(Enum.KeyCode[Select.AdvCursorInfo.Value]);
            local Health = math.round(_Humanoid.Health);
            local Age = string.format('%.2f', _Player.AccountAge / 365.25)

            local Text = string.format('%s\nStuds: %s\nHealth: %s\nTool: %s', MouseName, StudFinder, Health, (_Tool and _Tool.Name) or 'None')

            if Utils.Streets then
                Hash.Cred = 'Cred: ' .. _Player.leaderstats:FindFirstChild('Cred').Value
                
            elseif Utils.Prison then
                Hash.Cred = 'Stomps: ' .. _Player.leaderstats:FindFirstChild('Stomps').Value
            end

            if _Tool and Ammo and Clips then
                Text ..= string.format(' ( Clips: %s  Ammo: %s )', Clips.Value, Ammo.Value)
            end

            if not Keybind then
                Text ..= '\nMore Info..';
            else
                Text ..= string.format('\nAge: %s\n%s', Age, Hash.Cred or '');
            end 

            InfoCursor.Text = Text or ''
        end
    end

    InfoCursor.Position = UDim2.fromOffset(MousePosition.X + 40, MousePosition.Y - 24.5)
end


local function BulletColors(Object: Instance)
    if not Boolean.Trails.Value then return end
    if not Object or not Object:IsA('Trail') then return end

    local Color;
    local TrailClone = Object:Clone();

    TrailClone.Parent = Object.Parent;

    TrailClone.Texture = 'rbxassetid://8522442091'; -- Creds to DranghetaLurk, I used your texture
    TrailClone.Transparency = NumberSequence.new(0);
    TrailClone.Lifetime = Select.TrailLifetime.Value;
    TrailClone.TextureMode = Enum.TextureMode.Wrap;
    TrailClone.TextureLength = 5;
    TrailClone.MaxLength = 9e9;
    TrailClone.LightEmission = 1;
    TrailClone.LightInfluence = 0;
    TrailClone.FaceCamera = true;
    TrailClone.Brightness = Select.TrailBrightness.Value;
    --TrailClone.WidthScale = NumberSequence.new(0, 1);

    if Boolean.TrailRainbow.Value then
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, CycleHSV), 
            ColorSequenceKeypoint.new(1.00, CycleHSV)
        }

    elseif Boolean.TrailColorOne.Value and not Boolean.TrailColorTwo.Value and not Boolean.TrailRainbow.Value then
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Select.TrailColors1.Value), 
            ColorSequenceKeypoint.new(1.00, Select.TrailColors1.Value)
        }

    elseif Boolean.TrailColorOne.Value and Boolean.TrailColorTwo.Value and not Boolean.TrailRainbow.Value then
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Select.TrailColors1.Value), 
            ColorSequenceKeypoint.new(1.00, Select.TrailColors2.Value)
        }
    else
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(225, 225, 225)), 
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(225, 225, 225))
        }
    end

    TrailClone.Color = Color;
end


local function DebounceFunc(Name: string, IsDelay: boolean, Delay: number, Callback: (...any) -> (), Callback2: (...any) -> ()) : (...any) -> ()
    Callback = Callback or function() end
    Callback2 = Callback2 or function() end;
    Debounce[Name] = false;
    
    return function(...)
        if Debounce[Name] then return end

        Debounce[Name] = true;
        task.spawn(Callback, ...)
        task.spawn(Callback2, ...)

        if not IsDelay then
            Debounce[Name] = false;
        else
            task.delay(Delay, function()
                Debounce[Name] = false;
            end)
        end
    end
end


local function Boombox(Object: Instance)
    if not Object then return end

    local FindReverb = Object and Object:FindFirstChild('Reverb');
    local FindChorus = Object and Object:FindFirstChild('Chorus');
    local FindDistortion = Object and Object:FindFirstChild('Distortion');

    if (FindReverb or FindChorus or FindDistortion) then return end

    local Reverb = NewInstance('Instance', 'ReverbSoundEffect', { 
        Name = 'Reverb';
        Parent = Object;
        Enabled = Boolean.Reverb.Value;
    })

    local Distortion = NewInstance('Instance', 'DistortionSoundEffect', {
        Name = 'Distortion';
        Parent = Object;
        Level = 0;
        Enabled = Boolean.Distortion.Value;
    })

    local Chorus = NewInstance('Instance', 'ChorusSoundEffect', {
        Name = 'Chorus';
        Parent = Object;
        Enabled = Boolean.Chorus.Value;
    })
end


local function FindPlayersPart(Player: Player, Type: string, Part: string, Descendants: boolean) : Instance? -- // Should probably delete this
    local GrabPlayer = Player and Player.Character;

    if not GrabPlayer then
        return
    end

    if Type == 'Wait' or Type == 'wait' then
        return GrabPlayer:WaitForChild(Part)

    elseif Type == 'Find' or Type == 'find' then

        return GrabPlayer:FindFirstChild(Part, Descendants)
    elseif Type == 'Class' or Type == 'class' then

        return GrabPlayer:FindFirstChildOfClass(Part)
    else

        return GrabPlayer
    end

    Logger:Cout(debug.traceback())
end


function TeleportBypass()
end


local function FindRound(Object: Instance)
    if Object and Object.Name == 'Trail' and not Utils.CollectionService:HasTag(Object, TagTrails) then
        Utils.CollectionService:AddTag(Object, TagTrails)
    end
end


local function FindBoomboxes(Object: Instance)
    if Object and Object:IsA('Sound') and Object.Name == 'SoundX' then
        Boomboxes[Object.Name] = Object
        Utils.CollectionService:AddTag(Object, TagBoomboxes)
    end
end


local function ItemColors(Object: Instance)
    if not Boolean.ItemColors.Value or not Object or not TypeCheckTool(Object) then return end

    local Handle = Object and Object:FindFirstChild('Handle')
    local Pattern;

    local Patterns = {
        None = nil,
        Opium = 'rbxassetid://4504367541',
        Hex = 'rbxassetid://130475437036776',
        Distorted = 'rbxassetid://4504363124',
        Tracer = 'rbxassetid://127951277206835',
        Framework = 'rbxassetid://129400613975716',
        Custom = tostring(Select.ItemCustomPattern.Value),
    }

    Pattern = Patterns[Select.ItemPattern.Value]

    if Handle then
        if Handle:FindFirstChildOfClass('SurfaceAppearance') then
            Handle.SurfaceAppearance.Parent = nil
        end
    end

    for _, Index in next, Object:GetDescendants() do
        if Index and Index:IsA('BasePart') then

            if Index:IsA('UnionOperation') then
                Index.UsePartColor = true
            end

            if Index:IsA('MeshPart') then
                Index.TextureID = Pattern
            end

            Index.Material = Select.ItemMaterial.Value;
            table.insert(ProcessedItems, Index)
        end
    end
end


local function BoomboxEffects()
    if not Boomboxes or not next(Boomboxes) then
        return
    end

    for _, Index in next, Boomboxes do
        local SelectedBoombox = Index and Boomboxes[Index.Name]

        if not SelectedBoombox then
            return
        end

        local Chorus = SelectedBoombox and SelectedBoombox:FindFirstChild('Chorus')
        local Reverb = SelectedBoombox and SelectedBoombox:FindFirstChild('Reverb')
        local Distortion = SelectedBoombox and SelectedBoombox:FindFirstChild('Distortion')

        SelectedBoombox.Playing = Boolean.MuteBoombox.Value;
        SelectedBoombox.Volume = Select.BoomVolume.Value;
        SelectedBoombox.RollOffMaxDistance = Select.BoomDistance.Value;

        Hash.OwnerBoombox = Hash.OwnerBoombox or (function()
            for _, Index in next, Body:GetDescendants() do
                if Index:IsA('Sound') and Index.Name == 'SoundX' then
                    return Index
                end
            end
        end)()

        if Hash.OwnerBoombox then
            Hash.OwnerBoombox.Playing = Boolean.ExcludeOwner.Value
        end

        if not (Distortion and Reverb and Chorus) then
            return
        end
            
        if Boolean.BoomboxEffects.Value then
            Distortion.Enabled = Boolean.Distortion.Value;
            Distortion.Level = Select.DLevel.Value;

            Chorus.Enabled = Boolean.Chorus.Value;
            Chorus.Mix = Select.CMix.Value;
            Chorus.Depth = Select.CDepth.Value;
            Chorus.Rate = Select.CRate.Value;

            Reverb.Enabled = Boolean.Reverb.Value;
            Reverb.DryLevel = Select.RDryLevel.Value;
            Reverb.WetLevel = Select.RWetLevel.Value;
            Reverb.Density = Select.RDensity.Value;
        end

        if not Boolean.BoomboxEffects.Value then
            Distortion.Enabled = false
            Reverb.Enabled = false
            Chorus.Enabled = false
        end
    end
end


local function SendKnockedAttributes(Player: Player, Character: Model)
    local _Head = Utils.Head(Player)
    if not _Head then return end

    Player:SetAttribute('Knocked', _Head:FindFirstChild('Bone') ~= nil)

    local function PlayerDescendantAdded()
        if _Head:FindFirstChild('Bone') then
            Player:SetAttribute('Knocked', true)
        end
    end

    local function PlayerDescendantRemoving()
        if _Head:FindFirstChild('Bone') then
            Player:SetAttribute('Knocked', false)
        end
    end

    Character.DescendantAdded:Connect(PlayerDescendantAdded)
    Character.DescendantRemoving:Connect(PlayerDescendantRemoving)
end


local function Cash() : number -- Creds to whoever on devforums
    local Cash = CashUi.Text

    if not Cash then
        return
    end

    local CashData = string.gsub(Cash, '%D', '')
    CashData = tonumber(CashData)

    return CashData or 0
end


local function InitializePads() : table -- Creds to Ponyhook for the string.matchs
    local Pads = {};

    for _, Index in next, Utils.Workspace:GetDescendants() do
        local BlacklistedItems = {}

        if Index.Name == 'OldShotty | $600' or Index.Name == 'Sawed Off | $300' or Index.Name == 'Glock | $400' or Index.Name == 'OldGlock | $600' then
            table.insert(BlacklistedItems, Index.Name)
        end

        if Index and string.match(Index.Name, '%a+%s?%a+ | %$%d+') and not table.find(BlacklistedItems, Index.Name) then
            Hash.PadName = Index and string.match(Index.Name, '%a+%s?%a+')
            Hash.GetHead = Index and Index:FindFirstChild('Head'); -- Me when funny name moment
            Hash.HeadData = Hash.GetHead and Hash.GetHead:FindFirstChildOfClass('Folder')

            table.insert(Pads, {
                Name = Hash.PadName;
                Part = Hash.GetHead;
                Price = Hash.GetHead:FindFirstChild('ShopData').Price.Value;
            })
        end
    end

    return Pads
end -- // Public verison, you really can't use this but if you find a way, have at it


local function PurchaseItem(Item: string) : Instance?
    local Distance = math.huge;

    for _, Index in next, InitializePads() do
        if Index.Name == Item then
            local StudFinder = StudDistance(Index.Part)

            if StudFinder < Distance then
                Hash.InitializePad = Index.Name;
                Hash.InitializePart = Index.Part;
                Hash.InitializePrice = Index.Price;
                Distance = StudFinder;
            end
        end
    end

    if Cash() < Hash.InitializePrice or not (Body or Host:GetAttribute('Dead')) then
        Notify('Buy Item', '[Error]: Insignificant Cash')

        return Root.CFrame
    end

    return Hash.InitializePart
end


local function AutoHeal()
    if not Utils.Streets or not Body or not Root or not Humanoid or not Boolean.Autoheal.Value then return end

    local SaveOldPos = Root.CFrame;
    local Health = Humanoid.Health;

    Boolean.InstantPrompts.Value = true;

    if Weapon or Host:GetAttribute('HoldingTool') then
        Humanoid:UnequipTools()
    end

    local BuyFood = PurchaseItem('Taco') or PurchaseItem('Chicken')

    if BuyFood and BuyFood.CFrame then
        TeleportTo(BuyFood.CFrame)
    end

    local Proxy = Hash.InitializePart:FindFirstChildOfClass('ProximityPrompt')
    if not Proxy then return end

    repeat
        task.wait(0.5)
        fireproximityprompt(Proxy)
        task.wait(1.5);

        local Tool = Backpack and Backpack:FindFirstChild('Taco')
        if not Tool then return end

        Humanoid:EquipTool(Tool)
        Tool:Activate()
        Tool.Parent = Host.Backpack

        Health = Humanoid.Health;
    until Health <= 90 or Host:GetAttribute('Dead');

    TeleportTo(SaveOldPos)
    Boolean.InstantPrompts.Value = false
end


local function VelocityType(...) : Vector3?
    local Arguments = {...}
    local VelocitySet = {}

    do
        VelocitySet.Value = Arguments[1];
        VelocitySet.Part = Arguments[2];
        VelocitySet.Velocity = Arguments[3];
    end

    if VelocitySet.Value == 'Velocity' then
        return (VelocitySet.Part.AssemblyLinearVelocity * VelocitySet.Velocity);
    end

    if VelocitySet.Value == 'RotVelocity' then
        return (VelocitySet.Part.AssemblyAngularVelocity * VelocitySet.Velocity);
    end

    if VelocitySet.Value == 'MoveDirection' then
        return (VelocitySet.Part.MoveDirection * VelocitySet.Velocity);
    end

    return Vector3.zero
end


local function OnRenderStepped(Delta: number)
    local HostTorsoToWorld = Camera:WorldToViewportPoint(Torso.Position);

    local CountTicks = os.clock() * ((Boolean.ToolRainbow.Value and Select.RainbowSpeed.Value) or 0.3)
    CycleHSV = Color3.fromHSV(CountTicks % 1, 1, 1) -- Thanks to devforums

    MousePosition = Utils.UserInputService and Utils.UserInputService:GetMouseLocation()

    LogoFirst.Position = UDim2.fromOffset(MousePosition.X - 85, MousePosition.Y + 40);
    LogoSecond.Position = UDim2.fromOffset(MousePosition.X + 15, MousePosition.Y + 40);
    CursorImage.Position = UDim2.fromOffset(MousePosition.X, MousePosition.Y);
    CircleCursor.Position = UDim2.fromOffset(MousePosition.X, MousePosition.Y);

    CircleInner.Size = UDim2.fromOffset(Select.CursorSize.Value + 10, Select.CursorSize.Value + 10);
    CursorImage.Size = UDim2.fromOffset(Select.CursorSize.Value, Select.CursorSize.Value);
    CircleCursor.Size = UDim2.fromOffset(CursorImage.Size.X.Offset + 10, CursorImage.Size.Y.Offset + 10);

    if Circle then
        Circle.Visible = Boolean.FOVCircle.Value
        Circle.Radius = Select.CircleSize.Value
        Circle.Color = Select.FOVCircleColor.Value
        Circle.Thickness = Select.CircleThickness.Value

        if Boolean.FOVMiddleCircle.Value then
            Circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2);
        else
            Circle.Position = MousePosition 
        end
    end

    if Debounce.ScriptLoaded then
        UpdateBulletCounter();
        UpdateEsp();
        UpdateItemEsp();
        UpdateInfoCursor();
        UpdateBulletCounterPositions();
        BoomboxEffects();

        ColorCorrection.TintColor = Boolean.TintColor.Value and Select.TintColor.Value or ColorCorrection.TintColor;
        Utils.Lighting.Ambient = Boolean.Ambient.Value and Select.AmbientColor.Value or Utils.Lighting.Ambient;
        Utils.Lighting.OutdoorAmbient = Boolean.OutdoorAmbient.Value and Select.OutdoorAmbientColor.Value or Utils.Lighting.OutdoorAmbient;
        Utils.Lighting.FogColor = Boolean.FogColor.Value and Select.FogColor.Value or Utils.Lighting.FogColor;
        Utils.Lighting.Brightness = Boolean.Brightness.Value and Select.Brightness.Value or Utils.Lighting.Brightness;
        Utils.Lighting.ShadowSoftness = Boolean.ShadowSoftness.Value and Select.ShadowSoftness.Value or Utils.Lighting.ShadowSoftness;
        Utils.Lighting.ExposureCompensation = Boolean.Exposure.Value and Select.Exposure.Value or Utils.Lighting.ExposureCompensation;
        Utils.Lighting.FogEnd =  Boolean.FogEnd.Value and Select.FogEnd.Value or Utils.Lighting.FogEnd;
        Utils.Lighting.TimeOfDay = Boolean.Clock.Value and Select.Clock.Value or Utils.Lighting.TimeOfDay;

        Host.CameraMode = Select.POV.Value == 'FirstPerson' and Enum.CameraMode.LockFirstPerson or Host.CameraMode;

        for _, Index in next, Lights do
            if Boolean.LightColoring.Value then
                Index.Color = Select.LightColor.Value
            end
        end
    end

    if Boolean.ItemColors.Value then
        for _, Index in next, ProcessedItems do
            if Index then
                Index.Color = Boolean.ToolRainbow.Value and CycleHSV or Select.ItemColoring.Value;
            end
        end
    end

    if Boolean.Viewing.Value and ViewTarget and FindPlayersPart(ViewTarget) then
        Camera.CameraSubject = FindPlayersPart(ViewTarget, 'Find', 'Head');
    end

    if Boolean.Camlock.Value and CamlockTarget and FindPlayersPart(CamlockTarget) then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, FindPlayersPart(CamlockTarget, 'Find', Select.CamlockPart.Value).CFrame.Position)
    end

    if not Boolean.TintColor.Value and Utils.BothPrisons then
        ColorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
    end

    if Select.SnaplineDirection.Value == 'From Mouse' then
        SnaplineMethod = MousePosition;
    end

    if Select.SnaplineDirection.Value == 'From Screen' then
        SnaplineMethod = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 1)
    end

    if Select.SnaplineDirection.Value == 'From Player' then
        SnaplineMethod = Vector2.new(HostTorsoToWorld.X, HostTorsoToWorld.Y)
    end
end


local function OnHeartbeat(Delta: number)
    Ping = math.round(Utils.Stats:FindFirstChild('PerformanceStats').Ping:GetValue())

    local MoveDirection = (Humanoid and Humanoid.MoveDirection) or Vector3.zero
    Debounce.Typing = Utils.UserInputService and Utils.UserInputService:GetFocusedTextBox() ~= nil

    if Boolean.Flying.Value then
        UpdateFly();
    end

    if Utils.Streets then
        NoclipAddons(Boolean.NoClip.Value); -- // This was a pain
    end

    if Boolean.NoClip.Value and Torso and Head then
        Torso.CanCollide = false; 
        Head.CanCollide = false;

        if Utils.BothPrisons and (Body:FindFirstChild('Uzi') or Body:FindFirstChild('Glock')) then
            Body:FindFirstChild('Barrel', true).CanCollide = false;
        end
    else
        Torso.CanCollide = true;
        Head.CanCollide = true;

        if Utils.BothPrisons and (Body:FindFirstChild('Uzi') or Body:FindFirstChild('Glock')) then
            Body:FindFirstChild('Barrel', true).CanCollide = false;
        end
    end

    if Boolean.Airwalk.Value then
        local AirwalkPart = Body:FindFirstChild('Airwalk')

        if AirwalkPart and Root then
            AirwalkPart.CFrame = CFrame.new(Root.Position + Vector3.new(0, -3.5, 0))
        end
    end

    if Boolean.Blink.Value and (Debounce.Blink or Boolean.LoopBlink.Value) then
        local BlinkSpeed = Select.BlinkSpeed.Value / 6.5

        if Select.BlinkMethod.Value == 'Movedirection' and MoveDirection then
            Root.CFrame += Vector3.new(MoveDirection.X * BlinkSpeed, 0, MoveDirection.Z * BlinkSpeed)
        end

        if Select.BlinkMethod.Value == 'Cframe' and Root then
            local XAxis = (Movement.D and 1 or 0) - (Movement.A and 1 or 0)
            local ZAxis = (Movement.S and 1 or 0) - (Movement.W and 1 or 0)
            local Offset = Vector3.new(XAxis, 0, ZAxis);

            if Offset.Magnitude > 0 then
                Offset = Offset.Unit * BlinkSpeed
                Root.CFrame *= CFrame.new(Offset)
            end
        end

        if Select.BlinkMethod.Value == 'Lookvector' and Root then
            Root.AssemblyLinearVelocity = Root.CFrame.LookVector * (Select.BlinkSpeed.Value * 25)
        end
    end

    if Utils.Remake and Boolean.InfiniteStam.Value then
        Host:SetAttribute('Stamina', 100);
    end
end


local function AimlockConfig(Method: string, IsPonyhook: boolean, IsCyrus: boolean) : CFrame
    local SetAimlockTarget = Utils.Players[AimlockTarget.Name];
    local SetAimlockVelocity = Select.AimlockVelocity.Value or Ping

    if SetAimlockTarget then
        local AimlockCharacter = SetAimlockTarget and SetAimlockTarget.Character or SetAimlockTarget.CharacterAdded:Wait() -- eh?

        local AimlockedTarget = {
            Head = AimlockCharacter.FindFirstChild(AimlockCharacter, 'Head');
            Humanoid = AimlockCharacter.FindFirstChildOfClass(AimlockCharacter, 'Humanoid');
            Torso = AimlockCharacter.FindFirstChild(AimlockCharacter, 'Torso');

            StringPart = AimlockCharacter.FindFirstChild(AimlockCharacter, Select.AimlockPart.Value);
        }

        local SetHitBox = AimlockedTarget.StringPart or AimlockedTarget.Head;

        if Method == 'Cyrus' then
            local IsRotVelocity = 1;

            if IsCyrus then
                IsRotVelocity = VelocityType('RotVelocity', SetHitBox, SetAimlockVelocity);
            end

            return SetHitBox.CFrame + Vector3.new(VelocityType('Velocity', SetHitBox, SetAimlockVelocity) / IsRotVelocity)
        end

        if Method == 'Movedirection' then
            return SetHitBox.CFrame + Vector3.new(VelocityType('MoveDirection', AimlockedTarget.Humanoid, SetAimlockVelocity))
        end

        if Method == 'Ponyhook' then -- Like the name suggests, It's Ponyhooks aimlock
            local IsRandomVelocity = Vector3.new();
            local Vel = SetHitBox.AssemblyLinearVelocity -- It's an attribute in Ponyhook named Velocity, I'm just going to assume that its the targets velocity

            Vel *= Vector3.new(1, 0, 1); 
            Vel *= Select.PonyhookVelocity.Value;

            if IsPonyhook then
                IsRandomVelocity = Vector3.new(math.random(-5,5) / 10, math.random(-5,5) / 10, math.random(-5,5) / 10);
            end

            return SetHitBox.CFrame + IsRandomVelocity + (Vel * Ping / 1000);
        end
        
        if Method == 'Vector' then
            return SetHitBox.CFrame + Vector3.new(1, 0, 1) + Vector3.new(VelocityType('Velocity', SetHitBox, SetAimlockVelocity));
        end
        
        if Method == 'Velocity' then -- Test Methods
            return SetHitBox.CFrame + Vector3.new(VelocityType('Velocity', SetHitBox, SetAimlockVelocity) / Select.Humanization.Value)
        end
    end

    return Mouse.Hit;
end


local function FireAimlock()
    if not AimlockTarget then return end

    local AimlockCharacter = AimlockTarget.Character or AimlockTarget.CharacterAdded:Wait()

    if not AimlockCharacter then 
        Logger:Warning('No Aimlock Character found')
        return 
    end

    local AimlockOnTarget = AimlockCharacter[Select.AimlockPart.Value] or Mouse.Target;
    local AimlockOnHit = AimlockConfig(Select.AimlockMethod.Value, Boolean.RandomVelocity.Value, Boolean.RotationalVelocity.Value) or Mouse.Hit;

    if Utils.Streets then
        local Input = Backpack:FindFirstChild('Input', true)

        if Input and Input:IsA('RemoteEvent') then
            Input:FireServer('I', {
                velo = 16;
                shift = false;

                mousehit = AimlockOnHit;
                mousetarget = AimlockOnTarget;
            })
        end

        return
    end

    if Utils.Prison and Weapon and Weapon.Tool then
        local Remote =  Weapon.Tool.Name..'Fire';
        local FiringEvent = Utils.ReplicatedStorage:FindFirstChild(Remote, true)

        if FiringEvent and FiringEvent:IsA('RemoteEvent') then
            FiringEvent:FireServer(AimlockOnHit, AimlockOnTarget);
        end
    end

    if Utils.Remake then
        local FiringEvent = Utils.ReplicatedStorage:FindFirstChild('Game', true)

        if FiringEvent and FiringEvent:IsA('RemoteEvent') then
            FiringEvent:FireServer('Shoot', AimlockOnHit, AimlockOnTarget);
        end
    end
end


local function HookMouse() : (CFrame, Instance?)
    if Boolean.Aimlock.Value and AimlockTarget then
        return FindPlayersPart(AimlockTarget) or AimlockConfig(Select.AimlockMethod.Value, Boolean.RandomVelocity.Value, Boolean.RotationalVelocity.Value) or Mouse.Hit;
    end

    return Mouse.Hit, Mouse.Target
end


local function HookData()
    local GetIndex; GetIndex = hookmetamethod(game, '__index', newcclosure(function(self: Instance, Index: any)
        local Self = tostring(self)

        if typeof(self) ~= 'Instance' or checkcaller() then
            return GetIndex(self, Index);
        end

        if Utils.BothOriginal and Boolean.InfiniteStam.Value then
            if Self == 'Stamina' and Index == 'Value' then
                return 100;
            end
        end

        if self == Utils.ScriptContext and Index == 'Error' then
            return {connect = function() end} -- // PlayerGui.LocalScript
        end

        if self == Humanoid then
            if Index == 'WalkSpeed' then
                return Originals.WalkSpeed;
            end

            if Index == 'JumpPower' then
                return Originals.JumpPower;
            end

            if Index == 'HipHeight' then
                return Originals.HipHeight;
            end
        end

        if self == Utils.Workspace then
            if Index == 'Gravity' then
                return Originals.Gravity;
            end
        end

        if self == Camera then 
            if Index == 'FieldOfView' then
                return Originals.FOV;
            end
        end

        return GetIndex(self, Index);
    end));


    local GetNewIndex; GetNewIndex = hookmetamethod(game, '__newindex', newcclosure(function(self: Instance, Index: any, Value: any)
        if typeof(self) ~= 'Instance' or checkcaller() then
           return GetNewIndex(self, Index, Value);
        end

        Utils.StarterGui:SetCore('ResetButtonCallback', true)

        if self == Humanoid then
            if Index == 'JumpPower' then
                Value = Select.JumpPower.Value or Originals.JumpPower;
            end

            if Index == 'Jump' and Boolean.InfiniteStam.Value and Utils.UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                Value = true;
            end

            if Index == 'Health' then -- Detectable
                return;
            end

            if Index == 'AutoRotate' then
                Value = true;
            end

            if Index == 'WalkSpeed' and Boolean.NoSlow.Value then
                if Value == 0 or Value == 2 then
                    return Select.WalkSpeed.Value or Originals.WalkSpeed;
                end

                if Debounce.Crouching then
                    Value = Select.CrouchSpeed.Value or 8 or 7.9;
                end

                if Movement.W or Movement.A or Movement.S or Movement.D then
                    if not Debounce.Crouching then
                        Value = Select.WalkSpeed.Value or Originals.WalkSpeed;
                    
                    elseif Debounce.Crouching then
                        Value = Select.CrouchSpeed.Value or 8 or 7.9;
                    end
                end
                
                if Utils.BothOriginal and not Boolean.InfiniteStam.Value and Body:FindFirstChild(Body:FindFirstChild('Stam') and 'Stam' or 'Stamina').Value < 0.1 and Utils.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    Value = Originals.WalkSpeed;

                elseif Utils.Remake and not Boolean.InfiniteStam.Value and Host:GetAttribute('Stamina') < 0.1 and Utils.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    Value = Originals.WalkSpeed;

                elseif Utils.UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    Value = Select.WalkSpeed.Value;
                end
            end
        end

        if self == Root then -- Detectable
            if Index == 'CFrame' or Index == 'Position' then
                return
            end
        end

        if self == Utils.Workspace then
            if Index == 'Gravity' and Boolean.Gravity.Value then
                Value = Select.Gravity.Value or Originals.Gravity;
            end
        end

        if Utils.BothOriginal and Boolean.InfiniteStam.Value and self.Parent == Body and self.Name == 'Stamina' or self.Name == 'Stam' then -- Detectable if InfiniteStam is true
            if Index == 'Value' then
                return 100;
            end
        end

        if self.Name == 'GetMouse' and Index == 'OnClientInvoke' then -- Creds to Ponyhook because I'm not that great with hookfunction
            Value = HookMouse;
        end -- Detectable

        if self == Camera then 
            if Index == 'FieldOfView' then -- Because of the new chat commands
                Value = Select.FOV.Value or Originals.FOV;
            end
        end

        return GetNewIndex(self, Index, Value);
    end));


    local GetNameCalls; GetNameCalls = hookmetamethod(game, '__namecall', newcclosure(function(self: Instance, ...)
        local SetMethod, Arguments = (getnamecallmethod or get_namecall_method)(), {...};

        if typeof(self) ~= 'Instance' or checkcaller() then
            return GetNameCalls(self, unpack(Arguments));
        end

        if SetMethod == 'FireServer' then
            if Utils.Prison then
                if table.find({Utils.ReplicatedStorage, Backpack}, self.Parent) and table.find({'GlockFire', 'ShottyFire', 'UziFire', 'Fire', 'Shoot'}, self.Name) and self.ClassName == 'RemoteEvent' then
                    Arguments[1] = Mouse.Hit;
                    Arguments[2] = Mouse.Target;

                    if Boolean.Aimlock.Value and AimlockTarget and Select.AimlockMode.Value == 'Manual' then
                        local AimlockCharacter = AimlockTarget.Character or AimlockTarget.CharacterAdded:Wait() 

                        Arguments[1] = AimlockConfig(Select.AimlockMethod.Value, Boolean.RandomVelocity.Value, Boolean.RotationalVelocity.Value) or Mouse.Hit;
                        Arguments[2] = AimlockCharacter[Select.AimlockPart.Value] or Mouse.Target;
                    end
                end

                if self.Parent == Utils.ReplicatedStorage and self.Name == 'lIIl' then
                    return;
                end
            end

            if Utils.Remake then
                if table.find({Utils.ReplicatedStorage, Backpack}, self.Parent) and self.Name == 'Game' and self.ClassName == 'RemoteEvent' then
                    if Arguments[1] == 'Shoot' then
                        Arguments[2] = Mouse.Hit;
                        Arguments[3] = Mouse.Target;

                        if Boolean.Aimlock.Value and AimlockTarget and Select.AimlockMode.Value == 'Manual' then
                            local AimlockCharacter = AimlockTarget.Character or AimlockTarget.CharacterAdded:Wait() 

                            Arguments[2] = AimlockConfig(Select.AimlockMethod.Value, Boolean.RandomVelocity.Value, Boolean.RotationalVelocity.Value) or Mouse.Hit;
                            Arguments[3] = AimlockCharacter[Select.AimlockPart.Value] or Mouse.Target;
                        end
                    end
                end
            end

            if Utils.Streets then
                local Blacklisted = {'checkin1', 'checkin2', 'checkin3', 'bv', 'ws', 'hb'}
                local Dragging = {'e', 'drag', 'dragoff'}

                if self.Name == 'Input' and self.ClassName == 'RemoteEvent' then
                    if table.find({'I', 'm1', 'moff1'}, Arguments[1]) then
                        Arguments[2].mousehit = Mouse.Hit;
                        Arguments[2].velo = 16;
                        Arguments[2].shift = false;
                        Arguments[2].mousetarget = Mouse.Target;

                        if Boolean.Aimlock.Value and AimlockTarget and Select.AimlockMode.Value == 'Manual' then
                            local AimlockCharacter = AimlockTarget.Character or AimlockTarget.CharacterAdded:Wait() 

                            Arguments[2].mousehit = AimlockConfig(Select.AimlockMethod.Value, Boolean.RandomVelocity.Value, Boolean.RotationalVelocity.Value) or Mouse.Hit;
                            Arguments[2].mousetarget = AimlockCharacter[Select.AimlockPart.Value] or Mouse.Target;
                        end

                        os.clock();
                    end

                    if table.find(Blacklisted, Arguments[1]) then
                        return;
                    end

                    if table.find(Dragging, Arguments[1]) then
                        Arguments = {Arguments[1], {}}
                    end
                end
            end
        end

        if self.ClassName == 'RemoteEvent' and SetMethod == 'OnClientEvent' then
            if self.Name == 'ScreenShake' and Boolean.NoCameraShake.Value then
                return;
            end

            if self.Name == 'Flashbang' then
                return;
            end
        end

        if self == Body then -- Detectable
            if SetMethod == 'BreakJoints' or SetMethod == 'Destroy' or SetMethod == 'ClearAllChildren' then
                return;
            end
        end

        if self == Utils.Workspace then -- Detectable
            if SetMethod == 'ClearAllChildren' then
                return;
            end
        end

        if SetMethod == 'FindFirstChild' or SetMethod == 'WaitForChild' then -- (PlayerGui.LocalScript) -- Detectable
            --[[if Utils.Prison and Boolean.NoSlow.Value and Arguments[1] == 'Action' then
                --return; -- If NoSlow in prison does not work, uncomment this and it should work
            end]]--
        end
    
        return GetNameCalls(self, unpack(Arguments));
    end))


    local HookKick; HookKick = hookfunction(Host.Kick or Host.kick, newcclosure(function(self: Instance, ...)
        return HookKick(self, ...)
    end));
end

-- Commands []

do
    CommandHandler.Add('aimlock', {'aim', 'al'}, 'Locks your aim onto a player', '', true, function(Arguments)

        if Arguments[1] then
            Boolean.Aimlock.Value = true
            AimlockTarget = FindPlayer(Arguments[1])[1]

            if Boolean.EspOnTargetted.Value then
                AddEsp(AimlockTarget)
            end

            Notify('Aimlock Target', 'Aimlock Target is now '..AimlockTarget.DisplayName)
        else
            Boolean.Aimlock.Value = not Boolean.Aimlock.Value
            Notify('Aimlock', 'Aimlock is now '..tostring(Boolean.Aimlock.Value))
        end
    end)


    CommandHandler.Add('camlock', {'cam', 'cl'}, 'Locks your Camera onto a player', '', true, function(Arguments)

        if Arguments[1] then
            CamlockTarget = FindPlayer(Arguments[1])[1]
            Boolean.Camlock.Value = true;
            Notify('Camlock Target', 'Camlock Target is now '..CamlockTarget.DisplayName)
        else
            Boolean.Camlock.Value = not Boolean.Camlock.Value;
            Notify('Camlock', 'Camlock is now '..tostring(Boolean.Camlock.Value))
        end
    end)


    CommandHandler.Add('copyname', {}, 'Copys a players name to your clipboard so you do not have to struggle with typing or you can steal a display name', '', true, function(Arguments)

        if Arguments[1] then
            ClipboardTarget = FindPlayer(Arguments[1])[1].Name
            Utils.Clipboard(tostring(ClipboardTarget))
        end

        Notify('Copy Name','Copied name '..tostring(ClipboardTarget))
    end)


    CommandHandler.Add('stealaudio', {'steala', 'sa'}, 'Steals an audio from a person (Command provides no decryption)', '', true, function(Arguments)
        
        if Arguments[1] then
            AudioTarget = FindPlayer(Arguments[1])[1]

            if not (AudioTarget or AudioTarget.Character) then 
                Notify('Steal Audio','Player not found')
            end

            local SoundX = AudioTarget.Character:FindFirstChild('SoundX', true)

            if not SoundX then
                Notify('Steal Audio','Non-existant audio id, player is not using Boombox')
            end

            local AudioId = tostring(SoundX.SoundId)

            Utils.Clipboard(AudioId)
            Notify('Steal Audio','Audio id is now copied: '..tostring(AudioId))
        end
    end)


    CommandHandler.Add('esp', {}, 'Traces the player specifiied', '', true, function(Arguments)

        if Arguments[1] then
            EspTarget = FindPlayer(Arguments[1])

            if FindPlayer(Arguments[1]) == string.lower('all') then
                Debounce.EspAll = true;
            end

            for _, Index in next, (EspTarget) do
                AddEsp(Index);
            end

            EspTarget = FindPlayer(Arguments[1])[1] or 'nil'
            Notify('Esp','Esp\'d player '..tostring(EspTarget.DisplayName))
        end
    end)


    CommandHandler.Add('unesp', {}, 'Deletes the esp on the specified player', '', true, function(Arguments)

        if Arguments[1] then
            UnespTarget = FindPlayer(Arguments[1])

            if FindPlayer(Arguments[1]) == string.lower('all') then
                Debounce.EspAll = false;
            end

            for _, Index in next, (UnespTarget) do
                RemoveEsp(Index);
            end

            UnespTarget = FindPlayer(Arguments[1])[1] or 'nil'

            Notify('Unesp','Unesp\'d player '..tostring(UnespTarget.DisplayName))
        end
    end)


    CommandHandler.Add('watchforrejoin', {'rejoinwatch', 'wfr'}, 'Watches for the specified target to rejoin', '', true, function(Arguments)

        if Arguments[1] then
            WatchRejoinTarget = FindPlayer(Arguments[1])[1] or Arguments[1]

            if not FindPlayer(Arguments[1])[1] then
                Notify('Watch On Rejoin', 'Player not found in game, you can type out their full name (Ignore if you typed their name)')
            end
        end

        Notify('Watch On Rejoin','Target is now '..tostring(WatchRejoinTarget.DisplayName))
    end)


    CommandHandler.Add('fly', {'flight'}, 'Allows you to fly', '', true, function()
        Boolean.Flying.Value = not Boolean.Flying.Value

        if Boolean.Flying.Value then Fly() else KillFly() end
    end)


    CommandHandler.Add('flyspeed', {'flightspeed', 'fs'}, 'Changes your flightspeed', '', true, function(Arguments)

        if Arguments[1] then
            assert(tonumber(Arguments[1]), 'Fly Speed must be a number')
        end

        Select.FlySpeed.Value = Arguments[1] or 4
        Notify('Fly Speed', 'Fly Speed is now '..tonumber(Select.FlySpeed.Value))
    end)


    CommandHandler.Add('to', {'goto', 'tp', 'teleport'}, 'Teleports you to the targetted player', '', true, function(Arguments)

        if Arguments[1] then
            TeleportTarget = FindPlayer(Arguments[1])[1]
        end

        local TeleportToCFrame = FindPlayersPart(TeleportTarget, 'Class', 'Humanoid')
        TeleportTo((TeleportToCFrame and TeleportToCFrame.RootPart and TeleportToCFrame.RootPart.CFrame) or Root.CFrame)
    end)


    CommandHandler.Add('url', {}, 'Copys a players profile URL so you can search them up', '', true, function(Arguments)

        if Arguments[1] then
            UserIdTarget = FindPlayer(Arguments[1])[1]

            local SearchPlayer = tostring(UserIdTarget.UserId)
            Utils.Clipboard('https://www.roblox.com/users/'..SearchPlayer..'/profile')

            Notify('Url','Url copied and sent to clipboard '..tostring(UserIdTarget.DisplayName))
        end
    end)


    CommandHandler.Add('view', {'watch', 'spectate', 'eye'}, 'Changes your camera view onto a players perspective', '', true, function(Arguments)

        if Arguments[1] then
            ViewTarget = FindPlayer(Arguments[1])[1]
            Boolean.Viewing.Value = true;
        else
            Boolean.Viewing.Value = not Boolean.Viewing.Value;
        end

        if not Boolean.Viewing.Value then
            Camera.CameraSubject = Humanoid
        end

        Notify('Viewing','Viewing is now '..tostring(Boolean.Viewing.Value))
    end)


    CommandHandler.Add('aimlockmethod', {'aimmethod', 'am'}, 'Changes your aimlock functionality', 'cyrus, movedirection, ponyhook, vector, velocity', true, function(Arguments)
        local AimlockMethodIndex = {'cyrus', 'movedirection', 'ponyhook', 'vector', 'velocity'}

        if Arguments[1] and table.find(AimlockMethodIndex, Arguments[1]) then

            Boolean.RotationalVelocity.Value = (Arguments[1] == 'cyrus')

            Select.AimlockMethod.Value = String.sentenceCase(Arguments[1])
            Notify('Aimlock Method', 'Aimlock Method is now '..tostring(Select.AimlockMethod.Value))
        end
    end)


    CommandHandler.Add('aimlockpart', {'aimpart', 'amp', 'ap'}, 'Changes your aimlock targetted limb', 'head, root, torso', true, function(Arguments)
        local AimlockPartIndex = {'head','torso','root','humanoidrootpart'}

        if Arguments[1] and table.find(AimlockPartIndex, Arguments[1]) then
            if Arguments[1] == 'humanoidrootpart' or Arguments[1] == 'root' then
                Select.AimlockPart.Value = 'HumanoidRootPart';
            else
                Select.AimlockPart.Value = String.sentenceCase(Arguments[1])
            end

            Notify('Aimlock Part', 'Aimlock Part is now '..tostring(Select.AimlockPart.Value))
        end
    end)


    CommandHandler.Add('aimlockvelocity', {'aimvelocity', 'av'}, 'Changes your aimlocks velocity', '', true, function(Arguments)

        if Arguments[1] then
            assert(tonumber(Arguments[1]), 'Aimlock Velocity must be a number')
        end

        Select.AimlockVelocity.Value = Arguments[1]
        Notify('Aimlock Velocity', 'Aimlock Velocity is now '..tonumber(Select.AimlockVelocity.Value))
    end)


    CommandHandler.Add('rotvelocity', {'rotationalvelocity', 'rotationvelocity'}, 'Toggles on Cyrus\'s RotVelocity (Must be using AimlockMethod Cyrus)', '', true, function()
        Boolean.RotationalVelocity.Value = not Boolean.RotationalVelocity.Value
        Notify('Cyrus Rotational Velocity', 'Cyrus Rotational Velocity is now '..tostring(Boolean.RotationalVelocity.Value))
    end)


    CommandHandler.Add('fovcircle', {'aimbotcircle', 'circle'}, 'Toggles on a Fov Circle', '', true, function()
        Boolean.FOVCircle.Value = not Boolean.FOVCircle.Value
    end)


    CommandHandler.Add('randomvelocity', {'rv'}, 'Toggles on Ponyhooks random velocity (Must be using AimlockMethod Ponyhook)', '', true, function()
        Boolean.RandomVelocity.Value = not Boolean.RandomVelocity.Value
        Notify('Random Velocity', 'Random Velocity is now '..tostring(Boolean.RandomVelocity.Value))
    end)


    CommandHandler.Add('ponyhookvelocity', {'pv'}, 'Toggles on Ponyhooks Velocity Multiplier (Must be using AimlockMethod Ponyhook)', '', true, function(Arguments)

        if Arguments[1] then
            assert(tonumber(Arguments[1]), 'Ponyhook Velocity must be a number')
        end

        Select.PonyhookVelocity.Value = Arguments[1]
        Notify('Ponyhook Velocity', 'Ponyhook Velocity is now '..tostring(Select.PonyhookVelocity.Value))
    end)


    CommandHandler.Add('blink', {}, 'Allows you to sprint', '', true, function()
        Boolean.Blink.Value = not Boolean.Blink.Value
        Notify('Blink', 'Blink is now '..tostring(Boolean.Blink.Value))
    end)


    CommandHandler.Add('blinkspeed', {'bs'}, 'Changes your blink speed', '', true, function(Arguments)

        if Arguments[1] then
            assert(tonumber(Arguments[1]), 'Blink Speed must be a number')
        end

        Select.BlinkSpeed.Value = Arguments[1];
        Notify('Blink Speed', 'Blink Speed is now '..tonumber(Select.BlinkSpeed.Value))
    end)


    CommandHandler.Add('noshake', {}, 'Toggles camera shake when people use that stupid mech, legit has nothing to do with the game', '', true, function()
        Boolean.NoCameraShake.Value = not Boolean.NoCameraShake.Value
        Notify('No CameraShake','No CameraShake is now '..tostring(Boolean.NoCameraShake.Value))
    end)


    CommandHandler.Add('toggleesp', {}, 'Toggles ESP', '', true, function()
        Boolean.Esp.Value = not Boolean.Esp.Value
        Notify('Esp Toggle', 'Esp Toggle is now '..tostring(Boolean.Esp.Value))
    end)


    CommandHandler.Add('sit', {}, 'Sits your character down', '', true, function()
        if Humanoid then Humanoid.Sit = true end
    end)


    CommandHandler.Add('fov', {'fieldofview'}, 'Changes your FOV', '', true, function(Arguments)

        if Arguments[1] then
            assert(tonumber(Arguments[1]), 'Field Of View must be a number')
        end

        Select.FOV.Value = Arguments[1]
        Camera.FieldOfView = Select.FOV.Value
    end)


    CommandHandler.Add('fpscap', {'setfpscap'}, 'Changes your FPS cap', '', true, function(Arguments)
        if getfpscap and setfpscap then

            if Arguments[1] then
                assert(tonumber(Arguments[1]), 'FPS Cap must be a number')
            end

            Logger:Cout(getfpscap())
            setfpscap(Arguments[1])
        else
            Notify('Set FPS Cap', 'FPS Cap is now '..tonumber(getfpscap()))
        end 
    end)


    CommandHandler.Add('chams', {'cham', 'espchams'}, 'Highlights the esp\'d player', '', true, function()
        Boolean.EspChams.Value = not Boolean.EspChams.Value
    end)


    CommandHandler.Add('tpbypass', {'tpb', 'bypass'}, 'Bypasses anti-teleportation anticheats', '', true, function()
        Boolean.TpBypass.Value = not Boolean.TpBypass.Value
        TeleportBypass();

        Notify('Teleport Bypass','Teleport Bypass is now '..tostring(Boolean.TpBypass.Value))
    end)


    CommandHandler.Add('infzoom', {'infinitezoom'}, 'Allows you to zoom out into infinity', '', true, function()
        SetInfinityZoom(Boolean.InfiniteZoom.Value)
        Notify('Infinite Zoom','Infinite Zoom is now '..tostring(Boolean.InfiniteZoom.Value))
    end)


    CommandHandler.Add('exit', {'leave'}, 'Makes you leave the current game', '', true, function()
        game:shutdown()
    end)


    CommandHandler.Add('devmode', {'developermode'}, 'Allows you to use commands I\'ve thought of as not finished or polished. (May result in unwanted results)', '', true, function()
        Boolean.DevMode.Value = not Boolean.DevMode.Value
        Notify('Developer Mode', 'Be mindful of what commands you do, it could break the script or get you banned')
    end)


    CommandHandler.Add('remotespy', {'rspy'}, 'Allows you to spy on remotes', '', true, function() -- Just in here so I don't have to load IY
        Import('https://raw.githubusercontent.com/infyiff/backup/main/SimpleSpyV3/main.lua')
    end)


    CommandHandler.Add('darkdex', {'dex'}, 'Allows you to explorer the games files', '', true, function() -- Just in here so I don't have to load IY
        Import('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua')
    end)


    CommandHandler.Add('rejoin', {'rj'}, 'Rejoins the current game', '', true, function()
        Utils.TeleportService:TeleportToPlaceInstance(Place, Job)
    end)


    CommandHandler.Add('swap', {}, 'Swaps the current game between Streets and Prison', '', true, function()
        Utils.TeleportService:Teleport(Hash.PlaceSwap, Host)
    end)


    CommandHandler.Add('serverhop', {'shop'}, 'Hops servers', '', true, function() -- Creds to IY
        if HttpRequest then
            local Servers = {};
            local Url = Utils.HttpRequest({Url = string.format('https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true', Place)})
            local HtmlBody = Utils.HttpService:JSONDecode(Url.Body)

            if HtmlBody and HtmlBody.data then
                for _, Index in next, HtmlBody.data do
                    if type(Index) == 'table' and tonumber(Index.playing) and tonumber(Index.maxPlayers) and Index.playing < Index.maxPlayers and Index.id ~= Job then
                        table.insert(Servers, 1, Index.id)
                    end
                end
            end

            if #Servers > 0 then
                Utils.TeleportService:TeleportToPlaceInstance(Place, Servers[math.random(1, #Servers)], Host)
            end
        else
            Notify('Error 236', '(syn.request) was not found or not compatible')
        end
    end)


    CommandHandler.Add('name', {'tag', 'group'}, 'Changes your groups name', '', true, function(Arguments) -- They seem set on updating this
        if Arguments[1] and not Boolean.TpBypass.Value then
            local SetName = Arguments[1]
            Enums.SetClan(string.rep('\n', 100 - #SetName)..SetName)
        end
    end)


    CommandHandler.Add('notifications', {}, 'Toggles notifications', '', true, function()
        Boolean.Notifications.Value = not Boolean.Notifications.Value
    end)


    CommandHandler.Add('shiftlock', {}, 'Allows you to use shiftlock when developers have it locked', '', true, function()
        Host.DevEnableMouseLock = not Host.DevEnableMouseLock
    end)


    CommandHandler.Add('mouse', {'cursor'}, 'Toggles your cursor on and off', '', true, function()
        Utils.UserInputService.MouseIconEnabled = not Utils.UserInputService.MouseIconEnabled
    end)


    CommandHandler.Add('crosshair', {'rotcursor'}, 'Toggles your crosshair on and off', '', true, function()
        CursorImage.Visible = not CursorImage.Visible
    end)


    CommandHandler.Add('watermark', {}, 'Toggles the watermark', '', true, function()
        OuterWatermark.Visible = not OuterWatermark.Visible;
    end)


    CommandHandler.Add('showchat', {}, 'Toggles the chat UI', '', true, function()
        ChatFrame.Enabled = not ChatFrame.Enabled;
    end)
end

Menu:OnUnload(function() 
    Menu.Unloaded = true
end);

local Window = Menu:CreateWindow({Title = Utils.Title(2) .. ' [verison]: ' .. getgenv().Version .. ' | ' .. Utils.GameTitle(), Center = true, AutoShow = true}) do

FileMenu:SetLibrary(Menu)
ThemeMenu:SetLibrary(Menu)

ThemeMenu:SetFolder('mawborn/Themes');
FileMenu:SetFolder('mawborn/Menu');

-- Had to limit my usage of local, also they need to be in order as they are
-- Also can not use CommandHandler.Execute, as the UI will figure that command should be turned on :/

local Tabs = {
    Combat = Window:AddTab('Combat'), 
    Visuals = Window:AddTab('Visuals'), 
    MovementTab = Window:AddTab('Movement'), 
    World = Window:AddTab('World'), 
    Misc = Window:AddTab('Misc'), 
    Data = Window:AddTab('Data')
}

local Combat = {
    AimlockBox = Tabs.Combat:AddLeftTabbox(''),
    CamlockBox = Tabs.Combat:AddRightTabbox(''),
    ItemPurchase = Tabs.Combat:AddRightTabbox(''),
    ItemEspBox = Tabs.Combat:AddRightTabbox(''),
    ResetTab = Tabs.Combat:AddRightTabbox(''),
}

local Visuals = {
    EspBox = Tabs.Visuals:AddLeftTabbox(''),
    CircleBox = Tabs.Visuals:AddLeftTabbox(''),
    TrailsBox = Tabs.Visuals:AddRightTabbox(''),
    CameraBox = Tabs.Visuals:AddRightTabbox(''),
    ToolsTab = Tabs.Visuals:AddRightTabbox(''),
}

local Movements = {
    FlyBox = Tabs.MovementTab:AddLeftTabbox(''),
    PlayerBox = Tabs.MovementTab:AddLeftTabbox(''),
    BlinkBox = Tabs.MovementTab:AddRightTabbox(''),
    TeleportBox = Tabs.MovementTab:AddRightTabbox(''),
    KickPlayerBox = Tabs.MovementTab:AddRightTabbox(''),
}

local World = {
    WorldCommands = Tabs.World:AddLeftTabbox(''),
    World2Commands = Tabs.World:AddRightTabbox(''),
    BoomboxTab = Tabs.World:AddRightTabbox(''),
}

local Misc = {
    MiscTab = Tabs.Misc:AddLeftTabbox(''),
    DevTab = Tabs.Misc:AddLeftTabbox(''),
    ScriptDataTab = Tabs.Misc:AddLeftTabbox(''),
    ScriptTab = Tabs.Misc:AddRightTabbox(''),
    KeyTab = Tabs.Misc:AddRightTabbox(''),
    GameTab = Tabs.Misc:AddRightTabbox(''),
}

local CombatTab = {
    AimlockTab = Combat.AimlockBox:AddTab('Aimlock'),
    CamlockTab = Combat.CamlockBox:AddTab('Camlock'),
    ItemPurchase = Combat.ItemPurchase:AddTab('Buy Items'),
    ItemEspTab = Combat.ItemEspBox:AddTab('ItemEsp'),
    ItemEspMoreTab = Combat.ItemEspBox:AddTab('More'),
    ResetBox = Combat.ResetTab:AddTab('Reset'),
}

local VisualsTab = {
    EspTab = Visuals.EspBox:AddTab('Esp'),
    ChamsTab = Visuals.EspBox:AddTab('Chams'),
    CircleTab = Visuals.CircleBox:AddTab('FOV'),
    CustomCursorTab = Visuals.CircleBox:AddTab('Custom Cursor'),
    CircleMoreTab = Visuals.CircleBox:AddTab('More'),
    TrailsBox = Visuals.TrailsBox:AddTab('Trails'),
    CameraTab = Visuals.CameraBox:AddTab('Camera'),
    ViewBox = Visuals.CameraBox:AddTab('Viewing'),
    ToolsBox = Visuals.ToolsTab:AddTab('Tools'),
    ToolsMoreBox = Visuals.ToolsTab:AddTab('More'),
}

local MovementTab = {
    FlyTab = Movements.FlyBox:AddTab('Fly'),
    PlayerTab = Movements.PlayerBox:AddTab('Player'),
    BlinkTab = Movements.BlinkBox:AddTab('Blink'),
    TeleportTab = Movements.TeleportBox:AddTab('Teleport'),
    KickPlayerTab = Movements.KickPlayerBox:AddTab('Kick Players'),
}

local WorldTab = {
    WorldCmds = World.WorldCommands:AddTab('World'),
    World2Cmds = World.World2Commands:AddTab('Sky'),
    BoomboxBox = World.BoomboxTab:AddTab('Boombox'),
    ReverbBox = World.BoomboxTab:AddTab('Reverb'),
    DistortionBox = World.BoomboxTab:AddTab('Distort'),
    ChorusBox = World.BoomboxTab:AddTab('Chorus'),
}

local MiscTab = {
    MiscBox = Misc.MiscTab:AddTab('Misc'),
    Development = Misc.DevTab:AddTab('Development'),
    ScriptDataBox = Misc.ScriptDataTab:AddTab('Script'),
    Script = Misc.ScriptTab:AddTab('UI'),
    MoreKeybinds = Misc.KeyTab:AddTab('Keybinds'),
    GameBox = Misc.GameTab:AddTab('Game'),
}

CombatTab.AimlockTab:AddDivider();
CombatTab.CamlockTab:AddDivider();
CombatTab.ItemPurchase:AddDivider();
CombatTab.ItemEspTab:AddDivider();
CombatTab.ItemEspMoreTab:AddDivider();
CombatTab.ResetBox:AddDivider();

VisualsTab.EspTab:AddDivider();
VisualsTab.ChamsTab:AddDivider();
VisualsTab.CircleTab:AddDivider();
VisualsTab.CustomCursorTab:AddDivider();
VisualsTab.CircleMoreTab:AddDivider();
VisualsTab.TrailsBox:AddDivider();
VisualsTab.CameraTab:AddDivider();
VisualsTab.ViewBox:AddDivider();
VisualsTab.ToolsBox:AddDivider();
VisualsTab.ToolsMoreBox:AddDivider();

MovementTab.FlyTab:AddDivider();
MovementTab.PlayerTab:AddDivider();
MovementTab.BlinkTab:AddDivider();
MovementTab.TeleportTab:AddDivider();

WorldTab.WorldCmds:AddDivider();
WorldTab.World2Cmds:AddDivider();
WorldTab.BoomboxBox:AddDivider();
WorldTab.ReverbBox:AddDivider();
WorldTab.DistortionBox:AddDivider();
WorldTab.ChorusBox:AddDivider();

MiscTab.MiscBox:AddDivider();
MiscTab.Development:AddDivider();
MiscTab.ScriptDataBox:AddDivider();
MiscTab.Script:AddDivider();
MiscTab.MoreKeybinds:AddDivider();
MiscTab.GameBox:AddDivider();

FileMenu:BuildConfigSection(Tabs.Data);
ThemeMenu:ApplyToTab(Tabs.Data);

-- Combat [] Aimlock Box

CombatTab.AimlockTab:AddToggle('Aimlock', { Text = 'Aimlock', Tooltip = 'Turns on aimlock (DONT USE ON PRISON)' }):AddKeyPicker('AimlockKeybind', { Default = 'Q', SyncToggleState = true, Mode = 'Toggle', Text = 'Aimlock' }); Boolean.Aimlock:OnChanged(function()
    UpdateLabel()

    if Utils.Prison then
        Boolean.Aimlock.Value = false;
    end
end)

CombatTab.AimlockTab:AddToggle('CameraAimbot', { Text = 'Camera Aimbot', Tooltip = 'Aimbots the selected player', Default = true})

CombatTab.AimlockTab:AddLabel('Aimlock Target', false):AddKeyPicker('AimlockTargetKeybind', { Default = 'E', SyncToggleState = true, Mode = 'Toggle', Text = 'AimlockTarget' });

CombatTab.AimlockTab:AddBlank(3)

CombatTab.AimlockTab:AddToggle('EspOnTargetted', { Text = 'Esp On Target', Tooltip = 'Esps the player when you aimlock them', Default = true })
CombatTab.AimlockTab:AddToggle('WatchRejoinAimlock', { Text = 'Toggle On Rejoin', Tooltip = 'Toggles on if the player rejoins', Default = true })
CombatTab.AimlockTab:AddToggle('AutomaticReload', { Text = 'Auto Reload', Tooltip = 'Reloads your gun if it detects your out of ammo', Default = false })

CombatTab.AimlockTab:AddBlank(5)

CombatTab.AimlockTab:AddDropdown('AimlockPart', { Text = 'Aimlock Part', Tooltip = 'Changes your aimlock part', Values = {'Head', 'Torso', 'HumanoidRootPart'}, Default = 'HumanoidRootPart', Multi = false })

CombatTab.AimlockTab:AddDropdown('AimlockMethod', { Text = 'Aimlock Method', Tooltip = 'Changes your aimlock method', Values = {'Cyrus', 'Ponyhook', 'Movedirection', 'Velocity', 'Vector'}, Default = 'Velocity', Multi = false }):OnChanged(function()
    UpdateLabel()
end)

CombatTab.AimlockTab:AddDropdown('AimlockMode', { Text = 'Aimlock Mode', Tooltip = 'Changes the way your aimlock fires (RECOMMEND USING AUTO-RELOAD)', Values = {'Manual', 'New Manual', 'Automatic', 'Ciazware'}, Default = 'Manual', Multi = false })

CombatTab.AimlockTab:AddBlank(3);

CombatTab.AimlockTab:AddSlider('AutofireDelay', { Text = 'Fire Delay', Tooltip = 'Delay for the ciazware and automatic mode', Default = 0.3, Min = 0.1, Max = 2, Rounding = 2 });

CombatTab.AimlockTab:AddDivider();
CombatTab.AimlockTab:AddLabel('Advanced')
CombatTab.AimlockTab:AddBlank(2);

CombatTab.AimlockTab:AddToggle('RandomVelocity', { Text = 'Random Velocity', Tooltip = 'Must be using Ponyhook aimlock', Default = true }):OnChanged(function()
    UpdateLabel()
end);

CombatTab.AimlockTab:AddToggle('RotationalVelocity', { Text = 'Rotational Velocity', Tooltip = 'Must be using Cyrus aimlock', Default = true }):OnChanged(function()
    UpdateLabel()
end);

CombatTab.AimlockTab:AddBlank(3);

CombatTab.AimlockTab:AddSlider('AimlockVelocity', { Text = 'Aimlock Velocity', Default = 0.031, Min = 0, Max = 1, Rounding = 3}):OnChanged(function()
    UpdateLabel()
end);

CombatTab.AimlockTab:AddSlider('PonyhookVelocity', { Text = 'Ponyhook Velocity', Tooltip = 'Must be using Ponyhook aimlock', Default = 1, Min = 0.1, Max = 10, Rounding = 2 }):OnChanged(function()
    UpdateLabel()
end);

CombatTab.AimlockTab:AddSlider('Humanization', { Text = 'Humanization', Tooltip = 'Must be using Velocity aimlock', Default = 1, Min = 0.1, Max = 2, Rounding = 1 }):OnChanged(function()
    UpdateLabel()
end);

-- [] Camlock Box

CombatTab.CamlockTab:AddToggle('Camlock', { Text = 'Camlock', Tooltip = 'Turns on camlock' }):AddKeyPicker('CamlockKeybind', { Default = 'C', SyncToggleState = true, Mode = 'Toggle', Text = 'Camlock' });
CombatTab.CamlockTab:AddToggle('WatchRejoinCamlock', { Text = 'Toggle On Rejoin', Tooltip = 'Toggles on if the player rejoins', Default = true });

CombatTab.CamlockTab:AddBlank(3);

CombatTab.CamlockTab:AddDropdown('CamlockPart', { Text = 'Camlock Part', Tooltip = 'Changes your camlock part', Values = {'Head', 'Torso', 'HumanoidRootPart'}, Default = 'HumanoidRootPart', Multi = false })

-- [] Item Purchasing Box

CombatTab.ItemPurchase:AddToggle('InstantPrompts', { Text = 'Instant Proximity Prompts'})
CombatTab.ItemPurchase:AddToggle('Autoheal', { Text = 'Autoheal', Tooltip = 'IN DEV MDOE'})
CombatTab.ItemPurchase:AddLabel('Buy Ammo', false):AddKeyPicker('BuyAmmoKeybind', { Default = 'V', SyncToggleState = true, Mode = 'Toggle', Text = 'BuyAmmo' });

CombatTab.ItemPurchase:AddBlank(5);

CombatTab.ItemPurchase:AddDropdown('ItemPurchase', { Text = 'Buy Item', Tooltip = 'Buys the listed item (Must be using TpBypass)', Values = {'Uzi', 'Glock', 'Sawed Off', 'Shotty', 'Taco', 'Chicken', 'Greenbull'}, Default = 'Uzi', Multi = false })

-- [] Item Esp Box

CombatTab.ItemEspTab:AddToggle('ItemEsp', { Text = 'Item Esp', Tooltip = 'Tells you where tools are that spawn' })
CombatTab.ItemEspTab:AddToggle('ItemTracers', { Text = 'Snapline' })

CombatTab.ItemEspTab:AddBlank(3);

CombatTab.ItemEspTab:AddDropdown('ItemEspItems', { Text = 'Blacklist', Values = {'Sawed Off', 'Cash', 'Katana', 'Rifle', 'USAS', 'Uzi', 'Grenade', 'Molotov', 'Brick', 'Flash Bang', 'Pipe Bomb'}, Default = '', Multi = true})

-- [] More Item Esp Box

CombatTab.ItemEspMoreTab:AddToggle('TeleportToItem', { Text = 'Teleport To Item', Tooltip = 'Press the keybind and it will teleport you to the item if you\'re pointing at it' }):AddKeyPicker('ItemTeleport', { Default = 'Y', SyncToggleState = false, Mode = 'Toggle', Text = 'ItemTeleport' }); Select.ItemTeleport:OnClick(function()
    if Boolean.TeleportToItem.Value then
        TeleportTo(GrabItem(Items, Select.TeleportItemRadius.Value))
    end
end)

CombatTab.ItemEspMoreTab:AddBlank(3);

CombatTab.ItemEspMoreTab:AddSlider('TeleportItemRadius', { Text = 'Item Radius', Tooltip = 'Changes how far your mouse needs to be away from the item to target it', Default = 50, Min = 50, Max = 200, Rounding = 0})

-- [] Reset Box

CombatTab.ResetBox:AddToggle('InfiniteForcefield', { Text = 'Infinite Forcefield', Tooltip = 'Makes you basically invincible', Default = false })
CombatTab.ResetBox:AddLabel('Refresh Character', false):AddKeyPicker('ResetKeybind', { Default = 'R', SyncToggleState = true, Mode = 'Toggle', Text = 'Reset' }); Select.ResetKeybind:OnClick(function()
    RefreshPlayer()
end)

-- Visuals [] Esp Box

VisualsTab.EspTab:AddToggle('Esp', {Text = 'Esp', Tooltip = 'Toggles Esp', Default = true})

VisualsTab.EspTab:AddBlank(5);

VisualsTab.EspTab:AddToggle('EspBox', {Text = 'Box', Tooltip = 'Toggles box esp', Default = true})
VisualsTab.EspTab:AddToggle('EspSnapline', {Text = 'Snapline', Tooltip = 'Toggles tracers'})
VisualsTab.EspTab:AddToggle('EspHealthBar', {Text = 'Health', Tooltip = 'Toggles Esp healthBar', Default = true});
VisualsTab.EspTab:AddToggle('EspText', {Text = 'Text', Tooltip = 'Toggles Esp Text', Default = true});
VisualsTab.EspTab:AddToggle('EspRaycast', {Text = 'Raycast', Tooltip = 'Toggles Esp IsVisible Text', Default = true});
VisualsTab.EspTab:AddToggle('EspTool', {Text = 'Tools', Tooltip = 'Toggles Esp Tools', Default = true});
VisualsTab.EspTab:AddToggle('EspTargetColor', {Text = 'Target Color', Tooltip = 'Toggles Target Color Esp', Default = true}):AddColorPicker('TargetColorPicker', {Default = Colors.AccentColor});

VisualsTab.EspTab:AddDivider();

VisualsTab.EspTab:AddSlider('DrawingThickness', {Text = 'Thickness', Default = 1, Min = 1, Max = 8, Rounding = 0});
VisualsTab.EspTab:AddSlider('StudDistance', {Text = 'Distance', Default = 2400, Min = 1, Max = 4000, Rounding = 0});

VisualsTab.EspTab:AddDropdown('SnaplineDirection', {Text = 'Snapline Offset', Tooltip = 'Changes where your snapline comes from', Values = {'From Mouse', 'From Screen', 'From Player'}, Default = 'From Screen', Multi = false})

-- [] Chams Box

VisualsTab.ChamsTab:AddToggle('EspChams', {Text = 'Chams', Tooltip = 'Toggles Chams', Default = false});
VisualsTab.ChamsTab:AddToggle('ChamsOutline', {Text = 'Outline Color', Default = false}):AddColorPicker('ChamsOutlineColor', {Default = Color3.fromRGB(225, 225, 225)});

VisualsTab.ChamsTab:AddBlank(5);

VisualsTab.ChamsTab:AddToggle('HitChams', {Text = 'Hit Chams', Tooltip = 'Highlights a player when you shoot them', Default = false});

VisualsTab.ChamsTab:AddBlank(5);

VisualsTab.ChamsTab:AddDropdown('ChamsDepth', {Text = 'Depth', Tooltip = 'Changes if you can see the target through walls or not', Values = {'AlwaysOnTop', 'Occluded'}, Default = 'AlwaysOnTop', Multi = false})

VisualsTab.ChamsTab:AddDivider();
VisualsTab.ChamsTab:AddLabel('Esp More')
VisualsTab.ChamsTab:AddBlank(5);

VisualsTab.ChamsTab:AddToggle('HitCheck', {Text = 'Visualize Hittable', Tooltip = 'Turns the esp a different color if the player is not hittable from a far', Default = true}):AddColorPicker('HitCheckColor', {Default = Color3.fromRGB(255, 65, 0)});
VisualsTab.ChamsTab:AddToggle('KosCheck', {Text = 'Visualize KOS', Tooltip = 'Esps a player that is in the KOS', Default = true}):AddColorPicker('KosColor', {Default = Color3.fromRGB(255, 175, 0)});
VisualsTab.ChamsTab:AddBlank(2);
VisualsTab.ChamsTab:AddDropdown('EspFont', {Text = 'Font', Values = {'Monospace', 'UI', 'System', 'Plex'}, Default = 'System', Multi = false})

-- [] Circle Box

VisualsTab.CircleTab:AddToggle('FOVCircle', {Text = 'FOV Circle', Tooltip = 'Toggles FOV Circle', Default = false}):AddColorPicker('FOVCircleColor', {Default = Colors.AccentColor})
VisualsTab.CircleTab:AddToggle('FOVMiddleCircle', {Text = 'Circle In Middle', Tooltip = 'Keeps the circle in the middle of the screen', Default = false})

VisualsTab.CircleTab:AddBlank(2);

VisualsTab.CircleTab:AddSlider('CircleSize', {Text = 'FOV Circle Size', Tooltip = 'Changes the FOV Circle size', Default = 55, Min = 5, Max = 250, Rounding = 0});
VisualsTab.CircleTab:AddSlider('CircleThickness', {Text = 'FOV Circle Thickness', Tooltip = 'Changes the FOV Circle Thickness', Default = 1, Min = 1, Max = 8, Rounding = 0});

-- [] Custom Cursor Box

VisualsTab.CustomCursorTab:AddToggle('CustomCursor', {Text = 'Custom Cursor', Default = true}):AddColorPicker('CustomCursorColor', {Default = Colors.AccentColor}) Boolean.CustomCursor:OnChanged(function()
    CursorImage.Visible = Boolean.CustomCursor.Value;
end)

Select.CustomCursorColor:OnChanged(function()
    CursorImage.ImageColor3 = Select.CustomCursorColor.Value
end)

VisualsTab.CustomCursorTab:AddToggle('LogoCursor', {Text = 'Logo Cursor', Default = true}):OnChanged(function()
    LogoFirst.Visible = Boolean.LogoCursor.Value;
    LogoSecond.Visible = Boolean.LogoCursor.Value;
end)

VisualsTab.CustomCursorTab:AddToggle('CursorInfo', {Text = 'Cursor Info', Tooltip = 'Gives you info about the player, (Holding Alt shows more data)', Default = true})
VisualsTab.CustomCursorTab:AddToggle('CursorCircle', {Text = 'Cursor Circle', Default = true}):OnChanged(function()
    CircleCursor.Visible = Boolean.CursorCircle.Value;
    CircleInner.Visible = Boolean.CursorCircle.Value;
end)

VisualsTab.CustomCursorTab:AddLabel('More Cursor Info', false):AddKeyPicker('AdvCursorInfo', {Default = 'LeftAlt', SyncToggleState = true, Mode = 'Toggle', Text = 'Advanced Cursor Info'});

VisualsTab.CustomCursorTab:AddBlank(3);

VisualsTab.CustomCursorTab:AddSlider('CursorSize', {Text = 'Custom Cursor Size', Default = 65, Min = 5, Max = 100, Rounding = 0});

-- [] Circle More Box

VisualsTab.CircleMoreTab:AddToggle('Shiftlock', {Text = 'Shiftlock', Tooltip = 'Turns shiftlock off and on if Koto turns it off', Default = true}):OnChanged(function()
    Host.DevEnableMouseLock = Boolean.Shiftlock.Value
end)

VisualsTab.CircleMoreTab:AddToggle('Cursor', {Text = 'Cursor', Tooltip = 'Shows your real cursor', Default = true}):OnChanged(function()
    Utils.UserInputService.MouseIconEnabled = Boolean.Cursor.Value
end)

-- [] Trails Box

VisualsTab.TrailsBox:AddToggle('Trails', {Text = 'Trails', Tooltip = 'Toggles Trails', Default = true})
VisualsTab.TrailsBox:AddToggle('TrailRainbow', {Text = 'Rainbow', Default = false})
VisualsTab.TrailsBox:AddToggle('TrailColorOne', {Text = 'Trail Color One', Default = true}):AddColorPicker('TrailColors1', {Default = Color3.fromRGB(11, 11, 255)})
VisualsTab.TrailsBox:AddToggle('TrailColorTwo', {Text = 'Trail Color Two', Default = true}):AddColorPicker('TrailColors2', {Default = Color3.fromRGB(150, 150, 150)})

VisualsTab.TrailsBox:AddBlank(3);

VisualsTab.TrailsBox:AddSlider('TrailBrightness', {Text = 'Trail Brightness', Tooltip = 'Changes the trail brightness', Default = 10000, Min = 1, Max = 10000, Rounding = 0});
VisualsTab.TrailsBox:AddSlider('TrailLifetime', {Text = 'Trail Lifetime', Tooltip = 'Changes the trail lifetime', Default = 4, Min = 0.01, Max = 20, Rounding = 2});

-- [] Camera Box

VisualsTab.CameraTab:AddToggle('InfiniteZoom', {Text = 'Infinite Zoom', Tooltip = 'Toggles infinite zoom', Default = false}):OnChanged(function()
    CommandHandler.Execute('infzoom')
end)

VisualsTab.CameraTab:AddToggle('NoCameraShake', {Text = 'No Camera Shake', Tooltip = 'Disables camera shaking when someone spawns a mech', Default = true})

VisualsTab.CameraTab:AddBlank(3)

VisualsTab.CameraTab:AddSlider('FOV', {Text = 'Field Of View', Tooltip = 'Changes your field of view', Default = Originals.FOV, Min = 1, Max = 120, Rounding = 0}):OnChanged(function() 
    Camera.FieldOfView = Select.FOV.Value
end)

VisualsTab.CameraTab:AddDropdown('POV', {Text = 'Point Of View', Tooltip = 'Locks your POV', Values = {'Default', 'FirstPerson'}, Default = 'Default', Multi = false}):OnChanged(function()
    if Select.POV.Value == 'Default' then
        Host.CameraMode = 'Classic'
    end
end)

-- [] View Box

VisualsTab.ViewBox:AddToggle('Viewing', {Text = 'Viewing', Tooltip = 'Toggles view on a player', Default = false})

VisualsTab.ViewBox:AddToggle('WatchRejoinView', {Text = 'Toggle On Rejoin', Default = false})

-- [] Tools Box

VisualsTab.ToolsBox:AddToggle('ItemColors', {Text = 'Tool Colors', Tooltip = 'Allows you to make your tools look cool', Default = false}):AddColorPicker('ItemColoring', {Default = Colors.AccentColor})
VisualsTab.ToolsBox:AddToggle('ToolRainbow', {Text = 'Rainbow', Default = false})

VisualsTab.ToolsBox:AddBlank(2)

VisualsTab.ToolsBox:AddDropdown('ItemMaterial', {Text = 'Material', Values = {'ForceField', 'Glass', 'Glacier'}, Default = 'ForceField', Multi = false})
VisualsTab.ToolsBox:AddDropdown('ItemPattern', {Text = 'Pattern', Values = {'Distorted', 'Hex', 'Opium', 'Tracing', 'Framework', 'Custom', 'None'}, Default = 'Distorted', Multi = false})

VisualsTab.ToolsMoreBox:AddSlider('RainbowSpeed', {Text = 'Rainbow Speed', Default = 0.5, Min = 0.01, Max = 5, Rounding = 2});
VisualsTab.ToolsMoreBox:AddInput('ItemCustomPattern', {Text = 'Custom Pattern', Placeholder = 'Enter Texture ID', Tooltip = 'Must be using custom Pattern'})

-- Movement [] Fly Box

MovementTab.FlyTab:AddToggle('Flying', {Text = 'Flight', Tooltip = 'Toggles flying'}):OnChanged(function()
    if Boolean.Flying.Value then Fly() else KillFly() end
end)

Boolean.Flying:AddKeyPicker('FlightKeybind', {Default = 'F', SyncToggleState = true, Mode = 'Toggle', Text = 'Flight'}); Select.FlightKeybind:OnClick(function()
    if Boolean.Flying.Value then Fly() else KillFly() end
end)

MovementTab.FlyTab:AddBlank(3);

MovementTab.FlyTab:AddSlider('FlySpeed', {Text = 'Flight Speed', Tooltip = 'Changes your flying speed', Default = 4, Min = 1, Max = 40, Rounding = 0}):OnChanged(function()
    UpdateLabel()
end)

-- [] Player Box

MovementTab.PlayerTab:AddToggle('TpBypass', {Text = 'Tpbypass', Tooltip = 'Toggles tpbpyass (WILL RESET YOUR CHARACTER TO FUNCTION PROPERLY)'})

MovementTab.PlayerTab:AddToggle('InfiniteJump', {Text = 'Infinite Jump', Tooltip = 'Toggles infinite jump', Default = false}):OnChanged(function() 
    SetInfiniteJump(Boolean.InfiniteJump.Value)
end);

MovementTab.PlayerTab:AddToggle('InfiniteStam', {Text = 'Infinite Stamina', Tooltip = 'Toggles infinite stamina'}):OnChanged(function()
    UpdateLabel()
end);

MovementTab.PlayerTab:AddToggle('NoClip', {Text = 'No Clip', Tooltip = 'Toggles noclip'}):AddKeyPicker('NoClipKeybind', {Default = 'G', SyncToggleState = true, Mode = 'Toggle', Text = 'NoClip'}); Select.NoClipKeybind:OnClick(function()
    Notify('Noclip', 'Noclip is now '..tostring(Boolean.NoClip.Value))

    UpdateLabel();
end);

MovementTab.PlayerTab:AddToggle('NoSit', {Text = 'No Sit', Tooltip = 'Toggles no sit', Default = true}):OnChanged(function()
    for _, Index in next, Seats do
        Index.Disabled = Boolean.NoSit.Value
    end
end);

MovementTab.PlayerTab:AddToggle('NoVehicleSit', {Text = 'No Vehicle Sit', Tooltip = 'Turns off vehicle seats'}):OnChanged(function()
    for _, Index in next, VehicleSeats do
        Index.Disabled = Boolean.NoVehicleSit.Value
    end
end);

MovementTab.PlayerTab:AddToggle('NoSlow', {Text = 'No Slow', Tooltip = 'Toggles no slow', Default = true}):OnChanged(function()
    UpdateLabel()
end);

MovementTab.PlayerTab:AddToggle('Airwalk', {Text = 'Airwalk', Tooltip = 'Toggles airwalk'}):AddKeyPicker('AirwalkKeybind', {Default = '', SyncToggleState = true, Mode = 'Toggle', Text = 'Airwalk'}) Boolean.Airwalk:OnChanged(function()
    if Boolean.Airwalk.Value then Airwalk() else KillAirwalk() end
end);

MovementTab.PlayerTab:AddDivider();

MovementTab.PlayerTab:AddSlider('WalkSpeed', {Text = 'Walking Speed', Tooltip = 'Changes your walking speed', Default = Originals.WalkSpeed, Min = 1, Max = 500, Rounding = 0}):OnChanged(function()
    UpdateLabel()
end);

MovementTab.PlayerTab:AddSlider('RunSpeed', {Text = 'Running Speed', Tooltip = 'Changes your running speed', Default = 25, Min = 1, Max = 500, Rounding = 0}):OnChanged(function()
    UpdateLabel()
end);

MovementTab.PlayerTab:AddSlider('CrouchSpeed', {Text = 'Crouch Speed', Tooltip = 'Changes your crouching speed', Default = 8, Min = 1, Max = 500, Rounding = 0}):OnChanged(function()
    UpdateLabel()
end);

MovementTab.PlayerTab:AddSlider('HipHeight', {Text = 'Hip Height', Tooltip = 'Changes your hip height', Default = Originals.HipHeight , Min = 0, Max = 50, Rounding = 1}):OnChanged(function()
    Humanoid.HipHeight = Select.HipHeight.Value or Originals.HipHeight
end);

MovementTab.PlayerTab:AddSlider('JumpPower', {Text = 'Jump Power', Tooltip = 'Changes your jump power', Default = Originals.JumpPower, Min = 0, Max = 500, Rounding = 0})

-- [] Blink Box

MovementTab.BlinkTab:AddToggle('Blink', {Text = 'Blink', Tooltip = 'Makes allows you to run', Default = true}):AddKeyPicker('BlinkKeybind', {Default = 'B', SyncToggleState = true, Mode = 'Toggle', Text = 'Blink'}) Boolean.Blink:OnChanged(function()
    Notify('Blink', 'Blink is now '..tostring(Boolean.Blink.Value))

    UpdateLabel();
end)

MovementTab.BlinkTab:AddToggle('LoopBlink', {Text = 'Loop Blink', Tooltip = 'Keeps blink on so you dont have to hold shift', Default = false})

MovementTab.BlinkTab:AddBlank(3);

MovementTab.BlinkTab:AddSlider('BlinkSpeed', {Text = 'Blink Speed', Tooltip = 'Changes your blink speed', Default = 4, Min = 0, Max = 250, Rounding = 0}):OnChanged(function()
    UpdateLabel()
end);

MovementTab.BlinkTab:AddDropdown('BlinkMethod', {Text = 'Blink Method', Tooltip = 'Changes how your blink moves', Values = {'Movedirection', 'Cframe', 'Lookvector'}, Default = 'Movedirection', Multi = false}):OnChanged(function()
    UpdateLabel()
end);

-- [] Teleport Box

MovementTab.TeleportTab:AddToggle('ClickTp', {Text = 'Click Teleport', Tooltip = 'Teleports you to where ever your mouse is', Default = false}):AddKeyPicker('ClickTpKeybind', {Default = '', SyncToggleState = false, Mode = 'Toggle', Text = 'ClickTp'}) Select.ClickTpKeybind:OnClick(function()
    if Boolean.ClickTp.Value then
        TeleportTo(CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0)))
    end
end)

MovementTab.TeleportTab:AddBlank(3)

MovementTab.TeleportTab:AddSlider('TeleportDelay', {Text = 'Teleport Delay', Tooltip = 'Deleys your teleport', Default = 0.25, Min = 0, Max = 10, Rounding = 2});

-- [] Kick Players Box

-- World [] World Box

WorldTab.WorldCmds:AddToggle('Ambient', {Text = 'Ambient', Tooltip = 'Changes the worlds ambient color'}):AddColorPicker('AmbientColor', {Default = Colors.AccentColor})
WorldTab.WorldCmds:AddToggle('TintColor', {Text = 'Tint Color', Tooltip = 'Changes the worlds tint'}):AddColorPicker('TintColor', {Default = Colors.AccentColor})
WorldTab.WorldCmds:AddToggle('OutdoorAmbient', {Text = 'Outdoor Ambient', Tooltip = 'Changes the outdoor ambient color'}):AddColorPicker('OutdoorAmbientColor', {Default = Colors.AccentColor})
WorldTab.WorldCmds:AddToggle('FogColor', {Text = 'Fog Color', Tooltip = 'Changes the fog color'}):AddColorPicker('FogColor', {Default = Colors.AccentColor})
WorldTab.WorldCmds:AddToggle('Brightness', {Text = 'Brightness', Tooltip = 'Toggles brightness'})
WorldTab.WorldCmds:AddToggle('ShadowSoftness', {Text = 'Shadow Softness', Tooltip = 'Toggles shadowsoftness'})

WorldTab.WorldCmds:AddToggle('GlobalShadows', {Text = 'Global Shadows', Tooltip = 'Toggles globalshadows', Default = true}):OnChanged(function()
    Utils.Lighting.GlobalShadows = Boolean.GlobalShadows.Value
end)

WorldTab.WorldCmds:AddToggle('Exposure', {Text = 'Exposure', Tooltip = 'Toggles exposure'})
WorldTab.WorldCmds:AddToggle('FogEnd', {Text = 'Fod End', Tooltip = 'Toggles fogend'})
WorldTab.WorldCmds:AddToggle('Clock', {Text = 'Time Of Day', Tooltip = 'Toggles timeofday'})

WorldTab.WorldCmds:AddToggle('Gravity', {Text = 'Gravity', Tooltip = 'Toggles gravity'}):OnChanged(function()
    if not Boolean.Gravity.Value then
        Utils.Workspace.Gravity = Originals.Gravity;
    end
end)

WorldTab.WorldCmds:AddToggle('LightColoring', {Text = 'Light Coloring', Tooltip = 'Changes all of the lights colors'}):AddColorPicker('LightColor', {Default = Colors.AccentColor})

WorldTab.WorldCmds:AddToggle('Pumpkin Color', {Text = 'Pumpkin Coloring'}):AddColorPicker('PumpkinColor', {Default = Colors.AccentColor}):OnChanged(function()
    for _, Index in next, Pumpkins do
        Index.Color = Select.PumpkinColor.Value
    end
end)

WorldTab.WorldCmds:AddDivider();

WorldTab.WorldCmds:AddSlider('Brightness', {Text = 'Brightness', Default = Utils.Lighting.Brightness, Min = 0, Max = 300, Rounding = 0});
WorldTab.WorldCmds:AddSlider('ShadowSoftness', {Text = 'Shadow Softness', Default = 0.25, Min = 0, Max = 1, Rounding = 2});
WorldTab.WorldCmds:AddSlider('Exposure', {Text = 'Exposure', Default = 0.25, Min = 0.01, Max = 1, Rounding = 2});
WorldTab.WorldCmds:AddSlider('FogEnd', {Text = 'Fog End', Default = 2000, Min = 1, Max = 5000, Rounding = 0});
WorldTab.WorldCmds:AddSlider('Clock', {Text = 'Time Of Day', Default = 6, Min = 0, Max = 24, Rounding = 0});

WorldTab.WorldCmds:AddSlider('Gravity', {Text = 'Gravity', Default = Utils.Workspace.Gravity, Min = 0, Max = 300, Rounding = 2}):OnChanged(function()
    if Boolean.Gravity.Value then
        Utils.Workspace.Gravity = Select.Gravity.Value
    end
end)

-- [] World 2 Box

WorldTab.World2Cmds:AddSlider('SunAngularSize', {Text = 'Sun Angular Size', Default = Utils.Lighting:FindFirstChildOfClass('Sky').SunAngularSize, Min = 0, Max = 60, Rounding = 0}):OnChanged(function()
    Utils.Lighting:FindFirstChildOfClass('Sky').SunAngularSize = Select.SunAngularSize.Value
end)

WorldTab.World2Cmds:AddSlider('MoonAngularSize', {Text = 'Moon Angular Size', Default = Utils.Lighting:FindFirstChildOfClass('Sky').MoonAngularSize, Min = 0, Max = 60, Rounding = 0}):OnChanged(function()
    Utils.Lighting:FindFirstChildOfClass('Sky').MoonAngularSize = Select.MoonAngularSize.Value
end)

WorldTab.World2Cmds:AddSlider('StarCount', {Text = 'Star Count', Default = Utils.Lighting:FindFirstChildOfClass('Sky').StarCount, Min = 0, Max = 5000, Rounding = 0}):OnChanged(function()
    Utils.Lighting:FindFirstChildOfClass('Sky').StarCount = Select.StarCount.Value
end)

--[[World2Cmds:AddSlider('BloomSize', {Text = 'Bloom Size', Default = Utils.Lighting:FindFirstChildOfClass('BloomEffect').Size, Min = 0, Max = 5000, Rounding = 0}):OnChanged(function()
    Utils.Lighting:FindFirstChildOfClass('BloomEffect').Size = Select.BloomSize.Value
end)]] -- Only for prison, not worth it

WorldTab.World2Cmds:AddDivider();

WorldTab.World2Cmds:AddInput('MoonTextureId', {Text = 'Moon Texture Id', Placeholder = 'Enter ID', Tooltip = 'Changes the moons texture'}):OnChanged(function()
    Utils.Lighting:FindFirstChildOfClass('Sky').MoonTextureId = Select.MoonTextureId.Value
end)

WorldTab.World2Cmds:AddInput('SunTextureId', {Text = 'Sun Texture Id', Placeholder = 'Enter ID', Tooltip = 'Changes the suns texture'}):OnChanged(function()
    Utils.Lighting:FindFirstChildOfClass('Sky').SunTextureId = Select.SunTextureId.Value
end)

-- [] Boombox Box

WorldTab.BoomboxBox:AddToggle('MuteBoombox', {Text = 'Mute Boomboxes', Tooltip = 'Mutes boomboxes', Default = false})
WorldTab.BoomboxBox:AddToggle('ExcludeOwner', {Text = 'Exclude Owner', Tooltip = 'Unmutes your own boombox', Default = true})
WorldTab.BoomboxBox:AddToggle('BoomboxEffects', {Text = 'Boombox Effects', Tooltip = 'Allows you to add reverb, chorus and distortion'})
WorldTab.BoomboxBox:AddSlider('BoomVolume', {Text = 'Volume', Default = 0.5, Min = 0, Max = 50, Rounding = 1})
WorldTab.BoomboxBox:AddSlider('BoomDistance', {Text = 'Distance', Default = 100, Min = 3, Max = 10000, Rounding = 0})

WorldTab.ReverbBox:AddToggle('Reverb', {Text = 'Reverb'})
WorldTab.ReverbBox:AddSlider('RWetLevel', {Text = 'Wet Level', Default = 0, Min = -80, Max = 20, Rounding = 0})
WorldTab.ReverbBox:AddSlider('RDryLevel', {Text = 'Dry Level', Default = -6, Min = -80, Max = 20, Rounding = 0})
WorldTab.ReverbBox:AddSlider('RDensity', {Text = 'Density', Default = 1, Min = 0, Max = 1, Rounding = 2})

WorldTab.DistortionBox:AddToggle('Distortion', {Text = 'Distortion'})
WorldTab.DistortionBox:AddSlider('DLevel', {Text = 'Level', Default = 0.75, Min = 0, Max = 1, Rounding = 2})

WorldTab.ChorusBox:AddToggle('Chorus', {Text = 'Chorus'})
WorldTab.ChorusBox:AddSlider('CMix', {Text = 'Mix', Default = 0.5, Min = 0, Max = 1, Rounding = 2})
WorldTab.ChorusBox:AddSlider('CRate', {Text = 'Rate', Default = 0.5, Min = 0, Max = 20, Rounding = 1})
WorldTab.ChorusBox:AddSlider('CDepth', {Text = 'Depth', Default = 0.15, Min = 0, Max = 1, Rounding = 2})

-- Misc [] Misc Box

MiscTab.MiscBox:AddToggle('Chat', {Text = 'Chat', Tooltip = 'Toggles the chat UI', Default = true}):OnChanged(function()
    CommandHandler.Execute('showchat');
end)

MiscTab.MiscBox:AddToggle('LowCashIndicator', {Text = 'Low Cash Indicator', Tooltip = 'Will notify you if your cash is below 200', Default = true})

MiscTab.MiscBox:AddBlank(3)

MiscTab.MiscBox:AddSlider('ChatSize', {Text = 'ChatSize', Default = 0.8, Min = 0.1, Max = 1.2, Rounding = 1}):OnChanged(function()
    if ExperienceChat:FindFirstChild('chatWindow') then
        ExperienceChat.chatWindow.Size = UDim2.fromScale(1, Select.ChatSize.Value);
    end
end)

-- [] Script Box

MiscTab.Script:AddToggle('Watermark', {Text = 'Watermark', Tooltip = 'Toggles the watermark for mawborn', Default = true}):OnChanged(function()
    OuterWatermark.Visible = Boolean.Watermark.Value;
end)

MiscTab.Script:AddToggle('Notifications', {Text = 'Notifications', Default = true})

MiscTab.Script:AddToggle('StreamMode', {Text = 'StreamMode', Tooltip = 'Toggles streammode'})
MiscTab.Script:AddDivider()

MiscTab.Script:AddToggle('LowAmmoIndicator', {Text = 'Low Ammo Indicator', Default = true})

MiscTab.Script:AddBlank(3)

MiscTab.Script:AddDropdown('BulletCounter', {Text = 'Bullet Counter Source', Tooltip = 'Changes how your bullet counter is shown', Values = {'From Gun', 'From Screen', 'Default'}, Default = 'From Gun', Multi = false})

-- [] Development Box

MiscTab.Development:AddToggle('DevMode', {Text = 'Development Mode', Tooltip = 'Allows you to use commands that I have deemed not ready (Could result in unwanted results)'}):OnChanged(function()
    if Boolean.DevMode.Value then
        Notify('Developer Mode', 'Be mindful of what commands you do, it could break the script or get you banned')
    end
end)

MiscTab.Development:AddButton('Dark Dex V3', function()
    CommandHandler.Execute('dex')
end)

MiscTab.Development:AddButton('Remote Spy', function()
    CommandHandler.Execute('rspy')
end)

-- [] Script Data Box

MiscTab.ScriptDataBox:AddToggle('AutoExec', {Text = 'Auto Execute', Tooltip = 'Auto executes the script', Default = FileHandler.AutoExecute})
MiscTab.ScriptDataBox:AddToggle('AutoRejoin', {Text = 'Auto Rejoin', Tooltip = 'Auto joins the game if you got kicked'})

MiscTab.ScriptDataBox:AddLabel('Moderator Detection')
MiscTab.ScriptDataBox:AddBlank(2)

MiscTab.ScriptDataBox:AddToggle('AdminDetection', {Text = 'Moderator Detection', Default = true}):AddColorPicker('Colors.ModeratorColor', {Default = Colors.ModeratorColor})
MiscTab.ScriptDataBox:AddToggle('KickOnJoin', {Text = 'Leave On Join', Tooltip = 'Leaves the game if an admin joins'})

-- [] Keybinds Box

MiscTab.MoreKeybinds:AddLabel(' Command Bar', false):AddKeyPicker('CommandBarKeybind', {Default = 'Period', SyncToggleState = true, Mode = 'Toggle', Text = 'CommandBar'});

-- [] Game Box

MiscTab.GameBox:AddButton('Rejoin', function()
    CommandHandler.Execute('rejoin')
end)

MiscTab.GameBox:AddButton('Exit', function()
    CommandHandler.Execute('exit')
end)

MiscTab.GameBox:AddButton('Swap', function()
    CommandHandler.Execute('swap')
end)

MiscTab.GameBox:AddButton('Server Hop', function()
    CommandHandler.Execute('serverhop')
end)

-- FUNCTION START [] Combat [] Aimlock Box

Select.AimlockKeybind:OnClick(function()
    if Select.AimlockMode.Value ~= 'Ciazware' then
        Notify('Aimlock', 'Aimlock is now '..tostring(Boolean.Aimlock.Value))
    end

    local ProcessedInput = DebounceFunc('ProcessedInput', true, Select.AutofireDelay.Value, FireAimlock)

    if Select.AimlockMode.Value == 'Ciazware' then
        task.spawn(function()
            while Utils.RunService.Heartbeat:Wait() do

                if Weapon and Weapon.Ammo then
                    if Weapon.Ammo.Value ~= 0 and Select.AimlockKeybind.Value and Utils.UserInputService:IsKeyDown(Enum.KeyCode[Select.AimlockKeybind.Value]) then
                        ProcessedInput();
                    end
                end
            end
        end)
    end

    if Select.AimlockMode.Value == 'Automatic' then
        task.spawn(function()
            while Select.AimlockMode.Value == 'Automatic'
                and Body and Utils.RunService.Heartbeat:Wait()
                and Boolean.Aimlock.Value do

                if Weapon and Weapon.Ammo and Weapon.Ammo.Value ~= 0 then
                    ProcessedInput();
                end
            end
        end)
    end
end);


Select.AimlockTargetKeybind:OnClick(function()
    local _Target = TargetPlayer()
    if not _Target or not _Target.Character then return end

    AimlockTarget = _Target;

    if Boolean.EspOnTargetted.Value then
        AddEsp(AimlockTarget)
    end

    Notify('Aimlock Target', 'Aimlock Target is now '..tostring(AimlockTarget.DisplayName) or tostring(AimlockTarget.Name));
    UpdateLabel();
end)


Boolean.AutomaticReload:OnChanged(function()
    getgenv().AutomaticReload = function()
        local ProcessHandler = DebounceFunc('ProcessReload', true, 0.6, mouse1click)

        task.spawn(function()
            while Boolean.AutomaticReload.Value and Debounce.ScriptLoaded do
                Utils.RunService.Heartbeat:Wait()
                
                if Weapon and Weapon.Ammo and Weapon.Clips then
                    local Ammo = Weapon.Ammo;
                    local Clips = Weapon.Clips

                    if Ammo and Clips and Ammo.Value == 0 and Clips.Value > 0 and not Utils.TagSystem().has(Body, 'reloading') then
                        ProcessHandler()
                    end
                end
            end
        end)
    end

    getgenv().AutomaticReload()
end)

-- [] Camlock Box

Select.CamlockKeybind:OnClick(function()
    if Boolean.Camlock.Value and AimlockTarget then
        CamlockTarget = AimlockTarget
    end
    Notify('Camlock', 'Camlock is now '..tostring(Boolean.Camlock.Value))
end);

-- [] Buy Items Box

Boolean.InstantPrompts:OnChanged(function()
    if Boolean.InstantPrompts.Value then
        Hash.ProcessingProxy = Utils.ProximityPromptService.PromptButtonHoldBegan:Connect(function(Prompt)
            fireproximityprompt(Prompt)
        end)
        
        Debounce.InstantPrompt = true
    end

    if not Boolean.InstantPrompts.Value and Debounce.InstantPrompt then
        
        if Hash.ProcessingProxy and Hash.ProcessingProxy.Connected then
            Hash.ProcessingProxy:Disconnect()
        end
    end
end)


Select.BuyAmmoKeybind:OnClick(function()
    if not Utils.Streets then return end

    if not Weapon or not Host:GetAttribute('HoldingTool') or not Weapon.Clips then
        Notify('Buy Ammo', '[Error]: No tool found or equip a tool with ammo')
        return
    end

    local SaveOldPos = Root.CFrame;
    Boolean.InstantPrompts.Value = true;
    -- Start Function []

    local BuyAmmo = PurchaseItem('Buy Ammo')

    if BuyAmmo and BuyAmmo.CFrame then
        TeleportTo(BuyAmmo.CFrame)
    end

    local Proxy = Hash.InitializePart:FindFirstChildOfClass('ProximityPrompt')

    if Proxy then
        task.wait(0.5)
        fireproximityprompt(Proxy)
        task.wait(0.5);
    end

    TeleportTo(SaveOldPos)
    Boolean.InstantPrompts.Value = false
end)


CombatTab.ItemPurchase:AddButton('Confirm', function()
    local SaveOldPos = Root.CFrame
    Boolean.InstantPrompts.Value = true;

    local function ActivatePrompt(Target: string)
        local Proxy = Hash.InitializePart:FindFirstChildOfClass('ProximityPrompt')
        if not Proxy or not Target then return false end

        TeleportTo(Target.CFrame)
        fireproximityprompt(Proxy)
        task.wait(0.5)

        if Hash.InitializePart.BrickColor == BrickColor.new(21) then
            TeleportTo(Target.CFrame)
            fireproximityprompt(Proxy)
            task.wait(0.5)
        end

        return true
    end

    while Utils.RunService.Heartbeat:Wait() do
        local InitialTarget = PurchaseItem(Select.ItemPurchase.Value)
        if not ActivatePrompt(InitialTarget) then break end

        if Backpack:FindFirstChild(Select.ItemPurchase.Value) then
            Debounce.BoughtItem = true
            break;
        else
            Debounce.BoughtItem = false
        end

        if not Debounce.TeleportCompleted then
            task.wait(12); break
        end
    end

    TeleportTo(SaveOldPos)
    Boolean.InstantPrompts.Value = false
    Debounce.BoughtItem = false
end)

-- [] Reset Box

Boolean.InfiniteForcefield:OnChanged(function()
    while task.wait(0.1) and Boolean.InfiniteForcefield.Value do
        DeathPosition = CFrame.new(Root.Position, Root.Position + (Root.CFrame.Rotation * Vector3.new(1, 0, 1)).Unit)

        replicatesignal(Host.ConnectDiedSignalBackend)
        task.wait(Utils.Players.RespawnTime - 0.01)
        replicatesignal(Host.Kill)
    end
end)

-- Visuals [] Kos Check Box

Boolean.KosCheck:OnChanged(function()
    local function OnPlayers(Player: Player)
        if not Player then return end

        local UserId = Player.UserId;

        if Boolean.KosCheck.Value and Utils.KosCheck(UserId) then
            AddEsp(Player)
        end

        if not Boolean.KosCheck.Value and Utils.KosCheck(UserId) then
            RemoveEsp(Player)
        end

        Player.CharacterAdded:Connect(function()
            if Boolean.KosCheck.Value and Utils.KosCheck(UserId) then
                AddEsp(Player)
            end
        end)
    end

    for _, Index in next, Utils.Players:GetPlayers() do
        if Index then OnPlayers(Index) end
    end
end)

-- Movement [] TpBypass Box

Boolean.TpBypass:OnChanged(function()
    TeleportBypass();

    Notify('Teleport Bypass','Teleport Bypass is now '..tostring(Boolean.TpBypass.Value))
end)

-- [] Auto Execute

Boolean.AutoExec:OnChanged(function()
    if Debounce.HasTouchedAE ~= Boolean.AutoExec.Value then
        Debounce.HasTouchedAE = true

        FileHandler.AutoExecute = Boolean.AutoExec.Value;
        FileHandler:UpdateFile();
    end
end)

-- [] Moderator Detection

Boolean.AdminDetection:OnChanged(function()
    local function OnPlayers(Player: Player)
        if not Player then return end

        local UserId = Player.UserId

        if Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Player) then
            AddEsp(Player)
        end

        if not Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Player) then
            RemoveEsp(Player)
        end

        Player.CharacterAdded:Connect(function()
            if Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Player) then
                AddEsp(Player)
            end
        end)
    end

    for _, Index in next, Utils.Players:GetPlayers() do
        if Index then OnPlayers(Index) end
    end
end)

-- [] Bullet Counter

Select.BulletCounter:OnChanged(function()
    GunInfoBillboard.Enabled = false;
    OtherClip.Visible = false;
    OtherAmmo.Visible = false;
    AmmoUi.Visible = false;

    if Utils.Streets and CurrentAmmo then
        CurrentAmmo.Visible = false;
    end

    if Select.BulletCounter.Value == 'From Gun' then
        GunInfoBillboard.Enabled = true;
    end

    if Select.BulletCounter.Value == 'From Screen' then
        OtherClip.Visible = true; 
        OtherAmmo.Visible = true;
    end

    if Select.BulletCounter.Value == 'Default' then
        AmmoUi.Visible = true

        if Utils.Streets and CurrentAmmo then
            CurrentAmmo.Visible = true;
        end
    end
end)

-- [] Command Bar Keybind

Select.CommandBarKeybind:OnClick(function()
    Debounce.CommandState = not Debounce.CommandState

    if Debounce.CommandState then
        OuterCommand:TweenPosition(UDim2.fromOffset(775, 25), 'InOut', 'Linear', 0.5, true);
        OuterCommandBar:TweenPosition(UDim2.fromScale(0, 1.005), 'InOut', 'Linear', 0.65, true);

        CommandBar.Text = '';
        task.wait()
        CommandBar:CaptureFocus();

    else
        OuterCommandBar:TweenPosition(UDim2.fromScale(0, 0.1), 'InOut', 'Linear', 0.25, true);
        OuterCommand:TweenPosition(UDim2.fromOffset(775, -300), 'InOut', 'Linear', 0.4, true)
    end
end)

end

-- Input []

local function OnInput(Arguments: InputObject, OnChatted: boolean)
    if Arguments.KeyCode == Enum.KeyCode.LeftShift then
        if not Boolean.LoopBlink.Value and Boolean.Blink.Value then
            Debounce.Blink = true;
        end

        if Boolean.NoSlow.Value then
            Hash.StoreWalkSpeed = Select.WalkSpeed.Value

            Select.WalkSpeed.Value = Select.RunSpeed.Value;
        end
    end


    if Arguments.UserInputType == Enum.UserInputType.MouseButton1 then
        if Boolean.Aimlock.Value and Select.AimlockMode.Value == 'New Manual' then
            FireAimlock();
        end
    end


    if Arguments.KeyCode == Enum.KeyCode.LeftControl then
        Debounce.Crouching = true;
    end


    if OnChatted then
        return;
    end


    if Arguments.KeyCode == Enum.KeyCode.W then
        Movement.W = true;
    end


    if Arguments.KeyCode == Enum.KeyCode.A then
        Movement.A = true;
    end


    if Arguments.KeyCode == Enum.KeyCode.S then
        Movement.S = true;
    end


    if Arguments.KeyCode == Enum.KeyCode.D then
        Movement.D = true;
    end
end


local function OnEnded(Arguments: InputObject)
    if Arguments.KeyCode == Enum.KeyCode.LeftShift then
        if not Boolean.LoopBlink.Value and Boolean.Blink.Value then
            Debounce.Blink = false;
        end

        if Boolean.NoSlow.Value then
            Select.WalkSpeed.Value = Hash.StoreWalkSpeed or Originals.WalkSpeed;
        end
    end
    

    if Arguments.KeyCode == Enum.KeyCode.LeftControl then
        Debounce.Crouching = false;
    end


    if Arguments.KeyCode == Enum.KeyCode.W then
        Movement.W = false;
    end


    if Arguments.KeyCode == Enum.KeyCode.A then
        Movement.A = false;
    end


    if Arguments.KeyCode == Enum.KeyCode.S then
        Movement.S = false;
    end


    if Arguments.KeyCode == Enum.KeyCode.D then
        Movement.D = false;
    end
end


local function WorkspaceDescendantAdded(Object: Instance)
    if not Object then return end

    FindBoomboxes(Object)
    FindRound(Object)

    if Object.Name == 'RandomSpawner' then
        Object:SetAttribute('Labeled', false)

        task.delay(2, function()
            FindPartsOnMap(Object)

            InsertItem(Items, Object)
        end)
    end
end


local function BodyDescendantAdded(Object: Instance)
    if not Object then return end

    FindBoomboxes(Object)
    FindTool(Object)
        
    if Object:IsA('Part') and Object.Name == 'Bone' then
        Host:SetAttribute('KnockedOut', true)
    end
end


local function BodyDescendantRemoving(Object: Instance)
    if not Object then return end

    if Object:IsA('Part') and Object.Name == 'Bone' then
        Host:SetAttribute('KnockedOut', false)
    end
end


local function BodyOnChild()
    local function OnAdded(Item: Instance)
        if not Item then return end

        if Item:IsA('Tool') then
            InitializeTool(Item);
        end
        
        task.delay(0.3, function()
            if TypeCheckTool(Item) then
                ItemColors(Item)
            end
        end)
    end

    local function OnRemoving(Item: Instance)
        if Item and Weapon and Weapon.Tool == Item then
            Weapon = nil;

            Host:SetAttribute('HoldingTool', false) -- Incase you delete the tool
        end
    end

    for _, Index in next, Body:GetChildren() do
        if Index and Index:IsA('Tool') then
            InitializeTool(Index);
            break;
        end
    end

    Body.ChildAdded:Connect(OnAdded)
    Body.ChildRemoved:Connect(OnRemoving)
end


local function OnCharacterAdded(Character: Model)
    Body = Character or Host.Character;
    Head = Body and Body:WaitForChild('Head');
    Humanoid = Body and Body:WaitForChild('Humanoid') or Body:FindFirstChildOfClass('Humanoid');
    Root = Body and Body:WaitForChild('HumanoidRootPart') or Humanoid.RootPart
    Torso = Body and Body:WaitForChild('Torso');

    PlayerGui = Host and Host:WaitForChild('PlayerGui');
    Hud = PlayerGui and PlayerGui:WaitForChild('HUD');
    CashUi = Hud and Hud:FindFirstChild('Cash');
    AmmoUi = Hud and Hud:FindFirstChild('Ammo');
    CurrentAmmo = Hud and Hud:FindFirstChild('CurrentAmmo');
    Backpack = Host and Host:WaitForChild('Backpack');
    GetMouse = Body and Body:FindFirstChild('GetMouse');

    Host:SetAttribute('Dead', false)
    Host:SetAttribute('TpBypass', false)
    Host:SetAttribute('KnockedOut', false)

    Humanoid:GetPropertyChangedSignal('Health'):Connect(AutoHeal)

    Body.DescendantAdded:Connect(BodyDescendantAdded);
    Body.DescendantRemoving:Connect(BodyDescendantRemoving);
    BodyOnChild();

    if Boolean.AutomaticReload.Value then
        getgenv().AutomaticReload()
    end

    if Boolean.InfiniteForcefield.Value and Root then
        Root.CFrame = DeathPosition
    end

    task.delay(0.1, function() -- Waiting for shit to load      
        if Select.BulletCounter.Value ~= 'Default' then
            AmmoUi.Visible = false;

            if Utils.Streets and CurrentAmmo then
                CurrentAmmo.Visible = false;
            end
        end
    end)

    Head:GetPropertyChangedSignal('LocalTransparencyModifier'):Connect(function()
        Debounce.FirstPerson = (Head.LocalTransparencyModifier == 1)
    end)

    if Utils.Streets then
        CashUi:GetPropertyChangedSignal('Text'):Connect(function()
            if Cash() < 200 and Boolean.LowCashIndicator.Value and not Debounce.LowCash then
                Notify('Low Cash', 'Cash is getting low and is under $200 dollars')

                Debounce.LowCash = true;
            end

            if Cash() >= 200 then
                Debounce.LowCash = false;
            end
        end)
    end

    Humanoid.Died:Connect(function()
        Host:SetAttribute('Dead', true)
    end)
end


local function OnPlayerAdded(Player: Player)
    if not Player then return end

    local _Player = tostring(Player);
    local UserId = Player.UserId;

    Player:SetAttribute('Knocked', false);

    if Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Player) then
        AddEsp(Player)

        Notify('Admin Detection', 'Admin: '.. Player.Name .. ' has joined')

        if Boolean.KickOnJoin.Value then
            game:shutdown() -- Better than Host.Kick(), it's near instant
        end
    end

    if Boolean.KosCheck.Value and Utils.KosCheck(UserId) or Debounce.EspAll then
        AddEsp(Player)
    end

    if Utils.CreatorCheck(UserId) then
        AddEsp(Player)

        Notify('Creator', 'Creator: '.. tostring(Player.Name) .. ' has joined')
    end

    if AimlockTarget then
        if _Player == AimlockTarget.Name then
            if Boolean.WatchRejoinAimlock.Value then
                Boolean.Aimlock.Value = true
                AddEsp(Player)
            end

            Notify('Aimlock Target Joined', 'Aimlock target: ' .. AimlockTarget.DisplayName .. ' has rejoined')
        end
    end

    if CamlockTarget then
        if _Player == CamlockTarget.Name and not _Player == AimlockTarget.Name then

            if Boolean.WatchRejoinCamlock.Value then
                Boolean.Camlock.Value = true
            end

            Notify('Camlock Target Joined', 'Camlock target: ' .. CamlockTarget.DisplayerName .. ' has rejoined')
        end
    end

    if ViewTarget then
        if _Player == ViewTarget.Name and not Boolean.Camlock.Value and CamlockTarget then

            if Boolean.WatchRejoinView.Value then
                Boolean.Viewing.Value = true;
            end

            Notify('View Target Joined', 'View target: ' .. ViewTarget.DisplayName .. ' has rejoined')
        end
    end

    if WatchRejoinTarget and _Player == WatchRejoinTarget.Name and not _Player == ViewTarget.Name and not _Player == CamlockTarget.Name and not _Player == AimlockTarget.Name then
        Notify('Watch On Rejoin', 'Watch On Rejoin target: ' .. WatchRejoinTarget.DisplayName .. ' has rejoined')
    end

    Player.CharacterAdded:Connect(function(Character: Model)
        if Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Player) then
            AddEsp(Player)
        end

        if Boolean.KosCheck.Value and Utils.KosCheck(UserId) then
            AddEsp(Player)
        end

        if Utils.CreatorCheck(UserId) then
            AddEsp(Player)
        end

        SendKnockedAttributes(Player, Character)
    end)
end


local function OnPlayerRemoving(Player: Player)
    if not Player then return end

    local _Player = Player and tostring(Player);
    local UserId = Player and Player.UserId;

    if Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Player) then
        Notify('Admin Detection', 'Admin: '.. tostring(Player.Name) .. ' has left')
    end

    if Utils.CreatorCheck(UserId) then
        Notify('Creator', 'Creator: '.. tostring(Player.Name) .. ' has left')
    end
    
    if table.find(EspConfig, Player) then
        RemoveEsp(Player)
    end

    --[[if _Player == KickPlayerTarget.Name then
        Notify('Kick Successful', 'Player was kicked') -- // XD
    end]]

    if AimlockTarget then
        if _Player == AimlockTarget.Name then
            Notify('Aimlock Target Left', 'Aimlock target: '..tostring(AimlockTarget.DisplayName))
            Boolean.Aimlock.Value = false;
        end
    end

    if CamlockTarget then
        if _Player == CamlockTarget.Name and not _Player == AimlockTarget.Name then -- If they are the aimlock target, then you dont need two notifications
            Notify('Camlock Target Left', 'Camlock target: '..tostring(CamlockTarget.DisplayName))
            Boolean.Camlock.Value = false
        end
    end

    if ViewTarget then
        if _Player == ViewTarget.Name then
            Notify('View Target Left', 'Viewing target: '..tostring(ViewTarget.DisplayName))
            Boolean.Viewing.Value = false
        end
    end

    if WatchRejoinTarget then
        if WatchRejoinTarget and _Player == WatchRejoinTarget.Name and not _Player == ViewTarget.Name and not _Player == CamlockTarget.Name and not _Player == AimlockTarget.Name then
            Notify('Watch On Rejoin', 'Watch On Rejoin target has left')
        end
    end
end


local function OnPlayers(Player: Player)
    if not Player then return end
    local UserId = Player and Player.UserId;

    if Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Player) then
        AddEsp(Player)

        Notify('Admin Detection', 'Admin: ' .. tostring(Player.Name) .. ' is in game')
    end

    if Boolean.KosCheck.Value and Utils.KosCheck(UserId) then
        AddEsp(Player)
    end

    if Utils.CreatorCheck(UserId) then
        AddEsp(Player)

        Notify('Creator', 'Creator: '.. tostring(Player.Name) .. ' is in game')
    end

    local _Character = Utils.Body(Player)
    if not _Character then return end;

    local _Head = Utils.Head(Player);
    if not _Head then return end;

    Player:SetAttribute('Knocked', false)

    if _Head:FindFirstChild('Bone') then
        Player:SetAttribute('Knocked', true)
    end

    SendKnockedAttributes(Player, _Character)

    Player.CharacterAdded:Connect(function(Character: Model)
        if Boolean.AdminDetection.Value and Utils.AdminCheck(UserId, Player) then
            AddEsp(Player)
        end

        if Boolean.KosCheck.Value and Utils.KosCheck(UserId) then
            AddEsp(Player)
        end

        if Utils.CreatorCheck(UserId) then
            AddEsp(Player)
        end

        SendKnockedAttributes(Player, Character)
    end)
end


local function CheatData()
    local TaggedItems = {
        {Tag = TagTools, Key = 'ProcessedItem', IsDelay = true, Delay = 0.05, Callback = ItemColors},
        {Tag = TagTrails, Key = 'ProcessedTrail', IsDelay = false, Delay = 0, Callback = BulletColors, Callback2 = BulletColors}, -- No delay, needs to process instantly
        {Tag = TagBoomboxes, Key = 'ProcessedBoombox', IsDelay = true, Delay = 0.05, Callback = Boombox},
    }

    Utils.UserInputService.InputBegan:Connect(OnInput);
    Utils.UserInputService.InputEnded:Connect(OnEnded);

    Utils.RunService.RenderStepped:Connect(OnRenderStepped);
    Utils.RunService.Heartbeat:Connect(OnHeartbeat);

    Host.CharacterAdded:Connect(OnCharacterAdded);
    Host.Chatted:Connect(CommandHandler.Execute);

    Utils.Players.PlayerAdded:Connect(OnPlayerAdded);
    Utils.Players.PlayerRemoving:Connect(OnPlayerRemoving);

    Body.DescendantAdded:Connect(BodyDescendantAdded);
    Utils.Workspace.DescendantAdded:Connect(WorkspaceDescendantAdded);

    Humanoid:GetPropertyChangedSignal('Health'):Connect(AutoHeal)

    Host:SetAttribute('KnockedOut', false)
    Host:SetAttribute('TpBypass', false)

    ChatSpy();
    HookData();
    GameData();
    BodyOnChild();

    TextProperties:TextBounds(InfoCursor, 190, 19)

    for _, Index in next, Utils.Players:GetPlayers() do
        if Index then OnPlayers(Index) end
    end

    for _, Index in next, Seats do
        if Index then Index.Disabled = Boolean.NoSit.Value end
    end

    for Index, _ in next, CommandHandler.Commands do
        Network:AddLabel(string.format('[%s]: Arguments: {%s} %s',
            CommandHandler.Commands[Index].Name,
            CommandHandler.Commands[Index].Arguments,
            CommandHandler.Commands[Index].Description
        ))
    end

    for _, Index in next, getinstances() do
        if Index and Index:IsA('Tool') then
            for _, Values in next, Index:GetDescendants() do
                if Values and Values:IsA('BasePart') and Values.CanCollide then
                    WhitelistedItems[Index.Name] = Index
                    Debounce.ItemsProcessed = true;
                end
            end
        end

        if Index:IsA('Sound') and Index.Name == 'SoundX' then
            Boomboxes[Index.Name] = Index
            Debounce.ProcessedBoombox = true;
        end
    end

    for _, Index in next, TaggedItems do
        if not Index then return end
        local Arguments = {Index.Callback}

        if Index.Callback2 then
            table.insert(Arguments, Index.Callback2)
        end

        Utils.CollectionService:GetInstanceAddedSignal(Index.Tag):Connect(DebounceFunc(Index.Key, Index.IsDelay, Index.Delay, unpack(Arguments)))
    end

    if Utils.Prison then
        Select.AimlockPart.Value = 'Head';

        Hash.PlaceSwap = 455366377;
    end

    if Utils.Streets then
        Select.AimlockPart.Value = 'HumanoidRootPart';

        Hash.PlaceSwap = 15852982099;
        GetMouse.OnClientInvoke = HookMouse;

        CashUi:GetPropertyChangedSignal('Text'):Connect(function()
            if Cash() < 200 and Boolean.LowCashIndicator.Value and not Debounce.LowCash then
                Notify('Low Cash', 'Cash is getting low and is under $200 dollars')

                Debounce.LowCash = true;
            end

            if Cash() >= 200 then
                Debounce.LowCash = false;
            end
        end)
    end

    Head:GetPropertyChangedSignal('LocalTransparencyModifier'):Connect(function()
        Debounce.FirstPerson = (Head.LocalTransparencyModifier == 1)
    end)

    Debounce.ScriptLoaded = true;
end


Host.OnTeleport:Connect(function()
    if Queueonteleport and FileHandler.AutoExecute then
        repeat Utils.RunService.Heartbeat:Wait() until game:IsLoaded()

        Queueonteleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Loadstring.lua"))()');
        clearteleportqueue();
    end
end)


local Connection; Connection = Utils.RunService.Heartbeat:Connect(function()
    if Boolean.AutoRejoin.Value and Utils.GuiService:GetErrorMessage() ~= '' then
        CommandHandler.Execute('rejoin');
        Connection:Disconnect();
    end
end)


CheatData();
Notify(Utils.Title(2),'Took '..math.floor(tick() - OsTime)..' Seconds\nPress period for command bar with ' .. #CommandHandler.Commands .. ' Commands!')
