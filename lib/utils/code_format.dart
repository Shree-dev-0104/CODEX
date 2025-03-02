// Multi-language code formatter for Python, Java, and C/C++
class CodeFormatter {
  // Main entry point - format code based on file extension
  static String formatCode(String code, String fileName) {
    if (fileName.endsWith('.py')) {
      return formatPythonCode(code);
    } else if (fileName.endsWith('.java')) {
      return formatJavaCode(code);
    } else if (fileName.endsWith('.c') || fileName.endsWith('.cpp') || fileName.endsWith('.h')) {
      return formatCCode(code);
    } else {
      // Default to basic formatting for other languages
      return formatBasicCode(code);
    }
  }

  // Python-specific formatter
  static String formatPythonCode(String code) {
    List<String> lines = code.split('\n');
    List<String> formattedLines = [];
    int indentLevel = 0;
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      
      // Skip empty lines
      if (line.isEmpty) {
        formattedLines.add('');
        continue;
      }
      
      // Decrease indent for lines with only closing brackets
      if (line.startsWith(')') || line.startsWith(']') || line.startsWith('}')) {
        indentLevel = indentLevel > 0 ? indentLevel - 1 : 0;
      }
      
      // Add proper indentation
      String indentation = '    ' * indentLevel; // Python uses 4 spaces by convention
      formattedLines.add('$indentation$line');
      
      // Adjust indent level for the next line
      if (line.endsWith(':')) {
        // Python blocks start after colon
        indentLevel++;
      } else if (line.endsWith('(') || line.endsWith('[') || line.endsWith('{')) {
        // Open brackets increase indent
        indentLevel++;
      } else if (line.contains(')') || line.contains(']') || line.contains('}')) {
        // Check for closing brackets that might decrease indent
        int openCount = _countChar(line, '(') + _countChar(line, '[') + _countChar(line, '{');
        int closeCount = _countChar(line, ')') + _countChar(line, ']') + _countChar(line, '}');
        
        if (closeCount > openCount) {
          indentLevel = indentLevel > (closeCount - openCount) ? indentLevel - (closeCount - openCount) : 0;
        }
      }
    }
    
    return formattedLines.join('\n');
  }

  // Java-specific formatter
  static String formatJavaCode(String code) {
    List<String> lines = code.split('\n');
    List<String> formattedLines = [];
    int indentLevel = 0;
    bool inComment = false;
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      
      // Skip empty lines
      if (line.isEmpty) {
        formattedLines.add('');
        continue;
      }
      
      // Handle multi-line comments
      if (line.contains('/*') && !line.contains('*/')) {
        inComment = true;
      }
      if (line.contains('*/')) {
        inComment = false;
      }
      
      // Adjust indent for braces
      if (line.startsWith('}') || line.startsWith(')')) {
        indentLevel = indentLevel > 0 ? indentLevel - 1 : 0;
      }
      
      // Add proper indentation
      String indentation = '    ' * indentLevel; // Use 4 spaces for Java
      formattedLines.add('$indentation$line');
      
      // Don't adjust indent level inside comments
      if (!inComment) {
        // Special case for else statements (don't increase indent)
        if (line.startsWith('else') && line.endsWith('{')) {
          // Keep same indent level
        } else if (line.endsWith('{')) {
          indentLevel++;
        }
        
        // Handle one-line if statements without braces
        if ((line.startsWith('if') || line.startsWith('else if') || 
             line.startsWith('for') || line.startsWith('while')) && 
            !line.endsWith('{') && !line.contains('{')) {
          indentLevel++;
        }
      }
    }
    
    return formattedLines.join('\n');
  }

  // C/C++ formatter
  static String formatCCode(String code) {
    List<String> lines = code.split('\n');
    List<String> formattedLines = [];
    int indentLevel = 0;
    bool inComment = false;
    bool inPreprocessor = false;
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      
      // Skip empty lines
      if (line.isEmpty) {
        formattedLines.add('');
        continue;
      }
      
      // Handle preprocessor directives - no indent for them
      if (line.startsWith('#')) {
        formattedLines.add(line);
        inPreprocessor = line.endsWith('\\');
        continue;
      }
      
      // Continue preprocessor lines
      if (inPreprocessor) {
        formattedLines.add(line);
        inPreprocessor = line.endsWith('\\');
        continue;
      }
      
      // Handle multi-line comments
      if (line.contains('/*') && !line.contains('*/')) {
        inComment = true;
      }
      if (line.contains('*/')) {
        inComment = false;
      }
      
      // Adjust indent for braces and parentheses in control structures
      if (line.startsWith('}') || line.startsWith(')')) {
        indentLevel = indentLevel > 0 ? indentLevel - 1 : 0;
      }
      
      // Add proper indentation (except for preprocessor directives)
      String indentation = '    ' * indentLevel; // Use 4 spaces for C/C++ too
      formattedLines.add('$indentation$line');
      
      // Don't adjust indent level inside comments
      if (!inComment) {
        // Handle inline comments
        String codePart = line;
        if (line.contains('//')) {
          codePart = line.substring(0, line.indexOf('//'));
        }
        
        // Special handling for code with opening braces
        if (codePart.contains('{')) {
          indentLevel++;
        }
        
        // Handle one-line control statements without braces
        if ((codePart.startsWith('if') || codePart.startsWith('else if') || 
             codePart.startsWith('for') || codePart.startsWith('while')) && 
             !codePart.contains('{')) {
          indentLevel++;
        }
        
        // Handle case statements
        if (codePart.startsWith('case') || codePart.startsWith('default')) {
          // Case statements have special indentation in switch blocks
        }
      }
    }
    
    return formattedLines.join('\n');
  }
  
  // Basic formatter for other languages
  static String formatBasicCode(String code) {
    List<String> lines = code.split('\n');
    List<String> formattedLines = [];
    int indentLevel = 0;
    
    for (int i = 0; i < lines.length; i++) {
      String line = lines[i].trim();
      
      // Skip empty lines
      if (line.isEmpty) {
        formattedLines.add('');
        continue;
      }
      
      // Decrease indent for closing brackets
      if (line.startsWith('}') || line.startsWith(')') || line.startsWith(']')) {
        indentLevel = indentLevel > 0 ? indentLevel - 1 : 0;
      }
      
      // Add proper indentation
      String indentation = '  ' * indentLevel; // Use 2 spaces for generic code
      formattedLines.add('$indentation$line');
      
      // Increase indent after opening brackets
      if (line.endsWith('{') || line.endsWith('(') || line.endsWith('[')) {
        indentLevel++;
      }
    }
    
    return formattedLines.join('\n');
  }
  
  // Helper function to count characters in a string
  static int _countChar(String str, String char) {
    return str.split(char).length - 1;
  }
}