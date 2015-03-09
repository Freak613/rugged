# coding: utf-8
require 'rugged'

data = [
  { filename: 'eng.txt', content: 'english' },
  { filename: 'rus.txt', content: 'русский' }
]

def commit(repo, index, message)
  options = {}
  options[:tree] = index.write_tree(repo)

  options[:author] = {
    email: 'testuser@github.com',
    name: 'Test Author',
    time: Time.now
  }
  options[:committer] = {
    email: 'testuser@github.com',
    name: 'Test Author',
    time: Time.now
  }
  options[:message] ||= message
  options[:parents] = repo.empty? ? [] : [repo.head.target].compact
  options[:update_ref] = 'HEAD'

  Rugged::Commit.create(repo, options)
end

# Init repo
Rugged::Repository.init_at('.')
repo = Rugged::Repository.new('.')
index = repo.index
commit(repo, index, 'Initial commit')

# Add two files
data.each do |file|
  filename = file[:filename]
  content = file[:content]

  File.write filename, content

  oid = repo.write(content, :blob)
  index = repo.index
  index.read_tree(repo.head.target.tree)
  index.add(path: filename, oid: oid, mode: 0100644)

  commit(repo, index, "Added #{filename}")
end

# Check if files are binary
tree = repo.last_commit.tree
tree.each do |e|
  filename = data.find { |d| d[:filename] == e[:name] }[:filename]
  blob = repo.lookup(e[:oid])
  puts "#{filename} binary?=#{blob.binary?}"
end
