def load_fixture(fixture_path='default')
  ActiveRecord::FixtureSet.reset_cache
  fixtures_folder = File.join("./features/support/fixtures/#{fixture_path}/")
  fixtures = Dir[File.join(fixtures_folder, '*.yml')].map {|f| File.basename(f, '.yml') }
  ActiveRecord::FixtureSet.create_fixtures(fixtures_folder, fixtures)
end

