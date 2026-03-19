# Running the Workshop on Elastic Serverless (Search) with Instruqt

This guide describes how to run the **Negative Review Campaign Detection** workshop against **Elastic Cloud Serverless (search)** using Instruqt, using [elastic-autonomous-observability](https://play.instruqt.com/manage/elastic/tracks/elastic-autonomous-observability) as the environment base.

## Differences from the ECK/Snapshot Track

| Aspect | ECK track (default) | Serverless track |
|--------|---------------------|------------------|
| **Elasticsearch** | ECK-managed cluster in the lab (Kubernetes VM) | Elastic Cloud Serverless (search) project |
| **Data loading** | GCS snapshot restore | Bulk API (create indices + load from `data/sample` or generated data) |
| **Authentication** | Username/password or API key | API key only |
| **Index settings** | May use `number_of_shards` / `number_of_replicas` | Serverless-compatible (no shard settings) |
| **Hosts** | `kubernetes-vm` + `host-1` | Single VM `host-1` |

## Prerequisites

1. **Elastic Cloud Serverless (search) project**  
   Create a project in [Elastic Cloud](https://cloud.elastic.co) (Search product). Note:
   - **Elasticsearch URL** (e.g. `https://<deployment>.es.<region>.gcp.elastic.cloud:443`)
   - **Kibana URL** (e.g. `https://<deployment>.kb.<region>.gcp.elastic.cloud:443`)
   - **API key** with privileges to create indices, index documents, and run searches

2. **Instruqt track configuration**  
   Use the Serverless track and config in this repo:
   - `instruqt/track-serverless.yml` – track definition (challenges, tabs)
   - `instruqt/config-serverless.yml` – sandbox (one VM: `host-1`)
   - `instruqt/startup-serverless.sh` – track startup (create indices, load data, start app)

3. **Connection in Instruqt**  
   Attach an **Elastic Cloud connection** to the track so the following are set on `host-1`:
   - `ELASTICSEARCH_URL`
   - `ELASTICSEARCH_API_KEY` (or `ELASTICSEARCH_APIKEY`)
   - `KIBANA_URL`

## Using elastic-autonomous-observability as a Base

The [elastic-autonomous-observability](https://play.instruqt.com/manage/elastic/tracks/elastic-autonomous-observability) track is a reference for how to structure an Instruqt track that uses Elastic Cloud Serverless:

- **Single host** (or minimal set of hosts) that receive Cloud credentials via the connection.
- **No in-lab Elasticsearch/Kibana** – all ES and Kibana traffic goes to Cloud.
- **Data setup** via API (bulk index, ingest) rather than snapshot restore.

To run this workshop on Serverless:

1. Create or clone a track that uses the same connection pattern as elastic-autonomous-observability (e.g. one VM with `ELASTICSEARCH_URL`, `ELASTICSEARCH_API_KEY`, `KIBANA_URL`).
2. Use `instruqt/track-serverless.yml` as the track definition and `instruqt/config-serverless.yml` as the sandbox.
3. Register **track-level setup** to run `instruqt/startup-serverless.sh` on `host-1` when the track starts. That script:
   - Waits for Elasticsearch
   - Clones the workshop repo
   - Writes `.env` with Serverless credentials
   - Creates indices with `admin/create_indices --serverless` (and optionally `--skip-semantic` if ELSER is not in the project)
   - Loads data via `admin/load_data` / `admin/setup_workshop_data.sh`
   - Creates `incidents` and `notifications` indices (mappings only, no shard settings)
   - Starts the FastAPI app on port 8000

4. For **Challenge 1**, use `setup-host-1-serverless` so the host has the repo, `.env`, and app running (or runs the full bootstrap if data is not yet loaded).

## Files Added for Serverless

| File | Purpose |
|------|--------|
| `instruqt/track-serverless.yml` | Track metadata and challenges (same content as main track, Serverless-oriented) |
| `instruqt/config-serverless.yml` | Sandbox: one VM `host-1`; connection injects ES/Kibana env vars |
| `instruqt/startup-serverless.sh` | Track startup: create indices, load data, start app (no snapshot) |
| `instruqt/lib/auth.sh` | Shared auth helper: `es_curl()` with API key or basic auth |
| `instruqt/challenges/01-getting-to-know-your-data/setup-host-1-serverless` | Challenge 1 setup for Serverless (clone, .env, optional bootstrap) |
| `admin/create_indices.py` | New `--serverless` flag to omit `number_of_shards` / `number_of_replicas` |

Challenge scripts (setup/check/solve) for 01 and 02 were updated to source `lib/auth.sh` and use `es_curl` so they work with API key (Serverless). Challenge 02 setup creates `incidents` and `notifications` with mappings only when API key is set (Serverless-safe).

## ELSER (Semantic Search)

- If your Serverless project has **ELSER** deployed, the startup script will create the `reviews` index with `semantic_text` and inference ID `.elser-2-elasticsearch` (or the one in your mappings).
- If ELSER is **not** available, run create_indices with `--skip-semantic` so the `reviews` index is created without `semantic_text` fields. The startup script tries with ELSER first and falls back to `--skip-semantic` on failure.

## Kibana Tab in Instruqt

For the default ECK track, Kibana is a **service** tab pointing at the in-lab Kibana (e.g. `elastic:5601`). For Serverless, Kibana lives in the cloud. You can:

- Use a **virtualbrowser** in `config-serverless.yml` that opens `KIBANA_URL`, or
- Rely on the Instruqt connection’s “Open Kibana” behavior if your org’s connection provides it.

Adjust the Kibana tab in `track-serverless.yml` if your Instruqt setup uses a virtualbrowser or a different mechanism for Cloud Kibana.

## Local / Non-Instruqt Serverless Run

To run the workshop locally against a Serverless project (no Instruqt):

1. Create a Serverless (search) project and get **Elasticsearch URL**, **Kibana URL**, and **API key**.
2. Copy `.env.example` to `.env` and set:
   - `ELASTICSEARCH_URL`
   - `ELASTICSEARCH_API_KEY`
   - `KIBANA_URL`
3. Create indices and load data:
   ```bash
   python -m admin.create_indices --delete-existing --force --serverless
   ./admin/setup_workshop_data.sh
   ```
4. Start the app: `uvicorn app.main:app --host 0.0.0.0 --port 8000`

This matches what `startup-serverless.sh` does in the Instruqt Serverless track.
