-- [[ HYRISER HUB BETA - V15 CLEAN WHITE & GREY EDITION ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

-- [[ CONFIG ]] --
_G.Config = { 
    AutoHarvest = false,
    AutoSell = false,
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
ScreenGui.Name = "Hyriser_V15_CleanWhite"

-- MAIN FRAME (Màu đen nhạt/Xám tối)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size, MainFrame.Position = UDim2.new(0, 220, 0, 150), UDim2.new(0.12, 0, 0.15, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Đen nhạt (Xám tối)
MainFrame.Active, MainFrame.Draggable = true, true
MainFrame.Visible = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

-- Viền màu trắng xám nhạt
local FrameStroke = Instance.new("UIStroke", MainFrame)
FrameStroke.Color = Color3.fromRGB(200, 200, 200) 
FrameStroke.Thickness = 1.5

local Title = Instance.new("TextLabel", MainFrame)
Title.Size, Title.Text = UDim2.new(1, 0, 0, 35), "HYRISER HUB BETA"
Title.TextColor3, Title.BackgroundTransparency = Color3.fromRGB(255, 255, 255), 1
Title.Font, Title.TextSize = Enum.Font.SourceSansBold, 17

-- LOGO IMAGE (Ảnh nhân vật bạn gửi)
local ToggleIcon = Instance.new("ImageButton", ScreenGui)
ToggleIcon.Size, ToggleIcon.Position = UDim2.new(0, 55, 0, 55), UDim2.new(0.05, 0, 0.15, 0)
ToggleIcon.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleIcon.Image = "rbxassetid://134859472779962" 
ToggleIcon.ScaleType = Enum.ScaleType.Crop
Instance.new("UICorner", ToggleIcon).CornerRadius = UDim.new(0, 8) 

local StrokeIcon = Instance.new("UIStroke", ToggleIcon)
StrokeIcon.Color, StrokeIcon.Thickness = Color3.fromRGB(255, 255, 255), 1.5

ToggleIcon.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local function CreateToggle(label, key, pos)
    local b = Instance.new("TextButton", MainFrame)
    b.Size, b.Position = UDim2.new(0, 190, 0, 40), pos
    b.Font, b.TextSize = Enum.Font.SourceSansBold, 14
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    
    local function up()
        -- Khi ON: Màu trắng, chữ đen | Khi OFF: Màu xám đậm, chữ trắng
        if _G.Config[key] then
            b.BackgroundColor3 = Color3.fromRGB(240, 240, 240) -- Trắng sáng
            b.TextColor3 = Color3.fromRGB(0, 0, 0) -- Chữ đen
        else
            b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) -- Xám đậm
            b.TextColor3 = Color3.fromRGB(200, 200, 200) -- Chữ trắng xám
        end
        b.Text = label .. ": " .. (_G.Config[key] and "ON" or "OFF")
    end
    b.MouseButton1Click:Connect(function() _G.Config[key] = not _G.Config[key] up() end)
    up()
end

CreateToggle("AUTO SPAM HARVEST", "AutoHarvest", UDim2.new(0, 15, 0, 45))
CreateToggle("AUTO SELL (FULL)", "AutoSell", UDim2.new(0, 15, 0, 95))

-- [[ 3. LOGIC SMART SELL ]] --
-- (Logic thu hoạch và bán giữ nguyên như cũ)

local function IsInventoryFullUI()
    for _, v in pairs(LP.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Visible and (v.Text:lower():find("full") or v.Text:lower():find("make space")) then 
            return true 
        end
    end
    return false
end

local function GetItemCount()
    local count = #LP.Backpack:GetChildren()
    if LP.Character then
        for _, v in pairs(LP.Character:GetChildren()) do
            if v:IsA("Tool") then count = count + 1 end
        end
    end
    return count
end

local function ForceSellAction()
    for _, v in pairs(LP.PlayerGui:GetDescendants()) do
        if v:IsA("TextLabel") and v.Text:lower():find("sell everything") then
            local button = v:FindFirstAncestorWhichIsA("TextButton") or v.Parent:FindFirstChildOfClass("TextButton") or v.Parent
            if button and button:IsA("TextButton") then
                for _, connection in pairs(getconnections(button.MouseButton1Click)) do connection:Fire() end
                for _, connection in pairs(getconnections(button.Activated)) do connection:Fire() end
            end
        end
    end
end

task.spawn(function()
    while task.wait(0.5) do
        if _G.Config.AutoHarvest then
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            if _G.Config.AutoSell and IsInventoryFullUI() then
                local steve = workspace:FindFirstChild("Steve", true)
                if steve then
                    if not _G.Config.LastGardenPos then _G.Config.LastGardenPos = root.CFrame end
                    root.CFrame = steve:GetModelCFrame() * CFrame.new(0, 0, 3)
                    task.wait(1.2)
                    local p = steve:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if p then
                        fireproximityprompt(p)
                        task.wait(1.5)
                        ForceSellAction()
                        local waitTime = 0
                        while GetItemCount() > 0 and waitTime < 20 do
                            task.wait(0.5)
                            waitTime = waitTime + 1
                            if waitTime % 4 == 0 then ForceSellAction() end
                        end
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
