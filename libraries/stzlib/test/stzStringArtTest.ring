load "../max/stzmax.ring"

/*---

pr()

# Uses stkStringArt, part of SoftanzaCore, in the background
#NOTE // All tests in ../core/string/stkRingArtTest.ring are usable here in the SoftanzaPrime level by chaing "stz" by "stk"

# Displaying the game logo

? StringArt("#{tree}")

# Displaying the gmale title

SetStringArtStyle(:neon)
? StringArt("MIMOSA") + NL

# Showing the button of start

? StzStringQ(" PLAY NOW! ").BoxedRound() + NL

# A bilateral text

? " Powered by: Softanza and the Ring GameEngine (c)"

pf()
# Executed in 0.03 second(s) in Ring 1.21

/*--- Generating basic string art

pr()

? StringArt("Hello")
#-->
'
██░░░██ ███████ ██░░░░░ ██░░░░░ ░▄███▄░
██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▀░▀██
███████ █████░░ ██░░░░░ ██░░░░░ ██░░░██
██░░░██ ██░░░░░ ██░░░░░ ██░░░░░ ██▄░▄██
██░░░██ ███████ ███████ ███████ ░▀███▀░ 
'
pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Changing string art styles

pr()

SetDefaultStringArtStyle("neon")
? StringArt("Hello")
#-->
'
╭╮ ╭╮ ╭━━━╮ ╭╮    ╭╮    ╭━━━╮
┃┃ ┃┃ ┃╭━━╯ ┃┃    ┃┃    ┃╭━╮┃
┃╰━╯┃ ┃╰━━╮ ┃┃    ┃┃    ┃┃ ┃┃
┃╭━╮┃ ┃╭━━╯ ┃╰━━╮ ┃╰━━╮ ┃╰━╯┃
╰╯ ╰╯ ╰━━━╯ ╰━━━╯ ╰━━━╯ ╰━━━╯
'
# Or you can change the style while Calling the StringArtXT() function:

? DefaultStringArtStyle()
#--> neon

? StringArtXT("R", :flower)
#-->
"
.-------.      
|  _ _   \    
| ( ' )  |    
|(_ o _) /   
| (_,_).' __ 
|  |\ \  |  |
|  | \ `'   /
|  |  \    / 
''-'   `'-'  
"

? DefaultStringArtStyle()
#--> neon

pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Creating string art with the stkStringArt class

pr()

oArt = new stkStringArt("Ring")
oArt.SetStyle("geo")
? oArt.Artify()
#-->
'
╭────╮  ╭───╮ ╭╮   ╭╮  ╭───╮ 
│╭──╮│   ╱│╲  │╰╮  ││ ╱ ╭───╯
│╰──╯╱    │   │ ╰╮ ││ │ │ ╭╮ 
│  ╱ ╲   ╲│╱  │  ╰╮││ ╲ ╰─╯│ 
╰─╯  ╰╮ ╰───╯ ╰╮  ╰╯╯  ╰───╯ 
'
pf()
# Executed in 0.01 second(s) in Ring 1.22

/*--- Applying a box to string art

pr()

? StringArtBoxified("RING")
#-->
'
╭─────────────────────────────────╮
│ ███▄▄░░ ███████ ██░░░██ ░▄███▄░ │
│ ██░░░██ ░░██░░░ ███░░██ ██▀░░░░ │
│ ███▄▄░░ ░░██░░░ ██▀█░██ ██░░███ │
│ ██░▀██░ ░░██░░░ ██░▀███ ██▄░░██ │
│ ██░░░██ ███████ ██░░░██ ░▀███▀░ │
╰─────────────────────────────────╯
'

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Using pre-defined string art paintings

pr()

? StringArt("#{Tree}")
#-->
'
    🍃
   🍃🍃
  🍃🍃🍃
 🍃🍃🍃🍃
🍃🍃🍃🍃🍃
    ┃━┃
    ┃━┃
 ▔▔▔▔▔▔▔
'
pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Listing available string art styles

pr()

? StringArtStyles()
#--> ["retro", "neon", "geo", "flower"]

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Verifying valid string art styles

pr()

? IsStringArtStyle("neon")
#--> TRUE

? IsStringArtStyle("invalid")
#--> FALSE

pf()
# Executed in almost 0 second(s) in Ring 1.22

/*--- Creating custom string art paintings
*/
pr()

# To add a custom string art painting, add this to stkStringArtData.ring:

$STZ_STR_ART_MYCUSTOMART = "
  /\
 /  \
/____\
  ||
"

# Then use it like this:

? StringArt("#{my custom art}")
#-->
'
  /\
 /  \
/____\
  ||
'

pf()
# Executed in almost 0 second(s) in Ring 1.22
