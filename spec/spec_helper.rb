require 'pathname'

require 'bundler'
Bundler.setup

require 'rspec'
require 'fakeweb'
require 'ruby-debug'

FakeWeb.allow_net_connect = false

dir = (Pathname(__FILE__).dirname + '../lib').expand_path
require dir + 'linkedin'

def fixture_file(filename)
  return '' if filename == ''
  file_path = File.expand_path(File.dirname(__FILE__) + '/fixtures/' + filename)
  File.read(file_path)
end

def linkedin_url(url)
  url =~ /^http/ ? url : "https://api.linkedin.com#{url}"
end


def stub_get(url, filename, status=nil)
  options = {:body => fixture_file(filename)}
  options.merge!({:status => status}) unless status.nil?
  original_uri = URI.parse(url)
  
  # Register each permutation of the URL given its query parameters could
  # change based on how ruby does lookup
  if original_uri.query
    params = original_uri.query.split("&")
    params.each_permutation do |query_params|
      uri = URI.parse original_uri.path + "?" + query_params.join("&")
      FakeWeb.register_uri(:get, linkedin_url(uri.to_s), options)
    end
  else
     FakeWeb.register_uri(:get, linkedin_url(original_uri.to_s), options)
  end
end

def stub_post(url, filename)
  FakeWeb.register_uri(:post, linkedin_url(url), :body => fixture_file(filename))
end

def stub_put(url, filename)
  FakeWeb.register_uri(:put, linkedin_url(url), :body => fixture_file(filename))
end

def stub_delete(url, filename)
  FakeWeb.register_uri(:delete, linkedin_url(url), :body => fixture_file(filename))

end

class Array
  def each_permutation
    if self.size == 1
      yield self
    else
      self.each_index do |i|
        tmp, e = self.dup, self[i]
        tmp.delete_at(i)
        tmp.each_permutation do |x|
          yield e.to_a + x
        end
      end
    end
  end
end