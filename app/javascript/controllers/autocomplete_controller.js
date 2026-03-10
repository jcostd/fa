import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
    static targets = ["input", "hidden"]

    select(event) {
	event.preventDefault()

	this.hiddenTarget.value = event.currentTarget.dataset.id
	this.inputTarget.value = event.currentTarget.dataset.name

	const frame = this.element.querySelector("turbo-frame")
	if (frame) frame.innerHTML = ""
    }

    openModal(event) {
	event.preventDefault()

	const modalId = this.element.dataset.modalId
	const inputId = this.element.dataset.inputId
	const currentQuery = this.inputTarget.value

	const modal = document.getElementById(modalId)
	const nameInput = document.getElementById(inputId)

	if (modal) {
	    if (nameInput) nameInput.value = currentQuery
	    modal.showModal()

	    const frame = this.element.querySelector("turbo-frame")
	    if (frame) frame.innerHTML = ""
	} else {
	    console.error("Modale non trovato:", modalId)
	}
    }
}
