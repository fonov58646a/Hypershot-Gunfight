--[[
    ----------------------------------------------------------
    VortX Hub V1.5.0  –  HyperShot Gunfight Edition (Enhanced)
    ----------------------------------------------------------
    NEW in Custom Enhanced Build
    • Integrated Silent Aim with FOV Visualization
    • Teleport All Players/Bots
    • Big Head Modifications (Size Adjustments)
    • Dynamic FOV & Magic Bullet Support
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

--[[  2.  Save / Load  ]]
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
        InfProjectileSpeed = false,
        SilentAim = false,
        MagicBullet = false
    },
    Teleport = {
        Players = false,
        Bots = false,
        TeamCheck = false,
        Offset = 5,
        TeleportWeapons = false
    },
    BigHead = {
        Enabled = false,
        Size = 3
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

--[[  3.  Utility  ]]
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

--[[  4.  Silent Aim & FOV  ]]
local g = Settings.Combat
local e = workspace.CurrentCamera
local function m(n)
    if not g.VisibilityCheck then return true end
    local o = e.CFrame.Position
    local p = (n.Position - o).Unit * 1000
    local q = RaycastParams.new()
    q.FilterDescendantsInstances = {LocalPlayer.Character}
    q.FilterType = Enum.RaycastFilterType.Blacklist
    local r = Workspace:Raycast(o, p, q)
    if r then
        local s = r.Instance
        return s:IsDescendantOf(n.Parent)
    end
    return true
end

local function t(u)
    if not g.TeamCheck then return true end
    local v = LocalPlayer:GetAttribute("Team")
    if not v then return true end
    local w = nil
    if typeof(u) == "Instance" then
        w = u:GetAttribute("Team")
        if not w and u:IsA("Model") then
            local x = Players:GetPlayerFromCharacter(u)
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

local function an()
    local ao = Vector2.new(e.ViewportSize.X / 2, e.ViewportSize.Y / 2)
    local ap = nil
    local aq = g.FOV
    for _, ar in pairs(Workspace:GetChildren()) do
        if ar:IsA("Model") and ar:FindFirstChild(g.HitPart) and ar:FindFirstChild("Humanoid") and ar.Humanoid.Health > 0 then
            if not LocalPlayer.Character or ar ~= LocalPlayer.Character then
                if t(ar) then
                    local as = ar[g.HitPart]
                    local at, au = y(as.Position)
                    if au and m(as) then
                        local av = (ao - at).Magnitude
                        if av < aq then
                            aq = av
                            ap = as
                        end
                    end
                end
            end
        end
    end
    local aw = Workspace:FindFirstChild("Mobs")
    if aw then
        for _, ax in pairs(aw:GetChildren()) do
            if ax:FindFirstChild(g.HitPart) and ax:FindFirstChild("Humanoid") and ax.Humanoid.Health > 0 then
                if t(ax) then
                    local ay = ax[g.HitPart]
                    local az, ba = y(ay.Position)
                    if ba and m(ay) then
                        local bb = (ao - az).Magnitude
                        if bb < aq then
                            aq = bb
                            ap = ay
                        end
                    end
                end
            end
        end
    end
    return ap
end

local bc = false
UIS.TouchTap:Connect(function()
    bc = not bc
end)

local i = Drawing.new("Circle")
i.Radius = g.FOV
i.Color = Color3.fromRGB(1, 1, 1)
i.Thickness = 1
i.Filled = false
i.Transparency = 0
i.Visible = g.ShowFOV
i.ZIndex = 3

local function UpdateFOV()
    i.Radius = g.FOV
    i.Visible = g.ShowFOV
end

RunService.RenderStepped:Connect(function()
    if g.SilentAim then
        local target = an()
        if target then
            i.Position = Vector2.new(e.ViewportSize.X / 2, e.ViewportSize.Y / 2)
            UpdateFOV()
        else
            i.Visible = false
        end
    else
        i.Visible = false
    end
end)

local bo
bo = hookmetamethod(game, "__namecall", function(bp, ...)
    local bq = getnamecallmethod()
    local br = {...}
    if not checkcaller() and bp == Workspace and bq == "Raycast" and g.SilentAim then
        local bs = br[1]
        local bt = an()
        if bt then
            if g.MagicBullet then
                local bu = {
                    Instance = bt,
                    Position = bt.Position,
                    Normal = Vector3.new(0, 1, 0),
                    Material = Enum.Material.Plastic,
                    Distance = (bt.Position - bs).Magnitude
                }
                local bv = {}
                bv.__index = bv
                function bv:Distance() return self.Distance end
                function bv:Position() return self.Position end
                function bv:Instance() return self.Instance end
                setmetatable(bu, bv)
                return bu
            else
                local bw = (bt.Position - bs).Unit * 1000
                br[2] = bw
                return bo(bp, unpack(br))
            end
        end
    end
    return bo(bp, ...)
end)

--[[  5.  Big Head  ]]
RunService.RenderStepped:Connect(function()
    if Settings.BigHead.Enabled then
        local function dh(di, dj)
            local dk = di:FindFirstChild("Head")
            if dk and dk:IsA("BasePart") then
                dk.Size = Vector3.new(dj, dj, dj)
                dk.Transparency = 0
            end
        end
        
        for _, dl in ipairs(Workspace:GetChildren()) do
            if dl:IsA("Model") then
                dh(dl, Settings.BigHead.Size)
            end
        end
        local dm = Workspace:FindFirstChild("Mobs")
        if dm then
            for _, dn in ipairs(dm:GetChildren()) do
                if dn:IsA("Model") then
                    dh(dn, Settings.BigHead.Size)
                end
            end
        end
    end
end)

--[[  6.  Teleport All  ]]
RunService.RenderStepped:Connect(function()
    if Settings.Teleport.Players or Settings.Teleport.Bots then
        local ch = (LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()):FindFirstChild("HumanoidRootPart")
        if not ch then return end
        
        local ci = LocalPlayer.Character:GetAttribute("Team")
        local cj = Vector2.new(e.ViewportSize.X / 2, e.ViewportSize.Y / 2)
        local ck = e:ViewportPointToRay(cj.X, cj.Y)
        local cl = ck.Origin + ck.Direction * 1000
        
        if Settings.Teleport.Players then
            for _, cn in ipairs(Workspace:GetChildren()) do
                if cn:IsA("Model") and cn ~= LocalPlayer.Character then
                    local co = cn:FindFirstChild("HumanoidRootPart")
                    local cp = cn:FindFirstChild("Head")
                    if co and cp then
                        if Settings.Teleport.TeamCheck then
                            local cq = cn:GetAttribute("Team")
                            if cq and ci and cq ~= ci then
                                local cr = e.CFrame.Position + e.CFrame.LookVector * Settings.Teleport.Offset
                                local cs = Vector3.new(cr.X, cr.Y - 2, cr.Z)
                                co.CFrame = CFrame.new(cs, e.CFrame.Position)
                                cp.CFrame = CFrame.new(cp.Position, cl)
                            end
                        else
                            local cr = e.CFrame.Position + e.CFrame.LookVector * Settings.Teleport.Offset
                            local cs = Vector3.new(cr.X, cr.Y - 2, cr.Z)
                            co.CFrame = CFrame.new(cs, e.CFrame.Position)
                            cp.CFrame = CFrame.new(cp.Position, cl)
                        end
                    end
                end
            end
        end
        
        if Settings.Teleport.Bots then
            local ct = Workspace:FindFirstChild("Mobs")
            if ct then
                for _, cu in ipairs(ct:GetChildren()) do
                    if cu:IsA("Model") then
                        local cv = cu:FindFirstChild("HumanoidRootPart")
                        local cw = cu:FindFirstChild("Head")
                        if cv and cw then
                            if Settings.Teleport.TeamCheck then
                                local cx = cu:GetAttribute("Team")
                                if cx and ci and cx ~= ci then
                                    local cy = e.CFrame.Position + e.CFrame.LookVector * Settings.Teleport.Offset
                                    local cz = Vector3.new(cy.X, cy.Y - 2, cy.Z)
                                    cv.CFrame = CFrame.new(cz, e.CFrame.Position)
                                    cw.CFrame = CFrame.new(cw.Position, cl)
                                end
                            else
                                local cy = e.CFrame.Position + e.CFrame.LookVector * Settings.Teleport.Offset
                                local cz = Vector3.new(cy.X, cy.Y - 2, cy.Z)
                                cv.CFrame = CFrame.new(cz, e.CFrame.Position)
                                cw.CFrame = CFrame.new(cw.Position, cl)
                            end
                        end
                    end
                end
            end
        end
        
        if Settings.Teleport.TeleportWeapons then
            local db = Workspace:FindFirstChild("IgnoreThese") and Workspace.IgnoreThese:FindFirstChild("Pickups") and Workspace.IgnoreThese.Pickups:FindFirstChild("Weapons")
            if db then
                local dc = db:GetChildren()
                if #dc > 0 then
                    local cf = 1
                    for _, dd in ipairs(dc) do
                        if dd:IsA("Model") then
                            local de = dd:FindFirstChild("Center")
                            if de and de:IsA("BasePart") then
                                local df = ch.Position + ch.CFrame.LookVector * 10 + Vector3.new(0, -3, 0)
                                local dg = CFrame.new(df, ch.Position)
                                dd:SetPrimaryPartCFrame(dg)
                            elseif dd and dd:IsA("BasePart") then
                                local df = ch.Position + ch.CFrame.LookVector * 10 + Vector3.new(0, -3, 0)
                                local dg = CFrame.new(df, ch.Position)
                                dd.CFrame = dg
                            end
                        end
                    end
                end
            end
        end
    end
end)

--[[  7.  UI  ]]
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.5.0 – HyperShot (Enhanced)",
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
    Save()
end})
AimSec:AddSlider({Name = "FOV", Min = 20, Max = 500, Default = Settings.Aimbot.FOV, Callback = function(v) Settings.Aimbot.FOV = v; Save() end})
AimSec:AddToggle({Name = "Movement Prediction", Default = Settings.Aimbot.Prediction, Callback = function(v) Settings.Aimbot.Prediction = v; Save() end})

local CombatSec = Tabs.Main:AddSection({Name = "Combat Mods"})
CombatSec:AddToggle({Name = "Rapid Fire + No Recoil", Default = Settings.Combat.RapidFire, Callback = function(v)
    Settings.Combat.RapidFire = v
    Save()
end})
CombatSec:AddToggle({Name = "Infinite Ammo", Default = Settings.Combat.InfAmmo, Callback = function(v) Settings.Combat.InfAmmo = v; Save() end})
CombatSec:AddToggle({Name = "No Ability Cooldown", Default = Settings.Combat.NoAbilityCD, Callback = function(v) Settings.Combat.NoAbilityCD = v; Save() end})
CombatSec:AddToggle({Name = "Inf Projectile Speed", Default = Settings.Combat.InfProjectileSpeed, Callback = function(v) Settings.Combat.InfProjectileSpeed = v; Save() end})
CombatSec:AddToggle({Name = "Silent Aim", Default = Settings.Combat.SilentAim, Callback = function(v)
    Settings.Combat.SilentAim = v
    Save()
end})
CombatSec:AddToggle({Name = "Magic Bullet", Default = Settings.Combat.MagicBullet, Callback = function(v)
    Settings.Combat.MagicBullet = v
    Save()
end})

-- Visuals
local VisSec = Tabs.Visuals:AddSection({Name = "ESP"})
VisSec:AddToggle({Name = "Box ESP", Default = Settings.Visuals.BoxESP, Callback = function(v) Settings.Visuals.BoxESP = v; Save() end})
VisSec:AddToggle({Name = "Chams", Default = Settings.Visuals.Chams, Callback = function(v) Settings.Visuals.Chams = v; Save() end})
VisSec:AddToggle({Name = "Hitbox Expander", Default = Settings.Visuals.HitboxExpander, Callback = function(v)
    Settings.Visuals.HitboxExpander = v
    Save()
end})
VisSec:AddSlider({Name = "Head Size", Min = 3, Max = 50, Default = Settings.Visuals.HeadSize, Callback = function(v) Settings.Visuals.HeadSize = v; Save() end})

-- Farming
local FarmSec = Tabs.Farming:AddSection({Name = "Auto Farm"})
FarmSec:AddToggle({Name = "Auto Spawn", Default = Settings.Farming.AutoSpawn, Callback = function(v)
    Settings.Farming.AutoSpawn = v
    Save()
end})
FarmSec:AddToggle({Name = "Auto Open Chest", Default = Settings.Farming.AutoChest, Callback = function(v)
    Settings.Farming.AutoChest = v
    Save()
end})
FarmSec:AddDropdown({Name = "Chest Type", Options = {"Wooden","Bronze","Silver","Gold","Diamond"}, Default = Settings.Farming.ChestType, Callback = function(v) Settings.Farming.ChestType = v; Save() end})
FarmSec:AddToggle({Name = "Auto Spin Wheel", Default = Settings.Farming.AutoSpin, Callback = function(v) Settings.Farming.AutoSpin = v; Save() end})
FarmSec:AddToggle({Name = "Auto Playtime Award", Default = Settings.Farming.AutoPlaytime, Callback = function(v) Settings.Farming.AutoPlaytime = v; Save() end})
FarmSec:AddToggle({Name = "Auto Pickup Heal", Default = Settings.Farming.AutoHeal, Callback = function(v)
    Settings.Farming.AutoHeal = v
    Save()
end})
FarmSec:AddToggle({Name = "Auto Pickup Coin", Default = Settings.Farming.AutoCoin, Callback = function(v)
    Settings.Farming.AutoCoin = v
    Save()
end})
FarmSec:AddToggle({Name = "Auto Pickup Weapon", Default = Settings.Farming.AutoWeapon, Callback = function(v)
    Settings.Farming.AutoWeapon = v
    Save()
end})

-- Teleport & Big Head
local TeleportSec = Tabs.Settings:AddSection({Name = "Teleport"})
TeleportSec:AddToggle({Name = "Teleport Players", Default = Settings.Teleport.Players, Callback = function(v)
    Settings.Teleport.Players = v
    Save()
end})
TeleportSec:AddToggle({Name = "Teleport Bots", Default = Settings.Teleport.Bots, Callback = function(v)
    Settings.Teleport.Bots = v
    Save()
end})
TeleportSec:AddToggle({Name = "Team Check", Default = Settings.Teleport.TeamCheck, Callback = function(v)
    Settings.Teleport.TeamCheck = v
    Save()
end})
TeleportSec:AddSlider({Name = "Offset", Min = 1, Max = 20, Default = Settings.Teleport.Offset, Callback = function(v)
    Settings.Teleport.Offset = v
    Save()
end})
TeleportSec:AddToggle({Name = "Teleport Weapons", Default = Settings.Teleport.TeleportWeapons, Callback = function(v)
    Settings.Teleport.TeleportWeapons = v
    Save()
end})

local BigHeadSec = Tabs.Settings:AddSection({Name = "Big Head"})
BigHeadSec:AddToggle({Name = "Enable Big Head", Default = Settings.BigHead.Enabled, Callback = function(v)
    Settings.BigHead.Enabled = v
    Save()
end})
BigHeadSec:AddSlider({Name = "Size", Min = 1, Max = 10, Default = Settings.BigHead.Size, Callback = function(v)
    Settings.BigHead.Size = v
    Save()
end})

-- Info
Tabs.Info:AddLabel({Name = "Version: V1.5.0 Enhanced"})
Tabs.Info:AddLabel({Name = "Changes:"})
Tabs.Info:AddLabel({Name = "- Integrated Silent Aim & FOV Visualization"})
Tabs.Info:AddLabel({Name = "- Added Teleport All Feature"})
Tabs.Info:AddLabel({Name = "- Added Big Head Modifications"})
Tabs.Info:AddLabel({Name = "- Dynamic FOV & Magic Bullet Support"})

-- Init
OrionLib:Init()
Notify("VortX Hub V1.5.0", "Loaded successfully! Enjoy the game.", 5)
