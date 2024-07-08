1. Python 3 is required

2. Create python3 virtual environment:

```
py -3 -m venv env
```
or
```
python3 -m venv env
```

3. Enter the virtual environment:

```
./env/Scripts/activate.bat
```
or
```
source ./env/bin/activate
```

3. Install the requirements:

```
pip install -v ./requirements.txt
```

4. Create the executable and additional files:

```
pyinstaller --noconsole gui.py
```

5. Archive the content of dist/gui directory as zip, name it earth2160_zoom_aptcher_vX.X.zip,
where X.Y is a version.

Now you can unpack it somewhere and test.

Note: it's possible to bundle everything inside one file, but some antivirus software may report false positives in this case, so we withdraw from this method.