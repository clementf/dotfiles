begin
  require 'irb/ext/save-history'
  require 'irb/completion'
  require 'irbtools'
rescue LoadError
  puts "Could not load all specified module(s)"
end


IRB.conf[:SAVE_HISTORY] = 2000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-history"

class Object
  def me
    User.find 4222
  end

  def skip_setup
    User.last.update(account_has_been_setup: true)
  end

end
