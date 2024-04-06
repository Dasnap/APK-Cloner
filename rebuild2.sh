#!/bin/bash

# Create a keystore using keytool (you'll need to replace 'myKeystore.jks', 'myAlias', and 'myPassword' with your actual keystore information)
# keytool -genkey -v -keystore myKeystore.jks -alias myAlias -keyalg RSA -keysize 2048 -validity 10000 -storepass myPassword

# Decompile the APK
apktool d myApp.apk

# Rename the package (you'll need to replace 'myOldPackageName' and 'myNewPackageName' with your actual package names)
find ./ -type f -name "*.smali" -exec sed -i 's/com.teamsmart.videomanager.tv/com.teamsmart.videomanager.tq/g' {} \\;
find ./ -type f -name "AndroidManifest.xml" -exec sed -i 's/com.teamsmart.videomanager.tv/com.teamsmart.videomanager.tq/g' {} \\;

sed -i 's/renameManifestPackage: null/renameManifestPackage: com.teamsmart.videomanager.tq/g' myApp/apktool.yml

# Rebuild the APK
apktool b myApp

# Sign the APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore myKeystore.jks myApp/dist/myApp.apk myAlias -storepass myPassword
