# feh-bin

Conversion routines for Fire Emblem Heroes asset files.

## Example

```ruby
require 'feh-bin'

Dir.glob('assets/Common/SRPGMap/*.bin.lz').each do |fname|
  IO.binwrite(fname.sub(/.lz$/, ''), Feh::Bin.decompress(IO.binread(fname)).pack('c*'))
end
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
