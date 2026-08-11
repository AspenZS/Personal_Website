# Jay Henderson — Zephyre Systems portfolio

A dependency-free static portfolio for Jay Henderson, published under the maker identity
**ZEPHYRE SYSTEMS / Aspen // ZS**.

## Live site

GitHub Pages serves the `main` branch as a project site:

<https://aspenzs.github.io/Personal_Website/>

## Structure

- `index.html` — semantic portfolio content, metadata, and structured data
- `styles.css` — responsive Zephyre visual system
- `script.js` — accessible mobile navigation and current-year behavior
- `favicon.svg` — current Zephyre Systems mark
- `social-card.svg` — social preview artwork
- `manifest.webmanifest` — install and theme metadata
- `404.html` — branded not-found page
- `robots.txt` and `sitemap.xml` — discovery metadata
- `scripts/validate-site.ps1` — local source, identity, asset, and link validation

The legacy `favicon.ico` is retained only as repository history and is not referenced by the
current release.

## Local preview

From this repository:

```powershell
python -m http.server 8000
```

Then open <http://127.0.0.1:8000/>.

## Validation

```powershell
pwsh -NoProfile -File .\scripts\validate-site.ps1
```

The validator checks required files and metadata, local assets, duplicate IDs, stale GitHub
identity references, and prohibited legacy maker identities.

## Deployment

GitHub Pages publishes from `main` at the repository root. Assets intentionally use relative paths
so local previews and project-site hosting behave consistently.
