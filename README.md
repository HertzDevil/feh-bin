# feh-bin

Conversion routines for Fire Emblem Heroes asset files.

## Installation

```
$ gem install feh-bin
```

## Command line usage

To convert `a.bin` to `a.bin.lz`, and `b.bin.lz` to `b.bin`:

```
$ feh_bin_lz a.bin b.bin.lz
```

## Library example

```ruby
require 'feh/bin'

Dir.glob('assets/Common/SRPGMap/*.bin.lz').each do |fname|
  IO.binwrite(fname.sub(/.lz$/, ''), Feh::Bin.decompress(IO.binread(fname)).pack('c*'))
end
```

## Changelog

### V0.1.3

- Added read support for non-LZ11-compressed .bin.lz files

### V0.1.2

- Fixed double encryption issue in `Feh::Bin.compress`

### V0.1.0

- Initial release

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
