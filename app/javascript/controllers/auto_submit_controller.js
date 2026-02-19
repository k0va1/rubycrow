import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    const url = new URL(window.location.href)
    const { name, value } = event.target

    if (value) {
      url.searchParams.set(name, value)
    } else {
      url.searchParams.delete(name)
    }

    url.searchParams.delete("page")
    Turbo.visit(url.toString())
  }
}
