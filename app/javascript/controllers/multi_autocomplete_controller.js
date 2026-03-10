import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multi-autocomplete"
export default class extends Controller {
    static targets = ["input", "selectedContainer", "badgeTemplate"]

    connect() {
	this.handleModalSuccess = this.handleModalSuccess.bind(this)
	window.addEventListener("modal:success", this.handleModalSuccess)
    }

    disconnect() {
	window.removeEventListener("modal:success", this.handleModalSuccess)
    }

    handleModalSuccess(event) {
	if (event.detail.modalId === this.element.dataset.modalId) {
	    this.inputTarget.value = ""
	}
    }

    select(event) {
	event.preventDefault()

	const id = event.currentTarget.dataset.id
	const name = event.currentTarget.dataset.name
	const uniqueKey = new Date().getTime()

	let templateHtml = this.badgeTemplateTarget.innerHTML
	templateHtml = templateHtml.replace(/NEW_RECORD/g, uniqueKey)
	templateHtml = templateHtml.replace(/TEMPLATE_ID/g, id)
	templateHtml = templateHtml.replace(/TEMPLATE_NAME/g, name)

	this.selectedContainerTarget.insertAdjacentHTML('beforeend', templateHtml)

	// Resetta
	this.inputTarget.value = ""
	const frame = this.element.querySelector("turbo-frame")
	if (frame) frame.innerHTML = ""
    }

    removeRow(event) {
	event.preventDefault()
	const row = event.currentTarget.closest('.participation-row') || event.currentTarget.closest('.badge')
	if (!row) return

	const destroyFlag = row.querySelector('.destroy-flag')

	if (destroyFlag) {
	    destroyFlag.value = "1"
	    row.style.display = 'none'
	} else {
	    row.remove()
	}
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
	}
    }
}
