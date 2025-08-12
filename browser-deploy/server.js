const express = require('express');
const path = require('path');
const fs = require('fs').promises;
const { spawn } = require('child_process');
const os = require('os');

// Project templates
const PROJECT_TEMPLATES = {
    'hardhat.config.js': `require("@nomiclabs/hardhat-waffle");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      chainId: 1337
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    }
  }
};`,
    'package.json': (projectName) => `{
  "name": "${projectName}",
  "version": "1.0.0",
  "description": "Hardhat project created by siegeNgin",
  "scripts": {
    "compile": "hardhat compile",
    "test": "hardhat test"
  },
  "devDependencies": {
    "@nomiclabs/hardhat-ethers": "^2.0.0",
    "@nomiclabs/hardhat-waffle": "^2.0.0",
    "chai": "^4.2.0",
    "ethereum-waffle": "^3.0.0",
    "ethers": "^5.0.0",
    "hardhat": "^2.12.0"
  }
}`,
    '.gitignore': `node_modules
.env
coverage
coverage.json
typechain
typechain-types

# Hardhat files
cache
artifacts

# Editor
.vscode
.idea`,
    'contracts/HelloWorld.sol': `// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract HelloWorld {
    string public message;
    address public owner;
    
    event MessageChanged(string oldMessage, string newMessage);
    
    constructor(string memory _message) {
        message = _message;
        owner = msg.sender;
    }
    
    function setMessage(string memory _newMessage) public {
        string memory oldMessage = message;
        message = _newMessage;
        emit MessageChanged(oldMessage, _newMessage);
    }
    
    function getMessage() public view returns (string memory) {
        return message;
    }
}`
};

const app = express();
const PORT = process.env.PORT || 3000;

// CORS設定
const cors = require('cors');
const corsOptions = {
    origin: function (origin, callback) {
        // 開発環境ではすべて許可、本番環境では特定のオリジンのみ許可
        const allowedOrigins = process.env.NODE_ENV === 'production' 
            ? ['https://yourdomain.com'] 
            : true;
        callback(null, allowedOrigins);
    },
    credentials: true,
    optionsSuccessStatus: 200
};

// Middleware
app.use(cors(corsOptions));
app.use(express.static(__dirname));
app.use(express.json());

// Security: Validate project name to prevent path traversal
function validateProjectName(projectName) {
    // Check for null/undefined
    if (!projectName) return false;
    
    // Check for path traversal patterns
    const dangerous = ['..', '/', '\\', '~', './', '../', '..\\', '.\\'];
    for (const pattern of dangerous) {
        if (projectName.includes(pattern)) {
            return false;
        }
    }
    
    // Only allow alphanumeric, dash, and underscore
    if (!/^[a-zA-Z0-9_-]+$/.test(projectName)) {
        return false;
    }
    
    // Reasonable length limit
    if (projectName.length > 100) {
        return false;
    }
    
    return true;
}

// Additional security: Ensure path stays within projects directory
async function validateProjectPath(projectPath) {
    const projectsRoot = path.resolve(path.join(__dirname, '../projects'));
    const resolvedPath = path.resolve(projectPath);
    
    // Ensure the resolved path starts with projects root
    if (!resolvedPath.startsWith(projectsRoot)) {
        return false;
    }
    
    // Check if directory exists
    try {
        const stat = await fs.stat(resolvedPath);
        return stat.isDirectory();
    } catch {
        return false;
    }
}

// Get list of projects
app.get('/api/projects', async (req, res) => {
    try {
        const projectsDir = path.join(__dirname, '../projects');
        const items = await fs.readdir(projectsDir, { withFileTypes: true });
        const projects = items
            .filter(item => item.isDirectory())
            .map(item => item.name);
        
        res.json({ projects });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Get contracts for a project
app.get('/api/projects/:projectName/contracts', async (req, res) => {
    try {
        const { projectName } = req.params;
        
        // Validate project name
        if (!validateProjectName(projectName)) {
            return res.status(400).json({ error: 'Invalid project name' });
        }
        
        const projectPath = path.join(__dirname, '../projects', projectName);
        
        // Validate project path
        if (!await validateProjectPath(projectPath)) {
            return res.status(404).json({ error: 'Project not found' });
        }
        
        const artifactsPath = path.join(projectPath, 'artifacts/contracts');
        
        const contracts = {};
        
        // Check if artifacts exist
        try {
            await fs.access(artifactsPath);
        } catch {
            return res.json({ contracts });
        }
        
        // Read all contract directories
        const contractDirs = await fs.readdir(artifactsPath, { withFileTypes: true });
        
        for (const dir of contractDirs) {
            if (dir.isDirectory() && dir.name.endsWith('.sol')) {
                const contractPath = path.join(artifactsPath, dir.name);
                const files = await fs.readdir(contractPath);
                
                // Find contract JSON files (excluding .dbg.json)
                const contractFiles = files.filter(f => f.endsWith('.json') && !f.endsWith('.dbg.json'));
                
                for (const file of contractFiles) {
                    const contractName = path.basename(file, '.json');
                    const contractData = await fs.readFile(path.join(contractPath, file), 'utf8');
                    const parsed = JSON.parse(contractData);
                    
                    contracts[contractName] = {
                        abi: parsed.abi,
                        bytecode: parsed.bytecode
                    };
                }
            }
        }
        
        res.json({ contracts });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: error.message });
    }
});

// Check if dependencies are installed
async function checkDependencies(projectPath) {
    try {
        await fs.access(path.join(projectPath, 'node_modules'));
        return true;
    } catch {
        return false;
    }
}

// Install dependencies
async function installDependencies(projectPath) {
    return new Promise((resolve, reject) => {
        // Use platform-specific command execution
        const isWindows = os.platform() === 'win32';
        const npmCmd = isWindows ? 'npm.cmd' : 'npm';
        const install = spawn(npmCmd, ['install', '--production'], {
            cwd: projectPath,
            stdio: 'pipe',
            shell: false
        });
        
        let output = '';
        let errorOutput = '';
        
        install.stdout.on('data', (data) => {
            output += data.toString();
        });
        
        install.stderr.on('data', (data) => {
            errorOutput += data.toString();
        });
        
        install.on('close', (code) => {
            if (code === 0) {
                resolve({ success: true, output });
            } else {
                reject(new Error(errorOutput || 'npm install failed'));
            }
        });
    });
}

// Helper function to list directory contents
async function listDirectoryContents(dirPath, prefix = '') {
    const items = [];
    try {
        const entries = await fs.readdir(dirPath, { withFileTypes: true });
        for (const entry of entries) {
            const fullPath = path.join(dirPath, entry.name);
            if (entry.isDirectory()) {
                items.push(`${prefix}${entry.name}/`);
                // Recursively list subdirectories (limit depth to avoid node_modules)
                if (entry.name !== 'node_modules' && entry.name !== '.git') {
                    const subItems = await listDirectoryContents(fullPath, prefix + '  ');
                    items.push(...subItems);
                }
            } else {
                const stats = await fs.stat(fullPath);
                items.push(`${prefix}${entry.name} (${stats.size} bytes)`);
            }
        }
    } catch (error) {
        items.push(`${prefix}[Error reading directory: ${error.message}]`);
    }
    return items;
}

// Compile project
app.post('/api/projects/:projectName/compile', async (req, res) => {
    try {
        const { projectName } = req.params;
        
        // Validate project name
        if (!validateProjectName(projectName)) {
            return res.status(400).json({ success: false, error: 'Invalid project name' });
        }
        
        const projectPath = path.join(__dirname, '../projects', projectName);
        
        // Validate project path
        if (!await validateProjectPath(projectPath)) {
            return res.status(404).json({ success: false, error: 'Project not found' });
        }
        
        // Set headers for streaming response
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Transfer-Encoding', 'chunked');
        
        // Log directory contents before compile
        console.log('\n=== BEFORE COMPILE ===');
        console.log(`Project: ${projectName}`);
        console.log(`Path: ${projectPath}`);
        console.log('Directory contents:');
        const beforeContents = await listDirectoryContents(projectPath);
        beforeContents.forEach(item => console.log(item));
        
        // Send initial status
        res.write(JSON.stringify({ 
            status: 'starting', 
            message: 'Starting compilation...',
            debug: {
                projectPath,
                contents: beforeContents
            }
        }) + '\n');
        
        // Check and install dependencies if needed
        const hasDependencies = await checkDependencies(projectPath);
        console.log(`Dependencies check: ${hasDependencies ? 'Found' : 'Not found'}`);
        
        if (!hasDependencies) {
            console.log('Installing dependencies...');
            try {
                res.write(JSON.stringify({ status: 'installing', message: 'Installing dependencies...' }) + '\n');
                await installDependencies(projectPath);
                res.write(JSON.stringify({ status: 'installed', message: 'Dependencies installed successfully' }) + '\n');
                console.log('Dependencies installed successfully');
            } catch (error) {
                console.error('Failed to install dependencies:', error);
                res.write(JSON.stringify({ success: false, error: `Failed to install dependencies: ${error.message}` }) + '\n');
                return res.end();
            }
        } else {
            console.log('Dependencies already installed');
        }
        
        // Run hardhat compile
        // Use platform-specific command execution
        const isWindows = os.platform() === 'win32';
        const npxCmd = isWindows ? 'npx.cmd' : 'npx';
        
        console.log('\n=== EXECUTING COMPILE ===');
        console.log(`Command: ${npxCmd} hardhat compile`);
        console.log(`Working directory: ${projectPath}`);
        console.log(`Platform: ${os.platform()}`);
        
        const compile = spawn(npxCmd, ['hardhat', 'compile'], {
            cwd: projectPath,
            stdio: 'pipe',
            shell: false,
            env: { ...process.env, NODE_ENV: 'development' }
        });
        
        console.log(`Process PID: ${compile.pid}`);
        
        let output = '';
        let errorOutput = '';
        
        compile.stdout.on('data', (data) => {
            const chunk = data.toString();
            output += chunk;
            console.log('[STDOUT]:', chunk.trim());
        });
        
        compile.stderr.on('data', (data) => {
            const chunk = data.toString();
            errorOutput += chunk;
            console.log('[STDERR]:', chunk.trim());
        });
        
        compile.on('error', (error) => {
            console.error('[SPAWN ERROR]:', error);
        });
        
        compile.on('close', async (code) => {
            // Log directory contents after compile
            console.log('\n=== AFTER COMPILE ===');
            console.log(`Exit code: ${code}`);
            console.log('Directory contents:');
            const afterContents = await listDirectoryContents(projectPath);
            afterContents.forEach(item => console.log(item));
            
            // Check for artifacts and cache
            const artifactsPath = path.join(projectPath, 'artifacts');
            const cachePath = path.join(projectPath, 'cache');
            
            let artifactsExist = false;
            let cacheExists = false;
            
            try {
                await fs.access(artifactsPath);
                artifactsExist = true;
                console.log('\n✓ artifacts directory created');
            } catch {
                console.log('\n✗ artifacts directory NOT created');
            }
            
            try {
                await fs.access(cachePath);
                cacheExists = true;
                console.log('✓ cache directory created');
            } catch {
                console.log('✗ cache directory NOT created');
            }
            
            if (code === 0) {
                res.write(JSON.stringify({ 
                    success: true, 
                    output,
                    debug: {
                        exitCode: code,
                        artifactsCreated: artifactsExist,
                        cacheCreated: cacheExists,
                        afterContents
                    }
                }) + '\n');
            } else {
                res.write(JSON.stringify({ 
                    success: false, 
                    error: errorOutput || output,
                    debug: {
                        exitCode: code,
                        stdout: output,
                        stderr: errorOutput,
                        afterContents
                    }
                }) + '\n');
            }
            
            console.log('\n=== COMPILE COMPLETE ===\n');
            res.end();
        });
        
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Create new project
app.post('/api/projects/create', async (req, res) => {
    try {
        const { projectName } = req.body;
        
        // Validate project name
        if (!validateProjectName(projectName)) {
            return res.status(400).json({ success: false, error: 'Invalid project name' });
        }
        
        const projectPath = path.join(__dirname, '../projects', projectName);
        
        // Check if project already exists
        try {
            await fs.access(projectPath);
            return res.status(400).json({ success: false, error: 'Project already exists' });
        } catch {
            // Project doesn't exist, continue
        }
        
        // Create project directory structure
        await fs.mkdir(projectPath, { recursive: true });
        await fs.mkdir(path.join(projectPath, 'contracts'), { recursive: true });
        await fs.mkdir(path.join(projectPath, 'test'), { recursive: true });
        
        // Write template files
        await fs.writeFile(
            path.join(projectPath, 'hardhat.config.js'),
            PROJECT_TEMPLATES['hardhat.config.js']
        );
        
        await fs.writeFile(
            path.join(projectPath, 'package.json'),
            typeof PROJECT_TEMPLATES['package.json'] === 'function' 
                ? PROJECT_TEMPLATES['package.json'](projectName)
                : PROJECT_TEMPLATES['package.json']
        );
        
        await fs.writeFile(
            path.join(projectPath, '.gitignore'),
            PROJECT_TEMPLATES['.gitignore']
        );
        
        await fs.writeFile(
            path.join(projectPath, 'contracts', 'HelloWorld.sol'),
            PROJECT_TEMPLATES['contracts/HelloWorld.sol']
        );
        
        // Install dependencies
        res.setHeader('Content-Type', 'application/json');
        res.setHeader('Transfer-Encoding', 'chunked');
        
        res.write(JSON.stringify({ status: 'created', message: 'Project created successfully' }) + '\n');
        res.write(JSON.stringify({ status: 'installing', message: 'Installing dependencies...' }) + '\n');
        
        try {
            await installDependencies(projectPath);
            res.write(JSON.stringify({ success: true, message: 'Project created and dependencies installed' }) + '\n');
        } catch (error) {
            res.write(JSON.stringify({ success: true, message: 'Project created but dependency installation failed. Run npm install manually.' }) + '\n');
        }
        
        res.end();
        
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get deployment data for a contract
app.post('/api/projects/:projectName/deploy', async (req, res) => {
    try {
        const { projectName } = req.params;
        const { contractName } = req.body;
        
        // Validate project name
        if (!validateProjectName(projectName)) {
            return res.status(400).json({ success: false, error: 'Invalid project name' });
        }
        
        // Validate contract name (similar rules)
        if (!validateProjectName(contractName)) {
            return res.status(400).json({ success: false, error: 'Invalid contract name' });
        }
        
        const projectPath = path.join(__dirname, '../projects', projectName);
        
        // Validate project path
        if (!await validateProjectPath(projectPath)) {
            return res.status(404).json({ success: false, error: 'Project not found' });
        }
        
        const artifactsPath = path.join(projectPath, 'artifacts/contracts');
        
        // Check if artifacts directory exists
        try {
            await fs.access(artifactsPath);
        } catch {
            return res.status(404).json({ success: false, error: 'No compiled contracts found. Please compile first.' });
        }
        
        // Find the contract artifact
        const contractDirs = await fs.readdir(artifactsPath, { withFileTypes: true });
        
        for (const dir of contractDirs) {
            if (dir.isDirectory() && dir.name.endsWith('.sol')) {
                const contractPath = path.join(artifactsPath, dir.name, `${contractName}.json`);
                
                try {
                    const contractData = await fs.readFile(contractPath, 'utf8');
                    const parsed = JSON.parse(contractData);
                    
                    // Log for debugging
                    console.log(`Found contract ${contractName} at ${contractPath}`);
                    console.log(`Bytecode exists: ${!!parsed.bytecode}`);
                    console.log(`Bytecode length: ${parsed.bytecode ? parsed.bytecode.length : 0}`);
                    
                    return res.json({
                        success: true,
                        bytecode: parsed.bytecode,
                        abi: parsed.abi
                    });
                } catch (readError) {
                    // Continue searching
                    console.log(`Failed to read ${contractPath}: ${readError.message}`);
                }
            }
        }
        
        res.status(404).json({ success: false, error: 'Contract not found' });
        
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Clean project based on .gitignore
app.post('/api/projects/:projectName/clean', async (req, res) => {
    try {
        const { projectName } = req.params;
        
        // Validate project name
        if (!validateProjectName(projectName)) {
            return res.status(400).json({ success: false, error: 'Invalid project name' });
        }
        
        const projectPath = path.join(__dirname, '../projects', projectName);
        
        // Validate project path
        if (!await validateProjectPath(projectPath)) {
            return res.status(404).json({ success: false, error: 'Project not found' });
        }
        
        const deletedFiles = [];
        const errors = [];
        
        // Common patterns to clean (based on typical .gitignore)
        const cleanPatterns = [
            'node_modules',
            'artifacts',
            'cache',
            'coverage',
            '.coverage_cache',
            'typechain',
            'typechain-types'
        ];
        
        // Read .gitignore if exists
        const gitignorePath = path.join(projectPath, '.gitignore');
        try {
            const gitignoreContent = await fs.readFile(gitignorePath, 'utf8');
            const customPatterns = gitignoreContent
                .split('\n')
                .filter(line => line.trim() && !line.startsWith('#'))
                .map(line => line.trim());
            cleanPatterns.push(...customPatterns);
        } catch {
            // No .gitignore, use default patterns
        }
        
        // Clean each pattern
        for (const pattern of cleanPatterns) {
            const targetPath = path.join(projectPath, pattern);
            try {
                await fs.access(targetPath);
                await fs.rm(targetPath, { recursive: true, force: true });
                deletedFiles.push(pattern);
            } catch (error) {
                // File/directory doesn't exist or couldn't be deleted
                if (error.code !== 'ENOENT') {
                    errors.push({ pattern, error: error.message });
                }
            }
        }
        
        res.json({
            success: true,
            deletedFiles,
            errors,
            message: `Cleaned ${deletedFiles.length} items`
        });
        
    } catch (error) {
        res.status(500).json({ success: false, error: error.message });
    }
});

// Get project status
app.get('/api/projects/:projectName/status', async (req, res) => {
    try {
        const { projectName } = req.params;
        
        // Validate project name
        if (!validateProjectName(projectName)) {
            return res.status(400).json({ error: 'Invalid project name' });
        }
        
        const projectPath = path.join(__dirname, '../projects', projectName);
        
        // Validate project path
        if (!await validateProjectPath(projectPath)) {
            return res.status(404).json({ error: 'Project not found' });
        }
        
        const status = {
            hasDependencies: await checkDependencies(projectPath),
            hasArtifacts: false,
            hasCache: false,
            cleanableSize: 0
        };
        
        // Check for artifacts
        try {
            await fs.access(path.join(projectPath, 'artifacts'));
            status.hasArtifacts = true;
        } catch {}
        
        // Check for cache
        try {
            await fs.access(path.join(projectPath, 'cache'));
            status.hasCache = true;
        } catch {}
        
        res.json(status);
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// Root package.json for the browser-deploy tool
app.get('/package.json', (req, res) => {
    res.json({
        name: "siegengin-browser-deploy",
        version: "1.0.0",
        scripts: {
            start: "node server.js"
        },
        dependencies: {
            express: "^4.18.2"
        }
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`
🚀 siegeNgin Browser Deploy Tool is running!
   
   URL: http://localhost:${PORT}
   
   To use:
   1. Open the URL in your browser
   2. Select a project
   3. Connect MetaMask
   4. Compile and deploy contracts
   
   Press Ctrl+C to stop
    `);
});