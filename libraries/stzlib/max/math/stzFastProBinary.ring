

# Add this functionality to your stzFastPro.ring file

func FastProBinaryUpdate(cBytes, nColumns, nCount, nDiv, paCommands)
    # Implementation for direct binary operations without conversion
    # Similar to BinaryUpdateColumn but with consistent parameter format
    
    if NOT isList(paCommands)
        raise("FastProBinaryUpdate(): Invalid commands parameter!")
    ok
    
    cNewBytes = cBytes
    
    # Process each command by transforming the style to match RingFastPro
    for i = 1 to len(paCommands)
        aCmd = paCommands[i]
        
        if isString(aCmd[1])
            cOperation = lower(aCmd[1])
            
            switch cOperation
                on :set
                    if aCmd[:col] != NULL
                        cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                     :set, aCmd[:col], aCmd[:with])
                    but aCmd[:cols] != NULL
                        # Process multiple columns
                        for nCol in aCmd[:cols]
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :set, nCol, aCmd[:with])
                        next
                    but aCmd[:colsfrom] != NULL and aCmd[:to] != NULL
                        # Process range of columns
                        nStart = aCmd[:colsfrom]
                        nEnd = aCmd[:to]
                        for nCol = nStart to nEnd
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :set, nCol, aCmd[:with])
                        next
                    but aCmd[:all] != NULL
                        # All columns
                        for nCol = 1 to nColumns
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :set, nCol, aCmd[:with])
                        next
                    ok
                    
                on :multiply
                    if aCmd[:col] != NULL
                        if aCmd[:tocol] != NULL
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :mul, aCmd[:col], aCmd[:by], aCmd[:tocol])
                        else
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :mul, aCmd[:col], aCmd[:by])
                        ok
                    but aCmd[:colsfrom] != NULL and aCmd[:to] != NULL
                        # Process range of columns
                        nStart = aCmd[:colsfrom]
                        nEnd = aCmd[:to]
                        for nCol = nStart to nEnd
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :mul, nCol, aCmd[:by])
                        next
                    ok
                
                on :add
                    if aCmd[:tocol] != NULL
                        cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                     :add, aCmd[:tocol], aCmd[1])
                    but aCmd[:tocolsfrom] != NULL and aCmd[:to] != NULL
                        # Process range of columns
                        nStart = aCmd[:tocolsfrom]
                        nEnd = aCmd[:to]
                        for nCol = nStart to nEnd
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :add, nCol, aCmd[1])
                        next
                    ok
                
                on :subtract
                    if aCmd[:fromcol] != NULL
                        cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                     :sub, aCmd[:fromcol], aCmd[1])
                    but aCmd[:fromcolsfrom] != NULL and aCmd[:to] != NULL
                        # Process range of columns
                        nStart = aCmd[:fromcolsfrom]
                        nEnd = aCmd[:to]
                        for nCol = nStart to nEnd
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :sub, nCol, aCmd[1])
                        next
                    ok
                
                on :divide
                    if aCmd[:col] != NULL
                        if aCmd[:tocol] != NULL
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :div, aCmd[:col], aCmd[:by], aCmd[:tocol])
                        else
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :div, aCmd[:col], aCmd[:by])
                        ok
                    but aCmd[:colsfrom] != NULL and aCmd[:to] != NULL
                        # Process range of columns
                        nStart = aCmd[:colsfrom]
                        nEnd = aCmd[:to]
                        for nCol = nStart to nEnd
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :div, nCol, aCmd[:by])
                        next
                    ok
                
                on :modulo
                    if aCmd[:col] != NULL
                        cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                     :mod, aCmd[:col], aCmd[:by])
                    but aCmd[:colsfrom] != NULL and aCmd[:to] != NULL
                        nStart = aCmd[:colsfrom]
                        nEnd = aCmd[:to]
                        for nCol = nStart to nEnd
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :mod, nCol, aCmd[:by])
                        next
                    ok
                
                on :merge
                    if aCmd[:cols] != NULL and aCmd[:incol] != NULL
                        cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                     :merge, aCmd[:cols][1], aCmd[:cols][2], aCmd[:incol])
                    ok
                
                on :copy
                    if aCmd[:col] != NULL and aCmd[:tocol] != NULL
                        cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                     :copy, aCmd[:col], aCmd[:tocol])
                    ok
                
                on :raise
                    if aCmd[:col] != NULL
                        # Implement power operation by using multiplication in a loop
                        nCol = aCmd[:col]
                        nPower = aCmd[:topower]
                        
                        # Store original values
                        cTemp = cNewBytes
                        
                        # Multiply by itself (nPower-1) times
                        for i = 2 to nPower
                            cNewBytes = BinaryUpdateColumn(cNewBytes, nColumns, nCount, nDiv, 
                                         :mul, nCol, cTemp, nCol)
                        next
                    ok
            off
        ok
    next
    
    return cNewBytes

func FastProBinaryUpdateMany(cBytes, nColumns, nCount, nDiv, paCommandsList)
    # Apply multiple commands in sequence
    cResult = cBytes
    
    for aCommands in paCommandsList
        cResult = FastProBinaryUpdate(cResult, nColumns, nCount, nDiv, [aCommands])
    next
    
    return cResult

func AddByteChannel(cBytes, nColumns, nCount, nInitValue)
    # Add a new channel (column) to the byte array with optional initial value
    if nInitValue = NULL
        nInitValue = 255  # Default to 255 (fully opaque for alpha channel)
    ok
    
    return addBytesColumn(cBytes, nColumns, nCount, nInitValue)

# Utility function to work with image data directly
func FastProUpdateImage(cImageData, nWidth, nHeight, nChannels, paCommands)
    return FastProBinaryUpdate(cImageData, nChannels, nWidth * nHeight, 255, paCommands)
