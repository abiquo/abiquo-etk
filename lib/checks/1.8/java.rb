if abiquo_installed?

def java_ok?
  log = AETK::Log.instance
  if not File.exist? JAVA_BIN
    log.error "Java binary not found in #{JAVA_BIN}"
    return false
  end

  if `java -version 2>&1 | grep '64-Bit Server'`.empty?
    log.error "Java 64-Bit runtime not found"
    return false
  end

  return true
end

puts "Java:".bold.ljust(40) + (java_ok? ? "64 Bit Runtime".green.bold : "Not Found".red.bold)

end
