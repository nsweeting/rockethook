require "kemal"

Kemal.config.port = 5000
post "/" do
  "Hello World!"
end
Kemal.run
