local Std = {};

function Std:Cout(...)
    local Arguments = { ... }

    self.LastMessage = select(1, Arguments);
    print(select(1, Arguments));
end

function Std:Warning(...)
    local Arguments = { ... }

    self.LastMessage = select(1, Arguments);
    warn(select(1, Arguments));
end

function Std:Error(...)
    local Arguments = { ... }

    self.LastMessage = select(1, Arguments);
    error(select(1, Arguments));
end

return Std;
