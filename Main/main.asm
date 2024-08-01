;==============================================================
; WLA-DX banking setup
;==============================================================
.memorymap
    slotsize $7FF0	
    slot 0 $0000	

    slotsize $10	
    slot 1 $7FF0	

    slotsize $4000	
    slot 2 $8000	

    defaultslot 2	
.endme

.rombankmap
    bankstotal 8

    banksize $7FF0
    banks 1

    banksize $10
    banks 1

    banksize $4000
    banks 6
.endro


;==============================================================
; SMS defines
;==============================================================
.define PORT_VDP_ADDRESS    $BF 
.define VDPData             $BE
.define VRAMWrite           $4000
.define VRAMRead            $0000
.define CRAMWrite           $C000
.define NameTable           $3800
.define TextBox             $3CCC
.define TEXT_START          $1AC0

.define paletteSize         $10

.define VerticalBounds      $A8
.define DownBounds          $A8
.define LeftBounds          $09
.define RightBounds         $E8

.define BankSwitch          $FFFF
.define sramSwitch          $FFFC
.define highScoreCart       $8000
.define highScoreOffset     HeaderForSRAMEnd-HeaderForSRAM + highScoreCart
.define highScoreDataLength $000C   ;Score, score graphics and name


;==============================================================
; SDSC tag and ROM header
;==============================================================

.sdsctag 1.1, "SPACE TONBOW", "A TATE/YOKO Experiment","Bofner"

.bank 1 slot 1
.org $0000
    ;.db $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 
    ;I think the Checksum or header or something goes here

.bank 0 slot 0
.org $0000
;==============================================================
; Boot Section
;==============================================================

    di              ;Disable interrupts
    im 1            ;Interrupt mode 1
    jp init         ;Jump to the initialization program

;==============================================================
; SRAM Header file
;==============================================================
HeaderForSRAM:
.incbin "..\\SRAM\\save_header.bin"
HeaderForSRAMEnd:

;==============================================================
; Interrupt Handler
;==============================================================
.orga $0038
    push af                         ;Prserve AF
;Get the status of the VDP
        in a,(PORT_VDP_ADDRESS)     ;Get status of VDP
                                    ;Bit 7:     1 = VBlank 0 = HBlank
                                    ;Bit 6:     1 = >=9 sprites on raster
                                    ;Bit 5:     1 = Sprite collision
                                    ;Bit 4-0:   No function
        ;ld (VDPStatus), a           ;Save to check if we are at VBLANK
        or a                        ;Check if POS or NEG (Bit 7 OFF or ON)
        jp p, HBlank                ;If bit 7 is 0, then we are at HBlank
;Do specific scanline-based tasks
        jp VBlank
;VBlank and HBlank will handle returning
        ;reti


;==============================================================
; Pause button handler
;==============================================================
.org $0066
;Swap shadow registers and registers for pause protection
    push af
    push bc
    push de 
    push hl
        ld a, (tonbow.alive)
        cp $00
        jp z, EndPauseHandling
        ld a, (sceneID)
    ;If Scene ID is invalid, do nothing
        cp NO_SCENE_ID
        jp nc, EndPauseHandling
        ;ld a, (optionsByte)
        ;bit 3, a
        ;jr nz, EndPauseHandling
    ;Else...
    ;3 * N + PauseJumpTable
        ld c, a
        add a, c
        add a, c                           ;3 * N 
        ld h, 0
        ld l, a
        ld de, PauseJumpTable
        add hl, de                      ;3 * N + DPadJumpTable
        jp hl                           ;Jump to specific input subroutine

EndPauseHandling:
;Swap shadow registers and register back to end protection
    pop hl
    pop de
    pop bc
    pop af

    retn

;==============================================================
; What to do if we unpause
;==============================================================
UnpauseHandler:
    ld hl, sceneID
    ld a, (pauseSceneID)
    ld (hl), a

;Temporary Jerkiness fix
    
;End Jerkiness fix
    jp EndPauseHandling                         ;retn   

;==============================================================
; Pause Jump Table
;==============================================================
PauseJumpTable:
;Where to jump when PAUSE button hit
;Do correct action based on Scene ID                            ;$XX = Scene ID
    jp EndPauseHandling                                         ;$00 = SFS Splash Screen
    jp UnpauseHandler                                           ;$01 = Pause Screen
    jp EndPauseHandling                                         ;$02 = Title Screen
    jp DemoPause                                                ;$03 = Demo Level

;==============================================================
; Include our STRUCTS and assets
;==============================================================
.include "..\\Object_Files\\structs.asm"

;==============================================================
; Boiler Variables 
;============================================================== 
.enum $C000 export
    ;SATBuffer
    VBuffer         dsb $40         ;Holds the yPos for all sprites
    HCBuffer        dsb $80         ;Holds the xPos and CC for all sprites

    safetyBuffer    dsb $10     ;8 Byte buffer just in case we accidentally render too many sprites on the screen

    frameFinish     db          ;$00 = Not finished, $01 = Writing finished, $11 = VBlank and writing finished

    currentBank     db          ;Save the current bank

    VDPStatus       db          ;Holds VDP Status from the interrupt
                                ;Bit 7:     1 = VBlank
                                ;Bit 6:     1 = >=9 sprites on raster
                                ;Bit 5:     1 = Sprite collision
                                ;Bit 4-0:   No function

    playFM          db          ;Do we have FM unit?
    onFM            db          ;Are we currently using it?

    nextHBlankStep  dw          ;Variable that tells where to go for next HBlank

    DCInput         db          ;$DC input
    DDInput         db          ;$DD input

    spriteCount     db          ;How many sprites are on screen on current frame (Reset at th beginning of each frame)
    SBTVS instanceof spriteBufferTemporaryVariablesStruct   ;Used for writing to the SATBuffers

    frameCount      db          ;Used to count frames in intervals of 60

    scrollX0        db          ;Parallax X Scroll
    scrollX1        db          ;Parallax X Scroll
    scrollX2        db          ;Parallax X Scroll
    scrollX3        db          ;Parallax X Scroll
    scrollX4        db          ;Parallax X Scroll
    scrollX5        db          ;Parallax X Scroll
    scrollX6        db          ;Parallax X Scroll
    scrollX7        db          ;Parallax X Scroll
    scrollX8        db          ;Parallax X Scroll
    scrollX9        db          ;Parallax X Scroll
    scrollXA        db          ;Parallax X Scroll
    scrollXB        db          ;Parallax X Scroll
    scrollXC        db          ;Parallax X Scroll
    scrollXD        db          ;Parallax X Scroll
    scrollXE        db          ;Parallax X Scroll
    scrollXF        db          ;Parallax X Scroll

    scrollX0Frac    dw          ;Fractional position $WHOLELO, FRAC $UNUSED, WHOLEHI
    scrollX1Frac    dw          ;Fractional position $WHOLELO, FRAC $UNUSED, WHOLEHI

    scrollY         db          ;Generic, no parallax scrollY

    currentBGPal instanceof paletteStruct   ;Used for Fade
    currentSPRPal instanceof paletteStruct  ;Used for Fade
    targetBGPal instanceof paletteStruct    ;Used for Fade
    targetSPRPal instanceof paletteStruct   ;Used for Fade

    sceneComplete   db          ;Used to determine if a scene is finished or not
    sceneID         db          ;Used to determine the scene we are on ($00 = SFS, $02 = Title, $01 = Pause, etc.)         
    pauseSceneID    db          ;The scene ID of the screen we were just coming from
    tateMode        db          ;$00 = YOKO, $01 = TATE

    highScoreSMS    dw          ;Local High score

    pauseCursor instanceof cursorStruct         ;Located here so we don't overwite other sprites
    
    optionsBuffer   db                          ;\ These are used to determine controls, and TATE
    optionsByte     db                          ;/ 
    ;0000000
    ;|||||| `-------- Tate Mode
;    ||||| `--------- Control Mode
;    |||| `---------- Dash Mode
;    ||| `----------- UNUSED
;    || `------------ UNUSED
;    | `------------- UNUSED
;     `-------------- UNUSED 

    score           dw                          ;Keep track of the player's score

    randSeed        dw                          ;Random Number

    enemyList instanceof enemyListStruct        ;List of enemies on screen

    ;$C000 to $DFFF is the space I have to work with for variables and such
    endByte         db          ;The first piece of available data post boiler-plate data
    
.ende



;==============================================================
; Game Constants
;==============================================================
.define SFS                         $00
.define PAUSE_SCREEN                $01
.define TITLE_SCREEN                $02
.define DEMO_LEVEL                  $03
.define NO_SCENE_ID                 $04



;=============================================================================
; Special numbers 
;=============================================================================

.define postBoiler  endByte     ;Location in memory that is past the boiler plate stuff


;==============================================================
; Start up/Initialization
;==============================================================
init: 
    ld sp, $DFF0

;This code is from Phantasy Star
FMDetection:
    ld a,($c000)
    or $04             ; Disable I/O chip
    out ($3E),a
    ld bc, $0700        ; Counter (7 -> b), plus 0 -> c
-:  ld a,b
    and %00000001      ; Mask to bit 0 only
    out ($f2),a        ; Output to the audio control port
    ld e,a
    in a,($f2)         ; Read back
    and %00000111      ; Mask to bits 0-2 only
    cp e               ; Check low 3 bits are the same as what was written
    jr nz,+
    inc c              ; c = # of times the test was passed
+:  djnz -
    ld a,c
    cp 7               ; Check test was passed 7 times out of 7
    jr z,+
    xor a              ; If not, result is 0
+:  and 1              ; If so, result is 1
    ld (playFM), a     ; Store result in C
    xor a          ;Keep PSG Enabled even if we have FM
    ld hl, onFM
    ld (hl), a
    out ($f2),a        ;So we load $00 instead of $01
    ld a,($c000)
    out ($3e),a        ; Turn I/O chip back on

;==============================================================
; Initialize RAM to zero and set up some variables
;==============================================================

    ld bc, $DFFF - $C000            ;Size of entire RAM space for variables
    ld hl, $C000                    ;Beginning point of RAM
;Save our FM detector variables
    ld a, (playFM)
    ld d, a
    ld a, (onFM)
    ld e, a
-:
;Initialize RAM to zero
    xor a
    ld (hl), a
    dec bc
    inc hl
    or b
    jr nz, -
    or c
    jr nz, -

;Return our FM Detector variables
    ld a, d
    ld (playFM), a
    ld a, e
    ld (onFM), a

;==============================================================
; Initialize SRAM (if it needs to be initialized)
;==============================================================
;Check for our header
;SRAM Select Register
    ld a, %00001000
    ld (sramSwitch), a
;Load our registers with our data and counters
    ld b, HeaderForSRAMEnd-HeaderForSRAM
    ld hl, HeaderForSRAM
    ld de, highScoreCart
;Go through each value to check if the header holds the proper value
-:
    ld a, (de)
    ld c, (hl)
    inc hl              ;\ Increment our bytes for HL and DE
    inc de              ;/
    cp c
    jr nz, InitSRAM     ;If not proper, then initialize VRAM

    djnz -
OkaySRAM:
    jr +
;Initialize our SRAM
InitSRAM:
    ld b, HeaderForSRAMEnd-HeaderForSRAM
    ld hl, highScoreCart
    ld de, HeaderForSRAM
-:
;Transfer data
    ld a, (de)
    ld (hl), a
;Increment
    inc hl
    inc de
;Repeat for header length
    djnz -
;Once more to wipe the top score data
    ld b, highScoreDataLength
-:
    xor a
    ld (hl), a
    inc hl

    djnz -

+:
;Set our High Score
    ld hl, highScoreOffset        ;10s and 1 digit
    ld a, (hl)
    ld hl, highScoreSMS
    ld (hl), a
    ld hl, highScoreOffset + 1    ;100s digit
    ld a, (hl)
    ld hl, highScoreSMS+ 1
    ld (hl), a
;Switch out from SRAM
    ld a, %00000000
    ld (sramSwitch), a
;==============================================================
; Set up VDP Registers
;==============================================================
;This is VDP Intialization data
    ld hl,VDPInitData                       ; point to register init data.
    ld b,VDPInitDataEnd - VDPInitData       ; 11 bytes of register data.
    ld c, $80                               ; VDP register command byte.
    call SetVDPRegisters

;Set up banks
    ld a, $00
    ld ($FFFD), a
    ld a, $01
    ld ($FFFE), a
    ld a, $02
    ld ($FFFF), a    

;==============================================================
; Clear VRAM
;==============================================================
;Set first color in sprite palette to black
    ld hl, $C010 | CRAMWrite
    call SetVDPAddress
;Next we send the BG palette data
    ld (hl), $00
    ld bc, $01
    call CopyToVDP

    call BlankScreen
    
    call ClearVRAM    

;==============================================================
; Initialize special variables
;==============================================================

;Set up HBlank sequence
    ld hl, FirstHBlank
    ld (nextHBlankStep), hl


;==============================================================
; Set up PSGlib and MBPlay
;==============================================================
    ld a, Audio
    ld ($FFFF), a
    call PSGInit 
    ld hl, MBMBank
    ld (hl), Audio
    ld a, SFSBank
    ld ($FFFF), a 

;==============================================================
; Enable Interrupts
;==============================================================

    ;ei


BeginSpaceTonbow:

;Check for TATE mode
    in a, $DC                       ;Send Joypad port 1 input data to register A
    cpl                             ;Reverse the bits
    bit 5, a
    jr z, +
    ld hl, tateMode
    ld (hl), $01                    ;Set TATE Mode
+:
    call SteelFingerStudios
    di

    call TitleScreen
    di

    call DemoLevel

;Turn off HBlank
    ld a, $FF                               
    ld c, $8A
    call UpdateVDPRegister
;Wait for VBlank
    halt
;Stop Interrupts
    di
 ;Turn off the display
    ld a, %00100010 
    ld c, $81
    call UpdateVDPRegister

    jp BeginSpaceTonbow

;==============================================================
; Include Helper Files
;==============================================================
.include "..\\Helper_Files\\helperFunctions.asm"
.include "..\\Helper_Files\\interruptHandler.asm"
.include "..\\Object_Files\\enemyList.asm"

;Couldn't neatly fit them in the audio bank, so here they are
DangerousPlanetPSG:
    .incbin "..\\Audio\\music\\approaching_a_dangerous_planet.bin"
    
DangerousPlanetFM:
    .incbin "..\\Audio\\music\\approaching_a_dangerous_planet_FM.bin"

;==============================================================
; Include Game Mechanic Files
;==============================================================
.include "..\\Tonbow\\tonbowControllerOneInput.asm"
.include "..\\Tonbow\\updateTonbow.asm"
.include "..\\Tonbow\\tonbowInit.asm"
.include "..\\Object_Files\\demoOrb.asm"
.include "..\\Object_Files\\orbShot.asm"
.include "..\\Object_Files\\score.asm"
.include "..\\Pause_Screen\\pauseScreenControllerOneInput.asm"

;==============================================================
; Include Level Files
;==============================================================
.include "..\\Splash_Screen\\steelFingerStudios.asm"
.include "..\\Title_Screen\\titleScreen.asm"
.include "..\\Title_Screen\\titleControl.asm"
.include "..\\Demo_Level\\demoLevel.asm"
.include "..\\Demo_Level\\demoSetup.asm"
.include "..\\Demo_Level\\demoUpdate.asm"
.include "..\\Demo_Level\\demoBGScrolling.asm"
.include "..\\Demo_Level\\gameOverControl.asm"
.include "..\\Pause_Screen\\pauseScreen.asm"
.include "..\\Pause_Screen\\pauseSetup.asm"



;==============================================================
; Assets
;==============================================================
.include "..\\assets\\assets.asm"



