import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
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
          controller.gemSelected(val)
        }
      }
    })
  }

  async gemSelected(gemId) {
    const url = `${this.urlValue}?id=${encodeURIComponent(gemId)}`
    const response = await fetch(url, {
      headers: { "Accept": "application/json" }
    })

    if (!response.ok) return

    const gem = await response.json()

    const wrapper = this.element.closest("[data-nested-form-wrapper]")
    if (!wrapper) return

    const titleInput = wrapper.querySelector('input[name$="[title]"]')
    const urlInput = wrapper.querySelector('input[name$="[url]"]')
    const descInput = wrapper.querySelector('textarea[name$="[description]"]')

    if (titleInput) titleInput.value = gem.name
    if (urlInput) urlInput.value = gem.project_url
    if (descInput) descInput.value = gem.info || ""
  }
}
