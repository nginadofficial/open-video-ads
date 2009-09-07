# This is a simple script that compiles the plugin using MXMLC (free & cross-platform).
# To use, make sure you have downloaded and installed the Flex SDK in the following directory:
FLEXPATH=/Applications/flex_sdk_3

echo "Compiling JWPlayer OpenAdStreamer plugin..."
$FLEXPATH/bin/mxmlc ../src/OpenAdStreamer.as -sp ./ -o ../dist/OpenAdStreamer.swf -warnings=false -library-path ../libraries/as3corelib.swc ../libraries/JSwoof.swc ../libraries/ThunderBoltAS3_Flash.swc ../libraries/ova-vast-0.3.3.swc -use-network=false
