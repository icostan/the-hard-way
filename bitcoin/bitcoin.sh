#!/usr/bin/env sh

set -e

G=0479BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
p=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
n=FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141


echo The easy way...
echo
seed=$(bx seed)
echo $seed
echo $seed | bx ec-new | bx ec-to-public -u | bx ec-to-address
echo $seed | bx ec-new | bx ec-to-public -u | bx sha256 | bx ripemd160 | bx wrap-encode | bx base58-encode
echo $seed | bx ec-new | bx ec-multiply $G | bx sha256 | bx ripemd160 | bx wrap-encode | bx base58-encode

echo
echo The hard way...
echo
echo 0. Private key
# random
# k_in_bin=000000000000000000000000000000001111110010101010000010111111000000011111111111000000000011111110100101111100011000000000111011110000000000111111000000011111111000000111111111000000000111110010111111100000111100000011111101110000000000111011110000010100
# k_in_hex=$(echo "obase=16;ibase=2;$k_in_bin" | bc)

# mine
# k_in_bin=
# k_in_dec=265984200
# k_in_hex=000000000000000000000000000000000000000000000000000000000fda98c8

# 2
k_in_bin=000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010
k_in_hex=000000000000000000000000000000000000000000000000000000000000000$(echo "obase=16;ibase=2;$k_in_bin" | bc)
k_in_dec=$(echo "obase=10;ibase=2;$k_in_bin" | bc)

# Bitcoin Wiki: Technical background of version 1 Bitcoin addresses 18e14a7b6a307f426a94f8114701e7c8e774e7f9a47e2c2035db29a206321725
# k_in_bin=1100011100001010010100111101101101010001100000111111101000010011010101001010011111000000100010100011100000001111001111100100011100111011101001110011111111001101001000111111000101100001000000011010111011011001010011010001000000110001100100001011100100101
# k_in_hex=$(echo "obase=16;ibase=2;$k_in_bin" | bc)
# k_in_dec=$(echo "obase=10;ibase=2;$k_in_bin" | bc)

echo "Private key size: $(echo -n $k_in_bin | wc -c) bits"
echo "Private key in bin: $k_in_bin"
echo "Private key in dec: $k_in_dec"
echo "Private key in hex: $k_in_hex"
echo
echo 1. Public key
P=$(bx ec-to-public $k_in_hex)
echo $P
echo 02$(bx ec-multiply $G $k_in_hex | head -c 66 | tail -c 64)
bx ec-to-public -u $k_in_hex


echo
echo 2. Generating SHA256...
S=$(bx sha256 $P)
echo $S
ruby -rdigest -e "puts Digest::SHA256.hexdigest(['$P'].pack('H*'))"


echo
echo 3. Generating RIPEMD160...
R=$(bx ripemd160 $S)
echo $R
ruby -rdigest -e "puts Digest::RMD160.hexdigest(['$S'].pack('H*'))"


echo
echo 4.5.6.7.8 Wrap version byte and checksum...
V=$(bx wrap-encode $R)
echo $V
V1=00$R
S1=$(ruby -rdigest -e "puts Digest::SHA256.hexdigest(['$V1'].pack('H*'))")
S2=$(ruby -rdigest -e "puts Digest::SHA256.hexdigest(['$S1'].pack('H*'))")
C=$(echo $S2 | head -c 8)
W=$V1$C
echo $W


echo
echo 9. Bitcoin address...
A=$(bx base58-encode $V)
echo $A
bx base58-encode $W


echo
echo 10. Get rich
bx fetch-balance $A
