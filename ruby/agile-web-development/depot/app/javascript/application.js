// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"

import "trix"
import "@rails/actiontext"

// Flash any product that arrives via a Turbo Stream replace -- covers both
// the ActionCable broadcast from ProductsController#update and any future
// caller, without ProductsController needing to say "highlight this one".
document.addEventListener("turbo:before-stream-render", (event) => {
  const streamElement = event.target
  if (streamElement.action !== "replace" || !streamElement.target?.startsWith("product_")) return

  const renderDefault = event.detail.render
  event.detail.render = (stream) => {
    renderDefault(stream)
    document.getElementById(stream.target)?.classList.add("product-highlight")
  }
})
