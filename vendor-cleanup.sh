TREE=../../../vendor/sony/lilac/proprietary

# Start from a working tree that currently has the blobs (or a backup copy of it)
# Create a clean staging dir with only pinned files
rm -rf "$TREE/.pinned-stage" && mkdir -p "$TREE/.pinned-stage"

# Copy only pinned vendor files into the staging dir
rsync -a --files-from="pinned.list" \
      "$TREE/" "$TREE/.pinned-stage/"

# Replace proprietary/ with the pinned-only content
# rm -rf "$TREE/proprietary"
# mv "$TREE/.pinned-stage" "$TREE/proprietary"
