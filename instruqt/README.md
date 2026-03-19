# Instruqt track (Serverless)

The only Instruqt track in this repo is **[review-bomb-workshop-serverless](https://play.instruqt.com/manage/elastic/tracks/review-bomb-workshop-serverless)** — **Elastic Cloud Serverless (Elasticsearch)**, same pattern as [elastic-autonomous-observability](https://play.instruqt.com/manage/elastic/tracks/elastic-autonomous-observability): `es3-api` + `elastic/es3-api-v2` + secrets + `track_scripts/setup-es3-api`.

Shared workshop content lives under **`instruqt/`** (`challenges/`, `lib/`, `startup-serverless.sh`) and is symlinked from **`review-bomb-workshop-serverless/`**.

Challenge **Scripts** (like [elastic-autonomous-observability / connect-and-deploy](https://play.instruqt.com/manage/elastic/tracks/elastic-autonomous-observability/challenges/connect-and-deploy/tabs)) use Instruqt’s **`setup-es3-api`**, **`check-es3-api`**, **`solve-es3-api`** naming so they bind to the **`es3-api`** host. The **Elastic Serverless** service tab uses **`path: /app/dashboards#/list?...`** on port **8080** (same idea as AO’s “Elastic Serverless” tab).

## Challenge layout

Keep **one** challenge tree: `instruqt/challenges/01-…`. The **pushable** track root is `review-bomb-workshop-serverless/` with `assignment: challenges/01-…/assignment.md`.

Do **not** add duplicate folders as `instruqt/01-getting-to-know-your-data/` or next to the serverless `challenges/` symlink — Instruqt will report **duplicate slug**.

## Loading / wait screens

- **`lab_config.loadingMessages: true`** — rotating tips on the loading bar ([loading experience](https://docs.instruqt.com/tracks/manage/loading-experience)).
- **`enhanced_loading: false`** — **Notes only** (slide carousel while the lab loads), aligned with **elastic-autonomous-observability**.
- **`notes:`** on each challenge — carousel copy while waiting.

## Prerequisites

- [Instruqt CLI](https://docs.instruqt.com/getting-started/installation): `instruqt auth login`
- Push permission for **`owner: elastic`** in `track-serverless.yml` (change if you fork).

## Validate & push

From repo root (after `git commit`):

```bash
make publish
```

That validates, **`git push origin main`**, **`instruqt track push --force`** for the serverless track, then re-syncs `track.yml` from `track-serverless.yml`.

Manual:

```bash
cd instruqt/review-bomb-workshop-serverless
instruqt track validate
instruqt track push --force
```

## Serverless directory layout

| Path | Role |
|------|------|
| `review-bomb-workshop-serverless/track.yml` | Copy of `../track-serverless.yml` (re-copy after edits to the source file). |
| `review-bomb-workshop-serverless/config.yml` | `es3-api`, `elastic/es3-api-v2`, **`ESS_CLOUD_API_KEY`**, **`LLM_PROXY_PROD`**. |
| `review-bomb-workshop-serverless/track_scripts/setup-es3-api` | Provision project, nginx **:8080** / **:9200**, run `startup-serverless.sh`. |
| `review-bomb-workshop-serverless/track_scripts/cleanup-es3-api` | Delete Serverless project. |
| `track-serverless.yml` | Source for track metadata (author here, then copy to `review-bomb-workshop-serverless/track.yml`). |

### `instruqt track push` side effects

The CLI may **shorten** `review-bomb-workshop-serverless/track.yml` and create **`01-*`…`04-*`** next to the `challenges/` symlink → duplicate slugs until removed.

**`make publish`** already runs `rm -rf …/01-*` and `cp track-serverless.yml …/track.yml`. Stray dirs are in **`.gitignore`**.

**Remote track id:** `track-serverless.yml` must keep Instruqt’s internal **`id: 6cqqeywqqnqc`**. Using the slug as `id` causes **`Entity already exists`** on push.

**Challenge ids:** Each challenge needs Instruqt’s **opaque `id`** (not `01-getting-to-know-your-data`). If the loading carousel shows **“Failed to fetch status” / “Entity not found”**, ids are out of sync. Fix: `instruqt track pull elastic/review-bomb-workshop-serverless --force`, then copy each `id:` from the pulled `assignment.md` YAML frontmatter into `track-serverless.yml`, re-copy to `review-bomb-workshop-serverless/track.yml`, and push.

### Removing the old `review-bomb-workshop` track on Instruqt

The separate slug **`review-bomb-workshop`** is no longer maintained in this repo. Delete or archive it in the [Instruqt UI](https://play.instruqt.com/manage/elastic/tracks/review-bomb-workshop) if you no longer need it.

## References

- [docs/instruqt-serverless.md](../docs/instruqt-serverless.md)
- [Instruqt configuration files](https://docs.instruqt.com/reference/cli/configuration-files)
