From: genrad!ukma!david (David Herron, NPR Lover)
Subject: uucp info from LOGFILE (awk script)
Newsgroups: mod.sources
Approved: jpn@panda.UUCP

Mod.sources:  Volume 3, Issue 15
Submitted by: ukma!david (David Herron)


Here's a source I just wrote this evening.  It's short and self-explanatory ---

--- David Herron
--- ARPA-> ukma!david@ANL-MCS.ARPA
--- UUCP-> {ucbvax,unmvax,boulder,oddjob}!anlams!ukma!david
---        {ihnp4,decvax,ucbvax}!cbosgd!ukma!david

Hackin's in me blood.  My mother was known as Miss Hacker before she married!

-------------------------------------------------------------
# uucp.times.awk -- read a uucp LOGFILE and find out how long
# we spent talking to particular places.  (Also, remembers if
# the time spent was our call or their call).
#
# This is nice for: 1) Knowing when you made long distance
# calls and where to, 2) knowing how much of the load between
# you and some sites you're carrying.
#
#
# This works with the UUCP log file format produced by the
# uucp delivered with BRL Release 3.  (i.e. 4.2BSD, i.e. that
# *extremely* hacked up conglomeration of uucp's that prompted
# the writing of honey-danber). 
#
#
# USAGE
#	awk -f uucp.times.awk /usr/spool/uucp/LOGFILE
#
# Actually -- I would suggest saving LOGFILE somewhere and make
# sure uucico is no longer writing to it.  This way you're sure
# that the data generated is valid.  What I do here is:
#
#	set `date`
#	tag=$2.$7
#	cd /usr/spool/uucp
#	mv LOGFILE OLD/LOGFILE.${tag}
#	compress OLD/LOGFILE.${tag}
#	uncompress OLD/LOGFILE.${tag}
#	awk -f /usr/lib/uucp/uucp.times.awk OLD/LOGFILE.${tag}
#
# Somehow, compress waits until nobody is using the file before it
# compresses it.  This is nice and convenient.
#
#
# AUTHOR
#	David Herron (NPR lover)
#	cbosgd!ukma!david
#	University of Kentucky, Computer Science

BEGIN	{
	# states
	idle = 0; calling = 1; uscall = 2; themcall = 3;
	true = 1; false = 0

	# This ignores log entries for these systems.  They're
	# all local calls so we don't care how much time we 
	# spend talking to them.
	ignore["ukgs"] = true
	ignore["ukmb"] = true
	ignore["ukmc"] = true
	ignore["ukmd"] = true
	ignore["ukme"] = true
	ignore["ukmf"] = true
	ignore["ma3b2a"] = true
	ignore["ma3b2b"] = true
	ignore["ukecc"] = true
	ignore["ecc1"] = true
	ignore["ukengr4"] = true
	ignore["ukpa"] = true
	ignore["mason"] = true
	ignore["pcb"] = true
	# This one only calls us ... and, we don't really
	# care how much he spends ... That's his problem
	ignore["hasmed"] = true
	}

# We're calling some place, and the call part has actually worked.
# 1) Record their name in the master list.
# 2) Remember that we're placing the call.

$4 == "SUCCEEDED" && $5 == "(call" {
	if (ignore[$2] != true)
		state[$2] = calling
	else
		state[$2] = idle
	}

# A call succeeded.  Either they called us or we called them.
# state[$2] tells us who is doing the calling.
# Have to remember the time.

$4 == "OK" && $5 == "(startup)" {
	if (ignore[$2] != true) {
		startime[$2] = $3
		if (state[$2] == calling) {
			printf("call\tout\t%s\t%s\n", $2, $3)
			state[$2] = uscall
		}
		else {
			printf("call\tin\t%s\t%s\n", $2, $3)
			state[$2] = themcall
		}
	}
	}

# Our outgoing call failed.  Throw away our information about the call.

$4 == "TIMEOUT" {
	state[$2] = idle
	}

# A call finished either successfully or unsuccessfully.
# Have to add in the time to the appropriate sum.
#
# It would be "hard" to calculate the time correctly.  So, I'm using
# a heuristic here to make it easy.  I assume that no phone call is
# going to last for longer than 1 day.  I calculate the time
# for the ending and beginning of the call, and if it's negative
# I add 24 hours to it.
#
# I know ... groady to the max, buuut...

($4 == "OK" || $4 == "FAILED") && $5 == "(conversation" {
	if (ignore[$2] != true) {
		printf("done\t(%s)\t%s\t%s\n", $4, $2, $3)
		time = 0
		# get time spent into "time"
		# Time format is: "(mon/day-hr:min-pid)"
		n = split($3, nn, "-")
		n = split(nn[2], hrmin, ":")
		tend = (hrmin[1]*60) + hrmin[2]
		n = split(startime[$2], nn, "-")
		n = split(nn[2], hrmin, ":")
		tbeg = (hrmin[1]*60) + hrmin[2]

		time = tend - tbeg
		if (time < 0)
			time += (24*60)

		if (state[$2] == uscall)
			ourtime[$2] += time
		else
			theirtime[$2] += time
	}
	}

# All that's left to do now is to feed the chickens and go home

END	{
	for (i in ourtime)
		printf("%s -- ourtime = %d\ttheirtime = %d\n", \
			i, ourtime[i], theirtime[i])
	}

