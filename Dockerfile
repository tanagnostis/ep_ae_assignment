# set the base image with specific tag/version
FROM python:3.10.11

# set up working directory inside the container
WORKDIR /app

# copy and run the requirements.txt file to install the required packages.
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# copy files from  directory to the image's filesystem
COPY . /app

# start cron in foreground and set it as executable command for when the container starts 
CMD ["python", "ETL_pipeline.py"]