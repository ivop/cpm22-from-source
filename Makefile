all:
	+make -C src all

clean:
	rm -f *~
	+make -C src clean

distclean:
	+make -C src distclean
