-- ============================================================
--  zxhud – Camera Status Indicator · Config
--  Add / remove camera coverage zones freely below.
--  Each zone needs:
--    coords  → vector3  (centre of the zone)
--    radius  → number   (metres; player inside = GREEN camera)
--    label   → string   (optional, only for debugging)
-- ============================================================

Config = {}

Config.CameraZones = {
    {
        label  = "Police Station – Mission Row",
        coords = vector3(399.09, -1007.39, 56.67),
        radius = 120.0,
    },
    {
        label  = "Police Station –sheriif /ems sandy",
        coords = vector3(1845.07, 3679.95, 39.01),
        radius = 120.0,
    },
    {
        label  = "Police Station - plaeto",
        coords = vector3(-442.49, 6010.24, 40.12),
        radius = 120.0,
    },
    {
        label  = "ems paleto",
        coords = vector3(-221.45, 6294.48, 55.81),
        radius = 120.0,
    },
    {
        label  = "ems los santos",
        coords = vector3(356.3, -1416.88, 133.32),
        radius = 130.0,
    },
    {
        label  = "big hotel",
        coords = vector3(107.79, -960.76, 62.37),
        radius = 130.0,
    },
    {
        label  = "defualt hotel",
        coords = vector3(-664.83, -1116.22, 41.68),
        radius = 130.0,
    },
    {
        label  = "cardealr 1",
        coords = vector3(-89.95, 62.24, 121.8),
        radius = 130.0,
    },
    {
        label  = "cardealr 2",
        coords = vector3(-874.06, -193.77, 53.67),
        radius = 130.0,
    },
    {
        label  = "CARDEALER 3",
        coords = vector3(-38.04, -1095.97, 40.76),
        radius = 130.0,
    },
    {
        label  = "BANK CENTRAL",
        coords = vector3(226.24, 237.91, 105.5),
        radius = 130.0,
    },
    {
        label  = "ATOM",
        coords = vector3(86.77, 287.46, 116.73),
        radius = 130.0,
    },
    {
        label  = "BURGERSHOT",
        coords = vector3(-1193.83, -892.13, 19.98),
        radius = 130.0,
    },
    {
        label  = "HORNYS",
        coords = vector3(1243.74, -359.69, 74.84),
        radius = 130.0,
    },
    {
        label  = "PIZZERIA",
        coords = vector3(806.45, -752.33, 32.81),
        radius = 130.0,
    },
    {
        label  = "HUNTING JOB",
        coords = vector3(-679.89, 5838.79, 21.65),
        radius = 130.0,
    },
    {
        label  = "GRUPPE6",
        coords = vector3(-13.17, -689.42, 32.3),
        radius = 130.0,
    },{
        label  = "POSTAL JOB",
        coords = vector3(-423.49, -2789.24, 6.13),
        radius = 130.0,
    },
    {
        label  = "CITYHALL",
        coords = vector3(-537.41, -211.91, 37.65),
        radius = 130.0,
    },
    {
        label  = "JAIL",
        coords = vector3(1730.57, 2531.72, 52.98),
        radius = 130.0,
    },
    {
        label  = "AIRPORT MILITARTY",
        coords = vector3(-2085.92, 3105.15, 32.81),
        radius = 130.0,
    },{
        label  = "AIRPORT CIVILIAN",
        coords = vector3(-969.13, -2706.95, 92.18),
        radius = 130.0,
    },{
        label  = "IMPOUND",
        coords = vector3(-187.12, -1175.51, 43.1),
        radius = 130.0,
    },
    {
        label  = "JEWLERY",
        coords = vector3(-709.1, -192.37, 56.18),
        radius = 130.0,
    },
        {
        label  = "LEGION SQUARE",
        coords = vector3(166.3, -923.3, 78.57),
        radius = 130.0,
    },
        {
        label  = "GOVERNMENT BUILDING",
        coords = vector3(293.67, -1600.07, 65.18),
        radius = 130.0,
    },
        {
        label  = "PAWN SHOP",
        coords = vector3(187.94, -1335.04, 45.32),
        radius = 130.0,
    },
     {
        label  = "GARAGE CENTRAL",
        coords = vector3(238.94, -788.31, 52.07),
        radius = 130.0,
    },
        {
        label  = "phermacy",
        coords = vector3(379.16, -834.23, 29.29),
        radius = 130.0,
    },
    


    
}

-- How often (ms) the zone check runs when the player is on foot.
-- Lower = more responsive, higher = better performance.
-- Recommended: 500 – 1000
Config.ZoneCheckInterval = 600

-- ============================================================
--  zxhud – Extras (settings menu, cinematic mode, minimap mode)
--  This does NOT touch app.js/index.html — it only reads/writes
--  the CSS variables style.css already exposes, so it works
--  alongside the protected HUD renderer instead of editing it.
-- ============================================================

Config.Extras = {
    -- Key to open the in-game settings menu. Players can also rebind
    -- this under Settings > Key Bindings > FiveM > "zxhud".
    MenuKey = "f6",

    -- Quick toggle for cinematic mode without opening the full menu.
    CinematicKey = "F7",

    -- Accent color the HUD launches with (must match a #rrggbb hex).
    DefaultAccentColor = "#967969",

    -- Preset swatches shown in the menu. Add/remove freely.
    ColorPresets = {
        { name = "Gold (default)", hex = "#967969" },
        { name = "Crimson",        hex = "#c8433a" },
        { name = "Cyan",           hex = "#3ac8c0" },
        { name = "Violet",         hex = "#8a5fd6" },
        { name = "Emerald",        hex = "#3ac87a" },
        { name = "Ice Blue",       hex = "#6fa9d8" },
        { name = "Amber",          hex = "#d69a3a" },
        { name = "Rose",           hex = "#d65f96" },
    },

    -- Minimap visibility mode:
    --   "always"  → minimap shows on foot and in vehicles
    --   "vehicle" → minimap only shows while driving (original behavior)
    --   "never"   → minimap is always hidden
    DefaultMapMode = "vehicle",

    Cinematic = {
        BarHeightVh   = 12,   -- height (vh) of the top/bottom letterbox bars
        FadeMs        = 500,  -- fade speed in/out of cinematic mode
        HideNativeHud = true, -- also hides GTA's native HUD (wanted stars, cash, ammo, etc.)
    },
}
