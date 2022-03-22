##########################################################################
# Created by: Acosta, Matt
# 20 August 2021
# Description: This program uses the mars bitmap to draw horizontal and vertical lines, along with being able to color the background. All while using functions and macros to do it.
#
# Notes: This program is intended to be run from the MARS IDE.
##########################################################################

######################################################
# Macros made for you (you will need to use these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	# YOUR CODE HERE
	push(%input)
	andi %x %input 0x00FF0000
	srl %x %input 16
	andi %y %input 0x000000FF
	pop(%input)
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	# YOUR CODE HERE
	push(%x)
	push(%y)
	sllv %x %x 16
	add %output %x %y
	pop(%y)
	pop(%x)
.end_macro 

# Macro that converts pixel coordinate to address
# 	  output = origin + 4 * (x + 128 * y)
# 	where origin = 0xFFFF0000 is the memory address
# 	corresponding to the point (0, 0), i.e. the memory
# 	address storing the color of the the top left pixel.
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y)
	# YOUR CODE HERE
	push(%y)
	push(%x)
	sll %output %y 7
	add %output %x %output
	sll %output %output 2
	add %output %output 0xFFFF0000
	pop(%x)
	pop(%y)
.end_macro


.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
clear_bitmap: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
 	push($t0)
 	push($t1)
 	
 	movf $t7 $a0
 	
 	li $t0 0xFFFF0000
 	li $t1 65536
 	
 	goHere:
 	nop
 	sw $a0 ($t0)
 	add $t0 $t0 4
 	sub $t1 $t1 4
 	bgtz $t1 goHere
 	
 	pop($t1)
 	pop($t0)
 	jr $ra

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
draw_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	
	getCoordinates($a0 $t1 $t2)
	sll $t3 $t2 7
	add $t3 $t3 $t1
	li $t1 0xFFFF0000
	sll $t3 $t3 2
	add $t1 $t1 $t3
	sw $a1 ($t1)
	
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	
	getCoordinates($a0 $t0 $t1)
	sll $t3 $t1 7
	add $t3 $t3 $t0
	li $t0 0xFFFF0000
	sll $t3 $t3 2
	add $t0 $t0 $t3
	lw $v0 ($t0)
	
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_horizontal_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
        push($t0)
        push($t1)
     
        li $t0 0xFFFF0000
     	sll $a0 $a0 9
     	add $t0 $t0 $a0
     	li $t1 512
     
     	loop:
     	nop
     	sw $a1 ($t0)
     	add $t0 $t0 4
     	sub $t1 $t1 4
     	bgtz $t1 loop
     
     	pop($t1)
     	pop($t0)
     	jr $ra

#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_vertical_line: nop
	# YOUR CODE HERE, only use t registers (and a, v where appropriate)
     	push($t0)
     	push($t1)
     
     	li $t0 0xFFFF0000
     	mul $a0 $a0 4
     	add $t0 $t0 $a0
     	li $t1 512
     
     	helper:
     	nop
     	sw $a1 ($t0)
     	add $t0 $t0 512
     	sub $t1 $t1 4
     	bgtz $t1 helper
     
     	pop($t1)
     	pop($t0)
 	jr $ra

#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
draw_crosshair: nop
	push($ra)
	# HINT: Store the pixel color at $a0 before drawing the horizontal and 
	# vertical lines, then afterwards, restore the color of the pixel at $a0 to 
	# give the appearance of the center being transparent.
	
	# Note: Remember to use push and pop in this function to save your t-registers
	# before calling any of the above subroutines.  Otherwise your t-registers 
	# may be overwritten.  
	
	# YOUR CODE HERE, only use t0-t7 registers (and a, v where appropriate)
	push($a0)
	
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	
	getCoordinates($a0 $t2 $t3)
     	li $t0 0xFFFF0000
     	sll $t3 $t3 9
     	add $t0 $t0 $t3
     	li $t1 512
     
     	loopAgain1:
     	nop
     	sw $a1 ($t0)
     	add $t0 $t0 4
     	sub $t1 $t1 4
     	bgtz $t1 loopAgain1
	
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	
	getCoordinates($a0 $t2 $t3)
     	li $t0 0xFFFF0000 
     	sll $t2 $t2 2
     	add $t0 $t0 $t2
     	li $t1 512
     
     	loopAgain2:
     	nop
     	sw $a1 ($t0)
     	add $t0 $t0 512
     	sub $t1 $t1 4
     	bgtz $t1 loopAgain2
	
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	
	pop($a0)
	
	push($t0)
	push($t1)
	push($t2)
	push($t3)
	push($t4)
	
	getCoordinates($a0 $t2 $t3)
	getPixelAddress($t4 $t2 $t3)
	
	sw $t7 ($t4)
	
	pop($t4)
	pop($t3)
	pop($t2)
	pop($t1)
	pop($t0)
	
	pop($ra)
	# HINT: at this point, $ra has changed (and you're likely stuck in an infinite loop). 
	# Add a pop before the below jump return (and push somewhere above) to fix this.
	jr $ra
