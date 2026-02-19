import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "admin-theme"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    const saved = localStorage.getItem(STORAGE_KEY)
    if (saved === "dark") {
      document.documentElement.classList.add("lui-theme-dark")
    } else if (saved === "light") {
      document.documentElement.classList.remove("lui-theme-dark")
    }
    this._updateIcon()
  }

  toggle() {
    const isDark = document.documentElement.classList.contains("lui-theme-dark")
    if (isDark) {
      document.documentElement.classList.remove("lui-theme-dark")
      localStorage.setItem(STORAGE_KEY, "light")
    } else {
      document.documentElement.classList.add("lui-theme-dark")
      localStorage.setItem(STORAGE_KEY, "dark")
    }
    this._updateIcon()
  }

  _updateIcon() {
    if (!this.hasIconTarget) return
    const isDark = document.documentElement.classList.contains("lui-theme-dark")
    this.iconTarget.innerHTML = isDark ? this._sunSvg() : this._moonSvg()
  }

  _sunSvg() {
    return '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><circle cx="12" cy="12" r="5"/><path stroke-linecap="round" d="M12 1v2m0 18v2M4.22 4.22l1.42 1.42m12.72 12.72l1.42 1.42M1 12h2m18 0h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg>'
  }

  _moonSvg() {
    return '<svg class="w-5 h-5" fill="none" stroke="currentColor" stroke-width="1.5" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M21 12.79A9 9 0 1111.21 3 7 7 0 0021 12.79z"/></svg>'
  }
}
