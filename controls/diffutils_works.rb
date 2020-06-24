title 'Tests to confirm diffutils works as expected'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'diffutils')

control 'core-plans-diffutils-works' do
  impact 1.0
  title 'Ensure diffutils works as expected'
  desc '
  Verify diffutils by ensuring 
  (1) its installation directory exists and 
  (2) that it returns the expected version.
  (3) should detect equal contents
  (4) should detect different content
  '
  
  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stderr') { should be_empty }
  end
  
  command_relative_path = input('command_relative_path', value: 'bin/diff')
  command_full_path = File.join(plan_installation_directory.stdout.strip, command_relative_path)
  plan_pkg_version = plan_installation_directory.stdout.split("/")[5]
  describe command("#{command_full_path} --version") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /diff \(GNU diffutils\) #{plan_pkg_version}/ }
    its('stderr') { should be_empty }
  end

  alpha_file = "/hab/svc/diffutils/config/fixtures/alpha"
  describe command("#{command_full_path} #{alpha_file} #{alpha_file}") do
    its('exit_status') { should eq 0 }
    its('stdout') { should be_empty }
    its('stderr') { should be_empty }
  end
  
  beta_file = "/hab/svc/diffutils/config/fixtures/beta"
  describe command("#{command_full_path} #{alpha_file} #{beta_file}") do
    its('exit_status') { should_not eq 0 }
    its('stdout') { should_not be_empty }
    its('stderr') { should be_empty }
  end
end