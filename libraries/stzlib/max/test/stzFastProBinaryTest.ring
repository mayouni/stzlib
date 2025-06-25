load "../stzmax.ring"

# Example usage in your code

load "stbimage.ring"

pr()

    # Constants
    RVALUE = 1
    GVALUE = 2
    BVALUE = 3
    CIMAGE = "both.jpg"
    
    # Load image
    width = 0 
    height = 0 
    channels = 0
    
    # Loading image:
    cData = stbi_load(CIMAGE, :width, :height, :channels, STBI_rgb)
    
    # Test 5: Adding a fourth channel and manipulating it

        # Adding an alpha channel and creating a gradient

        cWithAlpha = AddByteChannel(cData, channels, width*height, 255)
        channels = 4
        
        # Create a horizontal gradient for alpha

        for y = 0 to height-1
            for x = 0 to width-1
                pos = (y * width + x) * channels + 4  # Position of alpha for this pixel
                alphaValue = (x * 255) / width        # Gradient from 0 to 255 across width
                cWithAlpha[pos] = alphaValue
            next
        next
        
        # Writing alpha_gradient.bmp

        stbi_write_bmp("bothfx.bmp", width, height, channels, cWithAlpha)

    
pf()
