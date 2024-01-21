Subject: v06i018:  missing files from Apollo pacman (pacman.p.h)
Newsgroups: mod.sources
Approved: rs@mirror.UUCP

Submitted by: cca!decvax!decwrl!imagen!geof (Geof Cooper)
Mod.sources: Volume 6, Issue 18
Archive-name: pacman.p.h

Sorry, this was my first attempt at automatically creating a shell archive
from the makefile, and I forgot to add the include files.  Here are the
missing files.  Please update the mod.sources distribution.
    - Geof

#!/bin/sh
# This is a shell archive.  Remove anything before this line,
# then unpack it by saving it in a file and typing "sh file".
# Contents:  board.ins.pas fig.ins.pas
 
echo x - board.ins.pas
sed 's/^XX//' > "board.ins.pas" <<'@//E*O*F board.ins.pas//'

XX{ **** INSERT FILE FOR PACMAN_BOARD MODULE **** }
XX{ Written January, 1985 by Geoffrey Cooper                                  }
XX{ Copyright (C) 1985, IMAGEN Corporation                                    }
XX{ This software may be duplicated in part of in whole so long as [1] this   }
XX{ notice is preserved in the copy, and [2] no financial gain is derived     }
XX{ from the copy.  Copies of this software other than as restricted above    }
XX{ may be made only with the consent of the author.                          }

XXTYPE
XX    board_$direction = 0..num_orientations-1;
XX    board_$elt = (wall, ecor, dcor, scor);

XXPROCEDURE board_$init(screen: gpr_$bitmap_desc_t;
XX                      screen_size: gpr_$offset_t;
XX                      pacs: integer); EXTERN;

XXPROCEDURE board_$reinit; EXTERN;

XXPROCEDURE board_$get_num_dots(OUT dots, sdots: Integer); EXTERN;

XXPROCEDURE board_$draw_board; EXTERN;

XXPROCEDURE board_$try_pac_position(IN OUT pos: gpr_$position_t); EXTERN;

XXPROCEDURE board_$can_turn(IN OUT pos: gpr_$position_t;
XX                          IN     new_dir: board_$direction;
XX                          OUT    turn: boolean); EXTERN;

XXPROCEDURE board_$clear_dot(pos: gpr_$position_t; 
XX                           OUT wasdot, special: boolean); EXTERN;


XXPROCEDURE board_$show_score(newscore, newnumpacs: integer); extern;

@//E*O*F board.ins.pas//
chmod u=rw,g=rw,o=rw board.ins.pas
 
echo x - fig.ins.pas
sed 's/^XX//' > "fig.ins.pas" <<'@//E*O*F fig.ins.pas//'
XX{ ******************************************************** }
XX{ ******************************************************** }
XX{ *********                                      ********* }
XX{ *********    FIG.INS.PAS                       ********* }
XX{ *********                                      ********* }
XX{ *********    Insert file for MOBILE_FIGURE     ********* }
XX{ *********    Module.                           ********* }
XX{ *********                                      ********* }
XX{ *********    Written 12/24/84 by Geof Cooper   ********* }
XX{ *********                                      ********* }
XX{ ******************************************************** }
XX{ ******************************************************** }
XX{ Copyright (C) 1984, 1985, IMAGEN Corporation                              }
XX{ This software may be duplicated in part of in whole so long as [1] this   }
XX{ notice is preserved in the copy, and [2] no financial gain is derived     }
XX{ from the copy.  Copies of this software other than as restricted above    }
XX{ may be made only with the consent of the author.                          }
XX                                                  
XXCONST
XX    num_orientations = 4;   { number of orientations of figure }
XX    guage = 16;

XX    { orientations: set up so orientation*360/num_or. = angle }
XX    or$right         = 0;
XX    or$up            = 1;
XX    or$left          = 2;
XX    or$down          = 3;

XXTYPE
XX    fig_$orientations = array[0..num_orientations-1] of gpr_$bitmap_desc_t;
XX    fig_$rep = RECORD
XX                { bitmaps describing figure in all orientations }
XX                figures     : fig_$orientations;

XX                { position on screen }
XX                position    : gpr_$position_t;

XX                { orientation selects one of above }
XX                orientation : 0..num_orientations-1;
XX    
XX                { velocity in direction of orientation, in pixels/unit time }
XX                velocity    : PInteger;
XX              END;
XX    fig_$t = ^fig_$rep;

XXPROCEDURE fig_$alloc_fig_bitmaps( OUT f: fig_$orientations ); EXTERN;

XXPROCEDURE fig_$create( IN figures: fig_$orientations;
XX                       IN pos_x, pos_y: Integer;
XX                       OUT r: fig_$t ); EXTERN;

XXPROCEDURE fig_$refresh( IN r: fig_$t ); EXTERN;

XXPROCEDURE fig_$move( IN r: fig_$t;
XX                     IN pos: gpr_$position_t ); EXTERN;
XX{ ASSUMES that raster op is XOR }


XXPROCEDURE fig_$elapse_time( IN r: fig_$t;
XX                            IN t: PInteger;
XX                            OUT newpos: gpr_$position_t ); EXTERN;

XXPROCEDURE fig_$turn( IN r: fig_$t; IN orient: PInteger ); EXTERN;

XXPROCEDURE fig_$set_velocity( IN r: fig_$t;
XX                             IN velocity: PInteger ); EXTERN;

XXFUNCTION fig_$coincident( IN r1, r2: fig_$t ): BOOLEAN;
XX    EXTERN;
@//E*O*F fig.ins.pas//
chmod u=rw,g=rw,o=rw fig.ins.pas
 
echo Inspecting for damage in transit...
temp=/tmp/sharin$$; dtemp=/tmp/sharout$$
trap "rm -f $temp $dtemp; exit" 0 1 2 3 15
cat > $temp <<\!!!
      35     143    1333 board.ins.pas
      69     299    2803 fig.ins.pas
     104     442    4136 total
!!!
wc  board.ins.pas fig.ins.pas | sed 's=[^ ]*/==' | diff -b $temp - >$dtemp
if test -s $dtemp
then echo "Ouch [diff of wc output]:" ; cat $dtemp
else echo "No problems found."
fi
exit 0
