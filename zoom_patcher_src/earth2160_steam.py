import enum
import os
import platform
import re
from pathlib import Path


def _get_path_to_steam():
    if "Windows" in platform.system():
        return _get_windows_path_to_steam()
    else:
        return _get_linux_path_to_steam()


def _get_linux_path_to_steam():
    from pwd import getpwuid
    home_dir = Path(getpwuid(os.getuid()).pw_dir)
    return home_dir / ".local/share/Steam/"


def _get_windows_path_to_steam():
    from winreg import HKEY_CURRENT_USER, ConnectRegistry, OpenKey, QueryValueEx
    try:
        reg = ConnectRegistry(None, HKEY_CURRENT_USER)
        with OpenKey(reg, r'SOFTWARE'):
            pass
    except RuntimeError as e:
        print("ERR: Failed to access registry, error: ", str(e))
        print("Assume that Steam is on the default installation path")
        return _find_real_directory("c:/program files (x86)/steam")

    try:
        with OpenKey(reg, r'SOFTWARE\Valve\Steam') as key:
            reg_value = QueryValueEx(key, "SteamPath")
            path = reg_value[0]
            print(f"Reg path: {path}")
            real_path = _find_real_directory(path)
            print(f"Real path: {real_path}")
    except RuntimeError as e:
        print(r"WARN: Could not access 'SOFTWARE\Valve\Steam\SteamPath', probably you don't have Steam")
        raise SteamInstallationNotFound()
    return real_path


def _find_real_directory(lowercase_path):
    # Split the lowercase path into components
    components = lowercase_path.split('/')

    # Start from the root directory
    current_path = components[0] + "/"
    components = components[1:]

    # Iterate over each component
    for component in components:
        # Skip empty components
        if not component:
            continue

        # Find the real directory name that matches the lowercase component
        real_directory = None
        for dir_name in os.listdir(current_path):
            if dir_name.lower() == component:
                real_directory = dir_name
                break

        # If the real directory is not found, return None
        if real_directory is None:
            return None

        # Update the current path
        current_path = current_path + real_directory + "/"

    # Return the real directory path
    return Path(current_path)


class Stage(enum.Enum):
    Root = 1
    InRoot = 2
    ListOfFolders = 3
    Folder = 4
    InFolder = 5
    Done = 6
    PathValue = 7


def _skip(folders_data, i, block_depth):
    if folders_data[i] == '"':
        pos = folders_data.find('"', i + 1)
        i = pos + 1
    if folders_data[i] == "{":
        block_depth += 1
        i += 1
    elif folders_data[i] == "}":
        block_depth -= 1
        i += 1
    return i, block_depth


def _get_paths(folders_data, default_steam_path):
    block_depth = 0
    all_len = len(folders_data)
    space = re.compile(r"\s+")
    number = re.compile(r'[01-9]+')
    stage = Stage.Root
    paths = []
    try:
        i = 0
        while True:
            if i == all_len:
                break
            if space.match(folders_data[i]):
                i += 1
                continue
            if stage == Stage.Done:
                break
            if stage == Stage.Root:
                if folders_data[i:16] == '"libraryfolders"':
                    i += len('"libraryfolders"')
                    stage = Stage.InRoot
                else:
                    raise RuntimeError("Cannot find 'libraryfolders'")
            elif stage == Stage.InRoot:
                if folders_data[i] == "{":
                    block_depth += 1
                    stage = Stage.ListOfFolders
                elif folders_data[i] == "}":
                    block_depth -= 1
                    stage = Stage.Done
                i += 1
            elif stage == Stage.ListOfFolders:
                if block_depth == 1 and folders_data[i] == '"':
                    pos = folders_data.find('"', i+1)
                    if pos > i + 1 and number.fullmatch(folders_data[i+1:pos]):
                        stage = Stage.Folder
                    i = pos + 1
                elif block_depth == 1 and folders_data[i] == "}":
                    stage = Stage.InRoot
                else:
                    i, block_depth = _skip(folders_data, i, block_depth)
            elif stage == Stage.Folder:
                if block_depth == 1 and folders_data[i] == "{":
                    stage = Stage.InFolder
                    block_depth += 1
                    i += 1
                else:
                    i, block_depth = _skip(folders_data, i, block_depth)
            elif stage == Stage.InFolder:
                if block_depth == 2 and folders_data[i] == '"':
                    pos = folders_data.find('"', i + 1)
                    if pos > i + 1 and folders_data[i + 1:pos] == "path":
                        stage = Stage.PathValue
                    i = pos + 1
                elif block_depth == 2 and folders_data[i] == "}":
                    block_depth -= 1
                    stage = Stage.ListOfFolders
                    i += 1
                else:
                    i, block_depth = _skip(folders_data, i, block_depth)
            elif stage == Stage.PathValue:
                if block_depth == 2 and folders_data[i] == '"':
                    pos = folders_data.find('"', i + 1)
                    paths.append(Path(folders_data[i+1:pos].replace(r"\\", "/")))
                    i = pos + 1
                    stage = Stage.InFolder
                else:
                    raise RuntimeError(f"Unexpected value on pos {i}: '{folders_data[i]}' instead of path value")
    except RuntimeError as e:
        print("ERR: Could not parse 'libraryfolders.vdf', ", str(e))
        print("Assume that the game is on the default installation path")
        paths.append(default_steam_path)
    return paths


def _read_foldersfile(folder_path):
    libraryfolders_vdf_file = folder_path / "libraryfolders.vdf"
    print(f"libraryfolders_vdf_file: {libraryfolders_vdf_file}")
    with open(libraryfolders_vdf_file, "r", encoding="utf-8-sig") as f:
        return f.read()


class SteamInstallationNotFound(RuntimeError):
    """Indicates that the game most probably installed by some other method"""
    pass


def get_path_to_game():
    """Returns a path to Earth2160_SSE.exe or None if not found; raises SteamInstallationNotFound is there's no Steam"""
    try:
        steam_path = _get_path_to_steam()
        paths = []
        for folder_path in [steam_path / "steamapps/", steam_path / "config/"]:
            paths.extend(_get_paths(_read_foldersfile(folder_path), steam_path))
        print(paths)
        for p in paths:
            path_to_game = p / "steamapps/common/Earth 2160/Earth2160_SSE.exe"
            if os.path.isfile(path_to_game):
                print(f"Found! Here it is: {path_to_game}")
                return path_to_game
    except:
        pass
    return None


if __name__ == "__main__":
    print("Result: ", get_path_to_game())
