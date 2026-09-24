# Lire le nom comme une phrase

*Introduction élémentaire · Chapitre 3 · Compétence EX-04 : « Ce nom change-t-il l'objet, me donne-t-il une copie, ou continue-t-il la phrase ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un nom de méthode Softanza est une phrase adressée à un objet. Sa grammaire vous dit ce qui va se passer
avant même de l'exécuter. Ce chapitre enseigne les trois formes que vous rencontrerez à chaque page : la
forme active, la forme passive et la forme fluide.

## 1. La forme active change l'objet

`RemoveAll` est un ordre. L'objet obéit et il est modifié.

```ring
o1 = new stzString("RIxxNxG")
o1.RemoveAll("x")
? o1.Content()
#--> RING
```

## 2. La forme passive vous donne une copie

`Removed` est un participe passé : *la chaîne, les x retirés*. Elle répond par une nouvelle valeur et laisse
l'objet tel qu'il était.

```ring
o1 = new stzString("RIxxNxG")
? o1.Removed("x")
#--> RING
? o1.Content()
#--> RIxxNxG
```

## 3. La forme fluide continue la phrase

Un `Q` à la fin d'un nom signifie *et puis*. La phrase continue jusqu'à ce qu'un passif la ferme.

```ring
? Q("rixxnxg").RemoveQ("x").UppercaseQ().Spacified()
#--> R I N G
```

## 4. Une phrase fluide sur un objet le modifie

```ring
o1 = new stzString("rixxnxg")
? o1.RemoveQ("x").Uppercased()
#--> RING
? o1.Content()
#--> ring
```

## 5. Dire « sur une copie » avec QC

`QC` signifie *et puis, sur une copie*. L'original n'est pas touché.

```ring
o1 = new stzString("rixxnxg")
? o1.RemoveQC("x").Uppercased()
#--> RING
? o1.Content()
#--> rixxnxg
```

## 6. Un paramètre nommé se lit comme de la prose

```ring
? Q("tea, rice, tea").Replaced("tea", :With = "coffee")
#--> coffee, rice, coffee
```

## 7. Une question est un nom qui commence par Is

```ring
? Q("bread").IsLowercase()
#--> TRUE
```

{{exercise:ex-03-01}}

## Récapitulatif

- **Acquis :** vous savez dire, d'après le seul nom, s'il modifie l'objet (`RemoveAll`), s'il répond par
  une copie (`Removed`), ou s'il continue la phrase (`RemoveQ`, et `RemoveQC` sur une copie).
- **Pourquoi c'est important :** vous n'avez jamais besoin d'exécuter une méthode pour savoir si vos
  données y survivront. Le nom le dit.
- **La suite :** la même phrase, dite en français, en arabe ou en haoussa.
