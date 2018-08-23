# The hard way - Bitcoin: Spending coins

## The easy way

### Create private key, public key and address

```shell
shell> bx seed # generate seed
27634686aa8838acaa68e27aea6c072534394ce411cb7d75

shell> echo 27634686aa8838acaa68e27aea6c072534394ce411cb7d75 | bx ec-new # generate private key
79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d

shell> echo 79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d | bx ec-to-public # generate public key
03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1

shell> echo 03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1 | bx ec-to-address # generate address
n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4
```

### Create transaction

Create transaction with input from previous transaction hash and index and out put as receiving address and amount in Satoshi.

```shell
shell> bx tx-encode -i d30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93:1 -o 2NFrxEjw5v2i7L8pm9dWjWSFpDRXmj8dBTn:64000000
010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd30100000000ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
```

### Sign transaction

Sign the input to be spent using private key and lock script.

```shell
shell> bx input-sign 79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d "dup hash160 [d7d35ff2ed9cbc95e689338af8cd1db133be6a4a] equalverify checksig" 010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd30100000000ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
3045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e1367451101
```

Assign script to transaction's input using signed endorsement and public key.

```shell
shell> bx input-set "[3045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e1367451101] [03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1]" 010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd30100000000ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b483045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e13674511012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
```

### Validate transaction

Validate input with public key, lock script and signed endorsement.

```
shell> bx input-validate 03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1 "dup hash160 [d7d35ff2ed9cbc95e689338af8cd1db133be6a4a] equalverify checksig" 3045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e1367451101 010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b483045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e13674511012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
The endorsement is valid.
```

Validate encoded transaction as a whole.

```shell
shell> bx validate-tx 010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b483045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e13674511012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
The transaction is valid.
```

### Broadcast transaction

Broadcast the transaction to blockchain.

```shell
bx send-tx 010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b483045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e13674511012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
Sent transaction.
```

Check address and transaction history.

```shell
shell> bx fetch-history n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4
transfers
{
    transfer
    {
        received
        {
            hash d30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93
            height 1384780
            index 1
        }
        spent
        {
            hash fb8c52b201eb474ea3b2cb1f482cf4f774f710c711267818fbdd4763a5ca38b9
            height 1384802
            index 0
        }
        value 65000000
    }
}
```

## The hard way

## Conclusions