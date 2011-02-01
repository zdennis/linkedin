module LinkedIn
  module UriHelpers
    def to_uri(path, options)
      uri = URI.parse(path)
      if options && options != {}
        uri.query = to_query(options)
      end
      uri.to_s
    end

    def to_query(options)
      options.inject([]) do |collection, opt|
        collection << "#{opt[0]}=#{opt[1]}"
        collection
      end * '&'
    end

  end
end