CC ?= gcc
CXX ?= g++

ASM80=../c-ports/Linux/Install/asm80
PLM80C=../c-ports/Linux/Install/plm80c
LINK=../c-ports/Linux/Install/link
LOCATE=../c-ports/Linux/Install/locate
OBJHEX=../c-ports/Linux/Install/objhex
HEXCOM=../tools/hexcom

PLM80LIB=../intel80tools/itools/plm80.lib/plm80.lib
SYSTEMLIB=systemlib.obj

BDOS=../bin/bdos.sys
CCP=../bin/ccp.sys

PLMPROGRAMS=ed load pip stat submit
PLMBINARIES=$(PLMPROGRAMS:%=../bin/%.com)
PLMSOURCES=$(PLMBINARIES:%.com=%.plm)

ASMPROGRAMS=dump
ASMBINARIES=$(ASMPROGRAMS:%=../bin/%.com)
ASMSOURCES=$(ASMBINARIES:%.com=%.asm)

.PRECIOUS: %.hex %.loc %.lnk %.obj

all: $(PLMBINARIES) $(BDOS) $(CCP) $(ASMBINARIES)

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

$(HEXCOM):
	+make -C ../tools hexcom

$(SYSTEMLIB): systemlib.asm

$(CCP): ccp.asm $(ASM80) $(LINK) $(LOCATE) $(OBJHEX) $(HEXCOM)
	$(ASM80) $<
	$(LINK) ccp.obj to ccp.lnk
	$(LOCATE) ccp.lnk to ccp.loc code \(e400h\) map
	$(OBJHEX) ccp.loc to ccp.hex
	$(HEXCOM) $@ < ccp.hex

$(BDOS): bdos.asm $(ASM80) $(LINK) $(LOCATE) $(OBJHEX) $(HEXCOM)
	$(ASM80) $<
	$(LINK) bdos.obj to bdos.lnk
	$(LOCATE) bdos.lnk to bdos.loc code \(ec00h\) map
	$(OBJHEX) bdos.loc to bdos.hex
	$(HEXCOM) $@ < bdos.hex

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

../bin/%.com: %.hex $(HEXCOM)
	$(HEXCOM) $@ < $<

../bin/%.com: %.asm $(ASM80) $(LINK) $(LOCATE) $(OBJHEX) $(HEXCOM)
	$(ASM80) $<
	$(LINK) $(<:%.asm=%.obj) to $(<:%.asm=%.lnk)
	$(LOCATE) $(<:%.asm=%.lnk) to $(<:%.asm=%.loc) map
	$(OBJHEX) $(<:%.asm=%.loc) to $(<:%.asm=%.hex)
	$(HEXCOM) $@ < $(<:%.asm=%.hex)

asm.lnk: as0com.obj as1io.obj as2scan.obj as3sym.obj as4sear.obj as5oper.obj as6main.obj
	$(LINK) as0com.obj,as1io.obj,as2scan.obj,as3sym.obj,as4sear.obj,as5oper.obj,as6main.obj to $@

asm.loc: asm.lnk
	$(LOCATE) $(<:%.lnk=%.lnk) to $(<:%.lnk=%.loc) map

clean:
	rm -f *~ *.lst *.loc *.hex *.obj *.lnk *.sys
	+make -C ../tools clean
	+make -C ../c-ports/Linux clean
	rm -rf ../bin/*

distclean: clean
	+make -C ../c-ports/Linux distclean
	rm -rf ../c-ports/Linux/Install/*
