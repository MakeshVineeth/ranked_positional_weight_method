workspace "Calculate RPW - Containers" "Level 2 C4 Container Diagram for Calculate RPW." {
    model {
        engineer = person "Industrial Engineer" "Uses the calculator on phones, foldables, tablets, watches, desktop, or web browsers."

        rpwSystem = softwareSystem "Calculate RPW" "Cross-platform offline line balancing platform and documentation site." {
            nativeApp = container "Android and Windows App" "Flutter (Material 3, Dart 3.15)" "Adaptive native client running offline on Android 7+ (API 24 to 37) and Windows."
            webApp = container "Web Application" "Flutter Web (HTML/JS/Wasm)" "Client-side PWA served at the GitHub Pages root."
            docsSite = container "Docs and Privacy Portal" "MkDocs Material and Static HTML" "Hosts user guide, C4 architecture, ADRs, and Google Play privacy policy."
            localPrefs = container "On-Device Preferences" "SharedPreferencesAsync / Web Storage" "Stores light, dark, or system theme choice locally." "Store"
        }

        hostClipboard = softwareSystem "Host Clipboard" "System or browser clipboard service." "External"

        engineer -> nativeApp "Solves RPW networks offline"
        engineer -> webApp "Solves RPW networks in browser"
        engineer -> docsSite "Reads documentation and privacy policy"
        nativeApp -> localPrefs "Reads and writes theme mode"
        webApp -> localPrefs "Reads and writes theme mode"
        nativeApp -> hostClipboard "Copies formatted reports"
        webApp -> hostClipboard "Copies formatted reports"
    }

    views {
        container rpwSystem "Containers" "Container diagram for Calculate RPW." {
            include *
            autoLayout tb
        }
        styles {
            element "Person" {
                shape Person
                background #08427B
                color #FFFFFF
            }
            element "Container" {
                background #438DD5
                color #FFFFFF
            }
            element "Store" {
                shape Cylinder
                background #2E6B9E
                color #FFFFFF
            }
            element "External" {
                background #686868
                color #FFFFFF
            }
        }
    }
}
