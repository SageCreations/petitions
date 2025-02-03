import sys
sys.path.append('./python-webui/')
sys.path.append('./data/')
import webui as ui
import database as db
import json

def close_the_application(e : ui.Event):
	ui.exit()

def main():
	# Create a window object
	my_window = ui.Window()

	# Bind am HTML element ID with a python function
	my_window.bind('Exit', close_the_application)

	my_window.set_runtime(ui.Runtime.Bun)

	my_window.set_root_folder("./views/")

	# Show the window
	my_window.show_browser("index.html", ui.Browser.Chrome)

	# Wait until all windows are closed
	ui.wait()

	print('Thank you.')

if __name__ == "__main__":
	db.load_database()
	# For testing purposes: print the current state of the database.
	print(json.dumps(db.database, indent=4))
	main()
