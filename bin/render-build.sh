#!/usr/bin/env bash
set -o errexit

echo "🚀 Starting Render build process..."

# Install Ruby dependencies
echo "💎 Installing Ruby dependencies..."
bundle install

# Install Node.js dependencies if package.json exists
if [ -f "package.json" ]; then
  echo "📦 Installing Node.js dependencies..."
  echo "📍 Node version: $(node -v 2>/dev/null || echo 'Node.js not found')"
  
  # Install with compatibility flags
  yarn install --frozen-lockfile=false
else
  echo "📦 No package.json found, skipping Node.js dependencies"
fi

# Precompile assets
echo "🎨 Precompiling assets..."
RAILS_ENV=production bundle exec rails assets:precompile

# Run database migrations
echo "🗄️ Running database migrations..."
bundle exec rails db:migrate

echo "✅ Build completed successfully!"
