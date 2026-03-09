import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dialog"
export default class extends Controller {
	connect() {
		if (document.documentElement.hasAttribute("data-turbo-preview")) return

		this.element.showModal()

		this.boundRemove = this.remove.bind(this)
		document.addEventListener("turbo:before-cache", this.boundRemove)
	}

	disconnect() {
		document.removeEventListener("turbo:before-cache", this.boundRemove)
	}

	close(event) {
		if (event) event.preventDefault()
		this.element.close()
	}

	remove() {
		this.element.remove()
	}
}
