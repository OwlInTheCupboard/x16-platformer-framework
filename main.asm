.include "x16.inc"

.org $080D
.segment "STARTUP"
.segment "INIT"
.segment "ONCE"
.segment "CODE"

  jmp start

.include "math.asm"

;Initial VERA settings
VERA_INTERUPT = $01
VERA_SCALE = 64 ;visable screen size is 320x240
VERA_L0_COLOR_DEPTH_MASK = $02
VERA_L1_COLOR_DEPTH_MASK = $02
VERA_DC_VIDEO_MASK = $70

default_irq_vector: .addr 0

test_number: .byte 0,0
test_result: .byte 0,0

start: ;initialise game states
  sei
  jsr initialise_interupts
  jsr initialise_vera
  jsr initialise_game
  cli
  jmp main

initialise_game: ;use this for any initial conditions or loading assets in memory on loading the game(e.g. pallets, graphics etc...)
  math_add_16bit test_number, 300
  math_floor_16bit test_number, test_result
  rts

custom_irq: ;game loop
  lda VERA_isr
  and #$01
  bne @update
  lda VERA_isr
  and #$02
  bne @line
  jmp @done
  @update: ;place per frame operations in here
    jmp @done
  @line: ;place per line operations in here (can be removed if not using line interupts)
    jmp @done
  @done:
  jmp (default_irq_vector)

main: ;loop forever
  wai
  jmp main

initialise_vera:
  lda #VERA_INTERUPT
  sta VERA_ien
  lda #VERA_SCALE
  sta VERA_dc_hscale
  sta VERA_dc_vscale
  lda VERA_dc_video
  ora #VERA_DC_VIDEO_MASK
  sta VERA_dc_video
  lda VERA_L0_config
  ora #VERA_L0_COLOR_DEPTH_MASK
  sta VERA_L0_config
  lda VERA_L1_config
  ora #VERA_L1_COLOR_DEPTH_MASK
  sta VERA_L1_config
  lda VERA_L1_tilebase
  ora #$03
  sta VERA_L1_tilebase
  rts

initialise_interupts: ;overwrite the defaut irq handler vector with a vector to custom irq handler
  lda IRQVec
  sta default_irq_vector
  lda IRQVec + 1
  sta default_irq_vector + 1

  lda #<custom_irq
  sta IRQVec
  lda #>custom_irq
  sta IRQVec + 1
  rts
