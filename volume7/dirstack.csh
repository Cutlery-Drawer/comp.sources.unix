Subject:  v07i095:  CSH tools for directory stacks
Newsgroups: mod.sources
Approved: mirror!rs

Submitted by: pyrbos!gsg!lew (Paul Lew)
Mod.sources: Volume 7, Issue 95
Archive-name: dirstack.csh

This is a set of tool to manipulate Csh directory stacks.  It helps
bad typists a lot and also benefits people who deal with a lot of
directories.  I rarely type full pathnames after I started using it.

To try it out, type: source shdir.make, this will define some alias
for you to use.  Type 's' and see what happens.

To install it, type:     shdir.make.
Man page is in:          shdir.man.

comments to: decvax!gsg!lew
------------------------------Cut Here---------------------------------
#! /bin/sh
# This is a shell archive, meaning:
# 1. Remove everything above the #! /bin/sh line.
# 2. Save the resulting text in a file.
# 3. Execute the file with /bin/sh (not csh) to create the files:
#	shdir.make
#	shdir.man
#	restdir
#	lsdir
#	useshdir
#	shdir.c
export PATH; PATH=/bin:$PATH
echo shar: extracting "'shdir.make'" '(6310 characters)'
if test -f 'shdir.make'
then
	echo shar: will not over-write existing file "'shdir.make'"
else
sed 's/^X//' << \SHAR_EOF > 'shdir.make'
X#! /bin/csh -f
X#
X#-	shdir.make - Directory stack installation script
X#-
X#-	To try out the function of shdir, use csh  "source" command to
X#-	invoke this program since some aliases will need to be defined
X#-	in your current environment.
X#-
X#-	Change the mode to execute and  then execute it  will cause it
X#-	to be installed.
X#-
X#	Author:		Paul Lew, General Systems Group, Salem, NH
X#	Last update:	10/14/86  02:26 PM
X#
X#if ( "${user}" == "lew" ) goto end
X#---------------------------------------------------------------#
X#	If invoked from csh "source" command, install locally	#
X#	else install globally and update .login, .cshrc, and	#
X#	.logout file.						#
X#---------------------------------------------------------------#
Xif ( $?0 ) goto install
X#---------------------------------------------------------------#
X#		   Compile shdir.c first			#
X#---------------------------------------------------------------#
Xif ( ! -e "shdir" ) then
X	if ( ! -e shdir.c ) then
X		echo "...File shdir.c missing, aborted..."
X		goto end
X		endif
X	echo -n "...Compiling shdir.c "
X	cc -s -o shdir shdir.c -ltermcap
X	echo "done..."
X	endif
X#---------------------------------------------------------------#
X#	Make sure all the required files are there		#
X#---------------------------------------------------------------#
Xforeach fname (restdir lsdir shdir useshdir)
X	if ( ! -e ${fname} ) then
X		echo "...${fname} not in directory ${cwd}, aborted..."
X		goto end
X		endif
X	end
X#---------------------------------------------------------------#
X#	    Define aliases in the current shell			#
X#---------------------------------------------------------------#
Xforeach aname (lsdir po s to)
X	@ achar = `alias ${aname} | wc -c`
X	if ( ${achar} > 0 ) echo "...alias ${aname} will be redefined..."
X	end
Xunset aname achar
Xalias	lsdir	source ${cwd}/lsdir
Xalias	po	'popd +\!* > /dev/null; shdir `dirs`'
Xalias	s	${cwd}'/shdir -s\!* `dirs` ;if ( ${status} ) pushd +${status} > /dev/null'
Xalias	to	'pushd \!* > /dev/null ; '"${cwd}"'/shdir `dirs`'
X#---------------------------------------------------------------#
X#	  Make a set of directory stack to demo			#
X#---------------------------------------------------------------#
Xset dirs = (`dirs`)
Xif ( ${#dirs} < 3 ) then
X	cd /usr/lib/uucp
X	foreach x (/usr/spool/uucp /usr/spool/uucppublic /etc ${cwd})
X		pushd $x > /dev/null
X		end
X	unset x
X	endif
X#---------------------------------------------------------------#
X#	Modify TERMCAP so he/she will see the result		#
X#---------------------------------------------------------------#
Xswitch ( "${TERM}" )
X	case vt100:
X	case vt102:
X	case vt125:
X	case vt220:
X	case vt240:
X	case wy75:
X	    set noglob
X	    eval `tset -Q -s`
X	    unset noglob
X	    set tc = ('jjkkllmmqqxx' '\E(B' '\E(0')
X	    foreach te (ac ae as)
X		echo "${TERMCAP}" | fgrep -s ":${te}"
X		if ( ${status} == 1 ) then
X			echo "...${te} added to TERMCAP..."
X			setenv TERMCAP "${TERMCAP}${te}=${tc[1]}:"
X			endif
X		shift tc
X		end
X	    breaksw
X	default:
X	endsw
X#---------------------------------------------------------------#
X#		     Give a little hint				#
X#---------------------------------------------------------------#
Xcat << cat_eof
X...Now type 's' and move to the directory you want by pressing space bar....
Xcat_eof
Xgoto end
X
X#---------------------------------------------------------------#
X#		Final installation starts here			#
X#---------------------------------------------------------------#
Xinstall:
Xcat << cat_eof
X       **************** GENERAL INFORMATION ****************
X
XThis is the final installation procedure.  It will move all the
Xexecutables to proper directory and also modify your .login, and
X.logout file so that directory stack will preserve across logins.
XYour .cshrc will also be modified to define aliases.
X
XThe defualt place to store the executables is: /usr/local/bin so that
Xit can be shared among users.  Press return on to the question below
Xif you like to use the default.
X
Xcat_eof
Xecho -n "Where do you want to place executables in your system? "
Xset dir = "$<"
Xif ( "${dir}" == "" ) set dir = '/usr/local/bin'
Xif ( ! -d "${dir}" ) then
X	mkdir "${dir}"
X	if ( ! -d "${dir}" ) then
X		echo "...${dir} is not a valid directory, aborted..."
X		goto end
X		endif
X	endif
X#---------------------------------------------------------------#
X#	 Check if dir specified is in the search path		#
X#---------------------------------------------------------------#
Xunset inpath
Xforeach cpath (${path})
X	if ( "${cpath}" == "${dir}" ) then
X		set inpath
X		break
X		endif
X	end
Xif ( ! ${?inpath} ) then
X	echo "...Warning: ${dir} not defined in your search path..."
X	endif
Xunset inpath cpath
X#---------------------------------------------------------------#
X#	  Move script to the executables directory		#
X#---------------------------------------------------------------#
Xforeach fname (restdir lsdir shdir useshdir)
X	if ( -e "${dir}/${fname}" ) then
X		echo "...${dir}/${fname} already exist..."
X		continue
X		endif
X	if ( ! -e ${fname} ) then
X		echo "...${fname} not in directory ${cwd}, aborted..."
X		goto end
X		endif
X	if ( ${cwd} == "${dir}" ) continue
X	if ( -e "${dir}/${fname}" ) then
X		echo "...${dir}/${fname} already exist..."
X	else
X		/bin/mv ${fname} "${dir}"
X		endif
X	end
Xsed -e "s:source /usr/local/bin:source ${dir}:" < ${dir}/lsdir > /tmp/lsdir$$
X/bin/mv -f /tmp/lsdir$$ ${dir}/lsdir
X/bin/chmod a+rx "${dir}/useshdir"
X/bin/chmod a+r-x "${dir}"/{restdir,lsdir}
X#---------------------------------------------------------------#
X#      Modify .cshrc, .logout to install for my account		#
X#---------------------------------------------------------------#
X${dir}/useshdir ${dir}
Xcat << cat_eof
X--------------------------------------------------------------------
XIf anyone else in your system would like to use shdir, he/she only
Xneed to execute script: useshdir.
X
XIf you like to have VT100 graphic characters to draw the box, add the
Xfollowing to your termcap entry after you verify it does support these
Xfeatures:
X
X	:ac=jjkkllmmqqxx:	#alternate graphic characters
X	:as=\E(0:		#alternate set start
X	:ae=\E(B:		#alternate set end
X
X   ******** The installation is now complete, have fun!! ********
Xcat_eof
X#---------------------------------------------------------------#
X#			  Exit here				#
X#---------------------------------------------------------------#
Xunset added msg
Xend:
SHAR_EOF
if test 6310 -ne "`wc -c < 'shdir.make'`"
then
	echo shar: error transmitting "'shdir.make'" '(should have been 6310 characters)'
fi
chmod +x 'shdir.make'
fi # end of overwriting check
echo shar: extracting "'shdir.man'" '(4868 characters)'
if test -f 'shdir.man'
then
	echo shar: will not over-write existing file "'shdir.man'"
else
sed 's/^X//' << \SHAR_EOF > 'shdir.man'
X.TH shdir 1-gsg "14 Oct 1986"
X.SH NAME
Xshdir, lsdir - C shell directory manipulation package
X.SH SYNOPSIS
XMost of the followings are C-shell aliases:
X.IP "s                  switch directory"
X.IP "to [dir]           push to a new directory"
X.IP "po [n]             pop out an old directory"
X.IP "lsdir [filename]   load/save directory stack"
X.SH DESCRIPTION
X.I Shdir
Xis actually a set of C program, shell scripts and aliases which
Xwill assist you to use BSD directory stack feature easily.
X.PP
XThe main program "shdir" is a C program which take C-shell dirs output
Xand display it graphically on the output with VT100 graphic chars.  It
Xalso allow you to move the cursor to the desired directory and change
Xto it with one keystroke.  The following is a list of commands to
Xshdir:
X.sp
X.DS 
X    space, j, J, l, L       move cursor down one line
X    backspace, k, K, h, H   move cursor up one line
X    n, p                    search for next/previous string
X    0-9                     go to the next 0-9
X    return                  select the entry
X.sp
X    Options to shdir:
X.sp
X    -s     or               select mode
X    -sxxx                   search string xxx in dir stack
X    -r                      use scroll if possible
X    -bx                     set box style to x (see below)
X    -v                      display version number
X.DE
X.PP
XOption '-s' tells shdir to enter select mode, i.e., displays directory
Xstack on the tube and allows user to select an entry.  If any argument
Xis supplied after the -s option to shdir,  it will be used as the
Xstring to search thru the directory stack.  If exactly one entry
Xmatches, shdir will echo that directory name and exit without
Xdisplaying the directory stack.  If more than one entry found, the
Xstack will be displayed on the tube with the cursor at the first entry
Xcontaining the string, type 'n' or 'p' will find the next/previous
Xmatch entry.
X.PP
XAn option '-r' to shdir will make the stack rotate on the tube, this
Xway you will not have to imagine what the stack looks like after it
Xrotates.  However, this feature can not be done by termcap
Xdescription, and currently only works for VT100 type of terminals.
X.PP
XShdir also allows you to choose your own box style by supplying -b
Xoption.  If the char after 'b' is 'h', shdir will try to use highlite
Xblanks for the box. If it is 'r', shdir will use reverse-video blanks
Xfor the box.  If it is 'g', shdir will use graphical chars for the
Xbox.  The default style sequence is (1) graphic chars, (2) highlite
Xblanks, (3) reverse video blanks, and (4) regular dashes.  If the
Xstyle you selected does not exist for your terminal in the termcap
Xdatabase, the next one in the style list will be used.
X.PP
XLsdir is a script which allow you to switch the entire directory stack
Xto a new environment.  For example, you may work on two projects, one
Xproject uses 8 directories and the other projects uses 5 different
Xdirectories.
X.PP
X.I s,
X.I to,
Xand
X.I po
Xare actually aliases, it means Switch to a new directory, push TO a new
Xdirectory, and POp up a given entry on the stack.
XYou may want to change them to whatever you like.
XThe definition looks like:
X.sp
X.DS
X    alias lsdir 'source ${dir}/lsdir'
X    alias po    'popd +\\!* > /dev/null; shdir \`dirs\`'
X    alias s     'shdir -s\\!* \`dirs\` ; \\
X                if (${status}) pushd +${status}>/dev/null'
X    alias to    'pushd \\!* > /dev/null ; shdir \`dirs\`'
X.DE
X.PP
XScript useshdir will modify your (1) .login to restore previously
Xsaved directory stack, so the environment can be preserved. (2) .cshrc
Xto define aliases (lsdir, po, s, to), so shdir can be invoke. (3) .logout
Xto save directory stack to a file.
X.PP
X.SH FILES
X.br
X/usr/local/bin/restdir, /usr/local/bin/lsdir, /usr/local/bin/useshdir
X.SH AUTHOR
XPaul Lew
X.br
XGeneral Systems Group, Salem NH
X.SH BUGS
XThis version uses termcap "ac" feature to draw graphic box. It may not
Xexist in your /etc/termcap file.
X.PP
XThere is output flushing problem when run shdir over Enet, sometimes
Xthe output did not seem to get flushed before switching to RAW mode.
XCurrent resolution is to add a one second delay if stdout is a
Xpseudo-terminal. Better solution should be investigated.
X.PP
XIf you select scrolling option (-r), shdir will poll the terminal for
Xits cursor position in order to decide the proper scrolling region.
XIt ASSUMED the return device cursor status report (DSR) to be string
Xlike: "ESC [ line; column R", this will only works for VT100 type
Xterminals.
X.PP
XThis program will not work if you have a directory name contains space(s).
XThis is because the output of dirs command uses spaces to separate
Xdirectory names.
X.PP
XShdir uses tabs to fill the end of line, this may cause little problem
Xon your terminal it terminal tab stops is not 8.
X.PP
XFor hackers: How about add features to termcap/terminfo so that all
Xthe  (DSR) operations can be done?
SHAR_EOF
if test 4868 -ne "`wc -c < 'shdir.man'`"
then
	echo shar: error transmitting "'shdir.man'" '(should have been 4868 characters)'
fi
fi # end of overwriting check
echo shar: extracting "'restdir'" '(649 characters)'
if test -f 'restdir'
then
	echo shar: will not over-write existing file "'restdir'"
else
sed 's/^X//' << \SHAR_EOF > 'restdir'
X#! /bin/csh -f
X#
X#	Shell script to restore directory stack (this file should be sourced)
X#
X#	Author:		Paul Lew, General Systems Group, Inc.
X#	Created at:	01/03/86
X#	Last update:	10/08/86  05:07 PM
X#
Xif ( $?0 ) then
X	echo "...You should source this program, not execute it..."
X	goto end
X	endif
Xif ( ! ${?SAVED_WD} ) setenv SAVED_WD ~/saved_wd
Xif ( ! ${?filename} ) set filename = ${SAVED_WD}/cwd.wd
Xset _dirlist = `cat ${filename}`
Xset _dirs
Xforeach _dir (${_dirlist})			#reverse directory stack
X	set _dirs = (${_dir} ${_dirs})
X	end
Xchdir ${_dirs[1]}
Xshift _dirs
Xforeach _dir (${_dirs})
X	pushd ${_dir} > /dev/null
X	end
Xunset _dirlist _dir _dirs
Xend:
SHAR_EOF
if test 649 -ne "`wc -c < 'restdir'`"
then
	echo shar: error transmitting "'restdir'" '(should have been 649 characters)'
fi
fi # end of overwriting check
echo shar: extracting "'lsdir'" '(2340 characters)'
if test -f 'lsdir'
then
	echo shar: will not over-write existing file "'lsdir'"
else
sed 's/^X//' << \SHAR_EOF > 'lsdir'
X#! /bin/csh -f
X#
X#	Shell script to load/save current directory stack from/to a file
X#
X#	Author:		Paul Lew
X#	Created at:	02/28/86  12:43
X#	Last update:	10/08/86  04:48 PM
X#
X#	Usage:	source lsdir <CR>	-- must be sourced
X#
Xif ( $?0 ) then
X	echo "...You should source this program, not execute it..."
X	goto end
X	endif
X#---------------------------------------------------------------#
X#		     Variable Declarations			#
X#---------------------------------------------------------------#
Xif ( ! ${?SAVED_WD} ) setenv SAVED_WD ~/saved_wd
Xunset load_dirs
Xset fname = ""
Xecho -n "Enter S/L/D for save/load/directory: "
Xswitch ( "$<" )
X	case [lL]:
X		set load_dirs
X		set opt = 'load'
X		breaksw
X	case [sS]:
X		set opt = 'save'
X		breaksw
X	case [dD]:
X		ls -l ${SAVED_WD}/*.wd | less
X		while ( 1 )
X			echo -n "File to see (no extension): "
X			set fname = "$<"
X			if ( ${fname} == "" ) goto end
X			cat ${SAVED_WD}/${fname}.wd | shdir
X			end
X	default:
X		goto end
X	endsw
X#---------------------------------------------------------------#
X#	Get filename from terminal and make sure it exists	#
X#---------------------------------------------------------------#
Xwhile ( "${fname}" == "" )
X	echo -n "File to ${opt}: "
X	set fname = "$<"
X	if ( "${fname}" == "" ) continue
X	if ( "${fname:t}" != "${fname}" ) then
X		echo -n "No path allowed, "
X		set fname = ''
X		endif
X	set filename = "${SAVED_WD}/${fname}.wd"
X	if ( ${?load_dirs} ) then
X		if ( ! -e "${filename}" ) then
X			echo -n "File [${filename}] does not exist, "
X			set fname = ''
X			endif
X		endif
X	end
X#---------------------------------------------------------------#
X#			Process request				#
X#---------------------------------------------------------------#
Xif ( ${?load_dirs} ) then
X	set curdir = `dirs`
X	echo "Old directory stack looks like:"
X	shdir ${curdir}
X	@ dir_count = ${#curdir} - 1
X	repeat ${dir_count} popd > /dev/null
X	source /usr/local/bin/restdir
X	echo "New directory stack looks like:"
X	shdir `dirs`
Xelse
X	if ( -e ${filename} ) then
X		cat ${filename} | shdir
X		echo -n "Old file listed above, override? [y/n]: "
X		if ( "$<" != "y" ) goto end
X		endif
X	dirs > ${filename}
X	endif
X#---------------------------------------------------------------#
X#		Clean up and exit here...			#
X#---------------------------------------------------------------#
Xend:
X	unset filename fname load_dirs dir_count curdir
SHAR_EOF
if test 2340 -ne "`wc -c < 'lsdir'`"
then
	echo shar: error transmitting "'lsdir'" '(should have been 2340 characters)'
fi
fi # end of overwriting check
echo shar: extracting "'useshdir'" '(3676 characters)'
if test -f 'useshdir'
then
	echo shar: will not over-write existing file "'useshdir'"
else
sed 's/^X//' << \SHAR_EOF > 'useshdir'
X#! /bin/csh -f
X#
X#-	useshdir - Update .login, .logout, and .cshrc to install shdir
X#-
X#-	This program will modify your .cshrc, .login, and .logout files
X#-	so that: (1) proper aliases will be defined. (2) directory stack
X#-	will be saved on logout and restored on login.
X#-
X#	Author:		Paul Lew, General Systems Group, Salem, NH
X#	Created at:	10/08/86  12:23 PM
X#	Last update:	10/14/86  02:28 PM
X#
X#-	Usage:	useshdir dirname <CR>
X#-
X#-	where: dirname is the directory where the shdir stored.
X#
Xset tmpfile = "/tmp/shdir$$.setup"
X#---------------------------------------------------------------#
X#	   Find shdir directory if not specified		#
X#---------------------------------------------------------------#
Xset dir = "$1"
Xif ( "${dir}" == "" ) set dir = '/usr/local/bin'
Xwhile (1)
X	if ( -e "${dir}/shdir" ) break
X	echo -n "Which directory did the shdir stored? "
X	set dir = "$<"
X	end
X#---------------------------------------------------------------#
X#	    Get Box style choice from the user			#
X#---------------------------------------------------------------#
Xcat << cat_eof
X
Xshdir can display the box in 3 styles (only if your terminal can
Xsupport the selected feature, i.e., proper entries in termcap
Xdatabase):
X
X	<1> special graphical character set for lines (default)
X	<2> reverse video blanks
X	<3> hightlighted blanks
X
Xcat_eof
Xecho -n "Please make a choice: [1-3]: "
Xswitch ( "$<" )
X	case 2:
X		set shdir = (shdir -br)
X		breaksw
X	case 3:
X		set shdir = (shdir -bh)
X		breaksw
X	case 1:
X	default:
X		set shdir = (shdir)
X	endsw
X#---------------------------------------------------------------#
X#		Add aliases to .cshrc file			#
X#---------------------------------------------------------------#
Xset msg = "Directory stack operation aliases"
X@ added = 0
Xif ( -e ~/.cshrc ) @ added = `grep "${msg}" ~/.cshrc | wc -l`
Xif ( ${added} == 0 ) then
X	cat > ${tmpfile} << cat_eof
X#
X# ${msg}  (Added: `date`)
X#
Xalias	lsdir	'source ${dir}/lsdir'
Xalias	po	'popd +\!* > /dev/null; '"${shdir}"' \`dirs\`'
Xalias	s	${shdir} '-s\!* \`dirs\` ;if ( \${status} ) pushd +\${status} > /dev/null'
Xalias	to	'pushd \!* > /dev/null ; '"${shdir}"' \`dirs\`'
Xcat_eof
X	echo ''
X	cat ${tmpfile}
X	echo ''
X	echo -n "Do you want to add these aliases to .cshrc file? [y/n]: "
X	if ( "$<" == "y") cat ${tmpfile} >> ~/.cshrc
X	endif
X#---------------------------------------------------------------#
X#	   Update directory stack save in .logout		#
X#---------------------------------------------------------------#
Xif ( ! -e ~/saved_wd ) mkdir ~/saved_wd
Xset msg = "save directory stack for next login"
X@ added = 0
Xif ( -e ~/.logout ) @ added = `grep "${msg}" ~/.logout | wc -l`
Xif ( ${added} == 0 ) then
X	echo "# ${msg}" > ${tmpfile}
X	echo 'dirs > ~/saved_wd/cwd.wd' >> ${tmpfile}
X	echo ''
X	cat ${tmpfile}
X	echo ''
X	echo -n "Do you want to add the line above to .logout file? [y/n]: "
X	if ( "$<" == "y") cat ${tmpfile} >> ~/.logout
X	endif
X#---------------------------------------------------------------#
X#		Add restore directory in .login			#
X#---------------------------------------------------------------#
Xset msg = "restore last working directory stacks"
X@ added = 0
Xif ( -e ~/.login ) @ added = `grep "${msg}" ~/.login | wc -l`
X#
Xif ( ${added} == 0 ) then
X	cat > ${tmpfile} << cat_eof
X# ${msg}
Xsource ${dir}/restdir
X${shdir} \`dirs\`
Xcat_eof
X#
X	echo ''
X	cat ${tmpfile}
X	echo ''
X	echo -n "Do you want to add above 3 lines to .login file? [y/n]: "
X	if ( "$<" == "y") cat ${tmpfile} >> ~/.login
X	endif
X#---------------------------------------------------------------#
X#			    Exit here				#
X#---------------------------------------------------------------#
Xend:
X/bin/rm -f ${tmpfile}
Xunset tmpfile dir msg added shdir
SHAR_EOF
if test 3676 -ne "`wc -c < 'useshdir'`"
then
	echo shar: error transmitting "'useshdir'" '(should have been 3676 characters)'
fi
chmod +x 'useshdir'
fi # end of overwriting check
echo shar: extracting "'shdir.c'" '(23978 characters)'
if test -f 'shdir.c'
then
	echo shar: will not over-write existing file "'shdir.c'"
else
sed 's/^X//' << \SHAR_EOF > 'shdir.c'
X/**************************************************************************
X*
X* File name:	shdir.c
X*
X* Author:	Paul Lew, General Systems Group, Inc. Salem, NH
X* Created at:	02/17/86  04:39 PM
X*
X* Description:	This program will take input argument from C shell directory
X*		stack and display on screen.  User can optionally select a
X*		directory to connect to.
X*	
X* Environment:	4.2 BSD Unix (under Pyramid OSx 2.5)
X*
X* Usage:	shdir [-r] [-sxxx] [-bh] [-br] [-bd] [-v] `dirs` <CR>
X*		where:
X*			-v	display version number
X*			-bh	use highlighted space for box
X*			-br	use reverse video space for box
X*			-bd	use dash char for box
X*			-r	use scroll if terminal support
X*			-sxxx	select directory xxx. If xxx not found or
X*				not specified, directory stack will be
X*				displayed to allow for selection.
X*
X* Update History:
X*
X*      Date		Description					By
X*    --------	------------------------------------------------	---
X*    02/17/86	Ver 1.0, Initial version				Lew
X*    02/28/86	Ver 1.1, add h, k for going backwards			Lew
X*    07/01/86	Ver 2.0, modify to work with termcap			Lew
X*    10/06/86	Ver 2.1, port to VAX BSD 4.2				Lew
X*    10/09/86	Ver 3.0, add scrolling capability			Lew
X*    10/13/86	Ver 3.1, add different options for different box style	Lew
X*    10/14/86	Ver 3.2, add string search feature			Lew
X*
X* Build:	cc -s -o shdir shdir.c -ltermcap
X*
X***************************************************************************/
X#include	<stdio.h>
X#include	<sgtty.h>
X#include	<ctype.h>
X#include	<strings.h>
X#include	<sys/file.h>
X
X#define		YES	1
X#define		NO	0
X#define		EOS	'\0'			/* end of string */
X#define		SPACE	' '
X#define		BS	'\010'
X#define		ESC	'\033'
X#define		RETURN	'\015'
X#define		NEWLINE	'\012'
X
X#define	when		break; case
X#define	otherwise	break;default
X
Xchar		*Version = "shdir Version 3.2  10/16/86  10:47 AM";
Xchar		*Author =
X		 "Paul Lew, General Systems Group   UUCP: decvax!gsg!lew";
X
XFILE		*Termfp;		/* terminal file pointer */
X
X#define		MAXDIR	22		/* not over typical screen size */
Xint		Maxdir = MAXDIR;	/* max # of directory to display */
X
X#define		MAXBAR	200
X
Xchar		Bar [MAXBAR];		/* vanilla bar */
Xchar		Topbar [MAXBAR];	/* top bar string */
Xchar		Botbar [MAXBAR];	/* bottom bar string */
Xchar		Vbar [20];		/* vertical bar string */
X
Xchar		Tab [80];
Xint		Ntab;
Xchar		Stack [1024];
Xchar		*Dirstack [MAXDIR];	/* pointers to directory entries */
Xint		Arglen [MAXDIR];	/* lengths of each entry */
Xint		Dircount = 0;
Xint		Topsel = 0;		/* start selection index */
X
X/* Curpos_query is a string to be sent to VT100 to get current cursor
X   position report.  There is no such field in termcap, you have to hack
X   the routine for other terminals since they might have different report
X   format */
X
Xchar		*Curpos_query = "\033[6n"; /* cursor position query */
Xint		Line;			/* # of lines per screen */
Xint		Fst_line = 0;		/* if %i specified Fst_line = 1 */
X
Xstruct	sgttyb	Scd;
Xint		Sno = 1;		/* first entry start index */
X
Xint		Select = NO;		/* YES = select entry */
Xint		Scroll = NO;		/* YES = use scroll feature if exist */
Xint		Tabstop = 8;		/* default tab-stop */
X
Xchar		*Search_string = NULL;	/* select search string */
Xint		Schlen = 0;		/* search string length */
Xint		Str_total = 0;		/* total matched search string */
Xint		Str_idx [MAXDIR];	/* string index */
X
X#define	BOX_REVERSE	1
X#define	BOX_HIGHLITE	2
X#define	BOX_GRAPH	3
X#define	BOX_DASH	4
X
Xint		Boxstyle = BOX_GRAPH;	/* default box style */
X
Xstruct	tcap	{
X	char		tc_id [3];	/* key for capability	*/
X	unsigned char	tc_delay;	/* # of msec to delay	*/
X	char		*tc_str;	/* ptr to Tc_str area	*/
X	unsigned char	tc_len;		/* length of tc_str	*/
X	};
X
Xstatic	char	Termcap [1024];
Xstatic	char	Tstr [1024];		/* buffer for real escape sequence */
Xstatic	char	*Tsp = Tstr;		/* pointer to be used by tgetstr */
Xstatic	int	Tcap_count = 0;		/* # of entries extracted */
X
X/*---------------- You may want to modify the following ----------------*/
X
X#define		AC	0
X#define		AE	1
X#define		AS	2
X#define		LE	3
X#define		ND	4
X#define		NL	5
X#define		UP	6
X#define		SR	7
X#define		SC	8
X#define		RC	9
X#define		CS	10
X#define		MR	11
X#define		MD	12
X#define		ME	13
X#define		BAD	14
X
Xstatic	struct	tcap Tcap [] = {
X		{ "ac",	0, NULL, 0 },	/* alternate chars		*/
X		{ "ae",	0, NULL, 0 },	/* exit alternate char set	*/
X		{ "as",	0, NULL, 0 },	/* start alternate char set	*/
X		{ "le", 0, NULL, 0 },	/* cursor left (CTRL H)		*/
X		{ "nd", 0, NULL, 0 },	/* cursor right			*/
X		{ "nl", 0, NULL, 0 },	/* cursor down (new line)	*/
X		{ "up", 0, NULL, 0 },	/* cursor up			*/
X		{ "sr", 0, NULL, 0 },	/* scroll reverse		*/
X		{ "sc", 0, NULL, 0 },	/* save cursor position		*/
X		{ "rc", 0, NULL, 0 },	/* restore cursor position	*/
X		{ "cs", 0, NULL, 0 },	/* set cursor scroll range	*/
X		{ "mr", 0, NULL, 0 },	/* mode reverse video		*/
X		{ "md", 0, NULL, 0 },	/* mode dense (highlight)	*/
X		{ "me", 0, NULL, 0 },	/* mode end (back to normal)	*/
X		{   "", 0, NULL, 0 }
X	};
X
X#define	SAVE_CURSOR	fprintf (Termfp, "%s", Tcap[SC].tc_str)
X#define	RESTORE_CURSOR	fprintf (Termfp, "%s", Tcap[RC].tc_str)
X
Xchar	*getenv(), *tgetstr(), *tgoto();
Xchar	*cs_define(), get_ac();
Xchar	*malloc();
X
X/*------------------------------------------------------------07/13/84--+
X|									|
X|	    M a i n    R o u t i n e    S t a r t s    H e r e		|
X|									|
X+----------------------------------------------------------------------*/
Xmain (argc, argv)
Xint	argc;		/* number of argument passed		*/
Xchar	**argv;		/* pointer to argument list		*/
X	{
X	register int	i, j;
X	char		*top = "\t";	/* top of stack string */
X	int		size;		/* longest string */
X
X	Termfp = fopen ("/dev/tty", "r+");
X	if (proc_arg (argc, argv) == 1) size = make_argv ();
X	else size = cp_ptr (argc, argv);
X
X	if (!Dircount) my_exit (0);
X	if (Search_string) Topsel = search ();
X
X	Ntab = make_bar (size) / 8;
X	fprintf (Termfp, "%s\n", Topbar);
X
X	if (Scroll) j = Topsel;
X	else	{
X		top = "   Top->";
X		j = 0;
X		}
X
X	for (i=0; i<Dircount; i++) {
X		put_line (j, (j==0) ? top : "\t", "\n");
X		if (++j >= Dircount) j = 0;
X		}
X
X	fprintf (Termfp, "%s\n", Botbar); fflush (Termfp);
X
X	if (Select && Dircount > 1) {
X		if (Tcap[UP].tc_len) my_exit (get_rdata ());
X		else my_exit (get_data ());
X		}
X
X	my_exit (0);
X	}
X
X/*-------------------------------------------------------------07/02/86-+
X|									|
X|	      make_bar : make all the graphical bar strings		|
X|									|
X+----------------------------------------------------------------------*/
Xmake_bar (size)
Xint	size;
X	{
X	register int	i;
X	char		*p;
X	char		hbar = get_ac('q');
X
X	size = ((size + 5)/Tabstop + 1) * Tabstop;
X	for (i=0; i<size-1 && i<MAXBAR; i++)
X		Bar[i] = hbar;		/* create bar string */
X	Bar[i] = EOS;
X
X	switch (Boxstyle) {
X	    case BOX_GRAPH:
X		if (Tcap[AC].tc_len) break;
X		Boxstyle = BOX_HIGHLITE;
X	    case BOX_HIGHLITE:
X		if (Tcap[MD].tc_len && Tcap[ME].tc_len) break;
X		Boxstyle = BOX_REVERSE;
X	    case BOX_REVERSE:
X		if (Tcap[MR].tc_len && Tcap[ME].tc_len) break;
X	    default:
X		Boxstyle = BOX_DASH;
X	    }
X
X	if (Boxstyle == BOX_GRAPH) {
X		sprintf (Topbar, "\015\t%s%c%s%c%s", Tcap[AS].tc_str,
X			 get_ac('l'), Bar, get_ac('k'), Tcap[AE].tc_str);
X		sprintf (Vbar, "%s%c%s", Tcap[AS].tc_str, get_ac('x'),
X			 Tcap[AE].tc_str);
X		sprintf (Botbar, "\t%s%c%s%c%s", Tcap[AS].tc_str,
X			 get_ac('m'), Bar, get_ac('j'), Tcap[AE].tc_str);
X		}
X	else if (Boxstyle == BOX_REVERSE || Boxstyle == BOX_HIGHLITE) {
X		while (--i >= 0) Bar[i] = SPACE;
X		p = Tcap [(Boxstyle == BOX_HIGHLITE) ? MD : MR].tc_str;
X		sprintf (Topbar, "\015\t%s %s %s",
X			 p, Bar, Tcap[ME].tc_str);
X		sprintf (Vbar, "%s %s", p, Tcap[ME].tc_str);
X		strcpy (Botbar, Topbar);
X		}
X	else	{
X		sprintf (Topbar, "\015\t+%s+", Bar);
X		sprintf (Vbar, "|");
X		strcpy (Botbar, Topbar);
X		}
X	return (size);
X	}
X
X/*-------------------------------------------------------------07/01/86-+
X|									|
X|		 get_rdata : get raw input and process it		|
X|									|
X+----------------------------------------------------------------------*/
Xget_rdata ()
X	{
X	register int	i, j, n;
X	int		x;		/* 0-9 index for next position */
X	char		c, buf[80];
X	int		dir, sel;
X	int		fd = fileno (Termfp);
X
X	rawio (fd, &Scd);
X	fputc (RETURN, Termfp);
X
X	if (Scroll) {			/* use scroll region */
X		sel = scroll_sel (fd);
X		i = 0; goto eos;
X		}
X	move_many (Dircount+1-Topsel, UP); /* back to top */
X	move_many (13, ND);
X
X	for (i=Topsel; ;) {		/* selection loop */
X		read (fd, &c, 1);
X		n = i;  x = 0;
X		switch (c & 0x7f) {
X			case '9': case '8': case '7': case '6':	case '5':
X			case '4': case '3': case '2': case '1': case '0':
X					x = (c & 0x7f) - '0';
X					if (x >= Dircount) continue;
X					i = figure_dir (x, i);
X					break;
X			case 'n':	i = find_idx (1, i);	/* next */
X					break;
X			case 'p':	i = find_idx (-1, i);	/* prev */
X					break;
X			case 'h': case 'H': case 'k': case 'K':
X			case BS:	if (--i < 0) i = Dircount-1;
X					break;
X			case RETURN:	sel = i; goto eos;
X			case SPACE:
X			default:	if (++i >= Dircount) i = 0;
X					break;
X			}
X		if (n == i) continue;
X		if (n > i) { n = n - i;  dir = UP; }
X		else { n = i - n;  dir = NL; }
X
X		/* move to next field */
X		strcpy (buf, " \010");
X		for (j=0; j<n; j++) strcat (buf, Tcap[dir].tc_str);
X		strcat (buf, "-\010");
X		fprintf (Termfp, "%s", buf);
X		fflush (Termfp);
X		}
Xeos:
X	move_many (Dircount-i+1, NL);
X	fputc (RETURN, Termfp);
X	fflush (Termfp);
X	resetio (fd, &Scd);
X	return (sel);
X	}
X
X/*-------------------------------------------------------------10/09/86-+
X|									|
X|		put_line : put a line on screen to scroll		|
X|									|
X+----------------------------------------------------------------------*/
Xput_line (i, lead, trail)
Xint	i;				/* index to Dirstack */
Xchar	*lead;				/* leading string */
Xchar	*trail;				/* trailing string */
X	{
X	register int	n, j;
X
X	n = Ntab - (Arglen[i]+5+1)/Tabstop;
X	for (j=0; j<n; j++) Tab[j] = '\t'; Tab[j] = EOS;
X	fprintf (Termfp, "%s%s %2d: %s%s%s%s",
X		lead, Vbar, i, Dirstack[i], Tab, Vbar, trail);
X	}
X
X/*-------------------------------------------------------------10/09/86-+
X|									|
X|		scroll_sel : scroll to show the selection		|
X|									|
X+----------------------------------------------------------------------*/
Xscroll_sel (fd)
Xint	fd;
X	{
X	register int	idx;		/* index to Dirstack of top element */
X	register int	target;		/* target index */
X	register int	move_cnt;	/* # of up/down to move */
X	int		topline;	/* top line number of the box */
X	int		botline;	/* bottom line # of the box */
X	int		ld;		/* last digit (0-9) */
X	char		c;
X
X	/* find out where is the cursor and define the scroll region
X	   accordingly. Note this should be done AFTER the directory
X	   stack dislpayed since you do not know where the original
X	   screen boundaries defined to be. */
X
X	botline = get_curline (fd) - 2;
X	topline = botline - Dircount + 1;		/* define region */
X	fprintf (Termfp, "%s%s%s", Tcap[SC].tc_str,
X		 cs_define (topline, botline), Tcap[RC].tc_str);
X
X	move_many (Dircount+1, UP);
X	move_many (13, ND);
X
X	for (idx=Topsel, move_cnt=1; ; move_cnt=1) {
X		read (fd, &c, 1);	/* get user key stroke */
X		c &= 0x7F;
X		switch (c) {
X		    case RETURN:
X			goto eofor;
X
X		    case 'n':
X			target = find_idx (1, idx);
X			goto move;
X		    case 'p':
X			target = find_idx (-1, idx);
X			goto move;
X		    case '9': case '8': case '7': case '6': case '5':
X		    case '4': case '3': case '2': case '1': case '0':
X			ld = c - '0';
X			if (ld >= Dircount) continue;
X			target = idx;
X			do	{
X				if (++target >= Dircount) target = 0;
X				} while (target % 10 != ld);
Xmove:			move_cnt = target - idx;
X			if (move_cnt < 0) move_cnt += Dircount;
X			if (move_cnt > Dircount/2) {
X				move_cnt = Dircount - move_cnt;
X				goto up;
X				}
X			goto down;
X
X		    case 'k': case 'K': case 'h': case 'H': case BS:
X			/* scroll down one entry */
Xup:			SAVE_CURSOR;
X			while (move_cnt-- > 0) {
X				move_many (1, SR);
X				if (--idx < 0) idx = Dircount - 1;
X				put_line (idx, "\r\t", "\r");
X				}
X			RESTORE_CURSOR;
X			break;
X
X		    case 'j': case 'J': case 'l': case 'L': case SPACE:
X		    default:	/* scroll up one entry */
Xdown:			SAVE_CURSOR;
X			move_many (Dircount-1, NL);
X			while (move_cnt-- > 0) {
X				move_many (1, NL);
X				put_line (idx, "\r\t", "\r");
X				if (++idx >= Dircount) idx = 0;
X				}
X			RESTORE_CURSOR;
X			break;
X		    }
X		fflush (Termfp);
X		}
Xeofor:
X	/* restore scrolling region to full screen (assumed the
X	   original state is so) */
X	fprintf (Termfp, "%s%s%s", Tcap[SC].tc_str,
X 		 cs_define (Fst_line, Line-1+Fst_line),
X		 Tcap[RC].tc_str);		/* reset region */
X	fflush (Termfp);
X	return (idx);
X	}
X
X/*-------------------------------------------------------------10/09/86-+
X|									|
X| cs_define : return a string contains cursor scroll region definition	|
X|									|
X+----------------------------------------------------------------------*/
Xchar	*
Xcs_define (from, to)
Xint	from;				/* start line number */
Xint	to;				/* end line number */
X	{
X	static char	cs_buf [20];
X	static int	cs_from = 0;
X	static int	cs_to = 0;
X	static char	tc1, tc2;
X	register char	*p;
X	register int	i;
X
X	if (cs_from == 0) {
X		p = Tcap[CS].tc_str;
X		i = 0;
X		while (*p != EOS) {
X			if (strncmp (p, "%i", 2) == 0) {
X				Fst_line = 1;
X				p += 2;
X				continue;
X				}
X			if (strncmp (p, "%d", 2) == 0) {
X				if (cs_from == 0) cs_from = i;
X				else cs_to = i;
X				i += 3;		/* 3 digits reserved */
X				p += 2;
X				continue;
X				}
X			cs_buf [i++] = *p++;
X			}
X		cs_buf [i] = EOS;
X		tc1 = cs_buf [cs_from + 3];
X		tc2 = cs_buf [cs_to + 3];
X		}
X	sprintf (&cs_buf[cs_from], "%03d", from);
X	cs_buf [cs_from + 3] = tc1;
X
X	sprintf (&cs_buf[cs_to], "%03d", to);
X	cs_buf [cs_to + 3] = tc2;
X
X	return (cs_buf);
X	}
X
X/*-------------------------------------------------------------10/09/86-+
X|									|
X|	    get_curline : get current cursor line number		|
X|									|
X+----------------------------------------------------------------------*/
Xget_curline (fd)
Xint	fd;
X	{
X	register int	i, gotesc = NO;
X	char		c;
X	int		line, column;
X	char		buf[80];
X
X	/* Ask terminal to report its cursor position */
X
X	fprintf (Termfp, "%s", Curpos_query); fflush (Termfp);
X	for (i=0; i<80-1; i++) {
Xloop:		read (fd, &c, 1);
X		c &= 0x7F;
X		if (gotesc == NO) {
X			if (c != ESC) goto loop;
X			gotesc = YES;
X			}
X		if ((buf[i] = c) == 'R') {	 /* end of report */
X			buf[++i] = EOS;
X			break;
X			}
X		}
X	sscanf (buf, "\033[%d;%dR", &line, &column);	/* VT100 only */
X	return (line);
X	}
X
X/*-------------------------------------------------------------10/09/86-+
X|									|
X|     move_many : repeatedly write certain string to output device	|
X|									|
X+----------------------------------------------------------------------*/
Xmove_many (n, code)
Xint	n;				/* repeat count */
Xint	code;				/* index to Tcap structure */
X	{
X	register int	i;
X
X	for (i=0; i<n; i++) {
X		fprintf (Termfp, "%s", Tcap[code].tc_str);
X		}
X	fflush (Termfp);
X	}
X
X/*-------------------------------------------------------------10/14/86-+
X|									|
X|	     my_exit : close opened terminal file then exit 		|
X|									|
X+----------------------------------------------------------------------*/
Xmy_exit (n)
Xint	n;
X	{
X	if (Termfp) fclose (Termfp);
X	exit (n);
X	}
X
X/*-------------------------------------------------------------07/01/86-+
X|									|
X|   get_data : get data for terminal with no cursor addr capability	|
X|									|
X+----------------------------------------------------------------------*/
Xget_data ()
X	{
X	char		buf [20];
X	register int	i = 0;
X
X	printf ("Please Select [0-%d]: ", Dircount-1);
X	gets (buf);
X	if (strlen (buf)) {
X		i = atoi (buf);
X		if (i < 0 || i > Dircount-1) i = 0;
X		}
X	return (i);
X	}
X
X#define	PADDING	'\200'
X/*-------------------------------------------------------------05/10/86-+
X|									|
X|	   tcap_init : initialize termcap data structure		|
X|									|
X+----------------------------------------------------------------------*/
Xtcap_init ()
X	{
X	register int	i;
X	struct	tcap	*p;
X	char		*tp;
X	unsigned int	delay;
X	int		status;
X	char		*termtype = getenv ("TERM");
X
X	if ((status = tgetent (Termcap, termtype)) != 1) {
X		if (status == 0) {
X			fprintf (stderr, "No entry for %s in termcap\r\n",
X				 termtype);
X			}
X		else	fprintf (stderr, "Can not open termcap file\r\n");
X		my_exit (1);
X		}
X
X	for (p= &Tcap[0]; strlen (p->tc_id) > 0; p++) {
X		tp = tgetstr (p, &Tsp);
X		if (tp == NULL) tp = "";	 /* no such capability */
X		delay = 0;
X		while (isdigit (*tp)) {
X			delay = delay*10 + (*tp++) - '0';
X			}
X		p->tc_delay = delay;
X		p->tc_len = strlen (tp);
X		if (delay) {
X			p->tc_str = malloc (p-> tc_len + delay);
X			strcpy (p->tc_str, tp);
X			tp = p->tc_str + p->tc_len;
X			for (i=0; i<delay; i++) *tp++ = PADDING;
X			*tp = EOS;
X			p->tc_len += delay;
X			}
X		else	p->tc_str = tp;
X		Tcap_count++;
X		}
X
X	Line = tgetnum ("li");
X	tcap_special ();
X	}
X
X/*-------------------------------------------------------------07/02/86-+
X|									|
X|		tcap_special : special initialization			|
X|									|
X+----------------------------------------------------------------------*/
Xtcap_special ()
X	{
X	if (Tcap[NL].tc_len == 0) {
X		Tcap[NL].tc_str = "\n";
X		Tcap[NL].tc_delay = 0;
X		Tcap[NL].tc_len = 1;
X		}
X	}
X
X/*-------------------------------------------------------------07/01/86-+
X|									|
X|  get_ac : get alternate character for a given VT100 alternate char	|
X|									|
X+----------------------------------------------------------------------*/
Xchar
Xget_ac (c)
Xchar	c;
X	{
X	register char	*p;
X	char		oc;
X
X	if (Tcap_count == 0) tcap_init ();
X	for (p=Tcap[AC].tc_str; *p != EOS; p += 2) {
X		if (*p == c) return *(p+1);
X		}
X	switch (c) {
X		case 'j':		/* lower right corner	*/
X		case 'k':		/* upper right corner	*/
X		case 'l':		/* upper left corner	*/
X		case 'm':  oc = '+';	/* lower left corner	*/
X			   break;
X		case 'q':  oc = '-';	/* horizontal bar */
X			   break;
X		case 'x':  oc = '|';	/* vertical bar */
X			   break;
X		default:   oc = '?';	/* bad choice */
X		}
X	return (oc);
X	}
X
X/*-------------------------------------------------------------02/18/86-+
X|									|
X|	      figure_dir : figure out which direction to go		|
X|									|
X+----------------------------------------------------------------------*/
Xfigure_dir (x, i)
Xint	x;				/* target index (0-9) */
Xint	i;				/* curent index (0-Dircount) */
X	{
X	int	n;
X
X	n = i % 10;
X	if (x == n) {
X		if (i + 10 < Dircount) return (i+10);
X		}
X	if (x > n) {
X		if (i - n + x < Dircount) return (i - n + x);
X		}
X	else	{
X		if (i - n + x + 10 < Dircount) return (i - n + x + 10);
X		}
X
X	return (x);
X	}
X
X/*-------------------------------------------------------------02/17/86-+
X|									|
X|	     cp_ptr : copy all the argv pointers to Dirstack		|
X|									|
X+----------------------------------------------------------------------*/
Xcp_ptr (argc, argv)
Xint	argc;
Xchar	**argv;
X	{
X	register int	i, j;
X	int		n;
X	int		size = 0;
X
X	for (j=0, i=Sno; i<argc; i++) {
X		if (j >= Maxdir) {
X			fprintf (stderr, "Max %d entries, extra ignored\n",
X				 Maxdir);
X			fflush (stderr);
X			break;
X			}
X		Dirstack[j] = argv[i];			/* save start addr */
X		Arglen[j++] = n = strlen (argv[i]);	/* and length */
X		if (n > size) size = n;
X		}
X	Dircount = j;
X	return (size);			/* return the longest length */
X	}
X
X/*-------------------------------------------------------------02/17/86-+
X|									|
X|		    make_argv : make an argument list			|
X|									|
X+----------------------------------------------------------------------*/
Xmake_argv ()
X	{
X	char		*p = Stack;
X	char		*op = Stack;	/* old pointer */
X	char		c;
X	register int	i = 0;
X	int		size = 0;
X	int		n;
X
X	gets (Stack);
X	while ((c = *p) != NEWLINE && c != EOS) {
X		if (c == SPACE) {
X			*p = EOS;
X			Dirstack[i] = op;
X			Arglen[i++] = n = p - op;
X			if (n > size) size = n;
X			op = p+1;
X			}
X		p++;
X		}
X	if (i > Maxdir) {
X		fprintf (stderr, "Max %d entries, extra ignored\n", Maxdir);
X		fflush (stderr);
X		i = Maxdir;
X		}
X	Dircount = i;
X	return (size);
X	}
X/*-------------------------------------------------------------10/14/86-+
X|									|
X|	    find_idx : find next/prev index from Str_idx array		|
X|									|
X+----------------------------------------------------------------------*/
Xfind_idx (dir, n)
Xint	dir;				/* direction: 1=next, -1=prev */
Xint	n;				/* current index */
X	{
X	register int	i;
X
X	for (i=0; i<Str_total; i++) {
X		if (Str_idx[i] == n) {		/* found current, locate next */
X			i += dir;
X			if (i == Str_total) i = 0;
X			if (i < 0) i = Str_total - 1;
X			return (Str_idx[i]);
X			}
X		}
X	return (n);
X	}
X
X/*------------------------------------------------------------07/12/84--+
X|									|
X|	proc_arg : routine to process command arguments (options)	|
X|									|
X+----------------------------------------------------------------------*/
Xproc_arg (argc, argv)
Xint	argc;
Xchar	**argv;
X	{
X	register int	i;
X	register int	n;
X	char		*p;
X
X	p = getenv ("TABSTOP");
X	if (p != NULL) {		/* set tabstop to n (default 8) */
X		n = atoi (p);
X		if (n > 0) Tabstop = n;
X		}
X	for (n=i=0; i<argc; i++) {
X		if (argv[i][0] != '-') {
X			n++;		/* count non-option argument */
X			continue;
X			}
X		Sno++;
X		switch (argv[i][1]) {
X		    when 's':	p = &argv[i][2];
X				if ((Schlen = strlen (p)) == 0) Select = YES;
X				else Search_string = p;
X
X		    when 'r':	tcap_init ();
X				if (Tcap[SC].tc_len != 0 &&
X				    Tcap[RC].tc_len != 0 &&
X				    Tcap[CS].tc_len != 0) Scroll = YES;
X
X		    when 'b':	box_style (argv[i][2]);
X
X		    when 'v':	printf ("%s\n%s\n", Version, Author);
X				my_exit (0);
X
X		    otherwise:	Sno--;		/* dont count */
X		    }
X		}
X	return (n);
X	}
X
X/*-------------------------------------------------------------10/14/86-+
X|									|
X|   search : find string in dir stack and exit or return found index	|
X|									|
X+----------------------------------------------------------------------*/
Xsearch ()
X	{
X	register int	i, j;
X	register char	*p;
X	int		len;
X	int		sel;
X
X	/* If argument starts with a number, it will be used as index to
X	   directory stack.  If not, it will be used as string to search */
X
X	sel = atoi (Search_string);
X	if (0 < sel && sel < Dircount) {	 /* number used as index */
Xmatch:		puts (Dirstack[sel]);
X		my_exit (sel);
X		}
X	for (Str_total=i=0, sel = -1; i<Dircount; i++) {
X		len = Arglen[i];
X		p = Dirstack[i];
X		for (j=0; j<=len-Schlen; j++) {
X			if (strncmp (Search_string, p+j, Schlen) == 0) {
X				Str_idx[Str_total++] = i;
X				if (sel == -1) sel = i;
X				break;
X				}
X			}
X		}
X	if (Str_total == 1) goto match;
X	Select = YES;
X	return ((sel == -1) ? 0 : sel); /* more than one, stay around */
X	}
X
X/*-------------------------------------------------------------10/14/86-+
X|									|
X|		    box_style : select box style			|
X|									|
X+----------------------------------------------------------------------*/
Xbox_style (style)
Xchar	style;				/* style */
X	{
X	switch (style) {
X		when 'h':	Boxstyle = BOX_HIGHLITE;
X		when 'r':	Boxstyle = BOX_REVERSE;
X		when 'g':	Boxstyle = BOX_GRAPH;
X		otherwise:	Boxstyle = BOX_DASH;
X		}
X	}
X
Xint		Old_flags;
Xint		Pseudo = -1;		/* 0/1 = normal/pseudo terminal */
X/*------------------------------------------------------------07/10/84--+
X|									|
X|	   rawio : oepn terminal in RAW mode without ECHO		|
X|									|
X+----------------------------------------------------------------------*/
Xrawio (fd, mp)
Xint		fd;			/* file descriptor */
Xstruct	sgttyb	*mp;			/* ptr to mode structure */
X	{
X	char	*tname = (char *) ttyname (fileno(stdout)) + 8;
X					/* /dev/ttypxxx	*/
X					/* 012345678	*/
X
X	if (*tname == 'p' || *tname == 'q' || *tname == 'r') {
X		/* pseudo terminal, delay a while so that output will
X		   drain...   */
X		Pseudo = YES;
X		sleep (1);
X		}
X	else	Pseudo = NO;
X
X	ioctl (fd, TIOCGETP, mp);
X	Old_flags = mp-> sg_flags;	/* save old setting */
X	mp-> sg_flags |= RAW;
X	mp-> sg_flags &= ~ECHO;
X	ioctl (fd, TIOCSETP, mp);
X	}
X
X/*------------------------------------------------------------07/10/84--+
X|									|
X|	resetio : close terminal and restore original setting		|
X|									|
X+----------------------------------------------------------------------*/
Xresetio (fd, mp)
Xint		fd;			/* file descriptor */
Xstruct	sgttyb	*mp;			/* ptr to old setting */
X	{
X	if (Pseudo) sleep (1);
X
X	mp-> sg_flags = Old_flags;
X	ioctl (fd, TIOCSETP, mp);	/* restore original setting */
X	}
SHAR_EOF
if test 23978 -ne "`wc -c < 'shdir.c'`"
then
	echo shar: error transmitting "'shdir.c'" '(should have been 23978 characters)'
fi
fi # end of overwriting check
#	End of shell archive
exit 0
