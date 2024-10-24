# Linux Admin Basics + Nginx

- Assignment 1: 

    - Make a Bash script. Bash script should provide a simple menu-driven interface for executing basic Linux commands:
        -   List files and directories: Displays a detailed list of files and directories in the current directory.
        -   Display disk usage: Shows disk usage statistics for all mounted filesystems.
        -   Show running processes: Lists information about all running processes on the system.
        -   Show network information: Shows network interface configuration details.
        -   Exit: Exits the script.

- Assignment 2: 

    - Install and configure Nginx. Install needed version of PHP and MySQL/MariaDB. Download and configure Wordpress, (OPTIONAL) set up HTTPS connection to the server.
    - Make the script that will do it all.

- Assignment 3: 

    - Setting up the python project from the Intern-Assignment-Code
        - Optional: Make a script that does this automatically
        - Update the packages on the machine
        - Install python3.9
        - Install pip
        - Install virtualenv
        - Install postgresql and postgresql-contrib

    - Connecting to the database
        - The goal is to connect to the database that both from our machine and the local ubuntu machine itself
        - For connecting from the local ubuntu machine itself
            - Using psql tool, how do we connect to the databse on localhost?
            - What is the default way of local authentication of users for postgres running on ubuntu?
            - What do we need to do to connect ot the database?
        - Changing the Postgresql configuration to make our life easier
            - Found where is Postgresql installed
            - In the installation folder change the configuration file so you can connect remotely to the Postgresql database (Hint: postgresql.conf)
            - Update the configuration so that the local users uses md5 method, instead of peer + allow access from any address in the same configuration file (Hint: pg_hba.conf)

    - Create a non-root user with root privilages, we want our app to be started with this non-root user.  
        - Add a completely new key for that user

    - Initiate a python project with creating a new virtual environment in ~/app, copy the code to the /src folder
        - With pip install the necessary requirements for the project to run
        - Set up environment variables
            -  Define and persist environment variables required for the project
            - Ensure these environment variables persist through reboots
        - Run ```alembic upgrade head``` to update our database
        - Start the application and verify it runs correctly
    
    - Install gunicorn with pip (httptools,uvloop)
        - Start the app with 3 workers

    - We want the app to be run automatically in the background
        - Create service to start our application
    
    - Add Nginx as proxy for our application, also add a firewall for security
    