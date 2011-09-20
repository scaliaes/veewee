#require 'open4'

module Veewee
  module Util

    class ShellResult
      attr_accessor :stdout
      attr_accessor :stderr
      attr_accessor :status

      def initialize(stdout,stderr,status)
        @stdout=stdout
        @stderr=stderr
        @status=status
      end
    end

    class Shell

      # http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/185404
      # This should work on windows too now
      # This will result in a ShellResult structure with stdout, stderr and status
      def self.execute(command,options = {})
        result=ShellResult.new("","",-1)
        puts "Executing #{command}" unless options[:mute]
        escaped_command=command
        #        puts "#{escaped_command}"
        IO.popen("#{escaped_command}"+ " 2>&1") { |p|
          p.each_line{ |l|
            result.stdout+=l
            print l unless options[:mute]
          }
          result.status=Process.waitpid2(p.pid)[1].exitstatus
          if result.status!=0
            puts "Exit status was not 0 but #{result.status}" unless options[:mute]
          end
        }
        return result
      end

      # This it original execute command, the main reason was for being able to output content
      # AND have the exit code. It was not compatible with windows though
      # pty allows you to gradually see the output of a local command
      # http://www.shanison.com/?p=415
      def self.execute2(command, options = {} )
        result=ShellResult.new

        require "pty"
        begin
          PTY.spawn( command ) do |r, w, pid|
            begin
              r.each { }
              #r.each { |line| print line;}

            rescue Errno::EIO
            end
          end
        rescue PTY::ChildExited => e
          puts "The child process exited!"
        end
      end

    end #Class
  end #Module
end #Module