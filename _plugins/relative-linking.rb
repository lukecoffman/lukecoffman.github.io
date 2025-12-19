# _plugins/relative-linking.rb
# Minimal Obsidian-style [[Wiki Links]] support for Jekyll
# Adapated from https://github.com/maximevaillancourt/digital-garden-jekyll-template/blob/main/_plugins/bidirectional_links_generator.rb

module Jekyll
  class RelativeLinking < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      # Collect all documents we want to support linking *to*
      docs = []

      # If your site uses a `notes` collection
      if site.collections.key?("notes")
        docs.concat(site.collections["notes"].docs)
      end

      # Normal pages
      docs.concat(site.pages)

      # Uncomment if you want blog posts to be linkable:
      if site.respond_to?(:posts) && site.posts.respond_to?(:docs)
        docs.concat(site.posts.docs)
      end

      link_extension = site.config["use_html_extension"] ? ".html" : ""

      # Rewrite wiki links inside every document
      docs.each do |current|
        content = current.content.dup

        docs.each do |target|
          next if target == current

          # Slug (filename without extension)
          slug = File.basename(target.basename, File.extname(target.basename))
          slug_pattern = Regexp.escape(slug)

          # Optional: match by front-matter title
          title = target.data["title"]
          title_pattern = Regexp.escape(title) if title

          href = "#{site.baseurl}#{target.url}#{link_extension}"

          # [[slug|Label]]
          content.gsub!(/\[\[(#{slug_pattern})\|([^\]]+)\]\]/i) do
            label = Regexp.last_match(2)
            %(<a class="internal-link" href="#{href}">#{label}</a>)
          end

          # [[title|Label]]
          if title_pattern
            content.gsub!(/\[\[(#{title_pattern})\|([^\]]+)\]\]/i) do
              label = Regexp.last_match(2)
              %(<a class="internal-link" href="#{href}">#{label}</a>)
            end
          end

          # [[slug]]
          content.gsub!(/\[\[(#{slug_pattern})\]\]/i) do
            label = Regexp.last_match(1)
            %(<a class="internal-link" href="#{href}">#{label}</a>)
          end

          # [[title]]
          if title_pattern
            content.gsub!(/\[\[(#{title_pattern})\]\]/i) do
              label = Regexp.last_match(1)
              %(<a class="internal-link" href="#{href}">#{label}</a>)
            end
          end
        end

        current.content = content
      end
    end
  end
end

