# Acrogoop

A real-time multiplayer word game built with Phoenix LiveView where players create acronyms from randomly generated letters and vote on the best submissions.

## 🎯 Current Status: **MVP Complete**

The application is fully functional with all core features implemented and working. Players can create games, join with game codes, play rounds, submit phrases, vote, and see real-time updates.

## ✨ Features

### ✅ Implemented
- **Game Creation & Joining**: Create games with customizable settings, join with 6-character game codes
- **Real-time Multiplayer**: Live updates using Phoenix PubSub for all game state changes
- **Session Management**: Automatic session ID generation and player reconnection
- **Game Flow**: Complete game lifecycle from waiting → in progress → voting → completed
- **Timer System**: Automatic round progression with configurable time limits
- **Voting System**: Players vote on submissions (cannot vote for own)
- **Scoring**: 100 points per vote received
- **Leaderboard**: Real-time score updates and player rankings
- **Responsive UI**: Modern interface built with Tailwind CSS
- **Database**: SQLite with Ecto migrations and proper schema relationships

### 🎮 Game Mechanics
- **Rounds**: 1-10 rounds per game (configurable)
- **Round Time**: 5-60 seconds for phrase submission (configurable)
- **Voting Time**: 5-120 seconds for voting (configurable)
- **Letters**: 6 random letters generated per round
- **Minimum Players**: 3 players required to start a game
- **Phrase Validation**: Must start with the generated letters

## 🚀 Quick Start

### Prerequisites
- Elixir 1.14+
- Node.js (for asset compilation)

### Installation & Setup
```bash
# Clone the repository
git clone <repository-url>
cd acrogoop

# Install dependencies and setup database
mix setup

# Start the Phoenix server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000) to start playing!

### Development Commands
```bash
# Start server in interactive Elixir shell
iex -S mix phx.server

# Run tests
mix test

# Reset database
mix ecto.reset

# Build assets
mix assets.build
```

## 🏗️ Architecture

### Core Modules
- `Acrogoop.Games` - Main business logic context
- `Acrogoop.Game` - Game schema with states: waiting, in_progress, voting, completed
- `Acrogoop.Player` - Player schema with session-based identification
- `Acrogoop.Submission` - Player phrase submissions
- `Acrogoop.Vote` - Voting system

### LiveView Components
- `AcrogoopWeb.HomeLive` - Home page for creating/joining games
- `AcrogoopWeb.GameLive` - Main game interface with real-time updates

### Database Schema
- **Games**: Core game data, settings, and state
- **Players**: Player information with session tracking
- **Submissions**: Round-by-round phrase submissions
- **Votes**: Voting records with foreign key relationships

## 🎯 Game Flow

1. **Create Game**: Set rounds (1-10), round time (5-60s), voting time (5-30s)
2. **Join Game**: Players join with name and session ID
3. **Start Game**: Minimum 3 players required, generates random letters
4. **Submit Phrases**: Players create acronyms within time limit
5. **Vote**: Players vote on submissions (cannot vote for own)
6. **Score**: 100 points per vote received
7. **Next Round**: Continues until all rounds complete

## 🔧 Technical Details

- **Framework**: Phoenix 1.7 with LiveView
- **Database**: SQLite with Ecto
- **Real-time**: Phoenix PubSub for broadcasting
- **Styling**: Tailwind CSS
- **Assets**: esbuild for JavaScript compilation
- **Session**: Session-based player identification (no auth required)

## 📝 Development Notes

- Session management handled in router pipeline
- Game codes are 6-character random strings (A-Z)
- Timer implementation uses spawned processes with PubSub broadcasts
- Player reconnection handled via session ID matching
- All database operations use proper Ecto schemas and relationships

## 🚧 Future Enhancements

- [ ] User authentication and accounts
- [ ] Game history and statistics
- [ ] Custom word lists and themes
- [ ] Mobile app
- [ ] Social features (friends, invites)
- [ ] Tournament mode
- [ ] AI-powered phrase suggestions

## 📚 Learn More

- [Phoenix Framework](https://www.phoenixframework.org/)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/)
- [Ecto](https://hexdocs.pm/ecto/)
- [Tailwind CSS](https://tailwindcss.com/)
