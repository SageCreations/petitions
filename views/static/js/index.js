// views/static/ts/index.ts
document.addEventListener("DOMContentLoaded", function() {
  if (typeof webui !== "undefined") {
    webui.setEventCallback((e) => {
      if (e == webui.event.CONNECTED) {
        console.log("Connected.");
        webui.getPetitions();
      } else if (e == webui.event.DISCONNECTED) {
        console.log("Disconnected.");
      }
    });
  } else {
    alert("Please add webui.js to your HTML.");
  }
});
var MyLib;
((MyLib) => {
  function hello() {
    console.log("Hello there, from MyLib!");
  }
  MyLib.hello = hello;
  function anotherFunction() {
    console.log("This is another function from MyLib.");
  }
  MyLib.anotherFunction = anotherFunction;
  function getPetitionFormData() {
    const nameInput = document.getElementById("create-petition-name");
    const descInput = document.getElementById("create-petition-desc");
    if (!nameInput || !descInput) {
      throw new Error("One or more form elements could not be found.");
    }
    console.log("name: ", nameInput.value, "\tdesc: ", descInput.value);
    return JSON.stringify({ name: nameInput.value, desc: descInput.value });
  }
  MyLib.getPetitionFormData = getPetitionFormData;
  function displayPetitions(petitionList) {
    const container = document.getElementById("petition-container");
    container.innerHTML = "";
    petitionList.forEach((petition) => {
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
  MyLib.displayPetitions = displayPetitions;
})(MyLib ||= {});
window.MyLib = MyLib;
