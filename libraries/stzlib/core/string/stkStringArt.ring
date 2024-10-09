load "stdlib.ring"
load "../error/stkError.ring"

#NOTE This class is dedicatd to Mahmoud for the effors he deployed
# in delivering the 1.21 version of Ring

# It provides several string art font styles (3 for the mean time).
# These styles can be rounded and background-shaded.

#---------------------------#
# STRING ART STYLES DATASET #
#---------------------------#

# "Pixelated Retro Blueprint"
# Softanza name: "retro"
'
╭──────────────────────────────╮
│ ░▄███▄░░░░███████░░░███████░ │
│ ██▀░░░░░░░░░██░░░░░░░░░▄██░░ │
│ ░▀███▄░░░░░░██░░░░░░░▄██░░░░ │
│ ░░░░▀██░░░░░██░░░░░░▄██░░░░░ │
│ ███▄▄█▀░░░░░██░░░░░░███████░ │
╰──────────────────────────────╯
'
# This style has a distinctly digital, retro-computer feel. The letters are
# formed by small square units, giving it a pixelated look. The white outline
# on a dark background with faint grid lines in the background evokes the
# aesthetics of old-school computer graphics or architectural blueprints.

$STRING_ART_001 = [
	[ "A" , ["░▄███▄░", "██▀░▀██", "███████", "██░░░██", "██░░░██"] ],
        [ "B" , ["███▄▄░░", "██░░░██", "███▄▄░░", "██░░░██", "███▄▄░░"] ],
        [ "C" , ["░▄███▄░", "██▀░░░░", "██░░░░░", "██▄░░░░", "░▀███▀░"] ],
        [ "D" , ["███▄▄░░", "██░░░██", "██░░░██", "██░░░██", "███▄▄░░"] ],
        [ "E" , ["███████", "██░░░░░", "█████░░", "██░░░░░", "███████"] ],
        [ "F" , ["███████", "██░░░░░", "█████░░", "██░░░░░", "██░░░░░"] ],
        [ "G" , ["░▄███▄░", "██▀░░░░", "██░░███", "██▄░░██", "░▀███▀░"] ],
        [ "H" , ["██░░░██", "██░░░██", "███████", "██░░░██", "██░░░██"] ],
        [ "I" , ["███████", "░░██░░░", "░░██░░░", "░░██░░░", "███████"] ],
        [ "J" , ["░░░░░██", "░░░░░██", "░░░░░██", "██░░░██", "░▀███▀░"] ],
        [ "K" , ["██░░░██", "██░░██░", "█████░░", "██░░██░", "██░░░██"] ],
        [ "L" , ["██░░░░░", "██░░░░░", "██░░░░░", "██░░░░░", "███████"] ],
        [ "M" , ["██░░░██", "███░███", "██▀█▀██", "██░░░██", "██░░░██"] ],
        [ "N" , ["██░░░██", "███░░██", "██▀█░██", "██░▀███", "██░░░██"] ],
        [ "O" , ["░▄███▄░", "██▀░▀██", "██░░░██", "██▄░▄██", "░▀███▀░"] ],
        [ "P" , ["███▄▄░░", "██░░░██", "███▄▄░░", "██░░░░░", "██░░░░░"] ],
        [ "Q" , ["░▄███▄░", "██▀░▀██", "██░▄▄██", "██▄░▀██", "░▀███▀█"] ],
        [ "R" , ["███▄▄░░", "██░░░██", "███▄▄░░", "██░▀██░", "██░░░██"] ],
        [ "S" , ["░▄███▄░", "██▀░░░░", "░▀███▄░", "░░░░▀██", "███▄▄█▀"] ],
        [ "T" , ["███████", "░░██░░░", "░░██░░░", "░░██░░░", "░░██░░░"] ],
        [ "U" , ["██░░░██", "██░░░██", "██░░░██", "██▄░▄██", "░▀███▀░"] ],
        [ "V" , ["██░░░██", "██░░░██", "██░░░██", "░██░██░", "░░▀█▀░░"] ],
        [ "W" , ["██░░░██", "██░░░██", "██░█░██", "███▄███", "░██▀██░"] ],
        [ "X" , ["██░░░██", "░██░██░", "░░███░░", "░██░██░", "██░░░██"] ],
        [ "Y" , ["██░░░██", "░██░██░", "░░███░░", "░░██░░░", "░░██░░░"] ],
        [ "Z" , ["███████", "░░░▄██░", "░▄██░░░", "▄██░░░░", "███████"] ],

	[ "0" , ["░█████░", "██░░░██", "██░░░██", "██░░░██", "░█████░"] ],
	[ "1" , ["░░███░░", "░████░░", "░░░██░░", "░░░██░░", "░█████░"] ],
	[ "2" , ["░█████░", "██░░░██", "░░░███░", "░███░░░", "███████"] ],
	[ "3" , ["░█████░", "██░░░██", "░░░███░", "██░░░██", "░█████░"] ],
	[ "4" , ["░░░███░", "░░████░", "░██░██░", "███████", "░░░░██░"] ],
	[ "5" , ["███████", "██░░░░░", "██████░", "░░░░░██", "██████░"] ],
	[ "6" , ["░█████░", "██░░░░░", "██████░", "██░░░██", "░█████░"] ],
	[ "7" , ["███████", "░░░░░██", "░░░███░", "░░██░░░", "░██░░░░"] ],
	[ "8" , ["░█████░", "██░░░██", "░█████░", "██░░░██", "░█████░"] ],
	[ "9" , ["░█████░", "██░░░██", "░██████", "░░░░░██", "░█████░"] ],
	[ "+" , ["░░░██░░░", "░░░██░░░", "███████░", "░░░██░░░", "░░░██░░░"] ],
	[ "-" , ["░░░░░░░", "░░░░░░░", "███████", "░░░░░░░", "░░░░░░░"] ],
	[ "*" , ["░░░░░░░", "██░░██░", "░░██░░░", "██░░██░", "░░░░░░░"] ],
	[ "/" , ["░░░░░██", "░░░░██░", "░░░██░░", "░░██░░░", "░██░░░░"] ],
	[ "=" , ["░░░░░░░", "███████", "░░░░░░░", "███████", "░░░░░░░"] ],

	[ " " , ["░░░", "░░░", "░░░", "░░░", "░░░"] ],
        [ "." , ["░░░", "░░░", "░░░", "░░░", "▓▓░"] ],
        [ "," , ["░░░", "░░░", "░░░", "▄▄░", "▀░░"] ],
        [ "!" , ["██░", "██░", "██░", "░░░", "██░"] ],
        [ "?" , ["▄▄█", "░░█", "▄█░", "░░░", "▄▄░"] ]

]

#--

# Style 002 : "Neon Outline"
# Softanza name : "neon"
'
┏━━╮┏┓┏┓╭━┓┏━┓
┃┏╮┃┃┃┃┃┃╭┛┃┗┓
┃┃┃╰┛┃┃┃┃╰┓┃┗┓
┗┛╰━━┛┗┛╰━┛┗━┛
'
# Description: This style features clean, continuous lines that
# form the letters, with an outline effect reminiscent of neon
# signs. The font has a modern, sleek appearance with rounded
# corners and a consistent thickness throughout.

$STRING_ART_002 = [
	[ "A", [ "╭━━━╮ ", 	"┃╭━╮┃ ", 	"┃┃━┃┃ ", 	"┃╰━╯┃ ", 	"╰━━━╯ " ] ],
	[ "B", [ "╭━━╮  ", 	"┃╭╮┃  ", 	"┃╰╯┃  ", 	"┃╭╮┃  ", 	"╰━━╯  " ] ],
	[ "C", [ "╭━━━╮ ", 	"┃╭━━╯ ", 	"┃┃    ", 	"┃╰━━╮ ", 	"╰━━━╯ " ] ],
	[ "D", [ "╭━━╮  ", 	"┃╭╮┃  ", 	"┃┃┃┃  ", 	"┃╰╯┃  ", 	"╰━━╯  " ] ],
	[ "E", [ "╭━━━╮ ", 	"┃╭━━╯ ", 	"┃╰━━╮ ", 	"┃╭━━╯ ", 	"╰━━━╯ " ] ],
	[ "F", [ "╭━━━╮ ", 	"┃╭━━╯ ", 	"┃╰━━╮ ", 	"┃╭━╮┃ ", 	"╰╯ ╰╯ " ] ],
	[ "G", [ "╭━━━╮ ", 	"┃╭━━╯ ", 	"┃┃╭━╮ ", 	"┃╰╯ ┃ ", 	"╰━━━╯ " ] ],
	[ "H", [ "╭╮ ╭╮ ", 	"┃┃ ┃┃ ", 	"┃╰━╯┃ ", 	"┃╭━╮┃ ", 	"╰╯ ╰╯ " ] ],
	[ "I", [ "╭━━━╮ ", 	"┃┃┃┃┃ ", 	" ┃┃┃  ", 	"┃┃┃┃┃ ", 	"╰━━━╯ " ] ],
	[ "J", [ " ╭━━╮ ", 	" ┃┃┃┃ ", 	" ┃┃┃┃ ", 	"╭╯╰╯┃ ", 	"╰━━━╯ " ] ],
	[ "K", [ "╭╮ ╭╮ ", 	"┃┃╭╯┃ ", 	"┃╰╯╭╯ ", 	"┃╭╮╰╮ ", 	"╰╯╰━╯ " ] ],
	[ "L", [ "╭╮    ", 	"┃┃"    , 	"┃┃    ", 	"┃╰━━╮ ", 	"╰━━━╯ " ] ],
	[ "M", [ "╭━╮╭━╮", 	"┃┃╰╯┃┃", 	"┃╭╮╭╮┃", 	"┃┃┃┃┃┃", 	"╰╯╰╯╰╯" ] ],
	[ "N", [ "╭━╮ ╭╮", 	"┃┃╰╮┃┃", 	"┃╭╮╰╯┃", 	"┃┃╰╮┃┃", 	"╰╯ ╰━╯" ] ],
	[ "O", [ "╭━━━╮ ", 	"┃╭━╮┃ ", 	"┃┃ ┃┃ ", 	"┃╰━╯┃ ", 	"╰━━━╯ " ] ],
	[ "P", [ "╭━━━╮ ", 	"┃╭━╮┃ ", 	"┃╰━╯┃ ", 	"┃╭━━╯ ", 	"╰╯    " ] ],
	[ "Q", [ "╭━━━╮ ", 	"┃╭━╮┃ ", 	"┃┃ ┃┃ ", 	"┃╰━╯┃ ", 	"╰━━╮╯ " ] ],
	[ "R", [ "╭━━━╮ ", 	"┃╭━╮┃ ", 	"┃╰━╯┃ ", 	"┃╭╮╭╯ ", 	"╰╯╰╯  " ] ],
	[ "S", [ "╭━━━╮ ", 	"┃╭━━╯ ", 	"╰━━╮  ", 	"╭━━╯  ", 	"╰━━━╯ " ] ],
	[ "T", [ "╭━━━━╮", 	"┃ ┃┃ ┃", 	"  ┃┃  ", 	"  ┃┃  ", 	"  ╰╯  " ] ],
	[ "U", [ "╭╮ ╭╮ ", 	"┃┃ ┃┃ ", 	"┃┃ ┃┃ ", 	"┃╰━╯┃ ", 	"╰━━━╯ " ] ],
	[ "V", [ "╭╮ ╭╮ ", 	"┃┃ ┃┃ ", 	"┃╰━╯┃ ", 	"╰╮╭╯  ", 	" ╰╯   " ] ],
	[ "W", [ "╭╮ ╭╮ ", 	"┃┃ ┃┃ ", 	"┃┃╭╯┃ ", 	"┃╰╯╮┃ ", 	"╰━━╯╰╯" ] ],
	[ "X", [ "╭╮ ╭╮ ", 	"╰╋━╋╯ ", 	"╭╋━╋╮ ", 	"┃┃ ┃┃ ", 	"╰╯ ╰╯ " ] ],
	[ "Y", [ "╭╮ ╭╮ ", 	"┃╰━╯┃ ", 	"╰╮╭╯  ", 	" ┃┃   ", 	" ╰╯   " ] ],
	[ "Z", [ "╭━━━╮ ", 	"╰━━╮┃ ", 	" ╭━╯┃ ", 	"╭╯╭━╯ ", 	"╰━━━╯ " ] ],
	
	[ "0", [ "╭━━━╮ ", 	"┃╭╮┃┃ ", 	"┃┃┃┃┃ ", 	"┃╰╯┃┃ ", 	"╰━━━╯ " ] ],
	[ "1", [ " ╭╮   ", 	"╭╯┃   ", 	" ┃┃   ", 	" ┃┃   ", 	"╰━╯   " ] ],
	[ "2", [ "╭━━━╮ ", 	"╰━━╮┃ ", 	"╭━━╯┃ ", 	"┃╰━━╮ ", 	"╰━━━╯ " ] ],
	[ "3", [ "╭━━━╮ ", 	"╰━━╮┃ ", 	" ╭━╯┃ ", 	"╰━━╮┃ ", 	"╰━━━╯ " ] ],
	[ "4", [ "╭╮ ╭╮ ", 	"┃┃ ┃┃ ", 	"┃╰━╯┃ ", 	"╰━━╮┃ ", 	"   ╰╯ " ] ],
	[ "5", [ "╭━━━╮ ", 	"┃╭━━╯ ", 	"╰━━╮  ", 	"╭━━╯  ", 	"╰━━━╯ " ] ],
	[ "6", [ "╭━━━╮ ", 	"┃╭━━╯ ", 	"┃╰━━╮ ", 	"┃╭━╮┃ ", 	"╰━━╯╰╯" ] ],
	[ "7", [ "╭━━━╮ ", 	"╰━━╮┃ ", 	"  ╭╯┃ ", 	" ╭╯╭╯ ", 	" ╰━╯  " ] ],
	[ "8", [ "╭━━━╮ ", 	"┃╭━╮┃ ", 	"┃╰━╯┃ ", 	"┃╭━╮┃ ", 	"╰━━╯╰╯" ] ],
	[ "9", [ "╭━━━╮ ", 	"┃╭━╮┃ ", 	"┃╰━╯┃ ", 	"╰━━╮┃ ", 	"╰━━━╯ " ] ],
	
	[ ".", [ "      ", 	"      ", 	"      ", 	"╭━╮   ", 	"╰━╯   " ] ],
	[ ",", [ "      ", 	"      ", 	"      ", 	"╭━╮   ", 	"╰╮┃   " ] ],
	[ "!", [ "╭━╮   ", 	"┃┃┃   ", 	"┃┃┃   ", 	"╰╯╰╮  ", 	"╭━━╯  " ] ],
	[ "?", [ "╭━━━╮ ", 	"╰━━╮┃ ", 	"  ╭╯┃ ", 	"  ╰━╮ ", 	"  ╭━╯ " ] ],
	[ " ", [ "      ", 	"      ", 	"      ", 	"  ", 		"      " ] ],
	[ "+", [ "  ╭╮  ", 	"  ┃┃  ", 	"╭━╋╋━╮", 	"  ┃┃  ", 	"  ╰╯  " ] ],
	[ "-", [ "      ", 	"      ", 	"╭━━━╮ ", 	"╰━━━╯ ", 	"      " ] ],
	[ "*", [ "╭╮ ╭╮ ", 	" ╰╋╋╯ ", 	"╭━╋╋━╮", 	" ╭╋╋╮ ", 	"╰╯ ╰╯ " ] ],
	[ "/", [ "  ╭╮  ", 	" ╭╯┃  ", 	" ╰╮┃  ", 	"╭╯┃   ", 	"╰╯    " ] ]
]

#--
# "Geo-Curve Fusion"
# Softanza name : "geo"

# Description : This  style offers a modern, slightly futuristic look while
# maintaining readability. It could be particularly effective for headlines,
# logos, or any application where you want to combine a tech-savvy feel with
# a touch of elegance.

$STRING_ART_003 = [
    [ "A", [ "  ╭─╮  ", " ╱   ╲ ", "╱─────╲", "│ ╭─╮ │", "╰─╯ ╰─╯" ] ],
    [ "B", [ "╭────╮ ", "│╭──╮│ ", "│╰──╮│ ", "│╭──╯│ ", "╰────╯ " ] ],
    [ "C", [ " ╭───╮ ", "╱    ╱ ", "│      ", "╲    ╲ ", " ╰───╯ " ] ],
    [ "D", [ "╭───╮  ", "│╭─╮│  ", "││ ││  ", "│╰─╯│  ", "╰───╯  " ] ],
    [ "E", [ "╭────╮ ", "│╭──── ", "│╰───╮ ", "│╭───╯ ", "╰────╯ " ] ],
    [ "F", [ "╭────╮ ", "│╭──── ", "│╰───╮ ", "│     │ ", "╰─────╯" ] ],
    [ "G", [ " ╭───╮ ", "╱ ╭───╯", "│ │ ╭╮ ", "╲ ╰─╯│ ", " ╰───╯ " ] ],
    [ "H", [ "╭╮   ╭╮", "││   ││", "│╰───╯│", "│╭───╮│", "╰╯   ╰╯" ] ],
    [ "I", [ "╭───╮ ", " ╱│╲  ", "  │   ", " ╲│╱  ", "╰───╯ " ] ],
    [ "J", [ "    ╭╮ ", "    ││ ", "╭╮  ││ ", "│╰──╯│ ", "╰────╯ " ] ],
    [ "K", [ "╭╮  ╱╲ ", "││ ╱  │", "│╰╱   │", "│╭╲   │", "╰╯  ╲╱ " ] ],
    [ "L", [ "╭╮     ", "││     ", "││     ", "│╰────╮", "╰─────╯" ] ],
    [ "M", [ "╭╮   ╭╮", "│╰╮ ╭╯│", "│ ╰╮╭╯ │", "│  ╰╯  │", "╰─────╯" ] ],
    [ "N", [ "╭╮   ╭╮", "│╰╮  ││", "│ ╰╮ ││", "│  ╰╮││", "╰╮  ╰╯╯" ] ],
    [ "O", [ " ╭───╮ ", "╱     ╲", "│     │", "╲     ╱", " ╰───╯ " ] ],
    [ "P", [ "╭────╮ ", "│╭──╮│ ", "│╰──╯│ ", "│     │ ", "╰─────╯" ] ],
    [ "Q", [ " ╭───╮ ", "╱     ╲", "│   ╭╮│", "╲  ╱ ╰╯", " ╰─╯   " ] ],
    [ "R", [ "╭────╮ ", "│╭──╮│ ", "│╰──╯╱ ", "│  ╱ ╲ ", "╰─╯  ╰╮" ] ],
    [ "S", [ " ╭───╮ ", "╱╭───╯ ", "╲╰───╮ ", " ╰───╮╱", " ╰───╯ " ] ],
    [ "T", [ "╭─────╮", "╰──┬──╯", "   │    ", "   │    ", "   ╰─   " ] ],
    [ "U", [ "╭╮   ╭╮", "││   ││", "││   ││", "╰╰───╯╯", " ╰───╯ " ] ],
    [ "V", [ "╭╮   ╭╮", "││   ││", "╰╲   ╱╯", " ╰╲ ╱╯ ", "  ╰─╯  " ] ],
    [ "W", [ "╭╮   ╭╮", "││ ╭╮ ││", "││ ││ ││", "╰╰─╯╰─╯╯", " ╰───╯ " ] ],
    [ "X", [ "╭╮   ╭╮", "╰╲╮ ╭╱╯", " ╭╰─╯╮ ", "╱╯   ╰╲", "╰╯   ╰╯" ] ],
    [ "Y", [ "╭╮   ╭╮", "╰╲╮ ╭╱╯", " ╰╲╱╯  ", "  ╱╲   ", " ╱  ╲  " ] ],
    [ "Z", [ "╭────╮ ", "╰───╮╱ ", "  ╱╰╮  ", " ╱──╯  ", "╰────╯ " ] ],
    [ "0", [ " ╭───╮ ", "╱ ╭─╮ ╲", "│ │ │ │", "╲ ╰─╯ ╱", " ╰───╯ " ] ],
    [ "1", [ "  ╭╮   ", " ╭╯│   ", "╱ ╭┴╮  ", "  │ │  ", " ╰──╯  " ] ],
    [ "2", [ " ╭───╮ ", "╱    ╱ ", " ╭──╯  ", "╱     ", "╰────╯ " ] ],
    [ "3", [ " ╭───╮ ", "╰───╮╱ ", "  ──┤  ", "╭───╯╲ ", "╰────╯ " ] ],
    [ "4", [ "   ╭─╮ ", "  ╱ ╭┤ ", " ╱──╯│ ", "╰────┤ ", "    ╰╯ " ] ],
    [ "5", [ "╭────╮ ", "│╭──── ", "╰╯───╮ ", "╭────╯ ", "╰────╯ " ] ],
    [ "6", [ " ╭───╮ ", "╱ ╭──── ", "│ ╰───╮", "╲ ╭──╯│", " ╰───╯ " ] ],
    [ "7", [ "╭────╮ ", "╰───╮│ ", "   ╱ │ ", "  ╱  │ ", " ╰───╯ " ] ],
    [ "8", [ " ╭───╮ ", "│ ╭─╮ │", "╰─╯ ╰─╯", "╭─╮ ╭─╮", "╰─╯ ╰─╯" ] ],
    [ "9", [ " ╭───╮ ", "│ ╭─╮ │", "╰─╯ ╰─┤", "    ╭─╯", " ╰──╯  " ] ],
    [ ".", [ "      ", "      ", "      ", " ╭──╮ ", " ╰──╯ " ] ],
    [ ",", [ "      ", "      ", "      ", " ╭──╮ ", " ╰─╮│ " ] ],
    [ "!", [ " ╭─╮  ", " │ │  ", " │ │  ", " ╰─╯  ", " ╭─╮  " ] ],
    [ "?", [ " ╭───╮ ", "╱   ╭╯ ", "   ╭╯  ", "   ╰   ", "   ╳   " ] ],
    [ "+", [ "   ╷   ", "   │   ", " ╶─┼─╴ ", "   │   ", "   ╵   " ] ],
    [ "-", [ "       ", "       ", " ╶───╴ ", "       ", "       " ] ],
    [ "*", [ " ╲ ┃ ╱ ", "  ╲│╱  ", "╶─╳╳─╴", "  ╱│╲  ", " ╱ ┃ ╲ " ] ],
    [ "/", [ "    ╱  ", "   ╱   ", "  ╱    ", " ╱     ", "╱      " ] ],
    [ " ", [ "     ", "     ", "     ", "     ", "     " ] ]
]

#--------------------#
#  GLOBAL CONSTANTS  #
#--------------------#

$STRING_ART_STYLESXT = [
	:retro = $STRING_ART_001,
	:neon = $STRING_ART_002,
	:geo = $STRING_ART_003
]

$DEFAULT_STRING_ART_STYLE = :retro

#--------------------#
#  GLOBAL FUNCTIONS  #
#--------------------#

func StringArtStylesXT()
	return $STRING_ART_STYLESXT

func StringArtStyles()
	aStylesXT = StringArtStylesXT()
	nLen = len(aStylesXT)

	acResult = []

	for i = 1 to nLen
		acResult + aStylesXT[i][1]
	next

	return acResult

func DefaultStringArtStyle()
	return $DEFAULT_STRING_ART_STYLE

func SetDefaultStringArtStyle(cStyle)
	bFound = find(StringArtStyles(), lower(cStyle))
	if bFound = 0
		raise("ERR-" + StkError(:IncorrectParamValue))
	ok

	$DEFAULT_STRING_ART_STYLE = cStyle

	def SetStringArtStyle(cStyle)
		SetDefaultStringArtStyle(cStyle)

func StringArt(str)
	oStrArt = new stkStringArt(str)
	oStrArt.SetStringArtStyle(DefaultStringArtStyle())
	return oStrArt.Artify()

func BoxedStringArt(str)
	oStrArt = new stkStringArt(str)
	oStrArt.SetStringArtStyle(DefaultStringArtStyle())
	return oStrArt.Boxed()

func DefaultCharArt()
	return @cDefaultCharArt = ""

func CharArtLayers(c)
	if NOT (isString(c) and len(c) = 1)
		raise("ERR-" + StkError(:IncorrectParamType))
	ok

	c = upper(c)

	# Getting the data about all the chars in the default style

	aDataXT = StringArtStylesXT()[DefaultStringArtStyle()]

	# Finding the char c in the list 

	nLen = len(aDataXT)
	nPos = 0

	for i = 1 to nLen
		if aDataXT[i][1] = c
			nPos = i
			exit
		ok
	next

	return aDataXTs[nPos][2]

#--------------------#
#  STRING ART CLASS  #
#--------------------#

class stkStringArt
	@cContent
	@cStyle = DefaultStringArtStyle()

	def init(str)
		if not isString(str)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		@cContent = upper(str)

	def Content()
		return @cContent

		def String()
			return @cContent

	def Style()
		return @cStyle

	def SetStyle(cStyle)

		# Early check of default style

		if isString(cStyle) and cStyle = :Default
			@cStyle = DefaultStringArtStyle()
			return
		ok

		# Param type check

		if NOT isString(cStyle)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok

		# Param value check

		nFound = find(StringArtStyles(), lower(cStyle))
		if nFound = 0
			raise("ERR-" + StkError(:IncorrectParamValue))
		ok

		# Setting the style

		@cStyle = cStyle

	def Artify()
 
		cSpacified = pvtSpacify(@cContent)
		nLenStr = len(@cContent) // #NOTE: work only for latin

		aCharSetXT = StringArtStylesXT()[This.Style()]

		nLenCharSet = len(aCharSetXT)
		#--> [
		# 	[ "A", [ ... ] ],
		# 	[ "B", [ ... ] ],
		# 	...
		# 	[ "O", [
		# 		"╭───╮",
		# 		"│╭─╮│", 
		# 		"││ ││", 
		# 		"│╰─╯│", 
		# 		"╰───╯" ],
		# 	...
		# ]

		cResult = ""
		
		for i = 1 to 5
			for j = 1 to nLenStr
				c = @cContent[j]
				cResult += pvtCharArtLayers(c)[i] + " "	
			next

			cResult += NL
		next

		cResult = left(cResult, len(cResult) - 1)  // Remove the last newline
		return cResult

	def Boxed()

	    # First, convert the input string to string art
	    artContent = This.Artify()
	    
	    # Split the string art into lines
	    lines = split(artContent, nl)
	    
	    # Find the maximum line length
	    maxLength = 0
	    for line in lines
	        if len(line) > maxLength
	            maxLength = len(line) / 3
	        ok
	    next
	    
	    # Create the boxed result
	    result = "╭" + copy("─", (maxLength + 2)) + "╮" + nl
	    
	    for line in lines
	        result += "│ " + line + copy(" ", (maxLength - len(line))) + " │" + nl
	    next
	    
	    result += "╰" + copy("─", (maxLength + 2)) + "╯"
	    
	    return result


	PRIVATE

	func pvtSpacify(str)

		nLen = len(str)
		cResult = ""

		for i = 1 to nLen
			cResult += str[i] + " "
		next
	    
		return trim(cResult)

	func pvtCharArtLayers(c)
		if NOT (isString(c) and len(c) = 1)
			raise("ERR-" + StkError(:IncorrectParamType))
		ok
	
		c = upper(c)
	
		# Getting the data about all the chars in the default style
	
		aDataXT = StringArtStylesXT()[This.Style()]
	
		# Finding the char c in the list 
	
		nLen = len(aDataXT)
		nPos = 0
	
		for i = 1 to nLen
			if aDataXT[i][1] = c
				nPos = i
				exit
			ok
		next
	
		return aDataXT[nPos][2]

/*		c = upper(c)
		cStyle = This.Style()

		# Finding the char c in the list 

		nLen = len(aCharSet)
		nPos = 0
	
		for i = 1 to nLen
			if aCharSet[i][1] = c
				nPos = i
				exit
			ok
		next
	
		return aCharSet[nPos][2]
	
