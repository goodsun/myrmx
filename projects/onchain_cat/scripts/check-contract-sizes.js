const fs = require('fs');
const path = require('path');

// Ethereum contract size limit
const CONTRACT_SIZE_LIMIT = 24576; // 24KB in bytes

function checkContractSizes() {
  const artifactsPath = path.join(__dirname, '../artifacts/contracts');
  const results = [];
  
  // Bank contracts to check
  const bankContracts = [
    'banks/BackBank1.sol/BackBank1.json',
    'banks/BackBank2.sol/BackBank2.json',
    'banks/BackBank3.sol/BackBank3.json',
    'banks/MainBank1.sol/MainBank1.json',
    'banks/MainBank2.sol/MainBank2.json',
    'banks/ItemBank1.sol/ItemBank1.json',
    'banks/ItemBank2.sol/ItemBank2.json',
    'banks/FrontBank1.sol/FrontBank1.json',
    'banks/FrontBank2.sol/FrontBank2.json',
  ];
  
  console.log('Checking contract sizes...\n');
  console.log(`Contract size limit: ${CONTRACT_SIZE_LIMIT} bytes (24KB)\n`);
  
  bankContracts.forEach(contractPath => {
    const fullPath = path.join(artifactsPath, contractPath);
    
    if (fs.existsSync(fullPath)) {
      const artifact = JSON.parse(fs.readFileSync(fullPath, 'utf8'));
      const bytecode = artifact.bytecode;
      
      // Remove '0x' prefix and calculate size
      const bytecodeWithoutPrefix = bytecode.startsWith('0x') ? bytecode.slice(2) : bytecode;
      const sizeInBytes = bytecodeWithoutPrefix.length / 2;
      const sizeInKB = (sizeInBytes / 1024).toFixed(2);
      
      const contractName = path.basename(contractPath, '.json');
      const isOverLimit = sizeInBytes > CONTRACT_SIZE_LIMIT;
      
      results.push({
        name: contractName,
        sizeInBytes,
        sizeInKB,
        isOverLimit,
        percentOfLimit: ((sizeInBytes / CONTRACT_SIZE_LIMIT) * 100).toFixed(1)
      });
      
      console.log(`${contractName}:`);
      console.log(`  Size: ${sizeInBytes} bytes (${sizeInKB} KB)`);
      console.log(`  ${isOverLimit ? '❌ OVER LIMIT' : '✅ Within limit'} (${results[results.length - 1].percentOfLimit}% of limit)`);
      
      if (isOverLimit) {
        console.log(`  Exceeds by: ${sizeInBytes - CONTRACT_SIZE_LIMIT} bytes`);
      }
      console.log('');
    }
  });
  
  // Summary
  console.log('\n=== SUMMARY ===');
  const overLimitContracts = results.filter(r => r.isOverLimit);
  
  if (overLimitContracts.length > 0) {
    console.log(`\n⚠️  ${overLimitContracts.length} contracts exceed the size limit:`);
    overLimitContracts.forEach(contract => {
      console.log(`   - ${contract.name}: ${contract.sizeInKB} KB (${contract.percentOfLimit}% of limit)`);
    });
    
    console.log('\n💡 Solutions:');
    console.log('1. Split large SVG data into multiple contracts');
    console.log('2. Use more aggressive optimization settings');
    console.log('3. Store SVG data off-chain (IPFS/Arweave)');
    console.log('4. Compress SVG data further');
  } else {
    console.log('✅ All contracts are within the size limit!');
  }
  
  // Find the largest contracts
  const sortedResults = [...results].sort((a, b) => b.sizeInBytes - a.sizeInBytes);
  console.log('\n📊 Largest contracts:');
  sortedResults.slice(0, 5).forEach((contract, index) => {
    console.log(`${index + 1}. ${contract.name}: ${contract.sizeInKB} KB`);
  });
}

// Run the check
checkContractSizes();