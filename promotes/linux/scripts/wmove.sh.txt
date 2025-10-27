#!/bin/bash

# To Use - Rename this file to wmove.sh
# 		 - by humpty Jun 2024 - Sep 2025

# Moves or Resizes the active window

# wmove.sh <cmd>
# 					e.g wmove.sh righthalf
# where <cmd> is

# full		- full size (permanent - not maximized nor fullscreen)

# lefthalf  - left & half screen width	e.g assign to WIN-LEFT
# righthalf	- right & half screen width	e.g assign to WIN-RIGHT
# tophalf	- top & half screen height	e.g assign to WIN-UP
# bothalf	- bottom & half screen height e.g assign to WIN-DOWN

# incheight	- increase height 1/10	e.g assign to CTRL-WIN-DOWN
# decheight	- decrease height		e.g assign to CTRL-WIN-UP
# incwidth	- increase width		e.g assign to CTRL-WIN-RIGHT
# decwidth	- decrease width		e.g assign to CTRL-WIN-LEFT

# moveup	- move up 1/10			e.g assign to ALT-WIN-UP
# movedown	- move down				e.g assign to ALT-WIN-DOWN
# moveleft	- move left				e.g assign to ALT-WIN-LEFT
# moveright	- move right			e.g assign to ALT-WIN-RIGHT

# screen width and height
SCR_W=$(xwininfo -root | grep Width | cut -f 4 -d ' ')
SCR_H=$(xwininfo -root | grep Height | cut -f 4 -d ' ')
ID=$(xprop -root | grep "NET_ACTIVE_WINDOW(WINDOW)" | cut -f 5 -d ' ')
# title height and border width
TIT_H=$(xwininfo -id $ID | grep "Relative upper-left Y" | cut -f 7 -d ' ')
BOR_W=$(xwininfo -id $ID | grep "Relative upper-left X" | cut -f 7 -d ' ')
# width and height
WIN_W=$(xwininfo -id $ID | grep Width | cut -f 4 -d ' ')
WIN_H=$(xwininfo -id $ID | grep Height | cut -f 4 -d ' ')
# X,Y
WIN_X=$(xwininfo -id $ID | grep "Absolute upper-left X" | cut -f 7 -d ' ')
WIN_Y=$(xwininfo -id $ID | grep "Absolute upper-left Y" | cut -f 7 -d ' ')

# right side inc/dec = 1/10 of the current width
INC_RIGHT=$(($WIN_W + $WIN_W/10))
DEC_RIGHT=$(($WIN_W - $WIN_W/10))

# bottom side inc/dec = 1/10 of the current height
INC_BOT=$(($WIN_H + $WIN_H/10))
DEC_BOT=$(($WIN_H - $WIN_H/10))

# top side inc/dec = 1/10 of the current height
INC_Y=$(($WIN_Y + $WIN_H/10 - $TIT_H))
DEC_Y=$(($WIN_Y - $WIN_H/10 - $TIT_H))

# left side inc/dec = 1/10 of the current width
INC_X=$(($WIN_X + $WIN_W/10 - $BOR_W))
DEC_X=$(($WIN_X - $WIN_W/10 - $BOR_W))

# work out half a window width and height
SCR_HALF_W=$(($SCR_W/2))
SCR_HALF_H=$(($SCR_H/2))
WIN_HALF_W=$(($SCR_HALF_W - $BOR_W*2 ))
WIN_HALF_H=$(($SCR_HALF_H - $TIT_H - $BOR_W))

# work out full a window width and height
WIN_FULL_W=$(($SCR_W - $BOR_W*2 ))
WIN_FULL_H=$(($SCR_H - $TIT_H - $BOR_W))

		wmctrl -r :ACTIVE: -b remove,maximized_horz
		wmctrl -r :ACTIVE: -b remove,maximized_vert
		wmctrl -r :ACTIVE: -b remove,fullscreen

case $1 in
	full)
		wmctrl -r :ACTIVE: -e 0,0,0,$WIN_FULL_W,$WIN_FULL_H
		;;
	lefthalf)
		wmctrl -r :ACTIVE: -e 0,0,-1,$WIN_HALF_W,-1
		;;
	righthalf)
		wmctrl -r :ACTIVE: -e 0,$SCR_HALF_W,-1,$WIN_HALF_W,-1
		;;
	tophalf)
		wmctrl -r :ACTIVE: -e 0,-1,0,-1,$WIN_HALF_H
		;;
	bothalf)
		wmctrl -r :ACTIVE: -e 0,-1,$SCR_HALF_H,-1,$WIN_HALF_H
		;;
	incwidth)
		wmctrl -r :ACTIVE: -e 0,-1,-1,$INC_RIGHT,-1
		;;
	decwidth)
		wmctrl -r :ACTIVE: -e 0,-1,-1,$DEC_RIGHT,-1
		;;
	incheight)
		wmctrl -r :ACTIVE: -e 0,-1,-1,-1,$INC_BOT
		;;
	decheight)
		wmctrl -r :ACTIVE: -e 0,-1,-1,-1,$DEC_BOT
		;;
	moveup)
		wmctrl -r :ACTIVE: -e 0,-1,$DEC_Y,-1,-1
		;;
	movedown)
		wmctrl -r :ACTIVE: -e 0,-1,$INC_Y,-1,-1
		;;
	moveleft)
		wmctrl -r :ACTIVE: -e 0,$DEC_X,-1,-1,-1
		;;
	moveright)
		wmctrl -r :ACTIVE: -e 0,$INC_X,-1,-1,-1
		;;
	*)
	echo action not found
	;;
esac

exit
