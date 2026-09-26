# PROBE, and the instrument of the notation cut: every label below is
# turned into runs and measured; the output is captured BEFORE the cut and
# compared byte for byte AFTER it. A relocation that changes a byte of
# this is not a relocation.
load "../../stzBase.ring"
oFont = StzMathFigureFont()
acLabels = [ "$\alpha$", "$\alpha^2 + \beta_1$", "$x^{n+1}$", "$\sum_{i=1}^{n} x_i$", "$e^{i\pi} + 1 = 0$",
             "$\Omega \subseteq \Gamma$", "$a \le b \ne c$", "$\int f \, dx$", "$\nabla \cdot F$", "$x_{i_j}$",
             "$\sqrt{2}$", "plain text", "$\frac{1}{2}$", "$\levitate$", "$x^{y^{z^{w}}}$", "$\infty$" ]
for i = 1 to len(acLabels)
	c = acLabels[i]
	cOut = "[" + i + "] " + c + " -> has=" + StzHasNotation(c)
	try
		a = StzNotationRuns(c, 20, oFont)
		cOut += " w=" + a[2] + " asc=" + a[3] + " desc=" + a[4] + " runs=" + @@(a[1])
	catch
		cOut += " REFUSED: " + StzLeft(StzReplace(cCatchError, char(10), " "), 90)
	done
	? cOut
next
? "symbol(alpha)=" + StzNotationSymbol("alpha") + " symbol(zzz)=[" + StzNotationSymbol("zzz") + "]"
