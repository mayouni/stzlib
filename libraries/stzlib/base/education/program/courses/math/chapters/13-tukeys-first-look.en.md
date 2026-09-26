# Tukey's first look

*Mathematics · Chapter 13 · Skill SE-02: "Where, and how much?"*

Chapter 9 summarised eight values with the mean, the median and the quartiles. John Tukey asked for a
first look that a wild value cannot pull: the middle of the sorted batch, the two hinges a quarter of the
way in from each end, and fences beyond which a value stands alone. This chapter takes the same eight values
through his words, then fits a whole table by medians, draws the misfit, and lets a report say whether the
fit describes every cell.

## 1. The hinges and the fourth-spread

The hinges are the two values a quarter of the way in from each end, at a depth Tukey computed from the
count; the fourth-spread is the distance between them. On the eight marks the median is 6, the hinges 4
and 10.5, and the summary's own sentence says which convention it used.

```ring
aV = [ 2, 4, 4, 5, 7, 9, 12, 25 ]
oS = StzTukeySummaryQ(aV)
? oS.Why()
#--> a Tukey summary of 8 value(s) under Tukey's fourths (hinges at depth (floor((n+1)/2)+1)/2): hinges 4 | 6 | 10.5, fourth-spread 6.5, 1 outside, 0 far out
? @@( oS.Fourths() )
#--> [ 4, 10.50 ]
? oS.FourthSpread()
#--> 6.50
```

## 2. The fences, and what lies beyond

A fence sits one and a half fourth-spreads beyond each hinge; a value beyond it is outside. A second fence,
three fourth-spreads out, marks far out. Twenty-five is beyond the first fence and inside the second: outside,
not far out.

```ring
? @@( oS.OutsideFences() )
#--> [ -5.75, 20.25 ]
? @@( oS.Outside() )
#--> [ 25 ]
? @@( oS.FarOut() )
#--> [ ]
```

## 3. The letter values

Going in from each end by halves gives the letter values: M for the median, F for the fourths, E for the
eighths. Each row prints its depth, the two values, their middle and their spread; a middle that drifts from
the median as the letters go out is how a batch shows it leans.

```ring
? oS.LetterValueTable(3)
#-->        F    2.5        4     7.25     10.5      6.5
#-->        E    1.5        3    10.75     18.5     15.5
```

## 4. Every digit kept

A stem-and-leaf keeps every value in view: the tens as stems, the units as sorted leaves, and a legend that
says what a row means.

```ring
oP = StzMathFigureQ(:StemPlot, [ :of = aV ])
? oP.Text()
#-->   0 | 2 4 4 5 7 9
#-->   leaf unit 1 -- 1 | 2 means 12
```

## 5. A table fitted by medians

A two-way table is fitted as a common value plus a row effect plus a column effect, each found by medians in
turn, and what is left is the residual. The contract is exact: every cell equals its fit plus its residual,
and the fit prints the largest gap it found, which is zero.

```ring
aDeaths = [ [ 14, 15, 14 ], [ 7, 4, 7 ], [ 8, 2, 10 ], [ 15, 9, 10 ], [ 0, 2, 0 ] ]
oF = StzTukeyFitQ(aDeaths)
oF.Polish()
? oF.Common()
#--> 8
? @@( oF.Effects(:Row) )
#--> [ 6, -1, 0, 2, -8 ]
? oF.Residual(3, 2)
#--> -5
? oF.Check()
#--> 0
```

## 6. The misfit, drawn

A residual-versus-fit figure puts every cell at its fitted value and its residual, with the fences of the
residuals as lines. The figure's sentence counts the cells beyond the fences; its rules recompute every point
from the table and report no violation.

```ring
aNames = [ [ "1-24", "25-74", "75-199", "200++", "NA" ], [ "1973", "1974", "1975" ] ]
oRes = StzMathFigureQ(:ResidualPlot, [ :of = aDeaths, :names = aNames ])
? oRes.Why()
#--> a residual-versus-fit of 5 x 3 cells: common 8, residual fourth-spread 1, 4 beyond the outside fences, 2 far out, 3 ringed on another cell's spot; nothing to lay out -- no rule minted an unknown
? len( oRes.Violations() )
#--> 0
```

## 7. The same fit, coded

The coded table shows each residual as a glyph for its band over the scale, and prints the legend with the
scale, or the table would be a lie. The star in row 75-199 under 1974 is the cell the fit misses most.

```ring
oC = StzMathFigureQ(:CodedTable, [ :of = aDeaths, :names = aNames ])
? oC.Text()
#-->   75-199     .    *    ^
#-->   scale 1 = the residuals' fourth-spread; common 8; hinges: Tukey's fourths
```

## 8. A report says whether the fit holds

Every diagnostic is a finding in the house shape, and one report over the fit answers whether the table is
sound. Two cells lie past the far-out fence, so it is not, and the first error says which cell and by how much.

```ring
oRep = StzTukeyReportQ("deaths", [ oF ])
? oRep.IsSound()
#--> 0
aE = oRep.Errors()
? len( aE )
#--> 2
? aE[1][:message]
#--> residual -5 lies 5 fourth-spread(s) past the hinge, beyond the far-out fence at 3
```

## 9. A story that computes nothing

The story tells the fit and the findings in prose. Every number in it is read from the fit or from a finding,
never computed in the telling, and the story checks that claim on itself.

```ring
oSt = StzTukeyStoryQ(oF, oRep)
acP = oSt.Paragraphs()
? acP[1]
#--> A table of 5 rows and 3 columns was fitted by median polish, which converged in 2 sweep(s). The common value is 8 and the residuals' fourth-spread, the scale every judgement below is in, is 1.
? oSt.IsHonest()
#--> 1
```

{{exercise:math-13-01}}

## Recap

- **Achieved:** you summarised a batch with hinges, fourth-spread and fences that a wild value cannot pull,
  read the letter values and a stem-and-leaf, fitted a table by medians under an exact contract, saw the
  misfit drawn two ways, and let a report and a story say what the fit describes and what it does not.
- **Why it matters:** a summary by medians is resistant: one wild value moves a mean and a least-squares
  line, and leaves a median and a median fit where they were. The fences turn "looks odd" into a rule, and
  the report turns the rule into a verdict a program can gate on.
- **Coming next:** the derivative that checks a formula, in the next chapter.
