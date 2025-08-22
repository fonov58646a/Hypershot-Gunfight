-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
-- VORTEX HUB V2.9 | ULTIMATE EDITION
-- ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

-- Load OrionLib
local OrionLib = nil
local function LoadOrion()
    pcall(function()
        OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
    end)
    if not OrionLib then
        warn("OrionLib failed to load. Please check your internet connection or try again later.")
    end
end
LoadOrion()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Remotes = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes")
local IgnoreThese = Workspace:WaitForChild("IgnoreThese")
local Pickups = IgnoreThese:WaitForChild("Pickups")

-- Global Settings
local Settings = {
    Aimbot = {
        Enabled = false,
        IsTargeting = false,
        HitChance = 100,
        Target = nil,
        hi = false
    },
    ESP = {
        Enabled = false,
        Color = Color3.fromRGB(255, 0, 0),
        Thickness = 1,
        Transparency = 0.7
    },
    Farming = {
        AutoSpawn = false,
        AutoChest = false,
        ChestType = "Diamond",
        AutoSpin = false,
        AutoPlaytime = false,
        AutoHeal = false,
        AutoCoin = false,
        AutoWeapon = false
    },
    Combat = {
        RapidFire = false,
        NoRecoil = false,
        InfAmmo = false,
        NoAbilityCD = false,
        InfProjectileSpeed = false
    },
    Misc = {
        HeadLock = false,
        AntiCheatBypass = false,
        RainbowBullets = false
    }
}

-- Save / Load Functions
local ConfigFolder = "VortXConfigs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
local ConfigFile = ConfigFolder .. "/Hypershot_" .. game.PlaceId .. ".json"

local function Save()
    writefile(ConfigFile, game:GetService("HttpService"):JSONEncode(Settings))
end

local function LoadConfig()
    if isfile(ConfigFile) then
        local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(ConfigFile)) end)
        if ok then
            for k, v in pairs(data) do
                Settings[k] = v
            end
        end
    end
end

LoadConfig()

-- Notification Function
local function Notify(Title, Text, Time)
    if OrionLib then
        OrionLib:MakeNotification({Name = Title, Content = Text, Time = Time or 5})
    else
        warn(Text)
    end
end

-- Get Enemies Function
local function GetEnemies()
    local t = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            table.insert(t, {
                Player = plr,
                Character = plr.Character,
                Head = plr.Character:FindFirstChild("Head") or hrp,
                Root = hrp
            })
        end
    end
    -- Add mobs if they exist
    local mobs = Workspace:FindFirstChild("Mobs")
    if mobs then
        for _, mob in ipairs(mobs:GetChildren()) do
            if mob:FindFirstChild("Head") then
                table.insert(t, {
                    Player = nil,
                    Character = mob,
                    Head = mob.Head,
                    Root = mob:FindFirstChild("HumanoidRootPart") or mob.Head
                })
            end
        end
    end
    return t
end

-- Silent Aim Implementation
local SilentAim = Settings.Aimbot
local oldNamecall = hookmetamethod(game, "__namecall", function(s, ...)
    local m = getnamecallmethod()
    local a = {...}
    if not checkcaller() and s == workspace and m == "Raycast" and SilentAim.Enabled and SilentAim.IsTargeting and SilentAim.Target then
        if math.random(1, 100) > SilentAim.HitChance then
            return namecall(s, ...)
        end
        local r = a[1]
        local t = SilentAim.Target.Position
        if SilentAim.hi then
            local f = {}
            f.Instance = SilentAim.Target
            f.Position = t
            f.Normal = Vector3.new(0, 1, 0)
            f.Material = Enum.Material.Plastic
            f.Distance = (t - r).Magnitude
            local p = {}
            setmetatable(p, {
                __index = function(_, k)
                    if k == "Distance" then return f.Distance end
                    if k == "Position" then return f.Position end
                    if k == "Instance" then return f.Instance end
                    return f[k]
                end
            })
            return p
        else
            local d = (t - r).Unit * 1000
            a[2] = d
            return namecall(s, unpack(a))
        end
    end
    return namecall(s, ...)
end)

-- ESP Implementation
local ESPFolder = Instance.new("Folder", Workspace)
ESPFolder.Name = "VortX_ESP"

local Drawings = {}

local function CreateESPBox(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    local espBox = Drawing.new("Square")
    espBox.Visible = false
    espBox.Thickness = Settings.ESP.Thickness
    espBox.Color = Settings.ESP.Color
    espBox.Transparency = Settings.ESP.Transparency
    espBox.Filled = false
    
    local espName = Drawing.new("Text")
    espName.Visible = false
    espName.Color = Settings.ESP.Color
    espName.Outline = true
    espName.OutlineColor = Color3.new(0, 0, 0)
    espName.Font = 2
    espName.TextSize = 14
    
    table.insert(Drawings, {espBox, espName, player})
    
    RunService.Heartbeat:Connect(function()
        if not Settings.ESP.Enabled or not player.Character then
            espBox.Visible = false
            espName.Visible = false
            return
        end
        
        local char = player.Character
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        local camera = Workspace.CurrentCamera
        local vector, onScreen = camera:WorldToViewportPoint(rootPart.Position)
        if onScreen then
            local size = Vector2.new(150, 300)
            espBox.Size = size
            espBox.Position = Vector2.new(vector.X - size.X / 2, vector.Y - size.Y / 2)
            espBox.Visible = true
            
            espName.Position = Vector2.new(vector.X, vector.Y - 30)
            espName.Text = player.Name
            espName.Visible = true
        else
            espBox.Visible = false
            espName.Visible = false
        end
    end)
end

local function ToggleESP(v)
    Settings.ESP.Enabled = v
    for _, drawing in ipairs(Drawings) do
        drawing[1].Visible = v
        drawing[2].Visible = v
    end
end

-- Rainbow Bullets Feature
local function ApplyRainbowBullets()
    if not Settings.Misc.RainbowBullets then return end
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" and rawget(v, "Color") then
            local colors = {
                Color3.fromRGB(255, 0, 0),   -- Red
                Color3.fromRGB(255, 165, 0), -- Orange
                Color3.fromRGB(255, 255, 0), -- Yellow
                Color3.fromRGB(0, 255, 0),   -- Green
                Color3.fromRGB(0, 0, 255),   -- Blue
                Color3.fromRGB(75, 0, 130),  -- Indigo
                Color3.fromRGB(238, 130, 238) -- Violet
            }
            local colorIndex = 0
            local function cycleColor()
                colorIndex = colorIndex % #colors + 1
                return colors[colorIndex]
            end
            v.Color = cycleColor()
        end
    end
end

-- Combat Mods
local function PatchTables()
    if not Settings.Combat.RapidFire then return end
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" then
            -- Rapid Fire / No Recoil
            if rawget(v, "Spread") then
                v.Spread = 0
                v.BaseSpread = 0
                v.MinCamRecoil = Vector3.new()
                v.MaxCamRecoil = Vector3.new()
                v.MinRotRecoil = Vector3.new()
                v.MaxRotRecoil = Vector3.new()
                v.ScopeSpeed = 100
            end
            -- Infinite Ammo
            if rawget(v, "Ammo") and Settings.Combat.InfAmmo then
                v.Ammo = math.huge
            end
            -- Ability No Cooldown
            if rawget(v, "CD") and Settings.Combat.NoAbilityCD then
                v.CD = 0
            end
            -- Projectile Speed
            if (rawget(v, "Speed") or rawget(v, "ProjectileSpeed")) and Settings.Combat.InfProjectileSpeed then
                v.Speed = 9e99
            end
        end
    end
end

-- Farming Loops
local FarmingLoops = {}
local function StartFarm(name, func) FarmingLoops[name] = true; while FarmingLoops[name] do func() wait() end end
local function StopFarm(name) FarmingLoops[name] = false end

local function SpawnLoop()
    while FarmingLoops.AutoSpawn do
        Remotes.Spawn:FireServer(false)
        wait(1.5)
    end
end

local function ChestLoop()
    while FarmingLoops.AutoChest do
        Remotes.OpenCase:InvokeServer(Settings.Farming.ChestType, "Random")
        wait(6)
    end
end

local function SpinLoop()
    while FarmingLoops.AutoSpin do
        Remotes.SpinWheel:InvokeServer()
        wait(5)
    end
end

local function PlaytimeLoop()
    while FarmingLoops.AutoPlaytime do
        for i = 1, 12 do
            Remotes.ClaimPlaytimeReward:FireServer(i)
            wait(1)
        end
        wait(15)
    end
end

local function PickupLoop(folderName, remoteName)
    return function()
        while FarmingLoops[remoteName] do
            local folder = Pickups:FindFirstChild(folderName)
            if folder then
                for _, obj in ipairs(folder:GetChildren()) do
                    Remotes[remoteName]:FireServer(obj)
                end
            end
            wait(0.3)
        end
    end
end

-- Head-Lock / Bring All
local HeadLockConn
local function StartHeadLock()
    HeadLockConn = RunService.RenderStepped:Connect(function()
        if not Settings.Misc.HeadLock then return end
        local cam = Workspace.CurrentCamera
        for _, enemy in ipairs(GetEnemies()) do
            enemy.Head.CFrame = cam.CFrame + cam.CFrame.LookVector * 5
        end
    end)
end

local function StopHeadLock()
    if HeadLockConn then HeadLockConn:Disconnect(); HeadLockConn = nil end
end

-- UI
if OrionLib then
    local Window = OrionLib:MakeWindow({
        Name = "VortX Hub V2.9 – HyperShot",
        ConfigFolder = ConfigFolder,
        SaveConfig = true,
        HidePremium = true
    })

    local Tabs = {
        Main = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"}),
        Visuals = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998"}),
        Farming = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483345998"}),
        Settings = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"}),
        Info = Window:MakeTab({Name = "Info", Icon = "rbxassetid://4483345998"})
    }

    -- Combat
    local AimSec = Tabs.Main:AddSection({Name = "Silent Aim"})
    AimSec:AddToggle({Name = "Enable Silent Aim", Default = Settings.Aimbot.Enabled, Callback = function(v)
        Settings.Aimbot.Enabled = v
        Save()
    end})
    AimSec:AddSlider({Name = "Hit Chance", Min = 1, Max = 100, Default = Settings.Aimbot.HitChance, Callback = function(v) Settings.Aimbot.HitChance = v; Save() end})
    AimSec:AddToggle({Name = "Hitbox Mode", Default = Settings.Aimbot.hi, Callback = function(v) Settings.Aimbot.hi = v; Save() end})

    local CombatSec = Tabs.Main:AddSection({Name = "Combat Mods"})
    CombatSec:AddToggle({Name = "Rapid Fire + No Recoil", Default = Settings.Combat.RapidFire, Callback = function(v)
        Settings.Combat.RapidFire = v
        PatchTables()
        Save()
    end})
    CombatSec:AddToggle({Name = "Infinite Ammo", Default = Settings.Combat.InfAmmo, Callback = function(v) Settings.Combat.InfAmmo = v; Save(); PatchTables() end})
    CombatSec:AddToggle({Name = "No Ability Cooldown", Default = Settings.Combat.NoAbilityCD, Callback = function(v) Settings.Combat.NoAbilityCD = v; Save(); PatchTables() end})
    CombatSec:AddToggle({Name = "Inf Projectile Speed", Default = Settings.Combat.InfProjectileSpeed, Callback = function(v) Settings.Combat.InfProjectileSpeed = v; Save(); PatchTables() end})
    CombatSec:AddToggle({Name = "Bring All / Head-Lock", Default = Settings.Misc.HeadLock, Callback = function(v)
        Settings.Misc.HeadLock = v
        if v then StartHeadLock() else StopHeadLock() end
        Save()
    end})

    -- Visuals
    local VisSec = Tabs.Visuals:AddSection({Name = "ESP"})
    VisSec:AddToggle({Name = "Enable ESP", Default = Settings.ESP.Enabled, Callback = function(v)
        Settings.ESP.Enabled = v
        if v then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    CreateESPBox(player)
                end
            end
        else
            for _, drawing in ipairs(Drawings) do
                drawing[1]:Remove()
                drawing[2]:Remove()
            end
            Drawings = {}
        end
        Save()
    end})
    VisSec:AddColorpicker({Name = "ESP Color", Default = Settings.ESP.Color, Callback = function(v)
        Settings.ESP.Color = v
        for _, drawing in ipairs(Drawings) do
            drawing[1].Color = v
            drawing[2].Color = v
        end
        Save()
    end})
    VisSec:AddSlider({Name = "ESP Thickness", Min = 0.1, Max = 5, Default = Settings.ESP.Thickness, Callback = function(v)
        Settings.ESP.Thickness = v
        for _, drawing in ipairs(Drawings) do
            drawing[1].Thickness = v
        end
        Save()
    end})

    local RainbowSec = Tabs.Visuals:AddSection({Name = "Rainbow Bullets"})
    RainbowSec:AddToggle({Name = "Rainbow Bullets", Default = Settings.Misc.RainbowBullets, Callback = function(v)
        Settings.Misc.RainbowBullets = v
        if v then ApplyRainbowBullets() end
        Save()
    end})

    -- Farming
    local FarmSec = Tabs.Farming:AddSection({Name = "Auto Farm"})
    FarmSec:AddToggle({Name = "Auto Spawn", Default = Settings.Farming.AutoSpawn, Callback = function(v)
        Settings.Farming.AutoSpawn = v
        if v then StartFarm("AutoSpawn", SpawnLoop) else StopFarm("AutoSpawn") end
        Save()
    end})
    FarmSec:AddToggle({Name = "Auto Open Chest", Default = Settings.Farming.AutoChest, Callback = function(v)
        Settings.Farming.AutoChest = v
        if v then StartFarm("AutoChest", ChestLoop) else StopFarm("AutoChest") end
        Save()
    end})
    FarmSec:AddDropdown({Name = "Chest Type", Options = {"Wooden","Bronze","Silver","Gold","Diamond"}, Default = Settings.Farming.ChestType, Callback = function(v) Settings.Farming.ChestType = v; Save() end})
    FarmSec:AddToggle({Name = "Auto Spin Wheel", Default = Settings.Farming.AutoSpin, Callback = function(v) Settings.Farming.AutoSpin = v; if v then StartFarm("AutoSpin", SpinLoop) else StopFarm("AutoSpin") end; Save() end})
    FarmSec:AddToggle({Name = "Auto Playtime Award", Default = Settings.Farming.AutoPlaytime, Callback = function(v) Settings.Farming.AutoPlaytime = v; if v then StartFarm("AutoPlaytime", PlaytimeLoop) else StopFarm("AutoPlaytime") end; Save() end})
    FarmSec:AddToggle({Name = "Auto Pickup Heal", Default = Settings.Farming.AutoHeal, Callback = function(v)
        Settings.Farming.AutoHeal = v
        if v then StartFarm("AutoHeal", PickupLoop("Heals", "PickUpHeal")) else StopFarm("AutoHeal") end
        Save()
    end})
    FarmSec:AddToggle({Name = "Auto Pickup Coin", Default = Settings.Farming.AutoCoin, Callback = function(v)
        Settings.Farming.AutoCoin = v
        if v then StartFarm("AutoCoin", PickupLoop("Coins", "PickUpCoins")) else StopFarm("AutoCoin") end
        Save()
    end})
    FarmSec:AddToggle({Name = "Auto Pickup Weapon", Default = Settings.Farming.AutoWeapon, Callback = function(v)
        Settings.Farming.AutoWeapon = v
        if v then StartFarm("AutoWeapon", PickupLoop("Weapons", "PickUpWeapons")) else StopFarm("AutoWeapon") end
        Save()
    end})

    -- Settings
    Tabs.Settings:AddButton({Name = "Unload Script", Callback = function()
        OrionLib:Destroy()
        for k in pairs(FarmingLoops) do StopFarm(k) end
        for _, drawing in ipairs(Drawings) do
            drawing[1]:Remove()
            drawing[2]:Remove()
        end
        Drawings = {}
        StopHeadLock()
        Notify("VortX Hub", "Unloaded safely.", 3)
    end})

    -- Info
    Tabs.Info:AddLabel({Name = "Version: V2.9"})
    Tabs.Info:AddLabel({Name = "Features:"})
    Tabs.Info:AddLabel({Name = "- Silent Aim with Hitbox Prediction"})
    Tabs.Info:AddLabel({Name = "- Custom ESP without loadstring"})
    Tabs.Info:AddLabel({Name = "- Rainbow Bullets"})
    Tabs.Info:AddLabel({Name = "- Improved Combat and Farming Mods"})

    -- Initialize OrionLib
    OrionLib:Init()
else
    warn("OrionLib could not be loaded. GUI features are disabled.")
end

-- Initialize ESP Boxes for all players
if Settings.ESP.Enabled then
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            CreateESPBox(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    if Settings.ESP.Enabled and player ~= LocalPlayer then
        task.wait(1)
        CreateESPBox(player)
    end
end)

Notify("VortX Hub V2.9", "Loaded successfully! Enjoy the game.", 5)
