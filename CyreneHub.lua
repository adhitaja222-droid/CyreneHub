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
local RemoteFunction = Msg:WaitForChild("RemoteFunction"):WaitForChild("RemoteFunction")
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

-- ================================================
--  SELL DATA
-- ================================================

local MATERIAL_LIST = {
    {name = "Copper Earring",       id = 1036},
    {name = "Goblin Bone",          id = 1144},
    {name = "Flame Crest",          id = 1099},
    {name = "Wind Shard",           id = 1151},
    {name = "Light Shard",          id = 1110},
    {name = "Goblin Finger",        id = 1145},
    {name = "Golden Tooth",         id = 1147},
    {name = "Dwarf Emblem",         id = 1146},
    {name = "Withered Mushroom",    id = 1149},
    {name = "Blueberry",            id = 1150},
}

-- ================================================
--  VARIABLES
-- ================================================

local questEnabled = {false, false, false, false, false}
local sellEnabled = {}
local skipCurrent = false
local autoQuestEnabled = false
local autoLoopEnabled = true
local antiAfkEnabled = false
local antiAfkConnection = nil
local autoSellEnabled = false

for i = 1, #MATERIAL_LIST do
    sellEnabled[i] = false
end

-- ================================================
--  ANTI AFK
-- ================================================

local function startAntiAFK()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end

    local function connectIdled()
        antiAfkConnection = player.Idled:Connect(function()
            print("[AntiAFK] Idle dicegah!")
            if antiAfkConnection then
                antiAfkConnection:Disconnect()
                antiAfkConnection = nil
            end
            task.wait(0.5)
            if antiAfkEnabled then
                connectIdled()
            end
        end)
    end

    connectIdled()
end

local function stopAntiAFK()
    if antiAfkConnection then
        antiAfkConnection:Disconnect()
        antiAfkConnection = nil
    end
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

QuestTab:CreateSection("Controls")

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

QuestTab:CreateSection("Quest Selection")

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

QuestTab:CreateSection("Status")
local StatusLabel = QuestTab:CreateLabel("Status: Idle")

-- ================================================
--  AUTO SELL TAB
-- ================================================

local SellTab = Window:CreateTab("Auto Sell", "shopping-cart")

SellTab:CreateSection("Controls")

SellTab:CreateToggle({
    Name         = "Auto Sell",
    CurrentValue = false,
    Flag         = "AutoSell",
    Callback     = function(Value)
        autoSellEnabled = Value
        Rayfield:Notify({
            Title    = "Auto Sell",
            Content  = "Auto Sell: " .. (Value and "ON" or "OFF"),
            Duration = 2,
            Image    = 4483362458,
        })
    end,
})

SellTab:CreateButton({
    Name     = "Sell Now",
    Callback = function()
        local hasSell = false
        for i = 1, #MATERIAL_LIST do
            if sellEnabled[i] then hasSell = true break end
        end
        if not hasSell then
            Rayfield:Notify({
                Title   = "Auto Sell",
                Content = "Pilih item dulu!",
                Duration = 2,
                Image   = 4483362458,
            })
            return
        end
        -- Trigger sell
        autoSellEnabled = true
        task.wait(0.1)
        autoSellEnabled = false
    end,
})

SellTab:CreateSection("Item Selection")

for i = 1, #MATERIAL_LIST do
    local idx = i
    SellTab:CreateToggle({
        Name         = MATERIAL_LIST[i].name,
        CurrentValue = false,
        Flag         = "Sell"..i,
        Callback     = function(Value)
            sellEnabled[idx] = Value
        end,
    })
end

SellTab:CreateSection("Status")
local SellStatusLabel = SellTab:CreateLabel("Status: Idle")

-- ================================================
--  PLAYER TAB
-- ================================================

local PlayerTab = Window:CreateTab("Player", "user")

PlayerTab:CreateSection("Stats")

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

MiscTab:CreateSection("Misc")

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
                Content  = "Aktif! Tidak akan di-kick.",
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

SettingsTab:CreateSection("Keybinds")

SettingsTab:CreateKeybind({
    Name           = "Emergency Stop",
    CurrentKeybind = "F8",
    HoldToInteract = false,
    Flag           = "EmergencyStop",
    Callback       = function()
        autoQuestEnabled = false
        autoSellEnabled  = false
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

local function openQuestDialog()
    RemoteEvent:FireServer("触发聊天", {"哈利因特", 10010100})
    task.wait(0.5)
    RemoteEvent:FireServer("触发聊天", {"哈利因特", 10010501})
    task.wait(1)
end

local function acceptQuest(index)
    openQuestDialog()
    TalkFunc:InvokeServer("发放任务", {QUEST_MAP[index]})
    StatusLabel:Set("Quest "..index..": Bunuh musuh!")
end

local function submitQuest()
    openQuestDialog()
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
--  SELL LOGIC
-- ================================================

local function openSellDialog()
    RemoteEvent:FireServer("触发聊天", {"隆巴特", 10030100})
    task.wait(0.5)
    RemoteEvent:FireServer("触发聊天", {"隆巴特", 10030401})
    task.wait(1)
    TalkFunc:InvokeServer("打开界面", {"SellPop"})
    task.wait(1)
end

local function doSell()
    SellStatusLabel:Set("Membuka toko...")
    openSellDialog()

    local countList = {}
    local onlyIDList = {}
    local count = 0
    local bag = player:FindFirstChild("Bag")

    if not bag then
        SellStatusLabel:Set("Bag tidak ditemukan!")
        return
    end

    -- Kumpulkan item yang dipilih
    for i, mat in ipairs(MATERIAL_LIST) do
        if sellEnabled[i] then
            -- Cari jumlah item di bag berdasarkan ID sell
            for _, item in pairs(bag:GetChildren()) do
                if item:IsA("NumberValue") and item.Value > 0 then
                    -- Match ID bag ke ID sell
                    count = count + 1
                    countList[count] = item.Value
                    onlyIDList[count] = mat.id
                    print("Sell:", mat.name, "x"..item.Value, "ID:", mat.id)
                    break
                end
            end
        end
    end

    if count == 0 then
        SellStatusLabel:Set("Tidak ada item dipilih!")
        return
    end

    -- Kirim sell request
    local ok, result = pcall(function()
        return RemoteFunction:InvokeServer("出售包物品", {
            countList = countList,
            onlyIDList = onlyIDList
        })
    end)

    if ok then
        SellStatusLabel:Set("Sell selesai! "..count.." item terjual.")
        Rayfield:Notify({
            Title   = "Auto Sell",
            Content = count.." item berhasil dijual!",
            Duration = 3,
            Image   = 4483362458,
        })
    else
        SellStatusLabel:Set("Sell gagal!")
    end
end

-- Auto Sell Loop (cek inventory penuh)
task.spawn(function()
    while true do
        task.wait(5)
        if autoSellEnabled then
            local bagFull = player:FindFirstChild("BagFullMaterial")
            if bagFull and bagFull.Value == true then
                SellStatusLabel:Set("Inventory penuh! Auto sell...")
                doSell()
            end
        end
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