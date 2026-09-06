local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local CoreGui = game:GetService("CoreGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoAnswerGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 180)
frame.Position = UDim2.new(0, 20, 0, 20)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 80, 100)
stroke.Thickness = 2
stroke.Parent = frame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 75)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 45))
})
gradient.Rotation = 90
gradient.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(220, 220, 255)
title.Text = "Auto Bot"
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = frame

local answerToggleButton = Instance.new("TextButton")
answerToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
answerToggleButton.Position = UDim2.new(0.1, 0, 0.2, 0)
answerToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
answerToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
answerToggleButton.Text = "Auto Answer: OFF"
answerToggleButton.Font = Enum.Font.GothamBold
answerToggleButton.TextSize = 12
answerToggleButton.Parent = frame

local answerButtonCorner = Instance.new("UICorner")
answerButtonCorner.CornerRadius = UDim.new(0, 8)
answerButtonCorner.Parent = answerToggleButton

local farmToggleButton = Instance.new("TextButton")
farmToggleButton.Size = UDim2.new(0.8, 0, 0, 35)
farmToggleButton.Position = UDim2.new(0.1, 0, 0.45, 0)
farmToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
farmToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
farmToggleButton.Text = "Coin Farm: OFF"
farmToggleButton.Font = Enum.Font.GothamBold
farmToggleButton.TextSize = 12
farmToggleButton.Parent = frame

local farmButtonCorner = Instance.new("UICorner")
farmButtonCorner.CornerRadius = UDim.new(0, 8)
farmButtonCorner.Parent = farmToggleButton

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0.75, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
statusLabel.Text = "Waiting for question..."
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 11
statusLabel.Parent = frame

local farmStatusLabel = Instance.new("TextLabel")
farmStatusLabel.Size = UDim2.new(1, 0, 0, 20)
farmStatusLabel.Position = UDim2.new(0, 0, 0.9, 0)
farmStatusLabel.BackgroundTransparency = 1
farmStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
farmStatusLabel.Text = "Coin Farm: Inactive"
farmStatusLabel.Font = Enum.Font.Gotham
farmStatusLabel.TextSize = 11
farmStatusLabel.Parent = frame

local isAnswerActive = false
local isFarmActive = false
local lastQuestion = ""
local humanoid = nil
local character = nil

local function getHumanoid()
    character = Player.Character or Player.CharacterAdded:Wait()
    humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid
end

local function teleportToCoin()
    if not isFarmActive then return end
    
    local map = workspace:FindFirstChild("Map")
    if not map then return end
    
    local functional = map:FindFirstChild("Functional")
    if not functional then return end
    
    local spawnedLetters = functional:FindFirstChild("SpawnedLetters")
    if not spawnedLetters then return end
    
    local coin = nil
    for _, child in ipairs(spawnedLetters:GetChildren()) do
        if child:IsA("Model") then
            coin = child
            break
        end
    end
    
    if coin and getHumanoid() then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            -- Находим позицию монеты
            local coinPosition = coin:GetPivot().Position
            -- Телепортируем игрока к монете
            rootPart.CFrame = CFrame.new(coinPosition + Vector3.new(0, 3, 0))
            farmStatusLabel.Text = "Teleported to coin"
        end
    else
        farmStatusLabel.Text = "No coins found"
    end
end

local function solveMath(expression)
    expression = string.gsub(expression, "%s+", "")
    expression = string.gsub(expression, "x", "*")
    expression = string.gsub(expression, "÷", "/")
    
    local a, b = string.match(expression, "(%d+)%+(%d+)")
    if a and b then return tostring(tonumber(a) + tonumber(b)) end
    
    a, b = string.match(expression, "(%d+)%-(%d+)")
    if a and b then return tostring(tonumber(a) - tonumber(b)) end
    
    a, b = string.match(expression, "(%d+)%*(%d+)")
    if a and b then return tostring(tonumber(a) * tonumber(b)) end
    
    a, b = string.match(expression, "(%d+)%/(%d+)")
    if a and b then
        if tonumber(b) ~= 0 then
            local result = tonumber(a) / tonumber(b)
            return tostring(math.floor(result + 0.5))
        end
    end
    
    return "0"
end

local function getQuestion()
    local currentObj = workspace:FindFirstChild("Map")
    if not currentObj then return nil end

    currentObj = currentObj:FindFirstChild("Functional")
    if not currentObj then return nil end

    currentObj = currentObj:FindFirstChild("Screen")
    if not currentObj then return nil end

    currentObj = currentObj:FindFirstChild("SurfaceGui")
    if not currentObj then return nil end

    currentObj = currentObj:FindFirstChild("MainFrame")
    if not currentObj then return nil end

    currentObj = currentObj:FindFirstChild("MainGameContainer")
    if not currentObj then return nil end

    currentObj = currentObj:FindFirstChild("MainTxtContainer")
    if not currentObj then return nil end

    currentObj = currentObj:FindFirstChild("QuestionText")
    if not currentObj or not currentObj:IsA("TextLabel") then return nil end
    
    return currentObj.Text
end

local function checkAndAnswer()
    local mainGui = PlayerGui:FindFirstChild("MainGui")
    if not mainGui then return false end
    
    local gameFrame = mainGui:FindFirstChild("GameFrame")
    if not gameFrame then return false end
    
    local textBoxContainer = gameFrame:FindFirstChild("PCTextBoxContainer")
    if not textBoxContainer then return false end
    
    if textBoxContainer.Visible then
        local textBox = textBoxContainer:FindFirstChild("TextBox")
        if textBox and textBox:IsA("TextBox") then
            local question = getQuestion()
            if question and question ~= "" and question ~= lastQuestion then
                lastQuestion = question
                local answer = solveMath(question)
                
                local randomDelay = math.random(1, 1)
                statusLabel.Text = "Answering in " .. randomDelay .. "s..."
                
                wait(randomDelay)
                
                textBox.Text = answer
                statusLabel.Text = "Answered: " .. answer
                
                return true
            end
        end
    end
    
    return false
end

answerToggleButton.MouseButton1Click:Connect(function()
    isAnswerActive = not isAnswerActive
    
    if isAnswerActive then
        answerToggleButton.BackgroundColor3 = Color3.fromRGB(80, 200, 120)
        answerToggleButton.Text = "Auto Answer: ON"
        statusLabel.Text = "Active - Monitoring..."
    else
        answerToggleButton.BackgroundColor3 = Color3.fromRGB(200, 60, 80)
        answerToggleButton.Text = "Auto Answer: OFF"
        statusLabel.Text = "Inactive"
    end
end)

farmToggleButton.MouseButton1Click:Connect(function()
    isFarmActive = not isFarmActive
    
    if isFarmActive then
        farmToggleButton.BackgroundColor3 = Color3.fromRGB(120, 200, 80)
        farmToggleButton.Text = "Coin Farm: ON"
        farmStatusLabel.Text = "Coin Farm: Active"
    else
        farmToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 180)
        farmToggleButton.Text = "Coin Farm: OFF"
        farmStatusLabel.Text = "Coin Farm: Inactive"
    end
end)

coroutine.wrap(function()
    while true do
        if isAnswerActive then
            checkAndAnswer()
        end
        wait(0.3)
    end
end)()

coroutine.wrap(function()
    while true do
        if isFarmActive then
            teleportToCoin()
            wait(2)
        else
            wait(0.5)
        end
    end
end)()

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

local notificationGui = Instance.new("ScreenGui")
notificationGui.Name = "NotificationGui"
notificationGui.ResetOnSpawn = false
notificationGui.Parent = CoreGui

local notificationFrame = Instance.new("Frame")
notificationFrame.Size = UDim2.new(0, 300, 0, 60)
notificationFrame.Position = UDim2.new(0.5, -150, 0.1, 0)
notificationFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
notificationFrame.BorderSizePixel = 0
notificationFrame.Parent = notificationGui

local notificationCorner = Instance.new("UICorner")
notificationCorner.CornerRadius = UDim.new(0, 10)
notificationCorner.Parent = notificationFrame

local notificationStroke = Instance.new("UIStroke")
notificationStroke.Color = Color3.fromRGB(100, 100, 150)
notificationStroke.Thickness = 2
notificationStroke.Parent = notificationFrame

local notificationLabel = Instance.new("TextLabel")
notificationLabel.Size = UDim2.new(1, 0, 1, 0)
notificationLabel.BackgroundTransparency = 1
notificationLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
notificationLabel.Text = "Made by Kirusha222"
notificationLabel.Font = Enum.Font.Gotham
notificationLabel.TextSize = 14
notificationLabel.Parent = notificationFrame

wait(3)

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(notificationFrame, tweenInfo, {Position = UDim2.new(0.5, -150, -0.1, 0)})
tween:Play()

tween.Completed:Connect(function()
    notificationGui:Destroy()
end)
