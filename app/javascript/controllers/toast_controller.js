import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
	static values = { timeout: { type: Number, default: 4000 } }

	connect() {
		this.timeoutId = setTimeout(() => {
			this.close()
		}, this.timeoutValue)
	}

	disconnect() {
		clearTimeout(this.timeoutId)
	}

	close() {
		this.element.remove()
	}
}
