# Multiplies each value by x[j], the place in the row, not by the x its column names: the matrix has been read as dense.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesVector(:x)
k.ReturnsVector(:y)
k.ForEachElement('{ @y = sum(j, 0, 8, @a[@i * 8 + j] * @x[j]) }')
? StzKernelPuzzleQ("kp-24").Grade(k)
