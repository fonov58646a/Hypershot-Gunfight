--[[
    ----------------------------------------------------------
    VortX Hub V1.6.0  –  HyperShot Gunfight Edition
    ----------------------------------------------------------
    •  Added  Kill-All (FFA Aimbot)  🎯  
    •  Replaced old ESP with  Universal ESP (Highlight)  
    •  Added  Rainbow-Bullet  visuals  
    •  Remade  No-Cooldown  &  Hitbox-Expander  
    •  Replaced classic aimbot with  Silent-Aim  (hook)  
    •  Removed “Info” tab – cleaner UI  
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
local Remotes = ReplicatedStorage:WaitForChild("Network"):WaitForChild("Remotes")
local IgnoreThese = Workspace:WaitForChild("IgnoreThese")
local Pickups = IgnoreThese:WaitForChild("Pickups")

local ConfigFolder = "VortXConfigs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
local ConfigFile = ConfigFolder .. "/Hypershot_" .. game.PlaceId .. ".json"

--  2.  Save / Load
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
            Target = nil
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

local function Save()
    writefile(ConfigFile, game:GetService("HttpService"):JSONEncode(Settings))
end
local function Load()
    local ok, data = pcall(function() return game:GetService("HttpService"):JSONDecode(readfile(ConfigFile)) end)
    if ok then for k,v in pairs(data) do Settings[k]=v end end
end
Load()

local function Notify(Title,Text,Time)
    OrionLib:MakeNotification({Name=Title,Content=Text,Time=Time or 5})
end

--  3.  Anti-Cheat Bypass
local function StealthBypass()
    local mt = getrawmetatable(game)
    setreadonly(mt,false)
    local old = mt.__namecall
    mt.__namecall = newcclosure(function(self,...)
        local m=getnamecallmethod()
        if m=="FireServer" or m=="InvokeServer" then return old(self,...) end
        return old(self,...)
    end)
    setreadonly(mt,true)
end

--  4.  NEW! Kill-All (FFA)
local Damage = ReplicatedStorage:WaitForChild("PlayerHitEvent")
local function ToggleKillAll(v)
    if v then
        task.spawn(function()
            while Settings.Combat.KillAll do
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LocalPlayer then
                        Damage:FireServer(p,100)
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end

--  5.  Universal ESP (Highlight)
local function ToggleUniversalESP(v)
    if v then
        local function addESP(plr)
            if plr~=LocalPlayer and plr.Character and not plr.Character:FindFirstChild("okbruh") then
                local hl = Instance.new("Highlight")
                hl.Name="okbruh"
                hl.Parent=plr.Character
                hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                hl.FillColor=Color3.fromRGB(255,100,50)
                hl.FillTransparency=.5
                hl.OutlineColor=Color3.new(1,1,1)
                hl.OutlineTransparency=0
            end
        end
        for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
        Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function() addESP(p) end)
        end)
    else
        for _,p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local ok=p.Character:FindFirstChild("okbruh")
                if ok then ok:Destroy() end
            end
        end
    end
end

--  6.  Rainbow Bullet
local function ToggleRainbowBullet(v)
    if v then
        task.spawn(function()
            while Settings.Visuals.RainbowBullet do
                for _,b in ipairs(Workspace:GetDescendants()) do
                    if b:IsA("BasePart") and (b.Name:lower():find("bullet") or b.Name:lower():find("projectile")) then
                        if not b:FindFirstChild("RainbowScript") then
                            local s=Instance.new("Script")
                            s.Name="RainbowScript"
                            s.Source=[[
                                local bullet = script.Parent
                                local hue=0
                                while true do
                                    bullet.Color = Color3.fromHSV(hue%1,1,1)
                                    hue = hue + 0.005
                                    task.wait(0.01)
                                end
                            ]]
                            s.Parent=b
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end

--  7.  No Cooldown remake
local function ToggleNoCooldown(v)
    if v then
        task.spawn(function()
            while Settings.Combat.NoAbilityCD do
                for _,tbl in next,getgc(true) do
                    if type(tbl)=="table" and rawget(tbl,"CD") then
                        tbl.CD=0
                    end
                end
                task.wait(1)
            end
        end)
    end
end

--  8.  Hitbox Expander remake
local function ToggleHitboxExpander(v)
    if v then
        task.spawn(function()
            while Settings.Visuals.HitboxExpander do
                for _,p in ipairs(Players:GetPlayers()) do
                    if p~=LocalPlayer and p.Character then
                        local head=p.Character:FindFirstChild("Head")
                        if head then
                            head.Size=Vector3.new(Settings.Visuals.HeadSize,Settings.Visuals.HeadSize,Settings.Visuals.HeadSize)
                            head.Transparency=0.7
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end

--  9.  Silent-Aim hook
local SilentAim = Settings.Combat.SilentAim
local o
local function ToggleSilentAim(v)
    if v and not o then
        o = hookmetamethod(game,"__namecall",function(s,...)
            local m=getnamecallmethod()
            local a={...}
            if not checkcaller() and s==Workspace and m=="Raycast" and SilentAim.Enabled and SilentAim.IsTargeting and SilentAim.Target then
                if math.random(1,100) > SilentAim.HitChance then return namecall(s,...) end
                local r=a[1]
                local t=SilentAim.Target.Position
                local f={}
                f.Instance=SilentAim.Target
                f.Position=t
                f.Normal=Vector3.new(0,1,0)
                f.Material=Enum.Material.Plastic
                f.Distance=(t-r).Magnitude
                local p={}
                setmetatable(p,{__index=function(_,k)
                    if k=="Distance" then return f.Distance end
                    if k=="Position" then return f.Position end
                    if k=="Instance" then return f.Instance end
                    return f[k]
                end})
                return p
            end
            return namecall(s,...)
        end)
    elseif not v and o then
        hookmetamethod(game,"__namecall",o)
        o=nil
    end
end

-- 10.  Farming toggles
local FarmingLoops = {}
local function ToggleFarm(name,func)
    if Settings.Farming[name] then
        FarmingLoops[name]=true
        task.spawn(function() while FarmingLoops[name] do func() task.wait() end end)
    else
        FarmingLoops[name]=false
    end
end

local SpawnLoop = function()
    while FarmingLoops.AutoSpawn do Remotes.Spawn:FireServer(false); task.wait(1.5) end
end
local ChestLoop = function()
    while FarmingLoops.AutoChest do Remotes.OpenCase:InvokeServer(Settings.Farming.ChestType,"Random"); task.wait(6) end
end
local SpinLoop = function()
    while FarmingLoops.AutoSpin do Remotes.SpinWheel:InvokeServer(); task.wait(5) end
end
local PlaytimeLoop = function()
    while FarmingLoops.AutoPlaytime do for i=1,12 do Remotes.ClaimPlaytimeReward:FireServer(i); task.wait(1) end task.wait(15) end
end
local PickupLoop = function(folder,remote)
    return function()
        while FarmingLoops[remote] do
            local f=Pickups:FindFirstChild(folder)
            if f then for _,o in ipairs(f:GetChildren()) do Remotes[remote]:FireServer(o) end end
            task.wait(0.3)
        end
    end
end

-- 11.  UI
local Window = OrionLib:MakeWindow({
    Name = "VortX Hub V1.6.0 – HyperShot",
    ConfigFolder = ConfigFolder,
    SaveConfig = true,
    HidePremium = true
})

local Tabs = {
    Combat = Window:MakeTab({Name="Combat",Icon="rbxassetid://4483345998"}),
    Visuals = Window:MakeTab({Name="Visuals",Icon="rbxassetid://4483345998"}),
    Farming = Window:MakeTab({Name="Farming",Icon="rbxassetid://4483345998"}),
    Settings = Window:MakeTab({Name="Settings",Icon="rbxassetid://4483345998"})
}

-- Combat
local CSec = Tabs.Combat:AddSection({Name="Combat"})
CSec:AddToggle({Name="Kill-All (FFA)", Default=Settings.Combat.KillAll, Callback=function(v)
    Settings.Combat.KillAll=v; ToggleKillAll(v); Save()
end})
CSec:AddToggle({Name="Silent Aim", Default=Settings.Combat.SilentAim.Enabled, Callback=function(v)
    Settings.Combat.SilentAim.Enabled=v; ToggleSilentAim(v); Save()
end})
CSec:AddSlider({Name="Silent Aim Hit-Chance", Min=0, Max=100, Default=Settings.Combat.SilentAim.HitChance, Callback=function(v)
    Settings.Combat.SilentAim.HitChance=v; Save()
end})
CSec:AddToggle({Name="No Recoil / Rapid-Fire", Default=Settings.Combat.RapidFire, Callback=function(v)
    Settings.Combat.RapidFire=v; Save()
end})
CSec:AddToggle({Name="Infinite Ammo", Default=Settings.Combat.InfAmmo, Callback=function(v)
    Settings.Combat.InfAmmo=v; Save()
end})
CSec:AddToggle({Name="No Ability Cooldown", Default=Settings.Combat.NoAbilityCD, Callback=function(v)
    Settings.Combat.NoAbilityCD=v; ToggleNoCooldown(v); Save()
end})
CSec:AddToggle({Name="Inf Projectile Speed", Default=Settings.Combat.InfProjectileSpeed, Callback=function(v)
    Settings.Combat.InfProjectileSpeed=v; Save()
end})

-- Visuals
local VSec = Tabs.Visuals:AddSection({Name="Visuals"})
VSec:AddToggle({Name="Universal ESP", Default=Settings.Visuals.UniversalESP, Callback=function(v)
    Settings.Visuals.UniversalESP=v; ToggleUniversalESP(v); Save()
end})
VSec:AddToggle({Name="Rainbow Bullet", Default=Settings.Visuals.RainbowBullet, Callback=function(v)
    Settings.Visuals.RainbowBullet=v; ToggleRainbowBullet(v); Save()
end})
VSec:AddToggle({Name="Hitbox Expander", Default=Settings.Visuals.HitboxExpander, Callback=function(v)
    Settings.Visuals.HitboxExpander=v; ToggleHitboxExpander(v); Save()
end})
VSec:AddSlider({Name="Head Size", Min=3, Max=50, Default=Settings.Visuals.HeadSize, Callback=function(v)
    Settings.Visuals.HeadSize=v; Save()
end})

-- Farming
local FSec = Tabs.Farming:AddSection({Name="Auto Farm"})
FSec:AddToggle({Name="Auto Spawn", Default=Settings.Farming.AutoSpawn, Callback=function(v)
    Settings.Farming.AutoSpawn=v; ToggleFarm("AutoSpawn",SpawnLoop); Save()
end})
FSec:AddToggle({Name="Auto Open Chest", Default=Settings.Farming.AutoChest, Callback=function(v)
    Settings.Farming.AutoChest=v; ToggleFarm("AutoChest",ChestLoop); Save()
end})
FSec:AddDropdown({Name="Chest Type", Options={"Wooden","Bronze","Silver","Gold","Diamond"}, Default=Settings.Farming.ChestType, Callback=function(v)
    Settings.Farming.ChestType=v; Save()
end})
FSec:AddToggle({Name="Auto Spin Wheel", Default=Settings.Farming.AutoSpin, Callback=function(v)
    Settings.Farming.AutoSpin=v; ToggleFarm("AutoSpin",SpinLoop); Save()
end})
FSec:AddToggle({Name="Auto Playtime Award", Default=Settings.Farming.AutoPlaytime, Callback=function(v)
    Settings.Farming.AutoPlaytime=v; ToggleFarm("AutoPlaytime",PlaytimeLoop); Save()
end})
FSec:AddToggle({Name="Auto Pickup Heal", Default=Settings.Farming.AutoHeal, Callback=function(v)
    Settings.Farming.AutoHeal=v; ToggleFarm("AutoHeal",PickupLoop("Heals","PickUpHeal")); Save()
end})
FSec:AddToggle({Name="Auto Pickup Coin", Default=Settings.Farming.AutoCoin, Callback=function(v)
    Settings.Farming.AutoCoin=v; ToggleFarm("AutoCoin",PickupLoop("Coins","PickUpCoins")); Save()
end})
FSec:AddToggle({Name="Auto Pickup Weapon", Default=Settings.Farming.AutoWeapon, Callback=function(v)
    Settings.Farming.AutoWeapon=v; ToggleFarm("AutoWeapon",PickupLoop("Weapons","PickUpWeapons")); Save()
end})

-- Settings
Tabs.Settings:AddButton({Name="Unload Script", Callback=function()
    OrionLib:Destroy()
    for k in pairs(FarmingLoops) do StopFarm(k) end
    ClearESP()
    Notify("VortX Hub","Unloaded safely.",3)
end})

-- Init
OrionLib:Init()
StealthBypass()
Notify("VortX Hub V1.6.0","Loaded successfully! Use toggles for individual features.",5)
