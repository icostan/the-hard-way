require_relative 'bitcoin-transaction'
require 'rspec'

RSpec.describe 'bitcoin' do
  it 'hash' do
    input = Input.new '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0, '', 0xffffffff
    t = Transaction.new 1, [input], [], 0
    expect(t.hash).to eq '0021a5a6876307b6093da76ab62e9487ad9a5a32b8a39cf6263064990e9253bb'
  end

  it 'signature hash' do
    input = Input.new '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0, 'OP_DUP OP_HASH160 D7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG', 0xffffffff
    t = Transaction.new 1, [input], [], 0
    expect(t.signature_hash).to eq 'f89572635651b2e4f89778350616989183c98d1a721c911324bf9f17a0cf5bf0'
  end
end
