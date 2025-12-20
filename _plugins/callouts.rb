# frozen_string_literal: true

module ObsidianCallouts
  # Matches: > [!def] Title ^optional-id
  CALLOUT_START_RE = /^\s*>\s*\[!([A-Za-z]+)\]\s*(.*?)\s*(\^[A-Za-z0-9\-_]+)?\s*$/.freeze
  ANY_BQ_RE        = /^\s*>/.freeze
  BQ_LINE_RE       = /^\s*>\s?(.*)$/.freeze

  # Matches stripped block-id lines inside the callout body: "^def-surprisal"
  BLOCK_ID_RE      = /^\s*(\^[A-Za-z0-9\-_]+)\s*$/.freeze

  def self.transform(markdown)
    lines = markdown.split("\n", -1)
    out = []
    i = 0

    while i < lines.length
      line = lines[i]
      m = line.match(CALLOUT_START_RE)

      unless m
        out << line
        i += 1
        next
      end

      type = m[1].downcase
      raw_title = (m[2] || "").strip
      header_block_id = (m[3] || "").strip # includes leading ^
      title = raw_title.empty? ? type.capitalize : raw_title

      body_lines = []

      # First line: drop "[!type]" and any trailing "^id"
      #first_body = line
      #  .sub(/^\s*>\s*\[![A-Za-z]+\]\s*/, "")
      #  .sub(/\s*\^[A-Za-z0-9\-_]+\s*$/, "")
      #body_lines << first_body unless first_body.strip.empty?

      # Collect the rest of the contiguous blockquote
      i += 1
      while i < lines.length && lines[i].match?(ANY_BQ_RE)
        bm = lines[i].match(BQ_LINE_RE)
        body_lines << (bm ? bm[1] : "")
        i += 1
      end

      # Find a body block-id line like "^def-surprisal" (your file uses this)
      body_block_id = nil
      body_lines.each_with_index do |bl, idx|
        mm = bl.match(BLOCK_ID_RE)
        next unless mm
        body_block_id = mm[1]        # keep the last one if multiple appear
        body_lines[idx] = ""         # remove from rendered content
      end

      # Prefer header id if present; else use the one inside the body
      block_id = header_block_id.empty? ? body_block_id : header_block_id
      block_id = block_id&.sub(/^\^/, "") # strip leading ^ for HTML id

      # Tidy body leading blanks
      body_lines.shift while body_lines.first == ""

      id_attr = (block_id && !block_id.empty?) ? %( id="#{escape_html(block_id)}") : ""

      out << %(<div class="callout callout-#{type}"#{id_attr}>)
      out << %(  <div class="callout-title">#{escape_html(title)}</div>)
      out << %(  <div class="callout-body" markdown="1">)
      out << ""
      body_lines.each { |bl| out << bl }
      out << ""
      out << %(  </div>)
      out << %(</div>)
    end

    out.join("\n")
  end

  def self.escape_html(s)
    s.to_s
     .gsub("&", "&amp;")
     .gsub("<", "&lt;")
     .gsub(">", "&gt;")
     .gsub('"', "&quot;")
     .gsub("'", "&#39;")
  end
end

Jekyll::Hooks.register [:pages, :documents], :pre_render do |doc|
  next unless doc.respond_to?(:content)
  ext = doc.respond_to?(:extname) ? doc.extname : File.extname(doc.path.to_s)
  next unless ext.downcase == ".md"

  doc.content = ObsidianCallouts.transform(doc.content)
end

