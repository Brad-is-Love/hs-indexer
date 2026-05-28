/***** TAKE NOTE ******
This is a hack to get genType to work!

In order for genType to produce recursive types, it needs to be at the 
root module of a file. If it's defined in a nested module it does not 
work. So all the MockDb types and internal functions are defined in TestHelpers_MockDb
and only public functions are recreated and exported from this module.

the following module:
```rescript
module MyModule = {
  @genType
  type rec a = {fieldB: b}
  @genType and b = {fieldA: a}
}
```

produces the following in ts:
```ts
// tslint:disable-next-line:interface-over-type-literal
export type MyModule_a = { readonly fieldB: b };

// tslint:disable-next-line:interface-over-type-literal
export type MyModule_b = { readonly fieldA: MyModule_a };
```

fieldB references type b which doesn't exist because it's defined
as MyModule_b
*/

module MockDb = {
  @genType
  let createMockDb = TestHelpers_MockDb.createMockDb
}

@genType
module Addresses = {
  include TestHelpers_MockAddresses
}

module EventFunctions = {
  //Note these are made into a record to make operate in the same way
  //for Res, JS and TS.

  /**
  The arguements that get passed to a "processEvent" helper function
  */
  @genType
  type eventProcessorArgs<'eventArgs> = {
    event: Types.eventLog<'eventArgs>,
    mockDb: TestHelpers_MockDb.t,
    chainId?: int,
  }

  /**
  A function composer to help create individual processEvent functions
  */
  let makeEventProcessor = (~contractName, ~eventName, ~handlerRegister, ~paramsRawEventSchema) => {
    async args => {
      let {event, mockDb, ?chainId} =
        args->(
          Utils.magic: eventProcessorArgs<'eventArgs> => eventProcessorArgs<Types.internalEventArgs>
        )
      let handlerRegister = handlerRegister->(Utils.magic: Types.HandlerTypes.Register.t<'eventArgs> => Types.HandlerTypes.Register.t<Types.internalEventArgs>)
      let paramsRawEventSchema = paramsRawEventSchema->(Utils.magic: S.t<'eventArgs> => S.t<Types.internalEventArgs>)

      let config = RegisterHandlers.getConfig()

      // The user can specify a chainId of an event or leave it off
      // and it will default to the first chain in the config
      let chain = switch chainId {
      | Some(chainId) => config->Config.getChain(~chainId)
      | None =>
        switch config.defaultChain {
        | Some(chainConfig) => chainConfig.chain
        | None =>
          Js.Exn.raiseError(
            "No default chain Id found, please add at least 1 chain to your config.yaml",
          )
        }
      }

      //Create an individual logging context for traceability
      let logger = Logging.createChild(
        ~params={
          "Context": `Test Processor for "${eventName}" event on contract "${contractName}"`,
          "Chain ID": chain->ChainMap.Chain.toChainId,
          "event": event,
        },
      )

      //Deep copy the data in mockDb, mutate the clone and return the clone
      //So no side effects occur here and state can be compared between process
      //steps
      let mockDbClone = mockDb->TestHelpers_MockDb.cloneMockDb

      if !(handlerRegister->Types.HandlerTypes.Register.hasRegistration) {
        Not_found->ErrorHandling.mkLogAndRaise(
          ~logger,
          ~msg=`No registered handler found for "${eventName}" on contract "${contractName}"`,
        )
      }
      //Construct a new instance of an in memory store to run for the given event
      let inMemoryStore = InMemoryStore.make()
      let loadLayer = LoadLayer.make(
        ~loadEntitiesByIds=TestHelpers_MockDb.makeLoadEntitiesByIds(mockDbClone),
        ~makeLoadEntitiesByField=(~entityMod) =>
          TestHelpers_MockDb.makeLoadEntitiesByField(mockDbClone, ~entityMod),
      )

      //No need to check contract is registered or return anything.
      //The only purpose is to test the registerContract function and to
      //add the entity to the in memory store for asserting registrations

      let eventBatchQueueItem: Types.eventBatchQueueItem = {
        event,
        eventName,
        contractName,
        handlerRegister,
        paramsRawEventSchema,
        chain,
        logIndex: event.logIndex,
        timestamp: event.block->Types.Block.getTimestamp,
        blockNumber: event.block->Types.Block.getNumber,
      }

      switch handlerRegister->Types.HandlerTypes.Register.getContractRegister {
      | Some(contractRegister) =>
        switch contractRegister->EventProcessing.runEventContractRegister(
          ~logger,
          ~eventBatchQueueItem,
          ~checkContractIsRegistered=(~chain as _, ~contractAddress as _, ~contractName as _) =>
            false,
          ~dynamicContractRegistrations=None,
          ~inMemoryStore,
          ~shouldSaveHistory=false,
        ) {
        | Ok(_) => ()
        | Error(e) => e->ErrorHandling.logAndRaise
        }
      | None => () //No need to run contract registration
      }

      switch handlerRegister->Types.HandlerTypes.Register.getLoaderHandler {
      | Some(loaderHandler) =>
        switch await eventBatchQueueItem->EventProcessing.runEventHandler(
          ~inMemoryStore,
          ~loadLayer,
          ~loaderHandler,
          ~logger,
          ~shouldSaveHistory=false,
        ) {
        | Ok(_) => ()
        | Error(e) => e->ErrorHandling.logAndRaise
        }
      | None => () //No need to run handler
      }

      //In mem store can still contatin raw events and dynamic contracts for the
      //testing framework in cases where either contract register or loaderHandler
      //is None
      mockDbClone->TestHelpers_MockDb.writeFromMemoryStore(~inMemoryStore)
      mockDbClone
    }
  }

  module MockBlock = {
    type t = {
      number?: int,
      timestamp?: int,
      hash?: string,
    }

    let toBlock = (_mock: t): Types.Block.t => {
      number: _mock.number->Belt.Option.getWithDefault(0),
      timestamp: _mock.timestamp->Belt.Option.getWithDefault(0),
      hash: _mock.hash->Belt.Option.getWithDefault("foo"),
    }
  }

  module MockTransaction = {
    type t = {
    }

    let toTransaction = (_mock: t): Types.Transaction.t => {
    }
  }

  @genType
  type mockEventData = {
    chainId?: int,
    srcAddress?: Address.t,
    logIndex?: int,
    block?: MockBlock.t,
    transaction?: MockTransaction.t,
  }

  /**
  Applies optional paramters with defaults for all common eventLog field
  */
  let makeEventMocker = (
    ~params: 'eventParams,
    ~mockEventData: option<mockEventData>,
  ): Types.eventLog<'eventParams> => {
    let {?block, ?transaction, ?srcAddress, ?chainId, ?logIndex} =
      mockEventData->Belt.Option.getWithDefault({})
    let block = block->Belt.Option.getWithDefault({})->MockBlock.toBlock
    let transaction = transaction->Belt.Option.getWithDefault({})->MockTransaction.toTransaction
    {
      params,
      transaction,
      chainId: chainId->Belt.Option.getWithDefault(1),
      block,
      srcAddress: srcAddress->Belt.Option.getWithDefault(Addresses.defaultAddress),
      logIndex: logIndex->Belt.Option.getWithDefault(0),
    }
  }
}


module SweepStakesNFTs = {
  module Enter = {
    @genType
    let processEvent = EventFunctions.makeEventProcessor(
      ~contractName=Types.SweepStakesNFTs.contractName,
      ~eventName=Types.SweepStakesNFTs.Enter.name,
      ~handlerRegister=Types.SweepStakesNFTs.Enter.handlerRegister,
      ~paramsRawEventSchema=Types.SweepStakesNFTs.Enter.paramsRawEventSchema,
    )

    @genType
    type createMockArgs = {
      @as("_tokenId")
      _tokenId?: bigint,
      @as("_amount")
      _amount?: bigint,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?_tokenId,
        ?_amount,
        ?mockEventData,
      } = args

      let params: Types.SweepStakesNFTs.Enter.eventArgs = 
      {
       _tokenId: _tokenId->Belt.Option.getWithDefault(0n),
       _amount: _amount->Belt.Option.getWithDefault(0n),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module Transfer = {
    @genType
    let processEvent = EventFunctions.makeEventProcessor(
      ~contractName=Types.SweepStakesNFTs.contractName,
      ~eventName=Types.SweepStakesNFTs.Transfer.name,
      ~handlerRegister=Types.SweepStakesNFTs.Transfer.handlerRegister,
      ~paramsRawEventSchema=Types.SweepStakesNFTs.Transfer.paramsRawEventSchema,
    )

    @genType
    type createMockArgs = {
      @as("from")
      from?: Address.t,
      @as("to")
      to?: Address.t,
      @as("tokenId")
      tokenId?: bigint,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?from,
        ?to,
        ?tokenId,
        ?mockEventData,
      } = args

      let params: Types.SweepStakesNFTs.Transfer.eventArgs = 
      {
       from: from->Belt.Option.getWithDefault(TestHelpers_MockAddresses.defaultAddress),
       to: to->Belt.Option.getWithDefault(TestHelpers_MockAddresses.defaultAddress),
       tokenId: tokenId->Belt.Option.getWithDefault(0n),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module Unstake = {
    @genType
    let processEvent = EventFunctions.makeEventProcessor(
      ~contractName=Types.SweepStakesNFTs.contractName,
      ~eventName=Types.SweepStakesNFTs.Unstake.name,
      ~handlerRegister=Types.SweepStakesNFTs.Unstake.handlerRegister,
      ~paramsRawEventSchema=Types.SweepStakesNFTs.Unstake.paramsRawEventSchema,
    )

    @genType
    type createMockArgs = {
      @as("_tokenId")
      _tokenId?: bigint,
      @as("_amount")
      _amount?: bigint,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?_tokenId,
        ?_amount,
        ?mockEventData,
      } = args

      let params: Types.SweepStakesNFTs.Unstake.eventArgs = 
      {
       _tokenId: _tokenId->Belt.Option.getWithDefault(0n),
       _amount: _amount->Belt.Option.getWithDefault(0n),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module WinnerAssigned = {
    @genType
    let processEvent = EventFunctions.makeEventProcessor(
      ~contractName=Types.SweepStakesNFTs.contractName,
      ~eventName=Types.SweepStakesNFTs.WinnerAssigned.name,
      ~handlerRegister=Types.SweepStakesNFTs.WinnerAssigned.handlerRegister,
      ~paramsRawEventSchema=Types.SweepStakesNFTs.WinnerAssigned.paramsRawEventSchema,
    )

    @genType
    type createMockArgs = {
      @as("winningTicket")
      winningTicket?: bigint,
      @as("_winner")
      _winner?: bigint,
      @as("_amount")
      _amount?: bigint,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?winningTicket,
        ?_winner,
        ?_amount,
        ?mockEventData,
      } = args

      let params: Types.SweepStakesNFTs.WinnerAssigned.eventArgs = 
      {
       winningTicket: winningTicket->Belt.Option.getWithDefault(0n),
       _winner: _winner->Belt.Option.getWithDefault(0n),
       _amount: _amount->Belt.Option.getWithDefault(0n),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module Withdraw = {
    @genType
    let processEvent = EventFunctions.makeEventProcessor(
      ~contractName=Types.SweepStakesNFTs.contractName,
      ~eventName=Types.SweepStakesNFTs.Withdraw.name,
      ~handlerRegister=Types.SweepStakesNFTs.Withdraw.handlerRegister,
      ~paramsRawEventSchema=Types.SweepStakesNFTs.Withdraw.paramsRawEventSchema,
    )

    @genType
    type createMockArgs = {
      @as("_tokenId")
      _tokenId?: bigint,
      @as("_amount")
      _amount?: bigint,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?_tokenId,
        ?_amount,
        ?mockEventData,
      } = args

      let params: Types.SweepStakesNFTs.Withdraw.eventArgs = 
      {
       _tokenId: _tokenId->Belt.Option.getWithDefault(0n),
       _amount: _amount->Belt.Option.getWithDefault(0n),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

}

