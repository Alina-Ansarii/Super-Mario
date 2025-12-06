;==============================================================================
; SUPER MARIO - MINIMAL START (SIMPLE COLORED VERSION)
; Just draw the map and show Mario (no movement yet)
;==============================================================================

INCLUDE Irvine32.inc

.data
;==============================================================================
; MARIO POSITION
;==============================================================================
marioX  BYTE 10             ; Mario's X position (column)
marioY  BYTE 18             ; Mario's Y position (row)

inputChar BYTE ?            ; Stores the last key pressed
marioVelY SBYTE 0           ; Vertical velocity (signed: negative=up, positive=down)
onGround  BYTE 1            ; 1 = on ground, 0 = in air
jumpPower SBYTE -4         ; Initial jump velocity (negative = upward)

;==============================================================================
; LEVEL 1 MAP (80 characters wide, 20 rows tall)
;==============================================================================
row0  BYTE "                                                                                ", 0
row1  BYTE "                                                                                ", 0
row2  BYTE "                                                                                ", 0
row3  BYTE "                                                                                ", 0
row4  BYTE "                                                                                ", 0
row5  BYTE "                                                                                ", 0
row6  BYTE "                                                                                ", 0
row7  BYTE "                                                                                ", 0
row8  BYTE "              o   o   o                                                         ", 0
row9  BYTE "          =========                                                             ", 0
row10 BYTE "                                                                                ", 0
row11 BYTE "                                                                                ", 0
row12 BYTE "                          o                                                     ", 0
row13 BYTE "      ===         =========                                                     ", 0
row14 BYTE "                                                                                ", 0
row15 BYTE "                                                                                ", 0
row16 BYTE "                                      o   o   o                                 ", 0
row17 BYTE "  o                           =================                                 ", 0
row18 BYTE "                                                                                ", 0
row19 BYTE "################################################################################", 0

.code

;==============================================================================
; PROCEDURE: ApplyGravity
; PURPOSE: Apply gravity and update Mario's Y position
;==============================================================================
ApplyGravity PROC
    push eax
    push ebx
    
    ; Check if Mario is in the air
    cmp onGround, 1
    je skip_gravity         ; On ground, no gravity needed
    
    ; Apply gravity (increase downward velocity)
    inc marioVelY           ; Gravity pulls down (+1 each frame)
    
    ; Cap maximum fall speed at +5
    cmp marioVelY, 5
    jle gravity_ok
    mov marioVelY, 5
    
gravity_ok:
    ; Apply vertical velocity to position
    mov al, marioY
    add al, marioVelY       ; marioY = marioY + marioVelY
    
    ; Check if hitting ground (row 18)
    cmp al, 18
    jl still_in_air
    
    ; Hit ground - stop falling
    mov marioY, 18
    mov marioVelY, 0
    mov onGround, 1
    jmp skip_gravity
    
still_in_air:
    ; Update Y position
    mov marioY, al
    mov onGround, 0
    
skip_gravity:
    pop ebx
    pop eax
    ret
ApplyGravity ENDP






;==============================================================================
; PROCEDURE: ClearMario
; PURPOSE: Erase Mario from his current position (draw a space)
;==============================================================================
ClearMario PROC
    push eax
    push edx
    
    ; Move cursor to Mario's current position
    mov dh, marioY
    mov dl, marioX
    call Gotoxy
    
    ; Draw a space to erase Mario
    mov al, ' '
    call WriteChar
    
    pop edx
    pop eax
    ret
ClearMario ENDP

;==============================================================================
; PROCEDURE: HandleInput
; PURPOSE: Read keyboard input and move Mario
;==============================================================================
HandleInput PROC
    push eax
    push ebx
    
    ; Check if a key was pressed (non-blocking)
    mov eax, 1              ; 1 = don't wait for key
    call ReadKey
    jz no_key               ; Jump if zero flag set (no key pressed)
    
    ; Store the key that was pressed
    mov inputChar, al
    
    ; Check which key was pressed
    cmp inputChar, 'a'
    je move_left
    cmp inputChar, 'A'
    je move_left
    
    cmp inputChar, 'd'
    je move_right
    cmp inputChar, 'D'
    je move_right
    
    cmp inputChar, 'w'
    je jump
    cmp inputChar, 'W'
    je jump
    cmp inputChar, ' '      ; Space bar also jumps
    je jump
    
    cmp inputChar, 27       ; ESC key
    je exit_game
    
    jmp no_key              ; Key pressed but not one we handle
    
move_left:
    ; Check if Mario can move left (not at edge)
    cmp marioX, 0
    je no_key               ; At left edge, can't move
    
    ; Erase Mario from current position
    call ClearMario
    
    ; Move Mario left
    dec marioX
    jmp no_key
    
move_right:
    ; Check if Mario can move right (not at edge)
    cmp marioX, 79          ; 79 = rightmost column
    je no_key               ; At right edge, can't move
    
    ; Erase Mario from current position
    call ClearMario
    
    ; Move Mario right
    inc marioX
    jmp no_key
    
jump:
    ; Only jump if on ground
    cmp onGround, 1
    jne no_key              ; Already in air, can't jump again
    
    ; Start jump
    mov al, jumpPower
    mov marioVelY, al       ; Set upward velocity
    mov onGround, 0         ; Mario is now in air
    
no_key:
    pop ebx
    pop eax
    ret
    
exit_game:
    exit
    
HandleInput ENDP





;==============================================================================
; PROCEDURE: DrawMap
; PURPOSE: Draw the entire level map on screen
;==============================================================================
DrawMap PROC
    push eax
    push edx
    
    ; Set ground color (brown)
    mov eax, brown + (black * 16)
    call SetTextColor
    
    ; Draw row 0
    mov dh, 0
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row0
    call WriteString
    
    ; Draw row 1
    mov dh, 1
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row1
    call WriteString
    
    ; Draw row 2
    mov dh, 2
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row2
    call WriteString
    
    ; Draw row 3
    mov dh, 3
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row3
    call WriteString
    
    ; Draw row 4
    mov dh, 4
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row4
    call WriteString
    
    ; Draw row 5
    mov dh, 5
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row5
    call WriteString
    
    ; Draw row 6
    mov dh, 6
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row6
    call WriteString
    
    ; Draw row 7
    mov dh, 7
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row7
    call WriteString
    
    ; Draw row 8 (has coins - use yellow)
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row8
    call WriteString
    
    ; Draw row 9 (has platforms - use red)
    mov eax, red + (black * 16)
    call SetTextColor
    mov dh, 9
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row9
    call WriteString
    
    ; Draw row 10
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 10
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row10
    call WriteString
    
    ; Draw row 11
    mov dh, 11
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row11
    call WriteString
    
    ; Draw row 12 (has coin - use yellow)
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 12
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row12
    call WriteString
    
    ; Draw row 13 (has platforms - use red)
    mov eax, red + (black * 16)
    call SetTextColor
    mov dh, 13
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row13
    call WriteString
    
    ; Draw row 14
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 14
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row14
    call WriteString
    
    ; Draw row 15
    mov dh, 15
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row15
    call WriteString
    
    ; Draw row 16 (has coins - use yellow)
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 16
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row16
    call WriteString
    
    ; Draw row 17 (has coin and platforms - use yellow)
    mov dh, 17
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row17
    call WriteString
    
    ; Draw row 18
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 18
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row18
    call WriteString
    
    ; Draw row 19 (ground - use brown)
    mov eax, brown + (black * 16)
    call SetTextColor
    mov dh, 19
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET row19
    call WriteString
    
    pop edx
    pop eax
    ret
DrawMap ENDP

;==============================================================================
; PROCEDURE: DrawMario
; PURPOSE: Draw Mario at his position
;==============================================================================
DrawMario PROC
    push eax
    push edx
    
    ; Move cursor to Mario's position
    mov dh, marioY          ; Row
    mov dl, marioX          ; Column
    call Gotoxy
    
    ; Set Mario's color (blue for roll 0642)
    mov eax, blue + (black * 16)
    call SetTextColor
    
    ; Draw Mario as 'M'
    mov al, 'M'
    call WriteChar
    
    pop edx
    pop eax
    ret
DrawMario ENDP

;==============================================================================
; MAIN PROGRAM
;==============================================================================
main PROC
    ; Clear the screen
    call Clrscr
    
    ; Draw the level map (only once at start)
    call DrawMap
    
game_loop:
    ; Erase Mario from old position
    call ClearMario
    
    ; Handle keyboard input
    call HandleInput
    
    ; Apply gravity (makes Mario fall)
    call ApplyGravity
    
    ; Draw Mario at his new position
    call DrawMario
    
    ; Small delay for smooth movement (16ms ? 60 FPS)
    mov eax, 16
    call Delay
    
    ; Loop forever
    jmp game_loop
    
    exit
main ENDP

END main
