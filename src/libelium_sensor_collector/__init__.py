# -*- coding: utf-8 -*-
import threading
import socket


class ReadingThread(threading.Thread):
    def __init__(self, port: int, callback):
        super().__init__()

        self.buffer = bytearray()
        self.cb = callback

        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.s.setblocking(0)
        self.s.bind(('', port))
        self.s.listen(10)

    def run(self):
        conn, addr = self.s.accept()
        with conn:
            print("Connected by", addr)
            while True:
                data = conn.recv(1024)
                self.buffer.extend(data)

                if b'\n' in self.buffer:
                    index = self.buffer.find(b'\n')
                    line = self.buffer[:index]
                    self.cb(line.decode("utf-8"))
                    self.buffer = self.buffer[index:]

