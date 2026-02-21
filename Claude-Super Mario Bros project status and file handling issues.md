This is a summary of the project status and recent work, suitable for providing context to Claude for your assembly language Super Mario Bros project.

---

## 📝 Project Context Summary for Claude

The project is an **assembly language implementation of Super Mario Bros** using the Irvine32 library, focusing on platforming mechanics and a full game structure.

### 1. Project Status & Scope

* **Completed:** Sections 1 (Basic Setup) and 2 (Core Gameplay) are complete (Title Screen, HUD, Basic Movement, Jumping, World 1-1 Layout, Goombas, Flagpole).
* **Incomplete/Partial:** File Handling (Section 9), Sound/Music (only SFX are done), and the Boss Level (Castle Fortress, Sections 3-5) are the primary remaining tasks.
* **Customization:** The **Speed Racer Mario** customizations (speed boost, turbo star, blue color/timer) are implemented.

---

### 2. Recent Fixes and Major Improvements

The last few sessions successfully addressed two critical structural and gameplay issues:

1.  **Mid-Air Movement Fix (Critical Gameplay):**
    * **Issue:** Mario could only jump vertically and could not move left or right while airborne (a limitation of the `ReadKey` procedure).
    * **Fix:** The `HandleInput` procedure was **replaced** to use the Windows API function **`GetAsyncKeyState`**, which allows for simultaneous detection of the jump key and horizontal movement keys (`A`/`D` and `W`/`Space`), restoring classic Mario mid-air control.

2.  **Map Vertical Expansion:**
    * **Goal:** To provide more vertical space for visual clarity and future boss level design.
    * **Change:** The World 1-1 map was expanded from **20 rows (0-19) to 24 rows (0-23)**, shifting all existing content down by four rows.
    * **Status:** All map handling procedures (`GetTileAtPosition`, `SetTileAtPosition`, `GetRowPointer`, `DrawMap`) and entity starting positions (Mario, Goombas, Flagpole) were updated to handle the new bounds, fixing multiple initialization bugs.

---

### 3. Current Focus and Next Steps

We are currently working towards fixing the remaining issues in the following order:

* **Current Task: File Handling Fixes (Section 9)**
    * Goal is to fix high scores wiping, clarify the use of the player name (for high scores), and ensure the `SaveProgress`/`LoadProgress` procedures are correctly called and functioning to support the "Continue" menu option.
* **Next Major Goal: Boss Level Integration (Castle Fortress)**
    * This is the next major feature. The integration plan involves creating a **`castleRow` map structure**, modifying the map rendering system to select the correct level based on a `currentLevel` variable, and implementing the required castle mechanics (Lava, Fire Bars, Bowser, Axe/Bridge win condition).

* the map has been implemented for level 2

IMPLEMENTATION ROADMAP (STEP-BY-STEP)
Phase 1: Castle Map & Basic Loading (5 marks)

Create castleRow0-castleRow23 arrays with castle layout
Modify GetRowPointer to support level switching
Test loading castle level after World 1-1

Phase 2: Lava & Hazards (5 marks)

Implement CheckLavaCollision
Add fire bar obstacles with rotation ( this is a maybe)
Test instant death mechanics

Phase 3: Bowser Boss (5 marks)

Create Bowser entity structure
Implement basic AI (walk, jump)
Add fire breath projectiles
Collision with Mario

Phase 4: Victory Condition (5 marks)

Add axe tile and collision
Implement bridge collapse animation
Victory/defeat screens
Integrate with high 

Phase 5:
organise the levels
so its title screen -> main menu -> level 1 -> win level 1-> level 2 