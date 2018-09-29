#!/usr/bin/env ruby

require 'forwardable'

module Feh module Bin
  # Single-pass output array stream that writes little-endian integers.
  class ArrayOStream

    # @return [Array<Integer>] the stream content
    def buf
      @buf.dup
    end

    # @return [Integer] the number of bytes written so far
    def bytes_written
      @buf.size
    end

    # Initializes the stream.
    def initialize
      @buf = []
    end

    # Writes an unsigned 8-bit integer.
    # @param x [Integer] integer value to write
    # @return [ArrayOStream] self
    def u8(x)
      write [x & 0xFF]
    end

    # Writes an unsigned 16-bit integer.
    # @param x [Integer] integer value to write
    # @return [ArrayOStream] self
    def u16(x)
      write [x & 0xFF, (x >> 8) & 0xFF]
    end

    # Writes an unsigned 32-bit integer.
    # @param x [Integer] integer value to write
    # @return [ArrayOStream] self
    def u32(x)
      write [x & 0xFF, (x >> 8) & 0xFF, (x >> 16) & 0xFF, (x >> 24) & 0xFF]
    end

    # Writes an array of bytes.
    # @param arr [Array<Integer>] an array of byte values
    # @return [ArrayOStream] self
    # @raise [ArgumentError] if *arr* is not a byte array
    def write(arr)
      raise ArgumentError, 'Input is not a byte array' unless
        arr.is_a?(Array) &&
        arr.all? {|x| x.is_a?(Integer) && x.between?(0, 255)}
      write2(arr)
    end

  private
    def write2(arr)
      @buf += arr
      self
    end
  end
end end
