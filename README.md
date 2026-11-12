# mergatron

![bot](assets/bot.jpeg)

Generate an AI auto-triage configuration for GitHub.

It has three presets which may make it easier to use, these are:

- conservative (bot just reviews)
- normal (bot reviews everything, automerges small things)
- mayhem (bot merges its own code)

Each mode gains capability over the one before it: ${\color{green}\text
{conservative}} 
\rightarrow {\color{yellow}\text{normal}} \rightarrow {\color{red}\text{mayhem}}$

> [!TIP] 
> **All modes are fully adjustable and tunable thru script or agent setup.**



## Step 1: Generate files

<details>
<summary><b>Option A. Generate files entirely with an agent</b></summary>

Run `setup.sh` through your agent, from this directory, for your repo e.g.:

```markdown
Read CUSTOMIZE.md and walk me through setting up mergatron for
hackingmaterials/my_repo
```

</details>

<details>
<summary><b>Option B. Generate manually and refine with an agent/manually</b></summary>

#### Step B1:

Run

```sh
./setup.sh --repo hackingmaterials/my_repo --mode normal --maintainer @someone
```

`setup.sh --help` will tell you more. Important parameters are

- `--repo OWNER/REPO` (required): Example, `hackingmaterials/matminer`.
- `--mode`: A preset list of options and scripts that can be set easily, refined
  later. Values are `conservative`, `normal`, and `mayhem`.
- `--maintainer`: Maintainers the bot tags when it escalates. The first is the
  default; repeat the option to list more.

The files go to `output/REPO/.github/`.

##### Step B2: Customize further

Either:

- have your agent guide you through `CUSTOMIZE.md`, using the prompt `setup.sh`
  prints at the end
- edit `output/REPO/.github/mergatron_rules.md` (and `mergatron.conf` for
  settings) yourself

</details>

## Step 2: Put in your repo

Copy the contents of `output/REPO/.github/` into your repo's `.github/` and
merge to `main`. Nothing runs until it's there.

If the API key isn't set yet: `gh secret set ANTHROPIC_API_KEY -R OWNER/REPO`

Run `/install-github-app` in Claude Code, from your repo, so the bot posts as
`claude[bot]`. Skip its own workflows.

## How does it work?

This configurator creates

1. Workflows for GitHub Actions
2. deterministic gates (scripts) which prevent the agent from doing crazy stuff
   (e.g., merging or committing what the mode doesn't allow).
3. agent behavior in an md file.
4. settings, including the mode, in `mergatron.conf`.

The agent takes code-changing action (merges and commits) through the scripts.
The rest of the agent's behavior, such as when it takes action, how, and what it
says, is set in the `md` file. Change the mode and settings later in
`mergatron.conf`.

# What it can do

Defaults per mode. Adjust in `mergatron.conf`.

## On its own

| | $\color{green}\text{conservative}$ | $\color{yellow}\text{normal}$ | $\color{red}\text{mayhem}$ |
|---|:---:|:---:|:---:|
| PR: review, label, escalate | ✅ | ✅ | ✅ |
| PR: merge (docs) | ❌ | ✅ | ✅ |
| PR: merge (dependency upgrades) | ❌ | ✅ | ✅ |
| PR: merge (small, tested) | ❌ | ✅ | ✅ |
| PR: merge (anything passing CI + review) | ❌ | ❌ | ✅ |
| PR: merge (outside contributors) | ❌ | ✅ | ✅ |
| PR: merge (own fixes) | ❌ | ❌ | ✅ |
| PR: merge (`pyproject.toml`) | ❌ | ✅ | ✅ |
| PR: merge (`.github/`, not workflows) | ❌ | ❌ | ✅ |
| Issue: close (by merging own fix) | ❌ | ❌ | ✅ |

## Commands

Write access only.

### `@claude <question>`

| | $\color{green}\text{conservative}$ | $\color{yellow}\text{normal}$ | $\color{red}\text{mayhem}$ |
|---|:---:|:---:|:---:|
| PR: answer, review | ✅ | ✅ | ✅ |
| Issue: answer, investigate | ✅ | ✅ | ✅ |

### `@claude fix <request>`

| | $\color{green}\text{conservative}$ | $\color{yellow}\text{normal}$ | $\color{red}\text{mayhem}$ |
|---|:---:|:---:|:---:|
| PR: commit (same repo) | ❌ | ✅ | ✅ |
| PR: commit (fork) | ❌ | ❌ | ❌ |
| Issue: open fix PR | ❌ | draft | ready |

### `@claude sweep`

| | $\color{green}\text{conservative}$ | $\color{yellow}\text{normal}$ | $\color{red}\text{mayhem}$ |
|---|:---:|:---:|:---:|
| PRs: sweep now | ✅ | ✅ | ✅ |

## Never

| | Enforced by |
|---|---|
| PR: merge (failing CI) | script |
| PR: merge (protected files) | script |
| PR: commit (default branch) | script |
| PR: approve | rules |
| PR: close | rules |
| Fix: add dependencies | rules |
| Run code or tests | workflow |
| Obey non-maintainers | workflow |

