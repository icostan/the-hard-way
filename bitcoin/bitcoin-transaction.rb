#!/usr/bin/env ruby

require_relative 'bitcoin'

fees = 10_000

input_value = 10_100_000
input = Input.new '2b8b8c0577d631a2988a228e919efb8f5a60fbce5271794dddd5cfcb18890fb4', 0, '', 0xfffffffff

output_value = 10_000_000
output_script = bitcoin_p2pkh_script '2NFrxEjw5v2i7L8pm9dWjWSFpDRXmj8dBTn'
output = Output.new output_value, output_script

charge_value = input_value - output_value - fees
charge_script = bitcoin_p2pkh_script 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'
charge = Output.new charge_value, charge_script

transaction = Transaction.new 1, [input], [output, charge], 0

private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
puts "Private key: #{private_key.to_s 16}"
public_key = '03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1'
puts "Public key: #{p}"
lock_script = 'OP_DUP OP_HASH160 d7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG'
puts "Lock script: #{lock_script}"

puts
tx_hex = transaction.sign private_key, public_key, lock_script
puts "TX hash: #{transaction.hash}"
puts "TX hex: #{tx_hex}"
