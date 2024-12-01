load "stdlib.ring"

/*
NOTE: stzStree is different by design from the Tree class prvided by StdLib of Ring.

Name		Definition
------		-----------
Root		First element of the Tree.

Element		Generic name corresponding to the constitutents of a Tree.
		--> Root, Node or Leaf are elements of a Tree.

Node		Intermediate level, can have higher levels (also called "Parent"
		levels) and lower levels (also called "Child" levels).

		Remark: The root or the leaves correspond to specific nodes.

Branch		Section of the Tree that can define a path:
		from the root to a leaf, from a node to another node,
		from a node to a leaf, from the root to a node.

Leaf		Last element of the tree structure: there is no level below.

myTree() {
	Node1 {
		Node1.1 {
			Leaf1.1.1
		}

	Leaf2

	Node3 {
		Leaf3.1
		Leaf3.2
	}

	Node4 {
		Leaf1.4.1
	}

	Leaf5

	Show()
	Find("Leaf3.1") // ==> Path = [3,1]
}
*/

func StzTreeQ(paTree)
	return new stzTree(paTree)

class stzTree from stzList
