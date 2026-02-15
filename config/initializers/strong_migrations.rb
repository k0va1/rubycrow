# Mark existing migrations as safe
StrongMigrations.start_after = 0

# Set timeouts for migrations
StrongMigrations.lock_timeout = 10.seconds
StrongMigrations.statement_timeout = 1.hour

# Analyze tables after indexes are added
StrongMigrations.auto_analyze = true
