from webui import webui
from jinja2 import Environment, FileSystemLoader
import os
import json
import uuid
import time


# Path to your local data folder
DATA_FOLDER = os.path.join(os.path.dirname(__file__), 'data')
JSON_FILE = os.path.join(DATA_FOLDER, 'database.json')


def load_database() -> dict:
    """
    Loads the JSON database into a Python dictionary.
    If the file does not exist, returns an empty dictionary.
    """
    if not os.path.exists(JSON_FILE):
        return {}
    with open(JSON_FILE, 'r') as file:
        try:
            data = json.load(file)
        except json.JSONDecodeError:
            # If the file is empty or malformed, return an empty dict.
            data = {}
    return data


def update_database(database: dict, new_data: dict = None, petition_id: str = None) -> None:
    """
    Updates the in-memory database and writes it to the JSON file.

    :param database: The in-memory database (a dict) to update.
    :param new_data: A dictionary containing new or updated petition data.
    :param petition_id: The unique id for the petition being updated (if applicable).
                       If provided, the new_data is inserted/updated under this key.
                       Otherwise, new_data is assumed to be a dict of multiple entries
                       that can be merged into the database.
    """
    if new_data:
        if petition_id:
            # Update or add a single petition by its id.
            database[petition_id] = new_data
        else:
            # Merge new_data dictionary with the existing database.
            database.update(new_data)

    # Write the updated database to the JSON file.
    with open(JSON_FILE, 'w') as file:
        json.dump(database, file, indent=2)


def create_petition(name: str, desc: str) -> dict:
    """
    Create a petition JSON object with:
    - A unique UUID as the id.
    - Provided name and description.
    - created_at and updated_at timestamps in seconds (stored in the '_nsec' key).

    :param name: The petition's name.
    :param desc: The petition's description.
    :return: A dictionary representing the petition.
    """
    # Generate a new UUID and get the current time in seconds.
    petition_id = str(uuid.uuid4())
    current_timestamp = int(time.time_ns())  # Seconds since epoch

    petition = {
        "id": petition_id,
        "name": name,
        "desc": desc,
        "created_at": {"_nsec": current_timestamp},
        "updated_at": {"_nsec": current_timestamp},
    }

    return petition


def render_template(template_name: str, **context) -> str:
    """
    Loads a template by name, applies the given context,
    and returns the final rendered string.
    """
    # 1. Create a Jinja2 environment, pointing to the 'templates' directory
    env = Environment(loader=FileSystemLoader('templates/'))

    # 2. Load the template
    template = env.get_template(template_name)

    # 3. Render it with any additional context variables
    return template.render(**context)


def add_petition(e: webui.Event):
    petition = create_petition(e.get_string_at(0), e.get_string_at(1))
    update_database(load_database(), petition, petition['id'])
    print(json.dumps(petition, indent=2))
    e.window.show(render_template("pages/dashboard.html", petition_data=load_database()))


def remove_petition(e: webui.Event):
    db_ctx = load_database()
    petition = db_ctx.pop(e.get_string())
    print("Petition was deleted: ", petition)
    update_database(db_ctx)
    # e.window.show(render_template("pages/dashboard.html", petition_data=load_database()))


def edit_petition(e: webui.Event):
    # webui.editPetition(petition_id, name_val, desc_val)
    db_ctx = load_database()
    petition = db_ctx.get(e.get_string_at(0))
    petition['name'] = e.get_string_at(1)
    petition['desc'] = e.get_string_at(2)
    petition['updated_at'] = time.time_ns()
    db_ctx[petition['id']] = petition
    update_database(db_ctx)



def dashboard_controller(w: webui.Window):
    # Render the dashboard template, passing in the petition data.
    rendered_html = render_template("pages/dashboard.html", petition_data=load_database())

    # Show in browser - this assumes your framework provides this functionality.
    # Replace `my_window.show_browser` and `webui.Browser.Firefox` with your actual calls.
    w.show_browser(rendered_html, webui.Browser.Firefox)


def main():
    # Create a window object
    my_window = webui.Window()

    my_window.set_root_folder("./templates/")

    # bind functions/events here
    my_window.bind("newPetition", add_petition)
    my_window.bind("deletePetition", remove_petition)
    my_window.bind("editPetition", edit_petition)

    # Show the Home Page initially
    dashboard_controller(my_window)

    # Wait until all windows are closed
    webui.wait()


if __name__ == "__main__":
    main()
