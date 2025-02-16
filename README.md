# petitions
An application to have a centralized database for an admin to keep track petitions from others.


## Create Executable
To bundle the application into an executable, run:
```shell
# This is to install a program that will create an 
# executable version of our application.
pip install pyinstaller

# This command will bundle webui in its internals, add our data folder
# and add our frontend folder within the '_internal' and name the executable 'petitions'
pyinstaller --collect-all webui --add-data "data:data" --add-data "templates:templates" -n petitions app.py

# Same thing but if you want just a single executable
pyinstaller --onefile --collect-all webui --add-data "data:data" --add-data "templates:templates" -n petitions app.py
```
