
GETTING STARTED WITH Homer2_UI AND AtlasViewerGUI


============================================
Running Homer2_UI and AtlasViewerGUI from 
Matlab 
============================================

  1) Required Matlab toolboxes: 

     Homer2_UI

       Signal Processing Toolbox
       Symbolic Math Toolbox
       Image Processing Toolbox
       Statistics Toolbox
       Wavelet Toolbox
       Curve Fitting Toolbox

     AtlasViewerGUI

       Image Processing Toolbox
       Simulink
       Control System Toolbox

  2) Download homer2 source code release file from the Homer2 web page
     on www.nitrc.org. Unzip the homer2 file. 

  3) Open Matlab and in the command window, change the current folder to 
     the homer2 root folder that you just downloaded and unzipped.

  4) In Matlab command window, type 

     >> setpaths
     
     This will set all the required matlab search paths for Homer2 and 
     AtlasViewer. 

     Note: this step should be done every time you start a new matlab 
     session. 
  
  5) To start either application, type Homer2_UI or AtlasViewerGUI, on 
     the command line. 


============================================
Running Homer2_UI and AtlasViewerGUI 
standalone. 
============================================
  
  Before you can run Homer2_UI and AtlasViewerGUI standalone, you have 
  to install the executable files for these applications. 

  In addition to that installation you have to download and install 
  the MATLAB Runtime. The MATLAB Runtime is a standalone set of shared 
  libraries that enables the execution of compiled MATLAB applications 
  on computers that do not have MATLAB installed. Without this installation, 
  the Homer2_UI and AtlasViewerGUI executables will NOT work. 

  The following is installation instructions for Homer2_UI and 
  AtlasViewerGUI executables and MATLAB Runtime:

  For Windows
  -----------
  
  1) Install MATLAB Runtime to be able to run Matlab applications. To do 
     this download Matlab Compiler Runtime R2016a (9.0.1) 64-bit for Windows 
     at the following URL:
  
        https://www.mathworks.com/products/compiler/mcr/
  
  
  2) When it finishes downloading, install it on your PC by 
     double-clicking on the downloaded file. 

     NOTE: You will need administrator rights to run MCRInstaller. 

  
  3) Download the 'homer2_install_win.zip' file to the Downloads folder 
     onyour MAC for the Homer2 web page on www.nitrc.org.
  
  4) Unzip 'homer2_instal_win.zip'
  
      a) Open Finder and go into the Downloads folder.
      b) Double click on the 'homer2_install_win.zip' to unzip it.
  
  
  5) To run the installation
  
      a) In Windows Explorer ( XP / 7 ) or File Explorer ( 8 / 10 ) go to 
         the just unzipped homer2_install folder.

      b) Double-click on the setup.bat file.
  
  6) Once installation finishes, you should have 2 new icons on your
     desktop:
  
      Homer2_UI.exe
      AtlasViewerGUI.exe
  
  Double click on either one to run it.
  
  
  For MAC and Linux
  -----------------
  
  NOTE: These instructions are for MAC but they apply equally to Linux, 
  just substitute linux in all places where mac is used. 
  
  1) Install MATLAB Runtime to be able to run Matlab applications. To do this
     download Matlab Runtime R2016a (9.0.1) 64-bit for Mac at the following
     address:
  
       https://www.mathworks.com/products/compiler/mcr/
  
  
  2) When it finishes downloading, install it on your Mac by double-clicking 
     on the downloaded file. When asked for the installation folder, keep
     it as is, that is,
  
       /Applications/MATLAB/MATLAB_Runtime.
  
  3) Download the 'homer2_install_mac.zip' file to the Downloads folder on
     your MAC.
  
  4) Download the ‘homer2_install_v2_2_mac_03132017.zip’ file to the 
     Downloads folder on your MAC.

  5) IMPORTANT: Open the MAC application 'Finder' and go into the Downloads 
     folder (or which ever folder contains the homer2 zip file) and make 
     sure there is no folder there named homer2_install (for example, from 
     previous homer2 installations). If there is, rename or delete it. The 
     point is to have no folders named homer2_install in the folder with 
     the zip file, before going to the next step.

  6) Unzip ‘homer2_install_v2_2_mac_03132017.zip’.

      a) Again in Finder, go in the Downloads folder (or which ever folder 
         contains the homer2 zip file).
      b) Double click on the “homer2_install_v2_2_mac_03132017.zip” to 
         unzip it.

  7) To run the installation

      a) In Finder go to the just unzipped homer2_install folder.
      b) Double-click on the setup.command file.

  8) Once installation finishes, you should have 2 new icons on your 
     desktop:

      Homer2_UI.command
      AtlasViewerGUI.command

     Double click on either one to run it.

