require 'hotch'

hotch = Hotch.new($0, viewer: ENV['HOTCH_VIEWER'], filter: ENV['HOTCH_FILTER'])
hotch.start

hotch.report_at_exit
