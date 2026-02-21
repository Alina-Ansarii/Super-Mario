;==============================================================================
; SUPER MARIO BROS - MASM Assembly Game
; Roll Number: 24I-0642
; Customization: Speed Racer Mario (25% speed boost, blue shirt, turbo star)
;==============================================================================

INCLUDE Irvine32.inc
includelib winmm.lib

Beep PROTO,
    dwFreq:DWORD,
    dwDuration:DWORD

GetAsyncKeyState PROTO,
    vKey:DWORD

mciSendStringA PROTO,
    lpszCommand:PTR BYTE,
    lpszReturnString:PTR BYTE,
    cchReturn:DWORD,
    hwndCallback:DWORD

.data
;==============================================================================
; CAMERA & POSITION TRACKING
;==============================================================================
oldMarioX BYTE 0
oldMarioY BYTE 0
cameraX BYTE 0

;==============================================================================
; MARIO STATE
;==============================================================================
marioX    BYTE 10
marioY    BYTE 18
marioVelY SBYTE 0
onGround  BYTE 1
jumpPower SBYTE -4
inputChar BYTE ?

;==============================================================================
; GAME STATE
;==============================================================================
currentScore  DWORD 0
coinCount     BYTE 0
currentWorld  BYTE 1
currentLevel  BYTE 1
timeRemaining WORD 300
livesCount    BYTE 3
frameCounter  DWORD 0

;==============================================================================
; UI STRINGS - TITLE SCREEN
;==============================================================================
titleArt1  BYTE "  ========================================================  ", 0
titleArt2  BYTE "                                                            ", 0
titleArt3  BYTE "   ####  #  # #### ### ####    #   #  ##  #### ###  ##     ", 0
titleArt4  BYTE "   #     #  # #  # #   #  #    ## ## #  # #  #  #  #  #    ", 0
titleArt5  BYTE "   ####  #  # #### ##  ####    # # # #### ####  #  #  #    ", 0
titleArt6  BYTE "      #  #  # #    #   # #     #   # #  # # #   #  #  #    ", 0
titleArt7  BYTE "   ####   ##  #    ### #  #    #   # #  # #  # ###  ##     ", 0
titleArt8  BYTE "                                                            ", 0
titleArt9  BYTE "             ** COAL PROJECT - FALL 2024 **                ", 0
titleArt10 BYTE "  ========================================================  ", 0
titleArt11 BYTE "                                                            ", 0
titleArt12 BYTE "                ROLL NUMBER: 24I-0642                      ", 0
titleArt13 BYTE "                                                            ", 0
titleArt14 BYTE "            CUSTOMIZATION: SPEED RACER MARIO               ", 0
titleArt15 BYTE "             - 25% Speed Boost                             ", 0
titleArt16 BYTE "             - Blue Shirt Color                            ", 0
titleArt17 BYTE "             - Turbo Star Power-Up                         ", 0

;==============================================================================
; UI STRINGS - MENUS
;==============================================================================
menuTitle  BYTE "            === MAIN MENU ===", 0
menuOpt1   BYTE "          [1] START NEW GAME", 0
menuOpt1b  BYTE "          [1] CONTINUE", 0
menuOpt1c  BYTE "          [2] START NEW GAME", 0
menuOpt2   BYTE "          [2] HIGH SCORES", 0
menuOpt2b  BYTE "          [3] HIGH SCORES", 0
menuOpt3   BYTE "          [3] INSTRUCTIONS", 0
menuOpt3b  BYTE "          [4] INSTRUCTIONS", 0
menuOpt4   BYTE "          [4] EXIT", 0
menuOpt4b  BYTE "          [5] EXIT", 0
menuPrompt BYTE "          Select option: ", 0

instTitle  BYTE "            === INSTRUCTIONS ===", 0
instLine1  BYTE "    CONTROLS:", 0
instLine2  BYTE "      W / UP    - Jump (hold for higher)", 0
instLine3  BYTE "      A / LEFT  - Move Left", 0
instLine4  BYTE "      D / RIGHT - Move Right", 0
instLine5  BYTE "      SPACE     - Jump", 0
instLine6  BYTE "      ESC       - Exit Game", 0
instLine7  BYTE " ", 0
instLine8  BYTE "    OBJECTIVE:", 0
instLine9  BYTE "      - Collect coins (o) for points", 0
instLine10 BYTE "      - Avoid falling off platforms", 0
instLine11 BYTE "      - Reach the end of each level", 0
instLine12 BYTE " ", 0
instLine13 BYTE "    YOUR CUSTOMIZATIONS (Roll 0642):", 0
instLine14 BYTE "      - Speed Boost: Mario moves 25% faster", 0
instLine15 BYTE "      - Blue Shirt: Custom color scheme", 0
instLine16 BYTE "      - Turbo Star: Special power-up", 0
instBack   BYTE "    Press any key to return to menu...", 0

pauseTitle    BYTE "        === GAME PAUSED ===", 0
pauseOpt1     BYTE "        [R] Resume Game", 0
pauseOpt2     BYTE "        [E] Exit to Menu", 0
pausePrompt   BYTE "       Select option:            ", 0

completeTitle     BYTE "    === LEVEL COMPLETE ===", 0
completeScore     BYTE "    Final Score: ", 0
completeTime      BYTE "    Time Bonus: ", 0
completeTotal     BYTE "    Total: ", 0
completeContinue  BYTE "    Press any key to continue...", 0

deathMessage BYTE "    Mario Lost a Life!", 0
gameOverMsg  BYTE "    === GAME OVER ===", 0

bowserDefeatMsg BYTE "BOWSER DEFEATED!", 0
princessMsg     BYTE "THANK YOU MARIO!", 0
princessMsg2    BYTE "YOU SAVED ME!", 0

enteringCastle  BYTE "Entering Castle...", 0
;==============================================================================
; HUD LABELS
;==============================================================================
hudMarioLabel BYTE "M A R I O", 0
hudWorldLabel BYTE "W O R L D", 0
hudTimeLabel  BYTE "T I M E", 0
hudCoinSymbol BYTE "O", 0
hudMultiply   BYTE "x", 0

;==============================================================================
; LEVEL MAP - WORLD 1-1 (120x24 characters)
;==============================================================================
row0  BYTE "                                                                                                                        ", 0
row1  BYTE "                                                                                                                        ", 0
row2  BYTE "                                                                                                                        ", 0
row3  BYTE "                                                                                                                        ", 0
row4  BYTE "                                                                                                                        ", 0
row5  BYTE "                                                              -----                                                     ", 0
row6  BYTE "   ---      ------                  ----- ---             ---                      ---    ----                  ---        ", 0
row7  BYTE "      ---                              ----                  ------                  ----                    ----         ", 0
row8  BYTE "                                                                                                                        ", 0
row9  BYTE "                                                                                                                        ", 0
row10 BYTE "                                                                                                                        ", 0
row11 BYTE "                                                                                                                        ", 0
row12 BYTE "                             o   o   o                                                                                  ", 0
row13 BYTE "                       =========                                                                                       ", 0
row14 BYTE "                 =======                                                         o o o                                 ", 0
row15 BYTE "                                                                                      ######                           ", 0
row16 BYTE "         o o o              o                                                                ?                        ", 0
row17 BYTE "      ===========                            #####          ___                                                     F  ", 0
row18 BYTE "                                               ?           |   |                                                   ||  ", 0
row19 BYTE "                                                           |   |                                                   ||  ", 0
row20 BYTE "    ==                          o o o                      |   |                       o o o                       ||  ", 0
row21 BYTE "  o                           ========                   #########                   =========                 === ||  ", 0
row22 BYTE "                                                                                                                   ||  ", 0
row23 BYTE "########################################################################################################################", 0


;==============================================================================
; CASTLE MAP - WORLD 1-2 BOSS LEVEL (120x24 characters) 
;==============================================================================
castleRow0  BYTE "                                                                                                                        ", 0
castleRow1  BYTE "                                                                                                                        ", 0
castleRow2  BYTE "                                                                                                                        ", 0
castleRow3  BYTE "      vVv                  vVv                  vVv                   vVv                      vVv                          ", 0
castleRow4  BYTE "      |||                  |||                  |||                   |||                      |||                          ", 0
castleRow5  BYTE "   [#######]            [#######]            [#######]             [#######]                [#######]                       ", 0
castleRow6  BYTE "   |  [+]  |            |  [+]  |            |  [+]  |             |  [+]  |                |  [+]  |                       ", 0
castleRow7  BYTE "   [#######]            [#######]            [#######]             [#######]                [#######]                       ", 0
castleRow8  BYTE "      |||                  |||                  |||                   |||                      |||                          ", 0
castleRow9  BYTE "                                                                                                                        ", 0
castleRow10 BYTE "                                                                                                                       ", 0
castleRow11 BYTE "  BBBBBBBBBBB              BBBBBBBBBB                                                                                   ", 0
castleRow12 BYTE "                                              BBBBBBBBB                                                                 ", 0
castleRow13 BYTE "                   BB                                       BBBBBBBB                                                   ", 0
castleRow14 BYTE "        BBBB                   BBBBBB                                    BBBBBBBBBBBBB                                  ", 0
castleRow15 BYTE "                                                  BBBB                                                                  ", 0
castleRow16 BYTE "  BB              BB                                         BB                                                         ", 0
castleRow17 BYTE "  BB                        BBBBBBB                                BB                                                   ", 0
castleRow18 BYTE "           BBBB                              BBBBBBBB                         BBBBBBB                                   ", 0
castleRow19 BYTE "                     BBBBBB                                                                         ~~~~~~~~~~A           ", 0
castleRow20 BYTE "  BB                                  BB                                                            ~~~~~~~~~~~             ", 0
castleRow21 BYTE "BBBBBBBBB      BBBB         BBBBBBBBBBBBBBB             BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB  BBBBB   ~~~~~~~~~~~      BBBBB  ", 0
castleRow22 BYTE "WwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWwWw", 0
castleRow23 BYTE "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB", 0

; PAUSE SYSTEM
;==============================================================================
gamePaused BYTE 0

;==============================================================================
; ENEMY SYSTEM - GOOMBAS
;==============================================================================
MAX_GOOMBAS EQU 3
GOOMBA_MOVE_DELAY EQU 5

goombaX       BYTE MAX_GOOMBAS DUP(0)
goombaY       BYTE MAX_GOOMBAS DUP(0)
goombaActive  BYTE MAX_GOOMBAS DUP(0)
goombaDir     BYTE MAX_GOOMBAS DUP(1)
goombaOldX    BYTE MAX_GOOMBAS DUP(0)
goombaOldY    BYTE MAX_GOOMBAS DUP(0)
goombaFrameCounter BYTE 0
goombaCount   BYTE 0

;==============================================================================
; LEVEL COMPLETION
;==============================================================================
levelComplete     BYTE 0
flagpoleX         BYTE 115
flagpoleTopY      BYTE 16
flagpoleBottomY   BYTE 22
slideCounter      BYTE 0

;==============================================================================
; POWER-UP SYSTEM - TURBO STAR
;==============================================================================
MAX_POWERUPS EQU 3
TURBO_DURATION EQU 480
MARIO_BASE_SPEED EQU 1

powerupX      BYTE MAX_POWERUPS DUP(0)
powerupY      BYTE MAX_POWERUPS DUP(0)
powerupActive BYTE MAX_POWERUPS DUP(0)
powerupType   BYTE MAX_POWERUPS DUP(0)
powerupCount  BYTE 0
turboActive   BYTE 0
turboTimer    WORD 0
blockHitX     BYTE 0
blockHitY     BYTE 0

;==============================================================================
; SOUND SYSTEM
;==============================================================================
noteFrequencies WORD 523, 587, 659, 698, 784, 880, 988, 1047
noteDuration    DWORD 150
coinCombo       BYTE 0
maxCombo        BYTE 0
lastCoinTime    DWORD 0
comboTimeout    EQU 120
jumpSoundFreq   WORD 800
enemyDefeatFreq WORD 600
powerupFreq     WORD 1000
blockHitFreq    WORD 400

;==============================================================================
; VISUAL EFFECTS - SPEED TRAILS
;==============================================================================
MAX_TRAIL_PARTICLES EQU 8

trailX        BYTE MAX_TRAIL_PARTICLES DUP(0)
trailY        BYTE MAX_TRAIL_PARTICLES DUP(0)
trailActive   BYTE MAX_TRAIL_PARTICLES DUP(0)
trailLifetime BYTE MAX_TRAIL_PARTICLES DUP(0)
trailIndex    BYTE 0
trailChars    BYTE '*', '+', '.', ' '

;==============================================================================
; FILE HANDLING
;==============================================================================
MAX_HIGHSCORES  EQU 5

playerFile      BYTE "player.txt", 0
highscoreFile   BYTE "highscore.txt", 0
progressFile    BYTE "progress.txt", 0
fileHandle      DWORD ?
playerName      BYTE 32 DUP(0)
playerNameLen   DWORD ?
highscoreNames  BYTE MAX_HIGHSCORES DUP(32 DUP(0))
highscoreValues DWORD MAX_HIGHSCORES DUP(0)
highscoreCount  BYTE 0
savedWorld      BYTE 1
savedLevel      BYTE 1
savedScore      DWORD 0
savedLives      BYTE 3
promptName      BYTE "Enter your name: ", 0
saveSuccess     BYTE "Progress saved!", 0
loadSuccess     BYTE "Progress loaded!", 0
noSaveFile      BYTE "No save file found - starting new game", 0
gameInitialized BYTE 0

;==============================================================================
; BOWSER BOSS SYSTEM
;==============================================================================
MAX_FIREBALLS EQU 5

bowserX             BYTE 0
bowserY             BYTE 0
bowserActive        BYTE 0
bowserDir           BYTE 0
bowserHealth        BYTE 0
bowserJumpTimer     BYTE 0
bowserFireTimer     BYTE 0
bowserBurstCount    BYTE 0
bowserBurstTimer    BYTE 0

fireballX           BYTE MAX_FIREBALLS DUP(0)
fireballY           BYTE MAX_FIREBALLS DUP(0)
fireballOldX        BYTE MAX_FIREBALLS DUP(0)
fireballOldY        BYTE MAX_FIREBALLS DUP(0)
fireballActive      BYTE MAX_FIREBALLS DUP(0)
fireballDir         BYTE MAX_FIREBALLS DUP(0)
fireballCount       BYTE 0

axeReached      BYTE 0
bridgeCollapse  BYTE 0
collapseFrame   BYTE 0
victoryShown    BYTE 0
;==============================================================================
; FIREBAR SYSTEM
;==============================================================================
MAX_FIREBARS EQU 3
FIREBAR_SPEED EQU 8

firebarX            BYTE MAX_FIREBARS DUP(0)
firebarY            BYTE MAX_FIREBARS DUP(0)
firebarActive       BYTE MAX_FIREBARS DUP(0)
firebarAngle        BYTE MAX_FIREBARS DUP(0)
firebarOldAngle     BYTE MAX_FIREBARS DUP(0)
firebarCount        BYTE 0
firebarFrameCounter BYTE 0


;==============================================================================
; BACKGROUND MUSIC SYSTEM
;==============================================================================
musicFile       BYTE "music.mp3", 0
musicFile2      BYTE "music2.mp3", 0
musicPlaying    BYTE 0

mciOpen         BYTE "open ", 0
mciOpenEnd      BYTE " type mpegvideo alias bgmusic", 0
mciPlay         BYTE "play bgmusic repeat", 0
mciStop         BYTE "stop bgmusic", 0
mciClose        BYTE "close bgmusic", 0
mciSetVolume    BYTE "setaudio bgmusic volume to 500", 0
mciCommand      BYTE 256 DUP(0)
mciReturn       BYTE 128 DUP(0)


.code

;==============================================================================
; ENEMY PROCEDURES
;==============================================================================

HandleGoombaDefeat PROC
    push eax
    push ebx
    
    call CheckGoombaCollisions
    cmp al, 255
    je no_goomba_hit
    
    movzx ebx, al
    
    cmp marioVelY, 0
    jle mario_got_hit
    
    mov goombaActive[ebx], 0
    
    push eax
    mov eax, 100
    call UpdateScore
    pop eax
    
    call PlayEnemyDefeatSound
    
    mov marioVelY, -3
    
    jmp no_goomba_hit
    
mario_got_hit:
    dec livesCount
    call PlayDeathSound
    
    cmp livesCount, 0
    jg no_goomba_hit
    
    call Clrscr
    mov dh, 12
    mov dl, 30
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET menuOpt4
    call WriteString
    mov eax, 3000
    call Delay
    
no_goomba_hit:
    pop ebx
    pop eax
    ret
HandleGoombaDefeat ENDP

CheckGoombaCollisions PROC
    push ebx
    push ecx
    push edx
    
    movzx ecx, goombaCount
    cmp ecx, 0
    je no_collision
    
    mov ebx, 0
    
check_collision_loop:
    movzx eax, goombaActive[ebx]
    cmp al, 0
    je next_collision_check
    
    movzx eax, goombaX[ebx]
    mov dl, marioX
    
    sub al, dl
    cmp al, -1
    jl next_collision_check
    cmp al, 1
    jg next_collision_check
    
    movzx eax, goombaY[ebx]
    mov dl, marioY
    
    sub al, dl
    cmp al, -1
    jl next_collision_check
    cmp al, 0
    jg next_collision_check
    
    mov al, bl
    jmp collision_found
    
next_collision_check:
    inc ebx
    dec ecx
    jnz check_collision_loop
    
no_collision:
    mov al, 255
    
collision_found:
    pop edx
    pop ecx
    pop ebx
    ret
CheckGoombaCollisions ENDP

ClearGoombas PROC
    push eax
    push ebx
    push ecx
    push edx
    
    movzx ecx, goombaCount
    cmp ecx, 0
    je no_goombas_clear
    
    mov ebx, 0
    
clear_goomba_loop:
    movzx eax, goombaActive[ebx]
    cmp al, 0
    je next_goomba_clear
    
    movzx eax, goombaOldX[ebx]
    movzx edx, goombaOldY[ebx]
    
    mov dl, al
    mov dh, byte ptr [goombaOldY + ebx]
    call GetTileAtPosition
    
    push ebx
    mov bl, al
    
    mov al, dl
    sub al, cameraX
    
    cmp al, 0
    jl skip_clear
    cmp al, 79
    jg skip_clear
    
    mov dl, al
    call Gotoxy
    
    cmp bl, '#'
    je clear_ground_tile
    cmp bl, '='
    je clear_platform_tile
    cmp bl, 'o'
    je clear_coin_tile
    cmp bl, '?'
    je clear_question_tile
    
    mov eax, white + (black * 16)
    jmp apply_clear_color
    
clear_ground_tile:
    mov eax, brown + (black * 16)
    jmp apply_clear_color
clear_platform_tile:
    mov eax, red + (black * 16)
    jmp apply_clear_color
clear_coin_tile:
    mov eax, yellow + (black * 16)
    jmp apply_clear_color
clear_question_tile:
    mov eax, yellow + (black * 16)
    
apply_clear_color:
    call SetTextColor
    mov al, bl
    call WriteChar
    
skip_clear:
    pop ebx
    
next_goomba_clear:
    inc ebx
    dec ecx
    jnz clear_goomba_loop
    
no_goombas_clear:
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ClearGoombas ENDP

UpdateGoombas PROC
    push eax
    push ebx
    push ecx
    push edx
    
    inc goombaFrameCounter
    movzx eax, goombaFrameCounter
    cmp al, GOOMBA_MOVE_DELAY
    jl skip_goomba_update
    
    mov goombaFrameCounter, 0
    
    movzx ecx, goombaCount
    cmp ecx, 0
    je skip_goomba_update
    
    mov ebx, 0
    
update_goomba_loop:
    movzx eax, goombaActive[ebx]
    cmp al, 0
    je next_goomba_update
    
    mov al, goombaX[ebx]
    mov goombaOldX[ebx], al
    mov al, goombaY[ebx]
    mov goombaOldY[ebx], al
    
    movzx eax, goombaX[ebx]
    movzx edx, goombaDir[ebx]
    
    cmp dl, 1
    je move_goomba_right
    
    dec al
    cmp al, 0
    je reverse_goomba
    jmp check_goomba_wall
    
move_goomba_right:
    inc al
    cmp al, 119
    jge reverse_goomba
    
check_goomba_wall:
    push ebx
    mov dl, al
    movzx eax, goombaY[ebx]
    mov dh, al
    call GetTileAtPosition
    call IsSolidTile
    pop ebx
    
    cmp al, 1
    je reverse_goomba
    
    push ebx
    movzx edx, goombaDir[ebx]
    cmp dl, 1
    je check_ground_right
    
    movzx eax, goombaX[ebx]
    dec al
    mov dl, al
    jmp do_ground_check
    
check_ground_right:
    movzx eax, goombaX[ebx]
    inc al
    mov dl, al
    
do_ground_check:
    movzx eax, goombaY[ebx]
    inc al
    mov dh, al
    call GetTileAtPosition
    call IsSolidTile
    pop ebx
    
    cmp al, 0
    je reverse_goomba
    
    movzx eax, goombaDir[ebx]
    cmp al, 1
    je apply_right_move
    
    dec byte ptr [goombaX + ebx]
    jmp next_goomba_update
    
apply_right_move:
    inc byte ptr [goombaX + ebx]
    jmp next_goomba_update
    
reverse_goomba:
    movzx eax, goombaDir[ebx]
    cmp al, 1
    je set_left
    
    mov goombaDir[ebx], 1
    jmp next_goomba_update
    
set_left:
    mov goombaDir[ebx], 255
    
next_goomba_update:
    inc ebx
    dec ecx
    jnz update_goomba_loop
    
skip_goomba_update:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
UpdateGoombas ENDP

InitializeGoombas PROC
    push eax
    push ecx
    
    mov goombaX[0], 25
    mov goombaY[0], 22
    mov goombaActive[0], 1
    mov goombaDir[0], 1
    
    mov goombaX[1], 95
    mov goombaY[1], 22
    mov goombaActive[1], 1
    mov goombaDir[1], 255
    
    mov goombaX[2], 110
    mov goombaY[2], 22
    mov goombaActive[2], 1
    mov goombaDir[2], 1
    
    mov goombaCount, 3
    
    pop ecx
    pop eax
    ret
InitializeGoombas ENDP

DrawGoombas PROC
    push eax
    push ebx
    push ecx
    push edx
    
    movzx ecx, goombaCount
    cmp ecx, 0
    je no_goombas
    
    mov ebx, 0
    
draw_goomba_loop:
    movzx eax, goombaActive[ebx]
    cmp al, 0
    je next_goomba
    
    movzx eax, goombaX[ebx]
    movzx edx, goombaY[ebx]
    
    sub al, cameraX
    
    cmp al, 0
    jl next_goomba
    cmp al, 79
    jg next_goomba
    
    mov dl, al
    mov dh, byte ptr [goombaY + ebx]
    call Gotoxy
    
    mov eax, brown + (black * 16)
    call SetTextColor
    
    mov al, 'G'
    call WriteChar
    
next_goomba:
    inc ebx
    dec ecx
    jnz draw_goomba_loop
    
no_goombas:
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawGoombas ENDP

;==============================================================================
;CASTLE OBSTACLES CLEARING
;==============================================================================
ClearFireballs PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    movzx ecx, fireballCount
    cmp ecx, 0
    je no_fireballs_clear
    
    mov esi, 0                   ; Use ESI as index instead of EBX
    
clear_fireball_loop:
    cmp fireballActive[esi], 0
    je next_fireball_clear
    
    ; Get old position into dl/dh
    movzx eax, fireballOldX[esi]
    mov dl, al
    movzx eax, fireballOldY[esi]
    mov dh, al
    
    ; Get tile at old position
    call GetTileAtPosition
    mov bl, al                   ; Save tile character in BL
    
    ; Convert world X to screen X
    movzx eax, fireballOldX[esi]
    sub al, cameraX
    
    ; Check if on screen
    cmp al, 0
    jl next_fireball_clear
    cmp al, 79
    jg next_fireball_clear
    
    ; Position cursor at screen coordinates
    mov dl, al
    movzx eax, fireballOldY[esi]
    mov dh, al
    call Gotoxy
    
    ; Set color based on underlying tile
    cmp bl, 'B'
    je clear_fb_brick
    cmp bl, 'W'
    je clear_fb_lava1
    cmp bl, 'w'
    je clear_fb_lava2
    cmp bl, '~'
    je clear_fb_bridge
    
    ; Default: empty space
    mov eax, white + (black * 16)
    jmp apply_fb_clear
    
clear_fb_brick:
    mov eax, gray + (black * 16)
    jmp apply_fb_clear
clear_fb_lava1:
    mov eax, white + (red * 16)
    jmp apply_fb_clear
clear_fb_lava2:
    mov eax, yellow + (red * 16)
    jmp apply_fb_clear
clear_fb_bridge:
    mov eax, brown + (black * 16)
    
apply_fb_clear:
    call SetTextColor
    mov al, bl                   ; Restore tile character
    call WriteChar
    
next_fireball_clear:
    inc esi                      ; Next fireball
    dec ecx
    jnz clear_fireball_loop
    
no_fireballs_clear:
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ClearFireballs ENDP

ClearBowser PROC
    push eax
    push edx
    
    cmp bowserActive, 0
    je no_bowser_clear
    
    movzx eax, bowserX
    sub al, cameraX
    cmp al, 0
    jl no_bowser_clear
    cmp al, 79
    jg no_bowser_clear
    
    mov dl, al
    mov dh, bowserY
    
    push edx
    call GetTileAtPosition
    
    push eax
    pop ebx
    push ebx
    
    pop edx
    push edx
    call Gotoxy
    pop edx
    
    pop ebx
    
    ; Set color based on tile
    cmp bl, 'B'
    je clear_bowser_brick
    cmp bl, '~'
    je clear_bowser_bridge
    
    mov eax, white + (black * 16)
    jmp apply_bowser_clear
    
clear_bowser_brick:
    mov eax, gray + (black * 16)
    jmp apply_bowser_clear
clear_bowser_bridge:
    mov eax, brown + (black * 16)
    
apply_bowser_clear:
    call SetTextColor
    mov al, bl
    call WriteChar
    
no_bowser_clear:
    pop edx
    pop eax
    ret
ClearBowser ENDP

ClearFirebars PROC
    push eax
    push ebx
    push ecx
    push edx
    
    movzx ecx, firebarCount
    cmp ecx, 0
    je no_firebars_clear
    
    mov ebx, 0
    
clear_firebar_loop:
    cmp firebarActive[ebx], 0
    je next_firebar_clear
    
    ; Use OLD angle to clear previous position
    movzx eax, firebarOldAngle[ebx]
    
    mov dl, firebarX[ebx]
    mov dh, firebarY[ebx]
    
    ; Calculate tip position based on OLD angle
    cmp al, 0
    je clear_offset_right
    cmp al, 1
    je clear_offset_downright
    cmp al, 2
    je clear_offset_down
    cmp al, 3
    je clear_offset_downleft
    cmp al, 4
    je clear_offset_left
    cmp al, 5
    je clear_offset_upleft
    cmp al, 6
    je clear_offset_up
    cmp al, 7
    je clear_offset_upright
    jmp next_firebar_clear
    
clear_offset_right:
    add dl, 3
    jmp clear_firebar_tip
clear_offset_downright:
    add dl, 2
    add dh, 2
    jmp clear_firebar_tip
clear_offset_down:
    add dh, 3
    jmp clear_firebar_tip
clear_offset_downleft:
    sub dl, 2
    add dh, 2
    jmp clear_firebar_tip
clear_offset_left:
    sub dl, 3
    jmp clear_firebar_tip
clear_offset_upleft:
    sub dl, 2
    sub dh, 2
    jmp clear_firebar_tip
clear_offset_up:
    sub dh, 3
    jmp clear_firebar_tip
clear_offset_upright:
    add dl, 2
    sub dh, 2
    
clear_firebar_tip:
    ; Get tile at tip position
    push ebx
    push edx
    call GetTileAtPosition
    mov bl, al
    pop edx
    
    ; Convert to screen coordinates
    mov al, dl
    sub al, cameraX
    cmp al, 0
    jl skip_tip_clear
    cmp al, 79
    jg skip_tip_clear
    
    push edx
    mov dl, al
    call Gotoxy
    
    ; Set color based on tile
    cmp bl, 'B'
    je clear_tip_brick
    cmp bl, 'X'
    je clear_tip_anchor
    
    mov eax, white + (black * 16)
    jmp apply_tip_clear
    
clear_tip_brick:
    mov eax, gray + (black * 16)
    jmp apply_tip_clear
clear_tip_anchor:
    mov eax, lightRed + (black * 16)
    
apply_tip_clear:
    call SetTextColor
    mov al, bl
    call WriteChar
    pop edx
    
skip_tip_clear:
    pop ebx
    
next_firebar_clear:
    inc ebx
    dec ecx
    jnz clear_firebar_loop
    
no_firebars_clear:
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ClearFirebars ENDP


;==============================================================================
; BOWSER BOSS PROCEDURES
;==============================================================================
InitializeBowser PROC
    push eax
    
    mov bowserX, 107
    mov bowserY, 18           
    mov bowserActive, 1
    mov bowserDir, 255
    mov bowserHealth, 3
    mov bowserJumpTimer, 0
    mov bowserFireTimer, 30
    mov fireballCount, 0
    mov bowserBurstCount, 0
    mov bowserBurstTimer, 0
    
    pop eax
    ret
InitializeBowser ENDP

UpdateBowser PROC
    push eax
    push ebx
    push edx
    
    cmp bowserActive, 0
    je skip_bowser_update
    
    ; Movement AI
    dec bowserJumpTimer
    cmp bowserJumpTimer, 0
    jg no_jump
    
    ; Random jump
    mov eax, 60
    call RandomRange
    add eax, 40
    mov bowserJumpTimer, al
    
no_jump:
    ; Move toward Mario
    mov al, marioX
    cmp al, bowserX
    jl move_bowser_left
    jg move_bowser_right
    jmp check_fire
    
move_bowser_left:
    cmp bowserX, 95           ; Adjusted boundary
    jle check_fire
    dec bowserX
    mov bowserDir, 255
    jmp check_fire
    
move_bowser_right:
    cmp bowserX, 115          ; Adjusted boundary
    jge check_fire
    inc bowserX
    mov bowserDir, 1
    
check_fire:
    ; Handle burst timing
    cmp bowserBurstCount, 3
    jge reset_burst_check
    
    ; In middle of burst
    dec bowserBurstTimer
    cmp bowserBurstTimer, 0
    jg skip_fire
    
    call BowserShootFire
    jmp skip_fire
    
reset_burst_check:
    ; Check if it's time for new burst
    dec bowserFireTimer
    cmp bowserFireTimer, 0
    jg skip_fire
    
    ; Start new burst
    mov bowserBurstCount, 0
    mov bowserBurstTimer, 0
    
    mov eax, 80
    call RandomRange
    add eax, 60
    mov bowserFireTimer, al
    
skip_fire:

skip_bowser_update:
    pop edx
    pop ebx
    pop eax
    ret
UpdateBowser ENDP

BowserShootFire PROC
    push eax
    push ebx
    push ecx
    
    ; Only shoot if burst count allows
    cmp bowserBurstCount, 3
    jge no_fireball_spawn
    
    ; Find empty fireball slot
    mov ecx, MAX_FIREBALLS
    mov ebx, 0
    
find_fireball_slot:
    cmp fireballActive[ebx], 0
    je found_fireball_slot
    inc ebx
    dec ecx
    jnz find_fireball_slot
    jmp no_fireball_spawn
    
found_fireball_slot:
    mov al, bowserX
    mov fireballX[ebx], al
    mov fireballOldX[ebx], al      ; Initialize old position
    mov al, bowserY
    mov fireballY[ebx], al
    mov fireballOldY[ebx], al      ; Initialize old position
    mov fireballActive[ebx], 1
    
    ; Shoot toward Mario
    mov al, marioX
    cmp al, bowserX
    jl shoot_left
    mov fireballDir[ebx], 1
    jmp fireball_done
    
shoot_left:
    mov fireballDir[ebx], 255
    
fireball_done:
    inc fireballCount
    inc bowserBurstCount
    mov bowserBurstTimer, 15
    
no_fireball_spawn:
    pop ecx
    pop ebx
    pop eax
    ret
BowserShootFire ENDP

UpdateFireballs PROC
    push eax
    push ebx
    push ecx
    push edx
    
    movzx ecx, fireballCount
    cmp ecx, 0
    je skip_fireball_update
    
    mov ebx, 0
    
update_fireball_loop:
    cmp fireballActive[ebx], 0
    je next_fireball_update
    
    ; Save old position
    mov al, fireballX[ebx]
    mov fireballOldX[ebx], al
    mov al, fireballY[ebx]
    mov fireballOldY[ebx], al
    
    ; Move fireball
    movzx eax, fireballDir[ebx]
    cmp al, 1
    je move_fireball_right
    
    dec fireballX[ebx]
    jmp check_fireball_bounds
    
move_fireball_right:
    inc fireballX[ebx]
    
check_fireball_bounds:
    cmp fireballX[ebx], 0
    jle deactivate_fireball
    cmp fireballX[ebx], 119
    jge deactivate_fireball
; Check collision with Mario
    mov al, fireballX[ebx]
    sub al, marioX
    cmp al, -1
    jl next_fireball_update
    cmp al, 1
    jg next_fireball_update
    
    mov al, fireballY[ebx]
    sub al, marioY
    cmp al, -1
    jl next_fireball_update
    cmp al, 1
    jg next_fireball_update
    
    ; Hit Mario - handle properly
    dec livesCount
    call PlayDeathSound
    
    ; Deactivate this fireball
    mov fireballActive[ebx], 0
    dec fireballCount
    
    ; Check for game over
    cmp livesCount, 0
    jg respawn_mario
    
    ; Game over - exit to menu
    call Clrscr
    mov dh, 12
    mov dl, 50
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET menuOpt4
    call WriteString
    
    push eax
    mov eax, 3000
    call Delay
    pop eax
    

    jmp next_fireball_update
    
respawn_mario:
    ; Reset Mario position
    mov marioX, 8
    mov marioY, 20
    mov cameraX, 0
    mov marioVelY, 0
    mov onGround, 1
    
    ; Brief pause and redraw
    push eax
    mov eax, 500
    call Delay
    pop eax
    
    call Clrscr
    call DrawMap
    
    jmp next_fireball_update
    
deactivate_fireball:
    mov fireballActive[ebx], 0
    dec fireballCount
    
next_fireball_update:
    inc ebx
    dec ecx
    jnz update_fireball_loop
    
skip_fireball_update:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
UpdateFireballs ENDP

CheckBowserCollision PROC
    push eax
    push edx
    
    cmp bowserActive, 0
    je no_bowser_collision
    
    ; Check if Mario is near Bowser
    mov al, bowserX
    sub al, marioX
    cmp al, -2
    jl no_bowser_collision
    cmp al, 2
    jg no_bowser_collision
    
    mov al, bowserY
    sub al, marioY
    cmp al, -2
    jl no_bowser_collision
    cmp al, 0
    jg no_bowser_collision
    
    ; Check if Mario is jumping on Bowser
    cmp marioVelY, 0
    jle mario_hit_bowser
    
    ; Mario jumped on Bowser
    dec bowserHealth
    call PlayEnemyDefeatSound
    
    mov marioVelY, -3
    
    cmp bowserHealth, 0
    jg no_bowser_collision
    
    ; Bowser defeated
    mov bowserActive, 0
    
    push eax
    mov eax, 5000
    call UpdateScore
    pop eax
    
    jmp no_bowser_collision
    
mario_hit_bowser:
    dec livesCount
    call PlayDeathSound
    
    ; Missing game over check!
    cmp livesCount, 0
    jg bowser_respawn
    
    ; Game over
    call Clrscr
    mov dh, 12
    mov dl, 30
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET menuOpt4
    call WriteString
    
    push eax
    mov eax, 3000
    call Delay
    pop eax
    
    mov levelComplete, 1
    jmp no_bowser_collision
    
bowser_respawn:
    mov marioX, 8
    mov marioY, 20
    mov cameraX, 0
    mov marioVelY, 0
    mov onGround, 1
    
    push eax
    mov eax, 500
    call Delay
    pop eax
    
    call Clrscr
    call DrawMap
no_bowser_collision:
    pop edx
    pop eax
    ret
CheckBowserCollision ENDP

DrawBowser PROC
    push eax
    push edx
    
    cmp bowserActive, 0
    je no_bowser_draw
    
    movzx eax, bowserX
    sub al, cameraX
    cmp al, 0
    jl no_bowser_draw
    cmp al, 79
    jg no_bowser_draw
    
    mov dl, al
    mov dh, bowserY
    call Gotoxy
    
    mov eax, lightRed + (black * 16)
    call SetTextColor
    
    mov al, 'K'  ; K for King Koopa
    call WriteChar
    
no_bowser_draw:
    pop edx
    pop eax
    ret
DrawBowser ENDP

DrawFireballs PROC
    push eax
    push ebx
    push ecx
    push edx
    
    movzx ecx, fireballCount
    cmp ecx, 0
    je no_fireballs_draw
    
    mov ebx, 0
    
draw_fireball_loop:
    cmp fireballActive[ebx], 0
    je next_fireball_draw
    
    movzx eax, fireballX[ebx]
    sub al, cameraX
    cmp al, 0
    jl next_fireball_draw
    cmp al, 79
    jg next_fireball_draw
    
    mov dl, al
    mov dh, byte ptr [fireballY + ebx]
    call Gotoxy
    
    mov eax, lightRed + (black * 16)
    call SetTextColor
    
    mov al, '@'
    call WriteChar
    
next_fireball_draw:
    inc ebx
    dec ecx
    jnz draw_fireball_loop
    
no_fireballs_draw:
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawFireballs ENDP

;==============================================================================
; LAVA & HAZARD PROCEDURES
;==============================================================================
CheckLavaCollision PROC
    push edx
    
    mov dl, marioX
    mov dh, marioY
    call GetTileAtPosition
    
    ; Check for lava tiles
    cmp al, 'W'
    je hit_lava
    cmp al, 'w'
    je hit_lava
    jmp no_lava
    
hit_lava:
    dec livesCount        
    call PlayDeathSound

    mov eax, WHITE + (black * 16)
   call SetTextColor

    
    ; Check for game over
    cmp livesCount, 0
    jg lava_respawn
    
    ; Game over
    call Clrscr
    mov dh, 12
    mov dl, 30
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET menuOpt4  
    call WriteString
    
    push eax
    mov eax, 3000
    call Delay
    pop eax
    
    mov levelComplete, 1
    jmp no_lava
    
lava_respawn:
    mov marioX, 8
    mov marioY, 20
    mov cameraX, 0
    mov marioVelY, 0
    mov onGround, 1
    
    push eax
    mov eax, 500
    call Delay
    pop eax
    
    call Clrscr
    call DrawMap
    
no_lava:
    pop edx
    ret
CheckLavaCollision ENDP

InitializeFirebars PROC
    push eax
    
    ; Firebar 1 - Upper left
    mov firebarX[0], 7
    mov firebarY[0], 10
    mov firebarActive[0], 1
    mov firebarAngle[0], 0
    mov firebarOldAngle[0], 0
    
    ; Firebar 2 - Middle
    mov firebarX[1], 34
    mov firebarY[1], 10
    mov firebarActive[1], 1
    mov firebarAngle[1], 4
    mov firebarOldAngle[1], 4
    
    ; Firebar 3 - Right side
    mov firebarX[2], 76
    mov firebarY[2], 13
    mov firebarActive[2], 1
    mov firebarAngle[2], 2
    mov firebarOldAngle[2], 2
    
    mov firebarCount, 3
    
    pop eax
    ret
InitializeFirebars ENDP


UpdateFirebars PROC
    push eax
    push ebx
    push ecx
    
    inc firebarFrameCounter
    movzx eax, firebarFrameCounter
    cmp al, FIREBAR_SPEED
    jl skip_firebar_update
    
    mov firebarFrameCounter, 0
    
    movzx ecx, firebarCount
    cmp ecx, 0
    je skip_firebar_update
    
    mov ebx, 0
    
update_firebar_loop:
    cmp firebarActive[ebx], 0
    je next_firebar_update
    
    ; Save old angle before updating
    mov al, firebarAngle[ebx]
    mov firebarOldAngle[ebx], al
    
    inc firebarAngle[ebx]
    cmp firebarAngle[ebx], 8
    jl next_firebar_update
    mov firebarAngle[ebx], 0
    
next_firebar_update:
    inc ebx
    dec ecx
    jnz update_firebar_loop
    
skip_firebar_update:
    pop ecx
    pop ebx
    pop eax
    ret
UpdateFirebars ENDP

CheckFirebarCollision PROC
    push eax
    push ebx
    push ecx
    push edx
    
    movzx ecx, firebarCount
    cmp ecx, 0
    je no_firebar_hit
    
    mov ebx, 0
    
check_firebar_loop:
    cmp firebarActive[ebx], 0
    je next_firebar_check
    
    ; Get firebar position
    movzx eax, firebarAngle[ebx]
    
    push ebx
    
    mov dl, firebarX[ebx]
    mov dh, firebarY[ebx]
    
    ; Offset based on angle
    cmp al, 0  ; Right
    je offset_right
    cmp al, 1  ; Down-right
    je offset_downright
    cmp al, 2  ; Down
    je offset_down
    cmp al, 3  ; Down-left
    je offset_downleft
    cmp al, 4  ; Left
    je offset_left
    cmp al, 5  ; Up-left
    je offset_upleft
    cmp al, 6  ; Up
    je offset_up
    cmp al, 7  ; Up-right
    je offset_upright
    jmp check_collision
    
offset_right:
    add dl, 3
    jmp check_collision
offset_downright:
    add dl, 2
    add dh, 2
    jmp check_collision
offset_down:
    add dh, 3
    jmp check_collision
offset_downleft:
    sub dl, 2
    add dh, 2
    jmp check_collision
offset_left:
    sub dl, 3
    jmp check_collision
offset_upleft:
    sub dl, 2
    sub dh, 2
    jmp check_collision
offset_up:
    sub dh, 3
    jmp check_collision
offset_upright:
    add dl, 2
    sub dh, 2
    
check_collision:
    ; Check if Mario is at this position
    mov al, marioX
    sub al, dl
    cmp al, -1
    jl no_hit_this_bar
    cmp al, 1
    jg no_hit_this_bar
    
    mov al, marioY
    sub al, dh
    cmp al, -1
    jl no_hit_this_bar
    cmp al, 1
    jg no_hit_this_bar
    
; Hit detected
    pop ebx
    
    dec livesCount
    call PlayDeathSound
    
    ; Check for game over
    cmp livesCount, 0
    jg firebar_respawn
    
    ; Game over
    call Clrscr
    mov dh, 12
    mov dl, 30
    call Gotoxy
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov edx, OFFSET menuOpt4
    call WriteString
    
    push eax
    mov eax, 3000
    call Delay
    pop eax
    
    mov levelComplete, 1
    jmp no_firebar_hit
    
firebar_respawn:
    mov marioX, 8
    mov marioY, 20
    mov cameraX, 0
    mov marioVelY, 0
    mov onGround, 1
    
    push eax
    mov eax, 500
    call Delay
    pop eax
    
    call Clrscr
    call DrawMap
no_hit_this_bar:
    pop ebx
    
next_firebar_check:
    inc ebx
    dec ecx
    jnz check_firebar_loop
    
no_firebar_hit:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckFirebarCollision ENDP

DrawFirebars PROC
    push eax
    push ebx
    push ecx
    push edx
    
    movzx ecx, firebarCount
    cmp ecx, 0
    je no_firebars
    
    mov ebx, 0
    
draw_firebar_loop:
    cmp firebarActive[ebx], 0
    je next_firebar_draw
    
    ; Draw anchor
    movzx eax, firebarX[ebx]
    sub al, cameraX
    cmp al, 0
    jl next_firebar_draw
    cmp al, 79
    jg next_firebar_draw
    
    mov dl, al
    mov dh, byte ptr [firebarY + ebx]
    call Gotoxy
    
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov al, 'X'
    call WriteChar
    
    ; Draw firebar based on angle
    movzx eax, firebarAngle[ebx]
    push ebx
    
    mov dl, firebarX[ebx]
    mov dh, firebarY[ebx]
    
    cmp al, 0
    je draw_right
    cmp al, 1
    je draw_downright
    cmp al, 2
    je draw_down
    cmp al, 3
    je draw_downleft
    cmp al, 4
    je draw_left
    cmp al, 5
    je draw_upleft
    cmp al, 6
    je draw_up
    cmp al, 7
    je draw_upright
    jmp done_draw_bar
    
draw_right:
    add dl, 3
    jmp draw_bar_tip
draw_downright:
    add dl, 2
    add dh, 2
    jmp draw_bar_tip
draw_down:
    add dh, 3
    jmp draw_bar_tip
draw_downleft:
    sub dl, 2
    add dh, 2
    jmp draw_bar_tip
draw_left:
    sub dl, 3
    jmp draw_bar_tip
draw_upleft:
    sub dl, 2
    sub dh, 2
    jmp draw_bar_tip
draw_up:
    sub dh, 3
    jmp draw_bar_tip
draw_upright:
    add dl, 2
    sub dh, 2
    
draw_bar_tip:
    mov al, dl
    sub al, cameraX
    cmp al, 0
    jl done_draw_bar
    cmp al, 79
    jg done_draw_bar
    
    push edx
    mov dl, al
    call Gotoxy
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov al, 'o'
    call WriteChar
    pop edx
    
done_draw_bar:
    pop ebx
    
next_firebar_draw:
    inc ebx
    dec ecx
    jnz draw_firebar_loop
    
no_firebars:
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawFirebars ENDP

;==============================================================================
; BACKGROUND MUSIC PROCEDURES
;==============================================================================

StartBackgroundMusic PROC
    push eax
    push esi
    push edi
    
    cmp musicPlaying, 1
    je already_playing
    
    lea edi, mciCommand
    lea esi, mciOpen
    
copy_open:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne copy_open
    dec edi
    
    movzx eax, currentLevel
    cmp al, 2
    jge use_castle_music
    
    lea esi, musicFile
    jmp copy_filename
    
use_castle_music:
    lea esi, musicFile2
    
copy_filename:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne copy_filename
    dec edi
    
    lea esi, mciOpenEnd
copy_end:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    cmp al, 0
    jne copy_end
    
    INVOKE mciSendStringA, ADDR mciCommand, ADDR mciReturn, 128, 0
    INVOKE mciSendStringA, ADDR mciSetVolume, ADDR mciReturn, 128, 0
    INVOKE mciSendStringA, ADDR mciPlay, ADDR mciReturn, 128, 0
    
    mov musicPlaying, 1
    
already_playing:
    pop edi
    pop esi
    pop eax
    ret
StartBackgroundMusic ENDP

StopBackgroundMusic PROC
    push eax
    
    cmp musicPlaying, 0
    je not_playing
    
    INVOKE mciSendStringA, ADDR mciStop, ADDR mciReturn, 128, 0
    INVOKE mciSendStringA, ADDR mciClose, ADDR mciReturn, 128, 0
    
    mov musicPlaying, 0
    
not_playing:
    pop eax
    ret
StopBackgroundMusic ENDP

;==============================================================================
; FILE HANDLING PROCEDURES
;==============================================================================

LoadHighScores PROC
    push eax
    push ebx
    push ecx
    push edx
    
    mov edx, OFFSET highscoreFile
    call OpenInputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je load_hs_failed
    
    mov eax, fileHandle
    lea edx, highscoreCount
    mov ecx, 1
    call ReadFromFile
    
    movzx ecx, highscoreCount
    cmp ecx, 0
    je close_hs_file
    
    mov ebx, 0
    
load_hs_loop:
    push ecx
    
    mov eax, fileHandle
    lea edx, highscoreValues[ebx * 4]
    mov ecx, 4
    call ReadFromFile
    
    mov eax, fileHandle
    mov edx, OFFSET highscoreNames
    mov eax, ebx
    mov ecx, 32
    imul eax, 32
    add edx, eax
    mov eax, fileHandle
    mov ecx, 32
    call ReadFromFile
    
    inc ebx
    pop ecx
    dec ecx
    jnz load_hs_loop
    
close_hs_file:
    mov eax, fileHandle
    call CloseFile
    
load_hs_failed:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
LoadHighScores ENDP

SaveHighScores PROC
    push eax
    push ebx
    push ecx
    push edx
    
    mov edx, OFFSET highscoreFile
    call CreateOutputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je save_hs_failed
    
    mov eax, fileHandle
    lea edx, highscoreCount
    mov ecx, 1
    call WriteToFile
    
    movzx ecx, highscoreCount
    cmp ecx, 0
    je close_hs_save
    
    mov ebx, 0
    
save_hs_loop:
    push ecx
    
    mov eax, fileHandle
    lea edx, highscoreValues[ebx * 4]
    mov ecx, 4
    call WriteToFile
    
    mov eax, fileHandle
    mov edx, OFFSET highscoreNames
    mov eax, ebx
    imul eax, 32
    add edx, eax
    mov eax, fileHandle
    mov ecx, 32
    call WriteToFile
    
    inc ebx
    pop ecx
    dec ecx
    jnz save_hs_loop
    
close_hs_save:
    mov eax, fileHandle
    call CloseFile
    
save_hs_failed:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
SaveHighScores ENDP

CheckAndAddHighScore PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi
    
    mov eax, currentScore
    
    cmp highscoreCount, MAX_HIGHSCORES
    jl add_score
    
    mov ebx, 4
    mov ecx, highscoreValues[ebx * 4]
    cmp eax, ecx
    jbe not_highscore
    
add_score:
    movzx ecx, highscoreCount
    mov ebx, 0
    
find_position:
    cmp ebx, ecx
    jge insert_at_position
    
    mov edx, highscoreValues[ebx * 4]
    cmp eax, edx
    jg insert_at_position
    
    inc ebx
    jmp find_position
    
insert_at_position:
    push eax
    push ebx
    
    cmp highscoreCount, MAX_HIGHSCORES
    jge shift_scores
    inc highscoreCount
    
shift_scores:
    movzx ecx, highscoreCount
    dec ecx
    cmp ecx, ebx
    jle skip_shift
    
shift_loop:
    mov eax, ecx
    dec eax
    mov edx, highscoreValues[eax * 4]
    mov highscoreValues[ecx * 4], edx
    
    push ecx
    mov esi, OFFSET highscoreNames
    mov edi, esi
    mov eax, ecx
    dec eax
    imul eax, 32
    add esi, eax
    mov eax, ecx
    imul eax, 32
    add edi, eax
    mov ecx, 32
    rep movsb
    pop ecx
    
    dec ecx
    cmp ecx, ebx
    jg shift_loop
    
skip_shift:
    pop ebx
    pop eax
    
    mov highscoreValues[ebx * 4], eax
    
    push edi
    push esi
    mov edi, OFFSET highscoreNames
    mov eax, ebx
    imul eax, 32
    add edi, eax
    mov esi, OFFSET playerName
    mov ecx, 32
    rep movsb
    pop esi
    pop edi
    
    call SaveHighScores
    
not_highscore:
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
CheckAndAddHighScore ENDP

DisplayHighScores PROC
    push eax
    push ebx
    push ecx
    push edx
    
    call Clrscr
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 5
    mov dl, 30
    call Gotoxy
    mov edx, OFFSET menuOpt2
    call WriteString
    
    call LoadHighScores
    
    movzx ecx, highscoreCount
    cmp ecx, 0
    je no_scores
    
    mov ebx, 0
    mov dh, 8
    
display_score_loop:
    push ecx
    
    mov dl, 25
    call Gotoxy
    
    mov eax, white + (black * 16)
    call SetTextColor
    mov eax, ebx
    inc eax
    call WriteDec
    mov al, '.'
    call WriteChar
    mov al, ' '
    call WriteChar
    
    mov edx, OFFSET highscoreNames
    mov eax, ebx
    imul eax, 32
    add edx, eax
    call WriteString
    
    mov al, ' '
    call WriteChar
    call WriteChar
    
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov eax, highscoreValues[ebx * 4]
    call WriteDec
    
    inc dh
    inc ebx
    pop ecx
    dec ecx
    jnz display_score_loop
    
no_scores:
    mov eax, gray + (black * 16)
    call SetTextColor
    mov dh, 20
    mov dl, 25
    call Gotoxy
    mov al, 'P'
    call WriteChar
    mov edx, OFFSET instBack
    add edx, 4
    call WriteString
    
    call ReadChar
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DisplayHighScores ENDP

GetPlayerName PROC
    push eax
    push ecx
    push edx
    
    call Clrscr
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 10
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET promptName
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    mov edx, OFFSET playerName
    mov ecx, 31
    call ReadString
    mov playerNameLen, eax
    
    call SavePlayerName
    
    pop edx
    pop ecx
    pop eax
    ret
GetPlayerName ENDP

SavePlayerName PROC
    push eax
    push edx
    
    mov edx, OFFSET playerFile
    call CreateOutputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je save_name_failed
    
    mov eax, fileHandle
    mov edx, OFFSET playerName
    mov ecx, playerNameLen
    call WriteToFile
    
    mov eax, fileHandle
    call CloseFile
    
save_name_failed:
    pop edx
    pop eax
    ret
SavePlayerName ENDP

LoadPlayerName PROC
    push ebx
    push ecx
    push edx
    
    mov edx, OFFSET playerFile
    call OpenInputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je load_name_failed
    
    mov eax, fileHandle
    mov edx, OFFSET playerName
    mov ecx, 31
    call ReadFromFile
    mov playerNameLen, eax
    
    mov eax, fileHandle
    call CloseFile
    
    mov al, 1
    jmp load_name_done
    
load_name_failed:
    mov al, 0
    
load_name_done:
    pop edx
    pop ecx
    pop ebx
    ret
LoadPlayerName ENDP

SaveProgress PROC
    push eax
    push edx
    
    mov al, currentWorld
    mov savedWorld, al
    mov al, currentLevel
    mov savedLevel, al
    mov eax, currentScore
    mov savedScore, eax
    mov al, livesCount
    mov savedLives, al
    
    mov edx, OFFSET progressFile
    call CreateOutputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je save_progress_failed
    
    mov eax, fileHandle
    lea edx, savedWorld
    mov ecx, 1
    call WriteToFile
    
    mov eax, fileHandle
    lea edx, savedLevel
    mov ecx, 1
    call WriteToFile
    
    mov eax, fileHandle
    lea edx, savedScore
    mov ecx, 4
    call WriteToFile
    
    mov eax, fileHandle
    lea edx, savedLives
    mov ecx, 1
    call WriteToFile
    
    mov eax, fileHandle
    call CloseFile
    
    push edx
    mov dh, 3
    mov dl, 55
    call Gotoxy
    mov eax, green + (black * 16)
    call SetTextColor
    mov edx, OFFSET saveSuccess
    call WriteString
    
    push eax
    mov eax, 1000
    call Delay
    pop eax
    pop edx
    
save_progress_failed:
    pop edx
    pop eax
    ret
SaveProgress ENDP

LoadProgress PROC
    push ebx
    push ecx
    push edx
    
    mov edx, OFFSET progressFile
    call OpenInputFile
    mov fileHandle, eax
    
    cmp eax, INVALID_HANDLE_VALUE
    je load_progress_failed
    
    mov eax, fileHandle
    lea edx, savedWorld
    mov ecx, 1
    call ReadFromFile
    
    mov eax, fileHandle
    lea edx, savedLevel
    mov ecx, 1
    call ReadFromFile
    
    mov eax, fileHandle
    lea edx, savedScore
    mov ecx, 4
    call ReadFromFile
    
    mov eax, fileHandle
    lea edx, savedLives
    mov ecx, 1
    call ReadFromFile
    
    mov eax, fileHandle
    call CloseFile
    
    mov al, savedWorld
    mov currentWorld, al
    mov al, savedLevel
    mov currentLevel, al
    mov eax, savedScore
    mov currentScore, eax
    mov al, savedLives
    mov livesCount, al
    
    mov al, 1
    jmp load_progress_done
    
load_progress_failed:
    mov al, 0
    
load_progress_done:
    pop edx
    pop ecx
    pop ebx
    ret
LoadProgress ENDP

;==============================================================================
; SOUND PROCEDURES
;==============================================================================

PlayDeathSound PROC
    push eax
    INVOKE Beep, 400, 100
    INVOKE Beep, 350, 100
    INVOKE Beep, 300, 150
    pop eax
    ret
PlayDeathSound ENDP

PlayFlagpoleSound PROC
    push eax
    INVOKE Beep, 523, 60
    INVOKE Beep, 659, 60
    INVOKE Beep, 784, 120
    pop eax
    ret
PlayFlagpoleSound ENDP

PlayPowerupSound PROC
    push eax
    push ebx
    push ecx
    
    mov ecx, 3
    mov ebx, 0
    
powerup_note_loop:
    movzx eax, noteFrequencies[ebx * 2]
    INVOKE Beep, eax, 120
    
    add ebx, 2
    dec ecx
    jnz powerup_note_loop
    
    pop ecx
    pop ebx
    pop eax
    ret
PlayPowerupSound ENDP

PlayCoinSound PROC
    push eax
    push ebx
    
    movzx ebx, coinCombo
    and ebx, 00000111b
    
    movzx eax, noteFrequencies[ebx * 2]
    INVOKE Beep, eax, 150
    
    inc coinCombo
    cmp coinCombo, 8
    jl combo_ok
    mov coinCombo, 0
    
combo_ok:
    mov eax, frameCounter
    mov lastCoinTime, eax
    
    mov al, coinCombo
    cmp al, maxCombo
    jle skip_max_update
    mov maxCombo, al
    
skip_max_update:
    pop ebx
    pop eax
    ret
PlayCoinSound ENDP

CheckComboTimeout PROC
    push eax
    push ebx
    
    mov eax, frameCounter
    sub eax, lastCoinTime
    cmp eax, comboTimeout
    jl combo_active
    
    mov coinCombo, 0
    
combo_active:
    pop ebx
    pop eax
    ret
CheckComboTimeout ENDP

PlayJumpSound PROC
    push eax
    movzx eax, jumpSoundFreq
    INVOKE Beep, eax, 100
    pop eax
    ret
PlayJumpSound ENDP

PlayEnemyDefeatSound PROC
    push eax
    movzx eax, enemyDefeatFreq
    INVOKE Beep, eax, 150
    pop eax
    ret
PlayEnemyDefeatSound ENDP

PlayBlockHitSound PROC
    push eax
    movzx eax, blockHitFreq
    INVOKE Beep, eax, 100
    pop eax
    ret
PlayBlockHitSound ENDP

;==============================================================================
; VISUAL EFFECTS PROCEDURES
;==============================================================================

SpawnTrailParticle PROC
    push eax
    push ebx
    
    cmp turboActive, 0
    je no_trail_spawn
    
    movzx ebx, trailIndex
    
    mov al, marioX
    mov trailX[ebx], al
    mov al, marioY
    mov trailY[ebx], al
    
    mov trailActive[ebx], 1
    mov trailLifetime[ebx], 12
    
    inc trailIndex
    cmp trailIndex, MAX_TRAIL_PARTICLES
    jl no_trail_spawn
    mov trailIndex, 0
    
no_trail_spawn:
    pop ebx
    pop eax
    ret
SpawnTrailParticle ENDP

UpdateTrailParticles PROC
    push eax
    push ebx
    push ecx
    
    mov ecx, MAX_TRAIL_PARTICLES
    mov ebx, 0
    
update_trail_loop:
    cmp trailActive[ebx], 0
    je next_trail_update
    
    dec trailLifetime[ebx]
    
    cmp trailLifetime[ebx], 0
    jg next_trail_update
    
    mov trailActive[ebx], 0
    
next_trail_update:
    inc ebx
    dec ecx
    jnz update_trail_loop
    
    pop ecx
    pop ebx
    pop eax
    ret
UpdateTrailParticles ENDP

DrawTrailParticles PROC
    push eax
    push ebx
    push ecx
    push edx
    
    mov ecx, MAX_TRAIL_PARTICLES
    mov ebx, 0
    
draw_trail_loop:
    cmp trailActive[ebx], 0
    je next_trail_draw
    
    movzx eax, trailX[ebx]
    movzx edx, trailY[ebx]
    
    sub al, cameraX
    
    cmp al, 0
    jl next_trail_draw
    cmp al, 79
    jg next_trail_draw
    
    mov dl, al
    mov dh, byte ptr [trailY + ebx]
    call Gotoxy
    
    movzx eax, trailLifetime[ebx]
    shr al, 2
    
    lea esi, trailChars
    add esi, eax
    mov al, [esi]
    
    push eax
    mov eax, lightBlue + (black * 16)
    call SetTextColor
    pop eax
    
    call WriteChar
    
next_trail_draw:
    inc ebx
    dec ecx
    jnz draw_trail_loop
    
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawTrailParticles ENDP

;==============================================================================
; POWER-UP PROCEDURES
;==============================================================================

UpdateTurboTimer PROC
    push eax
    
    cmp turboActive, 0
    je no_turbo
    
    dec turboTimer
    
    cmp turboTimer, 0
    jg no_turbo
    
    mov turboActive, 0
    
no_turbo:
    pop eax
    ret
UpdateTurboTimer ENDP

CheckPowerupCollection PROC
    push eax
    push ebx
    push ecx
    
    movzx ecx, powerupCount
    cmp ecx, 0
    je no_collection
    
    mov ebx, 0
    
check_collection_loop:
    cmp powerupActive[ebx], 0
    je next_collection_check
    
    movzx eax, powerupX[ebx]
    cmp al, marioX
    jne next_collection_check
    
    movzx eax, powerupY[ebx]
    cmp al, marioY
    jne next_collection_check
    
    cmp powerupType[ebx], 0
    jne next_collection_check
    
    mov turboActive, 1
    mov turboTimer, TURBO_DURATION
    
    push eax
    mov eax, 1000
    call UpdateScore
    pop eax
    
    mov powerupActive[ebx], 0
    dec powerupCount
    
next_collection_check:
    inc ebx
    dec ecx
    jnz check_collection_loop
    
no_collection:
    pop ecx
    pop ebx
    pop eax
    ret
CheckPowerupCollection ENDP

DrawPowerups PROC
    push eax
    push ebx
    push ecx
    push edx
    
    movzx ecx, powerupCount
    cmp ecx, 0
    je no_powerups
    
    mov ebx, 0
    
draw_powerup_loop:
    cmp powerupActive[ebx], 0
    je next_powerup
    
    movzx eax, powerupX[ebx]
    movzx edx, powerupY[ebx]
    
    sub al, cameraX
    
    cmp al, 0
    jl next_powerup
    cmp al, 79
    jg next_powerup
    
    mov dl, al
    mov dh, byte ptr [powerupY + ebx]
    call Gotoxy
    
    mov eax, lightBlue + (black * 16)
    call SetTextColor
    
    mov al, '*'
    call WriteChar
    
next_powerup:
    inc ebx
    dec ecx
    jnz draw_powerup_loop
    
no_powerups:
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawPowerups ENDP

SpawnTurboStar PROC
    push eax
    push ebx
    push ecx
    
    mov ecx, MAX_POWERUPS
    mov ebx, 0
    
find_slot:
    cmp powerupActive[ebx], 0
    je found_slot
    inc ebx
    dec ecx
    jnz find_slot
    
    jmp spawn_done
    
found_slot:
    mov al, blockHitX
    mov powerupX[ebx], al
    
    mov al, blockHitY
    inc al
    mov powerupY[ebx], al
    
    mov powerupActive[ebx], 1
    mov powerupType[ebx], 0
    
    inc powerupCount
    
spawn_done:
    pop ecx
    pop ebx
    pop eax
    ret
SpawnTurboStar ENDP

CheckBlockHit PROC
    push ebx
    push edx
    
    cmp marioVelY, 0
    jge no_block_hit
    
    mov dl, marioX
    mov dh, marioY
    dec dh
    
    call GetTileAtPosition
    
    cmp al, '?'
    jne no_block_hit
    
    mov al, dl
    mov blockHitX, al
    mov al, dh
    mov blockHitY, al
    
    mov cl, '#'
    call SetTileAtPosition
    
    call SpawnTurboStar
    call PlayBlockHitSound
    
    mov marioVelY, 0
    
    mov al, 1
    jmp block_hit_done
    
no_block_hit:
    mov al, 0
    
block_hit_done:
    pop edx
    pop ebx
    ret
CheckBlockHit ENDP

;==============================================================================
; LEVEL COMPLETION PROCEDURES
;==============================================================================

CalculateCompletionBonus PROC
    push ebx
    
    movzx eax, timeRemaining
    mov ebx, 50
    mul ebx
    
    mov bl, marioY
    cmp bl, 13
    jg middle_flag
    
    add eax, 5000
    jmp bonus_done
    
middle_flag:
    cmp bl, 16
    jg bottom_flag
    
    add eax, 2000
    jmp bonus_done
    
bottom_flag:
    add eax, 100
    
bonus_done:
    pop ebx
    ret
CalculateCompletionBonus ENDP

ShowCompletionScreen PROC
    push eax
    push edx
    
    call Clrscr
    
    call CalculateCompletionBonus
    push eax
    
    call UpdateScore
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET completeTitle
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 11
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET completeScore
    call WriteString
    mov eax, currentScore
    call WriteDec
    
    mov dh, 13
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET completeTime
    call WriteString
    pop eax
    push eax
    call WriteDec
    
    mov dh, 15
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET completeTotal
    call WriteString
    mov eax, currentScore
    call WriteDec
    
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov dh, 20
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET completeContinue
    call WriteString
    
    call ReadChar
    call CheckAndAddHighScore
    call SaveProgress
    
    pop eax
    pop edx
    pop eax
    ret
ShowCompletionScreen ENDP

AnimateFlagpoleSlide PROC
    push ebx
    push edx
    
    inc slideCounter
    
    mov al, slideCounter
    and al, 00000011b
    cmp al, 0
    jne still_sliding
    
    mov al, marioY
    cmp al, flagpoleBottomY
    jge slide_complete
    
    call ClearMario
    inc marioY
    call DrawMario
    
still_sliding:
    mov al, 0
    jmp slide_done
    
slide_complete:
    mov al, 1
    
slide_done:
    pop edx
    pop ebx
    ret
AnimateFlagpoleSlide ENDP

TriggerLevelCompletion PROC
    push eax
    
    mov levelComplete, 1
    call PlayFlagpoleSound
    
    mov marioVelY, 0
    mov onGround, 1
    
    movzx eax, currentLevel
    cmp al, 2
    jl normal_flag_completion
    
    jmp normal_flag_completion
    
normal_flag_completion:
    mov al, flagpoleX
    mov marioX, al
    mov slideCounter, 0
    
    pop eax
    ret
TriggerLevelCompletion ENDP

CheckFlagpoleCollision PROC
    push ebx
    push edx
    
    cmp levelComplete, 1
    je already_complete
    
    movzx eax, currentLevel
    cmp al, 2
    jge no_flag_collision
    
    mov al, marioX
    cmp al, flagpoleX
    jb no_flag_collision
    
    mov bl, flagpoleX
    add bl, 2
    cmp al, bl
    ja no_flag_collision
    
    mov al, marioY
    cmp al, flagpoleTopY
    jb no_flag_collision
    cmp al, flagpoleBottomY
    ja no_flag_collision
    
    mov al, 1
    jmp flag_check_done
    
already_complete:
    mov al, 1
    jmp flag_check_done
    
no_flag_collision:
    mov al, 0
    
flag_check_done:
    pop edx
    pop ebx
    ret
CheckFlagpoleCollision ENDP

;==============================================================================
; VICTORY CONDITION PROCEDURES
;==============================================================================

CheckAxeCollision PROC
    push edx
    
    cmp axeReached, 1
    je already_at_axe
    
    mov dl, marioX
    mov dh, marioY
    call GetTileAtPosition
    
    cmp al, 'A'
    jne no_axe
    
    mov axeReached, 1
    mov bridgeCollapse, 1
    mov collapseFrame, 0
    
    call PlayFlagpoleSound
    
no_axe:
already_at_axe:
    pop edx
    ret
CheckAxeCollision ENDP

UpdateBridgeCollapse PROC
    push eax
    push ebx
    push ecx
    push edx
    
    cmp bridgeCollapse, 0
    je no_collapse
    
    inc collapseFrame
    
    ; Collapse bridge tiles progressively
    movzx eax, collapseFrame
    shr al, 2  ; Slow down animation
    
    cmp al, 12
    jge collapse_done
    
    ; Remove bridge tile
    mov bl, al
    add bl, 100  ; Start X position of bridge
    
    mov dl, bl
    mov dh, 19   ; Bridge Y position
    mov cl, ' '
    call SetTileAtPosition
    
    jmp no_collapse
    
collapse_done:
    cmp victoryShown, 1
    je no_collapse
    
    call ShowVictoryScreen
    mov victoryShown, 1
    
no_collapse:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
UpdateBridgeCollapse ENDP

ShowVictoryScreen PROC
    push eax
    push edx
    
    call Clrscr
    
    ; Calculate final bonus
    movzx eax, timeRemaining
    mov ebx, 50
    mul ebx
    add eax, 10000  ; Victory bonus
    call UpdateScore
    
    ; Display victory message
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 50
    call Gotoxy
    mov edx, OFFSET bowserDefeatMsg
    call WriteString
    
    mov dh, 12
    mov dl, 50
    call Gotoxy
    mov edx, OFFSET princessMsg
    call WriteString
    
    mov dh, 14
    mov dl, 50
    call Gotoxy
    mov edx, OFFSET princessMsg2
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 14
    mov dl, 50
    call Gotoxy
   
    mov edx, OFFSET completeScore
    call WriteString
    mov eax, currentScore
    call WriteDec
    

    mov eax, cyan + (black * 16)
    call SetTextColor
    mov dh, 14
    mov dl, 50
    call Gotoxy



    mov edx, OFFSET completeContinue
    call WriteString
    
    call ReadChar
    
    call CheckAndAddHighScore
    
    pop edx
    pop eax
    ret
ShowVictoryScreen ENDP

;==============================================================================
; UI PROCEDURES
;==============================================================================

ShowPauseMenu PROC
    push ebx
    push edx
    
    mov eax, white + (gray * 16)
    call SetTextColor
    
    mov dh, 9
    mov dl, 22
    call Gotoxy
    mov ecx, 35
    mov al, ' '
draw_pause_line1:
    call WriteChar
    loop draw_pause_line1
    
    mov dh, 10
    mov dl, 22
    call Gotoxy
    mov ecx, 35
    mov al, ' '
draw_pause_line2:
    call WriteChar
    loop draw_pause_line2
    
    mov dh, 11
    mov dl, 22
    call Gotoxy
    mov ecx, 35
    mov al, ' '
draw_pause_line3:
    call WriteChar
    loop draw_pause_line3
    
    mov dh, 12
    mov dl, 22
    call Gotoxy
    mov ecx, 35
    mov al, ' '
draw_pause_line4:
    call WriteChar
    loop draw_pause_line4
    
    mov dh, 13
    mov dl, 22
    call Gotoxy
    mov ecx, 35
    mov al, ' '
draw_pause_line5:
    call WriteChar
    loop draw_pause_line5
    
    mov dh, 14
    mov dl, 22
    call Gotoxy
    mov ecx, 35
    mov al, ' '
draw_pause_line6:
    call WriteChar
    loop draw_pause_line6
    
    mov eax, yellow + (gray * 16)
    call SetTextColor
    
    mov dh, 10
    mov dl, 24
    call Gotoxy
    mov edx, OFFSET pauseTitle
    call WriteString
    
    mov eax, white + (gray * 16)
    call SetTextColor
    
    mov dh, 12
    mov dl, 24
    call Gotoxy
    mov edx, OFFSET pauseOpt1
    call WriteString
    
    mov dh, 13
    mov dl, 24
    call Gotoxy
    mov edx, OFFSET pauseOpt2
    call WriteString
    
    mov dh, 15
    mov dl, 24
    call Gotoxy
    mov edx, OFFSET pausePrompt
    call WriteString
    
pause_wait_input:
    call ReadChar
    
    cmp al, 'r'
    jne check_upper_r
    mov al, 'R'
    jmp valid_pause_input
    
check_upper_r:
    cmp al, 'R'
    je valid_pause_input
    
    cmp al, 'e'
    jne check_upper_e
    mov al, 'E'
    jmp valid_pause_input
    
check_upper_e:
    cmp al, 'E'
    je valid_pause_input
    
    jmp pause_wait_input
    
valid_pause_input:
    call WriteChar
    
    push eax
    mov eax, 500
    call Delay
    pop eax

    push eax
    mov eax, white + (black * 16)
    call SetTextColor
    pop eax
    
    pop edx
    pop ebx
    ret
ShowPauseMenu ENDP

DisplayTitleScreen PROC
    call Clrscr
    
    mov eax, white + (lightBlue * 16)
    call SetTextColor
    
    mov dh, 1
    mov dl, 5
    call Gotoxy
    mov al, '_'
    mov ecx, 10
draw_cloud1:
    call WriteChar
    loop draw_cloud1

    mov dh, 0
    mov dl, 6
    call Gotoxy
    mov al, '_'
    mov ecx, 5
draw_cloud1_top:
    call WriteChar
    loop draw_cloud1_top
    
    mov dh, 1
    mov dl, 60
    call Gotoxy
    mov al, '_'
    mov ecx, 9
draw_cloud2:
    call WriteChar
    loop draw_cloud2

    mov dh, 0
    mov dl, 65
    call Gotoxy
    mov al, '_'
    mov ecx, 3
draw_cloud2_top:
    call WriteChar
    loop draw_cloud2_top
    
    mov eax, brown + (black * 16)
    call SetTextColor
    mov dh, 22
    mov dl, 0
    call Gotoxy
    mov al, '#'
    mov ecx, 80
draw_ground:
    call WriteChar
    loop draw_ground
    
    mov eax, green + (black * 16)
    call SetTextColor
    
    mov dh, 20
    mov dl, 8
    call Gotoxy
    mov al, '|'
    call WriteChar
    mov dl, 9
    call Gotoxy
    call WriteChar
    mov dl, 10
    call Gotoxy
    call WriteChar
    
    mov dh, 21
    mov dl, 8
    call Gotoxy
    call WriteChar
    mov dl, 9
    call Gotoxy
    call WriteChar
    mov dl, 10
    call Gotoxy
    call WriteChar
    
    mov dh, 20
    mov dl, 68
    call Gotoxy
    mov al, '|'
    call WriteChar
    mov dl, 69
    call Gotoxy
    call WriteChar
    mov dl, 70
    call Gotoxy
    call WriteChar
    
    mov dh, 21
    mov dl, 68
    call Gotoxy
    call WriteChar
    mov dl, 69
    call Gotoxy
    call WriteChar
    mov dl, 70
    call Gotoxy
    call WriteChar
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dh, 19
    mov dl, 20
    call Gotoxy
    mov al, 'o'
    call WriteChar
    
    mov dl, 25
    call Gotoxy
    call WriteChar
    
    mov dl, 55
    call Gotoxy
    call WriteChar
    
    mov dl, 60
    call Gotoxy
    call WriteChar
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dh, 3
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt1
    call WriteString
    
    mov dh, 4
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt2
    call WriteString
    
    mov eax, lightRed + (black * 16)
    call SetTextColor
    
    mov dh, 5
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt3
    call WriteString
    
    mov dh, 6
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt4
    call WriteString
    
    mov dh, 7
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt5
    call WriteString
    
    mov dh, 8
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt6
    call WriteString
    
    mov dh, 9
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt7
    call WriteString
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dh, 10
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt8
    call WriteString
    
    mov dh, 11
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt9
    call WriteString
    
    mov dh, 12
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt10
    call WriteString
    
    mov eax, cyan + (black * 16)
    call SetTextColor
    
    mov dh, 14
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt12
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 16
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt14
    call WriteString
    
    mov dh, 17
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt15
    call WriteString
    
    mov dh, 18
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt16
    call WriteString
    
    mov dh, 19
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET titleArt17
    call WriteString
    
    mov eax, 4000
    call Delay
    
    ret
DisplayTitleScreen ENDP

DisplayMainMenu PROC
    call Clrscr
    
    ; Check if we have saved progress
    push eax
    call LoadProgress
    mov bl, al              ; Save result in bl
    pop eax

    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuTitle
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    
 ; Display menu based on save file existence
    cmp bl, 1
    je show_continue_menu
    
    ; No save file - show standard menu
    mov dh, 11
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt1
    call WriteString
    
    mov dh, 13
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt2
    call WriteString
    
    mov dh, 15
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt3
    call WriteString
    
    mov dh, 17
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt4
    call WriteString
    jmp show_prompt
    
show_continue_menu:
    ; Save file exists - show continue + new game
    mov dh, 11
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt1b    ; CONTINUE
    call WriteString
    
    mov dh, 13
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt1c    ; START NEW GAME
    call WriteString
    
    mov dh, 15
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt2b    ; HIGH SCORES
    call WriteString
    
    mov dh, 17
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt3b    ; INSTRUCTIONS
    call WriteString
    
    mov dh, 19
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET menuOpt4b    ; EXIT
    call WriteString
    
    show_prompt:
    mov dh, 21
        mov dl, 25
        call Gotoxy
        mov edx, OFFSET menuPrompt
        call WriteString
    
    menu_wait:
        call ReadChar
    
        ; Check which menu we're showing
        cmp bl, 1
        je continue_menu_input
    
        ; Standard menu (1-4)
        cmp al, '1'
        jb menu_wait
        cmp al, '4'
        ja menu_wait
        call WriteChar
        ret
    
    continue_menu_input:
        ; Continue menu (1-5)
        cmp al, '1'
        jb menu_wait
        cmp al, '5'
        ja menu_wait
        call WriteChar
    
        ; Map option 2 -> start new game (treat as option 1)
        ; Map options 3,4,5 -> 2,3,4
        cmp al, '2'
        jne not_new_game
        mov al, '1'      ; Treat as new game
        mov bl, 0        ; Flag that this is a new game request
        ret
    
    not_new_game:
        cmp al, '3'
        jl done_mapping
        dec al           ; Shift 3->2, 4->3, 5->4
    
    done_mapping:
        ret
DisplayMainMenu ENDP

DisplayInstructions PROC
    call Clrscr
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 3
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET instTitle
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 6
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine1
    call WriteString
    
    mov dh, 7
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine2
    call WriteString
    
    mov dh, 8
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine3
    call WriteString
    
    mov dh, 9
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine4
    call WriteString
    
    mov dh, 10
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine5
    call WriteString
    
    mov dh, 11
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine6
    call WriteString
    
    mov dh, 13
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine8
    call WriteString
    
    mov dh, 14
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine9
    call WriteString
    
    mov dh, 15
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine10
    call WriteString
    
    mov dh, 16
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine11
    call WriteString
    
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov dh, 18
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine13
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 19
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine14
    call WriteString
    
    mov dh, 20
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine15
    call WriteString
    
    mov dh, 21
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instLine16
    call WriteString
    
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 24
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET instBack
    call WriteString
    
    call ReadChar
    ret
DisplayInstructions ENDP

DrawGameHUD PROC
    push eax
    push edx
    
    mov eax, black + (lightMagenta * 16)
    call SetTextColor
    
    mov dh, 0
    mov dl, 0
    call Gotoxy
    mov ecx, 240
    mov al, ' '
hud_clear:
    call WriteChar
    loop hud_clear
    
    mov eax, yellow + (red * 16)
    call SetTextColor
    
    mov dh, 0
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET hudMarioLabel
    call WriteString
    
    mov eax, black + (lightMagenta * 16)
    call SetTextColor

    mov dh, 1
    mov dl, 2
    call Gotoxy
    mov eax, currentScore
    call WriteDec
    
    mov eax, blue + (yellow * 16)
    call SetTextColor

    mov dh, 0
    mov dl, 15
    call Gotoxy
    mov edx, OFFSET hudCoinSymbol
    call WriteString
    
    mov eax, black + (lightMagenta * 16)
    call SetTextColor
    mov dl, 16
    call Gotoxy
    mov edx, OFFSET hudMultiply
    call WriteString
    
    mov dh, 1
    mov dl, 15
    call Gotoxy
    movzx eax, coinCount
    call WriteDec
    
    mov eax, BLACK + (lightCyan * 16)
    call SetTextColor
    
    mov dh, 0
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET hudWorldLabel
    call WriteString
    
    mov dh, 1
    mov dl, 38
    call Gotoxy
    movzx eax, currentWorld
    call WriteDec
    mov al, '-'
    call WriteChar
    movzx eax, currentLevel
    call WriteDec
    
    cmp turboActive, 1
    je turbo_timer_color
    
    mov eax, black + (lightMagenta * 16)
    jmp set_timer_color
    
turbo_timer_color:
    mov eax, white + (blue * 16)
    
set_timer_color:
    call SetTextColor

    mov dh, 0
    mov dl, 60
    call Gotoxy
    mov edx, OFFSET hudTimeLabel
    call WriteString
    
    mov dh, 1
    mov dl, 60
    call Gotoxy
    movzx eax, timeRemaining
    call WriteDec
    
   mov eax, black + (lightMagenta * 16)

    mov dh, 0
    mov dl, 75
    call Gotoxy
    mov al, 'M'
    call WriteChar
    mov al, 'x'
    call WriteChar
    
    mov dh, 1
    mov dl, 75
    call Gotoxy
    movzx eax, livesCount
    call WriteDec
    
    mov eax, white + (black * 16)
    call SetTextColor
  
    pop edx
    pop eax
    ret
DrawGameHUD ENDP

;==============================================================================
; GAME STATE PROCEDURES
;==============================================================================

UpdateScore PROC
    add currentScore, eax
    
    cmp currentScore, 999999
    jbe score_ok
    mov currentScore, 999999
    
score_ok:
    ret
UpdateScore ENDP

UpdateCoins PROC
    inc coinCount
    
    cmp coinCount, 100
    jb no_life
    
    mov coinCount, 0
    inc livesCount
    
no_life:
    ret
UpdateCoins ENDP

UpdateGameTime PROC
    push eax
    
    inc frameCounter
    
    mov eax, frameCounter
    cmp eax, 60
    jl time_not_ready
    
    mov frameCounter, 0
    
    cmp timeRemaining, 0
    je time_not_ready
    dec timeRemaining
    
time_not_ready:
    pop eax
    ret
UpdateGameTime ENDP

;==============================================================================
; MAP & COLLISION PROCEDURES
;==============================================================================

GetTileAtPosition PROC
    push ebx
    push ecx
    push edx
    
  ; Use level-aware row pointer
    push eax
    movzx eax, currentLevel
    cmp al, 2
    pop eax
    jge use_castle_rows
    
    ; World 1-1 rows
    cmp dh, 0
    je check_row0
    cmp dh, 1
    je check_row1
    cmp dh, 2
    je check_row2
    cmp dh, 3
    je check_row3
    cmp dh, 4
    je check_row4
    cmp dh, 5
    je check_row5
    cmp dh, 6
    je check_row6
    cmp dh, 7
    je check_row7
    cmp dh, 8
    je check_row8
    cmp dh, 9
    je check_row9
    cmp dh, 10
    je check_row10
    cmp dh, 11
    je check_row11
    cmp dh, 12
    je check_row12
    cmp dh, 13
    je check_row13
    cmp dh, 14
    je check_row14
    cmp dh, 15
    je check_row15
    cmp dh, 16
    je check_row16
    cmp dh, 17
    je check_row17
    cmp dh, 18
    je check_row18
    cmp dh, 19
    je check_row19
    cmp dh, 20
    je check_row20
    cmp dh, 21
    je check_row21
    cmp dh, 22
    je check_row22
    cmp dh, 23
    je check_row23
    jmp out_of_bounds
    
use_castle_rows:
    ; Castle rows
    cmp dh, 0
    je check_castle_row0
    cmp dh, 1
    je check_castle_row1
    cmp dh, 2
    je check_castle_row2
    cmp dh, 3
    je check_castle_row3
    cmp dh, 4
    je check_castle_row4
    cmp dh, 5
    je check_castle_row5
    cmp dh, 6
    je check_castle_row6
    cmp dh, 7
    je check_castle_row7
    cmp dh, 8
    je check_castle_row8
    cmp dh, 9
    je check_castle_row9
    cmp dh, 10
    je check_castle_row10
    cmp dh, 11
    je check_castle_row11
    cmp dh, 12
    je check_castle_row12
    cmp dh, 13
    je check_castle_row13
    cmp dh, 14
    je check_castle_row14
    cmp dh, 15
    je check_castle_row15
    cmp dh, 16
    je check_castle_row16
    cmp dh, 17
    je check_castle_row17
    cmp dh, 18
    je check_castle_row18
    cmp dh, 19
    je check_castle_row19
    cmp dh, 20
    je check_castle_row20
    cmp dh, 21
    je check_castle_row21
    cmp dh, 22
    je check_castle_row22
    cmp dh, 23
    je check_castle_row23
    jmp out_of_bounds
    
check_row0:
    lea ebx, row0
    jmp get_char
check_row1:
    lea ebx, row1
    jmp get_char
check_row2:
    lea ebx, row2
    jmp get_char
check_row3:
    lea ebx, row3
    jmp get_char
check_row4:
    lea ebx, row4
    jmp get_char
check_row5:
    lea ebx, row5
    jmp get_char
check_row6:
    lea ebx, row6
    jmp get_char
check_row7:
    lea ebx, row7
    jmp get_char
check_row8:
    lea ebx, row8
    jmp get_char
check_row9:
    lea ebx, row9
    jmp get_char
check_row10:
    lea ebx, row10
    jmp get_char
check_row11:
    lea ebx, row11
    jmp get_char
check_row12:
    lea ebx, row12
    jmp get_char
check_row13:
    lea ebx, row13
    jmp get_char
check_row14:
    lea ebx, row14
    jmp get_char
check_row15:
    lea ebx, row15
    jmp get_char
check_row16:
    lea ebx, row16
    jmp get_char
check_row17:
    lea ebx, row17
    jmp get_char
check_row18:
    lea ebx, row18
    jmp get_char
check_row19:
    lea ebx, row19
    jmp get_char
check_row20:
    lea ebx, row20
    jmp get_char
check_row21:
    lea ebx, row21
    jmp get_char
check_row22:
    lea ebx, row22
    jmp get_char
check_row23:
    lea ebx, row23
    jmp get_char
   

   check_castle_row0:
    lea ebx, castleRow0
    jmp get_char
check_castle_row1:
    lea ebx, castleRow1
    jmp get_char
check_castle_row2:
    lea ebx, castleRow2
    jmp get_char
check_castle_row3:
    lea ebx, castleRow3
    jmp get_char
check_castle_row4:
    lea ebx, castleRow4
    jmp get_char
check_castle_row5:
    lea ebx, castleRow5
    jmp get_char
check_castle_row6:
    lea ebx, castleRow6
    jmp get_char
check_castle_row7:
    lea ebx, castleRow7
    jmp get_char
check_castle_row8:
    lea ebx, castleRow8
    jmp get_char
check_castle_row9:
    lea ebx, castleRow9
    jmp get_char
check_castle_row10:
    lea ebx, castleRow10
    jmp get_char
check_castle_row11:
    lea ebx, castleRow11
    jmp get_char
check_castle_row12:
    lea ebx, castleRow12
    jmp get_char
check_castle_row13:
    lea ebx, castleRow13
    jmp get_char
check_castle_row14:
    lea ebx, castleRow14
    jmp get_char
check_castle_row15:
    lea ebx, castleRow15
    jmp get_char
check_castle_row16:
    lea ebx, castleRow16
    jmp get_char
check_castle_row17:
    lea ebx, castleRow17
    jmp get_char
check_castle_row18:
    lea ebx, castleRow18
    jmp get_char
check_castle_row19:
    lea ebx, castleRow19
    jmp get_char
check_castle_row20:
    lea ebx, castleRow20
    jmp get_char
check_castle_row21:
    lea ebx, castleRow21
    jmp get_char
check_castle_row22:
    lea ebx, castleRow22
    jmp get_char
check_castle_row23:
    lea ebx, castleRow23
    jmp get_char

get_char:
    movzx eax, dl
    add ebx, eax
    mov al, [ebx]
    jmp get_done
    
out_of_bounds:
    mov al, ' '
    
get_done:
    pop edx
    pop ecx
    pop ebx
    ret
GetTileAtPosition ENDP

IsSolidTile PROC
    cmp al, '#'
    je is_solid
    cmp al, '='
    je is_solid
    cmp al, '?'
    je is_solid
    cmp al, '|'
    je is_solid
    cmp al, '_'
    je is_solid
    cmp al, 'B'        
    je is_solid
    cmp al, '~'        
    je is_solid
    
    mov al, 0
    ret
    
is_solid:
    mov al, 1
    ret
IsSolidTile ENDP

SetTileAtPosition PROC
    push eax
    push ebx
    push edx
    
    push ecx
    
    cmp dh, 0
    jl set_out_of_bounds
    cmp dh, 23
    ja set_out_of_bounds
    cmp dl, 0
    jl set_out_of_bounds
    cmp dl, 119
    ja set_out_of_bounds
    
    cmp dh, 0
    je set_row0
    cmp dh, 1
    je set_row1
    cmp dh, 2
    je set_row2
    cmp dh, 3
    je set_row3
    cmp dh, 4
    je set_row4
    cmp dh, 5
    je set_row5
    cmp dh, 6
    je set_row6
    cmp dh, 7
    je set_row7
    cmp dh, 8
    je set_row8
    cmp dh, 9
    je set_row9
    cmp dh, 10
    je set_row10
    cmp dh, 11
    je set_row11
    cmp dh, 12
    je set_row12
    cmp dh, 13
    je set_row13
    cmp dh, 14
    je set_row14
    cmp dh, 15
    je set_row15
    cmp dh, 16
    je set_row16
    cmp dh, 17
    je set_row17
    cmp dh, 18
    je set_row18
    cmp dh, 19
    je set_row19
    cmp dh, 20
    je set_row20
    cmp dh, 21
    je set_row21
    cmp dh, 22
    je set_row22
    cmp dh, 23
    je set_row23
    jmp set_out_of_bounds
    
set_row0:
    lea ebx, row0
    jmp set_char
set_row1:
    lea ebx, row1
    jmp set_char
set_row2:
    lea ebx, row2
    jmp set_char
set_row3:
    lea ebx, row3
    jmp set_char
set_row4:
    lea ebx, row4
    jmp set_char
set_row5:
    lea ebx, row5
    jmp set_char
set_row6:
    lea ebx, row6
    jmp set_char
set_row7:
    lea ebx, row7
    jmp set_char
set_row8:
    lea ebx, row8
    jmp set_char
set_row9:
    lea ebx, row9
    jmp set_char
set_row10:
    lea ebx, row10
    jmp set_char
set_row11:
    lea ebx, row11
    jmp set_char
set_row12:
    lea ebx, row12
    jmp set_char
set_row13:
    lea ebx, row13
    jmp set_char
set_row14:
    lea ebx, row14
    jmp set_char
set_row15:
    lea ebx, row15
    jmp set_char
set_row16:
    lea ebx, row16
    jmp set_char
set_row17:
    lea ebx, row17
    jmp set_char
set_row18:
    lea ebx, row18
    jmp set_char
set_row19:
    lea ebx, row19
    jmp set_char
set_row20:
    lea ebx, row20
    jmp set_char
set_row21:
    lea ebx, row21
    jmp set_char
set_row22:
    lea ebx, row22
    jmp set_char
set_row23:
    lea ebx, row23
    jmp set_char
    
set_char:
    movzx eax, dl
    add ebx, eax
    
    pop ecx
    mov [ebx], cl
    
    mov al, dl
    sub al, cameraX
    
    cmp al, 0
    jl set_skip_redraw
    cmp al, 79
    jg set_skip_redraw
    
    mov dl, al
    call Gotoxy
    
    cmp cl, '#'
    je set_color_ground
    cmp cl, '='
    je set_color_platform
    cmp cl, 'o'
    je set_color_coin
    cmp cl, '?'
    je set_color_question
    
    mov eax, white + (black * 16)
    jmp set_apply_color
    
set_color_ground:
    mov eax, brown + (black * 16)
    jmp set_apply_color
set_color_platform:
    mov eax, red + (black * 16)
    jmp set_apply_color
set_color_coin:
    mov eax, yellow + (black * 16)
    jmp set_apply_color
set_color_question:
    mov eax, yellow + (black * 16)
    
set_apply_color:
    call SetTextColor
    mov al, cl
    call WriteChar
    
set_skip_redraw:
    jmp set_done
    
set_out_of_bounds:
    pop ecx
    
set_done:
    pop edx
    pop ebx
    pop eax
    ret
SetTileAtPosition ENDP

CheckCoinCollection PROC
    push eax
    push ecx
    push edx
    
    mov dl, marioX
    mov dh, marioY
    call GetTileAtPosition
    
    cmp al, 'o'
    jne no_coin
    
    call UpdateCoins
    mov eax, 200
    call UpdateScore
    
    call PlayCoinSound

    push ebx
    mov bl, 2
    spawn_sparkle_loop:
        call SpawnTrailParticle
        dec bl
        jnz spawn_sparkle_loop
        pop ebx

    mov dl, marioX
    mov dh, marioY
    mov cl, ' '
    call SetTileAtPosition
    
no_coin:
    pop edx
    pop ecx
    pop eax
    ret
CheckCoinCollection ENDP

;==============================================================================
; MARIO PHYSICS
;==============================================================================

ApplyGravity PROC
    push eax
    push ebx
    push edx
    
    mov dl, marioX
    mov dh, marioY
    inc dh
    
    call GetTileAtPosition
    call IsSolidTile
    
    cmp al, 1
    je ground_exists
    
    mov onGround, 0
    
ground_exists:
    cmp onGround, 1
    je done_gravity
    
    inc marioVelY
    
    cmp marioVelY, 1
    jle vel_ok
    mov marioVelY, 1
    
vel_ok:
    mov al, marioY
    add al, marioVelY
    
    cmp al, 0
    jge bounds_ok
    mov al, 0
    mov marioVelY, 0
    
bounds_ok:
    mov bl, al
    
    cmp marioVelY, 0
    jg check_falling
    jmp check_rising
    
check_falling:
    mov dl, marioX
    mov dh, bl
    
    push ebx
    call GetTileAtPosition
    call IsSolidTile
    pop ebx
    
    cmp al, 1
    jne apply_move
    
    dec bl
    mov marioY, bl
    mov marioVelY, 0
    mov onGround, 1
    jmp done_gravity
    
check_rising:
    mov dl, marioX
    mov dh, bl
    
    cmp dh, 0
    je apply_move
    
    push ebx
    call GetTileAtPosition
    call IsSolidTile
    pop ebx
    
    cmp al, 1
    jne apply_move
    
    mov marioVelY, 0
    jmp done_gravity
    
apply_move:
    mov marioY, bl
    
done_gravity:
    pop edx
    pop ebx
    pop eax
    ret
ApplyGravity ENDP

ClearMario PROC
    push eax
    push ebx
    push ecx
    push edx
    
    mov dl, marioX
    mov dh, marioY
    call GetTileAtPosition
    
    mov bl, al
    
    mov dh, marioY
    mov al, marioX
    sub al, cameraX
    mov dl, al
    
    cmp dl, 0
    jl clear_done
    cmp dl, 79
    jg clear_done
    
    call Gotoxy
    
    cmp bl, '#'
    je clear_ground
    cmp bl, '='
    je clear_platform
    cmp bl, 'o'
    je clear_coin
    cmp bl, '?'
    je clear_question
    cmp bl, '|'
    je clear_pipe
    cmp bl, '_'
    je clear_pipe
    cmp bl, 'F'
    je clear_flag

    cmp bl, '#'
    je clear_ground
    cmp bl, '='
    je clear_platform
    cmp bl, 'o'
    je clear_coin
    cmp bl, '?'
    je clear_question
    cmp bl, '|'
    je clear_pipe
    cmp bl, '_'
    je clear_pipe
    cmp bl, 'F'
    je clear_flag
    cmp bl, 'B'
    je clear_castle_brick
    cmp bl, 'W'
    je clear_lava
    cmp bl, '~'
    je clear_bridge
    cmp bl, '['
    je clear_castle_wall
    cmp bl, ']'
    je clear_castle_wall
    cmp bl, '+'
    je clear_torch
    cmp bl, 'v'
    je clear_flame
    cmp bl, 'V'
    je clear_flame
    cmp bl, 'X'              
    je clear_firebar
    cmp bl, 'W'              
    je clear_lava_wave1
    cmp bl, 'w'              
    je clear_lava_wave2
    cmp bl, '#'             
    je clear_brick_detail
    
    mov eax, white + (black * 16)
    jmp set_clear_color
    
    mov eax, white + (black * 16)
    jmp set_clear_color
    
clear_ground:
    mov eax, brown + (black * 16)
    jmp set_clear_color
clear_platform:
    mov eax, red + (black * 16)
    jmp set_clear_color
clear_coin:
    mov eax, yellow + (black * 16)
    jmp set_clear_color
clear_question:
    mov eax, yellow + (black * 16)
    jmp set_clear_color
clear_pipe:
    mov eax, green + (black * 16)
    jmp set_clear_color
clear_flag:
    mov eax, white + (black * 16)

clear_castle_brick:
    mov eax, gray + (black * 16)
    jmp set_clear_color
clear_lava:
    mov eax, lightRed + (red * 16)
    jmp set_clear_color
clear_bridge:
    mov eax, brown + (black * 16)
    jmp set_clear_color
clear_castle_wall:
    mov eax, gray + (black * 16)
    jmp set_clear_color
clear_torch:
    mov eax, yellow + (black * 16)
    jmp set_clear_color
clear_flame:
    mov eax, lightRed + (black * 16)
    jmp set_clear_color
clear_firebar:
    mov eax, lightRed + (black * 16)
    jmp set_clear_color
clear_lava_wave1:
    mov eax, white + (red * 16)
    jmp set_clear_color
clear_lava_wave2:
    mov eax, yellow + (red * 16)
    jmp set_clear_color
clear_brick_detail:
    mov eax, gray + (black * 16)
    jmp set_clear_color

set_clear_color:
    call SetTextColor
    mov al, bl
    call WriteChar
    
clear_done:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
ClearMario ENDP

DrawMario PROC
    push eax
    push edx
    
    mov dh, marioY
    
    mov al, marioX
    sub al, cameraX
    mov dl, al
    
    cmp dl, 0
    jl mario_offscreen
    cmp dl, 79
    jg mario_offscreen
    
    call Gotoxy
    
    mov eax, blue + (black * 16)
    call SetTextColor
    
    mov al, 'M'
    call WriteChar
    
mario_offscreen:
    pop edx
    pop eax
    ret
DrawMario ENDP

;==============================================================================
;HandleInput
;==============================================================================

HandleInput PROC
    push eax
    push ebx
    
    ; Check for pause (still using ReadKey for letter keys)
    mov eax, 1
    call ReadKey
    jz check_movement_keys
    
    mov inputChar, al
    
    cmp inputChar, 'p'
    je pause_game
    cmp inputChar, 'P'
    je pause_game
    
    cmp inputChar, 27
    je exit_game
    
check_movement_keys:
    ; Check A key (LEFT) - VK_A = 0x41
    INVOKE GetAsyncKeyState, 41h
    test ax, 8000h
    jz check_d_key
    
    ; A is pressed - move left
    cmp marioX, 0
    je check_d_key
    
    push eax
    push edx
    mov dl, marioX
    dec dl
    mov dh, marioY
    call GetTileAtPosition
    call IsSolidTile
    cmp al, 1
    pop edx
    pop eax
    je check_d_key
    
    call ClearMario
    dec marioX
    cmp turboActive, 1
    jne check_d_key
    dec marioX
    
check_d_key:
    ; Check D key (RIGHT) - VK_D = 0x44
    INVOKE GetAsyncKeyState, 44h
    test ax, 8000h
    jz check_w_key
    
    ; D is pressed - move right
    cmp marioX, 119
    je check_w_key
    
    push eax
    push edx
    mov dl, marioX
    inc dl
    mov dh, marioY
    call GetTileAtPosition
    call IsSolidTile
    cmp al, 1
    pop edx
    pop eax
    je check_w_key
    
    call ClearMario
    inc marioX
    cmp turboActive, 1
    jne check_w_key
    inc marioX
    
check_w_key:
    ; Check W key (JUMP) - VK_W = 0x57
    INVOKE GetAsyncKeyState, 57h
    test ax, 8000h
    jz check_space_key
    
    ; W is pressed - jump if on ground
    cmp onGround, 1
    jne check_space_key
    
    mov al, jumpPower
    mov marioVelY, al
    mov onGround, 0
    call PlayJumpSound
    jmp no_key
    
check_space_key:
    ; Check SPACE key (JUMP) - VK_SPACE = 0x20
    INVOKE GetAsyncKeyState, 20h
    test ax, 8000h
    jz no_key
    
    ; SPACE is pressed - jump if on ground
    cmp onGround, 1
    jne no_key
    
    mov al, jumpPower
    mov marioVelY, al
    mov onGround, 0
    call PlayJumpSound
    jmp no_key

pause_game:
    mov gamePaused, 1
    jmp no_key

no_key:
    pop ebx
    pop eax
    ret
    
exit_game:
    exit
    
HandleInput ENDP

;==============================================================================
; MAP RENDERING
;==============================================================================

DrawMap PROC
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    mov esi, 0FFFFFFFFh
    mov dh, 2
    
draw_row_loop:
    cmp dh, 24
    jge map_done
    
    mov dl, 0
    call Gotoxy
    
    push edx
    call GetRowPointerForLevel
    pop edx
    
    mov cl, 0
    
draw_char_loop:
    cmp cl, 80
    jge next_row
    
    movzx edi, cameraX
    movzx eax, cl
    add edi, eax
    
    cmp edi, 120
    jge draw_empty
    
    push ebx
    add ebx, edi
    mov al, [ebx]
    pop ebx
    
    push eax
    
    ; World 1-1 tiles
    cmp al, '#'
    je color_ground_scroll
    cmp al, '='
    je color_platform_scroll
    cmp al, 'o'
    je color_coin_scroll
    cmp al, '?'
    je color_question_scroll
    cmp al, '|'
    je color_pipe_scroll
    cmp al, '_'
    je color_pipe_scroll
    cmp al, 'F'
    je color_flag_scroll
    cmp al, '-'
    je color_cloud
    
    ; Castle tiles - ADD THESE HERE
    cmp al, 'B'
    je color_brick_scroll
    cmp al, 'W'
    je color_lava_wave1
    cmp al, 'w'
    je color_lava_wave2
    cmp al, '~'
    je color_bridge_scroll
    cmp al, 'X'
    je color_firebar_scroll
    cmp al, 'A'
    je color_axe_scroll
    cmp al, '['
    je color_castle_wall
    cmp al, ']'
    je color_castle_wall
    cmp al, '+'
    je color_torch
    cmp al, 'v'
    je color_flame1
    cmp al, 'V'
    je color_flame2
    
    ; Default color for unknown tiles
    mov eax, white + (black * 16)
    jmp check_color_change
    
color_cloud:
    mov eax, white + (blue * 16)
    jmp check_color_change
color_ground_scroll:
    mov eax, brown + (black * 16)
    jmp check_color_change
color_platform_scroll:
    mov eax, red + (black * 16)
    jmp check_color_change
color_coin_scroll:
    mov eax, yellow + (black * 16)
    jmp check_color_change
color_question_scroll:
    mov eax, yellow + (black * 16)
    jmp check_color_change
color_pipe_scroll:
    mov eax, green + (black * 16)
    jmp check_color_change
color_flag_scroll:
    mov eax, white + (black * 16)
    jmp check_color_change

; CASTLE COLORS - ADD THESE
color_brick_scroll:
    mov eax, gray + (black * 16)
    jmp check_color_change
color_lava_wave1:
    mov eax, lightRed + (red * 16)
    jmp check_color_change
color_lava_wave2:
    mov eax, yellow + (red * 16)
    jmp check_color_change
color_bridge_scroll:
    mov eax, brown + (black * 16)
    jmp check_color_change
color_firebar_scroll:
    mov eax, lightRed + (black * 16)
    jmp check_color_change
color_axe_scroll:
    mov eax, yellow + (black * 16)
    jmp check_color_change
color_castle_wall:
    mov eax, gray + (black * 16)
    jmp check_color_change
color_torch:
    mov eax, yellow + (black * 16)
    jmp check_color_change
color_flame1:
    mov eax, lightRed + (black * 16)
    jmp check_color_change
color_flame2:
    mov eax, yellow + (black * 16)
    jmp check_color_change
    
check_color_change:
    cmp eax, esi
    je skip_color_set
    
    mov esi, eax
    call SetTextColor
    
skip_color_set:
    pop eax
    call WriteChar
    
    inc cl
    jmp draw_char_loop
    
draw_empty:
    mov eax, white + (black * 16)
    cmp eax, esi
    je skip_empty_color
    mov esi, eax
    call SetTextColor
skip_empty_color:
    mov al, ' '
    call WriteChar
    inc cl
    jmp draw_char_loop
    
next_row:
    inc dh
    jmp draw_row_loop
    
map_done:
    mov eax, white + (black * 16)
    call SetTextColor
    
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
DrawMap ENDP

GetRowPointer PROC
    cmp dh, 0
    je ptr_row0
    cmp dh, 1
    je ptr_row1
    cmp dh, 2
    je ptr_row2
    cmp dh, 3
    je ptr_row3
    cmp dh, 4
    je ptr_row4
    cmp dh, 5
    je ptr_row5
    cmp dh, 6
    je ptr_row6
    cmp dh, 7
    je ptr_row7
    cmp dh, 8
    je ptr_row8
    cmp dh, 9
    je ptr_row9
    cmp dh, 10
    je ptr_row10
    cmp dh, 11
    je ptr_row11
    cmp dh, 12
    je ptr_row12
    cmp dh, 13
    je ptr_row13
    cmp dh, 14
    je ptr_row14
    cmp dh, 15
    je ptr_row15
    cmp dh, 16
    je ptr_row16
    cmp dh, 17
    je ptr_row17
    cmp dh, 18
    je ptr_row18
    cmp dh, 19
    je ptr_row19
    cmp dh, 20
    je ptr_row20
    cmp dh, 21
    je ptr_row21
    cmp dh, 22
    je ptr_row22
    cmp dh, 23
    je ptr_row23

ptr_row0:
    lea ebx, row0
    ret
ptr_row1:
    lea ebx, row1
    ret
ptr_row2:
    lea ebx, row2
    ret
ptr_row3:
    lea ebx, row3
    ret
ptr_row4:
    lea ebx, row4
    ret
ptr_row5:
    lea ebx, row5
    ret
ptr_row6:
    lea ebx, row6
    ret
ptr_row7:
    lea ebx, row7
    ret
ptr_row8:
    lea ebx, row8
    ret
ptr_row9:
    lea ebx, row9
    ret
ptr_row10:
    lea ebx, row10
    ret
ptr_row11:
    lea ebx, row11
    ret
ptr_row12:
    lea ebx, row12
    ret
ptr_row13:
    lea ebx, row13
    ret
ptr_row14:
    lea ebx, row14
    ret
ptr_row15:
    lea ebx, row15
    ret
ptr_row16:
    lea ebx, row16
    ret
ptr_row17:
    lea ebx, row17
    ret
ptr_row18:
    lea ebx, row18
    ret
ptr_row19:
    lea ebx, row19
    ret
ptr_row20:
    lea ebx, row20
    ret
ptr_row21:
    lea ebx, row21
    ret
ptr_row22:
    lea ebx, row22
    ret
ptr_row23:
    lea ebx, row23
    ret
GetRowPointer ENDP


GetCastleRowPointer PROC
    cmp dh, 0
    je castle_ptr_row0
    cmp dh, 1
    je castle_ptr_row1
    cmp dh, 2
    je castle_ptr_row2
    cmp dh, 3
    je castle_ptr_row3
    cmp dh, 4
    je castle_ptr_row4
    cmp dh, 5
    je castle_ptr_row5
    cmp dh, 6
    je castle_ptr_row6
    cmp dh, 7
    je castle_ptr_row7
    cmp dh, 8
    je castle_ptr_row8
    cmp dh, 9
    je castle_ptr_row9
    cmp dh, 10
    je castle_ptr_row10
    cmp dh, 11
    je castle_ptr_row11
    cmp dh, 12
    je castle_ptr_row12
    cmp dh, 13
    je castle_ptr_row13
    cmp dh, 14
    je castle_ptr_row14
    cmp dh, 15
    je castle_ptr_row15
    cmp dh, 16
    je castle_ptr_row16
    cmp dh, 17
    je castle_ptr_row17
    cmp dh, 18
    je castle_ptr_row18
    cmp dh, 19
    je castle_ptr_row19
    cmp dh, 20
    je castle_ptr_row20
    cmp dh, 21
    je castle_ptr_row21
    cmp dh, 22
    je castle_ptr_row22
    cmp dh, 23
    je castle_ptr_row23

castle_ptr_row0:
    lea ebx, castleRow0
    ret
castle_ptr_row1:
    lea ebx, castleRow1
    ret
castle_ptr_row2:
    lea ebx, castleRow2
    ret
castle_ptr_row3:
    lea ebx, castleRow3
    ret
castle_ptr_row4:
    lea ebx, castleRow4
    ret
castle_ptr_row5:
    lea ebx, castleRow5
    ret
castle_ptr_row6:
    lea ebx, castleRow6
    ret
castle_ptr_row7:
    lea ebx, castleRow7
    ret
castle_ptr_row8:
    lea ebx, castleRow8
    ret
castle_ptr_row9:
    lea ebx, castleRow9
    ret
castle_ptr_row10:
    lea ebx, castleRow10
    ret
castle_ptr_row11:
    lea ebx, castleRow11
    ret
castle_ptr_row12:
    lea ebx, castleRow12
    ret
castle_ptr_row13:
    lea ebx, castleRow13
    ret
castle_ptr_row14:
    lea ebx, castleRow14
    ret
castle_ptr_row15:
    lea ebx, castleRow15
    ret
castle_ptr_row16:
    lea ebx, castleRow16
    ret
castle_ptr_row17:
    lea ebx, castleRow17
    ret
castle_ptr_row18:
    lea ebx, castleRow18
    ret
castle_ptr_row19:
    lea ebx, castleRow19
    ret
castle_ptr_row20:
    lea ebx, castleRow20
    ret
castle_ptr_row21:
    lea ebx, castleRow21
    ret
castle_ptr_row22:
    lea ebx, castleRow22
    ret
castle_ptr_row23:
    lea ebx, castleRow23
    ret
GetCastleRowPointer ENDP

GetRowPointerForLevel PROC
    ; Input: dh = row number (0-23)
    ; Output: ebx = pointer to correct row for current level
    
    push eax
    movzx eax, currentLevel
    
    cmp al, 2
    je get_castle_map
    
    ; Level 1 - World 1-1
    call GetRowPointer
    jmp done_get_row
    
get_castle_map:
    ; Level 2 - Castle
    call GetCastleRowPointer
    
done_get_row:
    pop eax
    ret
GetRowPointerForLevel ENDP

;==============================================================================
; MAIN PROGRAM
;==============================================================================

main PROC
    call LoadPlayerName
    cmp al, 0
    jne skip_name_input
    
    ;IF NO SAVED NAME GET IT
    call GetPlayerName
    
skip_name_input:
    ;Initialize high scores on first run
    cmp gameInitialized, 0
    jne menu_loop
    
    call LoadHighScores
    mov gameInitialized, 1
   
menu_loop:
    call DisplayTitleScreen
    call DisplayMainMenu
    
    ; bl = 0 if "new game" was requested from continue menu
    ; bl = 1 if we have save file and chose option 1 (continue)
    push ebx          
    
    cmp al, '1'
    je handle_option1
    cmp al, '2'
    je high_scores
    cmp al, '3'
    je show_instructions
    cmp al, '4'
    je exit_program
    jmp menu_loop
    
handle_option1:
    pop ebx
    cmp bl, 0
    je start_new_game    
    jmp start_game      
    
high_scores:
    call DisplayHighScores
    jmp menu_loop
    
show_instructions:
    call DisplayInstructions
    jmp menu_loop

start_game:
    call LoadProgress
    cmp al, 1
    je load_saved_game
    jmp start_fresh

start_new_game:
    
start_fresh:
    mov currentWorld, 1
    mov currentLevel, 1
    mov currentScore, 0
    mov coinCount, 0
    mov livesCount, 3
    jmp common_init
    
load_saved_game:
    
level_transition:


common_init:
    
    mov cameraX, 0
    
    ;adjust starting position based on level
    movzx eax, currentLevel
    cmp al, 2
    jge castle_start_pos
    
    ; World 1-1 starting position
    mov marioX, 10
    mov marioY, 22
    jmp init_physics
    
castle_start_pos:
    ; Castle starting position - on the first platform
    mov marioX, 8
    mov marioY, 20            
    
init_physics:
    mov marioVelY, 0
    mov onGround, 1
    mov timeRemaining, 300
    mov frameCounter, 0
    mov gamePaused, 0
    mov levelComplete, 0
    mov axeReached, 0
    mov bridgeCollapse, 0
    mov victoryShown, 0
    
    ;Initialize LEVEL 2 OR LEVEL 1
    movzx eax, currentLevel
    cmp al, 2
    jl init_world1
    
    ;Castle level initialization
    call InitializeBowser
    call InitializeFirebars
    jmp init_done
    
init_world1:
    ; World 1-1 initialization
    call InitializeGoombas
    
init_done:
    call StartBackgroundMusic
    call Clrscr
    call DrawMap

game_loop:
    cmp gamePaused, 1
    jne game_running
    
    call StopBackgroundMusic
    call ShowPauseMenu
    
    cmp al, 'R'
    je resume_game
    
    ; Save progress before returning to menu
    call SaveProgress
    call StopBackgroundMusic    
    call Clrscr
    jmp menu_loop
    
resume_game:
    mov gamePaused, 0
    call StartBackgroundMusic   
    call Clrscr
    call DrawMap
    


    game_running:
    cmp levelComplete, 1
    je level_completing

    call DrawGameHud
    
    mov al, marioX
    mov oldMarioX, al
    mov al, marioY
    mov oldMarioY, al
    
    call HandleInput
    call SpawnTrailParticle

    mov bl, cameraX
    mov al, marioX
    sub al, cameraX
    cmp al, 60
    jle check_left_scroll
    cmp cameraX, 40
    jge check_left_scroll
    inc cameraX
    jmp check_camera_moved

check_left_scroll:
    mov al, marioX
    sub al, cameraX
    cmp al, 20
    jge check_camera_moved
    cmp cameraX, 0
    jle check_camera_moved
    dec cameraX
    
check_camera_moved:
    cmp bl, cameraX
    je camera_static
    
    call DrawMap
    call DrawGameHUD
    jmp after_camera
    
camera_static:
    mov bh, marioX
    mov bl, marioY
    
    mov al, oldMarioX
    mov marioX, al
    mov al, oldMarioY
    mov marioY, al
    
    call ClearMario
    
    mov marioX, bh
    mov marioY, bl
    
after_camera:
    
    ; Check which level we're in
    movzx eax, currentLevel
    cmp al, 2
    jl world1_updates
    
    ; Castle level updates
    call CheckLavaCollision
    call ClearFirebars      
    call UpdateFirebars
    call CheckFirebarCollision
    call ClearBowser
    call UpdateBowser
    call UpdateFireballs    
    call ClearFireballs    
    call CheckBowserCollision
    call CheckAxeCollision
    call UpdateBridgeCollapse
    
    cmp victoryShown, 1
    je victory_complete
    
    jmp common_updates
    
world1_updates:
    ; World 1-1 updates
    call CheckBlockHit
    call UpdateGoombas
    call HandleGoombaDefeat
    call CheckFlagpoleCollision
    cmp al, 1
    jne common_updates
    call TriggerLevelCompletion
    
common_updates:
    call ApplyGravity
    call CheckCoinCollection
    call CheckPowerupCollection
    call UpdateGameTime
    call CheckComboTimeout
    call UpdateTurboTimer
    call UpdateTrailParticles
    
    call DrawMario
    
    ;draw level-specific entities
    movzx eax, currentLevel
    cmp al, 2
    jl draw_world1
    
; Castle level drawing
    call ClearFirebars      
    call DrawFirebars
    call DrawBowser
    call DrawFireballs
    jmp draw_common
    
draw_world1:
    call ClearGoombas
    call DrawGoombas
    
draw_common:
    call DrawPowerups
    call DrawTrailParticles
    
    mov eax, 16
    call Delay
    
    jmp game_loop

victory_complete:
    call StopBackgroundMusic
    jmp menu_loop


skip_block_hit:

    call ApplyGravity
    call CheckCoinCollection
    call CheckPowerupCollection
    call UpdateGameTime
    call CheckComboTimeout
    call UpdateTurboTimer
    call UpdateTrailParticles
    call UpdateGoombas
    call HandleGoombaDefeat
    call ClearGoombas
    call DrawMario
    call DrawGoombas
    call DrawPowerups
    call DrawTrailParticles

    call CheckFlagpoleCollision
    cmp al, 1
    jne skip_flag_test
    call TriggerLevelCompletion

skip_block_test:

skip_flag_test:
    call DrawMario
;   call DrawGoombas
    
    mov eax, 16
    call Delay
    
    jmp game_loop

level_completing:
    call DrawGameHud
    call DrawMap
    
    call AnimateFlagpoleSlide
    cmp al, 1
    jne still_animating
    
    call ShowCompletionScreen
    
    movzx eax, currentLevel
    cmp al, 1
    jne back_to_menu
    
    ;completed Lvl1 - go to lvl2
    mov currentLevel, 2
    mov levelComplete, 0
    call SaveProgress
    
  ;showing transition message
    call Clrscr
    mov dh, 12
    mov dl, 25
    call Gotoxy
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov edx, OFFSET enteringCastle
    call WriteString

    mov eax, 2000
    call Delay
    
    jmp level_transition  
    
back_to_menu:
    jmp menu_loop
    
still_animating:
    call DrawMario
    
    mov eax, 16
    call Delay
    jmp game_loop

exit_program:
    call StopBackgroundMusic    
    exit
main ENDP

END main