--[[  
    VortX Hub V1.7.0 - HyperShot Gunfight Edition
]]

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes")
local Pickups = Workspace:WaitForChild("IgnoreThese"):WaitForChild("Pickups")

-- Configuration
local ConfigFolder = "VortXConfigs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
local ConfigFile = ConfigFolder .. "/Hypershot_" .. game.PlaceId .. ".json"

-- Settings Table
local Settings = {
    Combat = {
        RapidFire = false,
        NoRecoil = false,
        InfAmmo = false,
        NoAbilityCD = false,
        InfProjectileSpeed = false,
        SilentAim = {
            Enabled = false,
            HitChance = 100,
            IsTargeting = false,
            Target = nil,
            hi = true
        }
    },
    Visuals = {
        UniversalESP = false,
        RainbowBullet = false,
        HitboxExpander = false,
        HeadSize = 20
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
    }
}

-- Utility Functions
local function SaveConfig()
    writefile(ConfigFile, game:GetService("HttpService"):JSONEncode(Settings))
end

local function LoadConfig()
    if isfile(ConfigFile) then
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(ConfigFile))
        end)
        if ok then
            for k, v in pairs(data) do
                Settings[k] = v
            end
        end
    end
end
LoadConfig()

local function Notify(title, text, duration)
    OrionLib:MakeNotification({Name = title, Content = text, Time = duration or 5})
end

-- Enhanced Silent Aim
local SilentAim = Settings.Combat.SilentAim
local originalHook

local function ToggleSilentAim(enabled)
    if enabled then
        originalHook = hookmetamethod(game, "__namecall", function(s, ...)
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
    else
        if originalHook then
            hookmetamethod(game, "__namecall", originalHook)
            originalHook = nil
        end
    end
end

-- Load Universal ESP
local ESP_UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/zzerexx/scripts/main/UniversalEspUI.lua"))()

-- Rainbow Bullet
local function ToggleRainbowBullet(enabled)
    if enabled then
        task.spawn(function()
            while Settings.Visuals.RainbowBullet do
                for _, bullet in ipairs(Workspace:GetDescendants()) do
                    if bullet:IsA("BasePart") and (bullet.Name:lower():find("bullet") or bullet.Name:lower():find("projectile")) then
                        if not bullet:FindFirstChild("RainbowScript") then
                            local script = Instance.new("Script")
                            script.Name = "RainbowScript"
                            script.Source = [[
                                local bullet = script.Parent
                                local hue = 0
                                while true do
                                    bullet.Color = Color3.fromHSV(hue % 1, 1, 1)
                                    hue = hue + 0.005
                                    task.wait(0.01)
                                end
                            ]]
                            script.Parent = bullet
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end

-- Remake No Cooldown and Rapid Fire
local function PatchTables()
    for _, v in next, getgc(true) do
        if type(v) == "table" then
            -- RapidFire / Anti-Recoil
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

-- Farming Functions
local FarmingLoops = {}

local function ToggleFarm(name, func)
    if Settings.Farming[name] then
        FarmingLoops[name] = true
        task.spawn(function()
            while FarmingLoops[name] do
                func()
                task.wait()
            end
        end)
    else
        FarmingLoops[name] = false
    end
end

local function SetupFarmingToggles()
    ToggleFarm("AutoSpawn", function()
        Remotes.Spawn:FireServer(false)
        task.wait(1.5)
    end)

    ToggleFarm("AutoChest", function()
        Remotes.OpenCase:InvokeServer(Settings.Farming.ChestType, "Random")
        task.wait(6)
    end)

    ToggleFarm("AutoSpin", function()
        Remotes.SpinWheel:InvokeServer()
        task.wait(5)
    end)

    ToggleFarm("AutoPlaytime", function()
        for i = 1, 12 do
            Remotes.ClaimPlaytimeReward:FireServer(i)
            task.wait(1)
        end
        task.wait(15)
    end)

    ToggleFarm("AutoHeal", function()
        local healsFolder = Pickups:FindFirstChild("Heals")
        if healsFolder then
            for _, heal in ipairs(healsFolder:GetChildren()) do
                Remotes.PickUpHeal:FireServer(heal)
            end
        end
        task.wait(0.3)
    end)

    ToggleFarm("AutoCoin", function()
        local coinsFolder = Pickups:FindFirstChild("Coins")
        if coinsFolder then
            for _, coin in ipairs(coinsFolder:GetChildren()) do
                Remotes.PickUpCoins:FireServer(coin)
            end
        end
        task.wait(0.3)
    end)

    ToggleFarm("AutoWeapon", function()
        local weaponsFolder = Pickups:FindFirstChild("Weapons")
        if weaponsFolder then
            for _, weapon in ipairs(weaponsFolder:GetChildren()) do
                Remotes.PickUpWeapons:FireServer(weapon)
            end
        end
        task.wait(0.3)
    end)
end

-- UI Setup
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.7.0 - HyperShot",
    ConfigFolder = ConfigFolder,
    SaveConfig = true,
    HidePremium = true
})

local Tabs = {
    Combat = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"}),
    Visuals = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998"}),
    Farming = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483345998"}),
    Settings = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})
}

-- Combat Tab
local CombatSection = Tabs.Combat:AddSection({Name = "Combat"})

CombatSection:AddToggle({
    Name = "Silent Aim",
    Default = Settings.Combat.SilentAim.Enabled,
    Callback = function(value)
        Settings.Combat.SilentAim.Enabled = value
        ToggleSilentAim(value)
        SaveConfig()
    end
})

CombatSection:AddSlider({
    Name = "Silent Aim Hit-Chance",
    Min = 0,
    Max = 100,
    Default = Settings.Combat.SilentAim.HitChance,
    Callback = function(value)
        Settings.Combat.SilentAim.HitChance = value
        SaveConfig()
    end
})

CombatSection:AddToggle({
    Name = "Rapid Fire + No Recoil",
    Default = Settings.Combat.RapidFire,
    Callback = function(value)
        Settings.Combat.RapidFire = value
        if value then PatchTables() end
        SaveConfig()
    end
})

CombatSection:AddToggle({
    Name = "Infinite Ammo",
    Default = Settings.Combat.InfAmmo,
    Callback = function(value)
        Settings.Combat.InfAmmo = value
        SaveConfig()
        PatchTables()
    end
})

CombatSection:AddToggle({
    Name = "No Ability Cooldown",
    Default = Settings.Combat.NoAbilityCD,
    Callback = function(value)
        Settings.Combat.NoAbilityCD = value
        SaveConfig()
        PatchTables()
    end
})

CombatSection:AddToggle({
    Name = "Inf Projectile Speed",
    Default = Settings.Combat.InfProjectileSpeed,
    Callback = function(value)
        Settings.Combat.InfProjectileSpeed = value
        SaveConfig()
        PatchTables()
    end
})

-- Visuals Tab
local VisualsSection = Tabs.Visuals:AddSection({Name = "Visuals"})

VisualsSection:AddToggle({
    Name = "Universal ESP",
    Default = Settings.Visuals.UniversalESP,
    Callback = function(value)
        Settings.Visuals.UniversalESP = value
        SaveConfig()
    end
})

VisualsSection:AddToggle({
    Name = "Rainbow Bullet",
    Default = Settings.Visuals.RainbowBullet,
    Callback = function(value)
        Settings.Visuals.RainbowBullet = value
        ToggleRainbowBullet(value)
        SaveConfig()
    end
})

VisualsSection:AddToggle({
    Name = "Hitbox Expander",
    Default = Settings.Visuals.HitboxExpander,
    Callback = function(value)
        Settings.Visuals.HitboxExpander = value
        SaveConfig()
    end
})

VisualsSection:AddSlider({
    Name = "Head Size",
    Min = 3,
    Max = 50,
    Default = Settings.Visuals.HeadSize,
    Callback = function(value)
        Settings.Visuals.HeadSize = value
        SaveConfig()
    end
})

-- Farming Tab
local FarmingSection = Tabs.Farming:AddSection({Name = "Auto Farm"})

FarmingSection:AddToggle({
    Name = "Auto Spawn",
    Default = Settings.Farming.AutoSpawn,
    Callback = function(value)
        Settings.Farming.AutoSpawn = value
        SetupFarmingToggles()
        SaveConfig()
    end
})

FarmingSection:AddToggle({
    Name = "Auto Open Chest",
    Default = Settings.Farming.AutoChest,
    Callback = function(value)
        Settings.Farming.AutoChest = value
        SetupFarmingToggles()
        SaveConfig()
    end
})

FarmingSection:AddDropdown({
    Name = "Chest Type",
    Options = {"Wooden", "Bronze", "Silver", "Gold", "Diamond"},
    Default = Settings.Farming.ChestType,
    Callback = function(value)
        Settings.Farming.ChestType = value
        SaveConfig()
    end
})

FarmingSection:AddToggle({
    Name = "Auto Spin Wheel",
    Default = Settings.Farming.AutoSpin,
    Callback = function(value)
        Settings.Farming.AutoSpin = value
        SetupFarmingToggles()
        SaveConfig()
    end
})

FarmingSection:AddToggle({
    Name = "Auto Playtime Award",
    Default = Settings.Farming.AutoPlaytime,
    Callback = function(value)
        Settings.Farming.AutoPlaytime = value
        SetupFarmingToggles()
        SaveConfig()
    end
})

FarmingSection:AddToggle({
    Name = "Auto Pickup Heal",
    Default = Settings.Farming.AutoHeal,
    Callback = function(value)
        Settings.Farming.AutoHeal = value
        SetupFarmingToggles()
        SaveConfig()
    end
})

FarmingSection:AddToggle({
    Name = "Auto Pickup Coin",
    Default = Settings.Farming.AutoCoin,
    Callback = function(value)
        Settings.Farming.AutoCoin = value
        SetupFarmingToggles()
        SaveConfig()
    end
})

FarmingSection:AddToggle({
    Name = "Auto Pickup Weapon",
    Default = Settings.Farming.AutoWeapon,
    Callback = function(value)
        Settings.Farming.AutoWeapon = value
        SetupFarmingToggles()
        SaveConfig()
    end
})

-- Settings Tab
Tabs.Settings:AddButton({
    Name = "Unload Script",
    Callback = function()
        OrionLib:Destroy()
        for k in pairs(FarmingLoops) do
            FarmingLoops[k] = false
        end
        if originalHook then
            hookmetamethod(game, "__namecall", originalHook)
            originalHook = nil
        end
        Notify("VortX Hub", "Unloaded safely.", 3)
    end
})

-- Initialize
LoadConfig()
OrionLib:Init()
Notify("VortX Hub V1.7.0", "Loaded successfully! Enjoy the game.", 5)
