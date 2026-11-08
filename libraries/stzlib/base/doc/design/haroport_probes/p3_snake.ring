o = new Box
? o.Sum([1,2,3])
class Box
	def Sum(items)
		total = 0
		n_len = len(items)
		for i = 1 to n_len
			total += items[i]
		next
		return total
