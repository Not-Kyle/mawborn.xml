local mawborn = getgenv().mawborn;

local Window = {};
local TextProperties = {};
TextProperties.__index = TextProperties;

function NewInstance(Type: string, Class: string, Properties: any) -- Thanks to Xaxa
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

function SetTextBounds(Self: Instance, XAxis: number, YAxis: number)
    local SettingSize = UDim2.fromOffset(math.max(XAxis, Self.TextBounds.X), math.max(YAxis, Self.TextBounds.Y))
    Self.Size = SettingSize
end

function TextProperties.new(Self: Instance, XAxis: number, YAxis: number) : RBXScriptConnection
    return Self.GetPropertyChangedSignal(Self, 'TextBounds'):Connect(function()
        SetTextBounds(Self, XAxis, YAxis)
    end)
end

function Window:MakeInformationLabel(Text: string, PositionX: number, PositionY: number)
    Text = Text or 'Label';
    PositionX = PositionX or 0.3;
    PositionY = PositionY or 0.88;

    local Outer = NewInstance('Instance', 'Frame', {
        Parent = mawborn;
        BackgroundColor3 = Color3.fromRGB(18, 18, 18);
        BorderColor3 = Color3.fromRGB(18, 18, 18);
        BorderSizePixel = 0;
        Position = UDim2.fromScale(PositionX, PositionY);
        Size = UDim2.new(0, 102, 0, 22);
    })

    local UiCorner = NewInstance('Instance', 'UICorner', {
        CornerRadius = UDim.new(0, 4);
        Parent = Outer;
    }) 

    local Inner = NewInstance('Instance', 'Frame', {
        Parent = Outer;
        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        BorderColor3 = Color3.fromRGB(0, 0, 0);
        Position = UDim2.new(0.02, 0, 0.1, 0);
        Size = UDim2.new(0, 98, 0, 18);
    })

    local UIGradient = NewInstance('Instance', 'UIGradient', {
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), 
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))
        };

        Rotation = -90;
        Parent = Inner;
    })

    local TextLabel = NewInstance('Instance', 'TextLabel', {
        Parent = Inner;
        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        BackgroundTransparency = 1;
        BorderColor3 = Color3.fromRGB(0, 0, 0);
        BorderSizePixel = 0;
        Position = UDim2.new(0, 0, -0.08, 0);
        Font = Enum.Font.Code;
        Text = Text;
        TextColor3 = Color3.fromRGB(225, 225, 225);
        TextSize = 13;
        TextStrokeTransparency = 0;
    })

    TextProperties.new(TextLabel, 98, 18);
end

return Window
