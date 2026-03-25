#!/bin/bash

echo "================================================"
echo "  AHB-Lite VIP - Quick Run Script"
echo "================================================"
echo ""

# Check if Makefile exists
if [ ! -f "Makefile" ]; then
    echo "ERROR: Makefile not found!"
    exit 1
fi

# Default test
TEST=${1:-basic_read_test}

echo "Running test: $TEST"
echo ""

# Compile and run
make clean
make compile
make sim TEST=$TEST

echo ""
echo "================================================"
echo "  Simulation Complete!"
echo "================================================"
echo ""
echo "To view waveforms:"
echo "  gtkwave sim/waves.vcd &"
echo ""
echo "To view log:"
echo "  less sim/transcript"
echo ""



#chmod +x run.sh
