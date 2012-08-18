#
# Adds an additional "sorted_categories" entry to the "site" variable, which contains
# all the categories sorted by the number of posts.
#
# References:
#
# https://github.com/mojombo/jekyll/wiki/Plugins
# http://www.somic.org/2011/03/04/how-i-organize-posts-in-jekyll/
#
#
module Jekyll

  class CategoryGenerator < Generator
    safe true

    def generate(site)
      site.config['sorted_categories'] = site.categories.map { |cat, posts|
        [ cat, posts.size, posts ] }.sort { |a,b| b[1] <=> a[1] }
      site.config['sorted_categories'].shift
    end
  end

end