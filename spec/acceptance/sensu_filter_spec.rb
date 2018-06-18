require 'spec_helper_acceptance'

describe 'sensu_filter', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  node = only_host_with_role(hosts, 'sensu_backend')
  context 'default' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_filter { 'test':
        action     => 'allow',
        statements => ["event.Entity.Environment == 'production'"],
        when_days  => {'all' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]},
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid filter' do
      on node, 'sensuctl filter info test --format json' do
        data = JSON.parse(stdout)
        expect(data['action']).to eq('allow')
      end
    end
  end

  context 'update filter' do
    it 'should work without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_filter { 'test':
        action     => 'allow',
        statements => ["event.Entity.Environment == 'production'"],
        when_days  => {'monday' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]},
      }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    it 'should have a valid filter with updated propery' do
      on node, 'sensuctl filter info test --format json' do
        data = JSON.parse(stdout)
        expect(data['when']['days']).to eq({'monday' => [{'begin' => '5:00 PM', 'end' => '8:00 AM'}]})
      end
    end
  end

  context 'ensure => absent' do
    it 'should remove without errors' do
      pp = <<-EOS
      include ::sensu::backend
      sensu_filter { 'test': ensure => 'absent' }
      EOS

      # Run it twice and test for idempotency
      apply_manifest_on(node, pp, :catch_failures => true)
      apply_manifest_on(node, pp, :catch_changes  => true)
    end

    describe command('sensuctl filter info test'), :node => node do
      its(:exit_status) { should_not eq 0 }
    end
  end
end
