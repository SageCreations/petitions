package petitions

import ui "webui"
import "base:runtime"
import "core:fmt"
import "core:os"
import "core:time/datetime"
import "core:strings"
import "core:encoding/json"


// == Structures ==============================================================


Petition :: struct {
    id:         string,
    name:       string,
    desc:       string,
    created_at: datetime.DateTime,
    updated_at: datetime.DateTime,
}


// ============================================================================


// == Globals =================================================================


// Database context to use throughout the Odin program during runtime.
database_context := make(map[string]Petition)


// ============================================================================


// == Database ================================================================

// Constant of where the data folder and file are/is
DATABASE :: "data/database.json"

// Load Database - initializes database/file if not already there and returns a map using the typeid passed in.
LoadDatabase :: proc($T: typeid) -> map[string]T {
    db_ctx := make(map[string]T)
    file_byte_data, success := os.read_entire_file_from_filename(DATABASE)
    if !success {
        fmt.printfln("Database file has not been created yet, initializing...")
        // marshal brackets to create json data to write to file with.
        data, _ := json.marshal(db_ctx, {pretty = true})
        succ := os.write_entire_file(DATABASE, data)
        if succ {
            fmt.printfln("Initialization complete.")
            file_byte_data, _ = os.read_entire_file_from_filename(DATABASE)
        } else {
            fmt.printfln("Failed to initialize the Database, something is wrong.\nExiting...")
            os.exit(1)
        }
    } else {
        fmt.printfln("Database file found.")
    }

    // unmarshal data to load into [dynamic]T to return
    fmt.printfln("Loading data in...")
    err := json.unmarshal(file_byte_data, &db_ctx)
    if err != nil {
        fmt.printfln("Something went wrong retrieving the database.\nError: %v", err)
        os.exit(1)
    }
    fmt.printfln("Success! Proceeding to Program.")
    return db_ctx
}

// Save Database - write to file
SaveDatabase :: proc() {
    data, json_err := json.marshal(database_context, {pretty = true})
    if json_err != nil {
        fmt.printfln("Database could not be marshaled!\nError: %v", json_err)
        os.exit(1)
    }

    success := os.write_entire_file(DATABASE, data)
    if success {
        fmt.printfln("Database saved succesfully.")
    } else {
        fmt.printfln("Failed to save database, something is wrong.\nExiting...")
        os.exit(1)
    }
}

// -- CRUD Operations ---------------------------
// Edit database_context directly in these functions

// get_all_petitions()
//  returns the full list of petition objects.
GetAllPetitions :: proc() -> map[string]Petition {
    return database_context
}

// get_petition_by_id(petition_id)
//  searches for and returns a petition based on its unique ID.
GetPetitionByID :: proc(petition_id: string) -> Petition {
    return database_context[petition_id]
}

// create_petition(petition_data)
//  accepts a dictionary with the petitioner's data, generates a unique ID and timestamps,
//  then appends it to the database.
CreatePetition :: proc(petition: Petition) {
    map_insert(&database_context, petition.id, petition)
}

// update_petition(petition_id, update_data)
//  updates an existing petition’s fields and refreshes the updatedAt timestamp.
UpdatePetition :: proc(petition_id: string, update_data: Petition) {
    data := update_data
    // TODO: ensure id stays the same, check if ID exists too
    database_context[petition_id] = data
}

// delete_petition(petition_id)
//  removes the petition from the list and persists the change.
DeletePetition :: proc (petition_id: string) {
    delete_key(&database_context, petition_id)
}


// ============================================================================


// == WEBUI Callbacks =========================================================


// This function gets called every time there is an event.
events :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()

    switch e.event_type {
    case .Connected:
        fmt.println("Connected.")
        // TODO: trying to call js from backend, .ts being compiled to js files
        ui.run(e.window, "hello();")
        ui.script(e.window, "hello();")
    case .Disconnected:
        fmt.println("Disconnected.")
    case .MouseClick:
        fmt.println("Click.")
    case .Navigation:
        target, _ := ui.get_arg(string, e)
        fmt.println("Starting navigation to:", target)
        ui.navigate(e.window, target)
    case .Callback:
        fmt.println("Callback")
    }
}

// Switch to `/second.html` in the same opened window.
switch_to_second_page :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    ui.show(e.window, "second.html")
}

show_second_window :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    ui.show(ui.new_window(), "second.html", await = true)
    // Remove the Go Back button when showing the second page in another window.
    //ui.run(w2, "document.getElementById('go-back').remove();")
}

close_window :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    ui.close(e.window)
}


// ============================================================================


// == Main Program ============================================================


main :: proc() {
    database_context = LoadDatabase(Petition)

    // Set the root folder for the UI.
    ui.set_default_root_folder("views")

    // Prepare the main window.
    my_window: uint = ui.new_window()

    ui.set_runtime(my_window, .Bun)

    // Bind HTML elements to functions.
    ui.bind(my_window, "switch-to-second-page", switch_to_second_page)
    ui.bind(my_window, "open-new-window", show_second_window)
    ui.bind(my_window, "exit", close_window)
    ui.bind(my_window, "", events) // Bind all events.

    // Show the main window.
    ui.show_browser(my_window, "index.html", .Chrome)

    // Wait until all windows get closed.
    ui.wait()
    ui.clean()
}


// ============================================================================