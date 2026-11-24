# tvim() - TypeScript project scaffold with debugging support (sourced from ~/.zshrc)
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
