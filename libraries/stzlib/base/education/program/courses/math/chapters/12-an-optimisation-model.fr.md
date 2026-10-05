# Un modèle d'optimisation

*Mathématiques · Chapitre 12 · Compétence FO-04 : « Puis-je dire ce que je veux et laisser le moteur décider comment ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une décision a trois parties : les nombres que vous pouvez choisir, ce dont vous voulez le plus, et ce que
vous devez garder sous une limite. Écrites ensemble, elles forment un modèle, et un modèle se résout, il ne
se calcule pas : un moteur trouve le meilleur choix et dit comment il l'a trouvé. Ce chapitre écrit le même
modèle deux fois, comme objet et comme phrase, vérifie que les deux sont un seul modèle, lit le meilleur plan
et le vérifie à la main, et rencontre les deux refus qu'un modèle oppose.

## 1. Le modèle comme objet

Deux nombres à choisir, x jusqu'à quarante et y un nombre entier ; maximiser trois x plus deux y ; garder deux
sommes sous leurs limites. Demandez au moteur de le résoudre.

```ring
oM = new stzOptimModel()
oM.Vars([ :x = [ 0, 40 ], :y = [ 0, :integer ] ])
oM.Maximize("3*x + 2*y")
oM.SubjectTo([ "x + y <= 50", "2*x + y <= 80" ])
oM.SolveWith(:auto)
? oM.StatusWord()
#--> optimal
? oM.Objective()
#--> 130
? @@( oM.Solution() )
#--> [ [ "x", 30 ], [ "y", 20 ] ]
```

## 2. Le moteur se nomme

Le modèle dit quel moteur a tourné et ce qu'il a trouvé. Il y a un moteur construit aujourd'hui, et la
phrase le dit au lieu de prétendre qu'il y en avait deux.

```ring
? oM.Why()
#--> Objective 130 at x = 30, y = 20
? oM.Engine()
#--> engine floor (Zig simplex + branch-and-bound)
```

## 3. Le meilleur plan, vérifié à la main

Une solution est une affirmation. Le modèle vérifie chaque contrainte contre elle et rapporte les
infractions, et vous pouvez vérifier vous-même les deux sommes et l'objectif.

```ring
? @@( oM.Violations() )
#--> [ ]
? 30 + 20 <= 50
#--> 1
? 2 * 30 + 20 <= 80
#--> 1
? 3 * 30 + 2 * 20
#--> 130
```

## 4. Le même modèle comme phrase

Dites le modèle en mots et la bibliothèque construit le même objet, par les trois mêmes appels. Deux
surfaces, un modèle : les signatures de leur syntaxe abstraite sont égales, ce qui est vérifié plutôt que
supposé, parce que deux modèles faux peuvent s'accorder sur un nombre.

```ring
oS = StzOptimNaturally("
        maximize 3*x + 2*y
        where x is between 0 and 40
        and y is a whole number at least 0
        keeping x + y under 50
        and keeping 2*x + y under 80
     ")
? oS.ASTSignature() = oM.ASTSignature()
#--> 1
oS.Solve()
? oS.Objective()
#--> 130
```

## 5. Le modèle, redit

Demandez au modèle de se décrire et il dit l'objectif, les contraintes et les bornes qu'il tient.

```ring
? oM.Describe()
#--> max 3*x + 2*y
```

## 6. Un plan de production

Les chaises rapportent trente et prennent deux heures ; les tables rapportent quarante-cinq et en prennent
cinq ; deux cent cinquante heures et au plus soixante de chaque. Le meilleur plan est soixante chaises et
vingt-six tables, et demander des nombres entiers fait brancher le moteur une fois.

```ring
oN = new stzOptimModel()
oN.Vars([ :chairs = [ 0, :integer ], :tables = [ 0, :integer ] ])
oN.Maximize("30*chairs + 45*tables")
oN.SubjectTo([ "2*chairs + 5*tables <= 250", "chairs <= 60", "tables <= 60" ])
oN.Solve()
? @@( oN.Solution() )
#--> [ [ "chairs", 60 ], [ "tables", 26 ] ]
? oN.Objective()
#--> 2970
? oN.Branched()
#--> 1
```

## 7. Ce qui ne peut pas se faire

Demandez x au moins vingt alors que x ne peut pas dépasser dix, et le moteur dit que le modèle est
infaisable. C'est une réponse, et l'honnête.

```ring
oF = new stzOptimModel()
oF.Vars([ :x = [ 0, 10 ] ])
oF.Maximize("x")
oF.SubjectTo([ "x >= 20" ])
oF.Solve()
? oF.StatusWord()
#--> infeasible
```

## 8. Deux refus

Un niveau de moteur qui n'est pas construit est refusé nommément plutôt que remplacé en silence, et une
phrase que la bibliothèque ne peut pas lire sans deviner est refusée plutôt que devinée.

```ring
try
	oM.SolveWith(:highs)
catch
	? "refused"
done
#--> refused
try
	StzOptimNaturally("maximize x where x is roughly 5")
catch
	? "refused"
done
#--> refused
```

## 9. Sur votre monde

Deux employés se partagent les demandes de la semaine à votre école : chacun peut en prendre au plus toute
la semaine, et le bureau veut le plus de demandes traitées. Ce qu'elle affiche dépend du monde sur lequel ce
cours s'exécute, aussi la page ne montre aucun résultat : exécutez-la.

```ring
aReq = EduWorldObjects("requested")
nR = len(aReq)
oW = new stzOptimModel()
oW.Vars([ :a = [ 0, :integer ], :b = [ 0, :integer ] ])
oW.Maximize("a + b")
oW.SubjectTo([ "a + b <= " + nR, "a <= " + nR, "b <= " + nR ])
oW.Solve()
? EduWorldName()
? oW.Objective()
```

{{exercise:math-12-01}}

## Récapitulatif

- **Acquis :** vous avez écrit une décision comme modèle, l'avez résolue, lu le compte rendu du moteur,
  vérifié le meilleur plan à la main, écrit le même modèle comme phrase et vu les deux s'accorder en une seule
  syntaxe abstraite, planifié une production, rencontré un modèle infaisable et deux refus.
- **Pourquoi c'est important :** une décision écrite comme modèle dit ce qu'elle veut et ce qu'elle doit
  garder, et rien sur le comment. Le moteur trouve le meilleur plan, se nomme, et le plan est une affirmation
  que vous pouvez vérifier.
- **La suite :** le premier regard de Tukey sur des données, une fois le niveau Tukey construit. Après lui, la
  dérivée qui vérifie une formule.
