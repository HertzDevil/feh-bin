
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "feh/bin/version"

Gem::Specification.new do |spec|
  spec.name          = "feh-bin"
  spec.version       = Feh::Bin::VERSION
  spec.authors       = ["Quinton Miller"]
  spec.email         = ["nicetas.c@gmail.com"]

  spec.summary       = "Conversion routines for Fire Emblem Heroes asset files"
  spec.description   = "Functions to compress and decompress binary asset files from Fire Emblem Heroes"
  spec.homepage      = "https://github.com/HertzDevil/feh-bin"
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extra_rdoc_files = ['README.md']

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
