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
p = 2**256 - 2**32 - 2**9 - 2**8 - 2**7 - 2**6 - 2**4 - 1
puts "Prime number (dec): #{p}"
puts "Prime number (hex): #{p.to_s(16)}"
puts

#
# 0. Private key
#
k = 0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010
puts "Private key (bin): #{'0' * 254 + '10'}"
puts "Private key (dec): #{k}"
puts "Private key (hex): #{k.to_s(16)}"
puts

#
# 1. Public key
#
# i2Gy = -32617584047406127887053860912668548655625778953140441154984154756096705713545

# TODO: better understanding of multiplicative inverse
def GCD(a, b)
  return [0, 1] if a.zero?
  x1, y1 = GCD(b % a, a)
  [y1 - (b / a) * x1, x1]
end
i_2Gy = GCD(2 * Gy, p).first
# puts "i_2Gy: #{i_2Gy}"

# TODO: better understanding of EC point doubling
slope = (3 * (Gx**2 % p) * i_2Gy)
# puts slope
x = (slope**2 % p) - 2 * Gx
# puts x
y = slope * (Gx-x) - Gy
# puts y

Px = x % p
puts "Px: #{Px}"
Py = y % p
puts "Py: #{Py}"
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
# 4.5.6.7.8 Wrap version byte and checksum
#
with_version="00#{ripemd160}"
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
