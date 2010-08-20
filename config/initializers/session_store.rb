# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_planetansi_session',
  :secret      => 'c99eb245c728fe9b93e2d80147f265ed5a5812efd0844cdd3242149576b94cfd2db43ac2a547738c15b7aaa060ee91bd2ab525c48de5258604f62ff56e5fbfb4'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
