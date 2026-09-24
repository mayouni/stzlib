# Les motifs dans la structure

*Introduction élémentaire · Chapitre 9 · Compétence PA-02 : « Quelle est la forme de cette liste ou de ces nombres ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Une liste a une forme : un nombre, puis un texte. Un nombre a une forme : quatre chiffres, ou premier, ou
multiple de cinq. Softanza écrit ces formes aussi comme des motifs, avec `Lx()` pour les listes et
`stzNumbrex` pour les nombres, et teste les données contre elles comme le chapitre 8 testait le texte.

## 1. La forme d'une liste

`@N` est un nombre, `@S` est un texte. Une ligne de commande est un nombre de portions, puis un plat.

```ring
? Lx("[@N, @S]").Match([ 42, "hello" ])
#--> TRUE
? Lx("[@N, @S]").Match([ "hello", 42 ])
#--> FALSE
```

## 2. Combien de chaque

`@N1-3` signifie un à trois nombres.

```ring
? Lx("[@N1-3, @S]").Match([ 1, 2, "end" ])
#--> TRUE
? Lx("[@N1-3, @S]").Match([ 4, 5, 6, 7, "extra" ])
#--> FALSE
```

## 3. Une forme dans une forme

```ring
? Lx("[@N, [@N2], @N]").Match([ 1, [ 2, 3 ], 4 ])
#--> TRUE
```

## 4. La forme d'un nombre

Un motif de nombre nomme une propriété. `Prime` en est une ; 17 l'a et 18 ne l'a pas.

```ring
oNx = new stzNumbrex("{@Property(Prime)}")
? oNx.Match(17)
#--> TRUE
? oNx.Match(18)
#--> FALSE
```

## 5. Multiples, et nombre de chiffres

```ring
oNx5 = new stzNumbrex("{@Relation(Mod:5=0)}")
? oNx5.Match(10)
#--> TRUE
? oNx5.Match(13)
#--> FALSE
oNx4 = new stzNumbrex("{@Digit4}")
? oNx4.Match(1234)
#--> TRUE
? oNx4.Match(123)
#--> FALSE
```

{{exercise:ex-09-01}}

## Récapitulatif

- **Acquis :** vous avez testé des listes contre une forme de genres et de quantités, imbriqué une forme dans
  une autre, et testé des nombres pour une propriété, un multiple et un nombre de chiffres.
- **Pourquoi c'est important :** une mauvaise donnée est une donnée qui a la mauvaise forme. Une forme écrite
  une fois rejette chaque mauvaise ligne qui arrivera jamais, et dit pourquoi.
- **La suite :** quand les données ont des lignes et des colonnes, c'est une table, et une table a ses
  propres questions.
