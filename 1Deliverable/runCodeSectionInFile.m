function runCodeSectionInFile(scriptFullPath,sectionNum)
%// TIP: You can use "which('scriptName')" to obtain the full path of a 
%// script on your MATLAB path.
%%% // Temporary Workaround
import java.awt.Robot;   %// part of temporary workaround
import java.awt.event.*; %// part of temporary workaround
RoboKey = Robot;         %// part of temporary workaround
RoboKey.setAutoDelay(10);%// part of temporary workaround
%% // Test if the needed components are available (optional)
if ~matlab.desktop.editor.isEditorAvailable || ...
   ~com.mathworks.mde.editor.codepad.Codepad.isCodepadEnabled
    error('MATLAB editor is N\A');
end
%% // Open and\or switch to the script file
%// Test if script is opened:
if ~matlab.desktop.editor.isOpen(scriptFullPath) 
    scriptDoc = matlab.desktop.editor.openDocument(scriptFullPath);
else %// in case the script is open, get a handle to it, and save it:
    scriptDoc = matlab.desktop.editor.findOpenDocument(scriptFullPath);
    %// Save the script before running (optional):
    scriptDoc.save;
end
scriptDoc.goToLine(0); %// Position the cursor at the beginning of the file
                       %// NOTE1: - uses zero based indexing!
jEd = com.mathworks.mlservices.MLEditorServices.getEditorApplication ...
        .openEditorForExistingFile(java.io.File(scriptFullPath));
jEd.getTextComponent.grabFocus; drawnow; %// part of temp fix
%// NOTE2: most of the above can be replaced with:
%//   EDITOROBJ = matlab.desktop.editor.openAndGoToLine(FILENAME,LINENUM);
%% // Get the Codepad and the LineManager handles:
jCm = com.mathworks.mde.editor.codepad.CodepadActionManager ...
                   .getCodepadActionManager(jEd);
jCp = jEd.getProperty('Codepad');
jLm = jCp.getLineManager(jEd.getTextComponent,jCm);
%% // Advance to the desired section
jAc = com.mathworks.mde.editor.codepad.CodepadAction.CODEPAD_NEXT_CELL;
                                           %// 'next-cell' Action

for ind1=1:sectionNum-1 %// click "advance" several times
    %// <somehowExecute(jAc) OR jCp.nextCell() >    
    RoboKey.keyPress(KeyEvent.VK_CONTROL); %// part of temporary workaround
    RoboKey.keyPress(KeyEvent.VK_DOWN);    %// part of temporary workaround
end
RoboKey.keyRelease(KeyEvent.VK_DOWN);      %// part of temporary workaround
RoboKey.keyRelease(KeyEvent.VK_CONTROL);   %// part of temporary workaround
%% Execute section - equivalent to clicking "Run Section" once

jAc = com.mathworks.mde.editor.codepad.CodepadAction.CODEPAD_EVALUATE_CELL; 
                                                 %// 'eval-cell' Action
%// <somehowExecute(jAc); OR jCp.evalCurrentCell(true) >    
RoboKey.keyPress(KeyEvent.VK_CONTROL); %// part of temporary workaround
RoboKey.keyPress(KeyEvent.VK_ENTER);   %// part of temporary workaround
RoboKey.keyRelease(KeyEvent.VK_CONTROL);   %// part of temporary workaround
%% // Close the file (optional)
jEd.close;
%% // Return focus to the command line:
com.mathworks.mde.cmdwin.CmdWin.getInstance.grabFocus;