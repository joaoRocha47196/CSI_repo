import tkinter as tk
import threading
from pynput import keyboard

class WindowSimulation:

    def __init__(self, simulation):
        
        self.__simulation = simulation

        # Create a threading.Event to signal the thread to stop
        self.__stop_event = threading.Event()

        # Create the main window
        self.__window = tk.Tk()
        self.__window.title("Simulador de iterações")

        # Create a button to execute the query
        button = tk.Button(self.__window, text="Iterar", command= self.__simulation.on_button_click)
        button.pack(pady=10)

        # Calculate the center of the screen
        screen_width = self.__window.winfo_screenwidth()
        screen_height = self.__window.winfo_screenheight()
        x = (screen_width - 360) // 2
        y = (screen_height - 200) // 2

        # Set the initial size and position of the window
        self.__window.geometry("360x50+{}+{}".format(x, y))

        # Bind the right arrow key to execute the query
        self.__window.bind("<Right>", lambda event: self.__simulation.on_button_click())

        # Bind the window close event to the on_close function
        self.__window.protocol("WM_DELETE_WINDOW", self.__on_close)

        # Create a thread to run the listener in the background
        self.__listener_thread = threading.Thread(target=self.__start_listener)
        self.__listener_thread.start()
        

        # Start the main event loop
        self.__window.mainloop()

    # Function to handle window close event
    def __on_close(self):
        print("Window closed. Exiting gracefully...")

        # Set the stop event to signal the thread to stop
        self.__stop_event.set()

        self.__listener_thread.join()

        self.__window.destroy()


    def __start_listener(self):
        with keyboard.Listener(on_press=self.__simulation.on_press) as listener:
            listener.join()
