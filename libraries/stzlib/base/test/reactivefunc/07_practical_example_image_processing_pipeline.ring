# Narrative
# --------
# Practical example: Image processing pipeline
#
# Extracted from stzreactivefunctest.ring, block #7.

load "../../stzBase.ring"


# Real applications often involve multiple processing steps
# This example shows a complete image processing workflow

pr()

oRs = new stzReactiveSystem()
oRs {
    Init()

    # Simulate image operations
    loadImage = func filename {
        if not substr(filename, ".jpg") and not substr(filename, ".png")
            raise("Invalid image format")
        ok
        sleep(0.1)  # Simulate file I/O
        return "IMAGE_DATA_" + filename + "_LOADED"
    }
    
    resizeImage = func imageData, width, height {
        sleep(0.05)  # Simulate processing
        return imageData + "_RESIZED_" + width + "x" + height
    }
    
    applyFilter = func imageData, filterType {
        sleep(0.03)  # Simulate filter processing
        return imageData + "_FILTER_" + filterType
    }
    
    saveImage = func imageData, outputPath {
        sleep(0.02)  # Simulate save operation
        return "SAVED: " + outputPath + " (" + len(imageData) + " bytes)"
    }

    # Make all functions reactive
    RLoad = MakeReactive(loadImage)
    RResize = MakeReactive(resizeImage)
    RFilter = MakeReactive(applyFilter)
    RSave = MakeReactive(saveImage)

    # Process multiple images with different transformations
    images = ["photo1.jpg", "photo2.png", "document.pdf"]  # Last one will fail
    
    for i = 1 to len(images)
        imageName = images[i]
        ? "Starting pipeline for: " + imageName
        
        RLoad.CallAsync([imageName], func imageData {
            ? "  ✓ Loaded: " + imageName
            
            # Resize loaded image
            RResize.CallAsync([imageData, 800, 600], func resizedData {
                ? "  ✓ Resized: " + imageName
                
                # Apply filter to resized image
                RFilter.CallAsync([resizedData, "sepia"], func filteredData {
                    ? "  ✓ Filtered: " + imageName
                    
                    # Save final result
                    outputPath = "output_" + imageName
                    RSave.CallAsync([filteredData, outputPath], func saveResult {
                        ? "  ✓ " + saveResult
                        ? "Pipeline complete for: " + imageName
                    }, func saveError {
                        ? "  ✗ Save failed for " + imageName + ": " + saveError
                    })
                    
                }, func filterError {
                    ? "  ✗ Filter failed for " + imageName + ": " + filterError
                })
                
            }, func resizeError {
                ? "  ✗ Resize failed for " + imageName + ": " + resizeError
            })
            
        }, func loadError {
            ? "  ✗ Load failed for " + imageName + ": " + loadError
        })
    next

    Start()
}
#-->
# Starting pipeline for: photo1.jpg
#   ✓ Loaded: photo1.jpg
#   ✓ Resized: photo1.jpg
#   ✓ Filtered: photo1.jpg
#   ✓ SAVED: output_photo1.jpg (57 bytes)
# Pipeline complete for: photo1.jpg
# Starting pipeline for: photo2.png
#   ✓ Loaded: photo2.png
#   ✓ Resized: photo2.png
#   ✓ Filtered: photo2.png
#   ✓ SAVED: output_photo2.png (57 bytes)
# Pipeline complete for: photo2.png
# Starting pipeline for: document.pdf
#   ✗ Load failed for document.pdf: Invalid image format

pf()
# Executed in 1.42 second(s) in Ring 1.23

#=========================================#
#  KEY TAKEAWAYS - REACTIVE FUNCTIONS    #
#=========================================#

/*
1. BASIC PATTERN:
   - Regular function: result = myFunc(params)
   - Reactive function: ReactiveFunc.CallAsync(params, successHandler, errorHandler)

2. BENEFITS:
   - Non-blocking: Other code runs while function executes
   - Parallel: Multiple functions run simultaneously  
   - Error-safe: Graceful error handling with dedicated error functions
   - Efficient: Better CPU utilization, faster overall execution

3. WHEN TO USE:
   - Heavy computations (math, data processing)
   - I/O operations (file reading, network calls)
   - Any operation that might take noticeable time
   - Batch processing of multiple items

4. BEST PRACTICES:
   - Always provide error handlers
   - Use meaningful variable names in callbacks
   - Chain operations properly for complex workflows
   - Remember to call Start() to begin processing

5. REMEMBER:
   - Reactive functions don't return values directly
   - Results come through success callback functions
   - Errors come through error callback functions
   - The reactive system handles all the complex threading for you
*/
