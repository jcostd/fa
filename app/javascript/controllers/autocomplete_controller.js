import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
	static targets = ["input", "hidden", "results"]
	static values = { url: String }

	connect() {
		this.timeout = null
	}

	search() {
		clearTimeout(this.timeout)
		const query = this.inputTarget.value

		if (query.length < 2) {
			this.resultsTarget.innerHTML = ""
			return
		}

		this.timeout = setTimeout(() => {
			fetch(`${this.urlValue}?query=${encodeURIComponent(query)}`)
				.then(response => response.text())
				.then(html => {
					this.resultsTarget.innerHTML = html
				})
		}, 300)
	}

	select(event) {
		event.preventDefault()

		// Popola i campi con i data-attribute del bottone cliccato
		this.hiddenTarget.value = event.currentTarget.dataset.id
		this.inputTarget.value = event.currentTarget.dataset.name

		// Nasconde i risultati
		this.resultsTarget.innerHTML = ""
	}

	openModal(event) {
		event.preventDefault()

		const query = event.currentTarget.dataset.query
		const modalId = event.currentTarget.dataset.modalId
		const inputId = event.currentTarget.dataset.inputId

		const modal = document.getElementById(modalId)
		const nameInput = document.getElementById(inputId)

		if (modal && nameInput) {
			nameInput.value = query
			modal.showModal()
			this.resultsTarget.innerHTML = ""
		}
	}
}
