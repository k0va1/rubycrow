import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["titleField", "urlField", "descriptionField"]
  static values = { url: String }

  connect() {
    const hiddenField = this.element.querySelector('[data-lui-combobox-target="hiddenField"]')
    if (hiddenField) this.interceptHiddenField(hiddenField)
  }

  interceptHiddenField(field) {
    const descriptor = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, "value")
    const controller = this

    Object.defineProperty(field, "value", {
      get() {
        return descriptor.get.call(this)
      },
      set(val) {
        const oldVal = descriptor.get.call(this)
        descriptor.set.call(this, val)
        if (val && val !== oldVal) {
          controller.articleSelected(val)
        }
      }
    })
  }

  async articleSelected(articleId) {
    const url = `${this.urlValue}?id=${encodeURIComponent(articleId)}`
    const response = await fetch(url, {
      headers: { "Accept": "application/json" }
    })

    if (!response.ok) return

    const article = await response.json()

    const titleInput = this.titleFieldTarget.querySelector("input")
    const urlInput = this.urlFieldTarget.querySelector("input")
    const descInput = this.descriptionFieldTarget.querySelector("textarea")

    if (titleInput) titleInput.value = article.title
    if (urlInput) urlInput.value = article.url
    if (descInput) descInput.value = article.summary || ""
  }
}
