/*
 *Please refer to https://docs.envio.dev for a thorough guide on all Envio indexer features*
 */

let { SweepStakesNFTsContract } = require("../generated/src/Handlers.bs.js");

const GLOBAL_EVENTS_SUMMARY_KEY = "GlobalEventsSummary";

module.exports = {
  GLOBAL_EVENTS_SUMMARY_KEY,
};

const INITIAL_EVENTS_SUMMARY = {
  id: GLOBAL_EVENTS_SUMMARY_KEY,
  sweepStakesNFTs_ApprovalCount: BigInt(0),
  sweepStakesNFTs_ApprovalForAllCount: BigInt(0),
  sweepStakesNFTs_DrawWinnerCount: BigInt(0),
  sweepStakesNFTs_EnterCount: BigInt(0),
  sweepStakesNFTs_TransferCount: BigInt(0),
  sweepStakesNFTs_UnstakeCount: BigInt(0),
  sweepStakesNFTs_WinnerAssignedCount: BigInt(0),
  sweepStakesNFTs_WithdrawCount: BigInt(0),
};

SweepStakesNFTsContract.Approval.loader((event, context) => {
  context.EventsSummary.load(GLOBAL_EVENTS_SUMMARY_KEY);
});

SweepStakesNFTsContract.Approval.handler((event, context) => {
  const summary = context.EventsSummary.get(GLOBAL_EVENTS_SUMMARY_KEY);

  const currentSummaryEntity = summary ?? INITIAL_EVENTS_SUMMARY;

  const nextSummaryEntity = {
    ...currentSummaryEntity,
    sweepStakesNFTs_ApprovalCount:
      currentSummaryEntity.sweepStakesNFTs_ApprovalCount + BigInt(1),
  };

  const sweepStakesNFTs_ApprovalEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    owner: event.params.owner,
    approved: event.params.approved,
    tokenId: event.params.tokenId,
    eventsSummary: GLOBAL_EVENTS_SUMMARY_KEY,
  };

  context.EventsSummary.set(nextSummaryEntity);
  context.SweepStakesNFTs_Approval.set(sweepStakesNFTs_ApprovalEntity);
});
SweepStakesNFTsContract.ApprovalForAll.loader((event, context) => {
  context.EventsSummary.load(GLOBAL_EVENTS_SUMMARY_KEY);
});

SweepStakesNFTsContract.ApprovalForAll.handler((event, context) => {
  const summary = context.EventsSummary.get(GLOBAL_EVENTS_SUMMARY_KEY);

  const currentSummaryEntity = summary ?? INITIAL_EVENTS_SUMMARY;

  const nextSummaryEntity = {
    ...currentSummaryEntity,
    sweepStakesNFTs_ApprovalForAllCount:
      currentSummaryEntity.sweepStakesNFTs_ApprovalForAllCount + BigInt(1),
  };

  const sweepStakesNFTs_ApprovalForAllEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    owner: event.params.owner,
    operator: event.params.operator,
    approved: event.params.approved,
    eventsSummary: GLOBAL_EVENTS_SUMMARY_KEY,
  };

  context.EventsSummary.set(nextSummaryEntity);
  context.SweepStakesNFTs_ApprovalForAll.set(
    sweepStakesNFTs_ApprovalForAllEntity
  );
});
SweepStakesNFTsContract.DrawWinner.loader((event, context) => {
  context.EventsSummary.load(GLOBAL_EVENTS_SUMMARY_KEY);
});

SweepStakesNFTsContract.DrawWinner.handler((event, context) => {
  const summary = context.EventsSummary.get(GLOBAL_EVENTS_SUMMARY_KEY);

  const currentSummaryEntity = summary ?? INITIAL_EVENTS_SUMMARY;

  const nextSummaryEntity = {
    ...currentSummaryEntity,
    sweepStakesNFTs_DrawWinnerCount:
      currentSummaryEntity.sweepStakesNFTs_DrawWinnerCount + BigInt(1),
  };

  const sweepStakesNFTs_DrawWinnerEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    eventsSummary: GLOBAL_EVENTS_SUMMARY_KEY,
  };

  context.EventsSummary.set(nextSummaryEntity);
  context.SweepStakesNFTs_DrawWinner.set(sweepStakesNFTs_DrawWinnerEntity);
});

SweepStakesNFTsContract.Enter.loader((event, context) => {
  context.EventsSummary.load(GLOBAL_EVENTS_SUMMARY_KEY);
  context.Participant.load(event.params._tokenId.toString());
});

SweepStakesNFTsContract.Enter.handler((event, context) => {
  const summary = context.EventsSummary.get(GLOBAL_EVENTS_SUMMARY_KEY);

  const currentSummaryEntity = summary ?? INITIAL_EVENTS_SUMMARY;

  const nextSummaryEntity = {
    ...currentSummaryEntity,
    sweepStakesNFTs_EnterCount:
      currentSummaryEntity.sweepStakesNFTs_EnterCount + BigInt(1),
  };

  const sweepStakesNFTs_EnterEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
    eventsSummary: GLOBAL_EVENTS_SUMMARY_KEY,
  };

  const participantId = event.params._tokenId.toString(); 
  let participantEntity = context.Participant.get(participantId);
  if (participantEntity != undefined) {
    context.Participant.set({
      id: participantId,
      address: participantEntity.address,
      totalStakes: participantEntity.totalStakes + event.params._amount,
      totalPrizes: participantEntity.totalPrizes,
      balance: participantEntity.balance + event.params._amount,
    });
  } else {
    context.Participant.set({
      id: participantId,
      address: participantEntity.address,
      totalStakes: event.params._amount,
      totalPrizes: BigInt(0),
      balance: BigInt(0),
    });
  }

  context.EventsSummary.set(nextSummaryEntity);
  context.SweepStakesNFTs_Enter.set(sweepStakesNFTs_EnterEntity);
});

SweepStakesNFTsContract.Transfer.loader((event, context) => {
  context.EventsSummary.load(GLOBAL_EVENTS_SUMMARY_KEY);
  context.Participant.load(event.params.tokenId.toString());
});

SweepStakesNFTsContract.Transfer.handler((event, context) => {
  const summary = context.EventsSummary.get(GLOBAL_EVENTS_SUMMARY_KEY);

  const currentSummaryEntity = summary ?? INITIAL_EVENTS_SUMMARY;

  const nextSummaryEntity = {
    ...currentSummaryEntity,
    sweepStakesNFTs_TransferCount:
      currentSummaryEntity.sweepStakesNFTs_TransferCount + BigInt(1),
  };

  const sweepStakesNFTs_TransferEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    from: event.params.from,
    to: event.params.to,
    tokenId: event.params.tokenId,
    eventsSummary: GLOBAL_EVENTS_SUMMARY_KEY,
  };

  const participantId = event.params.tokenId.toString();
  let participantEntity = context.Participant.get(participantId);
  if (participantEntity != undefined) {
    context.Participant.set({
      id: participantId,
      address: event.params.to,
      totalStakes: participantEntity.totalStakes,
      totalPrizes: participantEntity.totalPrizes,
      balance: participantEntity.balance,
    });
  } else {
    context.Participant.set({
      id: participantId,
      address: event.params.to,
      totalStakes: BigInt(0),
      totalPrizes: BigInt(0),
      balance: BigInt(0),
    });
  }


  context.EventsSummary.set(nextSummaryEntity);
  context.SweepStakesNFTs_Transfer.set(sweepStakesNFTs_TransferEntity);
});
SweepStakesNFTsContract.Unstake.loader((event, context) => {
  context.EventsSummary.load(GLOBAL_EVENTS_SUMMARY_KEY);
  context.Participant.load(event.params._tokenId.toString());
});

SweepStakesNFTsContract.Unstake.handler((event, context) => {
  const summary = context.EventsSummary.get(GLOBAL_EVENTS_SUMMARY_KEY);

  const currentSummaryEntity = summary ?? INITIAL_EVENTS_SUMMARY;

  const nextSummaryEntity = {
    ...currentSummaryEntity,
    sweepStakesNFTs_UnstakeCount:
      currentSummaryEntity.sweepStakesNFTs_UnstakeCount + BigInt(1),
  };

  const sweepStakesNFTs_UnstakeEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
    eventsSummary: GLOBAL_EVENTS_SUMMARY_KEY,
  };

  const participantId = event.params._tokenId.toString();
  let participantEntity = context.Participant.get(participantId);
  if (participantEntity != undefined) {
    context.Participant.set({
      id: participantId,
      address: participantEntity.address,
      totalStakes: participantEntity.totalStakes - event.params._amount,
      totalPrizes: participantEntity.totalPrizes,
      balance: participantEntity.balance - event.params._amount,
    });
  } else {
    context.Participant.set({
      id: participantId,
      address: participantEntity.address,
      totalStakes: BigInt(0),
      totalPrizes: BigInt(0),
      balance: BigInt(0),
    });
  }

  context.EventsSummary.set(nextSummaryEntity);
  context.SweepStakesNFTs_Unstake.set(sweepStakesNFTs_UnstakeEntity);
});
SweepStakesNFTsContract.WinnerAssigned.loader((event, context) => {
  context.EventsSummary.load(GLOBAL_EVENTS_SUMMARY_KEY);
  context.Participant.load(event.params._winner.toString());
});

SweepStakesNFTsContract.WinnerAssigned.handler((event, context) => {
  const summary = context.EventsSummary.get(GLOBAL_EVENTS_SUMMARY_KEY);

  const currentSummaryEntity = summary ?? INITIAL_EVENTS_SUMMARY;

  const nextSummaryEntity = {
    ...currentSummaryEntity,
    sweepStakesNFTs_WinnerAssignedCount:
      currentSummaryEntity.sweepStakesNFTs_WinnerAssignedCount + BigInt(1),
  };

  const participantId = event.params._winner.toString();
  let participantEntity = context.Participant.get(participantId);

  const sweepStakesNFTs_WinnerAssignedEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    winningTicket: event.params.winningTicket,
    _winner: event.params._winner,
    _amount: event.params._amount,
    participant: participantId,
    eventsSummary: GLOBAL_EVENTS_SUMMARY_KEY,
  };

  if (participantEntity != undefined) {
    context.Participant.set({
      id: participantId,
      address: participantEntity.address,
      totalStakes: participantEntity.totalStakes,
      totalPrizes: participantEntity.totalPrizes + event.params._amount,
      balance: participantEntity.balance + event.params._amount,
    });
  } else {
    context.Participant.set({
      id: participantId,
      address: participantEntity.address,
      totalStakes: BigInt(0),
      totalPrizes: event.params._amount,
      balance: event.params._amount,
    });
  }

  context.EventsSummary.set(nextSummaryEntity);
  context.SweepStakesNFTs_WinnerAssigned.set(
    sweepStakesNFTs_WinnerAssignedEntity
  );
});
SweepStakesNFTsContract.Withdraw.loader((event, context) => {
  context.EventsSummary.load(GLOBAL_EVENTS_SUMMARY_KEY);
});

SweepStakesNFTsContract.Withdraw.handler((event, context) => {
  const summary = context.EventsSummary.get(GLOBAL_EVENTS_SUMMARY_KEY);

  const currentSummaryEntity = summary ?? INITIAL_EVENTS_SUMMARY;

  const nextSummaryEntity = {
    ...currentSummaryEntity,
    sweepStakesNFTs_WithdrawCount:
      currentSummaryEntity.sweepStakesNFTs_WithdrawCount + BigInt(1),
  };

  const sweepStakesNFTs_WithdrawEntity = {
    id: event.transactionHash + event.logIndex.toString(),
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
    eventsSummary: GLOBAL_EVENTS_SUMMARY_KEY,
  };

  context.EventsSummary.set(nextSummaryEntity);
  context.SweepStakesNFTs_Withdraw.set(sweepStakesNFTs_WithdrawEntity);
});
