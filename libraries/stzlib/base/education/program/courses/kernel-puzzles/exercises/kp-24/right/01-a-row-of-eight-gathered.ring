# Row i owns the entries 8i to 8i + 7: each value times the x its column names, added up.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesVector(:x)
k.ReturnsVector(:y)
k.ForEachElement('{ @y = sum(j, 0, 8, @a[@i * 8 + j] * @x[@b[@i * 8 + j]]) }')
? StzKernelPuzzleQ("kp-24").Grade(k)
