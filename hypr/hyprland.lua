-- =================================================================================
--   Hyprland config file for my "linux retroism" rice. 
--   Converted to the modern v0.55+ Lua configuration syntax.
-- =================================================================================

-- ── VARIABLES ────────────────────────────────────────────────────────────────────
local mainMod     = "SUPER"
local terminal    = "kitty"
local fileManager = "nemo"

-- Complex app launcher menu query preserved perfectly as a string string
local menu        = "quickshell ipc call appLauncher_$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name') toggleAppLauncher"

-- ── MONITORS ─────────────────────────────────────────────────────────────────────
-- Updated to match your current display layout
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@120.00", position = "0x250",  scale = 1 })
hl.monitor({ output = "DP-2", mode = "2560x1440@165", position = "1920x0", scale = 1 })

-- ── ENVIRONMENT VARIABLES ────────────────────────────────────────────────────────
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Hackneyed-White-Mono-Animated-Dark-24px")

-- ── AUTOSTART ────────────────────────────────────────────────────────────────────
hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("quickshell")
    hl.exec_cmd("hyprctl setcursor Hackneyed-White-Mono-Animated-Dark-24px 24")
end)

-- ── MAIN CONFIGURATION BLOCK ─────────────────────────────────────────────────────
hl.config({
    input = {
        kb_layout = "us,ru",
        kb_options = "grp:alt_shift_toggle",
        kb_rules = "",
        kb_variant = "",
        kb_model = "",
        follow_mouse = 1,
        sensitivity = -0.65,
        touchpad = {
            natural_scroll = false
        }
    },
    
    cursor = {
        no_hardware_cursors = true
    },
    
    animations = {
        enabled = false
    },
    
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        -- Dotted properties must be defined as literal string keys in Lua
        ["col.active_border"] = "rgb(d8d8d8)",
        ["col.inactive_border"] = "rgb(9b9b9b)",
        resize_on_border = true,
        layout = "dwindle",
        allow_tearing = false
    },
    
    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 2,
            render_power = 5,
            sharp = false,
            color = "rgba(0,0,0,0.85)",
            offset = "2 2",
            scale = 1
            -- 'ignore_window' removed: deprecated in v0.55+
        },
        blur = {
            enabled = false
        }
    },
    
    dwindle = {
        preserve_split = true
        -- 'pseudotile' removed: deprecated in v0.55+
    },
    
    master = {
        new_status = "master"
    },
    
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true
    }
})

-- ── KEYBINDINGS ──────────────────────────────────────────────────────────────────

-- Core Applications
hl.bind(mainMod .. " + T",       hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q",            hl.dsp.window.close())
hl.bind(mainMod .. " + E",            hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + D",            hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + B",            hl.dsp.exec_cmd("firefox"))
hl.bind("CTRL + ALT + Delete",        hl.dsp.exec_cmd("wlogout"))

-- Window Layout & State
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Directional Focus Navigation (Fixes the nil value 'move_focus' error)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Directional Window Movement (Vim keys / Arrows alternative layout if needed)
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))

-- Screenshot Utility
hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.exec_cmd("hyprshot --mode region --output-folder /tmp"))

-- Workspaces: 1-10 Dynamic Loop
for i = 1, 10 do
    local key = i % 10 -- Maps workspace 10 to key "0"
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Interactive Mouse Operations
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Multimedia Keys (Using repeating/locked flags matching old 'bindel')
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),   { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),   { repeating = true, locked = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),  { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 10%+"),                        { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"),                        { repeating = true, locked = true })

-- ── WINDOW RULES ─────────────────────────────────────────────────────────────────
hl.window_rule({ match = { class = ".*" }, suppress_event = "maximize" })