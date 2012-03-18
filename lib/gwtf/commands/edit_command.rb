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
        tmp.puts "Description:"
        tmp.puts item.description if item.description
        tmp.rewind
        system("%s %s" % [ENV["EDITOR"], tmp.path])
        edited_item = File.read(tmp.path)
      ensure
        tmp.close
        tmp.unlink
      end

      if edited_item.split("\n").first =~ /^Subject:\s*(.+)/
        item.subject = $1
      else
        raise "Subject is required"
      end

      description = edited_item.split("\n")[2..-1]

      unless [description].flatten.compact.empty?
        item.description = description.join("\n")
      else
        item.description = nil
      end

      item.save

      puts item
    else
      editor = args[1..-1].join(" ")
      delim = editor[0,1]
      splits = editor.split(delim)

      raise "Attempting to do a subject edit with #{editor} based on delimiter #{delim} failed" unless splits.size == 3

      item.subject = item.subject.gsub(splits[1], splits[2])
      item.save
      puts item
    end
  end
end
