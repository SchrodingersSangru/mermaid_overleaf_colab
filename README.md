# mermaid-overleaf

**Beautiful Mermaid diagrams in cloud Overleaf — no shell-escape required.**

Write your diagram source directly in LaTeX. Get syntax-highlighted, themed code listings automatically. Optionally include pre-rendered images for publication-quality output.

[![License: LPPL 1.3c](https://img.shields.io/badge/license-LPPL%201.3c-blue.svg)](https://www.latex-project.org/lppl/)
[![Overleaf Compatible](https://img.shields.io/badge/Overleaf-cloud%20compatible-47A141.svg)](https://overleaf.com)

---

## Why this package?

Cloud Overleaf (overleaf.com) runs LaTeX in a sandbox — `--shell-escape` and external binaries like `mmdc` are not available. Existing packages (`ltmermaid`, `mermaid.sty`) therefore cannot run on cloud Overleaf.

`mermaid-overleaf` solves this with a **two-mode approach**:

| Mode | What you get | Shell-escape? |
|---|---|---|
| **Source display** | Syntax-highlighted, themed listing of your Mermaid code | ❌ Not needed |
| **Image mode** | Pre-rendered diagram + source listing side by side | ❌ Not needed |

---

## Features

- ✅ Works on **cloud Overleaf.com** — no configuration needed
- 🎨 **5 built-in colour themes**: `ocean`, `forest`, `sunset`, `arctic`, `midnight`
- 🏷️ **Diagram-type badges**: auto-labels flowchart, sequence, gantt, class, state, ER, pie, timeline, mindmap, git, journey
- 📐 **All Mermaid diagram types** supported in listings
- 🖼️ **Image mode** — include a pre-rendered PDF/SVG/PNG with source shown below
- 🔧 **Helper scripts** — `render.sh` / `render.ps1` to batch-render locally with `mmdc`
- 📝 **Inline command** — `\mermaidcode{...}` for Mermaid syntax in running text

---

## Installation on Overleaf

### Step 1 — Add the package to your project

In your Overleaf project:

1. Click **New File** in the left sidebar
2. Select **From External URL**
3. Enter this URL:
   ```
   https://raw.githubusercontent.com/YOUR-USERNAME/mermaid-overleaf/main/mermaid-overleaf.sty
   ```
4. Save as `mermaid-overleaf.sty`

The file is a **linked file** — click **Refresh** on it to pull the latest version whenever the package is updated.

### Step 2 — Load the package

```latex
\usepackage{mermaid-overleaf}           % default theme: ocean
% or
\usepackage[theme=forest]{mermaid-overleaf}  % set a global theme
```

---

## Quick Start

### Mode A — Source display (no image needed)

```latex
\begin{mermaid}[type=flowchart, theme=ocean, caption={My flow}]
flowchart TD
    A([Start]) --> B{Decision}
    B -->|Yes| C[Done]
    B -->|No|  A
\end{mermaid}
```

### Mode B — Pre-rendered image

```latex
\begin{mermaid}[
    image=figures/flow.pdf,
    type=flowchart,
    theme=ocean,
    caption={My flow diagram},
    label={fig:flow}
]
flowchart TD
    A --> B --> C
\end{mermaid}
```

---

## Environment Options

| Option | Type | Default | Description |
|---|---|---|---|
| `type` | string | `flowchart` | Diagram type for the badge |
| `theme` | string | `ocean` | Colour theme |
| `image` | file path | *(empty)* | Path to pre-rendered image |
| `caption` | text | *(empty)* | Figure caption |
| `label` | text | *(empty)* | `\label` key for `\ref` |
| `width` | dimension | `0.85\linewidth` | Listing / image width |
| `pos` | placement | `H` | Float placement specifier |

### Diagram type values

`flowchart` · `sequence` · `gantt` · `class` · `state` · `er` · `pie` · `timeline` · `mindmap` · `git` · `journey`

### Theme values

| Theme | Style |
|---|---|
| `ocean` | Dark navy, electric blue — default |
| `forest` | Deep green, crisp white |
| `sunset` | Dark brown, warm orange |
| `arctic` | Light/white background, blue accents |
| `midnight` | Near-black, purple accents |

---

## Commands

### Change theme mid-document

```latex
\MermaidSetTheme{sunset}
```

### Inline Mermaid code

```latex
Use \mermaidcode{graph TD} to set top-down direction.
```

### Workflow reminder box

```latex
\MermaidWorkflow
```

### Live editor note

```latex
\MermaidLiveNote
```

---

## Pre-rendering Locally (for Mode B)

### Requirements

```bash
npm install -g @mermaid-js/mermaid-cli
```

Node.js 18+ and Chromium are required by `mmdc`.

### Render all `.mmd` files in a directory

```bash
# Linux / macOS
chmod +x scripts/render.sh
./scripts/render.sh diagrams/ figures/

# Output SVG instead of PDF
./scripts/render.sh -f svg -t dark diagrams/ figures/

# Windows (PowerShell)
.\scripts\render.ps1 -SrcDir diagrams -OutDir figures
```

### Write your diagram source as a `.mmd` file

```
diagrams/
  flowchart.mmd
  sequence.mmd
  gantt.mmd
```

After rendering, upload the output files (`figures/*.pdf`) to Overleaf and reference them with the `image=` option.

---

## Complete Examples

See [`examples/example.tex`](examples/example.tex) for a full document demonstrating:

- All 9 diagram types
- All 5 themes
- Both modes (source display and image mode)
- Inline code, workflow box, and live note

---

## Workflow Summary

```
1. Write Mermaid source in \begin{mermaid}...\end{mermaid}
   → Compiles on Overleaf as a syntax-highlighted listing

2. (Optional) Paste source into https://mermaid.live
   → Export as PDF or SVG

3. Upload the exported file to your Overleaf project

4. Add image={path/to/file.pdf} to your mermaid environment
   → Renders image + source listing together
```

---

## Supported Diagram Types

| Keyword | Type |
|---|---|
| `flowchart TD/LR/RL/BT` | Flowchart |
| `sequenceDiagram` | Sequence diagram |
| `gantt` | Gantt chart |
| `classDiagram` | Class diagram |
| `stateDiagram-v2` | State machine |
| `erDiagram` | Entity-relationship |
| `pie` | Pie chart |
| `timeline` | Timeline |
| `mindmap` | Mind map |
| `gitGraph` | Git graph |
| `journey` | User journey |

---

## Repository Structure

```
mermaid-overleaf/
├── mermaid-overleaf.sty      ← The LaTeX package (add this to Overleaf)
├── README.md
├── LICENSE
├── examples/
│   ├── example.tex           ← Full demo document
│   └── diagrams/
│       ├── flowchart.mmd
│       ├── sequence.mmd
│       └── ...
└── scripts/
    ├── render.sh             ← Batch render (Linux/macOS)
    └── render.ps1            ← Batch render (Windows)
```

---

## Contributing

Pull requests welcome! Areas to contribute:

- New themes
- New diagram-type badge icons
- TikZ-drawn fallback diagrams for specific types
- CI to test `.tex` compilation

---

## License

LPPL 1.3c — The LaTeX Project Public License.
