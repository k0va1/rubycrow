import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { interval: { type: Number, default: 300000 } }

  connect() {
    this.refreshTimer = setInterval(() => {
      const frame = this.element.querySelector("turbo-frame")
      if (frame) frame.reload()
    }, this.intervalValue)
  }

  disconnect() {
    if (this.refreshTimer) clearInterval(this.refreshTimer)
  }
}
