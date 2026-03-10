import { Controller } from "@hotwired/stimulus";
import { debounce } from "utils/debounce";

// Connects to data-controller="omnibox"
export default class extends Controller {
    // Rimosso "form" dai targets!
    static targets = ["input", "results", "skeleton", "item"];

    connect() {
        this.currentIndex = -1;
        this.performSearch = debounce(this.performSearch.bind(this), 300);
    }

    search() {
        const query = this.inputTarget.value.trim();

        if (query.length >= 2) {
            this.showSkeleton();
            this.performSearch();
        } else {
            this.resetState();
        }
    }

    performSearch() {
        // Nuovo approccio: modifichiamo l'URL del Turbo Frame
        const urlString = this.inputTarget.dataset.url;
        if (!urlString) return;

        const url = new URL(urlString, window.location.origin);
        url.searchParams.set("query", this.inputTarget.value.trim());

        const frame = this.resultsTarget.querySelector("turbo-frame");
        if (frame) {
            frame.src = url.toString();
        }
    }

    toggleShortcut(event) {
        if ((event.metaKey || event.ctrlKey) && event.key === "k") {
            event.preventDefault();
            if (this.element.hasAttribute("open")) {
                this.close();
            } else {
                this.open();
            }
        }
    }

    open() {
        this.element.showModal();
        setTimeout(() => {
            this.inputTarget.focus();
        }, 10);
    }

    close() {
        this.element.close();
    }

    clearInput() {
        this.inputTarget.value = "";
        this.inputTarget.focus();
        this.resetState();
    }

    navigate(event) {
        if (event.key === "ArrowDown") {
            event.preventDefault();
            if (!this.hasItemTarget) return;
            this.currentIndex = Math.min(this.currentIndex + 1, this.itemTargets.length - 1);
            this.updateSelection();
        } else if (event.key === "ArrowUp") {
            event.preventDefault();
            if (!this.hasItemTarget) return;
            this.currentIndex = Math.max(this.currentIndex - 1, 0);
            this.updateSelection();
        } else if (event.key === "Enter") {
            event.preventDefault(); // Blocca l'invio per evitare comportamenti di default

            if (this.hasItemTarget && this.currentIndex >= 0) {
                const selectedItem = this.itemTargets[this.currentIndex];
                const link = selectedItem.tagName === "A" ? selectedItem : selectedItem.querySelector("a");

                if (link) {
                    link.click();
                    this.close();
                }
            }
        }
    }

    updateSelection() {
        this.itemTargets.forEach((item, index) => {
            if (index === this.currentIndex) {
                item.classList.add("bg-base-200", "border-primary");
                item.classList.remove("border-transparent");
                item.scrollIntoView({ block: "nearest" });
            } else {
                item.classList.remove("bg-base-200", "border-primary");
                item.classList.add("border-transparent");
            }
        });
    }

    // --- GESTIONE STATI ---
    resetState() {
        this.currentIndex = -1;
        this.hideSkeleton();
        const frame = this.resultsTarget.querySelector("turbo-frame");
        if (frame) {
            frame.removeAttribute("src"); // Blocca eventuali fetch in corso
            // Ricreiamo la schermata iniziale originale
            frame.innerHTML = `
              <div class="p-12 flex flex-col items-center justify-center text-center text-base-content/40 h-full mt-10">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-12 h-12 mb-4 opacity-20">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-5.197-5.197m0 0A7.5 7.5 0 105.196 5.196a7.5 7.5 0 0010.607 10.607z" />
                </svg>
                <p class="text-lg">Cosa stai cercando?</p>
                <p class="text-sm mt-1">Digita almeno 2 caratteri per iniziare la ricerca globale.</p>
              </div>`;
        }
    }

    resultsLoaded() {
        this.hideSkeleton();
        this.currentIndex = -1;
    }

    showSkeleton() {
        this.skeletonTarget.classList.remove("hidden");
        this.resultsTarget.classList.add("hidden");
    }

    hideSkeleton() {
        this.skeletonTarget.classList.add("hidden");
        this.resultsTarget.classList.remove("hidden");
    }
}
