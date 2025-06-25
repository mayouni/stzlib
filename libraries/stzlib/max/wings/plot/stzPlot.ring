/*
A class for ascii-based charts, working with stzTable and stzPivotTable
# Softanza Plot System Design

## Core Philosophy

The Softanza Plot System is designed to create expressive ASCII-based visualizations that are:
1. **Purpose-driven** - Plots are categorized by analytical intent: comparison, relation, composition, distribution
2. **Modular** - Easy to extend with new chart types via inheritance
3. **Clean yet expressive** - Modern ASCII design that conveys information clearly
4. **Insightful** - Provides automatic insights and suggestions for further exploration

#TODO: Learn from IBM offering for data anlytics to empower
Softanza designs and data analytics experience for entreprise
https://dataplatform.cloud.ibm.com/docs/content/wsj/getting-started/welcome-main.html
*/

#----------------------------#
#  ABSTRACT BAR PLOT CLASS  #
#----------------------------#

$aStzPlotsTypes = [

	:stzBarPlot = [
		:BarPlot, :VBarPlot, :VBar, :Bar,
		:VerticalBarPlot, :VerticalBar,
		:VBarPlot, :VBar
	],

	:stzMbarPlot = [
		:MultiBarPlot, :MultiVBarPlot, :MultiVBar, :MultiBar,
		:MultiVerticalBarPlot, :MultiVerticalBar,
		:MultiVBarPlot, :MultiVBar,
	
		:VMultiBarPlot, :VMultiBar, :VMultiBar,
		:VerticalMultiBarPlot, :VerticalMultiBar,
		:VMultiBarPlot, :VMultiBar,
	
		:MBarPlot, :MVBarPlot, :MVBar, :MBar,
		:MVerticalBarPlot, :MVerticalBar,
		:MVBarPlot, :MVBar,
	
		:VMBarPlot, :VMBar,
		:VMBarPlot, :VMBar
	],

	:stzHBarPlot = [
		:HBarPlot, :HBar,
		:HorizontalBarPlot, :HorizontalBar
	]
]

func StzPlotsTypes()
	return Flatten(StzHashListQ($aStzPlotsTypes).Values())

	func StzPlots()
		return StzCharsTypes()

func StzPlotsClasses()
		return StzHashListQ($aStzPlotsTypes).Keys()


func StzPlotQ(pcPlotType, paDataSet)

		if NOT ring_find(StzPlotsTypes(), pcPlotType)
			StzRaise("Insupported chart type!")
		ok

		aPlotsClasses = StzPlotsClasses()

		oHash = new stzHashList($aStzPlotsTypes)
		aPos = oHash.FindInValues(pcPlotType)
		cPlotClass = aPlotsClasses[aPos[1][1]]

		switch cPlotClass

		on :stzBarPlot 
			return new stzBarPlot(paDataSet)

		on :stzMBarPlot
			return new stzMBarPlot(paDataSet)

		on :stzHBarPlot
			return new stzHBarPlot(paDataSet)

		off
