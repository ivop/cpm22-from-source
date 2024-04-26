/*
 * genprlmap - Generate PRL bitmap for CP/M 2.2 relocator
 *
 * Used by DDT.COM
 *
 * Copyright © 2024 Ivo van Poorten
 * See LICENSE for details.
 *
 * usage: ./genprlmap in1.com in2.com out.map
 *
 * Assemble in1.com to 00000H
 * Assemble in2.com to 00100H
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

static FILE *open_file(const char *filename, const char *mode) {
    FILE *f = fopen(filename, mode);
    if (!f) {
        fprintf(stderr, "error: unable to open %s\n", filename);
        exit(1);
    }
    return f;
}

static int filesize(FILE *f) {
    fseek(f, 0, SEEK_END);
    int size = ftell(f);
    fseek(f, 0, SEEK_SET);
    return size;
}

static void output_bit(FILE *f, bool bit) {
    static int mask = 0x80;
    static int value = 0;

    if (bit) {
        value |= mask;
    }

    mask >>= 1;

    if (!mask) {
        fputc(value, f);
        value = 0;
        mask = 0x80;
    }
}

int main(int argc, char **argv) {
    if (argc != 4) {
        fprintf(stderr, "usage: genprlmap in1.com in2.com out.map\n");
        return 1;
    }
    FILE *f = open_file(argv[1], "rb");
    FILE *g = open_file(argv[2], "rb");

    int fsize = filesize(f);
    int gsize = filesize(g);

    if (fsize != gsize) {
        fprintf(stderr, "error: file size mismatch\n");
        return 1;
    }

    FILE *h = open_file(argv[3], "wb");

    for (int i=0; i<fsize; i++) {
        int a = fgetc(f);
        int b = fgetc(g);

        if (a != b) {
            output_bit(h, 1);
        } else {
            output_bit(h, 0);
        }
    }

    for (int i=0; i<fsize%8; i++) {
        output_bit(h, 0);
    }

    fclose(f);
    fclose(g);
    fclose(h);
}
