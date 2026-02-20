import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { handle: String }

  connect() {
    this.sortable = Sortable.create(this.element, {
      handle: this.handleValue || "[data-sortable-handle]",
      animation: 150,
      onEnd: this.updatePositions.bind(this)
    })
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy()
    }
  }

  updatePositions() {
    const items = this.element.querySelectorAll("[data-nested-form-wrapper]")
    items.forEach((item, index) => {
      const positionInput = item.querySelector("input[name*='[position]']")
      if (positionInput) {
        positionInput.value = index
      }
    })
  }
}
