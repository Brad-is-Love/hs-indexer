import assert from "assert";
import { 
  TestHelpers,
  SweepStakesNFTs_Enter
} from "generated";
const { MockDb, SweepStakesNFTs } = TestHelpers;

describe("SweepStakesNFTs contract Enter event tests", () => {
  // Create mock db
  const mockDb = MockDb.createMockDb();

  // Creating mock for SweepStakesNFTs contract Enter event
  const event = SweepStakesNFTs.Enter.createMockEvent({/* It mocks event fields with default values. You can overwrite them if you need */});

  it("SweepStakesNFTs_Enter is created correctly", async () => {
    // Processing the event
    const mockDbUpdated = await SweepStakesNFTs.Enter.processEvent({
      event,
      mockDb,
    });

    // Getting the actual entity from the mock database
    let actualSweepStakesNFTsEnter = mockDbUpdated.entities.SweepStakesNFTs_Enter.get(
      `${event.chainId}_${event.block.number}_${event.logIndex}`
    );

    // Creating the expected entity
    const expectedSweepStakesNFTsEnter: SweepStakesNFTs_Enter = {
      id: `${event.chainId}_${event.block.number}_${event.logIndex}`,
      _tokenId: event.params._tokenId,
      _amount: event.params._amount,
    };
    // Asserting that the entity in the mock database is the same as the expected entity
    assert.deepEqual(actualSweepStakesNFTsEnter, expectedSweepStakesNFTsEnter, "Actual SweepStakesNFTsEnter should be the same as the expectedSweepStakesNFTsEnter");
  });
});
