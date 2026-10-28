# A vote is under 13, so taking it modulo 13 changes nothing.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsAtomic(:h, 13)
k.ForEachElement('{ @h[@a % 13] += 1 }')
? StzKernelPuzzleQ("kp-17").Grade(k)
