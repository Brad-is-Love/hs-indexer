module ContractType = {
  @genType
  type t = 
    | @as("SweepStakesNFTs") SweepStakesNFTs

  let name = "CONTRACT_TYPE"
  let variants = [
    SweepStakesNFTs,
  ]
  let enum = Enum.make(~name, ~variants)
}

module EntityType = {
  @genType
  type t = 
    | @as("ContractTotals") ContractTotals
    | @as("SweepStakesNFTs_Enter") SweepStakesNFTs_Enter
    | @as("SweepStakesNFTs_Transfer") SweepStakesNFTs_Transfer
    | @as("SweepStakesNFTs_Unstake") SweepStakesNFTs_Unstake
    | @as("SweepStakesNFTs_WinnerAssigned") SweepStakesNFTs_WinnerAssigned
    | @as("SweepStakesNFTs_Withdraw") SweepStakesNFTs_Withdraw
    | @as("Token") Token
    | @as("User") User
    | @as("dynamic_contract_registry") DynamicContractRegistry

  let name = "ENTITY_TYPE"
  let variants = [
    ContractTotals,
    SweepStakesNFTs_Enter,
    SweepStakesNFTs_Transfer,
    SweepStakesNFTs_Unstake,
    SweepStakesNFTs_WinnerAssigned,
    SweepStakesNFTs_Withdraw,
    Token,
    User,
    DynamicContractRegistry,
  ]

  let enum = Enum.make(~name, ~variants)
}

let allEnums: array<module(Enum.S)> = [
  module(EntityHistory.RowAction),
  module(ContractType), 
  module(EntityType),
]
