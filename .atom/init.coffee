# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
# An example hack to log to the console when each text editor is saved.
#
# atom.workspace.observeTextEditors (editor) ->
#   editor.onDidSave ->
#     console.log "Saved! #{editor.getPath()}"

try
  childProcess = require('child_process');

  console.log("Fixing paths for Atom")
  process.env.PATH = childProcess.execFileSync('/bin/bash', ['-l', '-c', 'echo $PATH']).toString().trim();

catch exception
  console.error("Exception during PATH fixes: #{exception}");
