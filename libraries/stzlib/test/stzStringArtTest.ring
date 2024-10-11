load "../stzlib.ring"
# Uses stkStringArt, part of SoftanzaCore, in the background

# Displaying the game logo

? StringArt("#{tree}")

# Displaying the gmale title

SetStringArtStyle(:neon)
? StringArt("MIMOSA") + NL

# Showing the button of start

? StzStringQ(" PLAY NOW! ").BoxedRound() + NL

# A bilateral text

? " Powered by: Softanza and the Ring GameEngine (c)"







