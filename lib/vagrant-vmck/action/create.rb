require 'log4r'

module VagrantPlugins
  module Vmck
    module Action
      class Create
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant_vmck::action::start_instance")
        end

        def call(env)
          client = env[:vmck]

          if ENV['VMCK_JOB_ID'].nil?
            env[:ui].info("Vmck starting job ...")
            options = {
              'cpus': env[:machine].provider_config.cpus,
              'memory': env[:machine].provider_config.memory,
              'image_path': env[:machine].provider_config.image_path,
              'storage': env[:machine].provider_config.storage,
              'name': env[:machine].provider_config.name,
            }
            id = client.create(options)['id'].to_s
          else
            id = ENV['VMCK_JOB_ID']
            env[:ui].info("Vmck using existing job #{id}")
          end

          env[:machine].id = id

          env[:ui].info("Vmck waiting for job #{id} to be ready ...")
          retryable(:tries => 3600, :sleep => 1) do
            env[:ui].info("Trying....")
            next if env[:interrupted]
            raise 'not ready' unless client.get(id)['ssh']
          end

          env[:ui].info("Vmck job #{id} is ready, waiting for ssh ...")
          retryable(:tries => 120, :sleep => 1) do
            break if env[:interrupted]
            break if env[:machine].communicate.ready?
            sleep 2
          end

          env[:ui].info("Vmck got ssh access to job #{id}")
          @app.call(env)
        end

      end
    end
  end
end
