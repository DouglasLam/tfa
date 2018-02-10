require "thor"

module TFA
  class CLI < Thor
    package_name "TFA"
    class_option :filename
    class_option :directory

    desc "add NAME SECRET", "add a new secret to the database"
    def add(name, secret)
      secret = clean(secret)
      storage.save(name, secret)
      "Added #{name}"
    end

    desc "destroy NAME", "remove the secret associated with the name"
    def destroy(name)
      storage.delete(name)
    end

    desc "show NAME", "shows the secret for the given key"
    def show(name = nil)
      name ? storage.secret_for(name) : storage.all
    end

    desc "totp NAME", "generate a Time based One Time Password using the secret associated with the given NAME."
    def totp(name = nil)
      TotpCommand.new(storage).run(name)
    end

    desc "now SECRET", "generate a Time based One Time Password for the given secret"
    def now(secret)
      TotpCommand.new(storage).run('', secret)
    end

    private

    def storage
      @storage ||= Storage.new(
        filename: options[:filename] || 'tfa',
        directory: options[:directory] || Dir.home,
      )
    end

    def clean(secret)
      if secret.include?("=")
        /secret=([^&]*)/.match(secret).captures.first
      else
        secret
      end
    end
  end
end
