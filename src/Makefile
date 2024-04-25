CC ?= gcc
CXX ?= g++

ASM80=../c-ports/Linux/Install/asm80
PLM80C=../c-ports/Linux/Install/plm80c
LINK=../c-ports/Linux/Install/link
LOCATE=../c-ports/Linux/Install/locate
OBJHEX=../c-ports/Linux/Install/objhex
ASM=../tools/asm/asm
HEXCOM=../tools/hexcom/hexcom
GENPRLMAP=../tools/genprlmap/genprlmap

PLM80LIB=../intel80tools/itools/plm80.lib/plm80.lib
SYSTEMLIB=systemlib.obj

BDOS=../bin/bdos.sys
CCP=../bin/ccp.sys

PLMPROGRAMS=ed load pip stat submit
PLMBINARIES=$(PLMPROGRAMS:%=../bin/%.com)
PLMSOURCES=$(PLMBINARIES:%.com=%.plm)

ASMPROGRAMS=asm dump mload sd
ASMBINARIES=$(ASMPROGRAMS:%=../bin/%.com)
ASMSOURCES=$(ASMBINARIES:%.com=%.asm)

DDTBINARY=../bin/ddt.com

.PRECIOUS: %.hex %.loc %.lnk %.obj

all: $(PLMBINARIES) $(BDOS) $(CCP) $(ASMBINARIES) $(DDTBINARY) $(THIRDPARTYBIN)

$(ASM80):
	+make -C ../c-ports/Linux/asm80

$(PLM80C):
	+make -C ../c-ports/Linux/plm80c

$(LINK):
	+make -C ../c-ports/Linux/link

$(LOCATE):
	+make -C ../c-ports/Linux/locate

$(OBJHEX):
	+make -C ../c-ports/Linux/objhex

$(ASM):
	+make -C ../tools/asm asm

$(HEXCOM):
	+make -C ../tools/hexcom hexcom

$(GENPRLMAP):
	+make -C ../tools/genprlmap genprlmap

$(SYSTEMLIB): systemlib.asm

$(CCP): CCP.ASM $(ASM)
	$(ASM) CCP
	cp CCP.BIN $(CCP)

$(BDOS): BDOS.ASM $(ASM)
	$(ASM) BDOS
	cp BDOS.BIN $(BDOS)

%.obj: %.asm $(ASM80)
	$(ASM80) $<

%.hex: %.loc $(OBJHEX)
	$(OBJHEX) $< to $@

%.loc: %.lnk $(LOCATE)
	$(LOCATE) $< to $@ code\(100h\) stacksize\(100\) map

%.lnk: %.obj $(LINK) $(SYSTEMLIB) $(PLM80LIB)
	$(LINK) $<,$(SYSTEMLIB),$(PLM80LIB) to $@

%.obj: %.plm $(PLM80C)
	$(PLM80C) $<

%.com: %.hex $(HEXCOM)
	$(HEXCOM) $@ < $<

../bin/%.com: %.hex $(HEXCOM)
	$(HEXCOM) $@ < $<

../bin/%.com: %.asm $(ASM80) $(LINK) $(LOCATE) $(OBJHEX) $(HEXCOM)
	$(ASM80) $<
	$(LINK) $(<:%.asm=%.obj) to $(<:%.asm=%.lnk)
	$(LOCATE) $(<:%.asm=%.lnk) to $(<:%.asm=%.loc) map
	$(OBJHEX) $(<:%.asm=%.loc) to $(<:%.asm=%.hex)
	$(HEXCOM) $@ < $(<:%.asm=%.hex)

../bin/dump.com: DUMP.ASM $(ASM)
	$(ASM) DUMP
	cp DUMP.BIN $@

../bin/mload.com: MLOAD.ASM $(ASM)
	$(ASM) MLOAD
	cp MLOAD.BIN $@

../bin/sd.com: SD137.ASM $(ASM)
	$(ASM) SD137
	cp SD137.BIN $@

asm.lnk: as0com.obj as1io.obj as2scan.obj as3sym.obj as4sear.obj as5oper.obj as6main.obj $(LINK)
	$(LINK) as0com.obj,as1io.obj,as2scan.obj,as3sym.obj,as4sear.obj,as5oper.obj,as6main.obj to $@

asm.loc: asm.lnk $(LOCATE)
	$(LOCATE) $< to $(<:%.lnk=%.loc) map

# CONVOLUTED DDT RULES ;)

ddt0mov.loc: ddt0mov.lnk $(LOCATE)
	$(LOCATE) $< to $@ map

ddt0mov-padded.com: ddt0mov.com
	dd if=/dev/zero of=$@ bs=1 count=256
	dd if=$< of=$@ bs=1 conv=notrunc

ddt1asm.loc: ddt1asm.lnk $(LOCATE)
	$(LOCATE) $< to $@ code \(0000H\) stacksize\(0\) map

ddt1asm-padded.com: ddt1asm.com
	dd if=/dev/zero of=$@ bs=1 count=1664
	dd if=$< of=$@ bs=1 conv=notrunc

ddt1asm-nextpage.loc: ddt1asm.lnk $(LOCATE)
	$(LOCATE) $< to $@ code \(0100H\) stacksize\(0\) map

ddt1asm-nextpage-padded.com: ddt1asm-nextpage.com
	dd if=/dev/zero of=$@ bs=1 count=1664
	dd if=$< of=$@ bs=1 conv=notrunc

ddt2mon.loc: ddt2mon.lnk $(LOCATE)
	$(LOCATE) $< to $@ code \(0000H\) map

ddt2mon-nextpage.loc: ddt2mon.lnk $(LOCATE)
	$(LOCATE) $< to $@ code \(0100H\) stacksize\(0\) map

ddt12.com: ddt1asm-padded.com ddt2mon.com
	cat $^ > $@

ddt12-nextpage.com: ddt1asm-nextpage-padded.com ddt2mon-nextpage.com
	cat $^ > $@

ddt.map: ddt12.com ddt12-nextpage.com $(GENPRLMAP)
	$(GENPRLMAP) ddt12.com ddt12-nextpage.com $@

$(DDTBINARY): ddt0mov-padded.com ddt12.com ddt.map
	cat $^ > $@
	/usr/bin/printf "\xbc\x0f" | dd of=$@ bs=1 seek=1 conv=notrunc

clean:
	rm -f *~ *.lst *.loc *.hex *.obj *.lnk *.sys *.BIN *.PRN *.com *.map
	+make -C ../tools/hexcom clean
	+make -C ../tools/asm clean
	+make -C ../c-ports/Linux clean
	rm -rf ../bin/*

distclean: clean
	+make -C ../c-ports/Linux distclean
	rm -rf ../c-ports/Linux/Install/*
