require 'rspec'
require_relative 'bitcoin'

RSpec.describe 'bitcoin' do
  describe Der do
    it '#initialize' do
      der = Der.new r: 'r'
      expect(der.r).to eq 'r'
      expect(der.s).to be_nil
      expect(der.sighash_type).to eq 0x01
    end

    it '#serialize' do
      signature = '3045022100884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb02204b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e381301'
      der = Der.new r: 0x884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb,
                    s: 0x4b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e3813
      expect(der.serialize).to eq signature
    end

    it '.parse' do
      signature = '3045022100884d142d86652a3f47ba4746ec719bbfbd040a570b1deccbb6498c75c4ae24cb02204b9f039ff08df09cbe9f6addac960298cad530a863ea8f53982c09db8f6e381301'
      der = Der.parse signature
      expect(der.der).to eq 0x30
      expect(der.length).to eq 0x45
      expect(der.sighash_type).to eq 0x01
    end
  end

  describe Transaction do
    it '#serialize' do
      input = Input.new '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0, '', 0xffffffff
      t = Transaction.new 1, [input], [], 0
      expect(t.serialize).to eq '0100000001b3807042c92f449bbf79b33ca59d7dfec7f4cc71096704a9c526dddf496ee0970000000000ffffffff0000000000'
    end

    it '#hash' do
      input = Input.new '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0, '', 0xffffffff
      t = Transaction.new 1, [input], [], 0
      expect(t.hash).to eq '0021a5a6876307b6093da76ab62e9487ad9a5a32b8a39cf6263064990e9253bb'
    end

    it '#signature_hash' do
      input = Input.new '97e06e49dfdd26c5a904670971ccf4c7fe7d9da53cb379bf9b442fc9427080b3', 0, 'OP_DUP OP_HASH160 88350574280395ad2c3e2ee20e322073d94e5e40 OP_EQUALVERIFY OP_CHECKSIG', 0xffffffff
      t = Transaction.new 1, [input], [], 0
      expect(t.signature_hash).to eq 'f89572635651b2e4f89778350616989183c98d1a721c911324bf9f17a0cf5bf0'
    end

    it '#endorsement' do
      private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
      public_key = 0x03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1
      lock_script = 'OP_DUP OP_HASH160 d7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG'
      input = Input.new 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1, '', 0xffffffff
      output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
      t = Transaction.new 1, [input], [output], 0
      endorsement = t.endorsement private_key, public_key, lock_script
      # expect(endorsement).to eq '3045022100b290086350a59ce28dd80cc89eac80eac097c20a50ed8c4f35b1ecbed789b65c02200129f4c34a9b05705d4f5e55acff0ce44b5565ab4a8c7faa4a74cf5e1367451101'
    end

    it '#sign' do
      private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
      public_key = '03996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1'
      lock_script = 'OP_DUP OP_HASH160 d7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG'
      input = Input.new 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1, '', 0xffffffff
      output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
      t = Transaction.new 1, [input], [output], 0
      hex = t.endorse private_key, public_key, lock_script
      # puts hex
      h = '010000000193df6c67046aa304d6f08533cbbf87731fea9399d91a76f4080e0676a4e20dd3010000006b4830450221008a0637decccbd0c48c5f36d56cd3853db53eb2f04a87e44c14cc7f14cfea54cf02208061e91418cc8e95d732618966648878733ed52b58765b49111e60da2c068db8012103996c918f74f0a6f1aeed99ebd81ab8eed8df99bc96fc082b20839259d332bad1ffffffff010090d0030000000017a914f81498040e79014455a5e8f7bd39bce5428121d38700000000'
      # expect(hex).to eq h
    end
  end

  describe 'sign and verify' do
    before do
      message = 'Hello World!'
      @private_key = 5124534118363973067682110154994366664263350313713476914759747396381294262665
      @px, @py = ec_multiply @private_key, EC_Gx, EC_Gy, EC_p
      @temp_key = 8170412689086572914872624726984617755309377628698418075870043184004257040259
      @digest = Digest::SHA256.digest(message)
    end

    it 'with ECDSA gem' do
      require 'ecdsa'
      group = ECDSA::Group::Secp256k1
      public_key = ECDSA::Point.new group, @px, @py

      signature = ECDSA.sign(group, @private_key, @digest, @temp_key)
      valid = ECDSA.valid_signature?(public_key, @digest, signature)
      expect(valid).to be_truthy
    end

    describe 'with cryptocrafts' do
      it 'same temp key' do
        r, s = sign(@private_key, @digest, @temp_key)
        valid = verify?(@px, @py, @digest, [r, s])
        expect(valid).to be_truthy
      end
      it 'new temp key' do
        r, s = sign(@private_key, @digest)
        valid = verify?(@px, @py, @digest, [r, s])
        expect(valid).to be_truthy
      end
    end

    describe 'transaction' do
      it 'endorsement hash' do
        private_key = 0x79020296790075fc8e36835e045c513df8b20d3b3b9dbff4d043be84ae488f8d
        px, py = ec_multiply private_key, EC_Gx, EC_Gy, EC_p
        lock_script = 'OP_DUP OP_HASH160 d7d35ff2ed9cbc95e689338af8cd1db133be6a4a OP_EQUALVERIFY OP_CHECKSIG'
        input = Input.new 'd30de2a476060e08f4761ad99993ea1f7387bfcb3385f0d604a36a04676cdf93', 1, '', 0xffffffff
        output = Output.new 64000000, 'OP_HASH160 f81498040e79014455a5e8f7bd39bce5428121d3 OP_EQUAL'
        t = Transaction.new 1, [input], [output], 0
        hash = t.endorsement_hash lock_script
        hash_bytes = [hash].pack('H*')
        r, s = sign private_key, hash_bytes
        valid = verify? px, py, hash_bytes, [r, s]
        expect(valid).to be_truthy
      end
    end
  end

  describe 'utils' do
    before do
      @x = 0x09A4D6792295A7F730FC3F2B49CBC0F62E862272F
      @x_hex = @x.to_s 16
      @x_bytes = [@x_hex].pack 'H*'
    end
    it '#bytes2int' do
      expect(bytes2int(@x_bytes)).to eq @x
    end
    it '#int2bytes' do
      expect(int2bytes(@x)).to eq @x_bytes
    end
  end
end
