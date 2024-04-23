# Build CP/M 2.2 from source

Build CP/M 2.2 from the original Digital Research Inc. source code on Linux.

## Features

### OS Components

* BDOS
  * Assembled to the most common 0EC00H-0FBFFH address range.
  * Includes patch1 for deblocking BIOSes. Enabled by default.
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
* DUMP

#### NOSRC

* HEXCOM
* LIB
* LINK
* MAC
  * The original DRI ASM succesor that had added macro capabilities.

## Build instructions

```
git clone https://github.com/ivop/cpm22-from-source/
cd cpm22-from-source
git submodule update --init --recursive
make -j8
```

All built binaries end up in the _bin_ directory.

## Notes

* BDOS and CCP are assembled with David Given's ASM reimplementation. The other ASM files are assembled with the ISIS-II Intel 8080/8085 Macro Assembler, v4.1, ported to C by Mark Ogden.
* PL/M is compiled with the ISIS-II PL/M-80 Compiler v4.0, also ported to C by Mark Ogden.
* The assembly sources which are assembled with the Intel assembler are slightly modified to be compatible. Changes are:
  * One mnemonic per line.
  * Some double definitions and the title lines are commented out.
* To link PL/M applications, SYSTEM.LIB is needed. As it was nowhere to be found, I reimplemented the needed functionality in systemlib.asm.
* The _nosrc_ directory contains several utilities need on real hardware for which no source has been found.
