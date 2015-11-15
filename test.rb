#!/usr/bin/env ruby
# coding: utf-8

require 'fluent-logger'
require 'logger'

# 1. setup client fluentd which forward log to server fluentd forever
spawn("bundle", "exec", "fluentd", "-c", "client.conf",
  out: "/dev/null", err: "/dev/null")

sleep 1
if !fork
  # 2. post log to client fluentd forever
  log = Fluent::Logger::FluentLogger.new(
    nil, host: "127.0.0.1", port: 10000, logger: Logger.new("/dev/null")
  )
  loop do
    ok = log.post("hoge", {message: "x" * 1000})
    sleep 0.001
  end
  exit
end


# 3. server fluentd repeats restart forever
loop do
  warn "==> start new server fluentd"
  pid = spawn("bundle", "exec", "fluentd", "-c", "server.conf")
  sleep 5
  Process.kill "TERM", pid
  Process.waitpid pid
end
