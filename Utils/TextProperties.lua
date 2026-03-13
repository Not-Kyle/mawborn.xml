if getgenv().Mawborn.TextProperties then
    return
end

local MathMax = math.max;
local UD2fromOffset = UDim2.fromOffset;

local TextProperties = {};
TextProperties.__index = TextProperties;

local function SetTextBounds(Self: Instance, XAxis: number, YAxis: number)
    local SettingSize = UD2fromOffset(
        MathMax(XAxis, Self.TextBounds.X), 
        MathMax(YAxis, Self.TextBounds.Y)
    )

    Self.Size = SettingSize
end


local function SetAbsoluteSize(Self: Instance, Child: Instance, MinX: number, MinY: number, XAxis: number, YAxis: number)
    local Size = UD2fromOffset(
        MathMax(MinX, Child.AbsoluteSize.X + (XAxis or 0)),
        MathMax(MinY, Child.AbsoluteSize.Y + (YAxis or 0))
    )

    Self.Size = Size;
end


function TextProperties:TextBounds(Self: Instance, XAxis: number, YAxis: number) : RBXScriptConnection
    SetTextBounds(Self, XAxis, YAxis);

    local Connection = Self:GetPropertyChangedSignal('TextBounds'):Connect(function()
        SetTextBounds(Self, XAxis, YAxis)
    end)

    local KillConnection; KillConnection = Self.Destroying:Connect(function()
        Connection:Disconnect();

        if KillConnection then
            KillConnection:Disconnect();
        end
    end)

    return Connection;
end


function TextProperties:AbsoluteSize(Self: Instance, Child: Instance, MinX: number, MinY: number, XAxis: number, YAxis: number) : RBXScriptConnection
    SetAbsoluteSize(Self, Child, MinX, MinY, XAxis, YAxis)

    local Connection = Self:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
        SetAbsoluteSize(Self, Child, MinX, MinY, XAxis, YAxis)
    end)

    local KillConnection; KillConnection = Self.Destroying:Connect(function()
        Connection:Disconnect();

        if KillConnection then
            KillConnection:Disconnect();
        end
    end)

    return Connection;
end

return TextProperties;
