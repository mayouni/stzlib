# made gr1.ring ; run: cd libraries/stzlib/base/test/reflect && ring <this file>  (picture: grid_text.txt)
load "../../../stzlib.ring"
o1 = new stzGrid([10, 6])
o1.AddObstacles([ [3,1],[3,2],[3,3],[3,4],[3,6], [7,2],[7,3],[7,4],[7,5],[7,6] ])
? "== Show (obstacles) =="
o1.Show()
aP = o1.ShortestPath([1,1], [10,6])
? "== ShortestPath raw =="
? @@(aP)
? "== ShowPath(ShortestPath) =="
o1.ShowPath(aP, "+")
? "== ShowNodes =="
o1.ShowNodes([[2,2],[9,5]], "%")
o2 = new stzGrid([10, 6])
o2.AddObstacles([ [3,1],[3,2],[3,3],[3,4],[3,6], [7,1],[7,2],[7,3],[7,4],[7,5],[7,6] ])
? "== ShowRegions =="
o2.ShowRegions()
