import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { goal: Number }

  connect() {
    this.animated = false
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting && !this.animated) {
          this.animated = true
          this.animateCount()
        }
      })
    }, { threshold: 0.15 })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  animateCount() {
    const goal = this.goalValue
    const duration = 1500
    const startTime = performance.now()

    const step = (currentTime) => {
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / duration, 1)
      const eased = 1 - Math.pow(1 - progress, 3)
      this.element.textContent = Math.floor(eased * goal)

      if (progress < 1) {
        requestAnimationFrame(step)
      } else {
        this.element.textContent = goal
      }
    }

    requestAnimationFrame(step)
  }
}
