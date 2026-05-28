open Types

/**
The context holds all the state for a given events loader and handler.
*/
type t = {
  logger: Pino.t,
  eventBatchQueueItem: Types.eventBatchQueueItem,
  addedDynamicContractRegistrations: array<TablesStatic.DynamicContractRegistry.t>,
}

let getUserLogger = (logger): Logs.userLogger => {
  info: (message: string) => logger->Logging.uinfo(message),
  debug: (message: string) => logger->Logging.udebug(message),
  warn: (message: string) => logger->Logging.uwarn(message),
  error: (message: string) => logger->Logging.uerror(message),
  errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
    logger->Logging.uerrorWithExn(exn, message),
}

let makeEventIdentifier = (
  eventBatchQueueItem: Types.eventBatchQueueItem,
): Types.eventIdentifier => {
  let {event, blockNumber, timestamp} = eventBatchQueueItem
  {
    chainId: event.chainId,
    blockTimestamp: timestamp,
    blockNumber,
    logIndex: event.logIndex,
  }
}

let getEventId = (eventBatchQueueItem: Types.eventBatchQueueItem) => {
  EventUtils.packEventIndex(
    ~blockNumber=eventBatchQueueItem.blockNumber,
    ~logIndex=eventBatchQueueItem.event.logIndex,
  )
}

let make = (~eventBatchQueueItem: Types.eventBatchQueueItem, ~logger) => {
  let {event, chain, eventName, contractName, blockNumber} = eventBatchQueueItem
  let logger = logger->(
    Logging.createChildFrom(
      ~logger=_,
      ~params={
        "context": `Event '${eventName}' for contract '${contractName}'`,
        "chainId": chain->ChainMap.Chain.toChainId,
        "block": blockNumber,
        "logIndex": event.logIndex,
      },
    )
  )

  {
    logger,
    eventBatchQueueItem,
    addedDynamicContractRegistrations: [],
  }
}

let getAddedDynamicContractRegistrations = (contextEnv: t) =>
  contextEnv.addedDynamicContractRegistrations

let makeDynamicContractId = (~chainId, ~contractAddress) => {
  chainId->Belt.Int.toString ++ "-" ++ contractAddress->Address.toString
}
let makeDynamicContractRegisterFn = (
  ~contextEnv: t,
  ~contractName,
  ~inMemoryStore,
  ~shouldSaveHistory,
) => (contractAddress: Address.t) => {
   
  // Even though it's the Address.t type on ReScript side, for TS side it's a string.
  // So we need to ensure that it's a valid checksummed address.
  let contractAddress = contractAddress->Address.Evm.fromAddressOrThrow

  let {eventBatchQueueItem, addedDynamicContractRegistrations} = contextEnv
  let {chain, timestamp, blockNumber, logIndex} = eventBatchQueueItem

  let chainId = chain->ChainMap.Chain.toChainId
  let dynamicContractRegistration: TablesStatic.DynamicContractRegistry.t = {
    id: makeDynamicContractId(~chainId, ~contractAddress),
    chainId,
    registeringEventBlockNumber: blockNumber,
    registeringEventLogIndex: logIndex,
    registeringEventName: eventBatchQueueItem.eventName,
    registeringEventContractName: eventBatchQueueItem.contractName,
    registeringEventSrcAddress: eventBatchQueueItem.event.srcAddress,
    registeringEventBlockTimestamp: timestamp,
    contractAddress,
    contractType: contractName,
  }

  addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

  let eventIdentifier: Types.eventIdentifier = {
    chainId,
    blockTimestamp: timestamp,
    blockNumber,
    logIndex,
  }

  inMemoryStore.InMemoryStore.entities
  ->InMemoryStore.EntityTables.get(module(TablesStatic.DynamicContractRegistry))
  ->InMemoryTable.Entity.set(
    Set(dynamicContractRegistration)->Types.mkEntityUpdate(
      ~eventIdentifier,
      ~entityId=dynamicContractRegistration.id,
    ),
    ~shouldSaveHistory,
  )
}

let makeWhereLoader = (
  loadLayer,
  ~entityMod,
  ~inMemoryStore,
  ~fieldName,
  ~fieldValueSchema,
  ~logger,
) => {
  Entities.eq: loadLayer->LoadLayer.makeWhereEqLoader(
    ~entityMod,
    ~fieldName,
    ~fieldValueSchema,
    ~inMemoryStore,
    ~logger,
  ),
}

let makeEntityHandlerContext = (
  type entity,
  ~eventIdentifier,
  ~inMemoryStore,
  ~entityMod: module(Entities.Entity with type t = entity),
  ~logger,
  ~getKey,
  ~loadLayer,
  ~shouldSaveHistory,
): entityHandlerContext<entity> => {
  let inMemTable = inMemoryStore->InMemoryStore.getInMemTable(~entityMod)
  {
    set: entity => {
      inMemTable->InMemoryTable.Entity.set(
        Set(entity)->Types.mkEntityUpdate(~eventIdentifier, ~entityId=getKey(entity)),
        ~shouldSaveHistory,
      )
    },
    deleteUnsafe: entityId => {
      inMemTable->InMemoryTable.Entity.set(
        Delete->Types.mkEntityUpdate(~eventIdentifier, ~entityId),
        ~shouldSaveHistory,
      )
    },
    get: loadLayer->LoadLayer.makeLoader(~entityMod, ~logger, ~inMemoryStore),
  }
}

let getContractRegisterContext = (contextEnv, ~inMemoryStore, ~shouldSaveHistory) => {
  //TODO only add contracts we've registered for the event in the config
  addSweepStakesNFTs:  makeDynamicContractRegisterFn(~contextEnv, ~inMemoryStore, ~contractName=SweepStakesNFTs, ~shouldSaveHistory),
}

let getLoaderContext = (contextEnv: t, ~inMemoryStore: InMemoryStore.t, ~loadLayer: LoadLayer.t): loaderContext => {
  let {logger} = contextEnv
  {
    log: logger->getUserLogger,
    contractTotals: {
      get: loadLayer->LoadLayer.makeLoader(
        ~entityMod=module(Entities.ContractTotals),
        ~inMemoryStore,
        ~logger,
      ),
      getWhere: {
        
      },
    },
    sweepStakesNFTs_Enter: {
      get: loadLayer->LoadLayer.makeLoader(
        ~entityMod=module(Entities.SweepStakesNFTs_Enter),
        ~inMemoryStore,
        ~logger,
      ),
      getWhere: {
        
      },
    },
    sweepStakesNFTs_Transfer: {
      get: loadLayer->LoadLayer.makeLoader(
        ~entityMod=module(Entities.SweepStakesNFTs_Transfer),
        ~inMemoryStore,
        ~logger,
      ),
      getWhere: {
        
      },
    },
    sweepStakesNFTs_Unstake: {
      get: loadLayer->LoadLayer.makeLoader(
        ~entityMod=module(Entities.SweepStakesNFTs_Unstake),
        ~inMemoryStore,
        ~logger,
      ),
      getWhere: {
        
      },
    },
    sweepStakesNFTs_WinnerAssigned: {
      get: loadLayer->LoadLayer.makeLoader(
        ~entityMod=module(Entities.SweepStakesNFTs_WinnerAssigned),
        ~inMemoryStore,
        ~logger,
      ),
      getWhere: {
        
      },
    },
    sweepStakesNFTs_Withdraw: {
      get: loadLayer->LoadLayer.makeLoader(
        ~entityMod=module(Entities.SweepStakesNFTs_Withdraw),
        ~inMemoryStore,
        ~logger,
      ),
      getWhere: {
        
      },
    },
    token: {
      get: loadLayer->LoadLayer.makeLoader(
        ~entityMod=module(Entities.Token),
        ~inMemoryStore,
        ~logger,
      ),
      getWhere: {
        
        userAddress: loadLayer->makeWhereLoader(
          ~entityMod=module(Entities.Token),
          ~inMemoryStore,
          ~fieldName="userAddress",
          ~fieldValueSchema=S.string,
          ~logger,
        ),
      
      },
    },
    user: {
      get: loadLayer->LoadLayer.makeLoader(
        ~entityMod=module(Entities.User),
        ~inMemoryStore,
        ~logger,
      ),
      getWhere: {
        
      },
    },
  }
}

let getHandlerContext = (
  context,
  ~inMemoryStore: InMemoryStore.t,
  ~loadLayer,
  ~shouldSaveHistory,
) => {
  let {eventBatchQueueItem, logger} = context

  let eventIdentifier = eventBatchQueueItem->makeEventIdentifier
  {
    log: logger->getUserLogger,
    contractTotals: makeEntityHandlerContext(
      ~eventIdentifier,
      ~inMemoryStore,
      ~entityMod=module(Entities.ContractTotals),
      ~getKey=entity => entity.id,
      ~logger,
      ~loadLayer,
      ~shouldSaveHistory,
    ),
    sweepStakesNFTs_Enter: makeEntityHandlerContext(
      ~eventIdentifier,
      ~inMemoryStore,
      ~entityMod=module(Entities.SweepStakesNFTs_Enter),
      ~getKey=entity => entity.id,
      ~logger,
      ~loadLayer,
      ~shouldSaveHistory,
    ),
    sweepStakesNFTs_Transfer: makeEntityHandlerContext(
      ~eventIdentifier,
      ~inMemoryStore,
      ~entityMod=module(Entities.SweepStakesNFTs_Transfer),
      ~getKey=entity => entity.id,
      ~logger,
      ~loadLayer,
      ~shouldSaveHistory,
    ),
    sweepStakesNFTs_Unstake: makeEntityHandlerContext(
      ~eventIdentifier,
      ~inMemoryStore,
      ~entityMod=module(Entities.SweepStakesNFTs_Unstake),
      ~getKey=entity => entity.id,
      ~logger,
      ~loadLayer,
      ~shouldSaveHistory,
    ),
    sweepStakesNFTs_WinnerAssigned: makeEntityHandlerContext(
      ~eventIdentifier,
      ~inMemoryStore,
      ~entityMod=module(Entities.SweepStakesNFTs_WinnerAssigned),
      ~getKey=entity => entity.id,
      ~logger,
      ~loadLayer,
      ~shouldSaveHistory,
    ),
    sweepStakesNFTs_Withdraw: makeEntityHandlerContext(
      ~eventIdentifier,
      ~inMemoryStore,
      ~entityMod=module(Entities.SweepStakesNFTs_Withdraw),
      ~getKey=entity => entity.id,
      ~logger,
      ~loadLayer,
      ~shouldSaveHistory,
    ),
    token: makeEntityHandlerContext(
      ~eventIdentifier,
      ~inMemoryStore,
      ~entityMod=module(Entities.Token),
      ~getKey=entity => entity.id,
      ~logger,
      ~loadLayer,
      ~shouldSaveHistory,
    ),
    user: makeEntityHandlerContext(
      ~eventIdentifier,
      ~inMemoryStore,
      ~entityMod=module(Entities.User),
      ~getKey=entity => entity.id,
      ~logger,
      ~loadLayer,
      ~shouldSaveHistory,
    ),
  }
}

let getContractRegisterArgs = (contextEnv, ~inMemoryStore, ~shouldSaveHistory) => {
  Types.HandlerTypes.event: contextEnv.eventBatchQueueItem.event,
  context: contextEnv->getContractRegisterContext(~inMemoryStore, ~shouldSaveHistory),
}

let getLoaderArgs = (contextEnv, ~inMemoryStore, ~loadLayer) => {
  Types.HandlerTypes.event: contextEnv.eventBatchQueueItem.event,
  context: contextEnv->getLoaderContext(~inMemoryStore, ~loadLayer),
}

let getHandlerArgs = (
  contextEnv,
  ~inMemoryStore,
  ~loaderReturn,
  ~loadLayer,
  ~shouldSaveHistory,
) => {
  Types.HandlerTypes.event: contextEnv.eventBatchQueueItem.event,
  context: contextEnv->getHandlerContext(~inMemoryStore, ~loadLayer, ~shouldSaveHistory),
  loaderReturn,
}
