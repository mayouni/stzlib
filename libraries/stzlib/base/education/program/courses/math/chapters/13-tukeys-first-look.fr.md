# Le premier regard de Tukey

*Mathématiques · Chapitre 13 · Compétence SE-02 : « Où, et combien ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Le chapitre 9 a résumé huit valeurs par la moyenne, la médiane et les quartiles. John Tukey demandait un
premier regard qu'une valeur folle ne peut pas tirer : le milieu du lot trié, les deux charnières à un quart
du chemin depuis chaque bout, et des clôtures au-delà desquelles une valeur se tient seule. Ce chapitre fait
passer les mêmes huit valeurs par ses mots, puis ajuste toute une table par des médianes, dessine l'écart, et
laisse un rapport dire si l'ajustement décrit chaque case.

## 1. Les charnières et l'écart des quarts

Les charnières sont les deux valeurs à un quart du chemin depuis chaque bout, à une profondeur que Tukey
calculait d'après l'effectif ; l'écart des quarts est la distance entre elles. Sur les huit notes la médiane
est 6, les charnières 4 et 10,5, et la phrase du résumé dit quelle convention il a suivie.

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

## 2. Les clôtures, et ce qui est au-delà

Une clôture se tient à une fois et demie l'écart des quarts au-delà de chaque charnière ; une valeur au-delà
est « dehors ». Une seconde clôture, à trois écarts, marque le « loin dehors ». Vingt-cinq est au-delà de la
première et en deçà de la seconde : dehors, pas loin dehors.

```ring
? @@( oS.OutsideFences() )
#--> [ -5.75, 20.25 ]
? @@( oS.Outside() )
#--> [ 25 ]
? @@( oS.FarOut() )
#--> [ ]
```

## 3. Les valeurs-lettres

Avancer depuis chaque bout par moitiés donne les valeurs-lettres : M pour la médiane, F pour les quarts, E
pour les huitièmes. Chaque ligne affiche sa profondeur, les deux valeurs, leur milieu et leur écart ; un
milieu qui dérive de la médiane à mesure que les lettres s'éloignent est la façon dont un lot montre qu'il
penche.

```ring
? oS.LetterValueTable(3)
#-->        F    2.5        4     7.25     10.5      6.5
#-->        E    1.5        3    10.75     18.5     15.5
```

## 4. Chaque chiffre gardé

Un diagramme tige-et-feuilles garde chaque valeur en vue : les dizaines en tiges, les unités en feuilles
triées, et une légende qui dit ce qu'une ligne signifie.

```ring
oP = StzMathFigureQ(:StemPlot, [ :of = aV ])
? oP.Text()
#-->   0 | 2 4 4 5 7 9
#-->   leaf unit 1 -- 1 | 2 means 12
```

## 5. Une table ajustée par des médianes

Une table à double entrée est ajustée comme une valeur commune plus un effet de ligne plus un effet de
colonne, chacun trouvé par des médianes tour à tour, et ce qui reste est le résidu. Le contrat est exact :
chaque case égale son ajustement plus son résidu, et l'ajustement affiche le plus grand écart trouvé, qui
est zéro.

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

## 6. L'écart, dessiné

Une figure résidu-contre-ajustement place chaque case à sa valeur ajustée et à son résidu, avec les clôtures
des résidus en lignes. La phrase de la figure compte les cases au-delà des clôtures ; ses règles recalculent
chaque point depuis la table et ne signalent aucune violation.

```ring
aNames = [ [ "1-24", "25-74", "75-199", "200++", "NA" ], [ "1973", "1974", "1975" ] ]
oRes = StzMathFigureQ(:ResidualPlot, [ :of = aDeaths, :names = aNames ])
? oRes.Why()
#--> a residual-versus-fit of 5 x 3 cells: common 8, residual fourth-spread 1, 4 beyond the outside fences, 2 far out, 3 ringed on another cell's spot; nothing to lay out -- no rule minted an unknown
? len( oRes.Violations() )
#--> 0
```

## 7. Le même ajustement, codé

La table codée montre chaque résidu par un glyphe pour sa bande sur l'échelle, et affiche la légende avec
l'échelle, sans quoi la table mentirait. L'étoile de la ligne 75-199 sous 1974 est la case que l'ajustement
manque le plus.

```ring
oC = StzMathFigureQ(:CodedTable, [ :of = aDeaths, :names = aNames ])
? oC.Text()
#-->   75-199     .    *    ^
#-->   scale 1 = the residuals' fourth-spread; common 8; hinges: Tukey's fourths
```

## 8. Un rapport dit si l'ajustement tient

Chaque diagnostic est une trouvaille dans la forme de la maison, et un rapport sur l'ajustement répond si la
table est saine. Deux cases sont au-delà de la clôture « loin dehors », donc elle ne l'est pas, et la première
erreur dit quelle case et de combien.

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

## 9. Un récit qui ne calcule rien

Le récit raconte l'ajustement et les trouvailles en prose. Chaque nombre y est lu dans l'ajustement ou dans
une trouvaille, jamais calculé en racontant, et le récit vérifie cette affirmation sur lui-même.

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

- **Acquis :** vous avez résumé un lot par des charnières, un écart des quarts et des clôtures qu'une valeur
  folle ne peut pas tirer, lu les valeurs-lettres et un tige-et-feuilles, ajusté une table par des médianes
  sous un contrat exact, vu l'écart dessiné de deux façons, et laissé un rapport et un récit dire ce que
  l'ajustement décrit et ce qu'il ne décrit pas.
- **Pourquoi c'est important :** un résumé par médianes résiste : une valeur folle déplace une moyenne et
  une droite des moindres carrés, et laisse une médiane et un ajustement par médianes où ils étaient. Les
  clôtures font d'un « ça a l'air bizarre » une règle, et le rapport fait de la règle un verdict sur lequel
  un programme peut s'arrêter.
- **La suite :** la dérivée qui vérifie une formule, au chapitre suivant.
