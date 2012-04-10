module Gwtf
  class Item
    include ObjHash

    attr_accessor :file
    attr_reader :project

    property :description, :default => nil, :validation => String
    property :subject, :default => nil, :validation => String
    property :status, :default => "open", :validation => ["open", "closed"]
    property :item_id, :default => nil, :validation => Integer
    property :work_log, :default => [], :validation => Array
    property :due_date, :default => nil, :validation => /^20\d\d[- \/.](0[1-9]|1[012])[- \/.](0[1-9]|[12][0-9]|3[01])$/
    property :closed_at, :default => nil

    def initialize(file=nil, project=nil)
      @file = file
      @project = project

      load_item if file
    end

    def open?
      status == "open"
    end

    def closed?
      !open?
    end

    def overdue?
      if has_due_date? && open?
        return !!(days_till_due < 0)
      else
        return false
      end
    end

    def due?
      if has_due_date? && open?
        return !!(days_till_due <= 1)
      else
        return false
      end
    end

    def days_till_due
      return 1000 unless has_due_date?

      return (Date.parse(due_date) - Date.today).to_i
    end

    def load_item
      raise "A file to read from has not been specified" unless @file

      read_item = JSON.parse(File.read(@file))

      merge!(read_item)
    end

    def backup_dir
      File.join(File.dirname(file), "backups")
    end

    def save(backup=true)
      raise "No item_id set, cannot save item" unless item_id

      if backup && File.exist?(@file)
        backup_name = File.basename(@file) + "-" + Time.now.to_f.to_s

        FileUtils.mv(@file, File.join(backup_dir, backup_name))
      end

      File.open(@file, "w") do |f|
        f.print to_json
      end

      @file
    end

    def time_worked
      work_log.inject(0) do |result, log|
        begin
          result + log["elapsed"]
        rescue
          result
        end
      end
    end

    def flags
      flag = []

      flag << "closed" if closed?
      flag << "open" if open?
      flag << "descr" if description?
      flag << "overdue" if overdue?
      flag << work_log.size.to_s unless work_log.empty?
      flag
    end

    def compact_flags
      flags = []
      flags << "O" if overdue?
      flags << "D" if has_description?
      flags << "C" if closed?
      flags << "L" unless work_log.empty?

      flags
    end

    def colorize_by_due_date(string)
      if overdue?
        return Gwtf.red(string)
      elsif days_till_due <= 1 && open?
        return Gwtf.yellow(string)
      else
        return string
      end
    end

    def summary
      summary = StringIO.new

      summary.puts "    Subject: %s" % [ subject ]
      summary.puts "     Status: %s" % [ status ]

      if has_due_date? && open?
        due = "%s (%d days)" % [ due_date, days_till_due ]
        summary.puts "   Due Date: %s" % [ colorize_by_due_date(due) ]
      end

      summary.puts "Time Worked: %s" % [ Gwtf.seconds_to_human(time_worked) ] if time_worked > 0
      summary.puts "    Created: %s" % [ Time.parse(created_at.to_s).strftime("%F %R") ]
      summary.puts "     Closed: %s" % [ Time.parse(closed_at.to_s).strftime("%F %R") ] if closed?
      summary.puts "         ID: %s" % [ item_id ]

      if has_description?
        summary.puts
        summary.puts "Description:"

        description.split("\n").each do |line|
          summary.puts "%13s%s" % [ "", line]
        end

        summary.puts
      end

      time_spent = 0

      work_log.reverse.each_with_index do |log, idx|
        summary.puts if idx == 0
        summary.puts "Work Log: " if idx == 0

        # we used to automatically embed this into the description which was dumb
        if log["elapsed"] > 0
          elapsed = "(%s)" % [Gwtf.seconds_to_human(log["elapsed"])] unless log["text"] =~ /\(.+?\)$/
        else
          elapsed = ""
        end

        summary.puts "%27s %s %s" % [Time.parse(log["time"]).strftime("%F %R"), log["text"], elapsed]
      end

      summary.string
    end

    def to_s
      colorize_by_due_date("%5s %-4s%-10s %s" % [ item_id, compact_flags.join, has_due_date? ? due_date : "", subject ])
    end

    def record_work(text, elapsed=0)
      update_property(:edited_at, Time.now)

      work_log << {"text" => text, "time" => Time.now, "elapsed" => elapsed}
    end

    def open
      update_property(:closed_at, nil)
      update_property(:status, "open")
    end

    def close
      update_property(:closed_at, Time.now)
      update_property(:status, "closed")
    end

    def schedule_reminer(timespec, recipient, done=false, ifopen=false)
      command_args = ["--send"]
      command_args << "--recipient=%s" % [ recipient ]
      command_args << "--done" if done
      command_args << "--ifopen" if ifopen

      command = "echo gwtf --project='%s' remind %s %s | at %s 2>&1" % [ @project, command_args.join(" "), item_id, timespec]
      out = %x[#{command}]

      raise "Failed to add at(1) job: %s" % [ out ] unless $? == 0

      puts out
      out
    end

    def send_reminder(recipient, mark_as_done, klass)
      klass.new(self, recipient).notify

      if mark_as_done
        record_work("Closing item as part of scheduled reminder")
        close
        save
      end
    end
  end
end
