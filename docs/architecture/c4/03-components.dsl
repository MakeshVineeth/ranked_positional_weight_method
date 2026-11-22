workspace "Calculate RPW - Components" "Level 3 C4 Component Diagram inside the Flutter Client Container." {
    model {
        engineer = person "Industrial Engineer" "Interacts with adaptive screens across window sizes."
        localStorage = softwareSystem "Platform Key-Value Store" "SharedPreferences / browser localStorage." "External"
        hostClipboard = softwareSystem "Host Clipboard" "Platform clipboard API." "External"

        rpwSystem = softwareSystem "Calculate RPW" "Offline RPW line balancing application." {
            clientApp = container "Flutter Client Application" "Dart 3.15 & Material 3" "Platform-agnostic application container." {
                serviceLocator = component "ServiceLocator" "Singleton Pattern" "Wires dependencies and resets cleanly in tests."
                appRouter = component "AppRouter" "go_router" "Routes between /, /help, and /privacy branches."
                adaptiveShell = component "AdaptiveShell" "Responsive UI" "Chooses Wear layout, NavigationBar, NavigationRail, or Foldable split."
                calcViewModel = component "CalculatorViewModel" "ChangeNotifier (MVVM)" "Holds Guided and Quick Text input state and exposes outputs."
                themeRepo = component "ThemeRepository" "Repository" "Persists and notifies ThemeMode changes."
                inputValidator = component "RpwInputValidator" "Pure Dart" "Enforces OWASP allowlists, bounds, and token parsing."
                rpwSolver = component "HelgesonBirnieRpwSolver" "Strategy Pattern" "Validates DAGs, builds arrow chains, ranks RPWs, assigns stations."
                outputComposer = component "RpwOutputComposer" "Composite Builder" "Constructs ResultGroup/ResultItem tree and plain-text report."
                sampleFactory = component "SampleProblemFactory" "Factory Pattern" "Creates built-in assembly line presets."
                prefsService = component "PreferencesStorageService" "Data Service" "Wraps SharedPreferencesAsync."
                clipboardService = component "FlutterClipboardService" "Data Service" "Wraps Flutter Clipboard."
            }
        }

        engineer -> adaptiveShell "Interacts with calculator, help, and privacy screens"
        adaptiveShell -> appRouter "Switches active navigation branch"
        adaptiveShell -> themeRepo "Cycles theme mode"
        adaptiveShell -> calcViewModel "Submits inputs, samples, clear, and copy requests"
        serviceLocator -> calcViewModel "Provides validator, solver, composer, and clipboard"
        serviceLocator -> themeRepo "Provides storage service"
        calcViewModel -> inputValidator "Validates raw fields and lines"
        calcViewModel -> rpwSolver "Executes RPW calculation"
        calcViewModel -> outputComposer "Builds Composite UI sections and text report"
        calcViewModel -> sampleFactory "Loads sample RpwInput datasets"
        calcViewModel -> clipboardService "Copies report or item text"
        rpwSolver -> inputValidator "Validates graph structure and limits"
        themeRepo -> prefsService "Reads and saves theme choice"
        prefsService -> localStorage "Persists key-value data"
        clipboardService -> hostClipboard "Writes clipboard data"
    }

    views {
        component clientApp "Components" "Component diagram inside the Flutter Client Application." {
            include *
            autoLayout tb
        }
        styles {
            element "Component" {
                background #85BBF0
                color #000000
            }
            element "External" {
                background #686868
                color #FFFFFF
            }
        }
    }
}
