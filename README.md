# Spoke Shot

Tap to fire spokes into a spinning hub without hitting another one. Each level is built from its level number, so the levels never run out, and level 37 is the same wheel every time.

Copyright © 2026 Bretton. All rights reserved.

## Play it

- **On this Mac, offline:** double-click `index.html`. It opens in your browser and needs no internet.
- **On a phone, offline:** open <https://brettondodge.github.io/spoke-shot/> and add it to the home screen. After the first open it works with no signal. See [Putting it on a phone](#putting-it-on-a-phone).
- **Test it like a website on this Mac:** in this folder run `python3 -m http.server 8000`, then open <http://localhost:8000>. The offline helper works on localhost too.

## How progress is saved

The game saves three things: your furthest level, the level you're on, and whether sound is on.

- **From a web address or this folder:** saved in that browser on that device. Each device keeps its own. Clearing browser data or using private browsing erases it.
- **On claude.ai:** also saved to your Claude account, so it follows you between devices there.

The title screen and the Levels screen say where progress is being saved, and warn you when the browser isn't keeping it.

## Putting it on a phone

The game is hosted free on GitHub Pages at **<https://brettondodge.github.io/spoke-shot/>**. Every push to `main` updates it within a minute or two.

- **iPhone:** open the link in Safari, tap **Share → Add to Home Screen**, then open it from the home screen once while online.
- **Android:** open the link in Chrome, tap **⋮ → Add to Home screen** (or **Install app**), then open it once while online.

After that first open it plays offline. Players get updates the next time they open it with a connection.

For the App Store and Google Play later, wrap the game with Capacitor.

## Files

| Path | What it is |
| --- | --- |
| `index.html` | The whole game |
| `sw.js` | Offline helper (service worker). If you add or rename files, list them in `FILES` and bump `CACHE`. |
| `manifest.webmanifest` | Home-screen name, icon and colors |
| `fonts/` | Bagel Fat One and Atkinson Hyperlegible, with their licenses |
| `icons/` | App icons. Redraw them with `swift tools/make-icons.swift icons` |
| `tools/build-artifact.py` | Makes the claude.ai preview page from `index.html` |

## Tuning the levels

All in `index.html`:

- `makeLevel(n)` decides each level: spokes to fire, spokes already on the hub, spin speed and spin pattern.
- `MODE_UNLOCK` sets the level where each spin pattern first appears.
- `MAX_TOTAL` caps how many spokes one hub can carry. `HIT` sets how forgiving a near miss is.
- `WORLDS` holds the color palette for each 10-level world.

## Credits

- Bagel Fat One, by The Bagel Fat Project Authors. SIL Open Font License 1.1.
- Atkinson Hyperlegible, by the Braille Institute of America. SIL Open Font License 1.1.
