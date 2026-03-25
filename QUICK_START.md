# Quick Start Guide for Testing

## Run Individual Tests
```bash
# Basic read test
make sim TEST=basic_read_test

# Cache behavior test (most interesting!)
make sim TEST=cache_test

# Write test
make sim TEST=write_test

# Read-Write-Read test
make sim TEST=rwr_test

# Random stress test
make sim TEST=random_test

# Full regression (runs all)
make sim TEST=regression_test
```

## Run All Tests Automatically
```bash
./run_tests.sh
```

## Analyze Results
```bash
./analyze_results.sh

# Or view manually
cat sim/transcript | less

# Or with GUI
make gui TEST=cache_test
```

## View Waveforms
```bash
gtkwave sim/waves.vcd &

# Look for these signals:
# - HADDR (address)
# - HREADYOUT (ready signal)
# - HRDATA (read data)
# - Wait cycles (HREADYOUT low = waiting)
```

## Expected Results

### Cache Test
- First access: HIGH wait cycles (80-100) = MISS
- Second access (same addr): LOW wait cycles (1-2) = HIT
- Sequential accesses: LOW wait cycles = HITs
- Different line: HIGH wait cycles = MISS

### Scoreboard Should Show
- Hit Rate: >70% for good performance
- Average wait: 10-20 cycles
- Min wait: 0-2 cycles (hits)
- Max wait: 70-100 cycles (misses)

## What to Look For

â No UVM_ERROR or UVM_FATAL
â Cache hits showing low wait cycles
â Cache misses showing high wait cycles
â Read data matches written data (RWR test)
â Statistics in scoreboard report

## Troubleshooting

If tests fail:
1. Check sim/transcript for errors
2. View waveforms: `make gui TEST=<test>`
3. Increase verbosity: Edit Makefile, change to UVM_HIGH
4. Check specific test log: `cat sim_<testname>.log`

