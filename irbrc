# frozen_string_literal: true

[
  'irb/ext/save-history',
  'awesome_print',
  'irb/completion',
  'irbtools'
].each do |gem|

  begin
    require gem
  rescue LoadError
    puts "Could not load #{gem}"
  end
end

AwesomePrint.irb! if defined? AwesomePrint

IRB.conf[:SAVE_HISTORY] = 2000
IRB.conf[:HISTORY_FILE] = '~/.irb-history'
IRB.conf[:USE_AUTOCOMPLETE] = false

class Object
end
