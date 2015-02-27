SNACKPACK_APP_ROOT = ENV["SNACKPACK_APP_ROOT"]

working_directory SNACKPACK_APP_ROOT

pid File.join(SNACKPACK_APP_ROOT, "pids/unicorn.pid")

stderr_path File.join(SNACKPACK_APP_ROOT, "log/unicorn.stderr")
stdout_path File.join(SNACKPACK_APP_ROOT, "log/unicorn.stdout")

# Unicorn socket
listen "/tmp/unicorn.snackpack.sock"
listen "/tmp/unicorn.myapp.sock"

worker_processes 4

timeout 30
