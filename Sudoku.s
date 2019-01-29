	AREA	Sudoku, CODE, READONLY
	IMPORT sendchar
	PRESERVE8
	EXPORT	start

start

;	LDR R0, =gridOne	;
;	MOV R1, #2			; write tests for getSquare subroutine
;	MOV	R2, #8			;
;	BL	getSquare

;	LDR R0, =gridOne	;
;	MOV R1, #2			; write tests for setSquare subroutine
;	MOV R2,	#3			;
;	MOV R3,	#9			
;	BL	setSquare
	
;	LDR R0, =gridFive	;
;	MOV	R1, #0			; write tests for isValid subroutine
;	MOV	R2, #0			;
;	BL	isValid

;	LDR R0, =gridTwo	;
;	MOV R1, #8			; write tests for validInRow subroutine
;	MOV R2, #2			;
;	BL validInRow					

;	LDR R0, =gridThree	;
;	MOV	R1, #2			; write tests for validInColumn subroutine
;	MOV R2, #8			;
;	BL	validInColumn

;	LDR R0, =gridFour	;
;	MOV	R1, #1			; write tests for validInBox subroutine
;	MOV	R2, #4			;
;	BL	validInBox

;	LDR	R0, =gridOne
;	MOV	R1, #0
;	MOV	R2, #0
;	BL	sudoku

;	LDR	R0, =gridTwo	;
;	BL	printBoard		; write tests for printBoard subroutine

;	LDR R0, =cantSolve	;
;	BL	printString		; write tests for printString

	LDR R4, =gridOne	; load in sudoku grid
	LDR R0, =unsolved	; unsolvedStartAddr as parameter
	BL  printString		; printString(unsolvedStartAddr)
	MOV	R0, R4			; grid as parameter
	BL	printBoard		; printBoard(grid)
	LDR R0, =solved		; solvedStartAddr as parameter
	BL  printString		; printString(solvedStartAddr)
	MOV R0, R4			; grid as parameter
	MOV	R1, #0			; row = 0 as parameter
	MOV R2, #0			; column = 0 as parameter
	BL	sudoku			; solved = sudoku(grid, row, column)
	CMP	R0, #1			; if(solved = true)
	BNE	notSolved		; {
	MOV R0, R4			; 	grid as parameter
	BL	printBoard		; 	printBoard(grid)
	B	isSolved		; }
notSolved				; else {
	LDR R0, =cantSolve	;	cantSolveStartAddr as parameter
	BL	printString		;	printString(cantSolveStartAddr)
isSolved				; }

	
stop	B	stop



; getSquare subroutine
; Gets the value of a digit in the given row and column of an array
; Parameters
;	R0 Start address of array
;	R1 Row of digit (word sized)
;	R2 Column of digit (word sized)
; Return Value
;	R0 Digit at array[row][column] (byte sized)
getSquare
	STMFD	sp!, {R4, R5, R6, lr}	; save registers	
	MOV		R4, R0					; arrayStartAddr
	LDR		R6,=9					; rowSize=9
	MUL		R5, R1, R6				; index = row * rowSize
	ADD		R5, R5, R2				; index = index + column
	LDRB	R0, [R4, R5] 			; digit = array[row][column]
	LDMFD	sp!, {R4, R5, R6, pc}	; restore registers

; setSquare subroutine
; Sets the value of a digit in the given row and column of an array
; Parameters
;	R0 Start address of array 
;	R1 Row of digit (word sized)
;	R2 Column of digit (word sized)
;	R3 Value to set (byte sized)
setSquare
	STMFD	sp!, {R5, R6, lr}	; save registers
	LDR		R6,=9				; rowSize=9
	MUL		R5, R1, R6			; index = row * rowSize
	ADD		R5, R5, R2			; index = index + column
	STRB	R3, [R0, R5]		; array[row][column] = value
	LDMFD 	sp!, {R5, R6, pc}	; restore registers

; isValid subroutine
; Checks the validity of an element at a passed row index and
; column index based on the rules of Soduko
; Parameters
;	R0 Start address of grid array
;	R1 Row of element to check (word-sized)
;	R2 Column of element to check (word-sized)
; Return Value
;	R3 boolean stating whether the element is valid or not
;	(stores #1 for true, #0 for false)
isValid
	STMFD	sp!, {R4-R7, lr}; save registers
	MOV		R4, #0			; isValid = false
	MOV		R5, R0			; arrayStartAddr as local variable
	MOV		R6, R1			; row as local variable
	MOV		R7, R2			; column as local variable
	BL		validInRow		; validInRow(arrayStartAddr, row, column)
	CMP		R3, #1			; if(validInRow)
	BNE		notValid		; {
	MOV		R0, R5			;	arrayStartAddr as parameter
	MOV		R1, R6			;	row as parameter
	MOV		R2, R7			;	column as parameter
	BL		validInColumn	;	validInColumn(arrayStartAddr, row, column)
	CMP		R3, #1			;	if(validInColumn)
	BNE		notValid		;	{
	MOV		R0, R5			;		arrayStartAddr as parameter
	MOV		R1, R6			;		row as parameter
	MOV		R2, R7			;		column as parameter
	BL		validInBox		;		validInBox(arrayStartAddr, row, column)
	CMP		R3, #1			;		if(validInBox)
	BNE		notValid		;		{
	MOV		R4, #1			;			isValid = true
notValid					;		}}}
	MOV		R3, R4			; isValid as return value							
	LDMFD	sp!, {R4-R7, pc}; restore registers

; validInRow subroutine
; Checks if a bite-sized number at a passed word-sized row index
; and column index is valid in its own row
; Parameters
;	R0 Start address of array
;	R1 Row index of element to check
;	R2 Column index of element to check
; Return Value
;	R3 #1(true) if the number is valid, #0(false) if not
validInRow
	STMFD	sp!, {R4-R8, lr}	; save registers
	MOV 	R4, R0				; arrayStartAddress to local variable
	MOV		R5, R2				; column to local variable
	BL		getSquare			; elem = getSquare(arrayStartAddr, row, column)
	MOV		R6, R0				; elem to local variable
	LDR		R2, =0				; whileColumn = 0
	LDR		R3, =1				; validInRow=true
	LDR		R8, =9				; rowSize=9
whRow	
	CMP		R2, R8				; while(whileColumn<rowSize
	BHS		eWhRow				;	&&
	CMP		R3, #1				;	validInRow==true)
	BNE		eWhRow				;  {
	CMP		R5, R2				;	if(whileColumn!=column)
	BEQ		eIfRow				;	{
	MOV		R0, R4				;		arrayStartAddr as parameter
	BL		getSquare			;		otherElem = getSquare(arrayStartAddr, row, whileColumn)
	MOV		R7, R0				;		otherElem as local variable
	CMP		R7, R6				;		if(otherElem==elem)
	BNE		eIfRow2				;		{
	LDR		R3, =0				;			validInRow=false
eIfRow2							;		}	
eIfRow							;	}
	ADD		R2, R2, #1			;	whileColumn++
	B		whRow
eWhRow	
	LDMFD	sp!, {R4-R8, pc}	; restore registers
	
; validInColumn subroutine
; Checks if a bite-sized number at a passed word-sized row index
; and column index is valid in its own column
; Parameters
;	R0 Start address of array
;	R1 Row index of element to check
;	R2 Column index of element to check
; Return Value
;	R3 #1(true) if the number is valid, #0(false) if not
validInColumn
	STMFD	sp!, {R4-R8, lr}	; save registers
	MOV 	R4, R0				; arrayStartAddress to local variable
	MOV		R5, R1				; column to local variable
	BL		getSquare			; elem = getSquare(arrayStartAddr, row, column)
	MOV		R6, R0				; elem to local variable
	LDR		R1, =0				; whileColumn = 0
	LDR		R3, =1				; validInColumn=true
	LDR		R8, =9				; columnSize=9
whCol	
	CMP		R1, R8				; while(whileRow<columnSize
	BHS		eWhCol				;	&&
	CMP		R3, #1				;	validInColumn==true)
	BNE		eWhCol				;  {
	CMP		R5, R1				;	if(whileRow!=row)
	BEQ		eIfCol				;	{
	MOV		R0, R4				;		arrayStartAddr as parameter
	BL		getSquare			;		otherElem = getSquare(arrayStartAddr, row, whileColumn)
	MOV		R7, R0				;		otherElem as local variable
	CMP		R7, R6				;		if(otherElem==elem)
	BNE		eIfCol				;		{
	LDR		R3, =0				;			validInColumn=false
eIfCol2							;		}	
eIfCol							;	}
	ADD		R1, R1, #1			;	whileRow++
	B		whCol
eWhCol	
	LDMFD	sp!, {R4-R8, pc}	; restore registers
	
; validInBox subroutine
; Checks if a byte sized value at a passed row and column of a 2D array
; is valid in its 3x3 box according to the rules of Sudoku
; Parameter
;	R0 Start address of the array being accessed
;	R1 row
;	R2 column
; Return
;	R3 #1(True) if the number is valid, #0(False) if it is not
validInBox
	STMFD	sp!, {R4-R11, lr}	; save registers
	MOV		R4, R0				; arrayStartAddr as local variable
	MOV		R5, R1				; row as local variable
	MOV		R6, R2				; column as local variable
	LDR		R2, =3				; divior = 3
	BL		divide				; divide(row, divisor)
	MOV		R7, R2				; rowRemainder as local variable
	SUB		R7, R5, R7			; boxRow = row - rowRemainder
	MOV		R1, R6				; dividend = column
	LDR		R2, =3				; divisor = 3
	BL		divide				; divide(dividend, divisor)
	MOV		R8, R2				; columnRemainder as local variable
	SUB		R8, R6, R8			; boxColumn = column - columnRemainder
	MOV		R1, R5				; row as parameter
	MOV		R2, R6				; column as parameter
	BL		getSquare			; elem = getSquare(arrayStartAddr, row, column)
	MOV		R11, R0				; elem as local variable
	LDR 	R3, =1				; validInBox = true
	LDR		R9, =0				; rowCount = 0
boxWh1
	CMP		R3, #1				; while(validInBox==true
	BNE		eBoxWh1				;	&&
	CMP		R9, #3				;	rowCount<3)
	BHS		eBoxWh1				; {
	ADD		R1, R7, R9			;	rowIndex = boxRow+rowCount
	LDR		R10, =0				;	columnCount = 0
	MOV		R12, #0				;	sameIndex=false
boxWh2	
	CMP		R3, #1				;	while(validInBox==true
	BNE		eBoxWh2				;		&&
	CMP		R10, #3				;		columnCount<3)
	BHS		eBoxWh2				;	{
	MOV		R0, R4				; 		arrayStartAddr as parameter
	ADD		R2, R8, R10			;		columnIndex = boxColumn + columnCount
	CMP		R5, R1				;		if(row!=rowIndex						
	BEQ		skipCheck			;			&&
	CMP		R6, R2				;			column!=columnIndex)				
	BEQ		skipCheck			;		{	
	BL		getSquare			;			newElem = getSquare(arrayStartAddr, rowIndex, columnIndex)
	CMP		R0,	R11				;			if(elem==newElem)
	BNE		eBoxIf				;			{
	LDR		R3, =0				;				validInBox=false
eBoxIf							;			}
skipCheck						;		}
	LDR		R12, =0				;		sameIndex=false
	ADD		R10, R10, #1		;		columnCount++
	B		boxWh2				;	}
eBoxWh2
	ADD		R9, R9, #1			; rowCount++
	B		boxWh1				; }
eBoxWh1	
	LDMFD	sp!, {R4-R11, pc}	; restore registers
	
; divide subroutine
; Divides a dividend by a divisor, returning a quotient and remainder
; Parameters
;	R1 dividend
;	R2 divisor
; Return Values
;	R1 quotient
;	R2 remainder
divide
	STMFD	sp!, {R4-R5, lr}
	MOV		R4, R1				; dividend/remainder
	MOV		R5, R2				; divisor
	LDR		R1, =0				; quotient = 0
whDiv	
	CMP		R4, R5				; while(remainder>=divisor)
	BLO		eWhDiv				; {
	ADD		R1, R1, #1			;	quotient++
	SUB		R4, R4, R5			;	remainder-=divisor
	B		whDiv				; }
eWhDiv	
	MOV		R2, R4				; remainder to return value
	LDMFD	sp!, {R4-R5, pc}

; sudoku subroutine
; Uses recursion and a "brute force" method to solve a Sudoku grid.
; Will iterate through the digits in the current blank square and if the
; digit is valid, move on to the next square. Backtracks when it realises
; that a mistake has been made.
; Parameters
; 	R0 Start address of 2D array/sudoku grid
; 	R1 Row of element to set number in
; 	R2 Column of element to set number in
; Return Value
;	R0 Whether the current square has been 'solved' or not
sudoku
	STMFD	sp!, {R4-R10, lr}	; save registers
	MOV		R4, R0				; arrayStartAddr to local variable
	MOV		R5, R1				; row to local variable
	MOV		R6, R2				; column to local variable
	LDR		R7, =0				; result = false
	ADD		R8, R6, #1			; nextColumn = column + 1
	MOV		R9, R5				; nextRow = row
	CMP		R8, #8				; if(nextColumn>8)
	BLS		endIf1				; {
	LDR		R8, =0				;	nextColumn=0
	ADD		R9, R9, #1			;	nextRow++
endIf1							; }	
	BL		getSquare			; getSquare(arrayStartAddr, row, column)
	CMP		R0, #0				; if(getSquare!=0)
	BEQ		else1				; {
	CMP		R5, #8				;	if(row==8
	BNE		else2				;		&&
	CMP		R6, #8				;		column==8)
	BNE		else2				;	{
	MOV		R0, #1				;		result = true
	LDMFD	sp!, {R4-R10, pc}	;		return result
								;	}
else2							;	else{
	MOV		R0, R4				;		arrayStartAddr as parameter
	MOV		R1, R9				;		nextRow as parameter
	MOV		R2, R8				;		nextColumn as parameter
	BL		sudoku				;		result = sudoku(arrayStartAddr, nextRow, nextColumn)
	MOV		R7, R0				;		result to local variable
								;	}
	B		endElse2			; }				
else1							; else{
	LDR		R10, =1				;		
for	CMP		R10, #9				;	for(try=1; try<=9
	BHI		endFor				;		&&
	CMP		R7,	#0				;		result==false; try++)
	BNE		endFor				;	{
	MOV		R0, R4				;		arrayStartAddr as parameter
	MOV		R1, R5				;		row as parameter
	MOV		R2, R6				;		column as parameter
	MOV		R3, R10				;		try as parameter
	BL		setSquare			;		setSquare(arrayStartAddr, row, column, try)
	BL		isValid				;		isValid(grid, row, column)
	CMP		R3, #1				;		if(isValid)
	BNE		endIf2				;		{
	CMP		R5, #8				;			if(row==8
	BNE		else3				;				&&
	CMP		R6, #8				;				column==8)
	BNE		else3				;			{
	LDR		R7, =1				;				result=true
	B		endElse3			;			}
else3							;			else{
	MOV		R0, R4				;				arrayStartAddr as parameter
	MOV		R1, R9				;				nextRow as parameter
	MOV		R2, R8				;				nextColumn as parameter
	BL		sudoku				;				result = sudoku(arrayStartAddr, row, column)
	MOV		R7, R0				;				result as local variable
endElse3						;			}
endIf2							;		}
	ADD		R10, R10, #1		;		
	B		for					;	}
endFor	
	CMP		R7, #0				;	if(result==false)
	BNE		endIf3				;	{
	MOV		R0, R4				;		arrayStartAddr as parameter
	MOV		R1, R5				;		row as parameter
	MOV		R2, R6				;		column as parameter
	LDR		R3, =0				;		try = 0 (parameter)
	BL		setSquare			;		setSquare(arrayStartAddr, row, column, try)
endIf3							;	}
endElse2						; }
	MOV		R0, R7				; result as return value
	LDMFD	sp!, {R4-R10, pc}	; restore registers
	
	
; printBoard subroutine
; Prints a Sudoku board stored in a 2D array
; Parameters
; R0 Start address of array
printBoard
	STMFD 	sp!, {R4-R8, lr}	; load registers
	MOV		R4, R0				; arrayStartAddr
	LDR		R5,=9				; dimensionSize = 9
	LDR		R6,=0				 
printFor1							
	CMP		R6, R5				; for(row=0; row<dimensionSize; row++)
	BHS		ePrintFor1			; {						
	LDR		R7,=0				
printFor2	
	CMP		R7, R5				;	for(column=0; column<dimensionSize; column++)
	BHS		ePrintFor2			;	{
	MOV		R0, R4				;		arrayStartAddr as parameter
	MOV		R1, R6				;		row as parameter
	MOV		R2, R7				;		column as parameter
	BL		getSquare			;		elem = getSquare(arrayStartAddr, row, column)
	ADD		R0, R0, #0x30		;		elem to ASCII character
	BL		sendchar			;		print(elem)
	CMP		R7, #8				;		if(column<8)
	BHS		ePrintIf			;		{
	MOV		R0, #'|'				
	BL		sendchar			;			print('|')
ePrintIf						;		}		
	ADD		R7, R7, #1			;	}
	B		printFor2
ePrintFor2
	CMP		R6, #8				;	if(row<8)
	BHS		ePrintIf1			;	{
	MOV		R0, #0xA			
	BL		sendchar			; 		print(newLine)
	MOV		R0, #'-'			
	MOV		R8, #0	
printFor3	
	CMP		R8, #17				;		for(i=0; i<17; i++)
	BHS		ePrintFor3			;		{
	BL		sendchar			;			print('-')
	ADD		R8, R8, #1			;		}
	B		printFor3
ePrintFor3	
	MOV		R0, #0xA			
	BL		sendchar			;		print(newLine)
ePrintIf1						;	}	
	ADD		R6, R6, #1			; }
	B		printFor1			;
ePrintFor1	
	MOV		R0, #0xA			
	BL		sendchar			; print(newLine)
	LDMFD	sp!, {R4-R8, pc}	; restore registers
	
	
; printString subroutine
; Prints a null terminated string stored in memory
; Parameters
;	R0 Start address of string
printString
	STMFD	sp!, {R4, R5, lr}	; load registers
	MOV	 	R4, R0				; arrayStartAddr as parameter
	MOV		R0, #0xA			
	BL		sendchar			; print(newLine)
	LDR	 	R5, =0				; counter=0
stringWh
	LDRB 	R0, [R4, R5]		; 
	CMP	 	R0, #0				; while(array[counter]!0)
	BEQ	 	eStringWh			; {
	BL	 	sendchar			;  print(array[counter]
	ADD		R5, R5, #1			;  counter++
	B	 	stringWh			; }
eStringWh						
	MOV		R0, #0xA			
	BL		sendchar			; print(newLine)
	LDMFD	sp!, {R4, R5, pc}	; restore registers
	
	AREA	Grids, DATA, READWRITE

gridOne
		DCB	7,9,0,0,0,0,3,0,0
    	DCB	0,0,0,0,0,6,9,0,0
    	DCB	8,0,0,0,3,0,0,7,6
    	DCB	0,0,0,0,0,5,0,0,2
    	DCB	0,0,5,4,1,8,7,0,0
    	DCB	4,0,0,7,0,0,0,0,0
    	DCB	6,1,0,0,9,0,0,0,8
    	DCB	0,0,2,3,0,0,0,0,0
    	DCB	0,0,9,0,0,0,0,5,4

gridTwo
		DCB 0,1,2,3,4,5,6,7,8	;
		DCB	9,8,7,6,5,4,3,2,1	; to test validInRow subroutine
		DCB	1,4,5,8,6,5,3,2,0	;
		DCB 3,3,3,3,3,3,3,3,3	
		DCB	7,1,2,3,4,5,6,8,7
		DCB 0,0,0,0,1,0,0,0,0
		DCB	0,0,0,1,0,0,0,1,0
		DCB	9,9,9,1,9,9,9,9,9
		DCB 9,9,1,9,9,1,9,9,9
		
gridThree
		DCB 0,9,1,3,7,0,0,9,9	; to test validInColumn subroutine
		DCB 1,8,4,3,1,0,0,9,9
		DCB 2,7,5,3,2,0,0,9,1
		DCB 3,6,8,3,3,0,1,1,9
		DCB 4,5,6,3,4,1,0,9,9
		DCB 5,4,5,3,5,0,0,9,1
		DCB 6,3,3,3,6,0,0,9,9
		DCB 7,2,2,3,8,0,1,9,9
		DCB 8,1,0,3,7,0,0,9,9
		
gridFour
		DCB 1,2,3, 2,7,3, 2,2,1	; to test validInBox subroutine
		DCB 4,1,5, 4,7,7, 9,2,3
		DCB 6,7,8, 5,6,7, 8,4,6
		
		DCB 2,4,3, 0,0,0, 1,2,3
		DCB 3,6,8, 0,7,0, 4,0,5
		DCB 1,2,9, 0,0,0, 6,7,8
		
		DCB 4,6,8, 1,2,3, 6,7,8 
		DCB 3,5,2, 4,2,5, 1,2,3
		DCB 1,3,4, 2,2,2, 4,5,6
		
gridFive
		DCB 0,1,2, 3,4,5, 6,7,8	; to test isValid subroutine
		DCB 8,3,4, 7,6,2, 2,9,6
		DCB 7,5,6, 1,4,9, 9,3,1
		
		DCB 6,3,1, 1,2,3, 0,8,9
		DCB 5,5,9, 4,5,6, 7,2,4
		DCB 4,2,8, 7,8,9, 1,3,6
		
		DCB 3,4,5, 6,7,8, 9,2,1
		DCB 2,0,3, 3,2,6, 8,9,4
		DCB 1,5,7, 2,1,1, 1,0,3
		
gridSix
		DCB 7,0,0,0,0,6,0,0,0
		DCB 4,5,0,0,0,0,2,0,0
		DCB 0,8,0,4,0,0,0,0,7
		DCB 0,2,0,6,1,7,0,0,4
		DCB 0,0,0,0,0,0,0,0,0
		DCB 9,0,0,5,2,4,0,6,0
		DCB 3,0,0,0,0,5,0,9,0
		DCB 0,0,8,0,0,0,0,1,2
		DCB 0,0,0,9,0,0,0,0,5
		
gridSeven
		DCB 1,2,0,4,5,6,7,8,9
		DCB 0,0,3,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		DCB 0,0,0,0,0,0,0,0,0
		
	AREA strings, DATA, READONLY

unsolved
	DCB "Original grid:", 0
	
solved
	DCB "Solved grid (this may take a few seconds):", 0

cantSolve
	DCB	"This grid cannot be solved.", 0
	
	END
