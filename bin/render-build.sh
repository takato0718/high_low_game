#!/usr/bin/env bash
set -o errexit

echo "🚀 Starting Render build process..."

# Install Ruby dependencies
echo "💎 Installing Ruby dependencies..."
bundle install

# Install Node.js dependencies if package.json exists
if [ -f "package.json" ]; then
  echo "📦 Installing Node.js dependencies..."
  echo "📍 Node version: $(node -v)"
  echo "📍 Yarn version: $(yarn -v)"
  
  # Clean install to avoid conflicts
  rm -rf node_modules yarn.lock
  yarn install
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
