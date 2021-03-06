module EmberCLI
  class BuildServer
    attr_reader :name, :options, :pid

    def initialize(name, **options)
      @name, @options = name.to_s, options
    end

    def start
      symlink_to_assets_root
      add_assets_to_precompile_list
      @pid = spawn(command)
      at_exit{ stop }
    end

    def stop
      Process.kill "INT", pid if pid
      @pid = nil
    end

    private

    def symlink_to_assets_root
      assets_path.join(name).make_symlink dist_path.join("assets")
    end

    def add_assets_to_precompile_list
      Rails.configuration.assets.precompile << /(?:\/|\A)#{name}\//
    end

    def command
      <<-CMD.squish
        cd #{app_path};
        ember build --watch --output-path #{dist_path}
      CMD
    end

    def app_path
      options.fetch(:path){ Rails.root.join("app", name) }
    end

    def dist_path
      @dist_path ||= EmberCLI.root.join("apps", name).tap(&:mkpath)
    end

    def assets_path
      @assets_path ||= EmberCLI.root.join("assets").tap(&:mkpath)
    end
  end
end
