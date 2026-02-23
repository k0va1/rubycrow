import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.hiddenField = this.element.querySelector('[data-lui-combobox-target="hiddenField"]')
    if (this.hiddenField) this.interceptHiddenField(this.hiddenField)
  }

  disconnect() {
    if (this.hiddenField) {
      const descriptor = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, "value")
      Object.defineProperty(this.hiddenField, "value", descriptor)
    }
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
          controller.itemSelected(val)
        }
      }
    })
  }

  async itemSelected(itemId) {
    const url = `${this.urlValue}?id=${encodeURIComponent(itemId)}`
    const response = await fetch(url, {
      headers: { "Accept": "application/json" }
    })

    if (!response.ok) return

    const data = await response.json()

    const wrapper = this.element.closest("[data-nested-form-wrapper]")
    if (!wrapper) return

    const titleInput = wrapper.querySelector('input[name$="[title]"]')
    const urlInput = wrapper.querySelector('input[name$="[url]"]')
    const descInput = wrapper.querySelector('textarea[name$="[description]"]')

    if (titleInput) titleInput.value = data.title
    if (urlInput) urlInput.value = data.url
    if (descInput) descInput.value = data.description || ""
  }
}
