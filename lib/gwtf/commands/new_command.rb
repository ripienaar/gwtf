desc 'Create an item'
arg_name 'Short item description'
command [:new, :n] do |c|
  c.desc 'Invoke EDITOR to provide a long form description'
  c.default_value false
  c.switch [:edit, :e]

  c.action do |global_options,options,args|
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
    item.subject = args.join(" ")
    item.description = description if description
    item.save

    puts "Item #{item.item_id} saved"
  end
end
