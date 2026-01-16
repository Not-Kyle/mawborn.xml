if getgenv().Mawborn.Logger then
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

local StarterGui = Service.StarterGui;
local Messagebox = messagebox or messageboxasync;

local Std = {};
Std.__index = Std;

function Std:Cout(...)
    self.LastMessage = select(1, ...);
    print(select(1, ...));
end

function Std:Warning(...)
    self.LastMessage = select(1, ...);
    warn(select(1, ...));
end

function Std:Error(...)
    self.LastMessage = select(1, ...);
    error(select(1, ...));
end

function Std:MessageBox(Message: string, Title: string, Flag: number, Notify: boolean, Function: any)
    Function = Function or function() end

    if getgenv().MessageIsUsable then
        return Messagebox(Message, Title, Flag)

    else
        local function NotifyMessageBox(Title: string, Text: string, Flag: number, Func: any)
            Func = Func or function() end
            local Options = {};

            local BindableFunction = Instance.new('BindableFunction')
            BindableFunction.OnInvoke = Func;

            if Flag == 0 or nil then
                Options.One = 'OK'

            elseif Flag == 1 then
                Options.One = 'OK'
                Options.Two = 'Cancel'

            elseif Flag == 2 then
                Options.One = 'Abort'
                Options.Two = 'Retry'
                Options.Three = 'Ignore'

            elseif Flag == 3 then
                Options.One = 'Yes'
                Options.Two = 'No'
                Options.Three = 'Cancel'

            elseif Flag == 4 then
                Options.One = 'Yes'
                Options.Two = 'No'

            elseif Flag == 5 then
                Options.One = 'Retry'
                Options.Two = 'Cancel'

            elseif Flag == 6 then
                Options.One = 'Cancel'
                Options.Two = 'Try Again'
                Options.Three = 'Continue'
            
            elseif Flag == 7 then
                return
            end

            if Notify then
                StarterGui:SetCore('SendNotification', {
                    Title = Title;
                    Text = Text;
                    Duration = 20;
                    Button1 = Options.One;
                    Button2 = Options.Two;
                    Button3 = Options.Three;
                    Callback = BindableFunction;
                })
            end
        end

        return NotifyMessageBox(Title, Message, Flag, Function)
    end

    --[[
        Std:MessageBox('Text', 'Title', 0, true, function()
            if not getgenv().MessageIsUsable then
                Logger:Warning('No Messageboxasync')
            end
        end)
    ]]--
end

return Std;
