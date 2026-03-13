if getgenv().Mawborn.Logger then
    return
end

local Print, Warn, Error = print, warn, error;
local TableFreeze = table.freeze;
local Type = type;

local Logger = {};
Logger.__index = Logger;

function Logger:Cout(Message: string)
    if Type(Message) ~= 'string' then return end;

    Print(Message);
end

function Logger:Warning(Message: string)
    if Type(Message) ~= 'string' then return end;

    Warn(Message);
end

function Logger:Error(Message: string, Level: number)
    if Type(Message) ~= 'string' then return end;
    if Level and Type(Level) ~= 'number' then return end;

    Error(Message, Level or 0);
end

return TableFreeze(Logger);
