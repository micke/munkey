require_relative "../../lib/monitor_worker"

unless defined? Rails::Console
  WORKER_LOG_FILE = File.open(Rails.root.join("log/worker.log"), "a+")
  WORKER_LOG_FILE.sync = true
  WORKER_LOG = Logger.new(WORKER_LOG_FILE)
  worker = MonitorWorker.new(BOT, WORKER_LOG)
  MONITORING_TASK = Concurrent::TimerTask.new(execution_interval: 10, timeout_interval: 5) do
    worker.work!
  end
  MONITORING_TASK.execute
end
