# Getting Correct AppArmor Output on Windows (via Ubuntu WSL)

AppArmor requires a Linux kernel to enforce restrictions. This folder contains the steps to run the exercise correctly using Ubuntu WSL on Windows.

## Step 1 — Install Ubuntu WSL (one time)

Open PowerShell as Administrator:

```powershell
wsl --install -d Ubuntu
```

Restart your PC. Ubuntu will open and ask for a username and password — set anything (e.g. user: `devops`, pass: `1234`).

## Step 2 — Install dependencies inside Ubuntu WSL

Open Ubuntu from Start menu and run:

```bash
sudo apt-get update
sudo apt-get install -y apparmor-utils python3-pip
pip3 install docker
```

## Step 3 — Copy the AppArmor profile into the system

```bash
sudo cp /mnt/c/Users/ben09/OneDrive/Desktop/Devops_exercises_1BM23IS295/Exercise-5/my-apparmor-profile /etc/apparmor.d/my-apparmor-profile
```

## Step 4 — Load the profile

```bash
sudo apparmor_parser -r /etc/apparmor.d/my-apparmor-profile
```

Verify it loaded:

```bash
sudo aa-status | grep my-apparmor
```

## Step 5 — Navigate to Exercise-5 folder

```bash
cd /mnt/c/Users/ben09/OneDrive/Desktop/Devops_exercises_1BM23IS295/Exercise-5
```

## Step 6 — Build the Docker image from WSL

```bash
docker build -t flask-apparmor .
```

## Step 7 — Run apply_apparmor.py

```bash
python3 apply_apparmor.py
```

Expected output:
```
Building image from Dockerfile...
Running container with AppArmor profile...
Container started: f8c2a7f9b9b8
Inspecting container to verify AppArmor profile...
AppArmor profile applied: ['apparmor=my-apparmor-profile']
Stopping the container...
```

## Step 8 — Run test_restricted_actions.py

```bash
python3 test_restricted_actions.py
```

Expected output:
```
Starting container with AppArmor profile...
Container started: f8c2a7f9b9b8

Testing restricted actions...
Attempt to read /etc/passwd: Exit Code 1, Output:
Attempt to execute /bin/bash: Exit Code 126, Output:
Container stopped
```

- **Exit Code 1** → AppArmor blocked `/etc/passwd` read (deny /etc/** r)
- **Exit Code 126** → AppArmor blocked `/bin/bash` execution (deny /bin/** rmix)

## Screenshots

Screenshots of the correct Linux output will be added here after running on WSL.
