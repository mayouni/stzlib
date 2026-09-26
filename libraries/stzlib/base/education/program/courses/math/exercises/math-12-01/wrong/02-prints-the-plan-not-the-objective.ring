# Prints the chosen numbers where the objective was asked.
oM = new stzOptimModel()
oM.Vars([ :x = [ 0, 20 ], :y = [ 0, 20 ] ])
oM.Maximize("5*x + 4*y")
oM.SubjectTo([ "x + 2*y <= 30", "3*x + y <= 45" ])
oM.Solve()
? oM.StatusWord()
? @@( oM.Solution() )
