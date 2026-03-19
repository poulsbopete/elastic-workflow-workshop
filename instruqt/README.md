# Instruqt tracks

Two track roots live under this directory:

| Directory | Track slug | Use case |
|-----------|------------|----------|
| `instruqt/` (this folder) | `review-bomb-workshop` | ECK / snapshot workshop (`config.yml` → host `elastic`) |
| `review-bomb-workshop-serverless/` | [`review-bomb-workshop-serverless`](https://play.instruqt.com/manage/elastic/tracks/review-bomb-workshop-serverless) | **Serverless Elasticsearch** — same pattern as [elastic-autonomous-observability](https://play.instruqt.com/manage/elastic/tracks/elastic-autonomous-observability): `es3-api` + `elastic/es3-api-v2` + `ESS_CLOUD_API_KEY` + `track_scripts/setup-es3-api` |

## Challenge layout

Keep **one** challenge tree only: `challenges/01-…` under the track root (with `track.yml` beside it).

Do **not** add a second copy as `instruqt/01-getting-to-know-your-data/` etc. Instruqt will treat those as extra challenges and fail validation with **duplicate slug**.

## Loading / wait screens

- **`lab_config.loadingMessages: true`** — enables rotating tips during tab/sandbox load ([loading experience](https://docs.instruqt.com/tracks/manage/loading-experience)).
- **`enhanced_loading`** (track level) — `false` = **Notes only**: challenge **notes** as slides while the lab loads ([loading experience](https://docs.instruqt.com/tracks/manage/loading-experience)), matching **elastic-autonomous-observability**. `true` = **Full access** (assignment + tabs early; generic per-tab “coffee” wait messages).
- **Extra `notes:` slides** on each challenge — carousel content while waiting (especially challenge 1).

## Prerequisites

- [Instruqt CLI](https://docs.instruqt.com/getting-started/installation) installed and authenticated:

  ```bash
  instruqt auth login
  ```

- Permission to push to the **owner** team configured in `track.yml` (`owner: elastic` today). If you fork for your own org, change `owner` / `developers` in `track.yml` before pushing.

## Validate

```bash
cd instruqt
instruqt track validate

cd review-bomb-workshop-serverless
instruqt track validate
```

## Push to Instruqt

**Recommended (Git + both tracks):** from the **repository root**, after committing:

```bash
make publish
```

This runs `instruqt track validate` for both tracks, **`git push origin main`**, then **`instruqt track push --force`** for `review-bomb-workshop` and `review-bomb-workshop-serverless`, and re-syncs serverless `track.yml` from `track-serverless.yml` (see below).

---

From the track root you want to publish manually:

```bash
cd instruqt
instruqt track push --force

# Serverless variant (separate track on the platform)
cd review-bomb-workshop-serverless
instruqt track push --force
```

First-time **Serverless** track: if the platform has no track with slug `review-bomb-workshop-serverless`, create it in the Instruqt UI (or `instruqt track create`) for your team, then `pull` into this folder or align `track.yml` `id` with the remote, and push again.

Use `--force` only if you intend to overwrite remote edits:

```bash
instruqt track push --force
```

## Serverless track layout

`review-bomb-workshop-serverless/` contains:

- `track.yml` — copy of `../track-serverless.yml` (re-copy after editing the source file).
- `config.yml` — **`es3-api`** + `elastic/es3-api-v2` + secret `ESS_CLOUD_API_KEY` (matches Autonomous Observability).
- `track_scripts/setup-es3-api` — creates Serverless **Elasticsearch** project, nginx **:8080** / **:9200**, runs `../startup-serverless.sh`.
- `track_scripts/cleanup-es3-api` — deletes the project.
- `challenges`, `lib`, `startup-serverless.sh` — symlinks into parent `instruqt/`.

After changing shared challenge scripts, validate/push from **both** track directories if you maintain both labs.

### Serverless: `instruqt track push` side effects

The CLI may **rewrite** `review-bomb-workshop-serverless/track.yml` to a short summary and create **`01-*`…`04-*` directories** next to the `challenges/` symlink. That duplicates challenges and breaks `instruqt track validate` until removed.

**After each push** (or add to your workflow):

1. Delete the stray dirs: `rm -rf review-bomb-workshop-serverless/01-*` (four folders).
2. Restore the full definition: `cp track-serverless.yml review-bomb-workshop-serverless/track.yml` and set **`checksum`** from the short `track.yml` the CLI left behind (or run `validate` / next `push` output).

They are also listed in **`.gitignore`** so they are not committed by mistake.

**Remote track id:** `track-serverless.yml` uses Instruqt’s internal **`id: 6cqqeywqqnqc`** (not the slug). Using `id: review-bomb-workshop-serverless` causes **`Entity already exists`** on push.

## References

- [docs/instruqt-serverless.md](../docs/instruqt-serverless.md) — Serverless connection, env vars, and bootstrap.
- [Instruqt configuration files](https://docs.instruqt.com/reference/cli/configuration-files)
