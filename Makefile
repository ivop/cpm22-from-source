all:
	+make -C src all

clean:
	rm -f *~
	+make -C src clean

distclean: clean
	+make -C src distclean
