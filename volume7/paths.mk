Reply-To: tron@nsc.UUCP (Ronald S. Karr)
Subject:  v07i087:  Makefile to build UUCP paths
Newsgroups: mod.sources
Approved: mirror!rs

Submitted by: Ronald S. Karr <tron@nsc.NSC.COM>
Mod.sources: Volume 7, Issue 87
Archive-name: paths.mk

The following is a shell archive containing a Makefile and sample data
files for creating a paths file suitable for smail and other UUCP-domain
routing programs.

Also included is the patch to smail that I posted to net.sources.
The patch allows the specification of a site to send any mail
that you can't route.

This package assumes that you have pathalias, makedb (part of the pathalias
distribution) and the compress utilities running on your system.  If you
are not using makedb or the compress utilities, you will need to edit
the Makefile to remove references to these programs.

If you are running uuhosts to unbatch USENET map files, you will need to
modify it to use the Makefile given here to create paths file.  This
makefile will run uuwhere, to create the paths file annotated by location.
If you don't use this or have the uuwhere program somewhere other than
where we have it on our system, you will need to modify the Makefile.

======
  Ronald S. Karr			USENET: hplabs!nsc!tron
  National Semiconductor		ARPA:   decwrl!nsc!tron@ucbvax.ARPA
  Sunnyvale, CA				DOMAIN: tron@nsc.NSC.COM
-------------------------  Cut here ------------------------
#!/bin/sh
# shar:	Shell Archiver
#	Run the following text with /bin/sh to create:
#	Makefile
#	README
#	dead.samp
#	domain.com.samp
#	forces.samp
#	local.map.samp
#	oursite.samp
#	pathmerge.c
#	smail.patch
#	stripdom.c
#	sub.domain.com.samp
# This archive created: Wed Oct 15 01:04:39 1986
echo shar: extracting Makefile '(5119 characters)'
sed 's/^XX//' << \SHAR_EOF > Makefile
XX#!/bin/make -f
XX# MAKEFILE FOR THE PATHALIAS DATABASE
XX#
XX#	@(#)Makefile	1.9	9/25/86
XX#	@(#) Ronald S. Karr <tron@SC.NSC.COM>
XX#	@(#) National Seiconductor, Sunnyvale
XX#
XX# keywords:
XX#	full.paths - make pathalias database with domain and USENET maps.
XX#	domain.paths - make pathalias database with only domain maps.
XX#	local.paths - make the local domain paths.
XX#	extern.paths - make the domain-external paths.
XX#	dead.script - make sed script out of dead file.
XX#	hostmapfile - install our current entry in the USENET maps.
XX#	stripdom - make the stripdom program.
XX#	pathmerge - make the pathmerge program.
XX
XX# HOST INFORMATION
XX#	who we are
XXHOST		= oursite
XX#
XX#	the USENET map file containing our map entry
XX#	For example:  nsc is currently in u.usa.ca.4.
XX#	This can change, so be prepared to make sure it is
XX#	correct every once in a while.
XX#
XX#	If you don't know, leave this blank
XXHOSTMAPFILE	= u.usa.ca.1
XX#
XX#	our own, current, map entry file
XX#	If HOSTMAPFILE is blank, leave HOSTFILE blank as well.
XXHOSTFILE	= oursite.samp
XX#
XX#	define this to be the site we forward mail to that
XX#	we cannot find a path to in our database.
XX#	Set it to nothing if we do not have a more intelligent
XX#	mail forwarding site.
XX#
XX#	The format should be:  forwarding-relay = hostname
XX#	If you hard-coded the mail forwarding site in the smail
XX#	defs.h program, don't worry about this one.
XXFORWARD		= 
XX
XX# DOMAIN INFORMATION
XX#	List here domains that we wish to be able to abbreviate.
XX#	I.e., if you wished to be able to abbreviate the domain
XX#	.subdomain.domain to allow the use of only .subdomain,
XX#	define that here.
XXDOMAINS		= .domain.com .sub.domain.com .far.domain.com
XX#
XX#	Files to include for domain map.
XXDOMAINFILES	= domain.com.samp sub.domain.com.samp
XX
XX# USENET MAP DATABASE
XX#	Make this the directory containing the compressed
XX#	USENET map files.
XXMAPS		= /usr/spool/uumaps
XX
XX# EXTERNAL INFORATION
XX#	Files for generation of external paths
XX#	(not including USENET Map database)
XXEXTERNFILES	= local.map
XX
XX# DESTINATION
XX#	Directory containing the paths file and DBM database.
XXPATHDIR		= /usr/lib/uucp
XX
XX#	PATH variable for the shell
XXPATH		= .:/usr/local:/usr/local/bin:/usr/new:/usr/ucb:/usr/bin:/bin
XX
XXSHELL		= /bin/sh
XX
XX#	If you are including the USENET maps, make this full.paths
XX#	Otherwise, make this domain.paths.
XXall:		full.paths
XX
XX# build paths file given full USENET and local domain information.
XX# The pathmerge seems to make mistakes when given more than two files,
XX# so we only give it two files at a time, here.
XXfull.paths:	.full.paths
XX.full.paths:	stripdom pathmerge extern.paths local.paths forces
XX		sed	-e '/^#/d' \
XX			-e '/^[ 	]*$$/d' \
XX			-e 's/[ 	][ 	]*/	/' \
XX			< forces | sort | \
XX			pathmerge - local.paths | pathmerge - extern.paths | \
XX			stripdom ${DOMAINS} > ${PATHDIR}/.pa.temp
XX		makedb -o ${PATHDIR}/.pa.temp ${PATHDIR}/.pa.temp
XX		mv -f ${PATHDIR}/.pa.temp     ${PATHDIR}/paths
XX		-if test makedb != true; then \
XX			mv -f ${PATHDIR}/.pa.temp.dir ${PATHDIR}/paths.dir;\
XX			mv -f ${PATHDIR}/.pa.temp.pag ${PATHDIR}/paths.pag;\
XX		fi
XX		rm -f .domain.paths
XX		touch .full.paths
XX
XX# build paths file only with domain information.
XXdomain.paths:	.domain.paths
XX.domain.paths:	stripdom pathmerge local.paths forces
XX		sed	-e '/^#/d' \
XX			-e '/^[ 	]*$$/d' \
XX			-e 's/[ 	][ 	]*/	/' \
XX			< forces | sort | \
XX			pathmerge - local.paths | \
XX			stripdom ${DOMAINS} > ${PATHDIR}/.pa.temp
XX		makedb -o ${PATHDIR}/.pa.temp ${PATHDIR}/.pa.temp
XX		mv -f ${PATHDIR}/.pa.temp     ${PATHDIR}/paths
XX		mv -f ${PATHDIR}/.pa.temp.dir ${PATHDIR}/paths.dir
XX		mv -f ${PATHDIR}/.pa.temp.pag ${PATHDIR}/paths.pag
XX		rm -f .full.paths
XX		touch .domain.paths
XX
XX# build a file containing paths for the local domain.
XXlocal.paths:	${DOMAINFILES}
XX		(	echo ${FORWARD}; \
XX			cat ${DOMAINFILES}; \
XX		) | pathalias -l ${HOST} -i 2>> ERRORS | sort > local.paths
XX
XX# build a file containing paths for the USENET.
XX# the uuwhere stuff isn't critical, so ignore any errors from it.
XXextern.paths:	/DONE .hostmapfile ${EXTERNFILES} dead.script
XX		(	echo ${FORWARD}; \
XX			zcat ${MAPS}/u.*.Z; \
XX			cat ${EXTERNFILES}; \
XX		) | pathalias -l ${HOST} -i `cat dead.script` 2>> ERRORS | \
XX			sort > extern.paths
XX		-if test -f ${MAPS}/lib/uuwhere; then ${MAPS}/lib/uuwhere; fi
XX
XX# The file DONE should exist if you use uuhosts -unbatch for news.
XX# but if it doesn't, then this will keep extern.paths happy.
XX/DONE:
XX		-touch /DONE
XX
XX# Remove the comments here to enable the automatic editing of
XX# the map files to include an up-to-date copy of your map entry.
XXhostmapfile:	
XX.hostmapfile:	${MAPS}/${HOSTMAPFILE}.Z ${HOSTFILE}
XX#		-zcat ${MAPS}/${HOSTMAPFILE}.Z > ${MAPS}/.ho.temp
XX#		(	echo   "1;/^#N[ 	]*${HOSTFILE}$$/,//;/^#N/-2d"; \
XX#			echo	".-1r ${HOST}"; \
XX#			echo	"w"; \
XX#			echo	"q"; \
XX#		) | ed - ${MAPS}/.ho.temp
XX#		-compress ${MAPS}/.ho.temp
XX#		-mv -f ${MAPS}/.ho.temp.Z ${MAPS}/${HOSTMAPFILE}.Z
XX		touch .hostmapfile
XX
XX# Create a file which can be cat'ed into the argument list for pathalias.
XXdead.script:	dead
XX		awk '/^[^# 	]/ { print "-d " $$1 }' < dead > dead.script
XX
XXstripdom:	stripdom.c
XX		${CC} ${CFLAGS} -o stripdom stripdom.c
XXpathmerge:	pathmerge.c
XX		${CC} ${CFLAGS} -o pathmerge pathmerge.c
SHAR_EOF
if test 5119 -ne "`wc -c Makefile`"
then
echo shar: error transmitting Makefile '(should have been 5119 characters)'
fi
echo shar: extracting README '(2965 characters)'
sed 's/^XX//' << \SHAR_EOF > README
XX@(#)README	1.3	9/23/86
XX@(#) Ronald S. Karr
XX@(#) National Semiconductor, Sunnyvale
XX
XX	The files in this distribution comprise a set of programs
XX	and sample data files for the generation of a paths file
XX	for use with smail or other mailers that can use the data
XX	generated by pathalias.
XX
XX	To configure the system for your site, write some local
XX	connections maps in some files in this directory, write
XX	a dead, forces and local.map file, using the samples as
XX	guidelines, and edit the Makefile to reflect your current
XX	domain configuration.
XX
XXThe files in this directory:
XX
XXDocumentation
XX
XX README
XX	This file.
XX
XX
XXFiles used for generating local connection paths
XX
XX domain.com.samp
XX	The connection map for the top level of the DOMAIN.COM domain.
XX	A path file is generated for this independently of the
XX	the path file generation for external references.  Then,
XX	the paths in this file are merged into the normal paths
XX	file, overriding any of its paths.
XX
XX sub.domain.com.samp
XX	The connection map for the local subdomain of the domain
XX	DOMAIN.COM.  This is used concurrently with the domain.com
XX	file for path generation.
XX
XX local.paths
XX	The paths computed from pathalias operating upon domain.com
XX	and sub.domain.com.
XX
XX
XXFiles used for generating external connection paths
XX
XX oursite.samp
XX	The external connection map for this host.  This should
XX	only contain information for machines talking to other
XX	machines outside of the DOMAIN.COM domain and should not
XX	contain information on connections within the DOMAIN.COM
XX	domain.
XX
XX local.map.samp
XX	General connection map that contains information which
XX	we know about, but which is not broadcast.  This can also
XX	be used to give lower values to connections, so that
XX	they will be used in preference to other connections.
XX	This file is used concurrently with external maps path
XX	generation.
XX
XX dead.samp
XX	A list of links we consider to be dead, thus overriding
XX	whatever anybody else says.
XX
XX extern.paths.samp
XX	The paths computed from the USENET maps and the above
XX	files.
XX
XX
XXOther files
XX forces.samp
XX	A file of explicit paths to override any paths computed
XX	by Pathalias.
XX Makefile.FORM
XX	A makefile for generating the complete path database
XX	in /usr/lib/uucp/paths{,.dir,.pag}.  Also generates
XX	the intermediate file local.paths and stripdom.
XX stripdom.c
XX	Source for a program that filters pathalias output to
XX	generate multiple lines for each hostname having the
XX	form:
XX
XX		host.xx.domain.com
XX
XX			to make these names equivalent:
XX
XX		host.xx
XX		host.xx.domain
XX		host.xx.domain.com
XX
XX	Alternate domains to simplify can be specified in the
XX	Makefile.
XX pathmerge.c
XX	Source for a program to take multiple sorted path files
XX	as input files and produce on the standard output one path
XX	to all machines listed, with preference given to paths
XX	in the first files referenced in the argument list.
XX
XX	At present, this program does not work correctly when
XX	given more than two input files.  However, pathmerge
XX	can be cascaded as shown in Makefile.
SHAR_EOF
if test 2965 -ne "`wc -c README`"
then
echo shar: error transmitting README '(should have been 2965 characters)'
fi
echo shar: extracting dead.samp '(529 characters)'
sed 's/^XX//' << \SHAR_EOF > dead.samp
XX# SAMPLE DEAD LINKS FILE
XX#
XX#	@(#)dead.samp	1.1	9/8/86
XX#	@(#) Ronald S. Karr <tron@mesa.nsc.com>
XX#	@(#) National Semiconductor, Sunnyvale
XX#
XX#	This file contains links which are known to be dead, should not
XX#	be used (for monetary purposes), or which are not reliable.
XX#	As a result, these will be used only as a last resort when
XX#	pathalias computes the paths it intends to use.
XX
XX#	Paths links we consider unreliable.
XXmachineA!machineB
XXmachineC!machineD
XX
XX#	Paths we would rather not use, for monetary reasons.
XXourmachine!machineE
SHAR_EOF
if test 529 -ne "`wc -c dead.samp`"
then
echo shar: error transmitting dead.samp '(should have been 529 characters)'
fi
echo shar: extracting domain.com.samp '(1139 characters)'
sed 's/^XX//' << \SHAR_EOF > domain.com.samp
XX# SAMPLE CONNECTIVITY OF THE DOMAIN.COM DOMAIN
XX#
XX#	@(#)domain.com.samp	1.2	10/15/86
XX#	@(#) Ronald S. Karr <tron@mesa.nsc.com>
XX#	@(#) National Semiconductor, Sunnyvale
XX#
XX#	This file contains the connectivity maps for the top level
XX#	of the DOMAIN.COM domain.  All gateways to DOMAIN.COM must
XX#	have a current copy of this map.  Also, all other machines within
XX#	DOMAIN.COM must either have a current copy of this map or be
XX#	able to forward to a machine that does.
XX
XX#	Our site.
XXoursite	near-site(DIRECT),
XX	far-site(HOURLY)
XX
XX#	A nearby site in our organization.
XXnear-site
XX	oursite(DIRECT),
XX	other-site(HOURLY)
XX
XX#	A far-away site in our organization.
XXfar-site
XX	oursite(HOURLY)
XX
XX#    Top-level machines in .DOMAIN.COM
XXoursite		.domain.com	# we are a gateway site
XXnear-site	.domain.com	# not a gateway, but top-level anyway
XXfar-site	.domain.com	# far-site is also a gateway
XX
XX#    Aliases
XXoursite		= oursite.domain.com
XXnear-site	= near-site.domain.com
XXfar-site	= far-site.domain.com
XX
XX# SUBNETS OF DOMAIN.COM (with gateways)
XX
XX#	Near subnet (we are gateway)
XXoursite		= .sub.domain.com
XX#	Far subnet (far-site is gateway)
XXfar-site	= .far.domain.com
SHAR_EOF
if test 1139 -ne "`wc -c domain.com.samp`"
then
echo shar: error transmitting domain.com.samp '(should have been 1139 characters)'
fi
echo shar: extracting forces.samp '(773 characters)'
sed 's/^XX//' << \SHAR_EOF > forces.samp
XX# SAMPLE FORCED CONNECTION FILE
XX#
XX#	@(#)forces.samp	1.1	9/8/86
XX#	@(#) Ronald S. Karr <tron@mesa.nsc.com>
XX#	@(#) National Semiconductor, Sunnyvale
XX#
XX#	This file contains a list of literal paths which will be placed
XX#	into the pathalias database in preference to those computed by
XX#	the pathalias program.  The format of each data line is a name
XX#	followed by white space followed by a literal path to the machine,
XX#	including a %s for the user name.
XX#
XX#	The purpose of this file is to insulate you from problems caused
XX#	by inconsistencies between yours and your neighbors' map entries,
XX#	making sure that your lines to important sites do not change.  It
XX#	can also be used just to hard-code particular paths.
XX
XXimportant_site	machineA!important_site!%s
XXneighbor	neighbor!%s
SHAR_EOF
if test 773 -ne "`wc -c forces.samp`"
then
echo shar: error transmitting forces.samp '(should have been 773 characters)'
fi
echo shar: extracting local.map.samp '(535 characters)'
sed 's/^XX//' << \SHAR_EOF > local.map.samp
XX# SAMPLE LOCAL MAP MODIFICATIONS
XX#
XX#	@(#)local.map.samp	1.1	9/8/86
XX#	@(#) Ronald S. Karr <tron@mesa.nsc.com>
XX#	@(#) National Semiconductor, Sunnyvale
XX#
XX#	This file contains pathalias entries which we would prefer to
XX#	which we would like to add to the USENET map files.  It can
XX#	be used to add things that we know should exist or to add
XX#	information about local connectivity that doesn't exist
XX#	elsewhere.
XX
XX# Information that should be in the USENET map database.
XXsun		= sun.com
XXpyramid		= pyramid.com
XX
XXoursite		neighborsite(LOCAL)
SHAR_EOF
if test 535 -ne "`wc -c local.map.samp`"
then
echo shar: error transmitting local.map.samp '(should have been 535 characters)'
fi
echo shar: extracting oursite.samp '(639 characters)'
sed 's/^XX//' << \SHAR_EOF > oursite.samp
XX#N	oursite
XX#S	GENERIC UNIX BOX; 4.3 BSD UNIX
XX#O	The Corporation of Antarctica
XX#
XX#C	Contact Person
XX#E	oursite!postmast, oursite!Contact
XX#T	+1 111 222-3333
XX#
XX#P	1st street / Nowheresville, Antarctica
XX#L	120 0 16 W / 88 23 18 S
XX#
XX#R	Gateway to ourdomain.com
XX#
XX#U	newsfeed downstream
XX#W	Entry Writer <writer@oursite.ourdomain.com>; 	@(#)oursite.samp	1.2	9/25/86
XX# 
XXoursite	ucbvax(WEEKLY*4), ihnp4(HOURLY),
XX	seismo(HOURLY), cbosgd(HOURLY)
XX	mcvax(DIRECT)
XX# You can include a line like this if you are a gateway.
XX# For NSC.COM, `nsc' will broadcast gateway information in its
XX# map entries.  Other gateways need not do so.
XXoursite	.ourdomain.com
SHAR_EOF
if test 639 -ne "`wc -c oursite.samp`"
then
echo shar: error transmitting oursite.samp '(should have been 639 characters)'
fi
echo shar: extracting pathmerge.c '(2813 characters)'
sed 's/^XX//' << \SHAR_EOF > pathmerge.c
XX/*
XX * PATH-FILE MERGING PROGRAM
XX *
XX *	@(#)pathmerge.c	1.2	9/19/86
XX *	@(#) Ronald S. Karr <tron@mesa.nsc.com>
XX *	@(#) National Semiconductor, Sunnyvale
XX *
XX *	This program takes a set of sorted path files, as produced
XX *	by pathalias, and generates on the standard output a merge
XX *	of the path information, with one path given for each
XX *	hostname.  Precedence in preferred paths goes to the files
XX *	given earliest in the argument list.  One of the filenames
XX *	given in the argument list can be `-' for the standard
XX *	input.
XX */
XX#include <stdio.h>
XX
XXextern errno;
XXchar *malloc();
XX
XX#define SMLBUF	512
XX
XXmain(argc,argv)
XX	register int argc;
XX	char *argv[];
XX{
XX	register int i;
XX
XX	/* current input line, per file */
XX	register char **s  = (char **)malloc((argc - 1) * sizeof(char **));
XX	/* true if the per-file line is valid */
XX	register short *p  = (short *)malloc((argc - 1) * sizeof(short *));
XX	/* per-file file descriptors */
XX	register FILE **fd = (FILE **)malloc((argc - 1) * sizeof(FILE **));
XX
XX	register int k;
XX
XX	argv++; argc--;			/* we don't care about the prog name */
XX
XX	if (argc == 0) exit(0);		/* an unusual case */
XX
XX	/* initialize all of the variables */
XX	k = 0;
XX	for (i = 0; i < argc; i++) {
XX		if (strcmp(argv[i], "-") == 0) {
XX			if (k) {
XX				fprintf(stderr, "cannot open the standard input more than once\n");
XX			}
XX			fd[i] = stdin;
XX		} else {
XX			if ((fd[i] = fopen(argv[i], "r")) == NULL) {
XX				perror(argv[i]);
XX				exit(errno);
XX			}
XX		}
XX		s[i] = (char *)malloc(SMLBUF);
XX		p[i] = 0;		/* lines not valid yet */
XX	}
XX
XX	/* take care of special case of one file */
XX	if (argc == 1) {
XX		while ((i = getc(fd[0])) != EOF) putchar(i);
XX		exit(0);
XX	}
XX
XX	/* main operating loop */
XX	for (;;) {
XX
XX		/* for files that need a line, read one in */
XX		k = 0;			/* count how many are at end of file */
XX		for (i = 0; i < argc; i++) {
XX			if (p[i] == 0) {
XX				if (fgets(s[i], SMLBUF, fd[i]) != NULL) p[i]++;
XX				else k++;
XX			}
XX		}
XX		if (k == argc) exit(0);		/* if all files then done */
XX
XX		/* find the alphabetically least line */
XX		k = 0;
XX		for (i = 1; i < argc; i++) {
XX			if (p[k] == 0) k = i;	/* only use valid lines */
XX			if (p[i] == 0) continue;	/* no line yet */
XX			switch (cmp(s[i], s[k])) {
XX
XX			case 0:
XX				/* if two files have the same hostname
XX				 * don't use the second
XX				 */
XX				p[i] = 0;
XX				break;
XX			case -1:
XX				k = i;
XX				break;
XX			}
XX		}
XX		fputs(s[k], stdout);		/* write out that line */
XX		p[k] = 0;			/* read in the next */
XX	}
XX}
XX
XX/* compare two strings up to the first tab character
XX * to determine if the first is less than, equal to,
XX * or greater than the second, returning -1, 0 and 1
XX * respectively.
XX */
XXcmp(s, t)
XX	register char *s, *t;
XX{
XX	while (*s == *t && *s != '\t' && *s != '\0') s++, t++;
XX	if (*s == *t) return (0);
XX	if (*s == '\t') return (-1);
XX	if (*t == '\t') return (1);
XX	return (*s<*t? -1: 1);
XX}
SHAR_EOF
if test 2813 -ne "`wc -c pathmerge.c`"
then
echo shar: error transmitting pathmerge.c '(should have been 2813 characters)'
fi
echo shar: extracting smail.patch '(4182 characters)'
sed 's/^XX//' << \SHAR_EOF > smail.patch
XXHere is a diff of changes from the smail sent out by Mark Horton
XXto the version we are running here at nsc for auto-forwarding
XXcapability (unfortunately, this is only approximate, but it does
XXcontain the most important changes):
XX
XX*** defs.h.old	Oct  3 20:37:48 1986
XX--- defs.h	Oct  3 20:37:48 1986
XX***************
XX*** 56,61
XX  /* # define HOSTDOMAIN "host.dom"	/* replacement for HOSTNAME.MYDOM */
XX  
XX  /*
XX  **  Locations of files:
XX  **	PATHS is where the pathalias output is.  This is mandatory.
XX  **	Define LOG if you want a log of mail.  This can be handy for
XX
XX--- 58,73 -----
XX  /* # define HOSTDOMAIN "host.dom"	/* replacement for HOSTNAME.MYDOM */
XX  
XX  /*
XX+  * FORWARD is set to the site that we wish to send mail that we can't
XX+  * address to.  Does not need to be a direct connection.
XX+  *
XX+  * This hack local to National Semiconductor.
XX+  */
XX+ /* #ifndef FORWARD
XX+  * # define FORWARD    "forwarding-relay"
XX+  * #endif */
XX+ 
XX+ /*
XX  **  Locations of files:
XX  **	PATHS is where the pathalias output is.  This is mandatory.
XX  **	Define LOG if you want a log of mail.  This can be handy for
XX*** resolve.c.old	Fri Oct  3 20:46:45 1986
XX--- resolve.c		Fri Oct  3 20:46:46 1986
XX***************
XX*** 68,74
XX  	char *partv[MAXPATH];		/* "  "      "		*/
XX  	char temp[SMLBUF];		/* "  "      "		*/
XX  	int i;
XX! 		
XX  
XX  /*
XX  **  If we set REROUTE and are prepared to deliver UUCP mail, we split the 
XX
XX--- 68,74 -----
XX  	char *partv[MAXPATH];		/* "  "      "		*/
XX  	char temp[SMLBUF];		/* "  "      "		*/
XX  	int i;
XX! 	int route_done = 0;		/* set if everything routed */
XX  
XX  /*
XX  **  If we set REROUTE and are prepared to deliver UUCP mail, we split the 
XX***************
XX*** 100,106
XX  **  we are set to route ALWAYS or REROUTE) or a ROUTE form.
XX  */
XX  		if ( rsvp( form ) != ROUTE && 
XX! 		    ( rsvp( form ) != UUCP || routing == JUSTDOMAIN ) )
XX  			break;
XX  /*
XX  **  Apply router.  If BULLYing and routing failed, try next larger substring.
XX
XX--- 100,107 -----
XX  **  we are set to route ALWAYS or REROUTE) or a ROUTE form.
XX  */
XX  		if ( rsvp( form ) != ROUTE && 
XX! 		    ( rsvp( form ) != UUCP || routing == JUSTDOMAIN ) ) {
XX! 			route_done++;
XX  			break;
XX  		}
XX  /*
XX***************
XX*** 102,107
XX  		if ( rsvp( form ) != ROUTE && 
XX  		    ( rsvp( form ) != UUCP || routing == JUSTDOMAIN ) )
XX  			break;
XX  /*
XX  **  Apply router.  If BULLYing and routing failed, try next larger substring.
XX  */
XX
XX--- 103,109 -----
XX  		    ( rsvp( form ) != UUCP || routing == JUSTDOMAIN ) ) {
XX  			route_done++;
XX  			break;
XX+ 		}
XX  /*
XX  **  Apply router.  If BULLYing and routing failed, try next larger substring.
XX  */
XX***************
XX*** 112,117
XX  */
XX  		form = parse( temp, domain, user );
XX  	DEBUG("parse route '%s' = %s @ %s (%d)\n",temp,user,domain,form);
XX  		break;
XX  	}
XX  /*
XX
XX--- 114,120 -----
XX  */
XX  		form = parse( temp, domain, user );
XX  	DEBUG("parse route '%s' = %s @ %s (%d)\n",temp,user,domain,form);
XX+ 		route_done++;
XX  		break;
XX  	}
XX  /*
XX***************
XX*** 125,130
XX  		(void) strcpy( domain, "" );
XX  		form = LOCAL;
XX  	}
XX  /*
XX  **  If we were supposed to route and address but failed (form == ERROR), 
XX  **  or after routing once we are left with an address that still needs to
XX
XX--- 128,168 -----
XX  		(void) strcpy( domain, "" );
XX  		form = LOCAL;
XX  	}
XX+ 
XX+ /*
XX+ **  Local NSC hack to forward unrouted messages
XX+ */
XX+ #ifdef FORWARD
XX+ 	if ( !route_done )
XX+ 	{
XX+ 		char forward[SMLBUF];
XX+ 
XX+ 		/* get the path to the forwarding machine */
XX+ 		if ( getpath( FORWARD, forward) == EX_OK ) {
XX+ 			char *p;
XX+ 
XX+ 			/* splice in the address */
XX+ 			sprintf( temp, forward, address );
XX+ 
XX+ 			/* split the address at the first ! */
XX+ 			p = index( temp, '!' );
XX+ 
XX+ 			if ( p ) {
XX+ 				*p = '\0';
XX+ 				(void) strcpy( user, p+1 );
XX+ 				(void) strcpy( domain, temp );
XX+ 				ADVISE( "forward '%s' = %s @ %s (%d)\n",
XX+ 					address, user, domain, UUCP );
XX+ 				return ( UUCP );
XX+ 			}
XX+ 		}
XX+ 		exitstat = EX_NOHOST;
XX+ 		printf( "%s...couldn't forward to %s.\n", address, FORWARD );
XX+ 		form = ERROR;
XX+ 		return( form );
XX+ 	}
XX+ #endif FORWARD
XX+ 
XX  /*
XX  **  If we were supposed to route and address but failed (form == ERROR), 
XX  **  or after routing once we are left with an address that still needs to
XX
SHAR_EOF
if test 4182 -ne "`wc -c smail.patch`"
then
echo shar: error transmitting smail.patch '(should have been 4182 characters)'
fi
echo shar: extracting stripdom.c '(3353 characters)'
sed 's/^XX//' << \SHAR_EOF > stripdom.c
XX/*
XX * LOCAL DOMAIN QUALIFICATION PROGRAM
XX *
XX *	@(#)stripdom.c	1.2	9/19/86
XX *	@(#) Ronald S. Karr <tron@mesa.nsc.com>
XX *	@(#) National Semiconductor, Sunnyvale
XX *
XX *	This program accepts on the standard input a pathalias path
XX *	database and an argument list containing fully qualified
XX *	domains that the current machine is in.  Then on the standard
XX *	output this list is reproduced with any hosts in the given
XX *	fully-qualified domains reproduced on separate lines in less
XX *	qualified domains.  The output is ordered such that a sorted
XX *	file on input will be sorted on output as well.
XX *
XX * USAGE:
XX *	pathalias ... | stripdomain full-domain full-domain ... | ...
XX *
XX * NOTE:
XX *	ordering of full-domains in the argument list is not important
XX *	as the arguments are sorted by size before processing starts.
XX *	Also:  Domains should be given with the initial dot.
XX *
XX * EXAMPLE:
XX *	Given the command "stripdomain .nsc.com .sc.nsc.com" the following
XX *	input:
XX *		a.sc.nsc.com	m!a!%s
XX *		b.b16.sc.nsc.com	n!b!%s
XX *		c.nsc.com	o!c!%s
XX *		d.ta.nsc.com	p!d!%s
XX *		e	q!e!%s
XX *		f.com	r!f!%s
XX *
XX *	produces the following output:
XX *		a.sc	m!a!%s
XX *		a.sc.nsc	m!a!%s
XX *		a.sc.nsc.com	m!a!%s
XX *		b.b16.sc	n!b!%s
XX *		b.b16.sc.nsc	n!b!%s
XX *		b.b16.sc.nsc.com	n!b!%s
XX *		c.nsc	o!c!%s
XX *		c.nsc.com	o!c!%s
XX *		d.ta.nsc	p!d!%s
XX *		d.ta.nsc.com	p!d!%s
XX *		e	q!e!%s
XX *		f.com	r!f!%s
XX */
XX
XX#include <stdio.h>
XX#include <ctype.h>
XX
XX#define SMLBUF	512
XX
XX/* read input strings into here */
XXchar buf[SMLBUF];
XX
XXmain(argc,argv)
XX	int argc;
XX	register char *argv[];
XX{
XX	register char *p, *s;
XX	register i;
XX	static int lencompare();
XX
XX	/* for quick reference, make a table of lengths for the
XX	 * the various arguments.
XX	 */
XX	register int *l = (int *)malloc((--argc) * sizeof(int));
XX
XX	argv++;
XX
XX	/* sort arguments by size (largest to smallest) */
XX	qsort(argv, argc, sizeof(char *), lencompare);
XX	for (i = 0; argv[i] != NULL; i++) {
XX		l[i] = strlen(argv[i]);
XX	}
XX
XX	p = NULL;
XX	s = buf;
XX
XX	/* main processing loop, just get and process characters */
XX	for (;;) switch (*s++ = getchar()) {
XX
XX	/* mark the first white space we see in a line */
XX	case '\t':
XX	case ' ':
XX		if (p == NULL) {
XX			p = s - 1;
XX		}
XX		break;
XX
XX	/* end of line processing */
XX	case '\n':
XX		s[-1] = 0;		/* terminate the line */
XX		s = p;			/* keep track of the mark */
XX		if (p == NULL) break;	/* something is odd, but ignore */
XX
XX		/* look for local domain names before the mark */
XX		for (i = 0; argv[i] != NULL; i++) {
XX			p -= l[i];	/* note potential start of the domain */
XX
XX			/* if it couldn't possibly fit, try the next one */
XX			if (p - buf < 0) {
XX				p += l[i];
XX				continue;
XX			}
XX
XX			/* if it isn't a match, try the next one */
XX			if (strncmp(argv[i], p, l[i]) != 0) {
XX				p += l[i];
XX				continue;
XX			}
XX
XX			/* found a match with a domain name */
XX			for (;;) {
XX
XX				/* look for the NEXT dot */
XX				while (*++p != '.' && !isspace(*p)) ;
XX
XX				/* no more dots in domain */
XX				if (isspace(*p)) break;
XX
XX				/* output before the dot and from the mark */
XX				*p = '\0';
XX				fputs(buf, stdout);
XX				puts(s);
XX				*p = '.';
XX			}
XX			break;
XX		}
XX		p = NULL;
XX		s = buf;
XX		puts(s);		/* output the line as is */
XX		break;
XX
XX	case EOF:
XX		exit(0);		/* all done */
XX	}
XX}
XX
XXstatic int
XXlencompare(a,b)
XX	char **a,**b;
XX{
XX	register la,lb;
XX
XX	la = strlen(*a);
XX	lb = strlen(*b);
XX	if (la == lb) return (0);
XX	if (la < lb) return (1);
XX	else return (-1);
XX}
SHAR_EOF
if test 3353 -ne "`wc -c stripdom.c`"
then
echo shar: error transmitting stripdom.c '(should have been 3353 characters)'
fi
echo shar: extracting sub.domain.com.samp '(823 characters)'
sed 's/^XX//' << \SHAR_EOF > sub.domain.com.samp
XX# SAMPLE CONNECTIVITY OF THE SUB.DOMAIN.COM DOMAIN
XX#
XX#	@(#)sub.domain.com.samp	1.2	10/15/86
XX#	@(#) Ronald S. Karr <tron@mesa.nsc.com>
XX#	@(#) National Semiconductor, Sunnyvale
XX#
XX#	This file contains the connectivity maps for the top level
XX#	of the SUB.DOMAIN.COM domain.  All gateways to SUB.DOMAIN.COM
XX#	must have a current copy of this map.  Also, all other machines
XX#	within DOMAIN.COM must either have a current copy of this map
XX#	or be able to forward to a machine that does.
XX
XX#	Our site
XXoursite	close-site(DIRECT),
XX	this-site(DIRECT),
XX	another-site(LOCAL),
XX	OUR-ETHERNET
XX
XXOUR-ETHERNET	= { a,b,c,d }(DEAD)
XX
XX#    The top level of SUB.DOMAIN.COM
XXoursite		= oursite.sub.domain.com
XXclose-site	= close-site.sub.domain.com
XXthis-site	= this-site.sub.domain.com
XX
XX#    Subnets of SUB.DOMAIN.COM
XXanother-site	.sub.sub.domain.com
SHAR_EOF
if test 823 -ne "`wc -c sub.domain.com.samp`"
then
echo shar: error transmitting sub.domain.com.samp '(should have been 823 characters)'
fi
#	End of shell archive
exit 0

