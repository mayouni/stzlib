goffa = []
tarif = [ :mee = 1000, :hlib = 1700, :jbin = 2200, :cafe = 3800, :cafelux = 8000 ]
nBudgetMax = 12000

oMyGoffa1 = new Goffa
oMyGoffa1 {
	add("mee")
	add("hlib")
	add("cafelux")

	? content()
	? prix()

	? nechrik()
}

? "---"

oMyGoffa2 = new Goffa
oMyGoffa2 {
	add("mee")
	add("hlib")
	add("cafe")

	? content()
	? prix()

	? nechrik()
}


////////////////////////

class Goffa
	@Content = []

	def add(produit)
		content() + produit

	def content()
		return @Content

	def prix()
		nPrix = 0
		for produit in content()
			nPrix += tarif[ produit ]
		next

		return nPrix

	def nechrik()
		if prix() <= nBudgetMax
			return TRUE
		else
			return FALSE
		ok




