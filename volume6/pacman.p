/* Written  8:43 am  Jun 19, 1986 by sources-request@mirror.UUCP in mirror:mod.sources */
/* ---------- "v06i008:  Apollo Pacman-like game (" ---------- */
Submitted by: pyramid!decwrl!imagen!geof (Geof Cooper)
Mod.sources: Volume 6, Issue 8
Archive-name: pacman.p

The files in this distribution implement a Pacman-like game on Apollo
nodes.  The programs probably work on SR8, but have only be tested with
SR9.  Aegis calls are used exclusively (this was my program to learn
Apollo Pascal and Aegis).

#!/bin/sh
: "This is a shell archive, meaning:                              "
: "1. Remove everything above the #! /bin/sh line.                "
: "2. Save the resulting test in a file.                          "
: "3. Execute the file with /bin/sh (not csh) to create the files:"
: "	README"
: "	board.mod.pas"
: "	fig.mod.pas"
: "	pac.pas"
: "	pac_refresh.pas"
: "This archive created:  Thu Jun 12 11:11:59 PDT 1986 "
echo file: README
sed 's/^X//' >README << 'END-of-README'
X    APOLLO PAC Distribution
X    June, 1986
X
XThe files in this distribution implement a Pacman-like game on apollo
Xnodes.  The programs probably work on SR8, but have only be tested with
XSR9.  Aegis calls are used exclusively (this was my program to learn
Xapollo pascal and aegis).
X
XThe game is run by typing "pac" (one needs a graphics capable window
Xto run it).  The program runs in the window, and stops when the window
Xis obscured.  The screen is correctly redrawn when the window re-emerges,
Xand the game continues normally.
X
XThe game is similar to pacman.  One pac runs around a maze, pursued by
Xpointed objects called "nasties".  The pac scores points by eating the
Xdots in the maze.  When all the dots have been eaten, the screen is
Xrefreshed, an additional nasty appears, and all existing nasties get
Xone pixel-per-tick faster.  The pac's relative to the nasties may be
Xcontrolled.  A faster pac is harder to maneuver.  Also, the tick time
Xmay be modified to speed up or slow down the entire game.
X
XThe pac is steered using the arrow keys.  The keys have the effect of
Xqueuing a turn in the desired direction. The turn happens when the pac
Xis next able to make the turn.  There can only be one turn queued;
Xsubsequent key pushing changes the queued value.  This technique of
Xsteering makes it possible to steer the pac very quickly with a little
Xpractise, since the keys do not have to be pushed at the exact moment
Xthe pac is passing a corridor to effect a turn.
X
XThe sources are written in apollo pascal, and make use of apollo-pascal
Xlanguage extensions and system utilities.  In particular, all graphics
Xis done using GPR, the apollo graphics package.  Some of the keys used
Xare only on Version2 keyboards.  The next-window key is disabled because
XI kept hitting it and losing the game.
X
XThe program is a good example of a simple program that uses GPR.  It is
Xalso a good example of a simple real-time program for aegis.
X
X- Geof Cooper
X  IMAGEN Corporation
END-of-README
echo file: board.mod.pas
sed 's/^X//' >board.mod.pas << 'END-of-board.mod.pas'
XMODULE pacman_board;
X
X{ Written January, 1985 by Geoffrey Cooper                                  }
X{ program for creating a pacman board
X  needed improvements:
X    - ability to save a board for later re-editing
X    - ability to better define size of board - middle button?
X    - ability to set SDOTS as well as dots.}
X{ Copyright (C) 1985, IMAGEN Corporation                                    }
X{ This software may be duplicated in part of in whole so long as [1] this   }
X{ notice is preserved in the copy, and [2] no financial gain is derived     }
X{ from the copy.  Copies of this software other than as restricted above    }
X{ may be made only with the consent of the author.                          }
X
X%include '/sys/ins/base.ins.pas';
X%include '/sys/ins/error.ins.pas';
X%include '/sys/ins/kbd.ins.pas';
X%include '/sys/ins/gpr.ins.pas';
X%include '/sys/ins/vfmt.ins.pas';
X%include '/sys/ins/pgm.ins.pas';
X%include '/sys/ins/pad.ins.pas';
X
XDEFINE 
X    board_$init, board_$reinit,
X    board_$get_num_dots, board_$draw_board, board_$try_pac_position,
X    board_$can_turn, board_$clear_dot, board_$show_score;
X
X%include 'fig.ins.pas';
X%include 'board.ins.pas';
X
XCONST
X    board_width_x =    31;
X    board_width_y =    34;
X
X    halfguage = guage div 2;
X
X    score_x = guage;
X    score_y = (board_width_y+1) * guage;
X
X    pac_x = guage;
X    pac_y = score_y + 16;
X
XTYPE
X    board_$config = array [0..board_width_x-1, 0..board_width_y-1]
X                          of board_$elt;
X
XVAR
X    wall_bm     : gpr_$bitmap_desc_t;
X    dot_bm      : gpr_$bitmap_desc_t;
X    sdot_bm     : gpr_$bitmap_desc_t;
X
X    board_numdcor: integer;
X    board_numscor: integer;
X
X    score       : integer;
X    numpacs     : integer;
X    w           : gpr_$window_t;
X    status      : status_$t;
X
X    board       : board_$config;
X    board_init  : board_$config := [
X    [ wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall],
X    [ wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, dcor, wall],
X    [ wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, wall, dcor, wall],
X    [ wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, wall, wall, wall, wall, wall, dcor, dcor, wall, wall, dcor, wall],
X    [ wall, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, dcor, scor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, wall, dcor, wall],
X    [ wall, dcor, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, dcor, wall, wall, dcor, wall],
X    [ wall, dcor, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, dcor, wall],
X    [ wall, dcor, wall, dcor, scor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, dcor, wall],
X    [ wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, scor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, dcor, wall, wall, wall, dcor, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, dcor, dcor, wall, wall, dcor, wall, dcor, wall, dcor, dcor, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, wall, wall, wall, wall, dcor, wall, dcor, wall, dcor, wall, dcor, dcor, dcor, dcor, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, dcor, wall, wall, dcor, wall, wall, wall, wall, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, dcor, wall, wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, dcor, wall, dcor, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, dcor, wall, dcor, wall, dcor, wall, dcor, dcor, dcor, dcor, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, dcor, wall, dcor, wall, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall, dcor, wall, dcor, dcor, dcor, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, dcor, wall, dcor, wall, wall, wall, wall, wall, dcor, wall, wall, wall, wall, dcor, wall],
X    [ wall, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, dcor, wall],
X    [ wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall, wall]
X    ];
X
X
XPROCEDURE board_$fail(r: integer);
Xbegin
X    gpr_$terminate(false, status);
X    writeln('board_$fail(', r:0, ')');
X    pgm_$exit;
Xend;
X
XPROCEDURE board_$print_integer(n: integer; IN ctl: string; x, y: integer);
XVAR
X    text: string;
X    nlong: integer32;
X    textlen: integer;
X    status: status_$t;
X    dummy: integer32;
XBEGIN
X    nlong := n;
X    vfmt_$encode2(ctl, text, 80, textlen, nlong, dummy);
X    gpr_$move(x, y, status);
X    gpr_$text(text, textlen, status);
XEND;
X
XPROCEDURE board_$draw_board;
XVAR
X    x, y: INTEGER;
X    bm: gpr_$bitmap_desc_t;
X    pos: gpr_$position_t;
XBEGIN
X    gpr_$set_raster_op(0, 3, status);
X    gpr_$clear(0, status);
X    for x := 0 to board_width_x - 1 do
X      begin
X        pos.x_coord := x * guage;
X        for y := 0 to board_width_y -1 do
X          begin
X            if board[x, y] <> ecor then
X              begin
X                case board[x, y] of
X                    wall: bm := wall_bm;
X                    dcor: bm := dot_bm;
X                    scor: bm := sdot_bm
X                end;
X                pos.y_coord := y * guage;
X                gpr_$bit_blt(bm, w, 0, pos, 0, status);
X              end
X          end
X      end;
X
X    board_$print_integer(score, 'score: %5sd%$', score_x, score_y);
X    board_$print_integer(numpacs, 'pacs left: %5sd%$', pac_x, pac_y);
X
X    gpr_$set_raster_op(0, 6, status);
XEND;
X
XPROCEDURE board_$reinit;
XBEGIN
X    score := 0;
X    board := board_init;
X    board_$draw_board;
XEND;
X
XPROCEDURE board_$get_num_dots(* OUT dots, sdots: Integer *);
XBEGIN
X    dots := board_numdcor;
X    sdots := board_numscor;
XEND;
X
XPROCEDURE board_$init(* screen: gpr_$bitmap_desc_t;
X                        screen_size: gpr_$offset_t,
X                        pacs: integer *);
XVAR
X    attr: gpr_$attribute_desc_t;
X    size: gpr_$offset_t;
X    point: gpr_$position_t;
X    x, y: integer;
XBEGIN
X    board_numscor := 0;
X    board_numdcor := 0;
X    for x := 0 to board_width_x-1 do
X        for y := 0 to board_width_y-1 do
X            case board_init[x, y] of
X              scor: board_numscor := board_numscor + 1;
X              dcor: board_numdcor := board_numdcor + 1;
X              wall:;
X              ecor:
X            end;
X    screen_size.x_size := screen_size.x_size div guage;
X    screen_size.y_size := screen_size.y_size div guage;
X    if screen_size.x_size < board_width_x then
X        {board_$fail(1)};
X    if screen_size.y_size < board_width_y then
X        {board_$fail(2)};
X    gpr_$allocate_attribute_block(attr, status);
X    size.x_size := guage;
X    size.y_size := guage;
X    w.window_base.x_coord := 0;
X    w.window_base.y_coord := 0;
X    w.window_size := size;
X    gpr_$allocate_bitmap(size, 0, attr, wall_bm, status);
X    gpr_$set_bitmap(wall_bm, status);
X    gpr_$clear(1, status);
X
X    gpr_$allocate_bitmap(size, 0, attr, dot_bm, status);
X    gpr_$set_bitmap(dot_bm, status);
X    point.x_coord := halfguage;
X    point.y_coord := halfguage;
X    x := guage div 8;
X    if x = 0 then x := 1;
X    gpr_$circle_filled(point, x, status);
X
X    gpr_$allocate_bitmap(size, 0, attr, sdot_bm, status);
X    gpr_$set_bitmap(sdot_bm, status);
X    gpr_$set_raster_op(0, 6, status);
X    x := guage div 3;
X    if x = 0 then x := 1;
X    gpr_$circle_filled(point, x, status);
X    gpr_$set_fill_value(0, status);
X    x := guage div 5;
X    if x = 0 then x := 1;
X    gpr_$circle_filled(point, x, status);
X    gpr_$set_fill_value(1, status);
X    
X    gpr_$set_bitmap(screen, status);
X
X    score := 0;
X    numpacs := pacs;
X    board := board_init
XEND;
X
XFUNCTION board_$entierGuage(i: integer): integer;
XBEGIN
X    board_$entierGuage := i - (i mod guage);
XEND;
X
X{ modifies a position to avoid hitting a wall }
XPROCEDURE board_$try_pac_position(* IN OUT pos: gpr_$position_t *);
XVAR
X    x, y: integer;
X    x0, y0: integer;
X    test: integer;
X    extrem: integer;
XBEGIN
X    if pos.x_coord < 0 then pos.x_coord := 0;
X    if pos.y_coord < 0 then pos.y_coord := 0;
X    if pos.x_coord > ((board_width_x-1)*guage) then
X        pos.x_coord := ((board_width_x-1)*guage);
X    if pos.y_coord > ((board_width_y-1)*guage) then
X        pos.y_coord := ((board_width_y-1)*guage);
X
X    x := pos.x_coord div guage;
X    y := pos.y_coord div guage;
X
X    { find constraints in each direction }
X    if board[x, y] = wall then
X      begin
X        if x < (board_width_x-1) and then board[x+1, y] <> wall then
X            begin
X                x := x + 1;
X                pos.x_coord := x*guage;
X            end
X        else if y < (board_width_y-1) and then board[x, y+1] <> wall then
X            begin
X                y := y + 1;
X                pos.y_coord := y*guage;
X            end
X      end;
X
X    extrem := (pos.x_coord + (guage-1)) div guage;
X    if extrem >= board_width_x then extrem := board_width_x-1;
X    if extrem > x AND THEN board[extrem, y] = wall then
X            pos.x_coord := x*guage;
X
X    extrem := (pos.y_coord + (guage-1)) div guage;
X    if extrem >= board_width_y then extrem := board_width_y-1;
X    if extrem > y AND THEN board[x, extrem] = wall then
X            pos.y_coord := y*guage;
XEND;
X
X{ called to make a figure execute a saved turn }
XPROCEDURE board_$can_turn(* IN OUT pos: gpr_$position_t;
X                            IN     new_dir: board_$direction;
X                            OUT    turn: boolean *);
XVAR
X    elt: board_$elt;
X    x_inc, y_inc: integer;
X    x, y: integer;
X    spos: gpr_$position_t;
XBEGIN
X    spos.x_coord := (pos.x_coord+halfguage) div guage;
X    spos.y_coord := (pos.y_coord+halfguage) div guage;
X    x_inc := 0;
X    y_inc := 0;
X    case new_dir of
X      or$up     : y_inc := -1;
X      or$down   : y_inc :=  1;
X      or$right  : x_inc :=  1;
X      or$left   : x_inc := -1;
X    end;
X    x := spos.x_coord + x_inc;
X    y := spos.y_coord + y_inc;
X    if x < 0 OR ELSE x > board_width_x-1 or else
X       y < 0 OR ELSE y > board_width_y-1 then turn := false
X    else begin
X        elt := board[x, y];
X        if elt = wall
X          then turn := false
X          else begin
X            pos.x_coord := spos.x_coord * guage;
X            pos.y_coord := spos.y_coord * guage;
X            turn := true
X          end
X    end
XEND;
X
X{ called after above to clear a dot in a square of the board }
XPROCEDURE board_$clear_dot(* IN pos: gpr_$position_t; 
X                             OUT wasdot, special: boolean *);
XVAR
X    x, y: integer;
X    bm: gpr_$bitmap_desc_t;
X    draw: boolean;
X    drawpos: gpr_$position_t;
XBEGIN
X    x := (pos.x_coord+(halfguage)) div guage;
X    y := (pos.y_coord+(halfguage)) div guage;
X    draw := true;
X    case board[x, y] of
X        wall: {board_$fail(100);} draw := false;
X        ecor: begin
X                draw := false;
X                wasdot := false;
X                special := false;
X              end;
X        dcor: begin
X                bm := dot_bm;
X                wasdot := true;
X                special := false;
X              end;
X        scor: begin
X                bm := sdot_bm;
X                wasdot := true;
X                special := true;
X              end
X    end;
X    board[x, y] := ecor; { erase the dot if there was one}
X    if draw then 
X      begin
X        drawpos.x_coord := x * guage;
X        drawpos.y_coord := y * guage;
X        gpr_$bit_blt(bm, w, 0, drawpos, 0, status);
X      end
XEND;
X
XPROCEDURE board_$show_score(* newscore: integer, newnumpacs: integer *);
XBEGIN
X    if score <> newscore then begin
X        board_$print_integer(score, 'score: %5sd%$', score_x, score_y);
X        board_$print_integer(newscore, 'score: %5sd%$', score_x, score_y);
X        score := newscore
X        end;
X    if numpacs <> newnumpacs then begin
X        board_$print_integer(numpacs, 'pacs left: %5sd%$', pac_x, pac_y);
X        board_$print_integer(newnumpacs, 'pacs left: %5sd%$', pac_x, pac_y);
X        numpacs := newnumpacs
X        end
XEND;
X
END-of-board.mod.pas
echo file: fig.mod.pas
sed 's/^X//' >fig.mod.pas << 'END-of-fig.mod.pas'
XMODULE fig;
X                                                  
X{ ******************************************************** }
X{ ******************************************************** }
X{ *********                                      ********* }
X{ *********    FIG.MOD.PAS                       ********* }
X{ *********                                      ********* }
X{ *********    Written 12/24/84 by Geof Cooper   ********* }
X{ *********                                      ********* }
X{ ******************************************************** }
X{ ******************************************************** }
X{ Copyright (C) 1984, 1985, IMAGEN Corporation                              }
X{ This software may be duplicated in part of in whole so long as [1] this   }
X{ notice is preserved in the copy, and [2] no financial gain is derived     }
X{ from the copy.  Copies of this software other than as restricted above    }
X{ may be made only with the consent of the author.                          }
X                                                  
X%include '/sys/ins/base.ins.pas';
X%include '/sys/ins/error.ins.pas';
X%include '/sys/ins/kbd.ins.pas';
X%include '/sys/ins/gpr.ins.pas';
X%include '/sys/ins/pgm.ins.pas';
X%include '/sys/ins/pad.ins.pas';
X
XDEFINE fig_$create, fig_$refresh, fig_$move, fig_$elapse_time,
X       fig_$turn, fig_$set_velocity, fig_$alloc_fig_bitmaps,
X       fig_$coincident;
X
X%include 'fig.ins.pas';
X
XVAR
X    { pre-stored for fast bit_blt's }
X    fig_$wind: gpr_$window_t := [ [ 0, 0 ], [ guage, guage ] ];
X
X
XPROCEDURE fig_$cs(status: status_$t; position: integer);
XBEGIN
X    if status.all <> status_$ok then
X    begin
X        gpr_$terminate(false, status);
X        writeln('fig_$error(', position:0, ')');
X        error_$print(status);
X        pgm_$exit
X    end
XEND;
X
X
X{ Error 10 }
XPROCEDURE fig_$alloc_fig_bitmaps(* OUT f: fig_$orientations *);
XVAR
X    i           : integer;
X    attr        : gpr_$attribute_desc_t;
X    status      : status_$t;
X    size        : gpr_$offset_t;
XBEGIN
X    gpr_$allocate_attribute_block(attr, status);
X    fig_$cs(status, 11);
X    size.x_size := guage;
X    size.y_size := guage;
X    for i := 0 to num_orientations do
X        begin
X            gpr_$allocate_bitmap(size, 0, attr, f[i], status);
X            fig_$cs(status, 12);
X        end
XEND;
X
XPROCEDURE fig_$create(* IN figures: fig_$orientations;
X                        IN pos_x, pos_y: Integer;
X                        OUT r: fig_$t *);
XVAR           
X    status  : status_$t;
X
XBEGIN
X    new(r);
X
X    r^.figures     := figures;
X    r^.orientation := or$right;
X    r^.velocity    := 0;
X    r^.position.x_coord := pos_x;
X    r^.position.y_coord := pos_y;
XEND {fig_$create};
X
X{ Error 30 }
XPROCEDURE fig_$refresh(* IN r: fig_$t *);
XVAR
X    status: status_$t;
XBEGIN
X    gpr_$bit_blt(r^.figures[r^.orientation], fig_$wind, 0,
X                 r^.position, 0, status);
X    fig_$cs(status, 21);
XEND;
X
X{ Error 40 }
XPROCEDURE fig_$move(* IN r: fig_$t; IN pos: gpr_$position_t *);
X{ ASSUMES that raster op is XOR }
XVAR
X    status: status_$t;
XBEGIN
X    { write it once in its old place, to erase it }
X    fig_$refresh(r);
X    { and write it into its new place, to redraw it }
X    r^.position := pos;
X    fig_$refresh(r);
XEND;
X
X{ Error 50 }
X{ find new position based on current velocity }
XPROCEDURE fig_$elapse_time(* IN r: fig_$t; IN t: PInteger;
X                             OUT newpos: gpr_$position_t *);
XVAR
X    incr: INTEGER;
XBEGIN
X    incr := t * r^.velocity;
X    newpos := r^.position;
X    CASE r^.orientation OF
X      or$up:   newpos.y_coord := newpos.y_coord - incr;
X      or$down: newpos.y_coord := newpos.y_coord + incr;
X      or$right:newpos.x_coord := newpos.x_coord + incr;
X      or$left: newpos.x_coord := newpos.x_coord - incr
X    END
XEND;
X
X{ Error 60 }
XPROCEDURE fig_$turn(* IN r: fig_$t; IN orient: Integer *);
XVAR
X    status: status_$t;
XBEGIN
X    if r^.orientation <> orient then begin
X        { write it once in its old place, to erase it }
X        fig_$refresh(r);
X
X        { change orientation }
X        r^.orientation := orient;
X
X        { write it again to show it }
X        fig_$refresh(r)
X        end
XEND;
X
X{ Error 70 }
XPROCEDURE fig_$set_velocity(* IN r: fig_$t;
X                             IN velocity: PInteger *);
XBEGIN
X    r^.velocity := velocity;
XEND;
X
X
XFUNCTION fig_$coincident(* IN r1, r2: fig_$t *){: BOOLEAN};
XCONST
X    halfguage = guage div 2;
XVAR
X    pos1_x, pos1_y, pos2_x, pos2_y: integer;
XBEGIN
X    pos1_x := r1^.position.x_coord + halfguage;
X    pos1_y := r1^.position.y_coord + halfguage;
X    pos2_x := r2^.position.x_coord + halfguage;
X    pos2_y := r2^.position.y_coord + halfguage;
X    fig_$coincident := (abs(pos1_x - pos2_x) < guage)
X                                  AND
X                       (abs(pos1_y - pos2_y) < guage)
XEND;
X
END-of-fig.mod.pas
echo file: pac.pas
sed 's/^X//' >pac.pas << 'END-of-pac.pas'
XPROGRAM pacm;
X
X{ APOLLO PAC - a pacman like game                                           }
X{                                                                           }
X{ Written January, 1985 by Geoffrey Cooper                                  }
X{                                                                           }
X{ Copyright (C) 1985, IMAGEN Corporation                                    }
X{ This software may be duplicated in part of in whole so long as [1] this   }
X{ notice is preserved in the copy, and [2] no financial gain is derived     }
X{ from the copy.  Copies of this software other than as restricted above    }
X{ may be made only with the consent of the author.                          }
X
X%include '/sys/ins/base.ins.pas';
X%include '/sys/ins/error.ins.pas';
X%include '/sys/ins/kbd.ins.pas';
X%include '/sys/ins/gpr.ins.pas';
X%include '/sys/ins/pgm.ins.pas';
X%include '/sys/ins/pad.ins.pas';
X%include '/sys/ins/time.ins.pas';
X%include '/sys/ins/tone.ins.pas';
X
X%include 'fig.ins.pas';   {mobile_figure module}
X%include 'board.ins.pas'; {pacman_board module}
X
XPROCEDURE pacm_$refresh_all; EXTERN;
XPROCEDURE pacm_$noop; EXTERN;
XPROCEDURE pacm_$refresh_part(IN unobscured, pos_change: boolean); EXTERN;
X
XTYPE
X    ndesc = record
X                tip_x, tip_y: integer;
X                base_x, base_y: integer;
X                inc_x, inc_y: integer
X            end;
X
XCONST
X    pac_init_x = guage;
X    pac_init_y = guage;
X
X    nasty_init_x = guage*29;
X    nasty_init_y = guage*32;
X
X    max_nasties = 15;
X
XVAR
X    play_forever: boolean;
X
X    ndh: array[0..3] of ndesc := [
X        [  (guage div 2),  0, -(guage div 2), -(guage div 2),  0,  1 ],
X        [  0, -(guage div 2), -(guage div 2),  (guage div 2),  1,  0 ],
X        [ -(guage div 2),  0,  (guage div 2), -(guage div 2),  0,  1 ],
X        [  0,  (guage div 2), -(guage div 2), -(guage div 2),  1,  0 ]
X    ];
X
X    screen      : gpr_$bitmap_desc_t;
X    screen_size : gpr_$offset_t;
X
X    pac         : DEFINE fig_$t;
X    nasty       : fig_$t;
X    nasties     : DEFINE array [1..max_nasties] of fig_$t;
X    num_nasties : DEFINE integer;
X    pac_time    : integer32;
X    num_pacs    : integer;
X    screen_rfs  : integer;
X
X    score_dots  : integer;
X    score_bigdots: integer;
X    score        : integer;
X
X    clock_tick  : integer32 := 20000; { 12.5 ticks per second }
X
X    incs: array [1..3] of integer := [ 1, 3, 2 ];
X    nasty_rand   : integer;
X    last_tick   : DEFINE time_$clock_t;
X
X{ Initialize the display, using GPR routines }
XPROCEDURE pacm_$init_gpr;
XCONST
X    bitmap_max_size = 1024;
X    black_and_white = 0;
X    keyset = [ kbd_$up_arrow, kbd_$down_arrow, 
X               kbd_$left_arrow, kbd_$right_arrow,
X               kbd_$hold2,
X               kbd_$l_box_arrow, kbd_$r_box_arrow, 
X               kbd_$down_box_arrow2, kbd_$up_box_arrow2,
X               kbd_$next_win,
X               'f', 's',
X               'l',
X               'q' ];
X    buttonset = ['a', 'A', 'b', 'c']; 
X    locatorset  = [];
X    raster_op_XOR = 6;
XVAR
X    attr:           gpr_$attribute_desc_t;
X    status:         status_$t;
X    unobscured:     BOOLEAN;
X    font_width, 
X    font_height,
X    font_length,
X    font_id:        INTEGER;
X    font_name:      STRING;
X    plane:          integer;
X
XBEGIN
X    { Initialize the a displayed bitmap filling the frame }
X    screen_size.x_size := bitmap_max_size;
X    screen_size.y_size := bitmap_max_size;
X    gpr_$init( gpr_$direct, stream_$stdout, screen_size, black_and_white,
X                    screen, status );
X
X    gpr_$inq_bitmap_dimensions(screen, screen_size, plane, status);
X
X    gpr_$set_obscured_opt(gpr_$block_if_obs, status);
X
X    { Set up bitmap to use the default font }
X    pad_$inq_font( stream_$stdout, font_width, font_height, 
X                      font_name, sizeof(String), font_length, status );
X    gpr_$load_font_file( font_name, font_length, font_id, status );
X    gpr_$set_text_font( font_id, status );
X
X    { enable input from mouse }
X    gpr_$enable_input( gpr_$keystroke, keyset, status);
X
X    gpr_$set_raster_op(0, raster_op_XOR, status);
X
X    gpr_$set_cursor_active( true, status );
XEND;
X
XPROCEDURE add_time( IN OUT t: time_$clock_t; ticktime: linteger );
XVAR
X    i: linteger;
XBEGIN
X    i := t.low32 + ticktime;
X    if i < t.low32 then t.high16 := t.high16 + 1;
X    t.low32 := i
XEND;
X
XPROCEDURE pregnant_pause;
XCONST
X    ticktime = 156250;
XVAR
X    t           :time_$clock_t;
X    status      : status_$t;
XBEGIN
X    t.high16 := 0;
X    t.low32  := ticktime;
X    time_$wait( time_$relative, t, status );
X    add_time(last_tick, ticktime)
XEND;
X
XPROCEDURE pacm_$init_pac;
XVAR
X    pac_bitmaps : fig_$orientations;
X    pac_size    : gpr_$offset_t;
X    status      : status_$t;
X    point       : gpr_$position_t;
X    unobsc      : boolean;
X    i,j         : integer;
X    attr        : gpr_$attribute_desc_t;
XCONST
X    wedge_begin = (guage div 2) - (guage div 8) - 1;
X    wedge_end   = (guage div 2) + (guage div 8) + 1;
XBEGIN
X    gpr_$allocate_attribute_block(attr, status);
X    pac_size.x_size := guage;
X    pac_size.y_size := guage;
X    point.x_coord := guage div 2;
X    point.y_coord := guage div 2;
X    unobsc := gpr_$acquire_display(status);
X    for i := 0 to 3 do
X    begin
X        gpr_$allocate_bitmap(pac_size, 0, attr,
X                             pac_bitmaps[i], status);
X        gpr_$set_bitmap(pac_bitmaps[i], status);
X        gpr_$circle_filled(point, (guage div 2) - 1, status);
X        gpr_$set_draw_value(0, status);
X
X        for j := wedge_begin to wedge_end do
X          begin
X            gpr_$move((guage div 2), (guage div 2), status);
X            CASE i OF
X                0: gpr_$line( guage,  j    , status);
X                1: gpr_$line( j    ,  0    , status);
X                2: gpr_$line( 0    ,  j    , status);
X                3: gpr_$line( j    ,  guage, status);
X            END
X          end;
X        gpr_$set_draw_value(1, status)
X    END;
X    fig_$create(pac_bitmaps, pac_init_x, pac_init_y, pac);
X    fig_$set_velocity(pac, (guage div 2) + (guage div 8));
X    gpr_$release_display(status);
XEND;
X
XPROCEDURE pacm_$init_nasty;
XCONST
X    pi = 3.14159;
X    right_angle = pi/2;
X    mag = guage div 2;
XVAR
X    nasty_bitmaps : fig_$orientations;
X    size          : gpr_$offset_t;
X    status        : status_$t;
X    unobsc        : boolean;
X    i,j           : integer;
X    attr          : gpr_$attribute_desc_t;
X    org           : gpr_$position_t;
X    org0          : gpr_$position_t;
X    angle         : real;
X    x, y          : integer;
X    x1, y1        : integer;
XBEGIN
X    org.x_coord := guage div 2;
X    org.y_coord := guage div 2;
X    org0.x_coord := 0;
X    org0.y_coord := 0;
X    gpr_$allocate_attribute_block(attr, status);
X    size.x_size := guage;
X    size.y_size := guage;
X    unobsc := gpr_$acquire_display(status);
X    for i := 0 to 3 do
X        begin
X            gpr_$allocate_bitmap(size, 0, attr, nasty_bitmaps[i], status);
X            gpr_$set_bitmap(nasty_bitmaps[i], status);
X            gpr_$set_coordinate_origin(org, status);
X
X            gpr_$move(ndh[i].tip_x, ndh[i].tip_y, status);
X            for j := 0 to guage-1 do begin
X                gpr_$line(ndh[i].base_x, ndh[i].base_y, status);
X                gpr_$move(ndh[i].tip_x, ndh[i].tip_y, status);
X                ndh[i].base_x := ndh[i].base_x + ndh[i].inc_x;
X                ndh[i].base_y := ndh[i].base_y + ndh[i].inc_y
X                end;
X            gpr_$set_coordinate_origin(org0, status);
X        end;
X    fig_$create(nasty_bitmaps, nasty_init_x, nasty_init_y, nasty);
X    fig_$set_velocity(nasty, (guage div 2));
X    gpr_$release_display(status);
X    nasty_rand := 0;
X    nasties[1] := nasty;
X    num_nasties := 1
XEND;
X
XPROCEDURE pacm_$add_nasty(OUT n: fig_$t);
XBEGIN
X    fig_$create(nasty^.figures, nasty_init_x, nasty_init_y, n);
X    fig_$refresh(n);
X    fig_$set_velocity(n, (guage div 2));
XEND;
X
XPROCEDURE pacm_$tick_nasty(nasty: fig_$t);
X{
X    Algorithm for controlling the nasty:
X        using absolute difference between nasty x and y
X        positions and pac's, prefer the correct direction
X        in each axis, with the axis with the largest distance
X        having priority.
X
X        The other two possible turns are random, except that
X        the `about face' direction has low priority.
X    Then:
X        Only try all four possibilities when you have hit
X        a wall.
X
X        Only allow yourself to about face every
X        ALLOW_REVERSE moves unless you have hit a wall.
X}
XCONST
X    allow_reverse = 50;
XVAR
X    pos: gpr_$position_t;
X    turnpos: gpr_$position_t;
X    i: integer;
X    orient: integer;
X    can_turn: boolean;
X    no_change: boolean;
X    bound: integer;
X    t           :time_$clock_t;
X    turns: array[0..3] of integer;
X    diff_x, diff_y: integer;
X    about_face: integer;
XBEGIN
X    fig_$elapse_time(nasty, 1, pos);
X    board_$try_pac_position(pos);
X
X    nasty_rand := nasty_rand + 1;
X    no_change := pos = nasty^.position;
X    bound := 1;
X    if no_change then bound := 3;
X
X    { find priorities for directions }
X    diff_x := pos.x_coord - pac^.position.x_coord;
X    diff_y := pos.y_coord - pac^.position.y_coord;
X    if abs(diff_x) > abs(diff_y) then begin
X        if diff_x > 0 then begin
X            turns[0] := or$left;
X            turns[2] := or$right
X            end
X        else begin
X            turns[0] := or$right;
X            turns[2] := or$left
X            end;
X        if diff_y > 0 then begin
X            turns[1]:= or$up;
X            turns[3] := or$down
X            end
X        else begin
X            turns[1] := or$down;
X            turns[3] := or$up
X            end
X        end
X    else begin
X        if diff_x > 0 then begin
X            turns[1] := or$left;
X            turns[3] := or$right
X            end
X        else begin
X            turns[1] := or$right;
X            turns[3] := or$left
X            end;
X        if diff_y > 0 then begin
X            turns[0]:= or$up;
X            turns[2] := or$down
X            end
X        else begin
X            turns[0] := or$down;
X            turns[2] := or$up
X            end
X    end;
X    about_face := ((nasty^.orientation+2) mod 4);
X    if turns[2] = about_face then begin
X        i := turns[3];
X        turns[3] := turns[2];
X        turns[2] := i
X        end;
X    can_turn := false;
X    for i := 0 to bound do begin
X        orient := turns[i];
X        if no_change or else
X           orient <> about_face or else
X           (nasty_rand mod allow_reverse) = 0 then begin
X            turnpos := pos;
X            board_$can_turn(turnpos, orient, can_turn);
X            end;
X        if can_turn then exit
X        end;
X    if can_turn and then orient <> nasty^.orientation then begin
X        fig_$turn(nasty, orient);
X        pos := turnpos
X        end;
X    fig_$move(nasty, pos);
X    { check scores }
X    if fig_$coincident(nasty, pac) then begin
X        num_pacs := num_pacs - 1;
X        t.high16 := 0;
X        t.low32  := 10000;
X        tone_$time(t);
X        add_time(last_tick, 10000);
X        pos.x_coord := pac_init_x;
X        pos.y_coord := pac_init_y;
X        fig_$move(pac, pos);
X        pos.x_coord := nasty_init_x;
X        pos.y_coord := nasty_init_y;
X        fig_$move(nasty, pos);
X        pregnant_pause;
X        end
XEND;
X
XPROCEDURE pacm_$tick_all_nasties;
XVAR
X    i: integer;
XBEGIN
X    for i := 1 to num_nasties do
X        pacm_$tick_nasty(nasties[i]);
XEND;
X
XPROCEDURE pacm_$tick;
XVAR
X    i           : linteger;
X    status      : status_$t;
X    unobsc      : boolean;
X    release     : boolean;
XBEGIN
X    add_time(last_tick, clock_tick);
X    release := (pac_time mod 16) = 0;
X    pac_time := pac_time + 1;
X    if release then gpr_$release_display(status);
X    time_$wait( time_$absolute, last_tick, status );
X    time_$clock(last_tick);
X    if release then unobsc := gpr_$acquire_display(status);
XEND;
X
X
XPROCEDURE pacm_$play;
XVAR
X    c           : char; 
X    pos         : gpr_$position_t;
X    event       : gpr_$event_t;
X    cp          : ^char;
X    status      : status_$t;
X    unobsc      : boolean;
X    wasdot      : boolean;
X    special     : boolean;
X    is_q_orient : boolean;
X    can_turn    : boolean;
X    q_orient    : board_$direction;
X    num_dots    : integer;
X    num_bigdots : integer;
X    total_dots  : integer;
X    total_sdots : integer;
X    i           : integer;
X    num_events  : integer;
X    num_passes  : integer32;
X
X    u1, u2      : univ_ptr;
XBEGIN
X    num_dots := 0;
X    num_bigdots := 0;
X    score_dots := 0;
X    score_bigdots := 0;
X    score := 0;
X    pac_time := 0;
X    num_pacs := 5;
X    screen_rfs := 0;
X    pacm_$init_gpr;
X    pacm_$init_pac;
X    pacm_$init_nasty;
X    unobsc := gpr_$acquire_display(status);
X    gpr_$set_bitmap(screen, status);
X    u1 := addr(pacm_$refresh_part);
X    u2 := addr(pacm_$noop);
X    gpr_$set_refresh_entry(addr(pacm_$refresh_part), addr(pacm_$noop), status);
X    board_$init(screen, screen_size, num_pacs);
X    board_$get_num_dots(total_dots, total_sdots);
X    pacm_$refresh_all;
X    is_q_orient := false;
X    c := chr(0);
X    cp := addr(c);
X    num_events := 2;
X    num_passes := 0;
X    REPEAT
X        repeat
X            unobsc := gpr_$cond_event_wait(event, c, pos, status);
X            IF status.all <> status_$OK THEN
X                BEGIN
X                    error_$print(status);
X                    pgm_$exit;
X                END;
X            IF event = gpr_$keystroke THEN
X                CASE c OF
X                  kbd_$right_arrow:
X                        begin
X                            is_q_orient := true;
X                            q_orient := or$right
X                        end;
X                  kbd_$up_arrow:
X                        begin
X                            is_q_orient := true;
X                            q_orient := or$up
X                        end;
X                  kbd_$left_arrow:
X                        begin
X                            is_q_orient := true;
X                            q_orient := or$left
X                        end;
X                  kbd_$down_arrow:
X                        begin
X                            is_q_orient := true;
X                            q_orient := or$down
X                        end;
X                  'f':
X                        begin
X                            clock_tick := clock_tick - 1000;
X                            if clock_tick < 0 then clock_tick := 0;
X                        end;
X                  's':
X                        clock_tick := clock_tick + 1000;
X                  'l':
X                        pacm_$refresh_all;
X                  kbd_$up_box_arrow2:
X                        begin
X                            if pac^.velocity < (guage-1) then
X                                fig_$set_velocity(pac, pac^.velocity+1)
X                        end;
X                  kbd_$down_box_arrow2:
X                        begin
X                            if pac^.velocity <> 0 then
X                                fig_$set_velocity(pac, pac^.velocity - 1)
X                        end;
X                  kbd_$hold2:
X                        begin
X                            repeat
X                                unobsc := gpr_$event_wait(event, c, pos, status);
X                            until (event = gpr_$keystroke) AND (c = kbd_$hold2);
X                            num_events := 2
X                        end;
X                  'q':;
X                  OTHERWISE
X                        { ignore other characters -- they are defined so }
X                        { that pressing them by accident doesn't spoil   }
X                        { the game.                                      }
X                END;
X                num_events := num_events + 1;
X        UNTIL event <> gpr_$keystroke;
X
X        { num_passes is to prevent an initial "spurt" when libraries }
X        { are loaded the first time a pac is run in a process }
X        num_passes := num_passes + 1;
X        if (num_events > 1) or (num_passes < 10) then
X            time_$clock(last_tick);
X        num_events := 0;
X
X        pacm_$tick;
X        fig_$elapse_time(pac, 1, pos);
X
X        { stop pac man at boundary }
X        board_$try_pac_position(pos);
X        board_$clear_dot(pos, wasdot, special);
X        if wasdot then
X            if special then
X              begin
X                num_bigdots := num_bigdots + 1;
X                score_bigdots := score_bigdots + 1;
X                score := score + 5;
X              end
X            else
X              begin
X                num_dots := num_dots + 1;
X                score_dots := score_dots + 1;
X                score := score + 1;
X              end;
X        board_$show_score( score, num_pacs );
X        if is_q_orient then
X          begin
X            if pac^.orientation = q_orient then
X                is_q_orient := false
X            else
X              begin
X                board_$can_turn(pos, q_orient, can_turn);
X                if can_turn then
X                  begin
X                    fig_$turn(pac, q_orient);
X                    is_q_orient := false
X                  end
X              end
X          end;
X        fig_$move(pac, pos);
X
X        { move /nasty/ }
X        pacm_$tick_all_nasties;
X
X        if num_dots = total_dots  THEN
X          begin
X            screen_rfs := screen_rfs + 1;
X            board_$reinit;
X            fig_$refresh(pac);
X            for i := 1 to num_nasties do
X                fig_$refresh(nasties[i]);
X            num_bigdots := 0;
X            num_dots := 0;
X            for i := 1 to num_nasties do
X                if nasties[i]^.velocity < (guage-1) then
X                    fig_$set_velocity(nasties[i], nasties[i]^.velocity+1);
X            if num_nasties < max_nasties then begin
X                num_nasties := num_nasties + 1;
X                pacm_$add_nasty(nasties[num_nasties])
X                end;
X            num_pacs := num_pacs + 1;
X            time_$clock(last_tick);
X          end
X    UNTIL (c = 'q') OR ((num_pacs <= 0) AND (NOT play_forever));
X    { Read any extra characters that were typed but not read yet }
X    { This is necessary since otherwise special characters can get }
X    { left in the input stream and kill the csh }
X    repeat
X        unobsc := gpr_$cond_event_wait(event, c, pos, status);
X    until (event <> gpr_$keystroke) OR (status.all <> status_$ok);
X
X    gpr_$release_display(status);
X    gpr_$terminate(false, status);
X    i := 6 + screen_rfs - num_pacs;
X    if num_pacs <> 0 then
X        writeln('PAC score after ', i:0, ' pacs:')
X    else
X        writeln('Final PAC score (', i:0, ' pacs):');
X    writeln('    ', score:0, ' points, ', screen_rfs:0, ' entire screens consumed.')
XEND;
X
XPROCEDURE pacm_$help;
XVAR
X    status      : status_$t;
X    argv_ptr    : pgm_$argv_ptr;
X    argc        : integer;
XBEGIN
X    pgm_$get_args(argc, argv_ptr);
X    play_forever := false;
X    if argc = 7 then
X      begin
X        writeln('Pac - play forever mode.');
X        play_forever := true;
X        argc := 0;
X      end;
X    if argc > 1 then
X      begin
X        writeln('pac - play pac man.');
X        writeln('usage: pac');
X        writeln('[An argument gives this help, no argument plays the game]');
X        writeln('PAC is an adaptation of the ever-popular ATARI game, PACMAN(C).');
X        writeln('You control a round PAC, which runs from the scurrying');
X        writeln('NASTIES.  The nasties seek the PAC like heat-seeking missiles.');
X        writeln('When they catch it, it is destroyed, and both nasty and pac');
X        writeln('go to neutral corners.  You start the game with five PACs.');
X        writeln;
X        writeln('The PAC accumulates points by eating solid dots [1 point] and');
X        writeln('hollow dots [5 points].  When all the dots on the screen are');
X        writeln('eaten, the screen is re-filled, and you are given one more ');
X        writeln('PAC "life."  The game also gets tougher each time the screen');
X        writeln('refreshes, since a new nasty appears, and all existing nasties');
X        writeln('get a bit faster.');
X        writeln;
X        writeln('Control the PAC by using the arrow keys.  Pressing an');
X        writeln('arrow key queues a request to turn in that direction.');
X        writeln('The request is processed when the turn is first possible.');
X        writeln('For best results, do not hold down the arrow keys.');
X        writeln;
X        writeln('The UP and DOWN block arrows make the PAC get slower and faster,');
X        writeln('respectively.  A slow PAC is more maneuverable, but must');
X        writeln('be more strategic to escape the nasties.');
X        writeln;
X        writeln('Additional commands:');
X        writeln('    ''q''  - quits the game immediately');
X        writeln('    ''l''  - manual refresh of screen');
X        writeln('    HOLD - stops action until you press hold again');
X        writeln('    POP  - the game stops if the window is obscured');
X        writeln('    ''f''  - speed  up the game clock (decrease tick time)');
X        writeln('    ''s''  - slow down the game clock (increase tick time)');
X        writeln('If you start with a window that is too small, just enlarge it.');
X        writeln;
X        writeln('Run this program again without arguments to play.');
X        pgm_$exit
X      end
X    else
X      begin
X        writeln('Pac:  type ''q'' to quit, then ''pac help'' to get instructions');
X        pregnant_pause;
X      end
XEND;
X
XBEGIN
X    pacm_$help;
X    pacm_$play;
XEND.
END-of-pac.pas
echo file: pac_refresh.pas
sed 's/^X//' >pac_refresh.pas << 'END-of-pac_refresh.pas'
XMODULE pac_refresh;
X
X{ Copyright (C) 1985, IMAGEN Corporation                                    }
X{ This software may be duplicated in part of in whole so long as [1] this   }
X{ notice is preserved in the copy, and [2] no financial gain is derived     }
X{ from the copy.  Copies of this software other than as restricted above    }
X{ may be made only with the consent of the author.                          }
X
X%include '/sys/ins/base.ins.pas';
X%include '/sys/ins/error.ins.pas';
X%include '/sys/ins/kbd.ins.pas';
X%include '/sys/ins/gpr.ins.pas';
X%include '/sys/ins/pgm.ins.pas';
X%include '/sys/ins/pad.ins.pas';
X%include '/sys/ins/time.ins.pas';
X%include '/sys/ins/tone.ins.pas';
X
X%include 'fig.ins.pas';   {mobile_figure module}
X%include 'board.ins.pas'; {pacman_board module}
X
X
XVAR
X    last_tick: extern time_$clock_t;
X    pac: extern fig_$t;
X    nasties: extern array[1..15] of fig_$t;
X    num_nasties: extern integer;
X
XPROCEDURE pacm_$noop;
XBEGIN
X    { do nothing }
XEND;
X
XPROCEDURE pacm_$refresh_all;
XVAR
X    i: integer;
XBEGIN
X    board_$draw_board;
X    fig_$refresh(pac);
X    for i := 1 to num_nasties do
X        fig_$refresh(nasties[i]);
X    time_$clock(last_tick)
XEND;
X
XPROCEDURE pacm_$refresh_part(IN unobscured, pos_change: boolean);
XBEGIN
X    if unobscured or pos_change then
X        pacm_$refresh_all;
XEND;
X
END-of-pac_refresh.pas
exit


/* End of text from mirror:mod.sources */
