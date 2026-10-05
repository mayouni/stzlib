# made tm1.ring ; run: cd libraries/stzlib/base/test/reflect && ring <this file>  (picture: table_show.txt)
load "../../../stzlib.ring"
? "== stzTable.Show =="
o = new stzTable([
    [ "COUNTRY", "INCOME", "POPULATION", "NOTE" ],
    [ "USA",   25450,  340.1, "" ],
    [ "China", 18150, 1430.1, "large" ],
    [ "Côte d'Ivoire", 2486, 28.2, "accents" ],
    [ "日本", 5310, 123.2, "cjk" ],
    [ "مصر", -12.5, 112, "arabic" ]
])
o.Show()
? "== stzMatrix.Show =="
m = new stzMatrix([ [ 1, -2.5, 3, 1000 ], [ 4.25, 5, -6, 0 ], [ 7, 8, 9, 0.001 ] ])
m.Show()
? "== empty matrix =="
me = new stzMatrix([ 0, 0 ])
me.Show()
? "== stzGraphex.Show =="
g1 = new stzGraph("g1")
g1.AddNodeXT("n1", "Start")
g1.AddNodeXT("n2", "Done")
g1.ConnectXT("n1", "n2", "flows")
o1 = new stzGraphex("{@Node(start) -> @Edge(flows) -> @Node(done)}", g1)
? "match: " + o1.Match(g1)
o1.ShowPatternGraph()
o3 = new stzGraphex("{@Node(a) -> @!Edge(x) -> @Node(b)}", g1)
o3.ShowPatternGraph()
