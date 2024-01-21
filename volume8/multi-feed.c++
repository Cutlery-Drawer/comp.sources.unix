Subject:  v08i049:  Simultaneous multi-site news feeder in C++
Newsgroups: mod.sources
Approved: mirror!rs

Submitted by: "Stephen J. Muir" <stephen%computing.lancaster.ac.uk@Cs.Ucl.AC.UK>
Mod.sources: Volume 8, Issue 49
Archive-name: multi-feed.c++

[  I do not have C++.  --r$  ]

#!/bin/sh
echo 'Start of pack.out, part 01 of 01:'
echo 'x - README'
sed 's/^X//' > README << '/'
XSimultaneous Multi-Site News Feeder (version 1.0)
X--------------------------------------------------
X
XThis software may be freely copied provided that no charge is made and you
Xdon't pretend you wrote it.
X
XThis is the simultaneous multi-site news feeder.  It was written to solve the
Xfollowing problems with existing news batchers:
X
X	o When feeding several sites, each news article was the subject of
X	  several batch runs, thus consuming a lot of processor power.
X
X	o When feeding several sites, disk space would be gobbled up very
X	  quickly.
X
X	o If, for some reason, two batchers for the same site tried to run
X	  simultaneously, chaos would ensue.
X
X	o If the disk filled during batching, the batcher wouldn't notice and
X	  carry on regardless.
X
X	o If news was being unbatched during news batching, you would end up
X	  with lots of tiny batches.
X
X	o The log file(s) had to be trimmed from time to time.
X
X	o The "maximum batch size" was, in fact, a minimum batch size!
X
XNow for the bad news!  It is not very portable (yet!).  These are the minimum
Xrequirements:
X
X	o 4.2 BSD UNIX
X
X	o C++ version 1.1
X
X	o 2.10.3 news (if you want the multi-site facility)
X
XIf you have a different environment, then I'm afraid you'll have to hack it.
X
XInstallation:
X
X	1)  Edit the following files to your requirements:
X		Makefile
X		config.h
X		newsfeedlist.sh
X
X	2)  There are several bugs in the include files in C++ version 1.1.
X	    All but one of these will show up as compilation errors.  The
X	    remaining one, which will cause a memory fault if not fixed, is
X	    that the "stat" structure is different from that used by 4.2 BSD
X	    UNIX.  If you have done everything properly, there should be no
X	    errors or warnings during compilation.  You should be able to
X	    achieve this by editing the C++ include files alone.
X
X	3a) Edit your "sys" file, in order to make full use of the multi-site
X	    capabilities of this news batcher, to use the MULTICAST facility.
X	    This also has to be defined in inews.  (It will still accept old
X	    style batches.)  Here is a rather contrived example:
X
X		site1:M:world,comp,sci,rec,news:uucp-feed
X		site2:M:world,comp,sci,rec,news:uucp-feed
X		site3:M:world,comp,news:uucp-feed
X		uucp-feed:OF:all:
X
X	    All these sites will now be fed by "newsfeed uucp-feed"
X	    (but see below).
X
X	3b) You now need a command file which will take a news batch and queue
X	    it for several sites simultaneously (if you use the above feature).
X	    To save disk space problems when batching, it should ideally make
X	    one copy and use UNIX links for the remaining sites.  Here is an
X	    example, for an 8-bit compressed multi-feed, to put in file
X	    "uucp-feed.cmd":
X
X		#!/bin/sh
X		(echo "#! cunbatch"; /usr/lib/news/compress -q) | \
X		/usr/lib/news/uucp-multifeed $*
X
X	    You have to write "uucp-multifeed" yourself!  It takes the sites to
X	    queue for as arguments.  (I only use UUCP for one of the sites I
X	    feed, so I haven't bothered to write it.)  If the command file
X	    exits abnormally, batching will be abandoned and the various files
X	    will be reset to their previous state.  Thus, for example, if you
X	    wish to stop batching when the disk is too full, you could add the
X	    following to "uucp-feed.cmd" (after the first line):
X
X		if /usr/lib/news/disktoofull
X		then
X			echo $0: DISK TOO FULL >> /usr/lib/news/errlog
X			exit 1
X		fi
X
X	    where "disktoofull" returns normally if your disk is too full.
X
XSend any bugs/improvements to me:
X
XName:	Stephen J. Muir			| Post: University of Lancaster,
XEMAIL:	stephen@comp.lancs.ac.uk	|	Department of Computing,
XUUCP:	...!mcvax!ukc!dcl-cs!stephen	|	Bailrigg, Lancaster, UK.
XPhone:	+44 524 65201 Ext. 4120		|	LA1 4YR
/
echo 'x - Makefile'
sed 's/^X//' > Makefile << '/'
XCC=CC
XCFLAGS=-O
XCONFIGOBJS=main.o log.o misc.o
XOBJS=${CONFIGOBJS} feed.o batch.o io.o
XINSTALLDIR=/usr/lib/news/
X
Xnewsfeed:	${OBJS}
X		${CC} -o $@ ${OBJS}
X
X${OBJS}:	defs.h
X
X${CONFIGOBJS}:	config.h
X
Xinstall:	newsfeed newsfeedlist.sh newsfeed.man newsfeedlist.man
X		install -o news -g news -s newsfeed ${INSTALLDIR}
X		cp newsfeedlist.sh ${INSTALLDIR}newsfeedlist
X		chmod 755 ${INSTALLDIR}newsfeedlist
X		chown news ${INSTALLDIR}newsfeedlist
X		chgrp news ${INSTALLDIR}newsfeedlist
X		cp newsfeed.man /usr/man/mann/newsfeed.n
X		cp newsfeedlist.man /usr/man/mann/newsfeedlist.n
X
Xclean:
X		rm -f newsfeed *.o *..o *..c core
/
echo 'x - config.h'
sed 's/^X//' > config.h << '/'
X/* Written by Stephen J. Muir, Lancaster University, England, UK.
X *
X * EMAIL: stephen@comp.lancs.ac.uk
X * UUCP:  ...!mcvax!ukc!dcl-cs!stephen
X *
X * Version 1.0
X */
X
X// Any of the lines below may be commented out
X
X//# define DEBUG
X
X// News uid and gid.
X# define NEWSUID		2
X# define NEWSGID		4
X
X// Priority to run at.
X//# define NICENESS		1
X
X// Working directory.
X# define BATCH_OUT_DIR		"/usr/spool/news/batchout/"
X
X// Default maximum size of batch.
X# define DEFAULT_MAX_SIZE	200000
X
X// Stamp log even if there is nothing to batch.
X//# define ALWAYS_STAMP_LOG
X
X// Number of seconds after which to delete log entries.
X# define LOG_EXPIRE_SECONDS	(14*24*60*60)
X
X// Error log.
X# define ERROR_LOG		"/usr/lib/news/errlog"
/
echo 'x - defs.h'
sed 's/^X//' > defs.h << '/'
X/* Written by Stephen J. Muir, Lancaster University, England, UK.
X *
X * EMAIL: stephen@comp.lancs.ac.uk
X * UUCP:  ...!mcvax!ukc!dcl-cs!stephen
X *
X * Version 1.0
X */
X
X# include <sys/errno.h>
X# include <sys/types.h>
X# include <sys/file.h>
X# include <sys/stat.h>
X# include <sys/time.h>
X# include <sys/resource.h>
X# include <signal.h>
X# include <stream.h>
X# include <string.h>
X# include <osfcn.h>
X
X# define BUFFER_SIZE	4096
X# define WARNING(x)	error(x,0,0)
X# define SYS_WARNING(x)	error(x,1,0)
X# define FATAL(x)	error(x,0,1)
X# define SYS_FATAL(x)	error(x,1,1)
X
Xstruct sitelist
X{   const char	*site_name;
X    short	site_seen;
X    sitelist	*site_next;
X};
X
X// to free memory automagically
Xclass auto_delete
X{   void	*stored_ptr;
Xpublic:
X    auto_delete (void *ptr)	{ stored_ptr = ptr; }
X    ~auto_delete ()		{ delete stored_ptr; }
X};
X
X// to close files automagically
Xclass auto_close
X{   int	stored_fd;
Xpublic:
X    auto_close (int fd)	{ stored_fd = fd; }
X    ~auto_close ()	{ int e = errno; close (stored_fd); errno = e; }
X};
X
X// feed.o
Xextern void		feed_news (const char *, const char **, off_t);
X// log.o
Xextern void		open_log (const char *);
Xextern void		add_to_log (const char *, const sitelist *);
Xextern void		close_log ();
Xextern void		sync_log ();
Xextern void		reset_log ();
X// batch.o
Xextern int		open_batch (const char **, off_t);
Xextern int		send_article (const char *);
Xextern int		close_batch ();
Xextern void		kill_batch ();
X// io.o
Xextern void		fatal_input_stream_error (const char *, int);
Xextern void		fatal_output_stream_error (const char *);
Xextern int		getline (const istream&, char *, int);
Xextern int		append_file (const char *, const char *);
X// misc.o
Xextern const char	*rename_error;
Xextern char		*new_string (const char *);
Xextern char		*join_string (const char *, const char *);
Xextern void		error (const char *, int, int);
X// libC.a
Xextern void		(*_new_handler) ();
/
echo 'x - batch.c'
sed 's/^X//' > batch.c << '/'
X/* Written by Stephen J. Muir, Lancaster University, England, UK.
X *
X * EMAIL: stephen@comp.lancs.ac.uk
X * UUCP:  ...!mcvax!ukc!dcl-cs!stephen
X *
X * Version 1.0
X */
X
X# include "defs.h"
X
Xstatic short		batch_error;
Xstatic int		pid, output_channel = -1, (*old_pipe_signal) ();
Xstatic off_t		current_size, max_size;
Xstatic struct stat	statbuf;
X
X// This routine sets up a pipe to the enqueueing command.
X// Parameters:
X//	command -> command to queue the batch for transfer
X//	new_max_size -> maximum batch size
X// Return value:
X//	-2: couldn't create pipe
X//	-1: invalid invocation (pipe already open)
X//	 0: ok (as far as the parent process can tell)
Xopen_batch (const char **command, off_t new_max_size)
X{   if (output_channel != -1)
X	return -1;
X    max_size = new_max_size;
X    int		pipes [2];
X    if (pipe (pipes) == -1)
X	return -2;
X    // process table could be full, in which case we may be in trouble anyway,
X    // but at least it's not our fault for not reporting it
X    while ((pid = fork ()) == -1)
X	sleep (1);
X    if (pid == 0)
X    {	// child process ...
X	close (pipes [1]);
X	if (dup2 (pipes [0], 0) == -1)
X	    SYS_FATAL ("dup2()");
X	close (pipes [0]);
X	execv (*command, command);
X	// I hope this works!
X	SYS_FATAL (*command);
X    }
X    close (pipes [0]);
X    old_pipe_signal = signal (SIGPIPE, SIG_IGN);
X    output_channel = pipes [1];
X    batch_error = 0;
X    current_size = 0;
X    return 0;
X}
X
X// This routine closes the pipe and (hopefully) reports whether or not it
X// worked.
X// Return value:
X//	-2: something went wrong!
X//	-1: invalid invocation (pipe not open)
X//	 0: ok (as far as we can tell)
Xclose_batch ()
X{   if (output_channel == -1)
X	return -1;
X    close (output_channel);
X    output_channel = -1;
X    signal (SIGPIPE, old_pipe_signal);
X    int		status, wait_pid;
X    while ((wait_pid = wait (&status)) != pid && wait_pid != -1)
X	;
X    return (wait_pid == -1 || status) ? -2 : 0;
X}
X
X// This routine adds a file to the batch.  If this would cause batch overflow to
X// occur, the article is not added, assuming the caller will try again.
X// Parameters:
X//	pathname -> article to be included
X// Return value:
X//	-3: error (batch write error)
X//	-2: error (article read error)
X//	-1: invalid invocation (pipe not open or current batch in error)
X//	 0: ok (article added to batch)
X//	 1: ok (article didn't exist -- maybe it was cancelled/expired)
X//	 2: ok (article would overflow batch -- article not included)
Xsend_article (const char *pathname)
X{   if (output_channel == -1 || batch_error)
X	return -1;
X    register int	article_fd = open (pathname, O_RDONLY, 0);
X    if (article_fd == -1)
X	return 1;
X    auto_close	auto_article (article_fd);
X    if (fstat (article_fd, &statbuf) == -1)
X	return 1;
X    char	*rnews_header = form ("#! rnews %d\n", statbuf.st_size);
X    int		rnews_header_size = strlen (rnews_header);
X    if (current_size > 0 &&
X	max_size > 0 &&
X	(current_size + rnews_header_size + statbuf.st_size) > max_size
X       )
X	return 2;
X    char		buffer [BUFFER_SIZE];
X    register int	byte_count;
X    current_size += rnews_header_size + statbuf.st_size;
X    if (write (output_channel, rnews_header, rnews_header_size) !=
X	rnews_header_size
X       )
X    {	batch_error = 1;
X	return -3;
X    }
X    while ((byte_count = read (article_fd, buffer, BUFFER_SIZE)) > 0)
X	if (write (output_channel, buffer, byte_count) != byte_count)
X	{   batch_error = 1;
X	    return -3;
X	}
X    if (byte_count)
X    {	batch_error = 1;
X	return -2;
X    }
X    return 0;
X}
X
X// This routine tries to kill the current batch.
Xvoid	kill_batch ()
X{   if (output_channel != -1)
X	kill (pid, SIGTERM);
X}
/
echo 'x - feed.c'
sed 's/^X//' > feed.c << '/'
X/* Written by Stephen J. Muir, Lancaster University, England, UK.
X *
X * EMAIL: stephen@comp.lancs.ac.uk
X * UUCP:  ...!mcvax!ukc!dcl-cs!stephen
X *
X * Version 1.0
X */
X
X# include "defs.h"
X
Xstatic char	*base_again, *base_hold, *base_cmd, *default_site;
Xstatic short	first_article;
Xstatic int	fd_again = -1, fd_hold = -1;
Xstatic off_t	max_batch_size;
Xstatic sitelist	*hold_list;
Xstatic ostream	*stream_again, *stream_hold;
X
X// This routine writes the given line to the "again" file for reprocessing.
X// Parameters:
X//	article_line -> line to write
X// Return value:
X//	exits on error
Xstatic void	write_again (const char *article_line)
X{   if (fd_again == -1)
X    {	if ((fd_again = open (base_again,
X			      O_CREAT | O_TRUNC | O_WRONLY | O_APPEND,
X			      0666
X			     )
X	     ) == -1
X	   )
X	    SYS_FATAL (base_again);
X	fcntl (fd_again, F_SETFD, 1);
X	stream_again = new ostream (fd_again);
X    }
X    *stream_again << article_line << "\n";
X}
X
X// This routine writes the given article to the "hold" file.
X// Parameters:
X//	article -> article to write
X// Return value:
X//	exits on error
Xstatic void	write_hold (const char *article)
X{   if (fd_hold == -1)
X    {	if ((fd_hold = open (base_hold, O_CREAT | O_WRONLY | O_APPEND, 0666))
X	    == -1
X	   )
X	    SYS_FATAL (base_hold);
X	fcntl (fd_hold, F_SETFD, 1);
X	stream_hold = new ostream (fd_hold);
X    }
X    *stream_hold << article;
X    for (sitelist *site_ptr = hold_list;
X	 site_ptr;
X	 site_ptr = site_ptr->site_next
X	)
X	if (site_ptr->site_seen)
X	    *stream_hold << " " << site_ptr->site_name;
X    *stream_hold << "\n";
X}
X
X// This routine tries to write the given article to the current batch, starting
X// one if none is current.  If the article doesn't belong to the current batch,
X// it will save it for further processing.  Finally, it may add the article to
X// the "hold" file.
X// Parameters:
X//	article_line -> a line from the batch file
X// Return value:
X//	exits on error
Xstatic void	feed_article (const char *article_line)
X{   static short	batch_finished;
X    static sitelist	*feed_list;
X    register char	*c_ptr;
X    register int	ret, holding = 0;
X    register sitelist	*site_ptr, **site_ptr_ptr;
X
X    // wait until the whole input is reprocessed
X    if (first_article)
X	batch_finished = 0;
X    if (batch_finished)
X    {	write_again (article_line);
X	return;
X    }
X
X    // reset the "hold" list
X    for (site_ptr = hold_list; site_ptr; site_ptr = site_ptr->site_next)
X	site_ptr->site_seen = 0;
X
X    register char	*new_article_line = new_string (article_line);
X    auto_delete	auto_new_article_line (new_article_line);
X
X    // split line into (article, sitelist)
X    for (c_ptr = new_article_line; *c_ptr != ' ' && *c_ptr != '\0'; ++c_ptr)
X	;
X    while (*c_ptr == ' ')
X	*c_ptr++ = '\0';
X    if (*c_ptr == '\0')
X	c_ptr = default_site;
X
X    // if first article, make sure we can read it and set up the "feed" list
X    if (first_article)
X    {	int	site_count = 0;
X	// delete any previous "feed" list
X	for (site_ptr = feed_list; site_ptr; )
X	{   sitelist	*delete_ptr = site_ptr;
X	    site_ptr = site_ptr->site_next;
X	    delete delete_ptr->site_name;
X	    delete delete_ptr;
X	}
X	feed_list = 0;
X
X	// the first article *must* exist
X	if ((ret = access (new_article_line, R_OK)) == -1)
X	{   if (errno == ENOENT)
X		return;
X	    SYS_WARNING (new_article_line);
X	}
X
X	// now set up the "feed" list
X	for (site_ptr_ptr = &feed_list; *c_ptr; )
X	{   register char	*new_c_ptr = c_ptr;
X
X	    while (*new_c_ptr != ' ' && *new_c_ptr != '\0')
X		++new_c_ptr;
X	    while (*new_c_ptr == ' ')
X		*new_c_ptr++ = '\0';
X
X	    // make sure it's not in the hold list
X	    for (site_ptr = hold_list; site_ptr; site_ptr = site_ptr->site_next)
X		if ( ! strcmp (c_ptr, site_ptr->site_name))
X		{   site_ptr->site_seen = holding = 1;
X		    break;
X		}
X
X	    // if it's not in the hold list, add it to the feed list
X	    if (site_ptr == 0)
X	    {	sitelist	*new_entry = new sitelist;
X		new_entry->site_name = new_string (c_ptr);
X		//new_entry->site_seen = 1;
X		*site_ptr_ptr = new_entry;
X		site_ptr_ptr = &new_entry->site_next;
X		++site_count;
X	    }
X
X	    c_ptr = new_c_ptr;
X	}
X	*site_ptr_ptr = 0;
X
X	// write the article to the hold list (if necessary)
X	if (holding)
X	    write_hold (new_article_line);
X
X	// we *must* have some sites to feed
X	if ( ! site_count)
X	    return;
X
X	// start a batch
X	const char	**command_args = new char *[site_count + 2],
X			**args_ptr_ptr = command_args;
X	*args_ptr_ptr++ = base_cmd;
X	for (site_ptr = feed_list; site_ptr; site_ptr = site_ptr->site_next)
X	    *args_ptr_ptr++ = site_ptr->site_name;
X	*args_ptr_ptr = 0;
X	if ((ret = open_batch (command_args, max_batch_size)) < 0)
X	    FATAL (form ("open_batch() returns %d", ret));
X	delete command_args;
X	first_article = 0;
X    }	else	// ! first_article
X    {	// reset feed list
X	for (site_ptr = feed_list; site_ptr; site_ptr = site_ptr->site_next)
X	    site_ptr->site_seen = 0;
X
X	// check each site
X	while (*c_ptr)
X	{   register char	*new_c_ptr = c_ptr;
X	    while (*new_c_ptr != ' ' && *new_c_ptr != '\0')
X		++new_c_ptr;
X	    while (*new_c_ptr == ' ')
X		*new_c_ptr++ = '\0';
X
X	    // check hold list
X	    for (site_ptr = hold_list; site_ptr; site_ptr = site_ptr->site_next)
X		if ( ! strcmp (c_ptr, site_ptr->site_name))
X		{   site_ptr->site_seen = holding = 1;
X		    break;
X		}
X
X	    // if not in hold list, try the feed list
X	    if (site_ptr == 0)
X		for (site_ptr = feed_list;
X		     site_ptr;
X		     site_ptr = site_ptr->site_next
X		    )
X		    if ( ! strcmp (c_ptr, site_ptr->site_name))
X		    {	site_ptr->site_seen = 1;
X			break;
X		    }
X
X	    // if not in either list, just push it out for later
X	    if (site_ptr == 0)
X	    {	write_again (article_line);
X		return;
X	    }
X
X	    c_ptr = new_c_ptr;
X	}
X
X	// if feed list is not complete, just push it out for later
X	for (site_ptr = feed_list; site_ptr; site_ptr = site_ptr->site_next)
X	    if ( ! site_ptr->site_seen)
X	    {	write_again (article_line);
X		return;
X	    }
X
X	// write the article to the hold list (if necessary)
X	if (holding)
X	    write_hold (new_article_line);
X    }
X
X    // try to add the article to the current batch
X    if ((ret = send_article (new_article_line)) < 0)
X	FATAL (form ("send_article() returns %d", ret));
X
X    if (ret == 0)
X	add_to_log (new_article_line, feed_list);
X    else if (ret == 2)	// batch would've overflowed
X    {	++batch_finished;
X	if (holding)
X	{   for (site_ptr = feed_list;
X		 site_ptr;
X		 site_ptr = site_ptr -> site_next
X		)
X		// yuck ...
X		strcat (new_article_line, form (" %s", site_ptr->site_name));
X	    write_again (new_article_line);
X	} else
X	    write_again (article_line);
X    }
X}
X
X// This routine does everything necessary to feed news batches from a file.
X// The format of each line of the input file looks like:
X//	article_file
X// or:
X//	article_file site1 site2 ... siteN
X// In the first case, the site to be fed that article is assumed to be that
X// given by the name of the base_file (old batch format).
X// Parameters:
X//	base_file -> file containing articles to be batched
X//	hold_array -> list of sites NOT to be fed
X//	max_batch_size -> maximum size of batch (0 => unlimited)
X// Return value:
X//	exits on error
Xvoid	feed_news (const char *base_file,
X		   const char **hold_array,
X		   off_t max_batch_size
X		  )
X{   char	*base_input, *base_proc, *cp = rindex (base_file, '/'),
X		buffer [BUFFER_SIZE];
X    int		proc_fd;
X
X    // make this available to the routine that needs to know
X    ::max_batch_size = max_batch_size;
X
X    // in case it's not a MULTIHOST batch ...
X    default_site = cp ? cp + 1 : base_file;
X
X    // make our filenames
X    base_input = join_string (base_file, ".input");
X    base_proc = join_string (base_file, ".proc");
X    base_again = join_string (base_file, ".again");
X    base_hold = join_string (base_file, ".hold");
X    base_cmd = join_string (base_file, ".cmd");
X
X    // open the log file
X    open_log (base_file);
X
X    // error recovery from previous run ...
X    int			ret;
X    if ((ret = append_file (base_input, base_proc)) < 0)
X	SYS_FATAL (ret != -2 ? base_input : base_proc);
X
X    // prepare "hold" list
X    sitelist	**site_ptr_ptr = &hold_list;
X    for (const char **cpp = hold_array; *cpp; ++cpp)
X    {	sitelist	*new_entry = new sitelist;
X	new_entry->site_name = *cpp;
X	*site_ptr_ptr = new_entry;
X	site_ptr_ptr = &new_entry->site_next;
X    }
X    *site_ptr_ptr = 0;
X
X    // OK, time's up!  Any more articles arriving will have to wait until the
X    // next time ...
X    if (rename (base_file, base_input) == -1 && errno != ENOENT)
X	SYS_FATAL (form (rename_error, base_file, base_input));
X    if ((ret = append_file (base_input, base_proc)) < 0)
X	SYS_FATAL (ret != -2 ? base_input : base_proc);
X
X    // Main processing loop.
X    while ((proc_fd = open (base_proc, O_RDONLY, 0)) != -1)
X    {	auto_close auto_proc_fd (proc_fd);
X	fcntl (proc_fd, F_SETFD, 1);
X	istream	stream_proc (proc_fd, 0);
X	first_article = 1;
X
X	// give each line of the file to the article feeder
X	while ((ret = getline (stream_proc, buffer, BUFFER_SIZE)) == 0)
X	    feed_article (buffer);
X	if (ret != 1)
X	    fatal_input_stream_error (base_proc, ret);
X
X	// end of file ... finish current batch (if any)
X	if ( ! first_article && (ret = close_batch ()))
X	    FATAL (form ("close_batch() returns %d", ret));
X	sync_log ();
X
X	// tidy up the "again" file
X	if (fd_again != -1)
X	{   (*stream_again).flush ();
X	    if ( ! (*stream_again).good ())
X		fatal_output_stream_error (base_again);
X	    delete stream_again;
X	    close (fd_again);
X	    fd_again = -1;
X	}
X
X	// rename the "again" file to the "proc" file
X	if (rename (base_again, base_proc) == -1)
X	{   if (errno == ENOENT)
X	    {	if (unlink (base_proc) != -1)
X		    continue;
X		SYS_FATAL (base_proc);
X	    }
X	    else
X		SYS_FATAL (form (rename_error, base_again, base_proc));
X	}
X    }
X
X    if (errno != ENOENT)
X	SYS_FATAL (base_proc);
X
X    // tidy up the "hold" file
X    if (fd_hold != -1)
X    {	(*stream_hold).flush ();
X	if ( ! (*stream_hold).good ())
X	    fatal_output_stream_error (base_hold);
X	delete stream_hold;
X    }
X
X    // close the log file
X    close_log ();
X}
/
echo 'x - io.c'
sed 's/^X//' > io.c << '/'
X/* Written by Stephen J. Muir, Lancaster University, England, UK.
X *
X * EMAIL: stephen@comp.lancs.ac.uk
X * UUCP:  ...!mcvax!ukc!dcl-cs!stephen
X *
X * Version 1.0
X */
X
X# include "defs.h"
X
X// This routine prints an error message and exits.
X// Parameters:
X//	filename -> file on which the error occurred
X//	code -> cause of error
Xvoid	fatal_input_stream_error (const char *filename, int code)
X{   register char	*cp;
X    switch (code)
X    {	case -3:
X	    cp = "stream error";
X	    break;
X	case -2:
X	    cp = "incomplete last line";
X	    break;
X	case -1:
X	    cp = "line too long";
X	    break;
X	case 1:
X	    cp = "unexpected end of file";
X	    break;
X	default:
X	    cp = form ("something(code %d) is badly wrong", code);
X	    break;
X    }
X    FATAL (form ("%s: %s", filename, cp));
X}
X
X// This routine prints an error message and exits.
X// Parameters:
X//	filename -> file on which the error occurred
Xvoid	fatal_output_stream_error (const char *filename)
X{   FATAL (form ("%s: output stream error", filename));	}
X
X// This routine attempts to read the next line from the given input stream.
X// Parameters:
X//	infile -> input stream
X//	buffer -> where to put the line
X//	buffer_size -> size of the above
X// Return value:
X//	-3: stream failure (irrecoverable)
X//	-2: last line not terminated by a newline
X//	-1: line too long (irrecoverable)
X//	 0: ok
X//	 1: end of file
Xgetline (const istream& infile, char *buffer, int buffer_size)
X{   register char	c = '\0';
X    if (infile.get (buffer, buffer_size))
X    {	if (infile.get (c))
X	    return (c == '\n') ? 0 : -1;
X	return infile.eof () ? -2 : -3;
X    }
X    return infile.eof () ? 1 : -3;
X}
X
X// This routine attempts to copy the first file (if it exists) to the end of
X// the second (which is created if it doesn't exist).  Then, the first file is
X// removed.
X// Parameters:
X//	from -> name of input file
X//	to -> name of output file
X// Return Value:
X//	-3: error in unlinking input file
X//	-2: error writing output file
X//	-1: error reading input file
X//	 0: ok
X//	 1: no input file
X//	 2: output file was created
Xappend_file (const char *from, const char *to)
X{   register int	ret = 0, count, from_fd, to_fd;
X    if ((from_fd = open (from, O_RDONLY, 0)) == -1)
X	return (errno == ENOENT) ? 1 : -1;
X    auto_close auto_from_fd (from_fd);
X    if (access (to, F_OK) == -1)
X	ret = 2;
X    if ((to_fd = open (to, O_CREAT | O_WRONLY | O_APPEND, 0666)) == -1)
X	return -2;
X    auto_close auto_to_fd (to_fd);
X    char	buffer [BUFFER_SIZE];
X    while ((count = read (from_fd, buffer, BUFFER_SIZE)) > 0)
X	if (write (to_fd, buffer, count) != count)
X	    return -2;
X    if (count < 0 || close (from_fd) == -1)
X	return -1;
X    if (close (to_fd) == -1)
X	return -2;
X    if (unlink (from) == -1)
X	return -3;
X    return ret;
X}
/
echo 'x - log.c'
sed 's/^X//' > log.c << '/'
X/* Written by Stephen J. Muir, Lancaster University, England, UK.
X *
X * EMAIL: stephen@comp.lancs.ac.uk
X * UUCP:  ...!mcvax!ukc!dcl-cs!stephen
X *
X * Version 1.0
X */
X
X# include "defs.h"
X# include "config.h"
X
Xstatic char	*base_log;
Xstatic int	log_fd, log_size = -1;
Xstatic ostream	*stream_log;
X
X// This routine puts a date stamp on the log file, if this hasn't been done
X// yet.  It also creates the output stream for it (if necessary).
Xstatic void	start_log ()
X{   static short	log_started;
X    if (log_started)
X	return;
X    ++log_started;
X    if ( ! stream_log)
X	stream_log = new ostream (log_fd);
X    struct timeval	tv;
X    struct timezone	tz;
X    gettimeofday (&tv, &tz);
X    struct tm		*tp = localtime (&tv.tv_sec);
X    char		*ap = asctime (tp),
X			*tzn = timezone (tz.tz_minuteswest, tp->tm_isdst);
X    *stream_log << form (":%lu:%.20s%s%s",
X			 tv.tv_sec,
X			 ap,
X			 tzn ? tzn : "",
X			 ap + 19
X			);
X}
X
X// This routine removes those articles expected to be expired from the log file
X// and returns with the log file opened (for appending) and locked.
X// Parameters:
X//	base_file -> file containing articles to be batched
X// Return value:
X//	exits on error
Xvoid	open_log (const char *base_file)
X{   if ((log_fd = open (base_log = join_string (base_file, ".log"),
X			O_CREAT | O_RDWR | O_APPEND,
X			0666
X		       )
X	) == -1
X       )
X	SYS_FATAL (base_log);
X    fcntl (log_fd, F_SETFD, 1);
X    if (flock (log_fd, LOCK_EX | LOCK_NB) == -1)
X	FATAL (form ("previous batching for \"%s\" is still running", base_file)
X	      );
X# ifdef LOG_EXPIRE_SECONDS
X    istream		stream_old_log (log_fd);
X    char		buffer [BUFFER_SIZE];
X    register int	ret;
X    if (ret = getline (stream_old_log, buffer, BUFFER_SIZE))
X    {	if (ret == 1)	// empty log file
X	    return;
X	fatal_input_stream_error (base_log, ret);
X    }
X    if (buffer [0] != ':')
X    {	WARNING ("bad log format -- not truncated");
X	return;
X    }
X    long	expire_time = time (0) - LOG_EXPIRE_SECONDS;
X    if ((atol (&buffer [1]) - expire_time) > 0)
X	return;
X
X    // we don't want the old log anymore
X    auto_close auto_log_fd (log_fd);
X    char	*base_newlog = join_string (base_file, ".newlog");
X    if ((log_fd = open (base_newlog,
X			O_CREAT | O_TRUNC | O_WRONLY | O_APPEND,
X			0666
X		       )
X	) == -1
X       )
X	SYS_FATAL (base_newlog);
X    fcntl (log_fd, F_SETFD, 1);
X    if (flock (log_fd, LOCK_EX | LOCK_NB) == -1)
X	SYS_FATAL (base_newlog);
X    stream_log = new ostream (log_fd);
X    short	transferring = 0;
X    while ((ret = getline (stream_old_log, buffer, BUFFER_SIZE)) == 0)
X    {	if ( ! transferring &&
X	    buffer [0] == ':' &&
X	    (atol (&buffer [1]) - expire_time) > 0
X	   )
X	    ++transferring;
X	if (transferring)
X	    *stream_log << buffer << "\n";
X    }
X    if (ret != 1)
X	fatal_input_stream_error (base_log, ret);
X
X    (*stream_log).flush ();
X    if ( ! (*stream_log).good ())
X	fatal_output_stream_error (base_newlog);
X    if (rename (base_newlog, base_log) == -1)
X	SYS_FATAL (form (rename_error, base_newlog, base_log));
X# endif LOG_EXPIRE_SECONDS
X}
X
X// This routine adds an article, together with the list of sites it was sent
X// to, to the log file.
Xvoid	add_to_log (const char *article_line, const sitelist *fed_sites)
X{   register const sitelist	*site_ptr;
X    start_log ();
X    *stream_log << article_line;
X    for (site_ptr = fed_sites; site_ptr; site_ptr = site_ptr->site_next)
X	*stream_log << " " << site_ptr->site_name;
X    *stream_log << "\n";
X}
X
X// This routine closes the log file.
Xvoid	close_log ()
X{
X# ifdef ALWAYS_STAMP_LOG
X    start_log ();
X# endif ALWAYS_STAMP_LOG
X    if (stream_log)
X    {	(*stream_log).flush ();
X	if ( ! (*stream_log).good ())
X	    fatal_output_stream_error (base_log);
X	delete stream_log;
X    }
X}
X
X// This routine attempts to flush all data to the log file and remember its size
X// so that the next routine can truncate it if necessary.
Xvoid	sync_log ()
X{   if ( ! stream_log)
X	FATAL ("sync_log(): log not open");
X    (*stream_log).flush ();
X    if ( ! (*stream_log).good ())
X	fatal_output_stream_error (base_log);
X    if ((log_size = lseek (log_fd, 0, L_INCR)) == -1)
X	SYS_WARNING ("sync_log()");
X}
X
X// This routine attempts to truncate the log to the size determined by the
X// previous routine.
Xvoid	reset_log ()
X{   if (stream_log && log_size != -1)
X	if (ftruncate (log_fd, log_size) == -1)
X	    SYS_WARNING ("reset_log()");
X}
/
echo 'x - main.c'
sed 's/^X//' > main.c << '/'
X/* Written by Stephen J. Muir, Lancaster University, England, UK.
X *
X * EMAIL: stephen@comp.lancs.ac.uk
X * UUCP:  ...!mcvax!ukc!dcl-cs!stephen
X *
X * Version 1.0
X */
X
X# include "defs.h"
X# include "config.h"
X
Xstatic void	new_handler ()
X{   FATAL ("out of memory");
X}
X
X// This program does a batched feed of several sites simultaneously.  After
X// changing directory to BATCH_OUT_DIR (in feed_news()), the sites in base_file
X// are fed.  If any (optional) hold sites are given, they are not fed but are
X// saved for a future run.  This could be done if, say, those sites are down
X// for an extended period or perhaps ...
Xmain (int argc, char **argv)
X{   register int	fd;
X    register off_t	max_size = (off_t)DEFAULT_MAX_SIZE;
X    _new_handler = &new_handler;
X
X    // just in case we've been given a duff environment
X    while ((fd = open ("/dev/null", O_RDWR, 0)) != -1 && fd < 3)
X	;
X    if (fd != -1)
X	close (fd);
X    if (argc < 2 || (**++argv == '-' && argc < 3))
X    {	cerr << "usage: newsfeed [-max_size] base_file [list_of_hold_sites]\n";
X	exit (1);
X    }
X# ifndef DEBUG
X# ifdef NICENESS
X    if (setpriority (PRIO_PROCESS, getpid (), NICENESS) == -1)
X	SYS_WARNING ("setpriority()");
X# endif NICENESS
X# ifdef NEWSGID
X    if (setgid (NEWSGID) == -1)
X	SYS_WARNING ("setgid()");
X# endif NEWSGID
X# ifdef NEWSUID
X    if (setuid (NEWSUID) == -1)
X	SYS_WARNING ("setuid()");
X# endif NEWSUID
X    umask (022);	// We are (usually) not invoked by a user.
X# ifdef BATCH_OUT_DIR
X    char	*batch_out_dir = BATCH_OUT_DIR;	// saving space !!!
X    // go to where it's at!
X    if (chdir (batch_out_dir) == -1)
X	SYS_FATAL (batch_out_dir);
X# endif BATCH_OUT_DIR
X# endif DEBUG
X
X    if (**argv == '-')
X	max_size = (off_t)atol (*argv++ + 1);
X    feed_news (*argv, argv + 1, max_size);
X    exit (0);
X}
/
echo 'x - misc.c'
sed 's/^X//' > misc.c << '/'
X/* Written by Stephen J. Muir, Lancaster University, England, UK.
X *
X * EMAIL: stephen@comp.lancs.ac.uk
X * UUCP:  ...!mcvax!ukc!dcl-cs!stephen
X *
X * Version 1.0
X */
X
X# include "defs.h"
X# include "config.h"
X
X# if !defined(DEBUG) && defined(ERROR_LOG)
Xstatic int	error_fd;
X# endif
Xstatic ostream	*error_stream;
X
Xconst char	*rename_error = "rename(%s,%s)";
X
X// This routine prints an error message (and may exit).
X// Parameters:
X//	string -> error message
X//	perror_style -> adds a system error message by looking up "errno"
X//	fatal -> exits at end
X// Return value:
X//	exits if "fatal" is set or on error
Xvoid	error (const char *string, int perror_style, int fatal)
X{
X# if !defined(DEBUG) && defined(ERROR_LOG)
X    char	*error_log = ERROR_LOG;	// saving space !!!
X    if ( ! error_stream)
X    {	if ((error_fd = open (error_log, O_WRONLY | O_APPEND, 0)) != -1)
X	{   fcntl (error_fd, F_SETFD, 1);
X	    error_stream = new ostream (error_fd);
X	} else
X	    perror (error_log);
X    }
X# else
X    error_stream = &cerr;
X# endif
X    if (error_stream)
X    {	*error_stream << "newsfeed: "
X		      << (fatal ? "fatal: " : "warning: ")
X		      << string
X		      << (perror_style ? ": " : "")
X		      << (perror_style ? (errno < sys_nerr ? sys_errlist [errno]
X							   : "Unknown error"
X					 )
X				       : ""
X			 )
X		      << "\n";
X	(*error_stream).flush ();
X    }
X    if (fatal)
X    {	kill_batch ();
X	reset_log ();
X	exit (1);
X    }
X}
X
X// This routine returns a copy of its parameter.
Xchar	*new_string (const char *old_string)
X{   char	*string_ptr = new char [strlen (old_string) + 1];
X    strcpy (string_ptr, old_string);
X    return string_ptr;
X}
X
X// This routine returns the concatenation of its first and second parameter.
Xchar	*join_string (const char *first_string, const char *second_string)
X{   return new_string (form ("%s%s", first_string, second_string));	}
/
echo 'x - newsfeedlist.sh'
sed 's/^X//' > newsfeedlist.sh << '/'
X#! /bin/sh
Xfor i in $*
Xdo
X	case $i in
X	-h)	hold=;
X		continue;;
X	-h*)	hold="$hold `echo x$i|sed -e s/...//`"
X		continue;;
X	-)	size=;
X		continue;;
X	-*)	size=$i;
X		continue;;
X	//*)	continue;;
X	esac
X	/usr/lib/news/newsfeed $size $i $hold
Xdone
/
echo 'x - newsfeed.man'
sed 's/^X//' > newsfeed.man << '/'
X.TH NEWSFEED 1 "12 November 1986"
X.SH NAME
Xnewsfeed \- simultaneous multi-site news feeder
X.SH SYNOPSIS
X.B newsfeed
X[-max_size] base_file [list_of_hold_sites]
X.SH DESCRIPTION
X.I newsfeed
Xtakes a list of news articles (with sitenames) in file
X.I base_file
Xand batches them simultaneously for the given sites after changing to
Xthe batching directory (whatever was compiled in).
XEach line is a set of space\-separated strings,
Xthe first string being the full pathname of a news article.
XThe remaining strings are sites to which that news article is being fed.
XIf there are no sites, the last component of
X.I base_file
Xis used (old batch format).
X.PP
XIf the
X.I max_size
Xparameter is given, each batch is limited to that maximum size
X(unless a single article is greater than that size).
XThus, a maximum batch size of 1 causes each article to be contained in its own
Xbatch.
XA maximum batch size of 0 means there is no upper limit.
XThe default is whatever is compiled in.
X.PP
XAny
X.I hold_sites
Xgiven are saved to a file for later processing.
XThis may be used, for example, when those sites are down for extended periods.
X.SH FILES
X.ta \w'base_file.newlog  'u
Xbase_file	input file
X.br
Xbase_file.input	temporary file for error recovery
X.br
Xbase_file.proc	batch being processed
X.br
Xbase_file.again	batch to be reprocessed
X.br
Xbase_file.cmd	command to queue the batch
X.br
X	(takes a list of sites as parameters)
X.br
Xbase_file.log	log file
X.br
Xbase_file.newlog	temporary log file
X.br
Xbase_file.hold	list of held articles and their sites
X.SH "SEE ALSO"
Xnewsfeedlist(1)
X.SH AUTHOR
XStephen J. Muir, Lancaster University, England, UK
/
echo 'x - newsfeedlist.man'
sed 's/^X//' > newsfeedlist.man << '/'
X.TH NEWSFEEDLIST 1 "12 November 1986"
X.SH NAME
Xnewsfeedlist \- invoke news feeder repeatedly
X.SH SYNOPSIS
X.B newsfeedlist
X[arguments]
X.SH DESCRIPTION
X.I newsfeedlist
Xtakes a list of arguments
Xand calls the simultaneous multi-site news feeder with each one in turn.
X.PP
XInterspersed with the arguments may be any of the following options:
X.TP 8
X.B \-num
Xset the maximum batch size
X.TP
X.B \-
Xrestore the maximum batch size to the default
X.TP
X.B \-hsite
Xadd
X.B site
Xto the list of
X.I hold
Xsites
X.TP
X.B -h
Xdelete the list of
X.I hold
Xsites
X.TP
X.B //
Xany argument beginning with this string is ignored
X.SH "SEE ALSO"
Xnewsfeed(1)
X.SH AUTHOR
XStephen J. Muir, Lancaster University, England, UK
/
echo 'Part 01 of pack.out complete.'
exit
----------------------------------- Cut Here ----------------------------------
-- 
EMAIL:	stephen@comp.lancs.ac.uk	| Post: University of Lancaster,
UUCP:	...!mcvax!ukc!dcl-cs!stephen	|	Department of Computing,
Phone:	+44 524 65201 Ext. 4120		|	Bailrigg, Lancaster, UK.
Project:Alvey ECLIPSE Distribution	|	LA1 4YR

