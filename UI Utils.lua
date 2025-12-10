local mawborn = getgenv().mawborn;
local Window = {};

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

function Window:MakeInformationLabel(Text: string, PositionX: number, PositionY: number)
    Text = Text or 'Label';
    PositionX = PositionX or 0.34;
    PositionY = PositionY or 0.83;

    local Outer = NewInstance('Instance', 'Frame', {
        Parent = mawborn;
        BackgroundColor3 = Color3.fromRGB(18, 18, 18);
        BorderColor3 = Color3.fromRGB(18, 18, 18);
        BorderSizePixel = 0;
        Position = UDim2.fromScale(PositionX, PositionY);
        Size = UDim2.new(0, 100, 0, 20);
    })

    local UiCorner = NewInstance('Instance', 'UICorner', {
        UICorner_CornerRadius = UDim.new(0, 4);
        UICorner_Parent = Outer;
    }) 

    local Inner = NewInstance('Instance', 'Frame', {
        Parent = Outer;
        BackgroundColor3 = Color3.fromRGB(255, 255, 255);
        BorderColor3 = Color3.fromRGB(0, 0, 0);
        Position = UDim2.new(0.01, 0, 0.05, 0);
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
        Size = UDim2.new(0, 98, 0, 18);
        Font = Enum.Font.Code;
        Text = Text;
        TextColor3 = Color3.fromRGB(225, 225, 225);
        TextSize = 13;
        TextStrokeTransparency = 0;
    })
end

return Window
