# Copilot Instructions

## Build Commands

Build from the repo root (requires [MiKTeX](https://miktex.org/download) or TeX Live with `lualatex`):

```powershell
# Full build (English + Chinese PDFs + PNGs)
.\src\build.ps1

# PDF only, skip PNG conversion (no ImageMagick/Ghostscript needed)
.\src\build.ps1 -SkipPng

# English resume only
.\src\build.ps1 -EnOnly
.\src\build.ps1 -EnOnly -SkipPng
```

To compile a single resume manually (from `src/`):

```bash
cd src
lualatex --interaction=nonstopmode resume.tex
lualatex --interaction=nonstopmode resumeCN.tex
```

The build compiles LaTeX → PDF, optionally converts PDF → PNG, then copies PDFs to the repo root.

## Architecture

This is a LaTeX CV built on a **customized [Awesome-CV](https://github.com/posquit0/Awesome-CV) template**. Despite `%!TEX TS-program = xelatex` comments in the `.tex` files, the project uses **LuaLaTeX** (not XeLaTeX).

### Key files

- `src/awesome-cv.cls` — Custom document class, forked from Awesome-CV with local modifications (do not replace with upstream)
- `src/resume.tex` — English resume entry point
- `src/resumeCN.tex` — Chinese resume entry point (uses `luatexja-fontspec` for CJK support)
- `src/resume/` — English section files (education, experience, events, projects, skills)
- `src/resumeCN/` — Chinese section files (parallel structure, translated content)
- `src/fonts/` — Bundled fonts (Roboto, FontAwesome, SourceHanSansSC)

### Content flow

Each main `.tex` file `\input`s section files in order. To add/remove/reorder sections, edit the `\input` lines in `resume.tex` or `resumeCN.tex`. Content changes go in the individual section files.

## Key Conventions

### Custom macros in `awesome-cv.cls`

The class defines custom entry commands — these are **not standard LaTeX**:

- `\cventry{position}{title}{location}{date}{description}` — Work experience, projects, events
- `\eduentry{degree}{institution}{location}{date}{description}` — Education (custom addition, not in upstream Awesome-CV)
- `\cvskill{category}{items}` — Skills section
- `\cvhonor{award}{title}{location}{date}` — Honors

Descriptions use `\begin{cvitems}` with `\item` entries inside.

### Layout workaround in `awesome-cv.cls`

The `\cventry` and `\eduentry` macros place the description **outside** the `tabular*` environment (line ~621). This is a deliberate workaround — MiKTeX's LuaTeX doesn't correctly calculate row heights for multicolumn `m{}` columns when content has negative vspace. Do not move the description back inside the table.

### Two-resume symmetry

English (`src/resume/`) and Chinese (`src/resumeCN/`) share the same section structure. When updating content, consider whether the change applies to both versions.

### CI/CD

Two GitHub Actions workflows run on push/PR to `master`:
1. **convert_cv_pdf_png** — Compiles both resumes, generates PNGs, commits artifacts back
2. **update_resume_on_website** — Converts English resume to HTML via Pandoc and pushes to the personal-website repo
