
document.addEventListener('DOMContentLoaded', function() {
    // DOM is loaded. Check if `webui` object is available
    if (typeof webui !== 'undefined') {
        // Set events callback
        webui.setEventCallback((e) => {
            if (e == webui.event.CONNECTED) {
                // Connection to the backend is established
                console.log('Connected.');
                webui.getPetitions();
            } else if (e == webui.event.DISCONNECTED) {
                // Connection to the backend is lost
                console.log('Disconnected.');
            }
        });
    } else {
        // The virtual file `webui.js` is not included
        alert('Please add webui.js to your HTML.');
    }
});

// Create a namespace to group related functions.
namespace MyLib {
    export function hello() {
        console.log("Hello there, from MyLib!");
    }

    export function anotherFunction() {
        console.log("This is another function from MyLib.");
    }

    // Get name and description for a new petition from the createPetitionModal modal
    export function getPetitionFormData(): string {
        // Get the input elements from the DOM.
        const nameInput = document.getElementById('create-petition-name') as HTMLInputElement | null;
        const descInput = document.getElementById('create-petition-desc') as HTMLTextAreaElement | null;

        // Check that both elements exist.
        if (!nameInput || !descInput) {
            throw new Error("One or more form elements could not be found.");
        }
        console.log("name: ", nameInput.value, "\tdesc: ", descInput.value)

        // Create the data object.
        return JSON.stringify({ name: nameInput.value, desc: descInput.value });
    }

    export function displayPetitions(petitionList: Object): void {
        const container = document.getElementById('petition-container') as HTMLDivElement | null;
        container.innerHTML = ''

        petitionList.forEach((petition) => {
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
    }


}

// Extend the Window interface to include our library.
declare global {
    interface Window {
        MyLib: typeof MyLib;
    }
}

// Attach the namespace to the window object.
window.MyLib = MyLib;
