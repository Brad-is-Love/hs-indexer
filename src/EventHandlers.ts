// 
import {
  SweepStakesNFTs,
  ContractTotals,
  User,
  Token,
  SweepStakesNFTs_WinnerAssigned,
} from "generated";

const initialContractTotals: ContractTotals = {
  id: "1",
  totalPrizes: BigInt(0),
  balance: BigInt(77667989541107285312594) - BigInt(40000000000000000000),
};

const initialTokenHolders = [
  "0x815e2D7607cea807622130E85309385ED3Bb814B",
  "0x106BbE5ab25Afb431c0f2231B33E1Eac61d1253D",
  "0x097223Ee83e714e25aF3eC698293c635Bea05796",
  "0x4020F79Bd98039fca2082B934cDabb8c13a45E96",
  "0xFc49B14da27a9d6054a12460a15D1587f48ff712",
  "0xaC85Ec193E534cd5dE30A56dcEBbcf9325911E17",
  "0x7A504f7b53F639cC7F76828622915757c335cb7A",
  "0x943613B6C1A5f6561B79684BCf06173BDF65E365",
  "0x7188CC2282c105DfcE5249e6a909DB71b914B25b",
  "0x7188CC2282c105DfcE5249e6a909DB71b914B25b",
  "0x10B250059754A8b1637031865Ee3d2e7f8097668",
  "0xCF59EE6C0B0031D99766Ef7A0f627c9A4F05449d",
  "0x472b906625aaaE0a1bCD1C28827751AF26A7F266",
  "0x3B2Be8413F34fc6491506B18c530A264c0f7adAE",
  "0x96BD0333eaA6Cd1A3521097D0bC3BC3d4fcDA58C",
  "0x7188CC2282c105DfcE5249e6a909DB71b914B25b",
  "0x3d0e5733af22684d0091E179cA2BaCB24f1bB7D5",
  "0x7188CC2282c105DfcE5249e6a909DB71b914B25b",
  "0x7188CC2282c105DfcE5249e6a909DB71b914B25b",
  "0x7188CC2282c105DfcE5249e6a909DB71b914B25b",
  "0x7188CC2282c105DfcE5249e6a909DB71b914B25b",
  "0x82BD5fD0F73bA74f335917991519b151f7eD6E02",
  "0x27ea70F73636Ddb19C4CBef644f1391e26e5185b",
];

const initialBalances = [
  "601070000000000000000",
  "3181611496696738991495",
  "20000000000000000000",
  "350000000000000000000",
  "2709629203640932261413",
  "700766453421094854933",
  "10000485135144590863414",
  "194147729387676820159",
  "706520000000000000000",
  "45750000000000000000",
  "46250919522816251521180",
  "180000000000000000000",
  "100000000000000000000",
  "10001000000000000000000",
  "106090000000000000000",
  "500000000000000000000",
  "400000000000000000000",
  "200000000000000000000",
  "400000000000000000000",
  "500000000000000000000",
  "500000000000000000000",
  "20000000000000000000",
  "0",
];

SweepStakesNFTs.Transfer.handler(async ({ event, context }) => {
  let oldUser = await context.User.get(event.params.from.toString());
  let newUser = await context.User.get(event.params.to.toString());
  let token = await context.Token.get(event.params.tokenId.toString());
  let bal = BigInt(0);

  let contractTotals = await context.ContractTotals.get("1");
  if (contractTotals === undefined) {
    context.ContractTotals.set(initialContractTotals);
    // set initial token and create a user
    initialTokenHolders.forEach((address, index) => {
      let userObject: User = {
        id: address,
      };
      context.User.set(userObject);
      let tokenObject: Token = {
        id: index.toString(),
        userAddress: address,
        balance: BigInt(initialBalances[index]),
      };
      context.Token.set(tokenObject);
    });
  } else {
    // initial values have been set
    if (token !== undefined) {
      bal = token.balance;
      let tokenObject: Token = {
        id: event.params.tokenId.toString(),
        userAddress: event.params.to.toString(),
        balance: bal,
      };
      context.Token.set(tokenObject);
    } else {
      let tokenObject: Token = {
        id: event.params.tokenId.toString(),
        userAddress: event.params.to.toString(),
        balance: BigInt(0),
      };
      context.Token.set(tokenObject);
    }
    if (newUser === undefined) {
      // create a new user
      let userObject: User = {
        id: event.params.to.toString(),
      };
      context.User.set(userObject);
    }
  }
});

SweepStakesNFTs.Enter.handler(async ({ event, context }) => {
  let contractTotals = await context.ContractTotals.get("1");
  if (contractTotals !== undefined) {
    let contractObject: ContractTotals = {
      id: "1",
      totalPrizes: contractTotals.totalPrizes,
      balance: contractTotals.balance + event.params._amount,
    };
    context.ContractTotals.set(contractObject);
  }
  let token = await context.Token.get(event.params._tokenId.toString());
  if (token !== undefined) {
    let tokenObject: Token = {
      id: event.params._tokenId.toString(),
      userAddress: token.userAddress,
      balance: token.balance + event.params._amount,
    };
    context.Token.set(tokenObject);
  }
});

SweepStakesNFTs.Unstake.handler(async ({ event, context }) => {
  let contractTotals = await context.ContractTotals.get("1");
  if (contractTotals !== undefined) {
    let contractObject: ContractTotals = {
      id: "1",
      totalPrizes: contractTotals.totalPrizes,
      balance: contractTotals.balance - event.params._amount,
    };
    context.ContractTotals.set(contractObject);
  }
  let token = await context.Token.get(event.params._tokenId.toString());
  if (token !== undefined) {
    let tokenObject: Token = {
      id: event.params._tokenId.toString(),
      userAddress: token.userAddress,
      balance: token.balance - event.params._amount,
    };
    context.Token.set(tokenObject);
  }
});

SweepStakesNFTs.WinnerAssigned.handlerWithLoader({
  loader: async ({ event, context }) => {
    const token = await context.Token.get(event.params._winner.toString());
    if (token === undefined) {
      return { token: undefined, tokensOfUser: [] };
    }
    const tokensOfUser = await context.Token.getWhere.userAddress.eq(token.userAddress);
    return { token, tokensOfUser };
  },
  handler: async ({ event, context, loaderReturn }) => {
    const { token, tokensOfUser } = loaderReturn;

    let winningToken = token
    let winnerAddress = "Unknown";
    let winnerBalance = BigInt(0);
    let totalBalance = BigInt(0);
    
    if( tokensOfUser ){
      tokensOfUser.forEach( (token) => {
        winnerBalance += token.balance;
      });
    }
    if (winningToken !== undefined) {
      winnerAddress = winningToken.userAddress;
      let tokenObject: Token = {
        id: event.params._winner.toString(),
        userAddress: winningToken.userAddress,
        balance: winningToken.balance + event.params._amount,
      };
      context.Token.set(tokenObject);
    }
    let contractTotals = await context.ContractTotals.get("1");
    if (contractTotals !== undefined) {
      let contractObject: ContractTotals = {
        id: "1",
        totalPrizes: contractTotals.totalPrizes + event.params._amount,
        balance: contractTotals.balance + event.params._amount,
      };
      context.ContractTotals.set(contractObject);
      totalBalance = contractTotals.balance + event.params._amount;
    }
    let winnerAssignedObject: SweepStakesNFTs_WinnerAssigned = {
      id: event.block.hash,
      _winner: event.params._winner,
      _amount: event.params._amount,
      timestamp: event.block.timestamp,
      winnerAddress: winnerAddress,
      winnerBalance: winnerBalance,
      totalBalance: totalBalance,
    };
    context.SweepStakesNFTs_WinnerAssigned.set(winnerAssignedObject);
  },
});
