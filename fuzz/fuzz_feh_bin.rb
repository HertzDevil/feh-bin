#1/usr/bin/env ruby

require 'feh/bin'
require 'fuzzbert'

fuzz 'Feh::Bin' do
  deploy do |data|
    data2 = Feh::Bin.compress(data)
    data3 = Feh::Bin.decompress(data)
    raise StandardError unless data3 == data
  end

  data 'random' do
    r = FuzzBert::Generators.random(16384)
    ->() do
      a = r.().unpack('C*')
#      a += [0] * ((-a.size) % 4)
    end
  end
end
