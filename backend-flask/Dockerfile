FROM python:3.10-slim-buster

#
WORKDIR /backend-flask

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

#Outside Container -> Inside container
# . means everything in the directory
# first period . - /backend-flask (outside container)
#
COPY . .

ENV FLASK_ENV=development

EXPOSE ${PORT}
CMD [ "python3", "-m" , "flask", "run", "--host=0.0.0.0", "--port=4567"]