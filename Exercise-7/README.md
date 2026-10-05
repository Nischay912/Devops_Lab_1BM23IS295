# Exercise 7 – Introduction to CI and Jenkins Installation

## Objective
Understand the core concepts of Continuous Integration (CI) and perform a fresh local installation of Jenkins using Docker.

## What I did
- Learned the fundamentals of Continuous Integration (CI), its benefits, and popular CI tools (GitLab, CircleCI, Travis CI, Jenkins, etc.)
- Installed Jenkins locally using a Docker container
- Extracted the initial administrator password from the container to unlock Jenkins
- Completed the initial Jenkins setup via the web interface on port 8080

## Key Concepts
- **Continuous Integration (CI)** – A practice where developers frequently merge code to a shared repository, triggering automated builds and tests to detect errors early.
- **Jenkins** – An open-source automation server used to build, test, and deploy software.
- **Jenkins Pipeline** – A series of automated steps to build, test, and deploy applications.
- **Plugins** – Extensions that add functionality to Jenkins (e.g., Git plugin, Docker plugin).
- **Nodes/Agents** – Machines where Jenkins executes jobs.

## Output

Starting Jenkins using Docker:
```bash
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts

Unable to find image 'jenkins/jenkins:lts' locally
lts: Pulling from jenkins/jenkins
7d98d813d54f: Pull complete
a36a1f8447e8: Pull complete
f7ee35b739bf: Pull complete
bb3229cfea8c: Pull complete                                                                                             
d6f97f67d9a1: Pull complete
866fdfadf828: Pull complete
28ae6a41194b: Pull complete                                                                                             
9393a6815458: Pull complete
80c15ff4ebe9: Pull complete
4b1bc6ce70dc: Pull complete
1b47cf50f1d7: Pull complete
089de16bf95f: Pull complete
Digest: sha256:7ea4989040ce0840129937b339bf8c8f878c14b08991def312bdf51ca05aa358
Status: Downloaded newer image for jenkins/jenkins:lts
d350facb3a26a8282e286a9f63ea585b93372c97222692cb89429a298e39d1d1
```

Verifying the container is running and extracting the Initial Admin Password:
```bash
docker ps -a
CONTAINER ID   IMAGE                                 COMMAND                  CREATED          STATUS          PORTS
d350facb3a26   jenkins/jenkins:lts                   "/usr/bin/tini -- /u…"   14 minutes ago   Up 14 minutes   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:50000->50000/tcp, :::50000->50000/tcp   jenkins

docker exec -it d350facb3a26 bash
jenkins@d350facb3a26:/$ cat /var/jenkins_home/secrets/initialAdminPassword
060a3736329e4533ab8e4428ffcc9619
```

Accessing Jenkins at `http://localhost:8080/` and unlocking it using the retrieved password:

![jenkins-initial-pwd-Unlock](https://github.com/user-attachments/assets/1902e321-ac1b-4187-a046-ca996ddd546a)

Installing suggested plugins during the initial setup:

![jenkins-getting-started](https://github.com/user-attachments/assets/dff9c748-31cd-42f9-adee-3a5c5b317779)

Jenkins Landing Page after successful setup:

![jenkins-landing-page](https://github.com/user-attachments/assets/42839e8e-a592-4d1d-95a0-825ce3849970)
