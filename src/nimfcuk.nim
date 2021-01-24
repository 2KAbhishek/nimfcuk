## :Author: Abhishek Keshri
##
## This module implements an interpreter for the brainfuck programming language
## as well as a compiler of brainfuck into efficient Nim code.
##
## Example:
## .. code:: nim
##   import nimfcuk, streams
##
##   interpret("++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++.")
##   # Prints "Hello World!"


import streams

when not defined(nimnode):
  type NimNode = PNimrodNode

proc readCharEOF*(input: Stream): char =
  ## Read a character from an `input` stream and return a Unix EOF (-1). This
  ## is necessary because brainfuck assumes Unix EOF while streams use \0 for EOF.

  result = input.readChar
  if result == '\0': # Streams return 0 for EOF
    result = '\255'  # BF assumes EOF to be -1

