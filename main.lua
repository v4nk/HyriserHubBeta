-- [[ HYRISER HUB BETA - V16 (V15 BASE + AUTO SHOP) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- [[ CONFIG ]] --
_G.Config = { 
    AutoHarvest = false,
    AutoSell = false,
    AutoShopOnRestock = true, -- Tính năng mới: Tự mở shop khi có hàng
    ScanRange = 100,
    LastGardenPos = nil 
}

-- [[ 1. WALK SPEED 36 ]] --
RunService.Heartbeat:Connect(function()
    if LP.Character and LP.Character:FindFirstChild("Humanoid") then
        LP.Character.Humanoid.WalkSpeed = 36
    end
end)

-- [[ 2. UI INITIALIZATION ]] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "Hyriser_V16_Final"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 220, 0, 270), UDim2.new(0.12, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.Active, MainFrame.Draggable = true, true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(255, 200, 0)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 35), "HYRISER HUB BETA"
Title.TextColor3, Title.BackgroundTransparency = Color3.fromRGB(255, 200, 0), 1
Title.Font, Title.TextSize = Enum.Font.SourceSansBold, 17

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
CreateToggle("AUTO OPEN SHOP (RESTOCK)", "AutoShopOnRestock", UDim2.new(0, 15, 0, 145))

-- HÀM MỞ SHOP NHƯ VIDEO
local function OpenShopUI()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local bill = workspace:FindFirstChild("Bill", true)
    if root and bill then
        local p = bill:FindFirstChildWhichIsA("ProximityPrompt", true)
        if p then
            local oldPos = root.CFrame
            root.CFrame = bill:GetModelCFrame() -- Bay tới Bill
            task.wait(0.5)
            fireproximityprompt(p) -- Bấm tương tác để hiện UI như video
            task.wait(0.8)
            root.CFrame = oldPos -- Bay về vườn ngay lập tức
        end
    end
end

-- [[ 3. LOGIC THEO DÕI THÔNG BÁO (IMAGE & VIDEO) ]] --
LP.PlayerGui.DescendantAdded:Connect(function(v)
    if _G.Config.AutoShopOnRestock and v:IsA("TextLabel") then
        task.wait(0.1)
        if v.Text:lower():find("seed shop") and v.Text:lower():find("restocked") then
            OpenShopUI() -- Kích hoạt khi hiện thông báo như ảnh bạn gửi
        end
    end
end)

-- [[ 4. LOGIC GỐC V15 ]] --
local function GetItemCount()
    local count = #LP.Backpack:GetChildren()
    if LP.Character then
        for _, v in pairs(LP.Character:GetChildren()) do if v:IsA("Tool") then count = count + 1 end end
    end
    return count
end

local function IsInventoryFullUI()
    for _, v in pairs(LP.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible and (v.Text:lower():find("full") or v.Text:lower():find("make space")) then return true end
    end
    return false
end

task.spawn(function()
    while task.wait(0.5) do
        if _G.Config.AutoHarvest then
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            if _G.Config.AutoSell and IsInventoryFullUI() then
                local steve = workspace:FindFirstChild("Steve", true)
                if steve then
                    _G.Config.LastGardenPos = root.CFrame
                    root.CFrame = steve:GetModelCFrame() * CFrame.new(0, 0, 3)
                    task.wait(1.2)
                    local p = steve:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p then
                        fireproximityprompt(p)
                        task.wait(1.5)
                        -- Force Sell Everything
                        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
                            if gui:IsA("TextLabel") and gui.Text:lower():find("sell everything") then
                                local b = gui:FindFirstAncestorWhichIsA("TextButton") or gui.Parent:FindFirstChildOfClass("TextButton")
                                if b then for _, con in pairs(getconnections(b.MouseButton1Click)) do con:Fire() end end
                            end
                        end
                        local waitT = 0
                        while GetItemCount() > 0 and waitT < 20 do task.wait(0.5) waitT = waitT + 1 end
                        task.wait(2)
                        if _G.Config.LastGardenPos then root.CFrame = _G.Config.LastGardenPos end
                    end
                end
            else
                _G.Config.LastGardenPos = root.CFrame
                for _, v in pairs(workspace:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.ActionText == "Harvest" then
                        v.Style = Enum.ProximityPromptStyle.Custom
                        if (v.Parent.Position - root.Position).Magnitude <= _G.Config.ScanRange then
                            v.HoldDuration = 0
                            fireproximityprompt(v)
                        end
                    end
                end
            end
        end
    end
end)
