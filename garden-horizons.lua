-- Trustsense Hub entrypoint (Garden Horizons)
local sharedEnv = (getgenv and getgenv()) or _G
sharedEnv.TrustsenseHub = sharedEnv.TrustsenseHub or {}

local Hub = sharedEnv.TrustsenseHub
Hub.RunId = (Hub.RunId or 0) + 1
local CurrentRunId = Hub.RunId
Hub.IsUnloaded = false
Hub.Config = Hub.Config or {}
Hub.Features = Hub.Features or {}

Hub.Config.AutoPlant = Hub.Config.AutoPlant or {
    Enabled = false
}
Hub.Config.AutoBuySeeds = Hub.Config.AutoBuySeeds or {
    Enabled = false,
    SelectedSeedNames = {}
}
Hub.Config.AutoBuyGears = Hub.Config.AutoBuyGears or {
    Enabled = false,
    SelectedGearNames = {}
}
Hub.Config.AutoBotanist = Hub.Config.AutoBotanist or {
    Enabled = false,
    AutoRequestQuest = true,
    AutoDonateAll = true,
    AutoAppraiseHeld = false,
    TeleportToBotanist = true
}
Hub.Config.AutoSprinkler = Hub.Config.AutoSprinkler or {
    Enabled = false
}
Hub.Config.AutoSell = Hub.Config.AutoSell or {
    Enabled = false
}
Hub.Config.FPSBoost = Hub.Config.FPSBoost or {
    Enabled = false,
    TargetFPS = 360
}
Hub.Config.AutoHarvest = Hub.Config.AutoHarvest or {
    Enabled = false,
    SelectedPlantTypes = {},
    AllowUnripe = false,
    AllowRipe = true,
    AllowLush = true
}
Hub.Config.AntiAFK = Hub.Config.AntiAFK or {
    Enabled = true,
    DisableGameConnections = true,
    UseClassic = true
}

Hub.Config.AutoPlant.Enabled = Hub.Config.AutoPlant.Enabled == true
Hub.Config.AutoBuySeeds.Enabled = Hub.Config.AutoBuySeeds.Enabled == true
Hub.Config.AutoBuyGears.Enabled = Hub.Config.AutoBuyGears.Enabled == true
Hub.Config.AutoBotanist.Enabled = Hub.Config.AutoBotanist.Enabled == true
Hub.Config.AutoSprinkler.Enabled = Hub.Config.AutoSprinkler.Enabled == true
Hub.Config.AutoSell.Enabled = Hub.Config.AutoSell.Enabled == true
Hub.Config.FPSBoost.Enabled = Hub.Config.FPSBoost.Enabled == true
Hub.Config.FPSBoost.TargetFPS = math.max(60, math.min(500, math.floor(tonumber(Hub.Config.FPSBoost.TargetFPS) or 360)))
Hub.Config.AutoHarvest.Enabled = Hub.Config.AutoHarvest.Enabled == true
if Hub.Config.AntiAFK.Enabled == nil then
    Hub.Config.AntiAFK.Enabled = true
end
if Hub.Config.AntiAFK.DisableGameConnections == nil then
    Hub.Config.AntiAFK.DisableGameConnections = true
end
if Hub.Config.AntiAFK.UseClassic == nil then
    Hub.Config.AntiAFK.UseClassic = true
end
Hub.Config.AntiAFK.Enabled = Hub.Config.AntiAFK.Enabled == true
Hub.Config.AntiAFK.DisableGameConnections = Hub.Config.AntiAFK.DisableGameConnections == true
Hub.Config.AntiAFK.UseClassic = Hub.Config.AntiAFK.UseClassic == true
if Hub.Config.AutoBotanist.AutoRequestQuest == nil then
    Hub.Config.AutoBotanist.AutoRequestQuest = true
end
if Hub.Config.AutoBotanist.AutoDonateAll == nil then
    Hub.Config.AutoBotanist.AutoDonateAll = true
end
if Hub.Config.AutoBotanist.AutoAppraiseHeld == nil then
    Hub.Config.AutoBotanist.AutoAppraiseHeld = false
end
if Hub.Config.AutoBotanist.TeleportToBotanist == nil then
    Hub.Config.AutoBotanist.TeleportToBotanist = true
end
Hub.Config.AutoBotanist.AutoRequestQuest = Hub.Config.AutoBotanist.AutoRequestQuest == true
Hub.Config.AutoBotanist.AutoDonateAll = Hub.Config.AutoBotanist.AutoDonateAll == true
Hub.Config.AutoBotanist.AutoAppraiseHeld = Hub.Config.AutoBotanist.AutoAppraiseHeld == true
Hub.Config.AutoBotanist.TeleportToBotanist = Hub.Config.AutoBotanist.TeleportToBotanist == true
if Hub.Config.AutoHarvest.AllowRipe == nil then
    Hub.Config.AutoHarvest.AllowRipe = true
end
if Hub.Config.AutoHarvest.AllowLush == nil then
    Hub.Config.AutoHarvest.AllowLush = true
end
Hub.Config.AutoHarvest.AllowUnripe = Hub.Config.AutoHarvest.AllowUnripe == true
Hub.Config.AutoHarvest.AllowRipe = Hub.Config.AutoHarvest.AllowRipe == true
Hub.Config.AutoHarvest.AllowLush = Hub.Config.AutoHarvest.AllowLush == true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local PlantSeedRemote = RemoteEvents:WaitForChild("PlantSeed")
local PurchaseShopItemRemote = RemoteEvents:WaitForChild("PurchaseShopItem")
local GetShopDataRemote = RemoteEvents:WaitForChild("GetShopData")
local SellItemsRemote = RemoteEvents:WaitForChild("SellItems")
local HarvestFruitRemote = RemoteEvents:WaitForChild("HarvestFruit")
local UseGearRemote = RemoteEvents:WaitForChild("UseGear")
local AFKRemote = RemoteEvents:FindFirstChild("AFK") or RemoteEvents:WaitForChild("AFK", 5)
local ItemInventory = require(ReplicatedStorage:WaitForChild("Inventory"):WaitForChild("ItemInventory"))
local NumberFormatter = require(ReplicatedStorage:WaitForChild("Economy"):WaitForChild("Formatter"):WaitForChild("NumberFormatter"))
local FruitValueCalculator = require(ReplicatedStorage:WaitForChild("Economy"):WaitForChild("FruitValueCalculator"))
local SeedShopData = require(ReplicatedStorage:WaitForChild("Shop"):WaitForChild("ShopData"):WaitForChild("SeedShopData"))
local GearShopData = require(ReplicatedStorage:WaitForChild("Shop"):WaitForChild("ShopData"):WaitForChild("GearShopData"))
local SprinklerDefinitions = require(ReplicatedStorage:WaitForChild("Gears"):WaitForChild("Definitions"):WaitForChild("SprinklerDefinitions"))
local PlantDataDefinitions = require(ReplicatedStorage:WaitForChild("Plants"):WaitForChild("Definitions"):WaitForChild("PlantDataDefinitions"))
local BotanistDefinitions = require(ReplicatedStorage:WaitForChild("Plants"):WaitForChild("Definitions"):WaitForChild("BotanistDefinitions"))

local DISCORD_INVITE_URL = "https://discord.gg/6KVvbEYaXF"
local DISCORD_INVITE_CODE = "6KVvbEYaXF"

local EQUIP_DELAY = 0.08
local PLANT_DELAY = 0.12
local RETRY_DELAY = 0.1
local RETRIES_PER_POSITION = 2
local PLOT_WAIT_TIMEOUT = 10
local GRID_STEP = 1.85
local GRID_MARGIN = 0.9
local OCCUPIED_RADIUS = 1.45
local MAX_PLANT_DISTANCE = 22
local MOVE_TIMEOUT = 1.25
local MOVE_RECHECK_DELAY = 0.05
local TELEPORT_FALLBACK_HEIGHT = 3
local PASS_LOOP_DELAY = 0.12
local PLANT_RANK_REFRESH_INTERVAL = 2
local PLANT_RANK_MAX_ITEMS = 20
local AUTO_BUY_LOOP_DELAY = 1.0
local AUTO_BUY_PURCHASE_DELAY = 0.06
local AUTO_BUY_MAX_PURCHASES_PER_TICK = 60
local AUTO_SELL_LOOP_DELAY = 0.75
local STOCK_TIMER_UPDATE_INTERVAL = 1.0
local STOCK_TIMER_WARN_SECONDS = 45
local STOCK_TIMER_STALE_SECONDS = 120
local AUTO_HARVEST_LOOP_DELAY = 0.3
local AUTO_HARVEST_MAX_PER_TICK = 80
local AUTO_HARVEST_RETRY_GUARD_SECONDS = 1.4
local AUTO_HARVEST_INTERACT_DISTANCE = 14
local AUTO_HARVEST_BATCH_RADIUS = 20
local AUTO_SPRINKLER_LOOP_DELAY = 1.8
local AUTO_SPRINKLER_MAX_PER_TICK = 2
local AUTO_SPRINKLER_MOVE_DISTANCE = 10
local AUTO_SPRINKLER_MIN_NEW_COVERAGE = 1
local SPRINKLER_PLACE_COOLDOWN = 1.05
local SPRINKLER_PLACE_CONFIRM_TIMEOUT = 3.2
local SPRINKLER_DIRECT_CONFIRM_TIMEOUT = 1.15
local SPRINKLER_DIRECT_ATTEMPTS_PER_POSITION = 2
local SPRINKLER_CANDIDATE_DEDUPE_STEP = 0.75
local SPRINKLER_PLANT_CLEARANCE = 1.35
local SPRINKLER_CONFIRM_NEAR_DISTANCE = 4.5
local SPRINKLER_PLOT_FILTER_PADDING = 1.25
local SPRINKLER_MOUSE_CLICK_DELAY = 0.05
local SPRINKLER_POSITION_JITTER_STEP = 1.0
local SPRINKLER_REQUIRED_PLAYER_DISTANCE = 6.5
local SPRINKLER_DESIRED_STAND_DISTANCE = 4.2
local SPRINKLER_COVERAGE_TARGET_DEDUPE_STEP = 1.6
local SPRINKLER_COVERAGE_TARGET_MAX = 360
local ANTI_AFK_PULSE_INTERVAL = 20
local TELEPORT_HEIGHT_OFFSET = 3.5
local TELEPORT_NEAR_DISTANCE = 20
local TELEPORT_SUCCESS_DISTANCE = 26
local TELEPORT_REPEAT_COOLDOWN = 0.45
local GARDEN_TELEPORT_RIGHT_OFFSET = 4
local PLANT_FALLBACK_SIDE_OFFSET = 5
local ANTI_STUCK_SIDE_OFFSET = 4.5
local ANTI_STUCK_FORWARD_OFFSET = 3.5
local ANTI_STUCK_UP_OFFSET = 4.5
local TELEPORT_ZONE_RADIUS_SEEDS = 38
local TELEPORT_ZONE_RADIUS_SELL = 38
local TELEPORT_ZONE_RADIUS_SHOP = 38
local TELEPORT_ZONE_RADIUS_GARDEN_SPAWN = 36
local TELEPORT_ZONE_PLOT_PADDING = 4
local TOP_RANK_COLORS = {
    [1] = "#FFD700",
    [2] = "#C0C0C0",
    [3] = "#CD7F32"
}

local JITTER_OFFSETS = {
    Vector3.new(0, 0, 0),
    Vector3.new(0.28, 0, 0),
    Vector3.new(-0.28, 0, 0),
    Vector3.new(0, 0, 0.28),
    Vector3.new(0, 0, -0.28)
}

local function debugLog(...)
    return ...
end

local function sprinklerLog(message)
    local text = "[AutoSprinkler] " .. tostring(message or "")
    pcall(function()
        print(text)
    end)
    pcall(function()
        warn(text)
    end)
end

Hub.PendingUILabelUpdates = Hub.PendingUILabelUpdates or {}

local function queueUILabelUpdate(labelKey, text)
    Hub.PendingUILabelUpdates[labelKey] = tostring(text or "")
end

local function flushQueuedUILabelUpdates()
    local ui = Hub.UI
    if not ui then
        return
    end

    local queue = Hub.PendingUILabelUpdates
    local autoPlantText = queue.AutoPlant
    if autoPlantText ~= nil then
        queue.AutoPlant = nil
        local label = ui.AutoPlantStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(autoPlantText)
            end)
        end
    end

    local plantRankingsText = queue.PlantRankings
    if plantRankingsText ~= nil then
        queue.PlantRankings = nil
        local label = ui.PlantRankingsLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(plantRankingsText)
            end)
        end
    end

    local autoBuyText = queue.AutoBuySeeds
    if autoBuyText ~= nil then
        queue.AutoBuySeeds = nil
        local label = ui.AutoBuySeedsStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(autoBuyText)
            end)
        end
    end

    local autoBuyGearsText = queue.AutoBuyGears
    if autoBuyGearsText ~= nil then
        queue.AutoBuyGears = nil
        local label = ui.AutoBuyGearsStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(autoBuyGearsText)
            end)
        end
    end

    local autoBotanistText = queue.AutoBotanist
    if autoBotanistText ~= nil then
        queue.AutoBotanist = nil
        local label = ui.AutoBotanistStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(autoBotanistText)
            end)
        end
    end

    local autoSprinklerText = queue.AutoSprinkler
    if autoSprinklerText ~= nil then
        queue.AutoSprinkler = nil
        local label = ui.AutoSprinklerStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(autoSprinklerText)
            end)
        end
    end

    local autoSellText = queue.AutoSell
    if autoSellText ~= nil then
        queue.AutoSell = nil
        local label = ui.AutoSellStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(autoSellText)
            end)
        end
    end

    local autoHarvestText = queue.AutoHarvest
    if autoHarvestText ~= nil then
        queue.AutoHarvest = nil
        local label = ui.AutoHarvestStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(autoHarvestText)
            end)
        end
    end

    local antiAFKText = queue.AntiAFK
    if antiAFKText ~= nil then
        queue.AntiAFK = nil
        local label = ui.AntiAFKStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(antiAFKText)
            end)
        end
    end

    local fpsBoostText = queue.FPSBoost
    if fpsBoostText ~= nil then
        queue.FPSBoost = nil
        local label = ui.FPSBoostStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(fpsBoostText)
            end)
        end
    end

    local seedStockText = queue.SeedStock
    if seedStockText ~= nil then
        queue.SeedStock = nil
        local label = ui.SeedStockStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(seedStockText)
            end)
        end
    end

    local gearStockText = queue.GearStock
    if gearStockText ~= nil then
        queue.GearStock = nil
        local label = ui.GearStockStatusLabel
        if label and type(label.SetText) == "function" then
            pcall(function()
                label:SetText(gearStockText)
            end)
        end
    end
end

local function ensureUILabelUpdateBridge()
    if Hub.UIUpdateConnection then
        return
    end

    Hub.UIUpdateConnection = RunService.RenderStepped:Connect(function()
        if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        flushQueuedUILabelUpdates()
    end)
end

local function safeInvoke(remote, ...)
    local ok, resultA, resultB, resultC = pcall(remote.InvokeServer, remote, ...)
    if not ok then
        debugLog("Remote invoke failed:", remote.Name, resultA)
        return false, tostring(resultA)
    end
    return resultA, resultB, resultC
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
    return pcall(clipboardFn, text)
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

local function getCharacter()
    if LocalPlayer.Character then
        return LocalPlayer.Character
    end
    return LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoid()
    local character = getCharacter()
    return character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid")
end

local function getRootPart()
    local character = getCharacter()
    return character:FindFirstChild("HumanoidRootPart")
end

local function horizontalDistance(a, b)
    local a2 = Vector2.new(a.X, a.Z)
    local b2 = Vector2.new(b.X, b.Z)
    return (a2 - b2).Magnitude
end

local function getOwnedPlot()
    for _, plot in ipairs(workspace:WaitForChild("Plots"):GetChildren()) do
        if plot:IsA("Model") and plot:GetAttribute("Owner") == LocalPlayer.UserId then
            return plot
        end
    end
    return nil
end

local function findChildByPath(root, pathParts)
    local current = root
    for _, name in ipairs(pathParts) do
        if not current then
            return nil
        end
        current = current:FindFirstChild(name)
    end
    return current
end

local function getMapPhysical()
    return workspace:FindFirstChild("MapPhysical")
end

local function getGardenTeleportCFrame()
    local plot = getOwnedPlot()
    local spawnFolder = plot and plot:FindFirstChild("Spawn")
    local spawnPart = spawnFolder and spawnFolder:FindFirstChild("Spawn")
    if spawnPart and spawnPart:IsA("BasePart") then
        return spawnPart.CFrame * CFrame.new(GARDEN_TELEPORT_RIGHT_OFFSET, 0, 0)
    end
    return nil
end

local function getPlotRightDirection()
    local plot = getOwnedPlot()
    local spawnFolder = plot and plot:FindFirstChild("Spawn")
    local spawnPart = spawnFolder and spawnFolder:FindFirstChild("Spawn")
    if spawnPart and spawnPart:IsA("BasePart") then
        local rightVector = spawnPart.CFrame.RightVector
        local horizontalRight = Vector3.new(rightVector.X, 0, rightVector.Z)
        if horizontalRight.Magnitude > 0.001 then
            return horizontalRight.Unit
        end
    end
    return Vector3.new(1, 0, 0)
end

local function getSeedsTeleportCFrame()
    local mapPhysical = getMapPhysical()
    local teleportsFolder = mapPhysical and mapPhysical:FindFirstChild("Teleports")
    local seedTeleport = teleportsFolder and teleportsFolder:FindFirstChild("SeedsTeleport")
    if seedTeleport and seedTeleport:IsA("BasePart") then
        return seedTeleport.CFrame
    end

    local seedNpcRoot = findChildByPath(mapPhysical, {
        "Shops",
        "Seed Shop",
        "SeedNPC",
        "HumanoidRootPart"
    })
    if seedNpcRoot and seedNpcRoot:IsA("BasePart") then
        return seedNpcRoot.CFrame
    end

    return nil
end

local function getSellTeleportCFrame()
    local mapPhysical = getMapPhysical()
    local teleportsFolder = mapPhysical and mapPhysical:FindFirstChild("Teleports")
    local sellTeleport = teleportsFolder and teleportsFolder:FindFirstChild("SellTeleport")
    if sellTeleport and sellTeleport:IsA("BasePart") then
        return sellTeleport.CFrame
    end

    local sellNpcRoot = findChildByPath(mapPhysical, {
        "Shops",
        "Sell Stand",
        "Steve",
        "HumanoidRootPart"
    })
    if sellNpcRoot and sellNpcRoot:IsA("BasePart") then
        return sellNpcRoot.CFrame
    end

    return nil
end

local function getGearShopTeleportCFrame()
    local mapPhysical = getMapPhysical()
    local gearNpcRoot = findChildByPath(mapPhysical, {
        "Shops",
        "Gear Shop",
        "GearNPC",
        "HumanoidRootPart"
    })
    if gearNpcRoot and gearNpcRoot:IsA("BasePart") then
        return gearNpcRoot.CFrame
    end
    return nil
end

local function isPointInsidePartXZ(worldPosition, part, extraPadding)
    if not worldPosition or not part or not part:IsA("BasePart") then
        return false
    end
    local localPoint = part.CFrame:PointToObjectSpace(worldPosition)
    local halfX = part.Size.X * 0.5 + (extraPadding or 0)
    local halfZ = part.Size.Z * 0.5 + (extraPadding or 0)
    return math.abs(localPoint.X) <= halfX and math.abs(localPoint.Z) <= halfZ
end

local function isNearTargetCFrame(targetCFrame, radius)
    if typeof(targetCFrame) ~= "CFrame" then
        return false
    end
    local root = getRootPart()
    if not root then
        return false
    end
    return horizontalDistance(root.Position, targetCFrame.Position) <= radius
end

local function isAlreadyInGardenZone(gardenCFrame)
    local root = getRootPart()
    if not root then
        return false
    end
    local rootPos = root.Position

    local plot = getOwnedPlot()
    local plantableArea = plot and plot:FindFirstChild("PlantableArea")
    if plantableArea then
        for _, child in ipairs(plantableArea:GetChildren()) do
            if child:IsA("BasePart") and isPointInsidePartXZ(rootPos, child, TELEPORT_ZONE_PLOT_PADDING) then
                return true
            end
        end
    end

    if typeof(gardenCFrame) == "CFrame" then
        return horizontalDistance(rootPos, gardenCFrame.Position) <= TELEPORT_ZONE_RADIUS_GARDEN_SPAWN
    end

    return false
end

local function teleportToCFrame(targetCFrame)
    if typeof(targetCFrame) ~= "CFrame" then
        return false, "Invalid teleport destination"
    end

    local root = getRootPart()
    if not root then
        return false, "Character is not ready"
    end

    local targetPosition = targetCFrame.Position
    if horizontalDistance(root.Position, targetPosition) <= TELEPORT_NEAR_DISTANCE then
        return true
    end

    pcall(function()
        LocalPlayer:RequestStreamAroundAsync(targetPosition)
    end)

    local originalAnchored = root.Anchored
    root.Anchored = true
    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
    root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
    root.CFrame = CFrame.new(targetPosition + Vector3.new(0, TELEPORT_HEIGHT_OFFSET, 0)) * root.CFrame.Rotation
    task.wait(0.08)
    if root.Parent then
        root.Anchored = originalAnchored
    end

    root = getRootPart()
    if root and horizontalDistance(root.Position, targetPosition) <= TELEPORT_SUCCESS_DISTANCE then
        return true
    end

    return false, "Still too far after teleport"
end

local function teleportByResolver(destinationName, resolver, force, isAlreadyThereFn)
    local targetCFrame = resolver()
    if typeof(targetCFrame) ~= "CFrame" then
        return false, destinationName .. " destination unavailable"
    end

    Hub.TeleportState = Hub.TeleportState or {}
    local state = Hub.TeleportState
    local now = tick()

    if not force and type(isAlreadyThereFn) == "function" then
        local okAlready, isAlreadyThere = pcall(isAlreadyThereFn, targetCFrame)
        if okAlready and isAlreadyThere then
            state.LastDestination = destinationName
            state.LastAt = now
            return true
        end
    end

    if not force
        and state.LastDestination == destinationName
        and now - (state.LastAt or 0) < TELEPORT_REPEAT_COOLDOWN
    then
        return true
    end

    local ok, reason = teleportToCFrame(targetCFrame)
    state.LastDestination = destinationName
    state.LastAt = tick()
    return ok, reason
end

local function teleportToGarden(force)
    return teleportByResolver("Garden", getGardenTeleportCFrame, force, function(targetCFrame)
        return isAlreadyInGardenZone(targetCFrame)
    end)
end

local function teleportToSeeds(force)
    return teleportByResolver("Seeds", getSeedsTeleportCFrame, force, function(targetCFrame)
        return isNearTargetCFrame(targetCFrame, TELEPORT_ZONE_RADIUS_SEEDS)
    end)
end

local function teleportToSell(force)
    return teleportByResolver("Sell", getSellTeleportCFrame, force, function(targetCFrame)
        return isNearTargetCFrame(targetCFrame, TELEPORT_ZONE_RADIUS_SELL)
    end)
end

local function teleportToShop(force)
    return teleportByResolver("Shop", getGearShopTeleportCFrame, force, function(targetCFrame)
        return isNearTargetCFrame(targetCFrame, TELEPORT_ZONE_RADIUS_SHOP)
    end)
end

local function getPlantableParts(plot)
    local plantableArea = plot and plot:FindFirstChild("PlantableArea")
    if not plantableArea then
        return {}
    end

    local parts = {}
    for _, child in ipairs(plantableArea:GetChildren()) do
        if child:IsA("BasePart") then
            table.insert(parts, child)
        end
    end
    return parts
end

local function getOrderedPlantableParts(plot)
    local parts = getPlantableParts(plot)
    table.sort(parts, function(a, b)
        local aPos = a.Position
        local bPos = b.Position
        if math.abs(aPos.Z - bPos.Z) > 0.5 then
            return aPos.Z < bPos.Z
        end
        return aPos.X < bPos.X
    end)
    return parts
end

local function getOwnedPlotAndParts()
    local plot = getOwnedPlot()
    return plot, getOrderedPlantableParts(plot)
end

local function waitForPlotAndParts(timeoutSeconds)
    local deadline = tick() + timeoutSeconds
    while tick() < deadline do
        local plot, parts = getOwnedPlotAndParts()
        if plot and #parts > 0 then
            return plot, parts
        end
        task.wait(0.25)
    end
    return getOwnedPlotAndParts()
end

local function getPlantPosition(plant)
    if plant:IsA("BasePart") then
        return plant.Position
    end
    if not plant:IsA("Model") then
        return nil
    end
    if plant.PrimaryPart then
        return plant.PrimaryPart.Position
    end
    local ok, pivot = pcall(function()
        return plant:GetPivot()
    end)
    if ok and pivot then
        return pivot.Position
    end
    return nil
end

local function formatShillings(value)
    local amount = math.max(0, math.floor(tonumber(value) or 0))
    local ok, formatted = pcall(function()
        return NumberFormatter:FormatNumberShort(amount)
    end)
    if ok and formatted ~= nil then
        return tostring(formatted)
    end
    return tostring(amount)
end

local function escapeRichText(text)
    local safe = tostring(text or "")
    safe = safe:gsub("&", "&amp;")
    safe = safe:gsub("<", "&lt;")
    safe = safe:gsub(">", "&gt;")
    return safe
end

local SeedShopItemDefinitions = {}
do
    local rawShopData = SeedShopData and SeedShopData.ShopData
    if type(rawShopData) == "table" then
        for _, itemInfo in pairs(rawShopData) do
            if type(itemInfo) == "table" then
                local itemName = itemInfo.Name
                if type(itemName) == "string" and itemName ~= "" then
                    table.insert(SeedShopItemDefinitions, {
                        Name = itemName,
                        LayoutOrder = tonumber(itemInfo.LayoutOrder) or math.huge,
                        Price = tonumber(itemInfo.Price) or math.huge
                    })
                end
            end
        end
    end
end

table.sort(SeedShopItemDefinitions, function(a, b)
    if a.LayoutOrder ~= b.LayoutOrder then
        return a.LayoutOrder < b.LayoutOrder
    end
    if a.Price ~= b.Price then
        return a.Price < b.Price
    end
    return a.Name < b.Name
end)

local SeedShopItemNames = {}
local SeedShopItemNameLookup = {}
for _, itemDef in ipairs(SeedShopItemDefinitions) do
    if not SeedShopItemNameLookup[itemDef.Name] then
        SeedShopItemNameLookup[itemDef.Name] = true
        table.insert(SeedShopItemNames, itemDef.Name)
    end
end

local function isValidSeedShopItemName(itemName)
    return type(itemName) == "string" and SeedShopItemNameLookup[itemName] == true
end

local function normalizeSelectedSeedNameMap(rawSelection)
    local normalized = {}

    if type(rawSelection) == "string" then
        if isValidSeedShopItemName(rawSelection) then
            normalized[rawSelection] = true
        end
        return normalized
    end

    if type(rawSelection) ~= "table" then
        return normalized
    end

    for key, value in pairs(rawSelection) do
        if type(key) == "string" and type(value) == "boolean" then
            if value and isValidSeedShopItemName(key) then
                normalized[key] = true
            end
        elseif type(value) == "string" then
            if isValidSeedShopItemName(value) then
                normalized[value] = true
            end
        elseif type(value) == "table" then
            local candidate = value.Value or value.Name or value.Text
            if type(candidate) == "string" and isValidSeedShopItemName(candidate) then
                normalized[candidate] = true
            end
        end
    end

    return normalized
end

local function selectedSeedNameMapToList(selectedMap)
    local list = {}
    if type(selectedMap) ~= "table" then
        return list
    end

    for _, itemName in ipairs(SeedShopItemNames) do
        if selectedMap[itemName] == true then
            table.insert(list, itemName)
        end
    end
    return list
end

local function getSelectedSeedNamesOrdered()
    return selectedSeedNameMapToList(Hub.Config.AutoBuySeeds and Hub.Config.AutoBuySeeds.SelectedSeedNames)
end

local function getSelectedSeedCount()
    local selectedNames = getSelectedSeedNamesOrdered()
    return #selectedNames
end

Hub.Config.AutoBuySeeds.SelectedSeedNames = normalizeSelectedSeedNameMap(Hub.Config.AutoBuySeeds.SelectedSeedNames)

local GearShopItemDefinitions = {}
do
    local rawShopData = GearShopData and GearShopData.ShopData
    if type(rawShopData) == "table" then
        for _, itemInfo in pairs(rawShopData) do
            if type(itemInfo) == "table" then
                local itemName = itemInfo.Name
                if type(itemName) == "string" and itemName ~= "" then
                    table.insert(GearShopItemDefinitions, {
                        Name = itemName,
                        LayoutOrder = tonumber(itemInfo.LayoutOrder) or math.huge,
                        Price = tonumber(itemInfo.Price) or math.huge
                    })
                end
            end
        end
    end
end

table.sort(GearShopItemDefinitions, function(a, b)
    if a.LayoutOrder ~= b.LayoutOrder then
        return a.LayoutOrder < b.LayoutOrder
    end
    if a.Price ~= b.Price then
        return a.Price < b.Price
    end
    return a.Name < b.Name
end)

local GearShopItemNames = {}
local GearShopItemNameLookup = {}
for _, itemDef in ipairs(GearShopItemDefinitions) do
    if not GearShopItemNameLookup[itemDef.Name] then
        GearShopItemNameLookup[itemDef.Name] = true
        table.insert(GearShopItemNames, itemDef.Name)
    end
end

local function isValidGearShopItemName(itemName)
    return type(itemName) == "string" and GearShopItemNameLookup[itemName] == true
end

local function normalizeSelectedGearNameMap(rawSelection)
    local normalized = {}

    if type(rawSelection) == "string" then
        if isValidGearShopItemName(rawSelection) then
            normalized[rawSelection] = true
        end
        return normalized
    end

    if type(rawSelection) ~= "table" then
        return normalized
    end

    for key, value in pairs(rawSelection) do
        if type(key) == "string" and type(value) == "boolean" then
            if value and isValidGearShopItemName(key) then
                normalized[key] = true
            end
        elseif type(value) == "string" then
            if isValidGearShopItemName(value) then
                normalized[value] = true
            end
        elseif type(value) == "table" then
            local candidate = value.Value or value.Name or value.Text
            if type(candidate) == "string" and isValidGearShopItemName(candidate) then
                normalized[candidate] = true
            end
        end
    end

    return normalized
end

local function selectedGearNameMapToList(selectedMap)
    local list = {}
    if type(selectedMap) ~= "table" then
        return list
    end

    for _, itemName in ipairs(GearShopItemNames) do
        if selectedMap[itemName] == true then
            table.insert(list, itemName)
        end
    end
    return list
end

local function getSelectedGearNamesOrdered()
    return selectedGearNameMapToList(Hub.Config.AutoBuyGears and Hub.Config.AutoBuyGears.SelectedGearNames)
end

local function getSelectedGearCount()
    local selectedNames = getSelectedGearNamesOrdered()
    return #selectedNames
end

Hub.Config.AutoBuyGears.SelectedGearNames = normalizeSelectedGearNameMap(Hub.Config.AutoBuyGears.SelectedGearNames)

local SprinklerTypeNames = {}
local SprinklerTypeLookup = {}
for sprinklerType, definition in pairs(SprinklerDefinitions) do
    if type(sprinklerType) == "string" and sprinklerType ~= "" and type(definition) == "table" then
        SprinklerTypeLookup[sprinklerType] = true
        table.insert(SprinklerTypeNames, sprinklerType)
    end
end

local function getSprinklerPowerScore(sprinklerType)
    local definition = SprinklerDefinitions[sprinklerType]
    if type(definition) ~= "table" then
        return 0
    end

    local range = tonumber(definition.Range) or 0
    local duration = tonumber(definition.Duration) or 0
    local growthMultiplier = tonumber(definition.GrowthSpeedMultiplier) or 1
    local fruitMultiplier = tonumber(definition.FruitSizeMultiplier) or 1
    return range * duration * growthMultiplier * fruitMultiplier
end

table.sort(SprinklerTypeNames, function(a, b)
    local powerA = getSprinklerPowerScore(a)
    local powerB = getSprinklerPowerScore(b)
    if powerA ~= powerB then
        return powerA > powerB
    end
    return a < b
end)

local function isValidSprinklerTypeName(sprinklerType)
    return type(sprinklerType) == "string" and SprinklerTypeLookup[sprinklerType] == true
end

local function resolveSprinklerTypeFromTool(tool)
    if not tool or not tool:IsA("Tool") then
        return nil
    end

    local gearNameAttribute = tool:GetAttribute("GearName")
    if isValidSprinklerTypeName(gearNameAttribute) then
        return gearNameAttribute
    end

    if isValidSprinklerTypeName(tool.Name) then
        return tool.Name
    end

    local loweredName = string.lower(tostring(tool.Name or ""))
    for _, sprinklerType in ipairs(SprinklerTypeNames) do
        if string.find(loweredName, string.lower(sprinklerType), 1, true) then
            return sprinklerType
        end
    end

    return nil
end

local function getToolStackCount(tool)
    if not tool or not tool.Parent then
        return 0
    end
    local ok, count = pcall(function()
        return ItemInventory.getItemCount(tool)
    end)
    if ok and type(count) == "number" and count > 0 then
        return math.floor(count)
    end
    return 1
end

local function collectSprinklerTools()
    local sprinklers = {}

    local function collect(container)
        if not container then
            return
        end

        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool")
                and not tool:GetAttribute("IsCrate")
                and not tool:GetAttribute("IsHarvested")
            then
                local sprinklerType = resolveSprinklerTypeFromTool(tool)
                if sprinklerType then
                    local definition = SprinklerDefinitions[sprinklerType]
                    local range = definition and tonumber(definition.Range) or 0
                    local duration = definition and tonumber(definition.Duration) or 0
                    local growthMultiplier = definition and tonumber(definition.GrowthSpeedMultiplier) or 1
                    local fruitMultiplier = definition and tonumber(definition.FruitSizeMultiplier) or 1
                    local stackCount = getToolStackCount(tool)
                    if stackCount > 0 then
                        table.insert(sprinklers, {
                            Tool = tool,
                            SprinklerType = sprinklerType,
                            Range = range,
                            Duration = duration,
                            GrowthMultiplier = growthMultiplier,
                            FruitMultiplier = fruitMultiplier,
                            PowerScore = getSprinklerPowerScore(sprinklerType),
                            Count = stackCount
                        })
                    end
                end
            end
        end
    end

    collect(LocalPlayer:FindFirstChildOfClass("Backpack"))
    collect(LocalPlayer.Character)

    table.sort(sprinklers, function(a, b)
        if a.PowerScore ~= b.PowerScore then
            return a.PowerScore > b.PowerScore
        end
        if a.Range ~= b.Range then
            return a.Range > b.Range
        end
        return a.SprinklerType < b.SprinklerType
    end)

    return sprinklers
end

local function getSprinklerGroundPosition(sprinklerModel)
    if not sprinklerModel or not sprinklerModel:IsA("Model") then
        return nil
    end

    local groundAnchor = sprinklerModel:FindFirstChild("GroundAnchor", true)
    if groundAnchor and groundAnchor:IsA("BasePart") then
        return groundAnchor.Position
    end

    return getPlantPosition(sprinklerModel)
end

local function isWithinPlotPartsXZ(worldPosition, plotParts, extraPadding)
    if typeof(worldPosition) ~= "Vector3" or type(plotParts) ~= "table" or #plotParts == 0 then
        return false
    end
    for _, part in ipairs(plotParts) do
        if part:IsA("BasePart") and isPointInsidePartXZ(worldPosition, part, extraPadding or 0) then
            return true
        end
    end
    return false
end

local function getOwnedActiveSprinklers(plotParts)
    local sprinklers = {}
    for _, sprinklerModel in ipairs(CollectionService:GetTagged("Sprinkler")) do
        if sprinklerModel:IsA("Model")
            and sprinklerModel:IsDescendantOf(workspace)
            and sprinklerModel:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        then
            local position = getSprinklerGroundPosition(sprinklerModel)
            if position then
                if type(plotParts) == "table"
                    and #plotParts > 0
                    and not isWithinPlotPartsXZ(position, plotParts, SPRINKLER_PLOT_FILTER_PADDING)
                then
                    continue
                end
                local sprinklerType = sprinklerModel:GetAttribute("SprinklerType")
                local definition = SprinklerDefinitions[sprinklerType]
                local range = definition and tonumber(definition.Range) or 0
                local growthHealth = tonumber(sprinklerModel:GetAttribute("GrowthHealth")) or 0
                local growthMaxHealth = tonumber(sprinklerModel:GetAttribute("GrowthMaxHealth"))
                    or tonumber(sprinklerModel:GetAttribute("Duration"))
                    or 0
                local isActive = growthMaxHealth <= 0 or growthHealth < growthMaxHealth
                if isActive then
                    table.insert(sprinklers, {
                        Position = position,
                        Range = range,
                        SprinklerType = type(sprinklerType) == "string" and sprinklerType or "Unknown"
                    })
                end
            end
        end
    end
    return sprinklers
end

local function collectOwnedPlantTargetsForSprinklers(plotParts)
    local targets = {}
    local seenByUuid = {}

    local function considerPlant(plant)
        if not plant or not plant:IsA("Model") then
            return
        end
        if plant:GetAttribute("OwnerUserId") ~= LocalPlayer.UserId then
            return
        end
        if plant:GetAttribute("IsHarvested") then
            return
        end

        local plantUuid = plant:GetAttribute("Uuid")
        if plantUuid and seenByUuid[plantUuid] then
            return
        end

        local position = getPlantPosition(plant)
        if not position then
            return
        end
        if type(plotParts) == "table"
            and #plotParts > 0
            and not isWithinPlotPartsXZ(position, plotParts, SPRINKLER_PLOT_FILTER_PADDING)
        then
            return
        end

        if plantUuid then
            seenByUuid[plantUuid] = true
        end
        targets[#targets + 1] = position
    end

    local plantsFolder = workspace:FindFirstChild("Plants")
    if plantsFolder then
        for _, child in ipairs(plantsFolder:GetChildren()) do
            considerPlant(child)
        end
    end

    for _, taggedPlant in ipairs(CollectionService:GetTagged("Plant")) do
        considerPlant(taggedPlant)
    end

    return targets
end

local PlantTypeNames = {}
local PlantTypeNameLookup = {}
do
    if type(PlantDataDefinitions) == "table" then
        for plantType, definition in pairs(PlantDataDefinitions) do
            if type(plantType) == "string"
                and plantType ~= ""
                and type(definition) == "table"
            then
                PlantTypeNameLookup[plantType] = true
                table.insert(PlantTypeNames, plantType)
            end
        end
    end
end
table.sort(PlantTypeNames, function(a, b)
    return a < b
end)

local function isValidPlantTypeName(plantType)
    return type(plantType) == "string" and PlantTypeNameLookup[plantType] == true
end

local function normalizeSelectedPlantTypeMap(rawSelection)
    local normalized = {}

    if type(rawSelection) == "string" then
        if isValidPlantTypeName(rawSelection) then
            normalized[rawSelection] = true
        end
        return normalized
    end

    if type(rawSelection) ~= "table" then
        return normalized
    end

    for key, value in pairs(rawSelection) do
        if type(key) == "string" and type(value) == "boolean" then
            if value and isValidPlantTypeName(key) then
                normalized[key] = true
            end
        elseif type(value) == "string" then
            if isValidPlantTypeName(value) then
                normalized[value] = true
            end
        elseif type(value) == "table" then
            local candidate = value.Value or value.Name or value.Text
            if type(candidate) == "string" and isValidPlantTypeName(candidate) then
                normalized[candidate] = true
            end
        end
    end

    return normalized
end

local function selectedPlantTypeMapToList(selectedMap)
    local list = {}
    if type(selectedMap) ~= "table" then
        return list
    end

    for _, plantType in ipairs(PlantTypeNames) do
        if selectedMap[plantType] == true then
            table.insert(list, plantType)
        end
    end
    return list
end

local function getSelectedPlantTypeCount()
    return #selectedPlantTypeMapToList(Hub.Config.AutoHarvest and Hub.Config.AutoHarvest.SelectedPlantTypes)
end

local function normalizeRipenessStage(stageName)
    local normalized = string.lower(tostring(stageName or ""))
    if normalized == "" then
        return nil
    end
    if string.find(normalized, "lush", 1, true) then
        return "Lush"
    end
    if string.find(normalized, "unripe", 1, true) then
        return "Unripe"
    end
    if string.find(normalized, "ripe", 1, true) then
        return "Ripe"
    end
    if string.find(normalized, "ripened", 1, true) then
        return "Ripe"
    end
    return nil
end

local function shouldHarvestRipenessStage(stageName)
    local stage = normalizeRipenessStage(stageName)
    if stage == nil then
        return Hub.Config.AutoHarvest.AllowUnripe == true
    end
    if stage == "Unripe" then
        return Hub.Config.AutoHarvest.AllowUnripe == true
    end
    if stage == "Ripe" then
        return Hub.Config.AutoHarvest.AllowRipe == true
    end
    if stage == "Lush" then
        return Hub.Config.AutoHarvest.AllowLush == true
    end
    return false
end

local function getAutoHarvestStageSummary()
    local stages = {}
    if Hub.Config.AutoHarvest.AllowUnripe then
        table.insert(stages, "Unripe")
    end
    if Hub.Config.AutoHarvest.AllowRipe then
        table.insert(stages, "Ripe")
    end
    if Hub.Config.AutoHarvest.AllowLush then
        table.insert(stages, "Lush")
    end
    if #stages == 0 then
        return "none"
    end
    return table.concat(stages, ",")
end

local function getAutoHarvestTypeSummary()
    local selectedCount = getSelectedPlantTypeCount()
    if selectedCount <= 0 then
        return "all"
    end
    return tostring(selectedCount) .. " selected"
end

Hub.Config.AutoHarvest.SelectedPlantTypes = normalizeSelectedPlantTypeMap(Hub.Config.AutoHarvest.SelectedPlantTypes)

local function getShopStockAmount(shopDataSnapshot, shopItemName)
    local items = shopDataSnapshot and shopDataSnapshot.Items
    local itemState = type(items) == "table" and items[shopItemName] or nil
    local amount = itemState and tonumber(itemState.Amount) or 0
    if amount <= 0 then
        return 0
    end
    return math.floor(amount)
end

local function getSeedShopStockAmount(seedShopDataSnapshot, shopItemName)
    return getShopStockAmount(seedShopDataSnapshot, shopItemName)
end

local function getGearShopStockAmount(gearShopDataSnapshot, shopItemName)
    return getShopStockAmount(gearShopDataSnapshot, shopItemName)
end

local function fetchSeedShopDataSnapshot()
    local ok, data = pcall(function()
        return GetShopDataRemote:InvokeServer("SeedShop")
    end)
    if ok and type(data) == "table" and type(data.Items) == "table" then
        return data, nil
    end
    return nil, tostring(data)
end

local function fetchGearShopDataSnapshot()
    local ok, data = pcall(function()
        return GetShopDataRemote:InvokeServer("GearShop")
    end)
    if ok and type(data) == "table" and type(data.Items) == "table" then
        return data, nil
    end
    return nil, tostring(data)
end

local function purchaseSeedShopItem(shopItemName)
    local ok, resultA, resultB = pcall(function()
        return PurchaseShopItemRemote:InvokeServer("SeedShop", shopItemName)
    end)
    if not ok then
        return false, tostring(resultA), nil
    end

    if type(resultA) == "table" and type(resultA.Items) == "table" then
        return true, nil, resultA
    end

    if resultA == true then
        return true, nil, nil
    end

    if resultA == false then
        return false, tostring(resultB or "Purchase rejected"), nil
    end

    return false, tostring(resultA or resultB or "Unknown purchase response"), nil
end

local function purchaseGearShopItem(shopItemName)
    local ok, resultA, resultB = pcall(function()
        return PurchaseShopItemRemote:InvokeServer("GearShop", shopItemName)
    end)
    if not ok then
        return false, tostring(resultA), nil
    end

    if type(resultA) == "table" and type(resultA.Items) == "table" then
        return true, nil, resultA
    end

    if resultA == true then
        return true, nil, nil
    end

    if resultA == false then
        return false, tostring(resultB or "Purchase rejected"), nil
    end

    return false, tostring(resultA or resultB or "Unknown purchase response"), nil
end

local function buildAvailableStockText(title, itemDefinitions, stockSnapshot, fetchError)
    if #itemDefinitions == 0 then
        return title .. ": Definitions unavailable."
    end

    if not stockSnapshot then
        return title .. ": Could not fetch stock (" .. tostring(fetchError or "unknown") .. ")"
    end

    local lines = {}
    local availableCount = 0
    for _, itemDef in ipairs(itemDefinitions) do
        local amount = getShopStockAmount(stockSnapshot, itemDef.Name)
        if amount > 0 then
            availableCount = availableCount + 1
            lines[#lines + 1] = string.format("%s x%d", escapeRichText(itemDef.Name), amount)
        end
    end

    if availableCount == 0 then
        return title .. ": No stock available right now."
    end

    return string.format(
        "%s (%d available)\n%s",
        title,
        availableCount,
        table.concat(lines, "\n")
    )
end

local StockStatusState = {
    Seed = {
        Snapshot = nil,
        FetchError = nil,
        HasFetched = false,
        RestockInterval = tonumber(SeedShopData.RestockInterval) or 300,
        LastCycleIndex = nil,
        LastChangedAt = nil,
        Signature = nil
    },
    Gear = {
        Snapshot = nil,
        FetchError = nil,
        HasFetched = false,
        RestockInterval = tonumber(GearShopData.RestockInterval) or 300,
        LastCycleIndex = nil,
        LastChangedAt = nil,
        Signature = nil
    }
}

local function formatElapsedStockTime(totalSeconds)
    local seconds = math.max(0, math.floor(tonumber(totalSeconds) or 0))
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = seconds % 60
    return string.format("%02d:%02d", minutes, remainingSeconds)
end

local function getStockTimerColor(remainingSeconds)
    if remainingSeconds <= STOCK_TIMER_WARN_SECONDS then
        return "#EF4444"
    end
    if remainingSeconds <= STOCK_TIMER_STALE_SECONDS then
        return "#F59E0B"
    end
    return "#22C55E"
end

local function getServerClockSeconds()
    local ok, serverNow = pcall(function()
        return workspace:GetServerTimeNow()
    end)
    if ok and type(serverNow) == "number" then
        return serverNow
    end
    return tick()
end

local function buildStockSignature(itemDefinitions, stockSnapshot)
    local items = stockSnapshot and stockSnapshot.Items
    if type(items) ~= "table" then
        return nil
    end

    local signatureParts = {}
    for _, itemDef in ipairs(itemDefinitions) do
        local itemName = tostring(itemDef.Name or "")
        signatureParts[#signatureParts + 1] = itemName .. ":" .. tostring(getShopStockAmount(stockSnapshot, itemName))
    end
    return table.concat(signatureParts, "|")
end

local function buildStockTimerText(stockState)
    local restockInterval = math.max(1, math.floor(tonumber(stockState.RestockInterval) or 300))

    local serverSeconds = getServerClockSeconds()
    local secondsUntilRestock = restockInterval - serverSeconds % restockInterval
    local remainingSeconds = math.min(math.ceil(secondsUntilRestock), restockInterval)
    if remainingSeconds <= 0 then
        remainingSeconds = restockInterval
    end
    local timerColor = getStockTimerColor(remainingSeconds)
    return string.format(
        "<font color='%s'>Update Timer: %s</font>",
        timerColor,
        formatElapsedStockTime(remainingSeconds)
    )
end

local function renderStockStatus(labelKey, title, itemDefinitions, stockState)
    local stockText
    if stockState.HasFetched then
        stockText = buildAvailableStockText(title, itemDefinitions, stockState.Snapshot, stockState.FetchError)
    else
        stockText = title .. ": Loading..."
    end
    local timerText = buildStockTimerText(stockState)
    queueUILabelUpdate(labelKey, stockText .. "\n" .. timerText)
end

local function getStockCycleIndex(stockState, serverSeconds)
    local restockInterval = math.max(1, math.floor(tonumber(stockState.RestockInterval) or 300))
    return math.floor(serverSeconds / restockInterval)
end

local function updateStockState(stockState, itemDefinitions, stockSnapshot, fetchError)
    stockState.HasFetched = true
    stockState.Snapshot = stockSnapshot
    stockState.FetchError = fetchError

    if stockSnapshot then
        local serverSeconds = getServerClockSeconds()
        stockState.LastCycleIndex = getStockCycleIndex(stockState, serverSeconds)
        local now = tick()
        local signature = buildStockSignature(itemDefinitions, stockSnapshot)
        if signature ~= stockState.Signature then
            stockState.Signature = signature
            stockState.LastChangedAt = now
        elseif type(stockState.LastChangedAt) ~= "number" then
            stockState.LastChangedAt = now
        end
    end
end

local function updateSeedStockStatus(stockSnapshot, fetchError)
    updateStockState(StockStatusState.Seed, SeedShopItemDefinitions, stockSnapshot, fetchError)
    renderStockStatus("SeedStock", "Seed Stock", SeedShopItemDefinitions, StockStatusState.Seed)
end

local function updateGearStockStatus(stockSnapshot, fetchError)
    updateStockState(StockStatusState.Gear, GearShopItemDefinitions, stockSnapshot, fetchError)
    renderStockStatus("GearStock", "Gear Stock", GearShopItemDefinitions, StockStatusState.Gear)
end

local function refreshSeedStockStatus()
    task.spawn(function()
        if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        local stockSnapshot, fetchError = fetchSeedShopDataSnapshot()
        if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        updateSeedStockStatus(stockSnapshot, fetchError)
    end)
end

local function refreshGearStockStatus()
    task.spawn(function()
        if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        local stockSnapshot, fetchError = fetchGearShopDataSnapshot()
        if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        updateGearStockStatus(stockSnapshot, fetchError)
    end)
end

local function refreshStockOnNewServerCycle(serverSeconds)
    local function refreshIfCycleAdvanced(stockState, refreshFn)
        local cycleIndex = getStockCycleIndex(stockState, serverSeconds)
        if type(stockState.LastCycleIndex) ~= "number" then
            stockState.LastCycleIndex = cycleIndex
            return
        end
        if cycleIndex ~= stockState.LastCycleIndex then
            stockState.LastCycleIndex = cycleIndex
            refreshFn()
        end
    end

    refreshIfCycleAdvanced(StockStatusState.Seed, refreshSeedStockStatus)
    refreshIfCycleAdvanced(StockStatusState.Gear, refreshGearStockStatus)
end

local function ensureStockTimerLoop()
    if Hub.StockTimerLoopRunning then
        return
    end

    Hub.StockTimerLoopRunning = true
    local runId = CurrentRunId
    task.spawn(function()
        while not Hub.IsUnloaded and Hub.RunId == runId do
            local serverSeconds = getServerClockSeconds()
            refreshStockOnNewServerCycle(serverSeconds)
            renderStockStatus("SeedStock", "Seed Stock", SeedShopItemDefinitions, StockStatusState.Seed)
            renderStockStatus("GearStock", "Gear Stock", GearShopItemDefinitions, StockStatusState.Gear)
            task.wait(STOCK_TIMER_UPDATE_INTERVAL)
        end
        Hub.StockTimerLoopRunning = false
    end)
end

local function shouldStopAutoBuyForReason(reasonText)
    local reason = string.lower(tostring(reasonText or ""))
    if reason == "" then
        return false
    end

    if string.find(reason, "not enough", 1, true) then
        return true
    end
    if string.find(reason, "far", 1, true) then
        return true
    end
    if string.find(reason, "cooldown", 1, true) then
        return true
    end
    if string.find(reason, "stock", 1, true) then
        return true
    end
    return false
end

local function getSellableInventoryStats()
    local stackCount = 0
    local itemCount = 0

    local function collect(container)
        if not container then
            return
        end

        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and not tool:GetAttribute("IsCrate") then
                local value = 0
                local okValue, resolvedValue = pcall(function()
                    return FruitValueCalculator.GetValue(tool)
                end)
                if okValue and type(resolvedValue) == "number" then
                    value = resolvedValue
                end

                local lowerName = string.lower(tostring(tool.Name or ""))
                local hasSellHint = tool:GetAttribute("HarvestedFrom") ~= nil
                    or tool:GetAttribute("FruitValue") ~= nil
                    or string.find(lowerName, "kg", 1, true) ~= nil

                if value > 0 or hasSellHint then
                    local amount = 1
                    local okCount, itemCountValue = pcall(function()
                        return ItemInventory.getItemCount(tool)
                    end)
                    if okCount and type(itemCountValue) == "number" and itemCountValue > 0 then
                        amount = math.floor(itemCountValue)
                    end
                    stackCount = stackCount + 1
                    itemCount = itemCount + amount
                end
            end
        end
    end

    collect(LocalPlayer:FindFirstChildOfClass("Backpack"))
    collect(LocalPlayer.Character)
    return stackCount, itemCount
end

local function sellAllInventory()
    local ok, response = pcall(function()
        return SellItemsRemote:InvokeServer("SellAll")
    end)
    if not ok then
        return false, tostring(response)
    end

    if type(response) == "string" then
        local normalized = string.lower(response)
        if string.match(normalized, "^here") then
            return true, response
        end
        if string.find(normalized, "nothin", 1, true)
            or string.find(normalized, "nothing", 1, true)
            or string.find(normalized, "holdin", 1, true)
            or string.find(normalized, "holding", 1, true)
            or string.find(normalized, "far away", 1, true)
            or string.find(normalized, "cooldown", 1, true)
        then
            return false, response
        end
        return true, response
    end

    if response == true then
        return true, "Sold inventory."
    end
    if response == false or response == nil then
        return false, tostring(response or "Sell request returned no data")
    end
    return true, tostring(response)
end

local function getOwningPlantContainer(instance)
    local current = instance
    if current and current:IsA("BasePart") then
        current = current.Parent
    end

    while current and current ~= workspace do
        if current:GetAttribute("OwnerUserId") ~= nil then
            return current
        end
        current = current.Parent
    end

    return nil
end

local function resolvePlantType(instance, ownerContainer)
    local function readType(source)
        if not source then
            return nil
        end
        local plantType = source:GetAttribute("PlantType")
        if type(plantType) == "string" and plantType ~= "" then
            return plantType
        end
        local harvestedFrom = source:GetAttribute("HarvestedFrom")
        if type(harvestedFrom) == "string" and harvestedFrom ~= "" then
            return harvestedFrom
        end
        return nil
    end

    return readType(instance) or readType(ownerContainer)
end

local function shouldHarvestPlantType(plantType)
    local selectedMap = Hub.Config.AutoHarvest and Hub.Config.AutoHarvest.SelectedPlantTypes
    if type(selectedMap) ~= "table" or next(selectedMap) == nil then
        return true
    end
    return type(plantType) == "string" and selectedMap[plantType] == true
end

local function resolveHarvestPromptTarget(prompt)
    if not prompt or not prompt.Parent then
        return nil, nil
    end

    local targetModel = prompt.Parent
    if targetModel:IsA("BasePart") then
        targetModel = targetModel.Parent
    end
    if not targetModel or not targetModel:IsA("Model") then
        return nil, nil
    end

    local ownerContainer = targetModel
    if ownerContainer:GetAttribute("OwnerUserId") == nil then
        local parentModel = ownerContainer.Parent
        if parentModel and parentModel:IsA("Model") then
            ownerContainer = parentModel
        end
    end

    if not ownerContainer or ownerContainer:GetAttribute("OwnerUserId") == nil then
        return nil, nil
    end

    return targetModel, ownerContainer
end

local function buildHarvestPayloadFromTarget(targetModel)
    if not targetModel then
        return nil, nil
    end

    if targetModel:GetAttribute("HarvestablePlant") == true then
        local uuid = targetModel:GetAttribute("Uuid")
        if uuid == nil then
            return nil, nil
        end
        local key = tostring(uuid) .. ":0"
        return {
            Uuid = uuid
        }, key
    end

    local parentPlant = targetModel.Parent
    if not parentPlant or not parentPlant:IsA("Model") then
        return nil, nil
    end

    local parentUuid = parentPlant:GetAttribute("Uuid")
    if parentUuid == nil then
        return nil, nil
    end

    local growthAnchorIndex = targetModel:GetAttribute("GrowthAnchorIndex")
    local key = tostring(parentUuid) .. ":" .. tostring(growthAnchorIndex or 0)
    return {
        Uuid = parentUuid,
        GrowthAnchorIndex = growthAnchorIndex
    }, key
end

local function collectOwnedHarvestCandidates(options)
    local opts = type(options) == "table" and options or nil
    local customFilter = opts and opts.CustomFilter
    local ignorePlantTypeFilter = opts and opts.IgnorePlantTypeFilter == true
    local ignoreStageFilter = opts and opts.IgnoreStageFilter == true

    local candidates = {}
    local seenKeys = {}
    local root = getRootPart()
    local rootPos = root and root.Position or nil

    for _, taggedPrompt in ipairs(CollectionService:GetTagged("HarvestPrompt")) do
        if taggedPrompt:IsA("ProximityPrompt") then
            local targetModel, ownerContainer = resolveHarvestPromptTarget(taggedPrompt)
            if targetModel
                and ownerContainer
                and ownerContainer:GetAttribute("OwnerUserId") == LocalPlayer.UserId
                and not targetModel:GetAttribute("IsHarvested")
                and not ownerContainer:GetAttribute("IsHarvested")
            then
                local plantType = resolvePlantType(targetModel, ownerContainer)
                local passTypeFilter = ignorePlantTypeFilter or shouldHarvestPlantType(plantType)
                if passTypeFilter then
                    local ripenessStage = targetModel:GetAttribute("RipenessStage")
                        or ownerContainer:GetAttribute("RipenessStage")
                    local passStageFilter = ignoreStageFilter or shouldHarvestRipenessStage(ripenessStage)
                    if passStageFilter then
                        local mutation = targetModel:GetAttribute("Mutation")
                        if (type(mutation) ~= "string" or mutation == "") and ownerContainer ~= targetModel then
                            mutation = ownerContainer:GetAttribute("Mutation")
                        end

                        if type(customFilter) == "function" then
                            local okFilter, allowed = pcall(
                                customFilter,
                                targetModel,
                                ownerContainer,
                                plantType,
                                ripenessStage,
                                mutation
                            )
                            if not okFilter or not allowed then
                                continue
                            end
                        end

                        local payload, key = buildHarvestPayloadFromTarget(targetModel)
                        if payload and key and not seenKeys[key] then
                            seenKeys[key] = true
                            local worldPos = getPlantPosition(targetModel)
                            local distance = 0
                            if rootPos and worldPos then
                                distance = (worldPos - rootPos).Magnitude
                            end
                            table.insert(candidates, {
                                Payload = payload,
                                Key = key,
                                PlantType = plantType or "Unknown",
                                RipenessStage = normalizeRipenessStage(ripenessStage) or "Unknown",
                                Mutation = type(mutation) == "string" and mutation or "",
                                Position = worldPos,
                                Distance = distance,
                                TargetModel = targetModel
                            })
                        end
                    end
                end
            end
        end
    end

    table.sort(candidates, function(a, b)
        if a.Distance == b.Distance then
            return tostring(a.Key) < tostring(b.Key)
        end
        return a.Distance < b.Distance
    end)

    return candidates
end

local function getPlantDisplayName(instance, ownerContainer)
    return resolvePlantType(instance, ownerContainer) or instance.Name
end

local function getPlantSellValue(instance, ownerContainer)
    if not instance or not instance.Parent then
        return 0
    end

    local okDirect, directValue = pcall(function()
        return FruitValueCalculator.GetValue(instance)
    end)
    if okDirect and type(directValue) == "number" and directValue > 0 then
        return math.floor(directValue)
    end

    local resolvedType = resolvePlantType(instance, ownerContainer)
    local proxy = {}
    function proxy:GetAttribute(attributeName)
        if attributeName == "HarvestedFrom" then
            if type(resolvedType) == "string" and resolvedType ~= "" then
                return resolvedType
            end
            return nil
        end

        local value = instance:GetAttribute(attributeName)
        if value == nil and ownerContainer and ownerContainer ~= instance then
            value = ownerContainer:GetAttribute(attributeName)
        end
        return value
    end

    local okFallback, fallbackValue = pcall(function()
        return FruitValueCalculator.GetValue(proxy)
    end)
    if okFallback and type(fallbackValue) == "number" and fallbackValue > 0 then
        return math.floor(fallbackValue)
    end

    return 0
end

local function collectOwnedPlantValueEntries()
    local entries = {}
    local seen = {}

    local function consider(instance)
        if not instance
            or not instance.Parent
            or seen[instance]
            or not instance:IsA("Model")
        then
            return
        end
        seen[instance] = true

        local ownerContainer = getOwningPlantContainer(instance)
        if not ownerContainer then
            return
        end
        if ownerContainer:GetAttribute("OwnerUserId") ~= LocalPlayer.UserId then
            return
        end
        if instance:GetAttribute("IsHarvested") or ownerContainer:GetAttribute("IsHarvested") then
            return
        end

        local isFruit = CollectionService:HasTag(instance, "Fruit")
        local isHarvestablePlant = instance:GetAttribute("HarvestablePlant") == true
        if not isFruit and not isHarvestablePlant then
            return
        end

        local value = getPlantSellValue(instance, ownerContainer)
        if value > 0 then
            table.insert(entries, {
                Plant = instance,
                Name = getPlantDisplayName(instance, ownerContainer),
                Value = value
            })
        end
    end

    local clientPlantsFolder = workspace:FindFirstChild("ClientPlants")
    if clientPlantsFolder then
        for _, descendant in ipairs(clientPlantsFolder:GetDescendants()) do
            consider(descendant)
        end
    end

    local plantsFolder = workspace:FindFirstChild("Plants")
    if plantsFolder then
        for _, child in ipairs(plantsFolder:GetChildren()) do
            consider(child)
        end
    end

    for _, taggedPlant in ipairs(CollectionService:GetTagged("Plant")) do
        consider(taggedPlant)
    end
    for _, taggedFruit in ipairs(CollectionService:GetTagged("Fruit")) do
        consider(taggedFruit)
    end

    table.sort(entries, function(a, b)
        if a.Value == b.Value then
            return a.Name < b.Name
        end
        return a.Value > b.Value
    end)

    return entries
end

local function buildPlantRankingText()
    local entries = collectOwnedPlantValueEntries()
    local totalCount = #entries
    if totalCount == 0 then
        return "No plants found on your plot."
    end

    local shownCount = math.min(PLANT_RANK_MAX_ITEMS, totalCount)
    local lines = {
        string.format("Top %d / %d plants by value", shownCount, totalCount)
    }

    for index = 1, shownCount do
        local entry = entries[index]
        local lineText = string.format(
            "%02d. %s - $%s",
            index,
            escapeRichText(entry.Name),
            formatShillings(entry.Value)
        )
        local color = TOP_RANK_COLORS[index]
        if color then
            lineText = string.format("<font color='%s'>%s</font>", color, lineText)
        end
        lines[#lines + 1] = lineText
    end

    if totalCount > shownCount then
        lines[#lines + 1] = string.format("+%d more not shown", totalCount - shownCount)
    end

    return table.concat(lines, "\n")
end

local function isPositionOccupied(worldPosition)
    local plants = workspace:FindFirstChild("Plants")
    if not plants then
        return false
    end

    local target2D = Vector2.new(worldPosition.X, worldPosition.Z)
    for _, plant in ipairs(plants:GetChildren()) do
        if plant:GetAttribute("OwnerUserId") == LocalPlayer.UserId and not plant:GetAttribute("IsHarvested") then
            local plantPos = getPlantPosition(plant)
            if plantPos then
                local plant2D = Vector2.new(plantPos.X, plantPos.Z)
                if (plant2D - target2D).Magnitude <= OCCUPIED_RADIUS then
                    return true
                end
            end
        end
    end
    return false
end

local function buildGridPoints(parts)
    local points = {}
    local phaseOffsets = {
        Vector2.new(0, 0),
        Vector2.new(GRID_STEP * 0.5, 0),
        Vector2.new(0, GRID_STEP * 0.5)
    }

    for _, part in ipairs(parts) do
        local halfX = math.max(0, part.Size.X * 0.5 - GRID_MARGIN)
        local halfZ = math.max(0, part.Size.Z * 0.5 - GRID_MARGIN)

        for _, phase in ipairs(phaseOffsets) do
            local startX = -halfX + phase.X
            local startZ = -halfZ + phase.Y
            for x = startX, halfX, GRID_STEP do
                for z = startZ, halfZ, GRID_STEP do
                    local worldPos = (part.CFrame * CFrame.new(x, part.Size.Y * 0.5, z)).Position
                    table.insert(points, worldPos)
                end
            end
        end

        if halfX == 0 and halfZ == 0 then
            local worldPos = (part.CFrame * CFrame.new(0, part.Size.Y * 0.5, 0)).Position
            table.insert(points, worldPos)
        end
    end

    return points
end

local function dedupeWorldPositionsXZ(positions, step)
    local deduped = {}
    local seen = {}
    local quantizeStep = math.max(0.1, tonumber(step) or 0.75)

    for _, position in ipairs(positions) do
        if typeof(position) == "Vector3" then
            local keyX = math.floor(position.X / quantizeStep + 0.5)
            local keyZ = math.floor(position.Z / quantizeStep + 0.5)
            local key = tostring(keyX) .. ":" .. tostring(keyZ)
            if not seen[key] then
                seen[key] = true
                deduped[#deduped + 1] = position
            end
        end
    end

    return deduped
end

local function buildSprinklerFriendlyPlantOrder(parts)
    local positions = dedupeWorldPositionsXZ(buildGridPoints(parts), 0.45)
    if #positions <= 1 then
        return positions
    end

    local anchors = {}
    local activeSprinklers = getOwnedActiveSprinklers(parts)
    for _, sprinkler in ipairs(activeSprinklers) do
        local sprinklerPosition = sprinkler and sprinkler.Position
        if typeof(sprinklerPosition) == "Vector3" then
            anchors[#anchors + 1] = sprinklerPosition
        end
    end

    local partCenters = {}
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            partCenters[#partCenters + 1] = (part.CFrame * CFrame.new(0, part.Size.Y * 0.5, 0)).Position
        end
    end

    -- Without active sprinklers, center-first planting gives compact blocks
    -- that are easier for future sprinkler coverage than extending edge lines.
    if #anchors == 0 then
        for _, center in ipairs(partCenters) do
            anchors[#anchors + 1] = center
        end
    end
    if #anchors == 0 then
        return positions
    end

    local neighborRadiusSq = (GRID_STEP * 1.35) ^ 2
    local entries = {}
    for index, position in ipairs(positions) do
        local nearestAnchorSq = math.huge
        for _, anchorPosition in ipairs(anchors) do
            local dx = position.X - anchorPosition.X
            local dz = position.Z - anchorPosition.Z
            local distanceSq = dx * dx + dz * dz
            if distanceSq < nearestAnchorSq then
                nearestAnchorSq = distanceSq
            end
        end

        local nearestCenterSq = math.huge
        for _, centerPosition in ipairs(partCenters) do
            local dx = position.X - centerPosition.X
            local dz = position.Z - centerPosition.Z
            local distanceSq = dx * dx + dz * dz
            if distanceSq < nearestCenterSq then
                nearestCenterSq = distanceSq
            end
        end

        local neighborCount = 0
        for otherIndex, otherPosition in ipairs(positions) do
            if otherIndex ~= index then
                local dx = position.X - otherPosition.X
                local dz = position.Z - otherPosition.Z
                local distanceSq = dx * dx + dz * dz
                if distanceSq <= neighborRadiusSq then
                    neighborCount = neighborCount + 1
                end
            end
        end

        entries[#entries + 1] = {
            Position = position,
            AnchorDistSq = nearestAnchorSq,
            CenterDistSq = nearestCenterSq,
            NeighborCount = neighborCount
        }
    end

    table.sort(entries, function(a, b)
        if a.AnchorDistSq ~= b.AnchorDistSq then
            return a.AnchorDistSq < b.AnchorDistSq
        end
        if a.NeighborCount ~= b.NeighborCount then
            return a.NeighborCount > b.NeighborCount
        end
        if a.CenterDistSq ~= b.CenterDistSq then
            return a.CenterDistSq < b.CenterDistSq
        end
        if math.abs(a.Position.Z - b.Position.Z) > 0.05 then
            return a.Position.Z < b.Position.Z
        end
        return a.Position.X < b.Position.X
    end)

    local orderedPositions = {}
    for _, entry in ipairs(entries) do
        orderedPositions[#orderedPositions + 1] = entry.Position
    end
    return orderedPositions
end

local function worldPositionKeyXZ(position, step)
    if typeof(position) ~= "Vector3" then
        return nil
    end
    local quantizeStep = math.max(0.1, tonumber(step) or 0.75)
    local keyX = math.floor(position.X / quantizeStep + 0.5)
    local keyZ = math.floor(position.Z / quantizeStep + 0.5)
    return tostring(keyX) .. ":" .. tostring(keyZ)
end

local function downsampleWorldPositions(positions, maxCount)
    if type(positions) ~= "table" then
        return {}
    end
    local limit = math.max(1, math.floor(tonumber(maxCount) or 1))
    if #positions <= limit then
        return positions
    end

    local sampled = {}
    if limit == 1 then
        sampled[1] = positions[1]
        return sampled
    end

    local lastIndex = #positions - 1
    for sampleIndex = 1, limit do
        local t = (sampleIndex - 1) / (limit - 1)
        local sourceIndex = math.floor(t * lastIndex + 0.5) + 1
        sampled[#sampled + 1] = positions[math.clamp(sourceIndex, 1, #positions)]
    end
    return sampled
end

local function buildSprinklerCoverageTargets(parts, plantTargets)
    local targets = {}
    local prioritizedPlantTargets = {}
    if type(plantTargets) == "table" then
        for _, position in ipairs(plantTargets) do
            if typeof(position) == "Vector3" then
                targets[#targets + 1] = position
                prioritizedPlantTargets[#prioritizedPlantTargets + 1] = position
            end
        end
    end

    local gridTargets = buildGridPoints(parts)
    gridTargets = dedupeWorldPositionsXZ(gridTargets, SPRINKLER_COVERAGE_TARGET_DEDUPE_STEP)
    gridTargets = downsampleWorldPositions(gridTargets, SPRINKLER_COVERAGE_TARGET_MAX)

    for _, position in ipairs(gridTargets) do
        if typeof(position) == "Vector3" then
            targets[#targets + 1] = position
        end
    end

    targets = dedupeWorldPositionsXZ(targets, SPRINKLER_COVERAGE_TARGET_DEDUPE_STEP)
    if #targets > SPRINKLER_COVERAGE_TARGET_MAX then
        local limited = {}
        local seen = {}
        for _, position in ipairs(prioritizedPlantTargets) do
            local key = worldPositionKeyXZ(position, SPRINKLER_COVERAGE_TARGET_DEDUPE_STEP)
            if key and not seen[key] then
                seen[key] = true
                limited[#limited + 1] = position
                if #limited >= SPRINKLER_COVERAGE_TARGET_MAX then
                    return limited
                end
            end
        end

        for _, position in ipairs(targets) do
            local key = worldPositionKeyXZ(position, SPRINKLER_COVERAGE_TARGET_DEDUPE_STEP)
            if key and not seen[key] then
                seen[key] = true
                limited[#limited + 1] = position
                if #limited >= SPRINKLER_COVERAGE_TARGET_MAX then
                    break
                end
            end
        end
        targets = limited
    end
    return targets
end

local function getNearestPlantableSurfacePoint(parts, worldPosition)
    if typeof(worldPosition) ~= "Vector3" then
        return nil
    end

    local bestPoint = nil
    local bestDistanceSq = math.huge
    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            local localPos = part.CFrame:PointToObjectSpace(worldPosition)
            local halfX = part.Size.X * 0.5
            local halfZ = part.Size.Z * 0.5
            local clampedX = math.clamp(localPos.X, -halfX, halfX)
            local clampedZ = math.clamp(localPos.Z, -halfZ, halfZ)
            local surfacePoint = part.CFrame:PointToWorldSpace(Vector3.new(clampedX, part.Size.Y * 0.5, clampedZ))
            local dx = surfacePoint.X - worldPosition.X
            local dz = surfacePoint.Z - worldPosition.Z
            local distanceSq = dx * dx + dz * dz
            if distanceSq < bestDistanceSq then
                bestDistanceSq = distanceSq
                bestPoint = surfacePoint
            end
        end
    end
    return bestPoint
end

local function getGroundedSprinklerPosition(parts, worldPosition)
    if typeof(worldPosition) ~= "Vector3" then
        return nil
    end
    if type(parts) ~= "table" or #parts == 0 then
        return worldPosition
    end
    return getNearestPlantableSurfacePoint(parts, worldPosition) or worldPosition
end

local function buildSprinklerCandidatePoints(parts, plantTargets)
    local candidates = buildGridPoints(parts)

    for _, plantPosition in ipairs(plantTargets) do
        if typeof(plantPosition) == "Vector3" then
            candidates[#candidates + 1] = getGroundedSprinklerPosition(parts, plantPosition)
        end
    end

    for _, part in ipairs(parts) do
        if part:IsA("BasePart") then
            local topCenter = (part.CFrame * CFrame.new(0, part.Size.Y * 0.5, 0)).Position
            candidates[#candidates + 1] = getGroundedSprinklerPosition(parts, topCenter)
        end
    end

    return dedupeWorldPositionsXZ(candidates, SPRINKLER_CANDIDATE_DEDUPE_STEP)
end

local function computeSprinklerCoverage(candidatePosition, range, plantTargets, coveredState)
    local totalCovered = 0
    local newCovered = 0
    local rangeSq = range * range

    for index, plantPosition in ipairs(plantTargets) do
        local dx = candidatePosition.X - plantPosition.X
        local dz = candidatePosition.Z - plantPosition.Z
        local distanceSq = dx * dx + dz * dz
        if distanceSq <= rangeSq then
            totalCovered = totalCovered + 1
            if coveredState[index] ~= true then
                newCovered = newCovered + 1
            end
        end
    end

    return newCovered, totalCovered
end

local function markSprinklerCoverage(candidatePosition, range, plantTargets, coveredState)
    local rangeSq = range * range
    for index, plantPosition in ipairs(plantTargets) do
        local dx = candidatePosition.X - plantPosition.X
        local dz = candidatePosition.Z - plantPosition.Z
        local distanceSq = dx * dx + dz * dz
        if distanceSq <= rangeSq then
            coveredState[index] = true
        end
    end
end

local function isTooCloseToPlacedSprinklers(candidatePosition, range, existingSprinklers)
    for _, sprinkler in ipairs(existingSprinklers) do
        local spacingA = math.max(2.75, (tonumber(sprinkler.Range) or 0) * 0.32)
        local spacingB = math.max(2.75, range * 0.32)
        local requiredSpacing = math.max(spacingA, spacingB)
        if horizontalDistance(candidatePosition, sprinkler.Position) < requiredSpacing then
            return true
        end
    end
    return false
end

local function isCandidateTooCloseToPlants(candidatePosition, plantTargets, clearance)
    local threshold = math.max(0.1, tonumber(clearance) or 0)
    local thresholdSq = threshold * threshold
    for _, plantPosition in ipairs(plantTargets) do
        local dx = candidatePosition.X - plantPosition.X
        local dz = candidatePosition.Z - plantPosition.Z
        local distanceSq = dx * dx + dz * dz
        if distanceSq <= thresholdSq then
            return true
        end
    end
    return false
end

local function getSprinklerPlantClearance(range)
    local resolvedRange = math.max(0, tonumber(range) or 0)
    if resolvedRange <= 0 then
        return SPRINKLER_PLANT_CLEARANCE
    end
    -- Large-range sprinklers can be placed slightly closer to dense crops.
    return math.clamp(resolvedRange * 0.05, 0.55, SPRINKLER_PLANT_CLEARANCE)
end

local function computeSprinklerCoverageWithProximity(candidatePosition, range, plantTargets, coveredState)
    local totalCovered = 0
    local newCovered = 0
    local proximityScore = 0
    local rangeSq = range * range
    local safeRange = math.max(0.001, tonumber(range) or 0.001)

    for index, plantPosition in ipairs(plantTargets) do
        local dx = candidatePosition.X - plantPosition.X
        local dz = candidatePosition.Z - plantPosition.Z
        local distanceSq = dx * dx + dz * dz
        if distanceSq <= rangeSq then
            totalCovered = totalCovered + 1
            if coveredState[index] ~= true then
                newCovered = newCovered + 1
            end
            local distance = math.sqrt(distanceSq)
            proximityScore = proximityScore + ((safeRange - distance) / safeRange)
        end
    end

    return newCovered, totalCovered, proximityScore
end

local function computeUncoveredTargetCentroid(plantTargets, coveredState)
    local sumX = 0
    local sumZ = 0
    local count = 0
    for index, plantPosition in ipairs(plantTargets) do
        if coveredState[index] ~= true then
            sumX = sumX + plantPosition.X
            sumZ = sumZ + plantPosition.Z
            count = count + 1
        end
    end
    if count <= 0 then
        return nil
    end
    return Vector3.new(sumX / count, 0, sumZ / count)
end

local function buildSmartSprinklerPlan(plot, parts, toolEntries, maxPlacements)
    local placements = {}
    if not plot or #parts == 0 or #toolEntries == 0 or maxPlacements <= 0 then
        return placements, 0, 0
    end

    local plantTargets = collectOwnedPlantTargetsForSprinklers(parts)
    local coverageTargets
    if #plantTargets > 0 then
        coverageTargets = plantTargets
    else
        coverageTargets = buildSprinklerCoverageTargets(parts, plantTargets)
    end
    if #coverageTargets == 0 then
        return placements, 0, 0
    end

    local candidateTargets = #plantTargets > 0 and plantTargets or coverageTargets
    local candidates = buildSprinklerCandidatePoints(parts, candidateTargets)
    if #candidates == 0 then
        return placements, 0, 0
    end

    local existingSprinklers = getOwnedActiveSprinklers(parts)
    local coveredState = {}
    for _, sprinkler in ipairs(existingSprinklers) do
        markSprinklerCoverage(sprinkler.Position, sprinkler.Range, coverageTargets, coveredState)
    end

    local mutableTools = {}
    for _, entry in ipairs(toolEntries) do
        mutableTools[#mutableTools + 1] = {
            Tool = entry.Tool,
            SprinklerType = entry.SprinklerType,
            Range = entry.Range,
            Duration = entry.Duration,
            GrowthMultiplier = entry.GrowthMultiplier,
            FruitMultiplier = entry.FruitMultiplier,
            PowerScore = entry.PowerScore,
            Remaining = entry.Count
        }
    end

    local totalNewCoverage = 0
    while #placements < maxPlacements do
        local bestChoice = nil
        local uncoveredCentroid = computeUncoveredTargetCentroid(coverageTargets, coveredState)

        for toolIndex, toolEntry in ipairs(mutableTools) do
            if toolEntry.Remaining > 0 and toolEntry.Range > 0 then
                local plantClearance = getSprinklerPlantClearance(toolEntry.Range)
                for _, candidatePosition in ipairs(candidates) do
                    if not isTooCloseToPlacedSprinklers(candidatePosition, toolEntry.Range, existingSprinklers)
                        and not isCandidateTooCloseToPlants(candidatePosition, plantTargets, plantClearance)
                    then
                        local newCovered, totalCovered, proximityScore = computeSprinklerCoverageWithProximity(
                            candidatePosition,
                            toolEntry.Range,
                            coverageTargets,
                            coveredState
                        )
                        if newCovered > 0 then
                            local effectWeight = (toolEntry.GrowthMultiplier + toolEntry.FruitMultiplier) * 0.5
                                + (toolEntry.Duration / 300)
                            local centroidDistance = uncoveredCentroid
                                and horizontalDistance(candidatePosition, uncoveredCentroid)
                                or 0
                            local score = (newCovered * 1000 + totalCovered * 12 + proximityScore * 80
                                - centroidDistance * 2.5) * effectWeight
                            local isBetter = false
                            if not bestChoice then
                                isBetter = true
                            elseif score > bestChoice.Score then
                                isBetter = true
                            elseif math.abs(score - bestChoice.Score) <= 0.001 then
                                if proximityScore > (bestChoice.ProximityScore or -math.huge) + 0.001 then
                                    isBetter = true
                                elseif math.abs(proximityScore - (bestChoice.ProximityScore or 0)) <= 0.001
                                    and centroidDistance < (bestChoice.CentroidDistance or math.huge)
                                then
                                    isBetter = true
                                end
                            end
                            if isBetter then
                                bestChoice = {
                                    ToolIndex = toolIndex,
                                    Position = candidatePosition,
                                    Score = score,
                                    NewCovered = newCovered,
                                    TotalCovered = totalCovered,
                                    ProximityScore = proximityScore,
                                    CentroidDistance = centroidDistance
                                }
                            end
                        end
                    end
                end
            end
        end

        if not bestChoice or bestChoice.NewCovered < AUTO_SPRINKLER_MIN_NEW_COVERAGE then
            break
        end

        local chosenEntry = mutableTools[bestChoice.ToolIndex]
        placements[#placements + 1] = {
            Tool = chosenEntry.Tool,
            SprinklerType = chosenEntry.SprinklerType,
            Range = chosenEntry.Range,
            Position = bestChoice.Position,
            NewCovered = bestChoice.NewCovered,
            TotalCovered = bestChoice.TotalCovered
        }
        chosenEntry.Remaining = chosenEntry.Remaining - 1
        totalNewCoverage = totalNewCoverage + bestChoice.NewCovered

        markSprinklerCoverage(bestChoice.Position, chosenEntry.Range, coverageTargets, coveredState)
        existingSprinklers[#existingSprinklers + 1] = {
            Position = bestChoice.Position,
            Range = chosenEntry.Range,
            SprinklerType = chosenEntry.SprinklerType
        }
    end

    if #placements == 0 and #existingSprinklers == 0 then
        local fallbackToolEntry = nil
        for _, entry in ipairs(mutableTools) do
            if entry.Remaining > 0 and entry.Range > 0 then
                fallbackToolEntry = entry
                break
            end
        end

        if fallbackToolEntry then
            local bestFallback = nil
            local fallbackPlantClearance = getSprinklerPlantClearance(fallbackToolEntry.Range)
            local uncoveredCentroid = computeUncoveredTargetCentroid(coverageTargets, {})
            for _, candidatePosition in ipairs(candidates) do
                if not isCandidateTooCloseToPlants(candidatePosition, plantTargets, fallbackPlantClearance) then
                    local _, totalCovered, proximityScore = computeSprinklerCoverageWithProximity(
                        candidatePosition,
                        fallbackToolEntry.Range,
                        coverageTargets,
                        {}
                    )
                    local centroidDistance = uncoveredCentroid
                        and horizontalDistance(candidatePosition, uncoveredCentroid)
                        or 0
                    local fallbackScore = totalCovered * 100 + proximityScore * 20 - centroidDistance * 2.5
                    if totalCovered > 0 and (not bestFallback or fallbackScore > bestFallback.Score) then
                        bestFallback = {
                            Position = candidatePosition,
                            TotalCovered = totalCovered,
                            Score = fallbackScore
                        }
                    end
                end
            end

            if bestFallback then
                placements[#placements + 1] = {
                    Tool = fallbackToolEntry.Tool,
                    SprinklerType = fallbackToolEntry.SprinklerType,
                    Range = fallbackToolEntry.Range,
                    Position = bestFallback.Position,
                    NewCovered = bestFallback.TotalCovered,
                    TotalCovered = bestFallback.TotalCovered
                }
                totalNewCoverage = bestFallback.TotalCovered
            end
        end
    end

    return placements, totalNewCoverage, #coverageTargets
end

local function getSeedCount(tool)
    if not tool or not tool.Parent then
        return 0
    end
    return ItemInventory.getItemCount(tool)
end

local function collectSeedTools()
    local seeds = {}

    local function collect(container)
        if not container then
            return
        end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool")
                and not tool:GetAttribute("IsCrate")
                and not tool:GetAttribute("IsHarvested")
            then
                local plantType = tool:GetAttribute("PlantType")
                if type(plantType) == "string" and plantType ~= "" and getSeedCount(tool) > 0 then
                    table.insert(seeds, {
                        Tool = tool,
                        PlantType = plantType
                    })
                end
            end
        end
    end

    collect(LocalPlayer:FindFirstChildOfClass("Backpack"))
    collect(LocalPlayer.Character)

    table.sort(seeds, function(a, b)
        if a.PlantType == b.PlantType then
            return a.Tool.Name < b.Tool.Name
        end
        return a.PlantType < b.PlantType
    end)

    return seeds
end

local function getNextAvailableSeed(seedEntries)
    for _, entry in ipairs(seedEntries) do
        local tool = entry.Tool
        if tool and tool.Parent and getSeedCount(tool) > 0 then
            return entry
        end
    end
    return nil
end

local function equipTool(tool)
    if not tool or not tool.Parent then
        return false
    end
    local character = getCharacter()
    if tool.Parent == character then
        return true
    end
    local humanoid = getHumanoid()
    humanoid:EquipTool(tool)
    task.wait(EQUIP_DELAY)
    return tool.Parent == character
end

local function forceStandCharacter()
    local humanoid = getHumanoid()
    if not humanoid then
        return false
    end

    local changed = false
    local state = humanoid:GetState()
    if humanoid.Sit or state == Enum.HumanoidStateType.Seated then
        humanoid.Sit = false
        changed = true
    end

    if changed then
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
        end)
        task.wait(0.04)
        pcall(function()
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end

    return changed
end

local function getHorizontalFallbackForward()
    local root = getRootPart()
    if root then
        local look = root.CFrame.LookVector
        local horizontal = Vector3.new(look.X, 0, look.Z)
        if horizontal.Magnitude > 0.001 then
            return horizontal.Unit
        end
    end
    return Vector3.new(0, 0, -1)
end

local function tryUnstuckNearTarget(targetPosition, requiredDistance)
    local root = getRootPart()
    if not root then
        return false
    end

    forceStandCharacter()
    if horizontalDistance(root.Position, targetPosition) <= requiredDistance then
        return true
    end

    local right = getPlotRightDirection()
    local forward = getHorizontalFallbackForward()
    local offsets = {
        right * ANTI_STUCK_SIDE_OFFSET,
        -right * ANTI_STUCK_SIDE_OFFSET,
        forward * ANTI_STUCK_FORWARD_OFFSET,
        -forward * ANTI_STUCK_FORWARD_OFFSET,
        right * ANTI_STUCK_SIDE_OFFSET + forward * ANTI_STUCK_FORWARD_OFFSET,
        -right * ANTI_STUCK_SIDE_OFFSET + forward * ANTI_STUCK_FORWARD_OFFSET,
        Vector3.new(0, 0, 0)
    }

    for _, offset in ipairs(offsets) do
        root = getRootPart()
        if not root then
            return false
        end

        root.CFrame = CFrame.new(targetPosition + offset + Vector3.new(0, ANTI_STUCK_UP_OFFSET, 0))
        task.wait(0.06)
        forceStandCharacter()

        root = getRootPart()
        if root and horizontalDistance(root.Position, targetPosition) <= requiredDistance then
            return true
        end
    end

    return false
end

local function ensureInPlantRange(targetPosition)
    forceStandCharacter()
    local root = getRootPart()
    if not root then
        return false
    end
    if horizontalDistance(root.Position, targetPosition) <= MAX_PLANT_DISTANCE then
        return true
    end

    local humanoid = getHumanoid()
    local moveTarget = Vector3.new(targetPosition.X, root.Position.Y, targetPosition.Z)
    humanoid:MoveTo(moveTarget)

    local deadline = tick() + MOVE_TIMEOUT
    while tick() < deadline do
        root = getRootPart()
        if root and horizontalDistance(root.Position, targetPosition) <= MAX_PLANT_DISTANCE then
            return true
        end
        forceStandCharacter()
        task.wait(MOVE_RECHECK_DELAY)
    end

    if tryUnstuckNearTarget(targetPosition, MAX_PLANT_DISTANCE) then
        return true
    end

    root = getRootPart()
    if root then
        local sideOffset = getPlotRightDirection() * PLANT_FALLBACK_SIDE_OFFSET
        root.CFrame = CFrame.new(targetPosition + sideOffset + Vector3.new(0, TELEPORT_FALLBACK_HEIGHT, 0))
        task.wait(0.08)
        forceStandCharacter()
        root = getRootPart()
        if root and horizontalDistance(root.Position, targetPosition) <= MAX_PLANT_DISTANCE then
            return true
        end
    end

    return false
end

local function ensureInHarvestRange(targetPosition)
    if not targetPosition then
        return false
    end

    local inPlantRange = ensureInPlantRange(targetPosition)
    if not inPlantRange then
        return false
    end

    local root = getRootPart()
    if root and horizontalDistance(root.Position, targetPosition) <= AUTO_HARVEST_INTERACT_DISTANCE then
        return true
    end

    if tryUnstuckNearTarget(targetPosition, AUTO_HARVEST_INTERACT_DISTANCE) then
        return true
    end

    if root then
        root.CFrame = CFrame.new(targetPosition + Vector3.new(0, TELEPORT_FALLBACK_HEIGHT, 0))
        task.wait(0.06)
        forceStandCharacter()
    end

    root = getRootPart()
    return root and horizontalDistance(root.Position, targetPosition) <= AUTO_HARVEST_INTERACT_DISTANCE or false
end

local function ensureInSprinklerRange(targetPosition)
    if not targetPosition then
        return false
    end

    local root = getRootPart()
    if not root then
        return false
    end

    if horizontalDistance(root.Position, targetPosition) <= AUTO_SPRINKLER_MOVE_DISTANCE then
        return true
    end

    ensureInPlantRange(targetPosition)
    root = getRootPart()
    if root and horizontalDistance(root.Position, targetPosition) <= AUTO_SPRINKLER_MOVE_DISTANCE then
        return true
    end

    if tryUnstuckNearTarget(targetPosition, AUTO_SPRINKLER_MOVE_DISTANCE) then
        return true
    end

    root = getRootPart()
    if root then
        local sideOffset = getPlotRightDirection() * PLANT_FALLBACK_SIDE_OFFSET
        root.CFrame = CFrame.new(targetPosition + sideOffset + Vector3.new(0, TELEPORT_FALLBACK_HEIGHT, 0))
        task.wait(0.08)
        forceStandCharacter()
    end

    root = getRootPart()
    return root and horizontalDistance(root.Position, targetPosition) <= AUTO_SPRINKLER_MOVE_DISTANCE or false
end

local function getOwnedActiveSprinklerCount()
    return #getOwnedActiveSprinklers()
end

local function getOwnedTaggedSprinklerCount()
    local count = 0
    for _, sprinklerModel in ipairs(CollectionService:GetTagged("Sprinkler")) do
        if sprinklerModel:IsA("Model")
            and sprinklerModel:IsDescendantOf(workspace)
            and sprinklerModel:GetAttribute("OwnerUserId") == LocalPlayer.UserId
        then
            count = count + 1
        end
    end
    return count
end

local function hasOwnedSprinklerNearPosition(worldPosition, maxDistance)
    if typeof(worldPosition) ~= "Vector3" then
        return false
    end

    local threshold = math.max(0.25, tonumber(maxDistance) or SPRINKLER_CONFIRM_NEAR_DISTANCE)
    for _, sprinkler in ipairs(getOwnedActiveSprinklers()) do
        local sprinklerPosition = sprinkler.Position
        if typeof(sprinklerPosition) == "Vector3" and horizontalDistance(sprinklerPosition, worldPosition) <= threshold then
            return true
        end
    end

    return false
end

local function resolvePlotRightVector(plotParts, worldPosition)
    local fallback = Vector3.new(1, 0, 0)
    if typeof(worldPosition) ~= "Vector3" then
        return fallback
    end
    if type(plotParts) ~= "table" or #plotParts == 0 then
        return fallback
    end

    local bestPart = nil
    local bestDistanceSq = math.huge
    for _, part in ipairs(plotParts) do
        if part:IsA("BasePart") then
            local localPos = part.CFrame:PointToObjectSpace(worldPosition)
            local halfX = part.Size.X * 0.5
            local halfZ = part.Size.Z * 0.5
            local clampedX = math.clamp(localPos.X, -halfX, halfX)
            local clampedZ = math.clamp(localPos.Z, -halfZ, halfZ)
            local surfacePoint = part.CFrame:PointToWorldSpace(Vector3.new(clampedX, part.Size.Y * 0.5, clampedZ))
            local dx = surfacePoint.X - worldPosition.X
            local dz = surfacePoint.Z - worldPosition.Z
            local distanceSq = dx * dx + dz * dz
            if distanceSq < bestDistanceSq then
                bestDistanceSq = distanceSq
                bestPart = part
            end
        end
    end

    if bestPart then
        local right = bestPart.CFrame.RightVector
        local flatRight = Vector3.new(right.X, 0, right.Z)
        if flatRight.Magnitude > 0.001 then
            return flatRight.Unit
        end
    end

    return fallback
end

local function buildSprinklerPlacementAttemptSets(plotParts, worldPosition, plantTargets, plantClearance)
    local primaryPositions = {}
    local fallbackPositions = {}
    if typeof(worldPosition) ~= "Vector3" then
        return primaryPositions, fallbackPositions
    end

    local clearance = math.max(0.1, tonumber(plantClearance) or SPRINKLER_PLANT_CLEARANCE)
    local basePosition = getGroundedSprinklerPosition(plotParts, worldPosition) or worldPosition
    local anchorPosition = basePosition
    if type(plantTargets) == "table" and #plantTargets > 0 then
        local bestPlant = nil
        local bestDistanceSq = math.huge
        for _, plantPosition in ipairs(plantTargets) do
            if typeof(plantPosition) == "Vector3" then
                local dx = plantPosition.X - basePosition.X
                local dz = plantPosition.Z - basePosition.Z
                local distanceSq = dx * dx + dz * dz
                if distanceSq < bestDistanceSq then
                    bestDistanceSq = distanceSq
                    bestPlant = plantPosition
                end
            end
        end
        if bestPlant then
            anchorPosition = bestPlant
        end
    end
    local rightVector = resolvePlotRightVector(plotParts, anchorPosition)
    local ringDirections = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
        Vector3.new(0.707, 0, 0.707),
        Vector3.new(0.707, 0, -0.707),
        Vector3.new(-0.707, 0, 0.707),
        Vector3.new(-0.707, 0, -0.707)
    }

    local function addCandidate(targetList, candidatePosition, avoidPlants)
        if typeof(candidatePosition) ~= "Vector3" then
            return
        end
        local grounded = getGroundedSprinklerPosition(plotParts, candidatePosition) or candidatePosition
        if type(plotParts) == "table"
            and #plotParts > 0
            and not isWithinPlotPartsXZ(grounded, plotParts, 0.45)
        then
            return
        end
        if avoidPlants
            and type(plantTargets) == "table"
            and #plantTargets > 0
            and isCandidateTooCloseToPlants(grounded, plantTargets, clearance)
        then
            return
        end
        targetList[#targetList + 1] = grounded
    end

    local rightShiftRadii = {
        math.max(clearance + 0.35, 1.05),
        math.max(clearance + 0.85, 1.55),
        math.max(clearance + 1.35, 2.05),
        math.max(clearance + 1.9, 2.55),
        math.max(clearance + 2.45, 3.05)
    }
    for _, radius in ipairs(rightShiftRadii) do
        addCandidate(primaryPositions, anchorPosition + rightVector * radius, true)
    end

    local primaryRadii = {
        math.max(1.0, SPRINKLER_POSITION_JITTER_STEP * 1.2),
        math.max(1.45, SPRINKLER_POSITION_JITTER_STEP * 1.8),
        math.max(1.9, SPRINKLER_POSITION_JITTER_STEP * 2.4)
    }
    for _, radius in ipairs(primaryRadii) do
        for _, direction in ipairs(ringDirections) do
            addCandidate(primaryPositions, basePosition + direction * radius, true)
        end
    end

    local fallbackRadii = {
        math.max(2.3, SPRINKLER_POSITION_JITTER_STEP * 2.9),
        math.max(2.9, SPRINKLER_POSITION_JITTER_STEP * 3.6)
    }
    for _, radius in ipairs(fallbackRadii) do
        for _, direction in ipairs(ringDirections) do
            addCandidate(fallbackPositions, basePosition + direction * radius, false)
        end
    end

    addCandidate(fallbackPositions, basePosition, false)

    primaryPositions = dedupeWorldPositionsXZ(primaryPositions, 0.45)
    fallbackPositions = dedupeWorldPositionsXZ(fallbackPositions, 0.45)
    if #primaryPositions == 0 and typeof(basePosition) == "Vector3" then
        primaryPositions[1] = basePosition
    end
    return primaryPositions, fallbackPositions
end

local function buildSprinklerStandCandidates(plotParts, placementPosition)
    local candidates = {}
    if typeof(placementPosition) ~= "Vector3" then
        return candidates
    end

    local basePosition = getGroundedSprinklerPosition(plotParts, placementPosition) or placementPosition
    local ringDirections = {
        Vector3.new(1, 0, 0),
        Vector3.new(-1, 0, 0),
        Vector3.new(0, 0, 1),
        Vector3.new(0, 0, -1),
        Vector3.new(0.707, 0, 0.707),
        Vector3.new(0.707, 0, -0.707),
        Vector3.new(-0.707, 0, 0.707),
        Vector3.new(-0.707, 0, -0.707)
    }
    local ringRadii = {
        math.max(1.5, SPRINKLER_DESIRED_STAND_DISTANCE - 1.25),
        SPRINKLER_DESIRED_STAND_DISTANCE,
        SPRINKLER_DESIRED_STAND_DISTANCE + 1.4
    }

    candidates[#candidates + 1] = basePosition
    for _, radius in ipairs(ringRadii) do
        for _, direction in ipairs(ringDirections) do
            local offsetPosition = basePosition + direction * radius
            candidates[#candidates + 1] = getGroundedSprinklerPosition(plotParts, offsetPosition) or offsetPosition
        end
    end

    candidates = dedupeWorldPositionsXZ(candidates, 0.45)
    local root = getRootPart()
    if root then
        local rootPosition = root.Position
        table.sort(candidates, function(a, b)
            local rootDistA = horizontalDistance(rootPosition, a)
            local rootDistB = horizontalDistance(rootPosition, b)
            local placeDistA = math.abs(horizontalDistance(a, placementPosition) - SPRINKLER_DESIRED_STAND_DISTANCE)
            local placeDistB = math.abs(horizontalDistance(b, placementPosition) - SPRINKLER_DESIRED_STAND_DISTANCE)
            local scoreA = placeDistA * 10 + rootDistA
            local scoreB = placeDistB * 10 + rootDistB
            return scoreA < scoreB
        end)
    end

    return candidates
end

local function moveNearSprinklerPlacement(plotParts, placementPosition)
    if typeof(placementPosition) ~= "Vector3" then
        return false
    end

    local root = getRootPart()
    if root and horizontalDistance(root.Position, placementPosition) <= SPRINKLER_REQUIRED_PLAYER_DISTANCE then
        return true
    end

    local standCandidates = buildSprinklerStandCandidates(plotParts, placementPosition)
    local maxAttempts = math.min(#standCandidates, 18)
    for index = 1, maxAttempts do
        local standPosition = standCandidates[index]
        if typeof(standPosition) == "Vector3" then
            local moved = ensureInPlantRange(standPosition)
            if not moved then
                root = getRootPart()
                if root then
                    root.CFrame = CFrame.new(standPosition + Vector3.new(0, TELEPORT_FALLBACK_HEIGHT, 0))
                    task.wait(0.06)
                    forceStandCharacter()
                end
            end

            root = getRootPart()
            if root and horizontalDistance(root.Position, placementPosition) <= SPRINKLER_REQUIRED_PLAYER_DISTANCE then
                return true
            end
        end
    end

    local inRange = ensureInSprinklerRange(placementPosition)
    if not inRange then
        return false
    end
    root = getRootPart()
    return root and horizontalDistance(root.Position, placementPosition) <= SPRINKLER_REQUIRED_PLAYER_DISTANCE or false
end

local tryPlaceSprinkler
local cachedNativeSprinklerInputHandler = nil

local function resolveNativeSprinklerInputHandler()
    if cachedNativeSprinklerInputHandler then
        return cachedNativeSprinklerInputHandler
    end

    if type(getgc) ~= "function" then
        sprinklerLog("getgc unavailable for native sprinkler handler lookup")
        return nil
    end
    if type(debug) ~= "table" or type(debug.getinfo) ~= "function" then
        sprinklerLog("debug.getinfo unavailable for native sprinkler handler lookup")
        return nil
    end

    local okGc, gcObjects = pcall(function()
        return getgc(true)
    end)
    if not okGc or type(gcObjects) ~= "table" then
        sprinklerLog("getgc lookup failed")
        return nil
    end

    local bestCandidate = nil
    for _, object in ipairs(gcObjects) do
        if type(object) == "function" then
            local okInfo, info = pcall(function()
                return debug.getinfo(object)
            end)
            if okInfo and type(info) == "table" then
                local source = tostring(info.source or "")
                if string.find(source, "SprinklerPlacementController", 1, true) then
                    local nparams = tonumber(info.nparams) or -1
                    local score = 0
                    if nparams == 2 then
                        score = score + 2
                    end

                    if type(debug.getconstants) == "function" then
                        local okConsts, constants = pcall(function()
                            return debug.getconstants(object)
                        end)
                        if okConsts and type(constants) == "table" then
                            for _, constant in ipairs(constants) do
                                if constant == "MouseButton1" then
                                    score = score + 4
                                elseif constant == "Touch" then
                                    score = score + 2
                                elseif constant == "position" then
                                    score = score + 2
                                elseif constant == "UseGear" then
                                    score = score + 1
                                end
                            end
                        end
                    end

                    if score >= 6 and (not bestCandidate or score > bestCandidate.Score) then
                        bestCandidate = {
                            Func = object,
                            Score = score
                        }
                    end
                end
            end
        end
    end

    if bestCandidate and type(bestCandidate.Func) == "function" then
        cachedNativeSprinklerInputHandler = bestCandidate.Func
        sprinklerLog("Native sprinkler input handler found via getgc")
        return cachedNativeSprinklerInputHandler
    end

    sprinklerLog("Native sprinkler input handler not found via getgc")
    return nil
end

local function moveMouseToWorldPosition(worldPosition)
    if typeof(worldPosition) ~= "Vector3" then
        return false, "Invalid world position", nil, nil
    end

    local camera = workspace.CurrentCamera
    if not camera then
        return false, "No camera", nil, nil
    end

    local viewportPoint, onScreen = camera:WorldToViewportPoint(worldPosition)
    if not onScreen then
        return false, "Target off-screen", nil, nil
    end

    local x = math.floor(viewportPoint.X + 0.5)
    local y = math.floor(viewportPoint.Y + 0.5)

    local moved = false
    local moveError = nil
    if type(mousemoveabs) == "function" then
        local okAbs, errAbs = pcall(function()
            mousemoveabs(x, y)
        end)
        if okAbs then
            moved = true
        else
            moveError = tostring(errAbs)
        end
    end

    if not moved then
        local okService, vim = pcall(function()
            return game:GetService("VirtualInputManager")
        end)
        if okService and vim then
            local firedOk, firedErr = pcall(function()
                vim:SendMouseMoveEvent(x, y, game)
            end)
            if firedOk then
                moved = true
            else
                moveError = tostring(firedErr)
            end
        elseif not moveError then
            moveError = "No mousemoveabs and VirtualInputManager unavailable"
        end
    end

    if not moved then
        return false, moveError or "Mouse move failed", nil, nil
    end

    return true, nil, x, y
end

local function triggerNativeSprinklerInputAtWorldPosition(worldPosition)
    local moved, moveErr = moveMouseToWorldPosition(worldPosition)
    if not moved then
        return false, "Mouse move failed: " .. tostring(moveErr)
    end

    local nativeHandler = resolveNativeSprinklerInputHandler()
    if type(nativeHandler) ~= "function" then
        return false, "Native sprinkler handler unavailable"
    end

    local mockInput = {
        UserInputType = Enum.UserInputType.MouseButton1
    }
    local okFire, fireErr = pcall(function()
        nativeHandler(mockInput, false)
    end)
    if not okFire then
        return false, tostring(fireErr)
    end

    return true, nil
end

local function triggerSprinklerInputSignalAtWorldPosition(worldPosition)
    local moved, moveErr = moveMouseToWorldPosition(worldPosition)
    if not moved then
        return false, "Mouse move failed: " .. tostring(moveErr)
    end

    if type(firesignal) ~= "function" then
        return false, "firesignal unavailable"
    end

    local userInputService = game:GetService("UserInputService")
    local mockInput = {
        UserInputType = Enum.UserInputType.MouseButton1
    }
    local okFire, fireErr = pcall(function()
        firesignal(userInputService.InputBegan, mockInput, false)
    end)
    if not okFire then
        return false, tostring(fireErr)
    end

    return true, nil
end

local function simulateSprinklerMousePlaceAtWorldPosition(worldPosition)
    local moved, moveErr, x, y = moveMouseToWorldPosition(worldPosition)
    if not moved then
        return false, moveErr
    end

    if type(isrbxactive) == "function" then
        local okActive, active = pcall(function()
            return isrbxactive()
        end)
        if okActive and active == false then
            return false, "Game window is not focused"
        end
    end

    if type(mouse1click) == "function" then
        local okClick, clickErr = pcall(function()
            mouse1click()
        end)
        if okClick then
            return true, nil
        end
        sprinklerLog("mouse1click failed: " .. tostring(clickErr))
    end

    if type(mouse1press) == "function" and type(mouse1release) == "function" then
        local okPress, pressErr = pcall(function()
            mouse1press()
            task.wait(SPRINKLER_MOUSE_CLICK_DELAY)
            mouse1release()
        end)
        if okPress then
            return true, nil
        end
        sprinklerLog("mouse1press/mouse1release failed: " .. tostring(pressErr))
    end

    local okService, vim = pcall(function()
        return game:GetService("VirtualInputManager")
    end)
    if not okService or not vim then
        return false, "No executor mouse click functions and VirtualInputManager unavailable"
    end

    local firedOk, firedErr = pcall(function()
        task.wait(SPRINKLER_MOUSE_CLICK_DELAY)
        vim:SendMouseButtonEvent(x, y, 0, true, game, 1)
        task.wait(SPRINKLER_MOUSE_CLICK_DELAY)
        vim:SendMouseButtonEvent(x, y, 0, false, game, 1)
    end)
    if not firedOk then
        return false, tostring(firedErr)
    end

    return true, nil
end

local function activateSprinklerToolAtWorldPosition(tool, worldPosition)
    if not tool or not tool.Parent then
        return false, "Tool unavailable"
    end

    local moved, moveErr = moveMouseToWorldPosition(worldPosition)
    if not moved then
        return false, "Mouse move failed: " .. tostring(moveErr)
    end

    local okActivate, activateErr = pcall(function()
        tool:Activate()
    end)
    if not okActivate then
        return false, tostring(activateErr)
    end

    return true, nil
end

local function tryForcePlaceSingleSprinkler(parts, sprinklerTools)
    if type(parts) ~= "table" or #parts == 0 then
        return false, "No plot parts"
    end
    if type(sprinklerTools) ~= "table" or #sprinklerTools == 0 then
        return false, "No sprinkler tools"
    end

    local selectedToolEntry = nil
    for _, entry in ipairs(sprinklerTools) do
        if entry
            and entry.Tool
            and entry.Tool.Parent
            and isValidSprinklerTypeName(entry.SprinklerType)
            and (tonumber(entry.Range) or 0) > 0
            and getToolStackCount(entry.Tool) > 0
        then
            selectedToolEntry = entry
            break
        end
    end
    if not selectedToolEntry then
        return false, "No usable sprinkler tool"
    end

    local candidates = buildSprinklerCandidatePoints(parts, {})
    local preferred = {}
    local fallback = {}
    for _, candidatePosition in ipairs(candidates) do
        if typeof(candidatePosition) == "Vector3" then
            if not isPositionOccupied(candidatePosition) then
                preferred[#preferred + 1] = candidatePosition
            else
                fallback[#fallback + 1] = candidatePosition
            end
        end
    end
    if #preferred == 0 then
        preferred = fallback
    end
    if #preferred == 0 then
        return false, "No placement candidates"
    end

    local maxAttempts = math.min(24, #preferred)
    local lastReason = "Placement not confirmed"
    for index = 1, maxAttempts do
        local placed, reason = tryPlaceSprinkler(
            selectedToolEntry.Tool,
            selectedToolEntry.SprinklerType,
            preferred[index]
        )
        if placed then
            return true, nil
        end
        lastReason = tostring(reason or lastReason)
    end

    return false, lastReason
end

tryPlaceSprinkler = function(tool, sprinklerType, targetPosition)
    if not tool or not tool.Parent then
        return false, "Sprinkler tool no longer available"
    end
    if not isValidSprinklerTypeName(sprinklerType) then
        return false, "Invalid sprinkler type"
    end

    local equipped = equipTool(tool)
    if not equipped then
        return false, "Failed to equip sprinkler tool"
    end

    local _, plotParts = getOwnedPlotAndParts()
    local plantTargets = collectOwnedPlantTargetsForSprinklers(plotParts)
    local sprinklerRange = 0
    local sprinklerDefinition = SprinklerDefinitions[sprinklerType]
    if type(sprinklerDefinition) == "table" then
        sprinklerRange = tonumber(sprinklerDefinition.Range) or 0
    end
    local plantClearance = getSprinklerPlantClearance(sprinklerRange)
    local primaryPositions, fallbackPositions = buildSprinklerPlacementAttemptSets(
        plotParts,
        targetPosition,
        plantTargets,
        plantClearance
    )
    if #primaryPositions == 0 then
        local fallbackPosition = getGroundedSprinklerPosition(plotParts, targetPosition) or targetPosition
        if typeof(fallbackPosition) == "Vector3" then
            primaryPositions[1] = fallbackPosition
        end
    end
    if #primaryPositions == 0 and #fallbackPositions == 0 then
        return false, "No sprinkler placement positions available"
    end

    local function attemptPlacementAtPosition(placementPosition)
        local movedNearPlacement = moveNearSprinklerPlacement(plotParts, placementPosition)
        if not movedNearPlacement then
            return false, "Could not move near sprinkler placement"
        end

        local beforeStackCount = getToolStackCount(tool)
        local beforeActiveCount = getOwnedActiveSprinklerCount()
        local beforeTaggedCount = getOwnedTaggedSprinklerCount()
        local hadNearbySprinkler = hasOwnedSprinklerNearPosition(placementPosition, SPRINKLER_CONFIRM_NEAR_DISTANCE)

        local function placementConfirmed()
            local afterStackCount = getToolStackCount(tool)
            local afterActiveCount = getOwnedActiveSprinklerCount()
            local afterTaggedCount = getOwnedTaggedSprinklerCount()
            local hasNearbySprinklerNow = hasOwnedSprinklerNearPosition(placementPosition, SPRINKLER_CONFIRM_NEAR_DISTANCE)
            return afterTaggedCount > beforeTaggedCount
                or afterActiveCount > beforeActiveCount
                or afterStackCount < beforeStackCount
                or (not hadNearbySprinkler and hasNearbySprinklerNow)
        end

        local function waitForPlacementConfirmation(timeoutSeconds)
            local deadline = tick() + timeoutSeconds
            while tick() < deadline do
                task.wait(0.08)
                if placementConfirmed() then
                    return true
                end
            end
            return false
        end

        local fireReason = "Direct remote no confirm"
        for _ = 1, SPRINKLER_DIRECT_ATTEMPTS_PER_POSITION do
            local firedOk, firedErr = pcall(function()
                UseGearRemote:FireServer(sprinklerType, {
                    position = placementPosition
                })
            end)
            if not firedOk then
                fireReason = "Direct remote failed: " .. tostring(firedErr)
            else
                fireReason = "Direct remote no confirm"
                if waitForPlacementConfirmation(SPRINKLER_DIRECT_CONFIRM_TIMEOUT) then
                    return true, nil
                end
            end
            task.wait(0.05)
        end

        return false, fireReason
    end

    local lastReason = "Placement not confirmed"
    for _, attemptPosition in ipairs(primaryPositions) do
        local placed, reason = attemptPlacementAtPosition(attemptPosition)
        if placed then
            sprinklerLog("Placement confirmed via direct remote (planned offset)")
            return true, nil
        end
        lastReason = tostring(reason or lastReason)
    end

    for _, fallbackPosition in ipairs(fallbackPositions) do
        local placed, reason = attemptPlacementAtPosition(fallbackPosition)
        if placed then
            sprinklerLog("Placement confirmed via direct remote (fallback offset)")
            return true, nil
        end
        lastReason = tostring(reason or lastReason)
    end

    return false, lastReason
end

local function tryPlantAtPosition(plantType, worldPosition)
    local lastReason = "unknown"
    for _, offset in ipairs(JITTER_OFFSETS) do
        local targetPosition = worldPosition + offset
        local occupied = isPositionOccupied(targetPosition)
        local inRange = ensureInPlantRange(targetPosition)
        if not occupied and inRange then
            for _ = 1, RETRIES_PER_POSITION do
                local success, reasonA, reasonB = safeInvoke(PlantSeedRemote, plantType, targetPosition)
                if success then
                    return true, nil
                end

                lastReason = tostring(reasonA or reasonB or "rejected")
                if string.find(string.lower(lastReason), "far away", 1, true) then
                    ensureInPlantRange(targetPosition)
                end
                task.wait(RETRY_DELAY)
            end
        elseif not inRange then
            lastReason = "Could not move into plant range"
        end
    end
    return false, lastReason
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

local AutoPlantFeature = {
    Name = "AutoPlant",
    Enabled = Hub.Config.AutoPlant.Enabled,
    _running = false,
    _thread = nil,
    _planted = 0,
    _failed = 0,
    _lastFailReason = "none",
    _statusText = "Idle"
}

function AutoPlantFeature:_setStatus(text)
    self._statusText = text
    queueUILabelUpdate("AutoPlant", text)
end

function AutoPlantFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self:_setStatus("Auto Plant: Disabled")
    else
        self:_setStatus("Auto Plant: Enabled")
    end
end

function AutoPlantFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local plot, parts = waitForPlotAndParts(PLOT_WAIT_TIMEOUT)
    if not plot or #parts == 0 then
        self:_setStatus("Auto Plant: Waiting for owned plot...")
        return
    end

    local teleported, teleportReason = teleportToGarden()
    if not teleported then
        self:_setStatus("Auto Plant: Garden TP failed (" .. tostring(teleportReason) .. ")")
        return
    end

    local positions = buildSprinklerFriendlyPlantOrder(parts)
    if #positions == 0 then
        self:_setStatus("Auto Plant: No candidate positions")
        return
    end

    local seedEntries = collectSeedTools()
    local seedEntry = getNextAvailableSeed(seedEntries)
    if not seedEntry then
        self:_setStatus("Auto Plant: No seed tools available")
        return
    end

    local equippedTool = nil
    local passPlanted = 0
    local passFailed = 0
    local passLastFail = "none"

    for _, targetPosition in ipairs(positions) do
        if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            break
        end

        if isPositionOccupied(targetPosition) then
            -- Spot is already used by an existing plant.
        else
            seedEntry = getNextAvailableSeed(seedEntries)
            if not seedEntry then
                seedEntries = collectSeedTools()
                seedEntry = getNextAvailableSeed(seedEntries)
            end

            if not seedEntry then
                break
            end

            local equipped = true
            if equippedTool ~= seedEntry.Tool then
                equipped = equipTool(seedEntry.Tool)
                if equipped then
                    equippedTool = seedEntry.Tool
                end
            end

            if not equipped then
                passFailed = passFailed + 1
                passLastFail = "Failed to equip " .. tostring(seedEntry.Tool.Name)
            else
                local success, reason = tryPlantAtPosition(seedEntry.PlantType, targetPosition)
                if success then
                    passPlanted = passPlanted + 1
                    task.wait(PLANT_DELAY)
                else
                    passFailed = passFailed + 1
                    passLastFail = tostring(reason or "unknown")
                end
            end
        end
    end

    self._planted = self._planted + passPlanted
    self._failed = self._failed + passFailed
    if passLastFail ~= "none" then
        self._lastFailReason = passLastFail
    elseif passPlanted > 0 then
        self._lastFailReason = "none"
    end

    local remainingSeed = getNextAvailableSeed(collectSeedTools())
    if passPlanted > 0 then
        self:_setStatus(
            string.format(
                "Auto Plant: Pass=%d Total=%d Failed=%d",
                passPlanted,
                self._planted,
                self._failed
            )
        )
    elseif not remainingSeed then
        self:_setStatus(
            string.format(
                "Auto Plant: No seeds (Planted=%d Failed=%d)",
                self._planted,
                self._failed
            )
        )
    elseif passFailed > 0 then
        self:_setStatus(
            string.format(
                "Auto Plant: Pass=0 Failed=%d LastFail=%s",
                passFailed,
                self._lastFailReason
            )
        )
    else
        self:_setStatus(
            string.format(
                "Auto Plant: Plot looks full (Planted=%d Failed=%d)",
                self._planted,
                self._failed
            )
        )
    end
end

function AutoPlantFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self:_setStatus("Auto Plant: Starting...")
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self._failed = self._failed + 1
                self._lastFailReason = tostring(err)
                self:_setStatus("Auto Plant: Error - " .. tostring(err))
            end
            task.wait(PASS_LOOP_DELAY)
        end
    end)
end

function AutoPlantFeature:Stop()
    self._running = false
    self._thread = nil
    self:_setStatus("Auto Plant: Stopped")
end

replaceFeature("AutoPlant", AutoPlantFeature)

local AutoBuySeedsFeature = {
    Name = "AutoBuySeeds",
    Enabled = Hub.Config.AutoBuySeeds.Enabled,
    _running = false,
    _thread = nil,
    _purchased = 0,
    _failed = 0,
    _lastFailReason = "none",
    _statusText = "Auto Buy Seeds: Idle"
}

function AutoBuySeedsFeature:_setStatus(text)
    self._statusText = text
    queueUILabelUpdate("AutoBuySeeds", text)
end

function AutoBuySeedsFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self:_setStatus("Auto Buy Seeds: Disabled")
    else
        self:_setStatus(string.format("Auto Buy Seeds: Enabled (%d selected)", getSelectedSeedCount()))
    end
end

function AutoBuySeedsFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local selectedSeedNames = getSelectedSeedNamesOrdered()
    if #selectedSeedNames == 0 then
        self:_setStatus("Auto Buy Seeds: No seeds selected")
        return
    end

    local teleported, teleportReason = teleportToSeeds()
    if not teleported then
        self:_setStatus("Auto Buy Seeds: Seed TP failed (" .. tostring(teleportReason) .. ")")
        return
    end

    local shopData, fetchError = fetchSeedShopDataSnapshot()
    if not shopData then
        updateSeedStockStatus(nil, fetchError)
        self:_setStatus("Auto Buy Seeds: Could not fetch shop data (" .. tostring(fetchError) .. ")")
        return
    end
    updateSeedStockStatus(shopData, nil)

    local purchasedThisTick = 0
    local failedThisTick = 0
    local outOfStockCount = 0
    local lastFailReason = "none"
    local stopNow = false

    for _, shopItemName in ipairs(selectedSeedNames) do
        if stopNow
            or purchasedThisTick >= AUTO_BUY_MAX_PURCHASES_PER_TICK
            or not self.Enabled
            or Hub.IsUnloaded
            or Hub.RunId ~= CurrentRunId
        then
            break
        end

        local stockAmount = getSeedShopStockAmount(shopData, shopItemName)
        if stockAmount <= 0 then
            outOfStockCount = outOfStockCount + 1
        else
            local maxBuysForItem = math.min(stockAmount, AUTO_BUY_MAX_PURCHASES_PER_TICK - purchasedThisTick)
            for _ = 1, maxBuysForItem do
                if stopNow
                    or purchasedThisTick >= AUTO_BUY_MAX_PURCHASES_PER_TICK
                    or not self.Enabled
                    or Hub.IsUnloaded
                    or Hub.RunId ~= CurrentRunId
                then
                    break
                end

                local purchaseOk, purchaseError, updatedShopData = purchaseSeedShopItem(shopItemName)
                if purchaseOk then
                    purchasedThisTick = purchasedThisTick + 1
                    if type(updatedShopData) == "table" then
                        shopData = updatedShopData
                    else
                        local itemState = shopData.Items and shopData.Items[shopItemName]
                        if type(itemState) == "table" then
                            local currentAmount = tonumber(itemState.Amount) or 0
                            itemState.Amount = math.max(0, currentAmount - 1)
                        end
                    end
                else
                    failedThisTick = failedThisTick + 1
                    lastFailReason = tostring(purchaseError or "unknown")
                    if shouldStopAutoBuyForReason(lastFailReason) then
                        stopNow = true
                    end
                end

                task.wait(AUTO_BUY_PURCHASE_DELAY)
            end
        end
    end

    self._purchased = self._purchased + purchasedThisTick
    self._failed = self._failed + failedThisTick
    updateSeedStockStatus(shopData, nil)
    if failedThisTick > 0 then
        self._lastFailReason = lastFailReason
    elseif purchasedThisTick > 0 then
        self._lastFailReason = "none"
    end

    if purchasedThisTick > 0 then
        self:_setStatus(
            string.format(
                "Auto Buy Seeds: Bought=%d Total=%d Failed=%d Selected=%d",
                purchasedThisTick,
                self._purchased,
                self._failed,
                #selectedSeedNames
            )
        )
        return
    end

    if failedThisTick > 0 then
        self:_setStatus(
            string.format(
                "Auto Buy Seeds: Failed=%d LastFail=%s",
                failedThisTick,
                self._lastFailReason
            )
        )
        return
    end

    if outOfStockCount >= #selectedSeedNames then
        self:_setStatus("Auto Buy Seeds: Selected seeds are out of stock")
        return
    end

    self:_setStatus("Auto Buy Seeds: Nothing to buy right now")
end

function AutoBuySeedsFeature:Start()
    if self._running then
        return
    end
    self._running = true
    self:_setStatus(self._statusText)
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self._failed = self._failed + 1
                self._lastFailReason = tostring(err)
                self:_setStatus("Auto Buy Seeds: Error - " .. tostring(err))
            end
            task.wait(AUTO_BUY_LOOP_DELAY)
        end
    end)
end

function AutoBuySeedsFeature:Stop()
    self._running = false
    self._thread = nil
    self:_setStatus("Auto Buy Seeds: Stopped")
end

replaceFeature("AutoBuySeeds", AutoBuySeedsFeature)

local AutoBuyGearsFeature = {
    Name = "AutoBuyGears",
    Enabled = Hub.Config.AutoBuyGears.Enabled,
    _running = false,
    _thread = nil,
    _purchased = 0,
    _failed = 0,
    _lastFailReason = "none",
    _statusText = "Auto Buy Gears: Idle"
}

function AutoBuyGearsFeature:_setStatus(text)
    self._statusText = text
    queueUILabelUpdate("AutoBuyGears", text)
end

function AutoBuyGearsFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self:_setStatus("Auto Buy Gears: Disabled")
    else
        self:_setStatus(string.format("Auto Buy Gears: Enabled (%d selected)", getSelectedGearCount()))
    end
end

function AutoBuyGearsFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local selectedGearNames = getSelectedGearNamesOrdered()
    if #selectedGearNames == 0 then
        self:_setStatus("Auto Buy Gears: No gears selected")
        return
    end

    local teleported, teleportReason = teleportToShop()
    if not teleported then
        self:_setStatus("Auto Buy Gears: Shop TP failed (" .. tostring(teleportReason) .. ")")
        return
    end

    local shopData, fetchError = fetchGearShopDataSnapshot()
    if not shopData then
        updateGearStockStatus(nil, fetchError)
        self:_setStatus("Auto Buy Gears: Could not fetch shop data (" .. tostring(fetchError) .. ")")
        return
    end
    updateGearStockStatus(shopData, nil)

    local purchasedThisTick = 0
    local failedThisTick = 0
    local outOfStockCount = 0
    local lastFailReason = "none"
    local stopNow = false

    for _, shopItemName in ipairs(selectedGearNames) do
        if stopNow
            or purchasedThisTick >= AUTO_BUY_MAX_PURCHASES_PER_TICK
            or not self.Enabled
            or Hub.IsUnloaded
            or Hub.RunId ~= CurrentRunId
        then
            break
        end

        local stockAmount = getGearShopStockAmount(shopData, shopItemName)
        if stockAmount <= 0 then
            outOfStockCount = outOfStockCount + 1
        else
            local maxBuysForItem = math.min(stockAmount, AUTO_BUY_MAX_PURCHASES_PER_TICK - purchasedThisTick)
            for _ = 1, maxBuysForItem do
                if stopNow
                    or purchasedThisTick >= AUTO_BUY_MAX_PURCHASES_PER_TICK
                    or not self.Enabled
                    or Hub.IsUnloaded
                    or Hub.RunId ~= CurrentRunId
                then
                    break
                end

                local purchaseOk, purchaseError, updatedShopData = purchaseGearShopItem(shopItemName)
                if purchaseOk then
                    purchasedThisTick = purchasedThisTick + 1
                    if type(updatedShopData) == "table" then
                        shopData = updatedShopData
                    else
                        local itemState = shopData.Items and shopData.Items[shopItemName]
                        if type(itemState) == "table" then
                            local currentAmount = tonumber(itemState.Amount) or 0
                            itemState.Amount = math.max(0, currentAmount - 1)
                        end
                    end
                else
                    failedThisTick = failedThisTick + 1
                    lastFailReason = tostring(purchaseError or "unknown")
                    if shouldStopAutoBuyForReason(lastFailReason) then
                        stopNow = true
                    end
                end

                task.wait(AUTO_BUY_PURCHASE_DELAY)
            end
        end
    end

    self._purchased = self._purchased + purchasedThisTick
    self._failed = self._failed + failedThisTick
    updateGearStockStatus(shopData, nil)
    if failedThisTick > 0 then
        self._lastFailReason = lastFailReason
    elseif purchasedThisTick > 0 then
        self._lastFailReason = "none"
    end

    if purchasedThisTick > 0 then
        self:_setStatus(
            string.format(
                "Auto Buy Gears: Bought=%d Total=%d Failed=%d Selected=%d",
                purchasedThisTick,
                self._purchased,
                self._failed,
                #selectedGearNames
            )
        )
        return
    end

    if failedThisTick > 0 then
        self:_setStatus(
            string.format(
                "Auto Buy Gears: Failed=%d LastFail=%s",
                failedThisTick,
                self._lastFailReason
            )
        )
        return
    end

    if outOfStockCount >= #selectedGearNames then
        self:_setStatus("Auto Buy Gears: Selected gears are out of stock")
        return
    end

    self:_setStatus("Auto Buy Gears: Nothing to buy right now")
end

function AutoBuyGearsFeature:Start()
    if self._running then
        return
    end
    self._running = true
    self:_setStatus(self._statusText)
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self._failed = self._failed + 1
                self._lastFailReason = tostring(err)
                self:_setStatus("Auto Buy Gears: Error - " .. tostring(err))
            end
            task.wait(AUTO_BUY_LOOP_DELAY)
        end
    end)
end

function AutoBuyGearsFeature:Stop()
    self._running = false
    self._thread = nil
    self:_setStatus("Auto Buy Gears: Stopped")
end

replaceFeature("AutoBuyGears", AutoBuyGearsFeature)

Hub.AutoBotanistFeature = {
    Name = "AutoBotanist",
    Enabled = Hub.Config.AutoBotanist.Enabled,
    _running = false,
    _thread = nil,
    _statusText = "Auto Botanist: Idle",
    _completed = 0,
    _donated = 0,
    _harvested = 0,
    _failed = 0,
    _lastFailReason = "none",
    _lastQuestAt = 0,
    _lastAppraiseAt = 0,
    _questMutation = nil,
    _questTargetWeight = 0,
    _questTotalWeight = 0,
    _acceptedMutationMap = {}
}

function Hub.AutoBotanistFeature:_setStatus(text)
    self._statusText = text
    queueUILabelUpdate("AutoBotanist", text)
end

function Hub.AutoBotanistFeature:_getQuestRemote()
    return RemoteEvents:FindFirstChild("BotanistQuestRequest")
end

function Hub.AutoBotanistFeature:_getAppraiseRemote()
    return RemoteEvents:FindFirstChild("BotanistRequest")
end

function Hub.AutoBotanistFeature:_teleportToBotanist(force)
    return teleportByResolver("Botanist", function()
        local botanistRoot = findChildByPath(getMapPhysical(), {
            "Botanist",
            "Botanist",
            "HumanoidRootPart"
        })
        if botanistRoot and botanistRoot:IsA("BasePart") then
            return botanistRoot.CFrame
        end
        return nil
    end, force, function(targetCFrame)
        return isNearTargetCFrame(targetCFrame, TELEPORT_ZONE_RADIUS_SHOP)
    end)
end

function Hub.AutoBotanistFeature:_invokeQuest(action)
    local questRemote = self:_getQuestRemote()
    if not questRemote then
        return nil, "quest remote missing"
    end

    local response, err = safeInvoke(questRemote, action)
    if response == false then
        return nil, tostring(err or "invoke failed")
    end
    if type(response) ~= "table" then
        return nil, "unexpected response"
    end
    return response
end

function Hub.AutoBotanistFeature:_invokeAppraise()
    local appraiseRemote = self:_getAppraiseRemote()
    if not appraiseRemote then
        return nil, "appraise remote missing"
    end

    local response, err = safeInvoke(appraiseRemote)
    if response == false then
        return nil, tostring(err or "invoke failed")
    end
    if type(response) ~= "table" then
        return nil, "unexpected response"
    end
    return response
end

function Hub.AutoBotanistFeature:_splitMutationList(rawText)
    local list = {}
    if type(rawText) ~= "string" then
        return list
    end

    for mutationToken in string.gmatch(rawText, "([^,]+)") do
        local mutation = mutationToken:match("^%s*(.-)%s*$")
        if mutation ~= "" then
            list[#list + 1] = mutation
        end
    end

    if #list == 0 and rawText ~= "" then
        list[1] = rawText
    end
    return list
end

function Hub.AutoBotanistFeature:_buildAcceptedMutationMap(questMutation)
    local accepted = {}
    local mutation = type(questMutation) == "string" and questMutation or nil
    if not mutation or mutation == "" then
        return accepted
    end

    accepted[mutation] = true
    local questDefinitions = BotanistDefinitions and BotanistDefinitions.MutationQuests
    local questDefinition = type(questDefinitions) == "table" and questDefinitions[mutation] or nil
    local acceptedMutations = questDefinition and questDefinition.AcceptedMutations
    if type(acceptedMutations) == "table" then
        for _, acceptedMutation in ipairs(acceptedMutations) do
            if type(acceptedMutation) == "string" and acceptedMutation ~= "" then
                accepted[acceptedMutation] = true
            end
        end
    end

    local legacyMap = BotanistDefinitions and BotanistDefinitions.LegacyQuestMap
    if type(legacyMap) == "table" then
        local mappedMutation = legacyMap[mutation]
        if type(mappedMutation) == "string" and mappedMutation ~= "" then
            accepted[mappedMutation] = true
        end
        for oldMutation, normalizedMutation in pairs(legacyMap) do
            if normalizedMutation == mutation and type(oldMutation) == "string" and oldMutation ~= "" then
                accepted[oldMutation] = true
            end
        end
    end

    return accepted
end

function Hub.AutoBotanistFeature:_mutationMatchesAccepted(rawMutation)
    if type(self._acceptedMutationMap) ~= "table" or next(self._acceptedMutationMap) == nil then
        return false
    end

    local mutations = self:_splitMutationList(rawMutation or "")
    for _, mutation in ipairs(mutations) do
        if self._acceptedMutationMap[mutation] == true then
            return true
        end
    end
    return false
end

function Hub.AutoBotanistFeature:_refreshQuestState(response)
    local status = tostring(response and response.Status or "unknown")

    if status == "new_quest" or status == "quest_reminder" or status == "progress" then
        self._questMutation = tostring(response.Mutation or self._questMutation or "")
        self._questTargetWeight = tonumber(response.TargetWeight) or self._questTargetWeight or 0
        self._questTotalWeight = tonumber(response.TotalWeight) or self._questTotalWeight or 0
    elseif status == "complete" then
        local newQuest = type(response.NewQuest) == "table" and response.NewQuest or nil
        if newQuest then
            self._questMutation = tostring(newQuest.Mutation or "")
            self._questTargetWeight = tonumber(newQuest.TargetWeight) or 0
            self._questTotalWeight = tonumber(newQuest.TotalWeight) or 0
        else
            self._questMutation = self._questMutation or ""
            self._questTotalWeight = self._questTargetWeight
        end
    elseif status == "no_active_quest" then
        self._questMutation = nil
        self._questTargetWeight = 0
        self._questTotalWeight = 0
    end

    if type(self._questMutation) == "string" and self._questMutation ~= "" then
        self._acceptedMutationMap = self:_buildAcceptedMutationMap(self._questMutation)
    else
        self._acceptedMutationMap = {}
    end
end

function Hub.AutoBotanistFeature:_remainingQuestWeight()
    local targetWeight = math.max(0, tonumber(self._questTargetWeight) or 0)
    local totalWeight = math.max(0, tonumber(self._questTotalWeight) or 0)
    return math.max(0, targetWeight - totalWeight)
end

function Hub.AutoBotanistFeature:_collectMatchingHarvestedTools()
    local tools = {}

    local function collect(container)
        if not container then
            return
        end

        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and tool:GetAttribute("IsHarvested") and not tool:GetAttribute("IsCrate") then
                local rawMutation = tool:GetAttribute("Mutation")
                local hasKnownMutation = type(rawMutation) == "string" and rawMutation ~= ""
                local isAcceptedMutation = hasKnownMutation and self:_mutationMatchesAccepted(rawMutation)
                if isAcceptedMutation or not hasKnownMutation then
                    tools[#tools + 1] = {
                        Tool = tool,
                        Accepted = isAcceptedMutation
                    }
                end
            end
        end
    end

    collect(LocalPlayer.Character)
    collect(LocalPlayer:FindFirstChildOfClass("Backpack"))

    table.sort(tools, function(a, b)
        if a.Accepted ~= b.Accepted then
            return a.Accepted == true
        end
        return tostring(a.Tool.Name) < tostring(b.Tool.Name)
    end)

    return tools
end

function Hub.AutoBotanistFeature:_donateSingleMatchingTool()
    local matchingTools = self:_collectMatchingHarvestedTools()
    if #matchingTools == 0 then
        return false, "no_matching_tool"
    end

    for _, entry in ipairs(matchingTools) do
        local tool = entry.Tool
        if not tool or not tool.Parent then
            continue
        end

        local equipped = equipTool(tool)
        if not equipped then
            continue
        end

        local response, err = self:_invokeQuest("TurnInSingle")
        if not response then
            return false, tostring(err or "TurnInSingle failed")
        end

        local donateStatus = tostring(response.Status or "unknown")
        self:_refreshQuestState(response)

        if donateStatus == "progress" or donateStatus == "complete" then
            self._donated = self._donated + 1
            if donateStatus == "complete" then
                self._completed = self._completed + 1
            end
            self._lastFailReason = "none"
            return true, donateStatus, response
        end

        if donateStatus == "no_tool"
            or donateStatus == "not_harvested"
            or donateStatus == "favorited"
            or donateStatus == "no_mutation"
            or donateStatus == "unknown_mutation"
            or donateStatus == "wrong_mutation"
        then
            continue
        end

        return false, donateStatus, response
    end

    return false, "no_usable_tool"
end

function Hub.AutoBotanistFeature:_harvestSingleMatchingCrop()
    if type(self._questMutation) ~= "string" or self._questMutation == "" then
        return false, "no_active_quest"
    end

    local candidates = collectOwnedHarvestCandidates({
        IgnorePlantTypeFilter = true,
        IgnoreStageFilter = true,
        CustomFilter = function(_, _, _, _, mutation)
            return self:_mutationMatchesAccepted(mutation)
        end
    })

    if #candidates == 0 then
        local teleported, teleportReason = teleportToGarden()
        if not teleported then
            return false, "Garden TP failed (" .. tostring(teleportReason or "unknown") .. ")"
        end

        candidates = collectOwnedHarvestCandidates({
            IgnorePlantTypeFilter = true,
            IgnoreStageFilter = true,
            CustomFilter = function(_, _, _, _, mutation)
                return self:_mutationMatchesAccepted(mutation)
            end
        })
    end

    if #candidates == 0 then
        return false, "no matching quest crops"
    end

    local target = candidates[1]
    local targetPosition = target.Position or getPlantPosition(target.TargetModel)
    if not targetPosition then
        return false, "target position unavailable"
    end

    local movedClose = ensureInHarvestRange(targetPosition)
    if not movedClose then
        return false, "could not move into harvest range"
    end

    local sentOk, sentErr = pcall(function()
        HarvestFruitRemote:FireServer({ target.Payload })
    end)
    if not sentOk then
        return false, tostring(sentErr or "harvest remote failed")
    end

    self._harvested = self._harvested + 1
    local targetModel = target.TargetModel
    if targetModel and targetModel.Parent then
        targetModel:SetAttribute("IsHarvested", true)
        task.delay(3, function()
            if targetModel and targetModel.Parent then
                targetModel:SetAttribute("IsHarvested", nil)
            end
        end)
    end

    return true, target
end

function Hub.AutoBotanistFeature:_getHeldHarvestedTool()
    local character = LocalPlayer.Character
    local equippedTool = character and character:FindFirstChildOfClass("Tool")
    if equippedTool and equippedTool:GetAttribute("IsHarvested") then
        return equippedTool
    end
    return nil
end

function Hub.AutoBotanistFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self._questMutation = nil
        self._questTargetWeight = 0
        self._questTotalWeight = 0
        self._acceptedMutationMap = {}
        self:_setStatus("Auto Botanist: Disabled")
        return
    end

    local modeParts = {}
    if Hub.Config.AutoBotanist.AutoRequestQuest then
        table.insert(modeParts, "GetQuest")
    end
    if Hub.Config.AutoBotanist.AutoDonateAll then
        table.insert(modeParts, "QuestLoop")
    end
    if Hub.Config.AutoBotanist.AutoAppraiseHeld then
        table.insert(modeParts, "AppraiseHeld")
    end
    if #modeParts <= 0 then
        table.insert(modeParts, "Idle")
    end
    self:_setStatus("Auto Botanist: Enabled (" .. table.concat(modeParts, ", ") .. ")")
end

function Hub.AutoBotanistFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local now = tick()
    if (Hub.Config.AutoBotanist.AutoRequestQuest or not self._questMutation)
        and now - (self._lastQuestAt or 0) >= 6
    then
        self._lastQuestAt = now
        local questResponse, questError = self:_invokeQuest("GetQuest")
        if not questResponse then
            self._failed = self._failed + 1
            self._lastFailReason = tostring(questError or "GetQuest failed")
            self:_setStatus("Auto Botanist: GetQuest failed (" .. self._lastFailReason .. ")")
            return
        end

        self:_refreshQuestState(questResponse)
        local questStatus = tostring(questResponse.Status or "unknown")
        if questStatus == "new_quest" then
            self:_setStatus(
                string.format(
                    "Auto Botanist: New quest %s %.2fkg (Need %.2fkg)",
                    tostring(questResponse.Mutation or "?"),
                    tonumber(questResponse.TargetWeight) or 0,
                    self:_remainingQuestWeight()
                )
            )
        elseif questStatus == "quest_reminder" then
            self:_setStatus(
                string.format(
                    "Auto Botanist: Quest %s %.2f/%.2fkg",
                    tostring(questResponse.Mutation or "?"),
                    tonumber(questResponse.TotalWeight) or 0,
                    tonumber(questResponse.TargetWeight) or 0
                )
            )
        elseif questStatus == "no_active_quest" then
            if Hub.Config.AutoBotanist.TeleportToBotanist then
                local teleported, teleportReason = self:_teleportToBotanist(false)
                if not teleported then
                    self:_setStatus("Auto Botanist: No active quest (TP failed: " .. tostring(teleportReason or "unknown") .. ")")
                else
                    self:_setStatus("Auto Botanist: No active quest (TPed to Botanist)")
                end
            else
                self:_setStatus("Auto Botanist: No active quest")
            end
            return
        elseif questStatus ~= "error" and questStatus ~= "no_active_quest" then
            self:_setStatus("Auto Botanist: Quest status - " .. questStatus)
        end
    end

    if Hub.Config.AutoBotanist.AutoDonateAll then
        if type(self._questMutation) ~= "string" or self._questMutation == "" then
            self:_setStatus("Auto Botanist: No active quest")
            return
        end

        local donateCount = 0
        local lastDonateStatus = nil
        for _ = 1, 4 do
            if self:_remainingQuestWeight() <= 0 then
                break
            end

            local donated, donateStatus, donateResponse = self:_donateSingleMatchingTool()
            lastDonateStatus = donateStatus
            if donated then
                donateCount = donateCount + 1
                if donateStatus == "complete" then
                    self:_setStatus(
                        string.format(
                            "Auto Botanist: Quest complete (%sx %s) Completed=%d Donated=%d Harvested=%d",
                            tostring(tonumber(donateResponse.RewardCount) or 0),
                            tostring(donateResponse.RewardName or "reward"),
                            self._completed,
                            self._donated,
                            self._harvested
                        )
                    )
                    return
                end
            else
                if donateStatus == "no_matching_tool" or donateStatus == "no_usable_tool" then
                    break
                end
                if donateStatus == "no_active_quest" then
                    if Hub.Config.AutoBotanist.TeleportToBotanist then
                        local teleported, teleportReason = self:_teleportToBotanist(false)
                        if not teleported then
                            self:_setStatus("Auto Botanist: No active quest (TP failed: " .. tostring(teleportReason or "unknown") .. ")")
                        else
                            self:_setStatus("Auto Botanist: No active quest (TPed to Botanist)")
                        end
                    else
                        self:_setStatus("Auto Botanist: No active quest")
                    end
                    return
                end
                if donateStatus == "inventory_full" then
                    self:_setStatus("Auto Botanist: Inventory full for reward")
                    return
                end
                if donateStatus == "error" then
                    self._failed = self._failed + 1
                    self._lastFailReason = "TurnInSingle error"
                    self:_setStatus("Auto Botanist: Donate failed (" .. self._lastFailReason .. ")")
                    return
                end
                break
            end
        end

        if self:_remainingQuestWeight() > 0 then
            local harvested, harvestInfo = self:_harvestSingleMatchingCrop()
            if harvested then
                local target = harvestInfo
                self._lastFailReason = "none"
                self:_setStatus(
                    string.format(
                        "Auto Botanist: Harvested %s (%s). Quest %s %.2f/%.2fkg",
                        tostring(target.PlantType or "crop"),
                        tostring((type(target.Mutation) == "string" and target.Mutation ~= "") and target.Mutation or "?"),
                        tostring(self._questMutation or "?"),
                        tonumber(self._questTotalWeight) or 0,
                        tonumber(self._questTargetWeight) or 0
                    )
                )
                return
            end

            if donateCount > 0 then
                self:_setStatus(
                    string.format(
                        "Auto Botanist: Donated=%d Quest %s %.2f/%.2fkg",
                        donateCount,
                        tostring(self._questMutation or "?"),
                        tonumber(self._questTotalWeight) or 0,
                        tonumber(self._questTargetWeight) or 0
                    )
                )
                return
            end

            self:_setStatus(
                string.format(
                    "Auto Botanist: Waiting for %s crops (%s)",
                    tostring(self._questMutation or "?"),
                    tostring(harvestInfo or lastDonateStatus or "none")
                )
            )
            return
        else
            self._lastFailReason = "none"
            self:_setStatus(
                string.format(
                    "Auto Botanist: Quest target reached, syncing... %s %.2f/%.2fkg",
                    tostring(self._questMutation or "?"),
                    tonumber(self._questTotalWeight) or 0,
                    tonumber(self._questTargetWeight) or 0
                )
            )
            return
        end
    end

    if Hub.Config.AutoBotanist.AutoAppraiseHeld
        and now - (self._lastAppraiseAt or 0) >= 3
        and self:_getHeldHarvestedTool()
    then
        self._lastAppraiseAt = now
        local appraiseResponse, appraiseError = self:_invokeAppraise()
        if not appraiseResponse then
            self._failed = self._failed + 1
            self._lastFailReason = tostring(appraiseError or "appraise failed")
            self:_setStatus("Auto Botanist: Appraise failed (" .. self._lastFailReason .. ")")
            return
        end

        local appraiseStatus = tostring(appraiseResponse.Status or "unknown")
        if appraiseStatus == "success" then
            self._lastFailReason = "none"
            self:_setStatus("Auto Botanist: Appraised mutation " .. tostring(appraiseResponse.Mutation or "?"))
            return
        end
        if appraiseStatus == "insufficient_funds" then
            self:_setStatus("Auto Botanist: Appraise skipped (insufficient funds)")
            return
        end
        if appraiseStatus == "no_tool" then
            self:_setStatus("Auto Botanist: Equip harvested crop for appraise")
            return
        end
        if appraiseStatus ~= "error" then
            self:_setStatus("Auto Botanist: Appraise status - " .. appraiseStatus)
            return
        end
    end

    if type(self._questMutation) == "string" and self._questMutation ~= "" then
        self:_setStatus(
            string.format(
                "Auto Botanist: Quest %s %.2f/%.2fkg",
                tostring(self._questMutation),
                tonumber(self._questTotalWeight) or 0,
                tonumber(self._questTargetWeight) or 0
            )
        )
        return
    end

    self:_setStatus("Auto Botanist: Waiting for quest")
end

function Hub.AutoBotanistFeature:Start()
    if self._running then
        return
    end
    self._running = true
    self:_setStatus(self._statusText)
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self._failed = self._failed + 1
                self._lastFailReason = tostring(err)
                self:_setStatus("Auto Botanist: Error - " .. tostring(err))
            end
            task.wait(AUTO_BUY_LOOP_DELAY)
        end
    end)
end

function Hub.AutoBotanistFeature:Stop()
    self._running = false
    self._thread = nil
    self:_setStatus("Auto Botanist: Stopped")
end

replaceFeature("AutoBotanist", Hub.AutoBotanistFeature)

local AutoSprinklerFeature = {
    Name = "AutoSprinkler",
    Enabled = Hub.Config.AutoSprinkler.Enabled,
    _running = false,
    _thread = nil,
    _placed = 0,
    _failed = 0,
    _lastFailReason = "none",
    _statusText = "Smart Sprinkler: Idle"
}

function AutoSprinklerFeature:_setStatus(text)
    self._statusText = text
    queueUILabelUpdate("AutoSprinkler", text)
end

function AutoSprinklerFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self:_setStatus("Smart Sprinkler: Disabled")
    else
        self:_setStatus("Smart Sprinkler: Enabled")
    end
end

function AutoSprinklerFeature:Tick(forceRun)
    local isForced = forceRun == true
    if (not self.Enabled and not isForced) or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        if isForced then
            sprinklerLog("Manual tick blocked: enabled=" .. tostring(self.Enabled) .. " unloaded=" .. tostring(Hub.IsUnloaded))
        end
        return
    end

    if isForced then
        sprinklerLog("Manual tick started")
    end

    local plot, parts = waitForPlotAndParts(PLOT_WAIT_TIMEOUT)
    if not plot or #parts == 0 then
        self:_setStatus("Smart Sprinkler: Waiting for owned plot...")
        sprinklerLog("No owned plot/parts found")
        return
    end

    local sprinklerTools = collectSprinklerTools()
    if #sprinklerTools == 0 then
        self:_setStatus("Smart Sprinkler: No sprinkler tools found")
        sprinklerLog("No sprinkler tools found")
        return
    end
    sprinklerLog("Tools found: " .. tostring(#sprinklerTools))

    local teleported, teleportReason = teleportToGarden()
    if not teleported then
        self._failed = self._failed + 1
        self._lastFailReason = tostring(teleportReason or "unknown")
        self:_setStatus("Smart Sprinkler: Garden TP failed (" .. self._lastFailReason .. ")")
        sprinklerLog("Teleport failed: " .. tostring(self._lastFailReason))
        return
    end

    local placements, newCoverage, targetCount = buildSmartSprinklerPlan(
        plot,
        parts,
        sprinklerTools,
        AUTO_SPRINKLER_MAX_PER_TICK
    )
    sprinklerLog(
        string.format(
            "Plan: placements=%d newCoverage=%d targets=%d",
            #placements,
            tonumber(newCoverage) or 0,
            tonumber(targetCount) or 0
        )
    )
    if #placements == 0 then
        if targetCount <= 0 then
            self:_setStatus("Smart Sprinkler: No plants found for coverage")
            sprinklerLog("No targets for sprinkler coverage")
        else
            local onPlotSprinklers = getOwnedActiveSprinklers(parts)
            if #onPlotSprinklers <= 0 then
                local forcedPlaced, forceReason = tryForcePlaceSingleSprinkler(parts, sprinklerTools)
                if forcedPlaced then
                    self._placed = self._placed + 1
                    self._lastFailReason = "none"
                    self:_setStatus(
                        string.format(
                            "Smart Sprinkler: Placed=1 Total=%d Failed=%d (Forced placement)",
                            self._placed,
                            self._failed
                        )
                    )
                    sprinklerLog("Forced placement succeeded")
                    return
                end

                self._failed = self._failed + 1
                self._lastFailReason = tostring(forceReason or "forced placement failed")
                self:_setStatus(
                    string.format(
                        "Smart Sprinkler: Failed=%d LastFail=%s (NoOnPlotSprinklers Targets=%d)",
                        1,
                        self._lastFailReason,
                        targetCount
                    )
                )
                sprinklerLog("Forced placement failed: " .. tostring(self._lastFailReason))
                return
            end

            self:_setStatus(
                string.format(
                    "Smart Sprinkler: Existing coverage already good (Sprinklers=%d Targets=%d)",
                    #onPlotSprinklers,
                    targetCount
                )
            )
            sprinklerLog("Skipped because coverage already good")
        end
        return
    end

    local placedThisTick = 0
    local failedThisTick = 0
    local lastFailReason = "none"
    for _, placement in ipairs(placements) do
        if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            break
        end

        local tool = placement.Tool
        if not tool or not tool.Parent or getToolStackCount(tool) <= 0 then
            failedThisTick = failedThisTick + 1
            lastFailReason = "Sprinkler tool ran out"
        else
            local placed, placeReason = tryPlaceSprinkler(tool, placement.SprinklerType, placement.Position)
            if placed then
                placedThisTick = placedThisTick + 1
            else
                failedThisTick = failedThisTick + 1
                lastFailReason = tostring(placeReason or "unknown")
            end
        end

        task.wait(SPRINKLER_PLACE_COOLDOWN)
    end

    self._placed = self._placed + placedThisTick
    self._failed = self._failed + failedThisTick
    if failedThisTick > 0 then
        self._lastFailReason = lastFailReason
    elseif placedThisTick > 0 then
        self._lastFailReason = "none"
    end

    if placedThisTick > 0 then
        sprinklerLog("Placed this tick: " .. tostring(placedThisTick))
        self:_setStatus(
            string.format(
                "Smart Sprinkler: Placed=%d Total=%d Failed=%d (Coverage +%d/%d)",
                placedThisTick,
                self._placed,
                self._failed,
                newCoverage,
                targetCount
            )
        )
    elseif failedThisTick > 0 then
        sprinklerLog("Placement failed this tick: " .. tostring(self._lastFailReason))
        self:_setStatus(
            string.format(
                "Smart Sprinkler: Failed=%d LastFail=%s",
                failedThisTick,
                self._lastFailReason
            )
        )
    else
        self:_setStatus("Smart Sprinkler: No placement changes")
    end
end

function AutoSprinklerFeature:Start()
    if self._running then
        return
    end
    self._running = true
    self:_setStatus(self._statusText)
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self._failed = self._failed + 1
                self._lastFailReason = tostring(err)
                self:_setStatus("Smart Sprinkler: Error - " .. tostring(err))
            end
            task.wait(AUTO_SPRINKLER_LOOP_DELAY)
        end
    end)
end

function AutoSprinklerFeature:Stop()
    self._running = false
    self._thread = nil
    self:_setStatus("Smart Sprinkler: Stopped")
end

replaceFeature("AutoSprinkler", AutoSprinklerFeature)

local AutoSellFeature = {
    Name = "AutoSell",
    Enabled = Hub.Config.AutoSell.Enabled,
    _running = false,
    _thread = nil,
    _soldBatches = 0,
    _soldItems = 0,
    _failed = 0,
    _lastFailReason = "none",
    _statusText = "Auto Sell: Idle"
}

function AutoSellFeature:_setStatus(text)
    self._statusText = text
    queueUILabelUpdate("AutoSell", text)
end

function AutoSellFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self:_setStatus("Auto Sell: Disabled")
    else
        self:_setStatus("Auto Sell: Enabled")
    end
end

function AutoSellFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local sellableStacks, sellableItems = getSellableInventoryStats()
    if sellableStacks <= 0 then
        self:_setStatus("Auto Sell: No sellable items found")
        return
    end

    local teleported, teleportReason = teleportToSell()
    if not teleported then
        self._failed = self._failed + 1
        self._lastFailReason = tostring(teleportReason or "unknown")
        self:_setStatus("Auto Sell: Sell TP failed (" .. self._lastFailReason .. ")")
        return
    end

    local sold, responseText = sellAllInventory()
    if sold then
        self._soldBatches = self._soldBatches + 1
        self._soldItems = self._soldItems + sellableItems
        self._lastFailReason = "none"
        self:_setStatus(
            string.format(
                "Auto Sell: Batch=%d Items~%d (%s)",
                self._soldBatches,
                self._soldItems,
                tostring(responseText)
            )
        )
    else
        self._failed = self._failed + 1
        self._lastFailReason = tostring(responseText or "unknown")
        self:_setStatus(
            string.format(
                "Auto Sell: Failed=%d LastFail=%s",
                self._failed,
                self._lastFailReason
            )
        )
    end
end

function AutoSellFeature:Start()
    if self._running then
        return
    end
    self._running = true
    self:_setStatus(self._statusText)
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self._failed = self._failed + 1
                self._lastFailReason = tostring(err)
                self:_setStatus("Auto Sell: Error - " .. tostring(err))
            end
            task.wait(AUTO_SELL_LOOP_DELAY)
        end
    end)
end

function AutoSellFeature:Stop()
    self._running = false
    self._thread = nil
    self:_setStatus("Auto Sell: Stopped")
end

replaceFeature("AutoSell", AutoSellFeature)

local AutoHarvestFeature = {
    Name = "AutoHarvest",
    Enabled = Hub.Config.AutoHarvest.Enabled,
    _running = false,
    _thread = nil,
    _sent = 0,
    _failed = 0,
    _lastFailReason = "none",
    _statusText = "Auto Harvest: Idle",
    _retryGuard = {}
}

function AutoHarvestFeature:_setStatus(text)
    self._statusText = text
    queueUILabelUpdate("AutoHarvest", text)
end

function AutoHarvestFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self:_setStatus("Auto Harvest: Disabled")
    else
        self:_setStatus(
            string.format(
                "Auto Harvest: Enabled (Types=%s Stages=%s)",
                getAutoHarvestTypeSummary(),
                getAutoHarvestStageSummary()
            )
        )
    end
end

function AutoHarvestFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    if not Hub.Config.AutoHarvest.AllowUnripe
        and not Hub.Config.AutoHarvest.AllowRipe
        and not Hub.Config.AutoHarvest.AllowLush
    then
        self:_setStatus("Auto Harvest: No stages enabled")
        return
    end

    local candidates = collectOwnedHarvestCandidates()
    if #candidates == 0 then
        local teleported, teleportReason = teleportToGarden()
        if not teleported then
            self._failed = self._failed + 1
            self._lastFailReason = tostring(teleportReason or "unknown")
            self:_setStatus("Auto Harvest: Garden TP failed (" .. self._lastFailReason .. ")")
            return
        end
        candidates = collectOwnedHarvestCandidates()
    end

    if #candidates == 0 then
        self:_setStatus(
            string.format(
                "Auto Harvest: No matching crops (Types=%s Stages=%s)",
                getAutoHarvestTypeSummary(),
                getAutoHarvestStageSummary()
            )
        )
        return
    end

    local focusCandidate = candidates[1]
    local focusPosition = focusCandidate and (focusCandidate.Position or getPlantPosition(focusCandidate.TargetModel)) or nil
    if not focusPosition then
        self:_setStatus("Auto Harvest: Could not resolve target position")
        return
    end

    local movedClose = ensureInHarvestRange(focusPosition)
    if not movedClose then
        self._failed = self._failed + 1
        self._lastFailReason = "Could not move into harvest range"
        self:_setStatus("Auto Harvest: " .. self._lastFailReason)
        return
    end

    candidates = collectOwnedHarvestCandidates()
    if #candidates == 0 then
        self:_setStatus("Auto Harvest: No matching crops after moving")
        return
    end

    local root = getRootPart()
    local rootPos = root and root.Position or nil
    if rootPos then
        local nearbyCandidates = {}
        for _, candidate in ipairs(candidates) do
            local candidatePosition = candidate.Position or getPlantPosition(candidate.TargetModel)
            if candidatePosition and horizontalDistance(rootPos, candidatePosition) <= AUTO_HARVEST_BATCH_RADIUS then
                nearbyCandidates[#nearbyCandidates + 1] = candidate
            end
        end
        if #nearbyCandidates == 0 then
            self:_setStatus("Auto Harvest: No nearby crops in harvest range")
            return
        end
        candidates = nearbyCandidates
    end

    local now = tick()
    local retryGuard = self._retryGuard
    local payloadBatch = {}
    local harvestedTargets = {}
    for _, candidate in ipairs(candidates) do
        if #payloadBatch >= AUTO_HARVEST_MAX_PER_TICK then
            break
        end

        local nextAllowedAt = retryGuard[candidate.Key]
        if not nextAllowedAt or now >= nextAllowedAt then
            retryGuard[candidate.Key] = now + AUTO_HARVEST_RETRY_GUARD_SECONDS
            table.insert(payloadBatch, candidate.Payload)
            harvestedTargets[#harvestedTargets + 1] = candidate.TargetModel
        end
    end

    if #payloadBatch == 0 then
        self:_setStatus("Auto Harvest: Cooldown guard active, waiting...")
        return
    end

    local sentOk, sentErr = pcall(function()
        HarvestFruitRemote:FireServer(payloadBatch)
    end)

    if sentOk then
        self._sent = self._sent + #payloadBatch
        self._lastFailReason = "none"
        self:_setStatus(
            string.format(
                "Auto Harvest: Sent=%d Total=%d Failed=%d (Types=%s Stages=%s)",
                #payloadBatch,
                self._sent,
                self._failed,
                getAutoHarvestTypeSummary(),
                getAutoHarvestStageSummary()
            )
        )

        for _, target in ipairs(harvestedTargets) do
            if target and target.Parent then
                target:SetAttribute("IsHarvested", true)
                task.delay(3, function()
                    if target and target.Parent then
                        target:SetAttribute("IsHarvested", nil)
                    end
                end)
            end
        end
    else
        self._failed = self._failed + #payloadBatch
        self._lastFailReason = tostring(sentErr)
        self:_setStatus(
            string.format(
                "Auto Harvest: Failed=%d LastFail=%s",
                self._failed,
                self._lastFailReason
            )
        )
    end
end

function AutoHarvestFeature:Start()
    if self._running then
        return
    end
    self._running = true
    self:_setStatus(self._statusText)
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self._failed = self._failed + 1
                self._lastFailReason = tostring(err)
                self:_setStatus("Auto Harvest: Error - " .. tostring(err))
            end
            task.wait(AUTO_HARVEST_LOOP_DELAY)
        end
    end)
end

function AutoHarvestFeature:Stop()
    self._running = false
    self._thread = nil
    self._retryGuard = {}
    self:_setStatus("Auto Harvest: Stopped")
end

replaceFeature("AutoHarvest", AutoHarvestFeature)

local PlantRankingFeature = {
    Name = "PlantRanking",
    _running = false,
    _thread = nil,
    _statusText = "Scanning plot plants..."
}

function PlantRankingFeature:_setStatus(text)
    self._statusText = text
    queueUILabelUpdate("PlantRankings", text)
end

function PlantRankingFeature:Tick()
    if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end
    local ok, text = pcall(buildPlantRankingText)
    if ok and type(text) == "string" and text ~= "" then
        self:_setStatus(text)
        return
    end
    self:_setStatus("No plants found on your plot.")
end

function PlantRankingFeature:Start()
    if self._running then
        return
    end
    self._running = true
    self:_setStatus(self._statusText)
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self:_setStatus("Plant Ranking: Error - " .. tostring(err))
            end
            task.wait(PLANT_RANK_REFRESH_INTERVAL)
        end
    end)
end

function PlantRankingFeature:Stop()
    self._running = false
    self._thread = nil
end

replaceFeature("PlantRanking", PlantRankingFeature)

local AntiAFKFeature = {
    Name = "AntiAFK",
    Enabled = Hub.Config.AntiAFK.Enabled,
    _running = false,
    _thread = nil,
    _idledConnection = nil,
    _lastDisconnectCount = 0,
    _statusText = "Anti AFK: Idle"
}

function AntiAFKFeature:_setStatus(text)
    self._statusText = tostring(text or "Anti AFK: Idle")
    queueUILabelUpdate("AntiAFK", self._statusText)
end

function AntiAFKFeature:_disconnectConnectionObject(connection)
    if connection == nil then
        return false
    end
    local okDisconnect = false
    if type(connection.Disconnect) == "function" then
        okDisconnect = pcall(function()
            connection:Disconnect()
        end)
    elseif type(connection.Disable) == "function" then
        okDisconnect = pcall(function()
            connection:Disable()
        end)
    end
    return okDisconnect
end

function AntiAFKFeature:_connectionSourceMatches(connection, needle)
    if type(needle) ~= "string" or needle == "" then
        return false
    end
    if type(debug) ~= "table" or type(debug.getinfo) ~= "function" then
        return false
    end

    local callbackFn = nil
    local okFn, fnValue = pcall(function()
        return connection.Function
    end)
    if okFn and type(fnValue) == "function" then
        callbackFn = fnValue
    end
    if type(callbackFn) ~= "function" then
        return false
    end

    local okInfo, info = pcall(function()
        return debug.getinfo(callbackFn)
    end)
    if not okInfo or type(info) ~= "table" then
        return false
    end

    local source = tostring(info.source or "")
    return string.find(source, needle, 1, true) ~= nil
end

function AntiAFKFeature:_disconnectSignalConnections(signal, shouldDisconnectFn)
    if type(getconnections) ~= "function" then
        return 0, "getconnections unavailable"
    end

    local okConnections, connections = pcall(function()
        return getconnections(signal)
    end)
    if not okConnections or type(connections) ~= "table" then
        return 0, tostring(connections or "getconnections failed")
    end

    local disconnected = 0
    for _, connection in ipairs(connections) do
        local shouldDisconnect = true
        if type(shouldDisconnectFn) == "function" then
            local okShould, result = pcall(shouldDisconnectFn, connection)
            shouldDisconnect = okShould and result == true
        end
        if shouldDisconnect and self:_disconnectConnectionObject(connection) then
            disconnected = disconnected + 1
        end
    end

    return disconnected, nil
end

function AntiAFKFeature:_pulseServerNotAFK()
    if not AFKRemote or not AFKRemote:IsA("RemoteEvent") then
        return false
    end
    local ok = pcall(function()
        AFKRemote:FireServer(false)
    end)
    return ok
end

function AntiAFKFeature:_performClassicAntiAFKNudge()
    local camera = workspace.CurrentCamera
    local cameraCFrame = camera and camera.CFrame or CFrame.new()
    local okVirtualUser = pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:Button2Down(Vector2.new(0, 0), cameraCFrame)
        task.wait(0.08)
        VirtualUser:Button2Up(Vector2.new(0, 0), cameraCFrame)
    end)
    if okVirtualUser then
        return true
    end

    local okService, virtualInputManager = pcall(function()
        return game:GetService("VirtualInputManager")
    end)
    if okService and virtualInputManager then
        local okVim = pcall(function()
            virtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
            task.wait(0.05)
            virtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
        end)
        if okVim then
            return true
        end
    end

    return false
end

function AntiAFKFeature:_detachClassicConnection()
    if self._idledConnection then
        pcall(function()
            self._idledConnection:Disconnect()
        end)
        self._idledConnection = nil
    end
end

function AntiAFKFeature:_attachClassicConnection()
    self:_detachClassicConnection()
    if not Hub.Config.AntiAFK.UseClassic then
        return false
    end

    self._idledConnection = LocalPlayer.Idled:Connect(function()
        if not self._running or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        self:_pulseServerNotAFK()
        local nudged = self:_performClassicAntiAFKNudge()
        if nudged then
            self:_setStatus("Anti AFK: Prevented idle kick (classic)")
        else
            self:_setStatus("Anti AFK: Idled event hit, input nudge failed")
        end
    end)
    return self._idledConnection ~= nil
end

function AntiAFKFeature:_disableGameAFKConnections()
    if not Hub.Config.AntiAFK.DisableGameConnections then
        return 0
    end

    local disconnectedTotal = 0

    local disconnectedIdled = self:_disconnectSignalConnections(LocalPlayer.Idled, function(connection)
        return connection ~= self._idledConnection
    end)
    disconnectedTotal = disconnectedTotal + (tonumber(disconnectedIdled) or 0)

    local function afkLabelConnection(connection)
        return self:_connectionSourceMatches(connection, "AFKLabelController")
    end

    local disconnectedFocusReleased = self:_disconnectSignalConnections(UserInputService.WindowFocusReleased, afkLabelConnection)
    disconnectedTotal = disconnectedTotal + (tonumber(disconnectedFocusReleased) or 0)

    local disconnectedFocused = self:_disconnectSignalConnections(UserInputService.WindowFocused, afkLabelConnection)
    disconnectedTotal = disconnectedTotal + (tonumber(disconnectedFocused) or 0)

    local disconnectedCharacterAdded = self:_disconnectSignalConnections(LocalPlayer.CharacterAdded, afkLabelConnection)
    disconnectedTotal = disconnectedTotal + (tonumber(disconnectedCharacterAdded) or 0)

    self._lastDisconnectCount = disconnectedTotal
    return disconnectedTotal
end

function AntiAFKFeature:ApplyNow()
    if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local disconnected = self:_disableGameAFKConnections()
    local classicAttached = self:_attachClassicConnection()
    local pulseOk = self:_pulseServerNotAFK()

    local modeParts = {}
    modeParts[#modeParts + 1] = Hub.Config.AntiAFK.DisableGameConnections and "GameAFK disabled" or "GameAFK unchanged"
    modeParts[#modeParts + 1] = Hub.Config.AntiAFK.UseClassic and "Classic enabled" or "Classic disabled"
    local pulseText = pulseOk and "Pulse ok" or "Pulse unavailable"
    self:_setStatus(
        string.format(
            "Anti AFK: Active (%s | %s | Disconnected=%d | Hooked=%s)",
            table.concat(modeParts, " + "),
            pulseText,
            disconnected,
            tostring(classicAttached)
        )
    )
end

function AntiAFKFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self:_setStatus("Anti AFK: Disabled")
    else
        self:_setStatus("Anti AFK: Enabled")
    end
end

function AntiAFKFeature:Tick()
    if not self.Enabled or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local disconnected = self:_disableGameAFKConnections()
    local pulseOk = self:_pulseServerNotAFK()
    if disconnected > 0 then
        self:_setStatus("Anti AFK: Active (Disconnected=" .. tostring(disconnected) .. ")")
    elseif not pulseOk then
        self:_setStatus("Anti AFK: Active (AFK remote unavailable)")
    end
end

function AntiAFKFeature:Start()
    if self._running then
        return
    end

    self._running = true
    self:ApplyNow()
    self._thread = task.spawn(function()
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local ok, err = pcall(function()
                self:Tick()
            end)
            if not ok then
                self:_setStatus("Anti AFK: Error - " .. tostring(err))
            end
            task.wait(ANTI_AFK_PULSE_INTERVAL)
        end
    end)
end

function AntiAFKFeature:Stop()
    self._running = false
    self._thread = nil
    self:_detachClassicConnection()
    self:_setStatus("Anti AFK: Stopped")
end

replaceFeature("AntiAFK", AntiAFKFeature)

Hub.FPSBoostFeature = {
    Name = "FPSBoost",
    Enabled = Hub.Config.FPSBoost.Enabled,
    _running = false,
    _thread = nil,
    _statusText = "FPS Boost: Idle",
    _backup = setmetatable({}, { __mode = "k" }),
    _connections = {},
    _optimizedInstances = 0,
    _cullParts = setmetatable({}, { __mode = "k" })
}

function Hub.FPSBoostFeature:_setStatus(text)
    self._statusText = tostring(text or "FPS Boost: Idle")
    queueUILabelUpdate("FPSBoost", self._statusText)
end

function Hub.FPSBoostFeature:_rememberAndSet(target, propertyName, newValue)
    if target == nil then
        return false
    end

    local okRead, currentValue = pcall(function()
        return target[propertyName]
    end)
    if not okRead then
        return false
    end
    if currentValue == newValue then
        return false
    end

    local state = self._backup[target]
    if state == nil then
        state = {}
        self._backup[target] = state
    end
    if state[propertyName] == nil then
        state[propertyName] = {
            HasValue = true,
            Value = currentValue
        }
    end

    local okWrite = pcall(function()
        target[propertyName] = newValue
    end)
    return okWrite
end

function Hub.FPSBoostFeature:_disconnectConnections()
    for _, connection in ipairs(self._connections) do
        if connection then
            pcall(function()
                connection:Disconnect()
            end)
        end
    end
    self._connections = {}
end

function Hub.FPSBoostFeature:_restoreAll()
    local restored = 0
    for target, state in pairs(self._backup) do
        if state then
            for propertyName, entry in pairs(state) do
                if type(entry) == "table" and entry.HasValue then
                    local okWrite = pcall(function()
                        target[propertyName] = entry.Value
                    end)
                    if okWrite then
                        restored = restored + 1
                    end
                end
            end
        end
    end
    self._backup = setmetatable({}, { __mode = "k" })
    return restored
end

function Hub.FPSBoostFeature:_isCharacterDescendant(instance)
    if instance == nil then
        return false
    end
    local model = instance:FindFirstAncestorOfClass("Model")
    if model == nil then
        return false
    end
    return Players:GetPlayerFromCharacter(model) ~= nil
end

function Hub.FPSBoostFeature:_trackCullPart(instance)
    if instance == nil or not instance:IsA("BasePart") then
        return
    end
    if self:_isCharacterDescendant(instance) then
        return
    end
    self._cullParts[instance] = true
end

function Hub.FPSBoostFeature:_updateDistanceCulling()
    local camera = workspace.CurrentCamera
    if camera == nil then
        return 0
    end

    local changed = 0
    local cameraPosition = camera.CFrame.Position
    local cullDistance = 180
    for part in pairs(self._cullParts) do
        if part and part.Parent and part:IsA("BasePart") then
            local delta = part.Position - cameraPosition
            local hide = delta:Dot(delta) > (cullDistance * cullDistance)
            local targetModifier = hide and 1 or 0
            if self:_rememberAndSet(part, "LocalTransparencyModifier", targetModifier) then
                changed = changed + 1
            end
        else
            self._cullParts[part] = nil
        end
    end
    return changed
end

function Hub.FPSBoostFeature:_optimizeInstance(instance)
    if instance == nil then
        return false
    end

    local changed = false
    if instance:IsA("ParticleEmitter") then
        changed = self:_rememberAndSet(instance, "Enabled", false) or changed
        changed = self:_rememberAndSet(instance, "Rate", 0) or changed
    elseif instance:IsA("Trail") or instance:IsA("Beam") then
        changed = self:_rememberAndSet(instance, "Enabled", false) or changed
    elseif instance:IsA("Smoke") or instance:IsA("Fire") or instance:IsA("Sparkles") then
        changed = self:_rememberAndSet(instance, "Enabled", false) or changed
    elseif instance:IsA("PointLight") or instance:IsA("SpotLight") or instance:IsA("SurfaceLight") then
        changed = self:_rememberAndSet(instance, "Enabled", false) or changed
    elseif instance:IsA("PostEffect") then
        changed = self:_rememberAndSet(instance, "Enabled", false) or changed
    elseif instance:IsA("Decal") or instance:IsA("Texture") then
        changed = self:_rememberAndSet(instance, "Transparency", 1) or changed
    elseif instance:IsA("Atmosphere") then
        changed = self:_rememberAndSet(instance, "Density", 0) or changed
        changed = self:_rememberAndSet(instance, "Haze", 0) or changed
        changed = self:_rememberAndSet(instance, "Glare", 0) or changed
    end

    if instance:IsA("BasePart") then
        changed = self:_rememberAndSet(instance, "CastShadow", false) or changed
        changed = self:_rememberAndSet(instance, "Reflectance", 0) or changed
        local plasticMaterial = nil
        pcall(function()
            plasticMaterial = Enum.Material.Plastic
        end)
        if plasticMaterial ~= nil then
            changed = self:_rememberAndSet(instance, "Material", plasticMaterial) or changed
        end
        self:_trackCullPart(instance)
    end

    return changed
end

function Hub.FPSBoostFeature:_applyWorldOptimizations()
    local changedCount = 0
    self._cullParts = setmetatable({}, { __mode = "k" })
    for _, instance in ipairs(game:GetDescendants()) do
        if self:_optimizeInstance(instance) then
            changedCount = changedCount + 1
        end
    end
    self._optimizedInstances = changedCount
    return changedCount
end

function Hub.FPSBoostFeature:_applyGlobalOptimizations()
    local changedCount = 0
    local lighting = game:GetService("Lighting")
    local qualityLevelLow = nil
    pcall(function()
        qualityLevelLow = Enum.QualityLevel.Level01
    end)
    local savedQualityLow = nil
    pcall(function()
        savedQualityLow = Enum.SavedQualitySetting.QualityLevel1
    end)
    local compatibilityTech = nil
    pcall(function()
        compatibilityTech = Enum.Technology.Compatibility
    end)

    local okSettings, appSettings = pcall(function()
        return settings()
    end)
    if okSettings and appSettings and appSettings.Rendering then
        local renderSettings = appSettings.Rendering
        local qualityChanged = false
        if qualityLevelLow ~= nil then
            qualityChanged = self:_rememberAndSet(renderSettings, "QualityLevel", qualityLevelLow)
        end
        if not qualityChanged and savedQualityLow ~= nil then
            qualityChanged = self:_rememberAndSet(renderSettings, "QualityLevel", savedQualityLow)
        end
        if qualityChanged then
            changedCount = changedCount + 1
        end
    end

    changedCount = changedCount + (self:_rememberAndSet(lighting, "GlobalShadows", false) and 1 or 0)
    changedCount = changedCount + (self:_rememberAndSet(lighting, "EnvironmentDiffuseScale", 0) and 1 or 0)
    changedCount = changedCount + (self:_rememberAndSet(lighting, "EnvironmentSpecularScale", 0) and 1 or 0)
    changedCount = changedCount + (self:_rememberAndSet(lighting, "FogEnd", 100000) and 1 or 0)

    if compatibilityTech ~= nil then
        changedCount = changedCount + (self:_rememberAndSet(lighting, "Technology", compatibilityTech) and 1 or 0)
    end

    local terrain = workspace:FindFirstChildOfClass("Terrain")
    if terrain then
        changedCount = changedCount + (self:_rememberAndSet(terrain, "Decoration", false) and 1 or 0)
        changedCount = changedCount + (self:_rememberAndSet(terrain, "WaterWaveSize", 0) and 1 or 0)
        changedCount = changedCount + (self:_rememberAndSet(terrain, "WaterWaveSpeed", 0) and 1 or 0)
        changedCount = changedCount + (self:_rememberAndSet(terrain, "WaterReflectance", 0) and 1 or 0)
        changedCount = changedCount + (self:_rememberAndSet(terrain, "WaterTransparency", 1) and 1 or 0)
    end

    return changedCount
end

function Hub.FPSBoostFeature:_applyExecutorOptimizations()
    local targetFPS = math.max(60, math.min(500, math.floor(tonumber(Hub.Config.FPSBoost.TargetFPS) or 360)))
    local applied = {}

    if type(setfpscap) == "function" then
        local okSetCap = pcall(function()
            setfpscap(targetFPS)
        end)
        if okSetCap then
            applied[#applied + 1] = "setfpscap=" .. tostring(targetFPS)
        end
    end

    if #applied == 0 then
        return "none"
    end
    return table.concat(applied, ", ")
end

function Hub.FPSBoostFeature:_attachOptimizationHooks()
    self:_disconnectConnections()
    self._connections[#self._connections + 1] = game.DescendantAdded:Connect(function(instance)
        if not self._running or Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
            return
        end
        self:_optimizeInstance(instance)
    end)
end

function Hub.FPSBoostFeature:ApplyNow()
    if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end

    local globalChanges = self:_applyGlobalOptimizations()
    local worldChanges = self:_applyWorldOptimizations()
    local cullChanges = self:_updateDistanceCulling()
    local envSummary = self:_applyExecutorOptimizations()

    self:_setStatus(
        string.format(
            "FPS Boost: Active (World=%d Cull=%d Global=%d Env=%s)",
            worldChanges,
            cullChanges,
            globalChanges,
            envSummary
        )
    )
end

function Hub.FPSBoostFeature:SetEnabled(enabled)
    self.Enabled = not not enabled
    if not self.Enabled then
        self:_setStatus("FPS Boost: Disabled")
    else
        self:_setStatus("FPS Boost: Enabled")
    end
end

function Hub.FPSBoostFeature:Start()
    if self._running then
        self:ApplyNow()
        return
    end

    self._running = true
    self:_attachOptimizationHooks()
    self:ApplyNow()
    self._thread = task.spawn(function()
        local counter = 0
        while self._running and not Hub.IsUnloaded and Hub.RunId == CurrentRunId do
            local okApply, applyErr = pcall(function()
                counter = counter + 1
                self:_updateDistanceCulling()
                if counter % 20 == 0 then
                    self:_applyGlobalOptimizations()
                    self:_applyExecutorOptimizations()
                end
            end)
            if not okApply then
                self:_setStatus("FPS Boost: Error - " .. tostring(applyErr))
            end
            task.wait(0.8)
        end
    end)
end

function Hub.FPSBoostFeature:Stop()
    self._running = false
    self._thread = nil
    self:_disconnectConnections()
    self._cullParts = setmetatable({}, { __mode = "k" })
    local restored = self:_restoreAll()
    self:_setStatus("FPS Boost: Stopped (Restored=" .. tostring(restored) .. ")")
end

replaceFeature("FPSBoost", Hub.FPSBoostFeature)

local function stopAllFeatures()
    if Hub.Config.AutoPlant then
        Hub.Config.AutoPlant.Enabled = false
    end
    if Hub.Config.AutoBuySeeds then
        Hub.Config.AutoBuySeeds.Enabled = false
    end
    if Hub.Config.AutoBuyGears then
        Hub.Config.AutoBuyGears.Enabled = false
    end
    if Hub.Config.AutoBotanist then
        Hub.Config.AutoBotanist.Enabled = false
    end
    if Hub.Config.AutoSprinkler then
        Hub.Config.AutoSprinkler.Enabled = false
    end
    if Hub.Config.AutoSell then
        Hub.Config.AutoSell.Enabled = false
    end
    if Hub.Config.AutoHarvest then
        Hub.Config.AutoHarvest.Enabled = false
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
end

local function unloadHub()
    Hub.RunId = (Hub.RunId or 0) + 1
    Hub.IsUnloaded = true
    Hub.StockTimerLoopRunning = false
    stopAllFeatures()
    Hub.Features = {}
    Hub.PendingUILabelUpdates = {}

    if Hub.UIUpdateConnection then
        pcall(function()
            Hub.UIUpdateConnection:Disconnect()
        end)
        Hub.UIUpdateConnection = nil
    end

    local existingUI = Hub.UI
    if existingUI and existingUI.Library and type(existingUI.Library.Unload) == "function" then
        pcall(function()
            existingUI.Library:Unload()
        end)
    end
    Hub.UI = nil
end

function setAutoPlantEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end

    Hub.Config.AutoPlant.Enabled = nextState
    AutoPlantFeature:SetEnabled(nextState)

    if nextState then
        AutoPlantFeature:Start()
    else
        AutoPlantFeature:Stop()
    end
end

function setAutoBuySeedsEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end

    Hub.Config.AutoBuySeeds.Enabled = nextState
    AutoBuySeedsFeature:SetEnabled(nextState)

    if nextState then
        AutoBuySeedsFeature:Start()
    else
        AutoBuySeedsFeature:Stop()
    end
end

function setAutoBuyGearsEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end

    Hub.Config.AutoBuyGears.Enabled = nextState
    AutoBuyGearsFeature:SetEnabled(nextState)

    if nextState then
        AutoBuyGearsFeature:Start()
    else
        AutoBuyGearsFeature:Stop()
    end
end

function setAutoBotanistEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end

    Hub.Config.AutoBotanist.Enabled = nextState
    Hub.AutoBotanistFeature:SetEnabled(nextState)

    if nextState then
        Hub.AutoBotanistFeature:Start()
    else
        Hub.AutoBotanistFeature:Stop()
    end
end

function setAutoSprinklerEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end

    Hub.Config.AutoSprinkler.Enabled = nextState
    AutoSprinklerFeature:SetEnabled(nextState)

    if nextState then
        AutoSprinklerFeature:Start()
    else
        AutoSprinklerFeature:Stop()
    end
end

function setAutoSellEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end

    Hub.Config.AutoSell.Enabled = nextState
    AutoSellFeature:SetEnabled(nextState)

    if nextState then
        AutoSellFeature:Start()
    else
        AutoSellFeature:Stop()
    end
end

function setAutoHarvestEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end

    Hub.Config.AutoHarvest.Enabled = nextState
    AutoHarvestFeature:SetEnabled(nextState)

    if nextState then
        AutoHarvestFeature:Start()
    else
        AutoHarvestFeature:Stop()
    end
end

function setAntiAFKEnabled(enabled)
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

function setFPSBoostEnabled(enabled)
    local nextState = not not enabled
    if Hub.IsUnloaded and nextState then
        nextState = false
    end

    Hub.Config.FPSBoost.Enabled = nextState
    Hub.FPSBoostFeature:SetEnabled(nextState)

    if nextState then
        Hub.FPSBoostFeature:Start()
    else
        Hub.FPSBoostFeature:Stop()
    end
end

function loadRemoteModule(url, label)
    local ok, moduleOrError = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if not ok then
        warn(string.format("[TrustsenseHub] Failed to load %s from %s: %s", label, url, tostring(moduleOrError)))
        return nil
    end
    return moduleOrError
end

function setupObsidianUI()
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
    local ThemeManager = loadRemoteModule(repoBase .. "addons/ThemeManager.lua", "Obsidian ThemeManager")
    local SaveManager = loadRemoteModule(repoBase .. "addons/SaveManager.lua", "Obsidian SaveManager")
    local TrustsenseAuroraTheme = {
        FontColor = Color3.fromRGB(228, 237, 233),
        MainColor = Color3.fromRGB(20, 28, 30),
        AccentColor = Color3.fromRGB(92, 184, 161),
        BackgroundColor = Color3.fromRGB(12, 18, 20),
        OutlineColor = Color3.fromRGB(47, 67, 68)
    }

    local Window = Library:CreateWindow({
        Title = "Trustsense Hub",
        Footer = "Garden Horizons",
        Icon = 94313740477699,
        ToggleKeybind = Enum.KeyCode.RightShift
    })

    local Tabs = {
        Main = Window:AddTab("Main", "house"),
        Plot = Window:AddTab("Plot", "leaf"),
        Settings = Window:AddTab("Settings", "settings")
    }

    local autoPlantGroup = Tabs.Main:AddLeftGroupbox("Plant")
    local autoHarvestGroup = Tabs.Main:AddLeftGroupbox("Harvest")
    local discordGroup = Tabs.Main:AddRightGroupbox("Discord")
    local smartSprinklerGroup = Tabs.Main:AddRightGroupbox("Sprinkler")
    local antiAFKGroup = Tabs.Main:AddRightGroupbox("Stay Online")

    local autoBuySeedsGroup = Tabs.Plot:AddLeftGroupbox("Seeds")
    local plotRankingsGroup = Tabs.Plot:AddLeftGroupbox("Top Plants")
    local autoBuyGearsGroup = Tabs.Plot:AddRightGroupbox("Gears")
    local botanistGroup = Tabs.Plot:AddRightGroupbox("Botanist")
    local autoSellGroup = Tabs.Plot:AddRightGroupbox("Sell")

    local teleportGroup = Tabs.Main:AddRightGroupbox("Teleport")
    local uiGroup = Tabs.Settings:AddLeftGroupbox("Menu")
    local performanceGroup = Tabs.Settings:AddRightGroupbox("Performance")
    local refreshSeedStockSection = nil
    local refreshGearStockSection = nil

    local autoPlantToggle = autoPlantGroup:AddToggle("AutoPlant_Enabled", {
        Text = "Auto Plant",
        Default = Hub.Config.AutoPlant.Enabled
    })
    autoPlantToggle:OnChanged(function(value)
        setAutoPlantEnabled(value)
    end)

    local autoPlantStatusLabel = autoPlantGroup:AddLabel({
        Text = "Auto Plant: Ready",
        DoesWrap = true
    })

    local antiAFKEnabledToggle = antiAFKGroup:AddToggle("AntiAFK_Enabled", {
        Text = "Anti AFK",
        Default = Hub.Config.AntiAFK.Enabled
    })
    antiAFKEnabledToggle:OnChanged(function(value)
        setAntiAFKEnabled(value)
    end)

    local antiAFKDisableGameToggle = antiAFKGroup:AddToggle("AntiAFK_DisableGameConnections", {
        Text = "Block AFK Hooks",
        Default = Hub.Config.AntiAFK.DisableGameConnections
    })
    antiAFKDisableGameToggle:OnChanged(function(value)
        Hub.Config.AntiAFK.DisableGameConnections = value == true
        if Hub.Config.AntiAFK.Enabled then
            AntiAFKFeature:ApplyNow()
        end
    end)

    local antiAFKClassicToggle = antiAFKGroup:AddToggle("AntiAFK_UseClassic", {
        Text = "Classic Idle Bypass",
        Default = Hub.Config.AntiAFK.UseClassic
    })
    antiAFKClassicToggle:OnChanged(function(value)
        Hub.Config.AntiAFK.UseClassic = value == true
        if Hub.Config.AntiAFK.Enabled then
            AntiAFKFeature:ApplyNow()
        end
    end)

    local antiAFKStatusLabel = antiAFKGroup:AddLabel({
        Text = "Anti AFK: Ready",
        DoesWrap = true
    })

    local fpsBoostToggle = performanceGroup:AddToggle("FPSBoost_Enabled", {
        Text = "Ultra FPS Boost",
        Default = Hub.Config.FPSBoost.Enabled
    })
    fpsBoostToggle:OnChanged(function(value)
        setFPSBoostEnabled(value)
    end)

    performanceGroup:AddButton({
        Text = "FPS Cap 360",
        Func = function()
            Hub.Config.FPSBoost.TargetFPS = 360
            if Hub.Config.FPSBoost.Enabled then
                Hub.FPSBoostFeature:ApplyNow()
            end
        end
    })

    performanceGroup:AddButton({
        Text = "FPS Cap 500",
        Func = function()
            Hub.Config.FPSBoost.TargetFPS = 500
            if Hub.Config.FPSBoost.Enabled then
                Hub.FPSBoostFeature:ApplyNow()
            end
        end
    })

    performanceGroup:AddButton({
        Text = "Reapply Boost",
        Func = function()
            Hub.FPSBoostFeature:ApplyNow()
        end
    })

    local fpsBoostStatusLabel = performanceGroup:AddLabel({
        Text = "FPS Boost: Ready",
        DoesWrap = true
    })

    local plantRankingsLabel = plotRankingsGroup:AddLabel({
        Text = "Scanning plot plants...",
        DoesWrap = true
    })
    plotRankingsGroup:AddButton({
        Text = "Refresh Rankings",
        Func = function()
            PlantRankingFeature:Tick()
        end
    })

    local autoHarvestToggle = autoHarvestGroup:AddToggle("AutoHarvest_Enabled", {
        Text = "Auto Harvest",
        Default = Hub.Config.AutoHarvest.Enabled
    })
    autoHarvestToggle:OnChanged(function(value)
        setAutoHarvestEnabled(value)
    end)

    local function updateAutoHarvestFilterStatus()
        local prefix = Hub.Config.AutoHarvest.Enabled and "Auto Harvest: Running" or "Auto Harvest: Ready"
        AutoHarvestFeature:_setStatus(
            string.format(
                "%s (Types=%s Stages=%s)",
                prefix,
                getAutoHarvestTypeSummary(),
                getAutoHarvestStageSummary()
            )
        )
    end

    local autoHarvestUnripeToggle = autoHarvestGroup:AddToggle("AutoHarvest_AllowUnripe", {
        Text = "Harvest Unripe",
        Default = Hub.Config.AutoHarvest.AllowUnripe
    })
    autoHarvestUnripeToggle:OnChanged(function(value)
        Hub.Config.AutoHarvest.AllowUnripe = value == true
        updateAutoHarvestFilterStatus()
    end)

    local autoHarvestRipeToggle = autoHarvestGroup:AddToggle("AutoHarvest_AllowRipe", {
        Text = "Harvest Ripe",
        Default = Hub.Config.AutoHarvest.AllowRipe
    })
    autoHarvestRipeToggle:OnChanged(function(value)
        Hub.Config.AutoHarvest.AllowRipe = value == true
        updateAutoHarvestFilterStatus()
    end)

    local autoHarvestLushToggle = autoHarvestGroup:AddToggle("AutoHarvest_AllowLush", {
        Text = "Harvest Lush",
        Default = Hub.Config.AutoHarvest.AllowLush
    })
    autoHarvestLushToggle:OnChanged(function(value)
        Hub.Config.AutoHarvest.AllowLush = value == true
        updateAutoHarvestFilterStatus()
    end)

    local autoHarvestTypeDropdown = nil
    local function applyAutoHarvestTypeSelection(rawSelection)
        local normalized = normalizeSelectedPlantTypeMap(rawSelection)
        Hub.Config.AutoHarvest.SelectedPlantTypes = normalized
        updateAutoHarvestFilterStatus()
    end

    if #PlantTypeNames > 0 then
        autoHarvestTypeDropdown = autoHarvestGroup:AddDropdown("AutoHarvest_SelectedPlantTypes", {
            Text = "Plant Filter",
            Values = PlantTypeNames,
            Default = selectedPlantTypeMapToList(Hub.Config.AutoHarvest.SelectedPlantTypes),
            Multi = true,
            AllowNull = true,
            Searchable = true
        })
        autoHarvestTypeDropdown:OnChanged(function(value)
            applyAutoHarvestTypeSelection(value)
        end)

        autoHarvestGroup:AddButton({
            Text = "All Plants",
            Func = function()
                local allSelected = {}
                for _, plantType in ipairs(PlantTypeNames) do
                    allSelected[plantType] = true
                end
                Hub.Config.AutoHarvest.SelectedPlantTypes = allSelected
                if autoHarvestTypeDropdown and type(autoHarvestTypeDropdown.SetValue) == "function" then
                    pcall(function()
                        autoHarvestTypeDropdown:SetValue(selectedPlantTypeMapToList(allSelected))
                    end)
                end
                updateAutoHarvestFilterStatus()
            end
        })

        autoHarvestGroup:AddButton({
            Text = "Clear Plants",
            Func = function()
                Hub.Config.AutoHarvest.SelectedPlantTypes = {}
                if autoHarvestTypeDropdown and type(autoHarvestTypeDropdown.SetValue) == "function" then
                    pcall(function()
                        autoHarvestTypeDropdown:SetValue({})
                    end)
                end
                updateAutoHarvestFilterStatus()
            end
        })
    else
        autoHarvestGroup:AddLabel({
            Text = "Plant types unavailable.",
            DoesWrap = true
        })
    end

    local autoHarvestStatusLabel = autoHarvestGroup:AddLabel({
        Text = "Auto Harvest: Ready",
        DoesWrap = true
    })

    local autoBuySeedsToggle = autoBuySeedsGroup:AddToggle("AutoBuySeeds_Enabled", {
        Text = "Auto Buy Seeds",
        Default = Hub.Config.AutoBuySeeds.Enabled
    })
    autoBuySeedsToggle:OnChanged(function(value)
        setAutoBuySeedsEnabled(value)
    end)

    local autoBuySeedsDropdown = nil
    local function applyAutoBuySeedSelection(rawSelection)
        local normalized = normalizeSelectedSeedNameMap(rawSelection)
        Hub.Config.AutoBuySeeds.SelectedSeedNames = normalized
        local selectedCount = getSelectedSeedCount()
        if selectedCount > 0 then
            AutoBuySeedsFeature:_setStatus(string.format("Auto Buy Seeds: %d seed(s) selected", selectedCount))
        else
            AutoBuySeedsFeature:_setStatus("Auto Buy Seeds: No seeds selected")
        end
    end

    if #SeedShopItemNames > 0 then
        autoBuySeedsDropdown = autoBuySeedsGroup:AddDropdown("AutoBuySeeds_SelectedSeedNames", {
            Text = "Seed List",
            Values = SeedShopItemNames,
            Default = selectedSeedNameMapToList(Hub.Config.AutoBuySeeds.SelectedSeedNames),
            Multi = true,
            AllowNull = true,
            Searchable = true
        })
        autoBuySeedsDropdown:OnChanged(function(value)
            applyAutoBuySeedSelection(value)
        end)

        autoBuySeedsGroup:AddButton({
            Text = "All Seeds",
            Func = function()
                local allSelected = {}
                for _, itemName in ipairs(SeedShopItemNames) do
                    allSelected[itemName] = true
                end
                Hub.Config.AutoBuySeeds.SelectedSeedNames = allSelected
                if autoBuySeedsDropdown and type(autoBuySeedsDropdown.SetValue) == "function" then
                    pcall(function()
                        autoBuySeedsDropdown:SetValue(selectedSeedNameMapToList(allSelected))
                    end)
                end
                AutoBuySeedsFeature:_setStatus(string.format("Auto Buy Seeds: %d seed(s) selected", getSelectedSeedCount()))
            end
        })

        autoBuySeedsGroup:AddButton({
            Text = "Clear Selection",
            Func = function()
                Hub.Config.AutoBuySeeds.SelectedSeedNames = {}
                if autoBuySeedsDropdown and type(autoBuySeedsDropdown.SetValue) == "function" then
                    pcall(function()
                        autoBuySeedsDropdown:SetValue({})
                    end)
                end
                AutoBuySeedsFeature:_setStatus("Auto Buy Seeds: No seeds selected")
            end
        })
    else
        autoBuySeedsGroup:AddLabel({
            Text = "Seed list unavailable.",
            DoesWrap = true
        })
    end

    local autoBuySeedsStatusLabel = autoBuySeedsGroup:AddLabel({
        Text = "Auto Buy Seeds: Ready",
        DoesWrap = true
    })

    local autoBuyGearsToggle = autoBuyGearsGroup:AddToggle("AutoBuyGears_Enabled", {
        Text = "Auto Buy Gears",
        Default = Hub.Config.AutoBuyGears.Enabled
    })
    autoBuyGearsToggle:OnChanged(function(value)
        setAutoBuyGearsEnabled(value)
    end)

    local autoBuyGearsDropdown = nil
    local function applyAutoBuyGearSelection(rawSelection)
        local normalized = normalizeSelectedGearNameMap(rawSelection)
        Hub.Config.AutoBuyGears.SelectedGearNames = normalized
        local selectedCount = getSelectedGearCount()
        if selectedCount > 0 then
            AutoBuyGearsFeature:_setStatus(string.format("Auto Buy Gears: %d gear(s) selected", selectedCount))
        else
            AutoBuyGearsFeature:_setStatus("Auto Buy Gears: No gears selected")
        end
    end

    if #GearShopItemNames > 0 then
        autoBuyGearsDropdown = autoBuyGearsGroup:AddDropdown("AutoBuyGears_SelectedGearNames", {
            Text = "Gear List",
            Values = GearShopItemNames,
            Default = selectedGearNameMapToList(Hub.Config.AutoBuyGears.SelectedGearNames),
            Multi = true,
            AllowNull = true,
            Searchable = true
        })
        autoBuyGearsDropdown:OnChanged(function(value)
            applyAutoBuyGearSelection(value)
        end)

        autoBuyGearsGroup:AddButton({
            Text = "All Gears",
            Func = function()
                local allSelected = {}
                for _, itemName in ipairs(GearShopItemNames) do
                    allSelected[itemName] = true
                end
                Hub.Config.AutoBuyGears.SelectedGearNames = allSelected
                if autoBuyGearsDropdown and type(autoBuyGearsDropdown.SetValue) == "function" then
                    pcall(function()
                        autoBuyGearsDropdown:SetValue(selectedGearNameMapToList(allSelected))
                    end)
                end
                AutoBuyGearsFeature:_setStatus(string.format("Auto Buy Gears: %d gear(s) selected", getSelectedGearCount()))
            end
        })

        autoBuyGearsGroup:AddButton({
            Text = "Clear Selection",
            Func = function()
                Hub.Config.AutoBuyGears.SelectedGearNames = {}
                if autoBuyGearsDropdown and type(autoBuyGearsDropdown.SetValue) == "function" then
                    pcall(function()
                        autoBuyGearsDropdown:SetValue({})
                    end)
                end
                AutoBuyGearsFeature:_setStatus("Auto Buy Gears: No gears selected")
            end
        })
    else
        autoBuyGearsGroup:AddLabel({
            Text = "Gear list unavailable.",
            DoesWrap = true
        })
    end

    local autoBuyGearsStatusLabel = autoBuyGearsGroup:AddLabel({
        Text = "Auto Buy Gears: Ready",
        DoesWrap = true
    })

    botanistGroup:AddToggle("AutoBotanist_Enabled", {
        Text = "Auto Botanist",
        Default = Hub.Config.AutoBotanist.Enabled
    }):OnChanged(function(value)
        setAutoBotanistEnabled(value)
    end)

    botanistGroup:AddToggle("AutoBotanist_AutoRequestQuest", {
        Text = "Auto Get Quest",
        Default = Hub.Config.AutoBotanist.AutoRequestQuest
    }):OnChanged(function(value)
        Hub.Config.AutoBotanist.AutoRequestQuest = value == true
    end)

    botanistGroup:AddToggle("AutoBotanist_AutoDonateAll", {
        Text = "Auto Quest Loop",
        Default = Hub.Config.AutoBotanist.AutoDonateAll
    }):OnChanged(function(value)
        Hub.Config.AutoBotanist.AutoDonateAll = value == true
    end)

    botanistGroup:AddToggle("AutoBotanist_AutoAppraiseHeld", {
        Text = "Auto Appraise Held",
        Default = Hub.Config.AutoBotanist.AutoAppraiseHeld
    }):OnChanged(function(value)
        Hub.Config.AutoBotanist.AutoAppraiseHeld = value == true
    end)

    botanistGroup:AddToggle("AutoBotanist_TeleportToBotanist", {
        Text = "TP If No Quest",
        Default = Hub.Config.AutoBotanist.TeleportToBotanist
    }):OnChanged(function(value)
        Hub.Config.AutoBotanist.TeleportToBotanist = value == true
    end)

    botanistGroup:AddButton({
        Text = "Get Quest Now",
        Func = function()
            local response, err = Hub.AutoBotanistFeature:_invokeQuest("GetQuest")
            if not response then
                Hub.AutoBotanistFeature:_setStatus("Auto Botanist: GetQuest failed (" .. tostring(err) .. ")")
                return
            end
            Hub.AutoBotanistFeature:_refreshQuestState(response)
            Hub.AutoBotanistFeature:_setStatus(
                string.format(
                    "Auto Botanist: Quest status - %s (%s %.2f/%.2fkg)",
                    tostring(response.Status or "unknown"),
                    tostring(Hub.AutoBotanistFeature._questMutation or "?"),
                    tonumber(Hub.AutoBotanistFeature._questTotalWeight) or 0,
                    tonumber(Hub.AutoBotanistFeature._questTargetWeight) or 0
                )
            )
        end
    })

    botanistGroup:AddButton({
        Text = "Donate Quest Once",
        Func = function()
            local donated, status, response = Hub.AutoBotanistFeature:_donateSingleMatchingTool()
            if not donated then
                Hub.AutoBotanistFeature:_setStatus("Auto Botanist: Donate skipped (" .. tostring(status or "no matching tool") .. ")")
                return
            end
            Hub.AutoBotanistFeature:_setStatus(
                string.format(
                    "Auto Botanist: Donate status - %s (%s %.2f/%.2fkg)",
                    tostring(status or (response and response.Status) or "unknown"),
                    tostring(Hub.AutoBotanistFeature._questMutation or "?"),
                    tonumber(Hub.AutoBotanistFeature._questTotalWeight) or 0,
                    tonumber(Hub.AutoBotanistFeature._questTargetWeight) or 0
                )
            )
        end
    })

    botanistGroup:AddButton({
        Text = "Appraise Held Once",
        Func = function()
            if not Hub.AutoBotanistFeature:_getHeldHarvestedTool() then
                Hub.AutoBotanistFeature:_setStatus("Auto Botanist: Equip harvested crop first")
                return
            end
            local response, err = Hub.AutoBotanistFeature:_invokeAppraise()
            if not response then
                Hub.AutoBotanistFeature:_setStatus("Auto Botanist: Appraise failed (" .. tostring(err) .. ")")
                return
            end
            Hub.AutoBotanistFeature:_setStatus("Auto Botanist: Appraise status - " .. tostring(response.Status or "unknown"))
        end
    })

    botanistGroup:AddLabel({
        Text = "<font color='#94A3B8'>Appraise cost: ~32.5% of held crop value</font>",
        DoesWrap = true
    })

    local autoBotanistStatusLabel = botanistGroup:AddLabel({
        Text = "Auto Botanist: Ready",
        DoesWrap = true
    })

    refreshSeedStockSection = refreshSeedStockStatus
    refreshGearStockSection = refreshGearStockStatus

    refreshSeedStockSection()
    refreshGearStockSection()

    smartSprinklerGroup:AddLabel({
        Text = '<font color="#F59E0B">WIP: may miss some spots.</font>',
        DoesWrap = true
    })

    local autoSprinklerToggle = smartSprinklerGroup:AddToggle("AutoSprinkler_Enabled", {
        Text = "Auto Sprinkler",
        Default = Hub.Config.AutoSprinkler.Enabled
    })
    autoSprinklerToggle:OnChanged(function(value)
        setAutoSprinklerEnabled(value)
    end)

    smartSprinklerGroup:AddButton({
        Text = "Place Now",
        Func = function()
            sprinklerLog("Manual button clicked")
            task.spawn(function()
                local ok, err = pcall(function()
                    AutoSprinklerFeature:Tick(true)
                end)
                if not ok then
                    sprinklerLog("Manual tick error: " .. tostring(err))
                    AutoSprinklerFeature:_setStatus("Smart Sprinkler: Error - " .. tostring(err))
                end
            end)
        end
    })

    smartSprinklerGroup:AddLabel({
        Text = "Basic 8 | Turbo 12 | Super 16",
        DoesWrap = true
    })

    local autoSprinklerStatusLabel = smartSprinklerGroup:AddLabel({
        Text = "Smart Sprinkler: Ready",
        DoesWrap = true
    })

    local autoSellToggle = autoSellGroup:AddToggle("AutoSell_Enabled", {
        Text = "Auto Sell",
        Default = Hub.Config.AutoSell.Enabled
    })
    autoSellToggle:OnChanged(function(value)
        setAutoSellEnabled(value)
    end)

    local autoSellStatusLabel = autoSellGroup:AddLabel({
        Text = "Auto Sell: Ready",
        DoesWrap = true
    })

    autoSellGroup:AddDivider({
        Text = "Seed Stock",
        Margin = 1
    })
    local seedStockStatusLabel = autoSellGroup:AddLabel({
        Text = "Seed Stock: Loading...\n<font color='#94A3B8'>Update Timer: --:--</font>",
        DoesWrap = true
    })
    autoSellGroup:AddButton({
        Text = "Refresh Seeds",
        Func = refreshSeedStockSection
    })

    autoSellGroup:AddDivider({
        Text = "Gear Stock",
        Margin = 1
    })
    local gearStockStatusLabel = autoSellGroup:AddLabel({
        Text = "Gear Stock: Loading...\n<font color='#94A3B8'>Update Timer: --:--</font>",
        DoesWrap = true
    })
    autoSellGroup:AddButton({
        Text = "Refresh Gears",
        Func = refreshGearStockSection
    })

    local teleportStatusLabel = teleportGroup:AddLabel({
        Text = "<font color='#93C5FD'>Teleport: Ready</font>",
        DoesWrap = true
    })

    local function updateTeleportStatus(prefix, success, reason)
        local text
        if success then
            text = string.format("<font color='#22C55E'>%s: Teleported</font>", escapeRichText(prefix))
        else
            text = string.format(
                "<font color='#EF4444'>%s: Failed (%s)</font>",
                escapeRichText(prefix),
                escapeRichText(tostring(reason or "unknown"))
            )
        end
        pcall(function()
            teleportStatusLabel:SetText(text)
        end)
    end

    teleportGroup:AddButton({
        Text = "Garden",
        Func = function()
            local ok, reason = teleportToGarden(true)
            updateTeleportStatus("Garden", ok, reason)
        end
    })

    teleportGroup:AddButton({
        Text = "Seed Shop",
        Func = function()
            local ok, reason = teleportToSeeds(true)
            updateTeleportStatus("Seed", ok, reason)
        end
    })

    teleportGroup:AddButton({
        Text = "Sell Zone",
        Func = function()
            local ok, reason = teleportToSell(true)
            updateTeleportStatus("Sell", ok, reason)
        end
    })

    teleportGroup:AddButton({
        Text = "Gear Shop",
        Func = function()
            local ok, reason = teleportToShop(true)
            updateTeleportStatus("Shop", ok, reason)
        end
    })

    teleportGroup:AddButton({
        Text = "Botanist",
        Func = function()
            local ok, reason = Hub.AutoBotanistFeature:_teleportToBotanist(true)
            updateTeleportStatus("Botanist", ok, reason)
        end
    })

    uiGroup:AddLabel({
        Text = "Toggle key: RightShift",
        DoesWrap = true
    })
    uiGroup:AddButton({
        Text = "Refresh Status",
        Func = function()
            AutoPlantFeature:_setStatus(AutoPlantFeature._statusText or "Auto Plant: Ready")
            AutoBuySeedsFeature:_setStatus(AutoBuySeedsFeature._statusText or "Auto Buy Seeds: Ready")
            AutoBuyGearsFeature:_setStatus(AutoBuyGearsFeature._statusText or "Auto Buy Gears: Ready")
            Hub.AutoBotanistFeature:_setStatus(Hub.AutoBotanistFeature._statusText or "Auto Botanist: Ready")
            AutoSprinklerFeature:_setStatus(AutoSprinklerFeature._statusText or "Smart Sprinkler: Ready")
            AutoSellFeature:_setStatus(AutoSellFeature._statusText or "Auto Sell: Ready")
            AutoHarvestFeature:_setStatus(AutoHarvestFeature._statusText or "Auto Harvest: Ready")
            AntiAFKFeature:_setStatus(AntiAFKFeature._statusText or "Anti AFK: Ready")
            Hub.FPSBoostFeature:_setStatus(Hub.FPSBoostFeature._statusText or "FPS Boost: Ready")
            PlantRankingFeature:_setStatus(PlantRankingFeature._statusText or "Scanning plot plants...")
            renderStockStatus("SeedStock", "Seed Stock", SeedShopItemDefinitions, StockStatusState.Seed)
            renderStockStatus("GearStock", "Gear Stock", GearShopItemDefinitions, StockStatusState.Gear)
            flushQueuedUILabelUpdates()
        end
    })
    uiGroup:AddButton({
        Text = "Close Hub",
        Func = function()
            unloadHub()
        end
    })

    discordGroup:AddLabel({
        Text = '<font color="#5865F2"><b>Trustsense Community</b></font>',
        DoesWrap = true
    })
    discordGroup:AddLabel({
        Text = '<font color="#5865F2"><b>discord.gg/6KVvbEYaXF</b></font>',
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

    discordGroup:AddDivider({
        Text = "Changelog",
        Margin = 1
    })
    discordGroup:AddLabel({
        Text = "<font color='#22C55E'>[NEW]</font> Ultra FPS Boost now stacks classic low-graphics tweaks with environment culling for smoother gameplay.",
        DoesWrap = true
    })
    discordGroup:AddLabel({
        Text = "<font color='#22C55E'>[NEW]</font> Auto Botanist now runs quest-smart flow: fetch quest, harvest matching mutations, then donate quest-only crops.",
        DoesWrap = true
    })

    Hub.UI = {
        Library = Library,
        ThemeManager = ThemeManager,
        SaveManager = SaveManager,
        Window = Window,
        Tabs = Tabs,
        AutoPlantStatusLabel = autoPlantStatusLabel,
        PlantRankingsLabel = plantRankingsLabel,
        AutoBuySeedsStatusLabel = autoBuySeedsStatusLabel,
        AutoBuyGearsStatusLabel = autoBuyGearsStatusLabel,
        AutoBotanistStatusLabel = autoBotanistStatusLabel,
        AutoSprinklerStatusLabel = autoSprinklerStatusLabel,
        SeedStockStatusLabel = seedStockStatusLabel,
        GearStockStatusLabel = gearStockStatusLabel,
        AutoSellStatusLabel = autoSellStatusLabel,
        AutoHarvestStatusLabel = autoHarvestStatusLabel,
        AntiAFKStatusLabel = antiAFKStatusLabel,
        FPSBoostStatusLabel = fpsBoostStatusLabel
    }

    if ThemeManager and SaveManager then
        pcall(function()
            ThemeManager:SetLibrary(Library)
            if type(ThemeManager.SetDefaultTheme) == "function" then
                ThemeManager:SetDefaultTheme(TrustsenseAuroraTheme)
            end
            SaveManager:SetLibrary(Library)
            SaveManager:IgnoreThemeSettings()

            ThemeManager:SetFolder("TrustsenseHub")
            SaveManager:SetFolder("TrustsenseHub")
            if type(SaveManager.SetSubFolder) == "function" then
                SaveManager:SetSubFolder("Garden-Horizons")
            end

            SaveManager:BuildConfigSection(Tabs.Settings)
            ThemeManager:ApplyToTab(Tabs.Settings)
            if type(ThemeManager.LoadDefault) == "function" then
                ThemeManager:LoadDefault()
            elseif type(ThemeManager.ApplyTheme) == "function" then
                ThemeManager:ApplyTheme("Default")
            end
            SaveManager:LoadAutoloadConfig()
            if type(ThemeManager.ApplyTheme) == "function" then
                ThemeManager:ApplyTheme("Default")
            end
        end)
    end

    ensureUILabelUpdateBridge()
    ensureStockTimerLoop()
    AutoPlantFeature:_setStatus(AutoPlantFeature._statusText or "Auto Plant: Ready")
    AutoBuySeedsFeature:_setStatus(AutoBuySeedsFeature._statusText or "Auto Buy Seeds: Ready")
    AutoBuyGearsFeature:_setStatus(AutoBuyGearsFeature._statusText or "Auto Buy Gears: Ready")
    Hub.AutoBotanistFeature:_setStatus(Hub.AutoBotanistFeature._statusText or "Auto Botanist: Ready")
    AutoSprinklerFeature:_setStatus(AutoSprinklerFeature._statusText or "Smart Sprinkler: Ready")
    AutoSellFeature:_setStatus(AutoSellFeature._statusText or "Auto Sell: Ready")
    AutoHarvestFeature:_setStatus(AutoHarvestFeature._statusText or "Auto Harvest: Ready")
    AntiAFKFeature:_setStatus(AntiAFKFeature._statusText or "Anti AFK: Ready")
    Hub.FPSBoostFeature:_setStatus(Hub.FPSBoostFeature._statusText or "FPS Boost: Ready")
    PlantRankingFeature:_setStatus(PlantRankingFeature._statusText or "Scanning plot plants...")
    flushQueuedUILabelUpdates()
end

task.spawn(setupObsidianUI)

task.spawn(function()
    task.wait(0.2)
    if Hub.IsUnloaded or Hub.RunId ~= CurrentRunId then
        return
    end
    setAutoPlantEnabled(Hub.Config.AutoPlant.Enabled)
    setAutoBuySeedsEnabled(Hub.Config.AutoBuySeeds.Enabled)
    setAutoBuyGearsEnabled(Hub.Config.AutoBuyGears.Enabled)
    setAutoBotanistEnabled(Hub.Config.AutoBotanist.Enabled)
    setAutoSprinklerEnabled(Hub.Config.AutoSprinkler.Enabled)
    setAutoSellEnabled(Hub.Config.AutoSell.Enabled)
    setAutoHarvestEnabled(Hub.Config.AutoHarvest.Enabled)
    setAntiAFKEnabled(Hub.Config.AntiAFK.Enabled)
    setFPSBoostEnabled(Hub.Config.FPSBoost.Enabled)
end)

return Hub
