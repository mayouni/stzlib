# Example 1: Simple Ring to COBOL conversion
load "../../stzmax.ring"
load "../stzcobol.ring"

pr()

# Run the examples
TestSimpleConversion()
TestCobolToRingConversion()
TestCobolPatternGeneration()
TestReportGenerator()

pf()
# Executed in 0.18 second(s) in Ring 1.22

#------------------#
#  TEST FUNCTIONS  #
#------------------#

func testSimpleConversion()
    # A simple Ring program to calculate total price
    cRingCode = '
    # Simple price calculation program
    quantity = 5
    unitPrice = 10.50
    discount = 0.15
    
    func calculateTotal()
        subTotal = quantity * unitPrice
        discountAmount = subTotal * discount
        finalPrice = subTotal - discountAmount
        return finalPrice
    '
    
    # Create stzCobol object and translate
    cobolTranslator = new stzCobol(cRingCode)
    cCobolCode = cobolTranslator.translateToCobol()
    
    # Display the COBOL output
    ? "=== COBOL Code Generated from Ring ==="
    ? cCobolCode
    
    # Save to files for reference
    cobolTranslator.saveCobolToFile("price_calculation.cbl")

# Example 2: COBOL to Ring conversion
func testCobolToRingConversion()
    # A typical COBOL program segment
    cCobolCode = '
       IDENTIFICATION DIVISION.
       PROGRAM-ID. INVOICE-CALC.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 CUSTOMER-DATA.
          05 CUSTOMER-ID       PIC X(10).
          05 CUSTOMER-NAME     PIC X(30).
       01 INVOICE-AMOUNTS.
          05 SUBTOTAL          PIC S9(7)V99.
          05 TAX-RATE          PIC S9(2)V99 VALUE 0.08.
          05 TAX-AMOUNT        PIC S9(7)V99.
          05 TOTAL-DUE         PIC S9(7)V99.
       
       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           MOVE "CUST12345" TO CUSTOMER-ID.
           MOVE "ACME CORPORATION" TO CUSTOMER-NAME.
           MOVE 1250.75 TO SUBTOTAL.
           
           COMPUTE TAX-AMOUNT = SUBTOTAL * TAX-RATE.
           COMPUTE TOTAL-DUE = SUBTOTAL + TAX-AMOUNT.
           
           DISPLAY "Customer: " CUSTOMER-NAME.
           DISPLAY "Invoice Total: " TOTAL-DUE.
           
           STOP RUN.
    '
    
    # Create stzCobol object and translate
    cobolTranslator = new stzCobol(cCobolCode)
    cRingCode = cobolTranslator.translateToRing()
    
    # Display the Ring output
    ? "=== Ring Code Generated from COBOL ==="
    ? cRingCode
    
    # Save to files for reference
    cobolTranslator.saveRingToFile("invoice_calc.ring")

# Example 3: COBOL pattern-based generation
func testCobolPatternGeneration()
    # Using specialized annotations to guide translation
    cRingCode = '
    # @COBOL-PROGRAM: CUSTOMER-MANAGEMENT
    
    # @COBOL-VAR: STRING(20)
    customerId = "ABC123"
    
    # @COBOL-VAR: DECIMAL(10,2)
    accountBalance = 1250.75
    
    # @COBOL-VAR: INTEGER(5)
    customerStatus = 1
    
    # @COBOL-SECTION: MAIN
    func main()
        # @COBOL-PARA: PROCESS-CUSTOMER
        processCustomer()
        displayResult()
    
    # @COBOL-PARA: PROCESS-CUSTOMER
    func processCustomer()
        if accountBalance > 1000
            customerStatus = 2  # Premium status
        else
            customerStatus = 1  # Regular status
        
        # Direct COBOL snippet insertion
        # @COBOL-SNIPPET:
        # IF CUSTOMER-STATUS = 2
        #    DISPLAY "Premium Customer: " CUSTOMER-ID
        # ELSE
        #    DISPLAY "Regular Customer: " CUSTOMER-ID
        # END-IF.
    '
    
    # Create stzCobol object with annotations support
    cobolTranslator = new stzCobol(cRingCode)
    cCobolCode = cobolTranslator.translateToCobol()
    
    # Display the COBOL output
    ? "=== Pattern-Based COBOL Generation ==="
    ? cCobolCode

# Example 4: Legacy Report Generator
func testReportGenerator()
    # Create a modern Ring data report generator that outputs COBOL
    cRingCode = '
    # Modern data visualization app in Ring
    # that will generate COBOL report program
    
    # @COBOL-FILE: SEQUENTIAL "SALES.DAT"
    salesData = [
        ["2023-01", "Northeast", 12500.00],
        ["2023-01", "Southeast", 9800.50],
        ["2023-01", "Midwest", 11200.75],
        ["2023-01", "West", 15600.25]
    ]
    
    # @COBOL-REPORT: SALES-REPORT
    func generateReport()
        # Header
        ? "Sales Report - January 2023"
        ? "============================="
        
        # Summary
        totalSales = 0
        for record in salesData
            ? pad(record[2], 15) + formatMoney(record[3])
            totalSales += record[3]
        next
        
        ? "============================="
        ? "Total: " + formatMoney(totalSales)
    
    func formatMoney(amount)
        return "$" + amount
    '
    
    # Create stzCobol object and translate
    cobolTranslator = new stzCobol(cRingCode)
    cCobolCode = cobolTranslator.translateToCobol()
    
    # Display the COBOL output
    ? "=== COBOL Report Generator ==="
    ? cCobolCode
