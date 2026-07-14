# Bank Management

Banks and bank accounts support multi-currency balances, interest accrual, and cheque books.

## Entities

- `Bank` — financial institution master
- `BankAccount` — tenant account with balance and interest rate
- `BankMovement` — deposits and withdrawals
- `ChequeBook` — numbered cheque range per account

## Permissions

- `bank.manage` — accounting bank reconciliation (Accounting module)
- `treasury.bank.manage` — create banks and accounts (Treasury module)
- `cheque.manage` — issue and transition cheques

## Interest

`BankService.calculateInterest` delegates to `TreasuryEngine.calculateInterest` using day-count basis.
