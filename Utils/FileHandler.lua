local Service = setmetatable({}, {
    __index = function(self: Instance, ...)
        local Arguments = {...}
        local Key = select(1, Arguments);

        local Result = game:GetService(Key);
        
        if cloneref then
            return cloneref(Result);
        end

        rawset(self, Arguments, Result);
        return Result;
    end
})

local HttpService = Service.HttpService;

local Folder = 'mawborn';
local File = Folder .. '/source.xml';

local Config = {AutoExecute = true};

function Config:UpdateFile()
    return writefile and writefile(File, HttpService:JSONEncode(Config));
end

task.spawn(function()
    if not makefolder
        or not isfolder
        or not readfile
        or not writefile then
            
        return
    end

    if makefolder and not isfolder(Folder) then 
        makefolder(Folder);
    end

    local Connection, Contents = pcall(readfile, File)

    if Connection then
        local JSON_Decode = HttpService:JSONDecode(Contents)

        for Index, _ in next, Config do
            if JSON_Decode[Index] then
                Config[Index] = JSON_Decode[Index]
            end
        end

        Config:UpdateFile();
    else
        Config:UpdateFile();
    end
end)

return Config;
