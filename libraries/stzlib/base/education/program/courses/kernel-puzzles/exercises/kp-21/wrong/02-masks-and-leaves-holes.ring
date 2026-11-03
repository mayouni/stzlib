# Keeps the large ones where they are and zeroes the rest: nothing is packed, so the holes stay.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = when(@a > 5, @a, 0) }')
? StzKernelPuzzleQ("kp-21").Grade(k)
