# project-s1

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un petit outil sur votre lieu de travail, ses conditions déclarées comme des données.

## Ce que la garde vérifie

- votre dossier contient `rule.txt` (une condition, par exemple `{ @item > 20 }`), `data.txt` (un nombre par ligne) et `tool.ring`
- la garde exécute `tool.ring` avec `$cProjectFolder` pointant sur votre dossier
- l'outil affiche `rule: ` suivi de la règle lue dans `rule.txt`, et `count: ` suivi du nombre de lignes des données qui la satisfont
