import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { threshold: { type: Number, default: 80 } }

  connect() {
    this._ticking = false
    this._onScroll = () => {
      if (!this._ticking) {
        requestAnimationFrame(() => {
          this._update()
          this._ticking = false
        })
        this._ticking = true
      }
    }
    window.addEventListener("scroll", this._onScroll, { passive: true })
    this._update()
  }

  disconnect() {
    window.removeEventListener("scroll", this._onScroll)
  }

  _update() {
    if (window.scrollY > this.thresholdValue) {
      this.element.classList.add("visible")
    } else {
      this.element.classList.remove("visible")
    }
  }

  scrollTo(event) {
    event.preventDefault()
    const id = event.currentTarget.getAttribute("href").substring(1)
    const target = document.getElementById(id)
    if (target) {
      target.scrollIntoView({ behavior: "smooth" })
    }
  }
}
