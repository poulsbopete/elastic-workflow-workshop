# Presentation materials

## What's New in Elastic Search 9.3 (Peter Simkins deck)

| File | Purpose |
|------|---------|
| [`marp/whats-new-elastic-search-9.3.md`](marp/whats-new-elastic-search-9.3.md) | **Marp** slide source (20 slides), converted from the PDF deck. Version-controlled in Git. |
| [`slides.md`](slides.md) | Longer workshop slide outline (legacy / alternate). |
| [`talk-track.md`](talk-track.md) | Presenter speaking notes. |

### Build HTML / PDF from Git (Marp)

Install [Marp CLI](https://github.com/marp-team/marp-cli) once:

```bash
npm install -g @marp-team/marp-cli
```

From the **repository root**:

```bash
make presentation-html
# writes docs/slides/whats-new-elastic-search-9.3.html (for GitHub Pages /docs)
```

**GitHub Pages:** Settings → Pages → **Deploy from branch** → `main` → **`/docs`**. The site root is **`docs/index.html`**, which links to the built deck under **`docs/slides/`**. Commit the HTML after running `make presentation-html` (outputs are not ignored under `docs/slides/`).

Optional local PDF (not committed by default):

```bash
npx @marp-team/marp-cli --no-stdin presentation/marp/whats-new-elastic-search-9.3.md --pdf -o presentation/marp/whats-new-elastic-search-9.3.pdf
```

**VS Code:** install the [Marp for VS Code](https://marketplace.visualstudio.com/items?itemName=marp-team.marp-vscode) extension and open the `.md` file for live preview.

### Instruqt wait carousel

The **same narrative** (agenda, philosophy, review-bomb context, journey, challenges) is reflected in **`instruqt/track-serverless.yml`** (Instruqt track) under each challenge’s `notes:` blocks — shown as **slides while labs load** when **`enhanced_loading: false`** (Instruqt “Notes only”; same idea as elastic-autonomous-observability).

When you **change the Marp deck**, update those `notes:` sections (or ask to regenerate) so facilitators and learners stay aligned.

Source PDF (local only, not in repo): *Peter's What's New In Elastic - Search 9.3.pdf*
