#!/usr/bin/env ruby

require_relative 'bitcoin'

input = Input.new '2b8b8c0577d631a2988a228e919efb8f5a60fbce5271794dddd5cfcb18890fb4', 0, '', 0xfffffffff
output = Output.new 10_000_000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
transaction = Transaction.new 1, [input], [output], 0
puts "TX bin: #{transaction.serialize}"
puts "TX hash: #{transaction.hash}"

private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
puts "Private key: #{private_key.to_s 16}"
public_key = '03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1'
puts "Public key: #{public_key}"
lock_script = 'OP_DUP OP_HASH160 d7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG'
puts "Lock script: #{lock_script}"

puts
tx_hex = transaction.sign private_key, public_key, lock_script
puts "TX: #{tx_hex}"
