# QuestLog - RPG-Style Todo App

A command-line todo list application with RPG game mechanics. Complete quests to gain HP, abandon them to take damage!

## Overview

QuestLog transforms task management into an adventure. Every quest you complete rewards you with health points through dice rolls, while abandoning quests causes damage. Critical hits (rolling doubles) double the effect!

## Features

### Core Functionality
- ✅ **Quest Management**: Add, view, toggle, and delete quests
- 🎲 **Dice Roll Mechanics**: 2d6 rolls determine HP changes
- 💥 **Critical Hits**: Rolling doubles doubles the HP effect
- ❤️ **Health System**: 100 max HP with respawn at 50 HP on death
- 💾 **Persistence**: Auto-saves to JSON file between sessions
- 🎯 **Quest Limits**: Maximum of 100 active quests

### Advanced Features
- **Filtered Views**: 
  - `list` - Show active quests only
  - `list -all` - Show all quests
  - `list -done` - Show completed quests only
- **Smart Indexing**: All operations use storage indices
- **Health Penalties**: Invalid commands cost HP
- **Visual Health Bar**: Color-coded progress bar (🟢 🟡 🔴)

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

## Installation

1. Unzip the project folder
2. Open `QuestLog.xcodeproj` in Xcode
3. Select the "QuestLog" scheme
4. Press `Cmd+R` to build and run

## Usage

### Commands

| Command | Description | Example |
|---------|-------------|---------|
| `add` | Add a new quest | Type quest name when prompted |
| `list` | Show active quests | `list` |
| `list -all` | Show all quests | `list -all` |
| `list -done` | Show completed quests | `list -done` |
| `toggle` | Complete/uncomplete a quest | Select by index number |
| `delete` | Remove a quest | Select by index number |
| `help` | Show game rules | `help` |
| `exit` | Quit the game | `exit` |

### Game Mechanics

**Completing a Quest:**
- Roll 2d6 and gain that much HP
- Rolling doubles? CRITICAL HIT! Double the HP gained!
- Example: Roll [4, 4] = +16 HP

**Abandoning a Quest:**
- Roll 2d6 and lose that much HP
- Rolling doubles? BOTCHED! Double the damage!
- Example: Roll [3, 3] = -12 HP

**Invalid Actions:**
- Unknown command: -5 HP
- Invalid quest selection: -3 HP

**Death & Respawn:**
- Reach 0 HP and you respawn with 50 HP
- All your quests remain intact

## Testing

Run tests in Xcode:
- Switch to **QuestLogicCore** scheme
- Press `Cmd+U` to run all tests
- Or go to **Product → Test**

### Test Coverage

- ✅ Quest CRUD operations
- ✅ Health management
- ✅ Dice roll mechanics
- ✅ File system persistence

## Data Persistence

Quests and health are automatically saved to: **~/Documents/quests.json**

Future Work

Potential improvements:
• [ ] Quest priorities
• [ ] Experience points and leveling system
• [ ] Multiple character profiles
• [ ] Quest deadlines with time-based penalties
• [ ] Achievement system
• [ ] Cloud sync support
• [ ] SwiftUI GUI version

Known Limitations

• Console clearing may vary by terminal emulator
• Maximum of 100 quests to keep usable
• Single-player only 
• Health caps at 100 

Author

Created by Jonathan Sweeney as part of the iOS Nanodegree program.

License

This project is created for educational purposes as part of a course submission.

Quest on, adventurer! 🗡️⚔️🛡️
