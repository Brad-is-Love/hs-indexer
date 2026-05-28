@val external require: string => unit = "require"

let registerContractHandlers = (
  ~contractName,
  ~handlerPathRelativeToRoot,
  ~handlerPathRelativeToConfig,
) => {
  try {
    require("root/" ++ handlerPathRelativeToRoot)
  } catch {
  | exn =>
    let params = {
      "Contract Name": contractName,
      "Expected Handler Path": handlerPathRelativeToConfig,
      "Code": "EE500",
    }
    let logger = Logging.createChild(~params)

    let errHandler = exn->ErrorHandling.make(~msg="Failed to import handler file", ~logger)
    errHandler->ErrorHandling.log
    errHandler->ErrorHandling.raiseExn
  }
}

%%private(
  let makeGeneratedConfig = () => {
    let chains = [
      {
        let contracts = [
          {
            Config.name: "SweepStakesNFTs",
            abi: Types.SweepStakesNFTs.abi,
            addresses: [
              "0xc71D7C069Ae96794c5d6d54ff04754D2832601c3"->Address.Evm.fromStringOrThrow
,
            ],
            events: [
              module(Types.SweepStakesNFTs.Enter),
              module(Types.SweepStakesNFTs.Transfer),
              module(Types.SweepStakesNFTs.Unstake),
              module(Types.SweepStakesNFTs.WinnerAssigned),
              module(Types.SweepStakesNFTs.Withdraw),
            ],
            sighashes: [
              Types.SweepStakesNFTs.Enter.sighash,
              Types.SweepStakesNFTs.Transfer.sighash,
              Types.SweepStakesNFTs.Unstake.sighash,
              Types.SweepStakesNFTs.WinnerAssigned.sighash,
              Types.SweepStakesNFTs.Withdraw.sighash,
            ],
          },
        ]
        let chain = ChainMap.Chain.makeUnsafe(~chainId=1666600000)
        {
          Config.confirmedBlockThreshold: 200,
          syncSource: 
            HyperSync({endpointUrl: "https://1666600000.hypersync.xyz"})
,
          startBlock: 0,
          endBlock:  None ,
          chain,
          contracts,
          chainWorker:
            module(HyperSyncWorker.Make({
              let chain = chain
              let contracts = contracts
              let endpointUrl = "https://1666600000.hypersync.xyz"
              let allEventSignatures = [
                Types.SweepStakesNFTs.eventSignatures,
              ]->Belt.Array.concatMany
              let eventRouter =
                contracts
                ->Belt.Array.flatMap(contract => contract.events)
                ->EventRouter.fromEvmEventModsOrThrow(~chain)
              /*
                Determines whether to use HypersyncClient Decoder or Viem for parsing events
                Default is hypersync client decoder, configurable in config with:
                ```yaml
                event_decoder: "viem" || "hypersync-client"
                ```
              */
              let shouldUseHypersyncClientDecoder = Env.Configurable.shouldUseHypersyncClientDecoder->Belt.Option.getWithDefault(
                true,
              )
              let blockSchema = Types.Block.schema
              let transactionSchema = Types.Transaction.schema
            }))
        }
      },
    ]

    Config.make(
      ~shouldRollbackOnReorg=false,
      ~shouldSaveFullHistory=false,
      ~isUnorderedMultichainMode=false,
      ~chains,
      ~enableRawEvents=false,
      ~entities=[
        module(Entities.ContractTotals),
        module(Entities.SweepStakesNFTs_Enter),
        module(Entities.SweepStakesNFTs_Transfer),
        module(Entities.SweepStakesNFTs_Unstake),
        module(Entities.SweepStakesNFTs_WinnerAssigned),
        module(Entities.SweepStakesNFTs_Withdraw),
        module(Entities.Token),
        module(Entities.User),
      ],
    )
  }

  let config: ref<option<Config.t>> = ref(None)
)

let registerAllHandlers = () => {
  registerContractHandlers(
    ~contractName="SweepStakesNFTs",
    ~handlerPathRelativeToRoot="src/EventHandlers.ts",
    ~handlerPathRelativeToConfig="src/EventHandlers.ts",
  )

  let generatedConfig = makeGeneratedConfig()
  config := Some(generatedConfig)
  generatedConfig
}

let getConfig = () => {
  switch config.contents {
  | Some(config) => config
  | None => registerAllHandlers()
  }
}
