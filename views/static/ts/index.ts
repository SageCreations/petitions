// Define the Petition interface matching your backend JSON structure.
interface Petition {
    id: string;
    name: string;
    desc: string;
    created_at: string; // ISO date string
    updated_at: string;
}

/**
 * Render the petition list using JSON data supplied by the backend.
 * @param petitions An array of Petition objects.
 */
function renderPetitionsFromJSON(petitions: Petition[]): void {
    const container = document.getElementById("petition-container");
    if (!container) return;
    container.innerHTML = ""; // Clear existing content

    petitions.forEach((petition) => {
        // Create a card element for each petition.
        const card = document.createElement("div");
        card.className = "card mb-3";
        card.innerHTML = `
			<div class="card-body">
				<h5 class="card-title">${petition.name}</h5>
				<p class="card-text">${petition.desc}</p>
				<p class="card-text">
					<small class="text-muted">Created: ${new Date(petition.created_at).toLocaleString()}</small>
				</p>
				<button class="btn btn-primary btn-edit" data-id="${petition.id}">Edit</button>
			</div>
		`;
        container.appendChild(card);
    });

    // Attach click event listeners to all edit buttons.
    const editButtons = document.querySelectorAll(".btn-edit");
    editButtons.forEach((btn) => {
        btn.addEventListener("click", (e: Event) => {
            const target = e.target as HTMLElement;
            const id = target.getAttribute("data-id");
            if (id) {
                // In your application, you may already have the JSON data for this petition.
                // For demonstration, assume you have a function that retrieves it:
                fetchPetitionJSON(id).then((petition: Petition) => {
                    openEditModalFromJSON(petition);
                });
            }
        });
    });
}

/**
 * Open the Edit Petition Modal using JSON data.
 * @param petition A Petition object.
 */
function openEditModalFromJSON(petition: Petition): void {
    const editNameInput = document.getElementById("edit-petition-name") as HTMLInputElement;
    const editDescInput = document.getElementById("edit-petition-desc") as HTMLTextAreaElement;
    const editPetitionIdInput = document.getElementById("edit-petition-id") as HTMLInputElement;

    if (editNameInput) editNameInput.value = petition.name;
    if (editDescInput) editDescInput.value = petition.desc;
    if (editPetitionIdInput) editPetitionIdInput.value = petition.id;

    // Show the edit modal using Bootstrap's JS API.
    const editModalElement = document.getElementById("editPetitionModal");
    if (editModalElement) {
        const modal = new bootstrap.Modal(editModalElement);
        modal.show();
    }
}

/**
 * Open the Create Petition Modal. This clears the form fields.
 */
function openCreateModal(): void {
    const createNameInput = document.getElementById("create-petition-name") as HTMLInputElement;
    const createDescInput = document.getElementById("create-petition-desc") as HTMLTextAreaElement;

    if (createNameInput) createNameInput.value = "";
    if (createDescInput) createDescInput.value = "";

    const createModalElement = document.getElementById("createPetitionModal");
    if (createModalElement) {
        const modal = new bootstrap.Modal(createModalElement);
        modal.show();
    }
}

/**
 * Update an existing petition card with new JSON data.
 * For example, after an edit, update the card without re-rendering the entire list.
 * @param petition A Petition object.
 */
function updatePetitionCardFromJSON(petition: Petition): void {
    const container = document.getElementById("petition-container");
    if (!container) return;
    // Look for the card's button with the matching data-id attribute.
    const cardButton = container.querySelector(`button.btn-edit[data-id="${petition.id}"]`);
    if (cardButton && cardButton.parentElement) {
        // Replace the card's inner HTML.
        const card = cardButton.parentElement.parentElement;
        if (card) {
            card.innerHTML = `
				<div class="card-body">
					<h5 class="card-title">${petition.name}</h5>
					<p class="card-text">${petition.desc}</p>
					<p class="card-text">
						<small class="text-muted">Created: ${new Date(petition.created_at).toLocaleString()}</small>
					</p>
					<button class="btn btn-primary btn-edit" data-id="${petition.id}">Edit</button>
				</div>
			`;
            // Reattach the event listener for the updated edit button.
            const newEditButton = card.querySelector(".btn-edit");
            if (newEditButton) {
                newEditButton.addEventListener("click", () => openEditModalFromJSON(petition));
            }
        }
    } else {
        // Optionally, if the card isn't found (e.g. it's a new petition), re-render the list.
        // In your app, you might choose to simply append the new card.
    }
}

/**
 * Placeholder function to simulate fetching a petition's JSON data by its id.
 * In your application, replace this with an actual API call.
 * @param id The petition id.
 * @returns A promise that resolves to a Petition object.
 */
function fetchPetitionJSON(id: string): Promise<Petition> {
    return new Promise((resolve) => {
        // Simulated data. Replace with your fetch logic.
        const dummy: Petition = {
            id: id,
            name: "Sample Petition " + id,
            desc: "Description for petition " + id,
            created_at: new Date().toISOString(),
            updated_at: new Date().toISOString(),
        };
        resolve(dummy);
    });
}

// Set up event listeners once the DOM is fully loaded.
document.addEventListener("DOMContentLoaded", () => {
    // In your application, the backend would supply the JSON array.
    // For example, you might call:
    // fetch('/api/petitions').then(response => response.json()).then(renderPetitionsFromJSON);

    // For demonstration, assume an empty list initially:
    renderPetitionsFromJSON([]);

    // Open Create Petition Modal when the "New Petition" button is clicked.
    const createPetitionBtn = document.getElementById("btn-new-petition");
    if (createPetitionBtn) {
        createPetitionBtn.addEventListener("click", openCreateModal);
    }

    // The "Save" buttons in the modals would trigger your logic to send data back to the backend.
    // Once the backend responds with updated JSON, call openEditModalFromJSON or updatePetitionCardFromJSON as needed.
});

// Optionally, expose these functions globally for testing or further integration.
(window as any).renderPetitionsFromJSON = renderPetitionsFromJSON;
(window as any).openEditModalFromJSON = openEditModalFromJSON;
(window as any).openCreateModal = openCreateModal;
(window as any).updatePetitionCardFromJSON = updatePetitionCardFromJSON;
