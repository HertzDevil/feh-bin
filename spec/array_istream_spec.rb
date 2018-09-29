#!/usr/bin/env ruby

require_relative 'env'

describe Feh::Bin::ArrayIStream do
  describe '.new' do
    it 'validates the input' do
      assert_raises(ArgumentError) {ArrayIStream.new nil}
      assert_raises(ArgumentError) {ArrayIStream.new ''}
      assert_raises(ArgumentError) {ArrayIStream.new [0.5]}
      assert_raises(ArgumentError) {ArrayIStream.new [-1]}
      ArrayIStream.new [0, 255]
    end
  end

  describe '#size' do
    it 'returns the size of the input buffer' do
      assert_equal ArrayIStream.new([]).size, 0
      assert_equal ArrayIStream.new([0]).size, 1
    end
  end

  describe '#u8' do
    it 'reads an unsigned 8-bit integer' do
      a = ArrayIStream.new([0x0A, 0x0B, 0xFC])
      assert_equal a.u8, 0x0A
      assert_equal a.u8, 0x0B
      assert_equal a.u8, 0xFC
      assert_nil a.u8
    end
  end

  describe '#u16' do
    it 'reads an unsigned 16-bit integer' do
      a = ArrayIStream.new([0x01, 0x23, 0x45, 0xF7, 0x89])
      assert_equal a.u16, 0x2301
      assert_equal a.u16, 0xF745
      assert_nil a.u16
    end
  end

  describe '#u32' do
    it 'reads an unsigned 32-bit integer' do
      a = ArrayIStream.new([0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF, 0x00])
      assert_equal a.u32, 0x67452301
      assert_equal a.u32, 0xEFCDAB89
      assert_nil a.u32
    end
  end

  describe '#bytes_read' do
    it 'returns the number of bytes read' do
      a = ArrayIStream.new([0x00, 0x01, 0x02, 0x03])
      assert_equal a.bytes_read, 0
      a.u8
      assert_equal a.bytes_read, 1
      a.u16
      assert_equal a.bytes_read, 3
      a.u16
      assert_equal a.bytes_read, 3
      a.u8
      assert_equal a.bytes_read, 4
    end
  end

  describe '#remaining' do
    it 'returns the unread bytes' do
      a = ArrayIStream.new([0x00, 0x01, 0x02, 0x03])
      assert_equal a.remaining, [0x00, 0x01, 0x02, 0x03]
      a.u8
      assert_equal a.remaining, [0x01, 0x02, 0x03]
      a.u16
      assert_equal a.remaining, [0x03]
      a.u16
      assert_equal a.remaining, [0x03]
      a.u8
      assert_empty a.remaining
    end
  end
end
