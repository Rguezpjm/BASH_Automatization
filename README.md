<h1 align="center">Automatization BASH</h1>

This is a free-to-use repository containing various automations for technology personnel (DevOps, DBA, Cybersecurity, or Network/Information Technology).

## Available Scripts (.ps1)

| File Name | Latest Commit | Link |
|---|---|---|
| `script1.ps1` | `Add initial script1` | [script1.ps1](link/a/script1.ps1) |


## How to Use

To use the PowerShell scripts in this repository, follow these steps:

1.  **Download the script:** Download the desired `.ps1` file from the repository to your local machine. You can do this by clicking on the file and then clicking the "Raw" button, followed by saving the page. Or you can clone the repository using `git clone`.

2.  **Open PowerShell:** Open PowerShell as an administrator. You can do this by searching for "PowerShell" in the Start Menu, right-clicking on it, and selecting "Run as administrator".

3.  **Navigate to the script's directory:** Use the `cd` command to navigate to the directory where you saved the `.ps1` file. For example: `cd C:\Users\YourUser\Downloads`.

4.  **Set the Execution Policy (if needed):** PowerShell has an execution policy that restricts running scripts. If you get an error about execution policy, you need to set it. For testing purposes, you can use the following command (use with caution in production environments):

    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
    ```

    This command sets the execution policy to `Unrestricted` for the current PowerShell session only. A more secure approach for production environments would be to use `RemoteSigned`.

5.  **Run the script:** Execute the script using the following command:

    ```powershell
    .\script_name.ps1
    ```

    Replace `script_name.ps1` with the actual name of the script you downloaded.


## Contributing

*(Aquí puedes agregar información sobre cómo otros pueden contribuir al repositorio.)*

## Follower Count

[![Followers](https://img.shields.io/github/followers/Rguezpjm?style=social)](https://github.com/TuNombreDeUsuario?tab=followers)

## License

*(Puedes agregar una licencia como MIT, GPL, etc.)*
