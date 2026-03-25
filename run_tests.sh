#!/bin/bash

TESTS=(
    "basic_read_test"
    "cache_test"
    "write_test"
    "rwr_test"
    "random_test"
    "regression_test"
)

PASS=0
FAIL=0

echo "========================================"
echo "  Running Test Suite"
echo "========================================"
echo ""

for TEST in "${TESTS[@]}"; do
    echo "Running: $TEST"
    
    make clean > /dev/null 2>&1
    make sim TEST=$TEST > sim_${TEST}.log 2>&1
    
    if grep -q "UVM_ERROR" sim_${TEST}.log || grep -q "UVM_FATAL" sim_${TEST}.log; then
        echo "  Result: FAILED â"
        FAIL=$((FAIL+1))
    else
        echo "  Result: PASSED â"
        PASS=$((PASS+1))
    fi
    echo ""
done

echo "========================================"
echo "  Test Summary"
echo "========================================"
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
echo "  Total:  $((PASS+FAIL))"
echo "========================================"

if [ $FAIL -eq 0 ]; then
    echo "â All tests PASSED!"
    exit 0
else
    echo "â Some tests FAILED - check logs"
    exit 1
fi
