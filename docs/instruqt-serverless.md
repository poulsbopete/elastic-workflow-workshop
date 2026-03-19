# Running the Workshop on Elastic Serverless (Elasticsearch) with Instruqt

**Manage this track in Instruqt:** [review-bomb-workshop-serverless](https://play.instruqt.com/manage/elastic/tracks/review-bomb-workshop-serverless)

This guide describes the **Serverless** variant of the Negative Review Campaign Detection workshop. It is **based on the same Instruqt pattern as [Elastic Autonomous Observability](https://play.instruqt.com/manage/elastic/tracks/elastic-autonomous-observability)**:

- Host **`es3-api`** with image **`elastic/es3-api-v2`**
- Secrets **`ESS_CLOUD_API_KEY`** (Elastic Cloud API key for `bin/es3-api.py` to create/delete Serverless projects) and **`LLM_PROXY_PROD`** (for Agent Builder / LLM proxy in the lab, same pattern as other Elastic workshops)
- **`track_scripts/setup-es3-api`** provisions a **Serverless Elasticsearch** project (`PROJECT_TYPE=elasticsearch`), then configures **nginx** so:
  - **Kibana** is available on the VM at **`:8080`** (proxy to Cloud Kibana, Basic auth injected — same idea as the AO track)
  - **Elasticsearch** is available at **`:9200`** (proxy to Cloud ES)
- **`instruqt/startup-serverless.sh`** then bulk-loads workshop indices and starts **FastAPI on `:8000`**

Pushable track root: **`instruqt/review-bomb-workshop-serverless/`** (contains `track.yml`, `config.yml`, `track_scripts/`, symlinks to shared `challenges/` and `lib/`).

**Loading / wait UX:** `enhanced_loading: false` in `track.yml` matches Instruqt **[Notes only](https://docs.instruqt.com/tracks/manage/loading-experience)** — learners see the challenge **`notes:`** carousel (slides) while the sandbox provisions, like **[elastic-autonomous-observability](https://play.instruqt.com/manage/elastic/tracks/elastic-autonomous-observability)**. Setting `enhanced_loading: true` switches to **Full access** and shows assignment + tabs early with generic per-tab loading text instead.

## Sandbox summary

| Aspect | This Instruqt track |
|--------|---------------------|
| **Host** | **`es3-api`** (`elastic/es3-api-v2`) |
| **Elasticsearch** | **Serverless Elasticsearch** project (created per participant) |
| **Kibana tab** | **`:8080`** on `es3-api` (nginx → Cloud) |
| **Data** | **Bulk API** via `startup-serverless.sh` |
| **Secrets** | **`ESS_CLOUD_API_KEY`**, **`LLM_PROXY_PROD`** (Sandbox → Secrets) |

## Prerequisites (Instruqt track admin)

1. **Secrets (Sandbox → Secrets)**  
   - **`ESS_CLOUD_API_KEY`** — Elastic Cloud **organization** API key (same pattern as [elastic-autonomous-observability](https://play.instruqt.com/manage/elastic/tracks/elastic-autonomous-observability)). Required for `es3-api-v2` provisioning.  
   - **`LLM_PROXY_PROD`** — Retain for Kibana **Agent Builder** / LLM-backed steps. Declared in `config.yml` so `instruqt track push` does not drop it from the track definition.

2. **Optional: workshop Git repo / branch**  
   `track_scripts/setup-es3-api` clones **`WORKSHOP_REPO`** (default `https://github.com/poulsbopete/elastic-workflow-workshop.git`) and checks out **`WORKSHOP_BRANCH`** (default `main`). Set both under `virtualmachines[].environment` in `config.yml` if you publish from another fork or branch.

3. **Validate & push** (from repo root):

   ```bash
   cd instruqt/review-bomb-workshop-serverless
   instruqt auth login
   instruqt track validate
   instruqt track push
   ```

   On first publish you may need to create the remote track in the Instruqt UI or align `track.yml` `id` with `instruqt track pull`.

## Participant environment

After setup, the VM exports (via `/etc/profile.d/elastic-workshop-serverless.sh`):

- `ELASTICSEARCH_URL=http://127.0.0.1:9200`
- `KIBANA_URL=http://127.0.0.1:8080`
- `ELASTICSEARCH_API_KEY=…` (for Terminal / challenge scripts)

Challenge scripts that source `instruqt/lib/auth.sh` use **`es_curl`** and work with this layout.

## Files (Serverless / es3-api)

| Path | Purpose |
|------|--------|
| `instruqt/review-bomb-workshop-serverless/config.yml` | Sandbox: `es3-api`, `ESS_CLOUD_API_KEY` |
| `instruqt/review-bomb-workshop-serverless/track_scripts/setup-es3-api` | Provision project, nginx, clone repo, run `startup-serverless.sh` |
| `instruqt/review-bomb-workshop-serverless/track_scripts/cleanup-es3-api` | Delete Serverless project via `es3-api.py` |
| `instruqt/track-serverless.yml` | Source copy of track metadata (synced to `review-bomb-workshop-serverless/track.yml`) |
| `instruqt/startup-serverless.sh` | Indices + bulk load + uvicorn |
| `instruqt/config-serverless.yml` | Reference duplicate of sandbox config |

## ELSER (semantic search)

If the Serverless project has **ELSER**, `startup-serverless.sh` creates `semantic_text` fields. If not, it falls back to **`--skip-semantic`**.

## Troubleshooting track setup

| Symptom | What to check |
|--------|----------------|
| **`python3-venv` / broken `.venv/bin/python3`** | Use current repo: **`instruqt/lib/serverless_pydeps.sh`** + **`startup-serverless.sh`** install with **`pip install -t .pydeps`** and **`rm -rf .venv`**. **`setup-host-1-serverless`** no longer runs `python3 -m venv`. Commit, push Git, then re-run the track so `/opt/elastic-workflow-workshop` pulls the update. |
| **Stale clone on lab VM** | `setup-es3-api` runs `git pull` after clone; set **`WORKSHOP_REPO`** / branch in `config.yml` if you use a fork. |
| **API key errors** | Sandbox secret **`ESS_CLOUD_API_KEY`** must match the Elastic Cloud org key used by other `es3-api-v2` tracks. |
| **Logs** | `instruqt track logs review-bomb-workshop-serverless --since 15m` |

## Local run (no Instruqt)

Use a Serverless Elasticsearch project and `.env` with `ELASTICSEARCH_URL`, `ELASTICSEARCH_API_KEY`, and `KIBANA_URL` — see the main [README](../README.md) Serverless section.
