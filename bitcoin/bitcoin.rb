require 'digest'
require 'base58'

#
# secp256k1 domain parameters
#
G = '0479BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8'
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
puts "Base point: #{G}"
puts "Base point X coordinate: #{Gx.to_i}"
puts "Base point Y coordinate: #{Gy.to_i}"
puts

p = 2**256 - 2**32 - 2**9 - 2**8 - 2**7 - 2**6 - 2**4 - 1
puts "Prime number (dec): #{p}"
puts "Prime number (hex): #{p.to_s(16)}"
puts

#
# 0. Private key
#
k = 0x18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725
# k = 0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010
puts "Private key (bin): #{k.to_s(2)}"
puts "Private key (dec): #{k}"
puts "Private key (hex): #{k.to_s(16)}"
puts

#
# 1. Public key
#
# TODO: better understanding of multiplicative inverse, point addition, point doubling
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

# PDx, PDy = ec_double(Gx, Gy, p)
# PAx, PAy = ec_add(Gx, Gy, Px, Py, p)
Px, Py = ec_multiply(k, Gx, Gy, p)
puts "Px: #{Px.to_s(16)}"
puts "Py: #{Py.to_s(16)}"
# raise "Not Equal: #{ PAx.to_s(16) } != #{ PMx.to_s(16) }" if PAx != PMx

P = "#{Py > 0 ? '02' : '03'}#{Px.to_s(16)}"
puts "Public key (P): #{P}"

((Px**3 + 7 - Py**2) % p == 0) || raise('ERROR: public key point is not on the curve')
puts

#
# 2. Generating SHA256
#
sha256=Digest::SHA256.hexdigest([P].pack('H*'))
puts "SHA256: #{sha256}"
puts

#
# 3. Generating RIPEMD160
#
ripemd160=Digest::RMD160.hexdigest([sha256].pack('H*'))
puts "RIPEMD160: #{ripemd160}"
puts

#
# 4.5.6.7.8. Wrap version byte and checksum
#
network='00'
with_version="#{network}#{ripemd160}"
# puts "WITH VERSION: #{with_version}"
checksum=Digest::SHA256.hexdigest([Digest::SHA256.hexdigest([with_version].pack('H*'))].pack('H*'))[0, 8]
# puts "CHECKSUM: #{checksum}"
wrap_encode="#{with_version}#{checksum}"
puts "WRAP ENCODE: #{wrap_encode}"
puts

#
# 9. Bitcoin address
#
A=Base58.binary_to_base58([wrap_encode].pack('H*'), :bitcoin)
puts "Bitcoin Address: #{A}"
puts
