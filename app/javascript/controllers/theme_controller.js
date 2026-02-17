import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    const saved = localStorage.getItem("theme")
    if (saved === "light") {
      document.documentElement.setAttribute("data-theme", "light")
    }
    this._updateIcon()
  }

  toggle() {
    const isLight = document.documentElement.getAttribute("data-theme") === "light"
    if (isLight) {
      document.documentElement.removeAttribute("data-theme")
      localStorage.setItem("theme", "dark")
    } else {
      document.documentElement.setAttribute("data-theme", "light")
      localStorage.setItem("theme", "light")
    }
    this._updateIcon()
  }

  _updateIcon() {
    if (!this.hasIconTarget) return
    const isLight = document.documentElement.getAttribute("data-theme") === "light"
    this.iconTarget.innerHTML = isLight ? this._moonSvg() : this._sunSvg()
  }

  _sunSvg() {
    return '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><circle cx="12" cy="12" r="5" stroke-width="1.5"/><path stroke-linecap="round" stroke-width="1.5" d="M12 1v2m0 18v2M4.22 4.22l1.42 1.42m12.72 12.72l1.42 1.42M1 12h2m18 0h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>'
  }

  _moonSvg() {
    return '<svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"/></svg>'
  }
}
