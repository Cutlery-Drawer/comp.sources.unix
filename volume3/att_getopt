From: talcott!seismo!ut-sally!jsq (John Quarterman)
Subject: public domain AT&T getopt(3)
Newsgroups: mod.sources
Organization: IEEE/P1003 Portable Operating System Environment Committee
Approved: jpn@panda.UUCP

Mod.sources:  Volume 3, Issue 58
Submitted by: seismo!ut-sally!jsq (John Quarterman, Moderator mod.std.unix)

[
  There are two articles here, forwarded from mod.std.unix.  Also, the
  getopt source code is NOT in shar format - you will have to hand
  edit this file.       -   John P. Nelson,  moderator, mod.sources
]

************************

Newsgroups: mod.std.unix
Subject: public domain AT&T getopt source
Date: 3 Nov 85 19:34:15 GMT

Here's something you've all been waiting for:  the AT&T public domain
source for getopt(3).  It is the code which was given out at the 1985
UNIFORUM conference in Dallas.  I obtained it by electronic mail
directly from AT&T.  The people there assure me that it is indeed
in the public domain.

There is no manual page.  That is because the one they gave out at
UNIFORUM was slightly different from the current System V Release 2
manual page.  The difference apparently involved a note about the
famous rules 5 and 6, recommending using white space between an option
and its first argument, and not grouping options that have arguments.
Getopt itself is currently lenient about both of these things White
space is allowed, but not mandatory, and the last option in a group can
have an argument.  That particular version of the man page evidently
has no official existence, and my source at AT&T did not send a copy.
The current SVR2 man page reflects the actual behavor of this getopt.
However, I am not about to post a copy of anything licensed by AT&T.

I will submit this source to Berkeley as a bug fix.

I, personally, make no claims or guarantees of any kind about the
following source.  I did compile it to get some confidence that
it arrived whole, but beyond that you're on your own.


/*LINTLIBRARY*/
#define NULL	0
#define EOF	(-1)
#define ERR(s, c)	if(opterr){\
	extern int strlen(), write();\
	char errbuf[2];\
	errbuf[0] = c; errbuf[1] = '\n';\
	(void) write(2, argv[0], (unsigned)strlen(argv[0]));\
	(void) write(2, s, (unsigned)strlen(s));\
	(void) write(2, errbuf, 2);}

extern int strcmp();
extern char *strchr();

int	opterr = 1;
int	optind = 1;
int	optopt;
char	*optarg;

int
getopt(argc, argv, opts)
int	argc;
char	**argv, *opts;
{
	static int sp = 1;
	register int c;
	register char *cp;

	if(sp == 1)
		if(optind >= argc ||
		   argv[optind][0] != '-' || argv[optind][1] == '\0')
			return(EOF);
		else if(strcmp(argv[optind], "--") == NULL) {
			optind++;
			return(EOF);
		}
	optopt = c = argv[optind][sp];
	if(c == ':' || (cp=strchr(opts, c)) == NULL) {
		ERR(": illegal option -- ", c);
		if(argv[optind][++sp] == '\0') {
			optind++;
			sp = 1;
		}
		return('?');
	}
	if(*++cp == ':') {
		if(argv[optind][sp+1] != '\0')
			optarg = &argv[optind++][sp+1];
		else if(++optind >= argc) {
			ERR(": option requires an argument -- ", c);
			sp = 1;
			return('?');
		} else
			optarg = argv[optind++];
		sp = 1;
	} else {
		if(argv[optind][++sp] == '\0') {
			sp = 1;
			optind++;
		}
		optarg = NULL;
	}
	return(c);
}

************************

Newsgroups: mod.std.unix
Subject: Re: public domain AT&T getopt source
Date: 25 Nov 85 23:13:10 GMT

A couple of days after I posted the getopt source, I finally got
the copy I had ordered from the AT&T toolchest.  They are identical,
except that the one from the toolchest has the following prepended:

1,14d0
< /*
< 
<  *      Copyright (c) 1984, 1985 AT&T
<  *      All Rights Reserved
< 
<  *      THIS IS UNPUBLISHED PROPRIETARY SOURCE 
<  *      CODE OF AT&T.
<  *      The copyright notice above does not 
<  *      evidence any actual or intended
<  *      publication of such source code.
< 
<  */
< #ident	"@(#)getopt.c	1.9"
< /*	3.0 SID #	1.2	*/

AT&T appear to be of two minds about this, since the copy I got
directly by mail from them did not have any such notice, and this is in
fact the same code which *was* published at the Dallas Uniforum, and
made public domain, to boot.  Since the copy I posted was not the
toolchest one, and had no such notice, I guess the notice is irrelevant.

Now to send them a check for $1.80 for the toolchest transmission fee....

