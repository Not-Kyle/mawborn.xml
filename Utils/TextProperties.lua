if getgenv().Mawborn.TextProperties then
    return
end

local TextProperties = {};
TextProperties.__index = TextProperties;

local function SetTextBounds(Self: Instance, XAxis: number, YAxis: number)
    local SettingSize = UDim2.fromOffset(
        math.max(XAxis, Self.TextBounds.X), 
        math.max(YAxis, Self.TextBounds.Y)
    )

    Self.Size = SettingSize
end


local function SetAbsoluteSize(Self: Instance, Child: Instance, MinX: number, MinY: number, XAxis: number, YAxis: number)
    local Size = UDim2.fromOffset(
        math.max(MinX, Child.AbsoluteSize.X + (XAxis or 0)),
        math.max(MinY, Child.AbsoluteSize.Y + (YAxis or 0))
    )

    Self.Size = Size;
end


function TextProperties:TextBounds(Self: Instance, XAxis: number, YAxis: number) : RBXScriptConnection
    SetTextBounds(Self, XAxis, YAxis);
    
    return Self:GetPropertyChangedSignal('TextBounds'):Connect(function()
        SetTextBounds(Self, XAxis, YAxis)
    end)
end


function TextProperties:AbsoluteSize(Self: Instance, Child: Instance, MinX: number, MinY: number, XAxis: number, YAxis: number) : RBXScriptConnection
    SetAbsoluteSize(Self, Child, MinX, MinY, XAxis, YAxis)

    return Self:GetPropertyChangedSignal('AbsoluteSize'):Connect(function()
        SetAbsoluteSize(Self, Child, MinX, MinY, XAxis, YAxis)
    end)
end

return TextProperties;
