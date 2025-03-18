# Dabble.nvim

A Neovim plugin for quickly creating and running code snippets in various languages. Perfect for experimenting with code without leaving your editor.

## Work in progress
This plugin is not finished

## Features

- Create scratch buffers with language-specific templates
- Execute code with language-appropriate commands via builtin jobstart

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'antsoh161/dabble.nvim',
  config = function()
    require('dabble').setup({
      -- Custom configuration (optional)
    })
  end
}
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'antsoh161/dabble.nvim',
  config = function()
    require('dabble').setup({
      -- Custom configuration (optional)
    })
  end
}
```

## Usage

### Create a new scratch buffer

```
:DabbleNew cpp
:DabbleNew python3
```

This creates a new buffer with a language-specific template. The buffer is named with pattern `dabble_{language}_{timestamp}`.

### Run the current buffer

```
:DabbleRun
```

Executes the current buffer's code and displays the output in a split window below. For compiled languages, it handles both compilation and execution.

## Configuration

Customize templates and runners with the setup function:

```lua
require('dabble').setup({
  -- Default templates for different languages
  templates = {
    -- Overwrite the cpp template
    cpp = [[
#include <iostream>
#include <vector>
#include <string>

int main() {
    std::cout << "Hello, Custom Dabble!" << std::endl;
    return 0;
}
]],
    -- Overwrite the python template
    python3 = [[
def main():
    print("Hello, Custom Dabble!")

if __name__ == "__main__":
    main()
]],
    -- Add your own custom templates
  },
  
  -- Command runners for different languages
  runners = {
    cpp = {
      compile = "g++ -std=c++17 -Wall %s -o %s.out",
      run = "%s.out"
    },
    python3 = {
      run = "python3 %s"
    },
    rust = {
      compile = "rustc %s -o %s.out",
      run = "%s.out"
    },
    -- Add your own custom runners
  }
})
```

### Templates

Templates are the starting code that appears in the new buffer. The key is the language identifier that you'll use with `:DabbleNew`.

### Runners

Runners define how to execute the code:

- For interpreted languages like Python, you only need the `run` command
- For compiled languages like C++ or Rust, you need both `compile` and `run` commands

The placeholder `%s` is used to represent:
- The file path in the `compile` command and for non-compiled languages
- The output path (without extension) in the `run` command for compiled languages

## License

MIT
