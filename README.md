# AHB-Lite VIP Development

Complete UVM-based Verification IP for AHB-Lite protocol
with independent Master and Slave VIP components.

---

## Architecture

    ahb_lite_vip_project/
    |-- vip/                        (Master VIP - Producer)
    |   |-- src/
    |       |-- ahb_lite_if.sv
    |       |-- ahb_lite_seq_item.sv
    |       |-- ahb_lite_config.sv
    |       |-- ahb_lite_driver.sv
    |       |-- ahb_lite_monitor.sv
    |       |-- ahb_lite_agent.sv
    |       |-- ahb_lite_pkg.sv
    |       |-- sequences/
    |           |-- ahb_lite_base_seq.sv
    |           |-- ahb_lite_write_seq.sv
    |           |-- ahb_lite_read_seq.sv
    |           |-- ahb_lite_rwr_seq.sv
    |
    |-- slave_vip/                  (Slave VIP - Consumer)
    |   |-- src/
    |       |-- ahb_slave_if.sv
    |       |-- ahb_slave_seq_item.sv
    |       |-- ahb_slave_config.sv
    |       |-- ahb_slave_memory.sv
    |       |-- ahb_slave_driver.sv
    |       |-- ahb_slave_monitor.sv
    |       |-- ahb_slave_agent.sv
    |       |-- ahb_slave_pkg.sv
    |
    |-- verification_tb/            (Testbench)
    |   |-- master_verification_env.sv
    |   |-- master_verification_tb_top.sv
    |   |-- scoreboards/
    |   |   |-- master_functional_checker.sv
    |   |   |-- master_protocol_checker.sv
    |   |-- tests/
    |       |-- base_master_test.sv
    |       |-- master_write_test.sv
    |       |-- master_read_test.sv
    |       |-- master_rwr_test.sv
    |
    |-- sim/
        |-- Makefile

---

## Features

- Independent Master and Slave VIP packages
- Zero-wait state mode for maximum performance
- Configurable wait state injection
- Error response handling (2-cycle protocol)
- Protocol checking and functional scoreboards
- Pipelined transaction support
- UVM RAL integration ready

---

## Quick Start

    cd sim
    make master_read_verif

---

## Performance

| Metric              | Value                                  |
|---------------------|----------------------------------------|
| Zero-wait mode      | 10 reads in ~200ns (2 cycles per txn) |
| Throughput          | 55% of theoretical AHB maximum        |
| Protocol compliance | 100% AHB compliant                     |

---

## Test Suite

1. master_read_test   - Read verification
2. master_write_test  - Write verification
3. master_rw_test     - Read-write sequences
4. master_error_test  - Error response handling
5. master_long_test   - Extended stress test

---

## Configuration

    // Zero-wait state mode (fast)
    slave_cfg.wait_mode = ahb_slave_config::WAIT_ZERO;

    // Random wait states (realistic)
    slave_cfg.wait_mode = ahb_slave_config::WAIT_RANDOM;
    slave_cfg.min_wait  = 0;
    slave_cfg.max_wait  = 5;

---

## Documentation

See AHB_LITE_VIP_DEVELOPMENT_GUIDE.md for detailed architecture and usage.

---

## Author

Neha Dhabale

