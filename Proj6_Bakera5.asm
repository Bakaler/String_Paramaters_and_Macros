TITLE String Parameters and Macros     (Proj6_Bakaler5.asm)

; Author: Alexander Baker
; Last Modified: 6/ 2/ 2021
; OSU email address: Bakera5@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:  6               Due Date: 6/ 6/ 2021
; Description:  Runs a program (in main) which calls on the ReadVal and WriteVal procedures to:
 ;		1 - Get 10 valid integers from the user. (signed integers that fit within a 32 bit register)
 ;		2 - Stores these numeric values in an array.
 ;		3 - Display the integers, their sum, and their average.
 ; Program utilizes macros, procedures, and the stack frame

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
;  Prompts a user to input an integer string between -2^31 and 2^31-1
;  Checks string for validity in regards to byte length. 
;  If string is valid, stores string in memeory 
;  If invalud, displays error and prompts user to input an integer
;
; Preconditions: none
;
; Receives:
;  registers:
;    DL						= Sign Val from ReadVal; 2 means integer was invalid and to repromt user	; 0 negative, 1positive, 2 invalid
;
;  prompt_for_input_1		= Instruction prompt
;  userInputAddress_String	= Memory location used to store string 
;  sizeof_count				= Maxlength for string
;  errorPrompt				= Error prompt
;  prompt_for_input_2		= Reinstruction prompt
;  userInputAddress_Integer	= Memory location used to store integer
;
; returns: 
;  byte_count = Number of bytes entered by user
;  userInputAddress_String = Memory location holding entered string
; ---------------------------------------------------------------------------------
mGetString				MACRO		prompt_for_input_1, userInputAddress_String, sizeof_count, errorPrompt, prompt_for_input_2, byte_count, userInputAddress_Integer
  LOCAL		_redo					
  LOCAL		_checkFirst
  LOCAL		_return
  LOCAL		_start
  LOCAL     _intreturn

  ; Integer was deemed invalid in ReadVal, display error and repromt user
  CMP		DL, 2								; DL = 2		==		invalid integer from ReadVal
  JE		_redo

  ; Displays instructions and prompts user
 _start:
  MOV		EDX, prompt_for_input_1
  CALL		WriteString

  ; Set up and call for user inputted string
  MOV		EDX, userInputAddress_String			; Address of userInput (buffer)
  MOV		ECX, sizeof_count						; Buffer size
  CALL		ReadString
  
  ; Checks for a 0 character input
  CMP		EAX, 0	
  JE		_redo									; reprompts user

  ; Checks for a string that exceeds 10 len limit
  CMP		EAX, 11				
  JE		_checkFirst								; checks for inputted sign

  ; Checks for appropritate length (1-10)
  CMP		EAX, 11
  JB		_return									; valid string, jump over checks

  ; Invalid string length, reprompts use
  _redo:
  MOV		EDX, errorPrompt
  CALL		WriteString
  MOV		EDX, prompt_for_input_2
  CALL		WriteString
  JMP		_start

 _checkFirst:
  CLD
  MOV		ECX, byte_count
  MOV		ESI, userInputAddress_String
  MOV		EDI, userInputAddress_Integer

  ; Checks for a + or - infront of the string
  PUSH		EAX										; Stores EAX value
  LODSB
  CMP		AL, 45									; checks '-'
  JE		_intreturn
  CMP		AL, 43									; checks '+'
  JE		_intreturn
  CMP		AL, 48									;  checks '0'
  JE		_intreturn
  
  ; Else statement, invalid length or character
  MOV		EDX, errorPrompt						
  CALL		WriteString
  MOV		EDX, prompt_for_input_2
  CALL		WriteString
  POP		EAX
  JMP		_start									; Reprompts user

  ; Valid string (in terms of length)
  ; Makes sure to restore EAX register
 _intreturn:
   POP		EAX

  ; Valid string (in terms of length)
  ; Moves 1 to EDX 
 _return:
  
  MOV		EDX, 1

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Takes in a String address and prints the string
;
; Preconditions: 
;  none
;
; Receives:
;  stringAddress = Memory location of a String array
;
; returns:
;  None
; ---------------------------------------------------------------------------------

mDisplayString			MACRO		stringAddress
  PUSH		EDX							; Stores EDX
  MOV		EDX, stringAddress
  CALL		WriteString
  POP		EDX							; Restores EDX
ENDM
;Yup..

MAXLENGTH = 13						; Max input size is 13 bytes for a string (as the max integer input is   -4294967296 through 4294967295) 
									; Max length is 11, I have 13 to include a sign and null terminator

.data

; Strings, Displays, Prompts
programName				BYTE		"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures",13,10,0
programerName			BYTE		"Programmed by: Alexander Burnes-Baker:",13,10,0

programDescription_1	BYTE		"You will be asked to provide 10 signed decimal integers.",13,10,0
programDescription_2	BYTE		"Each number needs to be small enough to fit within a 32 bit register. After you have finished inputting the numbers ", 13, 10
						BYTE		"I will display a list of the integers, their sum, and their average value. Note, you may pad with zeroes but there ",13,10
						BYTE		"is a character limit! If you are liberal with padding zeroes, your integer may have to many charcters to assess.",13,10,0 

promptUserInput_1		BYTE		"Enter a signed number: ",0
promptUserInput_2		BYTE		"Try again and ",0
errorMessage			BYTE		"ERROR: Your input is not a signed integer, too large, or too long.",13,10,0

displayNumberMessage	BYTE		"You have entered the following numbers:",13,10,0
displaySumMessage		BYTE		"The sum of your numbers is: ",0
displayRoundedMessage	BYTE		"The rounded average is: ", 0

goodBye					BYTE		"Be excellent, be kind, and farewell!",13,10,0

; Numerical Data

integerArray			SDWORD		10	DUP(?)					; Integers created
size_integerArray		DWORD		LENGTHOF integerArray
integerArray_index		DWORD		0
byteCount				DWORD		?							; Byte count of string
userInteger				SDWORD		0							; Temp variable used to assess an integer
sum						SDWORD		?							; The total sum of all string
average					SDWORD		?							; The average of all string

; String Data
userInput				BYTE		MAXLENGTH DUP(?)			; String
size_userInput			DWORD		SIZEOF userInput

reversedString			BYTE		16 DUP(?)
commaSpaceNull			BYTE		", ",0

.code
main PROC														; This is where it gets fun

  ; Sets up and calls the introduction
  PUSH		OFFSET programName
  PUSH		OFFSET programerName
  PUSH		OFFSET programDescription_1
  PUSH		OFFSET programDescription_2
  CALL		introduction

  ; Sets the loop for gathering 10 integers
  MOV		ECX, 10

  ; External Loop to gather strings, translate them to integers, and store them in an array.
  _userInput_10:
    PUSH		ECX										; Saves Loop counter
    PUSH		integerArray_index
    PUSH		OFFSET integerArray_index
    PUSH		OFFSET integerArray
    PUSH		userInteger
    PUSH		OFFSET userInteger
    PUSH		OFFSET byteCount
    PUSH		OFFSET promptUserInput_2
    PUSH		OFFSET errorMessage
    PUSH		size_userInput
    PUSH		OFFSET userInput
    PUSH		OFFSET promptUserInput_1				; Wow that is a lot of pushing... 
    CALL		ReadVal

    POP		ECX											; Loads Loop counter
    ADD		integerArray_index, 4						; Sets up next location for array
   LOOP		_userInput_10

  ; Finds the sum and average integer value
  PUSH		OFFSET average
  PUSH		OFFSET size_integerArray
  PUSH		OFFSET sum
  PUSH		OFFSET integerArray
  CALL		Arithmetic

  ; Sets up and calls to display all of the integers values in the form of a string
  PUSH		OFFSET commaSpaceNull
  PUSH		OFFSET reversedString
  PUSH		OFFSET userInput
  PUSH		OFFSET userInteger
  PUSH		OFFSET integerArray
  PUSH		OFFSET displayNumberMessage
  CALL		EnteredNumbers

  ; Sets up and calls to display the sum of the integers as a string
  PUSH		OFFSET sum
  PUSH		OFFSET displaySumMessage
  PUSH		OFFSET userInteger
  PUSH		OFFSET reversedString
  PUSH		OFFSET userInput
  CALL		SumNumbers

  ; Sets up and calls to display the average of the integers as a string
  PUSH		OFFSET average
  PUSH		OFFSET displayRoundedMessage
  PUSH		OFFSET userInteger
  PUSH		OFFSET reversedString
  PUSH		OFFSET userInput
  CALL		AverageNumbers

  PUSH		OFFSET goodBye
  CALL		Farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: introduction
; 
; Utilizes the mDisplayString macro to call and print 4 strings
; Introduces the program, user, and desription 
;
; Preconditions: none
;
; Postconditions: none
;
; Receives:   
;  [EBP + 20]		OFFSET programName
;  [EBP + 16]		OFFSET programerName
;  [EBP + 12]		OFFSET programDescription_1
;  [EBP = 8]		OFFSET programDescription_2
;
; Returns: String display to the console
; ---------------------------------------------------------------------------------
introduction PROC
  PUSH				EBP
  MOV				EBP, ESP

  mDisplayString	[EBP+20]			; programName
  
  mDisplayString	[EBP+16]			; programerName
  CALL				CrLf

  mDisplayString	[EBP+12]			; programDescription_1

  mDisplayString	[EBP+8]				; programDescription_2
  CALL				CrLf
  CALL				CrLf

  POP				EBP
  RET				16

introduction ENDP

; ---------------------------------------------------------------------------------
; Name: readVal
; 
; Transforms and validates a string integer
; If valid, stores the integer in an array
; Calls on the mGetString macro ro receive a string in a memory location 
;
; Preconditions: none
;
; Postconditions: 
;   userInteger
;   byteCount
;   userInput
;
; Receives: 
;  	[EBP + 8]		OFFSET promptUserInput_1
;	[EBP + 12]	 	OFFSET userInput
;	[EBP + 16]		SIZEOF userInteger
;	[EBP + 20]		OFFSET errorMessage
;	[EBP + 24]		OFFSET promptUserInput_2
;	[EBP + 28]		OFFSET byteCount
;	[EBP + 32]		OFFSET userInteger
;	[EBP + 36]	    UserInteger (numeric Value)
;	[EBP + 40]	    OFFSET integerArray
;	[EBP + 44]	    OFFSET integerArray_index
;	[EBP + 48]		integerArray_index (numeric value) 
;
; Returns: 
;   DL					0, 1, 3 <- moves sign value infromation around (3 is used to determine too small of a negative number)
;   DH					0, 1, 2 <- Moves sign value infromation around (2 is an invalid integer)
;   integerArray		New integer is added to array
;	integerArray_index	Array index increase
; ---------------------------------------------------------------------------------

readVal PROC
  
  PUSH				EBP
  MOV				EBP, ESP

  ; intiliazes DH and DL before macro
  MOV				DH, 0					; First value sign check		; 0 Clear, 1 Set, 3 Large Negative
  MOV				DL, 1					; Sign Val						; 0 negative, 1positive, 2 invalid

  ; Calls mGetString macro to store a string into userInput
  _getString:
  mGetString		[EBP + 8], [EBP + 12], [EBP + 16], [EBP + 20], [EBP + 24], [EBP + 28], [EBP + 32]


  ; Store Byte Count
  MOV				[EBP + 28] , EAX		


  CLD										
  MOV				ECX, [EBP + 28]			;Sets loop size with byteCount
  MOV				ESI, [EBP + 12]			;Moves OFFSET userInput to source
  MOV				EDI, [EBP + 32]			;Moves OFFSET userInteger to desitnation

  ; Validates individual string byte, must be a '0-9', '+', '-'
  ; Moves through the array, checking each charcter up till the null terminator
  _integerLoop:
    MOV				EAX, 0					; Why is this? I believe it is here to clear EAX so nothing is stored accidentely
	LODSB
	CMP				AL, 0					; Null
	JE				_validString
	CMP				AL, 48					; Checks if below '0' string
	JB				_invalidString			
	CMP				AL, 57					; Checks if above '9' string
	JA				_invalidString
	SUB				AL, 48					; String to Integer 
	MOV				DH, 1					; Store value is Set

	; Arithmic operation to turn string into integer
	;
	; 10 x UserInteger + ( stringhex - 48)
	;      [EBP + 36]
	PUSH			EAX						; Stores EAX
	PUSH			EDX						; Stores EDX
	MOV				EAX, 10
	MOV				EBX, [EBP + 36]			; UserInteger (numeric Value)
	MUL				EBX						; Changed MUL to IMUL from original, i dont know what this'll do
	JO				_Mul_Overflow
	POP				EDX						; Restores EDX
	POP				EBX						; Restores EBX with old EAX value

	; More comparisions, mainly checks if integer is to0 large or small
	CMP				EAX, 2147483647
	JA				_cont					; If above 2147483647, invalid string
	ADD				EAX, EBX
	JO				_CheckIfNegativeOVERFLOW	; If overflow, invalid string (however maybe not! have to check negative condition)
	MOV				[EBP + 36], EAX
	LOOP			_integerLoop			; Move to next string hex assessment
	JMP				_validString			; String is Valid!

	; Some additional validation, not all invalidity is actually invalid... 
  _invalidString:
    CMP				AL, 43					; '+'
	JE				_setForPositive			; Not an ileegal character, return to validity, storing a positive value
	CMP				AL, 45					; '-'
	JE				_setForNegative			; Not an illegal character, retutn to validity, storing a negative value

	; Truly invalid, just a continutation of _invalidString
	_cont:
	MOV				DL, 2					; Used within MACRO to calrify string was not valid
	MOV				EAX, 0					
	MOV				[EBP + 36], EAX			; Clears userInteger from previously stored value
	JMP				_getString				; jumps to call macro


	; Large jump out of byte range, helper call 
	_reach:
	JMP				_integerLoop

	; Value was to large, has to check the negative value, but needs to pop 2 registers before ( Technically a helper, setting conditions before its main function, _CheckIfNeagtiveOVERFLOW)
	_Mul_Overflow:
	POP				EDX
	POP				EBX
	
	; Because 2147483648 is too large for a positive, but not negative, we need to make sure that the value isnt -2147483648
	_CheckIfNegativeOVERFLOW:
	CMP				DL, 0				; DL 0 == negative sign
	JNE				_cont				; If not negative, integer is invalid regardless
	CMP				EAX, 2147483648		; A ne case scenario to check for specifcally -2147483648
	JE				_LargeNegValid
	JMP				_cont				; Invalid string integer
	
	; valid string helper function
	_LargeNegValid:
	MOV				DH, 3				; Large negative set
	JMP				_validString

	; Used when the user starts a string with '+', validating that it is a the first and ONLY sign in the string
  _setForPositive:
    CMP				ECX, 1			; If only character in string, invalid
	JE				_cont
	CMP				DH, 1			; If other values signs have been mentioned before, invalid
	JE				_cont
	MOV				DH, 1			; Sets sign has been placed in string
    MOV				DL, 1					; EDX 1 == Positive value in front, used to call ADD
	LOOP			_reach			; EDX SHOULD NOT CHANGE IN PROGRAM!

	; Used when the user starts a string with '-', validating that it is a the first and ONLY sign in the string
  _setForNegative:
    CMP				ECX, 1			; If only character in string, invalid
	JE				_cont
    CMP				DH, 1			; If other values signs have been mentioned before, invalid
	JE				_cont
	MOV				DH, 1			; Sets sign has been placed in string
    MOV				DL, 0					; EDX 0 == Negative value in front, used to call SUB
	LOOP			_reach			; EDX SHOULD NOT CHANGE IN PROGRAM!


	; The string has been deemed worthy! 
	; validString_2 helper function (mainly used for negatives but a starting point for all strings who have become valid integers in this big wild world)
  _validString:

    CMP				DL, 1					; If string is positive, jump to rest of function
    JE				_validString_2
    MOV				EAX, [EBP + 36]			; UserInteger (numeric Value)
	IMUL			EAX, -1					; Negafies the integer (as it has been assessed as positive thus far)
	MOV				[EBP + 36], EAX			; Store the negative value
	CMP				DH, 3					; If it is not a large negative number (-2126005284), continue
	JNE				_validString_2
	MOV				EAX, 2126005284		
	ADD				[EBP +36], EAX

	; continuation of valid string, moves everything into its memory locations
  _validString_2:
   
   	MOV				ESI, [EBP + 36]			; UserInteger (numeric Value)
	MOV				EDI, [EBP + 40]			; OFFSET integerArray
	MOV				EBX, [EBP + 48]			; integerArray_index (numeric value) 
	MOV				EAX, ESI

	MOV				EAX, ESI
	MOV				[EDI + EBX], EAX

  POP				EBP
  RET				44		

readVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
; 
; Converts a numeric SDWORD into a string of ascii values
; Calls upon mDisplayString macro to print the string representation of the numeric SDWORD
;
; Preconditions: 
;	ESI holds address of userInteger
;
; Postconditions: 
;	none
;
; Receives:
;  ESI <-- Stored address of userInteger
;  EAX <-- Integer Value being assessed 
;  [EBP + 8]	OFFSET userInput (used to store string)
;  [EBP + 12]   OFFSET reversedString
;
; Returns: 
;  A printed string of ascii value representions on screen
; ---------------------------------------------------------------------------------

WriteVal PROC

  PUSH				EBP
  MOV				EBP, ESP

  ; Initializes loop to 1 and moves userInput into EDI register for string movement
  CLD
  MOV				ECX, 1
  MOV				EDI, [EBP + 8]		; OFFSET userInput (used to store string)

  ; Stores integer value of userInteger to the EAX register for comparisons
  MOV				EAX, [ESI]
  ADD				EAX, 0
  JS				_MakePositive		; If value is negative, we change it to a positive value here


  ; -- Integer value being assessed, also converts EAX to QWORD for signed divison
  MOV				EAX, [ESI]
  CDQ

  ; Return point after a negative value is turned positive
  ; Sets EBX to 10 for divison in _IntegerToString
  ; Sets EBX to QWORD for signed division
    _BackToTheGrind:
  MOV				EBX, 10
  CDQ

  ; Turns an 32 bit integer into a string of ascii values
  ; 
  _IntegerToString:
  IDIV				EBX						; Divide by 10

  ADD				EDX, 48					; Remainder + 48
  MOV				[EDI], EDX				; Move remainder into userInput
  ADD				EDI, 1					; Move to next integer value , such that x00 to 0x0
  CMP				EAX, 0					; If qoutient == 0, value is complete
  JE				_QuotientIsZero			
  MOV				EDX, 0					; Reset remainder to zero
  INC				ECX						; Increases loop value
  JMP				_IntegerToString		; Jumps back up to assess n+1 integer position

  ; Changes a negative SDWORD to a positive DWORD for assesment and store negative value
  _MakePositive:
  MOV				EBX, -1					; Moves -1 to EBX for multipilication
  IMUL				EAX, EBX				; -1 x userInteger positional value
  CDQ
  INC				ECX						; Increases loop by 1
  JMP				_BackToTheGrind			; Return to main WriteVal function

  ; Adds a negative sign ascii value to end of string 
  _negativeInteger:
  MOV				EDX, 45
  MOV				[EDI], EDX
  JMP				_QIZ

  ; Checks sign flag for negative integer, adds negative if that is the case through _negativeInteger
  _QuotientIsZero:
  MOV				EAX, [ESI]
  ADD				EAX, 0
  JS				_negativeInteger

  ; 'QoutientIsZero' continuation function, used to return from _negativeInteger
  ; Sets up EDI and ESI for string byte transfer
  _QIZ:
  PUSH				ESI						; Stores ESI

  MOV				ESI, [EBP + 8]			; OFFSET userInput (used to store string)
  ADD				ESI, ECX
  DEC				ESI						; Moves away from null terminator
  MOV				EDI, [EBP + 12]			;[OFFSET reversedString

  ; Adds a null terminator to the end of the Reversed string
  MOV				EDX, 0
  ADD				EDI, ECX
  MOV				[EDI], EDX
  SUB				EDI, ECX


  ; Reverses the string
  ; The integer '12345' is stored as '54321' in userInput due to how the algorithm deduces the ascii representation
  ; Because of this we want to reverse '54321' to '12345' to acturally represent our integer
  _revLoop:
	STD								; Sets flag so were walking backwards
	LODSB							; Loading the string BYTE
	CLD								; Clear direction Flag
	STOSB							; Store the string BYTE
  LOOP		_revLoop


  MOV				ESI, [EBP + 12]			; OFFSET reversedString
  MOV				EDX, ESI				; Moves string to EDX to be passed to mDisplayString

  mDisplayString	EDX


  POP				ESI
  POP				EBP
  RET				8

WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: Arithmetic
; 
; Finds the sum and average of the 10 inputted SDWORD values
;
; Preconditions: none
;
; Postconditions: none
;
; Receives: 
;	[EBP + 8]		OFFSET integerArray
;	[EBP + 12]		OFFSET sum
;	[EBP + 16]		OFFSET size_integerArray
;	[EBP + 20]		OFFSET average
;
; Returns: 
;	sum stores a 32 bit SDWORD value of the 10 values sum
;   average stores a 32 bit SDWORD value of the 10 values average
; ---------------------------------------------------------------------------------

Arithmetic PROC

  PUSH				EBP
  MOV				EBP, ESP
	
  MOV				ESI, [EBP + 8]			; OFFSET integerArray  		
  MOV				EDI, [EBP + 12]			; OFFSET sum
  MOV				ECX, 10					; Initialize the loop to 10

  ; For each value in the integerArraym they are added to the EDI value
  _summation:

    MOV				EAX, [ESI]				; Sets new integer into EAX
	ADD				[EDI], EAX				; Adds the integer into EDI
	ADD				ESI, 4					; Moves ESI to next integer in array
	LOOP			_summation

	; Moves the value in sum to EAX to turn into a QWORD
	MOV				EAX, [EDI]
	CDQ
	
	; Moves the value of 10 to EBX and turns it into a QWORD for average arithmetic
	MOV				ESI, [EBP + 16]			; OFFSET size_integerArray
	MOV				EBX, [ESI]
	CDQ

	; Divides sum by 10, storing the value into the average memory location
	IDIV			EBX
	MOV				EDI, [EBP + 20]			; OFFSET average
	MOV				[EDI], EAX

	POP				EBP						; pop

  RET		16

Arithmetic ENDP

; ---------------------------------------------------------------------------------
; Name: EnteredNumbers
; 
; Takes in the IntegerArray and userInteger variables
; Loops through the integerArray, pushing a value into the userInteger variable
; For each loop, userInteger is moved to the WriteVal PROC, which in itself calls the MACRO to display string
;
; Preconditions: none
;
; Postconditions: none
;
; Receives: 
;	[EBP +8]		OFFSET displayNumberMessage
;	[EBP + 12]		OFFSET integerArray
;	[EBP + 16]		OFFSET userInteger
;	[EBP + 20]		OFFSET userInput (used to store string)
;	[EBP + 24]		OFFSET reversedString
;	[EBP + 28]		OFFSET commaSpaceNull
;
; Being Pushed to macro			Pushed value in new EBP
;  [EBP + 20]			//		[EBP + 8]	 OFFSET userInput (used to store string)
;  [EBP + 24]			//		[EBP + 12]   OFFSET reversedString
;  ESI <- integerArray
;

; Returns: 
;	A printed display of 10 stored inputted integers as their ascii values to consol
; ---------------------------------------------------------------------------------

EnteredNumbers PROC

  PUSH				EBP
  MOV				EBP, ESP
  CALL				CrLf					; Give me some space

  mDisplayString	[EBP + 8]				;OFFSET displayNumberMessage
	
  ; Initializing Loop and ESI
  MOV				ECX, 10						; 10 integers, 10 loops
  MOV				ESI, [EBP + 12]				; OFFSET integerArray
  _loopHere:
    PUSH			ECX
    MOV				EDI, [EBP + 16]				; OFFSET userInteger
    MOV				EAX, [ESI]
    MOV				[EDI], EAX					; stores indexed value into userInteger

	; Sets up to push addresses of userInput and reversedString to WriteVal
    MOV				EDI, [EBP + 20]				; OFFSET userInput (used to store string)
    PUSH			EDI
    MOV				EDI, [EBP + 24]				; OFFSET reversedString
    PUSH			EDI
    CALL			WriteVal

	; Moves to next integer in array
    ADD				ESI, 4
    POP				ECX							; restores ECX
    CMP				ECX, 1						; if ECX is 1, jump to add a comma after integer is printed
    JNE				_commaNull
    ; Continuation of loopHere
	_retHere:
      LOOP				_loopHere

  ; Adds a space after array displat and returns to main proc
  CALL				CrLf
  POP				EBP
  RET				28

  ; Displays a ", " after a string
  _commaNull:
  mDisplayString	 [EBP + 28]					; OFFSET commaSpaceNull

  JMP			_retHere
EnteredNumbers ENDP

; ---------------------------------------------------------------------------------
; Name: SumNumbers
; 
; Prints the sum number prompt and integer display
;
; Preconditions: 
;	none
;
; Postconditions: 
;	none
;
; Receives: 
;	 [EBP + 8]		OFFSET userInput
;	 [EBP + 12]		OFFSET reversedString
;	 [EBP + 16]		OFFSET userInteger
;	 [EBP + 20]		OFFSET displaySumMessage
;	 [EBP + 24]		OFFSET sum
;
; Returns: 
;	print the displaySumMessgae string with the sum ascii string
; ---------------------------------------------------------------------------------


SumNumbers PROC
  PUSH				EBP
  MOV				EBP, ESP

  ; Calls mDsiplayString to dsiaply displaySumMessage prompt
  mDisplayString	[EBP + 20]					; OFFSET displaySumMessage

  MOV				ESI, [EBP + 24]				; OFFSET sum

  ; moves the ascii string of sum into userInteger as destination
  MOV				EDI, [EBP + 16]				; OFFSET userInteger
  MOV				EAX, [ESI]
  MOV				[EDI], EAX					; Moving ascii integer to userInteger
  
  ; Sets up to push addresses of userInput and reversedString to WriteVal 
  MOV				EDI, [EBP + 8]				; OFFSET userInput (used to store string)
  PUSH				EDI
  MOV				EDI, [EBP + 12]				; OFFSET reversedString
  PUSH				EDI
  CALL				WriteVal

  CALL				CrLf
  POP				EBP

  RET				24

SumNumbers ENDP

; ---------------------------------------------------------------------------------
; Name: AverageNumbers
; 
; Prints the average number prompt and integer display
;
; Preconditions: 
;	none
;
; Postconditions: 
;	none
;
; Receives: 
;	 [EBP + 8]		OFFSET userInput
;	 [EBP + 12]		OFFSET reversedString
;	 [EBP + 16]		OFFSET userInteger
;	 [EBP + 20]		OFFSET displaySumMessage
;	 [EBP + 24]		OFFSET average
;
; Returns: 
;	print the displayAverageMessgae string with the sum ascii string
; ---------------------------------------------------------------------------------

AverageNumbers PROC
  PUSH				EBP
  MOV				EBP, ESP

  mDisplayString	[EBP + 20]				; OFFSET displayAverageessage

  MOV				ESI, [EBP + 24]				; OFFSET average

  ; moves the ascii string of average into userInteger as destination
  MOV				EDI, [EBP + 16]				; OFFSET userInteger
  MOV				EAX, [ESI]
  MOV				[EDI], EAX
  
  ; Sets up to push addresses of userInput and reversedString to WriteVal 
  MOV				EDI, [EBP + 8]				; OFFSET userInput (used to store string)
  PUSH				EDI
  MOV				EDI, [EBP + 12]				; OFFSET reversedString
  PUSH				EDI
  CALL				WriteVal

  CALL				CrLf
  POP				EBP

  RET				24

AverageNumbers ENDP

; ---------------------------------------------------------------------------------
; Name: Farwell
; 
; Says goodbye to the user
;
; Preconditions: 
;	none
;
; Postconditions: 
;	none
;
; Receives: 
;	[EBP + 8]		OFFSET goodBye
;
; Returns: 
;	printed goodbye to consol
; ---------------------------------------------------------------------------------

Farewell PROC
  PUSH				EBP
  MOV				EBP, ESP

  mDisplayString	[EBP + 8]

  POP				EBP
  RET				4

Farewell ENDP


END main