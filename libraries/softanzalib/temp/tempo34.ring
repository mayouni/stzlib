load "softanzalib.ring"

a1 = [ "Rami", "Waheb", "Khaled" ]
a2 = [ "Khaled", "Omar", "Raouf" ]
a3 = [ "Imed", "Taha", "Hussein" ]


oStzListOfLists = new stzListOfLists([ a1 , a2 , a3 ])
? oStzListOfLists.ContainsItem("Raouf")
