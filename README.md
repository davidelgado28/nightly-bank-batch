# Nightly Banking Batch Reconciliation System in GnuCOBOL

A robust mainframe batch simulation written in COBOL, demonstrating classic sequential file processing, match-merge logic, and error reporting compatible with **GnuCOBOL**.

## Overview
In high-volume core banking environments, nightly batch jobs process millions of transactions against master customer account balances. This project simulates a simplified nightly reconciliation cycle that:
1. Reads sorted master account balances (`CAD-SALDO`).
2. Reads sorted daily transaction movements (`CAD-TRANS`).
3. Matches records using a key-control algorithm (`EVALUATE TRUE`).
4. Validates business constraints (e.g., catching orphan transactions and insufficient funds).
5. Generates an exception error report (`REL-ERRO`).

## Prerequisites
- **GnuCOBOL Compiler** (`cobc`) installed on your system.

## How to Compile and Run

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/your-username/nightly-bank-batch.git](https://github.com/your-username/nightly-bank-batch.git)
   cd nightly-bank-batch
