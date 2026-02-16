blogs = [
  {
    name: "Nate Berkopec",
    url: "https://www.speedshop.co",
    rss_url: "https://www.speedshop.co/feed.xml",
    description: "Ruby and Rails performance optimization",
    tags: ["performance", "rails"],
    twitter: "nateberkopec"
  },
  {
    name: "Evil Martians",
    url: "https://evilmartians.com/chronicles",
    rss_url: "https://evilmartians.com/chronicles.atom",
    description: "Product development consultancy sharing Ruby, Rails, and frontend insights",
    tags: ["rails", "ruby", "frontend"],
    twitter: "eaborai"
  },
  {
    name: "Thoughtbot",
    url: "https://thoughtbot.com/blog",
    rss_url: "https://thoughtbot.com/blog/summaries.xml",
    description: "Design and development consultancy blog",
    tags: ["rails", "ruby", "design"],
    twitter: "thoughtbot"
  },
  {
    name: "Riding Rails",
    url: "https://rubyonrails.org/blog",
    rss_url: "https://rubyonrails.org/blog.xml",
    description: "Official Ruby on Rails blog",
    tags: ["rails", "releases"],
  }
]

blogs.each do |attrs|
  Blog.find_or_create_by!(url: attrs[:url]) do |blog|
    blog.assign_attributes(attrs)
  end
rescue ActiveRecord::RecordInvalid => e
  puts "Skipped #{attrs[:name]}: #{e.message}"
end

puts "Seeded #{Blog.count} blogs"
