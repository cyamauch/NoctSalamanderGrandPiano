/*
 * t2mf
 * 
 * Convert text to a MIDI file.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if defined _WIN32 || defined MSDOS
  #include <io.h>
  #include <fcntl.h>
  #include "getopt.h"
#else
  #include <unistd.h>
#endif
#include <errno.h>
#include <ctype.h>
#include <setjmp.h>
#include "t2mf.h"
#include "version.h"


extern int optind;

#ifdef NO_YYLENG_VAR
#define	yyleng yylength
#endif

static jmp_buf erjump;
static int err_cont = 0;

static int TrkNr;
static int Format, Ntrks;
static int Measure, M0, Beat, Clicks;
static long T0;
static char* buffer = 0;
static int bufsiz = 0, buflen;
static int on0_to_off = 0;   /* replace On vol=0 with Off or vv*/

extern int yylex(void);
extern long yyval;
extern int yyleng;
extern int lineno;
extern char *yytext;
extern int do_hex;
extern int eol_seen;
extern FILE  *yyin;

static void mywritetrack();
static void checkchan();
static void checknote();
static void checkval();
static void splitval();
static void get16val();
static void checkcon();
static void checkprog();
static void checkeol();
static void gethex();

void error(const char *s)
{
    fprintf(stderr, "Error: %s\n", s);
}

static void parse_error(char *s)
{
    int c;
    int count;
    int ln = (eol_seen? lineno-1 : lineno);
    fprintf(stderr, "%d: %s\n", ln, s);
    if (yyleng > 0 && *yytext != '\n')
        fprintf(stderr, "*** %*s ***\n", yyleng, yytext);
    count = 0;
    /* skip rest of line */
    while (count < 100 && (c = yylex()) != EOL && c != EOF) count++;
    if (c == EOF) exit(1);
    if (err_cont)
        longjmp(erjump, 1);
}

static void syntax(char* mess)
{
    /* 100 is enough for all our uses; no risk of buffer overflow */
    char buffer[100];
    (void)strcpy(buffer, "Syntax error - ");
    (void)strcat(buffer, mess);
    (void)strcat(buffer, " expected");
    parse_error(buffer);
}

static int getint(char *mess)
{
    char ermesg[100];
    if (yylex() != INT) {
        sprintf(ermesg, "Integer expected for %s", mess);
        error(ermesg);
        yyval = 0;
    }
    return yyval;
}

static int getbyte(char *mess)
{
    char ermesg[100];
    getint(mess);
    if (yyval < 0 || yyval > 127) {
        sprintf(ermesg, "Wrong value (%ld) for %s", yyval, mess);
        error(ermesg);
        yyval = 0;
    }
    return yyval;
}

static void translate(void)
{
    int c;

    /* Skip byte order mark */
    if ((c = getchar()) == 0xef) {
        if (getchar() != 0xbb || getchar() != 0xbf) {
            error("Unknown byte order mark");
            exit(1);
        }
    } else
        ungetc(c, stdin);

    if (yylex()==MTHD) {
        Format = getint("MFile format");
        Ntrks = getint("MFile #tracks");
        Clicks = getint("MFile Clicks");
        if (Clicks < 0)
            Clicks = (Clicks&0xff)<<8|getint("MFile SMPTE division");
        checkeol();
        mfwrite(Format, Ntrks, Clicks, stdout);
    } else {
        fprintf(stderr, "Missing MFile – can’t continue\n");
        exit(1);
    }
}

static char data[5];
static int chan;

static void checkchan(void)
{
    if (yylex() != CH || yylex() != INT) syntax("ch=");
    if (yyval < 1 || yyval > 16)
        error("Chan must be between 1 and 16");
    chan = yyval-1;
}

static void checknote(void)
{
    int c = 0;
    
    if (yylex() != NOTE || ((c=yylex()) != INT && c != NOTEVAL))
        syntax("n= or note= <note>");
    if (c == NOTEVAL) {
        static int notes[] = {
            9,   /* a */
            11,  /* b */
            0,   /* c */
            2,   /* d */
            4,   /* e */
            5,   /* f */
            7    /* g */
        };
        char *p = yytext;
        c = *p++;
        if (isupper(c)) c = tolower(c);
        yyval = notes[c-'a'];
        switch (*p) {
            case '#':
            case '+':
                yyval++;
                p++;
                break;
            case 'b':
            case 'B':
            case '-':
                yyval--;
                p++;
                break;
        }	
        yyval += 12 * atoi(p);
    }
    if (yyval < 0 || yyval > 127)
        error("Note must be between 0 and 127");
    data[0] = yyval;
}

static void checkval(void)
{
    if (yylex() != VAL || yylex() != INT) syntax("v= or vol= or val= <int>");
    if (yyval < 0 || yyval > 127)
        error("Value must be between 0 and 127");
    data[1] = yyval;
}

static void splitval(void)
{
    if (yylex() != VAL || yylex() != INT) syntax("v= or vol= or val= <int>");
    if (yyval < 0 || yyval > 16383)
        error("Value must be between 0 and 16383");
    data[0] = yyval%128;
    data[1] = yyval/128;
}

static void get16val(void)
{
    if (yylex() != INT) syntax("<int>");
    if (yyval < 0 || yyval > 65535)
        error("Value must be between 0 and 65535");
    data[0] = (yyval>>8)&0xff;
    data[1] = yyval&0xff;
}

static void checkcon(void)
{
    if (yylex() != CON || yylex() != INT)
        syntax("c= or con= <int>");
    if (yyval < 0 || yyval > 127)
        error("Controller must be between 0 and 127");
    data[0] = yyval;
}

static void checkprog(void)
{
    if (yylex() != PROG || yylex() != INT) syntax("p= or prog= <int>");
    if (yyval < 0 || yyval > 127)
        error("Program number must be between 0 and 127");
    data[0] = yyval;
}

static void checkeol(void)
{
    if (eol_seen) return;
    if (yylex() != EOL) {
    	parse_error("Garbage deleted");
        while (! eol_seen) yylex();	 /* skip rest of line */
    }
}

static void gethex(void)
{
    int c;
    buflen = 0;
    do_hex = 1;
    c = yylex();
    if (c == STRING) {
        /* Note: yytext includes the trailing, but not the starting quote */
        int i = 0;
    	if (yyleng-1 > bufsiz) {
            bufsiz = yyleng-1;
            if (buffer)
                buffer = realloc(buffer, bufsiz);
            else
                buffer = malloc(bufsiz);
            if (! buffer) error("Out of memory");
        }
        while (i < yyleng-1) {
            c = yytext[i++];
rescan:
            if (c == '\\') {
                switch (c = yytext[i++]) {
                    case '0':
                        c = '\0';
                        break;
                    case 'n':
                        c = '\n';
                        break;
                    case 'r':
                        c = '\r';
                        break;
                    case 't':
                        c = '\t';
                        break;
                    case 'x':
                        if (sscanf(yytext+i, "%2x", &c) != 1)
                            parse_error("Illegal \\x in string");
                        i += 2;
                        break;
                    case '\r':
                    case '\n':
                        while ((c=yytext[i++]) == ' ' || c == '\t' ||
                                c == '\r' || c == '\n')
                            /* skip whitespace */;
                        goto rescan; /* sorry EWD :=) */
                }
            }
            buffer[buflen++] = c;
        }	    
    } else if (c == INT) {
        do {
    	    if (buflen >= bufsiz) {
                bufsiz += 128;
                if (buffer)
                    buffer = realloc(buffer, bufsiz);
                else
                    buffer = malloc(bufsiz);
                if (! buffer) error("Out of memory");
            }
/* This test not applicable for sysex
            if (yyval < 0 || yyval > 127)
                error("Illegal hex value"); */
            buffer[buflen++] = yyval;
            c = yylex();
        } while (c == INT);
        if (c != EOL) parse_error("Unknown hex input");
    }
    else parse_error("String or hex input expected");
}

long bankno(char *s, int n)
{
    long res = 0;
    int c;
    while (n-- > 0) {
        c = (*s++);
        if (islower(c))
            c -= 'a';
        else if (isupper(c))
            c -= 'A';
        else
            c -= '1';
        res = res * 8 + c;
    }
    return res;
}

static void mywritetrack(void)
{
    int opcode, c;
    long currtime = 0;
    long newtime, delta;
    int i, k;
 
    while ((opcode = yylex()) == EOL);
    if (opcode != MTRK)
        parse_error("Missing MTrk");
    checkeol();
    while (1) {
        err_cont = 1;
        setjmp(erjump);
        switch (yylex()) {
            case MTRK:
                parse_error("Unexpected MTrk");
                return;			/* PLB */
            case EOF:
                err_cont = 0;
                error("Unexpected EOF");
                return;
            case TRKEND:
                err_cont = 0;
                checkeol();
                return;
            case INT:
                newtime = yyval;
                if ((opcode=yylex())=='/') {
                    if (yylex() != INT)
                        parse_error("Illegal time value");
                    newtime = (newtime-M0)*Measure+yyval;
                    if (yylex() != '/' || yylex() != INT)
                        parse_error("Illegal time value");
                    newtime = T0 + newtime*Beat + yyval;
                    opcode = yylex();
                }
                delta = newtime - currtime;
                switch (opcode) {
                    case ON:
                    case OFF:
                    case POPR:
                        checkchan();
                        checknote();
                        checkval();
                        if (opcode == ON && on0_to_off > 0 && data[1] == 0) {
                            /* replace ON with vol=0 by OFF */
                            opcode = OFF;
                        } else if (opcode == OFF && on0_to_off < 0) {
                            /* replace OFF by ON with vol=0 */
                            opcode = ON;
                            data[1] = 0;
                        }
                        mf_w_midi_event(delta, opcode, chan,
                                (unsigned char *)data, 2L);
                        break;

                    case PAR:
                        checkchan();
                        checkcon();
                        checkval();
                        mf_w_midi_event(delta, opcode, chan,
                                (unsigned char *)data, 2L);
                        break;
		
                    case PB:
                        checkchan();
                        splitval();
                        mf_w_midi_event(delta, opcode, chan,
                                (unsigned char *)data, 2L);
                        break;

                    case PRCH:
                        checkchan();
                        checkprog();
                        mf_w_midi_event(delta, opcode, chan,
                                (unsigned char *)data, 1L);
                        break;
 
                    case CHPR:
                        checkchan();
                        checkval();
                        data[0] = data[1];
                        mf_w_midi_event(delta, opcode, chan,
                                (unsigned char *)data, 1L);
                        break;
 
                    case SYSEX:
                    case ARB:
                        gethex();
                        mf_w_sysex_event(delta, (unsigned char *)buffer,
                                (long)buflen);
                        break;

                    case TEMPO:
                        if (yylex() != INT) syntax("<int>");
                        mf_w_tempo(delta, yyval);
                        break;

                    case TIMESIG: {
                        int nn, denom, cc, bb;
                        if (yylex() != INT || yylex() != '/') syntax("<int>/<int>");
                        nn = yyval;
                        denom = getbyte("Denom");
                        cc = getbyte("clocks per click");
                        bb = getbyte("32nd notes per 24 clocks");
                        for (i = 0, k = 1 ; k < denom; i++, k <<= 1);
                        if (k != denom) error ("Illegal TimeSig");
                        data[0] = nn;
                        data[1] = i;
                        data[2] = cc;
                        data[3] = bb;
                        M0 += (newtime-T0)/(Beat*Measure);
                        T0 = newtime;
                        Measure = nn;
                        Beat = 4 * Clicks / denom;
                        mf_w_meta_event(delta, time_signature,
                                (unsigned char *)data, 4L);
                        break;
                    }

                    case SMPTE:
                        for (i=0; i<5; i++)
                            data[i] = getbyte("SMPTE");
                        mf_w_meta_event(delta, smpte_offset,
                                (unsigned char *)data, 5L);
                        break;

                    case KEYSIG:
                        data[0] = i = getint ("Keysig");
                        if (i < -7 || i > 7)
                            error ("Key Sig must be between -7 and 7");
                        if ((c=yylex()) != MINOR && c != MAJOR)
                            syntax("minor or major");
                        data[1] = (c == MINOR);
                        mf_w_meta_event(delta, key_signature,
                                (unsigned char *)data, 2L);
                        break;

                    case SEQNR:
                        get16val ();
                        mf_w_meta_event(delta, sequence_number,
                                (unsigned char *)data, 2L);
                        break;

                    case META: {
                        int type = yylex();
                        switch (type) {
                            case TRKEND:
                                type = end_of_track;
                                break;
                            case TEXT:
                            case COPYRIGHT:
                            case SEQNAME:
                            case INSTRNAME:
                            case LYRIC:
                            case MARKER:
                            case CUE:
                                type -= (META+1);
                                break;
                            case INT:
                                type = yyval;
                                break;
                            default:
                                parse_error("Illegal Meta type");
                        }
                        if (type == end_of_track)
                            buflen = 0;
                        else
                            gethex();
                        mf_w_meta_event(delta, type,
                                (unsigned char *)buffer, (long)buflen);
                        break;
                    }

                    case SEQSPEC:
                        gethex();
                        mf_w_meta_event(delta, sequencer_specific,
                                (unsigned char *)buffer, (long)buflen);
                        break;

                    default:
                        parse_error("Unknown input");
                        break;
                }
                currtime = newtime;
            case EOL:
                break;
            default:
                parse_error("Unknown input");
                break;
        }
        checkeol();
    }
}

static void initfuncs(void)
{
    Mf_putc = putchar;
    Mf_wtrack = mywritetrack;
}

static void usage(void)
{
    fprintf(stderr,
"t2mf v%s\n"
"Usage: t2mf [-r] [-on|-off] [textfile [midifile]]\n\n"
"Options:\n"
"  -on     replace Note On with vol=0 by Note Off\n"
"  -off    replace Note Off by Note On with vol=0\n"
"  -r      use running status\n", VERSION);
    exit(1);
}

int main(int argc, char **argv)
{
    int c;

    while ((c = getopt(argc, argv, "rho:")) != -1) {
        switch (c) {
            case 'r':
                Mf_RunStat = 1;
                break;
            case 'o':
                if (*optarg == 'n')
                    on0_to_off = 1;
                else if (*optarg == 'f')
                    on0_to_off = -1;
                else {
                    fprintf(stderr, "illegal option -o%s\n", optarg);
                }
                break;
            case 'h':
            case '?':
            default:
                usage();
        }
    }

    /* Filename "-" indicates stdin */
    if (optind < argc && strcmp(argv[optind++], "-") != 0
                      && !freopen(argv[optind - 1], "r", stdin)) {
        perror(argv[optind - 1]);
        exit(1);
    }
    yyin = stdin;

    /* Filename "-" indicates stdout */
    if (optind < argc && strcmp(argv[optind], "-") != 0
                      && !freopen(argv[optind], "w", stdout)) {
        perror(argv[optind]);
        exit(1);
    }
#if defined _WIN32 || defined MSDOS
	setmode(fileno(stdout),O_BINARY);
#endif

    initfuncs();
    TrkNr = 0;
    Measure = 4;
    Beat = 96;
    Clicks = 96;
    M0 = 0;
    T0 = 0;
    translate();

    return 0;
}
