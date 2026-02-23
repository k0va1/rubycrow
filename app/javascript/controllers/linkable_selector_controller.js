import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["typeSelect", "panel"]

  connect() {
    this.syncPanels()
  }

  typeChanged() {
    this.syncPanels()
  }

  syncPanels() {
    const selectedType = this.typeSelectTarget.value

    this.panelTargets.forEach(panel => {
      const hiddenField = panel.querySelector('[data-lui-combobox-target="hiddenField"]')
      const textInput = panel.querySelector('[data-lui-combobox-target="input"]')

      if (panel.dataset.linkableType === selectedType) {
        panel.classList.remove("hidden")
        if (hiddenField) hiddenField.disabled = false
      } else {
        panel.classList.add("hidden")
        if (hiddenField) {
          hiddenField.value = ""
          hiddenField.disabled = true
        }
        if (textInput) textInput.value = ""
      }
    })
  }
}
