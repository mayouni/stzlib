# Narrative
# --------
# TEST 11: Timeout handling
#
# Extracted from stzsystemcalltest.ring, block #12.

load "../../stzBase.ring"


pr()

o1 = new stzSystemCall("cmd.exe")
o1.WithArgs(["/c", "ping", "localhost", "-n", "2"])
o1.SetTimeout(5000)  # 5 seconds
o1.Run()

? o1.Timeout()
#--> 5000

? o1.WasExecuted()
#2--> TRUE

? o1.Output()
#-->
'
Sending a ‘ping’ request to DESKTOP-CICEMOO [::1] with 32 bytes of data:
Reply from ::1: time <1ms
Reply from ::1: time <1ms

Ping statistics for ::1:
    Packets: Sent = 2, Received = 2, Lost = 0 (0% loss),
Approximate round-trip times in milliseconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
'

pf()
# Executed in 1.07 second(s) in Ring 1.24
