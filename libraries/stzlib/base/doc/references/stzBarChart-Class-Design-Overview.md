# stzBarChart Class Design Overview

## Core Architecture
The class follows a **canvas-based rendering approach** where the chart is drawn character by character into a 2D array (`@acCanvas`) that represents the visual output. Think of it as ASCII art generation with precise positioning.

## Key Design Principles

### 1. H/V Naming Convention
- **H** = Horizontal (bottom axis with `─` chars and `>` arrow)  
- **V** = Vertical (left axis with `│` chars and `↑` arrow)
- **Why**: Eliminates X/Y confusion across different chart types
- **Legacy**: XY method names kept as aliases for backward compatibility

### 2. Modular Rendering Pipeline
```
_calculateLayout() → _initCanvas() → _draw*() methods → _canvasToString()
```

### 3. Adaptive Layout System
The layout engine (`_calculateLayout()`) dynamically calculates dimensions based on:
- Enabled components (axes, labels, values, average line)
- Content requirements (label lengths, value widths)
- User constraints (max widths, bar spacing)

## Quick Tweaking Guide

### Visual Customization
- **Characters**: Modify `@c*Char` variables (bar, axis, arrow, etc.)
- **Dimensions**: Adjust `@nWidth`, `@nHeight`, `@nBarWidth`, `@nBarInterSpace`
- **Spacing**: Change `@nAxisPadding`, `@nMaxLabelWidth`

### Feature Toggles
- **Components**: `@bShow*` variables control visibility of axes, labels, values, etc.
- **Display modes**: `SetValues()` vs `SetPercent()` (mutually exclusive)
- **Average line**: `SetAverage()` adds horizontal reference line

### Data Processing
- **Input formats**: Numbers list, hashlist with numeric values
- **Auto-labeling**: Generates X1, X2, X3... when no labels provided
- **Validation**: Enforces positive numbers only

## Internal Flow

### 1. Layout Calculation
`_calculateLayout()` returns a hashlist with all positioning data:
- Row/column positions for each component
- Element widths based on content
- Total canvas dimensions

### 2. Drawing Methods
Each `_draw*()` method is self-contained and optional:
- `_drawVAxis()`: Vertical line with arrow
- `_drawHAxis()`: Horizontal line with arrow and origin
- `_drawBars()`: Main data visualization
- `_drawValues()`: Numbers/percentages above bars
- `_drawLabels()`: Text below horizontal axis
- `_drawAverage()`: Reference line across chart

### 3. Canvas Management
- `@acCanvas[row][col]` stores individual characters
- `_setChar()` provides bounds checking
- `_canvasToString()` converts 2D array to display string

## Extending the Class

### Adding New Features
1. Add configuration variables (`@b*` for toggles, `@n*` for dimensions)
2. Update `_calculateLayout()` to account for new space requirements
3. Create corresponding `_draw*()` method
4. Add public setter methods with validation

### Custom Characters/Styling
- Modify character constants (`@c*Char`)
- Override drawing methods for custom rendering logic
- Adjust spacing constants for different visual densities

### Performance Notes
- Canvas size directly impacts memory usage
- Layout calculation runs once per render
- Drawing methods iterate over data, so O(n) complexity

The design emphasizes **configurability** and **modularity** - each visual component can be independently controlled while maintaining consistent positioning through the centralized layout system.