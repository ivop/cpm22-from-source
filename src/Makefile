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

BDOS=bdos.sys
CCP=ccp.sys

PROGRAMS=ed load pip stat submit
BINARIES=$(PROGRAMS:%=../bin/%.com)
SOURCES=$(BINARIES:%.com=%.plm)

.PRECIOUS: %.hex %.loc %.lnk %.obj

all: $(BINARIES) $(BDOS) $(CCP)

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

$(CCP): ccp.asm
	$(ASM80) $<
	$(LINK) ccp.obj to ccp.lnk
	$(LOCATE) ccp.lnk to ccp.loc code \(e400h\) map
	$(OBJHEX) ccp.loc to ccp.hex
	$(HEXCOM) $@ < ccp.hex

$(BDOS): bdos.asm

%.obj: %.asm $(ASM80)
	$(ASM80) $<

%.hex: %.loc $(OBJHEX)
	$(OBJHEX) $< to $@

%.loc: %.lnk $(LOCATE)
	$(LOCATE) $< to $@ code\(100h\) stacksize\(100\) map

%.lnk: %.obj $(LINK) $(SYSTEMLIB)
	$(LINK) $<,$(SYSTEMLIB),$(PLM80LIB) to $@

%.obj: %.plm $(PLM80C)
	$(PLM80C) $<

../bin/%.com: %.hex $(HEXCOM)
	$(HEXCOM) $@ < $<

clean:
	rm -f *~ *.lst *.loc *.hex *.obj *.lnk
	+make -C ../tools clean
	+make -C ../c-ports/Linux clean
	rm -rf ../bin/*

distclean: clean
	+make -C ../c-ports/Linux distclean
	rm -rf ../c-ports/Linux/Install/*
