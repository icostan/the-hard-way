#!/usr/bin/env ruby

require_relative 'bitcoin'

fees = 10_000

input = Input.new 25_000_000, '6b22d8a69432774ebbc00566755ff8da241be83c1b364ca177e241e23a0e111c', 0

output_script = bitcoin_p2pkh_script '2N959B4qEPkce8jbzQC7EQaS6uaEBB9YTgQ'
output = Output.new 1_000_000, output_script

change_value = input.value - output.value - fees
change_script = bitcoin_p2pkh_script 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'
change = Output.new change_value, change_script

transaction = Transaction.new 1, [input], [output, change], 0

private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
puts "Private key: #{private_key.to_s 16}"
public_key = '03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1'
puts "Public key: #{public_key}"
lock_script = bitcoin_p2pkh_script 'n1C8nsmi4sc4hMBGgVZrnhxeFtk1sTbMZ4'
puts "Lock script: #{lock_script}"

puts
puts 'Signing transaction...'
tx_hex = transaction.sign private_key, public_key, lock_script
puts "TX hash: #{transaction.hash}"
puts "TX hex: #{tx_hex}"
