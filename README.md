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

* ASM
  * The original DRI Assembler. Can be used on real hardware, or on an emulator, to assemble the original sources in the _archive_ directory.
* DUMP

#### NOSRC

* HEXCOM
* LIB
* LINK
* MAC
  * The original DRI ASM succesor that had added macro capabilities.

## Notes

* The assembler used is the ISIS-II Intel 8080/8085 Macro Assembler, v4.1, ported to C by Mark Ogden.
* PL/M is compiled with the ISIS-II PL/M-80 Compiler v4.0, also ported to C by Mark Ogden.
* The assembly sources are slightly modified to be compatible with the Intel assembler. Changes are:
  * One mnemonic per line.
  * Some double definitions and the title lines are commented out.
* To link PL/M applications, SYSTEM.LIB is needed. As it was nowhere to be found, I reimplemented the needed functionality in systemlib.asm.
* The _nosrc_ directory contains several utilities need on real hardware for which no source has been found.

