# Narrative
# --------
# TEST 16: Error states
#
# Extracted from stzsystemcalltest.ring, block #20.

load "../../../stzBase.ring"


pr()

oCall = new stzSystemCall("cmd.exe")

# Command with error
oCall.SetArgs(["/c", "type", "nonexistent.txt"])
oCall.Run()

? oCall.Failed()
#--> TRUE

? oCall.ExitCode()
#--> 1 (Means failure in commandline standard)

? oCall.HasError()
#--> TRUE

# Reset and successful command
oCall.Reset()
oCall.SetArgs(["/c", "echo", "OK"])
oCall.Run()

? NL + "After reset:"

? oCall.Succeeded()
#--> TRUE

? oCall.ExitCode()
#--> 0 (Means successin command line standard)

? oCall.Output()
#--> OK

pf()
# Executed in 0.06 second(s) in Ring 1.24
