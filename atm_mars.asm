.data
welcome:    .asciiz "\n----- ATM SYSTEM -----\n"
menu:       .asciiz "\n1. Check Balance\n2. Deposit\n3. Withdraw\n4. Transactions Count\n5. Mini Statement\n6. Exit\nEnter choice: "
balanceMsg: .asciiz "\nCurrent Balance: "
depositMsg: .asciiz "\nEnter deposit amount: "
withdrawMsg:.asciiz "\nEnter withdraw amount: "
errorMsg:   .asciiz "\nInsufficient Balance!"
thanks:     .asciiz "\nThank you for using ATM.\n"
countMsg:   .asciiz "\nTotal Transactions: "
lastDepMsg: .asciiz "\nLast Transaction: Deposit Amount = "
lastWithMsg:.asciiz "\nLast Transaction: Withdraw Amount = "
noTxnMsg:   .asciiz "\nNo transaction done yet.\n"

balance:        .word 10000     # Initial balance
txnCount:       .word 0         # Transaction counter
lastTxnType:    .word 0         # 0 = none, 1 = deposit, 2 = withdraw
lastTxnAmount:  .word 0         # Last transaction amount

.text
.globl main

main:
    li $v0, 4
    la $a0, welcome
    syscall

menu_loop:
    li $v0, 4
    la $a0, menu
    syscall

    li $v0, 5
    syscall
    move $t0, $v0

    beq $t0, 1, check_balance
    beq $t0, 2, deposit
    beq $t0, 3, withdraw
    beq $t0, 4, show_count
    beq $t0, 5, mini_statement
    beq $t0, 6, exit
    j menu_loop

# -------------------------------
# Check Balance
# -------------------------------
check_balance:
    li $v0, 4
    la $a0, balanceMsg
    syscall

    lw $a0, balance
    li $v0, 1
    syscall
    j menu_loop

# -------------------------------
# Deposit Money
# -------------------------------
deposit:
    li $v0, 4
    la $a0, depositMsg
    syscall

    li $v0, 5
    syscall
    move $t1, $v0

    lw $t2, balance
    add $t2, $t2, $t1
    sw $t2, balance

    # update transaction count
    lw $t3, txnCount
    addi $t3, $t3, 1
    sw $t3, txnCount

    # save last transaction
    li $t4, 1
    sw $t4, lastTxnType
    sw $t1, lastTxnAmount

    j menu_loop

# -------------------------------
# Withdraw Money
# -------------------------------
withdraw:
    li $v0, 4
    la $a0, withdrawMsg
    syscall

    li $v0, 5
    syscall
    move $t1, $v0

    lw $t2, balance
    blt $t2, $t1, insufficient

    sub $t2, $t2, $t1
    sw $t2, balance

    # update transaction count
    lw $t3, txnCount
    addi $t3, $t3, 1
    sw $t3, txnCount

    # save last transaction
    li $t4, 2
    sw $t4, lastTxnType
    sw $t1, lastTxnAmount

    j menu_loop

insufficient:
    li $v0, 4
    la $a0, errorMsg
    syscall
    j menu_loop

# -------------------------------
# Show Transaction Count
# -------------------------------
show_count:
    li $v0, 4
    la $a0, countMsg
    syscall

    lw $a0, txnCount
    li $v0, 1
    syscall
    j menu_loop

# -------------------------------
# Mini Statement
# -------------------------------
mini_statement:
    lw $t0, lastTxnType
    beq $t0, 0, no_txn
    beq $t0, 1, show_last_deposit
    beq $t0, 2, show_last_withdraw
    j menu_loop

show_last_deposit:
    li $v0, 4
    la $a0, lastDepMsg
    syscall

    lw $a0, lastTxnAmount
    li $v0, 1
    syscall
    j menu_loop

show_last_withdraw:
    li $v0, 4
    la $a0, lastWithMsg
    syscall

    lw $a0, lastTxnAmount
    li $v0, 1
    syscall
    j menu_loop

no_txn:
    li $v0, 4
    la $a0, noTxnMsg
    syscall
    j menu_loop

# -------------------------------
# Exit
# -------------------------------
exit:
    li $v0, 4
    la $a0, thanks
    syscall

    li $v0, 10
    syscall
