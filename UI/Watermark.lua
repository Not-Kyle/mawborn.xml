local IdentifyExecuter, _ = identifyexecutor or getexecutorname;

local StringSub, StringFormat, Tostring = string.sub, string.format, tostring;
local TableFreeze = table.freeze;
local TaskWait, TaskDefer = task.wait, task.defer;
local Utf8Len, Utf8Offset = utf8.len, utf8.offset;
local OsDate = os.date;

local Executor = StringSub(Tostring(IdentifyExecuter()), 1, 4) or 'unknown';

local Watermark = {};
local UTF8 = {};
UTF8.__index = UTF8;

function UTF8.sub(Text: string, Start: number, End: number)
    local StartingByte = Utf8Offset(Text, Start);
    local EndingByte = Utf8Offset(Text, End + 1);

    if not StartingByte then
        return ''
    end

    return StringSub(Text, StartingByte, (EndingByte or (#Text + 1)) - 1)
end

local function Typewrite(Method: string?, Property: Instance?, Text: string?, Delay: number?) -- ? Allows nil processing
    if not Property or not Text then return end

    Method = Method or 'In';
    Delay = Delay or 0.1;

    if Method == 'Out' then
        for Index = 1, Utf8Len(Text), 1 do

            TaskWait(Delay)
            Property.Text = UTF8.sub(Text, 1, Index)
        end
    end

    if Method == 'In' then
        for Index = Utf8Len(Text), 0, -1 do

            TaskWait(Delay)
            Property.Text = UTF8.sub(Text, 1, Index)
        end
    end
end

function Watermark:MakeWatermark(Parent: string)
    local OuterWatermark = Instance.new("Frame")
    OuterWatermark.Name = "OuterWatermark"
    OuterWatermark.Parent = Parent
    OuterWatermark.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterWatermark.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
    OuterWatermark.BorderColor3 = Color3.fromRGB(0, 0, 0)
    OuterWatermark.BorderSizePixel = 0
    OuterWatermark.Position = UDim2.fromScale(0.848, 0.985)
    OuterWatermark.Size = UDim2.new(0, 572, 0, 22)

    local BorderInner = Instance.new("Frame")
    BorderInner.Name = "InnerWatermark"
    BorderInner.Parent = OuterWatermark
    BorderInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BorderInner.BorderColor3 = Color3.fromRGB(27, 27, 27)
    BorderInner.Position = UDim2.new(0.00329387072, 0, 0.0809742287, 0)
    BorderInner.Size = UDim2.new(0, 568, 0, 18)

    local InnerWatermark = Instance.new("Frame")
    InnerWatermark.Name = "InnerWatermark"
    InnerWatermark.Parent = OuterWatermark
    InnerWatermark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InnerWatermark.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InnerWatermark.BorderMode = Enum.BorderMode.Inset
    InnerWatermark.Position = UDim2.new(0.00329387072, 0, 0.0809742287, 0)
    InnerWatermark.Size = UDim2.new(0, 568, 0, 18)

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))}
    UIGradient.Rotation = -90
    UIGradient.Parent = InnerWatermark

    local TitleWatermark = Instance.new("TextLabel")
    TitleWatermark.Name = "TitleWatermark"
    TitleWatermark.Parent = InnerWatermark
    TitleWatermark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleWatermark.BackgroundTransparency = 1.000
    TitleWatermark.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleWatermark.BorderSizePixel = 0
    TitleWatermark.Position = UDim2.new(0.00600000005, 0, -0.0500000007, 0)
    TitleWatermark.Size = UDim2.new(0, 400, 0, 18)
    TitleWatermark.Font = Enum.Font.Code
    TitleWatermark.Text = ''
    TitleWatermark.TextColor3 = Color3.fromRGB(225, 225, 225)
    TitleWatermark.TextSize = 13.000
    TitleWatermark.TextStrokeTransparency = 0.500
    TitleWatermark.TextXAlignment = Enum.TextXAlignment.Left

    local TitleWatermark_2 = Instance.new("TextLabel")
    TitleWatermark_2.Name = "TitleWatermark"
    TitleWatermark_2.Parent = InnerWatermark
    TitleWatermark_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleWatermark_2.BackgroundTransparency = 1.000
    TitleWatermark_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleWatermark_2.BorderSizePixel = 0
    TitleWatermark_2.Position = UDim2.new(0.715, 0, -0.0500000007, 0)
    TitleWatermark_2.Size = UDim2.new(0, 190, 0, 18)
    TitleWatermark_2.Font = Enum.Font.Code
    TitleWatermark_2.Text = ''
    TitleWatermark_2.TextColor3 = Color3.fromRGB(225, 225, 225)
    TitleWatermark_2.TextSize = 13.000
    TitleWatermark_2.TextStrokeTransparency = 0.500
    TitleWatermark_2.TextXAlignment = Enum.TextXAlignment.Left

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = OuterWatermark

    TaskDefer(function()
        while TaskWait() do
            local PrintLn = StringFormat('mawborn.xml | executor: %s | %s',
                Executor,
                OsDate('%a, %b %d, %I:%M %p %Y')
            )

            Typewrite('Out', TitleWatermark, PrintLn, 0.1)
            TaskWait(30)
            Typewrite('In', TitleWatermark, PrintLn, 0.1)
        end
    end)

    return TitleWatermark_2, OuterWatermark;
end

return TableFreeze(Watermark);
