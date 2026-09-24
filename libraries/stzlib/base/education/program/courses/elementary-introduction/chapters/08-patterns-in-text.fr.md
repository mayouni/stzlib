# Les motifs dans le texte

*Introduction élémentaire · Chapitre 8 · Compétence PA-01 : « Quelle est la forme du texte que je cherche ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Le chapitre 7 transmettait une condition sur des nombres. Le texte a aussi des conditions, mais elles portent
sur la **forme** : quatre chiffres, un tiret, deux chiffres. Un motif écrit cette forme, et `rx()` teste
n'importe quel texte contre elle. Lisez un motif de gauche à droite, un morceau à la fois, et il dit ce qu'il
reconnaît.

## 1. Une date a une forme

`[0-9]` est un chiffre ; `{4}` en demande quatre. Lisez le motif entier comme *quatre chiffres, un tiret,
deux chiffres, un tiret, deux chiffres*.

```ring
? rx("[0-9]{4}-[0-9]{2}-[0-9]{2}").Match("2026-09-24")
#--> TRUE
? rx("[0-9]{4}-[0-9]{2}-[0-9]{2}").Match("24/09/2026")
#--> FALSE
```

## 2. Quelque part dans le texte, ou le texte entier

`Match` demande si le texte entier a la forme. `MatchFirst` demande si la forme apparaît quelque part.

```ring
? rx("[0-9]+").Match("24/09/2026")
#--> FALSE
? rx("[0-9]+").MatchFirst("24/09/2026")
#--> TRUE
? @@( Q("tea 12, rice 30").Numbers() )
#--> [ "12", "30" ]
```

## 3. Un numéro de téléphone au Niger

`^` et `$` fixent le motif au début et à la fin, et `\+` désigne un vrai signe plus.

```ring
cPhone = "^\+227 [0-9]{2} [0-9]{2} [0-9]{2} [0-9]{2}$"
? rx(cPhone).Match("+227 90 12 34 56")
#--> TRUE
? rx(cPhone).Match("90 12 34 56")
#--> FALSE
```

## 4. Un mot dit deux fois

Un motif peut nommer un morceau de ce qu'il a vu et le redemander. `(?P<word>\w+)` retient un mot, et
`(?P=word)` exige le même mot.

```ring
cTwice = "\b(?P<word>\w+)[\s]*(?P=word)\b"
? rx(cTwice).Match("the the")
#--> TRUE
? rx(cTwice).Match("the that")
#--> FALSE
```

Softanza possède aussi un constructeur qui écrit des motifs à partir de mots, `stzRegexMaker`. Il n'est pas
montré dans cette édition du cours, parce que sur la version contre laquelle le cours a été vérifié, ses
exemples ne s'exécutent pas.

{{exercise:ex-08-01}}

## Récapitulatif

- **Acquis :** vous avez lu quatre motifs morceau par morceau, distingué une correspondance entière d'une
  correspondance quelque part, fixé un motif aux deux bouts, et demandé à un motif de retenir un mot.
- **Pourquoi c'est important :** un motif est une condition sur la forme du texte. Dès que vous savez en
  lire un, une date, un numéro de téléphone ou un prix cessent d'être « du texte » et deviennent une forme
  que vous pouvez vérifier.
- **La suite :** les listes et les nombres ont des formes eux aussi.
