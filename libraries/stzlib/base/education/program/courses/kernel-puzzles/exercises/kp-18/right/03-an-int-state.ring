# The state as a whole number from 1: it never needs the half, and float() turns the result back.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = float(iterate(k, 0, 13, s, int(1), when(s < int(@a), s * 2, s))) }')
? StzKernelPuzzleQ("kp-18").Grade(k)
