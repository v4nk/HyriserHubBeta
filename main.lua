-- [[ HYRISER HUB BETA - V19 (STEALTH AUTO BUY) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- [[ CONFIG ]] --
_G.Config = { 
    AutoHarvest = false,
    AutoSell = false,
    AutoBuySeeds = false, 
    AutoBuyGears = false,
    ScanRange = 100
}

-- [[ 1. WALK SPEED 36 ]] --
RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 36
    end
end)

-- [[ 2. UI INITIALIZATION ]] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Hyriser_V19_Stealth"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 220, 0, 310), UDim2.new(0.12, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active, MainFrame.Draggable = true, true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 200, 0)

-- LOGO HH
local ToggleIcon = Instance.new("TextButton", ScreenGui)
ToggleIcon.Size, ToggleIcon.Position, ToggleIcon.Text = UDim2.new(0, 45, 0, 45), UDim2.new(0.05, 0, 0.15, 0), "HH"
ToggleIcon.BackgroundColor3, ToggleIcon.TextColor3 = Color3.fromRGB(15, 15, 15), Color3.fromRGB(255, 200, 0)
ToggleIcon.Font, ToggleIcon.TextSize = Enum.Font.LuckiestGuy, 22
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ToggleIcon).Color = Color3.fromRGB(255, 200, 0)
ToggleIcon.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function CreateToggle(label, key, pos)
    local b = Instance.new("TextButton", MainFrame)
    b.Size, b.Position = UDim2.new(0, 190, 0, 40), pos
    b.Font, b.TextSize, b.TextColor3 = Enum.Font.SourceSansBold, 14, Color3.new(0, 0, 0)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    local function up()
        b.BackgroundColor3 = _G.Config[key] and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(150, 120, 0)
        b.Text = label .. ": " .. (_G.Config[key] and "ON" or "OFF")
    end
    b.MouseButton1Click:Connect(function() _G.Config[key] = not _G.Config[key] up() end)
    up()
end

CreateToggle("AUTO SPAM HARVEST", "AutoHarvest", UDim2.new(0, 15, 0, 45))
CreateToggle("AUTO SELL (FULL)", "AutoSell", UDim2.new(0, 15, 0, 95))
CreateToggle("STEALTH BUY SEEDS", "AutoBuySeeds", UDim2.new(0, 15, 0, 145))
CreateToggle("STEALTH BUY GEARS", "AutoBuyGears", UDim2.new(0, 15, 0, 195))

-- [[ 3. LOGIC MUA NGẦM (KHÔNG CẦN UI) ]] --
-- Danh sách các hạt giống và dụng cụ dựa trên video của bạn
local SeedList = {"Carrot Seed", "Corn Seed", "Onion Seed", "Strawberry Seed", "Mushroom Seed", "Beetroot Seed", "Tomato Seed", "Apple Seed", "Rose Seed", "Wheat Seed", "Banana Seed", "Plum Seed", "Potato Seed", "Cabbage Seed", "Cherry Seed"}
local GearList = {"Watering Can", "Basic Sprinkler", "Harvest Bell", "Turbo Sprinkler", "Favorite Tool", "Super Sprinkler"}

local function StealthBuy(itemName)
    -- Tìm RemoteEvent mua đồ của game (thường nằm trong ReplicatedStorage)
    local buyEvent = game:GetService("ReplicatedStorage"):FindFirstChild("BuyItem", true) or 
                     game:GetService("ReplicatedStorage"):FindFirstChild("PurchaseItem", true)
    
    if buyEvent and buyEvent:IsA("RemoteEvent") then
        buyEvent:FireServer(itemName)
    end
end

task.spawn(function()
    while task.wait(1) do
        if _G.Config.AutoBuySeeds then
            for _, seed in pairs(SeedList) do
                StealthBuy(seed)
            end
        end
        
        if _G.Config.AutoBuyGears then
            for _, gear in pairs(GearList) do
                StealthBuy(gear)
            end
        end
    end
end)

-- [[ 4. LOGIC GỐC V15 (FARM & SELL) ]] --
task.spawn(function()
    while task.wait(0.5) do
        if _G.Config.AutoHarvest then
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            
            -- Scan & Harvest
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and v.ActionText == "Harvest" then
                    if (v.Parent.Position - root.Position).Magnitude <= _G.Config.ScanRange then
                        v.HoldDuration = 0
                        fireproximityprompt(v)
                    end
                end
            end
        end
    end
end)

-- Auto Sell (Giữ nguyên logic bay tới Steve khi túi đầy)
task.spawn(function()
    while task.wait(1) do
        if _G.Config.AutoSell then
            local isFull = false
            for _, v in pairs(LP.PlayerGui:GetDescendants()) do
                if v:IsA("TextLabel") and v.Visible and v.Text:lower():find("full") then isFull = true break end
            end

            if isFull then
                local steve = workspace:FindFirstChild("Steve", true)
                local root = LP.Character:FindFirstChild("HumanoidRootPart")
                if steve and root then
                    local oldPos = root.CFrame
                    root.CFrame = steve:GetModelCFrame() * CFrame.new(0, 0, 3)
                    task.wait(1)
                    fireproximityprompt(steve:FindFirstChildWhichIsA("ProximityPrompt", true))
                    task.wait(1)
                    root.CFrame = oldPos
                end
            end
        end
    end
end)
