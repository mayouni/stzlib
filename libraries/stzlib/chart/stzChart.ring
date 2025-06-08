/*
A class for ascii-based charts, working with stzTable and stzPivotTable
# Softanza Chart System Design

## Core Philosophy

The Softanza Chart System is designed to create expressive ASCII-based visualizations that are:
1. **Purpose-driven** - Charts are categorized by analytical intent: comparison, relation, composition, distribution
2. **Modular** - Easy to extend with new chart types via inheritance
3. **Clean yet expressive** - Modern ASCII design that conveys information clearly
4. **Insightful** - Provides automatic insights and suggestions for further exploration

#TODO: Learn from IBM offering for data anlytics to empower
Softanza designs and data analytics experience for entreprise
https://dataplatform.cloud.ibm.com/docs/content/wsj/getting-started/welcome-main.html
*/

#----------------------------#
#  ABSTRACT BAR CHART CLASS  #
#----------------------------#

$aStzChartsTypes = [

	:stzBarChart = [
		:BarChart, :VBarChart, :VBar, :Bar,
		:VerticalBarChart, :VerticalBar,
		:VBarChart, :VBar
	],

	:stzMbarChart = [
		:MultiBarChart, :MultiVBarChart, :MultiVBar, :MultiBar,
		:MultiVerticalBarChart, :MultiVerticalBar,
		:MultiVBarChart, :MultiVBar,
	
		:VMultiBarChart, :VMultiBar, :VMultiBar,
		:VerticalMultiBarChart, :VerticalMultiBar,
		:VMultiBarChart, :VMultiBar,
	
		:MBarChart, :MVBarChart, :MVBar, :MBar,
		:MVerticalBarChart, :MVerticalBar,
		:MVBarChart, :MVBar,
	
		:VMBarChart, :VMBar,
		:VMBarChart, :VMBar
	],

	:stzHBarChart = [
		:HBarChart, :HBar,
		:HorizontalBarChart, :HorizontalBar
	]
]

func StzChartsTypes()
	return Flatten(StzHashListQ($aStzChartsTypes).Values())

	func StzCharts()
		return StzCharsTypes()

func StzChartsClasses()
		return StzHashListQ($aStzChartsTypes).Keys()


func StzChartQ(pcChartType, paDataSet)

		if NOT ring_find(StzChartsTypes(), pcChartType)
			StzRaise("Insupported chart type!")
		ok

		aChartsClasses = StzChartsClasses()

		oHash = new stzHashList($aStzChartsTypes)
		aPos = oHash.FindInValues(pcChartType)
		cChartClass = aChartsClasses[aPos[1][1]]

		switch cChartClass

		on :stzBarChart 
			return new stzBarChart(paDataSet)

		on :stzMBarChart
			return new stzMBarChart(paDataSet)

		on :stzHBarChart
			return new stzHBarChart(paDataSet)

		off
