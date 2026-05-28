open Table
open Enums.EntityType
type id = string

type internalEntity
module type Entity = {
  type t
  let name: Enums.EntityType.t
  let schema: S.t<t>
  let rowsSchema: S.t<array<t>>
  let table: Table.table
  let entityHistory: EntityHistory.t<t>
}
module type InternalEntity = Entity with type t = internalEntity
external entityModToInternal: module(Entity with type t = 'a) => module(InternalEntity) = "%identity"
external entityModsToInternal: array<module(Entity)> => array<module(InternalEntity)> = "%identity"

@get
external getEntityId: internalEntity => string = "id"

exception UnexpectedIdNotDefinedOnEntity
let getEntityIdUnsafe = (entity: 'entity): id =>
  switch Utils.magic(entity)["id"] {
  | Some(id) => id
  | None =>
    UnexpectedIdNotDefinedOnEntity->ErrorHandling.mkLogAndRaise(
      ~msg="Property 'id' does not exist on expected entity object",
    )
  }

//shorthand for punning
let isPrimaryKey = true
let isNullable = true
let isArray = true
let isIndex = true

@genType
type whereOperations<'entity, 'fieldType> = {eq: 'fieldType => promise<array<'entity>>}

module ContractTotals = {
  let name = ContractTotals
  @genType
  type t = {
    balance: bigint,
    id: id,
    totalPrizes: bigint,
  }

  let schema = S.object((s): t => {
    balance: s.field("balance", BigInt.schema),
    id: s.field("id", S.string),
    totalPrizes: s.field("totalPrizes", BigInt.schema),
  })

  let rowsSchema = S.array(schema)

  @genType
  type indexedFieldOperations = {
    
  }

  let table = mkTable(
     (name :> string),
    ~fields=[
      mkField(
      "balance", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "id", 
      Text,
      ~isPrimaryKey,
      
      
      
      
      ),
      mkField(
      "totalPrizes", 
      Numeric,
      
      
      
      
      
      ),
      mkField("db_write_timestamp", TimestampWithoutTimezone, ~default="CURRENT_TIMESTAMP"),
    ],
  )

  let entityHistory = table->EntityHistory.fromTable(~schema)
}

module SweepStakesNFTs_Enter = {
  let name = SweepStakesNFTs_Enter
  @genType
  type t = {
    _amount: bigint,
    _tokenId: bigint,
    id: id,
    userAddress: string,
  }

  let schema = S.object((s): t => {
    _amount: s.field("_amount", BigInt.schema),
    _tokenId: s.field("_tokenId", BigInt.schema),
    id: s.field("id", S.string),
    userAddress: s.field("userAddress", S.string),
  })

  let rowsSchema = S.array(schema)

  @genType
  type indexedFieldOperations = {
    
  }

  let table = mkTable(
     (name :> string),
    ~fields=[
      mkField(
      "_amount", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "_tokenId", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "id", 
      Text,
      ~isPrimaryKey,
      
      
      
      
      ),
      mkField(
      "userAddress", 
      Text,
      
      
      
      
      
      ),
      mkField("db_write_timestamp", TimestampWithoutTimezone, ~default="CURRENT_TIMESTAMP"),
    ],
  )

  let entityHistory = table->EntityHistory.fromTable(~schema)
}

module SweepStakesNFTs_Transfer = {
  let name = SweepStakesNFTs_Transfer
  @genType
  type t = {
    from: string,
    id: id,
    to: string,
    tokenId: bigint,
  }

  let schema = S.object((s): t => {
    from: s.field("from", S.string),
    id: s.field("id", S.string),
    to: s.field("to", S.string),
    tokenId: s.field("tokenId", BigInt.schema),
  })

  let rowsSchema = S.array(schema)

  @genType
  type indexedFieldOperations = {
    
  }

  let table = mkTable(
     (name :> string),
    ~fields=[
      mkField(
      "from", 
      Text,
      
      
      
      
      
      ),
      mkField(
      "id", 
      Text,
      ~isPrimaryKey,
      
      
      
      
      ),
      mkField(
      "to", 
      Text,
      
      
      
      
      
      ),
      mkField(
      "tokenId", 
      Numeric,
      
      
      
      
      
      ),
      mkField("db_write_timestamp", TimestampWithoutTimezone, ~default="CURRENT_TIMESTAMP"),
    ],
  )

  let entityHistory = table->EntityHistory.fromTable(~schema)
}

module SweepStakesNFTs_Unstake = {
  let name = SweepStakesNFTs_Unstake
  @genType
  type t = {
    _amount: bigint,
    _tokenId: bigint,
    id: id,
    userAddress: string,
  }

  let schema = S.object((s): t => {
    _amount: s.field("_amount", BigInt.schema),
    _tokenId: s.field("_tokenId", BigInt.schema),
    id: s.field("id", S.string),
    userAddress: s.field("userAddress", S.string),
  })

  let rowsSchema = S.array(schema)

  @genType
  type indexedFieldOperations = {
    
  }

  let table = mkTable(
     (name :> string),
    ~fields=[
      mkField(
      "_amount", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "_tokenId", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "id", 
      Text,
      ~isPrimaryKey,
      
      
      
      
      ),
      mkField(
      "userAddress", 
      Text,
      
      
      
      
      
      ),
      mkField("db_write_timestamp", TimestampWithoutTimezone, ~default="CURRENT_TIMESTAMP"),
    ],
  )

  let entityHistory = table->EntityHistory.fromTable(~schema)
}

module SweepStakesNFTs_WinnerAssigned = {
  let name = SweepStakesNFTs_WinnerAssigned
  @genType
  type t = {
    _amount: bigint,
    _winner: bigint,
    id: id,
    timestamp: int,
    totalBalance: bigint,
    winnerAddress: string,
    winnerBalance: bigint,
  }

  let schema = S.object((s): t => {
    _amount: s.field("_amount", BigInt.schema),
    _winner: s.field("_winner", BigInt.schema),
    id: s.field("id", S.string),
    timestamp: s.field("timestamp", GqlDbCustomTypes.Int.schema),
    totalBalance: s.field("totalBalance", BigInt.schema),
    winnerAddress: s.field("winnerAddress", S.string),
    winnerBalance: s.field("winnerBalance", BigInt.schema),
  })

  let rowsSchema = S.array(schema)

  @genType
  type indexedFieldOperations = {
    
  }

  let table = mkTable(
     (name :> string),
    ~fields=[
      mkField(
      "_amount", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "_winner", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "id", 
      Text,
      ~isPrimaryKey,
      
      
      
      
      ),
      mkField(
      "timestamp", 
      Integer,
      
      
      
      
      
      ),
      mkField(
      "totalBalance", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "winnerAddress", 
      Text,
      
      
      
      
      
      ),
      mkField(
      "winnerBalance", 
      Numeric,
      
      
      
      
      
      ),
      mkField("db_write_timestamp", TimestampWithoutTimezone, ~default="CURRENT_TIMESTAMP"),
    ],
  )

  let entityHistory = table->EntityHistory.fromTable(~schema)
}

module SweepStakesNFTs_Withdraw = {
  let name = SweepStakesNFTs_Withdraw
  @genType
  type t = {
    _amount: bigint,
    _tokenId: bigint,
    id: id,
  }

  let schema = S.object((s): t => {
    _amount: s.field("_amount", BigInt.schema),
    _tokenId: s.field("_tokenId", BigInt.schema),
    id: s.field("id", S.string),
  })

  let rowsSchema = S.array(schema)

  @genType
  type indexedFieldOperations = {
    
  }

  let table = mkTable(
     (name :> string),
    ~fields=[
      mkField(
      "_amount", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "_tokenId", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "id", 
      Text,
      ~isPrimaryKey,
      
      
      
      
      ),
      mkField("db_write_timestamp", TimestampWithoutTimezone, ~default="CURRENT_TIMESTAMP"),
    ],
  )

  let entityHistory = table->EntityHistory.fromTable(~schema)
}

module Token = {
  let name = Token
  @genType
  type t = {
    balance: bigint,
    id: id,
    userAddress: string,
  }

  let schema = S.object((s): t => {
    balance: s.field("balance", BigInt.schema),
    id: s.field("id", S.string),
    userAddress: s.field("userAddress", S.string),
  })

  let rowsSchema = S.array(schema)

  @genType
  type indexedFieldOperations = {
    
      @as("userAddress") userAddress: whereOperations<t, string>,
    
  }

  let table = mkTable(
     (name :> string),
    ~fields=[
      mkField(
      "balance", 
      Numeric,
      
      
      
      
      
      ),
      mkField(
      "id", 
      Text,
      ~isPrimaryKey,
      
      
      
      
      ),
      mkField(
      "userAddress", 
      Text,
      
      
      
      
      
      ),
      mkField("db_write_timestamp", TimestampWithoutTimezone, ~default="CURRENT_TIMESTAMP"),
    ],
  )

  let entityHistory = table->EntityHistory.fromTable(~schema)
}

module User = {
  let name = User
  @genType
  type t = {
    id: id,
    
  }

  let schema = S.object((s): t => {
    id: s.field("id", S.string),
    
  })

  let rowsSchema = S.array(schema)

  @genType
  type indexedFieldOperations = {
    
  }

  let table = mkTable(
     (name :> string),
    ~fields=[
      mkField(
      "id", 
      Text,
      ~isPrimaryKey,
      
      
      
      
      ),
      mkField("db_write_timestamp", TimestampWithoutTimezone, ~default="CURRENT_TIMESTAMP"),
      mkDerivedFromField(
      "tokens", 
      ~derivedFromEntity="Token",
      ~derivedFromField="userAddress",
      ),
    ],
  )

  let entityHistory = table->EntityHistory.fromTable(~schema)
}

let allEntities = [
  module(ContractTotals),
  module(SweepStakesNFTs_Enter),
  module(SweepStakesNFTs_Transfer),
  module(SweepStakesNFTs_Unstake),
  module(SweepStakesNFTs_WinnerAssigned),
  module(SweepStakesNFTs_Withdraw),
  module(Token),
  module(User),
  module(TablesStatic.DynamicContractRegistry),
]->entityModsToInternal
