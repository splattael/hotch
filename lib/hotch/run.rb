require 'hotch'
require 'tmpdir'

HOTCH_VIEWER = ENV['HOTCH_VIEWER']

NAME = $0.gsub(/\W/, '_')

hotch = Hotch.new
hotch.start

def system!(*args)
  system(*args) or raise "system call failed: #{args.join(' ')}"
end

at_exit do
  hotch.stop

  dir = Dir.mktmpdir("hotch.#{NAME}")
  dump = File.open(File.join(dir, "profile.dump"), "wb")
  svg = File.join(File.join(dir, "profile.svg"))

  StackProf::Report.new(hotch.results).print_graphviz(nil, dump)

  dump.close

  system! "dot", "-Tsvg", "-o", svg, dump.path

  puts "Profile SVG: #{svg}"

  if viewer = HOTCH_VIEWER
    system! viewer, svg
  end
end
