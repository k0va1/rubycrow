import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { goal: Number }

  connect() {
    const goal = this.goalValue
    if (goal === 0) return

    let current = 0
    const duration = 1500
    const stepTime = Math.max(Math.floor(duration / goal), 20)

    this.timer = setInterval(() => {
      current += Math.ceil(goal / (duration / stepTime))
      if (current >= goal) {
        current = goal
        clearInterval(this.timer)
        this.timer = null
      }
      this.element.textContent = current.toLocaleString()
    }, stepTime)
  }

  disconnect() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = null
    }
  }
}
