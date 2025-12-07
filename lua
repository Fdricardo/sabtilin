local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local isTeleporting = false
local noclipEnabled = false
local noclipConn = nil

local fastStealOn = false
local fastStealLoop = nil
local fastStealConn = nil

local function getCharacter()
local char = LocalPlayer.Character
if not char or not char.Parent then
char = LocalPlayer.CharacterAdded:Wait()
end
return char
end

local function getMyPlot()
local plots = workspace:FindFirstChild("Plots")
if not plots then return nil end
for _, plot in ipairs(plots:GetChildren()) do
local label = plot:FindFirstChild("PlotSign")
and plot.PlotSign:FindFirstChild("SurfaceGui")
and plot.PlotSign.SurfaceGui:FindFirstChild("Frame")
and plot.PlotSign.SurfaceGui.Frame:FindFirstChild("TextLabel")
if label then
local t = (label.ContentText or label.Text or "")
if t:find(LocalPlayer.DisplayName) and t:find("Base") then
return plot
end
end
end
return nil
end

local function getDeliveryHitbox()
local myPlot = getMyPlot()
if not myPlot then return nil end
local delivery = myPlot:FindFirstChild("DeliveryHitbox") or myPlot:FindFirstChild("DeliveryHitbox", true)
if delivery and delivery:IsA("BasePart") then
return delivery
end
return nil
end

local function setNoclip(on)
noclipEnabled = on
if on then
if noclipConn then noclipConn:Disconnect() end
noclipConn = RunService.Stepped:Connect(function()
local char = LocalPlayer.Character
if not char then return end
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = false
end
end
end)
else
if noclipConn then
noclipConn:Disconnect()
noclipConn = nil
end
local char = LocalPlayer.Character
if char then
for _, part in ipairs(char:GetDescendants()) do
if part:IsA("BasePart") then
part.CanCollide = true
end
end
end
end
end

local function shortTeleportFreezeCamera(targetCF, duration)
if isTeleporting then return end
isTeleporting = true
duration = duration or 0.2
if duration < 0.1 then duration = 0.1 end
if duration > 0.5 then duration = 0.5 end
local character = getCharacter()
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then
isTeleporting = false
return
end
local camera = workspace.CurrentCamera
if not camera then
isTeleporting = false
return
end
local originalCF = hrp.CFrame
local originalCamType = camera.CameraType
local originalCamSub = camera.CameraSubject
local originalCamCFrame = camera.CFrame
local function restoreCamera()
local char = LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")
if hum then
camera.CameraSubject = hum
camera.CameraType = Enum.CameraType.Custom
else
camera.CameraType = originalCamType or Enum.CameraType.Custom
camera.CameraSubject = originalCamSub
end
camera.CFrame = originalCamCFrame
end
local ok = pcall(function()
camera.CameraType = Enum.CameraType.Scriptable
camera.CFrame = originalCamCFrame
hrp.CFrame = targetCF
task.wait(duration)
hrp.CFrame = originalCF
end)
restoreCamera()
isTeleporting = false
if not ok then
warn("[SAB UTILS] shortTeleport error")
end
end

local function doInstantSteal()
local character = getCharacter()
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then return end
local delivery = getDeliveryHitbox()
if not delivery then return end
local targetCF = delivery.CFrame + delivery.CFrame.LookVector * 3 + Vector3.new(0, 3, 0)
shortTeleportFreezeCamera(targetCF, 0.25)
end

local function doForwardTP()
local character = getCharacter()
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then return end
hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * 8
end

local function patchPrompt(prompt)
if not prompt:IsA("ProximityPrompt") then return end
local ok = pcall(function()
if prompt.HoldDuration > 0.01 then
prompt.HoldDuration = 0.01
end
end)
if not ok then
end
end

local function setFastSteal(on)
fastStealOn = on
if on then
task.spawn(function()
for _, obj in ipairs(workspace:GetDescendants()) do
if obj:IsA("ProximityPrompt") then
patchPrompt(obj)
end
end
end)
if not fastStealLoop then
fastStealLoop = task.spawn(function()
while fastStealOn do
local ok, err = pcall(function()
for _, obj in ipairs(workspace:GetDescendants()) do
if obj:IsA("ProximityPrompt") then
patchPrompt(obj)
end
end
end)
if not ok then
warn("[SAB UTILS] FastSteal loop error:", err)
end
task.wait(0.08)
end
fastStealLoop = nil
end)
end
if fastStealConn then fastStealConn:Disconnect() end
fastStealConn = workspace.DescendantAdded:Connect(function(obj)
if fastStealOn and obj:IsA("ProximityPrompt") then
patchPrompt(obj)
end
end)
else
if fastStealConn then
fastStealConn:Disconnect()
fastStealConn = nil
end
end
end
