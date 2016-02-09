  # labwork.S
  # Written 2015 by F Lundevall
  # Skeleton file for IS1200/IS1500 lab 1 2015-2016.
  # The macros PUSH and POP are in the public domain.
.macro  PUSH reg
  addi  $sp,$sp,-4
  sw  \reg,0($sp)
.endm

.macro  POP reg
  lw  \reg,0($sp)
  addi  $sp,$sp,4
.endm
.data
delaycon: .word 13500

.text
.global hexasc, delay, time2string

hexasc: 
  sll $t0, $a0, 28  # skiftar 28 steg till vänster för att ta bort ev 1:a vid binära tal med fler än 4 siffror
  srl $t0, $t0, 28  # skiftar 28 steg till höger -||-
  addi  $t0, $t0, 0x30  # addera 0x30 för att hamna på rätt ställe i ascii
  li  $t1, 0x39 # spara 0x39 (9) i $t1 för att senare kunna använda i jämförelsemetoden
  ble $t0, $t1, inrange  # om den vi är på är mindre eller lika med 9 hoppar vi till perfection
  nop 
  addi  $t0, $t0, 7 # annars adderar vi 7 för att hoppa över specialtecknen och komma till stora bokstäverna
  
inrange:
  move  $v0, $t0  # returna tecknet
  jr  $ra   # hoppa tillbaka in i main där vi va sist
    nop
  

delay:

  la  $t1, delaycon  # läser av konstanten delaycon o sparar den i $t1
  lw  $t1, 0($t1)
  
while:
  beq $a0, $0, endwhile # kollar om antalet ms är lika med 0, i såna fall är whileloopen klar
  nop
  addi  $a0, $a0, -1  # minskar antalet ms med 1
  move  $t0, $0   # sätter $t0 (som representerar i) till 0
for:
  beq $t1, $t0, endfor  # kollar om delaycon är lika med 0, i såna fall är forloopen klar
  nop
  addi  $t0, $t0, 1 # ökar $t0 (som representerar i) med 1
  j for   # går tillbaka till början av forloopen
  nop
                    # istället för nop körs denna, detta för att spara en rad

endfor:
  j while   # går tillbaka till början av whileloopen
  nop

endwhile:
  jr  $ra   # lämnar funktionen
  nop

time2string:
  PUSH    $ra # vi som callee pushar dessa för att kunna hoppa in i en annan funktion från denna
  PUSH    $s0 # och komma tillbaka till samma värden
  PUSH    $s1
  PUSH    $s2
  PUSH    $s3
  PUSH    $a0
  
  srl $a0, $a1, 12  # skiftar talet för att få de 4 sista intressanta siffrorna och kallar på metoden
  jal hexasc    # som gör om en siffra till ascii-kod
  nop
  move  $s0, $v0  # sparar det returnerade värdet i $s0
  
  srl $a0, $a1, 8 
  jal hexasc
  nop
  move  $s1, $v0
  
  srl $a0, $a1, 4
  jal hexasc
  nop
  move  $s2, $v0
  
  move  $a0, $a1
  jal hexasc
  nop
  move  $s3, $v0
  
  POP     $a0  # poppar tillbaka $a0 för att kunna använda den tidigare adressen
  
  sb  $s0, 0($a0) # sparar värdet i $s0 i $a0
  sb  $s1, 1($a0) # sparar värdet i $s1 en nibble ifrån $a0
  li  $t0, 0x3a # sparar ett kommatecken i $t0
  sb  $t0, 2($a0) # sparar värdet i $s1 två nibble ifrån $a0
  sb  $s2, 3($a0) # sparar värdet i $s1 tre nibble ifrån $a0
  li  $t0, 0x39
  bne $s3, $t0, saveasusual
  nop
  li  $t0, 0x4e #
  sb  $t0, 4($a0)
  li  $t0, 0x49
  sb  $t0, 5($a0)
  li  $t0, 0x4e
  sb  $t0, 6($a0)
  li  $t0, 0x45
  sb  $t0, 7($a0) # sparar värdet i $s1 fyra nibble ifrån $a0
  sb  $zero, 8($a0)
  j done
  nop
 saveasusual:   
  sb  $s3, 4($a0) # sparar värdet i $s1 fyra nibble ifrån $a0
  sb  $zero, 5($a0) # sparar null 5  ifrån $a0
  
 done:
  
  POP     $s3 # poppar tillbaka alla s-register
  POP     $s2
  POP     $s1
  POP     $s0
  POP     $ra
  
  jr  $ra # hoppar tillbaka till där den var innan 
  nop

