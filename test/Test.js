
const assert = require("assert");
const { MockDb, SweepStakesNFTs } = require("../generated/src/TestHelpers.bs");
const { Addresses } = require("../generated/src/bindings/Ethers.bs");

let { GLOBAL_EVENTS_SUMMARY_KEY } = require("../src/EventHandlers");

const MOCK_EVENTS_SUMMARY_ENTITY = {
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

describe("SweepStakesNFTs contract Approval event tests", () => {
  // Create mock db
  const mockDbInitial = MockDb.createMockDb();

  // Add mock EventsSummaryEntity to mock db
  const mockDbFinal = mockDbInitial.entities.EventsSummary.set(
    MOCK_EVENTS_SUMMARY_ENTITY
  );

  // Creating mock SweepStakesNFTs contract Approval event
  const mockSweepStakesNFTsApprovalEvent = SweepStakesNFTs.Approval.createMockEvent({
    owner: Addresses.defaultAddress,
    approved: Addresses.defaultAddress,
    tokenId: 0n,
    mockEventData: {
      chainId: 1,
      blockNumber: 0,
      blockTimestamp: 0,
      blockHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
      srcAddress: Addresses.defaultAddress,
      transactionHash: "0x0000000000000000000000000000000000000000000000000000000000000000",
      transactionIndex: 0,
      logIndex: 0,
    },
  });

  // Processing the event
  const mockDbUpdated = SweepStakesNFTs.Approval.processEvent({
    event: mockSweepStakesNFTsApprovalEvent,
    mockDb: mockDbFinal,
  });

  it("SweepStakesNFTs_ApprovalEntity is created correctly", () => {
    // Getting the actual entity from the mock database
    let actualSweepStakesNFTsApprovalEntity = mockDbUpdated.entities.SweepStakesNFTs_Approval.get(
      mockSweepStakesNFTsApprovalEvent.transactionHash +
        mockSweepStakesNFTsApprovalEvent.logIndex.toString()
    );

    // Creating the expected entity
    const expectedSweepStakesNFTsApprovalEntity = {
      id:
        mockSweepStakesNFTsApprovalEvent.transactionHash +
        mockSweepStakesNFTsApprovalEvent.logIndex.toString(),
      owner: mockSweepStakesNFTsApprovalEvent.params.owner,
      approved: mockSweepStakesNFTsApprovalEvent.params.approved,
      tokenId: mockSweepStakesNFTsApprovalEvent.params.tokenId,
      eventsSummary: "GlobalEventsSummary",
    };
    // Asserting that the entity in the mock database is the same as the expected entity
    assert.deepEqual(
      actualSweepStakesNFTsApprovalEntity,
      expectedSweepStakesNFTsApprovalEntity,
      "Actual SweepStakesNFTsApprovalEntity should be the same as the expectedSweepStakesNFTsApprovalEntity"
    );
  });

  it("EventsSummaryEntity is updated correctly", () => {
    // Getting the actual entity from the mock database
    let actualEventsSummaryEntity = mockDbUpdated.entities.EventsSummary.get(
      GLOBAL_EVENTS_SUMMARY_KEY
    );

    // Creating the expected entity
    const expectedEventsSummaryEntity = {
      ...MOCK_EVENTS_SUMMARY_ENTITY,
      sweepStakesNFTs_ApprovalCount: MOCK_EVENTS_SUMMARY_ENTITY.sweepStakesNFTs_ApprovalCount + BigInt(1),
    };
    // Asserting that the entity in the mock database is the same as the expected entity
    assert.deepEqual(
      actualEventsSummaryEntity,
      expectedEventsSummaryEntity,
      "Actual EventsSummaryEntity should be the same as the expected EventsSummaryEntity"
    );
  });
});
