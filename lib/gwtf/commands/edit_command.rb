desc 'Edit an item subject using pattern replacement of using EDITOR'
arg_name 'item'
arg_name 'item [/foo/bar]'
command [:edit, :vi, :e] do |c|
  c.action do |global_options,options,args|
    raise "Please specify an item ID to edit" if args.empty?

    item = @items.load_item(args.first)

    if args.size == 1
      raise "EDITOR environment variable should be set" unless ENV.include?("EDITOR")

      begin
        tmp = Tempfile.new("gwtf")
        tmp.puts "Subject: %s" % [ item.subject ]
        tmp.puts "Due Date: %s" % [ item.due_date ]
        tmp.puts "Description:"
        tmp.puts item.description if item.description
        tmp.rewind
        system("%s %s" % [ENV["EDITOR"], tmp.path])
        edited_item = File.read(tmp.path)
      ensure
        tmp.close
        tmp.unlink
      end

      edited_item = edited_item.split("\n")

      if edited_item.first =~ /^Subject:\s*(.+)/
        item.subject = $1
      else
        raise "Subject is required"
      end

      if edited_item[1] =~ /^Due Date:\s*(.+)/
        if ["", " "].include?($1)
          item.due_date = nil
        else
          item.due_date = item.date_to_due_date($1)
        end
      else
        item.due_date = nil       # if the user just delete the line from the
        edited_item.insert(1, "") # treat it as removing the due date but insert
                                  # some blank data in the array to not break the
                                  # description finding logic
      end

      description = edited_item[4..-1]

      unless [description].flatten.compact.empty?
        item.description = description.join("\n")
      else
        item.description = nil
      end

      item.save

      puts item.to_s
    else
      editor = args[1..-1].join(" ")
      delim = editor[0,1]
      splits = editor.split(delim)

      raise "Attempting to do a subject edit with #{editor} based on delimiter #{delim} failed" unless splits.size == 3

      item.subject = item.subject.gsub(splits[1], splits[2])
      item.save
      puts item.to_s
    end
  end
end
