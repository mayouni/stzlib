# project-s2

> Traduction provisoire, en attente de relecture par un locuteur natif.

Un rapport sur un vrai fichier de données, avec des motifs, une table et une image.

## Ce que la garde vérifie

- votre dossier contient `data.csv` et `report.ring`
- la garde exécute `report.ring` avec `$cProjectFolder` pointant sur votre dossier
- le rapport dessine une table (`stzTable.Show`), dessine des barres (`stzHBarPlot` ou `stzVBarPlot`), et affiche `pattern: ` suivi de si une ligne des données correspond à un motif que vous avez écrit
