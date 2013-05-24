# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :shell do
  watch(%r{(lib|spec)/.*}) do 
    system %Q{export AGAINST="~> 2.3.0" && (bundle --quiet || bundle install --quiet) && bundle exec rake spec}
    system %Q{export AGAINST="~> 3.0" && (bundle --quiet || bundle install --quiet) && bundle exec rake spec}
  end
end
