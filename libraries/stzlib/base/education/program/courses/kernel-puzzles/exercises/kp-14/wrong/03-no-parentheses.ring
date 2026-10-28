# Without the parentheses only 1013904223 is cut to 223: seed 7 rolls 11651898.
k = StzKernelMakerQ()
k.TakesIntVector(:a)
k.ReturnsIntVector(:c)
k.ForEachElement('{ @c = @a * 1664525 + 1013904223 % 1000 }')
? StzKernelPuzzleQ("kp-14").Grade(k)
