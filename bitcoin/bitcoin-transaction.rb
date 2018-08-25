#!/usr/bin/env ruby

require 'digest'

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
    sha256 = Digest::SHA256.hexdigest([serialize].pack('H*'))
    hash_to_hex Digest::SHA256.hexdigest([sha256].pack('H*'))
  end
end

input = Input.new 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1, '', 0xffffffff
puts "IN: #{input.serialize}"

output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
puts "OUT: #{output.serialize}"

puts
transaction = Transaction.new 1, [input], [output], 0
puts "TX bin: #{transaction.serialize}"
puts "TX hash: #{transaction.hash}"
