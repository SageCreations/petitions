package data

import "core:fmt"
import "core:os"
import "core:encoding/json"
import "core:strings"


marshal_data :: proc(data: any = "{}") -> []byte {
    json_byte_data, err := json.marshal(data, {pretty = true})
    if err != nil {
        fmt.eprintfln("Unable to marshal JSON: %v", err)
        return nil
    }
    return json_byte_data
}

save_database :: proc(filepath: string = "./database.json", data: []byte) -> bool {
    werr := os.write_entire_file_or_err(filepath, data)
    if werr != nil {
        fmt.eprintfln("unable to write file: %v", werr)
        return false
    }
    return true
}


// TODO: document
init_database :: proc(filepath: string = "./database.json") -> bool {
    json_data := marshal_data()
    if json_data == nil { return false }

    return save_database(filepath, json_data)
}

// TODO: document
read_database :: proc(filepath: string = "./database.json", $T: typeid) -> (map[string]T, bool) {
    data, ok := os.read_entire_file_from_filename_or_err(filepath)
    if ok != nil {
        fmt.eprintfln("Failed to load the file: %v", ok)
        return nil, false
    }
    fmt.println("Success in loading file!")

    database: map[string]T
    if json.unmarshal(data, &T) == nil {
        fmt.println("Success in unmarshaling JSON")
    } else {
        fmt.eprintln("Failed to unmarshal JSON")
    }


    return database, true
}


load_partial_database_or_err :: proc($T: typeid, file_path: string = "data/data.json") -> map[string]T {
    db_ctx, err := load_database_or_err(file_path)
    if err != nil {
        fmt.eprintfln("shit is fucked up with loading the database ;_;")
        return nil
    }

    when T == Customer {
        return db_ctx.Customers, nil
    } else when T == Invoice {
        return db_ctx.Invoices, nil
    } else when T == Estimate {
        return db_ctx.Estimates, nil
    } else {
        fmt.eprintfln("Specified object: (%v), could not be found.", find)
        return nil
    }

}

