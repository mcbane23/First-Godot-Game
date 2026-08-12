# Knights

A small 2D platformer built with Godot 4.4, targeting desktop and mobile.

## Requirements

- [Godot Engine 4.4](https://godotengine.org/download) or later (Mobile renderer)

## Running the project

1. Open Godot and choose **Import**, then select `project.godot` in this repository.
2. Press **F5** (or the Play button) to run the main scene.

## Controls

| Action | Keyboard         |
|--------|------------------|
| Move   | A / D or ← / →   |
| Jump   | Space or W       |
| Attack | Ctrl or Enter *(input action exists but isn't wired up to gameplay yet)* |

On mobile/touch platforms, on-screen controls (`scenes/mobile_controls.tscn`) provide the same actions.

## Project structure

- `scenes/` — game scenes (player, enemies, levels, pickups, hazards)
- `scripts/` — GDScript sources
- `resources/` — shared resources (tileset, etc.)
- `assets/` — art and sprite sheets
- `android/` — Android export template config (build output is git-ignored)

## Android debug signing

The **Build Android debug APK** workflow signs every APK with the same keystore
on every run. This is required for updates to work: Android refuses to install a
build over an existing app that was signed with a different key, so the signing
key has to stay identical across builds.

The workflow takes that key from one of two places, in order:

1. the `ANDROID_DEBUG_KEYSTORE_BASE64` repository secret, if it is set;
2. otherwise `debug.keystore`, committed at the root of this repository.

### Current setup: the committed keystore

**During development this repository carries `debug.keystore` in git**, so builds
work without any secret configured. It is a throwaway development key.

This repository is public, which means **the signing key is public too**. Anyone
who can read the repository can sign an APK that Android will accept as an update
to this app. That is a deliberate trade for the development phase, while builds
only go to the people working on the game.

**Move to the secret before handing builds to testers.** Committing a key also
puts it in git history permanently, so the switch means generating a *new* key,
not reusing this one — and once testers have installed a build, changing the
signing key forces them to uninstall before they can install again. Doing it
before the first tester build avoids that.

### Switching to a secret

**1. Create a fresh debug keystore** (keep the generated file somewhere safe, and
do not commit it). `keytool` ships with the JDK:

```bash
keytool -genkeypair -v -keystore debug.keystore \
  -storepass android -alias androiddebugkey -keypass android \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Android Debug,O=Android,C=US"
```

**2. Upload it as a secret.** A keystore is binary and a secret holds text, so it
is stored base64-encoded; the workflow decodes it again. Use the form that
matches your shell:

```bash
# bash / zsh
gh secret set ANDROID_DEBUG_KEYSTORE_BASE64 --body "$(base64 -w0 debug.keystore)"
```

```powershell
# PowerShell (Windows). Its redirection operators differ from bash, so pass the
# value with --body rather than piping a file into the command.
$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes("debug.keystore"))
gh secret set ANDROID_DEBUG_KEYSTORE_BASE64 --body $b64
```

Run this from inside a clone of this repository, or add
`--repo mcbane23/First-Godot-Game`, so the secret lands on the right repository.
Then confirm it is stored where Actions can read it:

```
gh secret list
```

`ANDROID_DEBUG_KEYSTORE_BASE64` must appear in that list. Adding it through the
web UI works too, but it has to be a **repository secret** under
*Settings → Secrets and variables → Actions → Secrets*. The neighbouring
**Variables** tab, the Dependabot and Codespaces tabs, and per-environment
secrets are all separate stores that this workflow cannot read — a secret saved
in one of those looks exactly like no secret at all.

**3. Remove the committed key**, so builds cannot silently fall back to it:

```bash
git rm debug.keystore
```

Once the secret is set the workflow prefers it automatically; no workflow edit is
needed either way.

| Secret | Required | Default |
|--------|----------|---------|
| `ANDROID_DEBUG_KEYSTORE_BASE64` | no, while `debug.keystore` is committed | — |
| `ANDROID_DEBUG_KEYSTORE_USER` | no | `androiddebugkey` |
| `ANDROID_DEBUG_KEYSTORE_PASSWORD` | no | `android` |

If you used non-default `-alias`/`-storepass` values when creating the keystore,
set the two optional secrets to match. The build logs which source it used, warns
on every run that falls back to the committed key, and fails with an explanatory
message if neither source is available — rather than silently producing an APK
that cannot be installed as an update.

Keep a backup of `debug.keystore`. If it is lost, future builds get a new
signature and everyone has to uninstall the app before installing again.

## Notes

Some bundled art in `assets/` comes from third-party packs; check each pack's included `READ ME.txt`/license file before reusing or redistributing it outside this project.
