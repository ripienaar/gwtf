desc 'Edit an item subject using pattern replacement of using EDITOR'
arg_name 'item'
arg_name 'item [/foo/bar]'
command [:edit, :vi, :e] do |c|
  c.action do |global_options,options,args|
    raise "Please specify an item ID to edit" if args.empty?

    item = @items.load_item(args.first)

    if args.size == 1
      raise "EDITOR environment variable should be set" unless ENV.include?("EDITOR")

      descr_sep = "== EDIT BETWEEN THESE LINES =="

      temp_item = {"description" => "#{descr_sep}\n#{item.description}\n#{descr_sep}", "subject" => item.subject}

      begin
        tmp = Tempfile.new("gwtf")
        tmp.write(temp_item.to_yaml)
        tmp.rewind
        system("%s %s" % [ENV["EDITOR"], tmp.path])
        edited_item = YAML.load_file(tmp.path)
      ensure
        tmp.close
        tmp.unlink
      end

      item.subject = edited_item["subject"] if edited_item["subject"]

      if edited_item["description"] =~ /#{descr_sep}\n(.+)\n#{descr_sep}/m
        item.description = $1
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
