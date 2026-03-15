local InputService = Service.UserInputService;
local TextService = Service.TextService;
local TweenService = Service.TweenService;
local CoreGui = Service.CoreGui;
local RunService = Service.RunService;
local RenderStepped = RunService.RenderStepped;
local ContentProvider = Service.ContentProvider;
local LocalPlayer = Service.Players.LocalPlayer;
local Mouse = LocalPlayer:GetMouse();

local Font = Enum.Font.Code
local FontSize = 14;

local ProxyContentProvider = game:GetService('ContentProvider');
local ProxyCoreGui = game:GetService('CoreGui');

local OldPreloading; OldPreloading = hookmetamethod(game, '__namecall', newcclosure(function(self, ...) -- Adding PreloadAsync bypass?
    local Method = (getnamecallmethod or get_namecall_method)();
    local Arguments = {...};

    if not checkcaller() and (self == ProxyContentProvider or self == ContentProvider) then
        if (Method == 'PreloadAsync' or Method == 'preloadAsync') then
            local PreloadTable = Arguments[1];

            if typeof(PreloadTable) == 'table' then
                local ProxyTable = {};
                local CoreGuiFound = false;

                for _, Index in ipairs(PreloadTable) do
                    if typeof(Index) == 'Instance' and ((Index == ProxyCoreGui or Index:IsDescendantOf(ProxyCoreGui)) or (Index == CoreGui or  Index:IsDescendantOf(CoreGui))) then
                        CoreGuiFound = true;
                    else
                        table.insert(ProxyTable, Index);
                    end
                end

                if CoreGuiFound then
                    return OldPreloading(self, ProxyTable)
                end
            end
        end

        if (Method == 'GetAssetFetchStatus' or Method == 'getAssetFetchStatus') then
            local Asset = Arguments[1];
            if typeof(Asset) == 'string' and Asset:find('rbxassetid://') then
                return Enum.AssetFetchStatus.None;
            end
        end
    end

    return OldPreloading(self, ...)
end))
