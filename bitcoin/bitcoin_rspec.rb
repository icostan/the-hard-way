require 'rspec'
require_relative 'bitcoin'

RSpec.describe 'bitcoin' do
  it 'serialize' do
    input = Input.new '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0, '', 0xffffffff
    t = Transaction.new 1, [input], [], 0
    expect(t.serialize).to eq '0100000001b3807042c92f449bbf79b33ca59d7dfec7f4cc71096704a9c526dddf496ee0970000000000ffffffff0000000000'
  end

  it 'hash' do
    input = Input.new '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0, '', 0xffffffff
    t = Transaction.new 1, [input], [], 0
    expect(t.hash).to eq '0021a5a6876307b6093da76ab62e9487ad9a5a32b8a39cf6263064990e9253bb'
  end

  it 'signature hash' do
    input = Input.new '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0, 'OP_DUP OP_HASH160 88350574280395ad2c3e2ee20e322073d94e5e40 OP_EQUALVERIFY OP_CHECKSIG', 0xffffffff
    t = Transaction.new 1, [input], [], 0
    expect(t.signature_hash).to eq 'f89572635651b2e4f89778350616989183c98d1a721c911324bf9f17a0cf5bf0'
  end

  it 'endorsement' do
    k = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
    lock_script = 'OP_DUP OP_HASH160 d7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG'
    input = Input.new 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1, '', 0xffffffff
    output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
    t = Transaction.new 1, [input], [output], 0
    endorsement = t.endorsement k, lock_script
    expect(endorsement).to eq '3045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e1367451101'
  end
end
