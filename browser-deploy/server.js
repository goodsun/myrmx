const express = require('express');
const path = require('path');
const fs = require('fs').promises;
const { spawn } = require('child_process');
const os = require('os');

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
        
        // Check and install dependencies if needed
        if (!await checkDependencies(projectPath)) {
            try {
                res.write(JSON.stringify({ status: 'installing', message: 'Installing dependencies...' }) + '\n');
                await installDependencies(projectPath);
                res.write(JSON.stringify({ status: 'installed', message: 'Dependencies installed successfully' }) + '\n');
            } catch (error) {
                res.write(JSON.stringify({ success: false, error: `Failed to install dependencies: ${error.message}` }) + '\n');
                return res.end();
            }
        }
        
        // Run hardhat compile
        // Use platform-specific command execution
        const isWindows = os.platform() === 'win32';
        const npxCmd = isWindows ? 'npx.cmd' : 'npx';
        const compile = spawn(npxCmd, ['hardhat', 'compile'], {
            cwd: projectPath,
            stdio: 'pipe',
            shell: false
        });
        
        let output = '';
        let errorOutput = '';
        
        compile.stdout.on('data', (data) => {
            output += data.toString();
        });
        
        compile.stderr.on('data', (data) => {
            errorOutput += data.toString();
        });
        
        compile.on('close', (code) => {
            if (code === 0) {
                res.write(JSON.stringify({ success: true, output }) + '\n');
            } else {
                res.write(JSON.stringify({ success: false, error: errorOutput || output }) + '\n');
            }
            res.end();
        });
        
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
        
        // Find the contract artifact
        const contractDirs = await fs.readdir(artifactsPath, { withFileTypes: true });
        
        for (const dir of contractDirs) {
            if (dir.isDirectory() && dir.name.endsWith('.sol')) {
                const contractPath = path.join(artifactsPath, dir.name, `${contractName}.json`);
                
                try {
                    const contractData = await fs.readFile(contractPath, 'utf8');
                    const parsed = JSON.parse(contractData);
                    
                    return res.json({
                        success: true,
                        bytecode: parsed.bytecode,
                        abi: parsed.abi
                    });
                } catch {
                    // Continue searching
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