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
        div.innerHTML = `
            <label class="block text-sm font-medium mb-1">${input.name} (${input.type})</label>
            <input type="text" id="param-${index}" 
                   class="w-full border rounded px-3 py-2" 
                   placeholder="Enter ${input.type}">
        `;
        container.appendChild(div);
    });
    
    document.getElementById('constructorParams').classList.remove('hidden');
}

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
        
        // Update UI
        document.getElementById('accountAddress').textContent = address;
        document.getElementById('accountBalance').textContent = ethers.utils.formatEther(balance);
        document.getElementById('networkName').textContent = network.name || `Chain ID: ${network.chainId}`;
        
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
        showMessage('Deploying contract...', 'info');
        
        const contract = contracts[selectedContract];
        const constructorParams = getConstructorParams();
        
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
        
        // Deploy using MetaMask
        const factory = new ethers.ContractFactory(
            contract.abi,
            data.bytecode,
            signer
        );
        
        const deployTx = await factory.deploy(...constructorParams);
        showMessage('Transaction sent. Waiting for confirmation...', 'info');
        
        const deployed = await deployTx.deployed();
        
        // Show results
        showDeployResults({
            contractName: selectedContract,
            address: deployed.address,
            transactionHash: deployTx.deployTransaction.hash,
            abi: contract.abi
        });
        
        showMessage('Contract deployed successfully!', 'success');
        
    } catch (error) {
        console.error(error);
        showMessage(`Deploy failed: ${error.message}`, 'error');
    }
}

// Get constructor parameters from inputs
function getConstructorParams() {
    const params = [];
    const inputs = document.querySelectorAll('[id^="param-"]');
    
    inputs.forEach(input => {
        const value = input.value.trim();
        // Simple type conversion (expand as needed)
        if (value.match(/^\d+$/)) {
            params.push(parseInt(value));
        } else {
            params.push(value);
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