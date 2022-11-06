FILEBROWSER_TYPE_PARENT <- "parent"
FILEBROWSER_TYPE_DIR <- "dir"
FILEBROWSER_TYPE_FILE <- "file"
FILEBROWSER_TYPES <- c(FILEBROWSER_TYPE_PARENT, FILEBROWSER_TYPE_DIR, FILEBROWSER_TYPE_FILE)
FILEBROWSER_CSS <-
  ".shiny-file-browser { overflow: auto; border: 1px solid #ddd; padding: 0.5rem; user-select: none; font-size: 1.1em; }
  .shiny-file-browser .current-wd .current-wd-breadcrumbs { padding: 0.3rem 0; display: flex; align-items: center; }
  .shiny-file-browser .current-wd .file-breadcrumb { white-space: nowrap; padding: 0 0.2em; border-radius: 5px; transition: background 0.3s; }
  .shiny-file-browser .current-wd .file-breadcrumb-clickable { cursor: pointer; }
  .shiny-file-browser .current-wd .file-breadcrumb-clickable:hover { background: #f6f6f6; }
  .shiny-file-browser .current-wd .file-breadcrumb-clickable:active { background: #ccc; }
  .shiny-file-browser .current-wd .file-breadcrumb-separator { color: #b5b5b5; margin: 0 0.1em; }
  .shiny-file-browser .file-list { padding: 0 0.1rem; }
  .shiny-file-browser .file-row { display: flex; cursor: pointer; transition: background 0.3s; }
  .shiny-file-browser .file-row:hover { background: #f6f6f6; }
  .shiny-file-browser .file-row:active { background: #ccc; }
  .shiny-file-browser .file-icon { margin-right: 2rem; }
  .shiny-file-browser .file-type-dir .file-contents,
  .shiny-file-browser .file-type-parent .file-contents { font-weight: bold; padding-left: 0.2em; }
  .shiny-file-browser .file-meta { font-style: italic; }"
