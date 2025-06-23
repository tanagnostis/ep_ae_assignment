# ep_ae_assignment

Instructions:

1) Using terminal run:
   git clone git@github.com:tanagnostis/ep_ae_assignment.git
3) To setup the PostgreSQL database and Metabase visualization tool, run the following in terminal:
   docker compose up -d --build
4) To create the tables in the database and populate them with data, just run the Jupyter notebook dataset_exploration in the directory code.
5) In the sql directory, I have all the DDLs for the tables and materialized view as well as the queries for the KPIs.
6) For the visualization, I have created a public link:
   http://localhost:3000/public/question/ec3d660c-ee8d-4d3c-8a10-7eb6f5dfd527
