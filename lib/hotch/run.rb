require 'hotch'

viewer = ENV['HOTCH_VIEWER']

hotch = Hotch.new($0)
hotch.start

hotch.report_at_exit(viewer)
