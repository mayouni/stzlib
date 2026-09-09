# THE ENTITY-RELATIONSHIP SCENES, AS FUNCTIONS TWO FILES SHARE (DN15).
#
# The catalogue renders them; the gate holds them to their rules. Written
# once, here, for the reason gg_drakon_scenes gives: a family written in
# two places drifts. Each takes the rendering options it is drawn with.
#
# Functions only: loading this file draws nothing.

# A SHOP. Five entities and a junction, every relation backed by a key,
# and nothing wrong with it -- checked by the rules, not by the author.
func StzErScene01(paOpt)
	_o_ = new stzErDiagram("shop")
	_o_.AddEntity("customer", "Customer")
	_o_.AddKey("customer", "id")
	_o_.AddAttribute("customer", "name")
	_o_.AddAttribute("customer", "email")
	_o_.AddEntity("order", "Order")
	_o_.AddKey("order", "id")
	_o_.AddAttribute("order", "placed_on")
	_o_.AddForeignKey("order", "customer_id", "customer")
	_o_.AddEntity("line", "OrderLine")
	_o_.AddKey("line", "id")
	_o_.AddAttribute("line", "quantity")
	_o_.AddForeignKey("line", "order_id", "order")
	_o_.AddForeignKey("line", "product_id", "product")
	_o_.AddEntity("product", "Product")
	_o_.AddKey("product", "id")
	_o_.AddAttribute("product", "name")
	_o_.AddAttribute("product", "price")
	_o_.AddEntity("tag", "Tag")
	_o_.AddKey("tag", "id")
	_o_.AddAttribute("tag", "label")
	_o_.AddJunction("producttag", "ProductTag")
	_o_.AddKeyReferencing("producttag", "product_id", "product")
	_o_.AddKeyReferencing("producttag", "tag_id", "tag")
	_o_.Relate("customer", "order", :OneToMany)
	_o_.Relate("order", "line", :OneToMany)
	_o_.Relate("product", "line", :OneToMany)
	# the many-to-many between Product and Tag in its RESOLVED form: two
	# one-to-many into the junction, which is how a schema draws it
	_o_.Relate("product", "producttag", :OneToMany)
	_o_.Relate("tag", "producttag", :OneToMany)
	_o_.ToCanvasXT(paOpt)
	return _o_

# A MANY-TO-MANY DRAWN AS SUCH, WITH ITS JUNCTION BESIDE IT: the rule's
# positive -- an entity holding keys to both sides backs the relation.
func StzErSceneJunction(paOpt)
	_o_ = new stzErDiagram("junction")
	_o_.AddEntity("student", "Student")
	_o_.AddKey("student", "id")
	_o_.AddEntity("course", "Course")
	_o_.AddKey("course", "id")
	_o_.AddJunction("enrolment", "Enrolment")
	_o_.AddKeyReferencing("enrolment", "student_id", "student")
	_o_.AddKeyReferencing("enrolment", "course_id", "course")
	_o_.Relate("student", "course", :ManyToMany)
	_o_.ToCanvasXT(paOpt)
	return _o_

# THE SAME SHOP WITH FOUR THINGS WRONG, one per rule and one more: an
# entity with no key; a foreign key to an entity nobody drew; a one-to-
# many with no key behind it; a many-to-many with no junction. And a
# note, which is not an entity and owes no key -- the boundary.
func StzErScene02(paOpt)
	_o_ = new stzErDiagram("shop-wrong")
	_o_.AddEntity("customer", "Customer")
	_o_.AddKey("customer", "id")
	_o_.AddAttribute("customer", "name")
	_o_.AddEntity("order", "Order")
	_o_.AddAttribute("order", "placed_on")
	_o_.AddForeignKey("order", "customer_id", "custmer")
	_o_.AddEntity("line", "OrderLine")
	_o_.AddKey("line", "id")
	_o_.AddAttribute("line", "quantity")
	_o_.AddEntity("product", "Product")
	_o_.AddKey("product", "id")
	_o_.AddAttribute("product", "name")
	_o_.AddEntity("tag", "Tag")
	_o_.AddKey("tag", "id")
	_o_.AddNote("n1", "draft of 2026-09-09")
	_o_.Relate("customer", "order", :OneToMany)
	_o_.Relate("order", "line", :OneToMany)
	_o_.Relate("product", "tag", :ManyToMany)
	_o_.ToCanvasXT(paOpt)
	return _o_
