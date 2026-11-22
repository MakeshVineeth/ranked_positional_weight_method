workspace "Calculate RPW - System Context" "Level 1 C4 System Context for Calculate RPW." {
    model {
        engineer = person "Industrial Engineer" "Models precedence networks, task times (Tek), and cycle time targets."
        rpwSystem = softwareSystem "Calculate RPW" "Offline assembly line balancing application using the Ranked Positional Weight method."
        clipboard = softwareSystem "Host Clipboard" "Operating system or browser clipboard receiving copied results." "External"
        localStorage = softwareSystem "Device Preferences Storage" "On-device key-value store persisting selected theme mode." "External"

        engineer -> rpwSystem "Enters precedence graph, views balanced workstations, and reads help guide"
        rpwSystem -> clipboard "Copies single result items or full text reports on user tap"
        rpwSystem -> localStorage "Saves and loads theme preference locally"
    }

    views {
        systemContext rpwSystem "SystemContext" "System Context diagram for Calculate RPW." {
            include *
            autoLayout lr
        }
        styles {
            element "Person" {
                shape Person
                background #08427B
                color #FFFFFF
            }
            element "Software System" {
                background #1168BD
                color #FFFFFF
            }
            element "External" {
                background #686868
                color #FFFFFF
            }
        }
    }
}
