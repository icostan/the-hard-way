# Bitcoin

## TL;DR;

  * private key is just a number (just like a PIN code) but very large of `10^77` order (think about this in context of number of atoms in the known, observable universe which is `10^80`)
  * public key is just a scalar multiplication of private key and a point on Elliptic curve
  * Bitcoin address is derived from public key by doing some SHA256 hashing and adding network prefix and checksum suffix

## Elliptic Curve domain parameters defined in secp256k1 paper.

Domain parameters defined in secp256k1 paper are: p,a,b,G,n,h

### Prime number - p

``` ruby
ruby> p = 2**256 - 2**32 - 2**9 - 2**8 - 2**7 - 2**6 - 2**4 - 1
Prime number (dec): 115792089237316195423570985008687907853269984665640564039457584007908834671663
Prime number (hex): fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f
```

### Elliptic Curve (EC) - a, b

In general Elliptic Curves are defined as `y^2 = x^3 + ax + b` equation but since `a = 0` and `b = 7` it becomes `y^2 = x^3 + 7` which is the EC used in Bitcoin.

### Generator Point - G

A point on EC, `(x,y)` coordinates represented in uncompressed format as a concatenation of `x` and `y` prefixed with `04` or in compressed format as `x` coordinate prefix with `02`.

``` ruby
ruby> G = '0479BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8'
Uncompressed format: 0479BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8

ruby> Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
X coordinate (dec): 55066263022277343669578718895168534326250603453777594175500187360389116729240

ruby> Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
Y coordinate (dec): 32670510020758816978083085130507043184471273380659243275938904335757337482424
```

### Order and cofactor - n and h

TBD

## 0. Private key

We all know that Bitcoin private key is 256 bits long, let's generate a very simple one by hitting 0 and 1 keys multiple times.

``` ruby
ruby> k = 0b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010
Private key (bin): 0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010
Private key (dec): 2
Private key (hex): 2
```

That's right, this is a valid private key even if is a very weak one but is enough for the purpose of this article.

## 1. Public key

Now, public key is nothing than a scalar multiplication of private key (k) and elliptic curve generator point (G) as `P = k * G`.

## 2. SHA256 hashing

``` ruby

sha256=Digest::SHA256.hexdigest([P].pack('H*'))
```

``` shell
SHA256: b1c9938f01121e159887ac2c8d393a22e4476ff8212de13fe1939de2a236f0a7
```

## 3. RIPEMD160 hashing

``` ruby
ripemd160=Digest::RMD160.hexdigest([sha256].pack('H*'))
```

``` shell
RIPEMD160: 06afd46bcdfd22ef94ac122aa11f241244a37ecc
```

## 4. Add version byte

Version byte and resulting Base58 prefix:
  * 0x00 - Bitcoin address - 1
  * 0x05 - Pay-to-Script-Hash address - 3
  * 0x6F - Testnet address - m or n
  * 0x80 - Private key WIF - 5, K or L

``` ruby
with_version="00#{ripemd160}"
```

``` shell
WITH VERSION: 0006afd46bcdfd22ef94ac122aa11f241244a37ecc
```

## 5.6.7. Calculate checksum

Double SHA256 of previously calculated RIPEMD160 prefixed with version byte:

``` ruby
checksum=Digest::SHA256.hexdigest([Digest::SHA256.hexdigest([with_version].pack('H*'))].pack('H*'))[0, 8]
```

``` shell
CHECKSUM: 88462f2a
```

## 8. Wrap encoding

``` ruby
wrap_encode="#{with_version}#{checksum}"
```

``` shell
WRAP ENCODE: 0006afd46bcdfd22ef94ac122aa11f241244a37ecc88462f2a
```

## 9. Bitcoin address

``` ruby
A=Base58.binary_to_base58([wrap_encode].pack('H*'), :bitcoin)
```

``` shell
Bitcoin Address: 1cMh228HTCiwS8ZsaakH8A8wze1JR5ZsP
```

# References

  *[secp256k1](https://en.bitcoin.it/wiki/Secp256k1)
  *[Elliptic curve point multiplication](https://en.wikipedia.org/wiki/Elliptic_curve_point_multiplication)
  *[Bitcoin address generation](https://en.bitcoin.it/wiki/Technical_background_of_version_1_Bitcoin_addresses)
