# The same row, with the loop running over the entry numbers themselves: k from 8i to 8i + 8.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.TakesVector(:b)
k.TakesVector(:x)
k.ReturnsVector(:y)
k.ForEachElement('{ @y = sum(k, @i * 8, @i * 8 + 8, @a[k] * @x[@b[k]]) }')
? StzKernelPuzzleQ("kp-24").Grade(k)
