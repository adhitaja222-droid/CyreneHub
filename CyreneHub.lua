-- // AUTO QUEST UI - Wizard Alchemy (FIXED v2)
local RS = game:GetService("ReplicatedStorage")
local Msg = RS:WaitForChild("Msg")
local RemoteEvent = Msg:WaitForChild("RemoteEvent"):WaitForChild("RemoteEvent")
local TalkFunc = Msg:WaitForChild("Function"):WaitForChild("TalkFunc")
local player = game:GetService("Players").LocalPlayer
local playerGui = player.PlayerGui
local UIS = game:GetService("UserInputService")

local QUEST_MAP = {
    [1] = "任务2",
    [2] = "任务3",
    [3] = "任务4",
    [4] = "任务5",
    [5] = "任务6",
}

local QUEST_NAMES = {
    [1] = "The Bully of the Forest I",
    [2] = "The Bully of the Forest II",
    [3] = "The Forest Bandits I",
    [4] = "The Forest Bandits II",
    [5] = "Down with the Dwarf King!",
}

local questEnabled = {false, false, false, false, false}
local skipCurrent = false

-- // BUAT UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoQuestUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 320)
mainFrame.Position = UDim2.new(0, 20, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚔️ Auto Quest  [K] Hide"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

-- Draggable
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)
titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

local toggleLabel = Instance.new("TextLabel")
toggleLabel.Size = UDim2.new(1, -20, 0, 25)
toggleLabel.Position = UDim2.new(0, 10, 0, 45)
toggleLabel.BackgroundTransparency = 1
toggleLabel.Text = "Quest Toggles"
toggleLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
toggleLabel.TextScaled = true
toggleLabel.Font = Enum.Font.GothamBold
toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
toggleLabel.Parent = mainFrame

local circles = {}
local toggleBtns = {}

for i = 1, 5 do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 36)
    row.Position = UDim2.new(0, 10, 0, 70 + (i-1) * 42)
    row.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    row.BorderSizePixel = 0
    row.Parent = mainFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

    local questName = Instance.new("TextLabel")
    questName.Size = UDim2.new(0.75, 0, 1, 0)
    questName.Position = UDim2.new(0, 10, 0, 0)
    questName.BackgroundTransparency = 1
    questName.Text = QUEST_NAMES[i]
    questName.TextColor3 = Color3.fromRGB(220, 220, 220)
    questName.TextScaled = true
    questName.Font = Enum.Font.Gotham
    questName.TextXAlignment = Enum.TextXAlignment.Left
    questName.Parent = row

    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 44, 0, 24)
    toggleBtn.Position = UDim2.new(1, -54, 0.5, -12)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Parent = row
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)
    toggleBtns[i] = toggleBtn

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 18, 0, 18)
    circle.Position = UDim2.new(0, 3, 0.5, -9)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BorderSizePixel = 0
    circle.Parent = toggleBtn
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    circles[i] = circle

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.Parent = row

    local idx = i
    button.MouseButton1Click:Connect(function()
        questEnabled[idx] = not questEnabled[idx]
        if questEnabled[idx] then
            toggleBtns[idx].BackgroundColor3 = Color3.fromRGB(88, 101, 242)
            circles[idx].Position = UDim2.new(1, -21, 0.5, -9)
        else
            toggleBtns[idx].BackgroundColor3 = Color3.fromRGB(80, 80, 100)
            circles[idx].Position = UDim2.new(0, 3, 0.5, -9)
            -- Skip quest yang sedang jalan kalau di-off
            skipCurrent = true
        end
    end)
end

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 25)
statusLabel.Position = UDim2.new(0, 10, 1, -35)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Idle - Pilih quest dulu!"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
statusLabel.TextScaled = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

-- // QUEST FUNCTIONS
local function openDialog()
    RemoteEvent:FireServer("触发聊天", {"哈利因特", 10010100})
    wait(0.5)
    RemoteEvent:FireServer("触发聊天", {"哈利因特", 10010501})
    wait(1)
end

local function acceptQuest(index)
    openDialog()
    TalkFunc:InvokeServer("发放任务", {QUEST_MAP[index]})
    statusLabel.Text = "Quest "..index..": Bunuh musuh!"
    statusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
end

local function submitQuest()
    openDialog()
    for i = 1, 20 do
        pcall(function()
            TalkFunc:InvokeServer("完成任务", {"任务"..i})
        end)
        wait(0.1)
    end
end

local function waitForComplete(questIndex)
    local timeout = tick()
    while true do
        wait(2)
        -- Skip kalau toggle dimatiin
        if not questEnabled[questIndex] or skipCurrent then
            skipCurrent = false
            return false
        end
        -- Cek quest selesai
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Text and gui.Text:find("Talk") then
                return true
            end
        end
        -- Timeout 5 menit
        if tick() - timeout > 300 then
            return false
        end
    end
end

-- // MAIN LOOP
local round = 0
coroutine.wrap(function()
    while true do
        wait(1)

        local hasQuest = false
        for i = 1, 5 do
            if questEnabled[i] then hasQuest = true break end
        end

        if not hasQuest then
            statusLabel.Text = "Idle - Pilih quest dulu!"
            statusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        else
            round = round + 1
            statusLabel.Text = "Round "..round.." dimulai!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 220, 100)

            for i = 1, 5 do
                if questEnabled[i] then
                    acceptQuest(i)
                    local done = waitForComplete(i)
                    if done then
                        statusLabel.Text = "Quest "..i..": Submitting..."
                        statusLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
                        submitQuest()
                        wait(2)
                    else
                        print("Quest "..i.." diskip!")
                    end
                end
            end

            statusLabel.Text = "Round "..round.." selesai!"
            wait(1)
        end
    end
end)()

print("✅ Auto Quest UI siap! Tekan K untuk hide/show!")
