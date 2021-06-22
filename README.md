# String_Paramaters_and_Macros
Assembly level project written with MASM that converts between user inputted strings and integers, of which fit within a 32 bit register

# Project Description

Runs a program through main which calls upon the ReadVal and WriteVal procedures to get 10 valid signed integers from the user that will fit within a 32 bit register, store the string as a numerical value within an array, and then call the array to turn the integers into a string to display the signed integers, their sum, and their average. This program does not use ReadDec or WriteDec, all string to integer conversions are programmed. 

Program utilizies prodecures, pushing variables onto the stack from main before calling the procedure
All variables are passed to procedures via stack and use Base + Offset addressing as well as indirect addressing. 
