#!/usr/bin/env ruby

require_relative 'env'

describe Feh::Bin::ArrayOStream do
  describe '#buf' do
    it 'returns the written bytes' do
      assert_empty ArrayOStream.new.buf
    end
  end

  describe '#bytes_written' do
    it 'returns the number of bytes written' do
      assert_equal ArrayOStream.new.bytes_written, 0
      assert_equal ArrayOStream.new.u8(0).bytes_written, 1
      assert_equal ArrayOStream.new.u16(0).bytes_written, 2
      assert_equal ArrayOStream.new.u32(0).bytes_written, 4
    end
  end

  describe '#u8' do
    it 'writes an unsigned 8-bit integer' do
      assert_equal ArrayOStream.new.u8(0).u8(-1).u8(255).buf, [0x00, 0xFF, 0xFF]
    end
  end

  describe '#u16' do
    it 'writes an unsigned 16-bit integer' do
      assert_equal ArrayOStream.new.u16(1).u16(-2).buf,
        [0x01, 0x00, 0xFE, 0xFF]
    end
  end

  describe '#u32' do
    it 'writes an unsigned 32-bit integer' do
      assert_equal ArrayOStream.new.u32(1).u32(-2).buf,
        [0x01, 0x00, 0x00, 0x00, 0xFE, 0xFF, 0xFF, 0xFF]
    end
  end

  describe '#write' do
    it 'writes a byte array' do
      assert_equal ArrayOStream.new.write([1]).write([]).write([2, 3]).buf,
        [1, 2, 3]
    end

    it 'validates the input' do
      assert_raises(ArgumentError) {ArrayOStream.new.write(nil)}
      assert_raises(ArgumentError) {ArrayOStream.new.write('')}
      assert_raises(ArgumentError) {ArrayOStream.new.write([0.5])}
      assert_raises(ArgumentError) {ArrayOStream.new.write([-1])}
    end
  end
end
