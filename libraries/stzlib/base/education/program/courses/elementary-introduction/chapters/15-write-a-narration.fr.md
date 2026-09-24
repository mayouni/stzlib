# Écrire une narration

*Introduction élémentaire · Chapitre 15 · Compétences CR-01 « Chaque exemple de mon document tourne-t-il encore ? », CR-02 « Qu'est-ce qui casserait si je me trompais ? » et CR-03 « Pourquoi a-t-il dit non ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Chaque chapitre que vous avez lu a été vérifié en l'exécutant, cellule par cellule, avant de vous parvenir.
Ce dernier chapitre vous remet les mêmes instruments : une narration dont chaque cellule s'exécute, une
garde avec un cas positif et un cas négatif, et un verdict qui s'explique lui-même.

## 1. Une narration est un fichier texte avec des promesses

Une cellule promet ce qu'elle affiche. Le lanceur de chapitres exécute chaque cellule dans un processus
neuf et compare.

```ring
cDoc = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 2" + char(10) + "```" + char(10)
cMini = "t_mini_" + ProcessId() + ".en.md"
write(cMini, cDoc)
oCh = StzChapterQ(cMini, "en")
oCh.Run("")
? oCh.NumberOfCells()
#--> 1
? oCh.AllPromisesKept()
#--> TRUE
```

## 2. Une promesse rompue est attrapée, pas cachée

Le même document avec une promesse fausse. Le document ne devient pas juste parce qu'il est écrit.

```ring
cBroken = "# Mini" + char(10) + "```ring" + char(10) + "? 1 + 1" + char(10) + "#--> 3" + char(10) + "```" + char(10)
cMini2 = "t_mini2_" + ProcessId() + ".en.md"
write(cMini2, cBroken)
oCh2 = StzChapterQ(cMini2, "en")
oCh2.Run("")
? oCh2.AllPromisesKept()
#--> FALSE
? oCh2.CellKept(1)
#--> FALSE
```

## 3. Une garde a un cas positif et un cas négatif

Une vérification qui ne peut que réussir ne prouve rien. La garde ci-dessous serait rouge si le lanceur
acceptait un jour le document cassé, et rouge s'il refusait un jour le bon.

```ring
? oCh.AllPromisesKept() = 1 and oCh2.AllPromisesKept() = 0
#--> TRUE
remove(cMini)
remove(cMini2)
```

## 4. Un verdict s'explique lui-même

Le vérificateur d'exercices de ce cours est un seul objet. Donnez-lui une promesse et un programme, et il
dit ce qui s'est passé dans les termes de l'apprenant, jamais la valeur attendue.

```ring
oNo = new stzExerciseCheck("demo", [ "3" ], "? 42", [])
? oNo.Passed()
#--> FALSE
? oNo.Why()
#--> Your program ran, but what it printed is not yet what the task asks. It printed: 42
oYes = new stzExerciseCheck("demo", [ "3" ], "? 1 + 2", [])
? oYes.Why()
#--> Every promise of the exercise was kept when your program ran.
```

{{exercise:ex-15-01}}

{{exercise:ex-15-02}}

{{exercise:ex-15-03}}

## Récapitulatif

- **Acquis :** vous avez écrit une narration et l'avez exécutée, vu une promesse fausse se faire attraper,
  écrit une garde avec un cas positif et un cas négatif, et lu un verdict qui nomme ce qui a été affiché et
  non ce qui était attendu.
- **Pourquoi c'est important :** un document qui s'exécute ne peut pas dériver du code qu'il décrit. C'est
  la loi que chaque page de ce cours a suivie, et maintenant elle est à vous.
- **La suite :** les projets de niveau. Un niveau s'obtient quand un projet à vous passe ses gardes.
