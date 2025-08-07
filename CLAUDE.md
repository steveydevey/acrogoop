# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Acrogoop is a real-time multiplayer word game built with Phoenix LiveView. Players create acronyms from randomly generated letters and vote on the best submissions. The application uses Phoenix PubSub for real-time updates and SQLite for data persistence.

## 🎯 Current Status: **MVP Complete**

The application is fully functional with all core features implemented and working. The game flow is complete from creation to completion, with real-time updates, voting, scoring, and proper session management.

### ✅ What's Working
- Complete game lifecycle (create → join → play → vote → complete)
- Real-time multiplayer with Phoenix PubSub
- Session-based player management
- Timer system with automatic round progression
- Voting system with scoring
- Responsive UI with Tailwind CSS
- Database with proper Ecto schemas and relationships
- Game state management and validation

### 🚧 Areas for Enhancement
- **Testing**: No comprehensive test suite yet
- **Authentication**: Currently session-based only
- **Performance**: Could benefit from optimization
- **Features**: Many potential enhancements (see Future Enhancements section)

## Development Commands

- `mix setup` - Install dependencies, create database, run migrations, and build assets
- `mix phx.server` - Start the Phoenix server on localhost:4000
- `iex -S mix phx.server` - Start server in interactive Elixir shell
- `mix test` - Run all tests (creates test database and runs migrations)
- `mix ecto.create` - Create database
- `mix ecto.migrate` - Run database migrations
- `mix ecto.reset` - Drop, recreate, and seed database
- `mix deps.get` - Install Elixir dependencies
- `mix compile` - Compile the application

### Asset Commands

- `mix assets.setup` - Install Tailwind and esbuild if missing
- `mix assets.build` - Build assets with Tailwind and esbuild
- `mix assets.deploy` - Build and minify assets for production

## Architecture

### Core Modules

- `Acrogoop.Games` - Main business logic context for game operations
- `Acrogoop.Game` - Game schema with states: waiting, in_progress, voting, completed
- `Acrogoop.Player` - Player schema with session-based identification
- `Acrogoop.Submission` - Player phrase submissions for each round
- `Acrogoop.Vote` - Voting system for submissions

### LiveView Components

- `AcrogoopWeb.HomeLive` - Home page for creating/joining games
- `AcrogoopWeb.GameLive` - Main game interface with real-time updates
- Routes: `/` (home), `/game/:code` (game room)

### Real-time Features

- Uses Phoenix.PubSub for broadcasting game state changes
- Session-based player identification (no authentication required)
- Timer-based round progression with automatic state transitions
- Real-time score updates and leaderboard

### Database

- SQLite database with Ecto migrations in `priv/repo/migrations/`
- UUID primary keys for all schemas
- Foreign key relationships between games, players, submissions, and votes
- Recent migration added ready fields for enhanced game flow

## Game Flow

1. **Game Creation**: Creator sets rounds (1-10), round time (5-60s), voting time (5-30s)
2. **Player Joining**: Players join with name and session ID
3. **Game Start**: Minimum 3 players, generates random letters
4. **Round Play**: Players submit acronym phrases within time limit
5. **Voting**: Players vote on submissions (cannot vote for own)
6. **Scoring**: 100 points per vote received
7. **Next Round**: Continues until all rounds complete

## Key Implementation Notes

- Session management handled in router pipeline with `ensure_session_id/2`
- Game codes are 6-character random strings (A-Z)
- Random letters generated for each round (6 letters by default)
- Timer implementation uses spawned processes with PubSub broadcasts
- Player reconnection handled via session ID matching
- Phrase validation ensures submissions start with generated letters
- Ready system implemented for better game flow control

## Development Priorities

### High Priority
1. **Testing**: Implement comprehensive test suite
   - Unit tests for Games context
   - LiveView tests for game flow
   - Integration tests for real-time features
2. **Error Handling**: Improve error handling and user feedback
3. **Performance**: Optimize database queries and real-time updates

### Medium Priority
1. **Authentication**: Add user accounts and authentication
2. **Game History**: Store and display past games
3. **Statistics**: Player stats and leaderboards
4. **Mobile Optimization**: Improve mobile experience

### Low Priority
1. **Advanced Features**: Custom word lists, themes, tournaments
2. **Social Features**: Friends, invites, chat
3. **AI Integration**: Phrase suggestions and analysis

## Code Quality Guidelines

- Follow Elixir best practices and style guide
- Use proper Ecto schemas and relationships
- Implement proper error handling
- Add comprehensive documentation
- Write tests for new features
- Use LiveView patterns for real-time updates
- Keep UI responsive and accessible

## Common Patterns

### Real-time Updates
```elixir
# Subscribe to game updates
PubSub.subscribe(Acrogoop.PubSub, "game:#{code}")

# Broadcast updates
PubSub.broadcast(Acrogoop.PubSub, "game:#{code}", {:game_updated, game})
```

### Session Management
```elixir
# Generate session ID
session_id = :crypto.strong_rand_bytes(16) |> Base.encode64()

# Store in session
put_session(conn, :session_id, session_id)
```

### Timer Implementation
```elixir
# Start timer process
spawn(fn -> 
  Process.sleep(time_limit * 1000)
  PubSub.broadcast(Acrogoop.PubSub, "game:#{code}", :time_up)
end)
```

## Troubleshooting

### Common Issues
- **Database locked**: Kill existing processes, restart server
- **Session issues**: Clear browser data, check session ID generation
- **Real-time not working**: Verify PubSub configuration
- **Assets not loading**: Run `mix assets.build`

### Debug Commands
```elixir
# In IEx console
iex> Acrogoop.Games.list_games()
iex> Acrogoop.Games.get_game_by_code("ABC123")
iex> Acrogoop.Repo.all(Acrogoop.Game)
```