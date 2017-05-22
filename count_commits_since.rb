require 'Octokit'
require 'Slop'

opts = Slop.parse do |o|
  o.string '-o', '--organization', 'a github organization'
  o.string '-r', '--repository', 'a github repository'
  o.string '-u', '--username', 'username'
  o.string '-p', '--password', 'password'
  o.string '-d', '--date', 'date since'
  o.on '--help' do
    puts o
    exit
  end
end

def count_for_repo(client, repo, date, counts, names)
  commits = client.commits_since(repo, date)

  commits.each do |commit|
    author = commit[:commit][:author][:email]
    counts[author] = counts[author] ? counts[author] + 1 : 1
    names[author] = commit[:commit][:author][:name]
  end
rescue
  puts "error with repo #{repo}"
end

Octokit.auto_paginate = true

if opts[:username] && opts[:password]
  client = Octokit::Client.new(
    :login    => opts[:username],
    :password => opts[:password]
    )
    user = client.user
    user.login
else
  client = Octokit::Client.new
end

counts = Hash.new
names = Hash.new

if opts[:organization]
  repos = Octokit.organization_repositories(opts[:organization])
  repos.each do |r|
    count_for_repo(client, r[:full_name], opts[:date], counts, names)
  end
elsif opts[:repository]
  count_for_repo(client, opts[:repository], opts[:date], counts, names)
else
  exit
end

counts = counts.sort_by{|k,v| v}.reverse.to_h

counts.each do |key, value|
  puts "#{names[key]},#{key},#{value}"
end
