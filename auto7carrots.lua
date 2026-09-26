local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local GameEvents = ReplicatedStorage:WaitForChild("GameEvents")
local Farms = workspace:WaitForChild("Farm")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Auto7Carrots"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 300, 0, 250)
Frame.Position = UDim2.new(0.5, -150, 0.5, -125)
Frame.BackgroundColor3 = Color3.fromRGB(45, 95, 25)
Frame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "Auto 7 Carrots + Favorite"
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(26, 20, 8)
Title.Parent = Frame

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

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, 0, 0, 30)
Status.Position = UDim2.new(0, 0, 0, 100)
Status.Text = "Status: Ready"
Status.TextSize = 14
Status.TextColor3 = Color3.fromRGB(0, 255, 0)
Status.BackgroundTransparency = 1
Status.Parent = Frame

local Progress = Instance.new("TextLabel")
Progress.Size = UDim2.new(1, 0, 0, 25)
Progress.Position = UDim2.new(0, 0, 0, 130)
Progress.Text = "Progress: 0/7"
Progress.TextSize = 12
Progress.TextColor3 = Color3.fromRGB(255, 255, 255)
Progress.BackgroundTransparency = 1
Progress.Parent = Frame

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

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 35)
CloseBtn.Position = UDim2.new(1, -30, 0, 0)
CloseBtn.Text = "X"
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = Frame

local IsRunning = false

local function UpdateStatus(msg)
    Status.Text = "Status: " .. msg
    print(msg)
end

local function GetFarm()
    for _, farm in pairs(Farms:GetChildren()) do
        local important = farm:FindFirstChild("Important")
        if important then
            local data = important:FindFirstChild("Data")
            if data then
                local owner = data:FindFirstChild("Owner")
                if owner and owner.Value == LocalPlayer.Name then
                    return farm
                end
            end
        end
    end
    return nil
end

local function GetArea(Base)
    local Center = Base:GetPivot()
    local Size = Base.Size
    local X1 = math.ceil(Center.X - (Size.X/2))
    local Z1 = math.ceil(Center.Z - (Size.Z/2))
    local X2 = math.floor(Center.X + (Size.X/2))
    local Z2 = math.floor(Center.Z + (Size.Z/2))
    return X1, Z1, X2, Z2
end

local function Plant(pos, seed)
    GameEvents.Plant_RE:FireServer(pos, seed)
end

local function FindFavoriteRemote()
    local names = {"Favorite_RE", "SetFavorite", "ToggleFavorite", "MarkFavorite", "PinPlant"}
    for _, name in ipairs(names) do
        local remote = GameEvents:FindFirstChild(name)
        if remote then return remote end
    end
    return nil
end

local FavoriteRemote = FindFavoriteRemote()

local function FavoritePlant(plant)
    if not FavoriteRemote then return end
    pcall(function()
        FavoriteRemote:FireServer(plant, true)
    end)
end

local function Plant7()
    local myFarm = GetFarm()
    if not myFarm then UpdateStatus("No farm!") return 0 end
    
    local important = myFarm:FindFirstChild("Important")
    local locations = important:FindFirstChild("Plant_Locations")
    local dirt = locations:FindFirstChildOfClass("Part")
    
    if not dirt then UpdateStatus("No dirt!") return 0 end
    
    local X1, Z1, X2, Z2 = GetArea(dirt)
    local planted = 0
    
    for X = X1, X2, 2 do
        for Z = Z1, Z2, 2 do
            if planted >= 7 or not IsRunning then break end
            Plant(Vector3.new(X, 0.13, Z), "Carrot")
            planted = planted + 1
            Progress.Text = "Planting: " .. planted .. "/7"
            wait(0.3)
        end
        if planted >= 7 then break end
    end
    
    return planted
end

local function Favorite7()
    local myFarm = GetFarm()
    if not myFarm then return 0 end
    
    local important = myFarm:FindFirstChild("Important")
    local plants = important:FindFirstChild("Plants_Physical")
    
    local count = 0
    for _, plant in pairs(plants:GetChildren()) do
        if count >= 7 or not IsRunning then break end
        FavoritePlant(plant)
        count = count + 1
        Progress.Text = "Favoriting: " .. count .. "/7"
        wait(0.2)
    end
    
    return count
end

local function Run()
    if IsRunning then return end
    local loops = tonumber(LoopBox.Text) or 1
    IsRunning = true
    
    for i = 1, loops do
        if not IsRunning then break end
        UpdateStatus("Loop " .. i .. "/" .. loops .. " - Planting")
        
        if Plant7() == 0 then break end
        wait(2)
        
        UpdateStatus("Loop " .. i .. "/" .. loops .. " - Favoriting")
        Favorite7()
        wait(1)
    end
    
    IsRunning = false
    UpdateStatus("Done!")
    Progress.Text = "Progress: 0/7"
end

StartBtn.MouseButton1Click:Connect(function()
    spawn(Run)
end)

StopBtn.MouseButton1Click:Connect(function()
    IsRunning = false
    UpdateStatus("Stopped")
end)

CloseBtn.MouseButton1Click:Connect(function()
    IsRunning = false
    ScreenGui:Destroy()
end)

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

print("Auto 7 Carrots loaded!")
print("Favorite Remote: " .. (FavoriteRemote and FavoriteRemote.Name or "NOT FOUND"))