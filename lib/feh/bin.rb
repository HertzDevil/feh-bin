require 'feh/bin/version'

require 'feh/bin/lz11'

module Feh
  module Bin
    # Decompresses a .bin.lz file.
    # @param buf [Array<Integer>, String] content of the .bin.lz file
    # @return [Array<Integer>] content of the decompressed asset data
    # @return [Symbol] error code if the input is not a valid .bin.lz file
    def self.decompress(buf)
      buf = buf.bytes if buf.is_a?(String)
      read_bin_lz(buf)
#      buf = read_bin_lz(buf)
#      return buf if buf.is_a?(Symbol)
#      LZ11.new(buf).decompress
    end

    # Compresses data into a .bin.lz file.
    # @param buf [Array<Integer>, String] content of the data to compress
    # @return [Array<Integer>] content of the .bin.lz file
    # @return [Symbol] error code if the input is not a valid data buffer
    def self.compress(buf)
      buf = buf.bytes if buf.is_a?(String)
      buf = LZ11.new(buf).compress
      return buf if buf.is_a?(Symbol)
      write_bin_lz(buf)
    end

    # Unpacks a Fire Emblem Heroes .bin.lz file.
    # @param buf [Array<Integer>, String] content of the .bin.lz file
    # @return [Array<Integer>] content of the unpacked LZ11 archive
    # @return [Symbol] error code if the input is not a valid .bin.lz file
    def self.read_bin_lz(buf)
      buf = buf.bytes if buf.is_a?(String)
      header = buf.shift(4)
      xorseed = header[1] | (header[2] << 8) | (header[3] << 16)
      if (header.first & 0xFF) == 0x17 && (buf.first & 0xFF) == 0x11
        xorkey = [0x8083 * xorseed].pack('<I').bytes
        (4...buf.size).step(4).each do |i|
          4.times {|j| buf[i + j] ^= xorkey[j]}
          4.times {|j| xorkey[j] ^= buf[i + j]}
        end
        LZ11.new(buf).decompress
      elsif header.first == 0x04 && xorseed == buf.size
        xorkey = [0x8083 * xorseed].pack('<I').bytes
        (0...buf.size).step(4).each do |i|
          4.times {|j| buf[i + j] ^= xorkey[j]}
          4.times {|j| xorkey[j] ^= buf[i + j]}
        end
        buf
      else
        :invalid_archive
      end
    end

    # Packs a Fire Emblem Heroes .bin.lz file.
    # @param buf [Array<Integer>, String] content of an LZ11 archive
    # @return [Array<Integer>] content of the packed .bin.lz file
    # @return [Symbol] error code if the input is not a valid LZ11 archive
    def self.write_bin_lz(buf)
      buf = buf.bytes if buf.is_a?(String)
      bytes = LZ11.new(buf).compress
      return bytes if bytes.is_a?(Symbol)
      bytes += [0] * ((-bytes.size) % 4)
      xorseed = buf.size
      header = [xorseed * 0x100 + 0x17].pack('<I').bytes
      xorkey = [0x8083 * xorseed].pack('<I').bytes
      4.times {|j| bytes[4 + j] ^= xorkey[j]}
      (8...bytes.size).step(4).each do |i|
        4.times {|j| bytes[i + j] ^= bytes[i - 4 + j]}
      end
      header + bytes
    end
  end
end
