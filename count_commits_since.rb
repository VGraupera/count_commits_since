require 'Octokit'

if ARGV.length < 4
  puts "Too few arguments"
  exit
end

login, password, repo, date = ARGV

Octokit.auto_paginate = true

client = Octokit::Client.new \
  :login    => login,
  :password => password

user = client.user
user.login

commits = client.commits_since(repo, date)

counts = Hash.new
names = Hash.new

commits.each do |commit|
  author = commit[:commit][:author][:email]
  counts[author] = counts[author] ? counts[author] + 1 : 1
  names[author] = commit[:commit][:author][:name]
end

counts = counts.sort_by{|k,v| v}.reverse.to_h

counts.each do |key, value|
  puts "#{names[key]},#{key},#{value}"
end
