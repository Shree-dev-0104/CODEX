import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:highlight/languages/cpp.dart';
import 'package:highlight/languages/java.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/python.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:vs_code_app/database/database.dart';
import 'package:vs_code_app/utils/code_format.dart';

StreamController<String> outputController =
    StreamController<String>.broadcast();

class CodeEditorScreen extends StatefulWidget {
  final String fileName;
  const CodeEditorScreen({super.key, required this.fileName});

  @override
  _CodeEditorScreenState createState() => _CodeEditorScreenState();
}

class _CodeEditorScreenState extends State<CodeEditorScreen> {
  FilesDatabase db = FilesDatabase();
  late CodeController controller;
  bool _isShiftPressed = false;
  Process? _process;
  final TextEditingController inputController = TextEditingController();
  final FocusNode terminalFocusNode = FocusNode();
  Timer? _cursorTimer;
  bool _showCursor = true;
  String _terminalOutput = "No output yet...\n";
  String _currentInput = "";
  final ScrollController _scrollController = ScrollController();
  bool _isTerminalVisible = false; // Track terminal visibility

  void _formatCode() {
    setState(() {
      String formattedCode =
          CodeFormatter.formatCode(controller.text, widget.fileName);
      controller.text = formattedCode;
    });
  }

  @override
  void initState() {
    super.initState();
    db.loadData();
    _initializeController();

    // Create a blinking cursor timer
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });

    // Listen to the output stream and update the terminal output
    outputController.stream.listen((data) {
      setState(() {
        _terminalOutput += data;
      });
      // Scroll to the bottom of the terminal
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _cursorTimer?.cancel();
    _process?.kill();
    terminalFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeController() {
    var file = db.files.firstWhere(
      (file) => file["filename"] == widget.fileName,
      orElse: () => {"filename": widget.fileName, "content": ""},
    );

    controller = CodeController(
        text: file["content"]!,
        language: file["filename"].endsWith(".java")
            ? java
            : file["filename"].endsWith(".py")
                ? python
                : cpp);
  }

  void _saveFile() {
    int fileIndex =
        db.files.indexWhere((file) => file["filename"] == widget.fileName);
    if (fileIndex != -1) {
      db.files[fileIndex]["content"] = controller.text;
    }
    db.updateDatabase();
  }

  // Toggle terminal visibility
  void _toggleTerminal() {
    setState(() {
      _isTerminalVisible = !_isTerminalVisible;
    });
  }

  // Show the terminal when code is run
  void _showTerminalAndRun(Function runFunction) {
    setState(() {
      _isTerminalVisible = true;
    });
    runFunction();
  }

  //Function to run Python code
  Future<void> _runPythonCode() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/script.py');
      await file.writeAsString(controller.text);

      // Clear previous output
      setState(() {
        _terminalOutput = "Running Python script...\n";
        _currentInput = "";
      });

      _process?.kill();
      _process = await Process.start('python', [file.path]);
      _process!.stdout.transform(utf8.decoder).listen((data) {
        setState(() {
          _terminalOutput += data;
        });
        _scrollToBottom();
      });
      _process!.stderr.transform(utf8.decoder).listen((data) {
        setState(() {
          _terminalOutput += "Error: $data";
        });
        _scrollToBottom();
      });

      // Request focus to the terminal after running
      terminalFocusNode.requestFocus();
    } catch (e) {
      setState(() {
        _terminalOutput += "Error: $e\n";
      });
      _scrollToBottom();
    }
  }

  // Function to run Java code
  Future<void> _runJavaCode() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/script.java');
      await file.writeAsString(controller.text);

      // Clear previous output
      setState(() {
        _terminalOutput = "Running Java script...\n";
        _currentInput = "";
      });

      _process?.kill();
      _process = await Process.start('java', [file.path]);
      _process!.stdout.transform(utf8.decoder).listen((data) {
        setState(() {
          _terminalOutput += data;
        });
        _scrollToBottom();
      });
      _process!.stderr.transform(utf8.decoder).listen((data) {
        setState(() {
          _terminalOutput += "Error: $data";
        });
        _scrollToBottom();
      });

      // Request focus to the terminal after running
      terminalFocusNode.requestFocus();
    } catch (e) {
      setState(() {
        _terminalOutput += "Error: $e\n";
      });
      _scrollToBottom();
    }
  }

  // Send input to the process
  void _sendInput() {
    if (_process != null && _currentInput.isNotEmpty) {
      // First, display the input in the terminal output
      setState(() {
        _terminalOutput += "$_currentInput\n";
      });

      // Then send just the input text to the process
      _process!.stdin.writeln(_currentInput);

      // Clear the current input for the next input
      setState(() {
        _currentInput = "";
      });

      // Scroll to bottom to show the latest output
      _scrollToBottom();
    }
  }

// Function to run C code
  Future<void> _runCCode() async {
    try {
      final dir = await getTemporaryDirectory();
      final sourceFile = File('${dir.path}/script.c');
      final exeFile = File('${dir.path}/script');

      // Write code to source file
      await sourceFile.writeAsString(controller.text);

      // Clear previous output
      setState(() {
        _terminalOutput = "Compiling and running C program...\n";
        _currentInput = "";
      });

      // Kill any previous process
      _process?.kill();

      // Compile C program
      final compileProcess =
          await Process.start('gcc', [sourceFile.path, '-o', exeFile.path]);

      String compileError = '';
      compileProcess.stderr.transform(utf8.decoder).listen((data) {
        compileError += data;
      });

      final compileExitCode = await compileProcess.exitCode;
      if (compileExitCode != 0) {
        setState(() {
          _terminalOutput += "Compilation Error:\n$compileError";
        });
        _scrollToBottom();
        return;
      }

      // Run the compiled program
      _process = await Process.start(exeFile.path, [], runInShell: true);

      // Handle stdout dynamically
      _process!.stdout.transform(utf8.decoder).listen((data) {
        setState(() {
          _terminalOutput += data;
        });
        _scrollToBottom();

        // Check if C program is asking for input
        if (data.contains("Enter a number:")) {
          terminalFocusNode.requestFocus(); // Focus terminal input
        }
      });

      // Handle stderr
      _process!.stderr.transform(utf8.decoder).listen((data) {
        setState(() {
          _terminalOutput += "Error: $data";
        });
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        _terminalOutput += "Error: $e\n";
      });
      _scrollToBottom();
    }
  }

  Widget _buildTerminal() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          // Terminal header with close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Terminal',
                  style: TextStyle(color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _toggleTerminal,
                ),
              ],
            ),
          ),
          // Terminal content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Focus(
                focusNode: terminalFocusNode,
                onKeyEvent: (FocusNode node, KeyEvent event) {
                  if (event is KeyDownEvent) {
                    if (event.logicalKey == LogicalKeyboardKey.enter) {
                      // Handle Enter key
                      _sendInput();
                      return KeyEventResult.handled;
                    }

                    // Handle backspace
                    if (event.logicalKey == LogicalKeyboardKey.backspace) {
                      if (_currentInput.isNotEmpty) {
                        setState(() {
                          _currentInput = _currentInput.substring(
                              0, _currentInput.length - 1);
                        });
                      }
                      return KeyEventResult.handled;
                    }

                    // Add characters to input buffer
                    if (event.character != null &&
                        event.character!.isNotEmpty) {
                      // Filter out control characters
                      if (event.character!.codeUnitAt(0) >= 32) {
                        setState(() {
                          _currentInput += event.character!;
                        });
                        return KeyEventResult.handled;
                      }
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: GestureDetector(
                  onTap: () {
                    terminalFocusNode.requestFocus();
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _terminalOutput,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "monospace"),
                            ),
                            TextSpan(
                              text: "> $_currentInput",
                              style: const TextStyle(
                                  color: Colors.lightGreenAccent,
                                  fontSize: 14,
                                  fontFamily: "monospace"),
                            ),
                            TextSpan(
                              text: _showCursor ? "█" : "", // Blinking cursor
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: "monospace"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
              event.logicalKey == LogicalKeyboardKey.shiftRight) {
            setState(() {
              _isShiftPressed = true;
            });
          } else if (event.logicalKey == LogicalKeyboardKey.enter &&
              _isShiftPressed) {
            // Run code and show terminal when Shift+Enter is pressed
            Function runFunction = widget.fileName.endsWith(".java")
                ? _runJavaCode
                : widget.fileName.endsWith(".py")
                    ? _runPythonCode
                    : _runCCode;
            _showTerminalAndRun(runFunction);
          }
        } else if (event is KeyUpEvent) {
          if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
              event.logicalKey == LogicalKeyboardKey.shiftRight) {
            setState(() {
              _isShiftPressed = false;
            });
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.fileName),
          actions: [
            IconButton(
              icon: const Icon(Icons.format_align_left),
              tooltip: 'Format Code',
              onPressed: _formatCode,
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              tooltip: 'Save Code',
              onPressed: _saveFile,
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Run Code',
              onPressed: () {
                // Run code and show terminal when Run button is pressed
                Function runFunction = widget.fileName.endsWith(".java")
                    ? _runJavaCode
                    : widget.fileName.endsWith(".py")
                        ? _runPythonCode
                        : _runCCode;
                _showTerminalAndRun(runFunction);
              },
            ),
            // Terminal toggle button in app bar
            IconButton(
              icon: Icon(
                _isTerminalVisible ? Icons.terminal : Icons.desktop_windows,
              ),
              tooltip: _isTerminalVisible ? 'Hide Terminal' : 'Show Terminal',
              onPressed: _toggleTerminal,
            ),
          ],
        ),
        body: Column(
          children: [
            // Code editor - always visible
            CodeTheme(
              data: CodeThemeData(styles: monokaiSublimeTheme),
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: CodeField(
                    expands: true,
                    controller: controller,
                    textStyle:
                        const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),

            // Terminal at the bottom if visible
            if (_isTerminalVisible) _buildTerminal(),
          ],
        ),
      ),
    );
  }
}
