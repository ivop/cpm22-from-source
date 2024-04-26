/*
 * Very simple 'genhex'
 *
 * Copyright (C) 2024 by Ivo van Poorten
 * See LICENSE for details.
 *
 * usage: genhex file.com [start address in hexadecimal] > output.hex
 */

#include <stdio.h>
#define BUFSIZE 16

static char *hex = "0123456789ABCDEF";

static char *printx(char *p, unsigned char v) {
    *p++ = hex[v>>4];
    *p++ = hex[v&0xf];
    return p;
}

int main(int argc, char **argv) {
    int addr, nbytes;
    unsigned char buffer[BUFSIZE];
    char line[80];

    if (argc == 1) {
        fprintf(stderr, "usage: genhex file.dat [start address in hex]\n");
        return 1;
    }
    FILE *f = fopen(argv[1], "rb");
    if (!f) {
        fprintf(stderr, "error: unable to open %s\n", argv[1]);
        return 1;
    }
    if (argc > 2) {
        sscanf(argv[2], "%x", &addr);
    }
    if (addr > 0xffff) {
addr_error:
        fprintf(stderr, "error: address > 0xffff\n");
        return 1;
    }

    line[0] = ':';
    line[7] = line[8] = '0';

    puts("");
    while ((nbytes = fread(buffer, 1, 16, f)) != 0) {
        unsigned char chk = nbytes;
        char *p = line+1;
        p = printx(p, nbytes);
        p = printx(p, addr>>8);
        p = printx(p, addr);
        chk += addr>>8;
        chk += addr&0xff;
        p += 2;

        for (int i=0; i<nbytes; i++) {
            p = printx(p, buffer[i]);
            chk += buffer[i];
        }

        chk = ~chk + 1;
        p = printx(p, chk);
        *p = 0;
        puts(line);

        addr += nbytes;
        if (addr > 0xffff) goto addr_error;
    }
    puts(":00000001FF");
    putchar(26);            // CP/M EOF
}

