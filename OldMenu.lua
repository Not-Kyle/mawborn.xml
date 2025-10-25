getgenv().Public = setmetatable({}, {
    __index = function(self, ...)
        local Arguments = { ... };

        return getgenv()[Arguments[1]]
    end
})

Public.Script = {
    AccentColor  = Color3.fromRGB(170, 170, 255);
    BorderColor  = Color3.fromRGB(27, 27, 27);
    ScriptColor  = Color3.fromRGB(255, 255, 255);
    TextColor    = Color3.fromRGB(225, 225, 225);
    InboundColor = Color3.fromRGB(15, 15, 15);
}

local TextProperties = {};
TextProperties.__index = TextProperties;
local Window = {};

function SetTextBounds(Self: string, XAxis: number, YAxis: number)
    local SettingSize = UDim2.new(0, math.max(XAxis, Self.TextBounds.X), 0, math.max(YAxis, Self.TextBounds.Y))
    Self.Size = SettingSize
end


function TextProperties.new(Self: string, XAxis: number, YAxis: number)
    return { Self.GetPropertyChangedSignal(Self, 'TextBounds'):Connect(function()
        SetTextBounds(Self, XAxis, YAxis)
    end) }
end

function Window:MakeWindow(...)
    local Arguments = {...}
    local Network = {};
    local SubNetwork = {};

    Network.ScreenGui = Arguments[1];
    Network.Title = Arguments[2];

    OuterUI = Instance.new("Frame")
    OuterUI.Name = "OuterUI"
    OuterUI.Parent = Network.ScreenGui
    OuterUI.AnchorPoint = Vector2.new(0.5, 0.5)
    OuterUI.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    OuterUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
    OuterUI.BorderSizePixel = 0
    OuterUI.Position = UDim2.new(0.742671013, 0, 0.636934757, 0)
    OuterUI.Size = UDim2.new(0, 604, 0, 354)
    OuterUI.Selectable = true;
    OuterUI.Draggable = true;
    OuterUI.Active = true;

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 4)
    UICorner.Parent = OuterUI

    local BorderInnerUI = Instance.new("Frame")
    BorderInnerUI.Name = "InnerUI"
    BorderInnerUI.Parent = OuterUI
    BorderInnerUI.BackgroundColor3 = Color3.fromRGB(185, 185, 185)
    BorderInnerUI.BorderColor3 = Public.Script.BorderColor
    BorderInnerUI.Position = UDim2.new(0.003, 0, 0.0075, 0)
    BorderInnerUI.Size = UDim2.new(0, 600, 0, 350)

    local InnerUI = Instance.new("Frame")
    InnerUI.Name = "InnerUI"
    InnerUI.Parent = OuterUI
    InnerUI.BackgroundColor3 = Color3.fromRGB(185, 185, 185)
    InnerUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
    InnerUI.BorderMode = Enum.BorderMode.Inset
    InnerUI.Position = UDim2.new(0.003, 0, 0.0075, 0)
    InnerUI.Size = UDim2.new(0, 600, 0, 350)

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), 
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))
    }
    UIGradient.Rotation = -90
    UIGradient.Parent = InnerUI

    local TitleUI = Instance.new("TextLabel")
    TitleUI.Name = "TitleUI"
    TitleUI.Parent = InnerUI
    TitleUI.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TitleUI.BackgroundTransparency = 1
    TitleUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TitleUI.BorderSizePixel = 0
    TitleUI.Position = UDim2.new(0.00999999978, 0, 0, 0)
    TitleUI.Size = UDim2.new(0, 574, 0, 20)
    TitleUI.Font = Enum.Font.Code
    TitleUI.Text = Network.Title
    TitleUI.TextColor3 = Public.Script.TextColor
    TitleUI.TextSize = 14
    TitleUI.TextStrokeTransparency = 0.500
    TitleUI.TextXAlignment = Enum.TextXAlignment.Left

    local ExitButtonUI = Instance.new("TextButton")
    ExitButtonUI.Name = "ExitButtonUI"
    ExitButtonUI.Parent = InnerUI
    ExitButtonUI.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ExitButtonUI.BackgroundTransparency = 1
    ExitButtonUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
    ExitButtonUI.BorderSizePixel = 0
    ExitButtonUI.Position = UDim2.new(0.966666639, 0, 0, 0)
    ExitButtonUI.Size = UDim2.new(0, 20, 0, 20)
    ExitButtonUI.Font = Enum.Font.Code
    ExitButtonUI.Text = "X"
    ExitButtonUI.TextColor3 = Public.Script.TextColor
    ExitButtonUI.TextSize = 18
    ExitButtonUI.TextStrokeTransparency = 0.500

    local BorderFirstFrame = Instance.new("Frame")
    BorderFirstFrame.Name = "FirstFrame"
    BorderFirstFrame.Parent = InnerUI
    BorderFirstFrame.BackgroundColor3 = Public.Script.TextColor
    BorderFirstFrame.BorderColor3 = Public.Script.BorderColor
    BorderFirstFrame.Position = UDim2.new(0.009, 0, 0.0771429464, 0)
    BorderFirstFrame.Size = UDim2.new(0, 588, 0, 317)

    local FirstFrame = Instance.new("Frame")
    FirstFrame.Name = "FirstFrame"
    FirstFrame.Parent = InnerUI
    FirstFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
    FirstFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    FirstFrame.BorderMode = Enum.BorderMode.Inset
    FirstFrame.Position = UDim2.new(0.009, 0, 0.0771429464, 0)
    FirstFrame.Size = UDim2.new(0, 588, 0, 317)

    local UIGradient_2 = Instance.new("UIGradient")
    UIGradient_2.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), 
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))
    }
    UIGradient_2.Rotation = -90
    UIGradient_2.Parent = FirstFrame

    local BorderTabFrame = Instance.new("Frame")
    BorderTabFrame.Name = "TabFrame"
    BorderTabFrame.Parent = FirstFrame
    BorderTabFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    BorderTabFrame.BorderColor3 = Public.Script.BorderColor
    BorderTabFrame.Position = UDim2.new(0.0100000082, 0, 0.0850000232, 0)
    BorderTabFrame.Size = UDim2.new(0, 576, 0, 281)

    local TabFrame = Instance.new("Frame")
    TabFrame.Name = "TabFrame"
    TabFrame.Parent = FirstFrame
    TabFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    TabFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabFrame.BorderMode = Enum.BorderMode.Inset
    TabFrame.Position = UDim2.new(0.0100000082, 0, 0.0850000232, 0)
    TabFrame.Size = UDim2.new(0, 576, 0, 281)

    local Ignore = Instance.new("Frame")
    Ignore.Name = "Ignore"
    Ignore.Parent = FirstFrame
    Ignore.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    Ignore.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Ignore.BorderSizePixel = 0
    Ignore.Position = UDim2.new(0.01, 0, 0.08, 0)
    Ignore.Size = UDim2.new(0, 100, 0, 5)
    Ignore.ZIndex = 2

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = FirstFrame
    TabContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0.00999990478, 0, 0.0189274456, 0)
    TabContainer.Size = UDim2.new(0, 575, 0, 20)

    local UIListLayoutTab = Instance.new("UIListLayout")
    UIListLayoutTab.Parent = TabContainer
    UIListLayoutTab.FillDirection = Enum.FillDirection.Horizontal
    UIListLayoutTab.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayoutTab.VerticalAlignment = Enum.VerticalAlignment.Center

    function SubNetwork:MakeTab(Title: string)
        local Sections = {
            Tabs = {};
        };

        Sections.Tabs[#Sections.Tabs + 1] = {Name = Title};

        local BorderTabButton = Instance.new("TextButton")
        BorderTabButton.Name = "TabButton"
        BorderTabButton.Parent = TabContainer
        BorderTabButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        BorderTabButton.BorderColor3 = Public.Script.BorderColor
        BorderTabButton.Position = UDim2.new(0.00999999978, 0, 0.0189999994, 0)
        BorderTabButton.Size = UDim2.new(0, 100, 0, 20)
        BorderTabButton.Font = Enum.Font.Code
        BorderTabButton.Text = Title or 'Tab';
        BorderTabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        BorderTabButton.TextSize = 14
        BorderTabButton.TextStrokeTransparency = 0.500
        TextProperties.new(BorderTabButton, 100, 20)

        local TabButton = Instance.new("TextButton")
        TabButton.Name = "TabButton"
        TabButton.Parent = BorderTabButton
        TabButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        TabButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabButton.BorderMode = Enum.BorderMode.Inset
        TabButton.Position = UDim2.new(0, 0, 0, 0)
        TabButton.Size = UDim2.new(0, 100, 0, 20)
        TabButton.Font = Enum.Font.Code
        TabButton.Text = Title or 'Tab';
        TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabButton.TextSize = 14
        TabButton.TextStrokeTransparency = 0.500
        TextProperties.new(TabButton, 100, 20)

        local TabScrollFrame = Instance.new("ScrollingFrame")
        TabScrollFrame.Name = "TabScrollFrame"
        TabScrollFrame.Parent = TabFrame
        TabScrollFrame.Active = true
        TabScrollFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabScrollFrame.BackgroundTransparency = 1
        TabScrollFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TabScrollFrame.BorderSizePixel = 0
        TabScrollFrame.Position = UDim2.new(0, 0, 0.00142455183, 0)
        TabScrollFrame.Size = UDim2.new(0, 576, 0, 280)
        TabScrollFrame.BottomImage = "http://www.roblox.com/asset/?id=86927157225558"
        TabScrollFrame.MidImage = "http://www.roblox.com/asset/?id=95591733073455"
        TabScrollFrame.ScrollBarThickness = 4
        TabScrollFrame.TopImage = "http://www.roblox.com/asset/?id=115122166951013"

        function Sections:MakeSection(Direction: string, Title: string)
            local Actions = {};
            local SectionPos;

            if Direction == 'Left' then
                SectionPos = UDim2.new(0.01, 0, 0.025, 0)
            else
                SectionPos = UDim2.new(0.5125, 0, 0.025, 0)
            end

            local BorderSectionUI = Instance.new("Frame")
            BorderSectionUI.Name = "SectionUI"
            BorderSectionUI.Parent = TabScrollFrame
            BorderSectionUI.BackgroundColor3 = Public.Script.InboundColor
            BorderSectionUI.BorderColor3 = Public.Script.BorderColor
            BorderSectionUI.Position = SectionPos
            BorderSectionUI.Size = UDim2.new(1, -2, 1, -2)

            local SectionUI = Instance.new("Frame")
            SectionUI.Name = "SectionUI"
            SectionUI.Parent = BorderSectionUI
            SectionUI.BackgroundColor3 = Public.Script.InboundColor
            SectionUI.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionUI.BorderMode = Enum.BorderMode.Inset
            SectionUI.Position = UDim2.new(0, 0, 0, 0)
            SectionUI.Size = UDim2.new(1, -2, 1, -2)

            local UIGradient_88 = Instance.new("UIGradient")
            UIGradient_88.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(125, 125, 125)), 
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
            }
            UIGradient_88.Rotation = -90
            UIGradient_88.Parent = SectionUI

            local SectionTitle = Instance.new("TextLabel")
            SectionTitle.Name = "SectionTitle"
            SectionTitle.Parent = SectionUI
            SectionTitle.AnchorPoint = Vector2.new(0.5, 0.5)
            SectionTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SectionTitle.BackgroundTransparency = 1
            SectionTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            SectionTitle.BorderSizePixel = 0
            SectionTitle.Position = UDim2.new(0.375, 0, -0.0250000004, 0)
            SectionTitle.Size = UDim2.new(0, 187, 0, 15)
            SectionTitle.Font = Enum.Font.Code
            SectionTitle.Text = Title
            SectionTitle.TextColor3 = Public.Script.TextColor
            SectionTitle.TextSize = 12
            SectionTitle.TextStrokeTransparency = 0.500
            SectionTitle.TextXAlignment = Enum.TextXAlignment.Left

            local UIGradient_4 = Instance.new("UIGradient")
            UIGradient_4.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), 
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))
            }
            UIGradient_4.Rotation = -90
            UIGradient_4.Parent = SectionUI

            local Container = Instance.new("Frame")
            Container.Name = "Container"
            Container.Parent = SectionUI
            Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Container.BackgroundTransparency = 1
            Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Container.BorderSizePixel = 0
            Container.Position = UDim2.new(0.0528301895, 0, 0.06, 10)

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.Parent = Container
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout.Padding = UDim.new(0, 9)

            local function SetSize() -- Figure out a better method than this
                BorderSectionUI.Size = UDim2.new(0, 270, 0, UIListLayout.AbsoluteContentSize.Y + 25)
                SectionUI.Size = UDim2.new(0, 270, 0, UIListLayout.AbsoluteContentSize.Y + 25)
                Container.Size = UDim2.new(0, 260, 0, UIListLayout.AbsoluteContentSize.Y + 25)
            end

            UIListLayout.GetPropertyChangedSignal(UIListLayout, 'AbsoluteContentSize'):Connect(SetSize)

            function Actions:NewToggle(Title: string, Func: any)
                local Callback = false;
				Func = Func or function() end

                local BorderToggleButton = Instance.new("TextButton")
                BorderToggleButton.Name = "ToggleButton"
                BorderToggleButton.Parent = Container
                BorderToggleButton.BackgroundColor3 = Public.Script.InboundColor
                BorderToggleButton.BorderColor3 = Public.Script.BorderColor
                --BorderToggleButton.Position = UDim2.new(0.0528301895, 0, 0.0666666701, 0)
                BorderToggleButton.Size = UDim2.new(0, 10, 0, 10)
                BorderToggleButton.Font = Enum.Font.SourceSans
                BorderToggleButton.Text = ""
                BorderToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                BorderToggleButton.TextSize = 14

                local ToggleButton = Instance.new("TextButton")
                ToggleButton.Name = "ToggleButton"
                ToggleButton.Parent = BorderToggleButton
                ToggleButton.BackgroundColor3 = Public.Script.InboundColor
                ToggleButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ToggleButton.BorderMode = Enum.BorderMode.Inset
                ToggleButton.Position = UDim2.new(0, 0, 0, 0)
                ToggleButton.Size = UDim2.new(0, 10, 0, 10)
                ToggleButton.Font = Enum.Font.SourceSans
                ToggleButton.Text = ""
                ToggleButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                ToggleButton.TextSize = 14

                local UIGradient_3 = Instance.new("UIGradient")
                UIGradient_3.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(125, 125, 125)), 
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))
                }
                UIGradient_3.Rotation = -90
                UIGradient_3.Parent = ToggleButton

                local TextLabel = Instance.new("TextLabel")
                TextLabel.Parent = ToggleButton
                TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                TextLabel.BackgroundTransparency = 1
                TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
                TextLabel.BorderSizePixel = 0
                TextLabel.Position = UDim2.new(1, 0, 0, 0)
                TextLabel.Size = UDim2.new(0, 150, 0, 10)
                TextLabel.Font = Enum.Font.Code
                TextLabel.Text = ' - '..Title
                TextLabel.TextColor3 = Public.Script.TextColor
                TextLabel.TextSize = 12
                TextLabel.TextXAlignment = Enum.TextXAlignment.Left
                TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom

                local function OnMouse1Click()
                    Callback = not Callback

                    if not Callback and ToggleButton.BackgroundColor3 == Color3.fromRGB(255, 255, 255) then
                        ToggleButton.BackgroundColor3 = Public.Script.InboundColor

                        Func()
                    elseif Callback and ToggleButton.BackgroundColor3 == Public.Script.InboundColor then
                        ToggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

                        Func()
                    end
                end

                ToggleButton.MouseButton1Click:Connect(OnMouse1Click);
            end

            function Actions:NewDivider(Color: Color3)
                local BorderSpacer = Instance.new("Frame")
                BorderSpacer.Parent = Container
                BorderSpacer.BackgroundColor3 = Public.Script.InboundColor
                BorderSpacer.BorderColor3 = Color3.fromRGB(0, 0, 0)
                BorderSpacer.Position = UDim2.new(0, 0, 0.128, 0)
                BorderSpacer.Size = UDim2.new(0, 240, 0, 5)

                local Spacer = Instance.new("Frame")
                Spacer.Parent = BorderSpacer
                Spacer.BackgroundColor3 = Color or Public.Script.InboundColor
                Spacer.BorderColor3 = Public.Script.BorderColor
                Spacer.BorderMode = Enum.BorderMode.Inset
                Spacer.Position = UDim2.new(0, 0, 0, 0)
                Spacer.Size = UDim2.new(0, 240, 0, 5)
            end

            function Actions:NewBlank(Size: number)
                Size = Size or 1

                local Blank = Instance.new("Frame")
                Blank.Parent = Container
                Blank.BackgroundColor3 = Color3.fromRGB(0,0,0)
                Blank.BackgroundTransparency = 1
                Blank.BorderColor3 = Color3.fromRGB(0, 0, 0)
                Blank.Position = UDim2.new(0.038, 0, 0.128, 0)
                Blank.Size = UDim2.new(1, 0, 0, Size)
            end

            function Actions:NewDropdown(...)
                local Arguments = { ... };
                local List = {}

                local NewList = {}
                NewList.__index = NewList

                if type(...) == 'table' then -- Thnaks to Wallys UI for the fix to this shit
                    List = ...
                else
                    List.Title = Arguments[1];
                    List.Header = Arguments[2];
                    List.Arguments = Arguments[3] or {};
                end

                local ListTitle = Instance.new("TextLabel")
                ListTitle.Name = "ListTitle"
                ListTitle.Parent = Container
                ListTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ListTitle.BackgroundTransparency = 1
                ListTitle.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ListTitle.BorderSizePixel = 0
                ListTitle.Position = UDim2.new(0, 0, 0, 0)
                ListTitle.Size = UDim2.new(0, 165, 0, 13)
                ListTitle.Font = Enum.Font.Code
                ListTitle.Text = List.Title
                ListTitle.TextColor3 = Color3.fromRGB(225, 225, 225)
                ListTitle.TextSize = 12
                ListTitle.TextStrokeTransparency = 0.500
                ListTitle.TextXAlignment = Enum.TextXAlignment.Left

                local BorderListPrimaryButton = Instance.new("TextButton")
                BorderListPrimaryButton.Name = "ListPrimaryButton"
                BorderListPrimaryButton.Parent = ListTitle
                BorderListPrimaryButton.Active = false
                BorderListPrimaryButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                BorderListPrimaryButton.BorderColor3 = Color3.fromRGB(0,0,0)
                BorderListPrimaryButton.Position = UDim2.new(0.05, 0, 1.15, 0)
                BorderListPrimaryButton.Size = UDim2.new(0, 236, 0, 20)
                BorderListPrimaryButton.Font = Enum.Font.SourceSans
                BorderListPrimaryButton.Text = ""
                BorderListPrimaryButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                BorderListPrimaryButton.TextSize = 14

                local ListPrimaryButton = Instance.new("TextButton")
                ListPrimaryButton.Name = "ListPrimaryButton"
                ListPrimaryButton.Parent = BorderListPrimaryButton
                ListPrimaryButton.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                ListPrimaryButton.BorderColor3 = Color3.fromRGB(27, 27, 27)
                ListPrimaryButton.BorderMode = Enum.BorderMode.Inset
                ListPrimaryButton.Position = UDim2.new(0, 0, 0, 0)
                ListPrimaryButton.Size = UDim2.new(0, 236, 0, 20)
                ListPrimaryButton.Font = Enum.Font.SourceSans
                ListPrimaryButton.Text = ""
                ListPrimaryButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                ListPrimaryButton.TextSize = 14

                local UIGradient_List_2 = Instance.new("UIGradient")
                UIGradient_List_2.Color = ColorSequence.new{
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), 
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))
                }
                UIGradient_List_2.Rotation = -90
                UIGradient_List_2.Name = "UIGradient_List"
                UIGradient_List_2.Parent = ListPrimaryButton

                local PrimaryButtonText = Instance.new("TextLabel")
                PrimaryButtonText.Name = "PrimaryButtonText"
                PrimaryButtonText.Parent = ListPrimaryButton
                PrimaryButtonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                PrimaryButtonText.BackgroundTransparency = 1
                PrimaryButtonText.BorderColor3 = Color3.fromRGB(0, 0, 0)
                PrimaryButtonText.BorderSizePixel = 0
                PrimaryButtonText.Position = UDim2.new(0.0250000004, 0, 0, 0)
                PrimaryButtonText.Size = UDim2.new(0, 226, 0, 20)
                PrimaryButtonText.Font = Enum.Font.Code
                PrimaryButtonText.Text = List.Title
                PrimaryButtonText.TextColor3 = Color3.fromRGB(225, 225, 225)
                PrimaryButtonText.TextSize = 12
                PrimaryButtonText.TextStrokeTransparency = 0.500
                PrimaryButtonText.TextXAlignment = Enum.TextXAlignment.Left

                local ListContainer = Instance.new("Frame")
                ListContainer.Name = "ListContainer"
                ListContainer.Parent = ListPrimaryButton
                ListContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ListContainer.BackgroundTransparency = 1
                ListContainer.BorderColor3 = Color3.fromRGB(0, 0, 0)
                ListContainer.BorderSizePixel = 0
                ListContainer.Position = UDim2.new(0, 0, 1.14999998, 0)
                ListContainer.Size = UDim2.new(0, 235, 0, 20)

                local UIListLayout_List = Instance.new("UIListLayout")
                UIListLayout_List.Name = "UIListLayout_List"
                UIListLayout_List.Parent = ListContainer
                UIListLayout_List.SortOrder = Enum.SortOrder.LayoutOrder

                function NewList.new(Title: string)
                    local BorderListButton = Instance.new("TextButton")
                    BorderListButton.Name = "ListButton"
                    BorderListButton.Parent = ListContainer
                    BorderListButton.Active = false
                    BorderListButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    BorderListButton.BorderColor3 = Color3.fromRGB(0,0,0)
                    BorderListButton.Position = UDim2.new(0.0540034473, 0, 0.216903895, 0)
                    BorderListButton.Size = UDim2.new(0, 236, 0, 20)
                    BorderListButton.Font = Enum.Font.SourceSans
                    BorderListButton.Text = ""
                    BorderListButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                    BorderListButton.TextSize = 14

                    local ListButton = Instance.new("TextButton")
                    ListButton.Name = "ListButton"
                    ListButton.Parent = BorderListButton
                    ListButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    ListButton.BorderColor3 = Color3.fromRGB(27, 27, 27)
                    ListButton.BorderMode = Enum.BorderMode.Inset
                    ListButton.Position = UDim2.new(0, 0, 0, 0)
                    ListButton.Size = UDim2.new(0, 236, 0, 20)
                    ListButton.Font = Enum.Font.SourceSans
                    ListButton.Text = ""
                    ListButton.TextColor3 = Color3.fromRGB(0, 0, 0)
                    ListButton.TextSize = 14

                    local UIGradient_List = Instance.new("UIGradient")
                    UIGradient_List.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(9, 9, 9)), 
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 18, 18))
                    }
                    UIGradient_List.Rotation = -90
                    UIGradient_List.Name = "UIGradient_List"
                    UIGradient_List.Parent = ListButton

                    local ListButtonText = Instance.new("TextLabel")
                    ListButtonText.Name = "ListButtonText"
                    ListButtonText.Parent = ListButton
                    ListButtonText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    ListButtonText.BackgroundTransparency = 1
                    ListButtonText.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    ListButtonText.BorderSizePixel = 0
                    ListButtonText.Position = UDim2.new(0.0250000004, 0, 0, 0)
                    ListButtonText.Size = UDim2.new(0, 226, 0, 20)
                    ListButtonText.Font = Enum.Font.Code
                    ListButtonText.Text = Title
                    ListButtonText.TextColor3 = Color3.fromRGB(225, 225, 225)
                    ListButtonText.TextSize = 12
                    ListButtonText.TextStrokeTransparency = 0.500
                    ListButtonText.TextXAlignment = Enum.TextXAlignment.Left
                end

                for _, index in next, List do
                    local Args = index.Arguments

                    if Args then
                        NewList.new(Args)
                    end
                end
            end

            return Actions;
        end

        return Sections;
    end

    ExitButtonUI.MouseButton1Click:Connect(function()
        OuterUI.Visible = false
    end)

    return SubNetwork;
end

return Window
