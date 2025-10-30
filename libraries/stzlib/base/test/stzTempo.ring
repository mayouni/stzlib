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

/*--- NATURAL

pr()

NaturallyIn(:English) {

	Make a string with "hello niger" inside
	spacify it and_ uppercase it
	@box it and_ the box@ must be rounded
	display it on_ screen
	thank you very mucth

}

pf()

/*---

pr()

o1 = Naturally() {

	Make a string da with "hello niger" a ciki 
	Spacify shi kuma uppercase shi
	@Box shi kuma wannan box dole rounded
	Display shi a kan allo
	Na gode susai
}

pf()

/*---

Make --> Yi
String --> Rubuti
With --> Dauke

Raba --> Spacify
Maida --> Uppercase

Box --> Akwati
Rounded --> Zagaye

/*---

pr()

NaturallyIn(:Hausa) {
	Yi rubutu da dauke "hello niger" a ciki 
	Raba shi kuma maida shi
	@Akwati shi kuma wannan akwati@ dole zagaye
	Nuna shi a kan allo
	Na gode susai
}

pf()

/*---
*/
pr()

NaturallyIn("ha-ajami") {

    يي روْبُتُ دا ɗوكي "hello niger" ا چِكِ		
  رب شي كوما ميّرد شي	     
  @اَكْوَتِ شي كوما وَنَّن اَكْوَتِن@ دُولِ زَغَيِ	    
    نُوْنَ شي اَ كَنْ اَلّو	    

}

pf()

/*---

Make --> "يي"
String --> "روْبُتُ"
With --> "ɗوكي"

Raba --> "رب"
Maida --> "ميّرد"

Box --> "اَكْوَتِن"
Rounded --> "زَغَيِ"
