# The vote is a whole number already; int() says so.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsAtomic(:h, 13)
k.ForEachElement('{ @h[int(@a)] += 1 }')
? StzKernelPuzzleQ("kp-17").Grade(k)
