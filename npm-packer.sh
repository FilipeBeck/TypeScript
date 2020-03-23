#! /bin/bash

IN_DIR="./built/local"
OUT_DIR="./npm-package"
LIB_DIR="$OUT_DIR/lib"
BIN_DIR="$OUT_DIR/bin"

if [ ! -d $IN_DIR ]; then
	echo "Projeto ainda não compilado. Execute \`yarn build\` primeiro."
	exit 1
fi

if [ -d $OUT_DIR ]; then
	rm -rf $OUT_DIR
fi

mkdir $OUT_DIR $LIB_DIR $BIN_DIR

for ITEM in $(ls $IN_DIR/*.ts $IN_DIR/*.js $IN_DIR/*.map); do
	if [ -f "$ITEM" ]; then
		cp $ITEM $LIB_DIR
	fi
done

TSC_FILE="$BIN_DIR/tsc"
TSSERVER_FILE="$BIN_DIR/tsserver"

touch $TSC_FILE $TSSERVER_FILE

cat <<< "#!/usr/bin/env node" >> $TSC_FILE
cat <<< "require('../lib/tsc.js')" >> $TSC_FILE
cat <<< "#!/usr/bin/env node" >> $TSSERVER_FILE
cat <<< "require('../lib/tsserver.js')" >> $TSSERVER_FILE

PACKAGE_FILE="$OUT_DIR/package.json"
PACKAGE_CONTENT="$(node -e "const package = JSON.parse(require('fs').readFileSync('./package.json', 'utf8')); package.name = 'typescript-x'; console.log(JSON.stringify(package, null, 2))")"

cat <<< $PACKAGE_CONTENT > $PACKAGE_FILE

cat <<< "Add a \`testEnvironment\` option in 'tsconfig.json' that allows access non-exported members of modules and non-public members of classes" > "$OUT_DIR/README.md."

cp AUTHORS.md CODE_OF_CONDUCT.md LICENSE.txt CopyrightNotice.txt ThirdPartyNoticeText.txt $OUT_DIR