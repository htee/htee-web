class Stream < ActiveRecord::Base
  after_initialize :init

  belongs_to :user

  enum status: {
    :created => 0,
    :opened  => 1,
    :closed  => 2,
    :gisted  => 3,
  }

  def init
    self.name ||= SecureRandom.hex(10)
    self.name = self.name.parameterize
  end

  def owner
    user.login
  end

  def nwo
    "#{owner}/#{name}"
  end

  def path
    "/#{nwo}"
  end

  def gist(octokit, url)
    response = Rack::Client.get(url)

    if response.status == 200
      gist = octokit.create_gist \
        public: false,
        files: {
          "htee:#{name}.sh-session" => {
            content: response.body,
          },
        }

      update(gist_id: gist[:id], status: :gisted)
    end
  end

  def gist_path
    "/#{owner}/#{gist_id}"
  end
end
