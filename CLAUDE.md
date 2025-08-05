# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Acrogoop is a real-time multiplayer word game built with Phoenix LiveView. Players create acronyms from randomly generated letters and vote on the best submissions. The application uses Phoenix PubSub for real-time updates and SQLite for data persistence.

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