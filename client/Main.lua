
local QBCore = exports["qb-core"]:GetCoreObject()
local PlayerData = QBCore.Functions.GetPlayerData()
local isInVehicle = false
local seatbeltOn = false
local harnessOn = false
local cruiseOn = false
local speedMultiplier = 3.6
local hunger = 100
local thirst = 100
local stress = 100
local radioActive = false
local oxygen = 0
local lastFuelCheck = 0

DisplayRadar(false)

RegisterNetEvent("hud:client:UpdateNeeds", function(newHunger, newThirst)
hunger = newHunger
thirst = newThirst
end)

RegisterNetEvent("hud:client:UpdateStress", function(newStress)
stress = newStress
end)

RegisterNetEvent("pma-voice:radioActive")

AddEventHandler("pma-voice:radioActive", function(active)
radioActive = active
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
Wait(1000)
PlayerData = QBCore.Functions.GetPlayerData()
local ped = PlayerPedId()
local playerId = PlayerId()

CreateThread(function()
if not PlayerData.metadata.inlaststand and not PlayerData.metadata.isdead then
SetEntityHealth(ped, 200)
end
end)

Wait(1000)
TriggerEvent("hud:client:LoadMap")
end)

AddEventHandler("onResourceStart", function(resourceName)
if GetCurrentResourceName() ~= resourceName then
return
end

Wait(1000)
TriggerEvent("hud:client:LoadMap")
end)

RegisterNetEvent("hud:client:LoadMap", function()
Wait(50)
local defaultAspectRatio = 1.7777777777777777
local resolutionX, resolutionY = GetActiveScreenResolution()
local aspectRatio = resolutionX / resolutionY
local minimapOffset = 0

if defaultAspectRatio < aspectRatio then
minimapOffset = ((defaultAspectRatio - aspectRatio) / 3.6) - 0.008
end

RequestStreamedTextureDict("squaremap", false)
if not HasStreamedTextureDictLoaded("squaremap") then
Wait(150)
end

SetMinimapClipType(0)
AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "squaremap", "radarmasksm")
AddReplaceTexture("platform:/textures/graphics", "radarmask1g", "squaremap", "radarmasksm")
SetMinimapComponentPosition("minimap", "L", "B", 0.0 + minimapOffset, -0.047, 0.1638, 0.183)
SetMinimapComponentPosition("minimap_mask", "L", "B", 0.0 + minimapOffset, 0.0, 0.128, 0.2)
SetMinimapComponentPosition("minimap_blur", "L", "B", -0.01 + minimapOffset, 0.025, 0.262, 0.3)
SetBlipAlpha(GetNorthRadarBlip(), 0)
SetRadarBigmapEnabled(true, false)
SetMinimapClipType(0)
Wait(50)
SetRadarBigmapEnabled(false, false)
harnessOn = true
Wait(1200)
end)

RegisterNetEvent("QBCore:Client:OnPlayerUnload", function()
PlayerData = {}
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(data)
PlayerData = data
end)

RegisterNetEvent("seatbelt:client:ToggleSeatbelt", function()
seatbeltOn = not seatbeltOn
end)

RegisterNetEvent("seatbelt:client:ToggleCruise", function()
cruiseOn = not cruiseOn
end)

RegisterNetEvent("seatbelt:client:ToggleHarness", function(enabled)
harnessOn = enabled
end)

local fuelCheckTimer = 0
local cachedFuel = {}

function GetVehicleFuel(vehicle)
local currentTime = GetGameTimer()
local timeSinceLastCheck = currentTime - fuelCheckTimer

if timeSinceLastCheck > 2000 then
fuelCheckTimer = currentTime
cachedFuel = math.floor(exports["LegacyFuel"]:GetFuel(vehicle))
end

return cachedFuel
end

CreateThread(function()
while true do
Wait(500)

if LocalPlayer.state.isLoggedIn and QBCore then
isInVehicle = true
local playerId = PlayerId()
local ped = PlayerPedId()
local isDead = IsPlayerDead(ped)
local vehicle = GetVehiclePedIsIn(ped, false)
local inVehicle = IsPedInAnyVehicle(ped, false)
local speed = math.ceil(GetEntitySpeed(vehicle) * speedMultiplier)
local fuel = GetVehicleFuel(vehicle)
local hasHarness = exports['zx-smallresources']:HasHarness()

if hasHarness ~= nil then
harnessOn = hasHarness
end

if not IsEntityInWater(ped) then
oxygen = 100 - GetPlayerSprintStaminaRemaining(playerId)
else
oxygen = GetPlayerUnderwaterTimeRemaining(playerId) * 10
end

if IsPauseMenuActive() or isDead then
isInVehicle = false
end

if not inVehicle or IsThisModelABicycle(vehicle) then
SetRadarZoom(1100)
DisplayRadar(ZXExtras_ShouldShowMap(false))
SendNUIMessage({
action = isInVehicle,
type = "SimpleHud",
armour = GetPedArmour(ped),
health = GetEntityHealth(ped) - 100,
food = hunger,
thirst = thirst,
voice = LocalPlayer.state.proximity.distance,
talking = NetworkIsPlayerTalking(playerId),
stress = stress,
stamina = oxygen,
radiovf1 = radioActive,
inZone = _G.RC2_CameraInZone or false
})
else
local engineHealth = math.floor(GetVehicleEngineHealth(vehicle))
local gear = GetVehicleCurrentGear(vehicle)
local rpm = GetVehicleCurrentRpm(vehicle)

SetRadarZoom(1100)
DisplayRadar(ZXExtras_ShouldShowMap(true))
SendNUIMessage({
action = isInVehicle,
type = "CarHud",
armour = GetPedArmour(ped),
health = GetEntityHealth(ped) - 100,
food = hunger,
thirst = thirst,
voice = LocalPlayer.state.proximity.distance,
radiovf1 = radioActive,
talking = NetworkIsPlayerTalking(playerId),
stress = stress,
stamina = oxygen,
seatbelt = seatbeltOn,
harness = harnessOn,
fuel = fuel,
vehspeed = speed,
enginerun = engineHealth,
gear = gear,
rpm = rpm,
color = GetConvar("color", "default"),
inZone = _G.RC2_CameraInZone or false
})
end
else
SendNUIMessage({
action = false
})
end
end
end)
