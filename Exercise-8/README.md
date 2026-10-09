# Exercise 8 – Creating a "Hello World" Jenkins Job

## Objective
Create a separate GitHub repository with a bash script and configure a Jenkins Freestyle Job to pull the code from GitHub and execute it automatically.

## What I did
- Created a new GitHub repository named `devops-sample-code`.
- Wrote a simple `hello-world.sh` bash script locally.
- Initialized a local Git repository, committed the script, and pushed it to the `main` branch of the new GitHub repository.
- Started the local Jenkins Docker container and accessed the Jenkins dashboard.
- Created a new Jenkins **Freestyle project** named `HelloWorld`.
- Configured Jenkins **Source Code Management (SCM)** to automatically clone the GitHub repository.
- Added an **Execute shell** build step to run `sh hello-world.sh`.
- Triggered the Jenkins job manually and reviewed the successful console output.

## Key Concepts
- **Jenkins Freestyle Job** – A classic, highly customizable Jenkins job type that allows setting up simple continuous integration workflows through a web UI.
- **Source Code Management (SCM)** – Linking a Git repository directly to a Jenkins job so Jenkins can automatically fetch the latest source code into its workspace before building.
- **Execute Shell Build Step** – A build step that runs scripts and commands exactly as if they were typed into a Linux terminal inside the Jenkins workspace.

## Output

### Part 1: GitHub Repository Setup
Creating the new GitHub repository:
![create-repo](./screenshots/01-create-repo.png)

Repository created:
![created-repo](./screenshots/02-created-repo.png)

### Part 2: Local Script and Git Push
Writing the `hello-world.sh` script locally:
![create-script](./screenshots/03-create-script.png)

Initializing Git and committing the code:
![git-commit](./screenshots/04-git-commit.png)

Pushing the code to the GitHub remote repository:
![git-push](./screenshots/05-git-push.png)

### Part 3: Jenkins Job Configuration
Starting the Jenkins Docker container:
![start-jenkins](./screenshots/06-start-jenkins.png)

Logging back into Jenkins using the admin token:
![jenkins-login](./screenshots/08-jenkins-login.png)

Creating a new Freestyle project named `HelloWorld`:
![new-item](./screenshots/09-new-item.png)

Adding the job description:
![job-description](./screenshots/10-job-description.png)

Configuring Source Code Management (Git URL and branch):
![git-config](./screenshots/11-git-config.png)

Adding the Execute Shell build step:
![build-steps](./screenshots/12-build-steps.png)

### Part 4: Running the Build
Triggering the build from the dashboard:
![build-now](./screenshots/13-build-now.png)

Successful Console Output showing the script execution:
![console-output](./screenshots/14-console-output.png)
