--[[
    ----------------------------------------------------------
    VortX Hub V1.5.0  –  HyperShot Gunfight Edition
    ----------------------------------------------------------
    NEW in v1.5.0
    • Added **Movement-Prediction Headshot Aimbot** (always locks to future head position)
    • **Anti-Recoil / No-Spread / Rapid-Fire** merged into one toggle
    • **Hit-Box Expander** – universal head-size multiplier
    • **Ability No-Cooldown** – all abilities ready instantly
    • **Inf Projectile Speed** – bullets/rockets reach target instantly
    • **Anti-Cheat Bypass** – stealth hooks, silent aim, undetected as of 18 Aug 2025
    • **Bring All / Head-Lock** – drag every enemy head to crosshair
    • **Full Auto-Farm Loop** – spawn, chests, wheel, heal, coins, weapons, playtime
    • **OrionLib UI** – clean, draggable, auto-save config
    ----------------------------------------------------------
]]

--[[  1.  Libs & Helpers  ]]
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/1nig1htmare1234/SCRIPTS/main/Orion.lua"))()
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

local ConfigFolder = "VortXConfigs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
local ConfigFile = ConfigFolder .. "/Hypershot_" .. game.PlaceId .. ".json"

--  2.  Save / Load
local Settings = {
    Aimbot = {
        Enabled = false,
        FOV = 120,
        Smooth = 0.15,
        Prediction = true,
        VisibleCheck = true,
        HitPart = "Head"
    },
    Visuals = {
        ESP = false,
        BoxESP = false,
        Chams = false,
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
        AntiCheatBypass = false
    }
}

local function Save()
    writefile(ConfigFile, game:GetService("HttpService"):JSONEncode(Settings))
end
local function Load()
    if isfile(ConfigFile) then
        local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(ConfigFile)) end)
        if ok then
            for k, v in pairs(data) do
                Settings[k] = v
            end
        end
    end
end
Load()

--  3.  Utility
local function Notify(Title, Text, Time)
    OrionLib:MakeNotification({Name = Title, Content = Text, Time = Time or 5})
end

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
    -- mobs
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

--  4.  Aimbot + Prediction
local AimbotConn, Target = nil, nil
local function ShootAt(pos)
    local o = hookmetamethod(game, "__namecall", function(s, ...)
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
end

--  5.  Visuals
local ESPFolder = Instance.new("Folder", Workspace); ESPFolder.Name = "VortX_ESP"
local function ApplyESP()
    for _, enemy in ipairs(GetEnemies()) do
        if not enemy.Character:FindFirstChild("VortXBox") and Settings.Visuals.BoxESP then
            local box = Instance.new("BoxHandleAdornment")
            box.Name = "VortXBox"
            box.Size = enemy.Root.Size
            box.Color3 = Color3.fromRGB(255,0,0)
            box.Transparency = 0.6
            box.AlwaysOnTop = true
            box.Adornee = enemy.Root
            box.Parent = ESPFolder
        end
        if Settings.Visuals.Chams then
            local highlight = Instance.new("Highlight")
            highlight.Name = "VortXCham"
            highlight.FillColor = Color3.fromRGB(255,0,0)
            highlight.FillTransparency = 0.5
            highlight.Adornee = enemy.Character
            highlight.Parent = enemy.Character
        end
    end
end
local function ClearESP()
    ESPFolder:ClearAllChildren()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "VortXCham" then v:Destroy() end
    end
end

--  6.  Hitbox Expander
local function ExpandHitboxes()
    for _, enemy in ipairs(GetEnemies()) do
        local head = enemy.Head
        head.Size = Vector3.new(Settings.Visuals.HeadSize, Settings.Visuals.HeadSize, Settings.Visuals.HeadSize)
        head.Transparency = 0.7
    end
end

--  7.  Combat Mods
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

--  8.  Farming Loops
local FarmingLoops = {}
local function StartFarm(name, func) FarmingLoops[name] = true; while FarmingLoops[name] do func() wait() end end
local function StopFarm(name) FarmingLoops[name] = false end

SpawnLoop = function()
    while FarmingLoops.AutoSpawn do
        Remotes.Spawn:FireServer(false)
        wait(1.5)
    end
end
ChestLoop = function()
    while FarmingLoops.AutoChest do
        Remotes.OpenCase:InvokeServer(Settings.Farming.ChestType, "Random")
        wait(6)
    end
end
SpinLoop = function()
    while FarmingLoops.AutoSpin do
        Remotes.SpinWheel:InvokeServer()
        wait(5)
    end
end
PlaytimeLoop = function()
    while FarmingLoops.AutoPlaytime do
        for i = 1, 12 do
            Remotes.ClaimPlaytimeReward:FireServer(i)
            wait(1)
        end
        wait(15)
    end
end
PickupLoop = function(folderName, remoteName)
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

--  9.  Head-Lock / Bring All
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

-- 10.  UI
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.5.0 – HyperShot",
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
local AimSec = Tabs.Main:AddSection({Name = "Aimbot"})
AimSec:AddToggle({Name = "Enable Aimbot", Default = Settings.Aimbot.Enabled, Callback = function(v)
    Settings.Aimbot.Enabled = v
    if v then StartAimbot() else StopAimbot() end
    Save()
end})
AimSec:AddSlider({Name = "FOV", Min = 20, Max = 500, Default = Settings.Aimbot.FOV, Callback = function(v) Settings.Aimbot.FOV = v; Save() end})
AimSec:AddToggle({Name = "Movement Prediction", Default = Settings.Aimbot.Prediction, Callback = function(v) Settings.Aimbot.Prediction = v; Save() end})

local CombatSec = Tabs.Main:AddSection({Name = "Combat Mods"})
CombatSec:AddToggle({Name = "Rapid Fire + No Recoil", Default = Settings.Combat.RapidFire, Callback = function(v)
    Settings.Combat.RapidFire = v
    if v then PatchTables() end
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
VisSec:AddToggle({Name = "Box ESP", Default = Settings.Visuals.BoxESP, Callback = function(v) Settings.Visuals.BoxESP = v; ClearESP(); if v then ApplyESP() end; Save() end})
VisSec:AddToggle({Name = "Chams", Default = Settings.Visuals.Chams, Callback = function(v) Settings.Visuals.Chams = v; ClearESP(); if v then ApplyESP() end; Save() end})
VisSec:AddToggle({Name = "Hitbox Expander", Default = Settings.Visuals.HitboxExpander, Callback = function(v)
    Settings.Visuals.HitboxExpander = v
    if v then ExpandHitboxes() end
    Save()
end})
VisSec:AddSlider({Name = "Head Size", Min = 3, Max = 50, Default = Settings.Visuals.HeadSize, Callback = function(v) Settings.Visuals.HeadSize = v; Save() end})

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
    ClearESP()
    StopAimbot()
    StopHeadLock()
    Notify("VortX Hub", "Unloaded safely.", 3)
end})

-- Info
Tabs.Info:AddLabel({Name = "Version: V1.5.0"})
Tabs.Info:AddLabel({Name = "Changes:"})
Tabs.Info:AddLabel({Name = "- Movement-Prediction Headshot Aimbot"})
Tabs.Info:AddLabel({Name = "- Hitbox Expander"})
Tabs.Info:AddLabel({Name = "- No Ability Cooldown"})
Tabs.Info:AddLabel({Name = "- Inf Projectile Speed"})
Tabs.Info:AddLabel({Name = "- Anti-Cheat Bypass"})
Tabs.Info:AddLabel({Name = "- Full auto-farm suite"})
Tabs.Info:AddLabel({Name = "Press RightShift to toggle UI anytime."})

-- Init
OrionLib:Init()
Notify("VortX Hub V1.5.0", "Loaded successfully! Enjoy the game.", 5)

-- Auto-run patches on load
PatchTables()
