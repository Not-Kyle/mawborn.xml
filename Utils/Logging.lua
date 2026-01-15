local Std = {};

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

return Std;
