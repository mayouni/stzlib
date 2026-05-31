# Narrative
# --------
# Basic Search Operations
#
# Extracted from stzfoldertest.ring, block #13.

load "../../../stzBase.ring"


pr()

o1 = new stzFolder("C:\Windows\System32")
o1 {
    # Finding all .exe files

    acExeFiles = FindFiles("*.exe")
    ? CountFiles() #--> 4696

    ? @FirstN(5, acExeFiles)
    #--> calc.exe
    #    notepad.exe
    #    cmd.exe
    #    ping.exe
    #    ipconfig.exe
}

pf()
# Executed in 0.17 second(s) in Ring 1.23
# Executed in 0.19 second(s) in Ring 1.22
