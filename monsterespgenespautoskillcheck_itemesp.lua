-- Services
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local v2 = game:GetService("ReplicatedStorage")

local v3 = Players.LocalPlayer
local autoSkillEnabled = false
local monsterESP = false
local genESP = false
local itemESP = false

-- KEYBINDS
local GEN_KEY = Enum.KeyCode.F1
local MONSTER_KEY = Enum.KeyCode.F2
local PLAYER_KEY = Enum.KeyCode.F3
local ITEM_KEY = Enum.KeyCode.F4
local EXIT_KEY = Enum.KeyCode.F10

----------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------

local function getCurrentRoom()
    local container = Workspace:FindFirstChild("CurrentRoom")
    if not container then return nil end
    return container:GetChildren()[1] -- Gets the actual room model
end

local function applyHighlight(object, color, name)
    if not object:FindFirstChild(name) then
        local highlight = Instance.new("Highlight")
        highlight.Name = name
        highlight.FillColor = color
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.Parent = object
    end
end

----------------------------------------------------------------
-- REFRESH LOGIC (The Loops)
----------------------------------------------------------------

-- Combined Loop for Monsters, Gens, and Items
task.spawn(function()
    while task.wait(1) do
        local room = getCurrentRoom()
        if not room then continue end

        -- Monster ESP (F2)
        if monsterESP then
            local folder = room:FindFirstChild("Monsters")
            if folder then
                for _, m in pairs(folder:GetChildren()) do
                    applyHighlight(m, Color3.fromRGB(255, 0, 0), "MonsterHighlight")
                end
            end
        end

        -- Generator ESP (F1)
        if genESP then
            local folder = room:FindFirstChild("Generators")
            if folder then
                for _, g in pairs(folder:GetChildren()) do
                    applyHighlight(g, Color3.fromRGB(0, 255, 0), "GenHighlight")
                end
            end
        end

        -- Item ESP (F4)
        if itemESP then
            local folder = room:FindFirstChild("Items")
            if folder then
                for _, i in pairs(folder:GetChildren()) do
                    -- Items are often parts or models; highlight everything in the folder
                    applyHighlight(i, Color3.fromRGB(255, 255, 0), "ItemHighlight")
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- SKILL CHECK & INPUT
----------------------------------------------------------------

local function toggleSkillCheck(state)
    autoSkillEnabled = state
    local event = v2:FindFirstChild("Events") and v2.Events:FindFirstChild("SkillcheckUpdate")
    if not event then return end
    
    if state then
        event.OnClientInvoke = function() return "supercomplete" end
    else
        event.OnClientInvoke = nil
    end
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == GEN_KEY then
        genESP = not genESP
        print("Gen ESP:", genESP)
    elseif input.KeyCode == MONSTER_KEY then
        monsterESP = not monsterESP
        print("Monster ESP:", monsterESP)
    elseif input.KeyCode == ITEM_KEY then
        itemESP = not itemESP
        print("Item ESP:", itemESP)
    elseif input.KeyCode == PLAYER_KEY then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= v3 and v.Character then
                applyHighlight(v.Character, Color3.fromRGB(0, 170, 255), "PlayerHighlight")
            end
        end
    elseif input.KeyCode == EXIT_KEY then
        screenGui:Destroy()
    end
end)

----------------------------------------------------------------
-- UI SETUP
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui", v3.PlayerGui)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 60)
mainFrame.Position = UDim2.new(0.5, -110, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", mainFrame)

local btn = Instance.new("TextButton", mainFrame)
btn.Size = UDim2.new(1, 0, 1, 0)
btn.Text = "Auto Skill Check: OFF"
btn.TextColor3 = Color3.new(1, 0, 0)
btn.BackgroundTransparency = 1
btn.Font = Enum.Font.GothamBold
btn.TextSize = 14

btn.MouseButton1Click:Connect(function()
    autoSkillEnabled = not autoSkillEnabled
    toggleSkillCheck(autoSkillEnabled)
    btn.Text = autoSkillEnabled and "Auto Skill Check: ON" or "Auto Skill Check: OFF"
    btn.TextColor3 = autoSkillEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

print("--- DANDY'S WORLD HELPER ---")
print("F1: Gens | F2: Monsters | F3: Players | F4: Items | F10: Exit")
