  @genType
module SweepStakesNFTs = {
  module Enter = Types.MakeRegister(Types.SweepStakesNFTs.Enter)
  module Transfer = Types.MakeRegister(Types.SweepStakesNFTs.Transfer)
  module Unstake = Types.MakeRegister(Types.SweepStakesNFTs.Unstake)
  module WinnerAssigned = Types.MakeRegister(Types.SweepStakesNFTs.WinnerAssigned)
  module Withdraw = Types.MakeRegister(Types.SweepStakesNFTs.Withdraw)
}

