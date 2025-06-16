# CV Build System

This repository contains a build system for generating a professional PDF from a markdown CV.

## Files

- `kozuch_cv.md` - The main CV in markdown format
- `build.sh` - Build script that converts markdown to PDF
- `.github/workflows/build-cv.yml` - GitHub Actions workflow for automated building
- `config.local.example` - Example configuration file for local builds

## GitHub Actions Build

The repository is set up with GitHub Actions to automatically build the PDF on every push to main/master branch.

### Required Secrets

To use the automated build, you need to set these repository secrets:

1. Go to your repository Settings → Secrets and variables → Actions
2. Add these secrets:
   - `CV_EMAIL`: Your email address
   - `CV_PHONE`: Your phone number

### Workflow Features

- Builds PDF on every push to main/master
- Creates downloadable artifacts
- Automatically creates releases with PDF when you push a tag

### Creating a Release

To create a release with the PDF:

```bash
git tag v1.0.0
git push origin v1.0.0
```

## Local Development

### Prerequisites

Install required tools:

```bash
# Ubuntu/Debian
sudo apt-get install pandoc texlive-latex-recommended texlive-latex-extra texlive-fonts-recommended

# macOS
brew install pandoc
brew install --cask mactex
```

### Local Configuration

1. Copy the example config file:
   ```bash
   cp config.local.example config.local
   ```

2. Edit `config.local` with your details:
   ```bash
   EMAIL="your.email@example.com"
   PHONE="+421 XXX XXX XXX"
   ```

3. Build the PDF:
   ```bash
   chmod +x build.sh
   ./build.sh
   ```

The generated PDF will be saved to `output/kozuch_cv.pdf`.

### Build Script Features

- Substitutes `{{email}}` and `{{phone}}` placeholders
- Professional PDF formatting with proper margins and fonts
- Error handling and colored output
- Automatic output directory creation

## File Structure

```
.
├── kozuch_cv.md              # Main CV source
├── build.sh                  # Build script
├── config.local.example      # Configuration template
├── config.local              # Local configuration (git-ignored)
├── output/                   # Generated files (git-ignored)
│   └── kozuch_cv.pdf        # Generated PDF
└── .github/
    └── workflows/
        └── build-cv.yml      # GitHub Actions workflow
```

## Customization

The build script uses pandoc with the following settings:
- PDF engine: pdflatex
- Margins: 2cm
- Font size: 11pt
- Link colors: blue
- Page numbers in header

To customize the PDF output, modify the pandoc command in `build.sh`.
