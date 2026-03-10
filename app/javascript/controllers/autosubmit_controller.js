import { Controller } from "@hotwired/stimulus"
import { debounce } from "utils/debounce"

// Connects to data-controller="autosubmit"
export default class extends Controller {
    connect() {
        this.submitHandler = debounce(this.submitHandler.bind(this), 300)
    }

    submit() {
        this.submitHandler()
    }

    // Blocchiamo il tasto Invio per non far inviare il form principale del Job
    prevent(event) {
        event.preventDefault()
    }

    submitHandler() {
        // Comportamento legacy: se è attaccato a un form, fai il submit classico
        if (this.element.tagName === "FORM") {
            this.element.requestSubmit()
            return
        }

        // Nuovo comportamento: se è attaccato a un input (No form nidificati!)
        const input = this.element
        const frameId = input.dataset.frameId
        const urlString = input.dataset.url

        if (!frameId || !urlString) return

        // Costruiamo l'URL di ricerca
        const url = new URL(urlString, window.location.origin)
        url.searchParams.set("query", input.value)
        url.searchParams.set("frame_id", frameId)

        // Troviamo il frame e gli iniettiamo l'URL. Turbo farà la magia!
        const frame = document.getElementById(frameId)
        if (frame) {
            frame.src = url.toString()
        }
    }
}
