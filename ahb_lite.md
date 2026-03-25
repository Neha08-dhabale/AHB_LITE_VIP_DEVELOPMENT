# AHB-Lite VIPVIP Architecture: Query Log

---

## Query 1

For this AHB-Lite wrapper in this repository that I gave earlier, I have to create a VIP for this AHB wrapper. Tell me what all is needed and the steps and it should be such a way that any other can also make use of this VIP. Give me steps to proceed and what all is needed accordingly.

---

## Query 2

The VIP is ready that you gave me above. I have to start creating in my terminal hence give steps how to proceed and create files and how directories to be made, hence which files to be added from the repository that I gave and also what about the flash memory. Just for this VIP of AHB do I need to take the remaining codes same or just create? I think can use same only  you just tell me steps so that I can follow which will help me run the VIP in my terminal before integrating to the QSPI VIP and all. Now I just want a standalone VIP that runs and can tell the behaviour of the design as well.

---

## Query 3

Now that I have successfully got output for the read test, help me with the next steps. I have made some changes to the driver and monitor but now help me with the next steps to see how my VIP works after running the read test. Give complete next steps with codes. I'll put my updated driver and monitor task  rest all is the same as this with few Makefile changes only.

---

## Query 4

According to running the tests as you said by doing `make clean`, `make sim` and all  now that I have so many tests added I need to see their behaviour in waveform. Help add those commands to my Makefile such that I run it and it opens the GUI command for wave window directly.

---

## Query 5

Now here just make GUI for each test. Don't individually add wave for all  just collaborate it in the GUI for the particular test using one command. I should open GUI for that particular test and then add waveforms from there whichever needed.

---

## Query 6

With the XIP DUT you were testing the DUT through the master. With the slave VIP you are testing the master itself. Every wait state the slave injects, every error it returns, every back-to-back transaction it handles  all of it exercises a specific master VIP requirement that must hold true in any SoC the master is dropped into.

Now that you know that I have a master VIP that verified the DUT, moving on I need to verify this master VIP and make it in a way that's easily used by anyone later for their SoCs. Considering and putting all the parameters, configurations and everything that a VIP should consist of  the master VIP that is there had a DUT which was read only, so now I want to verify it with a slave VIP such that the write will also be verified.

Basically my understanding that I want is this:

**BEFORE (DUT-based):**

- Goal: verify DUT (XIP controller)
- Master VIP = stimulus generator
- DUT = device under test
- Scoreboard = checks DUT output
- Question: "Did DUT respond right?"

**AFTER (Slave VIP-based):**

- Goal: verify Master VIP behaviour
- Master VIP = device under test
- Slave VIP = programmable DUT
- Scoreboard = checks master protocol
- Question: "Did master behave right?"

Your master VIP going into bigger SoCs means it must guarantee:

- It always produces legal AHB protocol
- It handles wait states correctly
- It handles ERROR responses correctly
- It never violates HTRANS/HREADY rules

The slave VIP is your programmable mirror  you configure it to respond in specific ways and check the master reacts correctly. So help me generate this step by step. Already my master VIP is present  whatever is needed for this slave and integration and all parts, help me with it.

---

## Query 7

Go through my master VIP earlier that you gave and tell me any changes in that required as per the slave VIP now. Clarify the following doubt and help me solve the error.

---

## Query 8

Reset released, no data driven  drive was not responding. Error occurred as if it did not have slave clocking block added. Then update driver to use clocking blocks.

---

## Query 9

If you try and extract the output from this, analyse it well. My master earlier was verifying my DUT that was read mode so the write seq and all were structured in a way that ignored write and gave read only data from the memory. So now that the slave DUT is present, how do my master side changes have to be there according to this slave? Help me out with that  my seq and tests in master side, how are they going to affect or be modified in accordance with this slave VIP?

---

## Query 10

See my logs and tell me why only `0xDEADBEEF` is printing. Give me necessary changes and also written data should be seen and same should be read back also. RWR should happen and read and write as well.

---

## Query 11

Tell me how it should behave according to the sequences and is it actually happening? Just analyse it.

---

## Query 12

The `local::` syntax might not be supported in QuestaSim 10.6b. Let's use a local variable approach instead.

---

## Query 13

The slave driver/monitor need better synchronization with the clocking blocks and proper AHB timing.

---

## Query 14

The master monitor is collecting transactions TWICE  once in the address phase and once when they complete. This is causing the scoreboard to go completely out of sync. The master monitor should only report when the transaction completes, not when it starts!

---

## Query 15

Issue: to make synchronisation better.

- **Monitor**: Only captures address when NO transaction is pending (prevents duplicates)
- **Driver**: Samples HRDATA using clocking block's `#1step` delay

---

## Query 16

Data mismatch  when the monitor captures an address phase, it immediately checks if `HREADYOUT = 1` on the same cycle. But that is still the address phase! The data phase does not start until the NEXT cycle.

---

## Query 17

The slave monitor messages are at `UVM_HIGH` verbosity, so we can't see them!

---

## Query 18

`env.slave_cfg` is null! The env hasn't been built yet when you try to access it.

- **Solution**: Configure the slave BEFORE calling `super.build_phase()`

---

## Query 19

`HRESP` going high  according to protocol it should be asserted for 2 cycles.

---

## Query 20

Removed error response logic from comparing in scoreboard.

