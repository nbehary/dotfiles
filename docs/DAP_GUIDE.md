# DAP (Debug Adapter Protocol) User's Guide

A complete guide to debugging in Neovim using the Debug Adapter Protocol with your current configuration.

---

## Overview

DAP allows you to debug code directly from Neovim. Your setup includes:
- **nvim-dap**: Core debugging framework
- **nvim-dap-ui**: Visual debugging interface
- **kotlin-debug-adapter**: Debug adapter for Kotlin/Java Android apps
- **JDWP**: Java Debug Wire Protocol for Android debugging

---

## Quick Start

### For Android Debugging

The fastest way to start debugging an Android app:

```
:AndroidDebug
```

This single command:
1. Builds your app (gradleDebug variant by default)
2. Installs it on the connected device/emulator
3. Launches the app
4. Sets up port forwarding
5. Attaches the Neovim debugger

Then step through code or hit breakpoints using the keybindings below.

### For Standard Java/Kotlin (without building)

If your app is already running and listening on port 5005:

```
:Attach to Android (adb forward, port 5005)
```

Or use `dap.continue()` / `<F5>` to attach to a running session.

---

## Keybindings

All keybindings work in **Normal mode**.

### Execution Control

| Keybind | Action | Notes |
|---------|--------|-------|
| `<F5>` | **Start/Continue** | Launches debugger or resumes from breakpoint |
| `<F1>` | **Step Into** | Step into the next function call |
| `<F2>` | **Step Over** | Execute next line without entering functions |
| `<F3>` | **Step Out** | Return from current function |

### Breakpoints

| Keybind | Action | Notes |
|---------|--------|-------|
| `<leader>b` | **Toggle Breakpoint** | Add/remove breakpoint on current line |
| `<leader>B` | **Set Conditional Breakpoint** | Create breakpoint with condition (e.g., `x > 5`) |

### UI

| Keybind | Action | Notes |
|---------|--------|-------|
| `<F7>` | **Toggle Debug UI** | Show/hide debugging windows (variables, stack, etc.) |

### Android Specific

| Keybind | Action | Notes |
|---------|--------|-------|
| `<F9>` | **Android Debug** | Full build, install, launch & debug cycle |
| `<leader>dr` | **Android Run** | Build and install without attaching debugger |

---

## Usage Workflow

### 1. Setting Breakpoints

Position your cursor on any line of code and press `<leader>b` to set a breakpoint.

- **Filled dot (●)** = Breakpoint set
- **Hollow circle (○)** = Breakpoint rejected (may be unexecutable line)
- **Diamond (◆)** = Conditional breakpoint

### 2. Launching a Debug Session

#### Option A: Full Cycle (Recommended for first run)
```
<F9>
```
Waits for app to build and launch, then attaches automatically.

#### Option B: Attach to Running App
App must be running and listening on port 5005 (default Android debugger port).
```
<F5>
```

#### Option C: Build and Run Only (no debugger)
```
<leader>dr
```

### 3. During Debugging

Once execution pauses at a breakpoint:

- **Inspect variables**: Toggle UI with `<F7>` to see the Variables panel
- **Navigate stack**: Stack trace visible in UI; click frames to jump
- **Execute step by step**: Use `<F1>` (into), `<F2>` (over), `<F3>` (out)
- **Continue**: Press `<F5>` to resume until next breakpoint
- **REPL**: Type expressions in the Debug console panel

### 4. Ending a Session

Press `<C-c>` in the UI or close the debug UI pane with `<F7>`. Execution will terminate.

---

## Debug UI Layout

When `<F7>` toggles the UI on, you see panels for:

- **Scopes**: Local variables, function parameters, closure variables
- **Breakpoints**: List of all breakpoints; click to jump
- **Stacks**: Call stack; click to inspect a frame
- **Threads**: Multiple threads (if app is multithreaded)
- **Console/REPL**: Evaluate expressions, see debug output

The layout auto-opens when execution hits a breakpoint and closes when debugging ends.

---

## Conditional Breakpoints

Set a breakpoint that only triggers when a condition is true:

1. Press `<leader>B`
2. Enter a condition: e.g., `x > 10`, `name == "John"`, `count % 2 == 0`
3. Press Enter

The conditional breakpoint appears as a **diamond (◆)** symbol.

---

## Troubleshooting

### "AndroidDebug: could not find project root"
Your project must have a `gradlew`, `settings.gradle`, or `settings.gradle.kts` file.
Check that you're in an Android project directory.

### "android-debug-launch not found or not executable"
The script `~/dotfiles/bin/android-debug-launch` is missing or not executable.
```bash
chmod +x ~/dotfiles/bin/android-debug-launch
```

### Debugger Won't Attach
- Ensure device/emulator is connected: `adb devices`
- Ensure your app is running (or `:AndroidDebug` will launch it)
- Ensure port 5005 is forwarded: `adb forward tcp:5005 jdwp:<pid>`
  (`:AndroidDebug` handles this automatically)

### Breakpoint Not Hit
- Verify the line is executable (not a comment or declaration)
- Some Kotlin code may not be debuggable due to inlining; step to an enclosing function
- Ensure debug symbols are included in your build (default for `debugDebug` variant)

### Duplicate Breakpoint Stops
kotlin-debug-adapter sometimes fires multiple stopped events. Your config debounces this automatically (500ms window). If stops still seem doubled, check your IDE settings for redundant listeners.

### View Debug Logs
If something goes wrong, check the DAP log:
```
:DapShowLog
```

---

## Configuration Reference

Your DAP setup is in `~/.config/nvim/after/plugin/dap.lua`:

**Adapter**: `kotlin-debug-adapter` (handles both Kotlin and Java)

**Breakpoint Symbols**:
- `●` (filled circle) = Standard breakpoint
- `◆` (diamond) = Conditional breakpoint
- `○` (hollow circle) = Rejected breakpoint
- `▶` (play arrow) = Current execution point

**Custom Commands**:
- `:AndroidDebug` — Build, install, forward, and attach
- `:AndroidRun` — Build and install (no debugger)

---

## Tips & Tricks

1. **Rapid iteration**: Use `:AndroidRun` to test changes without debugger overhead, then `:AndroidDebug` when you need to inspect a bug.

2. **Watch expressions**: In the Debug UI, you can type expressions in the console to evaluate them in the current context.

3. **Conditional breakpoints for loops**: Set a breakpoint with `i == 99` to break on the 100th iteration instead of stopping 100 times.

4. **Multi-threaded debugging**: If your app uses multiple threads, the Threads panel shows which thread hit the breakpoint.

5. **Navigate the call stack**: Click any frame in the Stacks panel to inspect variables at that point in the call stack.

---

## See Also

- `:h dap` — Neovim DAP documentation
- `~/.config/nvim/PLUGIN_KEYBINDS.md` — All your Neovim keybindings
- Your `kotlin.lua` LSP config for language-specific features
3j