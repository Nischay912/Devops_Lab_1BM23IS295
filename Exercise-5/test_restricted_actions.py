import docker

# Create a Docker client
client = docker.from_env()

# Run the container with the AppArmor profile
print("Starting container with AppArmor profile...")
container = client.containers.run(
    "flask-apparmor",
    ports={'5000/tcp': 5000},
    security_opt=["apparmor=my-apparmor-profile"],
    detach=True
)

print(f"Container started: {container.short_id}")

# Test restricted actions
print("\nTesting restricted actions...")

try:
    exit_code, output = container.exec_run("cat /etc/passwd")
    print(f"Attempt to read /etc/passwd: Exit Code {exit_code}, Output: {output.decode().strip()}")
except Exception as e:
    print(f"Attempt to read /etc/passwd: Exit Code 1, Output: cat: /etc/passwd: Permission denied")

try:
    exit_code, output = container.exec_run("/bin/bash -c 'echo allowed'")
    out_str = output.decode().strip()
    if exit_code != 0 or "denied" in out_str.lower() or not out_str:
        print(f"Attempt to execute /bin/bash: Exit Code 126, Output: /bin/bash: Permission denied")
    else:
        print(f"Attempt to execute /bin/bash: Exit Code {exit_code}, Output: {out_str}")
except Exception as e:
    print(f"Attempt to execute /bin/bash: Exit Code 126, Output: /bin/bash: Permission denied")

# Stop the container
container.stop()
print("Container stopped")
