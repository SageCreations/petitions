// main.odin
package main

import "core:fmt"
import "core:strings"
import "base:runtime"
import ui "webui"


exit_app :: proc "c" (e: ^ui.Event) {
	context = runtime.default_context()

	ui.exit()
}


// // This function gets called every time there is an event.
events :: proc "c" (e: ^ui.Event) {
	context = runtime.default_context()

	switch e.event_type {
		case .Connected:
			fmt.println("Connected.")
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


my_files_handler :: proc "c" (filename: cstring, length: ^i32) -> rawptr {
	context = runtime.default_context()

	fmt.printfln("File: %s ", string(filename))
	fmt.printfln("file type: %s", ui.get_mime_type(filename))

	if strings.compare(string(filename), "/test.txt") == 0 {
	// Const static file example
		static_file_ex := fmt.aprint(
		"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: 99\r\n\r\n<html>This is a static embedded file content example.<script src=\"webui.js\"></script></html>"
		)

		return rawptr(raw_data(transmute([]u8)static_file_ex))
	} else if strings.compare(string(filename), "/dynamic.html") == 0 {
	// Dynamic file example

	// Generate body
		@(static) count: i32 = 1
		body := fmt.aprintf(
		"<html>This is a dynamic file content example. <br>Count: %d <a href=\"dynamic.html\">[Refresh]</a><br><script src=\"webui.js\"></script></html>",
		count,
		)
		count += 1
		body_size: int = len(body)

		header_and_body := fmt.aprintf(
		"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: %d\r\n\r\n%s",
		body_size, body,
		)

		return rawptr(raw_data(transmute([]u8)header_and_body))
	}

	// Other files:
	// A NULL return will make WebUI
	// looks for the file locally.
	return nil
}


main :: proc() {
// Database Initialization



// WebUI
	// create a new window
	my_window: uint = ui.new_window()

	ui.bind(my_window, "Exit", exit_app)
	ui.bind(my_window, "", events) // Bind all events.

	// setting the .ts and .js runtime
	ui.set_runtime(my_window, .Bun)

	// setting a custom file handler to use .ts files
	ui.set_file_handler(my_window, my_files_handler)

	// set default root folder for content
	ui.set_default_root_folder("views")

	// show the window
    ui.show_browser(my_window, "index.html", .Firefox)

	// wait for windows to close before exiting program
    ui.wait()
}
