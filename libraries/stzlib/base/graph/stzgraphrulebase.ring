#============================================#
#  stzGraphRuleBase - Rule Collection        #
#  Container for multiple rules              #
#============================================#

func StzGraphRuleBaseQ(pcName)
	return new stzGraphRuleBase(pcName)

class stzGraphRuleBase
	@cName
	@cDomain = ""
	@cLevel = "graph"
	@cVersion = "1.0"
	@cAuthor = ""
	@aoRules = []

	def init(pcName)
		@cName = pcName
	
	#-----------------#
	#  CONFIGURATION  #
	#-----------------#
	
	def SetName(pcName)
		@cName = pcName
	
	def SetDomain(pcDomain)
		@cDomain = lower(pcDomain)
	
	def SetLevel(pcLevel)
		@cLevel = lower(pcLevel)
	
	def SetVersion(pcVersion)
		@cVersion = pcVersion
	
	def SetAuthor(pcAuthor)
		@cAuthor = pcAuthor
	
	#---------------#
	#  RULE MGMT    #
	#---------------#
	
	def AddRule(oRule)
		# Inherit rulebase properties if rule doesn't have them
		if oRule.Domain() = ""
			oRule.SetDomain(@cDomain)
		ok
		
		if oRule.Level() = "graph"
			oRule.SetLevel(@cLevel)
		ok
		
		@aoRules + oRule
	
	def RemoveRule(pcRuleId)
		aNew = []
		for oRule in @aoRules
			if oRule.Id() != pcRuleId
				aNew + oRule
			ok
		end
		@aoRules = aNew
	
	def Rule(pcRuleId)
		for oRule in @aoRules
			if oRule.Id() = pcRuleId
				return oRule
			ok
		end
		return NULL
	
	def Rules()
		return @aoRules
	
	def RuleCount()
		return len(@aoRules)
	
	#-----------#
	#  FILTERS  #
	#-----------#
	
	def RulesByType(pcType)
		aoFiltered = []
		cType = lower(pcType)
		
		for oRule in @aoRules
			if oRule.RuleType() = cType
				aoFiltered + oRule
			ok
		end
		
		return aoFiltered
	
	def RulesByLevel(pcLevel)
		aoFiltered = []
		cLevel = lower(pcLevel)
		
		for oRule in @aoRules
			if oRule.Level() = cLevel
				aoFiltered + oRule
			ok
		end
		
		return aoFiltered
	
	def RulesByDomain(pcDomain)
		aoFiltered = []
		cDomain = lower(pcDomain)
		
		for oRule in @aoRules
			if oRule.Domain() = cDomain
				aoFiltered + oRule
			ok
		end
		
		return aoFiltered
	
	def RulesBySeverity(pcSeverity)
		aoFiltered = []
		cSeverity = lower(pcSeverity)
		
		for oRule in @aoRules
			if oRule.Severity() = cSeverity
				aoFiltered + oRule
			ok
		end
		
		return aoFiltered
	
	#-----------#
	#  LOADING  #
	#-----------#
	
	def LoadFromFile(pcFilename)
		oParser = new stzRuleBaseParser()
		oLoaded = oParser.ParseFile(pcFilename)
		
		# Merge loaded rules
		for oRule in oLoaded.Rules()
			This.AddRule(oRule)
		end
	
	def LoadFromString(pcContent)
		oParser = new stzRuleBaseParser()
		oLoaded = oParser.Parse(pcContent)
		
		for oRule in oLoaded.Rules()
			This.AddRule(oRule)
		end
	
	def MergeWith(oOtherRuleBase)
		for oRule in oOtherRuleBase.Rules()
			This.AddRule(oRule)
		end
	
	#-----------#
	#  GETTERS  #
	#-----------#
	
	def Name()
		return @cName
	
	def Domain()
		return @cDomain
	
	def Level()
		return @cLevel
	
	def Version()
		return @cVersion
	
	def Author()
		return @cAuthor
	
	#-----------#
	#  DISPLAY  #
	#-----------#
	
	def Show()
		? "RuleBase: " + @cName
		? "  Domain: " + @cDomain
		? "  Level: " + @cLevel
		? "  Rules: " + len(@aoRules)
		
		for oRule in @aoRules
			? "    - " + oRule.Id() + " (" + oRule.RuleType() + ")"
		end
	
	def ToHashlist()
		return [
			:name = @cName,
			:domain = @cDomain,
			:level = @cLevel,
			:version = @cVersion,
			:author = @cAuthor,
			:ruleCount = len(@aoRules)
		]


#============================================#
#  Pre-built Rule Bases                      #
#============================================#

#--------------------------#
#  GRAPH STRUCTURAL RULES  #
#--------------------------#

class stzGraphDefaultRuleBase from stzGraphRuleBase
	def init()
		super.init("Graph Structural Rules")
		@cDomain = "structural"
		@cLevel = "graph"
		This._LoadDefaultRules()
	
	def _LoadDefaultRules()
		# DAG Rule
		oRule = new stzGraphRule("dag_check")
		oRule {
			SetRuleType("validation")
			SetDomain("dag")
			SetMessage("Graph contains cycles")
			WhenGraph("acyclic", "mustbe")
			ThenViolation("Graph must be acyclic (DAG)")
		}
		This.AddRule(oRule)
		
		# Reachability (checked elsewhere)
		# Completeness (decision nodes need 2+ paths)

#--------------------------#
#  DIAGRAM DEFAULT RULES   #
#--------------------------#

class stzDiagramDefaultRuleBase from stzGraphRuleBase
	def init()
		super.init("Diagram Compliance Rules")
		@cLevel = "diagram"
		This._LoadDefaultRules()
	
	def _LoadDefaultRules()
		# SOX: Financial processes need audit trail
		oRule1 = new stzGraphRule("sox_audit_trail")
		oRule1 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("sox")
			SetMessage("SOX-001: Financial process missing audit trail")
			When("domain", "equals", "financial")
			Then("audittrail", "required", TRUE)
		}
		This.AddRule(oRule1)
		
		# SOX: Decisions need approval
		oRule2 = new stzGraphRule("sox_approval")
		oRule2 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("sox")
			SetMessage("SOX-002: Decision node lacks approval requirement")
			When("type", "equals", "decision")
			Then("requiresApproval", "required", TRUE)
		}
		This.AddRule(oRule2)

#--------------------------#
#  ORGCHART DEFAULT RULES  #
#--------------------------#

class stzOrgChartDefaultRuleBase from stzGraphRuleBase
	def init()
		super.init("OrgChart Governance Rules")
		@cLevel = "orgchart"
		This._LoadDefaultRules()
	
	def _LoadDefaultRules()
		# BCEAO: Board required (checked separately)
		# BCEAO: Audit independence
		oRule = new stzGraphRule("bceao_audit_independence")
		oRule {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("bceao")
			SetMessage("BCEAO-002: Audit must report to Board")
			When("department", "equals", "audit")
			Then("reportsTo", "mustbe", "board")
		}
		This.AddRule(oRule)
		
		# SOD: Ops not under Treasury
		oRule2 = new stzGraphRule("sod_ops_treasury")
		oRule2 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("sod")
			SetMessage("SOD-001: Operations reports through Treasury")
			When("department", "equals", "operations")
			Then("supervisor_department", "mustnotbe", "treasury")
		}
		This.AddRule(oRule2)


#  Pre-built Domain-Specific Rule Bases
#======================================

#------------------------------#
#  BANKING RULES (ALL LEVELS)  #
#------------------------------#

class stzBankingRuleBase from stzGraphRuleBase
	def init()
		super.init("Universal Banking Rules")
		@cDomain = "banking"
		This._LoadBankingRules()
	
	def _LoadBankingRules()
		# Graph-level: No approval cycles
		oRule1 = new stzGraphRule("banking_no_approval_cycles")
		oRule1 {
			SetRuleType("constraint")
			SetLevel("graph")
			SetDomain("banking")
			SetMessage("BANK-001: Approval workflows cannot contain cycles")
			WhenGraph("acyclic", "mustbe")
		}
		This.AddRule(oRule1)
		
		# Diagram-level: Fraud before payment
		oRule2 = new stzGraphRule("banking_fraud_detection")
		oRule2 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("banking")
			SetMessage("BANK-002: Payment missing fraud detection")
			When("operation", "equals", "payment")
			ThenViolation("Payment node must have fraud_check predecessor")
		}
		This.AddRule(oRule2)
		
		# OrgChart-level: Ops not under Treasury
		oRule3 = new stzGraphRule("banking_ops_treasury_separation")
		oRule3 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("banking")
			SetMessage("BANK-003: Operations reports through Treasury (SOD violation)")
			When("department", "equals", "operations")
			Then("supervisor_department", "mustnotbe", "treasury")
		}
		This.AddRule(oRule3)
		
		# OrgChart-level: Dual approval for large transactions
		oRule4 = new stzGraphRule("banking_dual_approval")
		oRule4 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("banking")
			SetMessage("BANK-004: Large transaction position requires 2+ approvers")
			When("transactionType", "equals", "large")
			Then("approverCount", "greaterthan", 1)
		}
		This.AddRule(oRule4)

#-------------------------------#
#  BCEAO RULES (WAEMU BANKING)  #
#-------------------------------#

class stzBCEAORuleBase from stzGraphRuleBase
	def init()
		super.init("BCEAO Governance Rules")
		@cDomain = "bceao"
		@cLevel = "orgchart"
		This._LoadBCEAORules()
	
	def _LoadBCEAORules()
		# Board required
		oRule1 = new stzGraphRule("bceao_board_required")
		oRule1 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("bceao")
			SetSeverity("error")
			SetMessage("BCEAO-001: Board of Directors is mandatory")
			When("title", "contains", "board")
			Then("exists", "required", TRUE)
		}
		This.AddRule(oRule1)
		
		# Audit independence
		oRule2 = new stzGraphRule("bceao_audit_independence")
		oRule2 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("bceao")
			SetSeverity("error")
			SetMessage("BCEAO-002: Audit must report directly to Board")
			When("department", "equals", "audit")
			Then("reportsTo", "mustbe", "board")
		}
		This.AddRule(oRule2)
		
		# Risk function required
		oRule3 = new stzGraphRule("bceao_risk_function")
		oRule3 {
			SetRuleType("validation")
			SetLevel("orgchart")
			SetDomain("bceao")
			SetSeverity("error")
			SetMessage("BCEAO-003: Dedicated Risk Management function required")
			When("department", "equals", "risk")
			Then("exists", "required", TRUE)
		}
		This.AddRule(oRule3)

#------------------------------#
#  SOX RULES (SARBANES-OXLEY)  #
#------------------------------#

class stzSOXRuleBase from stzGraphRuleBase
	def init()
		super.init("Sarbanes-Oxley Compliance")
		@cDomain = "sox"
		@cLevel = "diagram"
		This._LoadSOXRules()
	
	def _LoadSOXRules()
		# Financial processes need audit trail
		oRule1 = new stzGraphRule("sox_audit_trail")
		oRule1 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("sox")
			SetMessage("SOX-001: Financial process missing audit trail")
			When("domain", "equals", "financial")
			Then("audittrail", "required", TRUE)
		}
		This.AddRule(oRule1)
		
		# Decisions need approval
		oRule2 = new stzGraphRule("sox_approval_required")
		oRule2 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("sox")
			SetMessage("SOX-002: Decision node lacks approval requirement")
			When("type", "equals", "decision")
			Then("requiresApproval", "required", TRUE)
		}
		This.AddRule(oRule2)

#--------------#
#  GDPR RULES  #
#--------------#

class stzGDPRRuleBase from stzGraphRuleBase
	def init()
		super.init("GDPR Compliance")
		@cDomain = "gdpr"
		@cLevel = "diagram"
		This._LoadGDPRRules()
	
	def _LoadGDPRRules()
		# Personal data needs consent
		oRule1 = new stzGraphRule("gdpr_consent")
		oRule1 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("gdpr")
			SetMessage("GDPR-001: Personal data processing missing consent")
			When("dataType", "equals", "personal")
			Then("requiresConsent", "required", TRUE)
		}
		This.AddRule(oRule1)
		
		# Retention policy required
		oRule2 = new stzGraphRule("gdpr_retention")
		oRule2 {
			SetRuleType("validation")
			SetLevel("diagram")
			SetDomain("gdpr")
			SetMessage("GDPR-002: Data node missing retention policy")
			When("dataType", "equals", "personal")
			Then("retentionPolicy", "required", TRUE)
		}
		This.AddRule(oRule2)
