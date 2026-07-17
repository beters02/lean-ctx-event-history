<div align="center">

# LeanHistory

### See where your lean-ctx tokens went.

[![Luau](https://img.shields.io/badge/Luau-typed-00A2FF?logo=lua&logoColor=white)](https://luau.org/)
[![Lute](https://img.shields.io/badge/runtime-Lute%201.0-7C3AED)](https://github.com/luau-lang/lute)
[![lean--ctx](https://img.shields.io/badge/data-lean--ctx-10B981)](https://github.com/yvgude/lean-ctx)

**LeanHistory** is a small, terminal-native viewer for your local lean-ctx event
history. It turns the raw JSONL log into readable reports so you can see which
tools ran, how many tokens they received, how many they saved, and where the
largest context costs came from.

</div>

---

## Why LeanHistory?

lean-ctx records useful telemetry for every tool call, but a growing JSONL file
is not especially pleasant to inspect by hand. LeanHistory gives that history a
focused command-line interface:

- Browse the newest tool calls in chronological order.
- Filter by a lean-ctx tool name or a short alias.
- Rank calls by their remaining token cost.
- Compare original tokens, saved tokens, and savings percentages at a glance.
- See useful context such as read modes and file paths.
- Work directly from the local event log—no database or service required.

## Quick start

### Requirements

- [Lute](https://github.com/luau-lang/lute), the Luau runtime. The repository's
  editor aliases currently target the Lute `1.0.0` type definitions.
- A lean-ctx event history at the path configured in [`config.luau`](config.luau).

Clone the project and run it directly:

```sh
git clone https://github.com/beters02/leanhistory.git
cd leanhistory
lute run main.luau help
```

For editor type definitions, run:

```sh
lute setup --with-luaurc
```

You can also compile a standalone executable:

```sh
lute compile main.luau --output leanhistory
./leanhistory help
```

## Commands

| Command | Description |
| --- | --- |
| `help` | Show every available command and argument. |
| `calls [tool] [amount]` | Show recent calls, optionally filtered by tool. Defaults to all tools and 50 rows. |
| `hitters [amount]` | Show the calls with the largest net token cost. Defaults to 50 rows. |

### Recent calls

```sh
# The latest 20 calls across every tool
lute run main.luau calls all 20

# The latest 10 reads
lute run main.luau calls read 10

# The latest compose calls
lute run main.luau calls compose 25
```

Reports are rendered as compact tables:

```text
Recent ctx_read Calls
====================================================================================================
TIMESTAMP            TOOL                    ORIGINAL       SAVED   SAVINGS  DETAILS
----------------------------------------------------------------------------------------------------
2026-07-17 09:14:22  ctx_read                   12,480      10,615     85.1%  task | src/parser.luau
2026-07-17 09:16:03  ctx_read                    8,920       7,684     86.1%  signatures | src/types.luau
----------------------------------------------------------------------------------------------------
Showing 2 call(s) | Original: 21,400 | Saved: 18,299 | Savings: 85.5%
```

### Heavy hitters

Use `hitters` to find the calls that consumed the most tokens after savings:

```sh
lute run main.luau hitters 15
```

This is useful when you want to spot oversized reads, searches, or commands that
could be narrowed down.

## Tool filters

Filters are case-insensitive. Both canonical lean-ctx names and convenient
aliases are accepted.

| Tool | Aliases |
| --- | --- |
| `all` | `*` |
| `ctx_read` | `read` |
| `ctx_search` | `search` |
| `ctx_compose` | `compose` |
| `ctx_shell` | `shell` |
| `ctx_tree` | `tree` |
| `ctx_knowledge` | `knowledge`, `recall` |
| `ctx_session` | `session` |
| `ctx_call` | `call` |
| `ctx_discover_tools` | `discover`, `discover_tools` |

## Configuration

LeanHistory reads the event file specified by `LeanCtxHistoryLocation` in
[`config.luau`](config.luau). The current default is:

```luau
LeanCtxHistoryLocation = "/root/.local/state/lean-ctx/events.jsonl"
```

If lean-ctx stores its history elsewhere on your machine, update that value
before running the CLI.

## How it works

```text
lean-ctx events.jsonl
        ↓
balanced JSONL parsing
        ↓
validated ToolCall records
        ↓
filtered and ranked terminal reports
```

The parser safely tracks nested objects, arrays, quoted strings, and escapes. It
ignores non-`ToolCall` events, then converts valid records into a small typed
model used by the reporting commands.

## Project layout

| Path | Purpose |
| --- | --- |
| [`main.luau`](main.luau) | CLI entry point and command dispatch. |
| [`cli/`](cli/) | Commands, history loading, and table rendering. |
| [`parser.luau`](parser.luau) | JSONL framing, decoding, and event validation. |
| [`tool.luau`](tool.luau) | Supported lean-ctx tools and aliases. |
| [`tool_call.luau`](tool_call.luau) | Typed tool-call model and savings calculations. |
| [`config.luau`](config.luau) | Location of the lean-ctx history file. |

## Contributing

Issues and pull requests are welcome. Keep changes small, typed, and focused on
making lean-ctx history easier to understand from the terminal.

<div align="center">

Made for curious agents and the humans watching their context budgets.

</div>
