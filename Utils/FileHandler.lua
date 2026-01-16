local Utils = Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/Utils/Utils.lua');

local HttpService = Utils.AddService('HttpService');

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
        local Decode = HttpService:JSONDecode(Contents)

        for Index, _ in next, Config do
            if Decode[Index] then
                Config[Index] = Decode[Index]
            end
        end

        Config:UpdateFile();
    else
        Config:UpdateFile();
    end
end)

return Config;
