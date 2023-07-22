# Week 2 — Distributed Tracing
## Honeycomb Implementation
### Instrument Honeycomb with OTEL
* Create an environment called "Bootcamp" and export the "API KEY" environment variable in Gitpod.  
```APIKEY
export HONEYCOMB_API_KEY="my api key"
gp env HONEYCOMB_API_KEY="my api key"
```
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/b8dc7201-0a3e-4239-86a0-981e1513f6f1)
---------------
* Added OpenTelemetry to backend enviornment variables in docker-compose.yml  
![222496226-8e51b3e3-63ba-4834-b8ea-13734a89ae8b](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/279c72b8-e865-413a-8b49-b8fc08ec564a)

![image](https://user-images.githubusercontent.com/105418424/222496226-8e51b3e3-63ba-4834-b8ea-13734a89ae8b.png)
---------------
* Added opentelemetry modules into `requirements.txt` file  
![222496226-8e51b3e3-63ba-4834-b8ea-13734a89ae8b](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/265f3e54-2491-4e2c-a12e-65f69a66609b)

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/ef5e144a-5a5e-4a9e-a281-92a5506c5418)
---------------
* Install requirements 
``` Install reqs
cd backend-flask/
pip install -r requirements.txt
```
* After running compose up, I could see traces.
- Here's a summary/sample of *backend-flask* dataset traces

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/50fb4af9-6798-4a38-8dfa-1ebba8711600)

---------------
* After adding span attributes "app now" and "app results length" in `home_activities.py`  
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/014a4405-f602-4d7f-98ae-6f24c3d96497)

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/e64f823f-ece6-4c68-b8ca-7a28b25612b1)

---------------
## Instrument AWS X-Ray for Flask
* Added ``aws-xray-sdk`` to `requirements.txt`

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/40c0a595-8809-4409-9069-c43173dc5894)

---------------
* Install requirements 
``` Install reqs
cd backend-flask/
pip install -r requirements.txt
```
---------------
* Instrumenting X-Ray in flask app.py
* I follwed the video instructions and added the following code into my `app.py`
``` python
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.ext.flask.middleware import XRayMiddleware

xray_url = os.getenv("AWS_XRAY_URL")
xray_recorder.configure(service='backend-flask', dynamic_naming=xray_url)
XRayMiddleware(app, xray_recorder)
```

---------------
#### Setup AWS X-Ray Resources
* Adding a json file in `aws/json/xray.json` with sampling rule data
``` json
{
    "SamplingRule": {
        "RuleName": "Cruddur",
        "ResourceARN": "*",
        "Priority": 9000,
        "FixedRate": 0.1,
        "ReservoirSize": 5,
        "ServiceName": "backend-flask",
        "ServiceType": "*",
        "Host": "*",
        "HTTPMethod": "*",
        "URLPath": "*",
        "Version": 1
    }
  }
  ```
[Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/e1eb7f19156996da1f91e061a1a90021ea6e72b8 "Commit Link")

---------------
* Creating a group named `Cruddur`
``` CMD
aws xray create-group \
   --group-name "Cruddur" \
   --filter-expression "service(\"$FLASK_ADDRESS\")
```

* Creating the sampling rule using json file created earlier
``` cmd
aws xray create-sampling-rule --cli-input-json file://aws/json/xray.json
```
---------------
* After that, I added X-RAY Deamon Service to `docker-compose.yml`
``` yaml
  xray-daemon:
    image: "amazon/aws-xray-daemon"
    environment:
      AWS_ACCESS_KEY_ID: "${AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY: "${AWS_SECRET_ACCESS_KEY}"
      AWS_REGION: "us-east-1"
    command:
      - "xray -o -b xray-daemon:2000"
    ports:
      - 2000:2000/udp
```
* And addied the X-RAY env. vars to `docker-compose.yml`
``` yaml
    AWS_XRAY_URL: "*4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}*"
    AWS_XRAY_DAEMON_ADDRESS: "xray-daemon:2000"
```
[Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/e1eb7f19156996da1f91e061a1a90021ea6e72b8 "Commit Link")

## Instrument AWS X-Ray Subsegments
* After watching Andrew Brown solving instrument subsegments (and thanks to olley's blog as well)

Using X-Ray recorder ***capture*** in `app.py`  
```py
@xray_recorder.capture('activities_home')
```
```py
@xray_recorder.capture('activities_users')
``` 
```py
@xray_recorder.capture('activities_show')
```

[Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/e1eb7f19156996da1f91e061a1a90021ea6e72b8)

---------------
### Added subsegment
* Then I added the `mock-data` subsegment to `user_activities.py`  
```py
subsegment = xray_recorder.begin_subsegment('mock-data')
          # xray ---
      dict = {
        "now": now.isoformat(),
        "results-size": len(model['data'])
      }
      subsegment.put_metadata('key', dict, 'namespace')
      xray_recorder.end_subsegment()
    finally:  
    #  # Close the segment
      xray_recorder.end_subsegment()
```
[Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/c3307ea9fa47510235f618dbbb0245c2df4ce33f)

## CloudWatch Logs
* Added ***watchtower*** to `requirements.txt`
---------------
* Install requirements 
``` Install reqs
cd backend-flask/
pip install -r requirements.txt
```
---------------
#### CloudWatch configurations (I implemented it all, then commented all realted line to avoid unwanted extra costs)
* *I committed all changes in single commit*
  ** (CloudWatch instrumentation in `app.py`, set env. vars in `docker-compose.yml`,
  **Added ***watchtower*** to `requirements.txt`,
  **and added logger in `home_activities.py` )

[[Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/8335af1641aa993405352108b793ee581e83ee22 "Commit Link")
](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/8335af1641aa993405352108b793ee581e83ee22)
* And I got logs from our log group *"cruddur"*

## Rollbar
* Created a new project "FirstProject" name by default and selected Flask.

* Added ***blinker*** and ***rollbar*** to `requirements.txt`  
[Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/ef60d2e1ce42e556e244f0e6dbc8a0ae7650b4a1 "Commit Link")  
* Install requirements 
``` Install reqs
cd backend-flask/
pip install -r requirements.txt
```
---------------
* Set Access token env. variable
``` cmd
export ROLLBAR_ACCESS_TOKEN=""
gp env ROLLBAR_ACCESS_TOKEN=""
```
---------------
* Added Rollbar access token to backend env. vars in `docker-compose.yml`

[Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/cc4c6d13cc1380f36116863ed6f4b5d819e8e7bd "Commit Link")

---------------
* Added Rollbar to `app.py`  

``` python
import rollbar
import rollbar.contrib.flask
from flask import got_request_exception
```

```python
rollbar_access_token = os.getenv('ROLLBAR_ACCESS_TOKEN')
with app.app_context():
  def init_rollbar():
      """init rollbar module"""
      rollbar.init(
          # access token
          rollbar_access_token,
          # environment name
          'production',
          # server root directory, makes tracebacks prettier
          root=os.path.dirname(os.path.realpath(__file__)),
          # flask already sets up logging
          allow_logging_basic_config=False)

      # send exceptions from `app` to rollbar, using flask's signal system.
      got_request_exception.connect(rollbar.contrib.flask.report_exception, app)
```
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/aa4e5ace-b95b-4bdf-a225-59784a4520be)

* Added endpoint for testing
```python
@app.route('/rollbar/test')
def rollbar_test():
    rollbar.report_message('Hello World!', 'warning')
    return "Hello World!"
```

[Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/c43b0258dbd35b7d3043f454a501d03083d36ebf "Commit Link")

---------------
* Test endpoint URL `https://4567-${GITPOD_WORKSPACE_ID}.${GITPOD_WORKSPACE_CLUSTER_HOST}/rollbar/test`  
* Successfully can see the error in the code or errors logging in rollbar is alright and still showing well.

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/e396a2c9-1d5f-4bf8-ae23-9e825335fb40)


---------------

#### Testing errors of the app, it is showing up... No problem✌️:

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/d5797bde-cfe4-4235-a697-59d71f25c1f7)
