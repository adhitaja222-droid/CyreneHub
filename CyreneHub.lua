-- ================================================
--   CyreneHub - Wizard Alchemy
--   by Cyrene
--   UI Library: Rayfield
-- ================================================

local Rayfield = loadstring(game:HttpGet(
    'https://sirius.menu/rayfield'
))()

-- ================================================
--  SERVICES
-- ================================================

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Msg = RS:WaitForChild("Msg")
local RemoteEvent = Msg:WaitForChild("RemoteEvent"):WaitForChild("RemoteEvent")
local TalkFunc = Msg:WaitForChild("Function"):WaitForChild("TalkFunc")
local player = Players.LocalPlayer
local playerGui = player.PlayerGui

-- ================================================
--  QUEST DATA
-- ================================================

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
local autoQuestEnabled = false
local autoLoopEnabled = true
local antiAfkEnabled = false
local antiAfkConnection = nil

-- ================================================
--  ANTI AFK FUNCTIONS
-- ================================================

local function startAntiAFK()
    -- Disconnect dulu kalau ada yang lama
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end

    local function connectIdled()
        antiAfkConnection = player.Idled:Connect(function()
            print("[AntiAFK] Idle terdeteksi! Timer di-reset.")
            
            -- Disconnect dulu
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end

            task.wait(0.5)

            -- Reconnect lagi = timer AFK reset
            -- Karakter TIDAK bergerak sama sekali
            if antiAfkEnabled then
                connectIdled()
            end
        end)
    end

    connectIdled()
    print("[AntiAFK] Anti AFK aktif!")
end

local function stopAntiAFK()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
    print("[AntiAFK] Anti AFK dimatikan.")
end

-- ================================================
--  CREATE WINDOW
-- ================================================

local Window = Rayfield:CreateWindow({
    Name                   = "CyreneHub - Wizard Alchemy",
    Icon                   = 0,
    LoadingTitle           = "CyreneHub",
    LoadingSubtitle        = "by Cyrene",
    Theme                  = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings   = false,
    KeySystem              = false,
})

-- ================================================
--  AUTO QUEST TAB
-- ================================================

local QuestTab = Window:CreateTab("Auto Quest", "scroll-text")

local ControlSection = QuestTab:CreateSection("Controls")

QuestTab:CreateToggle({
    Name         = "Auto Quest",
    CurrentValue = false,
    Flag         = "AutoQuest",
    Callback     = function(Value)
        autoQuestEnabled = Value
        Rayfield:Notify({
            Title    = "Auto Quest",
            Content  = "Auto Quest: " .. (Value and "ON" or "OFF"),
            Duration = 2,
            Image    = 4483362458,
        })
    end,
})

QuestTab:CreateToggle({
    Name         = "Auto Loop",
    CurrentValue = true,
    Flag         = "AutoLoop",
    Callback     = function(Value)
        autoLoopEnabled = Value
    end,
})

local QuestSection = QuestTab:CreateSection("Quest Selection")

for i = 1, 5 do
    local idx = i
    QuestTab:CreateToggle({
        Name         = QUEST_NAMES[i],
        CurrentValue = false,
        Flag         = "Quest"..i,
        Callback     = function(Value)
            questEnabled[idx] = Value
            if not Value then skipCurrent = true end
        end,
    })
end

local StatusSection = QuestTab:CreateSection("Status")
local StatusLabel = QuestTab:CreateLabel("Status: Idle")

-- ================================================
--  PLAYER TAB
-- ================================================

local PlayerTab = Window:CreateTab("Player", "user")

local PlayerSection = PlayerTab:CreateSection("Stats")

PlayerTab:CreateSlider({
    Name         = "Walk Speed",
    Range        = {16, 200},
    Increment    = 1,
    Suffix       = "",
    CurrentValue = 16,
    Flag         = "WalkSpeed",
    Callback     = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = Value
        end
    end,
})

PlayerTab:CreateSlider({
    Name         = "Jump Power",
    Range        = {50, 500},
    Increment    = 1,
    Suffix       = "",
    CurrentValue = 50,
    Flag         = "JumpPower",
    Callback     = function(Value)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = Value
        end
    end,
})

-- ================================================
--  MISC TAB
-- ================================================

local MiscTab = Window:CreateTab("Misc", "settings")

local MiscSection = MiscTab:CreateSection("Misc")

MiscTab:CreateToggle({
    Name         = "Anti AFK",
    CurrentValue = false,
    Flag         = "AntiAFK",
    Callback     = function(Value)
        antiAfkEnabled = Value
        if Value then
            startAntiAFK()
            Rayfield:Notify({
                Title    = "Anti AFK",
                Content  = "Aktif! Karakter tidak akan bergerak & tidak akan di-kick.",
                Duration = 3,
                Image    = 4483362458,
            })
        else
            stopAntiAFK()
            Rayfield:Notify({
                Title    = "Anti AFK",
                Content  = "Dimatikan.",
                Duration = 2,
                Image    = 4483362458,
            })
        end
    end,
})

-- ================================================
--  SETTINGS TAB
-- ================================================

local SettingsTab = Window:CreateTab("Settings", "settings-2")

local KeybindSection = SettingsTab:CreateSection("Keybinds")

SettingsTab:CreateKeybind({
    Name           = "Emergency Stop",
    CurrentKeybind = "F8",
    HoldToInteract = false,
    Flag           = "EmergencyStop",
    Callback       = function()
        autoQuestEnabled = false
        antiAfkEnabled   = false
        stopAntiAFK()
        for i = 1, 5 do questEnabled[i] = false end
        Rayfield:Notify({
            Title   = "Emergency Stop",
            Content = "Semua script dihentikan!",
            Duration = 3,
            Image   = 4483362458,
        })
    end,
})

-- ================================================
--  QUEST LOGIC
-- ================================================

local function openDialog()
    RemoteEvent:FireServer("触发聊天", {"哈利因特", 10010100})
    task.wait(0.5)
    RemoteEvent:FireServer("触发聊天", {"哈利因特", 10010501})
    task.wait(1)
end

local function acceptQuest(index)
    openDialog()
    TalkFunc:InvokeServer("发放任务", {QUEST_MAP[index]})
    StatusLabel:Set("Quest "..index..": Bunuh musuh!")
end

local function submitQuest()
    openDialog()
    for i = 1, 20 do
        pcall(function()
            TalkFunc:InvokeServer("完成任务", {"任务"..i})
        end)
        task.wait(0.1)
    end
end

local function waitForComplete(questIndex)
    local timeout = tick()
    while true do
        task.wait(2)
        if not questEnabled[questIndex] or skipCurrent then
            skipCurrent = false
            return false
        end
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Text and gui.Text:find("Talk") then
                return true
            end
        end
        if tick() - timeout > 300 then return false end
    end
end

-- Main Quest Loop
task.spawn(function()
    local round = 0
    while true do
        task.wait(1)

        if not autoQuestEnabled then
            StatusLabel:Set("Status: Idle")
            continue
        end

        local hasAny = false
        for i = 1, 5 do
            if questEnabled[i] then hasAny = true break end
        end

        if not hasAny then
            StatusLabel:Set("Pilih quest dulu!")
            continue
        end

        round = round + 1
        StatusLabel:Set("Round "..round.." dimulai!")

        for i = 1, 5 do
            if questEnabled[i] and autoQuestEnabled then
                acceptQuest(i)
                local done = waitForComplete(i)
                if done then
                    StatusLabel:Set("Quest "..i..": Submitting...")
                    submitQuest()
                    Rayfield:Notify({
                        Title   = "Quest Selesai!",
                        Content = QUEST_NAMES[i].." berhasil disubmit!",
                        Duration = 3,
                        Image   = 4483362458,
                    })
                    task.wait(2)
                end
            end
        end

        StatusLabel:Set("Round "..round.." selesai!")

        if not autoLoopEnabled then
            autoQuestEnabled = false
            StatusLabel:Set("Status: Idle")
        end

        task.wait(1)
    end
end)

-- ================================================
--  NOTIFY ON LOAD
-- ================================================

Rayfield:Notify({
    Title    = "CyreneHub Loaded",
    Content  = "Wizard Alchemy Hub siap! by Cyrene",
    Duration = 4,
    Image    = 4483362458,
})