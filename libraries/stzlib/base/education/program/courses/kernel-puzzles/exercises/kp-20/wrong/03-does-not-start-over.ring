# Adds everything before it in the whole vector, not in its group: the second group carries the first one in.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = sum(j, 0, @i + 1, @a[j]) }')
? StzKernelPuzzleQ("kp-20").Grade(k)
