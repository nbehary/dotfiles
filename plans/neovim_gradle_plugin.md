# Plan: Neovim Gradle Build Config Analyzer and Variant Selector

This plan outlines the design and implementation of a Neovim integration to dynamically analyze the current Gradle project's build configuration, discover available build/run tasks (variants), and allow the user to interactively select which variant is mapped to the Gradle build and run keybinds.

## Proposed System Architecture

### 1. Build Config Parser & Variant Discovery (`lua/android/variant_discovery.lua`)
- **Parsing/Discovery Strategies**:
  - **Static Parsing**: Scan `app/build.gradle.kts` and `app/build.gradle` to extract `buildTypes` (e.g., `debug`, `release`, `firebaseCt`) and `productFlavors` (e.g., `dev`, `prod`).
  - **Dynamic Task Discovery**: Run `gradlew tasks --all` or query Gradle model to extract all tasks matching `assemble*Debug` or `install*Debug`.
  - **Combining Product Flavors & Build Types**: Synthesize valid variants (e.g., `firebaseCtDebug`, `debug`) from the discovered configurations.

### 2. Project Configuration Updates (`lua/android/project_config.lua`)
- Extend the existing `.nvim/project.json` schema to persist:
  - `selected_variant`: The flavor + build type string (e.g., `firebaseCtDebug`).
  - `build_task`: The exact Gradle task to run on `<leader>gb` (e.g., `assembleFirebaseCtDebug`).
  - `install_task`: The exact Gradle task to run on `<leader>gr` / `<F9>` (e.g., `installFirebaseCtDebug`).

### 3. User Interface for Selection
- Create a `:GradleSelectVariant` (or `:AndroidSelectVariant`) command.
- Use `vim.ui.select` to present a clean, searchable picker with all discovered variants.
- Upon selection:
  1. Save choices to `.nvim/project.json`.
  2. Dynamically update keybind states without needing a Neovim restart.
  3. Notify the user with a sleek `vim.notify` banner showing the active configuration.

### 4. Dynamic Keybind Integration (`after/ftplugin/kotlin.lua`)
- Refactor existing keybinds (`<leader>gb`, `<leader>gr`, `<F9>`, `<C-F9>`) to use the dynamically configured variant and tasks:
  - **Build (`<leader>gb`)**: Run `gradlew <build_task>`.
  - **Run (`<leader>gr` / `<F9>`)**: Run `gradlew <install_task> && android run --apks <apk>`.
  - **Debug (`<C-F9>`)**: Run `gradlew <build_task> && android run --debug --apks <apk>` and attach JDWP debugger via DAP.

---

## Proposed Changes

### [Component Name: Neovim Gradle Integration]

#### [NEW] [variant_discovery.lua](file:///home/nate/working_dotfiles/.config/nvim/lua/android/variant_discovery.lua)
- Implement static parsing and/or task extraction from Gradle.
- Expose `discover_variants(root_dir)` and `select_variant(callback)`.

#### [MODIFY] [project_config.lua](file:///home/nate/working_dotfiles/.config/nvim/lua/android/project_config.lua)
- Add `get_selected_variant()`, `set_selected_variant()`, `get_build_task()`, and `set_build_task()`.

#### [MODIFY] [kotlin.lua](file:///home/nate/working_dotfiles/.config/nvim/after/ftplugin/kotlin.lua)
- Integrate `:GradleSelectVariant` command and dynamic resolution of tasks in `<leader>gb`, `<leader>gr`, `<F9>`, and `<C-F9>`.

---

## Verification Plan

### Manual Verification
1. Open a Kotlin/Gradle project in Neovim.
2. Run `:GradleSelectVariant` and verify the picker displays the correct discovered Gradle build variants.
3. Choose a variant (e.g., `firebaseCtDebug`).
4. Trigger `<leader>gb` and verify that the correct Gradle command (e.g., `./gradlew assembleFirebaseCtDebug`) is executed.
5. Trigger `<leader>gr` and verify that the correct install command is executed.
6. Verify that `.nvim/project.json` is updated correctly.
