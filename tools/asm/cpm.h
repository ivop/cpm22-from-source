#pragma once
#include <stdio.h>
#include <stdint.h>

typedef struct {
    uint8_t dr;
    uint8_t f[11];
    uint8_t ex;
    uint8_t s1;
    uint8_t s2;
    uint8_t rc;
    uint8_t d[16];
    uint8_t cr;
    uint8_t r[3];
    FILE *fp;
} FCB;

extern uint16_t cpm_ram;
extern uint16_t cpm_ramtop;
extern uint8_t *cpm_default_dma;
extern FCB cpm_fcb;

extern void cpm_exit(void);
extern void cpm_conout(uint8_t b);
extern uint8_t cpm_const(void);
extern uint8_t cpm_open_file(FCB *fcb);
extern uint8_t cpm_close_file(FCB *fcb);
extern uint8_t cpm_delete_file(FCB *fcb);
extern uint8_t cpm_read_sequential(FCB *fcb);
extern uint8_t cpm_write_sequential(FCB *fcb);
extern uint8_t cpm_make_file(FCB *fcb);
extern void cpm_set_dma(void *ptr);
extern void cpm_overwrite_ccp(void);

extern void cpm_set_args(int argc, char **argv);
