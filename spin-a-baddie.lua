-- Trustsense Hub entrypoint
local sharedEnv = (getgenv and getgenv()) or _G
sharedEnv.TrustsenseHub = sharedEnv.TrustsenseHub or {}

local Hub = sharedEnv.TrustsenseHub
Hub.RunId = (Hub.RunId or 0) + 1
local CurrentRunId = Hub.RunId
Hub.IsUnloaded = false
Hub.Config = Hub.Config or {}
Hub.Features = Hub.Features or {}

local FPS_BOOST_TICK_INTERVAL = 0.4
local FPS_BOOST_SETTINGS_INTERVAL = 2.0

Hub.Config.AutoBuyAllDice = Hub.Config.AutoBuyAllDice or {
    Enabled = true,
    RunInterval = 1.0,
    BuyDelay = 0.05,
    IncludeRestockShop = true,
    IncludeRestockPotions = true,
    IncludeMerchantShop = true,
    MaxMerchantPurchasesPerTick = 20,
    ProfileWaitTimeout = 20,
    PlayerLoadedWaitTimeout = 20
}
Hub.Config.AutoBuyEggs = Hub.Config.AutoBuyEggs or {
    Enabled = false,
    RunInterval = 0.5,
    OpenAmount = 1,
    EggName = nil
}
Hub.Config.AutoOpenBestDice = Hub.Config.AutoOpenBestDice or {
    Enabled = true,
    RunInterval = 0.2
}
Hub.Config.AutoOpenBestDiceWeather = Hub.Config.AutoOpenBestDiceWeather or {
    Enabled = false,
    SmartMinCoinMultiplier = 6
}
Hub.Config.AutoUsePotions = Hub.Config.AutoUsePotions or {
    Enabled = true,
    RunInterval = 0.5,
    UseDelay = 0.5,
    UseLuck = true,
    UseMoney = true,
    UseMutationChance = true,
    UseNoConsumeDice = true,
    UsePrismatic = false
}
Hub.Config.AutoCollectQuests = Hub.Config.AutoCollectQuests or {
    Enabled = true,
    RunInterval = 0.8,
    ClaimDelay = 0.15,
    CheckReset = true,
    ResetCheckInterval = 5.0
}
Hub.Config.AutoClaimAllIndex = Hub.Config.AutoClaimAllIndex or {
    Enabled = true,
    RunInterval = 0.8
}
Hub.Config.AutoCollectCoins = Hub.Config.AutoCollectCoins or {
    Enabled = true,
    RunInterval = 0.5
}
Hub.Config.AutoSpinWheel = Hub.Config.AutoSpinWheel or {
    Enabled = true,
    RunInterval = 1.0
}
Hub.Config.AntiAFK = Hub.Config.AntiAFK or {
    Enabled = true,
    UseMobileMethod = true,
    MobilePulseInterval = 45,
    DisableIdledConnections = true,
    ConnectionScanInterval = 8
}
Hub.Config.FPSBoost = Hub.Config.FPSBoost or {
    Enabled = true,
    AggressiveMode = true,
    DisablePopups = true,
    DisableCutscenes = true,
    DisableAnnouncements = true,
    DisableRollSFX = true,
    DisableTitleAura = true,
    RunInterval = FPS_BOOST_TICK_INTERVAL,
    SettingsInterval = FPS_BOOST_SETTINGS_INTERVAL
}
if Hub.Config.AutoBuyAllDice.IncludeRestockPotions == nil then
    Hub.Config.AutoBuyAllDice.IncludeRestockPotions = true
end
Hub.Config.AutoBuyEggs.Enabled = Hub.Config.AutoBuyEggs.Enabled == true
Hub.Config.AutoBuyEggs.RunInterval = tonumber(Hub.Config.AutoBuyEggs.RunInterval) or 0.5
Hub.Config.AutoBuyEggs.OpenAmount = math.max(1, math.min(100, math.floor(tonumber(Hub.Config.AutoBuyEggs.OpenAmount) or 1)))
if type(Hub.Config.AutoBuyEggs.EggName) ~= "string" then
    Hub.Config.AutoBuyEggs.EggName = nil
end
Hub.Config.AutoOpenBestDice.RunInterval = 0.2
Hub.Config.AutoOpenBestDiceWeather.Enabled = Hub.Config.AutoOpenBestDiceWeather.Enabled == true
Hub.Config.AutoOpenBestDiceWeather.SmartMinCoinMultiplier = math.max(
    1,
    math.min(10, math.floor(tonumber(Hub.Config.AutoOpenBestDiceWeather.SmartMinCoinMultiplier) or 6))
)
Hub.Config.AutoUsePotions.Enabled = Hub.Config.AutoUsePotions.Enabled ~= false
Hub.Config.AutoUsePotions.RunInterval = tonumber(Hub.Config.AutoUsePotions.RunInterval) or 0.5
Hub.Config.AutoUsePotions.UseDelay = tonumber(Hub.Config.AutoUsePotions.UseDelay) or 0.5
if Hub.Config.AutoUsePotions.UseLuck == nil then
    Hub.Config.AutoUsePotions.UseLuck = true
end
if Hub.Config.AutoUsePotions.UseMoney == nil then
    Hub.Config.AutoUsePotions.UseMoney = true
end
if Hub.Config.AutoUsePotions.UseMutationChance == nil then
    Hub.Config.AutoUsePotions.UseMutationChance = true
end
if Hub.Config.AutoUsePotions.UseNoConsumeDice == nil then
    Hub.Config.AutoUsePotions.UseNoConsumeDice = true
end
if Hub.Config.AutoUsePotions.UsePrismatic == nil then
    Hub.Config.AutoUsePotions.UsePrismatic = false
end
Hub.Config.AutoCollectQuests.Enabled = Hub.Config.AutoCollectQuests.Enabled ~= false
Hub.Config.AutoCollectQuests.RunInterval = tonumber(Hub.Config.AutoCollectQuests.RunInterval) or 0.8
Hub.Config.AutoCollectQuests.ClaimDelay = tonumber(Hub.Config.AutoCollectQuests.ClaimDelay) or 0.15
if Hub.Config.AutoCollectQuests.CheckReset == nil then
    Hub.Config.AutoCollectQuests.CheckReset = true
end
Hub.Config.AutoCollectQuests.ResetCheckInterval = tonumber(Hub.Config.AutoCollectQuests.ResetCheckInterval) or 5.0
Hub.Config.AutoClaimAllIndex.Enabled = Hub.Config.AutoClaimAllIndex.Enabled ~= false
Hub.Config.AutoClaimAllIndex.RunInterval = tonumber(Hub.Config.AutoClaimAllIndex.RunInterval) or 0.8
Hub.Config.AutoCollectCoins.Enabled = Hub.Config.AutoCollectCoins.Enabled ~= false
Hub.Config.AutoCollectCoins.RunInterval = tonumber(Hub.Config.AutoCollectCoins.RunInterval) or 0.5
Hub.Config.AutoSpinWheel.Enabled = Hub.Config.AutoSpinWheel.Enabled ~= false
Hub.Config.AutoSpinWheel.RunInterval = tonumber(Hub.Config.AutoSpinWheel.RunInterval) or 1.0
Hub.Config.AntiAFK.Enabled = Hub.Config.AntiAFK.Enabled ~= false
if Hub.Config.AntiAFK.UseMobileMethod == nil then
    Hub.Config.AntiAFK.UseMobileMethod = true
end
Hub.Config.AntiAFK.MobilePulseInterval = math.max(
    15,
    math.min(120, tonumber(Hub.Config.AntiAFK.MobilePulseInterval) or 45)
)
if Hub.Config.AntiAFK.DisableIdledConnections == nil then
    Hub.Config.AntiAFK.DisableIdledConnections = true
end
Hub.Config.AntiAFK.ConnectionScanInterval = math.max(
    1,
    math.min(30, tonumber(Hub.Config.AntiAFK.ConnectionScanInterval) or 8)
)
Hub.Config.FPSBoost.Enabled = Hub.Config.FPSBoost.Enabled ~= false
if Hub.Config.FPSBoost.AggressiveMode == nil then
    Hub.Config.FPSBoost.AggressiveMode = true
end
if Hub.Config.FPSBoost.DisablePopups == nil then
    Hub.Config.FPSBoost.DisablePopups = true
end
if Hub.Config.FPSBoost.DisableCutscenes == nil then
    Hub.Config.FPSBoost.DisableCutscenes = true
end
if Hub.Config.FPSBoost.DisableAnnouncements == nil then
    Hub.Config.FPSBoost.DisableAnnouncements = true
end
if Hub.Config.FPSBoost.DisableRollSFX == nil then
    Hub.Config.FPSBoost.DisableRollSFX = true
end
if Hub.Config.FPSBoost.DisableTitleAura == nil then
    Hub.Config.FPSBoost.DisableTitleAura = true
end
Hub.Config.FPSBoost.RunInterval = FPS_BOOST_TICK_INTERVAL
Hub.Config.FPSBoost.SettingsInterval = FPS_BOOST_SETTINGS_INTERVAL

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local VirtualUserService = nil
pcall(function()
    VirtualUserService = game:GetService("VirtualUser")
end)

local LocalPlayer = Players.LocalPlayer
local Events = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local StatusState = ReplicatedStorage:WaitForChild("status")

local BuyRemote = Events:WaitForChild("buy")
local RegularPetRemote = Events:WaitForChild("RegularPet")
local MerchantRequestRemote = Events:WaitForChild("MerchantRequest")
local MerchantBuyRemote = Events:WaitForChild("MerchantBuy")
local EquipRemote = Events:WaitForChild("equip")
local UpdateRollingDiceRemote = Events:WaitForChild("updateRollingDice")
local UpdateSettingsRemote = Events:WaitForChild("updateSettings")
local QuestRemote = Events:WaitForChild("QuestRemote")
local IndexClaimAllRemote = Events:WaitForChild("claimAll")
local SpinRequestRemote = Events:WaitForChild("spinrequest")

local DiceData = require(Modules:WaitForChild("DiceData"))
local PotionData = require(Modules:WaitForChild("PotionData"))
local RarityData = require(Modules:WaitForChild("Rarities"))
local QuestData = require(Modules:WaitForChild("QuestHandler"))
local MutationData = require(Modules:WaitForChild("Mutations"))

local DISCORD_INVITE_URL = "https://discord.gg/6KVvbEYaXF"
local DISCORD_INVITE_CODE = "6KVvbEYaXF"

local function debugLog(...)
    return ...
end

local function getProfileData()
    if type(_G) == "table" and _G.Profile and _G.Profile.Data then
        return _G.Profile.Data
    end

    local okGetRenv, renv = pcall(function()
        if getrenv then
            return getrenv()
        end
        return nil
    end)

    if okGetRenv and type(renv) == "table" then
        local globalTable = renv._G
        if type(globalTable) == "table" and globalTable.Profile and globalTable.Profile.Data then
            return globalTable.Profile.Data
        end
    end

    return nil
end

local function waitForProfile(timeoutSeconds)
    local deadline = os.clock() + timeoutSeconds

    repeat
        local profileData = getProfileData()
        if profileData then
            return profileData
        end
        task.wait(0.1)
    until os.clock() >= deadline

    return nil
end

local function waitForPlayerLoaded(timeoutSeconds)
    if not LocalPlayer then
        return false
    end

    local deadline = os.clock() + timeoutSeconds
    repeat
        if LocalPlayer:GetAttribute("Loaded") then
            return true
        end
        task.wait(0.1)
    until os.clock() >= deadline

    return LocalPlayer:GetAttribute("Loaded") == true
end

local function safeInvoke(remote, ...)
    local ok, result = pcall(remote.InvokeServer, remote, ...)
    if not ok then
        debugLog("Remote invoke failed:", remote.Name, result)
        return false
    end
    return result
end

local function safeFire(remote, ...)
    local ok, err = pcall(remote.FireServer, remote, ...)
    if not ok then
        debugLog("Remote fire failed:", remote.Name, err)
        return false
    end
    return true
end

local function getRequestFunction()
    if type(request) == "function" then
        return request
    end
    if type(http_request) == "function" then
        return http_request
    end
    if type(syn) == "table" and type(syn.request) == "function" then
        return syn.request
    end
    if type(http) == "table" and type(http.request) == "function" then
        return http.request
    end
    if type(fluxus) == "table" and type(fluxus.request) == "function" then
        return fluxus.request
    end
    return nil
end

local function copyToClipboard(text)
    local clipboardFn = setclipboard or toclipboard
    if type(clipboardFn) ~= "function" then
        return false
    end

    local ok = pcall(clipboardFn, text)
    return ok
end

local function tryJoinDiscordInvite(inviteCode)
    local requestFn = getRequestFunction()
    if type(requestFn) ~= "function" then
        return false, "request function unavailable"
    end

    local payload = HttpService:JSONEncode({
        cmd = "INVITE_BROWSER",
        nonce = tostring(math.random(100000, 999999)),
        args = {
            code = inviteCode
        }
    })

    for port = 6463, 6472 do
        local ok, response = pcall(requestFn, {
            Url = string.format("http://127.0.0.1:%d/rpc?v=1", port),
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                Origin = "https://discord.com"
            },
            Body = payload
        })

        if ok and type(response) == "table" then
            local statusCode = tonumber(response.StatusCode or response.Statuscode or response.status_code)
            if statusCode and statusCode >= 200 and statusCode < 300 then
                return true
            end
        end
    end

    return false, "discord rpc unavailable"
end

local function doMobileAntiAfkPulse()
    local character = LocalPlayer and LocalPlayer.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.Health > 0 then
        local moved = pcall(function()
            humanoid:Move(Vector3.new(1, 0, 0), true)
        end)
        if moved then
            task.wait(0.1)
            pcall(function()
                humanoid:Move(Vector3.new(0, 0, 0), true)
            end)
            return true
        end
    end

    if VirtualUserService then
        local ok = pcall(function()
            VirtualUserService:CaptureController()
            VirtualUserService:ClickButton2(Vector2.new(0, 0))
        end)
        if ok then
            return true
        end
    end

    return false
end

local function disableIdledConnections()
    if not LocalPlayer or type(getconnections) ~= "function" then
        return 0
    end

    local ok, connections = pcall(getconnections, LocalPlayer.Idled)
    if not ok or type(connections) ~= "table" then
        return 0
    end

    local disabledCount = 0
    for _, connection in pairs(connections) do
        local disabled = false

        pcall(function()
            if type(connection.Disable) == "function" then
                connection:Disable()
                disabled = true
            end
        end)

        if not disabled then
            pcall(function()
                if type(connection.Disconnect) == "function" then
                    connection:Disconnect()
                    disabled = true
                end
            end)
        end

        if disabled then
            disabledCount = disabledCount + 1
        end
    end

    return disabledCount
end

local function trySet(instance, propertyName, value)
    local okRead, currentValue = pcall(function()
        return instance[propertyName]
    end)
    if not okRead then
        return false
    end

    if currentValue == value then
        return true
    end

    local okWrite = pcall(function()
        instance[propertyName] = value
    end)
    return okWrite
end

local PopupGuiNameSet = {
    top_not = true,
    bot_not = true,
    giftstuff = true
}

local PopupNameParts = {
    "notif",
    "notification",
    "popup",
    "announce"
}

local ProtectedGuiNameSet = {
    main = true,
    rolling = true,
    chat = true,
    playerlist = true,
    backpack = true,
    trustsensehub = true
}

local function hasPopupNamePart(name)
    local lowerName = string.lower(name)
    for _, part in ipairs(PopupNameParts) do
        if string.find(lowerName, part, 1, true) then
            return true
        end
    end
    return false
end

local function applyClassicFpsSettings(aggressiveMode)
    if aggressiveMode then
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    end

    trySet(Lighting, "GlobalShadows", false)
    trySet(Lighting, "FogEnd", 9e9)
    trySet(Lighting, "EnvironmentDiffuseScale", 0)
    trySet(Lighting, "EnvironmentSpecularScale", 0)
    trySet(Lighting, "Brightness", 1)
    pcall(function()
        Lighting.Technology = Enum.Technology.Compatibility
    end)

    local terrain = Workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        trySet(terrain, "WaterWaveSize", 0)
        trySet(terrain, "WaterWaveSpeed", 0)
        trySet(terrain, "WaterReflectance", 0)
        trySet(terrain, "WaterTransparency", 1)
        trySet(terrain, "Decoration", false)
    end
end

local function optimizeVisualInstance(instance, aggressiveMode)
    if instance:IsA("BasePart") then
        trySet(instance, "CastShadow", false)
        if aggressiveMode then
            trySet(instance, "Reflectance", 0)
            if instance.Material ~= Enum.Material.ForceField and instance.Material ~= Enum.Material.Neon then
                trySet(instance, "Material", Enum.Material.SmoothPlastic)
            end
        end
        return
    end

    if instance:IsA("ParticleEmitter") then
        trySet(instance, "Enabled", false)
        if aggressiveMode then
            trySet(instance, "Rate", 0)
        end
        return
    end

    if instance:IsA("Trail") or instance:IsA("Beam") or instance:IsA("Smoke") or instance:IsA("Fire")
        or instance:IsA("Sparkles")
    then
        trySet(instance, "Enabled", false)
        return
    end

    if instance:IsA("PointLight") or instance:IsA("SpotLight") or instance:IsA("SurfaceLight") then
        trySet(instance, "Enabled", false)
        return
    end

    if instance:IsA("PostEffect") then
        trySet(instance, "Enabled", false)
        return
    end

    if aggressiveMode and (instance:IsA("Decal") or instance:IsA("Texture")) then
        trySet(instance, "Transparency", 1)
        return
    end

    if aggressiveMode and instance:IsA("MeshPart") then
        trySet(instance, "RenderFidelity", Enum.RenderFidelity.Performance)
        return
    end
end

local function disablePopupUi()
    if not LocalPlayer then
        return
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return
    end

    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            local lowerName = string.lower(gui.Name)
            local shouldDisable = PopupGuiNameSet[gui.Name] == true
            if not shouldDisable and not ProtectedGuiNameSet[lowerName] and hasPopupNamePart(gui.Name) then
                shouldDisable = true
            end

            if shouldDisable then
                trySet(gui, "Enabled", false)
            end
        end
    end

    local mainGui = playerGui:FindFirstChild("Main")
    if mainGui then
        local weatherContainer = mainGui:FindFirstChild("WeatherContainer", true)
        if weatherContainer and weatherContainer:IsA("GuiObject") then
            trySet(weatherContainer, "Visible", false)
        end
    end
end

local function findRollStateRemote()
    if not LocalPlayer then
        return nil
    end

    local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        return nil
    end

    local remote = playerGui:FindFirstChild("RollState", true)
    if remote and remote:IsA("RemoteFunction") then
        return remote
    end

    return nil
end

local function findPotionToolByName(potionName)
    if not LocalPlayer then
        return nil
    end

    local character = LocalPlayer.Character
    if character then
        local characterTool = character:FindFirstChild(potionName)
        if characterTool and characterTool:IsA("Tool") then
            return characterTool
        end
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") and child.Name == potionName then
                return child
            end
        end

        local profileData = getProfileData()
        if profileData and profileData.equipping == potionName then
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Tool") then
                    return child
                end
            end
        end
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if backpack then
        local backpackTool = backpack:FindFirstChild(potionName)
        if backpackTool and backpackTool:IsA("Tool") then
            return backpackTool
        end
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") and child.Name == potionName then
                return child
            end
        end
    end

    return nil
end

local function activatePotionTool(potionName)
    local tool = findPotionToolByName(potionName)
    if not tool then
        return false
    end

    if LocalPlayer and LocalPlayer.Character and tool.Parent ~= LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            pcall(function()
                humanoid:EquipTool(tool)
            end)
            task.wait()
            tool = findPotionToolByName(potionName) or tool
        end
    end

    local ok = pcall(function()
        tool:Activate()
    end)
    return ok
end

local RestockDiceNames = {}
for diceName, diceInfo in pairs(DiceData) do
    if type(diceInfo) == "table" and not diceInfo.Not_Restockable then
        RestockDiceNames[#RestockDiceNames + 1] = diceName
    end
end

table.sort(RestockDiceNames, function(a, b)
    local aOrder = DiceData[a].Layout_Order or math.huge
    local bOrder = DiceData[b].Layout_Order or math.huge
    if aOrder == bOrder then
        return a < b
    end
    return aOrder < bOrder
end)

local DiceByLuckNames = {}
for diceName in pairs(DiceData) do
    DiceByLuckNames[#DiceByLuckNames + 1] = diceName
end

table.sort(DiceByLuckNames, function(a, b)
    local aLuck = DiceData[a].Luck_Percentage or 0
    local bLuck = DiceData[b].Luck_Percentage or 0
    if aLuck == bLuck then
        return a < b
    end
    return aLuck > bLuck
end)

local RestockPotionNames = {}
for potionName, potionInfo in pairs(PotionData) do
    if type(potionInfo) == "table" and not potionInfo.Not_Restockable and (potionInfo.Cost or 0) > 0 then
        RestockPotionNames[#RestockPotionNames + 1] = potionName
    end
end

table.sort(RestockPotionNames, function(a, b)
    local aOrder = PotionData[a].Layout_Order or math.huge
    local bOrder = PotionData[b].Layout_Order or math.huge
    if aOrder == bOrder then
        return a < b
    end
    return aOrder < bOrder
end)

local EggPrices = {
    CatEgg = 45000,
    DogEgg = 2100000,
    CubeEgg = 11500000,
    SlimeEgg = 125000000,
    NullEgg = 400000000,
    AquaEgg = 2500000000,
    MartianEgg = 1200000000000,
    BackroomsEgg = 100000000000000,
    AngelEgg = 1e16,
    MechEgg = 2e18
}

local EggNames = {}
for eggName in pairs(EggPrices) do
    EggNames[#EggNames + 1] = eggName
end

table.sort(EggNames, function(a, b)
    local aPrice = tonumber(EggPrices[a]) or math.huge
    local bPrice = tonumber(EggPrices[b]) or math.huge
    if aPrice == bPrice then
        return a < b
    end
    return aPrice < bPrice
end)

local function getEggPrice(eggName)
    return tonumber(EggPrices[eggName]) or 0
end

local function hasEggName(eggName)
    return type(eggName) == "string" and table.find(EggNames, eggName) ~= nil
end

if not hasEggName(Hub.Config.AutoBuyEggs.EggName) then
    Hub.Config.AutoBuyEggs.EggName = EggNames[1]
end

local WeatherEventStats = {}
for _, mutationInfo in pairs(MutationData) do
    if type(mutationInfo) == "table" then
        local eventName = mutationInfo.Event
        if type(eventName) == "string" and eventName ~= "" then
            local stats = WeatherEventStats[eventName]
            if not stats then
                stats = {
                    MaxCoinMultiplier = 0,
                    MaxGemMultiplier = 0,
                    MaxWeight = 0
                }
                WeatherEventStats[eventName] = stats
            end

            stats.MaxCoinMultiplier = math.max(stats.MaxCoinMultiplier, tonumber(mutationInfo.CoinMultiplier) or 0)
            stats.MaxGemMultiplier = math.max(stats.MaxGemMultiplier, tonumber(mutationInfo.GemMultiplier) or 0)
            stats.MaxWeight = math.max(stats.MaxWeight, tonumber(mutationInfo.Weight) or 0)
        end
    end
end

local WeatherEventNames = {}
for eventName in pairs(WeatherEventStats) do
    WeatherEventNames[#WeatherEventNames + 1] = eventName
end

table.sort(WeatherEventNames, function(a, b)
    local aStats = WeatherEventStats[a]
    local bStats = WeatherEventStats[b]
    local aCoins = (aStats and aStats.MaxCoinMultiplier) or 0
    local bCoins = (bStats and bStats.MaxCoinMultiplier) or 0
    if aCoins == bCoins then
        return a < b
    end
    return aCoins > bCoins
end)

local function getCurrentWeatherEvent()
    local eventName = StatusState:GetAttribute("event")
    if type(eventName) ~= "string" or eventName == "" then
        return nil
    end
    return eventName
end

local function getWeatherTimeRemaining()
    local endTime = tonumber(StatusState:GetAttribute("event_end_time")) or 0
    if endTime <= 0 then
        return 0
    end
    return math.max(0, endTime - os.time())
end

local function isSmartWeatherEvent(eventName)
    local stats = WeatherEventStats[eventName]
    if type(stats) ~= "table" then
        return false
    end

    local minCoins = Hub.Config.AutoOpenBestDiceWeather.SmartMinCoinMultiplier or 6
    if (stats.MaxWeight or 0) <= 0 then
        return false
    end
    return (stats.MaxCoinMultiplier or 0) >= minCoins
end

local function shouldOpenBestDiceForWeather()
    local weatherConfig = Hub.Config.AutoOpenBestDiceWeather
    if not weatherConfig or not weatherConfig.Enabled then
        return true
    end

    local eventName = getCurrentWeatherEvent()
    if not eventName then
        return false
    end

    return isSmartWeatherEvent(eventName)
end

local function canBuyItem(profileData, itemInfo)
    local rebirths = profileData.Rebirths or 0
    local requiredRebirths = itemInfo.RebirthsRequired or 0
    return rebirths >= requiredRebirths
end

local function hasInfiniteBasicDice(profileData)
    local gamepasses = profileData.gamepasses
    return type(gamepasses) == "table" and gamepasses.InfiniteDiceRolls == true
end

local function hasExtraInventoryPass(profileData)
    local gamepasses = profileData.gamepasses
    return type(gamepasses) == "table" and gamepasses["+500Inventory"] == true
end

local function getInventoryCount(profileData)
    local count = 0

    local hotbar = profileData.hotbar
    if type(hotbar) == "table" then
        for _ in pairs(hotbar) do
            count = count + 1
        end
    end

    local inv = profileData.inv
    if type(inv) == "table" then
        local unique = inv.unique
        if type(unique) == "table" then
            for _ in pairs(unique) do
                count = count + 1
            end
        end

        local stackable = inv.stackable
        if type(stackable) == "table" then
            for _ in pairs(stackable) do
                count = count + 1
            end
        end
    end

    return count
end

local function isInventoryFull(profileData)
    local maxSize = hasExtraInventoryPass(profileData) and 1500 or 1000
    return getInventoryCount(profileData) >= maxSize
end

local function getBestOpenableDice(profileData)
    local ownedDices = profileData.dices
    if type(ownedDices) ~= "table" then
        return nil
    end

    local infiniteBasic = hasInfiniteBasicDice(profileData)
    for _, diceName in ipairs(DiceByLuckNames) do
        local diceInfo = DiceData[diceName]
        if canBuyItem(profileData, diceInfo) then
            local count = ownedDices[diceName] or 0
            if count > 0 or (diceName == "Basic Dice" and infiniteBasic) then
                return diceName
            end
        end
    end

    return nil
end

local PotionPriority = {
    Luck = { "Luck Potion 3", "Luck Potion 2", "Luck Potion 1" },
    Money = { "Money Potion 3", "Money Potion 2", "Money Potion 1" },
    Mutation = { "Mutation Chance Potion 1" },
    NoConsumeDice = { "No Consume Dice Potion 1" },
    Prismatic = { "Prismatic Potion" }
}

local function getStackableCount(profileData, itemName)
    local inv = profileData.inv
    if type(inv) ~= "table" then
        return 0
    end

    local stackable = inv.stackable
    if type(stackable) ~= "table" then
        return 0
    end

    local entry = stackable[itemName]
    if type(entry) == "number" then
        return entry
    end
    if type(entry) == "table" then
        return tonumber(entry.count) or 0
    end
    return 0
end

local function isBuffActive(profileData, buffName)
    local buffs = profileData.buffs
    if type(buffs) ~= "table" then
        return false
    end

    local buffData = buffs[buffName]
    if type(buffData) ~= "table" then
        return false
    end

    local value1 = tonumber(buffData[1]) or 0
    local value2 = tonumber(buffData[2]) or 0
    return value1 > 0 or value2 > 0
end

local function isAnyBuffActive(profileData, buffNames)
    for _, buffName in ipairs(buffNames) do
        if isBuffActive(profileData, buffName) then
            return true
        end
    end
    return false
end

local function getFirstOwnedPotion(profileData, potionNames)
    for _, potionName in ipairs(potionNames) do
        if getStackableCount(profileData, potionName) > 0 then
            return potionName
        end
    end
    return nil
end

local function getIndexClaimableCount(profileData)
    local indexData = profileData.index
    if type(indexData) ~= "table" then
        return 0
    end

    local claimableCount = 0
    for _, mutationData in pairs(indexData) do
        if type(mutationData) == "table" then
            for _, claimState in pairs(mutationData) do
                if claimState == false then
                    claimableCount = claimableCount + 1
                end
            end
        end
    end

    return claimableCount
end

local function getWheelSpinCount()
    if not LocalPlayer then
        return 0
    end

    local rewards = LocalPlayer:FindFirstChild("rewards")
    if not rewards then
        return 0
    end

    local spinCountValue = rewards:FindFirstChild("SpinCount")
    if not spinCountValue then
        return 0
    end

    return tonumber(spinCountValue.Value) or 0
end

local function getCharacterTouchPart()
    if not LocalPlayer or not LocalPlayer.Character then
        return nil
    end

    local character = LocalPlayer.Character
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return nil
    end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart and rootPart:IsA("BasePart") then
        return rootPart
    end

    return nil
end

local function findCollectTouchParts()
    local parts = {}
    for _, instance in ipairs(Workspace:GetDescendants()) do
        if instance:IsA("BasePart") and instance.Name == "Touch" then
            local parent = instance.Parent
            if parent and parent.Name == "Collect" and instance:FindFirstChildOfClass("TouchTransmitter") then
                parts[#parts + 1] = instance
            end
        end
    end
    return parts
end

local function triggerTouchPart(touchPart, characterPart)
    if type(firetouchinterest) ~= "function" then
        return false
    end

    local touched = false
    local okBegin = pcall(firetouchinterest, characterPart, touchPart, 0)
    local okEnd = pcall(firetouchinterest, characterPart, touchPart, 1)
    touched = okBegin or okEnd or touched

    local okReverseBegin = pcall(firetouchinterest, touchPart, characterPart, 0)
    local okReverseEnd = pcall(firetouchinterest, touchPart, characterPart, 1)
    touched = okReverseBegin or okReverseEnd or touched

    return touched
end

local function findDiceManagerStateTable()
    if type(getgc) ~= "function" then
        return nil
    end

    local ok, gcObjects = pcall(function()
        return getgc(true)
    end)
    if not ok or type(gcObjects) ~= "table" then
        ok, gcObjects = pcall(function()
            return getgc()
        end)
    end
    if not ok or type(gcObjects) ~= "table" then
        return nil
    end

    for _, obj in ipairs(gcObjects) do
        if type(obj) == "table"
            and rawget(obj, "DiceSelected") ~= nil
            and rawget(obj, "isRolling") ~= nil
            and rawget(obj, "isHidden") ~= nil
            and rawget(obj, "autoSkipEnabled") ~= nil
        then
            return obj
        end
    end

    return nil
end

local function buyFromRestockShop(profileData, coinsBudget)
    local diceStock = profileData.dice_stock
    if type(diceStock) ~= "table" then
        return coinsBudget
    end

    for _, diceName in ipairs(RestockDiceNames) do
        local diceInfo = DiceData[diceName]
        local stock = diceStock[diceName] or 0
        local cost = diceInfo.Cost or 0

        if stock > 0 and cost > 0 and canBuyItem(profileData, diceInfo) then
            local affordable = math.floor(coinsBudget / cost)
            local purchaseAmount = math.min(stock, affordable)

            if purchaseAmount > 0 then
                local purchased = safeInvoke(BuyRemote, diceName, purchaseAmount, "dice")
                if purchased then
                    coinsBudget = coinsBudget - purchaseAmount * cost
                    task.wait(Hub.Config.AutoBuyAllDice.BuyDelay)
                end
            end
        end
    end

    return coinsBudget
end

local function buyFromPotionRestockShop(profileData, coinsBudget)
    local potionStock = profileData.potion_stock
    if type(potionStock) ~= "table" then
        return coinsBudget
    end

    for _, potionName in ipairs(RestockPotionNames) do
        local potionInfo = PotionData[potionName]
        local stock = potionStock[potionName] or 0
        local cost = potionInfo.Cost or 0

        if stock > 0 and cost > 0 and canBuyItem(profileData, potionInfo) then
            local affordable = math.floor(coinsBudget / cost)
            local purchaseAmount = math.min(stock, affordable)

            if purchaseAmount > 0 then
                local purchased = safeInvoke(BuyRemote, potionName, purchaseAmount, "potion")
                if purchased then
                    coinsBudget = coinsBudget - purchaseAmount * cost
                    task.wait(Hub.Config.AutoBuyAllDice.BuyDelay)
                end
            end
        end
    end

    return coinsBudget
end

local function buyFromMerchantShop(profileData, coinsBudget)
    local requestData = safeInvoke(MerchantRequestRemote)
    if type(requestData) ~= "table" or type(requestData.wares) ~= "table" then
        return coinsBudget
    end

    local maxPurchases = Hub.Config.AutoBuyAllDice.MaxMerchantPurchasesPerTick
    local purchasesThisTick = 0

    for offerIndex, offerData in ipairs(requestData.wares) do
        if purchasesThisTick >= maxPurchases then
            break
        end

        local diceName = offerData.Name
        local diceInfo = DiceData[diceName]
        local stock = tonumber(offerData.Stock) or 0

        if diceInfo and stock > 0 and canBuyItem(profileData, diceInfo) then
            local cost = diceInfo.Cost or 0
            if cost > 0 then
                local affordable = math.floor(coinsBudget / cost)
                local allowedByCap = maxPurchases - purchasesThisTick
                local purchaseAmount = math.min(stock, affordable, allowedByCap)

                for _ = 1, purchaseAmount do
                    local purchased = safeInvoke(MerchantBuyRemote, offerIndex)
                    if not purchased then
                        break
                    end

                    coinsBudget = coinsBudget - cost
                    purchasesThisTick = purchasesThisTick + 1
                    task.wait(Hub.Config.AutoBuyAllDice.BuyDelay)
                end
            end
        end
    end

    return coinsBudget
end

local function replaceFeature(name, featureObject)
    local previousFeature = Hub.Features[name]
    if previousFeature and type(previousFeature.Stop) == "function" then
        pcall(function()
            previousFeature:Stop()
        end)
    end
    Hub.Features[name] = featureObject
end

local function stopAllFeatures()
    if Hub.Config.AutoBuyAllDice then
        Hub.Config.AutoBuyAllDice.Enabled = false
    end
    if Hub.Config.AutoBuyEggs then
        Hub.Config.AutoBuyEggs.Enabled = false
    end
    if Hub.Config.AutoOpenBestDice then
        Hub.Config.AutoOpenBestDice.Enabled = false
    end
    if Hub.Config.AutoUsePotions then
        Hub.Config.AutoUsePotions.Enabled = false
    end
    if Hub.Config.AutoCollectQuests then
        Hub.Config.AutoCollectQuests.Enabled = false
    end
    if Hub.Config.AutoClaimAllIndex then
        Hub.Config.AutoClaimAllIndex.Enabled = false
    end
    if Hub.Config.AutoCollectCoins then
        Hub.Config.AutoCollectCoins.Enabled = false
    end
    if Hub.Config.AutoSpinWheel then
        Hub.Config.AutoSpinWheel.Enabled = false
    end
    if Hub.Config.AntiAFK then
        Hub.Config.AntiAFK.Enabled = false
    end
    if Hub.Config.FPSBoost then
        Hub.Config.FPSBoost.Enabled = false
    end

    for _, feature in pairs(Hub.Features) do
        if type(feature) == "table" then
            if type(feature.SetEnabled) == "function" then
                pcall(function()
                    feature:SetEnabled(false)
                end)
            end
            if type(feature.Stop) == "function" then
                pcall(function()
                    feature:Stop()
                end)
            end
        end
    end

    if LocalPlayer and LocalPlayer:GetAttribute("Auto") == true then
        pcall(function()
            LocalPlayer:SetAttribute("Auto", false)
        end)
    end

    local diceManagerState = findDiceManagerStateTable()
    if type(diceManagerState) == "table" then
        diceManagerState.isRolling = false
        diceManagerState.DiceSelected = nil
    end
end

local function unloadHub()
    Hub.RunId = (Hub.RunId or 0) + 1
    Hub.IsUnloaded = true
    stopAllFeatures()
    Hub.Features = {}

    local existingUI = Hub.UI
    if existingUI and existingUI.Library and type(existingUI.Library.Unload) == "function" then
        pcall(function()
            existingUI.Library:Unload()
        end)
    end
    Hub.UI = nil
end

local AutoBuyAllDiceFeature = {
    Name = "AutoBuyAllDice",
    Enabled = Hub.Config.AutoBuyAllDice.Enabled,
    _running = false,
    _thread = nil
}

function AutoBuyAllDiceFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AutoBuyAllDiceFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local profileData = getProfileData()
    if not profileData then
        return
    end

    local coinsBudget = profileData.Coins or 0
    if coinsBudget <= 0 then
        return
    end

    if Hub.Config.AutoBuyAllDice.IncludeRestockShop then
        coinsBudget = buyFromRestockShop(profileData, coinsBudget)
    end

    if coinsBudget > 0 and Hub.Config.AutoBuyAllDice.IncludeRestockPotions then
        coinsBudget = buyFromPotionRestockShop(profileData, coinsBudget)
    end

    if coinsBudget > 0 and Hub.Config.AutoBuyAllDice.IncludeMerchantShop then
        coinsBudget = buyFromMerchantShop(profileData, coinsBudget)
    end
end

function AutoBuyAllDiceFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Tick failed:", err)
            end
            task.wait(Hub.Config.AutoBuyAllDice.RunInterval)
        end
    end)
end

function AutoBuyAllDiceFeature:Stop()
    self._running = false
    self._thread = nil
end

replaceFeature("AutoBuyAllDice", AutoBuyAllDiceFeature)

local AutoBuyEggsFeature = {
    Name = "AutoBuyEggs",
    Enabled = Hub.Config.AutoBuyEggs.Enabled,
    _running = false,
    _thread = nil
}

function AutoBuyEggsFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AutoBuyEggsFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local profileData = getProfileData()
    if type(profileData) ~= "table" then
        return
    end

    local eggName = Hub.Config.AutoBuyEggs.EggName
    if not hasEggName(eggName) then
        return
    end

    local eggPrice = getEggPrice(eggName)
    if eggPrice <= 0 then
        return
    end

    local coins = tonumber(profileData.Coins) or 0
    if coins < eggPrice then
        return
    end

    local requestedAmount = Hub.Config.AutoBuyEggs.OpenAmount or 1
    local openAmount = math.max(1, math.min(100, math.floor(tonumber(requestedAmount) or 1)))
    local affordableAmount = math.floor(coins / eggPrice)
    local amountToOpen = math.min(openAmount, affordableAmount)
    if amountToOpen <= 0 then
        return
    end

    safeInvoke(RegularPetRemote, eggName, amountToOpen)
end

function AutoBuyEggsFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Auto buy eggs tick failed:", err)
            end
            task.wait(math.max(0.2, Hub.Config.AutoBuyEggs.RunInterval))
        end
    end)
end

function AutoBuyEggsFeature:Stop()
    self._running = false
    self._thread = nil
end

replaceFeature("AutoBuyEggs", AutoBuyEggsFeature)

local AutoOpenBestDiceFeature = {
    Name = "AutoOpenBestDice",
    Enabled = Hub.Config.AutoOpenBestDice.Enabled,
    _running = false,
    _thread = nil,
    _lastDiceName = nil,
    _diceManagerState = nil,
    _nextStateSearchAt = 0,
    _rollStateRemote = nil,
    _nextRollStateSearchAt = 0
}

function AutoOpenBestDiceFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AutoOpenBestDiceFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local profileData = getProfileData()
    if not profileData then
        return
    end

    if not shouldOpenBestDiceForWeather() then
        return
    end

    local settings = profileData.settings
    if type(settings) == "table" then
        settings.RollHighest = true
    end

    local bestDiceName = getBestOpenableDice(profileData)
    if not bestDiceName then
        return
    end

    local now = os.clock()
    if (not self._diceManagerState or type(self._diceManagerState) ~= "table")
        and now >= self._nextStateSearchAt
    then
        self._diceManagerState = findDiceManagerStateTable()
        self._nextStateSearchAt = now + 2
    end

    if self._diceManagerState and self._diceManagerState.DiceSelected ~= bestDiceName then
        self._diceManagerState.DiceSelected = bestDiceName
    end

    local fired = safeFire(UpdateRollingDiceRemote, bestDiceName)
    if fired then
        self._lastDiceName = bestDiceName
    end

    if LocalPlayer and LocalPlayer:GetAttribute("Auto") == true then
        pcall(function()
            LocalPlayer:SetAttribute("Auto", false)
        end)
    end

    if isInventoryFull(profileData) then
        return
    end

    if (not self._rollStateRemote or not self._rollStateRemote.Parent) and now >= self._nextRollStateSearchAt then
        self._rollStateRemote = findRollStateRemote()
        self._nextRollStateSearchAt = now + 2
    end

    if not self._rollStateRemote then
        return
    end

    if (LocalPlayer and LocalPlayer:GetAttribute("Rolling") == true)
        or (self._diceManagerState and self._diceManagerState.isRolling == true)
    then
        return
    end

    safeInvoke(self._rollStateRemote)
end

function AutoOpenBestDiceFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Best dice tick failed:", err)
            end
            task.wait(Hub.Config.AutoOpenBestDice.RunInterval)
        end
    end)
end

function AutoOpenBestDiceFeature:Stop()
    self._running = false
    self._thread = nil
    self._lastDiceName = nil
    self._diceManagerState = nil
    self._nextStateSearchAt = 0
    self._rollStateRemote = nil
    self._nextRollStateSearchAt = 0
end

replaceFeature("AutoOpenBestDice", AutoOpenBestDiceFeature)

local AutoUsePotionsFeature = {
    Name = "AutoUsePotions",
    Enabled = Hub.Config.AutoUsePotions.Enabled,
    _running = false,
    _thread = nil,
    _nextUseByPotion = {}
}

function AutoUsePotionsFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AutoUsePotionsFeature:_tryUsePotion(profileData, potionName, now)
    local nextAllowedAt = self._nextUseByPotion[potionName] or 0
    if now < nextAllowedAt then
        return false
    end

    local useDelay = math.max(0.1, Hub.Config.AutoUsePotions.UseDelay or 0.5)
    self._nextUseByPotion[potionName] = now + useDelay

    local beforeCount = getStackableCount(profileData, potionName)
    if beforeCount <= 0 then
        return false
    end

    local equipped = safeInvoke(EquipRemote, potionName, true)
    if not equipped then
        return false
    end

    local activated = false
    for _ = 1, 4 do
        if activatePotionTool(potionName) then
            activated = true
            break
        end
        task.wait(0.08)
    end

    task.wait(0.12)
    local latestProfileData = getProfileData() or profileData
    local afterCount = getStackableCount(latestProfileData, potionName)
    local consumed = afterCount < beforeCount or isBuffActive(latestProfileData, potionName)

    safeInvoke(EquipRemote, potionName, false)

    return consumed or activated
end

function AutoUsePotionsFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local profileData = getProfileData()
    if not profileData then
        return
    end

    local now = os.clock()
    local config = Hub.Config.AutoUsePotions

    if config.UsePrismatic and not isBuffActive(profileData, "Prismatic Potion") then
        local prismaticPotion = getFirstOwnedPotion(profileData, PotionPriority.Prismatic)
        if prismaticPotion and self:_tryUsePotion(profileData, prismaticPotion, now) then
            return
        end
    end

    if config.UseLuck and not isAnyBuffActive(profileData, PotionPriority.Luck) then
        local luckPotion = getFirstOwnedPotion(profileData, PotionPriority.Luck)
        if luckPotion and self:_tryUsePotion(profileData, luckPotion, now) then
            return
        end
    end

    if config.UseMoney and not isAnyBuffActive(profileData, PotionPriority.Money) then
        local moneyPotion = getFirstOwnedPotion(profileData, PotionPriority.Money)
        if moneyPotion and self:_tryUsePotion(profileData, moneyPotion, now) then
            return
        end
    end

    if config.UseMutationChance and not isAnyBuffActive(profileData, PotionPriority.Mutation) then
        local mutationPotion = getFirstOwnedPotion(profileData, PotionPriority.Mutation)
        if mutationPotion and self:_tryUsePotion(profileData, mutationPotion, now) then
            return
        end
    end

    if config.UseNoConsumeDice and not isAnyBuffActive(profileData, PotionPriority.NoConsumeDice) then
        local noConsumeDicePotion = getFirstOwnedPotion(profileData, PotionPriority.NoConsumeDice)
        if noConsumeDicePotion then
            self:_tryUsePotion(profileData, noConsumeDicePotion, now)
        end
    end
end

function AutoUsePotionsFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Auto potion tick failed:", err)
            end
            task.wait(Hub.Config.AutoUsePotions.RunInterval)
        end
    end)
end

function AutoUsePotionsFeature:Stop()
    self._running = false
    self._thread = nil
    self._nextUseByPotion = {}
end

replaceFeature("AutoUsePotions", AutoUsePotionsFeature)

local AutoCollectQuestsFeature = {
    Name = "AutoCollectQuests",
    Enabled = Hub.Config.AutoCollectQuests.Enabled,
    _running = false,
    _thread = nil,
    _nextClaimByIndex = {},
    _nextResetCheckAt = 0
}

function AutoCollectQuestsFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AutoCollectQuestsFeature:_tryClaimQuest(questIndex, questEntry, now)
    if type(questEntry) ~= "table" then
        return false
    end

    if questEntry.claimed == true then
        return false
    end

    local questData = QuestData.getQuestData and QuestData.getQuestData(questEntry.id)
    if type(questData) ~= "table" then
        return false
    end

    local goal = tonumber(questData.goal) or math.huge
    local progress = tonumber(questEntry.prog) or 0
    if progress < goal then
        return false
    end

    local questKey = tostring(questIndex)
    local nextAllowedAt = self._nextClaimByIndex[questKey] or 0
    if now < nextAllowedAt then
        return false
    end

    local claimDelay = math.max(0.05, Hub.Config.AutoCollectQuests.ClaimDelay or 0.15)
    self._nextClaimByIndex[questKey] = now + claimDelay
    return safeInvoke(QuestRemote, "ClaimReward", questIndex) == true
end

function AutoCollectQuestsFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local profileData = getProfileData()
    if type(profileData) ~= "table" then
        return
    end

    local questsData = profileData.quests
    if type(questsData) ~= "table" then
        return
    end

    local activeQuests = questsData.active_quests
    if type(activeQuests) ~= "table" then
        return
    end

    local config = Hub.Config.AutoCollectQuests
    local now = os.clock()

    if config.CheckReset then
        local dailyTs = tonumber(questsData.daily_ts) or 0
        if (os.time() - dailyTs) >= 86400 and now >= self._nextResetCheckAt then
            self._nextResetCheckAt = now + math.max(1, config.ResetCheckInterval or 5.0)
            safeInvoke(QuestRemote, "CheckReset")
            return
        end
    end

    local claimDelay = math.max(0.05, config.ClaimDelay or 0.15)
    for questIndex, questEntry in pairs(activeQuests) do
        local claimed = self:_tryClaimQuest(questIndex, questEntry, now)
        if claimed then
            task.wait(claimDelay)
        end
    end
end

function AutoCollectQuestsFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Auto quest tick failed:", err)
            end
            task.wait(math.max(0.2, Hub.Config.AutoCollectQuests.RunInterval))
        end
    end)
end

function AutoCollectQuestsFeature:Stop()
    self._running = false
    self._thread = nil
    self._nextClaimByIndex = {}
    self._nextResetCheckAt = 0
end

replaceFeature("AutoCollectQuests", AutoCollectQuestsFeature)

local AutoClaimAllIndexFeature = {
    Name = "AutoClaimAllIndex",
    Enabled = Hub.Config.AutoClaimAllIndex.Enabled,
    _running = false,
    _thread = nil
}

function AutoClaimAllIndexFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AutoClaimAllIndexFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local profileData = getProfileData()
    if type(profileData) ~= "table" then
        return
    end

    if getIndexClaimableCount(profileData) <= 0 then
        return
    end

    safeInvoke(IndexClaimAllRemote)
end

function AutoClaimAllIndexFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Auto index claim tick failed:", err)
            end
            task.wait(math.max(0.2, Hub.Config.AutoClaimAllIndex.RunInterval))
        end
    end)
end

function AutoClaimAllIndexFeature:Stop()
    self._running = false
    self._thread = nil
end

replaceFeature("AutoClaimAllIndex", AutoClaimAllIndexFeature)

local AutoCollectCoinsFeature = {
    Name = "AutoCollectCoins",
    Enabled = Hub.Config.AutoCollectCoins.Enabled,
    _running = false,
    _thread = nil,
    _touchParts = {},
    _nextTouchPartScanAt = 0
}

function AutoCollectCoinsFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AutoCollectCoinsFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local characterPart = getCharacterTouchPart()
    if not characterPart then
        return
    end

    local now = os.clock()
    if now >= self._nextTouchPartScanAt or #self._touchParts == 0 then
        self._touchParts = findCollectTouchParts()
        self._nextTouchPartScanAt = now + 2
    end

    for _, touchPart in ipairs(self._touchParts) do
        if touchPart and touchPart.Parent and touchPart:FindFirstChildOfClass("TouchTransmitter") then
            triggerTouchPart(touchPart, characterPart)
        end
    end
end

function AutoCollectCoinsFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Auto collect coins tick failed:", err)
            end
            task.wait(math.max(0.2, Hub.Config.AutoCollectCoins.RunInterval))
        end
    end)
end

function AutoCollectCoinsFeature:Stop()
    self._running = false
    self._thread = nil
    self._touchParts = {}
    self._nextTouchPartScanAt = 0
end

replaceFeature("AutoCollectCoins", AutoCollectCoinsFeature)

local AutoSpinWheelFeature = {
    Name = "AutoSpinWheel",
    Enabled = Hub.Config.AutoSpinWheel.Enabled,
    _running = false,
    _thread = nil
}

function AutoSpinWheelFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AutoSpinWheelFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    if getWheelSpinCount() <= 0 then
        return
    end

    safeInvoke(SpinRequestRemote)
end

function AutoSpinWheelFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Auto spin wheel tick failed:", err)
            end
            task.wait(math.max(0.2, Hub.Config.AutoSpinWheel.RunInterval))
        end
    end)
end

function AutoSpinWheelFeature:Stop()
    self._running = false
    self._thread = nil
end

replaceFeature("AutoSpinWheel", AutoSpinWheelFeature)

local AntiAFKFeature = {
    Name = "AntiAFK",
    Enabled = Hub.Config.AntiAFK.Enabled,
    _running = false,
    _thread = nil,
    _nextMobilePulseAt = 0,
    _nextConnectionScanAt = 0
}

function AntiAFKFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function AntiAFKFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local config = Hub.Config.AntiAFK
    local now = os.clock()

    if config.UseMobileMethod and now >= self._nextMobilePulseAt then
        doMobileAntiAfkPulse()
        self._nextMobilePulseAt = now + math.max(15, config.MobilePulseInterval or 45)
    end

    if config.DisableIdledConnections and now >= self._nextConnectionScanAt then
        disableIdledConnections()
        self._nextConnectionScanAt = now + math.max(1, config.ConnectionScanInterval or 8)
    end
end

function AntiAFKFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._nextMobilePulseAt = 0
    self._nextConnectionScanAt = 0
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("Anti AFK tick failed:", err)
            end
            task.wait(0.25)
        end
    end)
end

function AntiAFKFeature:Stop()
    self._running = false
    self._thread = nil
    self._nextMobilePulseAt = 0
    self._nextConnectionScanAt = 0
end

replaceFeature("AntiAFK", AntiAFKFeature)

local FPSBoostFeature = {
    Name = "FPSBoost",
    Enabled = Hub.Config.FPSBoost.Enabled,
    _running = false,
    _thread = nil,
    _connections = {},
    _optimized = setmetatable({}, { __mode = "k" }),
    _nextSettingsSyncAt = 0,
    _nextSettingToggleAt = {}
}

function FPSBoostFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
end

function FPSBoostFeature:_disconnectAll()
    for _, connection in ipairs(self._connections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end
    self._connections = {}
end

function FPSBoostFeature:_optimizeInstance(instance)
    if self._optimized[instance] then
        return
    end

    self._optimized[instance] = true
    optimizeVisualInstance(instance, Hub.Config.FPSBoost.AggressiveMode)
end

function FPSBoostFeature:_optimizeExisting()
    for _, instance in ipairs(Workspace:GetDescendants()) do
        self:_optimizeInstance(instance)
    end

    for _, instance in ipairs(Lighting:GetDescendants()) do
        self:_optimizeInstance(instance)
    end
end

function FPSBoostFeature:_bindNewInstances()
    self:_disconnectAll()

    self._connections[#self._connections + 1] = Workspace.DescendantAdded:Connect(function(instance)
        if not self._running or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        self:_optimizeInstance(instance)
    end)

    self._connections[#self._connections + 1] = Lighting.DescendantAdded:Connect(function(instance)
        if not self._running or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        self:_optimizeInstance(instance)
    end)
end

function FPSBoostFeature:_toggleSettingOff(profileData, settingName, now)
    local settings = profileData.settings
    if type(settings) ~= "table" then
        return
    end

    if settings[settingName] == false then
        return
    end

    local nextAllowedAt = self._nextSettingToggleAt[settingName] or 0
    if now < nextAllowedAt then
        return
    end

    self._nextSettingToggleAt[settingName] = now + 1.25
    local result = safeInvoke(UpdateSettingsRemote, settingName)
    if type(result) == "boolean" then
        settings[settingName] = result
    end
end

function FPSBoostFeature:_enforceCutscenesOff(profileData, now)
    local settings = profileData.settings
    if type(settings) ~= "table" then
        return
    end

    local cutscenes = settings.Cutscenes
    if type(cutscenes) ~= "table" then
        cutscenes = {}
        settings.Cutscenes = cutscenes
    end

    local maxToggles = 6
    local togglesUsed = 0

    for rarityName in pairs(RarityData) do
        if togglesUsed >= maxToggles then
            break
        end

        if cutscenes[rarityName] ~= false then
            local key = "Cutscenes:" .. tostring(rarityName)
            local nextAllowedAt = self._nextSettingToggleAt[key] or 0
            if now >= nextAllowedAt then
                self._nextSettingToggleAt[key] = now + 1.25
                local result = safeInvoke(UpdateSettingsRemote, "Cutscenes", rarityName)
                if type(result) == "boolean" then
                    cutscenes[rarityName] = result
                end
                togglesUsed = togglesUsed + 1
            end
        end
    end
end

function FPSBoostFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local config = Hub.Config.FPSBoost
    applyClassicFpsSettings(config.AggressiveMode)

    if config.DisablePopups then
        disablePopupUi()
    end

    local now = os.clock()
    if now < self._nextSettingsSyncAt then
        return
    end
    self._nextSettingsSyncAt = now + FPS_BOOST_SETTINGS_INTERVAL

    local profileData = getProfileData()
    if not profileData then
        return
    end

    if config.DisableAnnouncements then
        self:_toggleSettingOff(profileData, "Announcements", now)
    end
    if config.DisableRollSFX then
        self:_toggleSettingOff(profileData, "Roll_SFX", now)
    end
    if config.DisableTitleAura then
        self:_toggleSettingOff(profileData, "TitleAuraVisibility", now)
    end
    if config.DisableCutscenes then
        self:_enforceCutscenesOff(profileData, now)
    end
end

function FPSBoostFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self._optimized = setmetatable({}, { __mode = "k" })
    self._nextSettingsSyncAt = 0
    self._nextSettingToggleAt = {}

    self:_optimizeExisting()
    self:_bindNewInstances()

    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                debugLog("FPS boost tick failed:", err)
            end
            task.wait(FPS_BOOST_TICK_INTERVAL)
        end
    end)
end

function FPSBoostFeature:Stop()
    self._running = false
    self._thread = nil
    self:_disconnectAll()
    self._optimized = setmetatable({}, { __mode = "k" })
    self._nextSettingsSyncAt = 0
    self._nextSettingToggleAt = {}
end

replaceFeature("FPSBoost", FPSBoostFeature)

local function setAutoBuyEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AutoBuyAllDice.Enabled = nextState
    AutoBuyAllDiceFeature:SetEnabled(nextState)

    if nextState then
        AutoBuyAllDiceFeature:Start()
    else
        AutoBuyAllDiceFeature:Stop()
    end
end

local function setAutoBuyEggsEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AutoBuyEggs.Enabled = nextState
    AutoBuyEggsFeature:SetEnabled(nextState)

    if nextState then
        AutoBuyEggsFeature:Start()
    else
        AutoBuyEggsFeature:Stop()
    end
end

local function setAutoOpenBestDiceEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AutoOpenBestDice.Enabled = nextState
    AutoOpenBestDiceFeature:SetEnabled(nextState)

    if nextState then
        AutoOpenBestDiceFeature:Start()
    else
        AutoOpenBestDiceFeature:Stop()
    end
end

local function setAutoUsePotionsEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AutoUsePotions.Enabled = nextState
    AutoUsePotionsFeature:SetEnabled(nextState)

    if nextState then
        AutoUsePotionsFeature:Start()
    else
        AutoUsePotionsFeature:Stop()
    end
end

local function setAutoCollectQuestsEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AutoCollectQuests.Enabled = nextState
    AutoCollectQuestsFeature:SetEnabled(nextState)

    if nextState then
        AutoCollectQuestsFeature:Start()
    else
        AutoCollectQuestsFeature:Stop()
    end
end

local function setAutoClaimAllIndexEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AutoClaimAllIndex.Enabled = nextState
    AutoClaimAllIndexFeature:SetEnabled(nextState)

    if nextState then
        AutoClaimAllIndexFeature:Start()
    else
        AutoClaimAllIndexFeature:Stop()
    end
end

local function setAutoCollectCoinsEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AutoCollectCoins.Enabled = nextState
    AutoCollectCoinsFeature:SetEnabled(nextState)

    if nextState then
        AutoCollectCoinsFeature:Start()
    else
        AutoCollectCoinsFeature:Stop()
    end
end

local function setAutoSpinWheelEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AutoSpinWheel.Enabled = nextState
    AutoSpinWheelFeature:SetEnabled(nextState)

    if nextState then
        AutoSpinWheelFeature:Start()
    else
        AutoSpinWheelFeature:Stop()
    end
end

local function setAntiAFKEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.AntiAFK.Enabled = nextState
    AntiAFKFeature:SetEnabled(nextState)

    if nextState then
        AntiAFKFeature:Start()
    else
        AntiAFKFeature:Stop()
    end
end

local function setFPSBoostEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end
    Hub.Config.FPSBoost.Enabled = nextState
    FPSBoostFeature:SetEnabled(nextState)

    if nextState then
        FPSBoostFeature:Start()
    else
        FPSBoostFeature:Stop()
    end
end

local function loadRemoteModule(url, label)
    local ok, moduleOrError = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if not ok then
        warn(string.format("[TrustsenseHub] Failed to load %s from %s: %s", label, url, tostring(moduleOrError)))
        return nil
    end

    return moduleOrError
end

local function setupObsidianUI()
    local existingUI = Hub.UI
    if existingUI and existingUI.Library and type(existingUI.Library.Unload) == "function" then
        pcall(function()
            existingUI.Library:Unload()
        end)
    end

    local repoBase = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
    local Library = loadRemoteModule(repoBase .. "Library.lua", "Obsidian Library")
    if not Library then
        return
    end

    local Window = Library:CreateWindow({
        Title = "Trustsense Hub",
        Footer = "Spin-a-Baddie",
        Icon = 94313740477699,
        ToggleKeybind = Enum.KeyCode.RightShift
    })

    local Tabs = {
        Main = Window:AddTab("Main", "house"),
        Automation = Window:AddTab("Automation", "layout-grid"),
        Weather = Window:AddTab("Weather", "cloud-sun"),
        Settings = Window:AddTab("Settings", "settings")
    }

    local autoBuyGroup = Tabs.Main:AddLeftGroupbox("Auto Buy Dice")
    local autoEggGroup = Tabs.Main:AddLeftGroupbox("Auto Buy Eggs")
    local discordGroup = Tabs.Main:AddRightGroupbox("Discord")
    local tuningGroup = Tabs.Main:AddRightGroupbox("Auto Buy Tuning")
    local bestDiceGroup = Tabs.Main:AddRightGroupbox("Auto Open Best Dice")
    local autoPotionGroup = Tabs.Automation:AddLeftGroupbox("Auto Use Potions")
    local autoQuestGroup = Tabs.Automation:AddLeftGroupbox("Auto Collect Quests")
    local autoIndexGroup = Tabs.Automation:AddLeftGroupbox("Auto Claim Index")
    local autoWheelGroup = Tabs.Automation:AddLeftGroupbox("Auto Spin Wheel")
    local autoCoinGroup = Tabs.Automation:AddRightGroupbox("Auto Collect Coins")
    local antiAfkGroup = Tabs.Automation:AddRightGroupbox("Anti AFK")
    local fpsBoostGroup = Tabs.Automation:AddRightGroupbox("FPS Boost")
    local weatherConditionGroup = Tabs.Weather:AddLeftGroupbox("Dice Weather Conditions")
    local weatherStatusGroup = Tabs.Weather:AddRightGroupbox("Weather Status")

    local enabledToggle = autoBuyGroup:AddToggle("AutoBuyAllDice_Enabled", {
        Text = "Enable Auto Buy",
        Default = Hub.Config.AutoBuyAllDice.Enabled
    })
    enabledToggle:OnChanged(function(value)
        setAutoBuyEnabled(value)
    end)

    local restockToggle = autoBuyGroup:AddToggle("AutoBuyAllDice_IncludeRestock", {
        Text = "Buy Restock Shop Dice",
        Default = Hub.Config.AutoBuyAllDice.IncludeRestockShop
    })
    restockToggle:OnChanged(function(value)
        Hub.Config.AutoBuyAllDice.IncludeRestockShop = not not value
    end)

    local potionRestockToggle = autoBuyGroup:AddToggle("AutoBuyAllDice_IncludeRestockPotions", {
        Text = "Buy Restock Potions",
        Default = Hub.Config.AutoBuyAllDice.IncludeRestockPotions
    })
    potionRestockToggle:OnChanged(function(value)
        Hub.Config.AutoBuyAllDice.IncludeRestockPotions = not not value
    end)

    local merchantToggle = autoBuyGroup:AddToggle("AutoBuyAllDice_IncludeMerchant", {
        Text = "Buy Merchant Shop Dice",
        Default = Hub.Config.AutoBuyAllDice.IncludeMerchantShop
    })
    merchantToggle:OnChanged(function(value)
        Hub.Config.AutoBuyAllDice.IncludeMerchantShop = not not value
    end)

    local intervalSlider = tuningGroup:AddSlider("AutoBuyAllDice_RunInterval", {
        Text = "Run Interval",
        Default = Hub.Config.AutoBuyAllDice.RunInterval,
        Min = 0.1,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    intervalSlider:OnChanged(function(value)
        Hub.Config.AutoBuyAllDice.RunInterval = math.max(0.1, value)
    end)

    local buyDelaySlider = tuningGroup:AddSlider("AutoBuyAllDice_BuyDelay", {
        Text = "Buy Delay",
        Default = Hub.Config.AutoBuyAllDice.BuyDelay,
        Min = 0.0,
        Max = 0.5,
        Rounding = 2,
        Suffix = "s"
    })
    buyDelaySlider:OnChanged(function(value)
        Hub.Config.AutoBuyAllDice.BuyDelay = math.max(0, value)
    end)

    local merchantCapSlider = tuningGroup:AddSlider("AutoBuyAllDice_MerchantCap", {
        Text = "Merchant Buys Per Tick",
        Default = Hub.Config.AutoBuyAllDice.MaxMerchantPurchasesPerTick,
        Min = 1,
        Max = 100,
        Rounding = 0
    })
    merchantCapSlider:OnChanged(function(value)
        Hub.Config.AutoBuyAllDice.MaxMerchantPurchasesPerTick = math.max(1, math.floor(value))
    end)

    local autoEggToggle = autoEggGroup:AddToggle("AutoBuyEggs_Enabled", {
        Text = "Enable Auto Buy Eggs",
        Default = Hub.Config.AutoBuyEggs.Enabled
    })
    autoEggToggle:OnChanged(function(value)
        setAutoBuyEggsEnabled(value)
    end)

    local autoEggDropdown = autoEggGroup:AddDropdown("AutoBuyEggs_EggName", {
        Text = "Egg",
        Values = EggNames,
        Default = Hub.Config.AutoBuyEggs.EggName,
        Searchable = true
    })
    autoEggDropdown:OnChanged(function(value)
        if hasEggName(value) then
            Hub.Config.AutoBuyEggs.EggName = value
        end
    end)

    local autoEggAmountSlider = autoEggGroup:AddSlider("AutoBuyEggs_OpenAmount", {
        Text = "Eggs Per Open",
        Default = Hub.Config.AutoBuyEggs.OpenAmount,
        Min = 1,
        Max = 100,
        Rounding = 0
    })
    autoEggAmountSlider:OnChanged(function(value)
        Hub.Config.AutoBuyEggs.OpenAmount = math.max(1, math.min(100, math.floor(value)))
    end)

    local autoEggIntervalSlider = autoEggGroup:AddSlider("AutoBuyEggs_RunInterval", {
        Text = "Check Interval",
        Default = Hub.Config.AutoBuyEggs.RunInterval,
        Min = 0.2,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    autoEggIntervalSlider:OnChanged(function(value)
        Hub.Config.AutoBuyEggs.RunInterval = math.max(0.2, value)
    end)

    local bestDiceToggle = bestDiceGroup:AddToggle("AutoOpenBestDice_Enabled", {
        Text = "Enable Auto Open Best Dice",
        Default = Hub.Config.AutoOpenBestDice.Enabled
    })
    bestDiceToggle:OnChanged(function(value)
        setAutoOpenBestDiceEnabled(value)
    end)

    local bestDiceIntervalSlider = bestDiceGroup:AddSlider("AutoOpenBestDice_RunInterval", {
        Text = "Check Interval",
        Default = Hub.Config.AutoOpenBestDice.RunInterval,
        Min = 0.2,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    bestDiceIntervalSlider:OnChanged(function(value)
        Hub.Config.AutoOpenBestDice.RunInterval = math.max(0.2, value)
    end)

    weatherConditionGroup:AddLabel({
        Text = "Apply weather rules to Auto Open Best Dice.",
        DoesWrap = true
    })

    local weatherEnabledToggle = weatherConditionGroup:AddToggle("AutoOpenBestDiceWeather_Enabled", {
        Text = "Require Smart Weather",
        Default = Hub.Config.AutoOpenBestDiceWeather.Enabled
    })
    weatherEnabledToggle:OnChanged(function(value)
        Hub.Config.AutoOpenBestDiceWeather.Enabled = not not value
    end)

    local weatherMinCoinSlider = weatherConditionGroup:AddSlider("AutoOpenBestDiceWeather_SmartMinCoinMultiplier", {
        Text = "Smart Min Coin Mult",
        Default = Hub.Config.AutoOpenBestDiceWeather.SmartMinCoinMultiplier,
        Min = 1,
        Max = 10,
        Rounding = 0
    })
    weatherMinCoinSlider:OnChanged(function(value)
        Hub.Config.AutoOpenBestDiceWeather.SmartMinCoinMultiplier = math.max(1, math.min(10, math.floor(value)))
    end)

    local weatherSmartEventsLabel = weatherStatusGroup:AddLabel({
        Text = "Smart Events: --",
        DoesWrap = true
    })
    local weatherCurrentEventLabel = weatherStatusGroup:AddLabel({
        Text = "Current Event: --",
        DoesWrap = true
    })
    local weatherTimeLeftLabel = weatherStatusGroup:AddLabel({
        Text = "Time Left: --",
        DoesWrap = true
    })
    local weatherOpenStateLabel = weatherStatusGroup:AddLabel({
        Text = "Dice Opening: Allowed",
        DoesWrap = true
    })

    task.spawn(function()
        while not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local minCoins = Hub.Config.AutoOpenBestDiceWeather.SmartMinCoinMultiplier or 6
            local smartEvents = {}
            for _, eventName in ipairs(WeatherEventNames) do
                local stats = WeatherEventStats[eventName]
                if stats and (stats.MaxWeight or 0) > 0 and (stats.MaxCoinMultiplier or 0) >= minCoins then
                    smartEvents[#smartEvents + 1] = eventName
                end
            end
            if #smartEvents > 0 then
                weatherSmartEventsLabel:SetText("Smart Events: " .. table.concat(smartEvents, ", "))
            else
                weatherSmartEventsLabel:SetText("Smart Events: --")
            end

            local eventName = getCurrentWeatherEvent()
            if eventName then
                weatherCurrentEventLabel:SetText("Current Event: " .. eventName)
            else
                weatherCurrentEventLabel:SetText("Current Event: None")
            end

            local remaining = getWeatherTimeRemaining()
            if remaining > 0 then
                local minutes = math.floor(remaining / 60)
                local seconds = remaining % 60
                weatherTimeLeftLabel:SetText(string.format("Time Left: %d:%02d", minutes, seconds))
            else
                weatherTimeLeftLabel:SetText("Time Left: --")
            end

            if shouldOpenBestDiceForWeather() then
                weatherOpenStateLabel:SetText("Dice Opening: Allowed")
            else
                weatherOpenStateLabel:SetText("Dice Opening: Waiting for condition")
            end

            task.wait(0.5)
        end
    end)

    local autoPotionToggle = autoPotionGroup:AddToggle("AutoUsePotions_Enabled", {
        Text = "Enable Auto Use Potions",
        Default = Hub.Config.AutoUsePotions.Enabled
    })
    autoPotionToggle:OnChanged(function(value)
        setAutoUsePotionsEnabled(value)
    end)

    local autoPotionIntervalSlider = autoPotionGroup:AddSlider("AutoUsePotions_RunInterval", {
        Text = "Check Interval",
        Default = Hub.Config.AutoUsePotions.RunInterval,
        Min = 0.1,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    autoPotionIntervalSlider:OnChanged(function(value)
        Hub.Config.AutoUsePotions.RunInterval = math.max(0.1, value)
    end)

    local autoPotionUseDelaySlider = autoPotionGroup:AddSlider("AutoUsePotions_UseDelay", {
        Text = "Use Delay",
        Default = Hub.Config.AutoUsePotions.UseDelay,
        Min = 0.1,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    autoPotionUseDelaySlider:OnChanged(function(value)
        Hub.Config.AutoUsePotions.UseDelay = math.max(0.1, value)
    end)

    local autoPotionLuckToggle = autoPotionGroup:AddToggle("AutoUsePotions_UseLuck", {
        Text = "Use Luck Potions",
        Default = Hub.Config.AutoUsePotions.UseLuck
    })
    autoPotionLuckToggle:OnChanged(function(value)
        Hub.Config.AutoUsePotions.UseLuck = not not value
    end)

    local autoPotionMoneyToggle = autoPotionGroup:AddToggle("AutoUsePotions_UseMoney", {
        Text = "Use Money Potions",
        Default = Hub.Config.AutoUsePotions.UseMoney
    })
    autoPotionMoneyToggle:OnChanged(function(value)
        Hub.Config.AutoUsePotions.UseMoney = not not value
    end)

    local autoPotionMutationToggle = autoPotionGroup:AddToggle("AutoUsePotions_UseMutationChance", {
        Text = "Use Mutation Potion",
        Default = Hub.Config.AutoUsePotions.UseMutationChance
    })
    autoPotionMutationToggle:OnChanged(function(value)
        Hub.Config.AutoUsePotions.UseMutationChance = not not value
    end)

    local autoPotionNoConsumeToggle = autoPotionGroup:AddToggle("AutoUsePotions_UseNoConsumeDice", {
        Text = "Use No Consume Potion",
        Default = Hub.Config.AutoUsePotions.UseNoConsumeDice
    })
    autoPotionNoConsumeToggle:OnChanged(function(value)
        Hub.Config.AutoUsePotions.UseNoConsumeDice = not not value
    end)

    local autoPotionPrismaticToggle = autoPotionGroup:AddToggle("AutoUsePotions_UsePrismatic", {
        Text = "Use Prismatic Potion",
        Default = Hub.Config.AutoUsePotions.UsePrismatic
    })
    autoPotionPrismaticToggle:OnChanged(function(value)
        Hub.Config.AutoUsePotions.UsePrismatic = not not value
    end)

    local autoQuestToggle = autoQuestGroup:AddToggle("AutoCollectQuests_Enabled", {
        Text = "Enable Auto Collect Quests",
        Default = Hub.Config.AutoCollectQuests.Enabled
    })
    autoQuestToggle:OnChanged(function(value)
        setAutoCollectQuestsEnabled(value)
    end)

    local autoQuestIntervalSlider = autoQuestGroup:AddSlider("AutoCollectQuests_RunInterval", {
        Text = "Check Interval",
        Default = Hub.Config.AutoCollectQuests.RunInterval,
        Min = 0.2,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    autoQuestIntervalSlider:OnChanged(function(value)
        Hub.Config.AutoCollectQuests.RunInterval = math.max(0.2, value)
    end)

    local autoQuestClaimDelaySlider = autoQuestGroup:AddSlider("AutoCollectQuests_ClaimDelay", {
        Text = "Claim Delay",
        Default = Hub.Config.AutoCollectQuests.ClaimDelay,
        Min = 0.05,
        Max = 1.0,
        Rounding = 2,
        Suffix = "s"
    })
    autoQuestClaimDelaySlider:OnChanged(function(value)
        Hub.Config.AutoCollectQuests.ClaimDelay = math.max(0.05, value)
    end)

    local autoQuestResetToggle = autoQuestGroup:AddToggle("AutoCollectQuests_CheckReset", {
        Text = "Auto Quest Reset Check",
        Default = Hub.Config.AutoCollectQuests.CheckReset
    })
    autoQuestResetToggle:OnChanged(function(value)
        Hub.Config.AutoCollectQuests.CheckReset = not not value
    end)

    local autoIndexToggle = autoIndexGroup:AddToggle("AutoClaimAllIndex_Enabled", {
        Text = "Enable Auto Claim All",
        Default = Hub.Config.AutoClaimAllIndex.Enabled
    })
    autoIndexToggle:OnChanged(function(value)
        setAutoClaimAllIndexEnabled(value)
    end)

    local autoIndexIntervalSlider = autoIndexGroup:AddSlider("AutoClaimAllIndex_RunInterval", {
        Text = "Check Interval",
        Default = Hub.Config.AutoClaimAllIndex.RunInterval,
        Min = 0.2,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    autoIndexIntervalSlider:OnChanged(function(value)
        Hub.Config.AutoClaimAllIndex.RunInterval = math.max(0.2, value)
    end)

    autoWheelGroup:AddLabel({
        Text = "Uses free wheel spins only (SpinCount > 0).",
        DoesWrap = true
    })

    local autoWheelToggle = autoWheelGroup:AddToggle("AutoSpinWheel_Enabled", {
        Text = "Enable Auto Spin Wheel",
        Default = Hub.Config.AutoSpinWheel.Enabled
    })
    autoWheelToggle:OnChanged(function(value)
        setAutoSpinWheelEnabled(value)
    end)

    local autoWheelIntervalSlider = autoWheelGroup:AddSlider("AutoSpinWheel_RunInterval", {
        Text = "Check Interval",
        Default = Hub.Config.AutoSpinWheel.RunInterval,
        Min = 0.2,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    autoWheelIntervalSlider:OnChanged(function(value)
        Hub.Config.AutoSpinWheel.RunInterval = math.max(0.2, value)
    end)

    local autoCoinToggle = autoCoinGroup:AddToggle("AutoCollectCoins_Enabled", {
        Text = "Enable Auto Collect Coins",
        Default = Hub.Config.AutoCollectCoins.Enabled
    })
    autoCoinToggle:OnChanged(function(value)
        setAutoCollectCoinsEnabled(value)
    end)

    local autoCoinIntervalSlider = autoCoinGroup:AddSlider("AutoCollectCoins_RunInterval", {
        Text = "Check Interval",
        Default = Hub.Config.AutoCollectCoins.RunInterval,
        Min = 0.2,
        Max = 5.0,
        Rounding = 2,
        Suffix = "s"
    })
    autoCoinIntervalSlider:OnChanged(function(value)
        Hub.Config.AutoCollectCoins.RunInterval = math.max(0.2, value)
    end)

    antiAfkGroup:AddLabel({
        Text = "Two methods: mobile-safe activity pulse and AFK connection disable.",
        DoesWrap = true
    })

    local antiAfkToggle = antiAfkGroup:AddToggle("AntiAFK_Enabled", {
        Text = "Enable Anti AFK",
        Default = Hub.Config.AntiAFK.Enabled
    })
    antiAfkToggle:OnChanged(function(value)
        setAntiAFKEnabled(value)
    end)

    local antiAfkMobileToggle = antiAfkGroup:AddToggle("AntiAFK_UseMobileMethod", {
        Text = "Use Mobile Method",
        Default = Hub.Config.AntiAFK.UseMobileMethod
    })
    antiAfkMobileToggle:OnChanged(function(value)
        Hub.Config.AntiAFK.UseMobileMethod = not not value
    end)

    local antiAfkMobileIntervalSlider = antiAfkGroup:AddSlider("AntiAFK_MobilePulseInterval", {
        Text = "Mobile Pulse Interval",
        Default = Hub.Config.AntiAFK.MobilePulseInterval,
        Min = 15,
        Max = 120,
        Rounding = 0,
        Suffix = "s"
    })
    antiAfkMobileIntervalSlider:OnChanged(function(value)
        Hub.Config.AntiAFK.MobilePulseInterval = math.max(15, math.min(120, math.floor(value)))
    end)

    local antiAfkDisableConnectionsToggle = antiAfkGroup:AddToggle("AntiAFK_DisableIdledConnections", {
        Text = "Disable AFK Connections",
        Default = Hub.Config.AntiAFK.DisableIdledConnections
    })
    antiAfkDisableConnectionsToggle:OnChanged(function(value)
        Hub.Config.AntiAFK.DisableIdledConnections = not not value
    end)

    local antiAfkConnectionIntervalSlider = antiAfkGroup:AddSlider("AntiAFK_ConnectionScanInterval", {
        Text = "Connection Check Interval",
        Default = Hub.Config.AntiAFK.ConnectionScanInterval,
        Min = 1,
        Max = 30,
        Rounding = 0,
        Suffix = "s"
    })
    antiAfkConnectionIntervalSlider:OnChanged(function(value)
        Hub.Config.AntiAFK.ConnectionScanInterval = math.max(1, math.min(30, math.floor(value)))
    end)

    local fpsEnableToggle = fpsBoostGroup:AddToggle("FPSBoost_Enabled", {
        Text = "Enable FPS Boost",
        Default = Hub.Config.FPSBoost.Enabled
    })
    fpsEnableToggle:OnChanged(function(value)
        setFPSBoostEnabled(value)
    end)

    local fpsAggressiveToggle = fpsBoostGroup:AddToggle("FPSBoost_Aggressive", {
        Text = "Aggressive Render Trim",
        Default = Hub.Config.FPSBoost.AggressiveMode
    })
    fpsAggressiveToggle:OnChanged(function(value)
        Hub.Config.FPSBoost.AggressiveMode = not not value
    end)

    local fpsPopupsToggle = fpsBoostGroup:AddToggle("FPSBoost_DisablePopups", {
        Text = "Disable Popup UI",
        Default = Hub.Config.FPSBoost.DisablePopups
    })
    fpsPopupsToggle:OnChanged(function(value)
        Hub.Config.FPSBoost.DisablePopups = not not value
    end)

    local fpsCutsceneToggle = fpsBoostGroup:AddToggle("FPSBoost_DisableCutscenes", {
        Text = "Disable Cutscenes",
        Default = Hub.Config.FPSBoost.DisableCutscenes
    })
    fpsCutsceneToggle:OnChanged(function(value)
        Hub.Config.FPSBoost.DisableCutscenes = not not value
    end)

    local fpsAnnounceToggle = fpsBoostGroup:AddToggle("FPSBoost_DisableAnnouncements", {
        Text = "Disable Announcements",
        Default = Hub.Config.FPSBoost.DisableAnnouncements
    })
    fpsAnnounceToggle:OnChanged(function(value)
        Hub.Config.FPSBoost.DisableAnnouncements = not not value
    end)

    local fpsSfxToggle = fpsBoostGroup:AddToggle("FPSBoost_DisableRollSFX", {
        Text = "Disable Roll SFX",
        Default = Hub.Config.FPSBoost.DisableRollSFX
    })
    fpsSfxToggle:OnChanged(function(value)
        Hub.Config.FPSBoost.DisableRollSFX = not not value
    end)

    local fpsAuraToggle = fpsBoostGroup:AddToggle("FPSBoost_DisableTitleAura", {
        Text = "Disable Title Auras",
        Default = Hub.Config.FPSBoost.DisableTitleAura
    })
    fpsAuraToggle:OnChanged(function(value)
        Hub.Config.FPSBoost.DisableTitleAura = not not value
    end)

    local uiGroup = Tabs.Settings:AddLeftGroupbox("UI")
    uiGroup:AddLabel("Menu Toggle: RightShift")
    uiGroup:AddButton({
        Text = "Unload UI",
        Func = function()
            unloadHub()
        end
    })

    discordGroup:AddDivider({
        Text = "Discord Section",
        Margin = 2
    })
    discordGroup:AddLabel({
        Text = '<font color="#5865F2"><b>Trustsense Community</b></font>',
        DoesWrap = true
    })
    discordGroup:AddLabel({
        Text = '<font color="#99AAB5">Join for updates, support, and script news.</font>',
        DoesWrap = true
    })
    discordGroup:AddDivider({
        Text = "Invite Box",
        Margin = 2
    })

    local discordInviteLabel = discordGroup:AddLabel({
        Text = '<font color="#5865F2"><b>discord.gg/6KVvbEYaXF</b></font>\n<font color="#B9BBBE">https://discord.gg/6KVvbEYaXF</font>',
        DoesWrap = true
    })

    local discordStatusLabel = discordGroup:AddLabel({
        Text = '<font color="#99AAB5">Status: Ready</font>',
        DoesWrap = true
    })

    discordGroup:AddButton({
        Text = "Copy Invite",
        Func = function()
            local copied = copyToClipboard(DISCORD_INVITE_URL)
            if copied then
                discordStatusLabel:SetText('<font color="#57F287">Status: Invite copied to clipboard.</font>')
            else
                discordStatusLabel:SetText('<font color="#ED4245">Status: Clipboard is unavailable in this executor.</font>')
            end
        end
    })

    discordGroup:AddButton({
        Text = "Join Discord",
        Func = function()
            task.spawn(function()
                local joined, reason = tryJoinDiscordInvite(DISCORD_INVITE_CODE)
                if joined then
                    discordStatusLabel:SetText('<font color="#57F287">Status: Opened Discord invite.</font>')
                else
                    local copied = copyToClipboard(DISCORD_INVITE_URL)
                    if copied then
                        discordStatusLabel:SetText('<font color="#FEE75C">Status: Could not auto-open (' .. tostring(reason) .. '). Invite copied instead.</font>')
                    else
                        discordStatusLabel:SetText('<font color="#ED4245">Status: Could not auto-open (' .. tostring(reason) .. '). Use the invite box link.</font>')
                    end
                end
            end)
        end
    })

    local ThemeManager = loadRemoteModule(repoBase .. "addons/ThemeManager.lua", "Obsidian ThemeManager")
    local SaveManager = loadRemoteModule(repoBase .. "addons/SaveManager.lua", "Obsidian SaveManager")

    if ThemeManager and SaveManager then
        ThemeManager:SetLibrary(Library)
        SaveManager:SetLibrary(Library)
        SaveManager:IgnoreThemeSettings()
        ThemeManager:SetFolder("TrustsenseHub")
        SaveManager:SetFolder("TrustsenseHub")
        SaveManager:SetSubFolder("SpinABaddie")
        ThemeManager:ApplyToTab(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Settings)
        SaveManager:LoadAutoloadConfig()
    end

    Hub.UI = {
        Library = Library,
        Window = Window,
        Tabs = Tabs
    }
end

task.spawn(function()
    waitForProfile(Hub.Config.AutoBuyAllDice.ProfileWaitTimeout)
    waitForPlayerLoaded(Hub.Config.AutoBuyAllDice.PlayerLoadedWaitTimeout)

    if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    setAutoBuyEnabled(Hub.Config.AutoBuyAllDice.Enabled)
    setAutoBuyEggsEnabled(Hub.Config.AutoBuyEggs.Enabled)
    setAutoOpenBestDiceEnabled(Hub.Config.AutoOpenBestDice.Enabled)
    setAutoUsePotionsEnabled(Hub.Config.AutoUsePotions.Enabled)
    setAutoCollectQuestsEnabled(Hub.Config.AutoCollectQuests.Enabled)
    setAutoClaimAllIndexEnabled(Hub.Config.AutoClaimAllIndex.Enabled)
    setAutoCollectCoinsEnabled(Hub.Config.AutoCollectCoins.Enabled)
    setAutoSpinWheelEnabled(Hub.Config.AutoSpinWheel.Enabled)
    setAntiAFKEnabled(Hub.Config.AntiAFK.Enabled)
    setFPSBoostEnabled(Hub.Config.FPSBoost.Enabled)
end)

task.spawn(setupObsidianUI)

return Hub
