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

* ED -- editor
* LOAD -- convert HEX to COM
* PIP -- copy utility
* STAT -- status of files and devices
* SUBMIT -- batch processing

#### ASM

* ASM -- native DRI assembler
* DDT -- dynamic debugging tool
* DUMP -- dump hexadecimal listing to conout

#### Third-party ASM

* MLOAD -- alternative LOAD with more options
* SD -- Super Directory DIR replacement

#### NOSRC

* HEXCOM -- another HEX to COM converter
* LIB -- library tool
* LINK -- linker
* MAC -- DRI Macro assembler, ASM with macros

## Build instructions

```
git clone https://github.com/ivop/cpm22-from-source/
cd cpm22-from-source
git submodule update --init --recursive
make -j8
```

All built binaries end up in the _bin_ directory.

## Notes

* BDOS, CCP, DUMP, MLOAD, and SD are assembled with David Given's ASM reimplementation. The other ASM files are assembled with the ISIS-II Intel 8080/8085 Macro Assembler, v4.1, ported to C by Mark Ogden.
* PL/M is compiled with the ISIS-II PL/M-80 Compiler v4.0, also ported to C by Mark Ogden.
* The assembly sources which are assembled with the Intel assembler are slightly modified to be compatible. Changes are:
  * One mnemonic per line.
  * Some double definitions and the title lines are commented out.
  * If used, STACK is renamed to XSTACK because of a reserved word collision.
  * DDT is assembled to CSEG instead of ASEG (absolute segment). See below.
* To link PL/M applications, SYSTEM.LIB is needed. As it was nowhere to be found, I reimplemented the needed functionality in systemlib.asm.
* The _nosrc_ directory contains several utilities needed on real hardware for which no source has been found.
* Originally, DDT was assembled twice, but with ASM80 we can assemble it once to CSEG and  _locate_ it to 0000H and 0100H respectively to generate the Page ReLocation bitmap. It is unknown how the original bitmap was generated, so a new utility _genprlmap_ was written.
* Some binaries appear not to be binary identical to the original binary versions when in fact they are. The difference is in the reserved spaces. The original versions have random garbage in them, just the values that happened to be in memory at that specific location during link time. The versions created here have zeroes at these locations. Also, most original binaries are padded with either garbage or zeroes to an exact multiple of 128 bytes (CP/M sector size). The binaries created with the ISIS-II toolchain are not.
