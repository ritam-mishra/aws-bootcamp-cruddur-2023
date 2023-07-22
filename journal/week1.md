# Week 1 — App Containerization

## Required Homework
### Containerize Application
* Created a Dockerfile within the *flask-backend* and *frontend-react-js* folders containing the image instructions.  
[Backend Dockerfile](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/blob/main/backend-flask/Dockerfile "Backend Dockerfile") - [Frontend Dockerfile](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/blob/main/frontend-react-js/Dockerfile "Frontend Dockerfile")
* I copied the *docker-compose.yml* file contents from project repo and made sure it can run all the docker containers in a single command
[docker-compose file](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/blob/main/docker-compose.yml "docker-compose file")
* I added DynamoDB Local and Postgres to that *Docker-compose.yml* file, after following the steps from the youtube playlist
* Now docker compose up to run the containers (building the specific images if needed) and wait until all containers are in *started* state.

![image](![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/3890f0d1-f99b-422d-9fbf-85e908ba153b))

### Document the Notification Endpoint for the OpenAI Document
Following along with the *Create the notification feature* video:
* In the [openapi-3.0.yml file link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/blob/main/backend-flask/openapi-3.0.yml "openapi-3.0.yml") file, I added a new path *"/api/activities/notifications:"*, as per the guided video.   

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/7a8d7dbe-a9b1-4974-b2e4-770325ee4d3e)

### Write a Flask Backend Endpoint for Notifications  
* I created notifications endpoint, created a python file for notifications activities within *backend_flask* folder.
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/e684d533-7672-4e5c-b914-1921a733e296)

* I copied the *home activities* contents, then made some edits to be for notifications activites.
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/4cbb4365-cbd1-434f-b1d8-00cc258db826)
and the result was perfect! Hurray!!

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/bde93394-0df9-4038-b0be-70a78cc16af2)


### Write a React Page for Notifications
* Following the steps in the youtube video, I created a js file for the notifications page (copied the same as homefeed page with some modifications).

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/32eefe8f-3f6d-4782-8458-cfb77490fcc8)


### Run DynamoDB Local Container and ensure it works
* After adding DynamoDB Local and Postgres to that *Docker-compose.yml* file.

![dynamo-db](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/53b5269b-ebde-43cc-b1a7-adfbd56bfa4f)

### Run Postgres Container and ensure it works
* Following along with the video I ran a command to ensure postgres is working

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/b0950f45-f892-47db-8add-91f6c9df083e)

## Homework Challenges

### Push and tag a image to DockerHub
* To push the image, first I logged into my DockerHub account with `docker login`  
* Created the repository with the image name on DockerHub.
* Tagged the image with *ritammishra/aws-bootcamp-cruddur-2023-frontend-react-js:1.0* as the first version tag and pushed it.
  ![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/8d79cb85-e71b-44f1-8231-22c630c1d9e8)
* I repeated the above steps and pushed my backend image in the same way-
* Tagged the image with *ritammishra/aws-bootcamp-cruddur-2023-backend-flask:1.0* as the first version tag and pushed it.
  ![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/0117596b-91cd-40d5-bb4f-9295541c4f3d)
Finally i was able to upload both the images on dockerhub.
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/ff8620fc-fd93-4efa-80e0-4e812890a17e)


