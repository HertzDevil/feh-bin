#!/usr/bin/env ruby

require 'forwardable'
require 'feh/bin/array_istream'
require 'feh/bin/array_ostream'

module Feh module Bin
  # Converter for the LZ11 archive format used in Fire Emblem Heroes.
  # Ported from DSDecmp.
  class LZ11
    # @return [ArrayIStream] the input buffer of the converter.
    attr_reader :buf

    # Initializes the LZ11 converter.
    # @param buffer [Array<Integer>] byte array containing the data to convert
    def initialize(buffer)
      @buf = ArrayIStream.new(buffer)
    end

    # Decompresses an LZ11 archive.
    # @return [Array<Integer>] byte array representing the decompressed content
    #   of the input archive
    # @return [Symbol] error code if the input is not a valid LZ11 archive
    def decompress
      header = buf.u32
      return :invalid_data if (header & 0xFF) != 0x11
      decompressedSize = header >> 8
      decompressedSize = buf.u32 if decompressedSize == 0

      bufferLength = 0x1000
      buffer = Array.new(bufferLength)
      bufferOffset = 0

      flags = 0
      mask = 1

      outbuf = []
      until outbuf.size >= decompressedSize
        if mask == 1
          flags = buf.u8
          return :stream_too_short if flags.nil?
          mask = 0x80
        else
          mask >>= 1
        end

        if (flags & mask) > 0
          byte1 = buf.u8
          return :stream_too_short if byte1.nil?

          length = byte1 >> 4
          disp = -1
          case length
          when 0
            byte2 = buf.u8
            byte3 = buf.u8
            return :stream_too_short if byte3.nil?
            length = (((byte1 & 0x0F) << 4) | (byte2 >> 4)) + 0x11
            disp = (((byte2 & 0x0F) << 8) | byte3) + 0x1
          when 1
            byte2 = buf.u8
            byte3 = buf.u8
            byte4 = buf.u8
            return :stream_too_short if byte4.nil?
            length = (((byte1 & 0x0F) << 12) | (byte2 << 4) | (byte3 >> 4)) + 0x111
            disp = (((byte3 & 0x0F) << 8) | byte4) + 0x1
          else
            byte2 = buf.u8
            return :stream_too_short if byte2.nil?
            length = ((byte1 & 0xF0) >> 4) + 0x1
            disp = (((byte1 & 0x0F) << 8) | byte2) + 0x1
          end

          return :invalid_data if disp > outbuf.size

          bufIdx = bufferOffset + bufferLength - disp
          length.times do
            next_byte = buffer[bufIdx % bufferLength]
            bufIdx += 1
            outbuf << next_byte
            buffer[bufferOffset] = next_byte
            bufferOffset = (bufferOffset + 1) % bufferLength
          end
        else
          next_byte = buf.u8
          return :stream_too_short if next_byte.nil?
          outbuf << next_byte
          buffer[bufferOffset] = next_byte
          bufferOffset = (bufferOffset + 1) % bufferLength
        end
      end

      outbuf
    end

    # Compresses a byte buffer.
    # This function is not required to produce exactly the same results as
    # existing archives in Fire Emblem Heroes when given the same inputs.
    # @return [Array<Integer>] byte array representing the compressed LZ11
    #   archive
    # @return [Symbol] error code if the input is too large or empty
    def compress
      return :input_too_short if buf.size < 2
      return :input_too_large if buf.size > 0xFFFFFF

      outstream = ArrayOStream.new
        .u8(0x11).u16(buf.size).u8(buf.size >> 16)

      outbuffer = [8 * 4 + 1] * 33
      outbuffer[0] = 0
      bufferlength = 1
      bufferedBlocks = 0
      readBytes = 0
      while readBytes < buf.size
        if bufferedBlocks == 8
          outstream.write(outbuffer[0, bufferlength])
          outbuffer[0] = 0
          bufferlength = 1
          bufferedBlocks = 0
        end

        oldLength = [readBytes, 0x1000].min
        disp, length = occurrence_length(readBytes,
          [buf.size - readBytes, 0x10110].min, readBytes - oldLength, oldLength)
        if length < 3
          outbuffer[bufferlength] = buf[readBytes]
          readBytes += 1
          bufferlength += 1
        else
          readBytes += length
          outbuffer[0] |= (1 << (7 - bufferedBlocks)) & 0xFF
          case
          when length > 0x110
            outbuffer[bufferlength] = 0x10
            outbuffer[bufferlength] |= ((length - 0x111) >> 12) & 0x0F
            bufferlength += 1
            outbuffer[bufferlength] = ((length - 0x111) >> 4) & 0xFF
            bufferlength += 1
            outbuffer[bufferlength] = ((length - 0x111) << 4) & 0xF0
          when length > 0x10
            outbuffer[bufferlength] = 0x00
            outbuffer[bufferlength] |= ((length - 0x111) >> 4) & 0x0F
            bufferlength += 1
            outbuffer[bufferlength] = ((length - 0x111) << 4) & 0xF0
          else
            outbuffer[bufferlength] = ((length - 1) << 4) & 0xF0
          end
          outbuffer[bufferlength] |= ((disp - 1) >> 8) & 0x0F
          bufferlength += 1
          outbuffer[bufferlength] = (disp - 1) & 0xFF
          bufferlength += 1
        end

        bufferedBlocks += 1
      end

      if bufferedBlocks > 0
        outstream.write(outbuffer[0, bufferlength])
      end

      outstream.buf
    end

  private
    def occurrence_length(newPtr, newLength, oldPtr, oldLength, minDisp = 1)
      disp = 0
      return [disp, 0] if newLength == 0
      oldRange = buf[oldPtr, newLength + oldLength - minDisp - 1]
      newArray = buf[newPtr, newLength]

      j = 0
      k = 0
      t = [-1]
      pos = 1
      cnd = 0
      while pos < newArray.size
        if newArray[pos] == newArray[cnd]
          t[pos] = t[cnd]
          pos += 1
          cnd += 1
        else
          t[pos] = cnd
          cnd = t[cnd]
          while cnd >= 0 && newArray[pos] != newArray[cnd]
            cnd = t[cnd]
          end
          pos += 1
          cnd += 1
        end
      end
      t[pos] = cnd

      maxLength = 0
      while j < oldRange.size && j - k < oldLength - minDisp
        if newArray[k] == oldRange[j]
          j += 1
          k += 1
          if k > maxLength
            maxLength = k
            disp = oldLength - (j - k)
            break if maxLength == newLength
          end
        else
          k = t[k]
          if k < 0
            j += 1
            k += 1
          end
        end
      end

#      currentLengths = Array.new(oldLength - minDisp) do |i|
#        oldArray = oldRange[i, newLength]
#        p [oldArray, newArray]
#        oldArray.zip(newArray).take_while {|x, y| x == y}.size
#      end
#      maxLength = 0
#      currentLengths.each_with_index do |currentLength, i|
#        if currentLength > maxLength
#          maxLength = currentLength
#          disp = oldLength - i
#          break if maxLength == newLength
#        end
#      end

      [disp, maxLength]
    end
  end
end end
