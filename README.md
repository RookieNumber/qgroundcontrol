# M-Pilot Ground Control Station

By Wildan Fadillah 

clone this repository:
git clone --recursive -j8 https://gitlab.com/FullDroneSolutions/fulldronestations.git
go to the project repository then update the submodule:
git submodule update --recursive
Requirement for building desktop (windows) build:

Desktop QT 5.15.2 MSVC2019 64bit (if you run on windows system)
Desktop QT 5.15.2 GCC 64bit (if you run on ubuntu system)

the QT component needed to build this project (you can choose the requirement when installing QT):

QT Chart
Android ARMv7 (optional, used to build android)
Desktop component (stating on top of this section)

Building for windows build:

Open QT > open your project > at side menu choose Desktop QT 5.15.2 MSVC2019 64bit
Go to Build Setting > Choose your build directory
Navigate to build steps > click Details on qmake options
on Additional Arguments type "CONFIG+=installer" if you wanted to produce installer for your program
Choose release
Click Build (Hammer Icon)

Building for Android build:

Open QT > open your project > at side menu choose Android QT 5.15.2 Clang Multi Abi
Choose Release
click Build (Hammer Icon)




