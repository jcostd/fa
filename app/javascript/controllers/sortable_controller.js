import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

// Connects to data-controller="sortable"
export default class extends Controller {
	connect() {
		this.sortable = Sortable.create(this.element, {
			handle: ".sortable-handle",
			animation: 150,
			ghostClass: "opacity-50",
			onEnd: this.updatePositions.bind(this)
		})

		this.updatePositions()

		this.observer = new MutationObserver(() => {
			this.updatePositions()
		})

		this.observer.observe(this.element, { childList: true })
	}

	disconnect() {
		this.sortable.destroy()
		this.observer.disconnect()
	}

	updatePositions() {
		const positionInputs = this.element.querySelectorAll('.participation-row:not(template .participation-row) .position-input')

		let currentPosition = 1;

		positionInputs.forEach((input) => {
			const row = input.closest('.participation-row')
			const destroyFlag = row.querySelector('.destroy-flag')

			if (!destroyFlag || destroyFlag.value !== "1") {
				input.value = currentPosition
				currentPosition++
			}
		})
	}
}
