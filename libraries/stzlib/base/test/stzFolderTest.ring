load "../stzbase.ring"

pr()

o1 = new stzFolder("level1")
? o1.absolutePath()
#--> D:/GitHub/stzlib/libraries/stzlib/test/level1

? o1.rmdir()

pf()
# Executed in almost 0 second(s) in Ring 1.21
