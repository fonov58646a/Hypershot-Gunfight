-- Load Orion Library
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

-- Game Services
local a = game:GetService("UserInputService")
local b = game:GetService("RunService")
local c = game:GetService("Players")
local d = c.LocalPlayer
local e = workspace.CurrentCamera
local f = workspace
local g = getgenv().hypershotlum.silentaim

-- Silent Aim Configuration
getgenv().hypershotlum = {
    silentaim = {
        enabled = true,
        teamcheck = true,
        wallcheck = false,
        fov = 200,
        showfov = true,
        showsnapline = true,
        fovcolor = Color3.fromRGB(1, 1, 1),
        snapcolor = Color3.fromRGB(1, 1, 1),
        hitchance = 100,
        hitpart = "Head",
        dynamicfov = false,
        magicbullet = true,
        visibilitycheck = false
    },
    bighead = {
        enabled = false,
        size = 3
    },
    tpall = {
        players = false,
        bots = false,
        teamcheck = false,
        offset = 5,
        tpweapons = false
    }
}

-- Drawing Elements for Silent Aim
local i = Drawing.new("Circle")
i.Radius = g.fov
i.Color = g.fovcolor
i.Thickness = 1
i.Filled = false
i.Transparency = 0
i.Visible = g.showfov
i.ZIndex = 3

local j = Drawing.new("Circle")
j.Radius = g.fov
j.Color = Color3.new(0, 0, 0)
j.Thickness = 2.5
j.Filled = false
j.Transparency = 1
j.Visible = g.showfov
j.ZIndex = 1

local k = Drawing.new("Line")
k.Color = g.snapcolor
k.Thickness = 1
k.Transparency = 0
k.Visible = g.showsnapline
k.ZIndex = 3

local l = Drawing.new("Line")
l.Color = Color3.new(0, 0, 0)
l.Thickness = 2.5
l.Transparency = 1
l.Visible = g.showsnapline
l.ZIndex = 1

-- Helper Functions
local function m(n)
    if not g.visibilitycheck then return true end
    local o = e.CFrame.Position
    local p = (n.Position - o).Unit * 1000
    local q = RaycastParams.new()
    q.FilterDescendantsInstances = {d.Character}
    q.FilterType = Enum.RaycastFilterType.Blacklist
    local r = f:Raycast(o, p, q)
    if r then
        local s = r.Instance
        return s:IsDescendantOf(n.Parent)
    end
    return true
end

local function t(u)
    if not g.teamcheck then return true end
    local v = d:GetAttribute("Team")
    if not v then return true end
    local w = nil
    if typeof(u) == "Instance" then
        w = u:GetAttribute("Team")
        if not w and u:IsA("Model") then
            local x = c:GetPlayerFromCharacter(u)
            if x then w = x:GetAttribute("Team") end
        end
    end
    if not w then return true end
    return v ~= w
end

local function y(z)
    local aa, ab = e:WorldToViewportPoint(z)
    return Vector2.new(aa.X, aa.Y), ab
end

local function ac(ad)
    local ae = ad and ad:FindFirstChildOfClass("Humanoid")
    return ae and ae.Health > 0
end

local function af(ag)
    if not ag then return nil end
    local ah = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}
    local ai = {}
    for _, aj in pairs(ah) do
        local ak = ag:FindFirstChild(aj)
        if ak then table.insert(ai, ak) end
    end
    if #ai > 0 then
        return ai[math.random(1, #ai)]
    else
        return ag:FindFirstChild("Head") or ag:FindFirstChild("HumanoidRootPart")
    end
end

local function al(am)
    if not am then return nil end
    if g.hitpart == "Random" then
        return af(am)
    else
        return am:FindFirstChild(g.hitpart)
    end
end

local function an()
    local ao = Vector2.new(e.ViewportSize.X / 2, e.ViewportSize.Y / 2)
    local ap = nil
    local aq = g.fov
    for _, ar in pairs(f:GetChildren()) do
        if ar:IsA("Model") and ar:FindFirstChild(h.aimbone) and ac(ar) then
            if not d.Character or ar ~= d.Character then
                if t(ar) then
                    local as = ar[h.aimbone]
                    local at, au = y(as.Position)
                    if au and m(as) then
                        local av = (ao - at).Magnitude
                        if h.usefov and av < aq then
                            aq = av
                            ap = as
                        elseif not h.usefov then
                            ap = as
                            break
                        end
                    end
                end
            end
        end
    end
    local aw = f:FindFirstChild("Mobs")
    if aw then
        for _, ax in pairs(aw:GetChildren()) do
            if ax:FindFirstChild(h.aimbone) and ac(ax) then
                if t(ax) then
                    local ay = ax[h.aimbone]
                    local az, ba = y(ay.Position)
                    if ba and m(ay) then
                        local bb = (ao - az).Magnitude
                        if h.usefov and bb < aq then
                            aq = bb
                            ap = ay
                        elseif not h.usefov then
                            ap = ay
                            break
                        end
                    end
                end
            end
        end
    end
    return ap
end

-- Save/Load Functions
local Settings = {
    Combat = {
        SilentAim = {
            Enabled = true,
            TeamCheck = true,
            WallCheck = false,
            FOV = 200,
            ShowFOV = true,
            ShowSnapline = true,
            FOVColor = {1, 1, 1},
            SnapColor = {1, 1, 1},
            HitChance = 100,
            HitPart = "Head",
            DynamicFOV = false,
            MagicBullet = true,
            VisibilityCheck = false
        },
        BigHead = {
            Enabled = false,
            Size = 3
        },
        TPAll = {
            Players = false,
            Bots = false,
            TeamCheck = false,
            Offset = 5,
            TPWeapons = false
        },
        NoCooldown = true,
        RapidFire = true,
        NoRecoil = true,
        InfAmmo = true,
        InfProjectileSpeed = true
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

-- Combat Functions
local bc = false
a.TouchTap:Connect(function()
    bc = not bc
end)

local bd = g.fov
local be = 8
b.RenderStepped:Connect(function(bf)
    local bg = f:FindFirstChild("BotRig")
    if bg then
        bg:Destroy()
    end
    if not g.enabled then
        g.target = nil
        g.istargeting = false
        i.Visible = false
        j.Visible = false
        k.Visible = false
        l.Visible = false
        return
    end
    local bh = Vector2.new(e.ViewportSize.X / 2, e.ViewportSize.Y / 2)
    local bi = g.fov
    local bj = bi * 0.35
    local bk = bi
    if g.dynamicfov and bc then
        bk = bi + bj
    end
    bd = bd + (bk - bd) * math.clamp(be * bf, 0, 1)
    i.Position = bh
    i.Radius = bd
    j.Position = bh
    j.Radius = bd
    i.Visible = g.showfov and g.enabled
    j.Visible = g.showfov and g.enabled
    local bl = nil
    if h.aimboneenabled then
        bl = an()
    end
    g.target = bl
    g.istargeting = bl ~= nil
    if g.istargeting and g.showsnapline then
        local bm, bn = y(bl.Position)
        if bn then
            l.From = bh
            l.To = bm
            l.Visible = true
            k.From = bh
            k.To = bm
            k.Visible = true
        else
            k.Visible = false
            l.Visible = false
        end
    else
        k.Visible = false
        l.Visible = false
    end
end)

local bo
bo = hookmetamethod(game, "__namecall", function(bp, ...)
    local bq = getnamecallmethod()
    local br = {...}
    if not checkcaller() and bp == f and bq == "Raycast" and g.enabled and g.istargeting and g.target then
        if math.random(1, 100) > g.hitchance then
            return bo(bp, ...)
        end
        local bs = br[1]
        local bt = g.target.Position
        if g.magicbullet then
            local bu = {
                Instance = g.target,
                Position = bt,
                Normal = Vector3.new(5, 5, 5),
                Material = Enum.Material.Plastic,
                Distance = (bt - bs).Magnitude
            }
            local bv = {}
            bv.__index = bv
            function bv:Distance() return self.Distance end
            function bv:Position() return self.Position end
            function bv:Instance() return self.Instance end
            setmetatable(bu, bv)
            return bu
        else
            local bw = (bt - bs).Unit * 1000
            br[2] = bw
            return bo(bp, unpack(br))
        end
    end
    return bo(bp, ...)
end)

-- Farming Functions
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

-- UI Setup
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.7",
    ConfigFolder = ConfigFolder,
    SaveConfig = true,
    HidePremium = true
})

local Tabs = {
    Main = Window:MakeTab({Name = "Combat", Icon = "rbxassetid://4483345998"}),
    Farming = Window:MakeTab({Name = "Farming", Icon = "rbxassetid://4483345998"}),
    Settings = Window:MakeTab({Name = "Settings", Icon = "rbxassetid://4483345998"})
}

-- Combat Tab
local CombatTab = Tabs.Main
CombatTab:AddSection({Name = "Silent Aim"})
CombatTab:AddToggle({Name = "Enable Silent Aim", Default = Settings.Combat.SilentAim.Enabled, Callback = function(v)
    Settings.Combat.SilentAim.Enabled = v
    getgenv().hypershotlum.silentaim.enabled = v
    Save()
end})

CombatTab:AddToggle({Name = "Team Check", Default = Settings.Combat.SilentAim.TeamCheck, Callback = function(v)
    Settings.Combat.SilentAim.TeamCheck = v
    getgenv().hypershotlum.silentaim.teamcheck = v
    Save()
end})

CombatTab:AddToggle({Name = "Wall Check", Default = Settings.Combat.SilentAim.WallCheck, Callback = function(v)
    Settings.Combat.SilentAim.WallCheck = v
    getgenv().hypershotlum.silentaim.wallcheck = v
    Save()
end})

CombatTab:AddSlider({Name = "FOV", Min = 20, Max = 500, Default = Settings.Combat.SilentAim.FOV, Callback = function(v)
    Settings.Combat.SilentAim.FOV = v
    getgenv().hypershotlum.silentaim.fov = v
    Save()
end})

CombatTab:AddToggle({Name = "Show FOV", Default = Settings.Combat.SilentAim.ShowFOV, Callback = function(v)
    Settings.Combat.SilentAim.ShowFOV = v
    getgenv().hypershotlum.silentaim.showfov = v
    Save()
end})

CombatTab:AddToggle({Name = "Show Snapline", Default = Settings.Combat.SilentAim.ShowSnapline, Callback = function(v)
    Settings.Combat.SilentAim.ShowSnapline = v
    getgenv().hypershotlum.silentaim.showsnapline = v
    Save()
end})

CombatTab:AddColorpicker({Name = "FOV Color", Default = Color3.fromRGB(unpack(Settings.Combat.SilentAim.FOVColor)), Callback = function(v)
    Settings.Combat.SilentAim.FOVColor = {v.R, v.G, v.B}
    getgenv().hypershotlum.silentaim.fovcolor = v
    Save()
end})

CombatTab:AddColorpicker({Name = "Snapline Color", Default = Color3.fromRGB(unpack(Settings.Combat.SilentAim.SnapColor)), Callback = function(v)
    Settings.Combat.SilentAim.SnapColor = {v.R, v.G, v.B}
    getgenv().hypershotlum.silentaim.snapcolor = v
    Save()
end})

CombatTab:AddSlider({Name = "Hit Chance", Min = 1, Max = 100, Default = Settings.Combat.SilentAim.HitChance, Callback = function(v)
    Settings.Combat.SilentAim.HitChance = v
    getgenv().hypershotlum.silentaim.hitchance = v
    Save()
end})

CombatTab:AddDropdown({Name = "Hit Part", Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso", "LeftArm", "RightArm", "LeftLeg", "RightLeg"}, Default = Settings.Combat.SilentAim.HitPart, Callback = function(v)
    Settings.Combat.SilentAim.HitPart = v
    getgenv().hypershotlum.silentaim.hitpart = v
    Save()
end})

CombatTab:AddToggle({Name = "Dynamic FOV", Default = Settings.Combat.SilentAim.DynamicFOV, Callback = function(v)
    Settings.Combat.SilentAim.DynamicFOV = v
    getgenv().hypershotlum.silentaim.dynamicfov = v
    Save()
end})

CombatTab:AddToggle({Name = "Magic Bullet", Default = Settings.Combat.SilentAim.MagicBullet, Callback = function(v)
    Settings.Combat.SilentAim.MagicBullet = v
    getgenv().hypershotlum.silentaim.magicbullet = v
    Save()
end})

CombatTab:AddToggle({Name = "Visibility Check", Default = Settings.Combat.SilentAim.VisibilityCheck, Callback = function(v)
    Settings.Combat.SilentAim.VisibilityCheck = v
    getgenv().hypershotlum.silentaim.visibilitycheck = v
    Save()
end})

CombatTab:AddSection({Name = "Big Head"})
CombatTab:AddToggle({Name = "Enable Big Head", Default = Settings.Combat.BigHead.Enabled, Callback = function(v)
    Settings.Combat.BigHead.Enabled = v
    getgenv().hypershotlum.bighead.enabled = v
    Save()
end})

CombatTab:AddSlider({Name = "Head Size", Min = 1, Max = 10, Default = Settings.Combat.BigHead.Size, Callback = function(v)
    Settings.Combat.BigHead.Size = v
    getgenv().hypershotlum.bighead.size = v
    Save()
end})

CombatTab:AddSection({Name = "Combat Mods"})
CombatTab:AddToggle({Name = "No Cooldown", Default = Settings.Combat.NoCooldown, Callback = function(v)
    Settings.Combat.NoCooldown = v
    Save()
end})

CombatTab:AddToggle({Name = "Rapid Fire", Default = Settings.Combat.RapidFire, Callback = function(v)
    Settings.Combat.RapidFire = v
    Save()
end})

CombatTab:AddToggle({Name = "No Recoil", Default = Settings.Combat.NoRecoil, Callback = function(v)
    Settings.Combat.NoRecoil = v
    Save()
end})

CombatTab:AddToggle({Name = "Infinite Ammo", Default = Settings.Combat.InfAmmo, Callback = function(v)
    Settings.Combat.InfAmmo = v
    Save()
end})

CombatTab:AddToggle({Name = "Infinite Projectile Speed", Default = Settings.Combat.InfProjectileSpeed, Callback = function(v)
    Settings.Combat.InfProjectileSpeed = v
    Save()
end})

-- Farming Tab
local FarmingTab = Tabs.Farming
FarmingTab:AddToggle({Name = "Auto Spawn", Default = Settings.Farming.AutoSpawn, Callback = function(v)
    Settings.Farming.AutoSpawn = v
    if v then StartFarm("AutoSpawn", SpawnLoop) else StopFarm("AutoSpawn") end
    Save()
end})

FarmingTab:AddToggle({Name = "Auto Open Chest", Default = Settings.Farming.AutoChest, Callback = function(v)
    Settings.Farming.AutoChest = v
    if v then StartFarm("AutoChest", ChestLoop) else StopFarm("AutoChest") end
    Save()
end})

FarmingTab:AddDropdown({Name = "Chest Type", Options = {"Wooden","Bronze","Silver","Gold","Diamond"}, Default = Settings.Farming.ChestType, Callback = function(v) Settings.Farming.ChestType = v; Save() end})

FarmingTab:AddToggle({Name = "Auto Spin Wheel", Default = Settings.Farming.AutoSpin, Callback = function(v) Settings.Farming.AutoSpin = v; if v then StartFarm("AutoSpin", SpinLoop) else StopFarm("AutoSpin") end; Save() end})

FarmingTab:AddToggle({Name = "Auto Playtime Award", Default = Settings.Farming.AutoPlaytime, Callback = function(v) Settings.Farming.AutoPlaytime = v; if v then StartFarm("AutoPlaytime", PlaytimeLoop) else StopFarm("AutoPlaytime") end; Save() end})

FarmingTab:AddToggle({Name = "Auto Pickup Heal", Default = Settings.Farming.AutoHeal, Callback = function(v)
    Settings.Farming.AutoHeal = v
    if v then StartFarm("AutoHeal", PickupLoop("Heals", "PickUpHeal")) else StopFarm("AutoHeal") end
    Save()
end})

FarmingTab:AddToggle({Name = "Auto Pickup Coin", Default = Settings.Farming.AutoCoin, Callback = function(v)
    Settings.Farming.AutoCoin = v
    if v then StartFarm("AutoCoin", PickupLoop("Coins", "PickUpCoins")) else StopFarm("AutoCoin") end
    Save()
end})

FarmingTab:AddToggle({Name = "Auto Pickup Weapon", Default = Settings.Farming.AutoWeapon, Callback = function(v)
    Settings.Farming.AutoWeapon = v
    if v then StartFarm("AutoWeapon", PickupLoop("Weapons", "PickUpWeapons")) else StopFarm("AutoWeapon") end
    Save()
end})

-- Settings Tab
Tabs.Settings:AddButton({Name = "Unload Script", Callback = function()
    OrionLib:Destroy()
    for k in pairs(FarmingLoops) do StopFarm(k) end
    i.Visible = false
    j.Visible = false
    k.Visible = false
    l.Visible = false
end})

-- Start UI
OrionLib:Init()

-- Auto-run patches on load
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
            if rawget(v, "CD") and Settings.Combat.NoCooldown then
                v.CD = 0
            end
            -- Projectile Speed
            if (rawget(v, "Speed") or rawget(v, "ProjectileSpeed")) and Settings.Combat.InfProjectileSpeed then
                v.Speed = 9e99
            end
        end
    end
end

nocooldown()
luffy()
PatchTables()
