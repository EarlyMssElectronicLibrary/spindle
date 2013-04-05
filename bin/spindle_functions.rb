def print_message cmd, type, msg
  puts sprintf("%-23s  %-12s  %s", "[#{cmd}]", type, msg)
end # def print_message cmd, type, msg

def message cmd, msg
  print_message cmd, 'INFO', msg
end # def message cmd, 

def error cmd, msg
  print_message cmd, 'ERROR', msg
end # def message cmd, 

def report_count cmd, count, total, interval, file=nil
  width = total.to_s.size
  t = Time.now.strftime "%FT%T%z"
  msg = if file
          sprintf "%#{width}d/%d  %s  %-40s", count, total, t, file
        else
          sprintf "%#{width}d/%d  %s", count, total, t
        end
  if interval == 0 || count % interval == 0
    message cmd, msg
  end
end # def report_count count, total, interval, file=nil

def find_package_dir arg
  if arg 
    if Dir.exist? arg
      File.absolute_path arg
    else
      STDERR.puts "Error: PACKAGE_DIR not found: #{arg}"
    end
  else
    STDERR.puts "Error: no PACKAGE_DIR provided"
  end
end # def package_dir arg
