module Gwtf
  require 'objhash'
  require 'gwtf/items'
  require 'gwtf/item'
  require 'gwtf/version'
  require 'gwtf/notifier/base'
  require 'json'
  require 'yaml'
  require 'fileutils'
  require 'tempfile'
  require 'uri'
  require 'time'
  require 'readline'

  def self.each_command
    commands_dir = File.join(File.dirname(__FILE__), "gwtf", "commands")
    Dir.entries(commands_dir).grep(/_command.rb$/).sort.each do |command|
      yield File.join(commands_dir, command)
    end
  end

  def self.projects(root_dir)
    Dir.entries(root_dir).map do |entry|
      next if entry =~ /^\./
        next unless File.directory?(File.join(root_dir, entry))

      entry
    end.compact.sort
  end

  def self.notifier_for_address(address)
    uri = URI.parse(address)

    case uri.scheme
      when nil, "email"
        require 'gwtf/notifier/email'
        return Notifier::Email
      when "boxcar"
        gem 'boxcar_api', '>= 1.2.0'
        require 'boxcar_api'
        require 'gwtf/notifier/boxcar'

        return Notifier::Boxcar
      else
        raise "Do not know how to handle addresses of type #{uri.scheme} for #{address}"
    end
  end

  def self.ask(prompt="")
    stty_save = `stty -g`.chomp

    begin
      return Readline.readline("#{prompt} ", true)
    rescue Interrupt => e
      system('stty', stty_save)
      raise
    end
  end

  def self.green(msg)
    if STDOUT.tty?
      "[1m[32m%s[0m" % [ msg ]
    else
      msg
    end
  end

  def self.yellow(msg)
    if STDOUT.tty?
      "[1m[33m%s[0m" % [ msg ]
    else
      msg
    end
  end

  def self.red(msg)
    if STDOUT.tty?
      "[1m[31m%s[0m" % [ msg ]
    else
      msg
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
