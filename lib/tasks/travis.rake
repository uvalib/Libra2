#==============================================================================
# lib/tasks/travis.rake
#
# Rake tasks for running on Travis continuous integration server.
#==============================================================================

namespace :travis_ci do

  if defined?(RSpec)
    # Only load these files in testing environments
    require 'rspec/core/rake_task'

    #==========================================================================
    # High level test tasks invoked by the Travis test matrix.
    #==========================================================================

    # travis_ci:mainfeatures
    desc "Run main feature tests on Travis"
    task mainfeatures: :environment do
      Rake::Task["travis_ci:prep"].invoke
      error = jetty_test('travis_ci:features')
      raise "test failures: #{error}" if error
    end

    #==========================================================================
    # Helper tasks
    #==========================================================================

    # travis_ci:features
    desc "Run feature tests in the feature directory"
    RSpec::Core::RakeTask.new(:features) do |t|
      t.pattern = FileList['spec{,/features/**}/*_spec.rb']
      t.rspec_opts = ['--color', '--backtrace', '--format Fuubar']
    end

    # travis_ci:prep
    desc "Run a set of tasks to prepare for testing"
    task prep: :environment do
      WebMock.disable!
      Rake::Task["jetty:clean"].invoke
      Rake::Task["curation_concerns:jetty:config"].invoke
      Rake::Task["db:migrate"].invoke
    end

  end
end

# Starts and stops jetty around each high level Travis matrix test/job.
def jetty_test task
  jetty_params = Jettywrapper.load_config.merge({jetty_home: File.expand_path(File.join(Rails.root, 'jetty'))})
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task[task].invoke
  end
  return error
end
