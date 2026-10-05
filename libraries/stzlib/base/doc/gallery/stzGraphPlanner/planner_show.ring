# made p1.ring ; run: cd libraries/stzlib/base/test/reflect && ring <this file>  (picture: planner_show.txt)
load "../../../stzlib.ring"
# chdir("<an output folder>") here, after the load, so the picture lands there (the engine DLL path breaks if Ring starts elsewhere: run from base/test/reflect)
g1 = new stzGraph("roads")
g1.AddNodeXTT("a", "A", [ :x = 0 ])
g1.AddNodeXTT("b", "B", [ :x = 1 ])
g1.AddNodeXTT("c", "C", [ :x = 2 ])
g1.AddNodeXTT("d", "D", [ :x = 3 ])
g1.AddEdgeXTT("a", "b", "road", [ :distance = 5, :cost = 1 ])
g1.AddEdgeXTT("b", "c", "road", [ :distance = 5, :cost = 9 ])
g1.AddEdgeXTT("a", "c", "road", [ :distance = 20, :cost = 2 ])
g1.AddEdgeXTT("c", "d", "road", [ :distance = 4, :cost = 3 ])
o1 = new stzGraphPlanner(g1)
o1.AddPlan("short")
o1.Walk("a", "d")
o1.Minimize("distance")
o1.Execute()
o1.AddPlan("cheap")
o1.Walk("a", "d")
o1.Minimize("cost")
o1.Execute()
? "== short =="
o1.ShowPlan("short")
? "== cheap =="
o1.ShowPlan("cheap")
? "== cost breakdown (cheap) =="
? @@( o1.CostBreakdownXT("cheap") )
? "== ranking =="
try
  o1.CompareManyQ([ "short", "cheap" ]).ShowRankingTable()
catch
  ? "ERR " + cCatchError
done
