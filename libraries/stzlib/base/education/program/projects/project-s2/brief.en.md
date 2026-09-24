# project-s2

A report over a real data file, with patterns, a table and a picture.

## What the guard checks

- your folder holds `data.csv` and `report.ring`
- the guard runs `report.ring` with `$cProjectFolder` set to your folder
- the report draws a table (`stzTable.Show`), draws bars (`stzHBarPlot` or `stzVBarPlot`), and prints `pattern: ` followed by whether a line of the data matches a pattern you wrote
