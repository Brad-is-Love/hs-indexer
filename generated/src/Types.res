//*************
//***ENTITIES**
//*************
@genType.as("Id")
type id = string

@genType
type contractRegistrations = {
  // TODO: only add contracts we've registered for the event in the config
  addSweepStakesNFTs: (Address.t) => unit,
}

@genType
type entityLoaderContext<'entity, 'indexedFieldOperations> = {
  get: id => promise<option<'entity>>,
  getWhere: 'indexedFieldOperations,
}

@genType
type loaderContext = {
  log: Logs.userLogger,
  @as("ContractTotals") contractTotals: entityLoaderContext<Entities.ContractTotals.t, Entities.ContractTotals.indexedFieldOperations>,
  @as("SweepStakesNFTs_Enter") sweepStakesNFTs_Enter: entityLoaderContext<Entities.SweepStakesNFTs_Enter.t, Entities.SweepStakesNFTs_Enter.indexedFieldOperations>,
  @as("SweepStakesNFTs_Transfer") sweepStakesNFTs_Transfer: entityLoaderContext<Entities.SweepStakesNFTs_Transfer.t, Entities.SweepStakesNFTs_Transfer.indexedFieldOperations>,
  @as("SweepStakesNFTs_Unstake") sweepStakesNFTs_Unstake: entityLoaderContext<Entities.SweepStakesNFTs_Unstake.t, Entities.SweepStakesNFTs_Unstake.indexedFieldOperations>,
  @as("SweepStakesNFTs_WinnerAssigned") sweepStakesNFTs_WinnerAssigned: entityLoaderContext<Entities.SweepStakesNFTs_WinnerAssigned.t, Entities.SweepStakesNFTs_WinnerAssigned.indexedFieldOperations>,
  @as("SweepStakesNFTs_Withdraw") sweepStakesNFTs_Withdraw: entityLoaderContext<Entities.SweepStakesNFTs_Withdraw.t, Entities.SweepStakesNFTs_Withdraw.indexedFieldOperations>,
  @as("Token") token: entityLoaderContext<Entities.Token.t, Entities.Token.indexedFieldOperations>,
  @as("User") user: entityLoaderContext<Entities.User.t, Entities.User.indexedFieldOperations>,
}

@genType
type entityHandlerContext<'entity> = {
  get: id => promise<option<'entity>>,
  set: 'entity => unit,
  deleteUnsafe: id => unit,
}


@genType
type handlerContext = {
  log: Logs.userLogger,
  @as("ContractTotals") contractTotals: entityHandlerContext<Entities.ContractTotals.t>,
  @as("SweepStakesNFTs_Enter") sweepStakesNFTs_Enter: entityHandlerContext<Entities.SweepStakesNFTs_Enter.t>,
  @as("SweepStakesNFTs_Transfer") sweepStakesNFTs_Transfer: entityHandlerContext<Entities.SweepStakesNFTs_Transfer.t>,
  @as("SweepStakesNFTs_Unstake") sweepStakesNFTs_Unstake: entityHandlerContext<Entities.SweepStakesNFTs_Unstake.t>,
  @as("SweepStakesNFTs_WinnerAssigned") sweepStakesNFTs_WinnerAssigned: entityHandlerContext<Entities.SweepStakesNFTs_WinnerAssigned.t>,
  @as("SweepStakesNFTs_Withdraw") sweepStakesNFTs_Withdraw: entityHandlerContext<Entities.SweepStakesNFTs_Withdraw.t>,
  @as("Token") token: entityHandlerContext<Entities.Token.t>,
  @as("User") user: entityHandlerContext<Entities.User.t>,
}

//Re-exporting types for backwards compatability
@genType.as("ContractTotals")
type contractTotals = Entities.ContractTotals.t
@genType.as("SweepStakesNFTs_Enter")
type sweepStakesNFTs_Enter = Entities.SweepStakesNFTs_Enter.t
@genType.as("SweepStakesNFTs_Transfer")
type sweepStakesNFTs_Transfer = Entities.SweepStakesNFTs_Transfer.t
@genType.as("SweepStakesNFTs_Unstake")
type sweepStakesNFTs_Unstake = Entities.SweepStakesNFTs_Unstake.t
@genType.as("SweepStakesNFTs_WinnerAssigned")
type sweepStakesNFTs_WinnerAssigned = Entities.SweepStakesNFTs_WinnerAssigned.t
@genType.as("SweepStakesNFTs_Withdraw")
type sweepStakesNFTs_Withdraw = Entities.SweepStakesNFTs_Withdraw.t
@genType.as("Token")
type token = Entities.Token.t
@genType.as("User")
type user = Entities.User.t

type eventIdentifier = {
  chainId: int,
  blockTimestamp: int,
  blockNumber: int,
  logIndex: int,
}

type entityUpdateAction<'entityType> =
  | Set('entityType)
  | Delete

type entityUpdate<'entityType> = {
  eventIdentifier: eventIdentifier,
  entityId: id,
  entityUpdateAction: entityUpdateAction<'entityType>,
}

let mkEntityUpdate = (~eventIdentifier, ~entityId, entityUpdateAction) => {
  entityId,
  eventIdentifier,
  entityUpdateAction,
}

type entityValueAtStartOfBatch<'entityType> =
  | NotSet // The entity isn't in the DB yet
  | AlreadySet('entityType)

type updatedValue<'entityType> = {
  latest: entityUpdate<'entityType>,
  history: array<entityUpdate<'entityType>>,
}

@genType
type inMemoryStoreRowEntity<'entityType> =
  | Updated(updatedValue<'entityType>)
  | InitialReadFromDb(entityValueAtStartOfBatch<'entityType>) // This means there is no change from the db.

//*************
//**CONTRACTS**
//*************

module Log = {
  type t = {
    address: Address.t,
    data: string,
    topics: array<EvmTypes.Hex.t>,
    logIndex: int,
  }

  let fieldNames = ["address", "data", "topics", "logIndex"]
}

module Transaction = {
  @genType
  type t = {}

  let schema = S.object((_): t => {})
}

module Block = {
  @genType
  type t = {number: int, timestamp: int, hash: string}

  type rawEventFields = {number: int, timestamp: int, hash: string}

  let schema = S.object((s): t => {number: s.field("number", GqlDbCustomTypes.Int.schema), timestamp: s.field("timestamp", GqlDbCustomTypes.Int.schema), hash: s.field("hash", S.string)})

  let rawEventSchema = S.object((s): rawEventFields => {number: s.field("number", GqlDbCustomTypes.Int.schema), timestamp: s.field("timestamp", GqlDbCustomTypes.Int.schema), hash: s.field("hash", S.string)})

  @get
  external getNumber: t => int = "number"

  @get
  external getTimestamp: t => int = "timestamp"
 
  @get
  external getId: t => string = "hash"

}

@genType.as("EventLog")
type eventLog<'a> = {
  params: 'a,
  chainId: int,
  srcAddress: Address.t,
  logIndex: int,
  transaction: Transaction.t,
  block: Block.t,
}

module SingleOrMultiple: {
  @genType.import(("./bindings/OpaqueTypes", "SingleOrMultiple"))
  type t<'a>
  let normalizeOrThrow: (t<'a>, ~nestedArrayDepth: int=?) => array<'a>
  let single: 'a => t<'a>
  let multiple: array<'a> => t<'a>
} = {
  type t<'a> = Js.Json.t

  external single: 'a => t<'a> = "%identity"
  external multiple: array<'a> => t<'a> = "%identity"
  external castMultiple: t<'a> => array<'a> = "%identity"
  external castSingle: t<'a> => 'a = "%identity"

  exception AmbiguousEmptyNestedArray

  let rec isMultiple = (t: t<'a>, ~nestedArrayDepth): bool =>
    switch t->Js.Json.decodeArray {
    | None => false
    | Some(_arr) if nestedArrayDepth == 0 => true
    | Some([]) if nestedArrayDepth > 0 =>
      AmbiguousEmptyNestedArray->ErrorHandling.mkLogAndRaise(
        ~msg="The given empty array could be interperated as a flat array (value) or nested array. Since it's ambiguous,
        please pass in a nested empty array if the intention is to provide an empty array as a value",
      )
    | Some(arr) => arr->Js.Array2.unsafe_get(0)->isMultiple(~nestedArrayDepth=nestedArrayDepth - 1)
    }

  let normalizeOrThrow = (t: t<'a>, ~nestedArrayDepth=0): array<'a> => {
    if t->isMultiple(~nestedArrayDepth) {
      t->castMultiple
    } else {
      [t->castSingle]
    }
  }
}

module HandlerTypes = {
  @genType
  type args<'eventArgs, 'context> = {
    event: eventLog<'eventArgs>,
    context: 'context,
  }

  @genType
  type contractRegisterArgs<'eventArgs> = args<'eventArgs, contractRegistrations>
  @genType
  type contractRegister<'eventArgs> = contractRegisterArgs<'eventArgs> => unit

  @genType
  type loaderArgs<'eventArgs> = args<'eventArgs, loaderContext>
  @genType
  type loader<'eventArgs, 'loaderReturn> = loaderArgs<'eventArgs> => promise<'loaderReturn>

  @genType
  type handlerArgs<'eventArgs, 'loaderReturn> = {
    event: eventLog<'eventArgs>,
    context: handlerContext,
    loaderReturn: 'loaderReturn,
  }

  @genType
  type handler<'eventArgs, 'loaderReturn> = handlerArgs<'eventArgs, 'loaderReturn> => promise<unit>

  @genType
  type loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter> = {
    loader: loader<'eventArgs, 'loaderReturn>,
    handler: handler<'eventArgs, 'loaderReturn>,
    wildcard?: bool,
    eventFilters?: SingleOrMultiple.t<'eventFilter>,
    preRegisterDynamicContracts?: bool,
  }

  @genType
  type eventConfig<'eventFilter> = {
    wildcard?: bool,
    eventFilters?: SingleOrMultiple.t<'eventFilter>,
    preRegisterDynamicContracts?: bool,
  }

  module EventOptions = {
    type t = {
      isWildcard: bool,
      topicSelections: array<LogSelection.topicSelection>,
      preRegisterDynamicContracts: bool,
    }

    let getDefault = (~topic0) => {
      isWildcard: false,
      topicSelections: [LogSelection.makeTopicSelection(~topic0=[topic0])->Utils.unwrapResultExn],
      preRegisterDynamicContracts: false,
    }

    let make = (
      ~isWildcard,
      ~topicSelections: array<LogSelection.topicSelection>,
      ~preRegisterDynamicContracts,
    ) => {
      let topic0sGrouped = []
      let topicSelectionWithFilters = []
      topicSelections->Belt.Array.forEach(ts =>
        if ts->LogSelection.hasFilters {
          topicSelectionWithFilters->Js.Array2.push(ts)->ignore
        } else {
          ts.topic0->Belt.Array.forEach(topic0 => {
            topic0sGrouped->Js.Array2.push(topic0)->ignore
          })
        }
      )
      let topicSelections = switch topic0sGrouped {
      | [] => topicSelectionWithFilters
      | topic0sGrouped =>
        [
          LogSelection.makeTopicSelection(~topic0=topic0sGrouped)->Utils.unwrapResultExn,
        ]->Belt.Array.concat(topicSelectionWithFilters)
      }

      {
        isWildcard,
        topicSelections,
        preRegisterDynamicContracts,
      }
    }
  }

  type registeredEvent<'eventArgs, 'loaderReturn, 'eventFilter> = {
    loaderHandler?: loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter>,
    contractRegister?: contractRegister<'eventArgs>,
    eventOptions: EventOptions.t,
  }

  module Register: {
    type t<'eventArgs>
    let make: (~topic0: EvmTypes.Hex.t, ~contractName: string, ~eventName: string) => t<'eventArgs>
    let setLoaderHandler: (
      t<'eventArgs>,
      loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter>,
      ~getEventOptions: loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter> => option<
        EventOptions.t,
      >,
      ~logger: Pino.t=?,
    ) => unit
    let setContractRegister: (
      t<'eventArgs>,
      contractRegister<'eventArgs>,
      ~eventOptions: option<EventOptions.t>,
      ~logger: Pino.t=?,
    ) => unit
    let getLoaderHandler: t<'eventArgs> => option<
      loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter>,
    >
    let getContractRegister: t<'eventArgs> => option<contractRegister<'eventArgs>>
    let getEventOptions: t<'eventArgs> => EventOptions.t
    let hasRegistration: t<'eventArgs> => bool
  } = {
    type loaderReturn
    type eventFilter

    type t<'eventArgs> = {
      contractName: string,
      eventName: string,
      topic0: EvmTypes.Hex.t,
      mutable loaderHandler: option<loaderHandler<'eventArgs, loaderReturn, eventFilter>>,
      mutable contractRegister: option<contractRegister<'eventArgs>>,
      mutable eventOptions: option<EventOptions.t>,
    }

    let getLoaderHandler = (t: t<'eventArgs>): option<
      loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter>,
    > =>
      t.loaderHandler->(
        Utils.magic: option<loaderHandler<'eventArgs, loaderReturn, eventFilter>> => option<
          loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter>,
        >
      )

    let getContractRegister = (t: t<'eventArgs>): option<contractRegister<'eventArgs>> =>
      t.contractRegister

    let getEventOptions = ({eventOptions, topic0}: t<'eventArgs>): EventOptions.t =>
      switch eventOptions {
      | Some(eventOptions) => eventOptions
      | None => EventOptions.getDefault(~topic0)
      }

    let hasRegistration = ({loaderHandler, contractRegister}) =>
      loaderHandler->Belt.Option.isSome || contractRegister->Belt.Option.isSome

    let make = (~topic0, ~contractName, ~eventName) => {
      contractName,
      eventName,
      topic0,
      loaderHandler: None,
      contractRegister: None,
      eventOptions: None,
    }

    type eventNamespace = {contractName: string, eventName: string}
    exception DuplicateEventRegistration(eventNamespace)

    let setEventOptions = (t: t<'eventArgs>, value: EventOptions.t, ~logger=Logging.logger) => {
      switch t.eventOptions {
      | None => t.eventOptions = Some(value)
      | Some(_) =>
        let eventNamespace = {contractName: t.contractName, eventName: t.eventName}
        DuplicateEventRegistration(eventNamespace)->ErrorHandling.mkLogAndRaise(
          ~logger=Logging.createChildFrom(~logger, ~params=eventNamespace),
          ~msg="Duplicate eventOptions in handlers not allowed",
        )
      }
    }

    let setLoaderHandler = (
      t: t<'eventArgs>,
      value: loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter>,
      ~getEventOptions,
      ~logger=Logging.logger,
    ) => {
      switch t.loaderHandler {
      | None =>
        t.loaderHandler =
          value
          ->(Utils.magic: loaderHandler<'eventArgs, 'loaderReturn, 'eventFilter> => loaderHandler<
            'eventArgs,
            loaderReturn,
            eventFilter,
          >)
          ->Some
      | Some(_) =>
        let eventNamespace = {contractName: t.contractName, eventName: t.eventName}
        DuplicateEventRegistration(eventNamespace)->ErrorHandling.mkLogAndRaise(
          ~logger=Logging.createChildFrom(~logger, ~params=eventNamespace),
          ~msg="Duplicate registration of event handlers not allowed",
        )
      }

      switch getEventOptions(value) {
      | Some(eventOptions) => t->setEventOptions(eventOptions, ~logger)
      | None => ()
      }
    }

    let setContractRegister = (
      t: t<'eventArgs>,
      value: contractRegister<'eventArgs>,
      ~eventOptions,
      ~logger=Logging.logger,
    ) => {
      switch t.contractRegister {
      | None => t.contractRegister = Some(value)
      | Some(_) =>
        let eventNamespace = {contractName: t.contractName, eventName: t.eventName}
        DuplicateEventRegistration(eventNamespace)->ErrorHandling.mkLogAndRaise(
          ~logger=Logging.createChildFrom(~logger, ~params=eventNamespace),
          ~msg="Duplicate contractRegister handlers not allowed",
        )
      }
      switch eventOptions {
      | Some(eventOptions) => t->setEventOptions(eventOptions, ~logger)
      | None => ()
      }
    }
  }
}

type internalEventArgs

module type Event = {
  let sighash: string // topic0 for Evm and rb for Fuel receipts
  let topicCount: int // Number of topics for evm, always 0 for fuel
  let name: string
  let contractName: string

  type eventArgs
  let paramsRawEventSchema: S.schema<eventArgs>
  let convertHyperSyncEventArgs: HyperSyncClient.Decoder.decodedEvent => eventArgs
  let handlerRegister: HandlerTypes.Register.t<eventArgs>

  type eventFilter
  let getTopicSelection: SingleOrMultiple.t<eventFilter> => array<LogSelection.topicSelection>
}
module type InternalEvent = Event with type eventArgs = internalEventArgs

external eventToInternal: eventLog<'a> => eventLog<internalEventArgs> = "%identity"
external eventModToInternal: module(Event with type eventArgs = 'a) => module(InternalEvent) = "%identity"
external eventModWithoutArgTypeToInternal: module(Event) => module(InternalEvent) = "%identity"

let makeEventOptions = (
  type eventFilter,
  eventConfig: option<HandlerTypes.eventConfig<eventFilter>>,
  eventMod: module(Event with type eventFilter = eventFilter),
) => {
  let module(Event) = eventMod
  open Belt
  eventConfig->Option.map(({?wildcard, ?eventFilters, ?preRegisterDynamicContracts}) =>
    HandlerTypes.EventOptions.make(
      ~isWildcard=wildcard->Option.getWithDefault(false),
      ~topicSelections=eventFilters->Option.mapWithDefault(
        [
          LogSelection.makeTopicSelection(
            ~topic0=[Event.sighash->EvmTypes.Hex.fromStringUnsafe],
          )->Utils.unwrapResultExn,
        ],
        v => v->Event.getTopicSelection,
      ),
      ~preRegisterDynamicContracts=preRegisterDynamicContracts->Option.getWithDefault(false),
    )
  )
}

let makeGetEventOptions = (
  type eventFilter eventArgs,
  eventMod: module(Event with type eventFilter = eventFilter and type eventArgs = eventArgs),
) => {
  open Belt
  let module(Event) = eventMod
  (loaderHandler: HandlerTypes.loaderHandler<Event.eventArgs, 'loaderReturn, Event.eventFilter>) =>
    switch loaderHandler {
    | {wildcard: ?None, eventFilters: ?None, preRegisterDynamicContracts: ?None} => None
    | {?wildcard, ?eventFilters, ?preRegisterDynamicContracts} =>
      let topicSelections =
        eventFilters->Option.mapWithDefault(
          [
            LogSelection.makeTopicSelection(
              ~topic0=[Event.sighash->EvmTypes.Hex.fromStringUnsafe],
            )->Utils.unwrapResultExn,
          ],
          v => v->Event.getTopicSelection,
        )
      HandlerTypes.EventOptions.make(
        ~isWildcard=wildcard->Option.getWithDefault(false),
        ~topicSelections,
        ~preRegisterDynamicContracts=preRegisterDynamicContracts->Option.getWithDefault(false),
      )->Some
    }
}

@genType.import(("./bindings/OpaqueTypes.ts", "HandlerWithOptions"))
type fnWithEventConfig<'fn, 'eventConfig> = ('fn, ~eventConfig: 'eventConfig=?) => unit

@genType
type handlerWithOptions<'eventArgs, 'loaderReturn, 'eventFilter> = fnWithEventConfig<
  HandlerTypes.handler<'eventArgs, 'loaderReturn>,
  HandlerTypes.eventConfig<'eventFilter>,
>

@genType
type contractRegisterWithOptions<'eventArgs, 'eventFilter> = fnWithEventConfig<
  HandlerTypes.contractRegister<'eventArgs>,
  HandlerTypes.eventConfig<'eventFilter>,
>

module MakeRegister = (Event: Event) => {
  let handler: handlerWithOptions<Event.eventArgs, unit, Event.eventFilter> = (
    handler,
    ~eventConfig=?,
  ) => {
    Event.handlerRegister->HandlerTypes.Register.setLoaderHandler(
      {
        loader: _ => Promise.resolve(),
        handler,
        wildcard: ?eventConfig->Belt.Option.flatMap(c => c.wildcard),
        eventFilters: ?eventConfig->Belt.Option.flatMap(c => c.eventFilters),
        preRegisterDynamicContracts: ?eventConfig->Belt.Option.flatMap(c =>
          c.preRegisterDynamicContracts
        ),
      },
      ~getEventOptions=makeGetEventOptions(module(Event)),
    )
  }

  let contractRegister: contractRegisterWithOptions<Event.eventArgs, Event.eventFilter> = (
    contractRegister,
    ~eventConfig=?,
  ) =>
    Event.handlerRegister->HandlerTypes.Register.setContractRegister(
      contractRegister,
      ~eventOptions=makeEventOptions(eventConfig, module(Event)),
    )

  let handlerWithLoader = args =>
    Event.handlerRegister->HandlerTypes.Register.setLoaderHandler(
      args,
      ~getEventOptions=makeGetEventOptions(module(Event)),
    )
}

type fuelEventKind = 
  | LogData({
    logId: string,
    decode: string => internalEventArgs,
  })
  | Mint
  | Burn
  | Transfer
  | Call

type fuelEventConfig = {
  name: string,
  kind: fuelEventKind,
  isWildcard: bool,
  handlerRegister: HandlerTypes.Register.t<internalEventArgs>,
  paramsRawEventSchema: S.schema<internalEventArgs>,
}

type fuelContractConfig = {
  name: string,
  events: array<fuelEventConfig>,
}

type fuelSupplyParams = {
  subId: string,
  amount: bigint,
}

let fuelSupplyParamsSchema = S.object(s => {
  subId: s.field("subId", S.string),
  amount: s.field("amount", BigInt.schema),
})

type fuelTransferParams = {
  to: Address.t,
  assetId: string,
  amount: bigint,
}

let fuelTransferParamsSchema = S.object(s => {
  to: s.field("to", Address.schema),
  assetId: s.field("assetId", S.string),
  amount: s.field("amount", BigInt.schema),
})

module SweepStakesNFTs = {
let abi = Ethers.makeAbi((%raw(`[{"type":"event","name":"Enter","inputs":[{"name":"_tokenId","type":"uint256","indexed":true},{"name":"_amount","type":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"name":"from","type":"address","indexed":true},{"name":"to","type":"address","indexed":true},{"name":"tokenId","type":"uint256","indexed":true}],"anonymous":false},{"type":"event","name":"Unstake","inputs":[{"name":"_tokenId","type":"uint256","indexed":true},{"name":"_amount","type":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"WinnerAssigned","inputs":[{"name":"winningTicket","type":"uint256","indexed":false},{"name":"_winner","type":"uint256","indexed":true},{"name":"_amount","type":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Withdraw","inputs":[{"name":"_tokenId","type":"uint256","indexed":true},{"name":"_amount","type":"uint256","indexed":false}],"anonymous":false}]`): Js.Json.t))
let eventSignatures = ["Enter(uint256 indexed _tokenId, uint256 _amount)", "Transfer(address indexed from, address indexed to, uint256 indexed tokenId)", "Unstake(uint256 indexed _tokenId, uint256 _amount)", "WinnerAssigned(uint256 winningTicket, uint256 indexed _winner, uint256 _amount)", "Withdraw(uint256 indexed _tokenId, uint256 _amount)"]
let contractName = "SweepStakesNFTs"

module Enter = {

let sighash = "0xd4a5c7ae4a46d5c461c6ff68c62eaa769cf4622df3a057e8684b47237f33bbbb"
let topicCount = 2
let name = "Enter"
let contractName = contractName

@genType
type eventArgs = {_tokenId: bigint, _amount: bigint}
let paramsRawEventSchema = S.object((s): eventArgs => {_tokenId: s.field("_tokenId", BigInt.schema), _amount: s.field("_amount", BigInt.schema)})
let convertHyperSyncEventArgs = (decodedEvent: HyperSyncClient.Decoder.decodedEvent): eventArgs => {
      {
        _tokenId: decodedEvent.indexed->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
        _amount: decodedEvent.body->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
      }
    }

let handlerRegister: HandlerTypes.Register.t<eventArgs> = HandlerTypes.Register.make(
  ~topic0=sighash->EvmTypes.Hex.fromStringUnsafe,
  ~contractName,
  ~eventName=name,
)

@genType
type eventFilter = { @as("_tokenId") _tokenId?: SingleOrMultiple.t<bigint> }

let getTopicSelection = (eventFilters) => eventFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(_eventFilter => LogSelection.makeTopicSelection(~topic0=[sighash->EvmTypes.Hex.fromStringUnsafe], ~topic1=?_eventFilter._tokenId->Belt.Option.map(topicFilters => topicFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(TopicFilter.fromBigInt)), )->Utils.unwrapResultExn)

}

module Transfer = {

let sighash = "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef"
let topicCount = 4
let name = "Transfer"
let contractName = contractName

@genType
type eventArgs = {from: Address.t, to: Address.t, tokenId: bigint}
let paramsRawEventSchema = S.object((s): eventArgs => {from: s.field("from", Address.schema), to: s.field("to", Address.schema), tokenId: s.field("tokenId", BigInt.schema)})
let convertHyperSyncEventArgs = (decodedEvent: HyperSyncClient.Decoder.decodedEvent): eventArgs => {
      {
        from: decodedEvent.indexed->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
        to: decodedEvent.indexed->Js.Array2.unsafe_get(1)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
        tokenId: decodedEvent.indexed->Js.Array2.unsafe_get(2)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
      }
    }

let handlerRegister: HandlerTypes.Register.t<eventArgs> = HandlerTypes.Register.make(
  ~topic0=sighash->EvmTypes.Hex.fromStringUnsafe,
  ~contractName,
  ~eventName=name,
)

@genType
type eventFilter = { @as("from") from?: SingleOrMultiple.t<Address.t>, @as("to") to?: SingleOrMultiple.t<Address.t>, @as("tokenId") tokenId?: SingleOrMultiple.t<bigint> }

let getTopicSelection = (eventFilters) => eventFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(_eventFilter => LogSelection.makeTopicSelection(~topic0=[sighash->EvmTypes.Hex.fromStringUnsafe], ~topic1=?_eventFilter.from->Belt.Option.map(topicFilters => topicFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(TopicFilter.fromAddress)), ~topic2=?_eventFilter.to->Belt.Option.map(topicFilters => topicFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(TopicFilter.fromAddress)), ~topic3=?_eventFilter.tokenId->Belt.Option.map(topicFilters => topicFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(TopicFilter.fromBigInt)), )->Utils.unwrapResultExn)

}

module Unstake = {

let sighash = "0x9045c2ac9b2026de8075f2701bbdde882cd5e830b3b1ead9a15b22f2b5b93742"
let topicCount = 2
let name = "Unstake"
let contractName = contractName

@genType
type eventArgs = {_tokenId: bigint, _amount: bigint}
let paramsRawEventSchema = S.object((s): eventArgs => {_tokenId: s.field("_tokenId", BigInt.schema), _amount: s.field("_amount", BigInt.schema)})
let convertHyperSyncEventArgs = (decodedEvent: HyperSyncClient.Decoder.decodedEvent): eventArgs => {
      {
        _tokenId: decodedEvent.indexed->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
        _amount: decodedEvent.body->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
      }
    }

let handlerRegister: HandlerTypes.Register.t<eventArgs> = HandlerTypes.Register.make(
  ~topic0=sighash->EvmTypes.Hex.fromStringUnsafe,
  ~contractName,
  ~eventName=name,
)

@genType
type eventFilter = { @as("_tokenId") _tokenId?: SingleOrMultiple.t<bigint> }

let getTopicSelection = (eventFilters) => eventFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(_eventFilter => LogSelection.makeTopicSelection(~topic0=[sighash->EvmTypes.Hex.fromStringUnsafe], ~topic1=?_eventFilter._tokenId->Belt.Option.map(topicFilters => topicFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(TopicFilter.fromBigInt)), )->Utils.unwrapResultExn)

}

module WinnerAssigned = {

let sighash = "0x4cb2486ce1957771d0897dc9c91c5b155ff8fa1c6ca829a8ab8b9ce9af89d186"
let topicCount = 2
let name = "WinnerAssigned"
let contractName = contractName

@genType
type eventArgs = {winningTicket: bigint, _winner: bigint, _amount: bigint}
let paramsRawEventSchema = S.object((s): eventArgs => {winningTicket: s.field("winningTicket", BigInt.schema), _winner: s.field("_winner", BigInt.schema), _amount: s.field("_amount", BigInt.schema)})
let convertHyperSyncEventArgs = (decodedEvent: HyperSyncClient.Decoder.decodedEvent): eventArgs => {
      {
        _winner: decodedEvent.indexed->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
        winningTicket: decodedEvent.body->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
        _amount: decodedEvent.body->Js.Array2.unsafe_get(1)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
      }
    }

let handlerRegister: HandlerTypes.Register.t<eventArgs> = HandlerTypes.Register.make(
  ~topic0=sighash->EvmTypes.Hex.fromStringUnsafe,
  ~contractName,
  ~eventName=name,
)

@genType
type eventFilter = { @as("_winner") _winner?: SingleOrMultiple.t<bigint> }

let getTopicSelection = (eventFilters) => eventFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(_eventFilter => LogSelection.makeTopicSelection(~topic0=[sighash->EvmTypes.Hex.fromStringUnsafe], ~topic1=?_eventFilter._winner->Belt.Option.map(topicFilters => topicFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(TopicFilter.fromBigInt)), )->Utils.unwrapResultExn)

}

module Withdraw = {

let sighash = "0x56ca301a9219608c91e7bcee90e083c19671d2cdcc96752c7af291cee5f9c8c8"
let topicCount = 2
let name = "Withdraw"
let contractName = contractName

@genType
type eventArgs = {_tokenId: bigint, _amount: bigint}
let paramsRawEventSchema = S.object((s): eventArgs => {_tokenId: s.field("_tokenId", BigInt.schema), _amount: s.field("_amount", BigInt.schema)})
let convertHyperSyncEventArgs = (decodedEvent: HyperSyncClient.Decoder.decodedEvent): eventArgs => {
      {
        _tokenId: decodedEvent.indexed->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
        _amount: decodedEvent.body->Js.Array2.unsafe_get(0)->HyperSyncClient.Decoder.toUnderlying->Utils.magic,
      }
    }

let handlerRegister: HandlerTypes.Register.t<eventArgs> = HandlerTypes.Register.make(
  ~topic0=sighash->EvmTypes.Hex.fromStringUnsafe,
  ~contractName,
  ~eventName=name,
)

@genType
type eventFilter = { @as("_tokenId") _tokenId?: SingleOrMultiple.t<bigint> }

let getTopicSelection = (eventFilters) => eventFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(_eventFilter => LogSelection.makeTopicSelection(~topic0=[sighash->EvmTypes.Hex.fromStringUnsafe], ~topic1=?_eventFilter._tokenId->Belt.Option.map(topicFilters => topicFilters->SingleOrMultiple.normalizeOrThrow->Belt.Array.map(TopicFilter.fromBigInt)), )->Utils.unwrapResultExn)

}
}

@genType
type chainId = int

type eventBatchQueueItem = {
  eventName: string,
  contractName: string,
  handlerRegister: HandlerTypes.Register.t<internalEventArgs>,
  timestamp: int,
  chain: ChainMap.Chain.t,
  blockNumber: int,
  logIndex: int,
  event: eventLog<internalEventArgs>,
  paramsRawEventSchema: S.schema<internalEventArgs>,
  //Default to false, if an event needs to
  //be reprocessed after it has loaded dynamic contracts
  //This gets set to true and does not try and reload events
  hasRegisteredDynamicContracts?: bool,
}
