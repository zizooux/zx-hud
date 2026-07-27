/**
 * zxhud – Camera Status Indicator · html/camera.js
 *
 * Because index.html is fully obfuscated and builds its DOM at
 * runtime via JS, we cannot inject static HTML.  Instead this
 * script:
 *   1. Waits for the obfuscated code to finish painting .hud-main
 *   2. Injects a camera hex-cell that is pixel-perfect to the
 *      existing .main / .box-hud pattern in style.css
 *   3. Listens for "updateCamera" NUI messages (fired on every
 *      state change by camera.lua) and for the inZone field
 *      embedded in every SimpleHud / CarHud broadcast
 */

(function () {
    "use strict";

    /* ─── constants ─────────────────────────────────────── */
    const POLL_MS      = 200;   // DOM poll interval while waiting for .hud-main
    const MAX_WAIT_MS  = 15000; // give up after this long

    /* ─── state ─────────────────────────────────────────── */
    let currentState = null;    // null = not yet initialised
    let iconEl       = null;    // the <i> element we control

    /* ─── build the camera hex-cell ─────────────────────── */
    function buildCameraCell() {
        /*
         * Structure mirrors every other icon in this HUD:
         *
         *  <div class="main">            ← outer hexagon (dark bg, shadow)
         *    <div class="box-hud">       ← inner hexagon (slightly lighter)
         *      <i id="camera-status-icon" class="fa-solid fa-camera cam-out"></i>
         *    </div>
         *  </div>
         */
        const main = document.createElement("div");
        main.className = "main";
        main.id = "camera-hex-cell";

        const box = document.createElement("div");
        box.className = "box-hud";

        const icon = document.createElement("i");
        icon.className = "fa-solid fa-camera cam-out";
        icon.id        = "camera-status-icon";
        icon.title     = "Caméra : hors zone";

        box.appendChild(icon);
        main.appendChild(box);

        return { cell: main, icon };
    }

    /* ─── apply visual state ─────────────────────────────── */
    function setCameraState(inZone) {
        if (inZone === currentState || !iconEl) return;
        currentState = inZone;

        if (inZone) {
            iconEl.classList.remove("cam-out");
            iconEl.classList.add("cam-in");
            iconEl.title = "Caméra : zone surveillée";
        } else {
            iconEl.classList.remove("cam-in");
            iconEl.classList.add("cam-out");
            iconEl.title = "Caméra : hors zone";
        }
    }

    /* ─── inject cell into .hud-main ────────────────────── */
    function inject(hudMain) {
        const { cell, icon } = buildCameraCell();
        iconEl = icon;

        /* Append as the last hex in the row so layout is undisturbed */
        hudMain.appendChild(cell);

        /* Start red until Lua confirms a zone */
        setCameraState(false);

        console.log("[zxhud] Camera status indicator injected into .hud-main");
    }

    /* ─── poll until .hud-main exists in the DOM ─────────── */
    function waitForHudMain() {
        let elapsed = 0;

        const timer = setInterval(function () {
            elapsed += POLL_MS;

            const hudMain = document.querySelector(".hud-main");
            if (hudMain) {
                clearInterval(timer);
                inject(hudMain);
                return;
            }

            if (elapsed >= MAX_WAIT_MS) {
                clearInterval(timer);
                console.warn("[zxhud] .hud-main not found after " + MAX_WAIT_MS + "ms — camera icon skipped.");
            }
        }, POLL_MS);
    }

    /* ─── NUI message listener ───────────────────────────── */
    window.addEventListener("message", function (event) {
        const data = event.data;
        if (!data) return;

        /* Dedicated event from camera.lua (fires on zone change) */
        if (data.action === "updateCamera") {
            setCameraState(!!data.inZone);
            return;
        }

        /* Piggy-back: every SimpleHud / CarHud message also carries
           inZone so the icon stays in sync with the 500ms HUD loop  */
        if (typeof data.inZone !== "undefined") {
            setCameraState(!!data.inZone);
        }
    });

    /* ─── kick off ───────────────────────────────────────── */
    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", waitForHudMain);
    } else {
        waitForHudMain();
    }

})();
