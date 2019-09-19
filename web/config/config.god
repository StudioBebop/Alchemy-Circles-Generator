# God configuration

APP_ROOT = File.expand_path '../', File.dirname(__FILE__)

God.watch do |w|
  w.name = "alchemy_circles"
  w.interval = 30.seconds # default

  w.start = "cd #{APP_ROOT} && unicorn -c #{APP_ROOT}/config/unicorn.rb -D"

  # -QUIT = graceful shutdown, waits for workers to finish their current request before finishing
  w.stop = "kill -QUIT `cat #{APP_ROOT}/tmp/unicorn.pid`"

  w.restart = "kill -USR2 `cat #{APP_ROOT}/tmp/unicorn.pid`"

  w.start_grace = 10.seconds
  w.restart_grace = 10.seconds
  w.pid_file = "#{APP_ROOT}/tmp/unicorn.pid"

  # User under which to run the process
  w.uid = 'brandon'
  w.gid = 'brandon'

  # Cleanup the pid file (this is needed for processes running as a daemon)
  w.behavior(:clean_pid_file)

  # Conditions under which to start the process
  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.interval = 5.seconds
      c.running = false
    end
  end

  # Conditions under which to restart the process
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      c.above = 250.megabytes
      c.times = [3, 5] # 3 out of 5 intervals
    end

    restart.condition(:cpu_usage) do |c|
      c.above = 50.percent
      c.times = 5
    end
  end

  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end
