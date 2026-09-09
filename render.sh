#!/usr/bin/env bash
# =============================================================
#  render.sh — Pre-render Mermaid .mmd files to PDF/SVG/PNG
#              for use with mermaid-overleaf on cloud Overleaf
#
#  REQUIREMENTS:
#    npm install -g @mermaid-js/mermaid-cli
#    (installs mmdc — requires Node.js 18+ and Chromium)
#
#  USAGE:
#    ./render.sh                     # render all .mmd in current dir → PDF
#    ./render.sh diagrams/ figs/     # source dir → output dir
#    ./render.sh -f svg diagrams/    # output SVG instead of PDF
#    ./render.sh -f png -t dark .    # PNG with dark mermaid theme
#    ./render.sh --help
# =============================================================

set -euo pipefail

# ── Defaults ──────────────────────────────────────────────────
FORMAT="pdf"
THEME="default"       # mermaid built-in: default|dark|forest|neutral
BG="white"
SCALE="2"             # retina-quality PNGs
SRC_DIR="."
OUT_DIR=""            # if empty, output goes next to source

# ── Colours for terminal output ───────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; RESET='\033[0m'; BOLD='\033[1m'

log()  { echo -e "${CYAN}[render]${RESET} $*"; }
ok()   { echo -e "${GREEN}[  OK  ]${RESET} $*"; }
warn() { echo -e "${YELLOW}[ WARN ]${RESET} $*"; }
err()  { echo -e "${RED}[ ERR  ]${RESET} $*" >&2; }

# ── Help ──────────────────────────────────────────────────────
usage() {
cat <<EOF
${BOLD}render.sh${RESET} — render Mermaid diagrams to PDF/SVG/PNG

${BOLD}USAGE${RESET}
  ./render.sh [OPTIONS] [SRC_DIR [OUT_DIR]]

${BOLD}OPTIONS${RESET}
  -f, --format  <pdf|svg|png>   Output format (default: pdf)
  -t, --theme   <theme>         Mermaid theme: default|dark|forest|neutral
  -b, --bg      <colour>        Background colour (default: white)
  -s, --scale   <number>        Scale for PNG output (default: 2)
  -h, --help                    Show this help

${BOLD}EXAMPLES${RESET}
  ./render.sh                           # all .mmd here → PDF
  ./render.sh diagrams/ figs/           # diagrams/ → figs/
  ./render.sh -f svg -t dark diagrams/  # SVG, dark theme
  ./render.sh -f png -s 3 .             # PNG @3x

${BOLD}AFTER RENDERING${RESET}
  Upload the generated files to your Overleaf project, then use:

    \\begin{mermaid}[image=figs/mydiagram.pdf, caption={My diagram}]
      ... mermaid source ...
    \\end{mermaid}
EOF
}

# ── Argument parsing ──────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--format) FORMAT="$2"; shift 2 ;;
    -t|--theme)  THEME="$2";  shift 2 ;;
    -b|--bg)     BG="$2";     shift 2 ;;
    -s|--scale)  SCALE="$2";  shift 2 ;;
    -h|--help)   usage; exit 0 ;;
    -*)          err "Unknown option: $1"; usage; exit 1 ;;
    *)
      if [[ -z "$SRC_DIR" || "$SRC_DIR" == "." ]]; then
        SRC_DIR="$1"
      else
        OUT_DIR="$1"
      fi
      shift ;;
  esac
done

# Validate format
case "$FORMAT" in
  pdf|svg|png) ;;
  *) err "Invalid format '$FORMAT'. Use pdf, svg, or png."; exit 1 ;;
esac

# ── Check mmdc is available ───────────────────────────────────
if ! command -v mmdc &>/dev/null; then
  err "mmdc not found. Install it with:"
  err "  npm install -g @mermaid-js/mermaid-cli"
  exit 1
fi

log "Using mmdc: $(mmdc --version 2>/dev/null || echo 'unknown version')"

# ── Find source files ─────────────────────────────────────────
MMD_FILES=()
while IFS= read -r -d '' f; do
  MMD_FILES+=("$f")
done < <(find "$SRC_DIR" -maxdepth 3 -name "*.mmd" -print0 | sort -z)

if [[ ${#MMD_FILES[@]} -eq 0 ]]; then
  warn "No .mmd files found in '$SRC_DIR'."
  exit 0
fi

log "Found ${#MMD_FILES[@]} .mmd file(s) in '$SRC_DIR'"

# ── Render loop ───────────────────────────────────────────────
PASS=0; FAIL=0

for SRC in "${MMD_FILES[@]}"; do
  BASENAME=$(basename "$SRC" .mmd)

  if [[ -n "$OUT_DIR" ]]; then
    mkdir -p "$OUT_DIR"
    DEST="$OUT_DIR/$BASENAME.$FORMAT"
  else
    DEST="$(dirname "$SRC")/$BASENAME.$FORMAT"
  fi

  log "Rendering ${BOLD}$SRC${RESET} → $DEST"

  MMDC_ARGS=(
    --input  "$SRC"
    --output "$DEST"
    --theme  "$THEME"
    --backgroundColor "$BG"
    --pdfFit
  )

  if [[ "$FORMAT" == "png" ]]; then
    MMDC_ARGS+=(--scale "$SCALE")
  fi

  if mmdc "${MMDC_ARGS[@]}" 2>/dev/null; then
    ok "$BASENAME.$FORMAT"
    (( PASS++ )) || true
  else
    err "Failed: $SRC"
    (( FAIL++ )) || true
  fi
done

# ── Summary ───────────────────────────────────────────────────
echo ""
log "Done: ${GREEN}${PASS} rendered${RESET}, ${RED}${FAIL} failed${RESET}"

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
