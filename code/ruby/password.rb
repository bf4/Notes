# https://github.com/snusnu/subway/blob/master/lib/subway/password.rb
# encoding: utf-8

module Subway

  # Provides password encryption using bcrypt
  class Password

    include Concord.new(:bcrypt_password)
    include Adamantium

    DEFAULT_COST = 10

    def self.create(plaintext, cost = DEFAULT_COST)
      new(BCrypt::Password.create(plaintext, :cost => cost))
    end

    def self.coerce(ciphertext)
      new(BCrypt::Password.new(ciphertext))
    end

    def self.match?(plaintext, ciphertext)
      coerce(ciphertext).match?(plaintext)
    end

    def match?(password)
      @bcrypt_password == password
    end

    def to_s
      @bcrypt_password.to_s
    end

  end # class Password
end # module Subway
