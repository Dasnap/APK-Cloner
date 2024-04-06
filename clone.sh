#!/bin/bash

# Check if correct arguments are passed
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <apk-file>"
    exit 1
fi

APK_FILE=$1
DECOMPILED_DIR="decompiled"
NEW_APK_FILE="copy.apk"
KEYSTORE_FILE="key.keystore"
KEY_ALIAS="alias"
KEY_PASS="c5wt554G%CGGC%4cg54cg5cg"
KEY_VALIDITY=10000

echo "Decompile the APK"
apktool d $APK_FILE -o $DECOMPILED_DIR

echo "Get the old package name"
# OLD_PACKAGE_NAME=$(grep 'package=' $DECOMPILED_DIR/AndroidManifest.xml | cut -d '"' -f 2)
# OLD_PACKAGE_NAME=$(grep 'package=".*"' $DECOMPILED_DIR/AndroidManifest.xml | cut -d '"' -f 2)

# Read the file line by line
while IFS= read -r line
do
  # Check if the line contains 'package='
  if [[ $line == *"package="* ]]; then
    # Extract the value of package
    OLD_PACKAGE_NAME=$(echo $line | sed -n 's/.*package="\([^"]*\)".*/\1/p')
    echo "Package value is: $OLD_PACKAGE_NAME"
  fi
done < "$DECOMPILED_DIR/AndroidManifest.xml"

echo "Get the last character of the package name"
LAST_CHAR=${OLD_PACKAGE_NAME: -1}

echo "Increment the last character by one place in the alphabet"
NEW_LAST_CHAR=$(echo "$LAST_CHAR" | tr "0-9a-z" "1-9a-z_")

echo "Generate the new package name"
NEW_PACKAGE_NAME="${OLD_PACKAGE_NAME%?}$NEW_LAST_CHAR"

echo "Old package name = $OLD_PACKAGE_NAME"
echo "New package name = $NEW_PACKAGE_NAME"

# echo "Replace the old package name with the new one in all files"
# find $DECOMPILED_DIR -type f -exec sed -i "s/$OLD_PACKAGE_NAME/$NEW_PACKAGE_NAME/g" {} \;

echo "Replace the old package name with the new one in all files"
find $DECOMPILED_DIR -type f -exec sed -i "s/$OLD_PACKAGE_NAME/$NEW_PACKAGE_NAME/g" {} \;

echo "Build the APK"
apktool b $DECOMPILED_DIR -o $NEW_APK_FILE

echo "Check if a key with the same alias already exists"
if keytool -list -keystore $KEYSTORE_FILE -alias $KEY_ALIAS > /dev/null 2>&1; then
    echo "A key with the alias $KEY_ALIAS already exists in the keystore. Please enter a new alias:"
    read KEY_ALIAS
fi

echo "Generate a keystore"
keytool -genkey -v -keystore $KEYSTORE_FILE -alias $KEY_ALIAS -keyalg RSA -keysize 2048 -validity $KEY_VALIDITY -storepass $KEY_PASS -keypass $KEY_PASS -dname "CN=, OU=, O=, L=, S=, C="

echo "Sign the APK"
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $KEYSTORE_FILE -storepass $KEY_PASS -keypass $KEY_PASS $NEW_APK_FILE $KEY_ALIAS

# rm -r decompiled
# rm key.keystore

# echo "Done. The new APK is $NEW_APK_FILE"
