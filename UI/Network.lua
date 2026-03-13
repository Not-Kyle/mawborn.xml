local Window = {};

function Window:MakeCommandCenter(Parent: string)
    local Network = {};

    Network.OuterCommand = Instance.new('Frame')
    Network.OuterCommand.Name = 'OuterCommand'
    Network.OuterCommand.Parent = Parent
    Network.OuterCommand.AnchorPoint = Vector2.new(0, -0.5)
    Network.OuterCommand.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    Network.OuterCommand.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Network.OuterCommand.BorderSizePixel = 0
    Network.OuterCommand.Position = UDim2.new(0, 775, 0, -300)
    Network.OuterCommand.Size = UDim2.new(0, 350, 0, 120)

    local UICorner = Instance.new('UICorner')
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = Network.OuterCommand

    local BorderInner = Instance.new('Frame')
    BorderInner.Name = 'BorderInner'
    BorderInner.Parent = Network.OuterCommand
    BorderInner.BackgroundColor3 =Color3.fromRGB(255, 255, 255)
    BorderInner.BorderColor3 = Color3.fromRGB(27, 27, 27)
    BorderInner.Position = UDim2.new(0.006, 0, 0.02, 0)
    BorderInner.Size = UDim2.new(0, 346, 0, 116)

    local InnerCommand = Instance.new('Frame')
    InnerCommand.Name = 'InnerCommand'
    InnerCommand.Parent = Network.OuterCommand
    InnerCommand.BackgroundColor3 =Color3.fromRGB(255, 255, 255)
    InnerCommand.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InnerCommand.BorderMode = Enum.BorderMode.Inset
    InnerCommand.Position = UDim2.new(0.006, 0, 0.02, 0)
    InnerCommand.Size = UDim2.new(0, 346, 0, 116)

    local CommandList = Instance.new('ScrollingFrame')
    CommandList.Name = 'CommandList'
    CommandList.Parent = InnerCommand
    CommandList.Active = true
    CommandList.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CommandList.BackgroundTransparency = 1.000
    CommandList.BorderColor3 = Color3.fromRGB(0, 0, 0)
    CommandList.BorderSizePixel = 0
    CommandList.Position = UDim2.new(0.0175438598, 0, 0.0530973449, 0)
    CommandList.Size = UDim2.new(0, 335, 0, 107)
    CommandList.BottomImage = 'http://www.roblox.com/asset/?id=86927157225558'
    CommandList.CanvasSize = UDim2.new(3, 0, 6, 0)
    CommandList.MidImage = 'http://www.roblox.com/asset/?id=95591733073455'
    CommandList.ScrollBarThickness = 4
    CommandList.TopImage = 'http://www.roblox.com/asset/?id=115122166951013'
    CommandList.ScrollBarImageColor3 = Color3.new(130, 130, 195)

    local UIListLayout = Instance.new('UIListLayout')
    UIListLayout.Parent = CommandList
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    function Network:AddLabel(Message: string)
        local CommandLabel = Instance.new('TextLabel')
        CommandLabel.Parent = CommandList
        CommandLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        CommandLabel.BackgroundTransparency = 1.000
        CommandLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        CommandLabel.BorderSizePixel = 0
        CommandLabel.Size = UDim2.new(0, 322, 0, 15)
        CommandLabel.Font = Enum.Font.Code
        CommandLabel.Text = Message
        CommandLabel.TextColor3 = Color3.fromRGB(225, 225, 225)
        CommandLabel.TextSize = 14.000
        CommandLabel.TextStrokeTransparency = 0.500
        CommandLabel.TextXAlignment = Enum.TextXAlignment.Left
    end

    local UIGradient = Instance.new('UIGradient')
    UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))}
    UIGradient.Rotation = -90
    UIGradient.Parent = InnerCommand

    Network.OuterCommandBar = Instance.new('Frame')
    Network.OuterCommandBar.Name = 'OuterCommandBar'
    Network.OuterCommandBar.Parent = Network.OuterCommand
    Network.OuterCommandBar.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
    Network.OuterCommandBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Network.OuterCommandBar.BorderSizePixel = 0
    Network.OuterCommandBar.Position = UDim2.new(0, 0, 0.1, 0)
    Network.OuterCommandBar.Size = UDim2.new(0, 350, 0, 30)

    local UICorner_2 = Instance.new('UICorner')
    UICorner_2.CornerRadius = UDim.new(0, 4)
    UICorner_2.Parent = Network.OuterCommandBar

    local BorderInnerCommandBar = Instance.new('Frame')
    BorderInnerCommandBar.Name = 'InnerCommandBar'
    BorderInnerCommandBar.Parent = Network.OuterCommandBar
    BorderInnerCommandBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BorderInnerCommandBar.BorderColor3 = Color3.fromRGB(27, 27, 27)
    BorderInnerCommandBar.Position = UDim2.new(0.005, 0, 0.08, 0)
    BorderInnerCommandBar.Size = UDim2.new(0, 346, 0, 26)

    local InnerCommandBar = Instance.new('Frame')
    InnerCommandBar.Name = 'InnerCommandBar'
    InnerCommandBar.Parent = Network.OuterCommandBar
    InnerCommandBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    InnerCommandBar.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InnerCommandBar.BorderMode = Enum.BorderMode.Inset
    InnerCommandBar.Position = UDim2.new(0.005, 0, 0.08, 0)
    InnerCommandBar.Size = UDim2.new(0, 346, 0, 26)

    Network.CommandBar = Instance.new('TextBox')
    Network.CommandBar.Name = 'CommandBar'
    Network.CommandBar.Parent = InnerCommandBar
    Network.CommandBar.BackgroundColor3 = Color3.fromRGB(17, 14, 18)
    Network.CommandBar.BackgroundTransparency = 1.000
    Network.CommandBar.BorderColor3 = Color3.fromRGB(47, 47, 47)
    Network.CommandBar.BorderSizePixel = 0
    Network.CommandBar.Position = UDim2.new(0.032352943, 0, 0, 0)
    Network.CommandBar.Size = UDim2.new(0, 329, 0, 20)
    Network.CommandBar.Font = Enum.Font.Code
    Network.CommandBar.PlaceholderColor3 = Color3.fromRGB(225, 225, 225)
    Network.CommandBar.PlaceholderText = 'Type a command or search...'
    Network.CommandBar.Text = ''
    Network.CommandBar.TextColor3 = Color3.fromRGB(225, 225, 225)
    Network.CommandBar.TextSize = 14.000
    Network.CommandBar.TextStrokeTransparency = 0.500

    local UIGradient_2 = Instance.new('UIGradient')
    UIGradient_2.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))}
    UIGradient_2.Rotation = -90
    UIGradient_2.Parent = InnerCommandBar

    return Network;
end

return Window;
