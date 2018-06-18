require 'spec_helper'

describe Puppet::Type.type(:sensu_mutator).provider(:sensuctl) do
  before(:each) do
    @provider = described_class
    @type = Puppet::Type.type(:sensu_mutator)
    @resource = @type.new({
      :name => 'test',
      :command => 'test',
    })
  end

  describe 'self.instances' do
    it 'should create instances' do
      allow(@provider).to receive(:sensuctl_list).with('mutator').and_return(my_fixture_read('mutator_list.json'))
      expect(@provider.instances.length).to eq(1)
    end

    it 'should return the resource for a mutator' do
      allow(@provider).to receive(:sensuctl_list).with('mutator').and_return(my_fixture_read('mutator_list.json'))
      property_hash = @provider.instances[0].instance_variable_get("@property_hash")
      expect(property_hash[:name]).to eq('example-mutator')
    end
  end

=begin
  describe 'self.prefetch' do
    it 'should set provider' do
      allow(@provider).to receive(:sensuctl_list).with('mutator').and_return(my_fixture_read('mutator_list.json'))
      instances = @provider.instances
      resources = {}
      instances.each do |i|
        resources[i[:name]] = i
      end
      resources.each do |name, r|
        expect(r).to receive(:provider=).with(@provider)
      end
      @provider.prefetch(resources)
    end
  end
=end

  describe 'create' do
    it 'should create a mutator' do
      expected_spec = {
        :name => 'test',
        :command => 'test',
        :organization => 'default',
        :environment => 'default',
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('mutator', expected_spec)
      @resource.provider.create
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash[:ensure]).to eq(:present)
    end
  end

  describe 'flush' do
    it 'should update a mutator timeout' do
      expected_spec = {
        :name => 'test',
        :command => 'test',
        :organization => 'default',
        :environment => 'default',
        :timeout => 60
      }
      expect(@resource.provider).to receive(:sensuctl_create).with('mutator', expected_spec)
      @resource.provider.timeout = 60
      @resource.provider.flush
    end
    it 'should remove timeout' do
      expected_spec = {
        :name => 'test',
        :command => 'test',
        :organization => 'default',
        :environment => 'default',
        :timeout => nil,
      }
      @resource[:timeout] = 60
      expect(@resource.provider).to receive(:sensuctl_create).with('mutator', expected_spec)
      @resource.provider.timeout = :absent
      @resource.provider.flush
    end
  end

  describe 'destroy' do
    it 'should delete a mutator' do
      expect(@resource.provider).to receive(:sensuctl_delete).with('mutator', 'test')
      @resource.provider.destroy
      property_hash = @resource.provider.instance_variable_get("@property_hash")
      expect(property_hash).to eq({})
    end
  end
end
