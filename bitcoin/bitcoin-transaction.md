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
### Previous transaction to be spent

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

Create unlock script using signed endorsement and public key and assign it to transaction's input.

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

Secp256k1 elliptic curve parameters that we all know and love.

```ruby
EC_Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
EC_Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
EC_p = 2**256 - 2**32 - 2**9 - 2**8 - 2**7 - 2**6 - 2**4 - 1
EC_n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
```

Basic structs for transaction, input, output and DER signature.

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

Input = Struct.new :tx_hash, :index, :unlock_script, :sequence do
  def serialize
    script_hex = script_to_hex(unlock_script)
    hash_to_hex(tx_hash) + int_to_hex(index) + byte_to_hex(hex_size(script_hex)) + script_hex + int_to_hex(sequence)
  end
end

Output = Struct.new :amount, :lock_script do
  def serialize
    script_hex = script_to_hex(lock_script)
    long_to_hex(amount) + byte_to_hex(hex_size(script_hex)) + script_hex
  end
end

Transaction = Struct.new :version, :inputs, :outputs, :locktime do
  def serialize
    inputs_hex = inputs.map(&:serialize).join
    outputs_hex = outputs.map(&:serialize).join
    int_to_hex(version) +
      byte_to_hex(inputs.size) + inputs_hex +
      byte_to_hex(outputs.size) + outputs_hex +
      int_to_hex(locktime)
  end

  def hash
    hash_to_hex sha256(sha256(serialize))
  end

  def signature_hash(sighash_type = 0x1)
    sha256(sha256(serialize + int_to_hex(sighash_type)))
  end

  def endorsement_hash(lock_script, sighash_type = 0x1)
    inputs.first.unlock_script = lock_script
    signature_hash sighash_type
  end

  def sign(private_key, public_key, lock_script, sighash_type = 0x01)
    hash = endorsement_hash lock_script
    hash_bytes = [hash].pack('H*')
    r, s = ecdsa_sign private_key, hash_bytes
    der = Der.new r: r, s: s
    inputs.first.unlock_script = "#{der.serialize} #{public_key}"
    serialize
  end
end

Der = Struct.new :der, :length, :ri, :rl, :r, :si, :sl, :s, :sighash_type do
  def initialize(der: 0x30, length: 0x45, ri: 0x02, rl: 0x21, r: nil, si: 0x02, sl: 0x20, s: nil, sighash_type: 0x01)
    super der, length, ri, rl, r, si, sl, s, sighash_type
  end

  def serialize
    r_hex = to_hex(int2bytes(r)).rjust 66, '0'
    s_hex = to_hex(int2bytes(s)).rjust 64, '0'

    byte_to_hex(der) + byte_to_hex(length) +
      byte_to_hex(ri) + byte_to_hex(rl) + r_hex +
      byte_to_hex(si) + byte_to_hex(sl) + s_hex +
      byte_to_hex(sighash_type)
  end

  def self.parse(signature)
    fields = *[signature].pack('H*').unpack('CCCCH66CCH64C')
    Der.new r: fields[4], s: fields[7], sighash_type: fields[8]
  end
```

ECDSA sign/verify logic

```ruby
def ecdsa_sign(private_key, digest, temp_key = nil)
  temp_key ||= 1 + SecureRandom.random_number(EC_n - 1)
  rx, _ry = ec_multiply(temp_key, EC_Gx, EC_Gy, EC_p)
  r = rx % EC_n
  r > 0 || raise('r is zero, try again new temp key')
  i_tk = inverse temp_key, EC_n
  m = bytes2int digest
  s = (i_tk * (m + r * private_key)) % EC_n
  s > 0 || raise('s is zero, try again new temp key')
  [r, s]
end

def ecdsa_verify?(px, py, digest, signature)
  r, s = signature
  i_s = inverse s, EC_n
  m = bytes2int digest
  u1 = i_s * m % EC_n
  u2 = i_s * r % EC_n
  u1Gx, u1Gy = ec_multiply u1, EC_Gx, EC_Gy, EC_p
  u2Px, u2Py = ec_multiply u2, px, py, EC_p
  rx, _ry = ec_add u1Gx, u1Gy, u2Px, u2Py, EC_p
  r == rx
end

def bytes2int(bytes_string)
  bytes_string.bytes.reduce { |n, b| (n << 8) + b }
end
def int2bytes(n)
  a = []
  while n > 0
    a << (n & 0xFF)
    n >>= 8
  end
  a.reverse.pack('C*')
end
```

```ruby
ruby> input = Input.new '2b8b8c0577d631a2988a228e919efb8f5a60fbce5271794dddd5cfcb18890fb4', 0, '', 0xfffffffff
ruby> output = Output.new 10_000_000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
ruby> transaction = Transaction.new 1, [input], [output], 0
ruby> transaction.sign private_key, public_key, lock_script
0100000001b40f8918cbcfd5dd4d797152cefb605a8ffb9e918e228a98a231d677058c8b2b000000006b483045022100d955e6028004f02a05c1f606dd71b505eaf50bb405e3ddbfa30b60a05951d2f202204ffadf94dc93cdc98f842d21eac953b10debaf4bcec135fb0adbcef91fc67e9a012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff01809698000000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000
```

## Conclusions

## References

  *[OP_CHECKSIG](https://en.bitcoin.it/wiki/OP_CHECKSIG)
