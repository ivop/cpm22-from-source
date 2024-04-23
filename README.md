# Build CP/M 2.2 from source

Build CP/M 2.2 from the original Digital Research Inc. source code on Linux.

## Features

### OS Components

* BDOS
  * Assembled to the most common 0EC00H-0FBFFH address range.
  * Includes patch1 for deblocking BIOSes.
* CCP
  * Assembled to the most common 0E400H-0EBFFH address range.
  * Includes option to disable serialization. Disabled by default.

### Applications

#### PL/M

* ED
* LOAD
* PIP
* STAT
* SUBMIT

#### ASM

* DUMP
* ASM

## Notes

* The assembler used is the ISIS-II Intel 8080/8085 Macro Assembler, v4.1, ported to C by Mark Ogden.
* PL/M is compiled with the ISIS-II PL/M-80 Compiler v4.0, also ported to C by Mark Ogden.
* The assembly sources are slightly modified to be compatible with the Intel assembler. Changes are:
  * One mnemonic per line.
  * Some double definitions and the title lines are commented out.
* To link PL/M applications, SYSTEM.LIB is needed. As it was nowhere to be found, I reimplemented the core functionality in systemlib.asm.

