require 'rack/mock'

shared_examples_for 'Rack::Access' do
  subject { middleware.call(env) }

  let(:middleware) do
    described_class.new(mock_app, options)
  end

  let(:mock_app) do
    proc { |_env| [200, { 'Content-Type' => 'text/plain' }, %w(hello)] }
  end

  let(:env) do
    Rack::MockRequest.env_for(path, 'REMOTE_ADDR' => remote_addr, 'HTTP_HOST' => host, 'SERVER_NAME' => host)
  end

  shared_examples_for 'allowed' do
    it 'allow request' do
      expect(subject).to eq [200, { 'Content-Type' => 'text/plain' }, %w(hello)]
    end
  end

  shared_examples_for 'denied' do
    it 'deny request' do
      expect(subject).to eq [403, { 'Content-Type' => 'text/html', 'Content-Length' => '0' }, []]
    end
  end

  context 'option is default' do
    let(:host) { 'www.example.com' }
    let(:path) { '/' }
    let(:options) { {} }

    context 'access to "/" from 127.0.0.1' do
      let(:remote_addr) { '127.0.0.1' }

      it_behaves_like 'allowed'
    end

    context 'access to "/" from 192.168.1.1' do
      let(:remote_addr) { '192.168.1.1' }

      it_behaves_like 'denied'
    end
  end

  context 'allow access to "/" from 192.168.1.1' do
    let(:host) { 'www.example.com' }
    let(:path) { '/' }
    let(:options) { { '/' => %w(192.168.1.1) } }

    context 'access to "/" from 127.0.0.1' do
      let(:remote_addr) { '127.0.0.1' }

      it_behaves_like 'denied'
    end

    context 'access to "/a" from 127.0.0.1' do
      let(:remote_addr) { '127.0.0.1' }

      it_behaves_like 'denied'
    end

    context 'access to "/" from 192.168.1.1' do
      let(:remote_addr) { '192.168.1.1' }

      it_behaves_like 'allowed'
    end
  end

  context 'allow access to "http://www.example.com/" from 192.168.1.1' do
    let(:path) { '/' }
    let(:options) { { 'http://www.example.com/' => %w(192.168.1.1) } }

    context 'access to "http://www.example.com/" from 127.0.0.1' do
      let(:host) { 'www.example.com' }
      let(:remote_addr) { '127.0.0.1' }

      it_behaves_like 'denied'
    end

    context 'access to "http://www.example.com/" from 192.168.1.1' do
      let(:host) { 'www.example.com' }
      let(:remote_addr) { '192.168.1.1' }

      it_behaves_like 'allowed'
    end

    context 'access to "http://www2.example.com/" from 192.168.1.1' do
      let(:host) { 'www2.example.com' }
      let(:remote_addr) { '192.168.1.1' }

      it_behaves_like 'allowed'
    end
  end

  context 'allow access to "/" from 192.168.1.0/24' do
    let(:host) { 'www.example.com' }
    let(:path) { '/' }
    let(:options) { { '/' => %w(192.168.1.0/24) } }

    context 'access from 127.0.0.1' do
      let(:remote_addr) { '127.0.0.1' }

      it_behaves_like 'denied'
    end

    context 'access from 192.168.1.123' do
      let(:remote_addr) { '192.168.1.123' }

      it_behaves_like 'allowed'
    end
  end

  context 'allow access to "/" from 123.123.123.123 or 111.111.111.111' do
    let(:host) { 'www.example.com' }
    let(:path) { '/' }
    let(:options) { { '/' => %w(123.123.123.123 111.111.111.111) } }

    context 'access from 127.0.0.1' do
      let(:remote_addr) { '127.0.0.1' }

      it_behaves_like 'denied'
    end

    context 'access from 123.123.123.123' do
      let(:remote_addr) { '123.123.123.123' }

      it_behaves_like 'allowed'
    end

    context 'access from 111.111.111.111' do
      let(:remote_addr) { '111.111.111.111' }

      it_behaves_like 'allowed'
    end
  end

  context 'allow access to "/a/b" from 192.168.1.1' do
    let(:host) { 'www.example.com' }
    let(:options) { { '/a/b' => %w(192.168.1.1) } }

    context 'access to "/a"' do
      let(:path) { '/a' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'allowed'
      end
    end

    context 'access to "/a/b"' do
      let(:path) { '/a/b' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'denied'
      end
    end

    context 'access to "/a/b/"' do
      let(:path) { '/a/b/' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'denied'
      end
    end

    context 'access to "/a///b"' do
      let(:path) { '/a///b' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'denied'
      end
    end

    context 'access to "/a/b/c"' do
      let(:path) { '/a/b/c' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'denied'
      end
    end

    context 'access to "/a/bc"' do
      let(:path) { '/a/bc' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'allowed'
      end
    end
  end

  context 'restrict multiple paths' do
    let(:host) { 'www.example.com' }
    let(:options) do
      {
        '/a' => %w(192.168.1.1),
        '/a/b' => %w(192.168.1.2)
      }
    end

    context 'access to "/"' do
      let(:path) { '/' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.3' do
        let(:remote_addr) { '192.168.1.3' }

        it_behaves_like 'allowed'
      end
    end

    context 'access to "/a"' do
      let(:path) { '/a' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'denied'
      end

      context 'from 192.168.1.3' do
        let(:remote_addr) { '192.168.1.3' }

        it_behaves_like 'denied'
      end
    end

    context 'access to "/a/b"' do
      let(:path) { '/a/b' }

      context 'from 192.168.1.1' do
        let(:remote_addr) { '192.168.1.1' }

        it_behaves_like 'denied'
      end

      context 'from 192.168.1.2' do
        let(:remote_addr) { '192.168.1.2' }

        it_behaves_like 'allowed'
      end

      context 'from 192.168.1.3' do
        let(:remote_addr) { '192.168.1.3' }

        it_behaves_like 'denied'
      end
    end
  end
end
