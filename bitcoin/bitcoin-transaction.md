# The hard way - Bitcoin: Transaction

This is Part 2 of 'The hard way - Bitcoin' series and I will start with 'the easy way' section first because even this gets a bit complex, then will continue with the hard stuff, crafting a Bitcoin transaction from scratch using basic math and cryptography.

## A. The easy way

### Create private key, public key and address

We are going to generate private key, public key and Bitcoin testnet address to be used in this article.

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
### Previous transaction to be spent

In Bitcoin we have this concept called UTXO (Unspent Transaction Output) which is the unspent output of a previous transaction.

```shell
shell> bx fetch-tx d30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93
transaction
{
    hash d30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93
    inputs
    {
        input
        {
            address_hash 10924d4f0aefd6dc652ce1fe906694eba4dfc8ae
            previous_output
            {
                hash 264d0f5be4ebdd1102e23c4b440955b04b291c654323bdd33cd51d8989e3d54f
                index 1
            }
            script "[30450221009553c91c4aaf5ab137d5ed77cbc94a2c0511461f0de51b83fc2f00202f6a6beb022029a691221e1f664fa268524565d44f9e8a5387c5c091ec55f98ad12705720e7201] [02a46fc215bb6899814dc5bd026d815017784a2c4ceb78e7befdab1d5dfd51ef1a]"
            sequence 4294967294
        }
    }
    lock_time 1384777
    outputs
    {
        output
        {
            address_hash de69e4fc748732103653236dcc31c79e87422925
            script "dup hash160 [de69e4fc748732103653236dcc31c79e87422925] equalverify checksig"
            value 3625875580
        }
        output
        {
            address_hash d7d35ff2ed9cbc95e689338af8cd1db133be6a4a
            script "dup hash160 [d7d35ff2ed9cbc95e689338af8cd1db133be6a4a] equalverify checksig"
            value 65000000
        }
    }
    version 2
}
```

### Create transaction

Create transaction with two parameters: input (previous transaction hash and previous transaction output index) and output (receiving address and amount to send in Satoshi).

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

Create unlock script using signed endorsement and the public key then set it as transaction's input.

```shell
shell> bx input-set "[3045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e1367451101] [03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1]" 010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd30100000000ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b483045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e13674511012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
```

### Validate transaction

Validate input with public key, lock script and signed endorsement.

```shell
shell> bx input-validate 03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1 "dup hash160 [d7d35ff2ed9cbc95e689338af8cd1db133be6a4a] equalverify checksig" 3045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e1367451101 010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b483045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e13674511012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
The endorsement is valid.
```

Validate encoded transaction as a whole.

```shell
shell> bx validate-tx 010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b483045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e13674511012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
The transaction is valid.
```

### Broadcast transaction

Broadcast the transaction to network.

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

## B. The hard way

Now lets get down to real business and craft our own transaction starting with a few utility methods that we are going to use along the way.

Two methods to convert big numbers to bytes string and vice-versa, padding with `0x00` to satisfy the required length if any.

```ruby
def bytes_to_bignum(bytes_string)
  bytes_string.bytes.reduce { |n, b| (n << 8) + b }
end
def bignum_to_bytes(n, length=nil)
  a = []
  while n > 0
    a << (n & 0xFF)
    n >>= 8
  end
  a.fill 0x00, a.length, length - a.length if length
  a.reverse.pack('C*')
end
```

Base58 encoding / decoding methods, Bitcoin address decoding to Hash160 (hashing twice with sha256 then ripe160) and build Bitcoin script based on destination address that can be Pay-to-PublicKey-Hash or Pay-to-Script-hash.

```ruby
def bitcoin_base58_encode(ripe160_hash)
  alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  value = ripe160_hash.to_i 16
  output = ''
  while value > 0
    remainder = value % 58
    value /= 58
    output += alphabet[remainder]
  end
  output += alphabet[0] * [ripe160_hash].pack('H*').bytes.find_index{|b| b != 0}
  output.reverse
end
def bitcoin_base58_decode(address)
  alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  int_val = 0
  address.reverse.chars.each_with_index do |char, index|
    char_index = alphabet.index(char)
    int_val += char_index * 58**index
  end
  bignum_to_bytes(int_val, 25).unpack('H*').first
end
def bitcoin_address_decode(address)
  wrap_encode = bitcoin_base58_decode address
  wrap_encode[2, 40]
end
def bitcoin_script(address)
  hash160 = bitcoin_address_decode address
  if address.start_with? '2'
    "OP_HASH160 #{hash160} OP_EQUAL"
  else
    "OP_DUP OP_HASH160 #{hash160} OP_EQUALVERIFY OP_CHECKSIG"
  end
end
```

Multiple utility methods to transform different data types into hex string.

```ruby
class Struct
  OPCODES = {
    'OP_DUP' =>  0x76,
    'OP_HASH160' =>  0xA9,
    'OP_EQUAL' =>  0x87,
    'OP_EQUALVERIFY' =>  0x88,
    'OP_CHECKSIG' =>  0xAC
  }.freeze
  def opcode(token)
    raise "opcode #{token} not found" unless OPCODES.include?(token)
    OPCODES[token].to_s 16
  end
  def data(token)
    bin_size = hex_size token
    byte_to_hex(bin_size) + token
  end
  def hex_size(hex)
    [hex].pack('H*').size
  end
  def to_hex(binary_bytes)
    binary_bytes.unpack('H*').first
  end
  def hash_to_hex(value)
    to_hex [value].pack('H*').reverse
  end
  def int_to_hex(value)
    to_hex [value].pack('V')
  end
  def byte_to_hex(value)
    to_hex [value].pack('C')
  end
  def long_to_hex(value)
    to_hex [value].pack('Q<')
  end
  def script_to_hex(script_string)
    script_string.split.map { |token| token.start_with?('OP') ? opcode(token) : data(token) }.join
  end
  def sha256(hex)
    Digest::SHA256.hexdigest([hex].pack('H*'))
  end
end
```

Now, lets check the previous transaction that we want to spend.

```shell
shell> bx fetch-transaction ea8a64e122304637e8da016836e9afd59fc1179dfa15affc40d63b34e7db0cec

transaction
{
    hash ea8a64e122304637e8da016836e9afd59fc1179dfa15affc40d63b34e7db0cec
    inputs
    {
        input
        {
            address_hash d7d35ff2ed9cbc95e689338af8cd1db133be6a4a
            previous_output
            {
                hash 6b22d8a69432774ebbc00566755ff8da241be83c1b364ca177e241e23a0e111c
                index 0
            }
            script "[3045022100e4c449be7643140b9a62635afe8f99406311372f6ad4215d19a6d0b0ea306c7902203c6966502dba43b86d34d9252adb7632632bce1cf83ed721b5a1ac00e9e0f48a01] [03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1]"
            sequence 4294967295
        }
    }
    lock_time 0
    outputs
    {
        output
        {
            address_hash ad99d5964d9180d501c8863f4bcd7b04f0766787
            script "dup hash160 [ad99d5964d9180d501c8863f4bcd7b04f0766787] equalverify checksig"
            value 1000000
        }
        output
        {
            address_hash d7d35ff2ed9cbc95e689338af8cd1db133be6a4a
            script "dup hash160 [d7d35ff2ed9cbc95e689338af8cd1db133be6a4a] equalverify checksig"
            value 23990000
        }
    }
    version 1
}
```

Build transaction input from previous UTXO (Unspent Transaction Output): value, tx hash and output index.

```ruby
Input = Struct.new :value, :tx_hash, :index, :unlock_script, :sequence do
  def initialize(value, tx_hash, index, unlock_script: '', sequence: 0xfffffffff)
    super value, tx_hash, index, unlock_script, sequence
  end
  def serialize
    script_hex = script_to_hex(unlock_script)
    hash_to_hex(tx_hash) + int_to_hex(index) +
      byte_to_hex(hex_size(script_hex)) + script_hex + int_to_hex(sequence)
  end
end
input = Input.new 23_990_000, 'ea8a64e122304637e8da016836e9afd59fc1179dfa15affc40d63b34e7db0cec', 1
```

Build transaction output with output value and lock script.

```ruby
Output = Struct.new :value, :lock_script do
  def serialize
    script_hex = script_to_hex(lock_script)
    long_to_hex(value) + byte_to_hex(hex_size(script_hex)) + script_hex
  end
end
output_script = bitcoin_script '2N959B4qEPkce8jbzQC7EQaS6uaEBB9YTgQ'
output = Output.new 1_000_000, output_script
```

Build the second output which is the 'change' transaction.

```ruby
change_value = input.value - output.value - 10_000
change_script = bitcoin_script 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'
change = Output.new change_value, change_script
```

Before creating the actual transction lets introduce a few elliptic curve methods methods and parameters that we all know and love already.

```ruby
EC_Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
EC_Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
EC_p = 2**256 - 2**32 - 2**9 - 2**8 - 2**7 - 2**6 - 2**4 - 1
EC_n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141

def extended_euclidean_algorithm(a, b)
  s, old_s = 0, 1
  t, old_t = 1, 0
  r, old_r = b, a
  while r != 0
    quotient = old_r / r
    old_r, r = r, old_r - quotient * r
    old_s, s = s, old_s - quotient * s
    old_t, t = t, old_t - quotient * t
  end
  [old_r, old_s, old_t]
end
def inverse(n, p)
  gcd, x, y = extended_euclidean_algorithm(n, p)
  (n * x + p * y) % p == gcd || raise('invalid gcd')
  gcd == 1 || raise('no multiplicative inverse')
  x % p
end
def ec_double(px, py, pn)
  i_2y = inverse(2 * py, pn)
  slope = (3 * px**2 * i_2y) % pn
  x = (slope**2 - 2 * px) % pn
  y = (slope*(px - x) - py) % pn
  [x, y]
end
def ec_add(ax, ay, bx, by, pn)
  return [ax, ay] if bx == 0 && by == 0
  return [bx, by] if ax == 0 && ay == 0
  return ec_double(ax, ay, pn) if ax == bx && ay == by

  i_bax = inverse(ax - bx, pn)
  slope = ((ay - by) * i_bax) % pn
  x = (slope**2 - ax - bx) % pn
  y = (slope*(ax - x) - ay) % pn
  [x, y]
end
def ec_multiply(m, px, py, pn)
  nx, ny = px, py
  qx, qy = 0, 0
  while m > 0
    qx, qy = ec_add qx, qy, nx, ny, pn if m&1 == 1
    nx, ny = ec_double nx, ny, pn
    m >>= 1
  end
  [qx, qy]
end
```

And these are the core methods of Elliptic Curve Digital Signature Algorithm (ECDSA), the sign/verify methods with DER signature encoding.

```ruby
def ecdsa_sign(private_key, digest, temp_key = nil)
  temp_key ||= 1 + SecureRandom.random_number(EC_n - 1)
  rx, _ry = ec_multiply(temp_key, EC_Gx, EC_Gy, EC_p)
  r = rx % EC_n
  r > 0 || raise('r is zero, try again new temp key')
  i_tk = inverse temp_key, EC_n
  m = bytes_to_bignum digest
  s = (i_tk * (m + r * private_key)) % EC_n
  s > 0 || raise('s is zero, try again new temp key')
  [r, s]
end
def ecdsa_verify?(px, py, digest, signature)
  r, s = signature
  i_s = inverse s, EC_n
  m = bytes_to_bignum digest
  u1 = i_s * m % EC_n
  u2 = i_s * r % EC_n
  u1Gx, u1Gy = ec_multiply u1, EC_Gx, EC_Gy, EC_p
  u2Px, u2Py = ec_multiply u2, px, py, EC_p
  rx, _ry = ec_add u1Gx, u1Gy, u2Px, u2Py, EC_p
  r == rx
end
Der = Struct.new :der, :length, :ri, :rl, :r, :si, :sl, :s, :sighash_type do
  def initialize(der: 0x30, length: 0x45, ri: 0x02, rl: 0x21, r: nil, si: 0x02, sl: 0x20, s: nil, sighash_type: 0x01)
    super der, length, ri, rl, r, si, sl, s, sighash_type
  end
  def serialize
    byte_to_hex(der) + byte_to_hex(length) +
      byte_to_hex(ri) + byte_to_hex(rl) + to_hex(bignum_to_bytes(r, 33)) +
      byte_to_hex(si) + byte_to_hex(sl) + to_hex(bignum_to_bytes(s, 32)) +
      byte_to_hex(sighash_type)
  end
  def self.parse(signature)
    fields = *[signature].pack('H*').unpack('CCCCH66CCH64C')
    Der.new r: fields[4], s: fields[7], sighash_type: fields[8]
  end
end
```

We are getting there, build Bitcoin transaction passing in the input and the two outputs.

```ruby
Transaction = Struct.new :version, :inputs, :outputs, :locktime do
  def serialize
    inputs_hex = inputs.map(&:serialize).join
    outputs_hex = outputs.map(&:serialize).join
    int_to_hex(version) + byte_to_hex(inputs.size) + inputs_hex +
      byte_to_hex(outputs.size) + outputs_hex + int_to_hex(locktime)
  end
  def hash
    hash_to_hex sha256(sha256(serialize))
  end
  def signature_hash(lock_script = nil, sighash_type = 0x1)
    inputs.first.unlock_script = lock_script if lock_script
    hash = sha256(sha256(serialize + int_to_hex(sighash_type)))
    [hash].pack('H*')
  end
  def sign(private_key, public_key, lock_script, sighash_type = 0x01)
    bytes_string = signature_hash lock_script, sighash_type
    r, s = ecdsa_sign private_key, bytes_string
    der = Der.new r: r, s: s
    inputs.first.unlock_script = "#{der.serialize} #{public_key}"
    serialize
  end
end
transaction = Transaction.new 1, [input], [output, change], 0
```

Finally, to sign the transaction we need 3 things: private key, public key and the lock script of previous UTXO to spend.

```ruby
private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
public_key = '03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1'
lock_script = bitcoin_script 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'

tx_hex = transaction.sign private_key, public_key, lock_script
puts "TX hash: #{transaction.hash}"
puts "TX hex: #{tx_hex}"
```

And VOILA! take the returned transaction hex and decode/validate it:

```shell
shell> bx tx-decode 0100000001ec0cdbe7343bd640fcaf15fa9d17c19fd5afe9366801dae837463022e1648aea010000006b483045022100c1c85b5865f64f8f18c54f028a50942cd21cbda9c4a5f9296132defe51017c640220304793e361e71b3bae812923ca4aa5481a2fead05a73583ad5d930e7229f562f012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff0240420f000000000017a914ad99d5964d9180d501c8863f4bcd7b04f076678787a0a55e01000000001976a914d7d35ff2ed9cbc95e689338af8cd1db133be6a4a88ac00000000

transaction
{
    hash c218dc394fef23ab9652ed6fd49539aa5dfb4f0153127b5c433032918948e60b
    inputs
    {
        input
        {
            address_hash d7d35ff2ed9cbc95e689338af8cd1db133be6a4a
            previous_output
            {
                hash ea8a64e122304637e8da016836e9afd59fc1179dfa15affc40d63b34e7db0cec
                index 1
            }
            script "[3045022100c1c85b5865f64f8f18c54f028a50942cd21cbda9c4a5f9296132defe51017c640220304793e361e71b3bae812923ca4aa5481a2fead05a73583ad5d930e7229f562f01] [03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1]"
            sequence 4294967295
        }
    }
    lock_time 0
    outputs
    {
        output
        {
            address_hash ad99d5964d9180d501c8863f4bcd7b04f0766787
            script "hash160 [ad99d5964d9180d501c8863f4bcd7b04f0766787] equal"
            value 1000000
        }
        output
        {
            address_hash d7d35ff2ed9cbc95e689338af8cd1db133be6a4a
            script "dup hash160 [d7d35ff2ed9cbc95e689338af8cd1db133be6a4a] equalverify checksig"
            value 22980000
        }
    }
    version 1
}

```

then submit it to Bitcoin testnet network via:

- [Broadcast TX](https://testnet.blockchain.info/pushtx)
- or using `bitcoin-cli` command line tool

```shell
shell> bitcoin-cli -testnet sendrawtransaction 0100000001ec0cdbe7343bd640fcaf15fa9d17c19fd5afe9366801dae837463022e1648aea010000006b483045022100c1c85b5865f64f8f18c54f028a50942cd21cbda9c4a5f9296132defe51017c640220304793e361e71b3bae812923ca4aa5481a2fead05a73583ad5d930e7229f562f012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff0240420f000000000017a914ad99d5964d9180d501c8863f4bcd7b04f076678787a0a55e01000000001976a914d7d35ff2ed9cbc95e689338af8cd1db133be6a4a88ac00000000
```

## C. Conclusions

Creating transaction is a bit more difficult than generating a Bitcoin address that we saw in Part 1 but it is all possible once you understand the basics of Bitcoin like UTXOs, script and transactions.

## D. References

Here are the most important references but feel free to get in touch for more information.

  * [OP_CHECKSIG](https://en.bitcoin.it/wiki/OP_CHECKSIG)
  * [Bitcoin Script](https://en.bitcoin.it/wiki/Script)
  * [Address prefixes](https://en.bitcoin.it/wiki/List_of_address_prefixes)
  * [Libbitcoin-explorer](https://github.com/libbitcoin/libbitcoin-explorer/wiki)

The very end.
