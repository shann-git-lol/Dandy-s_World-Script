-- Services
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local v2 = game:GetService("ReplicatedStorage")

local v3 = Players.LocalPlayer
local autoSkillEnabled = false
local monsterESP = false
local genESP = false

-- KEYBINDS
local GEN_KEY = Enum.KeyCode.F1
local MONSTER_KEY = Enum.KeyCode.F2
local PLAYER_KEY = Enum.KeyCode.F3
local EXIT_KEY = Enum.KeyCode.F10

----------------------------------------------------------------
-- HELPER FUNCTIONS
----------------------------------------------------------------

local function getCurrentRoom()
    local container = Workspace:FindFirstChild("CurrentRoom")
    if not container then return nil end
    return container:GetChildren()[1]
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

-- Monster Loop
task.spawn(function()
    while task.wait(1) do
        if monsterESP then
            local room = getCurrentRoom()
            local folder = room and room:FindFirstChild("Monsters")
            if folder then
                for _, m in pairs(folder:GetChildren()) do
                    if m:IsA("Model") or m:IsA("BasePart") then
                        applyHighlight(m, Color3.fromRGB(255, 0, 0), "MonsterHighlight")
                    end
                end
            end
        end
    end
end)

-- Generator Loop
task.spawn(function()
    while task.wait(1) do
        if genESP then
            local room = getCurrentRoom()
            local folder = room and room:FindFirstChild("Generators")
            if folder then
                for _, g in pairs(folder:GetChildren()) do
                    if g:IsA("Model") or g:IsA("BasePart") then
                        applyHighlight(g, Color3.fromRGB(0, 255, 0), "GenHighlight")
                    end
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
        event.OnClientInvoke = function()
            return "supercomplete"
        end
    else
        event.OnClientInvoke = nil
    end
end

UIS.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == GEN_KEY then
        genESP = not genESP
        print("Generator ESP:", genESP and "ON" or "OFF")
    elseif input.KeyCode == MONSTER_KEY then
        monsterESP = not monsterESP
        print("Monster ESP:", monsterESP and "ON" or "OFF")
    elseif input.KeyCode == PLAYER_KEY then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= v3 and v.Character then
                applyHighlight(v.Character, Color3.fromRGB(0, 170, 255), "PlayerHighlight")
            end
        end
    elseif input.KeyCode == EXIT_KEY then
        screenGui:Destroy()
        -- Note: script:Destroy() only works in specific exploit environments
    end
end)

----------------------------------------------------------------
-- UI SETUP
----------------------------------------------------------------

local screenGui = Instance.new("ScreenGui", v3.PlayerGui)
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 200, 0, 50)
mainFrame.Position = UDim2.new(0.5, -100, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", mainFrame)

local btn = Instance.new("TextButton", mainFrame)
btn.Size = UDim2.new(1, 0, 1, 0)
btn.Text = "Auto Skill Check: OFF"
btn.TextColor3 = Color3.new(1, 0, 0)
btn.BackgroundTransparency = 1
btn.Font = Enum.Font.GothamBold

btn.MouseButton1Click:Connect(function()
    autoSkillEnabled = not autoSkillEnabled
    toggleSkillCheck(autoSkillEnabled)
    btn.Text = autoSkillEnabled and "Auto Skill Check: ON" or "Auto Skill Check: OFF"
    btn.TextColor3 = autoSkillEnabled and Color3.new(0, 1, 0) or Color3.new(1, 0, 0)
end)

print("--- DANDY'S WORLD HELPER LOADED ---")
