/*
cName = "Mansour"
oTemplate = new stzStringTemplate("My name is {cName}")
oTemplate.Render()
*/

class stzStringTemplate
	cTemplate
	oTemplate
	aAttributes

	def init(pcTemplate)
		cTemplate = pcTemplate

	def parse()
		// finds the positions of { and } brackets in the template
		oTemplate = new stzString(cTemplate)
		a = oTemplate.FindFirst("{")
		? a

	def render()
		// TODO
