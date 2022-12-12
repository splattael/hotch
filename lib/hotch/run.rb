# frozen_string_literal: true

require "hotch"

hotch = Hotch.new($PROGRAM_NAME, viewer: ENV.fetch("HOTCH_VIEWER", nil), filter: ENV.fetch("HOTCH_FILTER", nil))
hotch.start

hotch.report_at_exit
