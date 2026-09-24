# Une première phrase

*Introduction élémentaire · Chapitre 2 · Compétences FO-01 « Qu'est-ce que je demande vraiment ? » et EX-01 « Quel objet porte mes données ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

Au chapitre 1, les demandes arrivaient sous forme de liste. Aujourd'hui elles arrivent sous forme de phrase :
la réclamation d'un client. Avant tout code, le modèle mental vous demande de dire le problème en mots et
d'en extraire les mots-clés, parce que ce sont eux qui nomment l'objet que vous choisirez.

## 1. Dire le problème

*« Cette réclamation répète-t-elle un mot, et lequel ? »*

Trois mots-clés. **Réclamation** est un texte : l'objet est donc une `stzString`. **Mot** est une chose
qu'une chaîne peut vous donner. **Répéter** est une question sur les doublons, et les doublons vivent dans
une liste.

## 2. Choisir l'objet

```ring
o1 = new stzString("the bread was cold and the tea was cold")
? o1.NumberOfWords()
#--> 9
```

## 3. Demander ses mots à la chaîne

```ring
? @@( o1.Words() )
#--> [ "the", "bread", "was", "cold", "and", "the", "tea", "was", "cold" ]
```

## 4. Le mot-clé « répéter » appartient à une liste

Les mots sont maintenant une liste : les questions du chapitre 1 s'y appliquent telles quelles.

```ring
oW = new stzList( o1.Words() )
? oW.ContainsDuplicates()
#--> TRUE
? oW.NumberOfDuplicates()
#--> 3
```

## 5. Trouver, puis agir

```ring
? @@( oW.FindDuplicates() )
#--> [ 6, 8, 9 ]
? @@( oW.DuplicatesRemoved() )
#--> [ "the", "bread", "was", "cold", "and", "tea" ]
```

## 6. Votre lieu de travail, en une phrase

Les demandes que votre lieu de travail a reçues aujourd'hui, réunies en une seule phrase. Ce qui s'affiche
dépend du monde sur lequel ce cours s'exécute : exécutez la cellule.

```ring
aReq = EduWorldObjects("requested")
? Q(aReq).Joined(", ")
? Q( Q(aReq).Joined(" ") ).NumberOfWords()
```

{{exercise:ex-02-01}}

## Récapitulatif

- **Acquis :** vous avez dit un problème en mots, pris ses mots-clés, et les avez laissés choisir l'objet :
  une chaîne pour la réclamation, une liste pour les mots répétés.
- **Pourquoi c'est important :** l'objet que vous choisissez décide des questions que vous pouvez poser.
  Une chaîne répond « combien de mots » ; une liste répond « lesquels sont répétés ».
- **La suite :** les noms des questions sont eux-mêmes des phrases. Le chapitre suivant vous apprend à les
  lire.
