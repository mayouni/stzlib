load "../max/stzmax.ring"

profon

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

proff()
# Executed in 0.03 second(s) in Ring 1.21





