# opencode.nvim - OpenCode AI Assistant Integration for Neovim

Author: opencode.nvim community  
License: MIT  
Version: 1.0.0

---

## Introduction

opencode.nvim integrates the OpenCode AI assistant with Neovim, enabling editor-aware research, reviews, and code requests directly from your editor.

**Features:**

- Connect to any OpenCode instance or use the integrated one
- Share editor context (buffer, selection, diagnostics)
- Input prompts with completions and highlights
- Execute commands and monitor events in real-time
- Vim-like keybindings for message navigation

---

## Installation

Using lazy.nvim:

```lua
return {
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
  config = function()
    vim.g.opencode_opts = {}
    vim.o.autoread = true
  end,
}
```

**Requirements:**

- Neovim 0.10+
- OpenCode CLI installed: `npm install -g opencode-ai` or `brew install opencode`

---

## Configuration

Add to your config:

```lua
vim.g.opencode_opts = {
  -- Your configuration options
}

-- Required for events reload
vim.o.autoread = true
```

**Server Configuration:**

```lua
vim.g.opencode_opts = {
  server = {
    start = function() ... end,
    stop = function() ... end,
    toggle = function() ... end,
  },
}
```

---

## Keymaps

This section explains each keymap in detail with practical use cases.

### Recommended Keymaps Setup

```lua
local opencode = require("opencode")

-- Toggle opencode panel (open/close)
vim.keymap.set({ "n", "t" }, "<leader>ot", function()
  opencode.toggle()
end, { desc = "Toggle opencode panel" })

-- Ask at cursor position
vim.keymap.set({ "n", "t" }, "<leader>oa", function()
  opencode.ask("@cursor: ")
end, { desc = "Ask opencode about code at cursor" })

-- Ask about selected text (visual mode)
vim.keymap.set("v", "<leader>oa", function()
  opencode.ask("@selection: ")
end, { desc = "Ask opencode about selected text" })

-- Operator mode (add selection to opencode)
vim.keymap.set({ "n", "x" }, "go", function()
  return opencode.operator("@this ")
end, { desc = "Add motion range to opencode", expr = true })
```

#### Keymap Details

`<leader>ot` - Toggle OpenCode Panel

| Attribute | Value |
|-----------|-------|
| Modes | Normal, Terminal |
| Description | Opens or closes the OpenCode side panel |

**When to use:**

- When you want to open the OpenCode chat interface
- When you want to close the panel after finishing your session
- This is the main entry point to interact with OpenCode

**How it works:**

1. Press `<leader>ot` to open the panel (split window with OpenCode terminal)
2. The panel opens as a horizontal or vertical split
3. Type your prompts directly in the OpenCode interface
4. Press `<leader>ot` again to close the panel

---

`<leader>oa` (Normal Mode) - Ask at Cursor

| Attribute | Value |
|-----------|-------|
| Modes | Normal, Terminal |
| Description | Opens a prompt with context from code at cursor position |

**When to use:**

- You want to ask about the function you're currently reading
- You need an explanation of a specific code block
- You want to refactor or improve code under your cursor
- You want to write tests for the function at cursor

**How it works:**

1. Place your cursor on a function, variable, or code block
2. Press `<leader>oa`
3. A prompt opens with `@cursor:` pre-filled
4. Type your question (e.g., "explain this", "write tests", "refactor")
5. Press `Enter` to submit

**Example workflow:**

```
1. Navigate to a complex function
2. Press <leader>oa
3. Type "explain this function"
4. Press Enter
5. Read the explanation in the OpenCode panel
```

---

`<leader>oa` (Visual Mode) - Ask about Selection

| Attribute | Value |
|-----------|-------|
| Modes | Visual (v, V, Ctrl+v) |
| Description | Opens a prompt with your selected text as context |

**When to use:**

- You have specific code selected and want OpenCode to work with it
- You want to refactor only a portion of a file
- You need help with a specific algorithm or logic
- You want to translate code to another language

**How it works:**

1. Visually select text (`v` for character, `V` for line, `Ctrl+v` for block)
2. Press `<leader>oa`
3. A prompt opens with `@selection:` followed by your selected code
4. Type your request (e.g., "refactor this", "add comments", "optimize")
5. Press `Enter` to submit

**Example workflow:**

```
1. Select a block of code with visual mode (v or V)
2. Press <leader>oa
3. Type "refactor this to be more readable"
4. Press Enter
5. OpenCode shows the refactored version
```

---

#### `go` - Operator Mode (Add Motion to OpenCode)

| Attribute | Value |
|-----------|-------|
| Modes | Normal, Visual |
| Description | Uses a Vim motion to specify a range for OpenCode |
| Expression | Returns a string for use in operator-pending mode |

**When to use:**

- You want to quickly send a function or class to OpenCode
- You need to select a specific region using Vim motions
- You prefer using text objects (e.g., `goaf` for a function)

**How it works:**

1. Type `go` followed by a motion or text object
2. The motion's range is sent to OpenCode with `@this:` context
3. The prompt appears for you to add your request

**Example motions:**

| Command | Range |
|---------|-------|
| `goiw` | Inner word |
| `goaw` | A word |
| `gi5j` | 5 lines down |
| `goaf` | A function (requires treesitter) |
| `goa(` | A paragraph |
| `go$` | To end of line |

**Example workflow:**

```
1. Press goaf (go + a function text object)
2. Type "write unit tests for this function"
3. Press Enter
4. OpenCode generates tests for the function
```

---

### Terminal Mode Keymaps (Inside OpenCode Panel)

These keymaps work when the OpenCode terminal is active and you're in the OpenCode interface:

| Keymap | Action | Description |
|--------|--------|-------------|
| `Ctrl+b` | Page Up | Scroll up half a page |
| `Ctrl+f` | Page Down | Scroll down half a page |
| `gg` | First | Jump to first message |
| `G` | Last | Jump to last message |
| `Esc` | Interrupt | Stop the current OpenCode response |
| `Ctrl+c` | Cancel | Cancel current input |

**When to use:**

- Navigate through long conversations
- Interrupt a response that's taking too long
- Jump to the start or end of the conversation history

---

### Alternative Keymap Configurations

You can customize the keymaps to your preference:

```lua
-- Alternative: Using Ctrl shortcuts
vim.keymap.set({ "n", "x" }, "<C-a>", function()
  require("opencode").ask("@this: ", { submit = true })
end, { desc = "Ask opencode (submit)" })

vim.keymap.set({ "n", "x" }, "<C-x>", function()
  require("opencode").select()
end, { desc = "Open command palette" })

vim.keymap.set({ "n", "t" }, "<C-.>", function()
  require("opencode").toggle()
end, { desc = "Toggle opencode" })
```

---

## Usage

### `opencode.ask({prompt}, {opts})`

Input a prompt for OpenCode.

**Parameters:**

- `prompt` (string): Initial prompt text (e.g., "@cursor: ", "@selection: ")
- `opts` (table, optional): Configuration table
  - `submit` (boolean): Submit immediately
  - `append` (boolean): Append instead of submit (end with `\n`)

**Examples:**

```lua
-- Ask about code at cursor
:lua require("opencode").ask("@cursor: explain this code")

-- Ask about selected text
:lua require("opencode").ask("@selection: refactor this")

-- Submit immediately
:lua require("opencode").ask("@this: ", { submit = true })
```

### `opencode.toggle()`

Toggle opencode panel open/closed.

### `opencode.select()`

Open command palette with all available commands and prompts.

**Available Commands:**

| Command | Description |
|---------|-------------|
| `session.list` | List all sessions |
| `session.new` | Start a new session |
| `session.select` | Select an existing session |
| `session.share` | Share current session |
| `session.interrupt` | Interrupt current session |

---

## Contexts

Available context tokens:

| Token | Description |
|-------|-------------|
| `@this` | Current file / selection |
| `@cursor` | Code around cursor |
| `@file` | Current file |
| `@git` | Git diff of current file |
| `@repo` | Entire repository |
| `@problem` | Current LSP diagnostics |

---

## OpenCode CLI Settings

Create `~/.opencode.json` for OpenCode CLI settings:

```json
{
  "keybinds": {
    "leader": "ctrl+x",
    "app_exit": "ctrl+c,esc",
    "session_interrupt": "esc",
    "input_submit": "enter",
    "input_newline": "shift+enter,ctrl+j"
  },
  "model": {
    "default": "claude-3.5-sonnet"
  }
}
```

---

## Troubleshooting

### 1. OpenCode not starting

- Ensure OpenCode CLI is installed: `opencode --version`
- Start with port flag: `opencode --port 8080`

### 2. Keypress issues in editor mode

- This is a known issue with OpenCode CLI v1.0+
- Workaround: Set VISUAL or EDITOR to open in separate terminal

### 3. Plugin not loading

- Check: `:checkhealth opencode`
- Ensure dependencies (snacks.nvim) are installed

### 4. Focus issues (return to Neovim buffer)

- **Exit terminal mode**: `Ctrl+\` `Ctrl-n`
- **Navigate windows**: `Ctrl+w` `h/j/k/l`
- **Toggle off**: Press `<leader>ot` again

---

## Commands

| Command | Description |
|---------|-------------|
| `:OpenCode` | Open OpenCode panel |
| `:OpenCodeChat` | Start new chat session |

---

## Focus Navigation

After using opencode and asking questions, to return focus to your Neovim buffer:

1. **Exit terminal mode**: Press `Ctrl+\` then `Ctrl+n`
2. **Navigate to buffer**: Use `Ctrl+w h/j/k/l` to switch windows
3. **Toggle off**: Press your `<leader>ot` keymap again

This is standard Neovim terminal buffer behavior - opencode runs in an embedded terminal within Neovim.
