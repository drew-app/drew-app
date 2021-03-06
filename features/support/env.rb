require 'pry'
require 'active_record'
require 'active_record/fixtures'
require 'active_support'


# Setup database connection
ActiveRecord::Base.establish_connection({ "adapter"=>"postgresql",
                                          "encoding"=>"unicode",
                                          "pool"=>"5",
                                          "database"=>"drew-app_test",
                                          "username"=>ENV['POSTGRES_USER']
                                        })

def check_stale_pid pid_file
  if File.exists?(pid_file)
    stale_pid = File.open(pid_file, 'r') { |file| file.read }.to_i
    begin
      Process.getpgid( stale_pid )

      puts "Stale PID - Killing #{stale_pid}"
      Process.kill('HUP', stale_pid)

      while true #Until an exception occurs
        Process.getpgid( stale_pid )
        sleep(1)
      end
    rescue Errno::ESRCH
      File.delete(pid_file)
    end
  end
end

check_stale_pid('server.pid')
check_stale_pid('client.pid')

unless ENV['CLEAN'] == 'false'
  `rm -r ./drew-web-client/dist/`
end

unless File.exists? './drew-web-client/dist/index.html'
  print 'Building drew-web-client... '
  result = system('yarn --cwd ./drew-web-client/ run build --mode test', out: 'out/build-test.out', err: 'out/build-err.out')
  if result
    puts 'Success'
  else
    puts 'Failed (check out/build-err.out for more info)'
    exit
  end
end

@__server_pid = spawn('BUNDLE_GEMFILE=./drew-server/Gemfile puma ./drew-server/config.ru -p 8001 -e test', out: 'out/server-test.out', err: 'out/server-err.out')
client_command = "yarn ws -d ./drew-web-client/dist/ --spa index.html"
@__client_pid = spawn(client_command, out: 'out/client-test.out', err: 'out/client-err.out')


File.open('server.pid', 'w') { |file| file.write(@__server_pid)}
File.open('client.pid', 'w') { |file| file.write(@__client_pid)}

# Brute force. :(
sleep(2)

at_exit do
  Process.kill('HUP', @__server_pid)
  File.delete('server.pid')
  Process.kill('HUP', @__client_pid)
  File.delete('client.pid')
end

After do |scenario|
  # Available scenario methods: #failed?, #passed?, and #exception
  if scenario.failed?
    errors = page.driver.browser.manage.logs.get(:browser)
    if errors.present?
      message = errors.map(&:message).join("\n")
      puts message
    end

    path = File.join("error-report", "#{scenario.__id__}.png")
    page.driver.browser.save_screenshot(path)
  end
end
