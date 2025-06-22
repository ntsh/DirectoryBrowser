# DirectoryManager

`DocumentsStore` provides an observable model for working with files stored in a directory. It can load, sort and modify `Document` objects.

## Loading Files

```swift
let store = DocumentsStore(root: .documentsDirectory)
store.loadDocuments()
print(store.documents)
```

## Creating Folders and Importing Files

```swift
let newFolder = try store.createNewFolder()
let imported = store.importFile(from: someURL)
```

## Renaming and Deleting

```swift
try store.rename(document: newFolder, newName: "Photos")
store.delete(imported)
```

`DocumentsStore` also supports sorting with `SortOption`:

```swift
store.setSorting(.name(ascending: true))
```
