# Week 4 — Postgres and RDS

Week 4 focuses on RDS and creation of a new database with PostgreSQL engine via the AWS console for RDS. I learnt about databases and relational databases. From the live session on week 4 posted in the official youtube playlist, i got to know about how RDS works and how to integrate PostgreSQL on our project. The steps are shown below here with the required commit links. I had a lot of problem this week, I was not able to connect to the database and there were many problems in my code. After watching all the instructions I was able to create new activities.

## RCreating a RDS instance via AWS CLI.

I could create a new database with PostgreSQL engine via the AWS console for RDS, or use the following command line:

```sh
aws rds create-db-instance \
  --db-instance-identifier cruddur-db-instance \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version  14.6 \
  --master-username cruddurroot \
  --master-user-password <HIDDEN_PASSWORD> \
  --allocated-storage 20 \
  --availability-zone us-east-1a \
  --backup-retention-period 0 \
  --port 5432 \
  --no-multi-az \
  --db-name cruddur \
  --storage-type gp2 \
  --publicly-accessible \
  --storage-encrypted \
  --enable-performance-insights \
  --performance-insights-retention-period 7 \
  --no-deletion-protection
```

A RDS instance named `cruddur-db-instance` is created. According to the above `master-username`, `master-user-password`, `port`, `db-name`, and the endpoint shown on the AWS console, we can decide `PROD_CONNECTION_URL` and export it by:

```sh
export PROD_CONNECTION_URL='postgresql://<master-username>:<master-user-password>@<aws-rds-endpoint>:<port>/<db-name>'
gp env PROD_CONNECTION_URL='postgresql://<master-username>:<master-user-password>@<aws-rds-endpoint>:<port>/<db-name>'
```

In order to let our gitpod workspace connect to the RDS instance remotely, I edited the inbound rules of the RDS instance's VPC security groups by allowing gitpod's IP  to reach port 5432 for PostgreSQL. When it's done, AWS console is shown as the screenshot below.

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/d7b2e7b5-413d-4fd6-aad9-b3317f0d66e6)

Since gitpod's IP is changed whenever a new workspace is created, we can use the following command line to always let the current IP connect to the RDS instance remotely.

After following the video instructions, I created a script into `backend-flask/bin/rds-update-sg-rule`. [Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/a8e09a3d8b11238ea369f34d9a9ec928fc3d14c0), I also updated the .gitpod.yml such that every time we launch a gitpod workspace, these commands can be automatically completed. The script is given below

```sh
export DB_SG_ID=<YOUR_ID_FOR_THE_SECURITY_GROUP>
gp env DB_SG_ID=<YOUR_ID_FOR_THE_SECURITY_GROUP>
export DB_SG_RULE_ID=<YOUR_ID_FOR_THE_SECURITY_GROUP_RULE>
gp env DB_SG_RULE_ID=<YOUR_ID_FOR_THE_SECURITY_GROUP_RULE>

aws ec2 modify-security-group-rules \
    --group-id $DB_SG_ID \
    --security-group-rules "SecurityGroupRuleId=$DB_SG_RULE_ID,SecurityGroupRule={IpProtocol=tcp,FromPort=5432,ToPort=5432,CidrIpv4=$GITPOD_IP/32}"
```
### Bash Scripts and SQL for Postgres Operations

For working with local SQL, the `CONNECTION_URL` should be updated :

```sh
export CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
gp env CONNECTION_URL="postgresql://postgres:password@localhost:5432/cruddur"
```
### Connect to DB script
* Set `CONNECTION_URL` var. for local DB connection
```sh
export CONNECTION_URL="postgresql://postgres:pssword@127.0.0.1:5433/cruddur"
gp env CONNECTION_URL="postgresql://postgres:pssword@127.0.0.1:5433/cruddur"
```
* Created bash script named `db-connect` in `backend-flask/bin`.
```sh
#! /usr/bin/bash

# Make Colorful label
CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-connect"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

# Check to run in dev or prod
if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL
```
* Made it executable by the following command:  
```sh
chmod u+x bin/db-connect
```
* Execution the script:
```sh
./bin/db-connect
```
### To drop the DB script
* Create bash script named `db-drop` in `backend-flask/bin`.
```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-drop"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "drop database cruddur;"
```
### DB connections script
* In order to be able to drop database without error we have to make sure there's no opened sessions, So we can the below script to check all opened sessions
* Create bash script named `db-sessions` in `backend-flask/bin`.
```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-sessions"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

NO_URL=$(sed 's/\/cruddur//g' <<<"$URL")
psql $NO_URL -c "select pid as process_id, \
       usename as user,  \
       datname as db, \
       client_addr, \
       application_name as app,\
       state \
from pg_stat_activity;"
```
### Shell script to create the database
* I created bash script named `db-create` in `backend-flask/bin`.
```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-create"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

NO_DB_CONNECTION_URL=$(sed 's/\/cruddur//g' <<<"$CONNECTION_URL")
psql $NO_DB_CONNECTION_URL -c "CREATE database cruddur;"
```

### Shell script to load the schema
* Create bash script named `db-schema-load` in `backend-flask/bin`.
```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-schema-load"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

schema_path="$(realpath .)/db/schema.sql"

echo $schema_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $schema_path
```
### Shell script to load the seed data
* Create bash script named `db-seed` in `backend-flask/bin`.
```sh
#! /usr/bin/bash

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-seed"
printf "${CYAN}== ${LABEL}${NO_COLOR}\n"

seed_path="$(realpath .)/db/seed.sql"

echo $seed_path

if [ "$1" = "prod" ]; then
  echo "Running in production mode"
  URL=$PROD_CONNECTION_URL
else
  URL=$CONNECTION_URL
fi

psql $URL cruddur < $seed_path
```
### Setup script to load everything at once for the DB:
* Create bash script named `db-setup` in `backend-flask/bin`.
```sh
#! /usr/bin/bash

set -e # stop if it fails at any point

CYAN='\033[1;36m'
NO_COLOR='\033[0m'
LABEL="db-setup"
printf "${CYAN}===== ${LABEL}${NO_COLOR}\n"

bin_path="$(realpath .)/bin"

source "$bin_path/db-drop"
source "$bin_path/db-create"
source "$bin_path/db-schema-load"
source "$bin_path/db-seed"
```
All the changes can be seen in the [Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/20f94622fb06510e1b0fe96ec5af0e4dec41f517)
After running the setup script:
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/b30ae7b3-7f2c-40b8-9c88-38928fe68f07)

If we need to connect to the AWS RDS instance, we can do `./bin/db-connect prod`, so as for the other bash scripts.

## Implement a Postgres Client
The following steps were taken to implement the postgres client
* Adding `psycopg[binary]` and `psycopg[pool]` to `backend-flask/requirements.txt`
* Setting the environment variable `CONNECTION_URL: "postgresql://postgres:password@db:5432/cruddur"` for our backend-flask application in `docker-compose.yml`
* Creating `backend-flask/lib/db.py` for DB object and connection pool
* Replacing our mock endpoint with real api call in `backend-flask/services/home_activities.py`

After composing up the docker, we can see that the home page shows the activity specified in the `backend-flask/db/seed.sql`, instead of our previous mock data.

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/e5000645-7729-417c-9925-04b3268f1f69)

## AWS Lambda for Cognito Post Confirmation

In the production mode that we work with the AWS RDS instance instead of local postgres, when there is a new user signed up, the user should be inserted into the table of users. We can implement a AWS Lambda that runs in a VPC and commits code to RDS.

As seen in [this commit](https://github.com/beiciliang/aws-bootcamp-cruddur-2023/commit/11f2c91073dcfba165508eb6e3c28d15a9d1e332), we need to:

- In AWS Lambda, I created a Lambda function named `cruddur-post-confirmation`, and deploy the code source as seen in `aws/lambdas/cruddur-post-confirrmation.py`
- In the environment variables under the configuration tab, add a new one where the key is `CONNECTION_URL` and the value equals to our `PROD_CONNECTION_URL`
- Due to AWS Lambda missing the required PostgreSQL libraries in the AMI image, we needed to compile psycopg2 with the PostgreSQL libpq.so library statically linked libpq library instead of the default dynamic link. To make it simple, we can add a layer for psycopg2 by specifying an ARN. In my case, I used `arn:aws:lambda:us-east-1:779807585772:layer:psycopg2-py38:2`
- In Amazon Cognito > User pools > cruddur-user-pool, add lambda trigger under the user pool properties tab, where the trigger type is sign-up post confirmation, and the lambda function is assigned with our `cruddur-post-confirmation`; delete the existing user so we can later sign up again and see if it's inserted into our RDS instance's users table.
- In AWS Lambda's configurations tab, I added permissions to the execution role, so it can access EC2. This can be done by creating a policy named `AWSLambdaVPCAccessExecutionRole` in IAM > Policies, where the policy is specified by [json](https://stackoverflow.com/questions/41177965/aws-lambdathe-provided-execution-role-does-not-have-permissions-to-call-describ). Then we can add permissions to the execution role by attaching the created policy as seen in the screenshot below.
- In AWS Lambda's configurations tab, edit VPC so that Lambda is connected with the VPC to access the RDS instance. Then the page is shown as the screenshot below.

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/abdc1a54-e118-47cf-a5d7-0976dd642b73)
The permissions given to this lambda can be seen below:
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/a8a3d158-43af-4196-b4bc-cdce15d6442c)


### Create Activities

To insert the created activities into the table, we need to work with PSQL json functions to directly return json from the database, and correctly sanitize parameters passed to SQL to execute.

From the [commit link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/69f5cd3722336ce3de1e93e352a50f823ae4072e), I:

- Changed `backend-flask/services/create_activity.py` and `backend-flask/services/home_activities.py` to execute SQL commands and save the results for display
- Related SQL commands are saved in `create.sql`, `home.sql`, and `object.sql` under `backend-flask/db/sql/activities/`

Which successfully let me CRUD and create new activities.

