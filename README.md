# Research Map

A local web app for mapping research articles onto an interactive graph of **drugs / research compounds → targets → pathways → effects / diseases**, with Claude built in for extraction, descriptions and Q&A.

## What it does

- **Add articles** by PMID, PubMed link, PMC ID or link, DOI, arXiv, bioRxiv/medRxiv, or any article URL. You can paste several at once, one per line. You can also paste raw text or upload a PDF (**More…**).
  - PubMed metadata, abstract, MeSH terms and indexed chemicals come from NCBI E-utilities. When an open-access PMC version exists, the full text is pulled in too.
  - DOIs that aren't in PubMed are resolved through Crossref. Other web pages are read through their `citation_*` meta tags or page text.
- **AI extraction**: Claude reads each article and adds:
  - entities: drugs, targets, pathways, diseases, effects and formulations;
  - typed links: *inhibits, activates, up/downregulates, binds, agonist/antagonist of, modulates, part of, treats, increases/decreases…*;
  - for each link, the **mechanism**, **dose**, **model system**, **evidence**, **effect size** and **confidence**.

  Entities with the same name or alias are merged across articles, so the map grows into one connected network.
- **Interactive map** (Cytoscape.js):
  - Click a node to highlight its neighbourhood (1–4 hops) and open its details.
  - Click a link to see every supporting article and its mechanism.
  - Filter by entity type or relation type, search, and switch layouts. The default is **circular rings**: drugs at the centre, then targets, pathways, and effects/diseases on the outer ring, with faint guide circles. Each ring is ordered to minimise crossing links. Auto-optimized (free-form), layered, circle and grid are also available.
  - **Auto-arranging on every import**:
    - New nodes start next to the nodes they connect to. Then the map is re-optimized in the current layout. In the circular view, rings are reordered to cut crossings while keeping your existing order when it's about as good. In the free-form view, the fcose force layout accounts for label sizes.
    - Two candidate arrangements (refine the current one, or start fresh) are scored on edge crossings, overlapping nodes/labels, uneven edge lengths and spread. The better one is animated in, with a small preference for keeping your current arrangement.
    - Newly added nodes flash so you can spot them.
    - The layered view orders each column to minimise crossing links.
    - **Re-arrange** re-optimizes from scratch at any time.
  - Add your own nodes and links, merge duplicate nodes, and export to PNG or JSON.
- **Compare efficacy** (toolbar **Compare**, or **Compare…** on any node): put compounds or targets side by side, e.g. SPIN4 inhibition vs FGFR3 inhibition on overgrowth.
  - Every function/outcome each item reaches is traced through the map, directly or along the drug → target → pathway → effect chain (1–4 steps).
  - Each cell shows the net direction (↑ raises / ↓ lowers / ↕ mixed), the route, the reported effect sizes, evidence strength and source count.
  - **⊣ inhibited** on an item flips it to "what happens if you inhibit or knock it down".
  - Pick one outcome to see every route and its dose, model system and evidence side by side. "Similar in your map" suggests items that share outcomes.
  - **Compare with AI** has Claude weigh effect sizes, doses and model systems from your articles, and flag where the studies aren't comparable.
- **AI descriptions**: one click writes a brief on any drug, target or pathway, grounded in your mapped articles with PMID citations, or a structured summary of any article. Both are saved.
- **Ask AI**: chat about a topic, pathway, research drug, formulation or dose calculation.
  - Select a node to focus the question on it.
  - Claude can search your map and read your articles.
  - It does arithmetic **only through built-in calculator tools**, never in its head.
  - Optional web search is available.
- **Dose calculator tab** (works without AI):
  - FDA BSA/Km species conversion (HED)
  - weight-based dose
  - vial reconstitution (mg/mL, mL and U-100 syringe units per dose)
  - molarity / stock solutions, C1V1 = C2V2, body surface area, and a general calculator.

> For research and education only. Not medical advice. Check every calculation yourself before using it.

## Run it locally

Requires Python 3.10+.

### AI runs on your Claude plan, not an API key

The desktop app calls Claude through [Claude Code](https://claude.com/claude-code) signed in with your Claude (Pro / Max) account, so AI use counts against your plan's usage limits rather than API billing.
- Sign in once in a terminal with `claude auth login`. Check with `claude auth status`, which should show `"authMethod": "claude.ai"`.
- The app never uses an API key. `ANTHROPIC_API_KEY` / `ANTHROPIC_AUTH_TOKEN` are removed from the environment of every Claude call, even when they're set.
- Each call runs in an empty temporary folder with your personal Claude Code settings, plugins, hooks and MCP servers turned off. In chat, Claude reaches your map and the dose calculators through the app's own tool server (`app/mcp_server.py`).
- The **AI** pill at the top shows `AI: Claude plan` when this is working. Hover over it for details.
- Anthropic doesn't allow apps offered to other people to use claude.ai login, so this setup is for your own use on your own machine.

**Windows:** double-click `start.bat`. On first run it creates `.venv` and installs the requirements, then opens the app. If port 8000 is busy, the next free port is used.

Manual setup (any OS):

```bash
python -m venv .venv
source .venv/bin/activate          # Windows: .venv\Scripts\activate
pip install -r requirements.txt
claude auth login                  # once: sign in with your Claude account
python run.py                      # opens http://127.0.0.1:8000
```

Without Claude Code signed in, the app still works: articles are fetched and placed on the map using PubMed's indexed chemicals and MeSH terms, and the calculators work. AI extraction, descriptions, chat and Compare with AI need the sign-in.

### Optional settings (environment variables)

| Variable | Default | Purpose |
|---|---|---|
| `RESEARCH_MAP_MODEL` | `claude-opus-5-5` | Claude model |
| `RESEARCH_MAP_EXTRACT_EFFORT` | `medium` | Effort for article extraction (`low`…`max`) |
| `RESEARCH_MAP_CHAT_EFFORT` | `high` | Effort for chat answers |
| `CLAUDE_BIN` | found on `PATH` | Path to the `claude` executable, if it isn't on `PATH` |
| `RESEARCH_MAP_DB` | `data/research_map.db` | Where your map is stored (SQLite) |
| `NCBI_API_KEY` | – | Raises NCBI's rate limit if you add many PubMed articles |
| `PORT` / `HOST` | `8000` / `127.0.0.1` | Server address |

## iPad version

There's a separate edition that runs entirely in Safari on an iPad. It needs no Python or server, and you can add it to your Home Screen.
- **Download:** `dist/research-map-ipad.zip`, or the ready-to-host `docs/` folder.
- **Setup:** see [ipad/README.md](ipad/README.md). The quickest route is GitHub Pages from the `docs/` folder, then **Share → Add to Home Screen** in Safari.
- **What it includes:** everything above. Your map lives on the iPad.
- **AI on the iPad needs an API key**, entered in **Settings**. Safari can't run Claude Code, so it can't use your Claude plan. Only the desktop app runs on your plan.
- **Moving maps:** **Export** from one version and **Import** into the other.
- **Rebuilding after changing the app:** `python ipad/build.py`.

## Project layout

```
run.py              start the server
app/main.py         FastAPI routes
app/sources.py      PubMed / PMC / DOI / arXiv / URL fetching
app/ai.py           Claude extraction, descriptions, chat, compare
app/claude_plan.py  runs Claude on your Claude plan via the Claude Code CLI (no API key)
app/mcp_server.py   map + calculator tools served to Claude during chat
app/dosing.py       deterministic dose & formulation calculators
app/db.py           SQLite storage (articles, entities, relations)
app/static/         front end (vendored Cytoscape, marked, DOMPurify - works offline)
ipad/               iPad / browser-only edition: in-page backend, build script
docs/, dist/        built iPad edition (generated by ipad/build.py)
tests/              pytest suite
```

Run the tests with `pip install pytest httpx && pytest`.
