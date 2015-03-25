require 'hotch'

hotch = Hotch.new($0, viewer: ENV['HOTCH_VIEWER'])
hotch.start

hotch.report_at_exit
