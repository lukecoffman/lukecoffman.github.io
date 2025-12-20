# frozen_string_literal: true

# _plugins/relative-linking.rb
# Minimal Obsidian-style [[Wiki Links]] support for Jekyll
# - Supports [[Note]], [[Note|Label]]
# - Supports [[Note#fragment]], [[Note#fragment|Label]]
# - Supports Obsidian block ids: [[Note#^block-id]] -> ...#block-id
# - Supports heading fragments by mapping to kramdown's generated heading IDs (including de-dupe -1/-2)
# Adapated from https://github.com/maximevaillancourt/digital-garden-jekyll-template/blob/main/_plugins/bidirectional_links_generator.rb

module Jekyll
  class RelativeLinking < Jekyll::Generator
    safe true
    priority :low

    HEADING_RE = /^(#{'#' * 1,6})\s+(.+?)\s*$/.freeze
    EXPLICIT_ID_RE = /\s*\{#([A-Za-z0-9\-_]+)\}\s*$/.freeze

    def generate(site)
      docs = []
      docs.concat(site.collections["notes"].docs) if site.collections.key?("notes")
      docs.concat(site.pages)
      docs.concat(site.posts.docs) if site.respond_to?(:posts) && site.posts.respond_to?(:docs)

      link_extension = site.config["use_html_extension"] ? ".html" : ""

      # Precompute heading-id maps for every doc once:
      # { doc.object_id => { "Heading Text" => "heading-id", ... } }
      heading_maps = {}
      docs.each do |doc|
        next unless markdown_doc?(doc)
        heading_maps[doc.object_id] = build_heading_id_map(doc.content)
      end

      docs.each do |current|
        next unless markdown_doc?(current)
        content = current.content.dup

        docs.each do |target|
          next if target == current

          slug = File.basename(target.basename, File.extname(target.basename))
          slug_pattern = Regexp.escape(slug)

          title = target.data["title"]
          title_pattern = Regexp.escape(title) if title

          href_base = "#{site.baseurl}#{target.url}#{link_extension}"
          target_heading_map = heading_maps[target.object_id] || {}

          # Rewrite both slug and title variants
          content = rewrite_links(content, slug_pattern, href_base, target_heading_map)
          content = rewrite_links(content, title_pattern, href_base, target_heading_map) if title_pattern
        end

        current.content = content
      end
    end

    private

    def markdown_doc?(doc)
      return false unless doc.respond_to?(:content)
      ext = doc.respond_to?(:extname) ? doc.extname : File.extname(doc.path.to_s)
      ext.downcase == ".md"
    end

    # Build a map from heading display text to the final kramdown-style id.
    # Handles:
    # - explicit kramdown IDs like: "## Heading {#my-id}"
    # - duplicates: "## Heading" repeated -> "heading", "heading-1", "heading-2" ...
    def build_heading_id_map(markdown)
      map = {}
      used_ids = Hash.new(0)

      markdown.each_line do |line|
        m = line.match(HEADING_RE)
        next unless m

        raw = m[2]

        # Strip trailing explicit id if present
        explicit = raw.match(EXPLICIT_ID_RE)
        heading_text = raw.sub(EXPLICIT_ID_RE, "").strip

        base_id =
          if explicit
            explicit[1]
          else
            kramdown_like_id(heading_text)
          end

        # Deduplicate like kramdown typically does
        final_id = base_id
        if used_ids[base_id] > 0
          final_id = "#{base_id}-#{used_ids[base_id]}"
        end
        used_ids[base_id] += 1

        # First occurrence wins for a given heading text, but if duplicates exist with same text,
        # you actually can't disambiguate without extra syntax in the link.
        # We'll store the first; users can switch to block ids for perfect disambiguation.
        map[heading_text] ||= final_id
      end

      map
    end

    # Approximation of kramdown auto-id generation:
    # - downcase
    # - remove most punctuation
    # - spaces -> hyphens
    # - collapse multiple hyphens
    # - trim hyphens
    #
    # This matches common kramdown behavior for typical headings.
    def kramdown_like_id(text)
      t = text.downcase
      # remove anything not letter/number/space/hyphen/underscore
      t = t.gsub(/[^a-z0-9\s\-_]/, "")
      t = t.strip
      t = t.gsub(/\s+/, "-")
      t = t.gsub(/-+/, "-")
      t = t.gsub(/\A-+|-+\z/, "")
      t
    end

    def normalize_fragment(fragment, heading_map)
      return "" if fragment.nil? || fragment.empty?

      frag = fragment.dup

      # fragment comes in WITHOUT leading '#'
      # Handle Obsidian block id: ^my-id
      if frag.start_with?("^")
        return "##{frag[1..]}"
      end

      # Try to resolve as a heading (exact match)
      # Obsidian heading links are typically literal heading text.
      if heading_map.key?(frag)
        return "##{heading_map[frag]}"
      end

      # If user already provided something slug-like, pass through
      "##{frag}"
    end

    def rewrite_links(content, name_pattern, href_base, heading_map)
      return content if name_pattern.nil?

      # Optional fragment: "#...." (captured without '#'), stopping at '|' or ']]'
      frag_part = /(?:#([^\]\|]+))?/
      label_part = /(?:\|([^\]]+))?/

      # [[Name#frag|Label]] or [[Name|Label]] or [[Name#frag]] or [[Name]]
      content.gsub(/\[\[(#{name_pattern})#{frag_part}#{label_part}\]\]/i) do
        _name = Regexp.last_match(1)
        frag = Regexp.last_match(2) # without '#'
        label = Regexp.last_match(3)

        href = href_base + normalize_fragment(frag, heading_map)
        link_text = label || _name

        %(<a class="internal-link" href="#{href}">#{link_text}</a>)
      end
    end
  end
end

