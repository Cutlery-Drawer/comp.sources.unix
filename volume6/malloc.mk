Subject: v06i057:  Missing makefile for "malloc" posting (malloc.mk)
Newsgroups: mod.sources
Approved: rs@mirror.UUCP

Submitted by: cca!astrovax!wls (William L. Sebok)
Mod.sources: Volume 6, Issue 57
Archive-name: malloc.mk

Unfortunately in my last posting ('A "smarter" malloc') I forgot to include
the Makefile.  I have been cut off from the news for about a week as astrovax
undergoes transformation from a Vax 750 running 4.2 BSD to a Vax 8200 running
Ultrix v1.2.  Because of this I didn't realize it was missing till I started
getting letters about a missing Makefile.  Here it is the Makefile for a Vax.
Changes for other machines should be obvious.

Bill Sebok			Princeton University, Astrophysics
{allegra,akgua,cbosgd,decvax,ihnp4,noao,philabs,princeton,vax135}!astrovax!wls

[  The fault is really mine; I'm supposed to catch things like that...  -r$ ]
-----Cut here----
cat >Makefile <<'!E!O!T!'
LARGS=
CARGS= -O -Ddebug
CURBRK=

all:	malloc.o free.o realloc.o forget.o
	
# for vax users
.c.o:	malloc.h $*.c
	${CC} -S ${CARGS} ${CURBRK} $*.c
	sed -f asm.sed $*.s | as -o $*.o
	ld -x -r $*.o
	mv a.out $*.o

# for non-vax-users
#.c.o:	malloc.h $*.c
#	${CC} -c ${CARGS} ${CURBRK} $*.c
	

tstmalloc:	tstmalloc.o malloc.o free.o realloc.o forget.o
	${CC} ${LARGS} -o tstmalloc tstmalloc.o malloc.o free.o realloc.o \
		forget.o

vgrind:
	vgrind malloc.h malloc.c free.c realloc.c forget.c

shar:
	shar > shar.out README Makefile malloc.3 forget.3 malloc.h malloc.c \
	free.c realloc.c forget.c tstmalloc.c asm.sed malloc.adb

clean:
	rm -f tstmalloc *.[os] shar.out OUT core
!E!O!T!
exit 0
