local Request = (syn and syn.request) or (http and http.request) or http_request or request;
local Cached = {};

local RepositoryDomain = 'raw.githubusercontent.com';

local function RequestHttp(Url: string) : (string?, string?)
    local Domain = string.match(Url, 'https?://([^/]+)')

    if Domain ~= RepositoryDomain then
        return nil, 'Domain not allowed: ' .. tostring(Domain)
    end

    if Request then
        local Result = Request({
            Url = Url;
            Method = 'GET';
        })

        if not Result or Result.StatusCode ~= 200 then
            return nil, 'Request failed: ' .. (Result and Result.StatusCode or 'nil')
        end

        return Result.Body, nil
    end

    local Success, Result = pcall(function()
        return game:HttpGet(Url)
    end)

    if not Success then
        return nil, Result
    end

    return Result, nil
end

function Import(Url: string): any
    if Cached[Url] then
        return Cached[Url];
    end

    local Source, Error = RequestHttp(Url);

    if not Source then
        return warn('Import failed: ' .. tostring(Error));
    end

    local Chunk, CompileError = loadstring(Source, Url);

    if not Chunk then
        return warn('Compile error: ' .. CompileError);
    end

    local Env = setmetatable({}, {__index = getfenv()});
    setfenv(Chunk, Env);

    local Result;
    local function HandleError(Error)
        warn(string.format('[%s]: %s\n%s', Url, tostring(Error), debug.traceback()));
        return false
    end

    local Success = xpcall(function()
        Result = Chunk()
    end, HandleError)

    if not Success then
        return
    end

    Cached[Url] = Result
    return Result
end

getgenv().Import = Import
getgenv().Mawborn = {
    Version = '0.9.97';

    Library = {};
};

Import('https://raw.githubusercontent.com/Not-Kyle/mawborn.xml/refs/heads/main/src/Source.lua');
