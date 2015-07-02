class Article < ActiveRecord::Base
  before_create :add_url_slug
end

def add_url_slug
  new_slug = self.title.squish.downcase.tr(" ","-")
  encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => '',        # Use a blank for those replacements
    :universal_newline => true       # Always break lines with \n
  }
  new_slug = new_slug.encode(Encoding.find('ASCII'), encoding_options)
  new_slug = make_slug_unique(new_slug)
  self.slug = new_slug
end

def make_slug_unique (slug, itterator = 0)

  def add_itterator_to_slug(slug, itterator)
    slug + "-#{itterator}"
  end

  if itterator == 0
    articles_with_this_slug = Article.where(["slug = :slug", { slug: slug  }])
  else
    articles_with_this_slug = Article.where(["slug = :slug", { slug: add_itterator_to_slug(slug, itterator) }])
  end
  if articles_with_this_slug.length > 0
    itterator = itterator + 1
    make_slug_unique(slug, itterator)
  else
    itterator == 0 ? slug : add_itterator_to_slug(slug, itterator)
  end
end