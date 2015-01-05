require 'hotch'
require 'tmpdir'

HOTCH_VIEWER = ENV['HOTCH_VIEWER']

program = $0.gsub(/\W/, '_')

hotch = Hotch.new(program)
hotch.start

at_exit do
  hotch.stop

  hotch.report do |svg|
    puts "Profile SVG: #{svg}"

    if viewer = HOTCH_VIEWER
      system viewer, svg
    end
  end
end
