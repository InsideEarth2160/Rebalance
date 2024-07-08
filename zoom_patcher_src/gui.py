from tkinter import filedialog, messagebox
from earth2160_steam import get_path_to_game
from patch import patch_game


def show_message(title, message, error: bool = False):
    if error:
        messagebox.showerror(title, message)
    else:
        messagebox.showinfo(title, message)


def choose_file():
    try:
        return filedialog.askopenfilename(title="Where is your Earth2160_SSE.exe?",
                                          filetypes=[("Earth2160","Earth2160_SSE.exe")])
    except RuntimeError as e:
        print("ERR: Failed to choose where Earth2160_SSE.exe is located, ", str(e))
        return None


if __name__ == "__main__":
    show_message(title="Zoom Out Patch", message="This will add zoom out capabilities to your Earth 2160 game. "
                                       "Choosing a Earth2160_SSE.exe file to patch it...")
    filepath = get_path_to_game()
    if not filepath:
        filepath = choose_file()
    if not filepath:
        show_message(title="Failure",
                     message="Pathed not applied, don't know where is your Earth2160_SSE.exe",
                     error=True)
        exit(1)
    else:
        patch_game(filepath)
        show_message(title="Success", message="Have fun with new zoom out abilities!")
