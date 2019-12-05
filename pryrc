# frozen_string_literal: true

[
  'irb/ext/save-history',
  'awesome_print',
].each do |gem|

  begin
    require gem
  rescue LoadError
    puts "Could not load #{gem}"
  end
end

AwesomePrint.pry! if defined? AwesomePrint
