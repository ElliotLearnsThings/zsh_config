# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
export PATH="/Applications/MATLAB_R2024b.app/bin:$PATH"

#ZSH_THEME="powerlevel9k/powerlevel9k"

ZSH_DISABLE_COMPFIX=true

if type brew &>/dev/null; then
	FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

	autoload -Uz compinit
	compinit
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Function to toggle the secondary display rotation between 90 and 0 degrees on macOS
ttw() {
  # Get the current rotation of the secondary display
  local current_rotation=$(system_profiler SPDisplaysDataType | grep -A 10 "VG248" | grep "Rotation" | awk '{print $2}')
  
  # If no secondary display is found, inform the user and exit
  if [[ -z "$current_rotation" ]]; then
    echo "No secondary display detected."
    return 1
  fi
  
  # Toggle the rotation
  if [[ "$current_rotation" == "90" ]]; then
    # Set rotation to 0 degrees (normal)
    echo "Rotating secondary display to 0 degrees (normal)..."
    displayplacer "id:2 degree:0"
  else
    # Set rotation to 90 degrees
    echo "Rotating secondary display to 90 degrees..."
    displayplacer "id:2 degree:90"
  fi
  
  echo "Display rotation toggled successfully."
}

# Note: This function requires 'displayplacer' to be installed
# Install it with: brew tap jakehilborn/jakehilborn && brew install displayplacer


function pact() {
	source .venv/bin/activate
}

function pdact() {
	deactivate	
}

function killport() {
   lsof -ti :$1 | xargs kill
}

# Quickstart new pvim project (python with nvim)
function pvim() {
    python3 -m venv .venv
    source .venv/bin/activate
    pip install debugpy tqdm numpy basedpyright "$@"
		pip install --upgrade pip
		touch main.py
		echo "\ndef main():\n    return\n\nif __name__ == \"__main__\":\n    main()\n" >> main.py
		nvim main.py
}

# Quickstart new gvim project (go with vim)
function gvim() {
	go mod init $1
	touch main.go
	echo 'package main\n\nimport "fmt"\n\nfunc main() {\n    fmt.Println("Hello, World!")\n}' >> main.go
	nvim main.go
}

# Quickstart new rvim project (rust with vim)
function rvim() {
    cargo init
    nvim src/main.rs
}

function vim() {
	nvim "$@"
}

function gg() {
	git add "$1"
	git commit -m "$2"
}

function acp() {
  git add .
  git commit -m "$1"
  git push
}

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME=""


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(
	git
  yarn 
  web-search 
  jsontools
  macports
  node 
  sudo
  thor
  docker
	z
)


# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'


#test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# Reload the plugin to highlight the commands each time Iterm2 starts 


### VISUAL CUSTOMISATION ### 

# Elements options of left prompt (remove the @username context)
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir rbenv vcs)
# Elements options of right prompt
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status root_indicator background_jobs history time)



# Add a second prompt line for the command
# POWERLEVEL9K_PROMPT_ON_NEWLINE=true

# Add a space in the first prompt 
# POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX="%f"

# Visual customisation of the second prompt line
#local user_symbol="$"
#if [[ $(print -P "%#") =~ "#" ]]; then
    #user_symbol = "#"
#fi
# POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%{%B%F{black}%K{yellow}%} $user_symbol%{%b%f%k%F{yellow}%} %{%f%}"


# Change the git status to red when something isn't committed and pushed
# POWERLEVEL9K_VCS_MODIFIED_BACKGROUND='red'

# Add a new line after the global prompt 
# POWERLEVEL9K_PROMPT_ADD_NEWLINE=true


# Colorise the top Tabs of Iterm2 with the same color as background
# Just change the 18/26/33 wich are the rgb values 
#echo -e "\033]6;1;bg;red;brightness;18\a"
#echo -e "\033]6;1;bg;green;brightness;26\a"
#echo -e "\033]6;1;bg;blue;brightness;33\a"

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# echo '
# ┌─────────────────────────────────────────────────┐
# │ ┌─┐ ElliotLearnsThings Terminal v1.0      ┐ □ × │
# │ └─┘																						  │
# │                                                 │
# │  ███╗   ███╗ █████╗ ██████╗ ██████╗             │
# │  ████╗ ████║██╔══██╗██╔══██╗██╔══██╗            │
# │  ██╔████╔██║███████║██║  ██║██║  ██║            │
# │  ██║╚██╔╝██║██╔══██║██║  ██║██║  ██║            │
# │  ██║ ╚═╝ ██║██║  ██║██████╔╝██████╔╝            │
# │  ╚═╝     ╚═╝╚═╝  ╚═╝╚═════╝ ╚═════╝             │
# │                                                 │
# │  System: $(uname -s) $(uname -r)                │
# │  User: $(whoami)@$(hostname)                    │
# │  Shell: $SHELL                                  │
# │                                                 │
# └─────────────────────────────────────────────────┘
# '

eval "$(starship init zsh)"

python3 ascii.py

setopt hist_ignore_all_dups

function ascii() {
	python3 ~/ascii.py
}

set -o vi
bindkey -v
bindkey -v '^?' backward-delete-char

# BIG ts shit

# tvim() - Create a TypeScript project with debugging support and open in Neovim
tvim() {
  local project_name=${1:-ts-project}
  local main_file=${2:-main.ts}
  
  # Check if directory exists already
  if [[ -d "$project_name" ]]; then
    echo "Directory '$project_name' already exists. Choose a different name or delete the existing directory."
    return 1
  fi

  echo "🚀 Creating TypeScript project: $project_name"
  
  # Create project directory
  mkdir -p "$project_name"
  cd "$project_name"
  
  # Initialize npm project with default values
  echo "📦 Initializing npm project..."
  npm init -y > /dev/null
  
  # Update package.json with useful scripts
  echo "📝 Configuring package.json..."
  cat > package.json << EOF
{
  "name": "${project_name}",
  "version": "1.0.0",
  "description": "TypeScript project with debugging support",
  "main": "dist/${main_file%.ts}.js",
  "scripts": {
    "start": "tsx ${main_file}",
    "dev": "tsx --watch ${main_file}",
    "debug": "tsx --inspect-brk ${main_file}",
    "build": "tsc",
    "test": "jest"
  },
  "keywords": ["typescript", "debug"],
  "author": "",
  "license": "ISC"
}
EOF
  
  # Install TypeScript and related dependencies
  echo "📚 Installing dependencies..."
  npm install --save-dev typescript tsx ts-node @types/node jest ts-jest @types/jest > /dev/null
  
  # Create tsconfig.json
  echo "⚙️ Creating TypeScript configuration..."
  cat > tsconfig.json << EOF
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "esModuleInterop": true,
    "sourceMap": true,
    "outDir": "dist",
    "strict": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["**/*.ts"],
  "exclude": ["node_modules", "dist"]
}
EOF
  
  # Create a debug-ready main.ts file
  echo "🔧 Creating main TypeScript file with debugging support..."
  cat > "$main_file" << EOF
/**
 * ${project_name} - Main TypeScript file
 * Run with:
 *   - npm start     (normal execution)
 *   - npm run debug (debugging mode with inspector)
 */

// A delay function useful for setting breakpoints
function delay(ms: number): Promise<void> {
  return new Promise(resolve => {
    console.log(\`Waiting for \${ms}ms...\`);
    setTimeout(resolve, ms);
  });
}

// Log helpers with colors
const log = {
  info: (message: string) => console.log(\`\x1b[36m[INFO]\x1b[0m \${message}\`),
  success: (message: string) => console.log(\`\x1b[32m[SUCCESS]\x1b[0m \${message}\`),
  warn: (message: string) => console.log(\`\x1b[33m[WARNING]\x1b[0m \${message}\`),
  error: (message: string) => console.log(\`\x1b[31m[ERROR]\x1b[0m \${message}\`)
};

// Example class to demonstrate debugging
class DebugExample {
  private counter: number = 0;
  
  increment(amount: number = 1): number {
    this.counter += amount;
    return this.counter;
  }
  
  getValue(): number {
    return this.counter;
  }
}

// Main application function
async function main(): Promise<void> {
  log.info("Application starting...");
  
  const example = new DebugExample();
  
  // Good breakpoint location
  log.info(\`Initial counter value: \${example.getValue()}\`);
  
  // Process some values (good for debugging)
  for (let i = 1; i <= 3; i++) {
    await delay(1000);
    const newValue = example.increment(i);
    log.success(\`Counter incremented by \${i} to \${newValue}\`);
  }
  
  // Another good breakpoint location
  const finalValue = example.getValue();
  log.info(\`Final counter value: \${finalValue}\`);
  
  await delay(1000);
  log.success("Application completed successfully!");
}

// Run the main function
main().catch(error => {
  log.error(\`Unhandled error: \${error.message}\`);
  console.error(error);
});

// Keep process alive for attaching debugger
if (process.execArgv.some(arg => arg.includes('--inspect'))) {
  log.info("Running in debug mode - process will stay alive for debugging");
  setInterval(() => {}, 1000);
}
EOF
  
  # Create .gitignore
  echo "📄 Creating .gitignore..."
  cat > .gitignore << EOF
node_modules/
dist/
coverage/
*.log
.DS_Store
EOF

  # Create a README.md file with debugging instructions
  echo "📚 Creating README with debugging instructions..."
  cat > README.md << EOF
# ${project_name}

A TypeScript project with debugging support.

## Getting Started

\`\`\`bash
# Install dependencies
npm install

# Run in development mode
npm run dev

# Run with debugger
npm run debug
\`\`\`

## Debugging in Neovim

1. Start the application with the debugger:
   \`\`\`
   npm run debug
   \`\`\`

2. In Neovim, attach to the running process:
   \`\`\`
   :lua require('dap').continue()
   \`\`\`

3. Set breakpoints with:
   \`\`\`
   :lua require('dap').toggle_breakpoint()
   \`\`\`

4. Use \`<leader>dc\` to continue execution
   Use \`<leader>dn\` to step over
   Use \`<C-p>\` to step into
   Use \`<leader>do\` to step out
EOF

  # Create a .nvim.lua local config file for the project
  echo "🔧 Creating Neovim local config..."
  cat > .nvim.lua << EOF
-- Local Neovim configuration for TypeScript debugging
-- This file will be automatically loaded if you have the nvim-projectconfig plugin

-- Set up DAP for TypeScript
local dap = require('dap')

-- Configure DAP for TypeScript
dap.configurations.typescript = {
  {
    name = 'Attach to Process',
    type = 'node',
    request = 'attach',
    port = 9229,
    restart = false,
    sourceMaps = true,
    skipFiles = {'<node_internals>/**'}
  }
}

-- Match JavaScript configurations
dap.configurations.javascript = dap.configurations.typescript

-- Set up a command for the typical debugging workflow
vim.api.nvim_create_user_command('Debug', function()
  -- Open a terminal split and start the debugger
  vim.cmd('vsplit | terminal npm run debug')
  
  -- Wait for debugger to start, then attach
  vim.defer_fn(function()
    -- Open DAP UI
    require('dapui').open()
    
    -- Attach the debugger
    vim.defer_fn(function()
      require('dap').continue()
    end, 1000)
  end, 2000)
end, {})

-- Create convenient keymap
vim.keymap.set('n', '<leader>dd', "<CMD>Debug<CR>", { noremap = true, silent = true })

print("TypeScript debugging configuration loaded!")
EOF

  # Create .vscode directory for those who might use VS Code
  mkdir -p .vscode
  cat > .vscode/launch.json << EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Launch Program",
      "skipFiles": ["<node_internals>/**"],
      "program": "\${workspaceFolder}/${main_file}",
      "runtimeArgs": ["-r", "tsx/register"],
      "outFiles": ["\${workspaceFolder}/dist/**/*.js"],
      "sourceMaps": true
    },
    {
      "type": "node",
      "request": "attach",
      "name": "Attach to Process",
      "port": 9229,
      "skipFiles": ["<node_internals>/**"],
      "sourceMaps": true
    }
  ]
}
EOF

  # Success message
  echo ""
  echo "✅ TypeScript project created successfully!"
  echo "📂 Project: $project_name"
  echo "📝 Main file: $main_file"
  echo ""
  echo "📋 Commands:"
  echo "  npm start     - Run the application"
  echo "  npm run dev   - Run with auto-reload on changes"
  echo "  npm run debug - Run with debugger attached"
  echo "  npm run build - Compile TypeScript to JavaScript"
  echo ""
  echo "🛠️ Opening in Neovim..."
  
  # Open the main file in Neovim
  nvim "$main_file"
}

