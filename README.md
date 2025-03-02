# CODE-X

CODE-X is a lightweight code editor built using Flutter, designed to support Python, Java, and C execution. It provides a simple yet efficient environment for writing, editing, and running code.

## Features

- 📝 Minimalist text editor for a distraction-free coding experience
- 🚀 Supports Python, Java, and C execution
- 📂 Saves files in a list format: `["filename", "content"]`
- 🔧 Uses temporary script files and `process_run` for execution
- ⚡ Fast and lightweight, perfect for quick coding tasks

## Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/yourusername/CODE-X.git
   cd CODE-X
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Run the app:
   ```sh
   flutter run
   ```

## How It Works

- The landing page contains a 'Create' button that navigates to the text editor.
- Code is written in the editor and can be saved with a filename.
- The app executes the code by creating temporary script files and running them using `process_run`.
- Output is displayed within the app.

## Technologies Used

- Flutter
- Dart
- `process_run` for executing scripts

## Roadmap

-

## Contributing

Feel free to contribute by submitting issues or pull requests. Let's make CODE-X better together! 🚀

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

