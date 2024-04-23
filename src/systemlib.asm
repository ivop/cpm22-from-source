    name cpm
    public boot
    public iobyte
    public bdisk
    public mon1
    public mon2
    public mon3
    public maxb
    public fcb
    public buff
    aseg
    org 0
boot:
    org 3
iobyte:
    org 4
bdisk:
    org 5
mon1:
mon2:
mon3:
    org 6
maxb:
    org 005Ch
fcb:
    org 0080h
buff:
    end
