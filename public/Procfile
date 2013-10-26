web:          bundle exec unicorn -p $PORT -E $RACK_ENV
sidekiq:      bundle exec sidekiq -q default
sidekiq_web:  bundle exec rackup sidekiq.ru -s thin -p 9292 -E $RACK_ENV
faye:         bundle exec rackup faye.ru -s thin -p 9229 -E $RACK_ENV
