import { indexer } from "envio";
import type {
  ContractTotals,
  User,
  Token,
  SweepStakesNFTs_WinnerAssigned,
  SweepStakesNFTs_Enter,
} from "envio";

const initialContractTotals: ContractTotals = {
  id: "1",
  totalPrizes: BigInt(0),
  balance: BigInt("124551016781730306787521"),
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
  "0xa74Fa8F835cf758711DF77FA480E4404Aa6113bF",
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
  "0x2F4Fb92F1B8ab270ede2be71Df142D7cC9A3209a",
  "0x8a54bf03dF4CEEC2c2f2312Ab45Bb852d2dE95d0",
  "0x976DF602916aC2ee8C3Fbc377732174CfEc75282",
  "0x104bc9ff1CCF6fE2fc9dDe2f37261E844578891b",
  "0x104bc9ff1CCF6fE2fc9dDe2f37261E844578891b",
  "0x15b38E09dEC43c0414A83FF1D7AFD4367B14cb66",
  "0x4Db06a80df35248708931022079d260137a0Ae1b",
  "0xBB0B2E5E32c661e0979E0015c1561431A45E2b33",
  "0x28e5cC3a57bBeA7fb3e0d5D6A1b4f95Bbc03A5F2",
  "0x7f6860A769e1D2103Df246520BbE35A3c2ef7aA5",
  "0xeaf41e85A9804c74b332FAD07f7e0cac53085345",
  "0x10B250059754A8b1637031865Ee3d2e7f8097668",
  "0x4dba17793D4eebf6daC48150E2D69887810016e5",
  "0xF43440d2C5a1Dd837E399186AE3d0EB710Bc22B9",
  "0x6718C63C41476e5AdC3744AB1a5945DAB646A57a",
  "0x3dDb9162ab61919dBe6CCFB260f8efCFfd9fBc94",
  "0xB528507e863Fe20C220BFaec2C8F90542bfad029"
];

const initialBalances = [
  "29297651762981522421650",
  "4271439749578473319206",
  "20000000000000000000",
  "507380490550564045756",
  "2772063753854476405878",
  "795928291373433306778",
  "2028290544788267696301",
  "194147729387676820159",
  "843810873106206051983",
  "45750000000000000000",
  "368038644652000382208",
  "15532257199110287050044",
  "10169235401272706995746",
  "11238861645273713803094",
  "151607074913894129334",
  "500000000000000000000",
  "400000000000000000000",
  "200000000000000000000",
  "550719469666656525355",
  "600695543879428707094",
  "616481093909830854755",
  "20000000000000000000",
  "199000000000000000000",
  "100000000000000000000",
  "2077979397925253341970",
  "856760000000000000000",
  "19000000000000000000",
  "1038048848154629008504",
  "791958764846949853326",
  "3311836984780860431851",
  "657150884121957321313",
  "20000000000000000000",
  "1000000000000000000000",
  "20224035542919922528592",
  "12717887090681595786624",
  "0",
  "338000000000000000000",
  "0",
  "75000000000000000000"
];

async function initializeState(context: any) {
  let contractTotals = await context.ContractTotals.get("1");
  if (contractTotals === undefined) {
    context.ContractTotals.set(initialContractTotals);
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
  }
}

indexer.onEvent({ contract: "SweepStakesNFTs", event: "Transfer" }, async ({ event, context }) => {
  await initializeState(context);

  let newUser = await context.User.get(event.params.to.toString());
  let token = await context.Token.get(event.params.tokenId.toString());
  let bal = BigInt(0);

  const isBurn = event.params.to.toString() === "0x0000000000000000000000000000000000000000";
  const isMint = event.params.from.toString() === "0x0000000000000000000000000000000000000000";

  if (token !== undefined) {
    bal = isBurn || isMint ? BigInt(0) : token.balance;
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
    let userObject: User = {
      id: event.params.to.toString(),
    };
    context.User.set(userObject);
  }
});

indexer.onEvent({ contract: "SweepStakesNFTs", event: "Enter" }, async ({ event, context }) => {
  await initializeState(context);

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

  let userAddress = token !== undefined ? token.userAddress : event.srcAddress.toString();

  let enterObject: SweepStakesNFTs_Enter = {
    id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
    _tokenId: event.params._tokenId,
    _amount: event.params._amount,
    userAddress: userAddress,
  };
  context.SweepStakesNFTs_Enter.set(enterObject);
});

indexer.onEvent({ contract: "SweepStakesNFTs", event: "Unstake" }, async ({ event, context }) => {
  await initializeState(context);

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

indexer.onEvent({ contract: "SweepStakesNFTs", event: "WinnerAssigned" }, async ({ event, context }) => {
  await initializeState(context);

  const token = await context.Token.get(event.params._winner.toString());
  let tokensOfUser: Token[] = [];
  if (token !== undefined) {
    tokensOfUser = await context.Token.getWhere({ userAddress: { _eq: token.userAddress } });
  }

  let winningToken = token;
  let winnerAddress = "Unknown";
  let winnerBalance = BigInt(0);
  let totalBalance = BigInt(0);
  
  if (tokensOfUser) {
    tokensOfUser.forEach((token) => {
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
});
