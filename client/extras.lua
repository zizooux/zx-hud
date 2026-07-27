-- ============================================================
--  zxhud – Extras
--  Settings menu (accent color / cinematic mode / minimap mode).
--
--  Design note: this file never touches app.js or index.html.
--  It only talks to style.css's existing CSS variables (--gold,
--  --gold-dim, --gold-glow, --gold-faint) and toggles a body
--  class for cinematic mode, both applied by html/extras.js.
--  That keeps the original protected HUD renderer untouched.
-- ============================================================

local KVP_COLOR     = "zxhud_extras_color"
local KVP_MAPMODE   = "zxhud_extras_mapmode"
local KVP_CINEMATIC = "zxhud_extras_cinematic"

local ValidMapModes = { always = true, vehicle = true, ["never"] = true }

local State = {
    accentColor = Config.Extras.DefaultAccentColor,
    cinematic   = false,
    mapMode     = Config.Extras.DefaultMapMode,
}

local menuOpen = false

-- ──────────────────────────────────────────────────────────
-- Persistence
-- ──────────────────────────────────────────────────────────
local function LoadState()
    local savedColor = GetResourceKvpString(KVP_COLOR)
    local savedMode  = GetResourceKvpString(KVP_MAPMODE)
    local savedCine  = GetResourceKvpInt(KVP_CINEMATIC)

    if savedColor and savedColor:match("^#%x%x%x%x%x%x$") then
        State.accentColor = savedColor
    end

    if savedMode and ValidMapModes[savedMode] then
        State.mapMode = savedMode
    end

    State.cinematic = savedCine == 1
end

local function SaveState()
    SetResourceKvp(KVP_COLOR, State.accentColor)
    SetResourceKvp(KVP_MAPMODE, State.mapMode)
    SetResourceKvpInt(KVP_CINEMATIC, State.cinematic and 1 or 0)
end

-- ──────────────────────────────────────────────────────────
-- NUI push helpers
-- ──────────────────────────────────────────────────────────
local function PushInit()
    SendNUIMessage({
        type      = "zxhud_extras",
        action    = "init",
        color     = State.accentColor,
        cinematic = State.cinematic,
        mapMode   = State.mapMode,
        presets   = Config.Extras.ColorPresets,
        menuKey   = Config.Extras.MenuKey,
        cineKey   = Config.Extras.CinematicKey,
        barHeight = Config.Extras.Cinematic.BarHeightVh,
        fadeMs    = Config.Extras.Cinematic.FadeMs,
    })
end

-- ──────────────────────────────────────────────────────────
-- Feature: accent color
-- ──────────────────────────────────────────────────────────
local function ApplyColor(hex)
    State.accentColor = hex
    SendNUIMessage({ type = "zxhud_extras", action = "applyColor", color = hex })
    SaveState()
end

-- ──────────────────────────────────────────────────────────
-- Feature: cinematic mode
-- ──────────────────────────────────────────────────────────
local function ApplyCinematic(active)
    State.cinematic = active

    if Config.Extras.Cinematic.HideNativeHud then
        DisplayHud(not active)
    end

    if active then
        DisplayRadar(false)
    end

    SendNUIMessage({
        type      = "zxhud_extras",
        action    = "applyCinematic",
        cinematic = active,
        barHeight = Config.Extras.Cinematic.BarHeightVh,
        fadeMs    = Config.Extras.Cinematic.FadeMs,
    })

    SaveState()
end

-- ──────────────────────────────────────────────────────────
-- Feature: minimap mode
--   "always"  → map always visible
--   "vehicle" → map only visible while driving (default/original)
--   "never"   → map always hidden
-- Consumed by client/Main.lua on its existing update loop so the
-- rest of Main.lua's HUD logic is untouched.
-- ──────────────────────────────────────────────────────────
function ZXExtras_ShouldShowMap(isInVehicleContext)
    if State.cinematic then
        return false
    end

    if State.mapMode == "always" then
        return true
    elseif State.mapMode == "never" then
        return false
    end

    return isInVehicleContext -- "vehicle" mode
end

-- ──────────────────────────────────────────────────────────
-- Menu open/close
-- ──────────────────────────────────────────────────────────
local function OpenMenu()
    if menuOpen then return end
    menuOpen = true
    SetNuiFocus(true, true)
    PushInit()
    SendNUIMessage({ type = "zxhud_extras", action = "open" })
end

local function CloseMenu()
    if not menuOpen then return end
    menuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = "zxhud_extras", action = "close" })
end

RegisterCommand("hudmenu", function()
    if menuOpen then
        CloseMenu()
    else
        OpenMenu()
    end
end, false)
RegisterKeyMapping("hudmenu", "Open ZXHUD settings menu", "keyboard", Config.Extras.MenuKey)

RegisterCommand("hudcinematic", function()
    ApplyCinematic(not State.cinematic)
end, false)
RegisterKeyMapping("hudcinematic", "Toggle ZXHUD cinematic mode", "keyboard", Config.Extras.CinematicKey)

-- ──────────────────────────────────────────────────────────
-- NUI callbacks (all inputs validated before use)
-- ──────────────────────────────────────────────────────────
RegisterNUICallback("zxextras_close", function(_, cb)
    CloseMenu()
    cb({ ok = true })
end)

RegisterNUICallback("zxextras_setColor", function(data, cb)
    if type(data) == "table" and type(data.color) == "string" and data.color:match("^#%x%x%x%x%x%x$") then
        ApplyColor(data.color)
    end
    cb({ ok = true })
end)

RegisterNUICallback("zxextras_setCinematic", function(data, cb)
    if type(data) == "table" then
        ApplyCinematic(data.cinematic and true or false)
    end
    cb({ ok = true })
end)

RegisterNUICallback("zxextras_setMapMode", function(data, cb)
    if type(data) == "table" and type(data.mode) == "string" and ValidMapModes[data.mode] then
        State.mapMode = data.mode
        SaveState()
        SendNUIMessage({ type = "zxhud_extras", action = "applyMapMode", mapMode = State.mapMode })
    end
    cb({ ok = true })
end)

-- ──────────────────────────────────────────────────────────
-- Boot
-- ──────────────────────────────────────────────────────────
CreateThread(function()
    LoadState()
    Wait(1500) -- let zxhud finish its own initial LoadMap event first
    PushInit()
end)

RegisterNetEvent("QBCore:Client:OnPlayerLoaded", function()
    Wait(1500)
    PushInit()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if menuOpen then
        SetNuiFocus(false, false)
    end
end)
