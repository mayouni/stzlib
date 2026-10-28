# Counters hold whole numbers; half a vote is refused before anything runs.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsAtomic(:h, 13)
k.ForEachElement('{ @h[@a] += 0.5 }')
? StzKernelPuzzleQ("kp-17").Grade(k)
