// Main application logic
let provider;
let signer;
let selectedProject = '';
let selectedContract = '';
let contracts = {};

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

// Handle project selection change
async function onProjectChange(event) {
    selectedProject = event.target.value;
    
    if (selectedProject) {
        await loadContracts();
    } else {
        document.getElementById('contractsContainer').innerHTML = '<p class="text-gray-500">Select a project first</p>';
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
    1: { name: 'Ethereum Mainnet', color: 'text-red-600', warning: true },
    5: { name: 'Goerli Testnet', color: 'text-blue-600', warning: false },
    11155111: { name: 'Sepolia Testnet', color: 'text-blue-600', warning: false },
    137: { name: 'Polygon Mainnet', color: 'text-purple-600', warning: true },
    80001: { name: 'Mumbai Testnet', color: 'text-purple-600', warning: false },
    1337: { name: 'Localhost', color: 'text-green-600', warning: false },
    31337: { name: 'Hardhat', color: 'text-green-600', warning: false }
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
            warning: true 
        };
        
        // Update UI with network validation
        document.getElementById('accountAddress').textContent = address;
        document.getElementById('accountBalance').textContent = ethers.utils.formatEther(balance);
        
        const networkElement = document.getElementById('networkName');
        networkElement.textContent = networkInfo.name;
        networkElement.className = `font-semibold ${networkInfo.color}`;
        
        // Show warning for mainnet
        if (networkInfo.warning) {
            const warningDiv = document.createElement('div');
            warningDiv.className = 'mt-2 p-2 bg-red-50 border border-red-200 rounded text-sm text-red-600';
            warningDiv.innerHTML = '⚠️ Warning: You are connected to a mainnet. Real funds will be used!';
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
    
    showMessage('Compiling...', 'info');
    
    try {
        const response = await fetch(`/api/projects/${selectedProject}/compile`, {
            method: 'POST'
        });
        
        const data = await response.json();
        
        if (data.success) {
            showMessage('Compilation successful!', 'success');
            await loadContracts();
        } else {
            showMessage(`Compilation failed: ${data.error}`, 'error');
        }
    } catch (error) {
        showMessage('Compilation failed', 'error');
    }
}

// Deploy contract
async function deployContract() {
    if (!selectedContract || !signer) return;
    
    try {
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
        
        // Create contract factory
        const factory = new ethers.ContractFactory(
            contract.abi,
            data.bytecode,
            signer
        );
        
        // Estimate gas
        showMessage('Estimating gas...', 'info');
        let gasEstimate;
        try {
            gasEstimate = await factory.estimateGas.deploy(...constructorParams);
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