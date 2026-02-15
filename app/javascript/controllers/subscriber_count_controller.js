import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { target: Number }

  connect() {
    const target = this.targetValue
    if (target === 0) return

    let current = 0
    const duration = 1500
    const stepTime = Math.max(Math.floor(duration / target), 20)

    const timer = setInterval(() => {
      current += Math.ceil(target / (duration / stepTime))
      if (current >= target) {
        current = target
        clearInterval(timer)
      }
      this.element.textContent = current.toLocaleString()
    }, stepTime)
  }
}
