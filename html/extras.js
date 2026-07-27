/* ============================================================
 * zxhud – Extras UI
 * Standalone script. Does not read or modify app.js / index.html.
 * It only sets CSS custom properties that style.css already
 * defines (--gold, --gold-dim, --gold-glow, --gold-faint) and
 * toggles a body class for cinematic mode, plus renders its own
 * settings menu on top of the page.
 * ============================================================ */
(function () {
    "use strict";

    const state = {
        color: "#967969",
        cinematic: false,
        mapMode: "vehicle",
        presets: [],
        menuKey: "F6",
        cineKey: "F7",
        barHeight: 12,
        fadeMs: 500,
    };

    // ── style injection ────────────────────────────────────
    const style = document.createElement("style");
    style.id = "zx-extras-style";
    style.textContent = `
        #zx-extras-overlay {
            position: fixed;
            inset: 0;
            display: none;
            align-items: center;
            justify-content: center;
            z-index: 100000;
            background: rgba(0,0,0,0.45);
            font-family: "Rajdhani", "Share Tech Mono", sans-serif;
        }
        #zx-extras-overlay.zx-visible { display: flex; }

        .zx-panel {
            width: 380px;
            background: var(--panel, #080808);
            border: 1px solid var(--gold-dim, rgba(150,121,105,0.4));
            border-radius: 14px;
            box-shadow: 0 0 30px rgba(0,0,0,0.85), 0 0 18px var(--gold-dim, rgba(150,121,105,0.3));
            color: var(--text, #c8b09a);
            overflow: hidden;
        }
        .zx-panel-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 18px;
            border-bottom: 1px solid var(--gold-faint, rgba(150,121,105,0.12));
            background: var(--box, #0d0d0d);
        }
        .zx-panel-head h2 {
            font-size: 15px;
            letter-spacing: 0.14em;
            font-weight: 600;
            color: var(--gold, #967969);
            text-shadow: 0 0 8px var(--gold-glow, rgba(150,121,105,0.6));
        }
        .zx-close-btn {
            cursor: pointer;
            width: 26px;
            height: 26px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            border: 1px solid var(--gold-faint, rgba(150,121,105,0.15));
            color: var(--text, #c8b09a);
            font-size: 14px;
            transition: 0.2s;
        }
        .zx-close-btn:hover { color: #ff1744; border-color: #ff1744; }

        .zx-panel-body { padding: 18px; display: flex; flex-direction: column; gap: 18px; }

        .zx-section-title {
            font-size: 11px;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: var(--gold, #967969);
            opacity: 0.85;
            margin-bottom: 8px;
        }

        .zx-swatches { display: grid; grid-template-columns: repeat(8, 1fr); gap: 8px; }
        .zx-swatch {
            width: 100%;
            aspect-ratio: 1;
            border-radius: 50%;
            cursor: pointer;
            border: 2px solid rgba(255,255,255,0.08);
            transition: transform 0.15s ease, border-color 0.15s ease;
        }
        .zx-swatch:hover { transform: scale(1.12); }
        .zx-swatch.zx-active { border-color: #fff; box-shadow: 0 0 8px rgba(255,255,255,0.5); }

        .zx-custom-row { display: flex; gap: 8px; margin-top: 10px; align-items: center; }
        .zx-custom-row input[type="color"] {
            width: 34px; height: 34px; padding: 0; border: none; border-radius: 8px;
            background: none; cursor: pointer;
        }
        .zx-custom-row input[type="text"] {
            flex: 1;
            background: var(--box, #0d0d0d);
            border: 1px solid var(--gold-faint, rgba(150,121,105,0.15));
            border-radius: 6px;
            color: var(--text, #c8b09a);
            padding: 7px 10px;
            font-family: "Share Tech Mono", monospace;
            font-size: 12px;
        }

        .zx-toggle-row { display: flex; align-items: center; justify-content: space-between; }
        .zx-toggle-row span { font-size: 13px; }
        .zx-switch {
            width: 42px; height: 22px; border-radius: 999px;
            background: var(--box, #0d0d0d);
            border: 1px solid var(--gold-faint, rgba(150,121,105,0.2));
            position: relative; cursor: pointer; transition: 0.2s;
        }
        .zx-switch::after {
            content: "";
            position: absolute; top: 2px; left: 2px;
            width: 16px; height: 16px; border-radius: 50%;
            background: var(--text, #c8b09a);
            transition: 0.2s;
        }
        .zx-switch.zx-on { background: var(--gold-faint, rgba(150,121,105,0.35)); border-color: var(--gold, #967969); }
        .zx-switch.zx-on::after { left: 22px; background: var(--gold, #967969); box-shadow: 0 0 6px var(--gold-glow, rgba(150,121,105,0.6)); }

        .zx-segmented { display: flex; border-radius: 8px; overflow: hidden; border: 1px solid var(--gold-faint, rgba(150,121,105,0.2)); }
        .zx-segmented button {
            flex: 1; padding: 8px 4px; font-size: 11px; letter-spacing: 0.04em;
            background: var(--box, #0d0d0d); color: var(--text, #c8b09a);
            border: none; cursor: pointer; transition: 0.2s;
            font-family: "Rajdhani", sans-serif; font-weight: 600;
        }
        .zx-segmented button + button { border-left: 1px solid var(--gold-faint, rgba(150,121,105,0.15)); }
        .zx-segmented button.zx-active {
            background: var(--gold-faint, rgba(150,121,105,0.25));
            color: var(--gold, #967969);
            text-shadow: 0 0 6px var(--gold-glow, rgba(150,121,105,0.5));
        }

        .zx-hint { font-size: 10px; opacity: 0.55; margin-top: 4px; }
        .zx-panel-foot {
            padding: 12px 18px 16px;
            display: flex; justify-content: flex-end;
        }
        .zx-save-btn {
            padding: 8px 20px; border-radius: 7px; cursor: pointer;
            background: var(--gold-faint, rgba(150,121,105,0.25));
            border: 1px solid var(--gold, #967969);
            color: var(--gold, #967969);
            font-weight: 600; letter-spacing: 0.06em; font-size: 12px;
            transition: 0.2s;
        }
        .zx-save-btn:hover { background: var(--gold, #967969); color: #0a0a0a; }

        /* Cinematic mode: hides the real HUD elements by their existing
           selectors (from style.css) and shows letterbox bars. */
        body.zx-cinematic .hud-main,
        body.zx-cinematic .hud-rpm-fuel-engine,
        body.zx-cinematic .fuel-wrapper,
        body.zx-cinematic .engine-circle,
        body.zx-cinematic .gear,
        body.zx-cinematic .hud-rpm,
        body.zx-cinematic .hud-seggemts,
        body.zx-cinematic .seat-circle,
        body.zx-cinematic #camera-status-icon {
            opacity: 0 !important;
            pointer-events: none !important;
            transition: opacity 0.4s ease;
        }
        .zx-cine-bar {
            position: fixed; left: 0; right: 0; height: 0;
            background: #000; z-index: 99998; pointer-events: none;
        }
        .zx-cine-bar.zx-top { top: 0; }
        .zx-cine-bar.zx-bottom { bottom: 0; }
    `;
    document.head.appendChild(style);

    // ── cinematic letterbox bars ───────────────────────────
    const barTop = document.createElement("div");
    barTop.className = "zx-cine-bar zx-top";
    const barBottom = document.createElement("div");
    barBottom.className = "zx-cine-bar zx-bottom";
    document.body.appendChild(barTop);
    document.body.appendChild(barBottom);

    function setBarTransition(ms) {
        barTop.style.transition = `height ${ms}ms ease`;
        barBottom.style.transition = `height ${ms}ms ease`;
    }

    function setCinematicVisual(active, barHeightVh, fadeMs) {
        setBarTransition(fadeMs || 500);
        document.body.classList.toggle("zx-cinematic", !!active);
        const h = active ? `${barHeightVh || 12}vh` : "0";
        barTop.style.height = h;
        barBottom.style.height = h;
    }

    // ── accent color ────────────────────────────────────────
    function hexToRgba(hex, alpha) {
        const clean = hex.replace("#", "");
        const r = parseInt(clean.substring(0, 2), 16);
        const g = parseInt(clean.substring(2, 4), 16);
        const b = parseInt(clean.substring(4, 6), 16);
        return `rgba(${r}, ${g}, ${b}, ${alpha})`;
    }

    function applyAccentColor(hex) {
        const root = document.documentElement.style;
        root.setProperty("--gold", hex);
        root.setProperty("--gold-dim", hexToRgba(hex, 0.40));
        root.setProperty("--gold-glow", hexToRgba(hex, 0.60));
        root.setProperty("--gold-faint", hexToRgba(hex, 0.12));
    }

    // ── send to Lua ─────────────────────────────────────────
    function post(action, data) {
        fetch(`https://${GetParentResourceName()}/${action}`, {
            method: "POST",
            headers: { "Content-Type": "application/json; charset=UTF-8" },
            body: JSON.stringify(data || {}),
        }).catch(() => {});
    }

    // ── menu DOM ────────────────────────────────────────────
    const overlay = document.createElement("div");
    overlay.id = "zx-extras-overlay";
    overlay.innerHTML = `
        <div class="zx-panel">
            <div class="zx-panel-head">
                <h2>ZXHUD SETTINGS</h2>
                <div class="zx-close-btn" id="zx-close">✕</div>
            </div>
            <div class="zx-panel-body">
                <div>
                    <div class="zx-section-title">Accent Color</div>
                    <div class="zx-swatches" id="zx-swatches"></div>
                    <div class="zx-custom-row">
                        <input type="color" id="zx-color-picker" value="#967969">
                        <input type="text" id="zx-color-hex" maxlength="7" placeholder="#967969">
                    </div>
                </div>
                <div>
                    <div class="zx-section-title">Cinematic Mode</div>
                    <div class="zx-toggle-row">
                        <span>Hide HUD &amp; show letterbox bars</span>
                        <div class="zx-switch" id="zx-cine-switch"></div>
                    </div>
                    <div class="zx-hint" id="zx-cine-hint"></div>
                </div>
                <div>
                    <div class="zx-section-title">Minimap Display</div>
                    <div class="zx-segmented" id="zx-mapmode">
                        <button data-mode="always">Always</button>
                        <button data-mode="vehicle">In Vehicle</button>
                        <button data-mode="never">Off</button>
                    </div>
                </div>
            </div>
            <div class="zx-panel-foot">
                <div class="zx-save-btn" id="zx-save">Save &amp; Close</div>
            </div>
        </div>
    `;
    document.body.appendChild(overlay);

    const swatchesEl = overlay.querySelector("#zx-swatches");
    const colorPicker = overlay.querySelector("#zx-color-picker");
    const colorHex = overlay.querySelector("#zx-color-hex");
    const cineSwitch = overlay.querySelector("#zx-cine-switch");
    const cineHint = overlay.querySelector("#zx-cine-hint");
    const mapModeButtons = overlay.querySelectorAll("#zx-mapmode button");

    function renderSwatches() {
        swatchesEl.innerHTML = "";
        state.presets.forEach((p) => {
            const dot = document.createElement("div");
            dot.className = "zx-swatch";
            dot.style.background = p.hex;
            dot.title = p.name;
            dot.dataset.hex = p.hex;
            if (p.hex.toLowerCase() === state.color.toLowerCase()) dot.classList.add("zx-active");
            dot.addEventListener("click", () => selectColor(p.hex));
            swatchesEl.appendChild(dot);
        });
    }

    function selectColor(hex) {
        state.color = hex;
        applyAccentColor(hex);
        colorPicker.value = hex;
        colorHex.value = hex;
        [...swatchesEl.children].forEach((c) =>
            c.classList.toggle("zx-active", c.dataset.hex.toLowerCase() === hex.toLowerCase())
        );
        post("zxextras_setColor", { color: hex });
    }

    function updateCineUI() {
        cineSwitch.classList.toggle("zx-on", state.cinematic);
        cineHint.textContent = `Quick toggle key: ${state.cineKey}`;
    }

    function setCinematic(active) {
        state.cinematic = active;
        updateCineUI();
        setCinematicVisual(active, state.barHeight, state.fadeMs);
        post("zxextras_setCinematic", { cinematic: active });
    }

    function updateMapModeUI() {
        mapModeButtons.forEach((b) => b.classList.toggle("zx-active", b.dataset.mode === state.mapMode));
    }

    function setMapMode(mode) {
        state.mapMode = mode;
        updateMapModeUI();
        post("zxextras_setMapMode", { mode });
    }

    colorPicker.addEventListener("input", (e) => selectColor(e.target.value));
    colorHex.addEventListener("change", (e) => {
        const v = e.target.value.trim();
        if (/^#[0-9a-fA-F]{6}$/.test(v)) selectColor(v);
    });
    cineSwitch.addEventListener("click", () => setCinematic(!state.cinematic));
    mapModeButtons.forEach((b) => b.addEventListener("click", () => setMapMode(b.dataset.mode)));

    function closeMenu() {
        overlay.classList.remove("zx-visible");
        post("zxextras_close");
    }

    overlay.querySelector("#zx-close").addEventListener("click", closeMenu);
    overlay.querySelector("#zx-save").addEventListener("click", closeMenu);
    overlay.addEventListener("mousedown", (e) => {
        if (e.target === overlay) closeMenu();
    });
    document.addEventListener("keyup", (e) => {
        if (e.key === "Escape" && overlay.classList.contains("zx-visible")) closeMenu();
    });

    function openMenu() {
        renderSwatches();
        colorPicker.value = state.color;
        colorHex.value = state.color;
        updateCineUI();
        updateMapModeUI();
        overlay.classList.add("zx-visible");
    }

    // ── NUI message bridge ──────────────────────────────────
    window.addEventListener("message", (event) => {
        const d = event.data;
        if (!d || d.type !== "zxhud_extras") return;

        switch (d.action) {
            case "init":
                state.color = d.color || state.color;
                state.cinematic = !!d.cinematic;
                state.mapMode = d.mapMode || state.mapMode;
                state.presets = d.presets || [];
                state.menuKey = d.menuKey || state.menuKey;
                state.cineKey = d.cineKey || state.cineKey;
                state.barHeight = d.barHeight || state.barHeight;
                state.fadeMs = d.fadeMs || state.fadeMs;
                applyAccentColor(state.color);
                setCinematicVisual(state.cinematic, state.barHeight, state.fadeMs);
                break;
            case "open":
                openMenu();
                break;
            case "close":
                overlay.classList.remove("zx-visible");
                break;
            case "applyColor":
                state.color = d.color;
                applyAccentColor(d.color);
                break;
            case "applyCinematic":
                state.cinematic = !!d.cinematic;
                state.barHeight = d.barHeight || state.barHeight;
                state.fadeMs = d.fadeMs || state.fadeMs;
                setCinematicVisual(state.cinematic, state.barHeight, state.fadeMs);
                updateCineUI();
                break;
            case "applyMapMode":
                state.mapMode = d.mapMode;
                updateMapModeUI();
                break;
        }
    });
})();
