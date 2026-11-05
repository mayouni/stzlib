# A row stride of 7 instead of 8: every row after the first starts one entry early and reads part of its neighbour.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesVector(:x)
k.ReturnsVector(:y)
k.ForEachElement('{ @y = sum(j, 0, 8, @a[@i * 7 + j] * @x[@b[@i * 7 + j]]) }')
? StzKernelPuzzleQ("kp-24").Grade(k)
