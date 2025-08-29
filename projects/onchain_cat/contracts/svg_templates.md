# Optimized SVG Structure Templates

## Background Pattern (back/)
```xml
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
<g id="background-pattern">
<rect x="0" y="0" width="24" height="24" fill="#F0F8FF"/>
<rect x="0" y="0" width="24" height="2" fill="#87CEEB" opacity="0.5"/>
<rect x="0" y="4" width="24" height="2" fill="#87CEEB" opacity="0.5"/>
<!-- Additional pattern elements -->
</g>
</svg>
```

## Front Item (front/)
```xml
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">
<g id="front-item">
<rect x="5" y="17" width="1" height="3" fill="#710a0a"/>
<rect x="4" y="18" width="1" height="1" fill="#F00"/>
<rect x="6" y="18" width="1" height="3" fill="#F00"/>
<!-- Additional item elements -->
</g>
</svg>
```

## Accessory Item (item/)
```xml
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">
<g id="accessory-item">
<rect x="9" y="14" width="6" height="1" fill="#c80909"/>
<rect x="11" y="15" width="2" height="1" fill="#f8dd2a"/>
<rect x="10" y="16" width="1" height="1" fill="#f8dd2a"/>
<!-- Additional accessory elements -->
</g>
</svg>
```

## Main Character (main/)
```xml
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" shape-rendering="crispEdges">
<g id="main-character">
<rect x="6" y="3" width="3" height="3" fill="#778"/>
<rect x="7" y="4" width="1" height="1" fill="#FBC"/>
<rect x="15" y="3" width="3" height="3" fill="#778"/>
<!-- Additional character elements -->
</g>
</svg>
```

## Key Optimizations Applied:

1. **Consistent ViewBox**: All SVGs use `viewBox="0 0 24 24"` for uniform scaling
2. **Removed Redundant Attributes**: 
   - Removed explicit width/height from root (384x384)
   - Removed xmlns from child elements
   - Removed default opacity="1"
3. **Added Semantic Groups**: Each category has a specific group ID:
   - `background-pattern` for backgrounds
   - `front-item` for front items
   - `accessory-item` for accessories
   - `main-character` for main characters
4. **Preserved Important Attributes**:
   - Kept `shape-rendering="crispEdges"` for pixel art style
   - Maintained all color and position values
5. **Minimized File Size**:
   - Shortened hex colors where possible (#FF0000 → #F00)
   - Converted float coordinates to integers
   - Removed unnecessary whitespace