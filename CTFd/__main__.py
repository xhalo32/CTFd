import multiprocessing

from gunicorn.app.base import Application
from gunicorn import util


def number_of_workers():
    return (multiprocessing.cpu_count() * 2) + 1


class WSGIApplication(Application):
    def __init__(self, options=None):
        self.options = options or {}
        super().__init__()

    def init(self, parser, opts, args):
        # self.cfg.set()
        pass

    def load_config(self):
        config = {key: value for key, value in self.options.items()
                  if key in self.cfg.settings and value is not None}
        for key, value in config.items():
            self.cfg.set(key.lower(), value)

    def load(self):
        return util.import_app("CTFd:create_app()")

def main():
    # from CTFd import create_app

    # TODO check what the CLI does exactly and inline it here
    options = {
        'bind': '%s:%s' % ('127.0.0.1', '4000'),
        'workers': number_of_workers(),
        'loglevel': "debug",
        'worker_class': "CTFd.ggevent.NoSSLGeventWorker",
        # TODO increase keepalive when behind a reverse proxy
    }
    # from gunicorn.app.wsgiapp import WSGIApplication
    WSGIApplication(options).run()
    # StandaloneApplication(options).run()

if __name__ == '__main__':
    main()
