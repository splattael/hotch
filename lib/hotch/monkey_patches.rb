# Monkey patches

StackProf::Report.class_eval do
  def print_dump(f = STDOUT)
    f.puts Marshal.dump(@data.reject{|k,v| k == :files })
  end
end
