# ArtiBol

An example iOS app for Bol.com that showcases art using the [Artsy API](https://developers.artsy.net/docs).

---
## 🎨 Features

- **Art Catalog**  
  Infinitely scroll through a curated list of artworks.
- **Search**  
  Find your favorite artwork by keyword.
- **Detail View**  
  View extended information about a selected piece.

> **Note:**  

> Navigating from search results to an artwork’s detail endpoint may occasionally fail. Although each search result includes a `"self"` link, indexing delays and content restrictions mean that not every link will return a resource. Only a subset of artworks is exposed through the API, whereas search covers all content published on Artsy.

---
## 🚀 Running Locally

### 1. Generate the Xcode Project

This repository uses [XcodeGen](https://github.com/yonaskolb/XcodeGen) to generate the `.xcodeproj`. Any configuration changes must be made in **project.yml**, not directly in Xcode.

1. **Install XcodeGen** (if you haven’t already):  

```bash
brew install xcodegen
```

### 2. Clone this repository

### 3. Generate the project file

Navigate to the repo directory and run

```bash
xcodegen generate
```

> ⚠️ Do **not** modify the generated .xcodeproj directly. Always edit **project.yml**.

## **⚙️ Configuration**

Before running the app, update the debug configuration with your Artsy credentials:

1. Open ArtiBol/Infrastructure/Configurations/Debug/Debug.xcconfig.
2. Fill in the following keys with your Artsy **Client ID** and **Client Secret**:

```
CLIENT_ID = Your_Artsy_Client_ID
CLIENT_SECRET = Your_Artsy_Client_Secret
```
 - Obtain these credentials from [Artsy’s Client Applications page](https://developers.artsy.net/client_applications).

3. In Xcode, select the **ArtiBol-Debug** scheme.

## **▶️ Building and Running**

1. Open the generated ArtiBol.xcodeproj in Xcode.
2. Make sure the **ArtiBol-Debug** scheme is selected.
3. Choose an iOS Simulator or a physical device.
4. Hit **Run** (⌘R).
    
The app should compile and launch, showing the Art Catalog screen.

## **✅ Testing**

ArtiBol includes three types of automated tests:

1. **Unit Tests**
2. **Snapshot Tests**
    - **Important:** Snapshot tests are recorded on an **iPhone SE (3rd generation)** simulator. Running on a different device or simulator may cause mismatches. If a snapshot test fails due to a device change, re-record it.
3. **Feature Tests**

### ** Running All Tests**

In Xcode:

1. Select the **ArtiBol-Debug** scheme.    
2. Press **⌘U** or go to **Product → Test**.
3. All three test targets (Unit, Snapshot, Feature) will run in sequence.

## **📠 System Information**
•	Built and tested in Xcode 16.1 (behavior may vary on other versions
•	Running on macOS 15.4.1

## **❗ Known Issues**

- **Detail Endpoint Inconsistencies**
    - Not all search “self” links return valid resources, due to Artsy indexing delays and content restrictions. Some artwork details may fail to load.
- **Snapshot Tests on Different Devices**
    - If you switch simulators (e.g., from iPhone SE to iPhone 14), snapshot tests may fail. To fix, update or re-record the reference images.

## **🔗 Useful Links**

- [Artsy API Documentation](https://developers.artsy.net/docs)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [SnapshotTesting Library](https://github.com/pointfreeco/swift-snapshot-testing)
