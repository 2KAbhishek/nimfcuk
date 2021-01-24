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


{.push overflowchecks: off.}
proc xinc*(c: var char) {.inline.} =
  ## Increment a character with wrapping instead of overflow checks.
  inc c
proc xdec*(c: var char) {.inline.} =
  ## Decrement a character with wrapping instead of underflow checks.
  dec c
{.pop.}

proc interpret*(code: string; input, output: Stream) =
  ## Interprets the brainfuck `code` string, reading from `input` and writing
  ## to `output`.
  ##
  ## Example:
  ## .. code:: nim
  ##   var inpStream = newStringStream("Hello World!\n")
  ##   var outStream = newFileStream(stdout)
  ##   interpret(readFile("examples/rot13.b"), inpStream, outStream)
  var
    tape = newSeq[char]()
    codePos = 0
    tapePos = 0

  proc run(skip = false): bool =
    while tapePos >= 0 and codePos < code.len:
      if tapePos >= tape.len:
        tape.add '\0'

      if code[codePos] == '[':
        inc codePos
        let oldPos = codePos
        while run(tape[tapePos] == '\0'):
          codePos = oldPos
      elif code[codePos] == ']':
        return tape[tapePos] != '\0'
      elif not skip:
        case code[codePos]
        of '+': xinc tape[tapePos]
        of '-': xdec tape[tapePos]
        of '>': inc tapePos
        of '<': dec tapePos
        of '.': output.write tape[tapePos]
        of ',': tape[tapePos] = input.readCharEOF
        else: discard

      inc codePos

  discard run()

proc interpret*(code, input: string): string =
  ## Interprets the brainfuck `code` string, reading from `input` and returning
  ## the result directly.
  ##
  ## Example:
  ## .. code:: nim
  ##   echo interpret(readFile("examples/rot13.b"), "Hello World!\n")
  var outStream = newStringStream()
  interpret(code, input.newStringStream, outStream)
  result = outStream.data

proc interpret*(code: string) =
  ## Interprets the brainfuck `code` string, reading from stdin and writing to
  ## stdout.
  ##
  ## Example:
  ## .. code:: nim
  ##   interpret(readFile("examples/rot13.b"))
  interpret(code, stdin.newFileStream, stdout.newFileStream)
