# Narrative
# --------
# Example 5: Advanced Custom Domain Cluster
#
# Extracted from stzappserverclustertest.ring, block #5.

load "../../../stzBase.ring"


    oCluster = new stzCluster()
    
    # Create specialized clusters
    aNLPNodes = oCluster.CreateNLPCluster(3)
    aMathNodes = oCluster.CreateMathCluster(2) 
    aVisionNodes = oCluster.CreateVisionCluster(2)
    
    # Customize individual nodes for specific tasks
    aNLPNodes[1] {
        # First NLP node specialized for legal documents
        LoadSpecializedEngines()
        oComputeEngine {
            PreloadLegalTerminology()
            PreloadContractAnalysis()
            PreloadComplianceChecking()
        }
    }
    
    aNLPNodes[2] {
        # Second NLP node specialized for medical text
        oComputeEngine {
            PreloadMedicalTerminology() 
            PreloadICDCoding()
            PreloadClinicalAnalysis()
        }
    }
    
    aMathNodes[1] {
        # Math node optimized for financial modeling
        oComputeEngine {
            PreloadRiskModels()
            PreloadPortfolioOptimization()
            PreloadDerivativesPricing()
        }
    }
    
    oCluster.Start(8080)
