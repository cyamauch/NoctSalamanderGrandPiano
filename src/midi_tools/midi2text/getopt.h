/*
 * getopt - parse command line options
 *
 * This is a simplified version of the Posix getopt routine, based on the
 * original routine crack in the first implementation of mf2t/t2mf.
 * It is meant to be used on Windows and other systems that don't have getopt.
 * There used to be a getopt implementation in Mats Peterson's version
 * of midi2text, but it looked suspiciously similar to the BSD implementation
 * and it didn't have the BSD license attached, so I decided to rewrite crack
 * to make it compatible with getopt as far as it is used in mf2t and t2mf.
 * The changes are:
 * * calling sequence and return values compatible with getopt.
 * * '--' termination of options and arguments detached from their option letter.
 * * external variables renamed to be the same as in getopt (optind and optarg).
 *
 * The action of getopt is to read a command line in the format:
 *
 * % command [options]... [files]...
 *
 * where the options are of the form -x[argument], that is, a minus, a character
 * and an optional argument. The argument can be either next to the option
 * character or as the next command line argument.
 * The first command line argument not starting with '-', as well as the command
 * line argument '--' is taken as the end of the options and the beginning
 * of file names.
 *
 * Calling: getopt(argc, argv, optstring)
 * where argv is an array of strings (the command line arguments),
 * argc is the length of that array and optstring is the options string,
 * which  looks like this: "a:b:cd" for options a b c and d.
 * In this example, a and b take arguments, as specified by the
 * trailing colon, c and d do not. When getopt scans an option,
 * it returns the option character. If the option has an argument
 * the external character pointer optarg point to the argument. It also
 * sets optind to the index of the argv variable scanned. Getopt returns -1
 * when it has scanned the last option or after '--'. The value of optind
 * then points at the first argument after the last option, which should be
 * the first filename, if any. If there are no arguments, or no more
 * arguments after reading the options, optind == argc;
 *
 * Options may be concatenated, for instance, using the options argument
 * given above: -cd will treat c and d as options.  -cda<argument> also works.
 * 
 * Unknown options will generate an error message and return '?'.
 *
 * NOTE: WHEN MAKING MORE THAN ONE CALL TO getopt() IN A PROGRAM,
 * IT IS NECESSARY TO RESET optind TO 1 FIRST.
 */

#include <stdio.h>
#include <string.h>

int optind = 1;
char *optarg;
char *pvcon = NULL;

int getopt(int argc, char **argv, char *optstring)
{
    char *pv, *flgp;
    while (optind < argc) {
		if (pvcon != NULL)
		    pv = pvcon;
		else {
		    if (optind >= argc) return(-1);
		    pv = argv[optind];
            /* fprintf(stderr, "optind=%d, arg=%s\n", optind, pv); */
		    if (*pv != '-') 
			return(-1);
		}
        if (!strcmp(pv, "--")) { /* '--' = end of options */
            optind++;
            return(-1);
        }
		pv++;		/* skip '-' or prev. option */
		if (*pv != '\0') {
		    if ((flgp=strchr(optstring,(int)*pv)) != NULL) {
				pvcon = pv;
                /* Check if option needs an argument */
				if (*(flgp+1) == ':') {
                    optarg = pv+1;
                    pvcon = NULL;
                    if (*optarg == '\0') { /* no argument connected to option */
                        if (++optind >= argc) { /* no argument given */
                            fprintf(stderr, "option requires an argument -- %c\n", *pv);
                            return('?');
                        }
                        /* else next command line argument is option argument */
                        optarg = argv[optind];
                    }
                    optind++;
                }
                /* end of argument processing */
                return(*pv);
			}
		    else { /* option not in optstring */
			    fprintf(stderr, "illegal option -- %c\n", *pv);
			    pvcon = NULL;
			    return('?');
			}
		}
		pvcon = NULL;
        optind++;
	}
    return(-1);
}

