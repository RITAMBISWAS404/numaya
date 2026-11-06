# Optional offline gallery builder

`build_review_gallery.py` uses only Python's standard library. It builds an offline HTML gallery from real image paths, copies images into a portable assets folder and exports Current/A/B/C choices as JSON. It does not capture screens, inspect design quality or implement Flutter variants.

1. Copy the example schema to `review-manifest.json` in the root of the actual capture folder.
2. Replace every example value with real experiment IDs, names, rationale, capture metadata and image paths. Paths are relative to that manifest and must remain inside its folder. Add scrolling continuations to the image arrays. Never substitute reference screenshots for Numaya renders.
3. Run `python /path/to/build_review_gallery.py /path/to/review-manifest.json /path/to/gallery`.
4. Open gallery/index.html in a browser. Test filtering, selection, clearing and the JSON download, and inspect at phone and desktop width. Check every image opens.
5. Include the entire gallery directory, not just the HTML file, in the review ZIP.

Current/A/B/C are required for an experiment entry. Incomplete experiments belong in the report, not in a fabricated comparison. The script fails on missing images, duplicate experiment IDs, unsupported image extensions and paths outside the manifest directory. It preserves no choices after closing the page unless the user exports them. `USER_CHOICES.csv` is the manual fallback.

Keep shared component corrections and original Current images labeled clearly. Use refined_control_images when appropriate. This is a helper; a verified existing gallery can be extended instead.
