PlayPCMSample:
; Get block count
  ld b,(hl)
  inc hl
 
-:; PLay a block (from hl)
  push bc
    call PLAY_SAMPLE
  pop bc
  ; Switch to the next bank
  ld hl,$ffff
  inc (hl)
  ld hl,$8000
  ; And repeat
  djnz -
  ret

; Plays one sample
; hl: pointer to triplet count followed by data
PLAY_SAMPLE:
  ld a,(hl)
  ld ixl,a
  inc hl
  ld a,(hl)
  ld ixh,a
  inc hl
 
  ld c,$7f
 
-:
  ; Starting on a byte boundary version
  rld       ; 18
  and $f    ;  7
  or $90    ;  7
  ld d,a    ;  4

  ld a,(hl) ;  7
  and $f    ;  7
  or $b0    ;  7
  ld e,a    ;  4

  call Delay276

  inc hl    ;  6
  rld       ; 18
  and $f    ;  7
  or $d0    ;  7
 
  out (c),d ; 12
  out (c),e ; 12
  out (c),a ; 12
 
  ; Check counter
  dec ix    ; 10
  ld a,ixh  ;  8?
  or ixl    ;  8?
  ret z     ;  5
 
  ; Starting on a half-byte boundary version
  ld a,(hl) ;  7
  and $f    ;  7
  or $90    ;  7
  ld d,a    ;  4

  inc hl    ;  6
  rld       ; 18
  and $f    ;  7
  or $b0    ;  7
  ld e,a    ;  4
 
  call Delay286
 
  ld a,(hl) ;  7
  and $f    ;  7
  or $d0    ;  7
  inc hl    ;  6
 
  out (c),d ; 12
  out (c),e ; 12
  out (c),a ; 12

  ; Check counter
  dec ix    ; 10
  ld a,ixh  ;  8?
  or ixl    ;  8?
  jp nz,-   ; 10
  ret
 
Delay286:
  jp Delay276 ; 10
Delay276:
  ld b,14     ;  7
-:or a        ;  4*14
  djnz -      ; 13*14-5
  ld a,i      ;  9
  ret         ; 27 (including call)