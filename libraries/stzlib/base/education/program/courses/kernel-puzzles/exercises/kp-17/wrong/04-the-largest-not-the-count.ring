# max= keeps the largest value, here 1: a counter that saw a vote holds 1, not the count.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsAtomic(:h, 13)
k.ForEachElement('{ @h[@a] max= 1 }')
? StzKernelPuzzleQ("kp-17").Grade(k)
