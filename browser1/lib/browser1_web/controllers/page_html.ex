defmodule Browser1Web.PageHTML do
  use Browser1Web, :html

  embed_templates "page_html/*"

  def plural_phrase(n, noun), do: "#{n} #{noun}s"
end
