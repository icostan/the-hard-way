require 'digest'
require 'securerandom'

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

def base58(binary_hash)
  alphabet = '123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz'
  value = binary_hash.unpack('H*')[0].to_i 16
  output = ''
  while value > 0
    remainder = value % 58
    value /= 58
    output += alphabet[remainder]
  end
  output += alphabet[0] * binary_hash.bytes.find_index{|b| b != 0}
  output.reverse
end

def sign(k, signature_hash, sighash)
  r = SecureRandom.hex(32).to_i 16
  r < EC_n || raise('random ephemeral private key is too big')
  rx, ry = ec_multiply(r, EC_Gx, EC_Gy, EC_p)
  rx > 0 || raise('rx is zero, try again')
  i_r = inverse r, EC_p
  m = signature_hash.to_i 16
  s = i_r * (m + k * rx) % EC_p
  s > 0 || raise('s is zero, try again')
  encode_der rx, s, sighash
end

def encode_der(r, s, sighash_type)
  r_hex = r.to_s(16).rjust 66, '0'
  s_hex = s.to_s(16).rjust 64, '0'
  sighash_type_hex = sighash_type.to_s(16).rjust 2, '0'
  "30450221#{r_hex}0220#{s_hex}#{sighash_type_hex}"
end

# Utils
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

# transaction input
Input = Struct.new :tx_hash, :index, :unlock_script, :sequence do
  def serialize
    script_hex = script_to_hex(unlock_script)
    hash_to_hex(tx_hash) + int_to_hex(index) + byte_to_hex(hex_size(script_hex)) + script_hex + int_to_hex(sequence)
  end
end

# transaction output
Output = Struct.new :amount, :lock_script do
  def serialize
    script_hex = script_to_hex(lock_script)
    long_to_hex(amount) + byte_to_hex(hex_size(script_hex)) + script_hex
  end
end

# transaction
Transaction = Struct.new :version, :inputs, :outputs, :locktime do
  def serialize
    inputs_hex = inputs.map(&:serialize).join
    outputs_hex = outputs.map(&:serialize).join
    int_to_hex(version) + byte_to_hex(inputs.size) + inputs_hex + byte_to_hex(outputs.size) + outputs_hex + int_to_hex(locktime)
  end

  def hash
    hash_to_hex sha256(sha256(serialize))
  end

  def signature_hash(sighash = 1)
    sha256(sha256(serialize + int_to_hex(sighash)))
  end

  def endorsement(k, lock_script, sighash = 1)
    inputs.first.unlock_script = lock_script
    hash = signature_hash sighash
    sign k, hash, sighash
  end
end
