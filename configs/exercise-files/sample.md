# Neovim Quickstart Notes

A practical reference for the most useful Neovim motions and commands.
Keep it handy while you practice.

## Moving Around

Normal mode is the home base for navigation. Every session starts here.
Use `h`, `j`, `k`, `l` to move left, down, up, and right one character at a time.
Word motions are faster: `w` jumps forward one word, `b` jumps back.

## Editing Text

Press `i` to enter Insert mode before the cursor, or `a` to insert after it.
Use `o` to open a new line below, and `O` to open one above.
To delete a word under the cursor, type `daw` (delete around word).

## Common Actions

- Save a file: `:w`
- Quit without saving: `:q!`
- Save and quit: `:wq`
- Undo the last change: `u`
- Redo: `<C-r>`
- Search forward: `/pattern`

## A Short Code Example

```lua
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
```

This sets a Normal-mode mapping so `<leader>w` saves the current buffer.
You can place this in your `init.lua` or any file sourced by your config.

## Key Concepts Table

| Concept     | Key / Command | Notes                          |
|-------------|---------------|--------------------------------|
| Normal mode | `<Esc>`       | Return here from any mode      |
| Insert mode | `i` or `a`    | Type text                      |
| Visual mode | `v`           | Select characters              |
| Command     | `:`           | Run Ex commands                |
| Save        | `:w`          | Write buffer to disk           |
| Find file   | `<leader>ff`  | LazyVim: open file picker      |

## Next Steps

Once you are comfortable with basic motions, explore text objects (`ci"`, `da(`),
window splits (`:split`, `:vsplit`), and the built-in file explorer.
The best way to learn is to edit real files every day.
