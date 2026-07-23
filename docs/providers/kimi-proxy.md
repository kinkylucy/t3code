# Claude → Kimi K3 via CLIProxyAPI

This guide wires T3 Code's Claude provider through [CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI) so you can use **Kimi K3** (or other Kimi models) inside T3 Code.

## What you need

1. A running **CLIProxyAPI** server pointed at Kimi.
2. A **Kimi API key** from the [Kimi Open Platform](https://platform.kimi.ai/).
3. `claude` installed on your machine.

## 1. Start CLIProxyAPI

Use a config like this (`config.yaml`):

```yaml
host: "127.0.0.1"
port: 8317

api-keys:
  - "cliproxy-local-key"

claude-api-key:
  - api-key: "sk-kimi-..."          # your Kimi API key
    base-url: "https://api.kimi.com/coding"
    models:
      - name: "kimi-k3"
        alias: "kimi-k3"
        display-name: "Kimi K3"
        force-mapping: true
```

Run it:

```bash
./cli-proxy-api -config config.yaml
```

Verify the model list includes `kimi-k3`:

```bash
curl -s http://127.0.0.1:8317/v1/models \
  -H "Authorization: Bearer cliproxy-local-key"
```

## 2. Start T3 Code

### Option A: Double-click the launcher (macOS)

If you built this repo from source, a helper app bundle is installed at:

```text
~/Applications/T3 Code Proxy.app
```

Double-click it to start the T3 Code server and open your browser. On first launch, right-click the app and choose **Open** if macOS warns about an unidentified developer.

### Option B: Run from source

```bash
node apps/server/dist/bin.mjs serve --port 13773 --base-dir ~/.t3-proxy-test
```

Then open the printed **Pairing URL** in your browser.

## 3. Create a dedicated Claude home

Use the helper script in this repo to keep the proxy setup isolated from your normal Claude account:

```bash
./scripts/setup-kimi-claude-home.sh
```

This writes `~/.claude_kimi_proxy/settings.json` with the proxy URL and API key.

You can override defaults with environment variables:

```bash
CLIPROXY_API_KEY="my-secret-key" \
CLIPROXY_PORT=8317 \
CLAUDE_MODEL=kimi-k3 \
  ./scripts/setup-kimi-claude-home.sh
```

## 4. Add the provider in T3 Code

Open T3 Code Settings → Providers → Add Claude provider:

| Field | Value |
|-------|-------|
| Display name | `Claude → Kimi K3` |
| Binary path | `claude` |
| Claude HOME path | `~/.claude_kimi_proxy` |

In the provider's **Environment variables** section add:

```text
ANTHROPIC_API_KEY   cliproxy-local-key
ANTHROPIC_BASE_URL  http://127.0.0.1:8317
```

Mark `ANTHROPIC_API_KEY` as sensitive.

## 5. Pick the model

When creating a thread, choose the `Claude → Kimi K3` provider and select `kimi-k3` from the model picker.

## Switching back to real Claude

Use a separate Claude provider with an empty/default `Claude HOME path` and no custom env vars. T3 Code keeps each Claude home isolated, so your real Claude account won't be affected.

## Troubleshooting

- **`Model 'kimi-k3' not found`** — make sure CLIProxyAPI's `/v1/models` endpoint returns `kimi-k3`.
- **`/v1/v1/messages` 404** — `ANTHROPIC_BASE_URL` should be `http://127.0.0.1:8317`, **not** `http://127.0.0.1:8317/v1`. Claude Code appends `/v1` itself.
- **Claude still tries to use claude.ai** — run `/logout` inside a Claude session for the proxy home, or delete `~/.claude_kimi_proxy` and recreate it.
