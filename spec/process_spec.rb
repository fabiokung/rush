require File.dirname(__FILE__) + '/base'

if !RUBY_PLATFORM.match(/darwin/)   # doesn't work on OS X cause no /proc
	describe Rush::Process do
		before(:each) do
			@pid = fork do
				sleep 999
			end
			@process = Rush::Process.all.detect { |p| p.pid == @pid }
		end

		after(:each) do
			system "kill -9 #{@pid}"
		end

		it "gets the list of all processes" do
			list = Rush::Process.all
			list.size.should > 5
			list.first.should be_kind_of(Rush::Process)
		end

		it "knows the pid" do
			@process.pid.should == @pid
		end

		it "knows the uid" do
			@process.uid.should == ::Process.uid
		end

		it "knows the executed binary" do
			@process.command.should == "ruby"
		end

		it "knows the command line" do
			@process.cmdline.should match(/process_spec.rb/)
		end

		it "can kill itself" do
			system "sleep 30 &"
			@process = Rush::Process.all.detect { |p| p.command == "sleep" }
			@process.kill
			sleep 0.1
			@process.alive?.should be_false
		end
	end
end
