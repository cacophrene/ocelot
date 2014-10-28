#! /bin/bash

OCAMLOPT="ocamlopt"
DIRS="-I +site-lib/lablgtk2 -I +cairo"
LIBS="lablgtk.cmxa cairo.cmxa cairo_lablgtk.cmxa unix.cmxa"
FLAGS="-g -w s -nodynlink -unsafe"
CMX="custom_types.cmx gUI.cmx cA.cmx draw.cmx action.cmx"
BUILDDIR="_build"
TARGET="ocelot"

cd SOURCES && \
cp *.ml *.mli "$BUILDDIR" && \
cd "$BUILDDIR" && \
echo "(Ocelot) Building custom_types.cmx" && \
$OCAMLOPT $FLAGS $DIRS -c custom_types.mli custom_types.ml && \
echo "(Ocelot) Building gUI.cmx" && \
$OCAMLOPT $FLAGS $DIRS -c gUI.mli gUI.ml && \
echo "(Ocelot) Building cA.cmx" && \
$OCAMLOPT $FLAGS $DIRS -c cA.mli cA.ml && \
echo "(Ocelot) Building draw.cmx" && \
$OCAMLOPT $FLAGS $DIRS -c draw.mli draw.ml && \
echo "(Ocelot) Building action.cmx" && \
$OCAMLOPT $FLAGS $DIRS -c action.mli action.ml && \
echo "(Ocelot) Building executable" && \
$OCAMLOPT $FLAGS $DIRS $LIBS $CMX "$TARGET.ml" -o "$TARGET" && \
mv "$TARGET" ../.. && \
cd ../.. && \
./"$TARGET" $@
