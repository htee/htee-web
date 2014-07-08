ENV.each do |var, value|
  if var == 'HTEE_CONFIG'
    TOML.load_file(value)['web'].each do |key, value|
      Htee.config.send("#{key.downcase.gsub('-', '_')}=", value)
    end
  elsif var =~ /^HTEE_/
    key = var[/^HTEE_(.*)$/ ,1].downcase.gsub('-', '_')
    Htee.config.send("#{key}=", value)
  end
end
