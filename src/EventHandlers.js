/*
 *Please refer to https://docs.envio.dev for a thorough guide on all Envio indexer features*
 */

let { SweepStakesNFTsContract } = require("../generated/src/Handlers.bs.js");

SweepStakesNFTsContract.Transfer.loader((event, context) => {
  const tokenId = event.params.tokenId.toString();
  context.Token.tokenLoad(tokenId);
  context.User.load(event.params.to);
});

SweepStakesNFTsContract.Transfer.handler((event, context) => {
  //This event handles token transfers. We're not assigning value just sending the token to the new user so we have a mapping of token -> user
  const tokenId = event.params.tokenId.toString();
  const newOwner = event.params.to;
  const tokenEntity = context.Token.get(tokenId);
  const userEntity = context.User.get(newOwner);

  let tokenData = {};
  if (tokenEntity != undefined) {
    tokenData = {
      id: tokenId,
      user: newOwner,
      userAddress: newOwner,
      totalStakes: tokenEntity.totalStakes ?? BigInt(0),
      totalPrizes: tokenEntity.totalPrizes ?? BigInt(0),
      balance: tokenEntity.balance ?? BigInt(0),
    };
  } else {
    tokenData = {
      id: tokenId,
      user: newOwner,
      userAddress: newOwner,
      totalStakes: BigInt(0),
      totalPrizes: BigInt(0),
      balance: BigInt(0),
    };
  }

  const sweepStakesNFTs_TransferEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    from: event.params.from,
    to: event.params.to,
    tokenId: event.params.tokenId,
  };

  context.Token.set(tokenData);

  // set the user who received the token
  if (userEntity != undefined) {
    context.User.set({
      id: newOwner,
      totalPrizes: userEntity.totalPrizes,
      totalStakes: userEntity.totalStakes,
      balance: userEntity.balance,
    });
  } else {
    context.User.set({
      id: newOwner,
      totalPrizes: BigInt(0),
      totalStakes: BigInt(0),
      balance: BigInt(0),
    });
  }

  context.SweepStakesNFTs_Transfer.set(sweepStakesNFTs_TransferEntity);
});

SweepStakesNFTsContract.Enter.loader((event, context) => {
  const tokenId = event.params._tokenId.toString();
  context.Token.tokenLoad(tokenId, { loadUser: {} },);
  const contractName = "SweepStakes";
  context.ContractTotals.load(contractName);
});

SweepStakesNFTsContract.Enter.handler((event, context) => {
  const tokenId = event.params._tokenId.toString();
  const tokenEntity = context.Token.token;
  const contractName = "SweepStakes";
  const contractTotals = context.ContractTotals.get(contractName);
  const userAddress = tokenEntity.userAddress;
  const userEntity = context.Token.getUser(context.Token.token);

  const sweepStakesNFTs_EnterEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
    userAddress: tokenEntity.userAddress,
  };

  if (tokenEntity != undefined) {
    context.Token.set({
      id: tokenId,
      user: tokenEntity.userAddress,
      userAddress: tokenEntity.userAddress,
      totalStakes: tokenEntity.totalStakes + event.params._amount,
      totalPrizes: tokenEntity.totalPrizes,
      balance: tokenEntity.balance + event.params._amount,
    });
  } else {
    context.Token.set({
      id: tokenId,
      user: tokenEntity.userAddress,
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

  if (userEntity != undefined) {
    context.User.set({
      id: userEntity.id,
      totalPrizes: userEntity.totalPrizes,
      totalStakes: userEntity.totalStakes + event.params._amount,
      balance: userEntity.balance + event.params._amount,
    });
  } else {
    context.User.set({
      id: userAddress,
      totalPrizes: BigInt(0),
      totalStakes: event.params._amount,
      balance: event.params._amount,
    });
  }

  context.SweepStakesNFTs_Enter.set(sweepStakesNFTs_EnterEntity);
});

SweepStakesNFTsContract.Unstake.loader((event, context) => {
  const tokenId = event.params._tokenId.toString();
  context.Token.tokenLoad(tokenId, { loadUser: {} });
  const contractName = "SweepStakes";
  context.ContractTotals.load(contractName);
});

SweepStakesNFTsContract.Unstake.handler((event, context) => {
  const tokenId = event.params._tokenId.toString();
  const tokenEntity = context.Token.token;
  const contractName = "SweepStakes";
  const contractTotals = context.ContractTotals.get(contractName);
  const userAddress = tokenEntity.userAddress;
  const userEntity = context.Token.getUser(context.Token.token);

  const sweepStakesNFTs_UnstakeEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
    userAddress: tokenEntity.userAddress,
  };

  if (tokenEntity != undefined) {
    context.Token.set({
      id: tokenId,
      user: tokenEntity.userAddress,
      userAddress: tokenEntity.userAddress,
      totalStakes: tokenEntity.totalStakes - event.params._amount,
      totalPrizes: tokenEntity.totalPrizes,
      balance: tokenEntity.balance - event.params._amount,
    });
  } else {
    context.Token.set({
      id: tokenId,
      user: tokenEntity.userAddress,
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

  if (userEntity != undefined) {
    context.User.set({
      id: userEntity.id,
      totalPrizes: userEntity.totalPrizes,
      totalStakes: userEntity.totalStakes - event.params._amount,
      balance: userEntity.balance - event.params._amount,
    });
  } else {
    context.User.set({
      id: userAddress,
      totalPrizes: BigInt(0),
      totalStakes: BigInt(0),
      balance: BigInt(0),
    });
  }

  context.SweepStakesNFTs_Unstake.set(sweepStakesNFTs_UnstakeEntity);
});

SweepStakesNFTsContract.WinnerAssigned.loader((event, context) => {
  const tokenId = event.params._winner.toString();
  context.Token.tokenLoad(tokenId, { loadUser: {} });
  const contractName = "SweepStakes";
  context.ContractTotals.load(contractName);
});

SweepStakesNFTsContract.WinnerAssigned.handler((event, context) => {
  const tokenId = event.params._winner.toString();
  const tokenEntity = context.Token.token;
  const contractName = "SweepStakes";
  const contractTotals = context.ContractTotals.get(contractName);
  const userAddress = tokenEntity.userAddress;
  const userEntity = context.Token.getUser(context.Token.token);

  const sweepStakesNFTs_WinnerAssignedEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    winningTicket: event.params.winningTicket,
    _winner: event.params._winner,
    _amount: event.params._amount,
    token: tokenId,
    timestamp: event.blockTimestamp,
    winnerAddress: userEntity.id,
    winnerBalance: userEntity.balance,
    totalBalance: contractTotals.balance,
  };

  if (tokenEntity != undefined) {
    context.Token.set({
      id: tokenId,
      user: tokenEntity.userAddress,
      userAddress: tokenEntity.userAddress,
      totalStakes: tokenEntity.totalStakes,
      totalPrizes: tokenEntity.totalPrizes + event.params._amount,
      balance: tokenEntity.balance + event.params._amount,
    });
  } else {
    context.Token.set({
      id: tokenId,
      user: tokenEntity.userAddress,
      userAddress: tokenEntity.userAddress,
      totalStakes: BigInt(0),
      totalPrizes: event.params._amount,
      balance: event.params._amount,
    });
  }

  if (userEntity != undefined) {
    context.User.set({
      id: userEntity.id,
      totalPrizes: userEntity.totalPrizes + event.params._amount,
      totalStakes: userEntity.totalStakes,
      balance: userEntity.balance + event.params._amount,
    });
  } else {
    context.User.set({
      id: userAddress,
      totalPrizes: event.params._amount,
      totalStakes: BigInt(0),
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
