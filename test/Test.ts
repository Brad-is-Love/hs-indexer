import assert from "assert";
import { 
  createTestIndexer,
  TestHelpers,
  type SweepStakesNFTs_Enter
} from "envio";
import "../src/EventHandlers.js";

describe("SweepStakesNFTs contract Enter event tests", () => {
  it("SweepStakesNFTs_Enter is created correctly", async () => {
    const indexer = createTestIndexer();

    const _tokenId = 123n;
    const _amount = 456n;

    // Simulate event and process it
    await indexer.process({
      chains: {
        1666600000: {
          startBlock: 0,
          endBlock: 1,
          simulate: [
            {
              contract: "SweepStakesNFTs",
              event: "Enter",
              params: {
                _tokenId,
                _amount,
              },
              srcAddress: "0xc71D7C069Ae96794c5d6d54ff04754D2832601c3",
            },
          ],
        },
      },
    });

    const expectedSweepStakesNFTsEnter: SweepStakesNFTs_Enter = {
      id: "1666600000_0_0",
      _tokenId,
      _amount,
      userAddress: "0xc71D7C069Ae96794c5d6d54ff04754D2832601c3",
    };

    let allSweepStakesNFTsEnter = await indexer.SweepStakesNFTs_Enter.getAll();
    let actualSweepStakesNFTsEnter = allSweepStakesNFTsEnter[0];

    assert.deepEqual(actualSweepStakesNFTsEnter, expectedSweepStakesNFTsEnter, "Actual SweepStakesNFTsEnter should be the same as the expectedSweepStakesNFTsEnter");
  });
});
