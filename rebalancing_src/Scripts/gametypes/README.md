reba - is a source for rebalancing game type, the file is already preprocessed.

To make a new rebalancing do:
1. Make the desired changes to reba file, to particles file and what else you plan.
2. Update mission "TestRebalancing 9.161" in reba to a new version.
3. Copy reba file to reba_X_YYY.ec. For example you build 9.161 version. The file name will be 'reba_9_162.ec'
5. Compile the reba with EarthC2160_P.bat.
    For example to compile a new 9.162 rebalancing run from rebalancing_src/Scripts:
    ..\Tools\EarthC2160_P.bat gametypes\reba 9_162

    You will need Earth 2160 SDK to run the previous command, copy EarthC2160.exe from it to Tools folder.
    We don't include it in the repository due to legal concerns.

6. Place the resulting gametype\reba_9_162.eco file in your games installation folder to 'Scripts/gametypes/Skirmish/', add other required files
7. Test and debug it
8. Use WDPackager to put reba_9_162.eco and other files into the Rebalancing9.162.wd file
9. Add Rebalancing9.162.wd to the distr folder
10. Remove gametype\reba_9_162.eco
11. Commit to this repository and push to the https://github.com/InsideEarth2160/Rebalance an updated reba files (and probably some other files) as well as Rebalancing9.162.wd
