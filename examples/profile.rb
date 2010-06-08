# AUTHENTICATE FIRST found in examples/authenticate.rb

# client is a LinkedIn::Client

# get the profile for the authenticated user
client.profile

# get the public profile url for the authenticated user
client.profile(:fields => 'public-profile-url').
  relation_to_viewer['public-profile-url']

# get a profile for someone found in network via ID
client.profile(:id => 'gNma67_AdI')

# get a profile for someone via their public profile url
client.profile(:url => 'http://www.linkedin.com/in/netherland')


