/*
 *Please refer to https://docs.envio.dev for a thorough guide on all Envio indexer features*
 */

let { SweepStakesNFTsContract } = require("../generated/src/Handlers.bs.js");

SweepStakesNFTsContract.Transfer.loader((event, context) => {
  const tokenId = event.params.tokenId.toString();
  context.Token.load(tokenId);
});

SweepStakesNFTsContract.Transfer.handler((event, context) => {
  const tokenId = event.params.tokenId.toString();
  const newOwner = event.params.to;
  const tokenEntity = context.Token.get(tokenId);

  const sweepStakesNFTs_TransferEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    from: event.params.from,
    to: event.params.to,
    tokenId: event.params.tokenId,
  };

  if (tokenEntity != undefined) {
    context.Token.set({
      id: tokenId,
      userAddress: newOwner,
      totalStakes: tokenEntity.totalStakes ?? BigInt(0), // NOTE, it is logically impossible for `tokenEntity.totalStakes` to be undefinedlStakes - default value for prudance.
      totalPrizes: tokenEntity.totalPrizes ?? BigInt(0),
      balance: tokenEntity.balance ?? BigInt(0),
    });
  } else {
    context.Token.set({
      id: tokenId,
      userAddress: newOwner,
      totalStakes: BigInt(0),
      totalPrizes: BigInt(0),
      balance: BigInt(0),
    });
  }

  context.SweepStakesNFTs_Transfer.set(sweepStakesNFTs_TransferEntity);
});

SweepStakesNFTsContract.Enter.loader((event, context) => {
  const tokenId = event.params._tokenId.toString();
  context.Token.load(tokenId);
  const contractName = 'SweepStakes'
  context.ContractTotals.load(contractName);
});

SweepStakesNFTsContract.Enter.handler((event, context) => {
  const tokenId = event.params._tokenId.toString();
  const tokenEntity = context.Token.get(tokenId);
  const contractName = 'SweepStakes'
  const contractTotals = context.ContractTotals.get(contractName);

  const sweepStakesNFTs_EnterEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
  };

  if (tokenEntity != undefined) {
    context.Token.set({
      id: tokenId,
      userAddress: tokenEntity.userAddress,
      totalStakes: tokenEntity.totalStakes + event.params._amount,
      totalPrizes: tokenEntity.totalPrizes,
      balance: tokenEntity.balance + event.params._amount,
    });
  } else {
    context.Token.set({
      id: tokenId,
      userAddress: tokenEntity.userAddress,
      totalStakes: event.params._amount,
      totalPrizes: BigInt(0),
      balance: event.params._amount,
    });
  }

  if (contractTotals != undefined) {
    context.ContractTotals.set({
      id: contractName,
      totalPrizes: contractTotals.totalPrizes,
      balance: contractTotals.balance + event.params._amount,
    });
  } else {
    context.ContractTotals.set({
      id: contractName,
      totalPrizes: BigInt(0),
      balance: event.params._amount,
    });
  }

  context.SweepStakesNFTs_Enter.set(sweepStakesNFTs_EnterEntity);
});


SweepStakesNFTsContract.Unstake.loader((event, context) => {
  const tokenId = event.params._tokenId.toString();
  context.Token.load(tokenId);
  const contractName = 'SweepStakes'
  context.ContractTotals.load(contractName);
});

SweepStakesNFTsContract.Unstake.handler((event, context) => {
  const tokenId = event.params._tokenId.toString();
  const tokenEntity = context.Token.get(tokenId);
  const contractName = 'SweepStakes'
  const contractTotals = context.ContractTotals.get(contractName);

  const sweepStakesNFTs_UnstakeEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
  };

  if (tokenEntity != undefined) {
    context.Token.set({
      id: tokenId,
      userAddress: tokenEntity.userAddress,
      totalStakes: tokenEntity.totalStakes - event.params._amount,
      totalPrizes: tokenEntity.totalPrizes,
      balance: tokenEntity.balance - event.params._amount,
    });
  } else {
    context.Token.set({
      id: tokenId,
      userAddress: tokenEntity.userAddress,
      totalStakes: BigInt(0),
      totalPrizes: BigInt(0),
      balance: BigInt(0),
    });
  }

  context.ContractTotals.set({
    id: contractName,
    totalPrizes: contractTotals.totalPrizes,
    balance: contractTotals.balance - event.params._amount,
  });

  context.SweepStakesNFTs_Unstake.set(sweepStakesNFTs_UnstakeEntity);
});

SweepStakesNFTsContract.WinnerAssigned.loader((event, context) => {
  const tokenId = event.params._winner.toString();
  context.Token.load(tokenId);
  const contractName = 'SweepStakes'
  context.ContractTotals.load(contractName);
});

SweepStakesNFTsContract.WinnerAssigned.handler((event, context) => {
  const tokenId = event.params._winner.toString();
  const tokenEntity = context.Token.get(tokenId);
  const contractName = 'SweepStakes'
  const contractTotals = context.ContractTotals.get(contractName);

  const sweepStakesNFTs_WinnerAssignedEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    winningTicket: event.params.winningTicket,
    _winner: event.params._winner.toString(),
    _amount: event.params._amount,
    token: tokenId,
    timestamp: event.blockTimestamp,
    winnerAddress: tokenEntity.userAddress,
    winnerBalance: tokenEntity.balance,
    totalBalance: contractTotals.balance,
  };

  if (tokenEntity != undefined) {
    context.Token.set({
      id: tokenId,
      userAddress: tokenEntity.userAddress,
      totalStakes: tokenEntity.totalStakes,
      totalPrizes: tokenEntity.totalPrizes + event.params._amount,
      balance: tokenEntity.balance + event.params._amount,
    });
  } else {
    context.Token.set({
      id: tokenId,
      userAddress: tokenEntity.userAddress,
      totalStakes: BigInt(0),
      totalPrizes: event.params._amount,
      balance: event.params._amount,
    });
  }

  context.ContractTotals.set({
    id: contractName,
    totalPrizes: contractTotals.totalPrizes + event.params._amount,
    balance: contractTotals.balance + event.params._amount,
  });


  context.SweepStakesNFTs_WinnerAssigned.set(
    sweepStakesNFTs_WinnerAssignedEntity
  );
});


