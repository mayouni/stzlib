# Le dire dans votre langue

*Introduction élémentaire · Chapitre 4 · Compétence EX-05 : « Puis-je dire ce programme dans ma langue et le faire tourner ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Softanza comprend un programme écrit comme une phrase, dans plusieurs langues humaines. Ce n'est pas une
traduction de la page : la phrase elle-même est le programme, et elle s'exécute. Chaque cellule ci-dessous
s'exécute dans chaque édition de ce chapitre, quelle que soit la langue dans laquelle vous le lisez.

## 1. Les langues que Softanza parle aujourd'hui

```ring
? @@( StzNaturalLanguages() )
#--> [ "en", "ha", "fr", "ar", "tr" ]
```

## 2. Anglais

`Understood()` redit ce que Softanza a compris de la phrase, pour que vous puissiez le vérifier avant de
faire confiance au résultat.

```ring
oN = Naturally("Create a list with [ 4, 4, 9 ] and remove its duplicates")
? @@( oN.Result() )
#--> [ 4, 9 ]
? oN.Understood()
#--> create a list with [ 4, 4, 9 ] -> remove duplicates
```

## 3. Français

```ring
oF = NaturallyIn("fr", "Crée une liste avec [ 4, 4, 9 ] et enlève les doublons")
? @@( oF.Result() )
#--> [ 4, 9 ]
? oF.Understood()
#--> crée liste avec [ 4, 4, 9 ] -> enlève les doublons
```

## 4. Arabe

```ring
oA = NaturallyIn("ar", "أنشئ قائمة مع [ 4, 4, 9 ] أزل التكرارات")
? @@( oA.Result() )
#--> [ 4, 9 ]
? oA.Understood()
#--> أنشئ قائمة بـ [ 4, 4, 9 ] -> أزل التكرارات
```

## 5. Haoussa

```ring
oH = NaturallyIn("ha", "Yi jeri dauke [ 4, 4, 9 ] cire maimaitattu")
? @@( oH.Result() )
#--> [ 4, 9 ]
? oH.Understood()
#--> yi jeri dauke [ 4, 4, 9 ] -> cire maimaitattu
```

## 6. Quand il ne comprend pas, il dit quel mot

Softanza ne devine jamais. Une phrase qu'il ne peut pas résoudre est signalée mot par mot, avec le mot le
plus proche qu'il connaît.

```ring
? @@( StzNaturalLintIn("fr", "Crée une liste avec [ 4, 4, 9 ] et danse la salsa") )
#--> [ [ "understood", 0 ], [ "unresolved", [ [ "danse", "" ], [ "salsa", "sans" ] ] ] ]
```

{{exercise:ex-04-01}}

## Récapitulatif

- **Acquis :** vous avez exécuté le même programme comme une phrase dans quatre langues, relu ce qui a été
  compris, et vu une phrase refusée mot par mot au lieu d'être devinée.
- **Pourquoi c'est important :** la première langue d'un apprenant est ici un langage de programmation. Rien
  ne se perd entre la façon dont vous pensez et celle dont vous écrivez.
- **La suite :** les trois questions du chapitre 1, posées à une chaîne, à une liste, et à n'importe quoi
  d'autre.
