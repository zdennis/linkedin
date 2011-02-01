require 'pathname'

require 'bundler'
Bundler.setup

require 'rspec'
require 'fakeweb'

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
  FakeWeb.register_uri(:get, linkedin_url(url), options)
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

