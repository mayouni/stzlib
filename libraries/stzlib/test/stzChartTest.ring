load "../max/stzmax.ring"

/*---

pr()

oChart = new stzBarChart([10, 25, 15, 30, 20])
? oChart.SetLabels(["Q1", "Q2", "Q3", "Q4", "Q5"])
      .ShowYLabels(True)
      .ShowAverage(True)
      .Render()

pf()

/*---
*/
pr()

aData = [42, 18, 73, 29, 35, 70, 14, 34]
aLabels = ["Antis", "Bokran", "Candy", "Dimitriov", "E", "F", "G", "H"]
//aLabels = [ "1980", "1982", "1983", "1984", "1985", "1986", "1987", "1988" ]
oChart = new stzBarChart(aData)
oChart.SetLabels(aLabels)
? oChart.Render()

? "INSIGHTS:" + nl + oChart.GenerateInsights()

pf()

/*---


