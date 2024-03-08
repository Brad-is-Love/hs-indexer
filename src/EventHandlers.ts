import {
  SweepStakesNFTsContract_Transfer_loader,
  SweepStakesNFTsContract_Transfer_handler,
  SweepStakesNFTsContract_Enter_loader,
  SweepStakesNFTsContract_Enter_handler,
  SweepStakesNFTsContract_WinnerAssigned_loader,
  SweepStakesNFTsContract_WinnerAssigned_handler,
  SweepStakesNFTsContract_Unstake_loader,
  SweepStakesNFTsContract_Unstake_handler,
} from "../generated/src/Handlers.gen";
import { sweepStakesNFTs_WinnerAssignedEntity } from "./src/Types.gen";

// TODO: move to a Constants file.
const CONTRACT_NAME = 'SweepStakes'

SweepStakesNFTsContract_Transfer_loader(({ event, context }) => {
  const tokenId = event.params.tokenId.toString();
  context.Token.load(tokenId);
});

SweepStakesNFTsContract_Transfer_handler(({ event, context }) => {
  const tokenId = event.params.tokenId.toString();
  const newOwner = event.params.to;
  const tokenEntity = context.Token.get(tokenId);

  const sweepStakesNFTs_TransferEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    from: event.params.from,
    to: event.params.to,
    tokenId: event.params.tokenId,
  };

  if (tokenEntity !== undefined) {
    context.Token.set({
      ...tokenEntity, userAddress: newOwner,
    });
  } else {
    context.Token.set({
      id: tokenId,
      userAddress: newOwner,
      totalStakes: 0n,
      totalPrizes: 0n,
      balance: 0n,
    });
  }

  context.SweepStakesNFTs_Transfer.set(sweepStakesNFTs_TransferEntity);
});

SweepStakesNFTsContract_Enter_loader(({ event, context }) => {
  const tokenId = event.params._tokenId.toString();
  context.Token.load(tokenId);
  context.ContractTotals.load(CONTRACT_NAME);
});

SweepStakesNFTsContract_Enter_handler(({ event, context }) => {
  const tokenId = event.params._tokenId.toString();
  const tokenEntity = context.Token.get(tokenId);
  if (tokenEntity === undefined) {
    throw new Error('Token not found, error in handler. It should have been created by the "Transfer" event handler.')
  }

  const contractTotals = context.ContractTotals.get(CONTRACT_NAME);

  const sweepStakesNFTs_EnterEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
  };

  context.Token.set({
    id: tokenId,
    userAddress: tokenEntity.userAddress,
    totalStakes: tokenEntity.totalStakes + event.params._amount,
    totalPrizes: tokenEntity.totalPrizes,
    balance: tokenEntity.balance + event.params._amount,
  });

  if (contractTotals !== undefined) {
    context.ContractTotals.set({
      ...contractTotals,
      balance: contractTotals.balance + event.params._amount,
    });
  } else {
    context.ContractTotals.set({
      id: CONTRACT_NAME,
      totalPrizes: BigInt(0),
      balance: event.params._amount,
    });
  }

  context.SweepStakesNFTs_Enter.set(sweepStakesNFTs_EnterEntity);
});

SweepStakesNFTsContract_Unstake_loader(({ event, context }) => {
  const tokenId = event.params._tokenId.toString();
  context.Token.load(tokenId);
  context.ContractTotals.load(CONTRACT_NAME)
});

SweepStakesNFTsContract_Unstake_handler(({ event, context }) => {
  const tokenId = event.params._tokenId.toString();
  const tokenEntity = context.Token.get(tokenId);
  if (tokenEntity === undefined) {
    throw new Error('Token not found, error in handler. It should have been created by the "Transfer" event handler.')
  }

  const contractTotals = context.ContractTotals.get(CONTRACT_NAME);

  const sweepStakesNFTs_UnstakeEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
  };

  if (tokenEntity !== undefined) {
    context.Token.set({
      ...tokenEntity,
      totalStakes: tokenEntity.totalStakes - event.params._amount,
      balance: tokenEntity.balance - event.params._amount,
    });
  }

  if (contractTotals !== undefined) {
    context.ContractTotals.set({
      ...contractTotals,
      balance: contractTotals.balance - event.params._amount,
    });
  } else {
    throw new Error('ContractTotals not found, error in handler. It should have been created in the "Enter" event handler.')
  }

  context.SweepStakesNFTs_Unstake.set(sweepStakesNFTs_UnstakeEntity);
});

SweepStakesNFTsContract_WinnerAssigned_loader(({ event, context }) => {
  const tokenId = event.params._winner.toString();
  context.Token.load(tokenId);
  context.ContractTotals.load(CONTRACT_NAME);
});

SweepStakesNFTsContract_WinnerAssigned_handler(({ event, context }) => {
  const tokenId = event.params._winner.toString();
  const tokenEntity = context.Token.get(tokenId);

  if (tokenEntity === undefined) {
    throw new Error('Token not found, error in handler. It should have been created by the "Transfer" event handler.')
  }
  const contractTotals = context.ContractTotals.get(CONTRACT_NAME);
  if (contractTotals === undefined) {
    throw new Error('contractTotals not found, error in handler. It should have been created in the "Enter" event handler.')
  }

  const sweepStakesNFTs_WinnerAssignedEntity: sweepStakesNFTs_WinnerAssignedEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    winningTicket: event.params.winningTicket,
    _winner_id: event.params._winner.toString(),
    _amount: event.params._amount,
    token_id: tokenId,
    timestamp: event.blockTimestamp,
    winnerAddress: tokenEntity.userAddress,
    winnerBalance: tokenEntity.balance,
    totalBalance: contractTotals.balance,
  };

  if (tokenEntity != undefined) {
    context.Token.set({
      ...tokenEntity,
      totalPrizes: tokenEntity.totalPrizes + event.params._amount,
      balance: tokenEntity.balance + event.params._amount,
    });
  }

  context.ContractTotals.set({
    id: CONTRACT_NAME,
    totalPrizes: contractTotals.totalPrizes + event.params._amount,
    balance: contractTotals.balance + event.params._amount,
  });


  context.SweepStakesNFTs_WinnerAssigned.set(
    sweepStakesNFTs_WinnerAssignedEntity
  );
});

