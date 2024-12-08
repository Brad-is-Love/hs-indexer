/*
 * Please refer to https://docs.envio.dev for a thorough guide on all Envio indexer features
 */
import {
  SweepStakesNFTs,
  ContractTotals,
  User,
  Token,
  SweepStakesNFTs_WinnerAssigned,
} from "generated";

SweepStakesNFTs.Transfer.handler(async ({ event, context }) => {
  let newUser = await context.User.get(event.params.to.toString())
  let token = await context.Token.get(event.params.tokenId.toString())
  let bal = BigInt(0)

  if(token !== undefined){
    bal = token.balance
    let tokenObject: Token = {
      id: event.params.tokenId.toString(),
      userAddress: event.params.to.toString(),
      balance: bal
    }
    context.Token.set(tokenObject)
  } else {
    let tokenObject: Token = {
      id: event.params.tokenId.toString(),
      userAddress: event.params.to.toString(),
      balance: BigInt(0)
    }
    context.Token.set(tokenObject)
  }

  if(newUser !== undefined){
    let userObject: User = {
      id: event.params.to.toString(),
      balance: newUser.balance + bal
    }
    context.User.set(userObject)
  } else {
    let userObject: User = {
      id: event.params.to.toString(),
      balance: bal
    }
    context.User.set(userObject)
  }
});

SweepStakesNFTs.Enter.handler(async ({ event, context }) => {
  let contractTotals = await context.ContractTotals.get("1")
  if(contractTotals !== undefined){
    let contractObject: ContractTotals = {
      id: "1",
      totalPrizes: contractTotals.totalPrizes,
      balance: contractTotals.balance + event.params._amount
    }
    context.ContractTotals.set(contractObject)
  } else {
    let contractObject: ContractTotals = {
      id: "1",
      totalPrizes: BigInt(0),
      balance: event.params._amount
    }
    context.ContractTotals.set(contractObject)
  }
  let token = await context.Token.get(event.params._tokenId.toString())
  if(token !== undefined){
    let user = await context.User.get(token.userAddress)
    if(user !== undefined){
      let userObject: User = {
        id: token.userAddress,
        balance: user.balance + event.params._amount
      }
      context.User.set(userObject)
      let tokenObject: Token = {
        id: event.params._tokenId.toString(),
        userAddress: token.userAddress,
        balance: token.balance + event.params._amount
      }
    }
  }
});

SweepStakesNFTs.Withdraw.handler(async ({ event, context }) => {
  let contractTotals = await context.ContractTotals.get("1")
  if(contractTotals !== undefined){
    let contractObject: ContractTotals = {
      id: "1",
      totalPrizes: contractTotals.totalPrizes,
      balance: contractTotals.balance - event.params._amount
    }
    context.ContractTotals.set(contractObject)
  }
  let token = await context.Token.get(event.params._tokenId.toString())
  if(token !== undefined){
    let user = await context.User.get(token.userAddress)
    if(user !== undefined){
      let userObject: User = {
        id: token.userAddress,
        balance: user.balance - event.params._amount
      }
      context.User.set(userObject)
      let tokenObject: Token = {
        id: event.params._tokenId.toString(),
        userAddress: token.userAddress,
        balance: token.balance - event.params._amount
      }
      context.Token.set(tokenObject)
    }
  }
});


SweepStakesNFTs.WinnerAssigned.handler(async ({ event, context }) => {
  let winningToken = await context.Token.get(event.params._winner.toString())
  let winnerAddress = 'Unknown'
  let winnerBalance = BigInt(0)
  let totalBalance = BigInt(0)
  
  if (winningToken !== undefined) {
    let winniningUser = await context.User.get(winningToken.userAddress)
    if (winniningUser !== undefined) {
      let userObject: User = {
        id: winningToken.userAddress,
        balance: winniningUser.balance + event.params._amount
      }
      context.User.set(userObject)
      winnerAddress = winningToken.userAddress
      winnerBalance = winniningUser.balance + event.params._amount
    }
    let tokenObject: Token = {
      id: event.params._winner.toString(),
      userAddress: winningToken.userAddress,
      balance: winningToken.balance + event.params._amount
    }
    context.Token.set(tokenObject)
  }
  let contractTotals = await context.ContractTotals.get("1")
  if (contractTotals !== undefined) {
    let contractObject: ContractTotals = {
      id: "1",
      totalPrizes: contractTotals.totalPrizes + event.params._amount,
      balance: contractTotals.balance + event.params._amount
    }
    context.ContractTotals.set(contractObject)
    totalBalance = contractTotals.balance + event.params._amount
  }
  let winnerAssignedObject:
  SweepStakesNFTs_WinnerAssigned = {
    id: event.block.hash,
    _winner: event.params._winner,
    _amount: event.params._amount,
    timestamp: event.block.timestamp,
    winnerAddress: winnerAddress,
    winnerBalance: winnerBalance,
    totalBalance: totalBalance
  }
  context.SweepStakesNFTs_WinnerAssigned.set(winnerAssignedObject)
});
