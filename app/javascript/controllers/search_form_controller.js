import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      const url = new URL(window.location.href)
      const value = this.inputTarget.value.trim()

      if (value) {
        url.searchParams.set("search", value)
      } else {
        url.searchParams.delete("search")
      }

      url.searchParams.delete("page")
      Turbo.visit(url.toString())
    }, 300)
  }
}
