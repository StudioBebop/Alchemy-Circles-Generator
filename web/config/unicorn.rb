# Unicorn configuration file

APP_ROOT = File.expand_path '../', File.dirname(__FILE__)

worker_processes 32
#worker_processes 16
timeout 20

preload_app true

pid "#{APP_ROOT}/tmp/unicorn.pid"

listen "#{APP_ROOT}/tmp/unicorn.sock", :backlog => 2048

stderr_path "#{APP_ROOT}/log/unicorn.stderr.log"
stdout_path "#{APP_ROOT}/log/unicorn.stdout.log"

before_fork do |server, worker|
  old_pid = "#{APP_ROOT}/tmp/unicorn.pid.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end
