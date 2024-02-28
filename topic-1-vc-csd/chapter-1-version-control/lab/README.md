# Lab Instructions: Version Control and Branching

## Objective:
The objective of this lab is to familiarize yourself with version control concepts, particularly branching, using Git.

## Prerequisites:
- Install Git on your local machine if you haven't already. You can download it from [here](https://git-scm.com/).
- Have a basic understanding of Git commands such as `git init`, `git add`, `git checkout`, `git commit`, `git status`, and `git push`.

## Instructions:
1. **Clone the Repository:**
   - Start by cloning the lab repository to your local machine using the following command:
     ```
     git clone https://github.com/open-devsecops/topic-1-lab-reference-app
     ```
   
2. **Navigate to the Repository Directory:**
   - Move into the directory of the cloned repository on your machine
     ```
     cd <location_of_your_cloned_repo>
     ```

3. **Create a New Branch:**
   - Create a new branch named `feature-branch-<your_name>` (or a unique identifier for your branch) using the following command:
     ```
     git checkout -b feature-branch-<your_name>
     ```

4. **Make Changes:**
   - Make changes to the code or README file in the repository. This could be as simple as adding your name to a list or modifying a line of code.

5. **Stage and Commit Your Changes:**
   - Stage your changes using:
     ```
     git add .
     ```
   - Commit your changes with a descriptive message:
     ```
     git commit -m "Changed README"
     ```

6. **Push Your Branch:**
   - Push your branch to the remote repository:
     ```
     git push origin feature-branch
     ```

7. **Create a Pull Request:**
   - Navigate to the [GitHub repository page](https://github.com/open-devsecops/topic-1-lab-reference-app).
   - On the repo nav bar, click "Pull Requests."
   - On the right-hand side, click the green button titled "New Pull Request."
   - If it's not already there, change base branch to "main" and change compare to the branch you made.
   - Title it something meaningful, like "Added my name."
   - Click the green "Create pull request" button.
   - Click the green "Merge pull request" button and "Confirm."
        - **NOTE**: Typically in a professional setting, this is a step that the owner of a project will take after reviewing the changes you made. But for this exercise, you will do both steps.