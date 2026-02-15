import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("revealed")
            this.observer.unobserve(entry.target)
          }
        })
      },
      { threshold: 0.15 }
    )

    this.element.querySelectorAll("[data-reveal]").forEach((el) => {
      this.observer.observe(el)
    })
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
