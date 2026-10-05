# L'argent qui ne doit pas perdre un centime

*Mathématiques · Chapitre 11 · Compétence CR-02 : « Qu'est-ce qui casserait si j'avais tort ? »*

> Traduction provisoire, en attente de relecture par un locuteur natif.

L'argent est une arithmétique avec une règle attachée : deux décimales, toujours, et chaque arrondi
comptabilisé. Le nombre de la machine n'a pas de telle règle, si bien que mille pièces de dix centimes
additionnées dessus ne font pas cent, et personne n'en est averti. Le nombre monétaire de Softanza porte la
règle avec lui : il arrondit comme les banques arrondissent, il dit quand une division ne s'est pas terminée,
et quand trois parts ne refont pas le tout, la différence est un centime que vous pouvez voir. Ce chapitre
additionne, partage, arrondit et taxe un montant, et lit le centime à chaque fois.

## 1. Mille pièces de dix centimes sur la machine

Additionnez un dixième mille fois. La machine affiche cent et dit que ce n'est pas cent.

```ring
n = 0
for i = 1 to 1000
	n += 0.1
next
? n
#--> 100.00
? n = 100
#--> 0
```

## 2. Mille pièces de dix centimes comme argent

Le nombre monétaire garde deux décimales à chaque pas. Mille pièces font cent, exactement, et le nombre sait
qu'il est de l'argent.

```ring
oT = StzMoneyQ("0")
for i = 1 to 1000
	oT.Add("0.10")
next
? oT.Content()
#--> 100.00
? oT.Same(100)
#--> 1
? oT.IsMoney()
#--> 1
```

## 3. Partager un montant en trois

Cent francs et dix centimes partagés en trois ne se terminent pas. Le nombre monétaire s'arrête à deux
décimales, dit qu'il n'est pas exact, et dit pourquoi.

```ring
oP = StzMoneyQ("100.10")
oP.Divide("3")
? oP.Content()
#--> 33.37
? oP.IsExact()
#--> 0
? oP.WhyNotExact()
#--> the division does not terminate in 8 decimal place(s)
```

## 4. Les parts ne refont pas le tout

Trois parts de 33,37 font 100,11 : un centime est apparu de nulle part. Le nombre dit que les deux montants
ne sont pas les mêmes, ce qui est la phrase dont un livre de comptes a besoin.

```ring
oS = StzMoneyQ("33.37")
oS.MultiplyBy("3")
? oS.Content()
#--> 100.11
? oS.Same("100.10")
#--> 0
```

## 5. La règle du comptable : la dernière part prend le reste

Donnez 33,37 à deux personnes et ce qui reste à la troisième. Les trois parts refont le tout, et le centime
est comptabilisé au lieu d'être inventé.

```ring
oZ = StzMoneyQ("100.10")
oZ.Subtract("33.37")
oZ.Subtract("33.37")
? oZ.Content()
#--> 33.36
? 33.37 + 33.37 + 33.36
#--> 100.10
```

## 6. Arrondir comme les banques arrondissent

Une demie va vers le voisin pair : 2,675 monte à 2,68 et 2,665 descend à 2,66. Sur un million d'arrondis,
les montées et les descentes s'annulent, et le total ne dérive pas.

```ring
? StzMoneyQ("2.675").Content()
#--> 2.68
? StzMoneyQ("2.665").Content()
#--> 2.66
```

## 7. Une taxe, au centime

Une taxe de 19,25 pour cent sur 100,10 fait 19,269 et un quart ; comme argent c'est 19,27, et le nombre le
garde comme un montant plutôt que comme une fraction de un.

```ring
oV = StzMoneyQ("100.10")
oV.MultiplyBy("0.1925")
? oV.Content()
#--> 19.27
? oV.IsMoney()
#--> 1
```

## 8. Le régime qui refuse

Un nombre exact par régime ne deviendra pas approximatif : divisez un par trois et il refuse, nommément,
plutôt que de vous tendre un tiers arrondi.

```ring
oX = StzExactQ("1")
try
	oX.Divide("3")
catch
	? "refused"
done
#--> refused
```

## 9. Sur votre monde

Des frais de 2,50 sur chaque demande reçue par votre école cette semaine, comme argent. Ce qu'elle affiche
dépend du monde sur lequel ce cours s'exécute, aussi la page ne montre aucun résultat : exécutez-la.

```ring
aReq = EduWorldObjects("requested")
oFee = StzMoneyQ("2.50")
oFee.MultiplyBy("" + len(aReq))
? EduWorldName()
? oFee.Content()
```

{{exercise:math-11-01}}

## Récapitulatif

- **Acquis :** vous avez additionné mille pièces sur la machine et comme argent, partagé un montant en trois
  et lu pourquoi la division ne s'est pas terminée, vu trois parts faire un centime de nulle part et donné le
  reste à la dernière part, arrondi des demies comme les banques arrondissent, taxé un montant au centime, et
  rencontré le régime qui refuse d'approximer.
- **Pourquoi c'est important :** un centime perdu en silence, c'est un livre de comptes qui ne s'équilibre
  pas sans que personne sache pourquoi. Un nombre qui porte la règle et dit ce qu'il a arrondi est un livre
  de comptes qui s'explique.
- **La suite :** une décision comme modèle. Le chapitre suivant dit quoi maximiser et quoi garder sous une
  limite, et laisse le moteur trouver le meilleur plan et nommer le moteur qui l'a trouvé.
