import os
from cheroot import wsgi
from . import create_app

def main():
    print("Service running from:", os.getcwd())
    bind_path = "/"
    bind_addr = ("127.0.0.1", 4000)
    app = create_app()
    app.debug = True
    app.threaded = True

    wsgi_app = wsgi.PathInfoDispatcher({bind_path: app})
    server = wsgi.Server(bind_addr, wsgi_app, request_queue_size=512)

    # if self.use_ssl:
    #     try:
    #         self.server.ssl_adapter = BuiltinSSLAdapter(
    #             self.certfile, self.keyfile, self.certchain
    #         )
    #     except Exception as exc:
    #         self.log.error(
    #             self._("Cannot use HTTPS: {}").format(exc),
    #             exc_info=self.pyload.debug,
    #             stack_info=self.pyload.debug > 2,
    #         )
    #         self.use_ssl = False

    # #: hack cheroot to use our custom logger
    # self.server.error_log = lambda *args, **kwargs: self.log.log(
    #     kwargs.get("level", logging.ERROR), args[0], exc_info=self.pyload.debug
    # )

    try:
        server.start()

    except OSError as exc:
        if (
            exc.errno in (98, 10013)
            or isinstance(exc.args[0], str)
            and ("Errno 98" in exc.args[0] or "WinError 10048" in exc.args[0])
        ):
            print("** FATAL ERROR ** Could not start web server - Address Already in Use | Exiting pyLoad")
        else:
            raise
    except KeyboardInterrupt:
        print("Received KeyboardInterrupt...")
        server.stop()

    # if args.profile:
    #     from flask_debugtoolbar import DebugToolbarExtension
    #     import flask_profiler

    #     app.config["flask_profiler"] = {
    #         "enabled": app.config["DEBUG"],
    #         "storage": {"engine": "sqlite"},
    #         "basicAuth": {"enabled": False},
    #         "ignore": ["^/themes/.*", "^/events"],
    #     }
    #     flask_profiler.init_app(app)
    #     app.config["DEBUG_TB_PROFILER_ENABLED"] = True
    #     app.config["DEBUG_TB_INTERCEPT_REDIRECTS"] = False

    #     toolbar = DebugToolbarExtension()
    #     toolbar.init_app(app)
    #     print(" * Flask profiling running at http://127.0.0.1:4000/flask-profiler/")

    # app.run(debug=True, threaded=True, host="127.0.0.1", port=args.port)

if __name__=='__main__':
    main()