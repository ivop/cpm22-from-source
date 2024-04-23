CC ?= gcc

asm: asm.c cpm.c
	$(CC) -DIGNORE -I. -O3 -o $@ $^

cpm.c: cpm.h
asm.c: cpm.h

clean:
	rm -f asm *~
