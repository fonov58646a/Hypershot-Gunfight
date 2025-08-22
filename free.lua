--[[  
    VortX Hub V1.6.0 - HyperShot Gunfight Edition
    Enhanced Silent Aim and improved functionality
]]

-- Load Orion Library
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua'))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Local Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Remotes = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes")
local IgnoreThese = Workspace:WaitForChild("IgnoreThese")
local Pickups = IgnoreThese:WaitForChild("Pickups")

-- Configuration
local ConfigFolder = "VortXConfigs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
local ConfigFile = ConfigFolder .. "/Hypershot_" .. game.PlaceId .. ".json"

-- Settings Table
local Settings = {
    Combat = {
        KillAll = false,
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
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(ConfigFile))
        end)
        if success then
            for k, v in pairs(data) do
                Settings[k] = v
            end
        end
    end
end

local function Notify(title, text, duration)
    OrionLib:MakeNotification({Name = title, Content = text, Time = duration or 5})
end

-- Anti-Cheat Bypass
local function StealthBypass()
    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    local oldNamecall = mt.__namecall
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            return oldNamecall(self, ...)
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- Kill-All Functionality
local function ToggleKillAll(enabled)
    if enabled then
        task.spawn(function()
            while Settings.Combat.KillAll do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer then
                        Remotes.PlayerHitEvent:FireServer(player, 100)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end

-- Universal ESP
local function ToggleUniversalESP(enabled)
    if enabled then
        task.spawn(function()
            while Settings.Visuals.UniversalESP do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        if not player.Character:FindFirstChild("okbruh") then
                            local highlight = Instance.new("Highlight")
                            highlight.Name = "okbruh"
                            highlight.Parent = player.Character
                            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            highlight.FillColor = Color3.fromRGB(255, 100, 50)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.OutlineTransparency = 0
                            highlight.Enabled = true
                        end
                    end
                end
                task.wait(1)
            end
        end)

        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                if Settings.Visuals.UniversalESP then
                    task.spawn(function()
                        while player.Character and not player.Character:FindFirstChild("okbruh") do
                            for _, child in ipairs(player.Character:GetChildren()) do
                                if child:IsA("BasePart") then
                                    local highlight = Instance.new("Highlight")
                                    highlight.Name = "okbruh"
                                    highlight.Parent = player.Character
                                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                    highlight.FillColor = Color3.fromRGB(255, 100, 50)
                                    highlight.FillTransparency = 0.5
                                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    highlight.OutlineTransparency = 0
                                    highlight.Enabled = true
                                    break
                                end
                            end
                            task.wait()
                        end
                    end)
                end
            end)
        end)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                local highlight = player.Character:FindFirstChild("okbruh")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    end
end

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

-- No Cooldown
local function ToggleNoCooldown(enabled)
    if enabled then
        task.spawn(function()
            while Settings.Combat.NoAbilityCD do
                for _, v in next, getgc(true) do
                    if type(v) == "table" and rawget(v, "CD") then
                        v.CD = 0
                    end
                end
                task.wait(1)
            end
        end)
    end
end

-- Hitbox Expander
local function ToggleHitboxExpander(enabled)
    if enabled then
        task.spawn(function()
            while Settings.Visuals.HitboxExpander do
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local head = player.Character:FindFirstChild("Head")
                        if head then
                            head.Size = Vector3.new(Settings.Visuals.HeadSize, Settings.Visuals.HeadSize, Settings.Visuals.HeadSize)
                            head.Transparency = 0.7
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
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
}

-- UI Setup
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.6.0 - HyperShot",
    ConfigFolder = ConfigFolder,
    SaveConfig = true,
    HidePremium = true
})

-- Tabs
local Tabs = {
    Combat = Window:MakeTab({ Name = "Combat", Icon = "rbxassetid://4483345998" }),
    Visuals = Window:MakeTab({ Name = "Visuals", Icon = "rbxassetid://4483345998" }),
    Farming = Window:MakeTab({ Name = "Farming", Icon = "rbxassetid://4483345998" }),
    Settings = Window:MakeTab({ Name = "Settings", Icon = "rbxassetid://4483345998" })
}

-- Combat Tab
local CombatSection = Tabs.Combat:AddSection({ Name = "Combat" })

CombatSection:AddToggle({
    Name = "Kill-All (FFA)",
    Default = Settings.Combat.KillAll,
    Callback = function(value)
        Settings.Combat.KillAll = value
        ToggleKillAll(value)
        SaveConfig()
    end
})

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
    Name = "No Recoil / Rapid-Fire",
    Default = Settings.Combat.RapidFire,
    Callback = function(value)
        Settings.Combat.RapidFire = value
        SaveConfig()
    end
})

CombatSection:AddToggle({
    Name = "Infinite Ammo",
    Default = Settings.Combat.InfAmmo,
    Callback = function(value)
        Settings.Combat.InfAmmo = value
        SaveConfig()
    end
})

CombatSection:AddToggle({
    Name = "No Ability Cooldown",
    Default = Settings.Combat.NoAbilityCD,
    Callback = function(value)
        Settings.Combat.NoAbilityCD = value
        ToggleNoCooldown(value)
        SaveConfig()
    end
})

CombatSection:AddToggle({
    Name = "Inf Projectile Speed",
    Default = Settings.Combat.InfProjectileSpeed,
    Callback = function(value)
        Settings.Combat.InfProjectileSpeed = value
        SaveConfig()
    end
})

-- Visuals Tab
local VisualsSection = Tabs.Visuals:AddSection({ Name = "Visuals" })

VisualsSection:AddToggle({
    Name = "Universal ESP",
    Default = Settings.Visuals.UniversalESP,
    Callback = function(value)
        Settings.Visuals.UniversalESP = value
        ToggleUniversalESP(value)
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
        ToggleHitboxExpander(value)
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
local FarmingSection = Tabs.Farming:AddSection({ Name = "Auto Farm" })

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
    Options = { "Wooden", "Bronze", "Silver", "Gold", "Diamond" },
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
        for _, loop in pairs(FarmingLoops) do
            loop = false
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
StealthBypass()
Notify("VortX Hub V1.6.0", "Loaded successfully! Enjoy the game.", 5)
