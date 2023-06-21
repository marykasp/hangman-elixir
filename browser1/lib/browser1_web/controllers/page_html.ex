defmodule Browser1Web.PageHTML do
  use Browser1Web, :html

  def plural_phrase(n, noun), do: "#{n} #{noun}s"

  embed_templates "page_html/*"
end
