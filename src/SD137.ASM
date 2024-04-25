;		      SUPER DIRECTORY PROGRAM
;			      SD137
;			     5 FEB 89
;
;    Read SD.INF for detailed instructions on configuring SD for your
;    system.  For information regarding this utility's modification
;    history, read SD.HIS.
;
;		This program is being distributed ready
;		to use on a CP/M v2.2 computer with two
;		disk drives , no Z80DOS, and no ZCPR in use.
;
;		(Options often changed for RCPM use are
;		marked with an asterisk.)  The typical
;		RCPM Sysop might change only these:
;
;		    a)	3 options starting at MAXDRV
;		    b)	how many drives at LODRV and
;		    c)	6 options starting at USEF
;		    d)	USELCW needs wheel to prevent
;			   showing archive bits
;
;
;	     NOTE:  This version can be assembled with
;		    ASM, LASM, M80, MAC or SLRMAC.
;
; SD displays the directory of a CP/M disk, sorted alphabetically, with
; the file size in k, rounded to the nearest CP/M block size.  It also
; displays library and archive files with the file size in k, if the $L
; option is selected.
;
; Current versions of SD automatically adjust for any block size and di-
; rectory length under CP/M 2.2,  3.0 or MP/M.	They can also handle any
; number of disk drives or skip those not available.  Current features:
;
;	 1) Automatic pauses when the screen fills up except when the
;	    F, N, or P options are specified
;	 2) Searching individual or multiple drives and/or user areas
;	 3) Unconditional or optional disk system reset before execution
;	    begins
;	 4) Directing output to a disk file called DISK.DIR and append-
;	    ing to that file on subsequent runs
;	 5) Summary line output giving drive and user information, num-
;	    ber of files matched, how much space they consume and free
;	    space remaining on the disk
;	 6) Displaying or suppressing "system" files
;	 7) Accepting ambiguous filenames with or without a drive name
;	 8) Printer output (automatically suppresses the [more] pauses)
;	 9) Optional help menu with '?'
;	10) Displaying number of records used by files
;	11) Alphabetization of files sorted by type (extent)
;	12) Selecting alternate list format - vertical if horizontal
;	    is default, and vice versa.
;	13) Shows contents of .ARC, .ARK or .LBR files with $L option
;	14) Summary line output optionally contains name of ZCPR3 named
;	    directory, if selected
;	15) ZCPR3 named directory may be used in command line instead
;	    of DU: if selected
;	16) ZCPR3 Public user areas may be displayed with or without
;	    WHEEL byte
;	17) ZCPR3+ ENViorment support of wheel, maxdrv, maxusr location, and
;	    TCAP for REVID,ULINE string
;	18) If are using ZCPR34+, then have the capability of
;	    having the program build the LODRV-HIDRV table if DRVVEC
;	    equate is YES
;	19) Normal multi-page vertical sort or single page vertical sort
;	20) Choose files based upon attributes 1-4
;	21) Summary totals now supplied if /A,/D,/H (or combo).
;	22) Z80DOS time stamping and SETD22 type stamping of .LBR's
;	    supported via Z80DOS equate.
;	23) With Z80DOS, many features of date specification for file
;	    selection available 
;-----------------------------------------------------------------------
;
;	ASEG			; Needed for M80 and RMAC, ignore error
;
	ORG	0100H
;
	JMP	START
;
NO	EQU	0
YES	EQU	NOT NO		; (Some assemblers don't like 0FFh)
;
; Define version number
;
MAIN	EQU	1		; Main block number
VER	EQU	37		; Current version
MONTH	EQU	2		; Month
DAY	EQU	5		; Day
YEAR	EQU	89		; Year
;
;-----------------------------------------------------------------------
;			     options
;
MAXDRV	EQU	NO		; *Yes if MAXD byte is supported
MAXUR	EQU	NO		; *Yes if MAXU byte is supported
WHEEL	EQU	NO		; *Yes if using ZCPR wheel byte

; If using equate ZCPR3P set to YES, then the following 3 will be
; taken from the ENV descriptor automaticaly if the corresponding
; MAXDRV, MAXUR, or WHEEL equate is set YES

MXDRV	EQU	3DH		; *Set to max drive address if MAXDRV=Yes
MXUSR	EQU	3FH		; *Set to max user  address if MAXUR=Yes
WHLOC	EQU	3EH		; *Set to wheel location if WHEEL=Yes

MXZUSR	EQU	15		; Maximum user # allowed with WHEEL set
				; NOTE: OVERRIDES even MXUSR as specified
				; in ENV if ZCPR3P and MAXUR is YES

PRBRDR	EQU	NO		; Yes = print quasi-borders for libraries
WMBOOT	EQU	NO		; If warmboot is needed on exit
VLIST	EQU	YES		; Yes for vertical alphabetization
VSPAGE	EQU	YES		; If Vertical sort is to be by page

DRVVEC	EQU	NO		; Set to YES if want support of Z34
				; drive vector, NOTE: MUST HAVE
				; ZCPR3P SET YES

	DB	'Z3ENV'		; For ZCPR3 Environment ID
	DB	1		; Class 1, External
Z3ENV:	DW	0		; Environment Address.	If using ZCPR33
				; This can be left as is.
;-------------------------------
;
; Drive/User area lookup table:
; ----------------------------
; Change the following table as appropriate for your version of CP/M.
; You can limit the maximum user area without wheel byte independently
; for any drive available.  Use 0FFh for drives that are not available.
;
;		CP/M  v2.2 has 16 user areas, 0-15
;		CP/M  v3.0 has 32 user areas, 0-31
;
; NOTE: Use your editor to move the "HIDRV" line below the correct
; number of drives for your system.  This not only saves time when the
; highest drive has been reached, but will display a drive/user error
; message which otherwise will not be shown.
;
LODRV	EQU	$		; Mark beginning of drive/user table

	DB	15		; Maximum user area for drive A
	DB	15		; "	  "    "    "	"     B

	 IF	NOT DRVVEC
				; Use this as end of table if
				; are not using Z34+ drive vector
HIDRV	EQU	$		; Mark end of drive/user table
	 ENDIF		; NOT DRVVEC

	DB	0FFH		; "	  "    "    "	"     C
	DB	0FFH		; "	  "    "    "	"     D
	DB	0FFH		; "	  "    "    "	"     E
	DB	0FFH		; "	  "    "    "	"     F
	DB	0FFH		; "	  "    "    "	"     G
	DB	0FFH		; "	  "    "    "	"     H
	DB	0FFH		; "	  "    "    "	"     I
	DB	0FFH		; "	  "    "    "	"     J
	DB	0FFH		; "	  "    "    "	"     K
	DB	0FFH		; "	  "    "    "	"     L
	DB	0FFH		; "	  "    "    "	"     M
	DB	0FFH		; "	  "    "    "	"     N
	DB	0FFH		; "	  "    "    "	"     O
	DB	0FFH		; "	  "    "    "	"     P
	 IF	DRVVEC
				; Table filled in automatically if
				; using Z34+ drive vector
HIDRV	EQU	$		; Mark end of drive/user table
	 ENDIF		; DRVVEC
;
;-------------------------------
;
; Command line options:
; --------------------
; If any of the following equates are set NO, it prevents their use by
; any user (including the SYSOP) unless the wheel byte has been set for
; SYSOP use.  If running an RCPM, you may wish to say NO for those with
; an asterisk, such as USEF, USERO, USEP and USES to prevent others from
; using them - the wheel byte makes them available for SYSOP use.
;
; NOTE:  For RCPM use, all 5 would normally be set to "NO" to prevent
; remote use, but would be available to the Sysop with the WHEEL byte.
;
USEF	EQU	YES		; *Allow making a local disk copy?
USEO	EQU	YES		; *Allow showing only $SYS files?
USEP	EQU	YES		; *Allow making local printer listing?
USER	EQU	YES		; *Allow disk system reset?
USES	EQU	YES		; *Allow showing all, and $SYS files?

; Above note goes for the following
USEA	EQU	YES		; *Allow specifying attributes 1-4?

;
;-------------------------------
;
; Showing tagged attributes
; -------------------------
; Displaying files with tagged attributes ($R/O, $SYS, $ARC etc.) in an
; in an unique manner so they are easy to find, if present.
;
;	Example:
;		FILENAME.SyS	-  $SYS attribute set
;		FILENAME.doC	-  $SYS and $R/O both set
;		FILENAME.com	-  $SYS, $R/O and $ARC all set
;
; The following equates will permit SD to display the files with tagged
; attributes in lower case letters (a-z) as in example above.
;
USELC	EQU	YES		; Allow lower case letters (a-z)
USELCW	EQU	YES		; *Allow lower case without wheel byte?
;
;
;-------------------------------
;
; Time/date options
; -----------------
; The following equate will get the TIMEON from BYE, if BYE is active.
; The message "Time on system is xx Minutes" will be displayed.
;
TIMEON	EQU	NO		; Yes, gets TIMEON from BYE5
;
; The following equate will permit the date to be displayed using the
; European system DD/MM/YY or the American system MM/DD/YY.  This only
; shows when using 'V' to display version number.
;
EDATE	EQU	NO		; Yes = European, No = American
;
;-------------------------------
;
; If using Z80DOS and you want date stamping support, set the following
; to YES.
;
Z80DOS	EQU	NO
;
;-------------------------------
;
; If want to be able to specify files to be displayed based upon attribute
;	1 thru 4 , set the following to yes
;
FATTRIB	EQU	YES
;

;-------------------------------
;
; Z3CPR options
; -------------
;
ZCPR3P	EQU	NO		; Allow ENV support of MAXDRV,WHEEL,MAXUSR,
				; TCAP REVID/ULINE
NDIRS	EQU	NO		; To display directory names
SHOPUB	EQU	NO		; To display ZRDOS Public Directories
WHLPUB	EQU	NO		; To make SHOPUB wheel dependent
ZRDOS	EQU	NO		; Set to yes if using ZRDOS
Z3DRV	EQU	44		; Offset from ENV location to find drive max
Z3USR	EQU	45		; Offset from ENV location to find user max
Z3WHL	EQU	41		; Offset from ENV location to find wheel address
Z3NDR	EQU	21		; Offset from ENV location to find NDIR address
ZDRVEC	EQU	34H		; Offset from ENV location to find DRVVEC
Z3TCAP	EQU	80H		; Offset from ENV location to find TCAP

;-----------------------------------------------------------------------
;
; Reverse video options
; ---------------------
; The following equate will permit SD to display the files with tagged
; attributes in either reverse video or bright/dim modes.  This will al-
; low any character tagged to be visible, as opposed to the USELD method.
; Up to 7 bytes for enter and exit video modes are provided.  These can
; be easily patched with DDT, etc.
;
	 IF	NOT ZCPR3P
				; Use this equate to control REVID
				; if ARE NOT using ZCPR3+
REVID	EQU	NO		; Yes = inverse or bright/dim display
	 ENDIF

	 IF	ZCPR3P
REVID	EQU	YES		; Video codes will be taken from
				; ENV TCAP if ZCPR3+
	 ENDIF

;------------------------------------------
;
; The following equate will allow a SYSOP to control
; ULINE activation if BYE is active
; Set to YES if you want BYE running to disable underline
; Set to NO if you want ULINE to control underline

BYEULI	EQU	NO

;
; The following equate will highlight/underline the summary line
;
	 IF	NOT ZCPR3P
				; Use this equate to control REVID
				; if ARE NOT using ZCPR3+
ULINE	EQU	NO		; Yes = highlight/underline summary
	 ENDIF	; NOT ZCPR3P

	 IF	ZCPR3P
ULINE	EQU	YES		; ULINE will use SO codes from ENV TCAP
	 ENDIF	
;
;
; Reverse video control bytes
; ---------------------------
; If byte at RVON is 0, simple lower case will be used to display file
; attributes.
;
	 IF	REVID OR ZCPR3P
				; These will be filled in automatically
				; if ZCPR3+

RVON:	DB	0,0,0,0,0,0,0	; Up to 7 characters for ENTER REVERSE
	DB	0		; String Terminator MUST BE 0
;
RVOFF:	DB	0,0,0,0,0,0,0	; Up to 7 characters for EXIT REVERSE
	DB	0		; String Terminator MUST BE 0
	 ENDIF			; REVID OR ZCPR3P
;
; If byte at ULON is 0, no highlighting/underlining will be used in the
; banner line.
;
	 IF	ULINE OR ZCPR3P
				; These will be filled in automatically
				; if ZCPR3+
ULON:	DB	0,0,0,0,0,0,0	; Up to 7 characters for ENTER ULINE
	DB	0		; String Terminator, MUST BE 0
;
ULOFF:	DB	0,0,0,0,0,0,0	; Up to 7 characters for EXIT ULINE
	DB	0		; String Terminator MUST BE 0
	 ENDIF			; ULINE OR ZCPR3P

;
;			end of options
;-----------------------------------------------------------------------
;
; Reference items
; ---------------
RECORD	EQU	36
FRN	EQU	33
FCR	EQU	32
READRN	EQU	33
HDRSIZ	EQU	27
ARCMAR	EQU	26
SBCDE	EQU	52EDH
TMPLT0	EQU	$		; Start of initialization template

	 IF	VLIST
	DB	0
	 ENDIF			; VLIST

	 IF	NOT VLIST
	DB	0FFH
	 ENDIF			; NO VLIST

	DB	'A'		; All-users option flag
	DB	'C'		; File size in records option
	DB	'D'		; Multi-disk option flag

	 IF	USEF
	DB	'F'		; DISK.DIR file output option
	 ENDIF			; USEF

	 IF	NOT USEF
	DB	'F'+80H
	 ENDIF			; NOT USEF

	DB	'H'		; Show areas from current to highest
	DB	'L'		; Display library members flag
	DB	'N'		; No page-pause option flag

	 IF	USEO
	DB	'O'		; To show $SYS files only
	 ENDIF			; USEO

	 IF	NOT USEO
	DB	'O'+80H
	 ENDIF			; NOT USEO

	 IF	USEP
	DB	'P'		; Printer output option
	 ENDIF			; USEP

	 IF	NOT USEP
	DB	'P'+80H
	 ENDIF			; NOT USEP

	DB	'Q'		; To show only non-$ARC files

	 IF	USER
	DB	'R'		; Optional reset of disk system
	 ENDIF			; USER

	 IF	NOT USER
	DB	'R'+80H
	 ENDIF			; NOT USER

	 IF	USES
	DB	'S'		; Include $SYS files
	 ENDIF			; USES

	 IF	NOT USES
	DB	'S'+80H
	 ENDIF			; NOT USES

	DB	'T'		; Primary sort by file type
	DB	'V'		; Show SD version
	DB	'X'		; Alternate alphabetization

	 IF	Z80DOS
	DB	'='		; Look for exact match of date given
	DB	'+'		; Look for files of date GE date given
	DB	'-'		; Look for files of date LT date given
	DB	'!'		; Match with creation date
	DB	'%'		; Match with alteration date
	DB	'@'		; Match with access date
	DB	'Z'		; Do not show dates
	 ENDIF		;Z80DOS

;	 IF	FATTRIB		; Allow spec of file attributes 1-4?
	 IF	USEA AND FATTRIB
	DB	'1'		; Only files with attrib 1
	 ENDIF		;USEA

	 IF	NOT USEA AND FATTRIB
	DB	80H+'1'
	 ENDIF		;NOT USEA

	 IF	USEA AND FATTRIB
	DB	'2'		; Only files woth attrib 2
	 ENDIF		;USEA

	 IF	NOT USEA AND FATTRIB
	DB	80H+'2'
	 ENDIF		;NOT USEA

	 IF	USEA AND FATTRIB
	DB	'3'		; Only files with attrib 3
	 ENDIF		;USEA

	 IF	NOT USEA AND FATTRIB
	DB	80H+'3'
	 ENDIF		;NOT USEA

	 IF	USEA AND FATTRIB
	DB	'4'		; Only files with attrib 4
	 ENDIF		;USEA

	 IF	NOT USEA AND FATTRIB
	DB	80H+'4'
	 ENDIF		;NOT USEA

;	 ENDIF		;FATTRIB
;
; End of option lookup table
;
	DW	OUTBUF		; Next location in output buffer
	DB	128		; # of bytes left in output buffer
	DB	0,'DISK    DIR'	; Output Filename.typ
;
TMPLT1	EQU	$		; End of initialization data template

VERNAME:DB	13,10,'SD',MAIN+'0'
	DB	VER/10+'0',VER MOD 10+'0',' -- '

	 IF	NOT EDATE
	DB	MONTH/10+'0',MONTH MOD 10+'0','/'
	 ENDIF			; NOT EDATE

	DB	DAY/10+'0',DAY MOD 10+'0','/'

	 IF	EDATE
	DB	MONTH/10+'0',MONTH MOD 10+'0','/'
	 ENDIF			; EDATE

	DB	YEAR/10+'0',YEAR MOD 10+'0'

	 IF	Z80DOS
	DB	', Z80DOS'
	 ENDIF

	 IF	ZCPR3P 		;
	DB	', ZCPR3+/ARC/ARK Version'
	 ENDIF			; ZCPR3 


	DB	0
;
;-----------------------------------------------------------------------
;			 Program starts here
;-----------------------------------------------------------------------
;
START:	LXI	H,0
	DAD	SP		; HL=old stack
	SHLD	STACK		; Save it
	LXI	SP,STACK	; Get new stack

	 IF	ZCPR3P
	LHLD	Z3ENV		; Get ENV address
	PUSH	H
	LXI	D,Z3DRV		; Point to max drv byte
	DAD	D
	SHLD	Z3DRVL		; Save location away, only used if DRVVEC
				; equate YES
	POP	H
	PUSH	H
	LXI	D,Z3USR		; Point to maxuser byte
	DAD	D
	SHLD	Z3USRL		; Save location away
	POP	H
	PUSH	H
	LXI	D,Z3WHL		; Point to address pointer of wheel
	DAD	D
	MOV	E,M		; Get address of wheel byte
	INX	H
	MOV	D,M
	XCHG
	SHLD	Z3WHLL		; Save it away
	POP	H
	PUSH	H		; ENV pointer back
	LXI	D,Z3TCAP
	DAD	D		; point to TCAP
	MOV	A,M
	CPI	' '+1		; Any TCAP?
	JC	NOSTND		; C=NO
	LXI	D,17H		; And then to CLS string
	DAD	D
	CALL	VIDSKP		; Move on to SO string
	CALL	VIDSKP
	CALL	VIDSKP
	MOV	A,M
	ORA	A
	JZ	NOSTND		; Z=no SO string
	LXI	D,RVON		; Fill in out data base
	LXI	B,ULON
MOVSTO:	MOV	A,M
	ORA	A
	JZ	OSTNDO		; Z=done
	STAX	B
	STAX	D
	INX	H
	INX	D
	INX	B
	JMP	MOVSTO
OSTNDO:	INX	H		; Point to SI string
	MOV	A,M
	ORA	A
	JZ	NOSTND		; Z=none
	LXI	D,RVOFF		; Fill our data base in
	LXI	B,ULOFF
MOVSTD:	MOV	A,M
	ORA	A
	JZ	NOSTND
	STAX	D
	STAX	B
	INX	H
	INX	D
	INX	B
	JMP	MOVSTD

; FROM VLIB Module Name:  VIDA
; Author:  Richard Conn
; VLIB  Version Number:  1.1
; Module Version Number:  1.1
;
;  VIDSKP - Skip over video string pted to by HL; pt to byte after string
;
vidskp:
	MOV	A,M		;get next char
	INX	H		;pt to next
	ORA	A		;done if zero
	RZ
	CPI	'/'		;literal value?
	JNZ	VIDSKP		;continue if not
	INX	H		;pt to after literal value
	JMP	VIDSKP
NOSTND:
	POP	H
	 ENDIF		; ZCPR3P

	 IF	DRVVEC AND ZCPR3P
	PUSH	H
	LXI	D,ZDRVEC	; Add offset to DRVVEC
	DAD	D
	MOV	E,M		; Get the vector
	INX	H
	MOV	D,M
	LHLD	Z3USRL
	MOV	B,M		; Get MAXUSER from ENV

	LXI	H,LODRV		; Fill in our drive table
	MVI	C,10H		; Do 16 drives
STDRVV:
	MOV	A,D		; Shift the vector right
	ORA	A
	RAR
	MOV	D,A
	MOV	A,E
	RAR
	MOV	E,A
	MVI	M,0FFH		; Assume no drive
	JNC	NDRVV
	MOV	M,B		; Drive found, load maxuser allowed
NDRVV:	INX	H
	DCR	C
	JNZ	STDRVV
	POP	H
	 ENDIF		;DRVVEC AND ZCPR3P

	 IF	NDIRS
	LHLD	Z3ENV		; Get Environment Address
	LXI	D,Z3NDR		; Point to named directory space
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M		; DE Now contains NDR Address
	INX	H
	MOV	A,M
	ADI	1
	STA	NUMDIR		; Maximum number of entries plus 1
	XCHG
	SHLD	NAMADR		; Keep Address for later
	 ENDIF			; NDIRS
;
; Clear Public User Areas so they can be displayed
;
	 IF	SHOPUB
	LHLD	0109H		; Get Environment Address
	MVI	D,0
	MVI	E,07EH
	DAD	D		; HL Points to Public Drive Byte
	MOV	A,M		; Get public DRV byte
	STA	PUBDRV
	INX	H
	MOV	A,M		; Get public USR byte
	STA	PUBUSR
	 ENDIF			; SHOPUB

;	 IF	WHLPUB

	 IF	ZCPR3P AND WHLPUB
	PUSH	H
	LHLD	Z3WHLL		; Point to ENV
	MOV	A,M		; Get wheel
	POP	H
	 ENDIF		;ZCPR3P

	 IF	NOT ZCPR3P AND WHLPUB
	LDA	WHLOC		; Load wheel byte
	 ENDIF		; NOT ZCPR3P

	 IF	WHLPUB
	ORA	A
	JZ	NOPUB
	 ENDIF			; WHLPUB

	 IF	SHOPUB
	DCX	H
	MVI	A,0		; Clear Public Areas temporarily
	MOV	M,A
	INX	H
	MOV	M,A
	 ENDIF		; SHOPUB

	 IF	WHLPUB AND SHOPUB
NOPUB:	DS	0
	 ENDIF			; WHLPUB
;
; (WHLPUB enabled, the R option is redundant)
;
;	 ENDIF			; SHOPUB
;
; See if help is wanted
;
	LXI	H,FCB+1		; Filename
	MOV	A,M		; 1st Character

	 IF	NOT ZCPR3P
	CPI	'?'		; Is it "?"
	JNZ	INIT		; No, Continue
	INX	H		; Yes, Next Char
	MOV	A,M		; 2nd Character
	CPI	' '		; Is it " "
	JNZ	INIT		; If not, did not want help guide
	LDA	FCB+9		; Check for any extent
	CPI	' '
	JZ	HELPME		; If none, wanted help
	 ENDIF		; NOT ZCPR3P

	 IF	ZCPR3P
	CPI	'?'		; Is it "?"
	JNZ	CHKSLH		; No, Continue
	INX	H		; Yes, Next Char
	MOV	A,M		; 2nd Character
	CPI	' '		; Is it " "
	JNZ	INIT		; If not, did not want help guide
	LDA	FCB+9		; Check for any extent
	CPI	' '
	JZ	HELPME		; If none, wanted help
	JMP	INIT
CHKSLH: CPI	'/'		; Is it a slash?
	JNZ	INIT
	INX	H
	MOV	A,M		; two slashes gets help
	CPI	'/'
	JZ	HELPME
	 ENDIF		; ZCPR3P

;
; Zero out the entire initialization data area
;
INIT:	LXI	H,DATA0		; Point to start of initialized data area
	PUSH	H		; Save for non-zero filling later
	MVI	C,DATA1-DATA0	; Data area length
	XRA	A		; Clear the "A" register

ZFILL:	MOV	M,A		; Null the address
	INX	H		; Pointer+1
	DCR	C		; One less to go
	JNZ	ZFILL

	 IF	SHOPUB		; In order for the Public Directories
	MVI	A,0FFH		; To be displayed, Option 'R' must be
	STA	ROPFLG		; Forced true.
	 ENDIF			; SHOPUB
;
; Now copy non-zero initialization data from the template area
;
	POP	H		; Load A(DATA0)
	LXI	D,TMPLT0	; Load A(TMPLT0)
	MVI	C,TMPLT1-TMPLT0	; Template area length

NZFILL:	LDAX	D		; Load template byte
	MOV	M,A		; Move to data area
	INX	D		; Next location to store data
	INX	H		; Next location to get data
	DCR	C		; One less to go
	JNZ	NZFILL

	LXI	H,0		; Clear HL

	 IF	ZRDOS
	MVI	C,ZRDVER	; Get ZRDOS version
	CALL	BDOS
	MOV	A,L		; ZRDOS Version #
	STA	ZRDFLG		; Save it
	 ENDIF			; ZRDOS

	MVI	C,CPMVER	; Get CP/M  version
	CALL	BDOS
	MOV	A,L		; CP/M Version number
	STA	VERFLG		; Save it
	STA	SOHFLG		; Prevents initial unwanted CRLF
	CPI	20H		; Set carry if CP/M 1.4
	PUSH	PSW		; Save for BYE test
	MVI	E,0FFH		; Load current user number if CP/M 2
	MVI	C,STUSER	; Fall through with A=0 if not
	CNC	CPM		; Only if CP/M 2.0 or ZRDOS
	STA	OLDUSR		; Initial user number
	STA	NEWUSR		; New user = Initial user
	STA	BASUSR		; Directories
	POP	PSW		; Recover Version Flag
	MVI	E,241		; Special BYE5xx Call
	MVI	C,STUSER	; Returns 77 if BYE5xx active
	CNC	CPM		; BYE5nn not on CP/M 1.4 system
	SUI	77		; Return code expected
	STA	BYEACT		; BYEACT = 0, BYE5nn active

	 IF	TIMEON
	CALL	TIME
	 ENDIF			; TIMEON

	 IF	ZCPR3P
	LDA	FCB+13		; Point to command line buffer (CLB)
	STA	NEWUSR
	 ENDIF			; ZCPR3P

	 IF	NOT ZCPR3P
	LXI	H,TBUF+1	; Point to command line buffer (CLB)
	MOV	A,M		; CLB Character
	CPI	'['		; CP/M 3.0 style delimiter
	JZ	CLOK		; (may follow command in CP/M 3.0)
	INX	H		; CLB pointer +1
	ORA	A		; Terminator?
	JNZ	CLOK		; No, continue
	MOV	M,A		; Yes, set 2nd terminator

CLOK:	LXI	D,FCB		; A(file control block)
	CALL	FNAME		; Process filename.typ
	MOV	A,B		; Disk specification
	CPI	0FFH		; Current?
	JZ	CLUS		; Yes
	STAX	D		; No, set disk specification

CLUS:	MOV	A,C		; User specification
	CPI	0FFH		; Current?
	JZ	CLNON		; Yes
	STA	NEWUSR		; No, set user specification
	STA	BASUSR
	 ENDIF			; NOT ZCPR3P

CLNON:	MVI	C,CURDSK
	CALL	CPM		; Load current disk number
	STA	OLDDSK		; Save for reset if needed
	INR	A		; Adjust
	STA	OUTFCB		; Save directory file drive
	LXI	H,FCB		; A(file control block)
	MOV	A,M		; Load directory search drive
	ORA	A		; Any specified?
	JNZ	START1		; Yes, skip next routine
	LDA	OLDDSK		; Otherwise, get default disk
	INR	A		; Adjust
	JMP	START2

START1:	PUSH	PSW		; Save status
	MVI	A,1
	STA	DRVFLG		; Set DRVFLG = 1
	POP	PSW		; Load status

START2:	MOV	M,A		; Absolute drive code in directory FCB
;
; If at least one option is allowed,  scan command line for the option
; field delimiter. The option field delimiter is considered valid only
; if it is preceded by at least 1 space  (otherwise may be part of the
; directory filename).	 Any unrecognized options/illegal user numbers
; will be flagged.(We scan the command line buffer rather than the 2nd
; default FCB because all 8 options + 2 digit user number will not fit
; in the 2nd FCB name field).
;
	LXI	H,TBUF		; CLB pointer
	MOV	B,M		; CLB length
;
; Search for valid command line delimiter, if not found, assume no
; options.  Show help menu if single "?" entered.
;
SCNDOL:	INX	H		; CLB PTR+1
	DCR	B		; CLB LEN-1
	JM	DOPTN		; Exit if command line buffer empty
	MOV	A,M		; CLB Character
	CPI	'['		; CPM+ style delimiter?
	JZ	OPTDLM		; Yes
	CPI	'$'		; CPM2 style delimiter?
	JZ	SPB4		; Yes
	CPI	'/'		; ZCPR style delimiter?
	JNZ	SCNDOL		; No

SPB4:	DCX	H		; '$' found, space must precede
	MOV	A,M		; Previous character
	INX	H
	CPI	' '
	JNZ	SCNDOL		; No space, ignore '$'
;
; Valid delimiter found.  Scan the rest of the buffer for options.
; Errors past this point cause an abort.
;
OPTDLM:	XCHG			; DE = CLB pointer (swap pointers)

SCNOPT:	INX	D		; CLB PRT+1
	DCR	B		; CLB LEN-1
	JM	DOPTN		; If option field exhausted, exit

SCNAGN:	LDAX	D		; Load option character
	CPI	' '		; Is it " "?

	 IF	Z80DOS
	JZ	LOKDAT		; Space, go look for date info
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	JZ	SCNOPT		; Yes, Ignore it
	 ENDIF		;NOT Z80DOS

	CPI	']'		; CPM+ style terminator?
	JZ	SCNOPT		; Options may follow terminator
	LXI	H,OTBL-1	; OTBL pointer
	MVI	C,OEND-OTBL+1	; OTLB length

NOMACH:	INX	H		; OTLB pointer+1
	DCR	C		; OTLB length-1
	JZ	CLERR		; Error if option table end

	 IF	WHEEL		; ZCMD/ZCPR2/ZCPR3?
	PUSH	PSW		; Save "A" value
	 ENDIF		; WHEEL

	 IF	ZCPR3P AND WHEEL
	PUSH	H
	LHLD	Z3WHLL		; Point to ENV
	MOV	A,M		; Get wheel
	POP	H
	 ENDIF		;ZCPR3P AND WHEEL

	 IF	NOT ZCPR3P AND WHEEL
	LDA	WHLOC		; Load wheel byte
	 ENDIF		; NOT ZCPR3P AND WHEEL

	 IF	WHEEL
	ORA	A		; Set Flags
	JZ	NOMAC1		; Not set, so forget it
	MOV	A,M		; Load the table option
	 ENDIF		;WHEEL

	 IF	FATTRIB AND WHEEL
	ANI	7FH
	 ENDIF		;FATTRIB

	 IF	NOT FATTRIB AND WHEEL
	ANI	5FH		; Allow the option
	 ENDIF		;NOT FATTRIB

	 IF	WHEEL
	MOV	M,A		; Stuff back in table

NOMAC1:	POP	PSW		; Restore "A" value
	 ENDIF			; WHEEL

	CMP	M		; Compare with table entry
	JNZ	NOMACH		; If no match, check next
	MVI	M,0		; Else, activate the option
	JMP	SCNOPT		; Continue scan
;.....
;
; Playback the command line up to the character that stopped the scan
; and exit
;
CLERR:	XRA	A		; Clear "A" register
	INX	D		; Tag end of CLB
	STAX	D		; With terminator
	CALL	CRLF		; New line
	LXI	D,ERRMS2	; 'Error'
	CALL	PUTS
	LXI	D,ERRTAG	; '->'
	CALL	PUTS
	LXI	H,TBUF+1	; Playback CLB to error point

CLELP:	MOV	A,M		; Character
	ORA	A		; Zero?
	JZ	CLEX		; Yes, exit
	CALL	PUTCHR		; No, output to console
	INX	H		; CLB pointer+1
	JMP	CLELP		; Continue

CLEX:	MVI	A,'?'		; Tag line with a '?' field
	CALL	PUTCHR
	CALL	CRLF		; New Line

	 IF	SHOPUB
	CALL	RSTPUB
	 ENDIF			; SHOPUB

;;;;;	JMP	0000H		; And reset CCP, all finished
	JMP	EXIT2

	 IF	Z80DOS
LOKDAT:	INX	D
	LDAX	D		; Check to see if * was entered meaning
	CPI	'*'		; use current system time
	JNZ	LOKDAT1		; NZ=no
	CALL	SYSTIM		; Get the current system time
	JMP	LOKDAT2		; And continue
LOKDAT1:
	call	eval10		; convert month to binary
	ORA	A		; month can't be 0
	JZ	BADDATE
	CPI	13		 ; can't be >12
	JNC	BADDATE
	STA	MONTHS		; store month
	LDAX	D		; End of input line?
	ORA	A
	JZ	BADDATE		; Z=yes, a no-no
	INX	D		; Skip /
	call	eval10		; convert
	ORA	A		; day can't be 0
	JZ	BADDATE
	CPI	32		; or >31
	JNC	BADDATE
	STA	DAYS1		; store day
	LDAX	D		; End of input line?
	ORA	A
	JZ	BADDATE		; Z=yes, a no-no
	INX	D		; Skip /
	call	eval10
	STA	YEARS1		; store year
	PUSH	D
	LXI	H,YEARS1	; pt at date
	CALL	BIN2JUL		; get jul date in hl
	POP	D
LOKDAT2:
	CALL	DOPLMI		; Process any + or - operators
	SHLD	DATCHK
	LDAX	D
	CPI	' '		; Next char a space?
	JNZ	DOPTN		; NZ=no, continue
;	LHLD	DATCH1
;	MOV	A,H
;	ORA	L
;	JZ	CLERR
	LHLD	DATCHK		; set last input date=first input date
	SHLD	DATCH1
	JMP	LOKDAT		; And go try to get some more dates

SYSTIM:
	PUSH	D		; Save pointer to input line
	LXI	D,ASCII		; Tell Z80DOS to put time here
	MVI	C,105
	CALL	5		; Go get the time
	LXI	D,ASCII
	LDAX	D		; Get LSB of JDAY
	MOV	L,A
	INX	D
	LDAX	D		; Get MSB of JDAY
	MOV	H,A
	POP	D		; Get input pointer back
	INX	D		; Point ot next
DOPLMI:	LDAX	D
	CPI	'-'		; Does operator want a subtraction?
	JZ	SUBDAT
	CPI	'+'		; an add?
	RNZ			; NZ=no
	MVI	A,1
	STA	DATPLS
	JMP	OPDAT
SUBDAT:	XRA	A
	STA	DATPLS
OPDAT:	INX	D
	CALL	EVAL10		; Yes go get number
	PUSH	D
	MOV	E,A
	XRA	A
	MOV	D,A
	LDA	DATPLS		; Chec if adding
	ORA	A
	JNZ	DTIPLS		; NZ=yes
	MOV	A,L
	SBB	E
	MOV	L,A
	MOV	A,H
	SBB	D
	MOV	H,A
	POP	D
	RET
DTIPLS:
	DAD	D
	POP	D
	RET


EVAL10:
	XRA	A
	MOV	B,A		; B holds current number input
EVAL1:	LDAX	D		; Get input
	CPI	'/'		; / is seperator
	JZ	DEVAL10		; Z= done
	CPI	' '
	JZ	DEVAL10
	CPI	'+'
	JZ	DEVAL10
	CPI	'-'
	JZ	DEVAL10
	ORA	A
	JZ	DEVAL10		; Z= at end of line
	SUI	'0'		; Verify ascii 0-9
	JC	BADDATE
	CPI	10
	JNC	BADDATE
	INX	D
	MOV	C,A		; Old*10+new
	MOV	A,B
	ADD	A
	ADD	A
	ADD	B
	ADD	A
	ADD	C
	MOV	B,A		; B has current
	JMP	EVAL1
DEVAL10:
	MOV	A,B
	RET
BADDATE:
	PUSH	D
	LXI	D,BDTMES
	CALL	PUTS
	POP	D
	JMP	CLERR
BDTMES:
	DB	13,10,13,10
	DB	' *** Illegal Date Entered, form MM/DD/YY or MM/D/YY or M/DD/YY'
	DB	13,10,13,10,0

;
;	Binary to Julian Date routine.
;
; >>	hl -> yr,mo,da in bin
; << 	hl = Julian date
;
;	Convert to 8080 code from the original
;	BCD2JUL
;	by Bridger Mitchel and Howard Goldstein - 4/16/88
;
BIN2JUL:
	PUSH	PSW
	PUSH	B
	PUSH	D
	MOV	A,M		; A=yr
	INX	H
	MOV	C,M		;c = mo
	INX	H
	PUSH	H		;save ptr to day
	PUSH	PSW		;save year
;
; set hl= initial julian value of 77/12/31
;
	LXI	H,0
	SUI	78
	JZ	B2JUL3
	JNC	B2JUL0
	ADI	100		;<78, assume next century
B2JUL0:	MOV	B,A		;b = # yrs > 78
	MVI	A,1		;init modulo 4 counter
	LXI	D,365		;days/yr
B2JUL1:	DAD	D		;calc julian val. of  (yr/01/01 - 1)
	INR	A
	ANI	3		;every 4 yrs,
	JNZ	B2JUL2
	INX	H		;..add 1 for leap year
B2JUL2:	DCR	B
	JNZ	B2JUL1
;
; 	hl now = # days in years before current year
;
B2JUL3:	POP	PSW
	ANI	3		;if current yr == leap year
	JNZ	B2JUL5
	MOV	A,C
	CPI	3		;..and mo >= march
	JC	B2JUL5
	INX	H		;..add the extra day (Feb 29)
;
B2JUL5:	MOV	B,C		; b = month = # months +1 to sum
	LXI	D,DPERMO	;point at table
	JMP	B2JUL7
;
B2JUL6:	CALL	ADDHL		;add # days in this month
	INX	D		;bump tbl ptr
B2JUL7:	DCR	B
	JNZ	B2JUL6
;
	POP	D		;ptr to day
	CALL	ADDHL
	POP	D
	POP	B
	POP	PSW
	RET

ADDHL:	LDAX	D		;add day of current month
;
ADDA2HL:
	ADD	L
	MOV	L,A
	RNC
	INR	H
	RET

;
; table of days per month (non-leap year)
;

DPERMO:	DB	31		;jan
	DB	28		;feb
	DB	31		;mar
	DB	30		;apr
	DB	31		;may
	DB	30		;jun
	DB	31		;jul
	DB	31		;aug
	DB	30		;sep
	DB	31		;oct
	DB	30		;nov
	DB	31		;dec

	 ENDIF		;Z80DOS



;.....
;
; Options input or not specified, and associated flags set.
;
; If D-option, swap error vectors, then start at drive A if no
; drive specified on command line.
;
DOPTN:
	 IF	Z80DOS
	LHLD	DATCH1
	MOV	A,H
	ORA	L
	JZ	DOPTN1
	XCHG
	LHLD	DATCHK
	ORA	A
	DW	SBCDE
	JZ	CLERR
	JNC	DOPTN1
	LHLD	DATCHK
	SHLD	DATCH1
	XCHG
	SHLD	DATCHK
DOPTN1:
	 ENDIF		; Z80DOS

	LDA	DOPFLG		; If multi-disk flag set,
	ORA	A		; Need to set error traps
	JNZ	AOPTN		; If not, go check A-option
	CALL	SWAPEM		; Swap BDOS error vector tables
	LDA	DRVFLG		; Directory drive specified?
	ORA	A
	JNZ	AOPTN		; No, don't reset
	MVI	A,1		; Yes, Set FCB to A:
	STA	FCB
;
; Start user at 0 if A-option selected without U-option
;
AOPTN:	LDA	AOPFLG		; Check All-users option
	ORA	A
	JNZ	COPTN		; Jump if not
	LDA	HOPFLG		; Asking to show all from current?
	ORA	A
	JZ	COPTN		; If yes, do not reset "A" to zero
	XRA	A		; No, Start at user 0
	STA	NEWUSR
	STA	BASUSR
;
; Test if C-option and set indicator character 'r', else 'k'
;
COPTN:	LDA	COPFLG		; File sizes wanted in records?
	ORA	A
	MVI	A,'k'
	JNZ	COPTN1		; Jump if not
	MVI	A,'r'

COPTN1:	STA	FSIZEC		; Indicator char after size
;
; Determine whether horizontal or vertical alphabetization.
; If X-option selected, use alternate format.
; Set flag and fence character accordingly.
;
	LDA	XOPFLG		; Check for X option
	ORA	A
	LDA	VFLAG		; Get vertical flag
	JNZ	XOPTN1		; Jump if no X option
	CMA			; Else swap vertical/horizontal indicator
	STA	VFLAG		; And change VFLAG other way

XOPTN1:	DS	0
;
; The following optionally resets the disk system.  The reset must
; be done OUTSIDE of the multiple drive loop if the $F option is
; enabled because CP/M 1.4 will clobber the DMA buffer on reset.
;
	LDA	ROPFLG		; Reset Disk?
	ORA	A
	JNZ	NOOPT
;
; Disk reset if R option entered on command line
;
	MVI	C,RESET
	CALL	CPM
;
; Validate drive code and user area numbers from the drive table
;
NOOPT:	LXI	D,DRUMSG	; Get drive/user error message
	PUSH	D
	LDA	FCB		; Get directory drive code
	DCR	A		; Normalize to range of 0-31
	CPI	HIDRV-LODRV	; Compare with max drives on-line
	JNC	ERXIT		; Drive error exit if out of range

;	 IF	MAXDRV		; Look for MXDRV

	 IF	ZCPR3P AND MAXDRV
	LHLD	Z3DRVL		; Point to ENV as loaded
	 ENDIF		;ZCPR3P AND MAXDRV

	 IF	NOT ZCPR3P AND MAXDRV
	LXI	H,MXDRV		; A(MXDRV) to HL
	 ENDIF		;NOT ZCPR3P AND MAXDRV

	 IF	MAXDRV
	MOV	L,M		; (MXDRV) to L
	 ENDIF			; MAXDRV

;	 IF	MAXDRV

	 IF	NOT ZCPR3P AND MAXDRV
	INX	H		; +1
	 ENDIF		; NOT ZCPR33 AND MAXDRV

	 IF	MAXDRV AND NOT DRVVEC
	CMP	L		; Check it
	JNC	ERXIT		; Oops if not bigger
	 ENDIF			; MAXDRV AND NOT DRVVEC
;
; Skips any drives marked 0FFh, some computers do not have contiguous
; drives, such as Heath H89, etc.
;
	MOV	E,A		; Drive code = table index
	MVI	D,0
	LXI	H,LODRV		; DUTBL Pointer
	DAD	D		; DUTBL Pointer+INDEX
	MOV	A,M		; User Number
	ORA	A		; Set Status
	JM	NDSK		; If negative, ignore drive

;	 IF	WHEEL

	 IF	ZCPR3P AND WHEEL
	PUSH	H
	LHLD	Z3WHLL		; Point to enviorment
	MOV	A,M		; Get it
	POP	H
	 ENDIF		;ZCPR3P AND WHEEL

	 IF	NOT ZCPR3P AND WHEEL
	LDA	WHLOC		; Get wheel byte
	 ENDIF		;NOT ZCPR3P AND WHEEL

	 IF	WHEEL
	ORA	A		; Check it
	JZ	USRCK		; If reset, restrict user
	MVI	A,MXZUSR	; If set, max user = MXZUSR
	JMP	USRCK1
	 ENDIF			; WHEEL

USRCK:	LXI	H,LODRV		; DUTBL PTR
	DAD	D		; DUTLB PTR+INDEX
	MOV	A,M		; Load max user for this drive

	 IF	MAXUR		; Use low memory values if smaller
	MOV	H,A		; Current value of MAXUSR
	 ENDIF		;MAXUR

	 IF	ZCPR3P AND MAXUR
	PUSH	H
	LHLD	Z3USRL		; Point to ENV
	MOV	A,M		; Get user
	POP	H
	 ENDIF		;ZCPR3P AND MAXUR

	 IF	NOT ZCPR3P AND MAXUR
	LDA	MXUSR		; Alternate value
	 ENDIF		;NOT ZCPR3P AND MAXUR

;	 ENDIF			; MAXUR

	 IF	MAXUR AND NOT ZCPR3P
	SBI	1		; MAXUSR is really maximum user+1
	 ENDIF			; MAXUR AND NOT ZCPR3P

	 IF	MAXUR
	CMP	H		; Compare the two
	JNC	USRCK1		; OK if MAXU <= table value
	STA	MAXUSR		; Else replace it
	 ENDIF			; MAXUR

USRCK1:	MOV	B,A		; Save max user for later testing
	ANI	1FH		; Insure in range 0-31
	STA	MAXUSR		; Save it for later
	LXI	H,NEWUSR	; Point to directory user area
	CMP	M		; Compare with the maximum
	JC	ERXIT		; User number illegal, error exit
	POP	D		; Destroy error message pointer
	MOV	A,B		; Check to see if this drive
	ORA	A		; Has been mapped out
	JM	NDSK		; Yes, skip this drive
	LXI	H,FCB+1		; No, point to name
	MOV	A,M		; Any name specified?
	CPI	'$'		; Delimiter?
	JZ	WCD		; Yes, All files
	CPI	'/'		; Unix/ZCPR3 delimiter?
	JZ	WCD		; Yes, All files
	CPI	'['		; CP/M+ delimiter?
	JZ	WCD
	CPI	' '		; No, Filename specified
	JNZ	GOTFCB
;
; No FCB - make FCB all '?'
;
WCD:	MVI	B,11		; Filename+typ length

QLOOP:	MVI	M,'?'		; Store "?" in FCB
	INX	H		; FCB pointer+1
	DCR	B		; FCB length-1
	JNZ	QLOOP		; Continue

GOTFCB:	MVI	A,'?'		; Force wild extent
	STA	FCB+12
	CALL	SETSRC		; Set DMA for BDOS media change check
	LXI	H,FCB		; Point to FCB drive code for directory
	MOV	E,M		; Load drive code from FCB
	DCR	E		; Normalize drive code for select
	MVI	C,SELDSK	; Select directory drive to retrieve
	CALL	CPM		; The proper allocation vector
	CALL	CKVER		; Check version
	JC	V14		; Pre-2.x...get parameters the 1.4 way
	MVI	C,DSKPAR	; If 2.2 or MP/M...request DPB
	CALL	BDOS
	INX	H
	INX	H
	MOV	A,M		; Load block shift
	STA	BLKSHF		; Block Shift
	INX	H		; Bump to block mask
	MOV	A,M		; Load block mask
	STA	BLKMSK		; Block Mask
	INX	H
	INX	H
	MOV	E,M		; Get maximum block #
	INX	H
	MOV	D,M
	XCHG
	SHLD	BLKMAX		; Maximum Block #
	XCHG
	INX	H
	MOV	E,M		; Load directory size
	INX	H
	MOV	D,M
	XCHG
	JMP	FREE

V14:	LHLD	BDOS+1		; Get parameters 1.4 style
	MVI	L,3BH		; Point to directory size
	MOV	E,M		; Get it
	MVI	D,0		; Force high order to 0
	PUSH	D		; Save for later
	INX	H		; Point to block shift
	MOV	A,M		; Fetch
	STA	BLKSHF		; Save
	INX	H		; Point to block mask
	MOV	A,M		; Fetch it
	STA	BLKMSK		; And save it
	INX	H
	MOV	E,M		; Get maximum block #
	MVI	D,0
	XCHG
	SHLD	BLKMAX		; Save it
	POP	H		; Restore directory size
	JMP	FREE20		; Calculate free space from alloc vector
;
; Calculate number of K free on selected drive now so the FREE figure
; will not reflect either creation or additions to the DISK.DIR file.
; Note: This routine will not always function correctly as coded.  To
; insure the proper calculation when the $F option is specified and
; cataloging multiple disks on a single drive, you should do a CTL-C
; AFTER the disk to be cataloged has been readied.
;
FREE:	SHLD	DIRMAX		; Save max number of directory entries
	LDA	VERFLG		; Check version number
	CPI	30H		; CP/M 3.0?
	JC	FREE20		; No, Use old method
	LDA	FCB		; Load drive number
	DCR	A		; Normalize
	MOV	E,A		; Use compute free space BDOS call
	MVI	C,46		; Calculate free space
	CALL	CPM
	MVI	C,3		; Answer is a 24-bit integer

FRE3L1:	LXI	H,TBUF+2	; Answer in 1st 3 bytes of TBUF
	MVI	B,3		; Convert from records to k
	ORA	A		; By dividing by 8

FRE3L2:	MOV	A,M		; LS byte record count
	RAR			; /2
	MOV	M,A		; Replace
	DCX	H		; Next byte record count
	DCR	B		;
	JNZ	FRE3L2		; Loop for 3 bytes
	DCR	C
	JNZ	FRE3L1		; Shift 3 times
	LHLD	TBUF		; Now get result in k
	JMP	SAVFRE		; Save Free Space

FREE20:	MVI	C,DSKALL	; Allocation vector address
	CALL	BDOS
	XCHG
	LHLD	BLKMAX		; Max Block Number
	INX	H
	LXI	B,0		; Init block count = 0

GSPBYT:	PUSH	D		; Save allocation address
	LDAX	D
	MVI	E,8		; Set to process 8 blocks

GSPLUP:	RAL			; Test bit
	JC	NOTFRE
	INX	B

NOTFRE:	MOV	D,A		; Save bits
	DCX	H		; Count down blocks
	MOV	A,L
	ORA	H
	JZ	ENDALC		; Quit if out of blocks
	MOV	A,D		; Restore bits
	DCR	E		; Count down 8 bits
	JNZ	GSPLUP		; Do another bit
	POP	D		; Bump to next byte of allocation vector
	INX	D
	JMP	GSPBYT		; Process it

ENDALC:	POP	D		; Clear stack of allocation vector pointer
	MOV	L,C		; Copy blocks to HL
	MOV	H,B
	LDA	BLKSHF		; Load block shift factor
	SUI	3		; Convert from records to k
	JZ	SAVFRE		; Skip shifts if 1k blocks return free in HL

FREKLP:	DAD	H		; Multiply blocks by k/block
	DCR	A
	JNZ	FREKLP
;
SAVFRE:	SHLD	FREEBY		; Save free space for output later
	XCHG
	LHLD	TOTFRE
	DAD	D
	SHLD	TOTFRE
;
; Reenter here on subsequent passes while in the all-users mode
;
SETTBL:	LHLD	DIRMAX		; Load directory maximum size
	INX	H		; Directory size is DIRMAX+1
	DAD	H		; Double directory size
	LXI	D,ORDER		; Too get order table size
	DAD	D		; Allocate order table
	SHLD	TBLOC		; Name tbl begins where order tbl ends
	SHLD	NEXTT
	XCHG
	LHLD	BDOS+1		; Insure we have room to continue
	MOV	A,E
	SUB	L
	MOV	A,D
	SBB	H
	JNC	OUTMEM
	CALL	CKVER		; Set carry if pre-CP/M 2
	LDA	NEWUSR		; Load directory user area
	MOV	E,A
	MVI	C,STUSER	; Get the user function
	CNC	CPM		; Set new user number if CP/M 2
;
; Look up the FCB in the directory
;
	MVI	A,'?'		; Check for wild FCB extent
	LXI	H,FCB+12
	MOV	M,A		; Match all extents
	INX	H
	MOV	M,A		; Match all S1 bytes
	INX	H
	MOV	M,A		; Match all S2 bytes
	LXI	H,0
	SHLD	COUNT		; Initialize match counter
	SHLD	TOTFIL		; "  total file counter
	SHLD	TOTSIZ		; "  total size counter
	CALL	SETSRC		; Set DMA for directory search
	MVI	C,SRCHF		; Load 'search first' function
	JMP	LOOK		; Go search for 1st match
;
; Read more directory entries
;
MORDIR:	MVI	C,SRCHN		; Search next function

LOOK:	LXI	D,FCB		; A(file control block)
	CALL	CPM		; Read directory entry
	INR	A		; End (0FFH)?
	JZ	SPRINT		; Yes, sort & print what we have
;
; Point to directory entry
;
	DCR	A		; Undo previous INR A
	ANI	3		; Make modulus 4
	ADD	A		; Multiply
	ADD	A		; By 32 because
	ADD	A		; Each directory
	ADD	A		; Entry is 32
	ADD	A		; Bytes long
	LXI	H,TBUF+1	; Point to buffer (skip to FN/FT)
	ADD	L		; Point to entry

	 IF	FATTRIB
	MOV	L,A		; HL now point to file name
	LDA	ONEFLG		; Looking for only attribute 1?
	ORA	A
	JNZ	NOTONE		; NZ=no
	MOV	A,M
	ORA	A
	JP	MORDIR		; P=not attr 1
NOTONE:	INX	H
	LDA	TWOFLG		; Only attribute 2?
	ORA	A
	JNZ	NOTTWO		; NZ=no
	MOV	A,M
	ORA	A
	JP	MORDIR		; P=not attr 2
NOTTWO:	INX	H
	LDA	THRFLG		; Only attrib 3?
	ORA	A
	JNZ	NOTTHR		; NZ=no
	MOV	A,M
	ORA	A
	JP	MORDIR		; P= not attr 3
NOTTHR:	INX	H
	LDA	FORFLG		; Only attr 4?
	ORA	A
	JNZ	NOTFOR		; NZ=no
	MOV	A,M
	ORA	A
	JP	MORDIR		; P= not attr 4
NOTFOR:	MOV	A,L
	ADI	6
	 ENDIF		; FATTRIB

	 IF	NOT FATTRIB
	ADI	9		; Point to sys byte
	 ENDIF		; NOT FATTRIB

	MOV	L,A		; Save (can't carry to H)
	LDA	QOPFLG		; Find only non-$ARC files?
	ORA	A
	JNZ	OSYS		; No, check for only $SYS files
	INX	H		; Yes, get the archive byte
	MOV	A,M
	DCX	H
	ORA	A		; Check bit 7 for $ARC file
	JM	MORDIR		; If set, ignore this filename

OSYS:	LDA	OOPFLG		; Find only $SYS files?
	ORA	A
	JNZ	CKSYS
	MOV	A,M		; Yes, get system byte
	ORA	A		; Check bit 7 for $SYS file
	JP	MORDIR		; If not set, ignore this filename
	JMP	SYSFOK		; Else check for a match

CKSYS:	LDA	SOPFLG		; Did user request $SYS files?
	ORA	A
	JZ	SYSFOK		; If yes, exit
	MOV	A,M		; Get system byte back
	ORA	A		; Check bit 7 for $SYS file
	JM	MORDIR		; Skip that file

SYSFOK:	MOV	A,L		; Go back now
	SUI	10		; Back to user number (allocation flag)
	MOV	L,A		; HL points to entry now
	LDA	NEWUSR		; Get current user
	CMP	M
	JNZ	MORDIR		; Ignore if different
	INX	H

	 IF	Z80DOS
	PUSH	B		;
	PUSH	D		;
	PUSH	H		;
	MVI	C,54		; Get time stamp from last search
	CALL	BDOS		;
	LXI	D,6		; Point to last access field
	LDA	DGOPFL
	ORA	A
	JZ	ACCESS		; Z=what is wanted
	LXI	D,2		; Point to last alteration field
	LDA	DAOPFL
	ORA	A
	JZ	ACCESS		; Z=what is wanted
	LXI	D,0		; Point to creation field
	LDA	DNOPFL
	ORA	A
	JZ	ACCESS		; Z=what is wanted

	LXI	D,2		; Didn't say, so give him alteration date

ACCESS: PUSH	H
	DAD	D		; Point to right field in returned database
	MOV	E,M		; Get the date in Julian
	INX	H
	MOV	D,M
	MOV	A,D		; Is requested date 0 for the file?
	ORA	E
	JNZ	ACCESS1		; NZ=no, use it
	POP	H		
	MOV	E,M		; Was zero, use creation date
	INX	H
	MOV	D,M
	PUSH	H
ACCESS1:
	XCHG
	SHLD	DATMOD
	POP	H
;////
	POP	H
	POP	D
	POP	B
	 ENDIF		;Z80DOS
;
; Move entry to table
;
	XCHG			; Entry to DE
	LHLD	NEXTT		; Next table entry to HL
	MVI	B,11		; Entry length (name, type, extent)

TMOVE:	LDAX	D		; Get entry character

	 IF	NOT (USELC OR REVID)
	ANI	7FH		; Remove attributes
	 ENDIF			; NOT (USELC OR REVID)

	MOV	M,A		; Store in table
	INX	D
	INX	H
	DCR	B		; More?
	JNZ	TMOVE
	INX	D		; DE->> S1
	INX	D		; DE->> S2
	LDAX	D		; Get S2 byte, oflo=int(extents/32)
	PUSH	H		; Save HL
	MOV	L,A		; Set up 16-bit multiply
	MVI	H,0
	MVI	B,5
	CALL	SHLL		; HL is now # of oflo extents
	DCX	D		; DE->> S1
	DCX	D		; DE->> extent
	LDAX	D		; Get extent
	ADD	L
	MOV	L,A
	MOV	A,H
	ACI	0
	MOV	H,A		; HL has total extents
	MVI	B,7
	CALL	SHLL		; HL has total records less last ext
	INX	D		; DE->> S1
	INX	D		; DE->> S2
	INX	D		; Point to sector count
	LDAX	D		; Get it
	ADD	L
	MOV	L,A
	MOV	A,H
	ACI	0
	MOV	H,A		; HL has total records
	XTHL			; Do some fancy shuffling
	XCHG
	XTHL
	XCHG
	MOV	M,D
	INX	H
	MOV	M,E
	POP	D		; All back to normal
	INX	H

	 IF	Z80DOS
	LDA	DATMOD		; Get LSB of last modified date
	MOV	M,A		;
	INX	H		;
	LDA	DATMOD+1	; Get MSB of last modified date
	MOV	M,A		;
	INX	H		;
	 ENDIF		;Z80DOS

	SHLD	NEXTT		; Save updated table address
	XCHG
	LHLD	COUNT		; Bump the # of matches made
	INX	H
	SHLD	COUNT

	 IF	Z80DOS
	LXI	H,15		; Size of entry include date
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	LXI	H,13		; Size of next entry
	 ENDIF		;NOT Z80DOS

	DAD	D
	XCHG			; Future NEXTT is in DE
	LHLD	BDOS+1		; Pick up TPA end
	MOV	A,E
	SUB	L		; Compare NEXTT-TPA end
	MOV	A,D
	SBB	H
	JC	MORDIR		; If TPA end > NEXTT, loop back for more

OUTMEM:	CALL	ERXIT		; Exit if directory too large
	DB	'Memory',0
;
; Shift HL left by B bits
;
SHLL:	DAD	H
	DCR	B
	RZ
	JMP	SHLL
;
; Sort and print
;
SPRINT:	CALL	SETFOP		; Return to file output DMA & user #
	LHLD	COUNT		; Get file name count
	MOV	A,L
	ORA	H		; Any found?
	JZ	PRTOTL		; Exit if no files found
	PUSH	H		; Save file count
	STA	SUPSPC		; Enable leading zero suppression
;
; Initialize the order table
;
	LHLD	TBLOC		; Get start of name table
	XCHG			; Into DE
	LXI	H,ORDER		; Point to order table

	 IF	Z80DOS
	LXI	B,15		; Entry length including date
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	LXI	B,13		; Entry length
	 ENDIF		;NOT Z80DOS

BLDORD:	MOV	M,E		; Save low order address
	INX	H
	MOV	M,D		; Save high order address
	INX	H
	XCHG			; Table address to HL
	DAD	B		; Point to next entry
	XCHG
	XTHL			; Save table address, load loop counter
	DCX	H		; Count down loop
	MOV	A,L
	ORA	H		; More?
	XTHL			; Load table address, save loop counter
	JNZ	BLDORD		; Yes, go do another one
	POP	H		; Clean loop counter off stack
	LHLD	COUNT		; Get count
	SHLD	SCOUNT		; Save as # to sort
	DCX	H		; Only 1 entry?
	MOV	A,L
	ORA	H
	JZ	DONE		; Yes, so skip sort
;
; This sort routine is adapted from SOFTWARE TOOLS
;
	LHLD	SCOUNT		; Number of entries

L1:	ORA	A		; Clear carry
	MOV	A,H		; GAP=GAP/2
	RAR
	MOV	H,A
	MOV	A,L
	RAR
	MOV	L,A
	ORA	H		; Is it zero?
	JZ	DONE		; Then none left
	MOV	A,L		; Make gap odd
	ORI	1
	MOV	L,A
	SHLD	GAP
	INX	H		; I=GAP+1

L2:	SHLD	I
	XCHG
	LHLD	GAP
	MOV	A,E		; J=I-GAP
	SUB	L
	MOV	L,A
	MOV	A,D
	SBB	H
	MOV	H,A

L3:	SHLD	J
	XCHG
	LHLD	GAP		; JG=J+GAP
	DAD	D
	SHLD	JG
	CALL	COMPARE		; Compare (J) and (JG)
;
; Use carry flag instead of sign flag to test results of COMPARE 
; because the sign flag is set to M when the result of a subtraction
; is 80h or greater.
;
;	JP	P,L4		; If A(J)<=A(JG)
	JNC	L4		; <crw>
	LHLD	J
	XCHG
	LHLD	JG
	CALL	SWAP		; Exchange a(J) and a(JG)
	LHLD	J		; J=J-GAP
	XCHG
	LHLD	GAP
	MOV	A,E
	SUB	L
	MOV	L,A
	MOV	A,D
	SBB	H
	MOV	H,A
	JM	L4		; If J>0 go to l3
	ORA	L		; Check for zero
	JZ	L4
	JMP	L3

L4:	LHLD	SCOUNT		; For later
	XCHG
	LHLD	I		; I=I+1
	INX	H
	MOV	A,E		; If I<=n go to l2
	SUB	L
	MOV	A,D
	SBB	H
	JP	L2
	LHLD	GAP
	JMP	L1
;
; Sort is all done - print entries
;
DONE:	LDA	FOPFLG		; File output flag
	ORA	A		; Set?
	JNZ	NOOUT		; No, skip open
;
; If all user option enabled, and we're not on the first pass, then the
; output file is already open and positioned, so we can skip the open.
;
	LXI	H,OPNFLG	; Output file open flag
	CMP	M		; A=0,set Z if OPNFLG=0 also
	JNZ	NOOUT		; If OPNFLG not zero, skip open
	DCR	M		; Else, set OPNFLG for next user #
;
; First pass on file append - prepare DISK.DIR to receive new
; or appended output.
;
	LXI	D,OUTFCB	; Does output file exist?
	MVI	C,SRCHF
	CALL	CPM
	INR	A
	JNZ	OPENIT		; Yes, open for processing
	MVI	C,MAKE		; Else, create output file
	CALL	CPM
	INR	A		; Successful?
	JNZ	NOOUT		; Yes, Continue
;
; If make or open fails, declare error
;
OPNERR:	CALL	ERXIT
	DB	'Open',0
;
WRTERR:	CALL	ERXIT
	DB	'Write',0
;
; Output file already exists - open it and position
; it to the last record of the last extent.
;
OPENIT:	MVI	C,OPEN		; Open 1st extent of output file
	CALL	CPM
	INR	A
	JZ	OPNERR		; Bad deal if 1st won't open

OPNMOR:	LDA	OUTFCB+15	; Record count (RC)
	CPI	128
	JC	LSTEXT		; If RC<128, this is last extent
	LXI	H,OUTFCB+12
	INR	M		; Else, increment to next extent
	MVI	C,OPEN		; Try to open it
	CALL	CPM
	INR	A
	JNZ	OPNMOR		; Continue opening extents to end
	DCR	M		; Then, reopen preceding extent
	MVI	C,OPEN
	CALL	CPM
	LDA	OUTFCB+15	; Get RC for the last extent
;
; At this point, OUTFCB is opened to the last extent of the file, so
; read in the last record in the last extent.
;
LSTEXT:	ORA	A		; Is this extent empty?
	JZ	NOOUT		; Yes, starting a clean slate
	DCR	A		; Normalize record count
	STA	OUTFCB+32	; Set record number to read
	MVI	C,READ		; Read last record of file
	CALL	CPM
	ORA	A		; Successful read?
	JZ	RDOK		; Yes, scan for EOF mark

APERR:	CALL	ERXIT
	DB	'Append',0
;
; We now have the last record in the file in the buffer. Scan the last
; record for the EOF mark, indicate where we can start adding data.
;
RDOK:	LXI	H,OUTBUF	; Point to output buffer start
	MVI	B,128		; Output buffer length

SCAN:	MOV	A,M		; Character
	CPI	'Z'-40H		; End of file?
	JZ	RESCR		; Yes, save pointers and reset CR
	INX	H		; Pointer+1
	DCR	B		; Length-1
	JNZ	SCAN		; Continue to end of buffer
;
; If an explicit EOF mark or an implied EOF (last record is full) in
; the last buffer, move the FCB record and extent pointer back to cor-
; rect for the read operation so the first write operation will replace
; the last record of the DISK.DIR file.
;
RESCR:	PUSH	H		; Save EOF buffer pointer
	PUSH	B		; Save EOF buffer remaining
	LXI	H,OUTFCB+32	; Load current record again
	DCR	M		; Record-1
	JP	SAMEXT		; If CR>=0, still in same extent
	LXI	H,OUTFCB+12	; Else, move to previous extent
	DCR	M
	MVI	C,OPEN		; Then, reopen previous extent
	CALL	CPM
	INR	A
	JZ	APERR		; Append error if can not reopen
	LDA	OUTFCB+15	; Else,
	DCR	A		; Position to last record of
	STA	OUTFCB+32	; The extent

SAMEXT:	POP	PSW		; Recall EOF location in buffer
	STA	BUFCNT		; Set buffer counter
	POP	H		; Recall next buffer pointer
	SHLD	BUFPNT		; Set pointer for first addition

NOOUT:	LDA	FIRSTT		; First time through?
	ORA	A
	JNZ	NOVOPT		; No, we've been here before
	MVI	A,0FFH		; Yes,
	STA	FIRSTT		; Set first time flag
	LDA	VOPFLG		; Version display flag
	ORA	A		; Set?
	JNZ	NOVOPT		; No, skip version print
	LXI	D,VERNAME	; Yes, print version
	CALL	PUTS		; Print the string
	CALL	CRLF

NOVOPT:	LHLD	COUNT
	SHLD	LCOUNT
	LXI	H,0
	SHLD	LBTOTL
	SHLD	LMTOTL
	LXI	H,ORDER		; Initialize order table pointer
	SHLD	NEXTL
	SHLD	NEXTT
	LDA	VFLAG		; Check display form
	ORA	A
	JNZ	NEWLIN		; Jump if not vertical
	LHLD	COUNT		; Code computes end of name table
	CALL	MULT13		; (or start of second table
	XCHG			; Where files to be stored after
	LHLD	TBLOC		; Redundant extents removed)
	DAD	D
	SHLD	NEWPTR		; Save it twice
	SHLD	XPOINT		; For later
;
; Output the directory files we've matched
;
ENTRY:	LHLD	COUNT		; Files matched count
	DCX	H		; Count-1
	SHLD	COUNT
	MOV	A,H		; Is this the last file?
	ORA	L
	JZ	OKPRNT		; Yes, last file so skip compare
;
; Compare each entry to make sure that it isn't part of a multiple
; extent file.	Go only when we have the last extent of the file.
;
	PUSH	B		; Save number of columns
	LDA	VFLAG		; Check display form
	ORA	A
	CNZ	CKABRT		; If horiz, check for abort from keyboard
	LHLD	NEXTT
	MVI	A,11
	CALL	COMPR		; Does this entry match next one?
	POP	B		; Restore number of columns
	JNZ	OKPRNT		; No, print it
NOKPRN:	INX	H
	INX	H		; Skip, highest extent last in list
	SHLD	NEXTT
	JMP	ENTRY		; Loop back for next lowest extent
;
; VLIST substitution. If VLIST option chosen, OKPRINT moves unique
; filenames and sizes in "k" to a second table above the first for
; use later.
;
OKPRNT:
;////
	 IF	Z80DOS
	PUSH	H
	PUSH	D
	PUSH	B
	LHLD	NEXTT		; Get order table pointer
	MOV	E,M		; Get low order address
	INX	H
	MOV	D,M		; Get high order address
	LXI	H,13
	DAD	D
	MOV	E,M
	INX	H
	MOV	D,M
	LHLD	DATCHK		; Get the date we are looking for
	MOV	A,H
	ORA	L
	JZ	GDTMTC		; Z=not looking
	LHLD	DATCH1
	MOV	A,H
	ORA	L
	JZ	ONEDAT		; Z=only 1 date on input line
	DW	SBCDE
	JZ	GDTMTC		; Z=file date=low date
	JNC	NDTMTC		; NC=file date < low date, no output
	LHLD	DATCHK
	ORA	A
	DW	SBCDE
	JZ	GDTMTC		; Z=file date=high date
	JNC	GDTMTC		; NC=file date < high date
	JMP	NDTMTC		; File date > high date
ONEDAT:	LHLD	DATCHK
	MOV	A,H
	CMP	D		; Check if given date >,=,< the files date
	JZ	CHDLOW		; High EQ, check low
	JC	DATLT		; C=LT
	JMP	DATGE		; Given date GT file date
CHDLOW:	MOV	A,L		; Check low byte of date vs. file date
	CMP	E
DATGE:	MVI	A,0		; Assume EQ
	JC	DATLT		; C= given LT files date
	JZ	DATFLG		; Z= they are EQ
	MVI	A,2		; Given GT files date
	JMP	DATFLG
DATLT:	MVI	A,1		; Given was less than files
DATFLG:	STA	DTMTCH
	LDA	DEOPFL		; What kind of date match?
	ORA	A
	JZ	DTEXAC		; Z=exact
	LDA	DPOPFL
	ORA	A
	JZ	DTABVE		; Z=GE
	LDA	DMOPFL		; LT wanted?
	ORA	A
	JNZ	DTEXAC		; NZ=no, didn't tell us so do anything but gave
				; us a date so assume want exact match
	LDA	DTMTCH
	CPI	2
	JZ	GDTMTC		; Date was below and they wanted below
NDTMTC:
	POP	B
	POP	D
	POP	H
	PUSH	H
	LHLD	COUNT
	MOV	A,L
	ORA	H
	POP	H
	JZ	PRTOTL
	JMP	NOKPRN

DTEXAC:	LDA	DTMTCH		; They wanted exact, was it?
	ORA	A
	JZ	GDTMTC		; Z=yes
	JMP	NDTMTC
DTABVE:	LDA	DTMTCH		; They wanted GE
	CPI	1
	JZ	GDTMTC		; Z=G
	ORA	A
	JNZ	NDTMTC		; Must be 2, so not equal
GDTMTC:	POP	B
	POP	D
	POP	H
	 ENDIF		; Z80DOS
	
	LHLD	NEXTT		; Get order table pointer
	MOV	E,M		; Get low order address
	INX	H
	MOV	D,M		; Get high order address
	INX	H
	SHLD	NEXTT		; Save updated table pointer
	XCHG			; Table entry to HL
	LDA	VFLAG		; Check display form
	ORA	A
	JNZ	OKPR1		; Jump if not vertical
	PUSH	H		; Save address of byte to be moved
	LHLD	NEWPTR		; Address in new table to put byte
	PUSH	H		; Save address

	 IF	Z80DOS
	LXI	D,15		; Update address including date
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	LXI	D,13		; Update address
	 ENDIF		;NOT Z80DOS

	DAD	D
	SHLD	NEWPTR		; Save for later (end of table)
	POP	H		; Set current move  to	address
	XCHG			; Swap pointers
	POP	H		; Set current move from address
	MVI	B,11		; Filename.typ length
	CALL	MOVE		; Move it

	 IF	Z80DOS
	PUSH	H
	 ENDIF		;Z80DOS

	PUSH	D
	JMP	OKPR2

OKPR1:	MVI	B,8		; Filename length
	CALL	PUTSB		; Output
	MVI	A,'.'		; Period after filename
	CALL	PUTCHR		; Output
	MVI	B,3		; Filetype length
	CALL	PUTSB		; Output

	 IF	Z80DOS
	LDA	NODFLG
	ORA	A
	JZ	NOD1
	CALL	DISDAT
NOD1:
	 ENDIF		;Z80DOS

OKPR2:	
	CALL	SIZEFL
	LHLD	TOTSIZ		; DE = rounded size in K
	DAD	D		; Add to total used
	SHLD	TOTSIZ
	LHLD	TOTFIL		; Increment filecount
	INX	H
	SHLD	TOTFIL
	XCHG
	LDA	COPFLG		; Size wanted in records?
	ORA	A
	JNZ	OKPR3		; Jump if not
	LHLD	FILERC		; Else get record count

OKPR3:	LDA	VFLAG		; Check display form
	ORA	A
	JNZ	OKPR4		; Jump if not vertical
	POP	D		; A(size to go)
	MOV	A,H		; Move size to table two
	STAX	D
	INX	D
	MOV	A,L
	STAX	D

	 IF	Z80DOS
	POP	H		; Currently pointing to file size
	INX	H		; Skip size
	INX	H
	INX	D
	MOV	A,M		; Get LSB of date
	STAX	D		; Save it away
	INX	D
	INX	H
	MOV	A,M		; Ditto for MSB of date
	STAX	D
	 ENDIF		;Z80DOS
;
; One File Moved - Test to see if we have to move another
;
	LHLD	COUNT		; Current file counter
	MOV	A,H
	ORA	L
	JZ	PRTOTL		; Zero, output summary
	JMP	ENTRY
;
; Output the size of the individual file
;
OKPR4:	CALL	DECPRT		; Print it
	LDA	FSIZEC		; Follow with 'k' or 'r'
	CALL	PUTCHR
;
; One file output - test to see if we have to output another one.
;
	LHLD	COUNT		; Current file counter
	MOV	A,H
	ORA	L		; Zero?
	JZ	PRTOTL		; Yes, exit to summary output
;
; At least one more file to output,
; can we put it on the current line?
;
	DCR	C
	PUSH	PSW
	CNZ	FENCE		; If room left output fence character
	POP	PSW
	JNZ	ENTRY		; Output another file
;
; Current line full, start a new one
;
NEWLIN:
	 IF	Z80DOS
	MVI	C,2		; 2 names per line
	LDA	NODFLG
	ORA	A
	JNZ	NOD2
	MVI	C,4
NOD2:
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	MVI	C,4		; Reset names per line counter
	 ENDIF		;NOT Z80DOS

	CALL	CRLF		; Space down to next line
	JMP	ENTRY		; Output another file
;.....
;
; Compute the size of the file/library and update our summary datum.
; This has been changed into a subroutine so that both the file size
; computation and a library size (when printing out library members)
; can be computed in K.
;
SIZEFL:	MOV	D,M
	INX	H
	MOV	E,M		; Size in DE (records)
	XCHG
	SHLD	FILERC		; Save record count
	XCHG
	LDA	BLKMSK
	PUSH	PSW
	ADD	E
	MOV	E,A
	MOV	A,D
	ACI	0
	MOV	D,A
	POP	PSW
	CMA
	ANA	E
	MOV	E,A
	MVI	B,3

SHRR:	MOV	A,D
	ORA	A
	RAR
	MOV	D,A
	MOV	A,E
	RAR
	MOV	E,A
	DCR	B
	JNZ	SHRR
	RET
;
; Print HL in decimal with leading zero suppression
;
DECPRT:	XRA	A		; Clear leading zero flag
	STA	LZFLG
	LXI	D,-10000
	LDA	SUPSPC
	PUSH	PSW
	XRA	A
	STA	SUPSPC
	CALL	DIGIT
	POP	PSW
	STA	SUPSPC
	LXI	D,-1000		; Print 1000's digit
	CALL	DIGIT
	LXI	D,-100		; Etc.
	CALL	DIGIT
	LXI	D,-10
	CALL	DIGIT
	MVI	A,'0'		; Get 1's digit
	ADD	L
	JMP	PUTCHR

DIGIT:	MVI	B,'0'		; Start off with ASCII 0

DIGLP:	PUSH	H		; Save current remainder
	DAD	D		; Subtract
	JNC	DIGEX		; Quit on overflow
	POP	PSW		; Throw away remainder
	INR	B		; Bump digit
	JMP	DIGLP		; Loop back

DIGEX:	POP	H		; Restore pointer
	MOV	A,B
	CPI	'0'		; Zero digit?
	JNZ	DIGNZ		; No, type it
	LDA	LZFLG		; Leading zero?
	ORA	A
	MVI	A,'0'
	JNZ	PUTCHR		; Print digit
	LDA	SUPSPC		; Get space suppression flag
	ORA	A		; See if printing file totals
	RZ			; Yes, don't give leading spaces
	JMP	SPACE		; Leading zero..print space
;
DIGNZ:	STA	LZFLG		; Leading zero flag set
	JMP	PUTCHR		; Print leading zero & digit
;.....
;
;-----------------------------------------------------------------------
;		  VLIST subroutines begin here
;
;Multiply contents of HL register by 13
;
MULT13:	MOV	D,H
	MOV	E,L
	DAD	H
	DAD	D
	DAD	H
	DAD	H
	DAD	D

	 IF	Z80DOS
	DAD	D		; Actually by 15
	DAD	D		;
	 ENDIF	;Z80DOS

	RET
;.....
;
; Main VLIST subroutine to output a filename and column delimiter
;
VENTRY:	STA	VSFRST
	CALL	PFILE1		; Routine to print a filename
	RZ			; If at end of line return with zero set
	CC	FENCE		; Print column delimiter if more
	LHLD	JUMPER		; Put the jumper back in DE
	XCHG
	ORI	1		; Insure non zero return
	RET
;.....
;
PFILE1:
	PUSH	H
	PUSH	D
	XCHG
	LHLD	NEWPTR
	MOV	A,H
	CMP	D
	JNC	PFILE2
	MOV	A,L
	CMP	E
	POP	D
	POP	H
	RZ
	JNC	PFILE3
	XRA	A
	RET
PFILE2:	POP	D
	POP	H
PFILE3:
	MOV	A,M		; Let's see what we have
	CPI	0FEH
	RNC
	ANI	7FH		; Strip parity bit
	PUSH	B		; Save number of columns
	MVI	B,8		; Print filename and type
	CALL	PUTSB
	MVI	A,'.'
	CALL	PUTCHR
	MVI	B,3
	CALL	PUTSB
	
	 IF	Z80DOS
	LDA	NODFLG
	ORA	A
	JZ	NOD3
	CALL	DISDAT		; Display the date
NOD3:
	 ENDIF		;Z80DOS

	MOV	D,M		; Get it into DE
	INX	H
	MOV	E,M
	XCHG			; HL <-> DE
	CALL	DECPRT		; Print it out
	LDA	FSIZEC		; Follow with 'k' or 'r'
	CALL	PUTCHR
	POP	B		; Load number of columns
	LHLD	TOTFIL		; Load number of files left
	DCX	H		; # files-1
	SHLD	TOTFIL		; Resave it
	MOV	A,H
	ORA	L		; Zero yet?
	RZ			; Yes, no more files
	DCR	C		; No, decrement it
	STC			; Force carry on
	RET			; This return
;.....
;
;		      End of VLIST routines
;-----------------------------------------------------------------------
;
; Show total space and files used
;
PRTOTL:	
	XRA	A
	STA	VSFRST
	LDA	VFLAG		; Check display form
	ORA	A
	JZ	PRTOT1		; Jump if vertical
	LDA	LOPFLG
	ORA	A
	JNZ	PRTOT1
	LHLD	TOTFIL		; How many files matched?
	MOV	A,H
	ORA	L
	CNZ	PRTLMEM		; Skip .LBR check if none found

PRTOT1:	XRA	A		; Get a zero to
	STA	SUPSPC		; Suppress leading spaces in totals
	LHLD	TOTFIL		; How many files matched?
	MOV	A,H
	ORA	L
	JZ	NXTUSR		; Skip summary if none found
	PUSH	H		; Save TOTFIL
	STA	FNDFLG		; Set file found flag
	LDA	VFLAG		; Check display form
	ORA	A
	JNZ	PRTOT3		; Horizontal = 0FFh, exit if not zero
	LDA	SOHFLG
	ORA	A
	JZ	PRTOT2
	XRA	A
	STA	SOHFLG
	JMP	PRTOT3

PRTOT2:	CALL	CRLF

PRTOT3:	LXI	D,TOTMS1	; Print "13,10,' Drive'"
	CALL	PUTS
	LDA	FCB
	ADI	'A'-1
	CALL	PUTCHR		; Output the drive code
	CALL	CKVER
	JC	NOUSER
	CALL	PUTUSR		; Output user number

	 IF	NDIRS
	MVI	A,' '
	CALL	PUTCHR
	CALL	NAMDIR
	 ENDIF			; NDIRS

	LDA	USRNR
	CPI	10
	LXI	D,NOFMS2
	JC	$+6
	LXI	D,NOFMS2+1	; Print some spaces
	CALL	PUTS

	 IF	BYEULI
	LDA	BYEACT		; BYE active?
	ORA	A
	JZ	NOUSER		; Yes, skip ulcode
	 ENDIF		; BYEULI

	 IF	ULINE
	LXI	D,ULON		; Turn on underline
	CALL	COUTS		; If not null
	 ENDIF			; ULINE

NOUSER:	LXI	D,TOTMS6	; Print " Files: "
	CALL	PUTS
	POP	H		; Recall TOTFIL
	XCHG
	LHLD	TOTFL1		; Get total number of files so far		
	DAD	D		; Add in number this DU
	SHLD	TOTFL1		; And save it away
	XCHG
	CALL	DECPRT		; Print # of files matched
	LXI	D,TOTMS4	; No CRLF needed, display > 40
	CALL	PUTS
	LHLD	TOTSIZ		; Total k used by matched files
	XCHG
	LHLD	TOTSZ1		; Get running total of all files
	DAD	D
	SHLD	TOTSZ1		; And put it back
	XCHG
	CALL	DECPRT		; Print file size
	LXI	D,TOTMS5	; Print "k"
	CALL	PUTS
	CALL	PRTFRE		; Print free space remaining

	 IF	ULINE AND BYEULI
	LDA	BYEACT		; Bye active?
	ORA	A		;
	JZ	NPRNT		; Yes, skip ULINE off
	 ENDIF		; ULINE AND BYEULI

	 IF	ULINE
	LXI	D,ULOFF		; Turn off underline
	CALL	COUTS		; If not null
	 ENDIF			; ULINE
;
; Summary line printed, now print detail files, first compute total
; printout lines.
;
NPRNT:	LDA	VFLAG		; Check display form
	ORA	A
	JNZ	NXTUSR		; Jump if horizontal

	 IF	Z80DOS
	LXI	B,1
	LDA	NODFLG
	ORA	A
	JNZ	NOD4
	LXI	B,3
NOD4:
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	LXI	B,3
	 ENDIF		;NOT Z80DOS

	MOV	A,C		; Get number of names per line
	CMA			; Negative of number of columns
	MOV	E,A		; Into DE
	MVI	D,0FFH
	LHLD	TOTFIL		; Load total number of files
	DAD	B		; Round up to a full line
	MVI	C,0FFH

NPRNT1:	INR	C		; C-reg will hold number of
	DAD	D		; Lines to be displayed
	JC	NPRNT1
	MOV	A,C
	STA	LINES		; Done, save it for later
	STA	SUPSPC		; Allow spaces preceding file sizes
;
; Number lines times entry size = the number of bytes to skip in the
; second table when outputting files in vertical order.
;
	 IF	VSPAGE
	LDA	FOPFLG		; Check File output
	ORA	A
	JZ	NVSORT
	LDA	POPFLG
	ORA	A
	JZ	NVSORT
	LDA	NOPFLG
	ORA	A
	JNZ	VSORT
NVSORT:	MOV	A,C
	JMP	OVSORT
VSORT:
	LDA	LINCNT		; Get number of lines currently displayed
	MOV	B,A
	MVI	A,22		; Calc number left
	SUB	B
	MOV	B,A
	MOV	A,C		; Get how many lines this DU
	CMP	B
	JC	OVSORT		; If C, then this DU will fit on the page whole
	MOV	A,B		; This DU won't fit, so calc to fill up page
	ORA	A
	JNZ	OVSORT
	MOV	A,C
	CPI	23
	JC	OVSORT
	MVI	A,23
OVSORT:
	 ENDIF		; VSPAGE

	MOV	L,A		; Put number of lines into HL
	MVI	H,0
	CALL	MULT13
	SHLD	JUMPER		; Put it away
	XRA	A
	STA	WASHERE		; Set flag for FENCE that says next calc
				; is for the next page of display
;
; Fill a record with FF at the end of table 2
;
	LHLD	NEWPTR		; Now points to end of table 2
	MVI	B,128
	MVI	A,0FFH

NPRNT2:	MOV	M,A
	INX	H
	DCR	B
	JNZ	NPRNT2
;
; Increment the number of files for use later in VENTRY.  This insures
; that a column delimiter will be printed after the last filename, if
; the file appears in other than the last column of the display.
;
	 IF	NOT Z80DOS
	LXI	H,TOTFIL
	INR	M
	 ENDIF		;NOT Z80DOS
;
; Print out a line of files
;
NPRNT3:	
	 IF	Z80DOS
	MVI	C,2
	LDA	NODFLG
	ORA	A
	JNZ	NOD5
	MVI	C,4
NOD5:
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	MVI	C,4		; Reset number of columns
	 ENDIF		;NOT Z80DOS

	CALL	CRLF		; Start a new line
	MVI	A,1
	STA	VSFRST

;
; Print first filename
;
	LHLD	XPOINT		; XPOINT = to start of second table
	CALL	VENTRY		; At entry. Below, it is incremented
				; For additional lines of printout
	JZ	NLINE		; Either out of columns or out of files
;
; Print second filename
;
	LHLD	XPOINT
	DAD	D
	CALL	VENTRY
	JZ	NLINE
;
; Print third filename
;
	LHLD	XPOINT
	DAD	D
	DAD	D
	CALL	VENTRY
	JZ	NLINE
;
; Print fourth filename
;
	LHLD	XPOINT
	DAD	D
	DAD	D
	DAD	D
	CALL	VENTRY

NLINE:	LHLD	XPOINT		; Increment XPOINT to next file

	 IF	Z80DOS
	LXI	D,15
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	LXI	D,13
	 ENDIF		;NOT Z80DOS

	DAD	D
	SHLD	XPOINT
	LHLD	TOTFIL		; Out of files?
	MOV	A,H
	ORA	L
	JZ	DOLIB		; Yes, Check for libraries
	LXI	H,LINES		; No, just need a new line
	DCR	M
	JNZ	NPRNT3

DOLIB:	LDA	LOPFLG
	ORA	A
	JNZ	NXTUSR
	LHLD	TOTFIL		; How many files matched?
	MOV	A,H
	ORA	L

	 IF	NOT Z80DOS
	CNZ	PRTLMEM		; Skip library check if none found
	 ENDIF
	 IF	Z80DOS
	CALL	PRTLMEM
	 ENDIF

;
; Directory for one user area completed.  If all users option is select-
; ed, then go do another directory on the next user number until we ex-
; ceed the maximum user # for the selected drive.
;
NXTUSR:	LDA	AOPFLG		; All user flag
	ORA	A		; Set?
	JZ	NXTUSU		; Set if zero, show all user areas
	LDA	HOPFLG		; "H" flag to show remaining areas
	ORA	A
	JNZ	GOCLZ		; Non-zero, not set, exit

NXTUSU:	CALL	CKVER		; Running CP/M 2?
	JC	GOCLZ		; No, Skip user increment
	CALL	CKABRT		; Yes, Check for user abort
	LDA	MAXUSR		; No abort - get maximum user #
	LXI	H,NEWUSR	; Increment directory user number
	INR	M
	CMP	M		; Next user # exceed maximum?
	JNC	SETTBL		; No, more user areas to go
	LDA	BASUSR		; Reset base user number for
	MOV	M,A		; The next directory search
;
; We've finished all of our outputting. Flush the remainder of the out-
; put buffer and close the file before going to exit routine.
;
GOCLZ:	LXI	H,OPNFLG	; Get file open status, reset flag
	MOV	A,M		; To force reopen on next pass
	MVI	M,0
	ORA	A		; File open?
	JZ	NXTDSK		; No, Skip closing DISK.DIR
	LXI	H,BUFCNT
	MOV	A,M		; Load # of unflushed characters in
	MVI	M,128		; Buffer, force BUFCNT to empty status
	ORA	A		; If BUFCNT=128, buffer empty set sign
	JM	DDCLOS		; Close DISK.DIR if buffer is empty
	JZ	FLUSH		; Write last record to DISK.DIR if full
	LHLD	BUFPNT		; Else pad unused buffer with CTL-Z

PUTAGN:	MVI	M,'Z'-40H	; EOF marker
	INX	H		; Next buffer location
	DCR	A		; Count-1
	JNZ	PUTAGN		; Continue buffer padding fill

FLUSH:	LXI	D,OUTFCB	; Flush the last output buffer
	MVI	C,WRITE
	CALL	CPM
	ORA	A
	JNZ	WRTERR

DDCLOS:	LXI	D,OUTFCB	; Close DISK.DIR output file
	MVI	C,CLOSE
	CALL	CPM
;
; Directory for all user areas finished.  If the multi-disk option is
; enabled and selected, reset to the base user area and repeat the
; directory for next drive on-line until we either exceed the drives in
; our LODRV-HIDRV table, or the BDOS shuts us down with a select or bad
; record error, which will be intercepted back to the EXIT module.
;
NXTDSK:	LXI	H,FNDFLG	; Load file found flag
	MOV	A,M
	MVI	M,0		; Clear found flag for next drive
	ORA	A
	JNZ	NDSK		; Continue if at least 1 file found
	LXI	H,FOPFLG
	DCR	M
	PUSH	H
	LXI	D,NOFMS1	; Print 1st part of no files message
	CALL	PUTS		; Print it
	LXI	D,NOFLM
	CALL	PUTS		; Print message
	LDA	FCB
	ADI	'A'-1
	CALL	PUTCHR		; Output the drive
	CALL	CKVER
	JC	NOUSR1
	CALL	PUTUSR		; Output the user number

NOUSR1:	LXI	D,NOFMS3	; Print divider
	CALL	PUTS
	CALL	PRTFRE		; Tag with free message
	LDA	VFLAG		; Check display form
	ORA	A
	CNZ	CRLF		; Need another CRLF in horizontal mode
	POP	H
	INR	M

NDSK:	LDA	DOPFLG		; Multi-disk selected?
	ORA	A
	JNZ	NPRT		; No, skip next check
	CALL	CKABRT		; Check for user abort
	MVI	A,HIDRV-LODRV	; Load max drive code to search
	LXI	H,FCB		; Increment directory FCB drive code
	INR	M
	CMP	M		; Does next disk exceed maximum?
	JC	NPRT

;	 IF	MAXDRV

	 IF	ZCPR3P AND MAXDRV
	PUSH	H
	LHLD	Z3DRVL		; Point to ENV
	MOV	A,M		; Get it
	POP	H
	 ENDIF		;ZCPR3P AND MAXDRV

	 IF	NOT ZCPR3P AND MAXDRV
	LDA	MXDRV		; Look at another value limit
	INR	A
	 ENDIF		;NOT ZCPR3P AND MAXDRV

	 IF	MAXDRV AND NOT DRVVEC
	CMP	M		; Is it lower?
	JC	NPRT		; Bail out if too low
	JMP	NOOPT		; Search next disk
	 ENDIF			; MAXDRV AND NOT DRVVEC

	JNC	NOOPT		; Search next disk if maxdr not true
;
; If no printer, fall through to EXIT
;
NPRT:	LDA	POPFLG
	ORA	A		; Printer active?
	JNZ	EXIT		; No, just exit
	MVI	C,LIST
	MVI	E,13		; Print a CRLF
	CALL	CPM
	MVI	E,10		; Line feed
	CALL	CPM
	JMP	EXIT		; All done - exit to CCP
;.....
;
; Output the user number of the directory in decimal
;
PUTUSR:	LDA	NEWUSR
	CPI	10		; User no. < 10?
	JC	DUX		; Yes, skip 10's digit
	STA	USRNR
	PUSH	B		; No, process 10's digit
	MVI	C,'0'-1

DUY:	INR	C		; Get tens digit
	SUI	10
	JNC	DUY		; Loop until we've gone too far
	ADI	10
	MOV	B,A		; Save units digit
	MOV	A,C		; Print tens digit
	CALL	PUTCHR
	MOV	A,B		; Recall units digit
	POP	B

DUX:	ADI	'0'		; Make it ASCII
	JMP	PUTCHR

;.....
;
; Force new line on output and check for page pause
;
CRLF:	MVI	A,13		; Send CR
	CALL	PUTCHR
	MVI	A,10		; Send LF
	JMP	PUTCHR
;.....
;
; Separate the directory output on a line with a space,
; the delimiter, followed by another space.
;
FENCE:	CALL	SPACE

	 IF	Z80DOS
	LDA	NODFLG
	ORA	A
	JZ	FENCE1
	CALL	SPACE
	CALL	SPACE
FENCE1:
	 ENDIF		;Z80DOS

	MVI	A,':'		; Fence character
	CALL	PUTCHR		; Print it, then a space character

	 IF	Z80DOS
	LDA	NODFLG
	ORA	A
	JZ	NOD6
	CALL	SPACE
	CALL	SPACE
NOD6:
	 ENDIF		;Z80DOS

SPACE:	MVI	A,' '
;
; Output character in A to console, and optionally to printer
; and/or the output file.  Detects user abort request.
;
PUTCHR:	PUSH	B
	PUSH	D
	PUSH	H
	PUSH	PSW		; Save the character to output
	CALL	HITYPE		; Send it to console
	POP	PSW		; Restore the output character
	ANI	7FH		; Strip parity bit on character
;
; Test file output mode and skip to page pause test if not active
;
	MOV	B,A		; Save stripped character to B
	CPI	10		; At end of line?
	CZ	CKABRT		; Check for user abort request
	LDA	FOPFLG		; Is file output active?
	ORA	A
	JNZ	NOWRIT		; Go check for page pause if not
;
; File output mode active - make sure we have room in buffer to add
; the next character. If buffer full, write out current record first
; and then start a new record with current character.
;
	LHLD	BUFPNT		; Load current buffer pointer
	LDA	BUFCNT		; Load buffer capacity remaining
	ORA	A		; Buffer full?
	JNZ	PUTBUF		; No, Continue
	CALL	SETFOP		; Yes, Set the DMA address
	LXI	D,OUTFCB	; Else, write current buffer out
	MVI	C,WRITE
	CALL	CPM		; (call must save character in B)
	ORA	A		; Error?
	JNZ	WRTERR		; Yes, exit if disk full or R/O
	LXI	H,OUTBUF	; Reset buffer pointer
	MVI	A,128		; Reset buffer capacity

PUTBUF:	MOV	M,B		; Move char to next buffer position
	INX	H		; Bump buffer pointer
	SHLD	BUFPNT		; And save it
	DCR	A		; Buffer char count-1
	STA	BUFCNT		; And save it

NOWRIT:	MOV	A,B		; Recall stripped character
	ANI	7FH		; Strip parity bit on character
	MOV	E,A		; Setup list output call
	MVI	C,LIST
	LDA	POPFLG		; Load printer flag
	ORA	A		; Set?
	CZ	CPM		; Yes, print character
	MOV	A,E		; Recall character
	CPI	10		; Do we have a line feed?
	JNZ	PUTRET		; Exit if not
	LDA	NOPFLG		; Page pause function disabled?
	ORA	A
	JZ	PUTRET		; Yes, exit
	LDA	POPFLG		; Load, printer flag
	ORA	A		; Set?
	JZ	PUTRET		; Yes, skip page pause
	LDA	FOPFLG		; File output flag
	ORA	A		; Set?
	JZ	PUTRET		; Yes, skip page pause

	LDA	LINCNT		; Load line count
	INR	A		; Bump it
	STA	LINCNT
	MVI	L,23		; Allows use of [more] to finish display
	CMP	L		; End of the screen?
	JC	PUTRET

	LXI	D,EOSMSG	; Else, display pause message
	MVI	C,PRINT		; Without checking for line feeds
	CALL	BDOS
	CALL	GETCH		; Wait for character
	CPI	'C'-40H		; Abort on CTL-C
	JZ	EXIT1
	CPI	'K'-40H		; Or CTL-K
	JZ	EXIT1
	CPI	'X'-40H		; Or CTL-X
	JZ	EXIT1
	CPI	' '		; See if printing character
	JC	NOTEOS		; Exit if not

	 IF	NOT VSPAGE
	JZ	NOTEOS1		; If a space, exit to different place
	 ENDIF

	ANI	5FH		; Change to upper-case
	CPI	'C'		; Can abort with c, C
	JZ	EXIT1
	CPI	'K'		; Can abort with k, K
	JZ	EXIT1
	CPI	'X'		; Can abort with x, X
	JZ	EXIT1

NOTEOS:	XRA	A		; Reset line count
	STA	WASHERE		; Say are starting over

NOTEOS1:STA	LINCNT
	LXI	D,MORERA	; Overwrite the [more] display
	MVI	C,PRINT
	CALL	BDOS

	 IF	VSPAGE
	LDA	VSFRST
	ORA	A
	JZ	DLINES1
	LDA	WASHERE		; Were we here before?
	ORA	A
	JZ	WEWERE		; Z=no
	CPI	23		; Yes, must be moving by space bar, see how
				; many times
	JNZ	DLINES		; NZ=not a full page worth yet
	XRA	A		; A full page, move JUMPER up
	STA	WASHERE
WEWERE:	LHLD	JUMPER		; Get current jumper
	XCHG
	LHLD	XPOINT		; Get current position in array
	DAD	D		; Skip the right number of files
	 ENDIF
	 IF	Z80DOS AND VSPAGE
	LDA	NODFLG
	ORA	A
	JNZ	WEWERE1
	DAD	D
	DAD	D
WEWERE1:
	 ENDIF		; Z80DOS

	 IF	NOT Z80DOS AND VSPAGE
	DAD	D
	DAD	D
	 ENDIF		; NOT Z80DOS

	 IF	VSPAGE
	SHLD	XPOINT		; New current poition in output array
	LXI	H,23		; Calc new jumper, 23 lines/page
	LDA	LINES
	CPI	24
	JNC	MLINES
	MOV	L,A
MLINES:	CALL	MULT13
	SHLD	JUMPER
DLINES:
	LDA	WASHERE
	INR	A
	STA	WASHERE
DLINES1:
	MVI	A,1
	STA	VSFRST
	 ENDIF		; VSPAGE

	XRA	A		; Reset the 'A' register
PUTRET:	POP	H		; Exit from PUTCHR
	POP	D
	POP	B
	RET
;.....
;
; Output character, with low-case or reverse-video highlighting if high
; bit set and conditionals enabled.
;
HITYPE:	DS	0

	 IF	USELC OR REVID
	ORA	A		; Check for attributes not set
	JP	CONOUT		; No attribute..ignore this one
	ANI	7FH		; Attribute set, delete now
	 ENDIF			; USELC OR REVID

	 IF	NOT USELCW AND WHEEL
	MOV	E,A		; Save the character for later
	 ENDIF

	 IF	ZCPR3P AND (NOT USELCW AND WHEEL)
	PUSH	H
	LHLD	Z3WHLL		; Point to enviorment
	MOV	A,M		; Get it
	POP	H
	 ENDIF		;ZCPR3P AND ( NOT USELCW AND WHEEL)

	 IF	NOT ZCPR3P AND (NOT USELCW AND WHEEL)
	LDA	WHLOC		; Get wheel byte
	 ENDIF		;NOT ZCPR3P AND (NOT USELCW AND WHEEL)

	 IF	NOT USELCW AND WHEEL
	ORA	A		; Don't use lower case or REVID
	MOV	A,E		; Get back the character to display
	JZ	CONOUT
	 ENDIF			; NOT USELCW AND WHEEL

	 IF	REVID
	PUSH	PSW		; Save character
	LXI	D,RVON		; Turn on reverse video
	CALL	COUTS		; If not null
	POP	PSW		; Restore character
	 ENDIF			; REVID

	 IF	USELC
	CPI	'A'		; Change only from A-Z
	JC	TYPEC
	CPI	'Z'+1
	JNC	TYPEC		; Punctuation can change so leave it
	ORI	20H		; If attribute, make lower case
	 ENDIF			; USELC

	 IF	USELC OR REVID
TYPEC:	CALL	CONOUT		; Send the processed character
	 ENDIF			; USELC OR REVID

	 IF	REVID
	LXI	D,RVOFF		; Turn off reverse video
	CALL	COUTS		; If not null
	 ENDIF			; REVID

	 IF	USELC OR REVID
	RET
	 ENDIF			; USELC OR REVID
;.....
;
; Output character in A to console
;
CONOUT:	MOV	E,A		; Get character for BDOS entry
	MVI	C,WRCON
	JMP	BDOS		; Console Output
;.....
;
; Output (raw) null-terminated string at (DE) to console.
;

COUTS:	LDAX	D		; Get byte of string
	ORA	A		; Null?
	RZ			; Return if so
	PUSH	D
	CALL	CONOUT
	POP	D
	INX	D		; Next byte
	JMP	COUTS
;.....
;
; Output bytes at HL of length B to console/printer/file
;
PUTSB:	MOV	A,M
	CALL	PUTCHR
	INX	H
	DCR	B
	JNZ	PUTSB
	RET
;.....
;
; Output null-terminated string to console/printer/file
;
PUTS:	LDAX	D		; Load character from DE string
	ANI	7FH		; Strip off parity
	ORA	A		; Is a 0?
	RZ			; Yes, Terminate
	CALL	PUTCHR		; Display character
	INX	D		; Next string position
	JMP	PUTS		; Continue
;.....
;
; Fetch character from console (without echo)
;
GETCH:	LHLD	0000H+1		; Warm Boot Address
	MVI	L,9		; Direct Console
	CALL	GOHL		; Get Character
	ANI	7FH		; Strip off any parity
	RET
;.....
;
; Check for a CTL-C or CTL-S entered from the keyboard.  Jump to EXIT if
; CTL-C, pause on CTL-S.
;
CKABRT:	PUSH	H
	PUSH	D
	PUSH	B
	MVI	C,CONST
	CALL	BDOS
	ORA	A
	JZ	CKAB3		; No character, exit
	MVI	C,RDCON
	CALL	BDOS
	ANI	5FH
	CPI	'S'-40H
	JZ	CKAB0
	CPI	'S'
	JNZ	CKAB1
	CALL	CKAB4

CKAB0:	MVI	C,RDCON
	CALL	BDOS
	ANI	5FH

CKAB1:	CPI	'C'-40H		; CTL-C?
	JZ	CKAB2		; Yes, quit
	CPI	'K'-40H
	JZ	CKAB2
	CPI	'X'-40H
	JZ	CKAB2
	CPI	' '		; Any other CTL-character, abort
	JC	CKAB3
	CALL	CKAB4		; Clear the character from screen
	CPI	'C'
	JZ	CKAB2
	CPI	'K'
	JZ	CKAB2
	CPI	'X'
	JNZ	CKAB3

CKAB2:	LXI	D,CKMS1
	CALL	PUTS
	POP	B
	POP	D
	POP	H
	JMP	EX0		; All done

CKAB3:	POP	B
	POP	D
	POP	H
	RET

CKAB4:	PUSH	PSW
	LXI	D,CKMS2
	CALL	PUTS
	POP	PSW
	RET
;.....
;
; Call here to call address in HL
;
GOHL:	PCHL
;
; Enter BDOS, save all extended registers
;
CPM:	PUSH	B		; Save Registers
	PUSH	D
	PUSH	H

	 IF	ZRDOS
	LDA	ZRDFLG		; ZRDOS running?
	ORA	A
	JNZ	ZRD		; ZRDOS error trap and DOSs call
	 ENDIF			; ZRDOS

	CALL	BDOS
	MOV	B,A		; Save return code
	LDA	VERFLG		; Is this 3.0?
	CPI	30H
	MOV	A,B
	JC	CPM20		; No, exit normally
	CPI	0FFH		; Yes, was return code FF?
	JNZ	CPM20		; No, exit normally
	MOV	A,H		; Yes, check for error code
	ORA	A
	JNZ	DSKERR		; Exit if physical error
	MOV	A,B		; Else, continue normally

CPM20:	POP	H
	POP	D
	POP	B
	RET
;.....
;
; ZRDOS Error Trap and System Call exits to CPM20
;
	 IF	ZRDOS
ZRD:	CALL	SETTRAP		; Set the warm boot trap
	CALL	BDOS		; Do what we're told
	CALL	RESTRAP		; Reset the trap
	JMP	CPM20		; Error free exit
;.....
;
; Set Warm Boot Trap in ZRDOS
;
SETTRAP:PUSH	H
	PUSH	D
	PUSH	B
	MVI	C,SETWBT	; Set warm boot trap to come here
	LXI	D,WBTRAP
	CALL	BDOS
	POP	B
	POP	D
	POP	H
	RET
;.....
;
; WBTRAP is where the ZRDOS returns control on warm boot (error)
;
WBTRAP:	LXI	H,DSKERR	; Return here after trap reset
	PUSH	H		; Save DSKERR on stack
;
; Reset Warm Boot Trap in ZRDOS
;
RESTRAP:PUSH	H
	PUSH	D
	PUSH	B
	PUSH	PSW
	MVI	C,RESWBT	; Reset warm boot trap
	CALL	BDOS
	POP	PSW
	POP	B
	POP	D
	POP	H
	RET
	 ENDIF			; ZRDOS
;.....
;
; For file output mode, return to old user area and set DMA for the file
; output buffer.
;
SETFOP:	CALL	CKVER		; Clear carry if CP/M 2 or later
	LDA	OLDUSR		; Get user number at startup
	MOV	E,A
	MVI	C,STUSER
	CNC	CPM		; Reset old user number if CP/M 2
	LXI	D,OUTBUF	; Move DMA from search buffer into
	JMP	SET2		; Output buffer
	RET
;.....
;
; Move disk buffer DMA to default buffer for directory search operations
; and BDOS media change routines (required for pre-CP/M 2 systems while
; in file output mode with active buffer).
;
SETSRC:	LXI	D,TBUF		; Default DMA Address

SET2:	MVI	C,STDMA		; Set DMA Address
	JMP	CPM
;.....
;
; Print amount of free space remaining on selected drive
;
PRTFRE:	LXI	D,TOTMS7	; Print " Free: '
	CALL	PUTS
	LHLD	FREEBY
	CALL	DECPRT		; Print k free
	LXI	D,TOTMS8	; Print "k "
	CALL	PUTS
	LDA	VFLAG		; Alphabetizing vertically?
	ORA	A
	RZ			; If yes, finished
	JMP	CRLF		; Else turn up an extra line
;.....
;
; Show string on the console
;
SHOW:	LDAX	D		; Get character from DE string
	ANI	7FH		; Strip off parity
	ORA	A		; Is it a 0?
	RZ			; Yes, terminate
	PUSH	B		; Save registers
	PUSH	D
	PUSH	H
	CALL	CONOUT		; Show character on console
	POP	H		; Load registers
	POP	D
	POP	B
	INX	D		; Next string position
	JMP	SHOW		; Continue
;.....
;
; Compare routine for last extent of file search
;
COMPR:	PUSH	H		; Save table address
	MOV	E,M		; Load low order
	INX	H
	MOV	D,M		; Load high order
	INX	H
	MOV	C,M
	INX	H
	MOV	B,M
;
; BC, DE now point to entries to be compared
;
	XCHG
	MOV	E,A		; Get count

CMPLP:	LDAX	B
	XRA	M		; Copy bit 7 of M
	ANI	7FH		; Into bit 7 of A
	XRA	M
	CMP	M		; Then compare
	INX	H
	INX	B
	JNZ	NOTEQL		; Quit on mismatch
	DCR	E		; Or end of count
	JNZ	CMPLP
;
NOTEQL:	POP	H
	RET			; Condition code tells all
;.....
;
; Swap entries in the order table
;
SWAP:	LXI	B,ORDER-2	; Table base
	DAD	H		; *2
	DAD	B		; + base
	XCHG
	DAD	H		; *2
	DAD	B		; + base
	MOV	C,M
	LDAX	D
	XCHG
	MOV	M,C
	STAX	D
	INX	H
	INX	D
	MOV	C,M
	LDAX	D
	XCHG
	MOV	M,C
	STAX	D
	RET
;.....
;
; New compare routine for sorting
;
; Changed to perform full 8-bit test of file size words.  7-bit
; test failed when one word was 80h larger than the other. <crw>
;
COMPARE:LXI	B,ORDER-2
	DAD	H
	DAD	B
	XCHG
	DAD	H
	DAD	B
	XCHG
	MOV	C,M
	INX	H
	MOV	B,M
	XCHG
	MOV	E,C
	MOV	D,B
	MOV	C,M
	INX	H
	MOV	H,M
	MOV	L,C
;	LD	B,13		; Count for normal sort
	MVI	B,11
	LDA	TOPFLG		; Check for sort by type
	ORA	A
;	JP	NZ,CMPLPE	; Jump if normal sort
	JZ	COMP1		; Jump if sort by type
	CALL	CMPLPE
	RNZ
	JMP	COMP2		; Names match, go test extents
COMP1:
	PUSH	H		; Save name pointers for later
	PUSH	D
	LXI	B,8		; Point to file types
	DAD	B
	XCHG
	DAD	B
	XCHG
	MVI	B,3		; Count for type compare
	CALL	CMPLPE
	POP	D		; Retrieve name pointers
	POP	H		; 
	RNZ
	MVI	B,8		; Count for name compare
	CALL	CMPLPE
	RNZ
	INX	D		; Point to extent
	INX	D
	INX	D
	INX	H
	INX	H
	INX	H
COMP2:	MVI	B,2		; Count for extent compare

COMPB8:	LDAX	D
	CMP	M		; 8-bit compare <crw>
	INX	D
	INX	H
	RNZ
	DCR	B
	JNZ	COMPB8
	RET

CMPLPE:	LDAX	D		; 
	XRA	M		; Copy bit 7 of M
	ANI	7FH		; Into bit 7 of A
	XRA	M		; 
	CMP	M		; Then compare
	INX	D
	INX	H
	RNZ
	DCR	B
	JNZ	CMPLPE
	RET

;.....
;
; Error exit
;
ERXIT:	MVI	A,0FFH		; Error Flag
	STA	FOPFLG		; Disable file output on error
	CALL	CRLF		; Space down
	POP	D		; Load message string pointer
	CALL	PUTS		; Print message
	LXI	D,ERRMS1	; " Error"
	CALL	PUTS		; Print message
	CALL	CRLF		; Space down
;
; Exit - all done, restore stack
;
EXIT:	LDA	DOPFLG		; Multi-disk selected?
	ORA	A
	JNZ	EX0		; No, skip next
	CALL	CKABRT		; Check for user abort
	MVI	A,HIDRV-LODRV	; Maximum drive code to search
	LXI	H,FCB		; Increment directory FCB drive code
	INR	M
	CMP	M		; Does next disk exceed maximum?
	JC	EX0

;	 IF	MAXDRV

	 IF	ZCPR3P AND MAXDRV
	PUSH	H
	LHLD	Z3DRVL		; Point to ENV
	MOV	A,M		; Get it
	POP	H
	 ENDIF		;ZCPR3P AND MAXDRV

	 IF	NOT ZCPR3P AND MAXDRV
	LDA	MXDRV		; Look at another value limit
	INR	A
	 ENDIF		;NOT ZCPR3P AND MAXDRV

	 IF	MAXDRV AND NOT DRVVEC
	CMP	M		; Is it lower?
	JC	EX0		; Bail out if too low
	JMP	NOOPT		; Search next disk
	 ENDIF			; MAXDRV AND NOT DRVVEC

	JNC	NOOPT		; Search next disk if MAXDR not true

EX0:	LDA	VFLAG		; Check display form
	ORA	A
	CZ	CRLF		; Turn up a blank line at end if vertical
	MVI	C,CONST		; Check console status
	CALL	CPM
	ORA	A		; Character waiting?
	MVI	C,RDCON
	CNZ	CPM		; Gobble up character

	 IF	ZRDOS
	LDA	ZRDFLG		; ZRDOS running?
	ORA	A
	JNZ	EXIT2		; Yes
	 ENDIF			; ZRDOS

	LDA	VERFLG		; Version flag
	CPI	30H		; CP/M 3.0?
	JC	EXIT1		; No
	MVI	C,2DH		; Yes,
	MVI	E,0		; Reset error mode to default
	CALL	CPM
	JMP	EXIT2		; Quit

EXIT1:	LDA	DOPFLG		; If they were swapped
	ORA	A
	CZ	SWAPEM

EXIT2	EQU	$

	 IF	SHOPUB
	CALL	RSTPUB
	 ENDIF			; SHOPUB

	LDA	AOPFLG		; Doing all users
	MOV	C,A
	LDA	DOPFLG		; Or disk?
	ANA	C
	MOV	C,A
	LDA	HOPFLG		; Or higher users?
	ANA	C
	JNZ	TOTDONE		; If no, skip totals
	MVI	A,1		; Force no file output
	STA	LINCNT
	STA	FOPFLG
	LXI	D,ALLTOT	; First part of message
	CALL	PUTS
	LHLD	TOTFL1		; Total files found
	CALL	DECPRT
	LXI	D,TOTMS4
	CALL	PUTS
	LHLD	TOTSZ1		; Total 'k' found
	CALL	DECPRT
	LXI	D,TOTMS8
	CALL	PUTS
	LXI	D,TOTMS7
	CALL	PUTS
	LHLD	TOTFRE
	CALL	DECPRT
	LXI	D,ALLTO1
	CALL	PUTS
TOTDONE:
	 IF	WMBOOT
	JMP	0000H
	 ENDIF			; WMBOOT

	LDA	OLDDSK		; Restore original drive
	MOV	E,A
	MVI	C,14
	CALL	CPM
	LDA	OLDUSR		; Restore original user area
	MOV	E,A
	MVI	C,32
	CALL	CPM

EXIT3:	LHLD	STACK		; Get old stack pointer
	SPHL			; Move back to old stack
	RET			; And return to CCP
;.....
;
; Restore Public areas if they were changed
;
	 IF	SHOPUB
RSTPUB:	LHLD	0109H
	MVI	D,0
	MVI	E,07EH
	DAD	D
	LDA	PUBDRV
	MOV	M,A
	INX	H
	LDA	PUBUSR
	MOV	M,A
	RET
	 ENDIF			; SHOPUB
;.....
;
	 IF	NDIRS
NAMDIR:	MVI	A,0
	STA	CURDIR		; Initial check count

NAMDR1:	LHLD	NAMADR		; Named directory buffer address

NAMDR2:	LDA	FCB		; Get current Drive
	CMP	M		; Does NDR entry match current drive?
	JNZ	NXTDIR		; No, check next
	LDA	NEWUSR		; Get current user
	INX	H
	CMP	M		; Does NDR entry match current user?
	JNZ	NXTDIR		; No, check next
	MVI	A,'['		; Frame the name in brackets
	CALL	PUTCHR
	MVI	C,8		; Number of Characters in entry

DIRCHR:	INX	H		; Match, Point to Directory Name
	MOV	A,M		; Get Character
	CPI	20H		; End of entry?
	JNZ	DIRCH1		; No

DIRCH0:	PUSH	PSW
	MVI	A,']'		; Print closing bracket
	CALL	PUTCHR
	POP	PSW
	JMP	DIRCH2

DIRCH1:	CALL	PUTCHR
	DCR	C
	JNZ	DIRCHR		; Output Eight characters
	JMP	DIRCH0
	RET			; Done
DIRCH2:	MOV	A,C
	ORA	A
	RZ
	MVI	A,20H		; Fill with spaces for neatness sake
	CALL	PUTCHR
	DCR	C
	JNZ	DIRCH2
	RET

NXTDIR:	LDA	CURDIR
	ADI	1		; Increment Directory pointer
	STA	CURDIR
	LXI	H,NUMDIR
	CMP	M		; Exceeded Max Entry?
	JZ	NODIR		; Yes, there is no entry for this DU
	LHLD	NAMADR		; Get base NDR address
	MVI	D,0
	MVI	E,18		; Increment to next entry

NXTD:	DAD	D
	DCR	A		; Decrement count
	JNZ	NXTD		; Until current Offset reached
	JMP	NAMDR2		; And check the entry for a match
NODIR:	MVI	C,10		; No match, output ten spaces

NODIR1:	MVI	A,20H
	CALL	PUTCHR
	DCR	C
	JNZ	NODIR1
	RET
	 ENDIF			; NDIRS
;.....
;
; Trap BDOS select and sector error vectors to our own intercept routine
; so we can catch a reference to an illegal drive.
;
SWAPEM:	DS	0

	 IF	ZRDOS
	LDA	ZRDFLG		; See if ZRDOS running
	ORA	A
	RNZ			; Yes, quit this
	 ENDIF			; ZRDOS

	LDA	VERFLG		; Version flag
	CPI	30H		; Error mode call available?
	JC	SWAP20		; No, use BDOS error vectors
	MVI	C,2DH		; Yes, use error mode call
	MVI	E,0FFH		;
	CALL	CPM		; Set "return code only" mode
	RET

SWAP20:	LHLD	BDOS+1		; Load pointer to base of BDOS
	INX	H		; Swap new pointer if running a
	MOV	E,M		; Program below the CCP
	INX	H
	MOV	D,M
	XCHG			; HL points to the proper vector
	MVI	L,9		; Point to record error vector
	LXI	D,VECTBL	; Exchange with our vector table
	MVI	A,4		; 4 bytes to swap

SWAPLP:	MOV	B,M		; Load byte from HL
	XCHG
	MOV	C,M		; Load byte from DE
	MOV	M,B		; Save byte from HL
	XCHG
	MOV	M,C		; Save byte from DE
	INX	H		; Increment exchange pointers
	INX	D
	DCR	A		; Counter-1
	JNZ	SWAPLP		; Continue swapping
	RET
;.....
;
; Check CP/M version number. Return carry flag set if pre-CP/M 2.  If
; CP/M 2 or later or MP/M (any version), return carry clear.
;
CKVER:	LDA	VERFLG		; Version Flag
	CPI	20H		; CP/M 2.0?
	RET
;.....
;
; Return point from intercepted BDOS select and bad record errors.
;
DSKERR:	LXI	SP,STACK	; Get out of BDOS' stack
	JMP	EXIT		; And exit back to CCP
;.....
;
;-----------------------------------------------------------------------
;		     Start of FNAME routine
;
; Main module
;	on entry, DE points to FCB to be filled, HL points to first
;		byte of target string, RFCB is 36 bytes long
;	on exit, B=disk number (1 for A, etc.) and C=user number
;		HL points to terminating character
;		A=0 and Z set if error in disk or user numbers
;		A=0FFH and NZ if ok
;
MAXDISK	EQU	16		; Maximum number of disks
MAXUSER	EQU	31		; Maximum user number

FNAME:	PUSH	D		; Save DE
	MVI	A,0FFH		; Set default disk and user
	STA	DISKNO
	STA	USERNO
	MVI	B,36		; Initialize FCB
	PUSH	D		; Save pointer
	XRA	A		; A=0

FNINI:	STAX	D		; Store zero
	INX	D		; Point to next
	DCR	B		; Count down
	JNZ	FNINI
	POP	D		; Get pointer back
	PUSH	H		; Save pointer
;
; Scan for colon, comma, or space in string
;
COLON:	MOV	A,M		; Scan for colon or space
	INX	H		; Point to next
	CPI	':'		; Colon found?
	JZ	COLON1
	CPI	','		; Comma found?
	JZ	GETF1
	CPI	' '+1		; Delimiter?
	JC	GETF1
	JMP	COLON		; Continue if not EOL
;
COLON1:	POP	H		; Clear stack
	MOV	A,M		; Save possible drive specification
	CALL	CAPS		; Capitalize
	CPI	'A'		; Digit if less than "A"
	JC	USERCK		; Process user number
	SUI	'A'		; Change from ASCII to binary
	CPI	MAXDISK		; Within bounds?
	JC	SVDISK
;
ERREXIT:XRA	A		; Error indicator
	POP	D		; Restore DE
	RET
;.....
;
; Log in specified disk
;
SVDISK:	INR	A		; Adjust to 1 for "A"
	STA	DISKNO		; Save flag
	INX	H		; Point to next character
;
; Check for user
;
USERCK:	MOV	A,M		; Get possible user #
	CPI	':'		; No user number
	JZ	GETFILE
	CPI	'?'		; All user numbers?
	JNZ	USERC1
	STA	USERNO		; Set value
	INX	H		; Point to after
	MOV	A,M		; Must be colon
	CPI	':'
	JZ	GETFILE
	JMP	ERREXIT		; Fatal error if not colon after ?

USERC1:	XRA	A		; Zero user number
	MOV	B,A		; B = A for user number

USRLOOP:MOV	A,M		; Get digit
	INX	H		; Point to next
	CPI	':'		; Done?
	JZ	USRDN
	SUI	'0'		; Convert to binary
	JC	ERREXIT		; User number error?
	CPI	10
	JNC	ERREXIT
	MOV	C,A		; Next digit in C
	MOV	A,B		; Old number in A
	ADD	A		; *2
	ADD	A		; *4
	ADD	B		; *5
	ADD	A		; *10
	ADD	C		; *10+new digit
	MOV	B,A		; Result in B
	JMP	USRLOOP

USRDN:	MOV	A,B		; Get newer user number
	CPI	MAXUSER+1	; Within range?
	JNC	ERREXIT
	STA	USERNO		; Save in flag
	JMP	GETFILE
;
; Extract file name
;
GETF1:	POP	H		; Get pointer to byte
;
GETFILE:MOV	A,M		; Pointing to colon?
	CPI	':'
	JNZ	GFILE1
	INX	H		; Skip over colon

GFILE1:	MOV	A,M		; Get next character
	CPI	','		; Delimiter?
	JZ	GFQUES
	CPI	' '+1		; Not a delimiter?
	JNC	GFILE2

GFQUES:	INX	D		; Fill with ???
	MVI	B,11		; 11 bytes
	MVI	A,'?'

GFFILL:	STAX	D		; Put?
	INX	D		; Point to next
	DCR	B		; Count down
	JNZ	GFFILL

FNDONE:	LDA	DISKNO		; Get disk number
	MOV	B,A		; In 'B'
	LDA	USERNO		; Get user number
	MOV	C,A		; In 'C'
	POP	D		; Restore registers
	MVI	A,0FFH		; No error
	ORA	A		; Set flags
	RET
;
; Get file name fields
;
GFILE2:	MVI	B,8		; At most, 8 byte filename
	CALL	SCANF		; Scan and fill
	MVI	B,3		; At most, 3 byte filetype
	MOV	A,M		; Get delimiter
	CPI	'.'		; Filename ending in "."?
	JNZ	GFILE3
	INX	H		; Point to character after "."
	CALL	SCANF		; Scan and fill
	JMP	FNDONE		; Done, return to "args"

GFILE3:	CALL	SCANF4		; Fill with spaces
	JMP	FNDONE
;
; Scanner routine
;
SCANF:	CALL	DELCK		; Check for delimiter
	JZ	SCANF4		; Fill with spaces if found
	INX	D		; Next byte in filename
	CPI	'*'		; Question mark fill ?
	JNZ	SCANF1
	MVI	A,'?'		; Place "?"
	STAX	D
	JMP	SCANF2

SCANF1:	STAX	D		; Place character
	INX	H		; Next position

SCANF2:	DCR	B		; Count down
	JNZ	SCANF		; Continue loop

SCANF3:	CALL	DELCK		; Skip to delimiter
	RZ
	INX	H		; Point to next
	JMP	SCANF3

SCANF4:	INX	D		; Next filename or filetype
	MVI	A,' '		; Fill with spaces
	STAX	D
	DCR	B		; Count down
	JNZ	SCANF4
	RET
;.....
;
; Check character pointed to by HL for a delimiter,
; return with Zero flag set if the character is a delimiter
;
DELCK:	MOV	A,M		; Get the character
	CALL	CAPS		; Capitalize
	ORA	A		; 0=delimiter
	RZ
	CPI	' '+1		; Space character+1
	JC	DELCK1		; Space character or less
	CPI	'='
	RZ
	CPI	5FH		; Underscore
	RZ
	CPI	'.'
	RZ
	CPI	':'
	RZ
	CPI	';'
	RZ
	CPI	','
	RZ
	CPI	'<'
	RZ
	CPI	'>'
	RET
;
DELCK1:	CMP	M		; Compare with self for OK
	RET
;.....
;
CAPS:	CPI	'a'
	RC
	CPI	'z'+1
	RNC
	SUI	20H
	RET
;.....
;		      End of FNAME routine
;-----------------------------------------------------------------------
;
; Subroutines to read library file directory
;
PRTLMEM:LXI	H,ORDER		; Initialize order table pointer
	SHLD	NEXTL
	XRA	A
	STA	LNCNT

ENTRYL:	LHLD	LCOUNT		; Get FCB count
	DCX	H		; Decrement it
	SHLD	LCOUNT
	MOV	A,H		; Is this the last file?
	ORA	L
	JZ	LBRTST		; Yes, skip compare
	PUSH	B
	CALL	CKABRT		; Keyboard abort?
	LHLD	NEXTL
	MVI	A,11
	CALL	COMPR		; This entry match next one?
	POP	B
	JNZ	LBRTST		; No, print it
	INX	H
	INX	H		; Skip, highest extent last in list
	SHLD	NEXTL
	JMP	ENTRYL		; Loop back for next lowest extent
;.....
;
; Exit Library member printing
;
LBEXIT:	LHLD	LMTOTL
	MOV	A,H
	ORA	L
	RZ
	PUSH	H		; Save member count
	XRA	A		; Get a zero to
	STA	SUPSPC		; Suppress leading spaces in totals

	 IF	Z80DOS
	MVI	L,2		; If last line is full, don't turn
	LDA	NODFLG
	ORA	A
	JNZ	NOD7
	MVI	L,4
NOD7:
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	MVI	L,4		; If last line is full, don't turn
	 ENDIF		;NOT Z80DOS

	LDA	LNCNT
	CMP	L		; Up extra line
	CNZ	CRLF		; If partial line, extra line needed
	LXI	D,CONTM1	; Print "There are "
	CALL	PUTS
	POP	H		; Get total member count back
	CALL	DECPRT
	LXI	D,MFILES	; Print "Members in "
	CALL	PUTS
	LHLD	LBTOTL
	CALL	DECPRT
	LXI	D,LIBR
	JMP	PUTS
;
; Valid entry obtained - spit it out
;
LBRTST:	MVI	A,1		; Turn off .ARC/ARK
	STA	ISARC
	LHLD	NEXTL		; Load order table pointer
	MOV	E,M		; Low order address
	INX	H
	MOV	D,M		; High order address
	INX	H
	SHLD	NEXTL		; Save updated table pointer
	LXI	H,8
	DAD	D
	CALL	CKLBR
	JZ	LBRSET
	CALL	CKARC
	JNZ	LBRNEX
	XRA	A
	STA	ISARC

LBRSET:	PUSH	D

	 IF	Z80DOS
	LDA	NODFLG
	ORA	A
	JZ	ZARC0
	LDA	ISARC
	ORA	A
	JZ	ZARC0
	MVI	L,2		; 2 NAMES PER LINE
	JMP	ZARC0A
ZARC0:	MVI	L,4		; 4 NAMES PER LINE
ZARC0A:	LDA	LNCNT
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	LDA	LNCNT
	MVI	L,4
	 ENDIF		;NOT Z80DOS

	CMP	L
	CNZ	CRLF
	PUSH	PSW		; Just in case
	LXI	D,LFMSP1	; Long Library directory message
	LDA	ISARC
	ORA	A
	JNZ	SARCM1
	LXI	D,AFMSP1

SARCM1:	CALL	PUTS		; Print it
	POP	PSW		; Put it back
	LDA	FCB		; Load current drive
	ADI	'A'-1		; Convert to ASCII
	CALL	PUTCHR		; Print it
	CALL	PUTUSR		; Print user # after it
	MVI	A,':'		; And colon
	CALL	PUTCHR
	POP	H
	PUSH	H
	MVI	B,8		; Filename length
	CALL	PUTSB
	MVI	A,'.'		; Period after filename
	CALL	PUTCHR
	MVI	B,3		; 3 characters of filetype
	CALL	PUTSB

	 IF	Z80DOS
	LDA	NODFLG
	ORA	A
	JZ	NOD8
	CALL	DISDAT
NOD8:
	 ENDIF		;Z80DOS

	CALL	SIZEFL		; Compute size of library in k
	XCHG
	CALL	DECPRT
	LXI	D,LFMSP3
	CALL	PUTS
	POP	H
;
; Saves the library file name into LBRFCB
;
	LDA	FCB
	LXI	D,LBRFCB	; To
	STAX	D
	INX	D
	MVI	B,11		; Length
	CALL	MOVE		; Do the move
	XCHG
	MVI	B,25

CLMFCB:	MVI	M,0
	INX	H
	DCR	B
	JNZ	CLMFCB
	CALL	SETLDMA
	LXI	D,LBRFCB	; Point to file
	MVI	C,OPEN		; Get function
	CALL	CPM		; Open it
	MVI	C,READ
	LXI	D,LBRFCB
	CALL	CPM
	CALL	SETFOP
	LXI	H,LBBUF
	MOV	A,M
	ORA	A
	JZ	CKLDIR		; Check directory present?

	LDA	ISARC
	ORA	A
	JNZ	BADLBR
	MOV	A,M
	CPI	ARCMAR
	JZ	CKADIR

BADLBR:	LXI	H,NLBRF
	LDA	ISARC
	ORA	A
	JNZ	NBARC
	LXI	H,NARCF

NBARC:	MVI	B,25
	CALL	PUTSB
;
LMLEXI:	CALL	LBCLOS
;
; Do next library file
;
LBRNEX:	LHLD	LCOUNT		; Check count
	MOV	A,H
	ORA	L
	JZ	LBEXIT		; No more, all done
	JMP	ENTRYL		; Else, get next .LBR file
;.....
;
; Close the library file
;
LBCLOS:	LXI	D,LBRFCB
	MVI	C,CLOSE
	CALL	CPM
	RET
;.....
;
; Set the Library file DMA address
;
SETLDMA:CALL	CKVER		; Set carry if pre-CP/M 2
	LDA	NEWUSR		; Get user area for directory
	MOV	E,A
	MVI	C,STUSER	; Get the user function
	CNC	CPM		; And set new user number if CP/M 2
	LXI	D,LBBUF
	MVI	C,STDMA
	CALL	CPM
	RET
;.....
;
; Check to see if there indeed is a LBR file directory
;
CKLDIR:	MVI	B,11		; Length of file name
	MVI	A,' '		; Space
	INX	H

CKDLP:	CMP	M
	JNZ	BADLBR
	DCR	B
	INX	H
	JNZ	CKDLP
;
; The first entry in the LBR directory is indeed blank.  Now see if the
; directory size is > 0
;
	MOV	E,M		; File starting location low
	INX	H		; Must be zero here
	MOV	A,M		; File starting location high
	ORA	E		; Must be zero here also
	JNZ	BADLBR
	INX	H
	MOV	E,M		; Get library size low
	INX	H		; Point to library size high
	MOV	D,M		; Get library size high
	MOV	A,D
	ORA	E		; Library must have some size
	JZ	BADLBR
	DCX	D
	XCHG
	SHLD	SLFILE
	LHLD	LBTOTL
	INX	H
	SHLD	LBTOTL

	 IF	Z80DOS
	LDA	ISARC
	ORA	A
	JZ	ZARC1
	LDA	NODFLG
	ORA	A
	JZ	ZARC1
	MVI	A,2
	JMP	ZARC1A
ZARC1:	MVI	A,4
ZARC1A:
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	MVI	A,4
	 ENDIF		;NOT Z80DOS

	STA	LNCNT		; Reset names per line counter
	MVI	B,3
	LXI	H,17
	DAD	D
	JMP	LMTEST

LFMLOP:	LHLD	SLFILE		; Get next buffer if more
	MOV	A,L
	ORA	H
	JZ	LMLEXI
	DCX	H
	SHLD	SLFILE
	CALL	SETLDMA
	MVI	C,READ
	LXI	D,LBRFCB
	CALL	CPM
	CALL	SETFOP
	MVI	B,4		; Get file count per record
	LXI	H,LBBUF		; Get buffer starting address

LMTEST:	MOV	A,M		; Get member open flag
	ORA	A		; Test for open
	JZ	PRMNAM

LMTESA:	LDA	ISARC
	ORA	A
	RZ
	LXI	D,32		; Member not open get offset
	DAD	D		; To next and add it in
	DCR	B		; Is buffer empty ?
	JNZ	LMTEST		; No so test next entry
	JMP	LFMLOP		; Yes, get next buffer
;
PRMNAM:	PUSH	H		; Print member name and size
	PUSH	B
	CALL	CKABRT		; Keyboard abort?
	LXI	H,LNCNT

	 IF	Z80DOS
	LDA	ISARC
	ORA	A
	JZ	ZARC2
	LDA	NODFLG
	ORA	A
	JZ	ZARC2
	MVI	A,2
	JMP	ZARC2A
ZARC2:	MVI	A,4
ZARC2A:
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	MVI	A,4
	 ENDIF		;NOT Z80DOS

	CMP	M
	JNZ	PRMNA1

	 IF	PRBRDR
	MVI	A,'*'		; Load "A" with border character
	CALL	PUTCHR		; Print it
	MVI	A,' '		;
	CALL	PUTCHR		; Space between border and text
	 ENDIF			; PRBRDR

	JMP	PRMNA2

PRMNA1:	CALL	SPACE
	MVI	A,':'
	CALL	PUTCHR
	CALL	SPACE

PRMNA2:	POP	B
	POP	H
	PUSH	H
	PUSH	B
	INX	H
	MVI	B,8		; Filename length
	CALL	PUTSB
	MVI	A,'.'		; Period after filename
	CALL	PUTCHR
	MVI	B,3		; 3 characters of filetype
	CALL	PUTSB
	INX	H
	INX	H

	 IF	Z80DOS
	PUSH	H		; Save pointer
	LDA	ISARC
	ORA	A
	JZ	ZARC3
	LDA	NODFLG
	ORA	A
	JZ	ZARC3
	LXI	D,2
	DAD	D		; Skip size field and point to CRC
				; DISDAT will point it to date field
	CALL	DISDAT		; Show the date
ZARC3:	POP	H
	 ENDIF	;Z80DOS

	MOV	E,M
	INX	H
	MOV	D,M
	XCHG
;
; Output the size of the individual file
;
	PUSH	D
	PUSH	H
	XCHG
	LHLD	LLENLOC
	XCHG
	DAD	D
	SHLD	LLENLOC
	POP	H
;
; New code added to convert lib members from records to 'k'.  Upon entry
; member's size in records is in HL.
;
	LDA	COPFLG		; File sizes wanted in records?
	ORA	A
	JZ	PRMNA3		; Jump if so
	LXI	D,7		; Round up to nearest 1k
	DAD	D
	XCHG
	LXI	H,0
	MOV	A,E		; Low byte of record count in A
	RRC
	RRC
	RRC
	ANI	1FH
	MOV	E,A		; And put it back
	MOV	L,D		; Get the high byte if any
	MVI	D,0		; Clean out the old resting place
	DAD	H		; Multiply it by 32 to convert to
	DAD	H		; Number of k bytes
	DAD	H
	DAD	H
	DAD	H
	DAD	D		; And add in the low byte

PRMNA3:	POP	D
	CALL	DECPRT		; Go print it
	LDA	FSIZEC		; Follow with 'k' or 'r'
	CALL	PUTCHR
;
; Update library member total and name counter
;
	LHLD	LMTOTL
	INX	H
	SHLD	LMTOTL
	LDA	LNCNT
	DCR	A
	STA	LNCNT
	POP	B
	POP	H
	JNZ	LMTESA		; And go output another file
;
; Current line full, start a new one
;
	 IF	Z80DOS
	LDA	ISARC
	ORA	A
	JZ	ZARC4
	LDA	NODFLG
	ORA	A
	JZ	ZARC4
	MVI	A,2
	JMP	ZARC4A
ZARC4:	MVI	A,4
ZARC4A:
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS
	MVI	A,4
	 ENDIF		;NOT Z80DOS

	STA	LNCNT		; Reset names per line counter
	CALL	CRLF		; Space down to next line
	JMP	LMTESA
;.....
;
; Move characters from "HL" to "DE" length in "B"
;
MOVE:	MOV	A,M		; Get a character
	STAX	D		; Store it
	INX	H		; To next "from"
	INX	D		; To next "to"
	DCR	B		; More?
	JNZ	MOVE		; Yes, loop
	RET			; No, return
;.....
;
; Archive file subroutines
;
CKADIR:	XRA	A
	DCR	A
	STA	GETABL		; Say buffer is full (first read by lbr test)
	LHLD	LBTOTL		; Bump library count total
	INX	H
	SHLD	LBTOTL
	MVI	A,4		; LDA	 MNPL
	STA	LNCNT		; Reset names per line counter

ARCLP:	CALL	GET		; Get the next character from buffer
	CPI	ARCMAR		; Is it archive header marker?
	JNZ	BADLBR		; And abort if not
	CALL	GET		; Get header version
	ORA	A		; If zero, that's logical end of file,
	JZ	LMLEXI		; And we're done
	LXI	D,ANAME		; Set to fill header buffer
	MVI	B,HDRSIZ	; Setup normal header size less file name
	CPI	1		; But test if version 1
	JNZ	GETHD1		; Skip if not version 1
	LXI	B,HDRSIZ-4	; Else, header is 4 bytes less

GETHD1:	CALL	GET		; Get header byte
	STAX	D		; Store in buffer
	INX	D
	DCR	B
	JNZ	GETHD1		; Loop for all bytes
	LXI	H,ARCFIL	; Prefill dummy arc FCB name with spaces
	MVI	B,11

FIXAN:	MVI	M,' '
	INX	H
	DCR	B
	JNZ	FIXAN
	MVI	B,5		; Prefill rest of dummy FCB with zero

FIXAE:	MVI	M,0
	INX	H
	DCR	B
	JNZ	FIXAE
	LXI	H,ANAME		; Get pointer to archive header buffer
	LXI	D,ARCFIL	; Point to our dummy FCB
	MVI	B,8		; Get name length

MANAME:	MOV	A,M		; Get character from header
	INX	H
	ORA	A
	JZ	AEDONE		; Nothing in buffer so we're done
	CPI	02EH		; Is the char a point
	JZ	DAEXT		; DO FILE EXTENT
	STAX	D
	INX	D
	DCR	B
	JNZ	MANAME

DAEXT:	LXI	D,ARCFIL+8	; Get dummy file extent address
	MVI	B,3
	MOV	A,M
	CPI	2EH
	JNZ	AELOP
	INX	H

AELOP:	MOV	A,M		; Fill in the file extent
	ORA	A
	JZ	AEDONE
	STAX	D
	INX	H
	INX	D
	DCR	B
	JNZ	AELOP

AEDONE:	LXI	H,ASIZE
	MOV	E,M		; Fetch BCDE from (HL)
	INX	H
	MOV	D,M
	INX	H
	MOV	C,M
	XRA	A		; Clear flags
	MOV	A,E		; Convert file length count in bytes
	RAL			; To length in records for output
	MOV	A,D
	RAL
	MOV	E,A
	MOV	A,C
	RAL
	MOV	D,A
	XCHG
	SHLD	ARCFIL+13	; Save file length
	LXI	H,ARCFIL-1	; Point to dummy FCB
	CALL	PRMNAM		; List the file info
	LXI	H,ASIZE		; Get remaining file size
	MOV	A,M
	ANI	7FH
	LHLD	ARCFIL+13	; Save file length
	XCHG			; Save record offset
	LXI	H,GETABL	; Point to offset of last byte read
	ADD	M		; Add byte offsets
	CPI	80H		; Does it overflow current record?
	JC	NRAD
	SUI	80H		; Adjust pointer
	INX	D		; Bump record number

NRAD:	MOV	M,A		; Update buffer pointer for new position
	MOV	A,D		; Check record offset
	ORA	E
	JZ	LEXIT		; Return if none (still in same record)
	PUSH	D		; Save record offset
	LXI	D,LBRFCB
	MVI	C,RECORD	; Compute current "random" record no.
	CALL	CPM		; (I.e. next sequential record to read)
	LHLD	LBRFCB+FRN	; Get result
	DCX	H		; Adjust next record to current record
	POP	D		; Restore record offset
	DAD	D		; Compute new record no.
	JC	BADLBR		; If >64k, it's past largest (8 Mb) file
	SHLD	LBRFCB+FRN	; Save new record no.
	MVI	C,READRN	; Read the random record
	CALL	GETREC
	ORA	A
	JNZ	BADLBR		; File read error
	LXI	H,LBRFCB+FCR	; Point to current record in extent
	INR	M		; Bump for subsequent sequential read

LEXIT:	JMP	ARCLP		; Loop for next file
;.....
;
; Get next sequential byte from archive file
;
GET:	PUSH	B		; Save registers
	PUSH	D
	PUSH	H
	LDA	GETABL		; Point to last byte read
	INR	A		; At end of buffer?
	CPI	80H
	CNC	GETNXT		; Yes, read next record and reset pointer
	STA	GETABL		; Save new buffer pointer
	MOV	L,A
	MVI	H,0
	LXI	D,LBBUF
	DAD	D
	MOV	A,M		; Fetch byte from there
	POP	H		; Restore registers
	POP	D
	POP	B
	RET			; Return
;
; Get next sequential record from archive file
;
GETNXT:	MVI	C,READ		; Setup read-sequential function code
	CALL	GETREC
	ORA	A
	JNZ	RDERR
	PUSH	PSW
	XRA	A
	DCR	A
	STA	GETABL
	POP	PSW
	RET
;
RDERR:	POP	H		; Strip GETNXT return
	POP	H		; Clean up the get stack
	POP	D
	POP	B
	POP	H		; Strip get calling address
	JMP	BADLBR		; Show error
;
; Get record (sequential or random) from archive file
;
GETREC:	PUSH	H
	PUSH	B
	CALL	SETLDMA		; Set library DMA address
	LXI	D,LBRFCB	; Setup FCB address
	POP	B		; Restore read function
	CALL	CPM		; Do it
	PUSH	PSW		; Save read status
	CALL	SETFOP		; Reset Print file DMA address
	POP	PSW		; Restore read status
	POP	H		; Restore buffer pointer
	RET
;.....
;
; Test file extent for ARC/ARK
;
CKARC:	PUSH	H
	PUSH	D
	PUSH	B
	XCHG
	LXI	H,ARCTYP
	MVI	C,2		; Number for the loop to test
;
CKARL:	LDAX	D
	ANI	7FH
	CMP	M
	JNZ	CKARX
	INX	H
	INX	D
	DCR	C
	JNZ	CKARL
;
; The first 2 match now see if C or K for .ARC or .ARK
;
	LDAX	D
	ANI	7FH
	CPI	'C'		; See if "C"
	JZ	CKARX
	CPI	'K'		; See if "K"

CKARX:	POP	B
	POP	D
	POP	H
	RET
;.....
;
; Test file extent for LBR
;
CKLBR:	PUSH	H
	PUSH	D
	PUSH	B
	XCHG
	LXI	H,LBRTYP
	MVI	C,3

CKLBL:	LDAX	D
	ANI	7FH
	CMP	M
	JNZ	CKLBX
	INX	H
	INX	D
	DCR	C
	JNZ	CKLBL

CKLBX:	POP	B
	POP	D
	POP	H
	RET
;
; TIMEON routine
;
; Go through a search to see if BYE is active
;
	 IF	TIMEON
TIME:	LHLD	0001H		; Point to warm boot again
	DCX	H		; If BYE active,
	MOV	D,M		; Pick up pointer to BYE variables
	DCX	H		; (COVECT) followed by "BYE"
	MOV	E,M
	LXI	H,15		; Calculate address of BYE variable
	DAD	D		; Where ptr to orig BIOS vector stored
	MOV	E,M		; Load that address into DE
	INX	H		; If BIOS active, DE now points to
	MOV	D,M		; Original BIOS console output vector
	INX	H		; Point to BYE signon message
	MOV	A,M		; Get letter
	ANI	05FH		; Convert to upper case if needed
	CPI	'B'		; Try to match "BYE"
	RNZ			; Out if BYE not active
	INX	H
	MOV	A,M
	ANI	05FH		; Convert to u-case if needed
	CPI	'Y'
	RNZ
	INX	H
	MOV	A,M
	ANI	05FH		; Convert to u-case if needed
	CPI	'E'
	RNZ

	LXI	D,6		; Bye running, point to RTCBUF
	DAD	D
	MOV	E,M		; Get RTCBUF address
	INX	H		; And copy
	MOV	D,M		; In DE
	XCHG			; Put in HL
	LXI	D,7		; Offset to
	DAD	D		; Time-on-system byte
	MOV	A,M		; Load TOS byte
	LXI	H,TONMS1	; Where to store in ASCII
	CALL	DEC8		; Convert binary to ASCII
	LXI	D,TONMSG
	CALL	PUTS		; Print the message
	RET			; And return
;.....
;
; DEC8 will convert an 8 bit binary number in A to 3 ASCII
; bytes. HL points to the MSB location where the ASCII bytes
; will be stored. Leading zeros are suppressed, store spaces
; in your buffer before calling.
;
DEC8:	PUSH	B
	PUSH	D
	MVI	E,0		; Leading zero flag
	MVI	D,100

DEC81:	MVI	C,'0'-1

DEC82:	INR	C
	SUB	D		; 100 or 10
	JNC	DEC82		; Still +
	ADD	D		; Now add it back
	MOV	B,A		; Remainder
	MOV	A,C		; Get 100/10
	CPI	'1'		; Zero?
	JNC	DEC83		; Yes
	MOV	A,E		; Check flag
	ORA	A		; Reset?
	MOV	A,C		; Restore byte
	JZ	DEC84		; Leading zeros are skipped

DEC83:	MOV	M,A		; Store in buffer
	INX	H		; Increment storage location
	MVI	E,0FFH		; Set zero flag

DEC84:	MOV	A,D
	SUI	90		; 100 to 10
	MOV	D,A
	MOV	A,B		; Remainder
	JNC	DEC81		; Do it again
	ADI	'0'		; Make ASCII
	MOV	M,A		; And store it
	POP	D
	POP	B
	RET

TONMSG:	DB	13,10,'Minutes on System: '
TONMS1:	DB	'    ',0
	 ENDIF			; TIMEON
;
;		      end of TIMEON routine
;-----------------------------------------------------------------------
;			   help routine
;
; Help menu if ? is typed, using a fancy ZCMD or ZCPR system
;
	 IF	WHEEL
HELPME:	LXI	D,OPTMSG	; Point at message
	CALL	SHOW
	 ENDIF		;WHEEL

	 IF	ZCPR3P AND WHEEL
	PUSH	H
	LHLD	Z3WHLL		; Point to enviorment
	MOV	A,M		; Get it
	POP	H
	 ENDIF		;ZCPR3P AND WHEEL

	 IF	NOT ZCPR3P AND WHEEL
	LDA	WHLOC		; Get wheel byte
	 ENDIF		;NOT ZCPR3P AND WHEEL

	 IF	WHEEL
	ORA	A		; If set, help out poor SYSOP
	JZ	EXIT3		; No - exit
	LXI	D,SYSOP1	; Point at message
	CALL	SHOW
	JMP	EXIT3		; And exit
;
; This menu of options will appear to normal users (WHEEL not set).
; Modify the menus to accommodate your system requirements.
;
OPTMSG:	DB	13,10,13,10
	DB	'  Available Options (start with a  $  or  /  or'
	DB	'  [ character):',13,10,13,10
	DB	'  A - all user areas               N - no page pause'
	DB	' [more]',13,10
	DB	'  C - file sizes in records        Q - show non-$ARCHived'
	DB	' files',13,10
	DB	'  D - all drives                   T - order files'
	DB	' by EXT type',13,10
	DB	'  H - Current area to highest      V - show version'
	DB	' number',13,10
	DB	'  L - list LBR/ARC/ARK members     X - aux. format'
	DB	' (horiz/vert)'
	 ENDIF

	 IF	Z80DOS AND WHEEL
	DB	13,10
	DB	'  Z - Do not show dates',13,10
	DB	'  = - Exact date match             + - GE date match',13,10
	DB	'  - - LT date match                ! - Use creation date for'
	DB	' match',13,10
	DB	'  % - Use alteration date match    @ - Use access date for'
	DB	' match',13,10
	DB	'   A date input with no =+-!%@ will use =% default,'
	DB	' * as date is current date'
	 ENDIF		;Z80DOS

	 IF	WHEEL
	DB	13,10,13,10
	 ENDIF

	 IF	Z80DOS AND WHEEL
	DB	' Example - to list all drives/users, no pauses,'
	DB	' GE date match on access date:',13,10,13,10
	DB	'                     B0>SD $AND+@ 7/1/88'
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS AND WHEEL
	DB	'  Example - to list all drives and user areas,'
	DB	' no pauses:',13,10,13,10
	DB	'                     B0>SD $AND <ret>'
	 ENDIF		;NOT Z80DOS

	 IF	WHEEL
	DB	13,10,13,10,0
;
; This menu of options appears only when the WHEEL is set.
;
SYSOP1:	DB	'  * * * Special SYSOP Options (WHEEL SET) * * *'
	 ENDIF

	 IF	NOT FATTRIB AND WHEEL
	DB	13,10,13,10
	 ENDIF		;NOT FATTRIB

	 IF	FATTRIB AND WHEEL
	DB	13,10
	 ENDIF		;FATTRIB

	 IF	WHEEL
	DB	'  F - file output (DISK.DIR)       R - reset disk'
	DB	' system',13,10
	DB	'  O - show $SYS files only         S - include'
	DB	' $SYS files',13,10
	DB	'  P - printer output',13,10
	 ENDIF

	 IF	FATTRIB AND WHEEL
	DB	'  1 - Check attrib 1               2 - Check attrib 2',13,10
	DB	'  3 - Check attrib 3               4 - Check attrib 4',13,10
	 ENDIF		;FATTRIB

	 IF	WHEEL
	DB	0
	 ENDIF			; WHEEL
;
; Help menu if ? is typed, NOT using any fancy ZCMD or ZCPR system
;
	 IF	NOT WHEEL
HELPME:	LXI	D,OPTMSG	; Point at message
	CALL	SHOW
	JMP	EXIT3		; And exit
;
OPTMSG:	DB	13,10,13,10
	DB	'  Available Options (start with a  $  or  /  or'
	DB	'  [  character):',13,10
	DB	13,10
	DB	'  A - all user areas               P - printer output'
	DB	13,10
	DB	'  C - file sizes in records        Q - show non $ARChived'
	DB	' files',13,10
	DB	'  D - all drives                   R - reset disk system'
	DB	13,10
	DB	'  F - file output (DISK.DIR)       S - include $SYS'
	DB	' files',13,10
	DB	'  H - Current area to highest      T - order files'
	DB	' by EXT type',13,10
	DB	'  L - list LBR/ARC/ARK members     V - show version'
	DB	' number',13,10
	DB	'  N - no page pause [more]         X - aux. format'
	DB	' (horiz/vert)',13,10
	DB	'  O - show $SYS files only'
	 ENDIF		;NOT WHEEL

	 IF Z80DOS AND NOT WHEEL
	DB	'         Z - do not show dates'
	 ENDIF			; Z80DOS

	 IF	NOT WHEEL
	DB	13,10
	 ENDIF		;NOT WHEEL

	 IF	FATTRIB AND NOT WHEEL
	DB	'  1 - Check attrib 1               2 - Check attrib 2',13,10
	DB	'  3 - Check attrib 3               4 - Check attrib 4',13,10
	 ENDIF		;FATTRIB

	 IF	Z80DOS AND NOT WHEEL
	DB	'  = - Exact date match             + - GE date match',13,10
	DB	'  - - LT date match                ! - Use creation date for'
	DB	' match',13,10
	DB	'  % - Use alteration date match    @ - Use access date for'
	DB	' match',13,10
	DB	'   A date input with no =+-!%@ will use =% default,'
	DB	' * as date is current date'
	DB	13,10,13,10
	DB	' Example - to list all drives/users, no pauses,'
	DB	' GE date match on access date:',13,10,13,10
	DB	'                     B0>SD $AND+@ 7/1/88',13,10,13,10,0
	 ENDIF		;Z80DOS

	 IF	NOT Z80DOS AND NOT WHEEL
	DB	13,10,'  Example - to list all drives and user areas,'
	DB	' no pauses:',13,10,13,10
	DB	'                     B0>SD $AND <ret>'
	DB	13,10,13,10,13,10,13,10,13,10,13,10,13,10
	DB	0
	 ENDIF		;NOT Z80ODS

;	 ENDIF			; NOT WHEEL


	 IF	Z80DOS
DISDAT:	PUSH	B
	PUSH	H		; Save pointer to size field
	PUSH	D
	INX	H		; and skip over size
	INX	H		;
	MOV	E,M		; Get JD in DE
	INX	H		;
	MOV	D,M		;
	XCHG			; to HL
	CALL	DATEHL		;
	PUSH	H		; Month and Year in L,H
	PUSH	PSW		; Day in A
	CALL	SPACE
	CALL	SPACE
	POP	PSW
	JNZ	DAYOK		; NZ = was a day there
	POP	H
	CALL	NODATE
	JMP	DNOTOK
DAYOK:	PUSH	PSW
	MOV	A,L		; Month out
	CALL	BCDOUT
	MVI	A,'/'
	CALL	PUTCHR
	POP	PSW
	CALL	BCDOUT		; Day out
	MVI	A,'/'
	CALL	PUTCHR
	POP	H
	MOV	A,H		; Year out
	CALL	BCDOUT
DNOTOK:	CALL	SPACE
	CALL	SPACE
	POP	D
	POP	H
	POP	B
	RET

NODATE:
	LXI	D,NODATM
	CALL	PUTS
	RET
NODATM:
	DB	'-- -- --',0

BCDOUT:
	PUSH	B		; Save
	MOV	B,A		; A holds BCD digits
	RAR
	RAR
	RAR
	RAR
	CALL	BCDOT1		; Output high order
	MOV	A,B
	CALL	BCDOT1		; And low order
	POP	B
	RET
BCDOT1:	ANI	0FH
	ADI	'0'
	CALL	PUTCHR
	RET

;
; DATEHL converts the value in HL to BCD year, month, day
;	 for use with Z80DOS time stamps.
;
;
; Inputs:	HL contains hex days since December 31, 1977
;
; Outputs:	H contains BCD 20th century year
;		L contains BCD month
;		A contains BCD day
;
;		Zero flag set (Z) and A=0 if invalid date (zero) detected,
;		Zero flag reset (NZ) and A=0ffh otherwise.

; Converted to 8080 from DATEHL by Carson Wilson who Adapted from B5C-CPM3.INS

DATEHL:
	MOV	A,H
	ORA	L		; Test blank date (zero)
	RZ			; Return Z and A=0 if so
	SHLD	DAYS		; Save initial value
	MVI	B,78		; Set years counter
LOOP:
	CALL	CKLEAP
	LXI	D,-365		; Set up for subtract
	JNZ	NOPLY		; Skip if no leap year
	DCX	D		; Set for leap year
NOPLY:
	DAD	D		; Subtract
	JNC	YDONE		; Continue if years done
	MOV	A,H
	ORA	L
	JZ	YDONE
	SHLD	DAYS		; Else save days count
	INR	B		; Increment years count
	JMP	LOOP		; And do again
;
; The years are now finished, the years count is in 'B' (HL is invalid)
;
YDONE:
	MOV	A,B
	CALL	BINBCD
	STA	YEARS		; save BCD year
;
	CALL	CKLEAP
	MVI	A,0E4H		; -28
	JNZ	FEBNO		; February not 29 days
	MVI	A,0E3H		; Leap year -29
FEBNO:
	STA	FEB		; Set february
	LHLD	DAYS		; Get days count
	LXI	D,MTABLE	; Point to months table
	MVI	B,0FFH		; Set up 'B' for subtract
	MVI	A,0		; Set a for # of months
MLOOP:
	PUSH	PSW
	LDAX	D		; Get month
	MOV	C,A		; Put in 'C' for subtract
	POP	PSW
	SHLD	DAYS		; save days count
	DAD	B		; Subtract
	INX	D		; Increment months counter
	INR	A
	JC	MLOOP		; Loop for next month

;
; The months are finished, days count is on stack.  First, calculate
; month.
;
MDONE:
	MOV	B,A		; Save months
	LHLD	DAYS
	MOV	A,H
	ORA	L
	JNZ	NZD
	DCX	D
	DCX	D
	LDAX	D
	CMA
	INR	A
	MOV	L,A
	DCR	B
NZD:
	MOV	A,L		; Retrieve binary day of month
	CALL	BINBCD		; Convert to BCD
	PUSH	PSW		; Save day in A
;
	MOV	A,B		; Retrieve the binary month
	CALL	BINBCD		; Convert binary month to BCD
	MOV	L,A		; Return month in L
;
	LDA	YEARS
	MOV	H,A		; Return year in H
;
	POP	PSW		; Restore day
	ORA	A		; Set NZ flag
	RET

;
; Support Routines:
;

;
; Check for leap years.
;
CKLEAP:
	MOV	A,B
	ANI	0FCH
	CMP	B
	RET
;
; Convert A to BCD & store back in A
;
BINBCD:
	ORA	A
	RZ
	PUSH	B
	MOV	B,A
	XRA	A
BINBCD1:
	ADI	1
	DAA
	DCR	B
	JNZ	BINBCD1
	POP	B
	RET
;
; Buffers:
;

;
; Months table
;
MTABLE:
	DB	0E1H			;January -31
FEB:
	db	0E4H 			;February -28
	db	0E1H,0E2H,0E1H,0E2H 	;Mar-Jun -31,-30,-31,-30
	db	0E1H,0E1H,0E2H		;Jul-Sep -31,-31,-30
	db	0E1H,0E2H,0E1H		;Oct-Dec -31,-30,-31

	 ENDIF	;Z80DOS



;
; Messages and Error statements
;
CKMS1:	DB	13,10,'++ ABORTED ++',0
CKMS2:	DB	8,' ',8,0
DRUMSG:	DB	'Drive/User',0
EOSMSG:	DB	'[more] ','$'

	 IF	VSPAGE
MORERA:	DB	13,'                  ----------------------------------------'
	DB	13,10,'$'
	 ENDIF			;VSPAGE

	 IF	NOT VSPAGE
MORERA:	DB	13,'        ',13,'$'
	 ENDIF

ERRMS1:	DB	' '
ERRMS2:	DB	'Error',0
ERRTAG:	DB	' ->',0
NOFLM:	DB	'>> No detectable file(s) on ',0
NOFMS1:	DB	13,10,13,10,' ',0
NOFMS2:	DB	'  ',0
NOFMS3:	DB	':  ',0
SOHFLG:	DB	0
TOTMS1:	DB	13,10,'         Drive ',0
TOTMS4:	DB	'/',0
TOTMS5:	DB	'k  ',0
TOTMS6:	DB	' Files: ',0
TOTMS7:	DB	' Free: ',0
TOTMS8:	DB	'k ',0
ALLTOT:	DB	13,10,'             Total files: ',0
ALLTO1:	DB	'k',13,10,0

	 IF	PRBRDR
CONTM1:	DB	13,10,'** There are ',0
MFILES:	DB	' member files in ',0
LIBR:	DB	' library(s) and/or archive(s) **',0
AFMSP1:	DB	13,10,'** Archive directory for ',0
LFMSP1:	DB	13,10,'** Library directory for ',0
LFMSP3:	DB	'k'
	DB	' **'
	DB	13,10,0
	 ENDIF			; PRBRDR

	 IF	NOT PRBRDR
CONTM1:	DB	13,10,'There are ',0
MFILES:	DB	' member files in ',0
LIBR:	DB	' library(s) and/or archive(s)',0
AFMSP1:	DB	13,10,'Archive directory for ',0
LFMSP1:	DB	13,10,'Library directory for ',0
LFMSP3:	DB	'k'
	DB	13,10,0
	 ENDIF			; Not PRBRDR

NLBRF:	DB	'++ Not a library file ++',13,10
NARCF:	DB	'++ Not an archive file ++',13,10
LBRTYP:	DB	'LBR'
ARCTYP:	DB	'AR'		; We only test the first 2 in the loop.
				; The C or K are tested separately.
;
; Permanently initialized data area
;
VECTBL:	DW	DSKERR		; BDOS record error intercept vector
	DW	DSKERR		; BDOS select error intercept vector
;
; End of code that must be stored on disk in the .COM file
;
; Data area reinitialized by code when SD is run or rerun
;
DATA0	EQU	$		; Start of area to initialize

OTBL	EQU	$		; Mark start of option table
VFLAG:	DS	1
AOPFLG:	DS	1
COPFLG:	DS	1
DOPFLG:	DS	1
FOPFLG:	DS	1
HOPFLG:	DS	1
LOPFLG:	DS	1
NOPFLG:	DS	1
OOPFLG:	DS	1
POPFLG:	DS	1
QOPFLG:	DS	1
ROPFLG:	DS	1
SOPFLG:	DS	1
TOPFLG:	DS	1
VOPFLG:	DS	1
XOPFLG:	DS	1

	 IF	Z80DOS		;
DEOPFL:	DS	1
DPOPFL:	DS	1
DMOPFL:	DS	1
DNOPFL: DS	1
DAOPFL: DS	1
DGOPFL:	DS	1
NODFLG:	DS	1
	 ENDIF	;Z80DOS

	 IF	FATTRIB
ONEFLG:	DS	1
TWOFLG:	DS	1
THRFLG:	DS	1
FORFLG:	DS	1
	 ENDIF

OEND	EQU	$		; End of option table
;
; End of option lookup table
;
BUFPNT:	DS	2		; Next location in output buffer
BUFCNT:	DS	1		; Number of bytes left in output buffer
OUTFCB:	DS	1+8+3		; User number, filename, and filetype
;
; Beginning of area reinitialized to zero each time SD.COM is run
;
	DS	21		; Rest of DISK.DIR FCB
DISKNO:	DS	1		; Disk number
USERNO:	DS	1		; User number
OPNFLG:	DS	1		; File open flag
DRVFLG:	DS	1		; D option check for prior drive specificaton
FNDFLG:	DS	1		; Files Matched Flag
BYEACT:	DS	1		; BYE Active Flag

LINCNT:	DS	1		; # lines printed on screen
LLENLOC:DS	2		; Running total of .LBR length
LMTOTL:	DS	2
LBTOTL:	DS	2
LNCNT:	DS	1
LCOUNT:	DS	2
NEXTL:	DS	2
SLFILE:	DS	2
LINES:	DS	1		; Number of lines to be printed
FIRSTT:	DS	1		; First time flag for version number
ISARC:	DS	1
;
; Uninitialized data area
;
BASUSR:	DS	1		; Copy of original directory user #
BLKMAX:	DS	2		; Highest block # on drive
BLKMSK:	DS	1		; Records/block - 1
BLKSHF:	DS	1		; Number shifts to mult by sec/blk
COUNT:	DS	2		; Entry count
DIRMAX:	DS	2		; Highest file # in directory
FILERC:	DS	2		; File size in records
FREEBY:	DS	2		; Number of k left on dir. drive
FSIZEC:	DS	1		; File size character ('k' or 'r')
GAP:	DS	2		; Sort routine storage
I:	DS	2		; Sort routine storage
J:	DS	2		; Sort routine storage
JG:	DS	2		; Sort routine storage
LZFLG:	DS	1		; 0 when printing leading zeros
MAXUSR:	DS	1		; Max user # for drive
NEWUSR:	DS	1		; User # selected by "$U" option
NEXTT:	DS	2		; Next table entry
OLDDSK:	DS	1		; Currently logged-in drive
OLDUSR:	DS	1		; User number upon invocation
SCOUNT:	DS	2		; # to sort
SUPSPC:	DS	1		; Leading space flag
TBLOC:	DS	2		; Start of name table
TOTFIL:	DS	2		; Total number of files
TOTSIZ:	DS	2		; Total size of all files
TOTFL1:	DS	2		; Total files of all D/U
TOTSZ1:	DS	2		; Total size of all D/U
TOTFRE:	DS	2
USRNR:	DS	1		; User number
VERFLG:	DS	1		; CP/M version number (0=pre-CP/M 2)
ZRDFLG:	DS	1		; ZRDOS version number

	IF	Z80DOS		;
DATPLS:	DS	1		; Holds +/- flag for date math
DATCH1:	DS	2		; Holds first input date
DATCHK:	DS	2		; Holds date to look for
DTMTCH:	DS	1		; Holds <,>=,>
DATMOD:	DS	2		; Holds date found for file
DAYS:	ds	2		; temporary buffers
YEARS:	ds	1		;
YEARS1:	DS	1
MONTHS:	DS	1
DAYS1:	DS	1
ASCII:	DS	5		; holds date from system
	ENDIF		;Z80DOS


DATA1	EQU	$		; End of area to initialize

	 IF	ZCPR3P
Z3DRVL:	DS	2		; Points to Z33 max drv location
Z3USRL:	DS	2		; Points to Z33 max user location
Z3WHLL:	DS	2		; Points to Z33 wheel location
	 ENDIF		;ZCPR3P

	 IF	NDIRS
NAMADR:	DS	2		; Named Directory Buffer Address
NUMDIR:	DS	1		; Number of entries
CURDIR:	DS	1		; NDR Check counter
	 ENDIF			; NDIRS

	 IF	SHOPUB
PUBDRV:	DS	1		; Storage for Public Drive byte
PUBUSR:	DS	1		; "	"    "	  User	 "
	 ENDIF			; SHOPUB

GETABL:	DS	1
LBRFCB:	DS	36
LBBUF:	DS	128

ANAME:	DS	13
ASIZE:	DS	14
ARCFIL:	DS	16

NEWPTR:	DS	2		; Start of second table
XPOINT:	DS	2
JUMPER:	DS	2		; Increment for second table to
WASHERE:
	DS	1
VSFRST:	DS	1
OUTBUF:	DS	128		; Output file buffer
;
; BDOS equates
;
BDOS	EQU	0005H		; Entry Point for BDOS calls
FCB	EQU	005CH		; Default FCB Address
TBUF	EQU	0080H		; Default DMA Address

RDCON	EQU	1		; Console input
WRCON	EQU	2		; Console output
LIST	EQU	5		; List output
PRINT	EQU	9		; Print string
CONST	EQU	11		; Get console status
CPMVER	EQU	12		; Return CP/M version
RESET	EQU	13		; Reset disk system
SELDSK	EQU	14		; Select disk
OPEN	EQU	15		; Open file
CLOSE	EQU	16		; Close file
SRCHF	EQU	17		; Search for first
SRCHN	EQU	18		; Search for next
READ	EQU	20		; Read sequential
WRITE	EQU	21		; Write sequential
MAKE	EQU	22		; Make file
CURDSK	EQU	25		; Return current disk
STDMA	EQU	26		; Set DMA Address
DSKALL	EQU	27		; Get address of allocation vector
DSKPAR	EQU	31		; Get address of disk parameters
STUSER	EQU	32		; Set/get user number

	 IF	ZRDOS
ZRDVER	EQU	48		; Return version (ZRDOS)
SETWBT	EQU	50		; Set warm boot trap (ZRDOS)
RESWBT	EQU	52		; Reset warm boot trap (ZRDOS)
	 ENDIF			; ZRDOS

	DS	60		; Stack area
STACK:	DS	2		; Old stack pointer

ORDER	EQU	$		; Order table starts here

	END
