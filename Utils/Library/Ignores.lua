local Checkcaller, Newcclosure, Hookfunction = checkcaller, newcclosure, hookfunction;

local Typeof = typeof;
local Ipairs = ipairs;
local Insert = table.insert;

local ProxyContentProvider = game:GetService('ContentProvider');
local ProxyCoreGui = game:GetService('CoreGui');

local OldPreloader; OldPreloader = Hookfunction(ProxyContentProvider.PreloadAsync, Newcclosure(function(self, ...)
    local Arguments = {...};

    if Checkcaller() or Typeof(self) ~= 'Instance' or self ~= ProxyContentProvider then
        return OldPreloader(self, ...);
    end

    if Typeof(Arguments[1]) == 'table' then
        local ProxyTable = {};
        local FoundCoreGui = false;

        for _, Index in Ipairs(Arguments[1]) do
            if Index == ProxyCoreGui or Index:IsDescendantOf(ProxyCoreGui) then
                FoundCoreGui = true;
            else
                Insert(ProxyTable, Index);
            end
        end

        if FoundCoreGui then
            return OldPreloader(self, ProxyTable, Arguments[2]);
        end
    end

    return OldPreloader(self, ...);
end))

local OldAssetFetch; OldAssetFetch = Hookfunction(ProxyContentProvider.GetAssetFetchStatus, Newcclosure(function(self, ...)
    local Arguments = {...};

    if Checkcaller() or Typeof(self) ~= 'Instance' or self ~= ProxyContentProvider then
        return OldAssetFetch(self, ...);
    end

    local Asset = Arguments[1];
    if Typeof(Asset) == 'string' and Asset:find('rbxassetid://') then
        return Enum.AssetFetchStatus.None;
    end

    return OldAssetFetch(self, ...);
end))
