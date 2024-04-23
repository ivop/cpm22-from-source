#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "cpm.h"

uint16_t cpm_ram = 0;
uint16_t cpm_ramtop = 65535;

static uint8_t default_dma[128];

uint8_t *cpm_default_dma = default_dma;
static uint8_t *dma;

FCB cpm_fcb;

char *fcb_to_filename(FCB *fcb) {
    static char fname[20];
    int i, j = 0;
    for (i=0; i<11; i++) {
        if (fcb->f[i] != ' ') {
            fname[j++] = fcb->f[i];
        }
        if (i==7 && fcb->f[8] != ' ') {
            fname[j++] = '.';
        }
    }
    fname[j] = 0;
    return fname;
}

void cpm_exit(void) {
    exit(0);
}

void cpm_conout(uint8_t b) {
    putchar(b);
}

uint8_t cpm_const(void) {
    return 0;
}

uint8_t cpm_open_file(FCB* fcb) {
    char *filename = fcb_to_filename(fcb);
    return !(fcb->fp = fopen(filename, "rb")) ? 0xff : 0;
}

uint8_t cpm_close_file(FCB* fcb) {
    char *filename = fcb_to_filename(fcb);
    fclose(fcb->fp);
    return 0;
}

uint8_t cpm_delete_file(FCB* fcb) {
    char *filename = fcb_to_filename(fcb);
}

uint8_t cpm_read_sequential(FCB *fcb) {
    int ret = fread(dma, 1, 128, fcb->fp);
    return 0;
}

uint8_t cpm_write_sequential(FCB *fcb) {
    return !(fwrite(dma, 128, 1, fcb->fp) == 1);
}

uint8_t cpm_make_file(FCB* fcb) {
    char *filename = fcb_to_filename(fcb);
    fprintf(stderr, "make file: %s\n", filename);
    return !(fcb->fp = fopen(filename, "wb")) ? 0xff : 0;
}

void cpm_set_dma(void* ptr) {
    dma = ptr;
}

void cpm_overwrite_ccp(void) {
}

void cpm_set_args(int argc, char **argv) {
    char *name, *ext;

    if (argc != 2) {
        fprintf(stderr, "error: usage: asm filename.asm\n");
        exit(1);
    }

    memset(cpm_fcb.f, ' ', 11);
    name = argv[1];
    ext = strchr(name, '.');
    if (ext) {
        strncpy(cpm_fcb.f, name, ext-name);
        strncpy(cpm_fcb.f+8, ext+1, 3);
    } else {
        strncpy(cpm_fcb.f, name, 8);
    }

    for (int i=0; i<11; i++)
        if (!cpm_fcb.f[i])
            cpm_fcb.f[i] = ' ';
}

