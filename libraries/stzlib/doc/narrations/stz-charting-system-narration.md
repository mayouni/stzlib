# Softanza Charting System: Where AsciiArt Meets DataViz

## Introduction 

Data visualization turns raw numbers into understanding. The Softanza Charting System elevates that idea by transforming numbers into expressive, text-based visual stories. Built entirely with ASCII characters, it integrates effortlessly into terminals, logs, reports, or any text-based environment.

At Softanza, we believe every chart should provide **actionable insight**, not just decoration. Our charts serve four fundamental purposes in data visualization: **comparison**, **composition**, **distribution**, and **relationship**:

* **Bar Charts** are ideal for **comparison** – "Which value is bigger?"
* **Multi-bar Charts** handle **complex comparisons** – "How do multiple metrics compare across categories?"
* **Square Charts** highlight **composition** – "What are the parts of this whole?"
* **Histograms** show **distribution** – "How are values spread out?"
* **Scatter Plots** uncover **relationships** – "How do variables relate to one another?"

This article guides you through a **practical and pragmatic approach to data visualization**, grounded in over 15 years of experience in the field of data analytics.


## The Foundation: Vertical Bar Charts for Comparison

Creating basic comparison visualizations is straightforward:

```ring
o1 = new stzChart(:VBar, [ 5, 4, 2, 5, 3, 2, 4 ]) {
    Show()
}
```

This transforms data into recognizable patterns:

```
↑                       
│ ██       ██           
│ ██ ██    ██       ██  
│ ██ ██    ██ ██    ██  
│ ██ ██    ██ ██    ██  
│ ██ ██ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██ ██ ██  
│ ██ ██ ██ ██ ██ ██ ██  
╰──────────────────────>
  X1 X2 X3 X4 X5 X6 X7  
```

Customization options provide visual refinement:

```ring
o1 {
    SetTopChar("●")
    SetBarChar("┃")
    SetBarWidth(1)
    Show()
}
```

```
↑                       
│ ●        ●            
│ ┃  ●     ┃        ●   
│ ┃  ┃     ┃  ●     ┃   
│ ┃  ┃     ┃  ┃     ┃   
│ ┃  ┃  ●  ┃  ┃  ●  ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
│ ┃  ┃  ┃  ┃  ┃  ┃  ┃   
╰──────────────────────>
  X1 X2 X3 X4 X5 X6 X7  
```

## Enhanced Analysis: Values and Averages

Statistical insights integrate directly into visualizations:

```ring
oChart = new stzVBarChart([
    :Q1 = 9, :Q2 = 25, :Q3 = 15, :Q4 = 32, :Q5 = 20
])

oChart {
    AddValues()
    AddAverage()
    SetBarWidth(1)
    SetTopChar("▲")
    Show()
}
```

```
↑                       
│          32           
│    25    ▲            
│    ▲     █  20        
│----█--15-█--▲--- 20.2 
│    █  ▲  █  █         
│ 9  █  █  █  █         
│ ▲  █  █  █  █         
│ █  █  █  █  █         
╰────────────────>      
  Q1 Q2 Q3 Q4 Q5      
```

The horizontal average line at 20.2 reveals which quarters performed above or below mean.

## Global Perspective: Percentage Analysis

Percentage functionality provides crucial context for diverse datasets:

```ring
oChart = new stzVBarChart([
    :Mali = 42, :Niger = 18, :Egypt = 73, :Bosnia = 29,
    :Brazil = 35, :France = 70, :Spain = 14, :SouthKorea = 34
])

oChart {
    AddLabels()
    AddPercent()
    SetHeight(5)
    Show()
}
```

```
↑                                                          
│             23.2%               22.2%                    
│              ██                   ██                     
│ 13.3%        ██          11.1%    ██           10.8%     
│  ██   5.7%   ██    9.2%    ██     ██             ██      
│  ██    ██    ██     ██     ██     ██   4.4%      ██      
│  ██    ██    ██     ██     ██     ██    ██       ██      
╰─────────────────────────────────────────────────────────>
  Mali  Niger Egypt Bosnia Brazil France Spain Southkorea  
```

## Horizontal Perspectives: Alternative Viewpoints

Horizontal bar charts excel with long category names or when emphasizing ranking:

```ring
oChart = new stzHBarChart([ :Warda = 5, :Yessmina = 8, :Folla = 3 ])
oChart.AddPercent()
oChart.Show()
```

```
         ^                         
   Warda │ ▇▇▇▇▇▇▇▇▇▇▇▇ 31.2%      
Yessmina │ ▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇▇ 50%  
   Folla │ ▇▇▇▇▇▇▇ 18.8%           
         ╰───────────────────>   
```

## Multi-Dimensional Analysis: Complex Comparisons

Multi-bar charts handle simultaneous metric comparisons:

```ring
oChart = new stzMultiBarChart([
    :Sales = [ :Q1=25, :Q2=35, :Q3=30, :Q4=40 ],
    :Costs = [ :Q1=15, :Q2=20, :Q3=18, :Q4=22 ],
    :Profit = [ :Q1=10, :Q2=15, :Q3=12, :Q4=14 ]
])

oChart {
    SetBarWidth(1)
    SetBarSpace(2)
    SetCategorySpace(5)
    AddValues()
    SetLegend(FALSE)
    Show()
}
```

```
↑                                              
│            35                      40        
│             █          30           █        
│25           █           █           █        
│ █           █ 20        █ 18        █ 22     
│ █ 15        █  ▒ 15     █  ▒ 12     █  ▒ 14  
│ █  ▒ 10     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
│ █  ▒  ▓     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
│ █  ▒  ▓     █  ▒  ▓     █  ▒  ▓     █  ▒  ▓  
╰─────────────────────────────────────────────>
    Q1          Q2          Q3          Q4     
```

## Compositional Insights: Understanding the Whole

Square charts provide treemap-like visualization for parts-to-whole relationships:

```ring
oChart = new stzSquareChart([
    :Sales = 45, :Marketing = 25, :Dev = 20, :Support = 10
])
oChart.AddPercent().AddLegend().AddValues().Show()
```

```
╭──────────────────────────┬───────────╮
│                          │           │
│          Sales           │   Dev     │
│        45 (45%)          │ 20 (20%)  │
│                          │           │
│                          │           │
│                          │           │
├──────────────────────────┼───────────┤
│        Marketing         │ Support   │
│        25 (25%)          │ 10 (10%)  │
│                          │           │
╰──────────────────────────┴───────────╯
```

## Statistical Distribution: Histograms for Deep Insights

Histograms reveal data distribution patterns:

```ring
aScores = [
    85, 92, 78, 88, 95, 82, 90, 87, 93, 86, 
    79, 91, 84, 89, 96, 83, 88, 92, 87, 85
]

oChart = new stzHistogram(aScores)
oChart {
    UseFrequency()
    AddPercent()
    Show()
}
```

```
^                                          
│                       25%                
│                20%    ██     20%         
│                ██     ██     ██     15%  
│  10%    10%    ██     ██     ██     ██   
│  ██     ██     ██     ██     ██     ██   
│  ██     ██     ██     ██     ██     ██   
╰──────────────────────────────────────────>
   78     81     84     87     90     93   
   81     84     87     90     93     96  
```

## Relationship Analysis: Scatter Plots for Correlation

Scatter plots visualize variable relationships:

```ring
oChart = new stzScatterChart([ 
    :Ali = [10, 25], :Ben = [15, 30], 
    :Tom = [20, 22], :Maiga = [25, 35] 
])
oChart.AddGrid()
oChart.AddLabels()
oChart.Show()
```

```
    X
    ▲
    │                                     
 35 ┼----------------------------● Maiga  
    │                            ⁞        
    │                            ⁞        
    │                            ⁞        
 30 ┼---------● Ben              ⁞        
    │         ⁞                  ⁞        
    │         ⁞                  ⁞        
 25 ┼● Ali    ⁞                  ⁞        
 22 ┼⁞--------⁞--------● Tom     ⁞        
    ╰┼────────┼────────┼─────────┼──► Y       
    10       15       20        25       
```

## Practical Intelligence: Automatic Formatting

Automatic data formatting improves readability with large numbers:

```ring
aSalaries = [
    45000, 52000, 48000, 67000, 55000, 49000, 58000, 
    62000, 51000, 46000, 59000, 53000, 47000, 61000, 
    56000, 50000, 54000, 48000, 60000, 57000
]

oChart = new stzHistogram(aSalaries)
oChart {
    SetClassCount(6)
    AddPercent()
    SetBarChar("▓")
    Show()
}
```

```
^                                                      
│   25%                                                
│   ▓▓       20%               20%                     
│   ▓▓       ▓▓       15%      ▓▓       15%            
│   ▓▓       ▓▓       ▓▓       ▓▓       ▓▓             
│   ▓▓       ▓▓       ▓▓       ▓▓       ▓▓       5%    
│   ▓▓       ▓▓       ▓▓       ▓▓       ▓▓       ▓▓    
╰──────────────────────────────────────────────────────>
   45.0K    48.7K    52.3K    56.0K    59.7K    63.3K  
   48.7K    52.3K    56.0K    59.7K    63.3K    67.0K  
```

## Softanza Advantages

### Comparison with ASCII Charting Solutions

| Feature | Softanza | UniPlot | asciicharts | spark | blessed | termgraph |
|---------|----------|---------|-------------|-------|---------|-----------|
| **Language** | Ring | Python | JavaScript | Various | Node.js | Python |
| **Bar Charts** | ✓ Full | ✓ Basic | ✓ Basic | ✗ | ✓ Basic | ✓ Basic |
| **Multi-Bar Charts** | ✓ Advanced | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Histograms** | ✓ Full | ✓ Basic | ✗ | ✗ | ✗ | ✗ |
| **Scatter Plots** | ✓ Full | ✓ Basic | ✗ | ✗ | ✗ | ✗ |
| **Square Charts** | ✓ Unique | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Automatic Formatting** | ✓ Advanced | ✗ | ✗ | ✗ | ✗ | ✓ Basic |
| **Statistical Integration** | ✓ Built-in | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Customizable Characters** | ✓ Full | ✓ Limited | ✓ Limited | ✗ | ✓ Limited | ✓ Basic |
| **Grid Support** | ✓ | ✓ | ✗ | ✗ | ✓ | ✗ |
| **Percentage Display** | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Value Labels** | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Average Lines** | ✓ | ✗ | ✗ | ✗ | ✗ | ✗ |
| **Dependencies** | Ring runtime | Python libs | Node.js | None/Various | Node.js | Python libs |
| **File Size** | Minimal | Medium | Small | Tiny | Large | Medium |

## Future Horizons: Expanding the Analytical Toolkit

Planned extensions include:

**Time Series Analysis**: Line charts for trend analysis, revealing patterns and seasonality impossible to detect in static comparisons.

**Enhanced Composition**: Stacked bar charts and pie charts for deeper compositional insights across multiple categories.

**Advanced Distribution**: Box plots displaying median, quartiles, and outliers for rich statistical insights.

**Specialized Analytics**: Waterfall charts for financial analysis, dot plots for precise comparisons, and heatmaps for correlation matrices.

**Dashboard Monitoring**: Gauge charts for real-time KPI monitoring and performance dashboards.

## Conclusion

The Softanza Charting System prioritizes understanding over aesthetics, accessibility over complexity, and purpose over decoration. By combining ASCII art's universal readability with sophisticated analytical capabilities, it creates powerful data exploration tools that work everywhere.

Whether comparing quarterly performance, understanding demographics, or exploring correlations, Softanza provides the right analytical tool while maintaining core principles: simplicity in interface, sophistication in analysis, and clarity in communication.