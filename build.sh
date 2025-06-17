#!/bin/bash

# Build script for CV - converts markdown to PDF using pandoc
set -e

# Configuration
SOURCE_FILE="kozuch_cv.md"
OUTPUT_DIR="output"
OUTPUT_FILE="kozuch_cv.pdf"
TEMP_FILE="temp_cv.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building CV PDF...${NC}"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}Error: Source file '$SOURCE_FILE' not found${NC}"
    exit 1
fi

# Load configuration
EMAIL=""
PHONE=""

# Check for environment variables first (GitHub Actions)
if [ -n "$CV_EMAIL" ] && [ -n "$CV_PHONE" ]; then
    echo -e "${YELLOW}Using environment variables for configuration${NC}"
    EMAIL="$CV_EMAIL"
    PHONE="$CV_PHONE"
elif [ -f "config.local" ]; then
    echo -e "${YELLOW}Loading configuration from config.local${NC}"
    source config.local
else
    echo -e "${YELLOW}No config found. Using placeholders.${NC}"
    EMAIL="your.email@example.com"
    PHONE="+421 XXX XXX XXX"
fi

# Substitute variables in markdown
echo -e "${YELLOW}Substituting variables...${NC}"
sed -e "s/{{email}}/$EMAIL/g" \
    -e "s/{{phone}}/$PHONE/g" \
    -e "s/📧/**Email**:/g" \
    -e "s/📱/**Phone**:/g" \
    -e "s/🔗/**LinkedIn**:/g" \
    -e "s/💻/**GitHub**:/g" \
    -e "s/📄/**CV source**:/g" \
    -e "s/📍/**Location**:/g" \
    "$SOURCE_FILE" > "$TEMP_FILE"

echo -e "${GREEN}✓ Variables substituted successfully${NC}"

# Check build method - Docker or local pandoc
USE_DOCKER=false

if command -v docker &> /dev/null && [ "$FORCE_LOCAL" != "1" ]; then
    echo -e "${YELLOW}Docker detected, using containerized build...${NC}"
    USE_DOCKER=true
elif command -v pandoc &> /dev/null; then
    echo -e "${YELLOW}Using local pandoc installation...${NC}"
    USE_DOCKER=false
else
    echo -e "${RED}Error: Neither Docker nor pandoc is available${NC}"
    echo "Options:"
    echo "1. Install Docker (recommended)"
    echo "2. Install pandoc: sudo apt-get install pandoc texlive-latex-recommended texlive-fonts-recommended"
    echo "3. Force local build: FORCE_LOCAL=1 ./build.sh"
    exit 1
fi

# Convert to PDF using pandoc with professional settings
echo -e "${YELLOW}Converting to PDF...${NC}"

PANDOC_ARGS="'$TEMP_FILE' \
    --pdf-engine=xelatex \
    --variable=geometry:margin=2cm \
    --variable=fontsize:11pt \
    --variable=linkcolor:blue \
    --variable=urlcolor:blue \
    --variable=toccolor:blue \
    --include-in-header=<(echo '\usepackage{fancyhdr}') \
    --include-in-header=<(echo '\pagestyle{fancy}') \
    --include-in-header=<(echo '\fancyhf{}') \
    --include-in-header=<(echo '\rhead{\thepage}') \
    --include-in-header=<(echo '\renewcommand{\headrulewidth}{0pt}') \
    -o '$OUTPUT_DIR/$OUTPUT_FILE'"

if [ "$USE_DOCKER" = true ]; then
    docker run --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        --entrypoint sh \
        pandoc/latex:latest \
        -c "pandoc $PANDOC_ARGS"
else
    eval "pandoc $PANDOC_ARGS"
fi

# Clean up temporary file
rm -f "$TEMP_FILE"

if [ -f "$OUTPUT_DIR/$OUTPUT_FILE" ]; then
    echo -e "${GREEN}✓ PDF generated successfully: $OUTPUT_DIR/$OUTPUT_FILE${NC}"
    
    # Show file size
    SIZE=$(du -h "$OUTPUT_DIR/$OUTPUT_FILE" | cut -f1)
    echo -e "${GREEN}File size: $SIZE${NC}"
else
    echo -e "${RED}Error: PDF generation failed${NC}"
    exit 1
fi