package petitions

import ui "webui"
import "base:runtime"
import "core:fmt"
import "core:os"
import "core:time"
import "core:time/datetime"
import "core:strings"
import "core:encoding/json"
import "core:crypto"
import "core:encoding/uuid"


// == Structures ==============================================================


Petition :: struct {
    id:         string,
    name:       string,
    desc:       string,
    created_at: time.Time,
    updated_at: time.Time,
}

create_petition :: proc(new_name: string, new_desc: string) -> Petition {
    uuid_identifier := uuid.generate_v7_with_counter(u16(len(database_context)))
    new_uuid, _ := uuid.to_string(uuid_identifier, context.temp_allocator)
    new_time := time.now()
    return Petition {
        id          = new_uuid,
        name        = new_name,
        desc        = new_desc,
        created_at  = new_time,
        updated_at  = new_time,
    }
}

update_petition :: proc(petition: ^Petition) {
    // TODO: make it where I can pass in args inside of {} to change stuff
    petition.updated_at = time.now()
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
CreatePetition :: proc(new_name: string, new_desc: string) {
    // This scope will have a CSPRNG.
    context.random_generator = crypto.random_generator()

    uuid_identifier := uuid.generate_v7_with_counter(u16(len(database_context)))
    new_uuid, _ := uuid.to_string(uuid_identifier, context.temp_allocator)
    new_time := time.now()
    new_petition := Petition {
        id          = new_uuid,
        name        = new_name,
        desc        = new_desc,
        created_at  = new_time,
        updated_at  = new_time,
    }

    map_insert(&database_context, new_petition.id, new_petition)
    fmt.printfln("database: %v", database_context)
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
        ui.run(e.window, "MyLib.anotherFunction();")
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

test_msg :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    // TODO: trying to call js from backend, .ts being compiled to js files
    //ui.run(e.window, "hello();")
    ui.run(e.window, "MyLib.hello();")
}

create_petition_cb :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    Data :: struct {
        name: string,
        desc: string,
    }

    // get the data from the front end
    data, _ := ui.get_arg(Data, e)
    fmt.printfln("data: %V",data)

    // create a new petition
    CreatePetition(data.name, data.desc)
}

get_petition_list_cb :: proc "c" (e: ^ui.Event) {
    context = runtime.default_context()
    fmt.printfln("getPetitions() was called")

    json_data, json_err := json.marshal(GetAllPetitions(), {spec = .JSON5, pretty = true})
    if json_err != nil {
        fmt.printfln("Unable to marshal petition list: %v", json_err)
    }
    resp: string = strings.clone_from_bytes(json_data)

    ui.run(e.window, fmt.tprintf("MyLib.displayPetitions(%s);", resp))
}


// ============================================================================


// == Main Program ============================================================


main :: proc() {
    database_context = LoadDatabase(Petition)

    // Prepare the main window.
    my_window: uint = ui.new_window()

    ui.set_runtime(my_window, .Bun)

    // Bind HTML elements to functions.
    ui.bind(my_window, "getPetitions", get_petition_list_cb)
    ui.bind(my_window, "newPetition", create_petition_cb)
    ui.bind(my_window, "btn-test", test_msg)
    ui.bind(my_window, "switch-to-second-page", switch_to_second_page)
    ui.bind(my_window, "open-new-window", show_second_window)
    ui.bind(my_window, "exit", close_window)
    ui.bind(my_window, "", events) // Bind all events.

    ui.set_config(.multi_client, true)
    ui.set_config(.use_cookies, true)

    // Set up custom file handler
    build_virtual_file_system("./views/")
    ui.set_file_handler(my_window, vfs)

    // Show the main window.
    browser_number := ui.get_best_browser(my_window)
    ui.show_browser(my_window, "index.html", ui.Browser(browser_number))

    // Wait until all windows get closed.
    ui.wait()

    SaveDatabase()
    ui.clean()
}


// ============================================================================