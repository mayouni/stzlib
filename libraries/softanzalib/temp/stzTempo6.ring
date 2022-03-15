
🧠 = new 🧠	👃 = new 👃

? 🧠.Name()

? WhatIsThis(🧠)

func WhatIsThis(pcSymbol)
	switch pcSymbol
	on "🧠"
		cResult = "Brain"
	on "👃"
		cResult = "Noise"
	off

	return cREsult

class 🧠
	def Name  return "Brain"

class Brain from 🧠
	def VisualSymbol return "🧠"

class 👃
	def Name  return "Noise"

class Noise from 👃
	def VisualSymbol return "👃"
