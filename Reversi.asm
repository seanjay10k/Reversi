.data 
#Labels to print the board
vline1: .asciiz "1 |   |   |   |   |   |   |   |   |   \n"
vline2: .asciiz "2 |   |   |   |   |   |   |   |   |   \n"
vline3: .asciiz "3 |   |   |   |   |   |   |   |   |   \n"
vline4: .asciiz "4 |   |   |   | x | o |   |   |   |   \n"
vline5: .asciiz "5 |   |   |   | o | x |   |   |   |   \n"
vline6: .asciiz "6 |   |   |   |   |   |   |   |   |   \n"
vline7: .asciiz "7 |   |   |   |   |   |   |   |   |   \n"
vline8: .asciiz "8 |   |   |   |   |   |   |   |   |   \n"
numline: .asciiz"    1   2   3   4   5   6   7   8     \n"
newline: .asciiz"\n"
array : .word vline1,vline2,vline3,vline4,vline5,vline6,vline7,vline8
userKey_o: .asciiz"o"
gameKey_x: .asciiz"x"
gameKey_sp: .asciiz" "
promptX: .asciiz "Please enter x-coordinate "
promptY: .asciiz "please enter y-coordinate "
x_co: .word 0
y_co: .word 0

errormsg: .asciiz "Enter the valid input.\n"

.text 

la $t7,vline1 # get address of vline1
la $t8,vline8 #get address of numline
addi $t8,$t8,40 #t8 is the lowermost boundary of table



printBoard:
li	$v0, 4
la	$a0, vline1	# Printing the vertical line 1
syscall
li	$v0, 4
la	$a0, vline2	# Printing the vertical line 2
syscall
la	$a0, vline3	# Printing the vertical line 3
syscall
la	$a0, vline4	# Printing the vertical line 4
syscall
la	$a0, vline5	# Printing the vertical line 5
syscall
la	$a0, vline6	# Printing the vertical line 6
syscall
la	$a0, vline7	# Printing the vertical line 7
syscall
la	$a0, vline8	#Printing the vertical line 8
syscall
la $a0,numline
syscall


li $a3,2 
li $a2,0

#USER_First:


validinput:
li $v0,4
la $a0,promptX
syscall
li $v0,5
syscall
move $t0,$v0
sw $t0,x_co

li $v0,4
la $a0,promptY
syscall 
li $v0,5
syscall
move $t1,$v0
sw $t0,y_co

bgt $t0,8,error
blt $t0,1,error
 
bgt $t1,8,error
blt $t1,1,error
j exit
 
error:
li $v0,4
la $a0,errormsg
syscall
j validinput

exit:
la $t9,vline1 #t9 has vline1 address, ie array base address
# resolve y coordinate first
addi $t2,$t1,-1 #t1 is y-coordinate, substract 1 so vline1+(40*y) gets us to correct vline
#t2 is updated y
mul $t2,$t2,40 #t2 now points to correct offset 
add $t3,$t2,$t9 #t3 has accurate vline or accurate y user wants
addi $s0,$t3,0 # s0 has our y address
#t0 is our user entered x-coordinate
mul $t4,$t0,4 # t4 now is accurate space away from desired vline 
addi $s1,$t4,0 #s1 has value of t4(x) 
add $t5, $t3,$t4 # finally, t5 has the space we wanted
addi $s2,$t5,0 # s2 has accurate position to place 

lb $s4,($s2)
beq $s4,$t6,error #if address already has 'o',error
beq $s4,$t9,error #if address already has 'x',error 




Whoseturn:
div $a2,$a3

mfhi $a2

#addi $a3,$a3,1

beq $a2,0,USER1
beq $a2,1,USER2
j Whoseturn
 
 
USER1:
addi $a2,$a2,1 # turn counter
lb $t6,userKey_o #t6 has 'o'
lb $t9,gameKey_x #t9 has 'x'
lb $t5,gameKey_sp #t5 has ' ' ie.space
jal CheckNeighbors
j SetPrint

USER2:
addi $a2,$a2,1 #turn counter
lb $t6,gameKey_x #t6 has 'x'
lb $t9,userKey_o #t9 has 'o'
lb $t5,gameKey_sp #t5 has ' ' ie.space
jal CheckNeighbors
j SetPrint

 


#j Whoseturn

#li $v0,10 #terminate
#syscall







CheckNeighbors:
#addi $sp,$sp,-4
#sw $ra,0($sp)
#andi $s5,$ra,1
##############################################################EEEEEEEEEEEEEEEEEEEEEEE
East:
li $s7,0 #s7 be our counter

CheckEast:
addiu $t0,$s2,4 #4 spaces to right of calculated address
#check r/l/up/down boundary later
lb $t1,($t0) #see what is already in that address
beq $t1,$t6,SouthEast #if already has 'o', just move on...
beq $t1,$t5,SouthEast #if already has ' ', just move on..
beq $t1,$t9,StackOp #if already has 'x' ,go to stack and save the address
#j SouthEast # can remove this later

StackOp:
addi $sp,$sp,-4 # create 4 bytes space in stack 
addiu $s7,$s7,1 #using s7 as a counter
sw $t0,0($sp) 
#j checkNewX
checkNewX:
addiu $t0,$t0,4 #more 4 spaces to right
lb $t1,($t0) #load byte from that address
beq $t1,$t9,StackOp
beq $t1,$t6,updateBoard

bge $t1,$t8,Restorestack
beq $t1,$t5,Restorestack
j checkNewX

Restorestack:

addiu $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,SouthEast
j Restorestack

updateBoard:
lw $s6,($sp)
sb $t6,($s6)
addiu $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,updateBoardkey
j updateBoard

updateBoardkey: 
sb $t6,($s2) # put 'o' into the computed XY address
j SouthEast



###############################################################SESESESESESESESESESESESE
SouthEast:

li $s7,0 #s7 be our counter

CheckSouthEast:
addi $t0,$s2,44 #44 spaces to right of calculated address
#check r/l/up/down boundary later
lb $t1,($t0) #see what is already in that address
beq $t1,$t6,South #if already has 'o', just move on...
beq $t1,$t5,South #if already has ' ', just move on..
beq $t1,$t9,StackOp1 #if already has 'x' ,go to stack and save the address
#j SouthEast # can remove this later

StackOp1:
addiu $sp,$sp,-4 # create 4 bytes space in stack 
addi $s7,$s7,1 #using s7 as a counter
sw $t0,($sp) 
#j checkNewX
checkNewX1:
addi $t0,$t0,44 #more 4 spaces to right
lb $t1,($t0) #load byte from that address
beq $t1,$t9,StackOp1
beq $t1,$t6,updateBoard1
bge $t1,$t8,Restorestack1
beq $t1,$t5,Restorestack1
j checkNewX1

Restorestack1:
addi $sp,$sp,4
addi $s7,$s7,-1

beqz $s7,South
j Restorestack1

updateBoard1:
lw $s6,($sp)
sb $t6,($s6)
addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,updateBoardkey1
j updateBoard1

updateBoardkey1: 
sb $t6,($s2) # put 'o' into the computed XY address

j South

South:

li $s7,0 #s7 be our counter

CheckSouth:
addi $t0,$s2,40 #4 spaces to right of calculated address
#check r/l/up/down boundary later
lb $t1,($t0) #see what is already in that address
beq $t1,$t6,SW #if already has 'o', just move on...
beq $t1,$t5,SW #if already has ' ', just move on..
beq $t1,$t9,StackOp2 #if already has 'x' ,go to stack and save the address
#j SouthEast # can remove this later

StackOp2:
addiu $sp,$sp,-4 # create 4 bytes space in stack 
addi $s7,$s7,1 #using s7 as a counter
sw $t0,($sp) 
#j checkNewX
checkNewX2:
addi $t0,$t0,40 #more 4 spaces to right
lb $t1,($t0) #load byte from that address
beq $t1,$t9,StackOp2
beq $t1,$t6,updateBoard2
bge $t1,$t8,Restorestack2
beq $t1,$t5,Restorestack2
j checkNewX2

Restorestack2:

addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,SW
j Restorestack2

updateBoard2:
lw $s6,($sp)
sb $t6,($s6)
addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,updateBoardkey2
j updateBoard2

updateBoardkey2: 
sb $t6,($s2) # put 'o' into the computed XY address

j SW


SW:

li $s7,0 #s7 be our counter

CheckSW:
addi $t0,$s2,36 #4 spaces to right of calculated address
#check r/l/up/down boundary later
lb $t1,($t0) #see what is already in that address
beq $t1,$t6,W #if already has 'o', just move on...
beq $t1,$t5,W #if already has ' ', just move on..
beq $t1,$t9,StackOp3 #if already has 'x' ,go to stack and save the address
j W # can remove this later

StackOp3:
addiu $sp,$sp,-4 # create 4 bytes space in stack 
addi $s7,$s7,1 #using s7 as a counter
sw $t0,($sp) 
#j checkNewX
checkNewX3:
addi $t0,$t0,36 #more 4 spaces to right
lb $t1,($t0) #load byte from that address
beq $t1,$t9,StackOp3
beq $t1,$t6,updateBoard3
bge $t1,$t8,Restorestack3
beq $t1,$t5,Restorestack3
j checkNewX3

Restorestack3:

addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,W
j Restorestack3

updateBoard3:
lw $s6,($sp)
sb $t6,($s6)
addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,updateBoardkey3
j updateBoard3

updateBoardkey3: 
sb $t6,($s2) # put 'o' into the computed XY address

j W

W:
li $s7,0 #s7 be our counter

CheckW:
addi $t0,$s2,-4 #4 spaces to right of calculated address
#check r/l/up/down boundary later
lb $t1,($t0) #see what is already in that address
beq $t1,$t6,NW #if already has 'o', just move on...
beq $t1,$t5,NW #if already has ' ', just move on..
beq $t1,$t9,StackOp4 #if already has 'x' ,go to stack and save the address
#j SouthEast # can remove this later

StackOp4:
addiu $sp,$sp,-4 # create 4 bytes space in stack 
addi $s7,$s7,1 #using s7 as a counter
sw $t0,($sp) 
#j checkNewX
checkNewX4:
addi $t0,$t0,-4 #more 4 spaces to right
lb $t1,($t0) #load byte from that address
beq $t1,$t9,StackOp4
beq $t1,$t6,updateBoard4
bge $t1,$t8,Restorestack4
beq $t1,$t5,Restorestack4
j checkNewX4

Restorestack4:

addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,NW
j Restorestack4

updateBoard4:
lw $s6,($sp)
sb $t6,($s6)
addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,updateBoardkey4
j updateBoard4

updateBoardkey4: 
sb $t6,($s2) # put 'o' into the computed XY address

j NW




NW:

li $s7,0 #s7 be our counter

CheckNW:
addi $t0,$s2,-44 #4 spaces to right of calculated address
#check r/l/up/down boundary later
lb $t1,($t0) #see what is already in that address
beq $t1,$t6,N #if already has 'o', just move on...
beq $t1,$t5,N #if already has ' ', just move on..
beq $t1,$t9,StackOp5 #if already has 'x' ,go to stack and save the address
#j SouthEast # can remove this later

StackOp5:
addiu $sp,$sp,-4 # create 4 bytes space in stack 
addi $s7,$s7,1 #using s7 as a counter
sw $t0,($sp) 
#j checkNewX
checkNewX5:
addi $t0,$t0,-44 #more 4 spaces to right
lb $t1,($t0) #load byte from that address
beq $t1,$t9,StackOp5
beq $t1,$t6,updateBoard5
bge $t1,$t8,Restorestack5
beq $t1,$t5,Restorestack5
j checkNewX5

Restorestack5:
addi $sp,$sp,4
addi $s7,$s7,-1

beqz $s7,N
j Restorestack5

updateBoard5:
lw $s6,($sp)
sb $t6,($s6)
addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,updateBoardkey5
j updateBoard5

updateBoardkey5: 
sb $t6,($s2) # put 'o' into the computed XY address

j N


N:
li $s7,0 #s7 be our counter

CheckN:
addi $t0,$s2,-40 #4 spaces to right of calculated address
#check r/l/up/down boundary later
lb $t1,($t0) #see what is already in that address
beq $t1,$t6,NE #if already has 'o', just move on...
beq $t1,$t5,NE #if already has ' ', just move on..
beq $t1,$t9,StackOp6 #if already has 'x' ,go to stack and save the address
#j SouthEast # can remove this later

StackOp6:
addiu $sp,$sp,-4 # create 4 bytes space in stack 
addi $s7,$s7,1 #using s7 as a counter
sw $t0,($sp) 
#j checkNewX
checkNewX6:
addi $t0,$t0,-40 #more 4 spaces to right
lb $t1,($t0) #load byte from that address
beq $t1,$t9,StackOp6
beq $t1,$t6,updateBoard6
bge $t1,$t8,Restorestack6
beq $t1,$t5,Restorestack6
j checkNewX6

Restorestack6:
addi $sp,$sp,4
addi $s7,$s7,-1

beqz $s7,NE
j Restorestack6

updateBoard6:
lw $s6,($sp)
sb $t6,($s6)
addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,updateBoardkey6
j updateBoard6

updateBoardkey6: 
sb $t6,($s2) # put 'o' into the computed XY address

j NE


NE:
li $s7,0 #s7 be our counter

CheckNE:
addi $t0,$s2,-36 #4 spaces to right of calculated address
#check r/l/up/down boundary later
lb $t1,($t0) #see what is already in that address
beq $t1,$t6,finishNeighbors #if already has 'o', just move on...
beq $t1,$t5,finishNeighbors #if already has ' ', just move on..
beq $t1,$t9,StackOp7 #if already has 'x' ,go to stack and save the address
#j SouthEast # can remove this later

StackOp7:
addiu $sp,$sp,-4 # create 4 bytes space in stack 
addi $s7,$s7,1 #using s7 as a counter
sw $t0,($sp) 
#j checkNewX
checkNewX7:
addi $t0,$t0,-36 #more 4 spaces to right
lb $t1,($t0) #load byte from that address
beq $t1,$t9,StackOp7
beq $t1,$t6,updateBoard7
bge $t1,$t8,Restorestack7
beq $t1,$t5,Restorestack7
j checkNewX7

Restorestack7:
addi $sp,$sp,4
addi $s7,$s7,-1

beqz $s7,finishNeighbors
j Restorestack7

updateBoard7:
lw $s6,($sp)
sb $t6,($s6)
addi $sp,$sp,4
addi $s7,$s7,-1
beqz $s7,updateBoardkey7
j updateBoard7

updateBoardkey7: 
sb $t6,($s2) # put 'o' into the computed XY address

finishNeighbors:

jr $ra
#####################################################################PRINTING

SetPrint:
la $t7,vline1 # get address of vline1
la $t8,vline8 #get address of numline
addi $t8,$t8,40 #t8 is the lowermost boundary of table
 
printUpdatedBoard:
beq $t7,$t8,validinput #if address in t7==t8, stop printing and reprompt
lb $s3,($t7)#load the byte from starting address
li $v0,11 #print the byte
move $a0,$s3 
syscall
addi $t7,$t7,1#update the address in t7 to t7+1
j printUpdatedBoard



