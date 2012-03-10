module Gwtf
  require 'gwtf/items'
  require 'gwtf/item'
  require 'gwtf/version'
  require 'json'
  require 'yaml'
  require 'fileutils'
  require 'tempfile'

  def self.each_command
    commands_dir = File.join(File.dirname(__FILE__), "gwtf", "commands")
    Dir.entries(commands_dir).grep(/_command.rb$/).sort.each do |command|
      yield File.join(commands_dir, command)
    end
  end

  # borrowed from ohai, thanks Adam.
  def self.seconds_to_human(seconds)
    days = seconds.to_i / 86400
    seconds -= 86400 * days

    hours = seconds.to_i / 3600
    seconds -= 3600 * hours

    minutes = seconds.to_i / 60
    seconds -= 60 * minutes

    if days > 1
      return sprintf("%d days %d hours %d minutes %d seconds", days, hours, minutes, seconds)
    elsif days == 1
      return sprintf("%d day %d hours %d minutes %d seconds", days, hours, minutes, seconds)
    elsif hours > 0
      return sprintf("%d hours %d minutes %d seconds", hours, minutes, seconds)
    elsif minutes > 0
      return sprintf("%d minutes %d seconds", minutes, seconds)
    else
      return sprintf("%d seconds", seconds)
    end
  end
end
