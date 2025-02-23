# Quadkillers

Make sure you open up this specific sub-folder as the root of your vscode workspace
- For example: vscode -> file -> open folder -> .\quadkillers\QuadKillers###\Quadkillers

## Setting up Processing
1. Install the [processing language extension](https://marketplace.visualstudio.com/items?itemName=Tobiah.language-pde) by Avin Zarlez
2. ctrl+shift+p --> create task file
3. (For windows) Add processing to your path variable in windows
    - Open the processing-#.#.# folder
    - Copy the java executable file as a path
    - settings -> edit environment variables -> edit PATH -> add the processing file directory you copied
    - restart vscode
<!-- 4. Alternative: Change the path directory in tasks.json (Alternative to 3)
    - Find the `"command": "${config:processing.path}",` line in the `.vscode/tasks.json` file
    - Copy the processing-#.#.# folder as a path
    - Replace `processing.path` with the folder directory you copied -->
4. ctrl+shift+p --> run processing project (or use shortcut ctrl+shift+b)