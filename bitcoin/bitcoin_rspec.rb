require 'rspec'
require_relative 'bitcoin'

RSpec.describe 'bitcoin' do
  describe Transaction do
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
    end
  end

  describe 'sign and verify' do
    before do
      message = 'Hello World!'
      @private_key = 5124534118363973067682110154994366664263350313713476914759747396381294262665
      @px, @py = ec_multiply @private_key, EC_Gx, EC_Gy, EC_p
      @temp_key = 8170412689086572914872624726984617755309377628698418075870043184004257040259
      @digest = Digest::SHA256.hexdigest(message)
      # puts "Message digest: #{@digest}"
    end

    it 'with ECDSA gem' do
      # puts '==> ECDSA'
      require 'ecdsa'
      group = ECDSA::Group::Secp256k1
      public_key = ECDSA::Point.new group, @px, @py

      signature1 = ECDSA.sign(group, @private_key, @digest, @temp_key)
      # puts signature1.inspect
      valid1 = ECDSA.valid_signature?(public_key, @digest, signature1)
      expect(valid1).to be_truthy
    end

    it 'with cryptocrafts' do
      # puts '==> CryptoCrafts'
      r, s = sign(@private_key, @digest, @temp_key)
      # puts [r, s].inspect
      valid2 = verify?(@px, @py, @digest, [r, s])
      expect(valid2).to be_truthy
    end
  end
end
