module LinkedIn
  class Paginator
    include ::Enumerable
    include ::LinkedIn::UriHelpers
    
    def initialize(client, path, options={}, &block)
      @client, @path, @options = client, path, options
      @block = block
    end

    def each(&block)
      start, total, count = 0, 0, 25
      loop do
        response_body = @client.get to_uri(@path, @options.merge(:start => start, :count => count))
        doc = Nokogiri::XML(response_body)
        total = doc.search('people[total]').attr('total').value.to_i
        yield response_body
        if start + doc.search('people person').count >= total
          # we're on the last page
          break
        else
          start += count
        end
      end
      self
    end
  end
end