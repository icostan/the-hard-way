#!/usr/bin/env ruby

require 'digest'
require 'securerandom'

#
# utils
#
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

#
# Bitcoin
#
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
  # TODO: hard coded 50?
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

#
# Struct utils
#
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
    # TODO: data size is defined as 1-9 bytes
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

#
# inputs
#
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

#
# outputs
#
Output = Struct.new :value, :lock_script do
  def serialize
    script_hex = script_to_hex(lock_script)
    long_to_hex(value) + byte_to_hex(hex_size(script_hex)) + script_hex
  end
end
output_script = bitcoin_script '2N959B4qEPkce8jbzQC7EQaS6uaEBB9YTgQ'
output = Output.new 1_000_000, output_script

change_value = input.value - output.value - 10_000
change_script = bitcoin_script 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'
change = Output.new change_value, change_script

#
# transaction
#
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
    sha256(sha256(serialize + int_to_hex(sighash_type)))
  end

  def sign(private_key, public_key, lock_script, sighash_type = 0x01)
    hash = signature_hash lock_script, sighash_type
    hash_bytes = [hash].pack('H*')
    r, s = ecdsa_sign private_key, hash_bytes
    der = Der.new r: r, s: s
    inputs.first.unlock_script = "#{der.serialize} #{public_key}"
    serialize
  end
end
transaction = Transaction.new 1, [input], [output, change], 0

#
# EC
#
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

#
# ECDSA
#
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

# DER signature format, sighash type is not part of standard DER
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

puts
private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
public_key = '03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1'
lock_script = bitcoin_script 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'

puts 'Signing transaction...'
tx_hex = transaction.sign private_key, public_key, lock_script
puts "TX hash: #{transaction.hash}"
puts "TX hex: #{tx_hex}"
