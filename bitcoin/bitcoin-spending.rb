#!/usr/bin/env ruby

class Struct
  def hash_to_hex(value)
    [value].pack('H*').reverse.unpack('H*').first
  end
  def int_to_hex(value)
    [value].pack('V').unpack('H*').first
  end
  def byte_to_hex(value)
    [value].pack('C').unpack('H*').first
  end
end

Input = Struct.new :hash, :index, :unlock_script_size, :unlock_script, :sequence do
  def to_hash
    hash_to_hex(hash) + int_to_hex(index) + byte_to_hex(unlock_script_size) + unlock_script + int_to_hex(sequence)
  end
end
input = Input.new '7957a35fe64f80d234d76d83a2a8f1a0d8149a41d81de548f0a65a8a999f6f18', 0, 139, 'dup hash160 [d7d35ff2ed9cbc95e689338af8cd1db133be6a4a] equalverify checksig', 4294967295
puts input.to_hash

Output = Struct.new :amount, :lock_script_size, :lock_script do
  def to_hash
    amount.to_s(16) + lock_script_size.to_s(16) + lock_script
  end
end
output = Output.new 1500000, 25, 'OP_DUP OP_HASH160 ab68025513c3dbd2f7b92a94e0581f5d50f654e7 OP_EQUALVERIFY OP_CHECKSIG'
puts output.to_hash

Transaction = Struct.new :version, :inputs, :outsputs do
  def to_hash
    int_to_hex(version)
  end
end
transaction = Transaction.new 1, [], []
puts transaction.to_hash
