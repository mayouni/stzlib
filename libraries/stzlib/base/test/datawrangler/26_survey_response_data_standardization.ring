# Narrative
# --------
# Survey response data standardization
#
# Extracted from stzdatawranglertest.ring, block #26.

load "../../stzBase.ring"

pr()

# REAL-WORLD SCENARIO: SURVEY RESPONSE STANDARDIZATION

# Survey responses with inconsistent formats
aSurveyData = [
    ["Resp001", "25", "Male", "YES", "Satisfied", "Bachelor's", "50000"],
    ["Resp002", "thirty-two", "F", "true", "Very Satisfied", "Masters", "75000"],
    ["Resp003", "", "female", "1", "Neutral", "PhD", ""],  # Missing age and salary
    ["Resp004", "45", "M", "NO", "Dissatisfied", "High School", "35000"],
    ["Resp005", "28", "Female", "false", "satisfied", "bachelor", "55000"],  # Case inconsistencies
    ["Resp006", "65", "Male", "Yes", "Very satisfied", "Masters", "90000"],
    ["Resp007", "22", "F", "0", "", "Associate", "30000"]  # Missing satisfaction
]

aSurveyHeaders = ["ResponseID", "Age", "Gender", "Subscribe", "Satisfaction", "Education", "Income"]

o1 = new stzDataWrangler(aSurveyData, aSurveyHeaders)

? BoxRound("Survey data standardization process")

# Custom validation rules for survey data
aCustomRules = [
    ["Age", 18, 100],
    ["Income", 0, 500000]
]

? ""
? "1. Range validation with custom rules:"
aRangeIssues = o1.ValidateRanges(aCustomRules)
for issue in aRangeIssues
    ? " • " + issue
next

? ""
? "2. Comprehensive standardization:"
aStandardizationResult = o1.ExecutePlan("export", TRUE)

? ""
? "3. Export-ready survey data:"
aStandardizedSurvey = o1.ExportForStzTable()
? StzTableQ(aStandardizedSurvey).ClassName()

#-->
'
╭─────────────────────────────────────╮
│ Survey data standardization process │
╰─────────────────────────────────────╯

1. Range validation with custom rules:

2. Comprehensive standardization:
• Executing Plan: Prepare for Export
• Format data for external systems

❌ Clean column names...
╰─> Error: Bad parameter type!

❌ Replace with export-friendly values...
╰─> Error: Error (R19) : Calling function with less number of parameters

❌ Standardize date formats...
╰─> Error: Bad parameter type!

✅ Final validation check...
╰─> Export validation - 2 issues found

( Plan execution completed in 0.00 second(s): 1 successful, 3 errors )

3. Export-ready survey data:
stztable

'
pf()
# Executed in 0.02 second(s) in Ring 1.22
