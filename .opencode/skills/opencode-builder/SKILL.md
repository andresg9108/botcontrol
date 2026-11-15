---
name: opencode-builder
description: Maintains OpenCode agents, skills, and commands; use ONLY when creating, editing, reviewing, or auditing those assets under .opencode.
---

# Build OpenCode Agents and Skills

Create and maintain OpenCode configuration assets only under `.opencode/` for the agbot Flutter BLE remote, using canonical project structure and English-only content. Keep final user summaries in Spanish unless requested otherwise.

## When to use

- The user asks to create, edit, review, or audit a project agent, skill, or command.
- The target is an agent Markdown file, a skill `SKILL.md`, a command file, or `.opencode/opencode.json`.
- Do not use this skill for application code or project documentation outside `.opencode/`.

## Workflow

1. Inventory the relevant files under `.opencode/agents/`, `.opencode/skills/`, and either `.opencode/command/` or `.opencode/commands/` before editing. For a full audit, include every file and auxiliary resource in the requested directories; use explicit search roots so hidden `.opencode/` paths are not skipped.
2. Read every target file and the project sources needed to verify its claims. Record the initial Git state when permitted. Use `todowrite` for multi-step tracking when available; otherwise keep a concise progress checklist in the conversation without claiming a tool call.
3. Write every agent and skill Markdown file entirely in English, including frontmatter.
4. Use only these allowed locations:

| Asset | Path |
| --- | --- |
| Agent | `.opencode/agents/<name>.md` |
| Skill | `.opencode/skills/<name>/SKILL.md` |
| Command | `.opencode/command/<name>.md` |
| Command (also supported; preferred by V2) | `.opencode/commands/<name>.md` |
| Skill resources | `.opencode/skills/<name>/references/`, `scripts/`, or other required supporting files |
| Project config | `.opencode/opencode.json` or `.opencode/opencode.jsonc` |

5. Never create or edit files outside `.opencode/`.
6. Load `customize-opencode`, then compare version-sensitive guidance with the [official schema](https://opencode.ai/config.json), [agents](https://opencode.ai/docs/agents/), [permissions](https://opencode.ai/docs/permissions/), [skills](https://opencode.ai/docs/skills/), and [migration guide](https://opencode.ai/docs/migrate-v1/). The built-in skill may describe V1 while online documentation describes V2. Existing project agents use the supported V1-compatible `permission` map with `bash`; retain this consistent format unless a migration is requested or the installed runtime is verified to require another format. Do not infer the CLI version from a tooling dependency. Keep dependencies unchanged unless an upgrade is requested.
7. Follow the canonical template structure below, adapting mode and permission allowlists to each agent's actual responsibilities; do not copy the builder's edit scope onto application agents. Do not put prompt text in frontmatter.
8. For portable skill IDs, keep names lowercase and hyphen-separated, no longer than 64 characters, and identical to their folder names. V1 requires this alignment; V2 derives the ID from the path and treats frontmatter `name` as a display label. Keep the shared convention rather than relying on V2-only relaxation.
9. Give every skill a concise, third-person `description` that states what it does and when to use it; gate specialized skills with `Use ONLY when...`.
10. Keep agent descriptions in one sentence that states what the agent does and when to use it.
11. Order permission patterns from broad defaults to exceptions because the last matching rule wins: deny by default, allow the role's paths/commands, then deny excluded subtrees where an allow overlaps them. Permission wildcards are whole-value matching, not shell/file-discovery globs: `*` matches `/`, so `lib/*.dart` covers direct and nested files, whereas `lib/**/*.dart` misses direct children. Check actual root and nested paths. Allow exact Git review forms, not `git diff*` (which also matches `git difftool` and write-capable arguments). Formatting command wildcards can admit extra arguments; prompts must still restrict formatting to explicit authorized changed files.
12. Verify cross-references use exact skill IDs and that every agent points to its intended skill. `customize-opencode` is supplied by the harness, not by a project skill directory; report its absence in a different installation rather than creating a duplicate. Keep primary-only roles primary unless delegated invocation is explicitly required; `all` enables both uses, while `subagent` enables delegated use only. Do not promise that an unavailable agent/tool can be invoked.
13. Re-read changed files and confirm that no file outside `.opencode/` was changed by this work. For diff review, follow `final-answers-and-considerations` when Git access is permitted. Inspect untracked files separately because a plain Git diff will not include them. Validate YAML frontmatter, skill IDs/folder names, referenced paths, permission ordering, and absence of obsolete project assumptions; report parsing separately from actual OpenCode startup validation.
14. Use the current skill map: `flutter-project` for architecture/widgets; `dart-flutter-standards` for Dart; `flutter-mobile-design` for mobile presentation; `flutter-ble-control` for BLE/input/lifecycle; `flutter-verification` for app checks; `project-readme-maintenance`, `responder-ia`, and `final-answers-and-considerations` for their existing roles. Load only task-relevant skills. Do not reintroduce web framework/module rules without evidence that the project now uses them.
15. Keep `node_modules/`, package locks, and generated/cache files out of configuration-authoring edits. Add agents or skills only for recurring responsibilities with clear triggers, avoiding one skill per widget. Do not hard-code a provider/model without a user requirement. Do not automatically delegate work unless requested by the user or applicable instructions.

### Canonical agent structure (existing V1-compatible project format)

```markdown
---
description: What the agent does and when to use it, in one third-person sentence.
mode: primary
permission:
  edit:
    "*": deny
    ".opencode/agents/*.md": allow
    ".opencode/skills/*": allow
    ".opencode/*node_modules/*": deny
    ".opencode/*package-lock.json": deny
    ".opencode/*bun.lock*": deny
  bash: deny
---

# <Agent Name>

You are <role> in the <project> codebase.

## Role

<What this agent does and its responsibilities.>

## When to use

<The situations in which this agent should be invoked.>

## Rules

- <Permission and scope rules.>
- <Required skills and project conventions.>
- <Safety, accuracy, and output requirements.>

## Workflow

1. <Preparation.>
2. <Implementation.>
3. <Verification.>

## Output

<Deliverable format and required verification results.>
```

- For the existing V1-compatible files, use `description`, `mode`, and `permission`; optional version-specific fields include `model`, `variant`, `hidden`, `color`, `steps`, `options`, `disable`, `temperature`, and `top_p`. Check the matching schema before adding fields; this is not the native V2 field list.
- Valid modes are `primary`, `subagent`, and `all`.
- The Markdown body is the agent prompt; keep prompt text out of frontmatter.
- Native V2 uses `permissions` as an ordered array of `{ action, resource, effect }`, with `shell` instead of `bash` and `subagent` instead of `task`. Agent fields include `disabled` and `request`; a model variant joins the model reference as `provider/model#variant`. Convert a whole agent definition together: V2 markers such as `permissions` cause legacy `permission` fields in the same file to be ignored. Do not mix the formats or migrate to V2-only syntax without confirming compatibility.

### Canonical skill structure

The existing `.opencode/skills/<id>/SKILL.md` layout is discovered in both versions. Keep a nonempty description so the skill is advertised. Supporting-resource paths are relative to the skill directory; explicitly label repository-root paths such as `lib/` and `test/` when authoring instructions. Include resources in discovery/reference review, and never execute them unless the active agent's permissions allow it.

```markdown
---
name: <folder-name>
description: What the skill does and when to use it, in one third-person sentence.
---

# <Skill Name>

<Short summary of the skill's purpose.>

## When to use

- <Trigger condition.>
- <Task type covered.>
- <Adjacent task that must not load the skill.>

## Workflow

1. <Preparation and prerequisites.>
2. <Procedure.>
3. <Verification.>

## Output

<Required result format, files, naming, and language rules.>
```

## Output

Report changed files under `.opencode/` and structural improvements using `final-answers-and-considerations`. Tell the user to quit and restart OpenCode because configuration is loaded at startup.
