# ChatGPT Pro Planning Skill for Codex

[简体中文](README.zh-CN.md)

Use the ChatGPT website's highest available Pro capability as a second planning pass before Codex executes a complex task. The skill prepares a minimal evidence-backed brief, asks before transmitting it, waits for the complete Pro response, routes follow-up questions, and then critically reconciles the result with the original task.

## Why this skill exists

Complex tasks often fail before implementation begins: goals are underspecified, constraints are mixed with assumptions, and risks are discovered too late. This skill adds a deliberate external planning pass without surrendering control to another model.

Codex remains responsible for:

- selecting and sanitizing the context sent to ChatGPT;
- verifying that the account and capability are actually Pro;
- waiting for the complete answer, even during long reasoning runs;
- deciding whether ChatGPT follow-up questions need human input;
- rejecting unverified claims and recommendations that conflict with local evidence;
- producing the final integrated plan.

## Install

### Codex built-in installer

Paste this into Codex:

```text
$skill-installer install the skill from https://github.com/Ericwong5021/chatgpt-pro-planning-skill/tree/main/skill
```

### One-command installer

Review [`install.sh`](install.sh), then run:

```bash
curl -fsSL https://raw.githubusercontent.com/Ericwong5021/chatgpt-pro-planning-skill/main/install.sh | bash
```

The installer writes to `${CODEX_HOME:-$HOME/.codex}/skills/chatgpt-pro-planning` and fails if that directory already exists. It never silently overwrites an installed skill.

The skill becomes available on the next Codex turn.

## Requirements

- Codex with global skills support.
- The ChatGPT browser extension connected through **Settings → Computer use**.
- A signed-in ChatGPT account with Pro capability available.
- The bundled `chrome:control-chrome` browser skill.

No OpenAI API key is required. The skill operates the logged-in ChatGPT website through the browser extension.

## Usage

```text
$chatgpt-pro-planning Analyze this migration before implementation. Compare the viable architectures, identify missing evidence, and produce a staged plan with acceptance criteria.
```

Chinese works equally well:

```text
$chatgpt-pro-planning 请先用网页版 ChatGPT Pro 分析这个任务，再给出分阶段实施计划和验收证据。
```

## Workflow

1. Inspect the task and collect current evidence.
2. Build a compact planning brief with goals, facts, constraints, unknowns, and exclusions.
3. Verify the visible ChatGPT account is Pro.
4. Select the highest available capability and record the actual model and reasoning labels.
5. Show the sanitized brief and ask for confirmation before sending it to `chatgpt.com`.
6. Submit the brief in a fresh conversation.
7. Wait until thinking and generation have fully ended.
8. Route any follow-up question through the human-involvement gate.
9. Read the complete response, including content outside the current viewport.
10. Reconcile the response against local evidence and deliver the integrated plan.

## Completion contract

A skill call is complete only when all of these are true:

- ChatGPT no longer shows thinking, generating, or stop-response state.
- The final response is stable and the page has returned to an idle input state.
- The response is not truncated, interrupted, waiting for a required answer, or showing an error/retry state.
- The requested analysis and planning sections are materially answered.
- Codex has read the complete response and reviewed its facts, assumptions, constraints, and feasibility.

Pro reasoning can take ten minutes or longer. A quiet page is not a timeout signal. The skill does not refresh, resubmit, or downgrade the model while generation is still healthy.

## Follow-up question gate

| ChatGPT behavior | Human input | Skill behavior |
| --- | --- | --- |
| Optional invitation after a complete answer | Not needed | Finish without replying |
| Blocking question already answered by verified context | No new content needed | Prepare a concise reply and ask for send confirmation |
| Non-critical missing detail that can be an explicit assumption | Usually not needed | Ask ChatGPT to proceed with labeled assumptions after send confirmation |
| Preference, value tradeoff, current financial/health/relationship fact, sensitive data, or scope-changing choice | Required | Pause, preserve the tab, and ask one focused question |

If ChatGPT repeats the same blocking question or cannot safely proceed, the call remains incomplete. The skill reports the blocker instead of fabricating an answer.

## Privacy and safety

- Nothing is typed into ChatGPT until the user sees and confirms the exact sanitized brief.
- Passwords, tokens, cookies, hidden instructions, and unnecessary private files are excluded.
- Browser cookies, local storage, passwords, and profiles are never inspected.
- Every additional message to ChatGPT requires action-time send confirmation.
- ChatGPT Memory or personalization may still influence a fresh conversation. Any fact not present in the approved brief or independently verified context is treated as unverified.
- CAPTCHA, authentication failure, unavailable Pro capability, and model-selection ambiguity fail closed.

## Failure behavior

The skill never reports a partial answer as success. A failed generation can be retried once only when the page exposes a safe retry action for that response. If the retry also fails, the call is reported as incomplete with observable evidence.

## Repository layout

```text
.
├── README.md
├── README.zh-CN.md
├── install.sh
└── skill
    ├── SKILL.md
    └── agents
        └── openai.yaml
```

## Uninstall

Move the installed directory out of the global skills folder:

```bash
mv "${CODEX_HOME:-$HOME/.codex}/skills/chatgpt-pro-planning" "${CODEX_HOME:-$HOME/.codex}/skills/chatgpt-pro-planning.backup"
```

## License

[MIT](LICENSE)
