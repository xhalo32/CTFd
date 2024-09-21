from gunicorn.workers.ggevent import GeventWorker, monkey, socket

class NoSSLGeventWorker(GeventWorker):
    def patch(self):
        monkey.patch_all(ssl=False)

        # patch sockets
        sockets = []
        for s in self.sockets:
            sockets.append(socket.socket(s.FAMILY, socket.SOCK_STREAM,
                                         fileno=s.sock.fileno()))
        self.sockets = sockets
