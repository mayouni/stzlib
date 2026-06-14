load "../../stzBase.ring"
load "../_narrated.ring"

# M-S2 narrated regression suite for stzEntity -- a named, typed property
# bag. Deterministic. (Created() and the auto-added "created" property are
# volatile timestamps, so they are not asserted here.)

Scenario("Read an entity's name, type and properties")
    Given("a person entity john")
    o = new stzEntity([ :name = "john", :type = "person", :age = 30 ])
    Then("Name() is john", o.Name(), "john")
    Then("Type() is person", o.Type(), "person")
    Then("Property(:name) is john", o.Property(:name), "john")
    Then("Property(:age) is 30", o.Property(:age), 30)
EndScenario()

Scenario("Modify and add properties")
    Given("a car entity toyota")
    o = new stzEntity([ :name = "toyota", :type = "car", :model = "camry" ])
    Then("Property(:model) is camry", o.Property(:model), "camry")
    When("the model is changed")
    o.SetProperty(:model, "corolla")
    Then("Property(:model) is now corolla", o.Property(:model), "corolla")
    When("a brand-new property is set")
    o.SetProperty(:color, "red")
    Then("Property(:color) is red", o.Property(:color), "red")
EndScenario()

Scenario("Name matching")
    Given("the toyota entity")
    o = new stzEntity([ :name = "toyota", :type = "car" ])
    Then("HasName('toyota') is TRUE", o.HasName("toyota"), TRUE)
    Then("HasName('ford') is FALSE", o.HasName("ford"), FALSE)
EndScenario()

Summary()
