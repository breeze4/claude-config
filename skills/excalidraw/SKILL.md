---
name: excalidraw
description: Generate Excalidraw diagram files (.excalidraw) as JSON. Use when asked to create a diagram, flowchart, architecture diagram, or any visual diagram that should be editable.
allowed-tools: Write, Read, Edit
user_invocable: true
argument-hint: [diagram description]
---

# Excalidraw Diagram Generator

Generate `.excalidraw` files that open in VS Code with the Excalidraw extension.

## CRITICAL: Visual Diagram Standards

**You are generating a VISUAL DIAGRAM, not a text document.** Every diagram must communicate through visual structure — shapes, positions, colors, sizes, connections, and grouping. If you catch yourself putting a paragraph of text inside a single large rectangle, STOP. That is not a diagram. That is a text box. Redo it.

### Mandatory Requirements

1. **Every distinct concept gets its own shape.** A "concept" is any noun, service, component, step, entity, role, or data store. If it has a name, it gets a shape.
2. **Every relationship gets an arrow or line.** If A talks to B, depends on B, flows into B, or relates to B — draw a connection. Label it if the relationship type matters.
3. **Use position to show structure.** Hierarchy = vertical stacking (parent above children). Sequence = left-to-right or top-to-bottom flow. Peer items = same row/column. Layers = top-to-bottom bands.
4. **Use color to show categories.** Same-category items share a color. Different categories get different colors. Never make everything the same color.
5. **Use shape type to show element roles.** Rectangles = processes/services. Diamonds = decisions. Ellipses = start/end/actors. Rounded rects = actions/steps. Frames = boundaries/groups.
6. **Use size to show importance.** Primary systems are larger (200-260w). Secondary items are standard (140-180w). Minor details are smaller (100-130w).
7. **Use groupIds to cluster related elements.** Related shapes and their labels share a groupId so they move together.

### What NEVER To Do

- NEVER put all content in one big rectangle with multiline text
- NEVER create a diagram with fewer than 4 shapes (if the topic has fewer than 4 concepts, break concepts down further)
- NEVER make all shapes the same size, same color, and unconnected
- NEVER use text blocks as the primary content carrier — text labels shapes, it doesn't replace them
- NEVER place shapes randomly — use a grid, lanes, or tree structure
- NEVER skip arrows between things that have relationships

## Process

1. **Decompose the subject into visual elements.** List every concept (noun) as a shape. List every relationship (verb/preposition) as a connection. This list should have 6+ elements minimum for any real diagram.
2. **Choose a layout pattern** from the Layout Patterns section below.
3. **Assign colors by category** — pick 2-4 colors from the palette, one per logical grouping.
4. **Assign sizes by importance** — primary elements larger, secondary smaller.
5. **Calculate positions on a grid.** Use the spacing constants below. Write out the grid positions before generating JSON.
6. **Generate the JSON** with all bidirectional bindings correct.
7. **Self-check**: Count your shapes. If < 6, you probably collapsed too many concepts into text. Fix it. Count your arrows. If < 3, you probably skipped relationships. Fix it.
8. Default output path: `docs/diagrams/` unless user specifies otherwise.

## Layout Patterns

### Flow (flowcharts, pipelines, sequences)
- Primary direction: top-to-bottom or left-to-right
- Grid: columns at x=100, 340, 580, 820... rows at y=100, 260, 420, 580...
- Decision diamonds branch into parallel columns
- Use color for branches: green=happy path, red=error, yellow=alternate

### Hierarchy (org charts, component trees, taxonomies)
- Root node centered at top, large (240w x 80h)
- Children evenly spaced below, standard size (160w x 70h)
- Grandchildren below those, smaller (130w x 60h)
- Vertical gap: 120px between levels. Horizontal gap: 40px between siblings.

### Layers (architecture, network, stack diagrams)
- Horizontal bands, each 200px tall
- Full-width frame or large rect as band background (labeled)
- Components within each band arranged horizontally, 100px apart
- Arrows cross between bands vertically
- Top = client/user. Bottom = data/infrastructure.

### Grid (comparison, feature matrix, entity relationships)
- Evenly spaced rows and columns
- Column headers as colored rectangles at top
- Row items aligned consistently
- Connecting lines between related cells

### Radial/Hub (dependency maps, system context)
- Central element large and centered (240w x 100h)
- Satellites arranged in a circle/ring around center, 250-300px from center
- Arrows from center to satellites (or vice versa)
- Color satellites by category

### Swim Lanes (cross-team processes, sequence-style)
- Vertical lanes, each 250px wide, separated by dashed lines
- Lane headers as colored rectangles at top
- Process steps as shapes within lanes
- Horizontal arrows between lanes for handoffs
- Number each step for sequence

## Spacing Constants

```
SHAPE_W_LARGE   = 240    Primary/important elements
SHAPE_W_MEDIUM  = 160    Standard elements
SHAPE_W_SMALL   = 120    Minor elements
SHAPE_H         = 70     Standard height
SHAPE_H_TALL    = 100    Tall elements (multi-line labels)
GAP_H           = 100    Horizontal gap between shapes
GAP_V           = 120    Vertical gap between rows
ARROW_GAP       = 5      Gap between arrow endpoint and shape edge
GRID_COL_W      = 260    Column width in grid layouts (shape + gap)
GRID_ROW_H      = 190    Row height in grid layouts (shape + gap)
MARGIN          = 100    Starting margin from origin
```

## File Structure

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "https://excalidraw.com",
  "elements": [],
  "appState": { "viewBackgroundColor": "#ffffff" },
  "files": {}
}
```

## Element Base Properties

Every element needs these properties:

```
id            string    Unique ID (e.g. "rect-1", "arrow-2")
type          string    rectangle | ellipse | diamond | arrow | line | text | freedraw | frame
x, y          number    Position in pixels
width, height number    Dimensions
angle         number    Rotation in radians (0 = none)
strokeColor   string    Hex color (e.g. "#1e1e1e")
backgroundColor string  Hex color or "transparent"
fillStyle     string    "solid" | "hachure" | "cross-hatch"
strokeWidth   number    1 (thin), 2 (medium), 4 (thick)
strokeStyle   string    "solid" | "dashed" | "dotted"
roughness     number    0 (architect), 1 (artist), 2 (cartoonist)
opacity       number    0-100
roundness     object    null (sharp) | {"type": 3} (rounded)
seed          number    Random integer for rough.js rendering
version       number    1
versionNonce  number    Random integer
isDeleted     boolean   false
groupIds      array     [] or [groupId] for grouped elements
frameId       null      null unless inside a frame
boundElements array     [] or [{id, type}] for bound arrows/labels
updated       number    Unix timestamp ms
link          null      null or URL string
locked        boolean   false
```

## Element Types

### Shapes: rectangle, ellipse, diamond

Use base properties only. For labeled shapes, add a separate text element with `containerId` pointing to the shape (preferred method).

### Text

Additional properties beyond base:

```
text           string   The displayed text (use \n for line breaks)
fontSize       number   16, 20, 28, 36 are common
fontFamily     number   1=Virgil(hand), 2=Helvetica, 3=Cascadia(mono)
textAlign      string   "left" | "center" | "right"
verticalAlign  string   "top" | "middle"
containerId    string   ID of parent shape (for labels inside shapes)
```

When text has a `containerId`:
- Set `verticalAlign: "middle"` and `textAlign: "center"`
- The parent shape must list the text in `boundElements: [{"id": "text-id", "type": "text"}]`
- Text width/height should fit inside the container
- Keep labels SHORT: 1-3 words per shape. If you need more detail, use a smaller annotation text nearby, not a paragraph inside the shape.

### Arrow and Line

Additional properties beyond base:

```
points          array    [[0,0], [dx, dy], ...] — MUST start with [0,0], relative offsets
startBinding    object   {elementId, focus: 0, gap: 5} or null
endBinding      object   {elementId, focus: 0, gap: 5} or null
startArrowhead  string   null | "arrow" | "dot" | "bar" | "triangle"
endArrowhead    string   null | "arrow" | "dot" | "bar" | "triangle"
```

Use `roundness: {"type": 2}` for smooth curved arrows.

## Critical Rules

### Arrow Binding is Bidirectional

When an arrow connects two shapes, you MUST update both sides:

1. Arrow gets `startBinding` / `endBinding` with the shape's `elementId`
2. Each bound shape gets the arrow in its `boundElements`: `[{"id": "arrow-id", "type": "arrow"}]`

If you forget either side, the arrow won't stay attached when the shape is moved.

### Container Text Binding is Bidirectional

When text is inside a shape:

1. Text gets `containerId: "shape-id"`
2. Shape gets `{"id": "text-id", "type": "text"}` in its `boundElements`

### Points Array

- Always starts with `[0, 0]`
- Subsequent points are **relative offsets** from the arrow's `(x, y)`
- For a horizontal arrow 200px long: `points: [[0, 0], [200, 0]]`
- For an L-shaped arrow: `points: [[0, 0], [100, 0], [100, 80]]`
- Arrow `width` and `height` should match the bounding box of all points

### ID and Seed Generation

- Use descriptive IDs: `"db-rect"`, `"api-arrow"`, `"auth-text"`
- Generate random seeds: any integer, e.g. `Math.floor(Math.random() * 2000000000)`
- Use current timestamp for `updated`

## Color Palette (Excalidraw defaults)

| Color | Stroke | Background | Use For |
|-------|--------|------------|---------|
| Blue | `#1971c2` | `#a5d8ff` | Frontend, UI, client-side |
| Green | `#2f9e44` | `#b2f2bb` | Backend, success, APIs |
| Orange | `#e8590c` | `#ffd8a8` | Data, storage, databases |
| Violet | `#6741d9` | `#d0bfff` | External services, 3rd party |
| Red | `#e03131` | `#ffc9c9` | Errors, alerts, destructive |
| Teal | `#099268` | `#96f2d7` | Infrastructure, DevOps |
| Yellow | `#f08c00` | `#ffec99` | Warnings, async, queues |
| Cyan | `#0c8599` | `#99e9f2` | Auth, security, middleware |
| Pink | `#c2255c` | `#fcc2d7` | Users, actors, personas |
| Grape | `#9c36b5` | `#eebefa` | Analytics, monitoring |
| Indigo | `#3b5bdb` | `#bac8ff` | Networking, communication |
| Black | `#1e1e1e` | — | Borders, text, neutral |

Pick 2-4 colors per diagram. Same color = same category. Never use one color for everything.

## Default Style

Apply these defaults to ALL elements unless there's a specific reason to deviate:

```
roughness       0          Always. Clean, architect-style lines. No hand-drawn wobble.
fillStyle       "solid"    Always. No hachure or cross-hatch.
strokeWidth     2          Standard. Use 1 only for minor/subtle elements.
strokeStyle     "solid"    Default. Use "dashed" only for optional, external, or async connections.
fontFamily      2          Helvetica for all labels. Use 3 (Cascadia) only for code/technical text.
fontSize        20         Standard labels. 28 for titles. 16 for annotations.
opacity         100        Always fully opaque.
roundness       {"type":3} Rounded corners on rectangles. Use null only for diamonds.
```

These are not suggestions. Use them on every element.

## Template: Minimal Element

```json
{
  "type": "rectangle",
  "id": "r1",
  "x": 100, "y": 100, "width": 160, "height": 70,
  "strokeColor": "#1971c2",
  "backgroundColor": "#a5d8ff",
  "fillStyle": "solid",
  "strokeWidth": 2,
  "strokeStyle": "solid",
  "roughness": 0,
  "opacity": 100,
  "angle": 0,
  "roundness": { "type": 3 },
  "seed": 1847301385,
  "version": 1,
  "versionNonce": 449037191,
  "isDeleted": false,
  "groupIds": [],
  "frameId": null,
  "boundElements": [],
  "updated": 1739612400000,
  "link": null,
  "locked": false
}
```

## Diagram Type Checklists

### Flowchart
- [ ] Every step is its own rectangle (rounded for start/end)
- [ ] Every decision is a diamond with 2+ outgoing arrows
- [ ] Arrows labeled on branches (Yes/No, Success/Fail)
- [ ] Color distinguishes paths: green=happy, red=error, yellow=alternate
- [ ] 6+ shapes minimum

### Architecture Diagram
- [ ] Every service/component is its own shape
- [ ] Frames or large background rects delineate layers/boundaries
- [ ] Arrows show data flow direction, labeled with protocol (HTTP, gRPC, SQL)
- [ ] Color-coded by domain (2-4 colors)
- [ ] External vs internal systems visually distinct (dashed border for external)
- [ ] 8+ shapes minimum

### Sequence-style
- [ ] Each actor/service is a rectangle at top of its lane
- [ ] Dashed vertical lines extend down from each actor
- [ ] Horizontal arrows between lanes, numbered sequentially
- [ ] Arrow labels describe the message/action
- [ ] 4+ actors, 6+ messages minimum

### Entity Relationship
- [ ] Each entity is its own rectangle
- [ ] Key fields listed as text inside or below entity
- [ ] Lines connect related entities
- [ ] Cardinality labels on connections (1:N, M:N)
- [ ] 4+ entities minimum

### Component / Module Map
- [ ] Each module/package is its own shape
- [ ] Arrows show dependencies (A depends on B = arrow from A to B)
- [ ] Size reflects complexity or importance
- [ ] Color reflects layer/category
- [ ] 6+ components minimum

<description>$ARGUMENTS</description>
