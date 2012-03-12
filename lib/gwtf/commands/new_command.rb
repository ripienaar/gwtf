desc 'Create an item'
arg_name 'Short item description'
command [:new, :add, :n, :a, :c] do |c|
  c.desc 'Invoke EDITOR to provide a long form description'
  c.default_value false
  c.switch [:edit, :e]

  c.action do |global_options,options,args|
    subject = args.join(" ")
    raise "Please supply a short desciption for the item on the command line" if subject == ""

    if options[:edit]
      raise "EDITOR is not set" unless ENV.include?("EDITOR")

      begin
        tmp = Tempfile.new("gwtf")
        system("%s %s" % [ENV["EDITOR"], tmp.path])
        description = tmp.read.chomp
      ensure
        tmp.close
        tmp.unlink
      end
    else
      description = nil
    end

    item = @items.new_item
    item.subject = subject
    item.description = description if description
    item.save

    puts item
  end
end
