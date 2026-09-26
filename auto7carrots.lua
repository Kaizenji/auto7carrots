--[[
    Auto Plant 7 Carrots + Auto Favorite + Loop Selector
    Based on depthso's autofarm.lua
]]

--// Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--// Folders
local GameEvents = ReplicatedStorage.GameEvents
local Farms = workspace.Farm

--// Get Player's Farm
local function GetFarm(PlayerName)
    for _, Farm in pairs(Farms:GetChildren()) do
        local Important = Farm:FindFirstChild("Important")
        if not Important then continue end
        local Data = Important:FindFirstChild("Data")
        if not Data then continue end
        local Owner = Data:FindFirstChild("Owner")
        if Owner and Owner.Value == PlayerName then
            return Farm
        end
    end
    return nil
end

--// Get Plant Locations
local function GetPlantLocations()
    local MyFarm = GetFarm(LocalPlayer.Name)
    if not MyFarm then return {} end
    local Important = MyFarm:FindFirstChild("Important")
    if not Important then return {} end
    local Locations = Important:FindFirstChild("Plant_Locations")
    if not Locations then return {} end
    return Locations:GetChildren()
end

--// Plant Function
local function Plant(Position, Seed)
    GameEvents.Plant_RE:FireServer(Position, Seed)
end

--// Get Area
local function GetArea(Base)
    local Center = Base:GetPivot()
    local Size = Base.Size
    local X1 = math.ceil(Center.X - (Size.X/2))
    local Z1 = math.ceil(Center.Z - (Size.Z/2))
    local X2 = math.floor(Center.X + (Size.X/2))
    local Z2 = math.floor(Center.Z + (Size.Z/2))
    return X1, Z1, X2, Z2
end

--// ============================================
--// POSSIBLE FAVORITE REMOTE NAMES (Try one by one)
--// ============================================
local FavoriteRemoteNames = {
    "Favorite_RE",
    "SetFavorite", 
    "ToggleFavorite",
    "MarkFavorite",
    "PinPlant",
    "StarPlant",
    "FavoritePlant"
}

local FavoriteRemote = nil

--// Find Favorite Remote
local function FindFavoriteRemote()
    for _, name in ipairs(FavoriteRemoteNames) do
        local remote = GameEvents:FindFirstChild(name)
        if remote then
            print("✅ Found Favorite Remote: " .. name)
            return remote
        end
    end
    
    -- If not found, show all available remotes
    print("❌ Favorite Remote not found. Available GameEvents:")
    for _, obj in pairs(GameEvents:GetChildren()) do
        print("  - " .. obj.Name)
    end
    return nil
end

--// Favorite Function
local function FavoritePlant(Plant)
    if not FavoriteRemote then
        FavoriteRemote = FindFavoriteRemote()
    end
    
    if FavoriteRemote then
        -- Try different argument patterns
        pcall(function()
            FavoriteRemote:FireServer(Plant, true)
        end)
        pcall(function()
            FavoriteRemote:FireServer(Plant.Name, true)
        end)
        pcall(function()
            FavoriteRemote:FireServer(Plant)
        end)
    end
end

--// ============================================
--// SIMPLE UI (Mobile Friendly)
--// ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Auto7Carrots"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 280)
Frame.Position = UDim2.new(0.5, -150, 0.5, -140)
Frame.BackgroundColor3 = Color3.fromRGB(45, 95, 25)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "Auto 7 Carrots + Favorite"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(26, 20, 8)
Title.Parent = Frame

-- Loop Count
local LoopLabel = Instance.new("TextLabel")
LoopLabel.Size = UDim2.new(1, 0, 0, 25)
LoopLabel.Position = UDim2.new(0, 0, 0, 40)
LoopLabel.Text = "Loop Count:"
LoopLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopLabel.BackgroundTransparency = 1
LoopLabel.Parent = Frame

local LoopBox = Instance.new("TextBox")
LoopBox.Size = UDim2.new(0.8, 0, 0, 30)
LoopBox.Position = UDim2.new(0.1, 0, 0, 65)
LoopBox.Text = "1"
LoopBox.BackgroundColor3 = Color3.fromRGB(69, 142, 40)
LoopBox.TextColor3 = Color3.fromRGB(255, 255, 255)
LoopBox.Parent = Frame

-- Status
local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0, 100)
Status.Text = "Status: Ready"
Status.TextSize = 14
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.BackgroundTransparency = 1
Status.Parent = Frame

-- Progress
local Progress = Instance.new("TextLabel")
Progress.Size = UDim2.new(1, 0, 0, 25)
Progress.Position = UDim2.new(0, 0, 0, 130)
Progress.Text = "Progress: 0/7"
Progress.TextSize = 12
Progress.TextColor3 = Color3.fromRGB(255, 255, 255)
Progress.BackgroundTransparency = 1
Progress.Parent = Frame

-- Buttons
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.8, 0, 0, 35)
StartBtn.Position = UDim2.new(0.1, 0, 0, 165)
StartBtn.Text = "START"
StartBtn.TextSize = 16
StartBtn.BackgroundColor3 = Color3.fromRGB(69, 142, 40)
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Parent = Frame

local StopBtn = Instance.new("TextButton")
StopBtn.Size = UDim2.new(0.8, 0, 0, 35)
StopBtn.Position = UDim2.new(0.1, 0, 0, 205)
StopBtn.Text = "STOP"
StopBtn.TextSize = 16
StopBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
StopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StopBtn.Parent = Frame

local TestFavBtn = Instance.new("TextButton")
TestFavBtn.Size = UDim2.new(0.8, 0, 0, 30)
TestFavBtn.Position = UDim2.new(0.1, 0, 0, 245)
TestFavBtn.Text = "Test Favorite"
TestFavBtn.TextSize = 14
TestFavBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 0)
TestFavBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TestFavBtn.Parent = Frame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 35)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Frame

--// Variables
local IsRunning = false

--// Update Status
local function UpdateStatus(msg)
    Status.Text = "Status: " .. msg
    print(msg)
end

local function UpdateProgress(current, total, action)
    Progress.Text = string.format("%s: %d/%d", action, current, total)
end

--// Plant 7 Carrots
local function Plant7Carrots()
    local locations = GetPlantLocations()
    if #locations == 0 then
        UpdateStatus("No farm found!")
        return 0
    end
    
    local dirt = locations[1]
    local X1, Z1, X2, Z2 = GetArea(dirt)
    
    local positions = {}
    for X = X1, X2, 2 do
        for Z = Z1, Z2, 2 do
            if #positions >= 7 then break end
            table.insert(positions, Vector3.new(X, 0.13, Z))
        end
        if #positions >= 7 then break end
    end
    
    for i, pos in ipairs(positions) do
        if not IsRunning then break end
        Plant(pos, "Carrot")
        UpdateProgress(i, 7, "Planting")
        wait(0.3)
    end
    
    return #positions
end

--// Favorite 7 Plants
local function Favorite7Plants()
    local MyFarm = GetFarm(LocalPlayer.Name)
    if not MyFarm then return 0 end
    
    local Important = MyFarm:FindFirstChild("Important")
    if not Important then return 0 end
    
    local PlantsPhysical = Important:FindFirstChild("Plants_Physical")
    if not PlantsPhysical then return 0 end
    
    local count = 0
    for _, plant in pairs(PlantsPhysical:GetChildren()) do
        if not IsRunning then break end
        if count >= 7 then break end
        
        FavoritePlant(plant)
        count = count + 1
        UpdateProgress(count, 7, "Favoriting")
        wait(0.2)
    end
    
    return count
end

--// Main Loop
local function RunScript()
    if IsRunning then return end
    
    local loops = tonumber(LoopBox.Text) or 1
    IsRunning = true
    
    UpdateStatus("Starting " .. loops .. " loops...")
    
    for i = 1, loops do
        if not IsRunning then break end
        
        UpdateStatus("Loop " .. i .. "/" .. loops)
        
        -- Plant
        local planted = Plant7Carrots()
        if planted == 0 then
            UpdateStatus("Planting failed!")
            break
        end
        
        wait(2) -- Wait for plants
        
        -- Favorite
        UpdateStatus("Favoriting...")
        Favorite7Plants()
        
        wait(1)
    end
    
    IsRunning = false
    UpdateStatus("Done! " .. loops .. " loops")
end

--// Test Favorite Only
local function TestFavorite()
    UpdateStatus("Testing Favorite...")
    FavoriteRemote = FindFavoriteRemote()
    if FavoriteRemote then
        UpdateStatus("Favorite Remote found: " .. FavoriteRemote.Name)
    else
        UpdateStatus("Check console for available remotes")
    end
end

--// Button Events
StartBtn.MouseButton1Click:Connect(function()
    spawn(RunScript)
end)

StopBtn.MouseButton1Click:Connect(function()
    IsRunning = false
    UpdateStatus("Stopped")
end)

TestFavBtn.MouseButton1Click:Connect(TestFavorite)

CloseBtn.MouseButton1Click:Connect(function()
    IsRunning = false
    ScreenGui:Destroy()
end)

--// Drag
local dragging = false
local dragStart, startPos

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position
    end
end)

Frame.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

Frame.InputEnded:Connect(function()
    dragging = false
end)

--// Initial Check
print("=== AUTO 7 CARROTS + FAVORITE ===")
print("Click 'Test Favorite' to find the Favorite Remote")
UpdateStatus("Ready - Click Test Favorite first!")
