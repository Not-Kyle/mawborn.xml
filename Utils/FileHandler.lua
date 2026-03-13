if getgenv().Mawborn.FileHandler then
    return
end

local Readfile, Writefile = readfile, writefile;
local Isfolder, Makefolder = isfolder, makefolder;

local Pcall = pcall;
local Next = next;
local Defer = task.defer;

local Folder = 'mawborn';
local File = Folder .. '/source.xml';

local Utils = Import('Utils/Utils.lua');

local Config = {AutoExecute = true};

function Config:UpdateFile()
    return Writefile and Writefile(File, Utils.HttpService:JSONEncode(Config));
end

Defer(function()
    if not Makefolder
        or not Isfolder
        or not Readfile
        or not Writefile then
            
        return
    end

    if Makefolder and not Isfolder(Folder) then 
        Makefolder(Folder);
    end

    local Connection, Contents = Pcall(Readfile, File)

    if Connection then
        local Decode = Utils.HttpService:JSONDecode(Contents)

        for Index, _ in Next, Config do
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
