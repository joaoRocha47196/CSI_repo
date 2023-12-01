import psycopg2
from pynput import keyboard


class Simulation:

    # PostgreSQL database connection parameters
    def __init__(self):
        self.__db_params = {
            "host": "localhost",
            "database": "my_gis_world",
            "user": "postgres",
            "password": "iseliano",
        }

        # Your PostgreSQL query
        self.__sql_query = "SELECT simular_trajetorias(2,1);"

    def on_button_click(self):
        self.execute_query()

    # Function to execute PostgreSQL query
    def execute_query(self):
        try:
            # Connect to the database
            connection = psycopg2.connect(**self.__db_params)
            cursor = connection.cursor()

            # Execute the query
            cursor.execute(self.__sql_query)

            # Commit the transaction
            connection.commit()

        except Exception as e:
            print(f"Error: {e}")

        finally:
            # Close the database connection
            if connection:
                connection.close()

    # Function to be called when a key is pressed
    def on_press(self,key):
        try:
            if key == keyboard.Key.right:
                print("Right arrow key pressed. Executing query...")
                self.execute_query()
            else:
                print(f"Key pressed: {key}")

        except Exception as e:
            print(f"Error: {e}")


