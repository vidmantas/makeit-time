set :application, "timetrack"
set :repository,  "http://svn.assembla.com/svn/make-it/timetrack/"

set :scm_username, 'Vidmantas'
set :scm_password, proc{Capistrano::CLI.password_prompt('SVN pass:')}

role :app, "209.20.74.109"
role :web, "209.20.74.109"
role :db,  "209.20.74.109", :primary => true

set :user, 'vidmantas'
set :deploy_to, "/home/vidmantas/public_html/timetrack"

ssh_options[:port] = 24311
set :use_sudo, false

set :deploy_via, :export
set :keep_releases, 3

namespace(:deploy) do
  task :restart do
    run "touch #{release_path}/tmp/restart.txt"
  end
end

namespace(:db) do
  desc "Make symlink for database yaml" 
  task :symlink do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml" 
  end
end

after "deploy:update_code", "db:symlink"