require 'stackprof'
require 'tmpdir'

HOTCH_REPORTER = ENV.fetch('HOTCH_REPORTER', 'print_graphviz')
HOTCH_VIEWER = ENV['HOTCH_VIEWER']

NAME = $0.gsub(/\W/, '_')

StackProf.start

def system!(*args)
  system(*args) or raise "system call failed: #{args.join(' ')}"
end

at_exit do
  StackProf.stop

  begin
    dir = Dir.mktmpdir("hotch.#{NAME}")
    dump = File.open(File.join(dir, "profile.dump"), "wb")
    svg = File.join(File.join(dir, "profile.svg"))

    old_verbose, $VERBOSE = $VERBOSE, nil
    old_stdout, STDOUT = STDOUT, dump

    StackProf::Report.new(StackProf.results).public_send(HOTCH_REPORTER)

    dump.close

    system! "dot", "-Tsvg", "-o", svg, dump.path

    puts "Profile SVG: #{svg}"

    if viewer = HOTCH_VIEWER
      system! viewer, svg
    end
  ensure
    STDOUT = old_stdout
    $VERBOSE = old_verbose
  end

end
