# Lacquer Project

Welcome to the Lacquer project! Follow these steps to get started.

## Features

## Setup Instructions

1. **Get the `.env` file**  
   Visit [this link](https://github.com/Lacquer-UIT/.github-private/blob/main/profile/README.md) for instructions on obtaining the `.env` file. Place it in the project root directory.


2. **Install `just` (Command Runner)**  
   Ensure you have `just` installed. You can install it using any of the following methods:
   - **Using Cargo (Universal)** (recommended):
     ```sh
     cargo install just
     ```
   - **Using Homebrew (macOS/Linux):**
     ```sh
     brew install just
     ```
   - **Using Scoop (Windows):**
     ```sh
     scoop install just
     ```
   - **Download Prebuilt Binaries:** [Check the official releases](https://github.com/casey/just/releases)

3. **Run the Project**  
   Use the `just` command to run the program:
   ```sh
   just
   ```

   **Alternative: Run with custom environment variables**  
   You can also run the app with custom environment variables:
   ```sh
   flutter run --dart-define=SERVER_URL=https://your-server-url.com
   ```

4. **Initialize Husky Hook (Run Once)**  
   Before making commits, initialize the Husky hook:
   ```sh
   just init
   ```
