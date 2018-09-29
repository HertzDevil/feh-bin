#!/usr/bin/env ruby

require 'forwardable'

module Feh module Bin
  # Single-pass input array stream that reads little-endian integers.
  class ArrayIStream
    extend Forwardable

    # @!attribute [r] size
    #   @return [Integer] the size of the underlying array stream
    def_delegators :@buf, :[], :size

    # @return [Integer] the number of bytes read so far
    attr_reader :bytes_read

    # Initializes the stream.
    # @param buffer [Array<Integer>] an array of byte values between 0 and 255
    # @raise [ArgumentError] if *arr* is not a byte array
    def initialize(buffer)
      raise ArgumentError, 'Input is not a byte array' unless
        buffer.is_a?(Array) &&
        buffer.all? {|x| x.is_a?(Integer) && x.between?(0, 255)}
      @buf = buffer
      @bytes_read = 0
    end

    # Attempts to read an unsigned 8-bit integer.
    # @return [Integer] the integer read
    # @return [nil] if not enough bytes remaining are present to form an integer
    def u8
      return nil if @bytes_read > @buf.size - 1
      x = @buf[@bytes_read]
      @bytes_read += 1
      x
    end

    # Attempts to read an unsigned 16-bit integer.
    # @return [Integer] the integer read
    # @return [nil] if not enough bytes remaining are present to form an integer
    def u16
      return nil if @bytes_read > @buf.size - 2
      x = @buf[@bytes_read]
      x |= @buf[@bytes_read + 1] << 8
      @bytes_read += 2
      x
    end

    # Attempts to read an unsigned 32-bit integer.
    # @return [Integer] the integer read
    # @return [nil] if not enough bytes remaining are present to form an integer
    def u32
      return nil if @bytes_read > @buf.size - 4
      x = @buf[@bytes_read]
      x |= @buf[@bytes_read + 1] << 8
      x |= @buf[@bytes_read + 2] << 16
      x |= @buf[@bytes_read + 3] << 24
      @bytes_read += 4
      x
    end

    # Returns the unread bytes of the stream.
    # @return [Array<Integer>] An array of unread bytes.
    def remaining
      @buf[@bytes_read..-1]
    end
  end
end end
