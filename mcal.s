#
#	Name:		Beauchamp, Joshua
#	Project:		2
#	Due:		03/18/2024
#	Course:		cs-2640-02-sp24
#
#	Description:
#		The objective of the project is to print out the Gregorian calendar of any
#		month given that the user inputs the numerical values of the month and the
#		year of the monthly calendar that they wish to print out. Using formulas
#		to calculate the first day of the given month, the program proceeds to
#		display the assigned number of each day in their appropriate location on the 
#		calendar. It takes leap years into account when calulating the amount of total
#		days in the chosen month.


	.data
# Headers and prompts
title:		.asciiz	"Mini Calendar by J. Beauchamp"
monthInput:	.asciiz	"Enter the month? "
yearInput:	.asciiz	"Enter the year? "
week:		.asciiz	"Sun Mon Tue Wed Thu Fri Sat"	

# Months of the year
jan:		.asciiz	"January "
feb:		.asciiz	"February "
mar:		.asciiz	"March "
apr:		.asciiz	"April "
may:		.asciiz	"May "
june:		.asciiz	"June "
july:		.asciiz	"July "
aug:		.asciiz	"August "
sep:		.asciiz	"September "
oct:		.asciiz	"October "
nov:		.asciiz	"November "
dec:		.asciiz	"December "

# Spaces for calendar
oneSpace:		.asciiz	" "
twoSpace:		.asciiz	"  "
noDay:		.asciiz	"    "
# Array of months
monNames:		.word	jan, feb, mar, apr, may, june, july, aug, sep, oct, nov, dec



	.text
main:	la	$a0, title
	li	$v0, 4
	syscall
	li	$a0, '\n'
	li	$v0, 11
	syscall
	syscall

	# Prompts the user to input a number for the month
	la	$a0, monthInput	
	li	$v0, 4
	syscall
	li	$v0, 5		# Takes the number of month and places it into t0
	syscall			# $t0 = month
	move	$t0, $v0
	move	$t4, $t0		# Copies month value for calculation of days in the month

	# Prompts the user to input a number for the year
	la	$a0, yearInput	
	li	$v0, 4
	syscall
	li	$v0, 5		# Takes the number of year and places it into t1
	syscall			# $t1 = year
	move	$t1, $v0

	li	$a0, '\n'
	li	$v0, 11
	syscall

	# Outputs the calendar header of the month and the year
	move	$t3, $t0	
	sub	$t3, $t3, 1
	sll	$t3, $t3, 2	# Calculates the offset
	la	$a0, monNames	# Gets the base address
	addu	$a0, $a0, $t3	# Adds the offset and base address
	lw	$a0, ($a0)	# Returns the effective address of the month
	li	$v0, 4		# Outputs the month
	syscall

	move	$a0, $t1		# Outputs the year
	li	$v0, 1
	syscall

	li	$a0, '\n'
	li	$v0, 11
	syscall

	# Calculates whether the month has 30 days or 31 days depending on which month it is
	bne	$t4, 1, endJan
	li	$t4, 31
endJan:
	bne	$t4, 3, endMar
	li	$t4, 31
endMar:
	bne	$t4, 4, endApr
	li	$t4, 30
endApr:
	bne	$t4, 5, endMay
	li	$t4, 31
endMay:
	bne	$t4, 6, endJune
	li	$t4, 30
endJune:
	bne	$t4, 7, endJul
	li	$t4, 31
endJul:
	bne	$t4, 8, endAug
	li	$t4, 31
endAug:
	bne	$t4, 9, endSep
	li	$t4, 30
endSep:
	bne	$t4, 10, endOct
	li	$t4, 31
endOct:
	bne	$t4, 11, endNov
	li	$t4, 30
endNov:
	bne	$t4, 12, endDec
	li	$t4, 31
endDec:	

	# Checks if february has an extra day for leap year
	# Is a leap year if divisible by 4 and not by 100
	# Is a leap year if divisible by 400
	bne	$t4, 2, endFeb
	li	$t4, 28
	rem	$t5, $t1, 4
	rem	$t6, $t1, 100
	bnez	$t5, firstCase	# Checks if divisible by 4 to move onto second case
	beqz	$t6, firstCase	# Checks if divisible by 100 as well as 4
	li	$t4, 29
firstCase:
	rem	$t5, $t1, 400	# Checks if divisible by 400
	bne	$t5, 0, endFeb
	li	$t4, 29
endFeb:

	move	$t6, $t4		# Stores the total days of the month in a register for later use

	# Caluclates "a"
	li	$t3, 14
	sub	$t2, $t3, $t0
	div	$t2, $t2, 12
	mflo	$t2		# $t2 = a

	# Calculates "y"
	sub	$t3, $t1, $t2	# $t3 = y

	# Calculates "m"
	mul	$t4, $t2, 12
	add	$t4, $t4, $t0
	sub	$t4, 2		# $t4 = m

	# Calculates "d"
	addi	$t5, $t3, 1
	div	$t0, $t3, 4
	add	$t5, $t5, $t0
	div	$t0, $t3, 100
	sub	$t5, $t5, $t0
	div	$t0, $t3, 400
	add	$t5, $t5, $t0
	mul	$t1, $t4, 31
	div	$t1, $t1, 12
	add	$t5, $t5, $t1
	rem	$t5, $t5, 7	# $t5 = d

	# Prints out the calendar by printing out the numerical values of the
	# days in their appropriate spot on a calendar. At the end of each week,
	# a newline character is outputted and a new week starts being displayed
	la	$a0, week		# Outputs the header for the calendar week days
	li	$v0, 4
	syscall
	li	$a0, '\n'
	li	$v0, 11
	syscall

	# noDayFor loops the total amount of spaces on the calendar that no days fall
	# on, all while updating the counter
	li	$t0, 1		# Keeps track of the loop counter
	li	$t1, 0		# Keeps track of the amount of day spots passed, is used to print newline at end of each week
noDayFor:	bgt	$t0, $t5, endNoDayFor	# Loop for total number of no days
	la	$a0, noDay	# Outputs 4 whitespace characters for empty days
	li	$v0, 4
	syscall
	addi	$t1, $t1, 1
	addi	$t0, $t0, 1
	b noDayFor
endNoDayFor:

	# t0 is now the value that is outputteed for the day number, so it is reset to 1.
	li	$t0, 1

	# monthFor is a for loop that loops from 1, representing the first day, to
	# the total amount of days in the month, which was stored in $t6 earlier.
	# There are two separate inner loops for single digit and double digit
	# numbers since they require two different amounts of whitespace
	# character spacing
monthFor:	bgt	$t0, $t6, endMonthFor	# Calendar loop for entire month

	# First inner loop which is used for single digit numbers, and prints the
	# appropriate amount of spaces between each single digit
	bgt	$t0, 9, endSingleDigit	# Checks if the current day is single digit
	la	$a0, twoSpace
	li	$v0, 4
	syscall
	move	$a0, $t0			# Outputs current day number
	li	$v0, 1
	syscall

	# Run a check that checks if current do is Saturday. If it is saturday,
	# it outputs a single whitespace since formats the calendar as it is
	# intended to be formatted
	rem	$t2, $t1, 7		# Gets the week day value to check if it is Saturday
	beq	$t2, 6, endSingleSatCheck
	beq	$t0, $t6, endMonthFor
	la	$a0, oneSpace		# Prints one whitespace after each day 
	li	$v0, 4
	syscall
endSingleSatCheck:
endSingleDigit:
	# End of First Loop

	# Second inner loop which is used for double digit numbers, and prints the 
	# appropriate amount of spaces between each single digit
	rem	$t2, $t1, 7		# Gets the week day value to check if it is Saturday
	blt	$t0, 10, endDoubleDigit	# Checks if the current day is double digit
	bnez	$t0, endNonSunday		# Prints two whitespaces in front of non-Sunday days
	la	$a0, twoSpace
	li	$v0, 4
	syscall
	move	$a0, $t0			# Outputs current day number
	li	$v0, 1
	syscall
endNonSunday:

	beqz	$t0, endSunday	# Prints one whitespace in front of number for Sundays
	la	$a0, oneSpace
	li	$v0, 4
	syscall
	move	$a0, $t0			# Outputs current day number
	li	$v0, 1
	syscall
endSunday:

	# Runs a check that checks if current do is Saturday for proper format.
	# If saturday, do not print whitespace as to only have newline
	# character following the values of Saturday
	beq	$t2, 6, endDoubleSatCheck
	beq	$t0, $t6, endMonthFor
	la	$a0, oneSpace		# Prints one whitespace after each day 
	li	$v0, 4
	syscall
endDoubleSatCheck:
endDoubleDigit:
	# End of Second Loop

	addi	$t0, $t0, 1		# Increments current day
	addi	$t1, $t1, 1		# Increments day counter
	rem	$t2, $t1, 7		# Stores the week day value of the current day

	# Checks if the current day is last day of the week as to print a newline
	# character to start next row of the calendar
	bnez	$t2, endNewWeek
	li	$a0, '\n'
	li	$v0, 11
	syscall
endNewWeek:
	# End of last day check

	b	monthFor			# Loops back to beginning of month loop
endMonthFor:
	# End of calendar loop for entire month

	# Prints new line before ending program
	li	$a0, '\n'
	li	$v0, 11
	syscall

	# Exits program
	li	$v0, 10
	syscall
