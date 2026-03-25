#!/bin/bash

echo "========================================"
echo "  Analyzing Test Results"
echo "========================================"
echo ""

# Check latest simulation transcript
if [ -f "sim/transcript" ]; then
    echo "Last Test Results:"
    echo "===================="
    
    # Extract scoreboard statistics
    echo ""
    echo "Scoreboard Statistics:"
    grep "SCOREBOARD STATISTICS" sim/transcript -A 20
    
    echo ""
    echo "Cache Performance:"
    grep "Cache Behavior:" sim/transcript -A 5
    
    echo ""
    echo "Errors/Warnings:"
    grep "UVM_ERROR" sim/transcript
    grep "UVM_WARNING" sim/transcript
    
    echo ""
    echo "Wait Cycle Analysis:"
    grep "Wait Cycle Statistics:" sim/transcript -A 5
else
    echo "No simulation transcript found!"
    echo "Run: make sim TEST=<testname>"
fi
