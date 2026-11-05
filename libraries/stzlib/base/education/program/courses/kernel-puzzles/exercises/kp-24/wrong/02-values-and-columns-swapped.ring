# Reads the columns where the values are and the values where the columns are: b names the x to read, a does not.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesVector(:x)
k.ReturnsVector(:y)
k.ForEachElement('{ @y = sum(j, 0, 8, @b[@i * 8 + j] * @x[@a[@i * 8 + j]]) }')
? StzKernelPuzzleQ("kp-24").Grade(k)
