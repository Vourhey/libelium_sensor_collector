# -*- coding: utf-8 -*-
import threading
import socket
import select
import rospy


class ReadingThread(threading.Thread):

    MAX_CONNECTIONS = 10
    INPUTS = list()
    OUTPUTS = list()

    def __init__(self, ip: str, port: int, callback):
        super().__init__()

        self.buffer = bytearray()
        self.cb = callback
        self.server_address = (ip, port)

    def _get_non_blocking_server_socket(self):

        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.setblocking(0)

        server.bind(self.server_address)

        server.listen(self.MAX_CONNECTIONS)

        return server

    def handle_readables(self, readables, server):
        for resource in readables:

            if resource is server:
                connection, client_address = resource.accept()
                connection.setblocking(0)
                self.INPUTS.append(connection)
                rospy.loginfo("new connection from {address}".format(address=client_address))

            else:
                data = ""
                try:
                    data = resource.recv(1024)

                except ConnectionResetError:
                    pass

                if data:
                    rospy.loginfo("getting data: {data}".format(data=str(data)))
                    self.buffer.extend(data)

                    while len(self.buffer) > 1:
                        if b'\n' in self.buffer:
                            index = self.buffer.find(b'\n')
                            line = self.buffer[:index]
                            self.cb(line.decode("utf-8", "backslashreplace"))
                            self.buffer = self.buffer[index+1:]

                    if resource not in self.OUTPUTS:
                        self.OUTPUTS.append(resource)

                else:
                    self.clear_resource(resource)


    def clear_resource(self, resource):
        if resource in self.OUTPUTS:
            self.OUTPUTS.remove(resource)
        if resource in self.INPUTS:
            self.INPUTS.remove(resource)
        resource.close()

        rospy.loginfo('closing connection ' + str(resource))

    def run(self):
        server_socket = self._get_non_blocking_server_socket()
        self.INPUTS.append(server_socket)

        rospy.loginfo("Server is running...")

        try:
            while self.INPUTS:
                readables, writables, exceptional = select.select(self.INPUTS, self.OUTPUTS, self.INPUTS)
                self.handle_readables(readables, server_socket)
        except KeyboardInterrupt:
            self.clear_resource(server_socket)
            rospy.loginfo("Server stopped!")

