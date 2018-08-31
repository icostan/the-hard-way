#!/usr/bin/env ruby

require_relative 'bitcoin'


input = Input.new 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1, '', 0xfffffffff
puts "IN: #{input.serialize}"

output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
puts "OUT: #{output.serialize}"

puts
transaction = Transaction.new 1, [input], [output], 0
puts "TX bin: #{transaction.serialize}"
puts "TX hash: #{transaction.hash}"

k = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
puts
puts "PK: #{k}"
puts "TX sign: #{sign k, transaction.signature_hash, 1}"
