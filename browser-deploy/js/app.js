// Main application logic
let provider;
let signer;
let selectedProject = '';
let selectedContract = '';
let contracts = {};
let deployedContract = null; // Store deployed contract instance

// Initialize the application
document.addEventListener('DOMContentLoaded', async () => {
    // Load projects
    await loadProjects();
    
    // Event listeners
    document.getElementById('connectWallet').addEventListener('click', connectWallet);
    document.getElementById('projectSelect').addEventListener('change', onProjectChange);
    document.getElementById('refreshProjects').addEventListener('click', loadProjects);
    document.getElementById('compileBtn').addEventListener('click', compileProject);
    document.getElementById('refreshContracts').addEventListener('click', loadContracts);
    document.getElementById('deployBtn').addEventListener('click', deployContract);
    document.getElementById('cleanProject').addEventListener('click', cleanProject);
    document.getElementById('createProject').addEventListener('click', createNewProject);
    
    // Contract interaction event listeners
    document.getElementById('readTab').addEventListener('click', () => switchTab('read'));
    document.getElementById('writeTab').addEventListener('click', () => switchTab('write'));
    document.getElementById('eventsTab').addEventListener('click', () => switchTab('events'));
    document.getElementById('refreshEvents').addEventListener('click', refreshEvents);
});

// Load available projects
async function loadProjects() {
    try {
        const response = await fetch('/api/projects');
        const data = await response.json();
        
        const select = document.getElementById('projectSelect');
        select.innerHTML = '<option value="">Select a project...</option>';
        
        data.projects.forEach(project => {
            const option = document.createElement('option');
            option.value = project;
            option.textContent = project;
            select.appendChild(option);
        });
    } catch (error) {
        showMessage('Failed to load projects', 'error');
    }
}

// Validate project name on client side
function isValidProjectName(name) {
    // Same validation as server
    if (!name) return false;
    
    const dangerous = ['..', '/', '\\', '~', './', '../', '..\\', '.\\'];
    for (const pattern of dangerous) {
        if (name.includes(pattern)) {
            return false;
        }
    }
    
    if (!/^[a-zA-Z0-9_-]+$/.test(name)) {
        return false;
    }
    
    if (name.length > 100) {
        return false;
    }
    
    return true;
}

// Handle project selection change
async function onProjectChange(event) {
    selectedProject = event.target.value;
    
    // Validate project name
    if (selectedProject && !isValidProjectName(selectedProject)) {
        showMessage('Invalid project name', 'error');
        selectedProject = '';
        event.target.value = '';
        return;
    }
    
    if (selectedProject) {
        await loadContracts();
        await loadProjectStatus();
        document.getElementById('cleanProject').classList.remove('hidden');
    } else {
        document.getElementById('contractsContainer').innerHTML = '<p class="text-gray-500">Select a project first</p>';
        document.getElementById('cleanProject').classList.add('hidden');
        document.getElementById('projectStatus').classList.add('hidden');
    }
}

// Load project status
async function loadProjectStatus() {
    if (!selectedProject) return;
    
    try {
        const response = await fetch(`/api/projects/${selectedProject}/status`);
        const status = await response.json();
        
        console.log('Project status:', status); // デバッグ用
        
        const statusDetails = document.getElementById('statusDetails');
        statusDetails.innerHTML = '';
        
        const items = [
            { label: 'Dependencies', value: status.hasDependencies ? '✅ Installed' : '❌ Not installed' },
            { label: 'Build artifacts', value: status.hasArtifacts ? '✅ Present' : '❌ Not built' },
            { label: 'Cache', value: status.hasCache ? '✅ Present' : '❌ Empty' }
        ];
        
        items.forEach(item => {
            const p = document.createElement('p');
            p.innerHTML = `<span class="text-gray-600">${item.label}:</span> ${item.value}`;
            statusDetails.appendChild(p);
        });
        
        document.getElementById('projectStatus').classList.remove('hidden');
    } catch (error) {
        console.error('Failed to load project status:', error);
    }
}

// Clean project
async function cleanProject() {
    if (!selectedProject) return;
    
    const confirm = window.confirm(
        `This will delete:\n` +
        `- node_modules\n` +
        `- artifacts\n` +
        `- cache\n` +
        `- other .gitignore entries\n\n` +
        `Are you sure you want to clean the project "${selectedProject}"?`
    );
    
    if (!confirm) return;
    
    showMessage('Cleaning project...', 'info');
    
    try {
        const response = await fetch(`/api/projects/${selectedProject}/clean`, {
            method: 'POST'
        });
        
        const data = await response.json();
        
        if (data.success) {
            showMessage(`Cleaned ${data.deletedFiles.length} items`, 'success');
            
            // Show details
            if (data.deletedFiles.length > 0) {
                console.log('Deleted:', data.deletedFiles);
            }
            if (data.errors.length > 0) {
                console.error('Errors:', data.errors);
            }
            
            // Reload status
            await loadProjectStatus();
            await loadContracts();
        } else {
            showMessage(`Clean failed: ${data.error}`, 'error');
        }
    } catch (error) {
        showMessage('Clean failed', 'error');
    }
}

// Load contracts for selected project
async function loadContracts() {
    if (!selectedProject) return;
    
    try {
        const response = await fetch(`/api/projects/${selectedProject}/contracts`);
        const data = await response.json();
        
        contracts = data.contracts;
        const container = document.getElementById('contractsContainer');
        container.innerHTML = '';
        
        if (Object.keys(contracts).length === 0) {
            container.innerHTML = '<p class="text-gray-500">No contracts found. Compile first.</p>';
            return;
        }
        
        Object.keys(contracts).forEach(contractName => {
            const div = document.createElement('div');
            div.className = 'flex items-center mb-2';
            div.innerHTML = `
                <input type="radio" name="contract" value="${contractName}" 
                       id="contract-${contractName}" class="mr-2">
                <label for="contract-${contractName}" class="cursor-pointer">${contractName}</label>
            `;
            container.appendChild(div);
        });
        
        // Add change listener to radio buttons
        document.querySelectorAll('input[name="contract"]').forEach(radio => {
            radio.addEventListener('change', onContractSelect);
        });
    } catch (error) {
        showMessage('Failed to load contracts', 'error');
    }
}

// Handle contract selection
function onContractSelect(event) {
    selectedContract = event.target.value;
    updateDeployButton();
    
    // Show constructor parameters if any
    const contract = contracts[selectedContract];
    if (contract && contract.abi) {
        const constructor = contract.abi.find(item => item.type === 'constructor');
        if (constructor && constructor.inputs.length > 0) {
            showConstructorParams(constructor.inputs);
        } else {
            document.getElementById('constructorParams').classList.add('hidden');
        }
    }
}

// Show constructor parameter inputs
function showConstructorParams(inputs) {
    const container = document.getElementById('paramsContainer');
    container.innerHTML = '';
    
    inputs.forEach((input, index) => {
        const div = document.createElement('div');
        div.className = 'mb-3';
        
        // Determine input type based on Solidity type
        let inputType = 'text';
        let placeholder = `Enter ${input.type}`;
        let pattern = '';
        let additionalInfo = '';
        
        if (input.type.includes('uint') || input.type.includes('int')) {
            inputType = 'number';
            placeholder = 'Enter number';
            pattern = '^-?[0-9]+$';
        } else if (input.type === 'address') {
            placeholder = '0x...';
            pattern = '^0x[a-fA-F0-9]{40}$';
            additionalInfo = '<span class="text-xs text-gray-500">Must be a valid Ethereum address</span>';
        } else if (input.type === 'bool') {
            // Use select for boolean
            div.innerHTML = `
                <label class="block text-sm font-medium mb-1">${input.name} (${input.type})</label>
                <select id="param-${index}" class="w-full border rounded px-3 py-2" data-type="${input.type}">
                    <option value="true">true</option>
                    <option value="false">false</option>
                </select>
            `;
            container.appendChild(div);
            return;
        } else if (input.type.includes('[]')) {
            placeholder = 'Enter comma-separated values';
            additionalInfo = '<span class="text-xs text-gray-500">Separate array elements with commas</span>';
        }
        
        div.innerHTML = `
            <label class="block text-sm font-medium mb-1">${input.name} (${input.type})</label>
            <input type="${inputType}" 
                   id="param-${index}" 
                   class="w-full border rounded px-3 py-2" 
                   placeholder="${placeholder}"
                   pattern="${pattern}"
                   data-type="${input.type}"
                   onblur="validateInput(${index}, '${input.type}')">
            ${additionalInfo}
            <span id="error-${index}" class="text-xs text-red-500 hidden"></span>
        `;
        container.appendChild(div);
    });
    
    document.getElementById('constructorParams').classList.remove('hidden');
}

// Network configurations
const NETWORKS = {
    1: { name: 'Ethereum Mainnet', color: 'text-red-600', warning: true, symbol: 'ETH' },
    5: { name: 'Goerli Testnet', color: 'text-blue-600', warning: false, symbol: 'ETH' },
    11155111: { name: 'Sepolia Testnet', color: 'text-blue-600', warning: false, symbol: 'ETH' },
    137: { name: 'Polygon Mainnet', color: 'text-purple-600', warning: true, symbol: 'MATIC' },
    80001: { name: 'Mumbai Testnet', color: 'text-purple-600', warning: false, symbol: 'MATIC' },
    1337: { name: 'Localhost', color: 'text-green-600', warning: false, symbol: 'ETH' },
    31337: { name: 'Hardhat', color: 'text-green-600', warning: false, symbol: 'ETH' }
};

// Connect MetaMask wallet
async function connectWallet() {
    if (typeof window.ethereum === 'undefined') {
        showMessage('Please install MetaMask!', 'error');
        return;
    }
    
    try {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
        provider = new ethers.providers.Web3Provider(window.ethereum);
        signer = provider.getSigner();
        
        const address = await signer.getAddress();
        const balance = await provider.getBalance(address);
        const network = await provider.getNetwork();
        
        // Validate network
        const networkInfo = NETWORKS[network.chainId] || { 
            name: `Unknown Network (Chain ID: ${network.chainId})`, 
            color: 'text-gray-600', 
            warning: true,
            symbol: 'ETH'
        };
        
        // Update UI with network validation
        document.getElementById('accountAddress').textContent = address;
        document.getElementById('accountBalance').textContent = ethers.utils.formatEther(balance);
        document.getElementById('tokenSymbol').textContent = networkInfo.symbol;
        
        const networkElement = document.getElementById('networkName');
        networkElement.textContent = networkInfo.name;
        networkElement.className = `font-semibold ${networkInfo.color}`;
        
        // Clear previous warnings
        const existingWarning = document.querySelector('#accountInfo .bg-red-50');
        if (existingWarning) {
            existingWarning.remove();
        }
        
        // Show warning for mainnet
        if (networkInfo.warning) {
            const warningDiv = document.createElement('div');
            warningDiv.className = 'mt-2 p-2 bg-red-50 border border-red-200 rounded text-sm text-red-600';
            warningDiv.innerHTML = `⚠️ Warning: You are connected to ${networkInfo.name}. Real ${networkInfo.symbol} will be used!`;
            document.getElementById('accountInfo').appendChild(warningDiv);
        }
        
        document.getElementById('connectWallet').classList.add('hidden');
        document.getElementById('accountInfo').classList.remove('hidden');
        
        updateDeployButton();
        
        // Listen for account changes
        window.ethereum.on('accountsChanged', connectWallet);
        window.ethereum.on('chainChanged', () => window.location.reload());
        
    } catch (error) {
        showMessage('Failed to connect wallet', 'error');
    }
}

// Compile project
async function compileProject() {
    if (!selectedProject) {
        showMessage('Please select a project first', 'error');
        return;
    }
    
    showMessage('Checking dependencies...', 'info');
    
    try {
        const response = await fetch(`/api/projects/${selectedProject}/compile`, {
            method: 'POST'
        });
        
        // Handle streaming response for installation progress
        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let buffer = '';
        
        while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            
            buffer += decoder.decode(value, { stream: true });
            const lines = buffer.split('\n');
            buffer = lines.pop() || '';
            
            for (const line of lines) {
                if (line.trim()) {
                    try {
                        const message = JSON.parse(line);
                        if (message.status === 'installing') {
                            showMessage('Installing dependencies... This may take a minute.', 'info');
                        } else if (message.status === 'installed') {
                            showMessage('Dependencies installed!', 'success');
                            await loadProjectStatus();
                        }
                    } catch {
                        // Not JSON, might be final response
                    }
                }
            }
        }
        
        // Parse final response
        if (buffer.trim()) {
            try {
                const data = JSON.parse(buffer);
                if (data.success) {
                    showMessage('Compilation successful!', 'success');
                    // 少し待ってからステータスを更新（ファイルシステムの遅延対策）
                    setTimeout(async () => {
                        await loadContracts();
                        await loadProjectStatus();
                    }, 500);
                } else {
                    showMessage(`Compilation failed: ${data.error}`, 'error');
                }
            } catch (parseError) {
                console.error('Failed to parse response:', buffer);
                // それでもコンパイルは成功している可能性があるので、ステータスを更新
                setTimeout(async () => {
                    await loadContracts();
                    await loadProjectStatus();
                }, 500);
            }
        }
    } catch (error) {
        if (error.name === 'TypeError' && error.message === 'Failed to fetch') {
            showMessage('サーバーに接続できません。サーバーが起動しているか確認してください。', 'error');
        } else if (error.name === 'TypeError' && error.message === 'network error') {
            showMessage('ネットワークエラーが発生しました。接続を確認してください。', 'error');
        } else {
            showMessage('Compilation failed: ' + error.message, 'error');
        }
        console.error(error);
    }
}

// Create new project
async function createNewProject() {
    const projectName = prompt('Enter new project name:');
    
    if (!projectName) return;
    
    // Validate project name (alphanumeric, hyphens, underscores)
    if (!projectName.match(/^[a-zA-Z0-9_-]+$/)) {
        showMessage('Invalid project name. Use only letters, numbers, hyphens, and underscores.', 'error');
        return;
    }
    
    try {
        showMessage('Creating new project...', 'info');
        
        const response = await fetch('/api/projects/create', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ projectName })
        });
        
        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        
        while (true) {
            const { done, value } = await reader.read();
            if (done) break;
            
            const chunk = decoder.decode(value);
            const lines = chunk.trim().split('\n');
            
            for (const line of lines) {
                if (line) {
                    try {
                        const data = JSON.parse(line);
                        if (data.status) {
                            showMessage(data.message, 'info');
                        } else if (data.success) {
                            showMessage(data.message, 'success');
                            // Reload projects and select the new one
                            await loadProjects();
                            document.getElementById('projectSelect').value = projectName;
                            await onProjectChange({ target: { value: projectName } });
                        } else if (data.error) {
                            showMessage(data.error, 'error');
                        }
                    } catch (e) {
                        console.error('Failed to parse:', line);
                    }
                }
            }
        }
        
    } catch (error) {
        console.error(error);
        showMessage('Failed to create project: ' + error.message, 'error');
    }
}

// Deploy contract
async function deployContract() {
    if (!selectedContract || !signer) return;
    
    try {
        // Check if ethers is loaded
        console.log('ethers object:', typeof ethers !== 'undefined' ? 'loaded' : 'not loaded');
        if (typeof ethers !== 'undefined') {
            console.log('ethers.ContractFactory:', ethers.ContractFactory);
        }
        
        showMessage('Preparing deployment...', 'info');
        
        const contract = contracts[selectedContract];
        
        // Validate constructor params before proceeding
        let constructorParams;
        try {
            constructorParams = getConstructorParams();
            
            // Additional validation against ABI
            const constructor = contract.abi.find(item => item.type === 'constructor');
            if (constructor && constructor.inputs.length !== constructorParams.length) {
                throw new Error(`Expected ${constructor.inputs.length} parameters, got ${constructorParams.length}`);
            }
        } catch (error) {
            showMessage(`Parameter validation failed: ${error.message}`, 'error');
            return;
        }
        
        const response = await fetch(`/api/projects/${selectedProject}/deploy`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                contractName: selectedContract,
                constructorArgs: constructorParams
            })
        });
        
        const data = await response.json();
        
        if (!data.success) {
            showMessage(`Deploy preparation failed: ${data.error}`, 'error');
            return;
        }
        
        // Validate bytecode
        if (!data.bytecode || data.bytecode === '0x') {
            showMessage('Contract bytecode not found. Please compile the project first.', 'error');
            return;
        }
        
        // Create contract factory
        console.log('Creating contract factory...');
        console.log('ABI:', contract.abi);
        console.log('Bytecode length:', data.bytecode?.length);
        console.log('Signer:', signer);
        
        const factory = new ethers.ContractFactory(
            contract.abi,
            data.bytecode,
            signer
        );
        
        console.log('Factory created:', factory);
        console.log('Factory.deploy method:', factory.deploy);
        console.log('Constructor params:', constructorParams);
        
        // Estimate gas
        showMessage('Estimating gas...', 'info');
        let gasEstimate;
        try {
            console.log('Attempting gas estimation...');
            console.log('factory.estimateGas:', factory.estimateGas);
            
            // ethers v5 uses getDeployTransaction for gas estimation
            const deployTransaction = factory.getDeployTransaction(...constructorParams);
            gasEstimate = await provider.estimateGas(deployTransaction);
            
            const gasPrice = await provider.getGasPrice();
            const estimatedCost = gasEstimate.mul(gasPrice);
            
            // Show gas estimation dialog
            const confirmDeploy = await showGasEstimateDialog({
                gasLimit: gasEstimate.toString(),
                gasPrice: ethers.utils.formatUnits(gasPrice, 'gwei'),
                estimatedCost: ethers.utils.formatEther(estimatedCost),
                network: await provider.getNetwork()
            });
            
            if (!confirmDeploy) {
                showMessage('Deployment cancelled', 'info');
                return;
            }
        } catch (error) {
            showMessage(`Gas estimation failed: ${error.message}`, 'error');
            return;
        }
        
        // Deploy with gas limit
        showMessage('Deploying contract...', 'info');
        const deployTx = await factory.deploy(...constructorParams, {
            gasLimit: gasEstimate.mul(110).div(100) // 10% buffer
        });
        showMessage('Transaction sent. Waiting for confirmation...', 'info');
        
        const deployed = await deployTx.deployed();
        
        // Show results
        showDeployResults({
            contractName: selectedContract,
            address: deployed.address,
            transactionHash: deployTx.deployTransaction.hash,
            abi: contract.abi,
            gasUsed: deployTx.deployTransaction.gasLimit.toString()
        });
        
        showMessage('Contract deployed successfully!', 'success');
        
        // Store deployed contract instance for interaction
        deployedContract = new ethers.Contract(deployed.address, contract.abi, signer);
        
        // Show interaction section
        setTimeout(() => {
            showContractInteraction(selectedContract, deployed.address, contract.abi);
        }, 2000);
        
    } catch (error) {
        console.error(error);
        showMessage(`Deploy failed: ${error.message}`, 'error');
    }
}

// Validate input based on type
function validateInput(index, type) {
    const input = document.getElementById(`param-${index}`);
    const errorSpan = document.getElementById(`error-${index}`);
    const value = input.value.trim();
    
    let isValid = true;
    let errorMessage = '';
    
    if (type === 'address') {
        if (!value.match(/^0x[a-fA-F0-9]{40}$/)) {
            isValid = false;
            errorMessage = 'Invalid Ethereum address';
        }
    } else if (type.includes('uint')) {
        if (!value.match(/^\d+$/) || parseInt(value) < 0) {
            isValid = false;
            errorMessage = 'Must be a positive number';
        }
    } else if (type.includes('int')) {
        if (!value.match(/^-?\d+$/)) {
            isValid = false;
            errorMessage = 'Must be a valid integer';
        }
    } else if (type.includes('bytes32')) {
        if (!value.match(/^0x[a-fA-F0-9]{64}$/)) {
            isValid = false;
            errorMessage = 'Must be 32 bytes hex string';
        }
    }
    
    if (!isValid) {
        input.classList.add('border-red-500');
        errorSpan.textContent = errorMessage;
        errorSpan.classList.remove('hidden');
    } else {
        input.classList.remove('border-red-500');
        errorSpan.classList.add('hidden');
    }
    
    return isValid;
}

// Get constructor parameters from inputs with validation
function getConstructorParams() {
    const params = [];
    const inputs = document.querySelectorAll('[id^="param-"]');
    
    inputs.forEach(input => {
        const value = input.value.trim();
        const type = input.getAttribute('data-type');
        
        try {
            // Type-specific parsing
            if (type === 'bool') {
                params.push(value === 'true');
            } else if (type.includes('uint') || type.includes('int')) {
                // Handle big numbers
                if (type.includes('256')) {
                    params.push(ethers.BigNumber.from(value));
                } else {
                    params.push(parseInt(value));
                }
            } else if (type === 'address') {
                // Validate and checksum address
                params.push(ethers.utils.getAddress(value));
            } else if (type.includes('[]')) {
                // Handle arrays
                const arrayValues = value.split(',').map(v => v.trim());
                if (type.includes('address[]')) {
                    params.push(arrayValues.map(addr => ethers.utils.getAddress(addr)));
                } else if (type.includes('uint') || type.includes('int')) {
                    params.push(arrayValues.map(v => 
                        type.includes('256') ? ethers.BigNumber.from(v) : parseInt(v)
                    ));
                } else {
                    params.push(arrayValues);
                }
            } else if (type.includes('bytes')) {
                // Ensure proper hex formatting
                params.push(value.startsWith('0x') ? value : '0x' + value);
            } else {
                // Default: string types
                params.push(value);
            }
        } catch (error) {
            throw new Error(`Invalid value for ${type}: ${error.message}`);
        }
    });
    
    return params;
}

// Show deployment results
function showDeployResults(result) {
    const resultsSection = document.getElementById('resultsSection');
    const resultsContainer = document.getElementById('deployResults');
    
    resultsContainer.innerHTML = `
        <div class="bg-green-50 border border-green-200 rounded p-4">
            <p class="font-semibold text-green-800">✅ Deployment Successful!</p>
            <p class="mt-2"><strong>Contract:</strong> ${result.contractName}</p>
            <p><strong>Address:</strong> 
                <span class="font-mono text-sm">${result.address}</span>
                <button onclick="copyToClipboard('${result.address}')" class="ml-2 text-blue-500 hover:text-blue-700">
                    [Copy]
                </button>
            </p>
            <p><strong>Transaction Hash:</strong> 
                <span class="font-mono text-sm">${result.transactionHash}</span>
            </p>
            <div class="mt-3">
                <p><strong>ABI:</strong></p>
                <div class="mt-1 space-x-2">
                    <button onclick="showABI('${result.contractName}')" class="text-blue-500 hover:text-blue-700">
                        [Show]
                    </button>
                    <button onclick="downloadABI('${result.contractName}')" class="text-blue-500 hover:text-blue-700">
                        [Download]
                    </button>
                    <button onclick="copyABI('${result.contractName}')" class="text-blue-500 hover:text-blue-700">
                        [Copy]
                    </button>
                </div>
            </div>
        </div>
    `;
    
    resultsSection.classList.remove('hidden');
}

// Update deploy button state
function updateDeployButton() {
    const button = document.getElementById('deployBtn');
    button.disabled = !selectedContract || !signer;
}

// Show message
function showMessage(message, type = 'info') {
    const container = document.getElementById('messageContainer');
    const div = document.createElement('div');
    
    const colors = {
        info: 'bg-blue-500',
        success: 'bg-green-500',
        error: 'bg-red-500'
    };
    
    div.className = `${colors[type]} text-white px-4 py-3 rounded shadow-lg mb-2`;
    div.textContent = message;
    
    container.appendChild(div);
    
    setTimeout(() => {
        div.remove();
    }, 5000);
}

// Utility functions
function copyToClipboard(text) {
    navigator.clipboard.writeText(text);
    showMessage('Copied to clipboard!', 'success');
}

function copyABI(contractName) {
    const abi = JSON.stringify(contracts[contractName].abi, null, 2);
    copyToClipboard(abi);
}

function downloadABI(contractName) {
    const abi = JSON.stringify(contracts[contractName].abi, null, 2);
    const blob = new Blob([abi], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `${contractName}_ABI.json`;
    a.click();
    URL.revokeObjectURL(url);
}

function showABI(contractName) {
    const abi = JSON.stringify(contracts[contractName].abi, null, 2);
    alert(`ABI for ${contractName}:\n\n${abi}`);
}

// Show gas estimate dialog
function showGasEstimateDialog(gasInfo) {
    return new Promise((resolve) => {
        const dialog = document.createElement('div');
        dialog.className = 'fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50';
        dialog.innerHTML = `
            <div class="bg-white rounded-lg p-6 max-w-md">
                <h3 class="text-lg font-semibold mb-4">⛽ Gas Estimation</h3>
                <div class="space-y-2 mb-4">
                    <p><strong>Network:</strong> ${gasInfo.network.name || `Chain ID: ${gasInfo.network.chainId}`}</p>
                    <p><strong>Gas Limit:</strong> ${parseInt(gasInfo.gasLimit).toLocaleString()}</p>
                    <p><strong>Gas Price:</strong> ${gasInfo.gasPrice} Gwei</p>
                    <p class="text-lg"><strong>Estimated Cost:</strong> ${gasInfo.estimatedCost} ETH</p>
                    ${gasInfo.network.chainId === 1 ? '<p class="text-red-500 text-sm">⚠️ This is Mainnet! Real ETH will be spent.</p>' : ''}
                </div>
                <div class="flex space-x-3">
                    <button onclick="resolveGasDialog(false)" class="flex-1 bg-gray-300 text-gray-700 px-4 py-2 rounded hover:bg-gray-400">
                        Cancel
                    </button>
                    <button onclick="resolveGasDialog(true)" class="flex-1 bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600">
                        Deploy
                    </button>
                </div>
            </div>
        `;
        
        window.resolveGasDialog = (value) => {
            document.body.removeChild(dialog);
            resolve(value);
        };
        
        document.body.appendChild(dialog);
    });
}

// Show contract interaction interface
function showContractInteraction(contractName, address, abi) {
    document.getElementById('interactContractName').textContent = contractName;
    document.getElementById('interactContractAddress').textContent = address;
    
    // Populate read and write functions
    populateFunctions(abi);
    
    // Show interaction section
    document.getElementById('interactionSection').classList.remove('hidden');
    
    // Switch to read tab by default
    switchTab('read');
}

// Populate contract functions
function populateFunctions(abi) {
    const readContainer = document.getElementById('readFunctions');
    const writeContainer = document.getElementById('writeFunctions');
    
    readContainer.innerHTML = '';
    writeContainer.innerHTML = '';
    
    abi.forEach((item, index) => {
        if (item.type === 'function') {
            const functionDiv = createFunctionUI(item, index);
            
            if (item.stateMutability === 'view' || item.stateMutability === 'pure') {
                readContainer.appendChild(functionDiv);
            } else {
                writeContainer.appendChild(functionDiv);
            }
        }
    });
    
    // Show message if no functions
    if (readContainer.innerHTML === '') {
        readContainer.innerHTML = '<p class="text-gray-500">No read functions available</p>';
    }
    if (writeContainer.innerHTML === '') {
        writeContainer.innerHTML = '<p class="text-gray-500">No write functions available</p>';
    }
}

// Create function UI
function createFunctionUI(func, index) {
    const div = document.createElement('div');
    div.className = 'border rounded p-4 bg-gray-50';
    
    let inputsHtml = '';
    if (func.inputs && func.inputs.length > 0) {
        inputsHtml = func.inputs.map((input, i) => `
            <div class="mt-2">
                <label class="text-sm font-medium">${input.name || 'param' + i} (${input.type})</label>
                <input type="text" 
                       id="func-${index}-input-${i}" 
                       class="w-full border rounded px-3 py-2 mt-1"
                       placeholder="Enter ${input.type}">
            </div>
        `).join('');
    }
    
    const isReadFunction = func.stateMutability === 'view' || func.stateMutability === 'pure';
    const buttonText = isReadFunction ? 'Query' : 'Execute';
    const buttonClass = isReadFunction ? 'bg-blue-500 hover:bg-blue-600' : 'bg-orange-500 hover:bg-orange-600';
    
    div.innerHTML = `
        <div class="flex justify-between items-start mb-2">
            <h4 class="font-semibold">${func.name}</h4>
            ${!isReadFunction ? '<span class="text-xs bg-orange-100 text-orange-700 px-2 py-1 rounded">Payable</span>' : ''}
        </div>
        ${inputsHtml}
        <button onclick="executeFunction(${index}, ${isReadFunction})" 
                class="${buttonClass} text-white px-4 py-2 rounded mt-3">
            ${buttonText}
        </button>
        <div id="func-${index}-result" class="mt-3 hidden"></div>
    `;
    
    return div;
}

// Execute contract function
async function executeFunction(funcIndex, isReadFunction) {
    if (!deployedContract) {
        showMessage('No contract instance available', 'error');
        return;
    }
    
    const abi = deployedContract.interface.fragments;
    const func = abi[funcIndex];
    
    // Collect input values
    const inputs = [];
    if (func.inputs && func.inputs.length > 0) {
        for (let i = 0; i < func.inputs.length; i++) {
            const inputElement = document.getElementById(`func-${funcIndex}-input-${i}`);
            const value = inputElement.value.trim();
            
            if (!value) {
                showMessage(`Please provide value for ${func.inputs[i].name || 'parameter ' + i}`, 'error');
                return;
            }
            
            // Parse value based on type
            try {
                inputs.push(parseInputValue(value, func.inputs[i].type));
            } catch (error) {
                showMessage(`Invalid input for ${func.inputs[i].name}: ${error.message}`, 'error');
                return;
            }
        }
    }
    
    try {
        let result;
        
        if (isReadFunction) {
            // Call read function
            result = await deployedContract[func.name](...inputs);
            
            // Display result
            const resultDiv = document.getElementById(`func-${funcIndex}-result`);
            resultDiv.innerHTML = `
                <div class="bg-green-50 border border-green-200 rounded p-3">
                    <p class="text-sm font-semibold text-green-800">Result:</p>
                    <p class="font-mono text-sm mt-1">${formatResult(result)}</p>
                </div>
            `;
            resultDiv.classList.remove('hidden');
        } else {
            // Execute write function
            showMessage('Sending transaction...', 'info');
            const tx = await deployedContract[func.name](...inputs);
            
            showMessage('Transaction sent. Waiting for confirmation...', 'info');
            const receipt = await tx.wait();
            
            // Display result
            const resultDiv = document.getElementById(`func-${funcIndex}-result`);
            resultDiv.innerHTML = `
                <div class="bg-green-50 border border-green-200 rounded p-3">
                    <p class="text-sm font-semibold text-green-800">Transaction Successful!</p>
                    <p class="text-sm mt-1">Hash: <span class="font-mono">${receipt.transactionHash}</span></p>
                    <p class="text-sm">Gas Used: ${receipt.gasUsed.toString()}</p>
                </div>
            `;
            resultDiv.classList.remove('hidden');
            
            showMessage('Transaction confirmed!', 'success');
            
            // Refresh events if on events tab
            if (!document.getElementById('eventsSection').classList.contains('hidden')) {
                await refreshEvents();
            }
        }
    } catch (error) {
        console.error(error);
        showMessage(`Function call failed: ${error.message}`, 'error');
    }
}

// Parse input value based on type
function parseInputValue(value, type) {
    if (type === 'address') {
        if (!ethers.utils.isAddress(value)) {
            throw new Error('Invalid address');
        }
        return value;
    } else if (type.startsWith('uint') || type.startsWith('int')) {
        return ethers.BigNumber.from(value);
    } else if (type === 'bool') {
        return value.toLowerCase() === 'true';
    } else if (type.startsWith('bytes')) {
        return value.startsWith('0x') ? value : '0x' + value;
    } else if (type.includes('[]')) {
        return value.split(',').map(v => parseInputValue(v.trim(), type.replace('[]', '')));
    }
    return value;
}

// Format result for display
function formatResult(result) {
    if (result === null || result === undefined) {
        return 'null';
    } else if (ethers.BigNumber.isBigNumber(result)) {
        return result.toString();
    } else if (typeof result === 'object') {
        return JSON.stringify(result, null, 2);
    }
    return result.toString();
}

// Switch between tabs
function switchTab(tab) {
    // Update tab styles
    const tabs = ['read', 'write', 'events'];
    tabs.forEach(t => {
        const tabButton = document.getElementById(`${t}Tab`);
        if (t === tab) {
            tabButton.className = 'px-4 py-2 font-semibold text-blue-600 border-b-2 border-blue-600';
        } else {
            tabButton.className = 'px-4 py-2 font-semibold text-gray-600 hover:text-gray-800';
        }
    });
    
    // Show/hide content
    document.getElementById('readFunctions').classList.toggle('hidden', tab !== 'read');
    document.getElementById('writeFunctions').classList.toggle('hidden', tab !== 'write');
    document.getElementById('eventsSection').classList.toggle('hidden', tab !== 'events');
    
    // Load events when switching to events tab
    if (tab === 'events' && deployedContract) {
        refreshEvents();
    }
}

// Refresh event logs
async function refreshEvents() {
    if (!deployedContract) {
        showMessage('No contract instance available', 'error');
        return;
    }
    
    const eventLogsContainer = document.getElementById('eventLogs');
    eventLogsContainer.innerHTML = '<p class="text-gray-500">Loading events...</p>';
    
    try {
        // Get all events from the contract
        const filter = deployedContract.filters;
        const events = await deployedContract.queryFilter(filter);
        
        if (events.length === 0) {
            eventLogsContainer.innerHTML = '<p class="text-gray-500">No events found</p>';
            return;
        }
        
        // Display events
        eventLogsContainer.innerHTML = events.map((event, index) => `
            <div class="border rounded p-3 bg-gray-50">
                <div class="flex justify-between items-start mb-2">
                    <h5 class="font-semibold">${event.event}</h5>
                    <span class="text-xs text-gray-500">Block #${event.blockNumber}</span>
                </div>
                <div class="text-sm space-y-1">
                    ${Object.entries(event.args || {})
                        .filter(([key]) => isNaN(key)) // Filter out numeric keys
                        .map(([key, value]) => `
                            <p><span class="font-medium">${key}:</span> ${formatResult(value)}</p>
                        `).join('')}
                </div>
                <p class="text-xs text-gray-500 mt-2">Tx: ${event.transactionHash.substring(0, 10)}...</p>
            </div>
        `).join('');
        
    } catch (error) {
        console.error(error);
        eventLogsContainer.innerHTML = `<p class="text-red-500">Failed to load events: ${error.message}</p>`;
    }
}