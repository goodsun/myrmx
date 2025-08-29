// Deploy configuration with gas settings
module.exports = {
  // デフォルトのガス設定
  defaultGasSettings: {
    gasLimit: 15000000, // 15M gas - 通常のコントラクト用
    gasPrice: "auto", // 自動設定
  },
  
  // 大きなコントラクト用の特別なガス設定
  largeContractGasSettings: {
    gasLimit: 25000000, // 25M gas - BackBankなど大きなコントラクト用
    gasPrice: "auto",
  },
  
  // 各コントラクトタイプ別の推奨ガス設定
  contractGasOverrides: {
    // Bankコントラクトは大きいので多めのガス
    "BackBank1": { gasLimit: 20000000 },
    "BackBank2": { gasLimit: 25000000 }, // 特に大きい
    "BackBank3": { gasLimit: 20000000 },
    "MainBank1": { gasLimit: 15000000 },
    "MainBank2": { gasLimit: 15000000 },
    "ItemBank1": { gasLimit: 15000000 },
    "ItemBank2": { gasLimit: 15000000 },
    "FrontBank1": { gasLimit: 15000000 },
    "FrontBank2": { gasLimit: 15000000 },
    
    // Aggregatorコントラクト
    "BackBank": { gasLimit: 8000000 },
    "MainBank": { gasLimit: 8000000 },
    "ItemBank": { gasLimit: 8000000 },
    "FrontBank": { gasLimit: 8000000 },
    
    // その他のコントラクト
    "CatComposer": { gasLimit: 10000000 },
    "CatMetadata": { gasLimit: 10000000 },
    "OnchainCats": { gasLimit: 10000000 },
  },
  
  // デプロイ時の待機設定
  confirmations: 1, // ローカルは1、本番は2-6推奨
  
  // タイムアウト設定
  timeout: 600000, // 10分
};