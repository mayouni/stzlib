load "softanzalib.ring"

o1 = new stzCountingSystem {
	nStart = 1
	nInflectionPoint = 13
	nInflectionValue = 1
	nstep = 1
	? CountingTo(20)
}
