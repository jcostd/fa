import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="omnibox"
export default class extends Controller {
	connect() {
	}

	focusShortcut(event) {
		if ((event.metaKey || event.ctrlKey) && event.key === "k") {
			event.preventDefault();
			this.element.focus();
		}
	}
}
