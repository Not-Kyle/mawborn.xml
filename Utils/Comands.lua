if getgenv().Mawborn.Commands then
    return
end

local CommandCooldown = 0.5;
local LastCommandTime = 0;

local Commands = {};
local CommandHandler = {};

CommandHandler.Commands = Commands;

local Logger = Import('Utils/Logging.lua')

function CommandHandler.Add(...) -- Reworked version of Ciazware command handler
    local Arguments = { ... };
    local CommandNet = {};

    if typeof(Arguments[1]) == 'table' then
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
    for _, Index in next, Commands do
        if Index.Name == CommandName or (Index.Alias and table.find(Index.Alias, CommandName)) then
            return Index.Function
        end
    end
end

function CommandHandler.Execute(Arguments: string)
    local Success, Error = pcall(function()
        local Time = os.clock();

        if Time - LastCommandTime < CommandCooldown then -- Stops double chat commands
            return
        end

        local SplitArgs = string.split(Arguments, ' ')
        local IndexedCommand = CommandHandler.Index(string.lower(table.remove(SplitArgs, 1)))

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
