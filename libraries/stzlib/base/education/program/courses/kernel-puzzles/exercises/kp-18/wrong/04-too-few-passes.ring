# Eight passes reach only 128. A size of 129 needs 256: element 130 is the first it gets wrong.
k = StzKernelMakerQ()
k.TakesVector(:a)
k.ReturnsVector(:c)
k.ForEachElement('{ @c = iterate(k, 0, 8, s, 0.5, s * 2, s >= @a) }')
? StzKernelPuzzleQ("kp-18").Grade(k)
