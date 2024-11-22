import socket


def tcp_echo_client(host='0.0.0.0', port=8080):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
        client_socket.connect((host, port))
        print(f"Connected to {host}:{port}")

        message = input("Enter message to send to the server: ")
        client_socket.sendall(message.encode())

        response = client_socket.recv(1024).decode()
        print(f"Received from server: {response}")


if __name__ == "__main__":
    tcp_echo_client()
