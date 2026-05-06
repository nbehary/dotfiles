# Android Debugging with DAP in Neovim

## How it works

```
nvim-dap  <--DAP-->  kotlin-debug-adapter  <--JDWP-->  adb forward  <-->  Android app
```

- `kotlin-debug-adapter` (from mason) bridges the DAP protocol to JDWP.
- `adb forward tcp:5005 jdwp:<pid>` exposes the app's debugger on localhost.
- `am start -D` launches the app paused, waiting for the debugger to attach
  (so early breakpoints aren't missed).

## Prerequisites

- `adb` on your `$PATH`
- A device or emulator (`adb devices` lists at least one)
- A debug build (`buildTypes.debug { isDebuggable = true }` is the default)
- `kotlin-debug-adapter` installed by mason (auto-installed via
  mason-tool-installer in `init.lua`)

## Usage

From the project root (where `gradlew` lives):

1. Set breakpoints with `<leader>b`.
2. Press `<leader>da`. This runs `bin/android-debug-launch`, which:
   - reads `applicationId` from `build.gradle(.kts)`
   - runs `./gradlew installDebug`
   - resolves the launcher activity dynamically
   - launches the app with `am start -D` (paused, waiting for debugger)
   - forwards `tcp:5005` to the app's JDWP port
   - then nvim-dap attaches and execution resumes
3. `<F7>` toggles the dap-ui (variables, stack, watches).

## Keymaps

| Key          | Action                  |
| ------------ | ----------------------- |
| `<leader>da` | Full Android debug flow |
| `<F5>`       | Continue                |
| `<F1>`       | Step into               |
| `<F2>`       | Step over               |
| `<F3>`       | Step out                |
| `<leader>b`  | Toggle breakpoint       |
| `<leader>B`  | Conditional breakpoint  |
| `<F7>`       | Toggle DAP UI           |

## Manual workflow (without `<leader>da`)

If you want to attach to an already-running app:

```bash
PID=$(adb shell pidof com.example.yourapp)
adb forward tcp:5005 jdwp:$PID
```

Then in Neovim, `<F5>` and pick the attach config.

## Troubleshooting

**"Couldn't connect to localhost:5005 ECONNREFUSED"**
The JDWP forward isn't set up, or the app isn't running. Re-run `<leader>da`
or do the manual `adb forward` above.

**"android-debug-launch failed: Could not find applicationId"**
The script looks in `./build.gradle(.kts)` and `./app/build.gradle(.kts)`.
If your `applicationId` lives elsewhere, edit `bin/android-debug-launch`.

**Breakpoints not hit**
Confirm the build is debuggable and that you're running the debug variant
(`installDebug`, not `installRelease`).

**`kotlin-debug-adapter: command not found`**
Run `:Mason`, find `kotlin-debug-adapter`, and install it manually. Or check
`:MasonToolsInstall`.
