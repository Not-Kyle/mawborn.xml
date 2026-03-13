if getgenv().Mawborn.Commands then
    return
end

local Typeof, Pcall = typeof, pcall;
local Next = next;
local Find, Remove = table.find, table.remove;
local Split, Lower = string.split, string.lower;
local OsClock = os.clock;

local CommandCooldown = 0.5;
local LastCommandTime = 0;

local Commands = {};
local CommandHandler = {};

CommandHandler.Commands = Commands;

local Logger = Import('Utils/Logging.lua')

function CommandHandler.Add(...) -- Reworked version of Ciazware command handler
    local Arguments = { ... };
    local CommandNet = {};

    if Typeof(Arguments[1]) == 'table' then
        CommandNet = Arguments[1];
    else
        CommandNet = {
            Name = Arguments[1],
            Alias = Arguments[2],
            Description = Arguments[3],
            Arguments = Arguments[4],
            Status = Arguments[5],
            Function = Arguments[6],
        }
    end
    
    Commands[#Commands + 1] = CommandNet;
end

function CommandHandler.Index(CommandName: string)
    for _, Index in Next, Commands do
        if Index.Name == CommandName or (Index.Alias and Find(Index.Alias, CommandName)) then
            return Index.Function
        end
    end
end

function CommandHandler.Execute(Arguments: string)
    local Success, Error = Pcall(function()
        local Time = OsClock();

        if Time - LastCommandTime < CommandCooldown then -- Stops double chat commands
            return
        end

        local SplitArgs = Split(Arguments, ' ')
        local IndexedCommand = CommandHandler.Index(Lower(Remove(SplitArgs, 1)))

        if not IndexedCommand then
            return
        end

        LastCommandTime = Time
        IndexedCommand(SplitArgs)
    end)

    if not Success then
        Logger:Warning(Error);
    end
end

return CommandHandler
