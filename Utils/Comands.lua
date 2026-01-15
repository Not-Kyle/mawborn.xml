local CommandCooldown = 0.5;
local LastCommandTime = 0;

local Commands = {};
local CommandHandler = {};

local Logger = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Logging.lua')

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

function CommandHandler.Index(Arguments: string)
    for _, Index in next, Commands do
        if Index.Name == Arguments or (Index.Alias and table.find(Index.Alias, Arguments)) then
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

        local SplitArgs = string.split(string.lower(Arguments), ' ')
        local IndexedCommand = CommandHandler.Index(table.remove(SplitArgs, 1))

        if not IndexedCommand then
            return
        end

        IndexedCommand(SplitArgs)
        LastCommandTime = Time
    end)

    if not Success then
        Logger:Warning(Error);
    end
end

return CommandHandler, Commands;
