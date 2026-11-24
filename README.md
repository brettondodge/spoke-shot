# Spoke Shot

Tap to fire spokes into a spinning hub without hitting another one. Each level is built from its level number, so the levels never run out, and level 37 is the same wheel every time.

There are two difficulties, each with its own progress. **Normal** is the default and climbs gently. **Hard** is the original game and takes real skill.

Copyright © 2026 Bretton. All rights reserved.

## Play it

- **On this Mac, offline:** double-click `index.html`. It opens in your browser and needs no internet.
- **On a phone, offline:** open <https://brettondodge.github.io/spoke-shot/> and add it to the home screen. After the first open it works with no signal. See [Putting it on a phone](#putting-it-on-a-phone).
- **Test it like a website on this Mac:** in this folder run `python3 -m http.server 8000`, then open <http://localhost:8000>. The offline helper works on localhost too.

## How progress is saved

For each difficulty, the game saves your furthest level and the level you're on. It also saves which difficulty you last played and whether sound is on. Saves from before difficulties existed count as Hard progress.

- **From a web address or this folder:** saved in that browser on that device. Each device keeps its own. Clearing browser data or using private browsing erases it.
- **On claude.ai:** also saved to your Claude account, so it follows you between devices there.

The title screen and the Levels screen say where progress is being saved, and warn you when the browser isn't keeping it.

- **Save codes:** Levels → **Save code** shows a short code (like `E2R3-ATAE`) holding both difficulties' progress. Enter it on another phone or browser to pick up there. Restoring only ever moves progress forward, and a mistyped code is rejected.
- **Home Screen tip:** in a phone's browser tab, the title screen suggests adding the game to the Home Screen, because Safari clears a site's data after about a week away. The tip never shows in the installed app, and tapping ✕ hides it for good.

## Leaderboard

Players who tap **Join the leaderboard** and pick a name share their furthest level on Normal and Hard. Nothing else is shared. Players who never join stay fully offline. The board shows on the title screen (top 3, plus your own rank) and in full from **See all** or Levels → **Leaderboard**.

- **Syncing:** a phone sends its entry when the game opens, after each new furthest level, and as soon as it's back online. Offline, the board shows the last copy it downloaded and how old it is.
- **Identity:** each phone gets an anonymous Firebase account. No email or password is involved. A new phone, or a cleared browser, is a new player until it joins again.
- **Turning it off:** empty the `LEADERBOARD` settings near the top of the script in `index.html`, and the board disappears.
- **Removing an entry:** open the [Firebase console](https://console.firebase.google.com), then Realtime Database → Data → `scores`. Hover over the entry and click the trash icon.

It runs on a free Firebase project (Realtime Database, Anonymous sign-in, and Email/Password sign-in for the admin). The web settings in `index.html` are public by design. These database rules are what protect the data: anyone can read the board, a phone can only write its own entry, and the admin account (`admin@spoke-shot.firebaseapp.com`, signed in with its password) can write any entry. Every entry must have a 1–16 character name and levels from 1 up.

```json
{
  "rules": {
    "scores": {
      ".read": true,
      ".indexOn": ["normal", "hard"],
      "$uid": {
        ".write": "auth != null && (auth.uid === $uid || (auth.token.email === 'admin@spoke-shot.firebaseapp.com' && auth.token.firebase.sign_in_provider === 'password'))",
        ".validate": "newData.hasChildren(['name', 'normal', 'hard', 'updated'])",
        "name": { ".validate": "newData.isString() && newData.val().length >= 1 && newData.val().length <= 16" },
        "normal": { ".validate": "newData.isNumber() && newData.val() >= 1 && newData.val() <= 1000000" },
        "hard": { ".validate": "newData.isNumber() && newData.val() >= 1 && newData.val() <= 1000000" },
        "updated": { ".validate": "newData.val() === now" },
        "$other": { ".validate": false }
      }
    }
  }
}
```

The game runs on players' phones, so someone tech-savvy could post a made-up level. Fix or erase it from the admin screen.

## Admin

Hold the **Level** label at the top left for 3 seconds, then sign in with user `Admin` and the admin password. Tap any player to rename them, change their Normal and Hard levels, or erase them. Erasing takes two taps.

- **Changes stick.** A player's phone takes your edit the next time it connects. Their game progress follows the new levels, and a renamed or erased player isn't put back by their own phone. An erased player can choose to join again.
- **Staying signed in:** you stay signed in until you tap **Sign out** or close the app. Holding Level again while signed in goes straight to the player list.
- **Where the password lives:** only in Firebase. It is never in this repository or the game's code. Anyone who finds the hidden sign-in still needs the password, and Firebase slows down repeated wrong guesses, so use a password that isn't easy to guess.

One-time setup in the [Firebase console](https://console.firebase.google.com):

1. **Authentication → Sign-in method → Add new provider → Email/Password.** Turn on **Email/Password**, leave Email link off, and click **Save**.
2. **Authentication → Users → Add user.** Use email `admin@spoke-shot.firebaseapp.com` and your admin password. (The game turns the user name `Admin` into that address.)
3. **Realtime Database → Rules.** Paste the rules above and click **Publish**.

Do step 2 before step 3. The rules trust whoever owns that email address, and Firebase never lets a second account take an address that's already in use. Creating the account first claims it.

**Forgot the password?** "Reset password" sends an email, and that address has no inbox. Instead, delete the admin user and add it again with a new password. The rules don't need to change.

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
| `sw.js` | Offline helper (service worker). Bump `CACHE` with every release so installed copies switch over on their next launch. List any new files in `FILES`. |
| `manifest.webmanifest` | Home-screen name, icon and colors |
| `fonts/` | Bagel Fat One and Atkinson Hyperlegible, with their licenses |
| `icons/` | App icons. Redraw them with `swift tools/make-icons.swift icons` |
| `tools/build-artifact.py` | Makes the claude.ai preview page from `index.html` |

## Tuning the levels

All in `index.html`:

- `DIFFS` holds one recipe per difficulty:
  - `fire`, `pre` and `speed` set the spokes to fire, the spokes already on the hub, and the spin speed for level `n`.
  - `unlock` sets the level where each spin pattern first appears.
  - `maxTotal` caps how many spokes one hub can carry.
  - `hit` sets how forgiving a near miss is. Lower is more forgiving.
- Changing Hard's recipe changes levels that players have already reached, so tune Normal first.
- `makeLevel(n, difficulty)` turns a recipe into a wheel. Keep the order of its `r()` calls, or every level changes.
- `WORLDS` holds the color palette for each 10-level world.

## Credits

- Bagel Fat One, by The Bagel Fat Project Authors. SIL Open Font License 1.1.
- Atkinson Hyperlegible, by the Braille Institute of America. SIL Open Font License 1.1.
