#! /usr/bin/env watchr

ENV["WATCHR"] = "1"
system 'clear'

def run(cmd)
  `#{cmd}`
end

def run_all_tests
  system('clear')
  result = run "cask exec ert-runner"
  puts result
end

run_all_tests
watch('(dev/)?.*.el') { run_all_tests }

# Ctrl-\
Signal.trap 'QUIT' do
  puts " --- Running all tests ---\n\n"
  run_all_tests
end

# Ctrl-C
Signal.trap 'INT' do
  abort("\n")
end
