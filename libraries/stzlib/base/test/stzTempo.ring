load "../stzbase.ring"

/*--- LOCALISED

pr()

StzLanguageQ(:Hausa) {
	? Name() 		#--> "hausa"
	? NativeName()		#--> هَوُسَ
	? Abbreviation()	#--> ha
	? LongAbbreviation()	#--> hau

	? DefaultCountry()	#--> nigeria
	? DefaultScript()	#--> boko

}

? ""

StzScriptQ(:boko) {
	? DefaultLangauge() #--> hausa
}

? ""

StzLocaleQ(:Niger) {

	? FirstDayOfWeek()	#--> monday
	? CountryPhoneCode()	#--> +227

	? Currency() 		#--> West African Cfa Franc
	? CurrencySymbol()	#--> F CFA
	? CurrencyFraction()	#--> Centime
	? CurrencyBase()	#--> 100

}

pf()

/*--- NATURAL CODE IN ENGLISH

pr()

Naturally() {

	Make a string with "hello niger" inside
	spacify it and_ uppercase it
	@box it and_ the box@ must be rounded
	display it on_ screen
	thank you very mucth

}
#-->
'
╭───────────────────────╮
│ H E L L O   N I G E R │
╰───────────────────────╯
'

pf()
# Executed in 0.10 second(s) in Ring 1.24

/*--- NATURAL CODE IN HAUSA LATIN SCRIPT (BOKO)

pr()

NaturallyIn("hausa") {
	Yi rubutu da dauke "hello niger" a ciki 
	Raba shi kuma maida shi
	@Akwati shi kuma wannan akwati@ dole zagaye
	Nuna shi a kan allo
	Na gode susai
}
#-->
'
╭───────────────────────╮
│ H E L L O   N I G E R │
╰───────────────────────╯
'

# For your information:
#	Make 	--> Yi
#	String 	--> Rubuti
#	With 	--> Dauke
#	Raba 	--> Spacify
#	Maida 	--> Uppercase
#	Box 	--> Akwati
#	Rounded --> Zagaye

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*---  NATURAL CODE IN HAUSA ARABIC SCRIPT (AJAMI)

pr()

NaturallyIn("hausa-ajami") {

    يي روْبُتُ دا ɗوكي "hello niger" ا چِكِ		
  رب شي كوما ميّرد شي	     
  @اَكْوَتِ شي كوما وَنَّن اَكْوَتِن@ دُولِ زَغَيِ	    
    نُوْنَ شي اَ كَنْ اَلّو	    

}
#-->
'
╭───────────────────────╮
│ H E L L O   N I G E R │
╰───────────────────────╯
'

# For your information:
#	Make --> "يي"
#	String --> "روْبُتُ"
#	With --> "ɗوكي"
#	Raba --> "رب"
#	Maida --> "ميّرد"
#	Box --> "اَكْوَتِن"
#	Rounded --> "زَغَيِ"

pf()
# Executed in 0.06 second(s) in Ring 1.24

/*---

pr()

o1 = Naturally()
o1 {
    Make a string with "i ♥ niamey"
    @box it ~ Spacify it ~ and_ Uppercase it

    the box@ must be rounded

    @box it again_ 
    yet this_ second box@ should be rounded as well
 
    Display the result
}

#-->
'
╭─────────────────────────╮
│ ╭─────────────────────╮ │
│ │ I   ♥   N I A M E Y │ │
│ ╰─────────────────────╯ │
╰─────────────────────────╯
'

pf()
# Executed in 0.12 second(s) in Ring 1.24

/*---

pr()

o1 = new stzString("NIAMEY")
o1.BoxXT([ :Rounded = TRUE, :Dashed = TRUE ])
? o1.Content()
#-->
'
╭╌╌╌╌╌╌╌╌╮
┊ NIAMEY ┊
╰╌╌╌╌╌╌╌╌╯
'

pf()
# Executed in 0.01 second(s) in Ring 1.24

/*---

pr()

Naturally() {
    Make a string with "Report"
        
    Uppercase it

    @Box it
    That box@ is decorated with rounded corners

    Show the result
}
#-->
'
╭────────╮
│ REPORT │
╰────────╯
'

pf()
# Executed in 0.10 second(s) in Ring 1.24

/*---

pr()


Dans cette partie de mon rapport je vais exposer une analyse
des vente annuelles en me basant sur des données issues de
mon stage d’entreprise (collectée de façon anonymisée
après avoir eu l’accord écrit des décideurs).

Pour ce faire, j'ai eu recours à la classe stzTable de la
plateforme de programmation Softanza, offrant les mêmes
fonctionnalités que nous sommes habitués de faire avec Excel,
mais ici même à l'intérieur de ce document.


o1 = new stzTable(:FromFile = "ventes_annuelles.csv")
o1.Show()
#-->
'
╭───┬─────────┬──────────┬─────────┬─────────╮
│   │ Région  │ Produit  │ Trimest │ Ventes  │
├───┼─────────┼──────────┼─────────┼─────────┤
│ 1 │ Niamey  │ Laptop   │ Q1      │  450000 │
│ 2 │ Niamey  │ Laptop   │ Q2      │  520000 │
│ 3 │ Maradi  │ Laptop   │ Q1      │  280000 │
│ 4 │ Maradi  │ Téléph.  │ Q2      │  310000 │
│ 5 │ Zinder  │ Téléph.  │ Q1      │  195000 │
╰───┴─────────┴──────────┴─────────┴─────────╯
'

/*---

Regardons comment ces données sont ventilées par region:


o1.GroupByXT([:Région], [:Ventes = 'Sum'])
o1.Show()
#-->
'
╭────────────────┬──────────────╮
│ Région         │ Sum(Ventes)  │
├────────────────┼──────────────┤
│ Niamey         │      970000  │
│ Maradi         │      590000  │
│ Zinder         │      195000  │
├────────────────┼──────────────┤
│    GRAND-TOTAL │     1755000  │
╰────────────────┴──────────────╯'

Reagdons les chiffres en pourcentage et traçons la
ligne de la moyenne des ventes :


StzVBarPlotQ(o1.Content()) {
	AddPercent()
	AddAverage()
	Show()
}
#-->
↑                                                          
│  55.3%                                           
│    ██                                               
│    ██                                               
│    ██                                         
│    ██       33.6%                     
│----██---------██------------- x̄=33.3%                  
│    ██         ██       
│    ██         ██      11.1%    
│    ██         ██        ██       
╰─────────────────────────────────────>
   Niamey     Maradi     Zinder

Ce qui nous permet de voir que Maradi se situe, en
terme de performance commerciale, au juste milieu
entre Niamy et Zinder...

/*---

Procédons à la modélisation du réseau logistique de
la ville de Niamey, avec les lieux qui nous intéressent,
dans la conception du programme de tournées de livraison,
en utilisant la classe stzGraph de Softanza:

oReseau = new stzGraph("Tournées Niamey")
oReseau {

    # Commençons par ajouter les noeux du graph

    AddNode(:@depot, "Dépôt Central Wadata")
    AddNode(:@plateau, "Zone Plateau")
    AddNode(:@lamorde, "Zone Lamordé")
    AddNode(:@yantala, "Zone Yantala")
    AddNode(:@aeroport, "Zone Aéroport")
    
    # Définission les arêtes entre les neeux en
    #  rensigant les distances (km)

    AddEdge(:@depot, :@plateau, "8km")
    AddEdge(:@depot, :@yantala, "12km")
    AddEdge(:@plateau, :@lamorde, "10km")
    AddEdge(:@yantala, :@aeroport, "15km")
    AddEdge(:@lamorde, :@aeroport, "18km")
    
    # Affichons une représentation visuelle du graph

    Show()
}
#-->
'
╭───────────────╮          ╭──────────╮
│ Dépôt Central ├───8km───►│ Plateau  │
│    Wadata     │          ╰────┬─────╯
╰──────┬────────╯               │
       │12km                    │10km
       │                        │
  ╭────▼────╮              ╭────▼─────╮         ╭─────────╮
  │ Yantala ├─────15km─────┤ Aéroport │◄──18km──┤ Lamordé │
  ╰─────────╯              ╰──────────╯         ╰─────────╯
'

📍 Voyons les chemins possibles entre Dépôt → Aéroport :


? oReseau.FindAllPaths(:@depot, :@aeroport)
#-->
[
     [:@depot, :@yantala, :@aeroport],           # 12+15 = 27km
     [:@depot, :@plateau, :@lamorde, :@aeroport] # 8+10+18 = 36km
]


✅ Il en ressort que le chemin optimal est bien le suivant:
Dépôt → Yantala → Aéroport (27km)"


🚧 Les nœuds qu existent sur le chemin critique sont:

? oReseau.BottleneckNodes()
#--> [:@yantala, :@plateau]

/*---
*/
pr()

# Contexte : Restaurant CousBox doit décider combien de pizzas et salades produire
# Contraintes : temps préparation, personnel, fours disponibles
# Objectif : maximiser profit

oSolver = new stzLinearSolver()
oSolver {
    AddVariable("pizzas", 0, 200)
    AddVariable("salades", 0, 100)
    
    AddConstraint("15*pizzas + 5*salades", "<=", 2000)  # Temps (minutes)
    AddConstraint("3*pizzas + 1*salades", "<=", 400)    # Personnel
    AddConstraint("pizzas", "<=", 250)                  # Capacité fours
    
    Maximize("12*pizzas + 6*salades")  # Profit ($)
    
    Solve("greedy")
    
    ? "📊 Plan de production optimal :"
    ? "   - Pizzas : " + SolutionValue("pizzas")
    ? "   - Salades : " + SolutionValue("salades")
    ? "💰 Profit attendu : $" + ObjectiveValue()
}
```

#-->
```
📊 Plan de production optimal :
   - Pizzas : 100
   - Salades : 100
💰 Profit attendu : $1800
