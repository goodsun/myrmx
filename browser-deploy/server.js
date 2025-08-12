const express = require('express');
const path = require('path');
const fs = require('fs').promises;
const { spawn } = require('child_process');

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
        
        // Run hardhat compile
        const compile = spawn('npx', ['hardhat', 'compile'], {
            cwd: projectPath,
            shell: true
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
                res.json({ success: true, output });
            } else {
                res.json({ success: false, error: errorOutput || output });
            }
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

// Root package.json for the browser-deploy tool
app.get('/package.json', (req, res) => {
    res.json({
        name: "hardhat-browser-deploy",
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
🚀 Hardhat Browser Deploy Tool is running!
   
   URL: http://localhost:${PORT}
   
   To use:
   1. Open the URL in your browser
   2. Select a project
   3. Connect MetaMask
   4. Compile and deploy contracts
   
   Press Ctrl+C to stop
    `);
});