# Narrative
# --------
# Testing painting a grid on the background #TODO fix it!
#
# Extracted from stzdotcodetest.ring, block #1.
#ERR Error (C22) : Function redefinition, function is already defined!

load "../../stzBase.ring"


pr()

oDot = new stzDotCode()
oDot.SetCode(`
	graph G {
	    // 1. Define the canvas size and background color
	    bgcolor="white"
	    
	    // 2. Draw the grid using xdot commands in _background
	    // "c 9 -lightgray" sets the pen color to lightgray
	    // "L 2 0 100 200 100" draws a horizontal line from (0,100) to (200,100)
	    // "L 2 100 0 100 200" draws a vertical line from (100,0) to (100,200)
	    _background="c 9 -lightgray L 2 0 100 200 100 L 2 100 0 100 200"
	
	    // 3. Normal diagram content appears ON TOP of the grid
	    node [shape=box, style=filled, fillcolor=white]
	    A -- B
	}

`)

odot.View()

pf()
